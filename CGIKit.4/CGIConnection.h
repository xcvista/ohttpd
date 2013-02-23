//
//  CGIConnection.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

@class GCDAsyncSocket, CGIResponse;

static NSString *const CGIConnectionRequestSiteNotification = @"tk.maxius.ohttpd.incoming";
static NSString *const CGIConnectionRequestKey = @"request";

@interface CGIConnection : NSObject

- (id)initWithSocket:(GCDAsyncSocket *)socket;
- (void)postResponse:(CGIResponse *)response;

@end

CGIEndDecls