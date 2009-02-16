//
//  AppDelegate.h
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSAuthDelegate.h"
#import "GSGist.h"

@interface GSAppDelegate : NSObject <GSAuthDelegate> {
	NSOperationQueue *_syncQueue;
}

- (void)saveToGitHub:(GSGist *)gist;

@end
