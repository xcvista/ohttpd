//
//  CGIResponse.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

NSString *CGIDefaultResponseStatusName(NSUInteger status);

@class CGIRequest;

@interface CGIResponse : NSObject

@property NSUInteger responseStatus;
@property NSString *responseStatusName;
@property NSString *protocolVersion;
@property NSMutableDictionary *responseFields;
@property NSData *responseData;

- (id)initWithRequest:(CGIRequest *)request;
- (NSData *)responsePacket;

@end

CGIEndDecls
