//
//  CGIConnection.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-16.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIListener.h"
#import "GCDAsyncSocket.h"
#import "CGIServer.h"
#import "CGIConnection.h"

@interface CGIListener () <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *_socket;
@property unsigned short _port;
@property NSMutableDictionary *_sockets;
@property dispatch_queue_t _queue;

- (void)_onServerShuttingDown:(NSNotification *)aNotification;

@end

@implementation CGIListener

- (id)initWithPort:(unsigned short)port
{
    if (self = [super init])
    {
        CGILog(@"Opening port %u to listen.", CGILogPriorityDebug, port);
        self._queue = dispatch_queue_create([NSprintf(@"tk.maxius.ohttpd.listener.%u", port) cStringUsingEncoding:NSUTF8StringEncoding], 0);
        self._socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self._queue];
        NSError *err = nil;
        if (![self._socket acceptOnPort:port error:&err])
        {
            CGIPanic(@"Socket failed to bind: %@", err);
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onServerShuttingDown:) name:CGIServerStoppingNotification object:nil];
        self._port = port;
        CGILog(@"Port %u is opened for listening.", CGILogPriorityDebug, self._port);
    }
    return self;
}

- (void)_onServerShuttingDown:(NSNotification *)aNotification
{
    self._socket.delegate = nil;
    [self._socket disconnect];
    CGILog(@"Port %u is now closed.", CGILogPriorityDebug, self._port);
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    CGILog(@"Client connection [%@]:%u received.", CGILogPriorityInformative, newSocket.connectedHost, newSocket.connectedPort);
    CGIConnection *connection = [[CGIConnection alloc] initWithSocket:newSocket];
    [[CGIServer server] addConnection:connection];
}

- (void)dealloc
{
    CGILog(@"Listener object for port %u is deallocated.", CGILogPriorityDebug, self._port);
    if (self._socket.delegate)
        [self _onServerShuttingDown:nil];
    self._queue = nil;
}

@end
