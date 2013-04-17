//
//  CGIServer.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-16.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

@class CGIConnection, CGIModuleManager;
@protocol CGIModule;

static NSString *const CGIServerStoppingNotification = @"tk.maxius.ohttpd.closing";

@interface CGIServer : NSObject

+ (CGIServer *)server; // The singleton server object.

// Start the server. I used this so that all code could be run in an OO environ-
// ment. It will exit upon being notified using exit(3). Logging is done using
// NSLog.
- (void)launch __attribute__((__noreturn__));
- (CGILogPriority)logPriority;
- (void)stop;
- (void)addConnection:(CGIConnection *)connection;
- (void)removeConnection:(CGIConnection *)connection;
- (CGIModuleManager *)moduleManager;

@end

CGIEndDecls
