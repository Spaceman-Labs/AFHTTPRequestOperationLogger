// AFHTTPRequestLogger.h
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFHTTPRequestOperationLogger.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestLumberjackLogger.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static int httpLogLevel = LOG_LEVEL_INFO;

@implementation AFHTTPRequestOperationLogger

+ (int)ddLogLevel
{
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel
{
    httpLogLevel = logLevel;
}

+ (AFHTTPRequestOperationLogger *)sharedLogger {
    static AFHTTPRequestOperationLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

  return _sharedLogger;
}


- (void)dealloc {
  [self stopLogging];
}

- (void)startLogging {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
}

- (void)stopLogging {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

- (void)HTTPOperationDidStart:(NSNotification *)notification {	
	AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

	if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }

	NSString *body = nil;
	if ([operation.request HTTPBody]) {
		body = [NSString stringWithUTF8String:[[operation.request HTTPBody] bytes]];
	}
	
	HTTPLogInfo(@"%@ '%@'", [operation.request HTTPMethod], [[operation.request URL] absoluteString]);
	HTTPLogVerbose(@"\tHeader Fields: %@\n\tBody: %@", [operation.request allHTTPHeaderFields], body);
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification {
	AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }

    if (operation.error) {
		HTTPLogError(@"Response: %@ '%@' (%ld): %@", [operation.request HTTPMethod], [[operation.response URL] absoluteString], (long)[operation.response statusCode], operation.error);
    } else {
		HTTPLogInfo(@"%ld '%@'", (long)[operation.response statusCode], [[operation.response URL] absoluteString]);
		HTTPLogVerbose(@"\tResponse: %@", operation.responseString);
    }
}

@end
