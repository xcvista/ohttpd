//
//  CGIDecls.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#ifndef CGIKit_4_CGIDecls_h
#define CGIKit_4_CGIDecls_h

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define CGIBeginDecls extern "C" {
#define CGIEndDecls }
#else
#define CGIBeginDecls
#define CGIEndDecls
#endif

#define NSprintf(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define NSstrcatf(string, format, ...) [(string) stringByAppendingFormat:(format), ##__VA_ARGS__]

typedef NS_ENUM(NSUInteger, CGILogPriority)
{
    CGILogPriorityDebug,
    CGILogPriorityInformative,
    CGILogPriorityWarning,
    CGILogPriorityError,
    CGILogPriorityPanic
};

NS_FORMAT_FUNCTION(1, 3) void CGILog(NSString *format, CGILogPriority priority, ...);
void CGILogv(NSString *format, CGILogPriority priority, va_list args);
NS_FORMAT_FUNCTION(1, 2) __attribute__((__noreturn__)) void CGIPanic(NSString *format, ...);
__attribute__((__noreturn__)) void CGIPanicv(NSString *format, va_list args);

#endif
