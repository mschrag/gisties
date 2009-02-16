//
//  SaveToGitHubOperation.h
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSGist.h"

@interface GSSaveToGitHubOperation : NSOperation {
	GSGist *_gist;
}

-(id)initWithGist:(GSGist *)gist;

@end
