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
#import "AFURLConnectionOperation+Spaceman.h"
#import "DDLog.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface AFHTTPRequestOperationLogger ()
@property (nonatomic, strong) NSDictionary *requestDurations;
@end

@implementation AFHTTPRequestOperationLogger
@synthesize level = _level;

+ (AFHTTPRequestOperationLogger *)sharedLogger {
    static AFHTTPRequestOperationLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

  return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.level = AFLoggerLevelInfo;
	self.requestDurations = [NSMutableDictionary new];

    return self;
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

- (void)HTTPOperationDidStart:(NSNotification *)notification
{
	CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
	AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];
	
    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
	
	_requestDurations[operation.UUID] = @(time);
	
	NSString *body = nil;
	if ([operation.request HTTPBody]) {
		body = [NSString stringWithUTF8String:[[operation.request HTTPBody] bytes]];
	}
	
	switch (self.level) {
		case AFLoggerLevelDebug:
			DDLogVerbose(@"%@ '%@': %@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], [operation.request allHTTPHeaderFields], body);
			break;
		case AFLoggerLevelInfo:
			DDLogInfo(@"Request Sent\n\tMethod: %@\n\tURL: '%@'\n\tUUID: %@\n", [operation.request HTTPMethod], [[operation.request URL] absoluteString], operation.UUID);
			break;
        default:
            break;
	}
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification
{
	CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime duration = NAN;
	AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
	
	NSNumber *startTime = _requestDurations[operation.UUID];
	if (startTime) {
		duration = time - ([startTime doubleValue]);
	}
	
    if (operation.error) {
        switch (self.level) {
            case AFLoggerLevelDebug:
            case AFLoggerLevelInfo:
            case AFLoggerLevelWarn:
            case AFLoggerLevelError:
                DDLogError(@"Response Received **ERROR**\n\t%@ '%@' (%ld): %@", [operation.request HTTPMethod], [[operation.response URL] absoluteString], (long)[operation.response statusCode], operation.error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case AFLoggerLevelDebug:
                DDLogCVerbose(@"%ld '%@': %@", (long)[operation.response statusCode], [[operation.response URL] absoluteString], operation.responseString);
                break;
            case AFLoggerLevelInfo:
                DDLogInfo(@"Response Received\n\tDuration: %fs\n\tResponse Code: %ld\n\tURL: '%@'\n\tUUID: %@\n", duration, (long)[operation.response statusCode], [[operation.response URL] absoluteString], operation.UUID);
                break;
            default:
                break;
        }
    }
}

@end
