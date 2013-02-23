//
//  CGISite.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

static NSString *const CGISiteConflictionDetectionNotification = @"tk.maxius.ohttpd.confavoid";

@interface CGISite : NSObject

@property NSString *listenHost;
@property NSUInteger listenPort;
@property BOOL listing;
@property NSString *documentRoot;

- (id)initWithConfig:(NSDictionary *)configure;

- (NSString *)localPathForPath:(NSString *)path;
- (NSURL *)localURLForPath:(NSString *)path;

@end

CGIEndDecls
