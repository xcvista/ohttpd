//
//  CGIModuleManager.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-3-8.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>
#import <CGIKit/CGIModule.h>

CGIBeginDecls

@class CGIRequest, CGIResponse, CGISite;

@interface CGIModuleManager : NSObject

- (id)initWithModuleConfigure:(NSDictionary *)moduleConfigure;

- (BOOL)tryHandleRequest:(CGIRequest *)request
                response:(CGIResponse *)response
                    site:(CGISite *)site
              keepBundle:(BOOL)keep;

@end

CGIEndDecls
