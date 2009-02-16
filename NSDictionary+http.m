//
//  NSDictionary+http.m
//  Gisties
//
//  Created by Michael Schrag on 2/14/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "NSDictionary+http.h"

@implementation NSDictionary (http)

- (NSString *)formEncoded {
	NSMutableString *formEncoded = [NSMutableString stringWithCapacity:256];
	
	BOOL started = NO;
	NSString *key;
	NSEnumerator *keys = [self keyEnumerator];
	while ((key = [keys nextObject]) != nil) {
		if (started) {
			[formEncoded appendString: @"&"];
		}
		NSString *escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *escapedValue = [[self objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[formEncoded appendString: [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue]];
		started = YES;
	}
	
	return formEncoded;
}

@end

