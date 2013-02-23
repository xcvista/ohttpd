//
//  CGIInfo.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIInfo.h"

@implementation CGIInfo

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site
{
    if (![request.method isEqualToString:@"HEAD"])
    {
        NSString *outputString = NSprintf(@"<!DOCTYPE html>\n"
                                           "<html>\n"
                                          "<head>\n"
                                          "<title>CGIInfo</title>\n"
                                          "<style type=\"text/css\">\n"
                                          "%@"
                                          "</style>\n"
                                          "</head>\n"
                                          "<body>\n"
                                          "<h1>CGIInfo.bundle</h1>\n"
                                          "<h2>Request</h2>\n"
                                          "<table>\n"
                                          "<tr><th>Key</th><th>Value</th>\n"
                                          "<tr><td>Request</td><td>%@ %@ %@</td>\n",
                                          [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"style"
                                                                                                                              ofType:@"css"]
                                                                    encoding:NSUTF8StringEncoding error:NULL],
                                          request.method, request.requestURI, request.protocolVersion);
        for (NSString *key in request.requestFields)
            outputString = NSstrcatf(outputString, @"<tr><td>%@</td><td><pre>%@</pre></td></tr>\n",
                                     key, request.requestFields[key]);
        if ([request.requestContent length])
            outputString = NSstrcatf(outputString, @"<tr><td>Request data</td><td><pre>%@</pre><br /><pre>%@</pre></td>\n",
                                     request.requestContent, [[NSString alloc] initWithData:request.requestContent encoding:NSUTF8StringEncoding]);
        outputString = NSstrcatf(outputString, @"</table>\n"
                                 "<h2>Server</h2>"
                                 "<table>\n"
                                 "<tr><th>Key</th><th>Value</th>\n"
                                 "<tr><td>Listening</td><td>[%@]:%li</td>\n"
                                 "<tr><td>Document root</td><td>%@</td>\n"
                                 "<tr><td>Listing</td><td>%@</td>"
                                 "</table>",
                                 site.listenHost, site.listenPort, site.documentRoot, (site.listing) ? @"YES" : @"NO");
        outputString = NSstrcatf(outputString, @"<hr />\n"
                                 "<address>CGIInfo.bundle 1.0</address>\n"
                                 "</body>\n"
                                 "</html>\n");
        response.responseData = [outputString dataUsingEncoding:NSUTF8StringEncoding];
        response.responseFields[@"Connection"] = @"Close";
    }
}

@end
