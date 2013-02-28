//
//  AFURLConnectionOperation+Spaceman.m
//  Compares
//
//  Created by Jerry Jones on 2/27/13.
//  Copyright (c) 2013 Spaceman Labs. All rights reserved.
//

#import "AFURLConnectionOperation+Spaceman.h"
#import <objc/runtime.h>

NSString * const AFURLConnectionOperationSpacemanUUIDKey = @"com.spacemanlabs.afurlconnection.uuid";

@implementation AFURLConnectionOperation (Spaceman)

- (NSString *)UUID
{
	NSString *uuidString = objc_getAssociatedObject(self, (__bridge void *)AFURLConnectionOperationSpacemanUUIDKey);
	
	if (nil != uuidString) {
		return uuidString;
	}
	
	CFUUIDRef UUID = CFUUIDCreate(NULL);
	uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, UUID);
	CFRelease(UUID);
	
	objc_setAssociatedObject(self, (__bridge void *)AFURLConnectionOperationSpacemanUUIDKey, uuidString, OBJC_ASSOCIATION_RETAIN);
	
	return uuidString;
}

@end
