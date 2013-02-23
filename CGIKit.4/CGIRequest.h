//
//  CGIRequest.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

@interface CGIRequest : NSObject

@property NSString *method;
@property NSString *requestURI;
@property NSString *protocolVersion;
@property NSDictionary *requestFields;
@property NSData *requestContent;

- (NSUInteger)requestPort;
- (NSString *)requestHost;
- (NSURL *)requestURL;

@end

CGIEndDecls
