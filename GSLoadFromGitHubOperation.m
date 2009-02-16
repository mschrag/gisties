//
//  LoadFromGitHubOperation.m
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSLoadFromGitHubOperation.h"

@implementation GSLoadFromGitHubOperation
-(id)initWithGist:(GSGist *)gist {
	if (self = [super init]) {
		_gist = [gist retain];
	}
	return self;
}

-(void)main {  
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"loading %@ from github ...", _gist);
	NSError *error;
	[_gist loadFromGitHub:&error];
	NSLog(@"done");
	[pool release];
}

- (void)dealloc {
	[_gist release];
	[super dealloc];
}
@end
