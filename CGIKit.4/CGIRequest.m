//
//  CGIRequest.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIRequest.h"

@implementation CGIRequest

- (NSString *)description
{
    return NSprintf(@"%@: %@ %@ %@\n%@\n%@", [super description], self.method, self.requestURI, self.protocolVersion, self.requestFields, self.requestContent);
}

- (NSString *)requestHost
{
    NSRange colon = [self.requestFields[@"Host"] rangeOfString:@":"];
    NSString *host = (colon.location == NSNotFound) ? self.requestFields[@"Host"] : [self.requestFields[@"Host"] substringToIndex:colon.location];
    return [host stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSUInteger)requestPort
{
    NSRange colon = [self.requestFields[@"Host"] rangeOfString:@":"];
    return (colon.location == NSNotFound) ? 80 : [[self.requestFields[@"Host"] substringFromIndex:NSMaxRange(colon)] integerValue];
}

- (NSURL *)requestURL
{
    return [NSURL URLWithString:NSprintf(@"http://%@%@", self.requestFields[@"Host"], self.requestURI)];
}

@end
