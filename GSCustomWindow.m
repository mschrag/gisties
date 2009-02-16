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

//Once the user starts dragging the mouse, we move the window with it. We do this because the window has no title
//bar for the user to drag (so we have to implement dragging ourselves)
- (void)mouseDragged:(NSEvent *)theEvent {
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	NSRect windowFrame = [self frame];
	
	//grab the current global mouse location; we could just as easily get the mouse location 
	//in the same way as we do in -mouseDown:
	NSPoint currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
	NSPoint newOrigin = NSMakePoint(currentLocation.x - _initialLocation.x, currentLocation.y - _initialLocation.y);
	
	// Don't let window get dragged up under the menu bar
	if ((newOrigin.y + windowFrame.size.height) > (screenFrame.origin.y + screenFrame.size.height)) {
		newOrigin.y = screenFrame.origin.y + (screenFrame.size.height - windowFrame.size.height);
	}
	
	//go ahead and move the window to the new location
	[self setFrameOrigin:newOrigin];
}

//We start tracking the a drag operation here when the user first clicks the mouse,
//to establish the initial location.
- (void)mouseDown:(NSEvent *)theEvent {    
	NSRect windowFrame = [self frame];
	
	//grab the mouse location in global coordinates
	_initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	_initialLocation.x -= windowFrame.origin.x;
	_initialLocation.y -= windowFrame.origin.y;
}

@end
