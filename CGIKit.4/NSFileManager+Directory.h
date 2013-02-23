//
//  NSFileManager+Directory.h
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-23.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Directory)

- (BOOL)isDirectoryAtPath:(NSString *)path;

@end
