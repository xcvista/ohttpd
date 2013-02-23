//
//  CGISite.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGISite.h"
#import "CGIConnection.h"
#import "CGIRequest.h"
#import "CGIResponse.h"
#import "CGIModule.h"
#import "CGIServer.h"
#import "NSFileManager+Directory.h"

@interface CGISite ()

@property NSArray *_indexPages;

@end

@implementation CGISite

- (id)initWithConfig:(NSDictionary *)configure
{
    if (!configure)
        return nil;
    
    if (self = [super init])
    {
        self.documentRoot = configure[@"CGIDocumentRoot"];
        self.listenPort = [configure[@"CGIListen"] unsignedIntegerValue];
        self.listenHost = configure[@"CGIHost"];
        self.listing = [configure[@"CGIListing"] boolValue];
        self._indexPages = configure[@"CGIIndexPages"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_tryHandle:)
                                                     name:CGIConnectionRequestSiteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:CGISiteConflictionDetectionNotification
                                                            object:self
                                                          userInfo:@{@"host": self.listenHost,
                                                                     @"port": @(self.listenPort)}];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_hasConflict:)
                                                     name:CGISiteConflictionDetectionNotification
                                                   object:nil];
        CGILog(@"Site %@:%li loaded", CGILogPriorityInformative, self.listenHost, self.listenPort);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)localPathForPath:(NSString *)path
{
    NSString *_path = ([path hasPrefix:@"/"]) ? [path substringFromIndex:1] : path;
    return [self.documentRoot stringByAppendingPathComponent:_path];
}

- (NSURL *)localURLForPath:(NSString *)path
{
    NSString *_path = ([path hasPrefix:@"/"]) ? [path substringFromIndex:1] : path;
    return [NSURL URLWithString:_path relativeToURL:[NSURL URLWithString:NSprintf(@"file://localhost%@/", self.documentRoot)]];
}

- (void)_tryHandle:(NSNotification *)aNotification
{
    CGIRequest *request = [aNotification userInfo][CGIConnectionRequestKey];
    
    if ([request requestPort] == self.listenPort)
    {
        if ([self.listenHost isEqual:@"*"] || [self.listenHost isEqual:[request requestHost]])
        {
            [self _handle:request response:[[CGIResponse alloc] initWithRequest:request] sender:[aNotification object]];
        }
    }
}

- (void)_handle:(CGIRequest *)request response:(CGIResponse *)response sender:(CGIConnection *)sender
{
    NSURL *requestedURL = [request requestURL];
    NSURL *localURL = [self localURLForPath:[requestedURL path]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    id<CGIModule> __weak module = [[CGIServer server] moduleForLocalURL:localURL];
    if (module)
        [module processRequest:request response:response site:self];
    else if ([fileManager isDirectoryAtPath:[localURL path]])
    {
        BOOL processed = NO;
        for (NSString *index in self._indexPages)
        {
            NSString *newLocal = [[localURL path] stringByAppendingPathComponent:index];
            if ([fileManager fileExistsAtPath:newLocal] && (module = [[CGIServer server] moduleForLocalURL:[NSURL URLWithString:NSprintf(@"file://localhost%@", newLocal)]]))
            {
                request.requestURI = [request.requestURI stringByAppendingPathComponent:index];
                [module processRequest:request response:response site:self];
                processed = YES;
                break;
            }
        }
        if (!processed)
        {
            module = [[CGIServer server] moduleForListing];
            [module processRequest:request response:response site:self];
        }
    }
    else if (![fileManager fileExistsAtPath:[localURL path]])
    {
        response.responseStatus = 404;
        response.responseFields[@"Connection"] = @"Close";
        response.responseData =
        [@"<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "<title>HTTP/1.1 404</title>\n"
         "</head>\n"
         "<body>\n"
         "<h1>HTTP/1.1 404 Not Found</h1>\n"
         "<p>You are asking for a nonexistant resource.</p>\n"
         "<hr />\n"
         "<address>ohttpd/1.0</address>\n"
         "</body>\n"
         "</html>\n" dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        response.responseStatus = 403;
        response.responseFields[@"Connection"] = @"Close";
        response.responseData =
        [@"<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "<title>HTTP/1.1 403</title>\n"
         "</head>\n"
         "<body>\n"
         "<h1>HTTP/1.1 403 Forbidden</h1>\n"
         "<p>You are not allowed to access this location.</p>\n"
         "<p>To admin: no module for this URL is found.</p>\n"
         "<hr />\n"
         "<address>ohttpd/1.0</address>\n"
         "</body>\n"
         "</html>\n" dataUsingEncoding:NSUTF8StringEncoding];
    }
    [sender postResponse:response];
}

- (void)_hasConflict:(NSNotification *)aNotification
{
    NSString *host = [aNotification userInfo][@"host"];
    NSNumber *port = [aNotification userInfo][@"port"];
    
    if ([port isEqual:@(self.listenPort)])
    {
        if ([self.listenHost isEqual:@"*"] || [host isEqual:@"*"] || [self.listenHost isEqual:host])
        {
            CGILog(@"Conflict: %@:%@ vs %@:%@", CGILogPriorityWarning, self.listenHost, @(self.listenPort), host, port);
        }
    }
}

@end
