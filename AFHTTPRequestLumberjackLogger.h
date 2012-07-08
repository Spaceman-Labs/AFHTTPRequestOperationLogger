//
//  AFHTTPRequestLumberjackLogger.h
//  Goolia
//
//  Created by Jerry Jones on 7/8/12.
//  Copyright (c) 2012 Spaceman Labs, LLC. All rights reserved.
//

// Blatently robbed from:
// https://github.com/robbiehanson/CocoaLumberjack/wiki/CustomContext

#import "DDLog.h"

#define HTTP_LOG_CONTEXT 80

#define HTTPLogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_ERROR,   HTTP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HTTPLogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_WARN,    HTTP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HTTPLogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_INFO,    HTTP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HTTPLogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(httpLogLevel, LOG_FLAG_VERBOSE, HTTP_LOG_CONTEXT, frmt, ##__VA_ARGS__)