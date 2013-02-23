//
//  NSFileManager+Directory.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "NSFileManager+Directory.h"

@implementation NSFileManager (Directory)

- (BOOL)isDirectoryAtPath:(NSString *)path
{
    BOOL dir = NO;
    if (![self fileExistsAtPath:path isDirectory:&dir])
        return NO;
    else
        return dir;
}

@end
