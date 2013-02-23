//
//  CGIModule.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <CGIKit/CGIDecls.h>

CGIBeginDecls

@class CGIRequest, CGIResponse, CGISite;

@protocol CGIBundle <NSObject>

- (void)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site;

@optional
- (BOOL)canUnload __attribute__((deprecated));
- (void)willUnload __attribute__((deprecated));

@end

@protocol CGIModule <CGIBundle>

- (BOOL)canProcessLocalURL:(NSURL *)URL;

@end

CGIEndDecls
