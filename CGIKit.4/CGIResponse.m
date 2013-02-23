//
//  CGIResponse.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIResponse.h"
#import "CGIRequest.h"

NSString *CGIDefaultResponseStatusName(NSUInteger status)
{
    static NSDictionary *statuses;
    if (!statuses)
        statuses = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle bundleForClass:[CGIResponse class]] URLForResource:@"status" withExtension:@"plist"]];
    return statuses[NSprintf(@"%li", status)];
}

@implementation CGIResponse

- (id)initWithRequest:(CGIRequest *)request
{
    if (self = [super init])
    {
        self.protocolVersion = request.protocolVersion;
        self.responseFields = [NSMutableDictionary dictionary];
        self.responseStatus = 200;
        self.responseFields[@"Content-Type"] = @"text/html; charset=utf-8";
        self.responseFields[@"Server"] = @"ohttpd 1.0";
        
        if (request.requestFields[@"Connection"])
            self.responseFields[@"Connection"] = request.requestFields[@"Connection"];
        
        // Make the date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
        NSLog(@"Date: %@", self.responseFields[@"Date"] = [dateFormatter stringFromDate:[NSDate date]]);
    }
    return self;
}

- (NSData *)responsePacket
{
    if ([self.responseData length])
        self.responseFields[@"Length"] = NSprintf(@"%li", [self.responseData length]);
    if (![self.responseStatusName length])
        self.responseStatusName = CGIDefaultResponseStatusName(self.responseStatus);
    
    NSString *headerLine = NSprintf(@"%@ %li %@", self.protocolVersion, self.responseStatus, self.responseStatusName);
    NSString *headers = @"";
    for (NSString *key in self.responseFields)
        headers = [headers stringByAppendingFormat:@"%@: %@\r\n", key, self.responseFields[key]];
    NSData *headerData = [NSprintf(@"%@\r\n%@\r\n", headerLine, headers) dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *returnData = [NSMutableData dataWithCapacity:[headerData length] + [self.responseData length]];
    [returnData appendData:headerData];
    [returnData appendData:self.responseData];
    return [returnData copy];
}

@end
