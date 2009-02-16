//
//  AppDelegate.m
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSAppDelegate.h"
#import "GSGisty.h"
#import "GSSaveToGitHubOperation.h"

@implementation GSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_syncQueue = [[NSOperationQueue alloc] init];
	
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *gistiesFolder = [GSGist gistiesFolder];
	NSArray *gistyPaths = [fileManager directoryContentsAtPath:gistiesFolder];
	for (NSString *gistyPath in gistyPaths) {
		if ([[gistyPath pathExtension] isEqualToString:@"gisty"]) {
			NSURL *gistyURL = [[NSURL alloc] initFileURLWithPath:[gistiesFolder stringByAppendingPathComponent:gistyPath] isDirectory:YES];
			GSGisty *gisty = [controller openDocumentWithContentsOfURL:gistyURL display:YES];
			GSGist *gist = [gisty gist];
			if ([gist temporary]) {
				NSLog(@"temporary %@", [gist gistyFile]);
			}
			[gistyURL release];
		}
	}
}

- (void)dealloc {
	[_syncQueue release];
	[super dealloc];
}

- (void)loadFromGitHub:(GSGist *)gist {
	
}

- (void)saveToGitHub:(GSGist *)gist {
	GSSaveToGitHubOperation *operation = [[GSSaveToGitHubOperation alloc] initWithGist:gist];
	[_syncQueue addOperation:operation];
	[operation release];
}

- (NSString *)gitPath {
	return @"/usr/local/bin/git";
}

- (NSString *)userName {
	return @"mschrag";
}

- (NSString *)token {
	return @"XXX";
}
@end
