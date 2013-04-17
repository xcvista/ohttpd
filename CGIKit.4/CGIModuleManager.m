//
//  CGIModuleManager.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-3-8.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIModuleManager.h"
#import "CGIRequest.h"
#import "CGIResponse.h"
#import "CGISite.h"

@interface CGIModuleManager ()

@property NSString *_moduleRoot;
@property NSArray *_moduleBinding;
@property NSMutableDictionary *_loadedModules;

@end

@implementation CGIModuleManager

- (id)initWithModuleConfigure:(NSDictionary *)moduleConfigure
{
    if (self = [super init])
    {
        self._moduleRoot = moduleConfigure[@"CGIMoguleRoot"];
        self._moduleBinding = moduleConfigure[@"CGIModuleBinding"];
        self._loadedModules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)tryHandleRequest:(CGIRequest *)request
                response:(CGIResponse *)response
                    site:(CGISite *)site
              keepBundle:(BOOL)keep
{
    // Tell if there is any bundles in it.
    NSArray *pathElements = [[request requestURL] pathComponents];
    if ([pathElements count] > 1)
    {
        pathElements = [pathElements subarrayWithRange:NSMakeRange(1, [pathElements count] - 1)];
    }
    else
    {
        if (self._loadedModules[@""])
        {
            
        }
        NSBundle *bundle = [NSBundle bundleWithURL:[site localURLForPath:@""]];
        if (bundle)
        {
            BOOL okay = NO;
            BOOL _keep = keep;
            [bundle load];
            if ([[bundle principalClass] conformsToProtocol:@protocol(CGIBundle)])
            {
                id<CGIBundle> object = [[[bundle principalClass] alloc] init];
                okay = [object processRequest:request
                                     response:response
                                         site:site];
                _keep = _keep && [object canUnload];
            }
            if (_keep)
            {
                
            }
        }
    }
}

@end
