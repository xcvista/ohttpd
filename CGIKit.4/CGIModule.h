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

- (BOOL)processRequest:(CGIRequest *)request response:(CGIResponse *)response site:(CGISite *)site;

@optional
- (BOOL)canUnload;
- (void)willUnload;

@end

CGIEndDecls
