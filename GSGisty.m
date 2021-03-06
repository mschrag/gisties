//
//  Gisty.m
//  Gisties
//
//  Created by Michael Schrag on 2/14/09.
//  Copyright m Dimension Technology 2009 . All rights reserved.
//

#import "GSGisty.h"
#import "GSAppDelegate.h"

@implementation GSGisty

@synthesize gist = _gist;
@synthesize fileNameField = _fileNameField;
@synthesize contentView = _contentView;

- (id)init {
	if (self = [super init]) {
		GSGist *gist = [[GSGist alloc] initWithAuthDelegate:[[NSApplication sharedApplication] delegate]];
		[gist setPrivate:YES];
		[gist setFrame:NSMakeRect(-1, -1, 533, 300)];
		[self setGist:gist];
		[gist release];
	}
	return self;
}

- (NSString *)windowNibName {
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"Gisty";
}

- (void)windowDidMove:(NSNotification *)notification {
	NSError *error;
	[[self gist] setFrame:[[notification object] frame]];
	[[self gist] updateFolderAttributes:&error];
}

- (void)windowDidResize:(NSNotification *)notification {
	NSError *error;
	[[self gist] setFrame:[[notification object] frame]];
	[[self gist] updateFolderAttributes:&error];
}

- (void)close {
//	NSLog(@"close");
	[super close];
}

- (void)windowWillClose:(NSNotification *)notification {
	//NSError *error;
	//[[self gist] deleteFromGitHub:&error];
	//[[self gist] deleteFromDisk:&error];
}


/*
- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo {
	NSLog(@"canClose");
}
*/

- (void)shouldCloseWindowController:(NSWindowController *)windowController delegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo {
	[super shouldCloseWindowController:windowController delegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
	[controller setShouldCascadeWindows:NO];
	
	[super windowControllerDidLoadNib:controller];

	if (!NSIsEmptyRect([_gist frame])) {
		[[controller window] setFrame:[_gist frame] display:YES];
	}
	if ([_gist frame].origin.x == -1) {
		[[controller window] center];
	}
	[_contentView setTextContainerInset:NSMakeSize(6, 10)];
	[[[controller window] standardWindowButton:NSWindowCloseButton] setEnabled:YES];
}

- (void)saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
	NSError *error;
	[_gist saveToDisk:&error];
	[(GSAppDelegate *)[[NSApplication sharedApplication] delegate] saveToGitHub:_gist];
	if (delegate) {
		NSInvocation *delegateInvocation = [[NSInvocation alloc] init];
		[delegateInvocation setTarget:delegate];
		[delegateInvocation setSelector:didSaveSelector];
		[delegateInvocation setArgument:self atIndex:0];
		[delegateInvocation setArgument:[NSNumber numberWithBool:YES] atIndex:1];
		[delegateInvocation setArgument:contextInfo atIndex:2];
		[delegateInvocation invoke];
		[delegateInvocation release];
	}
	[self updateChangeCount:NSChangeCleared];
}

- (NSString *)displayName {
	return [[_gist gistyFile] lastPathComponent];
}


- (void)runModalSavePanelForSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
	/*
	*/
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
	// Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

	// For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

	if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)wrapper ofType:(NSString *)docType {
	return [self readFromFileWrapper:	wrapper ofType:docType error:NULL];
}

- (void)loadGistyFromFolder:(NSString *)path error:(NSError **)error {
	GSGist *gist = [[GSGist alloc] initWithFolder:[self fileName] authDelegate:[[NSApplication sharedApplication] delegate]];
	[gist loadFromDisk:error];
	if ([gist temporary]) {
		[(GSAppDelegate *)[[NSApplication sharedApplication] delegate] saveToGitHub:gist];
	}
	[self setGist:gist];
	[gist release];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	[self loadGistyFromFolder:[self fileName] error:outError];

	if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	[self loadGistyFromFolder:[absoluteURL path] error:outError];
	// Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
	
	// For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
	
	if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return YES;
}

- (void)dealloc {
	[_gist release];
	[_fileNameField release];
	[_contentView release];
	[super dealloc];
}

- (IBAction)reload:(id)sender {
	if (![[self gist] temporary]) {
		[(GSAppDelegate *)[[NSApplication sharedApplication] delegate] loadFromGitHub:[self gist]];
	}
}
@end
