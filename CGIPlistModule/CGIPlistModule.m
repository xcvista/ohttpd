//
//  CGIPlistModule.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIPlistModule.h"

@implementation CGIPlistModule

- (BOOL)canProcessLocalURL:(NSURL *)URL
{
    NSData *data = [NSData dataWithContentsOfURL:URL];
    id plist = [NSPropertyListSerialization propertyListWithData:data
                                                         options:0
                                                          format:NULL
                                                           error:NULL];
    return (plist != nil);
}

- (NSString *)HTMLForPlist:(id)plist
{
    NSString *returnString = @"";
    if ([plist isKindOfClass:[NSDictionary class]])
    {
        returnString = NSprintf(@"<table>\n"
                                "<tr><th colspan=\"2\">%@</th></tr>\n"
                                "<tr><th>Key</th><th>Value</th>\n", NSStringFromClass([plist class]));
        for (id key in plist)
        {
            returnString = NSstrcatf(returnString, @"<tr><td>%@</td><td>%@</td>\n",
                                     [self HTMLForPlist:key], [self HTMLForPlist:plist[key]]);
        }
        returnString = NSstrcatf(returnString, @"</table>\n");
    }
    else if ([plist isKindOfClass:[NSArray class]])
    {
        returnString = NSprintf(@"<table>\n"
                                "<tr><th colspan=\"2\">%@</th></tr>\n"
                                "<tr><th>#</th><th>Value</th>\n", NSStringFromClass([plist class]));
        for (NSUInteger i = 0; i < [plist count]; i++)
        {
            returnString = NSstrcatf(returnString, @"<tr><td>%li</td><td>%@</td>\n",
                                     i, [self HTMLForPlist:plist[i]]);
        }
        returnString = NSstrcatf(returnString, @"</table>\n");
    }
    else if ([plist isKindOfClass:[NSData class]])
        returnString = NSprintf(@"<table>\n"
                                "<tr><th rowspan=\"2\">%@</th><td><pre>%@</pre></td></tr>\n"
                                "<tr><td><pre>%@</pre></tr>\n"
                                "</table>\n",
                                NSStringFromClass([plist class]), [plist description], [[NSString alloc] initWithData:plist encoding:NSUTF8StringEncoding]);
    else
        returnString = NSprintf(@"<em>%@</em>: <pre>%@</pre>", NSStringFromClass([plist class]), plist);
    return returnString;
}

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site
{
    NSString *localPath = [[site localURLForPath:[[request requestURL] path]] path];
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    id plist = [NSPropertyListSerialization propertyListWithData:data
                                                         options:0
                                                          format:NULL
                                                           error:NULL];
    NSString *outputString = NSprintf(@"<!DOCTYPE html>\n"
                                      "<html>\n"
                                      "<head>\n"
                                      "<title>CGIInfo</title>\n"
                                      "<style type=\"text/css\">\n"
                                      "%@"
                                      "</style>\n"
                                      "</head>\n"
                                      "<body>\n"
                                      "%@\n"
                                      "<hr />\n"
                                      "<address>CGIInfo.bundle 1.0</address>\n"
                                      "</body>\n"
                                      "</html>\n",
                                      [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"style"
                                                                                                                          ofType:@"css"]
                                                                encoding:NSUTF8StringEncoding error:NULL],
                                      [self HTMLForPlist:plist]);
    response.responseData = [outputString dataUsingEncoding:NSUTF8StringEncoding];
    response.responseFields[@"Connection"] = @"Close";
    
}

@end
