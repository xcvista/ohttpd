//
//  main.m
//  ohttpd
//
//  Created by Maxthon Chan on 13-2-16.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGIKit/CGIKit.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        [[CGIServer server] launch];
        
    }
    return EXIT_SUCCESS;
}

