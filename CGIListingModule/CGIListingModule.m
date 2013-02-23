//
//  CGIListingModule.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIListingModule.h"
#import <CGIKit/NSFileManager+Directory.h>

@implementation CGIListingModule

- (BOOL)canProcessLocalURL:(NSURL *)URL
{
    return [[NSFileManager defaultManager] isDirectoryAtPath:[URL path]];
}

- (BOOL)canUnload
{
    return NO;
}

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site
{
    if ([request.method isEqualToString:@"GET"])
    {
        if (![request.requestURI hasSuffix:@"/"])
        {
            [response.responseFields removeAllObjects];
            response.responseFields[@"Location"] = NSstrcatf([[request requestURL] path], @"/");
            response.responseStatus = 302;
        }
        else
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *remotePath = [[request requestURL] path];
            NSString *localPath = [[site localURLForPath:[[request requestURL] path]] path];
            NSArray *localObjects = [fileManager contentsOfDirectoryAtPath:localPath error:NULL];
            NSString *finalString = NSprintf(@"<!DOCTYPE html>\n"
                                             "<html>\n"
                                             "<head>\n"
                                             "<title>%@</title>\n"
                                             "</head>\n"
                                             "<body>\n"
                                             "<h1><pre>%@</pre></h1>\n"
                                             "<hr />\n"
                                             "<ul>\n", remotePath, remotePath);
            if ([remotePath compare:@"/"] != NSOrderedSame)
                finalString = NSstrcatf(finalString, @"<li><a href=\"..\">.. (Parent)</a></li>\n");
            if (![localObjects count])
                finalString = NSstrcatf(finalString, @"<li>There is no content under this directory.</li>\n");
            else
            {
                for (NSString *object in localObjects)
                {
                    NSString *objectDisp = [fileManager isDirectoryAtPath:[localPath stringByAppendingPathComponent:object]] ? ([NSBundle bundleWithPath:[localPath stringByAppendingPathComponent:object]] ? object : NSstrcatf(object, @"/")) : object;
                    finalString = NSstrcatf(finalString, @"<li><a href=\"%@\"><pre>%@</pre></a></li>\n", objectDisp, objectDisp);
                }
            }
            finalString = NSstrcatf(finalString, @"</ul>\n"
                                    "<hr />\n"
                                    "<address>ohttpd/1.0 Module CGIListingModule</address>\n"
                                    "</body>\n"
                                    "</html>\n");
            response.responseData = [finalString dataUsingEncoding:NSUTF8StringEncoding];
            response.responseFields[@"Connection"] = @"Close";
        }
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
