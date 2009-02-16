//
//  SaveToGitHubOperation.m
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSSaveToGitHubOperation.h"


@implementation GSSaveToGitHubOperation
-(id)initWithGist:(GSGist *)gist {
	if (self = [super init]) {
		_gist = [gist retain];
	}
	return self;
}

-(void)main {  
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"saving %@ to github ...", _gist);
	NSError *error;
	[_gist saveToGitHub:&error];
	NSLog(@"done");
	[pool release];
}
	
- (void)dealloc {
	[_gist release];
	[super dealloc];
}
@end
