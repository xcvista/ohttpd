//
//  CGIBundleModule.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIBundleModule.h"

@implementation CGIBundleModule

- (BOOL)canProcessLocalURL:(NSURL *)URL
{
    NSBundle *bundle = [NSBundle bundleWithURL:URL];
    if (!bundle)
        return NO;
    if ([[bundle principalClass] conformsToProtocol:@protocol(CGIBundle)])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site
{
    NSString *localLocation = [[site localURLForPath:[[request requestURL] path]] path];
    NSBundle *bundle = [NSBundle bundleWithPath:localLocation];
    id<CGIBundle> module = [[[bundle principalClass] alloc] init];
    [module processRequest:request response:response site:site];
}

@end
