//
//  CGIServer.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-16.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIServer.h"
#import "CGIListener.h"
#import "CGISite.h"
#import "NSFileManager+Directory.h"
#import "CGIModule.h"
#import "CGIModuleManager.h"

static __strong CGIServer *CGIDefaultServer;

@interface CGIServer ()

@property NSDictionary *_config;

@property NSMutableArray *_connections;
@property NSMutableArray *_listeners;
@property NSMutableArray *_sites;
@property CGIModuleManager *moduleManager;
@property BOOL running;

- (void)_panic __attribute__((__noreturn__));
- (void)_stop __attribute__((__noreturn__));

- (void)_launch:(id)object __attribute__((__noreturn__));

@end

void CGILog(NSString *format, CGILogPriority priority, ...)
{
    va_list args;
    va_start(args, priority);
    CGILogv(format, priority, args);
    va_end(args);
}

void CGILogv(NSString *format, CGILogPriority priority, va_list args)
{
    NSArray *adverbs = @[@"DEBUG", @"INFO", @"WARNING", @"ERROR", @"PANIC"];
    if (priority >= ((CGIDefaultServer) ? [[CGIServer server] logPriority] : 0))
        NSLogv([NSString stringWithFormat:@"%@: %@", adverbs[priority], format], args);
}

void CGIPanic(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    CGIPanicv(format, args);
    va_end(args);
}

void CGIPanicv(NSString *format, va_list args)
{
    CGILogv(format, CGILogPriorityPanic, args);
    if (CGIDefaultServer)
        [[CGIServer server] _panic];
    else
        abort();
    __builtin_unreachable();
}

@implementation CGIServer

+ (CGIServer *)server
{
    if (!CGIDefaultServer)
    {
        CGIDefaultServer = [[self alloc] init];
    }
    return CGIDefaultServer;
}

- (id)init
{
    if (self = [super init])
    {
        NSArray *defaultConfigureFileLocations = @[@"ohttpd.plist", @"/etc/ohttpd/ohttpd.plist"];
        for (NSString *location in defaultConfigureFileLocations)
            if ((self._config = [NSDictionary dictionaryWithContentsOfFile:location]))
                break;
        if (!self._config)
            CGIPanic(@"Configure file not found.");
    }
    return self;
}

- (CGILogPriority)logPriority
{
    return [self._config[@"CGILogLevel"] unsignedIntegerValue];
}

- (void)launch
{
    // Should I dispatch?
    // FIXME: I cannot safely dispatch now.
    //BOOL dispatch = [self._config[@"CGIDispatch"] boolValue];
    
    //if (dispatch)
    //{
    //    CGILog(@"Dispatching into a thread.", CGILogPriorityDebug);
    //    [NSThread detachNewThreadSelector:@selector(_launch:) toTarget:self withObject:nil];
    //    exit(0);
    //}
    //else
    {
        [self _launch:nil];
    }
    __builtin_unreachable();
}

- (void)_launch:(id)object
{
    @autoreleasepool
    {
        CGILog(@"Starting server on process %u.", CGILogPriorityInformative, getpid());
        
        [[NSThread currentThread] setName:@"tk.maxius.ohttpd.server"];
        
        self.moduleManager = [[CGIModuleManager alloc] initWithModuleConfigure:self._config[@"CGIModules"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *err = nil;
        NSString *sitesRoot = self._config[@"CGIEnabledSites"];
        NSArray *subpaths = [fileManager contentsOfDirectoryAtPath:sitesRoot
                                                             error:&err];
        if (!subpaths)
            CGIPanic(@"Failed to load sites: %@", err);
        
        self._sites = [NSMutableArray array];
        NSMutableSet *portsToListen = [NSMutableSet set];
        
        for (NSString *path in subpaths)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[sitesRoot stringByAppendingPathComponent:path]];
            if (!dict)
                continue;
            CGISite *site = [[CGISite alloc] initWithConfig:dict];
            [self._sites addObject:site];
            [portsToListen addObject:@(site.listenPort)];
        }
        
        if (![self._sites count])
            CGIPanic(@"No site is loaded");
        
        self._listeners = [NSMutableArray arrayWithCapacity:[portsToListen count]];
        self._connections = [NSMutableArray array];
        
        for (NSNumber *port in portsToListen)
        {
            CGIListener *listener = [[CGIListener alloc] initWithPort:[port unsignedShortValue]];
            [self._listeners addObject:listener];
        }
        
        self.running = YES;
        CGILog(@"Server started.", CGILogPriorityInformative);
        
        while (self.running)
        {
            // I need this run loop to receive ohttpctl messages.
            [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode
                                  beforeDate:[NSDate distantFuture]];
        }
        __builtin_unreachable();
    }
}

- (void)stop
{
    [self _stop];
    exit(0);
}

- (void)addConnection:(CGIConnection *)connection
{
    [self._connections addObject:connection];
}

- (void)removeConnection:(CGIConnection *)connection
{
    [self._connections removeObject:connection];
}

- (void)_stop
{
    CGILog(@"Stopping server in 10 seconds...", CGILogPriorityInformative);
    [[NSNotificationCenter defaultCenter] postNotificationName:CGIServerStoppingNotification object:nil];
    self.running = NO;
    sleep(10);
    CGILog(@"Server stopped.", CGILogPriorityInformative);
    exit(0);
}

- (void)dealloc
{
    [self stop];
}

- (void)_panic
{
    [self _stop];
    abort(); // Maybe make it more graceful?
}

@end

