//
//  BorderlessWindow.m
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSCustomWindow.h"


@implementation GSCustomWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation]) {
    [self setBackgroundColor: [NSColor clearColor]];
    [self setLevel:NSStatusWindowLevel];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow: YES];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	SEL action = [menuItem action];
	
	if (action == @selector(performClose:)) {
		return YES;
	}
	else if (action == @selector(performMiniaturize:)) {
		return YES;
	}
	
	return [super validateMenuItem:menuItem];
}

- (void)performClose:(id)sender {
	NSDocument *aDoc = [[NSDocumentController sharedDocumentController] documentForWindow:self];
	if ([self isDocumentEdited]) {
		[aDoc canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(close) contextInfo:self];
		
		//[aDoc saveDocumentWithDelegate:self didSaveSelector:@selector(close) contextInfo:self];
	}
	else {
		[aDoc close];
	}
	//[self close];
}

- (void)performMiniaturize:(id)sender {
	[self miniaturize:sender];
}

//Once the user starts dragging the mouse, we move the window with it. We do this because the window has no title
//bar for the user to drag (so we have to implement dragging ourselves)
- (void)mouseDragged:(NSEvent *)theEvent {
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	NSRect windowFrame = [self frame];
	
	//grab the current global mouse location; we could just as easily get the mouse location 
	//in the same way as we do in -mouseDown:
	NSPoint currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];

	if (_resizing) {
		NSSize dSize = NSMakeSize(currentLocation.x - _initialLocation.x, currentLocation.y - _initialLocation.y);
		NSRect newFrame = NSMakeRect(_initialFrame.origin.x, _initialFrame.origin.y + dSize.height, _initialFrame.size.width + dSize.width, _initialFrame.size.height - dSize.height);
		if (newFrame.size.width < [self minSize].width) {
			newFrame.size.width = [self minSize].width;
		}
		if (newFrame.size.height < [self minSize].height) {
			float dHeight = ([self minSize].height - newFrame.size.height);
			newFrame.size.height = [self minSize].height;
			newFrame.origin.y -= dHeight;
		}
		[self setFrame:newFrame display:YES];
	}
	else {
		NSPoint newOrigin = NSMakePoint(currentLocation.x - _initialLocation.x, currentLocation.y - _initialLocation.y);

		// Don't let window get dragged up under the menu bar
		if ((newOrigin.y + windowFrame.size.height) > (screenFrame.origin.y + screenFrame.size.height)) {
			newOrigin.y = screenFrame.origin.y + (screenFrame.size.height - windowFrame.size.height);
		}
		
		//go ahead and move the window to the new location
		[self setFrameOrigin:newOrigin];
	}
}

//We start tracking the a drag operation here when the user first clicks the mouse,
//to establish the initial location.
- (void)mouseDown:(NSEvent *)theEvent {
	NSRect windowFrame = [self frame];

	NSPoint locationInWindow = [theEvent locationInWindow];
	float resizeSquare = 15.0f;
	if (locationInWindow.x >= (windowFrame.size.width - resizeSquare) && locationInWindow.y <= resizeSquare) {
		_resizing = YES;
		_initialFrame = windowFrame;
		//grab the mouse location in global coordinates
		_initialLocation = [self convertBaseToScreen:locationInWindow];
	}
	else {
		_resizing = NO;
		//grab the mouse location in global coordinates
		_initialLocation = [self convertBaseToScreen:locationInWindow];
		_initialLocation.x -= windowFrame.origin.x;
		_initialLocation.y -= windowFrame.origin.y;
	}
}

@end
