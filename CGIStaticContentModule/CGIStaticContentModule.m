//
//  CGIStaticContentModule.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIStaticContentModule.h"
#import <CGIKit/NSFileManager+Directory.h>

@implementation CGIStaticContentModule

- (BOOL)canProcessLocalURL:(NSURL *)URL
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[URL path]] && ![[NSFileManager defaultManager] isDirectoryAtPath:[URL path]];
}

- (BOOL)canUnload
{
    return NO;
}

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site
{
    if ([request.method isEqualToString:@"GET"])
    {
        static NSDictionary *MIMEs;
        if (!MIMEs)
            MIMEs = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"mime" withExtension:@"plist"]];
        NSString *localPath = [[site localURLForPath:[[request requestURL] path]] path];
        NSString *MIME = MIMEs[[localPath pathExtension]];
        if (!MIME)
            MIME = @"application/octect-stream";
        response.responseData = [NSData dataWithContentsOfFile:localPath];
        response.responseFields[@"Connection"] = @"Close";
    }
    else if ([request.method isEqualToString:@"HEAD"])
    {
        static NSDictionary *MIMEs;
        if (!MIMEs)
            MIMEs = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"mime" withExtension:@"plist"]];
        NSString *localPath = [[site localURLForPath:[[request requestURL] path]] path];
        NSString *MIME = MIMEs[[localPath pathExtension]];
        if (!MIME)
            MIME = @"application/octect-stream";
        response.responseFields[@"Connection"] = @"Close";
    }
    else
    {
        response.responseStatus = 405;
        response.responseFields[@"Connection"] = @"Close";
        response.responseData =
        [@"<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "<title>HTTP/1.1 405</title>\n"
         "</head>\n"
         "<body>\n"
         "<h1>HTTP/1.1 405 Method Not Allowed</h1>\n"
         "<p>The method you used is not accepted.</p>\n"
         "<hr />\n"
         "<address>ohttpd/1.0</address>\n"
         "</body>\n"
         "</html>\n" dataUsingEncoding:NSUTF8StringEncoding];
    }
}

@end
