//
//  Gist.h
//  Gisties
//
//  Created by Michael Schrag on 2/13/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSAuthDelegate.h"

@interface GSGist : NSObject {
	id<GSAuthDelegate> _authDelegate;
	
	NSString *_gistyFolder;
	NSString *_gistID;
	NSString *_originalName;
	NSString *_name;
	NSAttributedString *_content;
	BOOL _private;
	BOOL _loaded;
	BOOL _temporary;
	
	BOOL _saving;
	BOOL _syncing;
	BOOL _saveDuringSync;
	BOOL _syncDuringSave;
	
	NSRect _frame;
}

@property (readwrite, retain) NSString *gistyFolder;
@property (readwrite, retain) NSString *gistID;
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSAttributedString *content;
@property (readwrite, assign) BOOL private;
@property (readwrite, assign) BOOL loaded;
@property (readwrite, assign) BOOL temporary;
@property (readwrite, assign) BOOL saving;
@property (readwrite, assign) BOOL syncing;
@property (readwrite, assign) NSRect frame;
@property (readwrite, retain) NSString *originalName;

- (id)initWithAuthDelegate:(id<GSAuthDelegate>)delegate;
- (id)initWithID:(NSString *)gistID authDelegate:(id<GSAuthDelegate>)delegate;
- (id)initWithFolder:(NSString *)gistyFolder authDelegate:(id<GSAuthDelegate>)delegate;
- (void)load:(NSError **)error;
- (void)loadFromDisk:(NSError **)error;
- (void)loadFromGitHub:(NSError **)error;
- (void)saveToDisk:(NSError **)error;
- (void)saveToGitHub:(NSError **)error;
- (void)deleteFromDisk:(NSError **)error;
- (void)deleteFromGitHub:(NSError **)error;
- (NSString *)gistyFolder;
- (NSString *)gistyFile;

+ (NSString *)gistiesFolder;

@end
