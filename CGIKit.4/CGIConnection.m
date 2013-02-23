//
//  CGIConnection.m
//  CGIKit.4
//
//  Created by Maxthon Chan on 13-2-17.
//  Copyright (c) 2013年 Maxthon Chan. All rights reserved.
//

#import "CGIConnection.h"
#import "GCDAsyncSocket.h"
#import "CGIServer.h"
#import <CGIKit/CGIKit.h>

typedef NS_ENUM(NSUInteger, CGIConnectionDataType)
{
    CGIConnectionRequestURI,
    CGIConnectionRequestHeader,
    CGIConnectionRequestBody
};

#define CGIConnLog(format, priority, ...) CGILog(NSprintf(@"[%@]:%u to %u: %@", self._socket.connectedHost, self._socket.connectedPort, self._socket.localPort, format), priority, ##__VA_ARGS__)

@interface CGIConnection () <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *_socket;
@property dispatch_queue_t _queue;
@property CGIRequest *_request;
@property NSMutableDictionary *_buffer;
@property CGIResponse *_response;

- (void)_connect;

@end

@implementation CGIConnection

- (id)initWithSocket:(GCDAsyncSocket *)socket
{
    if (self = [super init])
    {
        self._queue = dispatch_queue_create([NSprintf(@"tk.maxius.ohttpd.connection.%u.%u.%@", socket.localPort, socket.connectedPort, socket.connectedHost) cStringUsingEncoding:NSUTF8StringEncoding], 0);
        self._socket = socket;
        [socket synchronouslySetDelegate:self delegateQueue:self._queue];
        
        CGILog(@"Connection object %@ from [%@]:%u to %u established.", CGILogPriorityDebug, [super description], socket.connectedHost, socket.connectedPort, socket.localPort);
        
        // Do connection, async.
        [NSThread detachNewThreadSelector:@selector(_connect) toTarget:self withObject:nil];
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag)
    {
        case CGIConnectionRequestURI:
        {
            NSString *requestLine = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            CGIConnLog(@"Request: %@", CGILogPriorityDebug, requestLine);
            self._request = [[CGIRequest alloc] init];
            NSArray *parts = [requestLine componentsSeparatedByString:@" "];
            self._request.method = parts[0];
            self._request.requestURI = parts[1];
            self._request.protocolVersion = parts[2];
            [self._socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:CGIConnectionRequestHeader];
            break;
        }
        case CGIConnectionRequestHeader:
        {
            NSString *requestLine = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([requestLine length])
            {
                // Another request line.
                if (!self._buffer)
                    self._buffer = [NSMutableDictionary dictionary];
                
                // Find the first colon.
                NSRange firstColon = [requestLine rangeOfString:@":"];
                NSString *key = [[requestLine substringToIndex:firstColon.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[requestLine substringFromIndex:NSMaxRange(firstColon)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self._buffer[key] = value;
                [self._socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:CGIConnectionRequestHeader];
                break;
            }
            else
            {
                // Request is read.
                self._request.requestFields = [self._buffer copy];
                if ([self._buffer[@"Content-Length"] integerValue])
                {
                    // There is some content coming up.
                    NSUInteger contentLength = [self._buffer[@"Content-Length"] integerValue];
                    [self._socket readDataToLength:contentLength withTimeout:-1 tag:CGIConnectionRequestBody];
                }
                else
                {
                    [self _dispatchRequest];
                }
                break;
            }
        }
        case CGIConnectionRequestBody:
        {
            self._request.requestContent = [NSData dataWithData:data];
            [self _dispatchRequest];
            break;
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    CGILog(@"Connection from [%@]:%u closed.", CGILogPriorityInformative, [self._socket connectedHost], [self._socket connectedPort]);
    [[CGIServer server] removeConnection:self];
}

- (void)dealloc
{
    CGILog(@"Connection object %@ deallocated.", CGILogPriorityDebug, [super description]);
}

- (void)_connect
{
    [[NSThread currentThread] setName:NSprintf(@"tk.maxius.ohttpd.connection-controller.%u.%u.%@", self._socket.localPort, self._socket.connectedPort, self._socket.connectedHost)];
    CGIConnLog(@"Getting data.", CGILogPriorityDebug);
    [self._socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:CGIConnectionRequestURI];
}

- (void)_dispatchRequest
{
    CGILog(@"Got request:\n%@", CGILogPriorityDebug, self._request);
    if (![self._request.requestFields[@"Host"] length])
    {
        // No Host - blah, 400.
        self._response = [[CGIResponse alloc] initWithRequest:self._request];
        self._response.responseStatus = 400;
        self._response.responseFields[@"Connection"] = @"Close";
        self._response.responseData =
        [@"<!DOCTYPE html>\n"
          "<html>\n"
          "<head>\n"
          "<title>HTTP/1.1 400</title>\n"
          "</head>\n"
          "<body>\n"
          "<h1>HTTP/1.1 400 Bad Request</h1>\n"
          "<p>Your client sent a malformed request</p>\n"
          "<p>Please check your configure.</p>\n"
          "<hr />\n"
          "<address>ohttpd/1.0</address>\n"
          "</body>\n"
          "</html>\n" dataUsingEncoding:NSUTF8StringEncoding];
        [self._socket writeData:[self._response responsePacket] withTimeout:-1 tag:0];
        [self._socket disconnectAfterWriting];
    }
    else
    {
        @try
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CGIConnectionRequestSiteNotification
                                                                object:self
                                                              userInfo:@{CGIConnectionRequestKey: self._request}];
        }
        @catch (NSException *exception)
        {
            // Crashed. 500.
            self._response = [[CGIResponse alloc] initWithRequest:self._request];
            self._response.responseStatus = 500;
            self._response.responseFields[@"Connection"] = @"Close";
            self._response.responseData =
            [@"<!DOCTYPE html>\n"
             "<html>\n"
             "<head>\n"
             "<title>HTTP/1.1 500</title>\n"
             "</head>\n"
             "<body>\n"
             "<h1>HTTP/1.1 500 Internal Server Error</h1>\n"
             "<p>Server app crashed.</p>\n"
             "<hr />\n"
             "<address>ohttpd/1.0</address>\n"
             "</body>\n"
             "</html>\n" dataUsingEncoding:NSUTF8StringEncoding];
            [self._socket writeData:[self._response responsePacket] withTimeout:-1 tag:0];
            [self._socket disconnectAfterWriting];
            CGILog(@"HTTP 500: %@", CGILogPriorityError, exception);
        }
    
    }
}

- (void)postResponse:(CGIResponse *)response
{
    [self._socket writeData:[response responsePacket] withTimeout:-1 tag:0];
    if ([response.responseFields[@"Connection"] isEqualToString:@"Close"])
    {
        [self._socket disconnectAfterWriting];
    }
    else
    {
        [self._socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:CGIConnectionRequestURI];
    }
}

@end
