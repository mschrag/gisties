//
//  Gisty.h
//  Gisties
//
//  Created by Michael Schrag on 2/14/09.
//  Copyright m Dimension Technology 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "GSGist.h"
#import "GSClickableTextField.h"

@interface GSGisty : NSDocument {
	GSGist *_gist;
	GSClickableTextField *_fileNameField;
	NSTextView *_contentView;
}

@property (retain, readwrite) IBOutlet GSClickableTextField *fileNameField;
@property (retain, readwrite) IBOutlet NSTextView *contentView;
@property (retain, readwrite) GSGist *gist;

@end
