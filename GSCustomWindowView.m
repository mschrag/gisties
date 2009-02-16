//
//  GSCustomWindowView.m
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSCustomWindowView.h"


@implementation GSCustomWindowView

//This routine is called at app launch time when this class is unpacked from the nib.
//We get set up here.
-(void)awakeFromNib {
	//load the images we'll use from the bundle's Resources directory
	circleImage = [NSImage imageNamed:@"circle"];
	pentaImage = [NSImage imageNamed:@"pentagram"];
	//tell ourselves that we need displaying
	[self setNeedsDisplay:YES];
}

//When it's time to draw, this routine is called.
//This view is inside the window, the window's opaqueness has been turned off,
//and the window's styleMask has been set to NSBorderlessWindowMask on creation,
//so what this view draws *is all the user sees of the window*.  The first two lines below
//then fill things with "clear" color, so that any images we draw are the custom shape of the window,
//for all practical purposes.  Furthermore, if the window's alphaValue is <1.0, drawing will use
//transparency.
-(void)drawRect:(NSRect)rect {
	/*
	//erase whatever graphics were there before with clear
	[[NSColor clearColor] set];
	NSRectFill([self frame]);
	//if our window transparency is >0.7, we decide to draw the circle.  Otherwise, draw the pentagram.
	//If we called -disolveToPoint:fraction: instead of -compositeToPoint:operation:, then the image
	//could itself be drawn with less than full opaqueness, but since we're already setting the alpha
	//on the entire window, we don't bother with that here.
	if ([[self window] alphaValue]>0.7) {
    [circleImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
	else {
    [pentaImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
	//the next line resets the CoreGraphics window shadow (calculated around our custom window shape content)
	//so it's recalculated for the new shape, etc.  The API to do this was introduced in 10.2.
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_1) {
		[[self window] setHasShadow:NO];
		[[self window] setHasShadow:YES];
	}
	else {
		[[self window] invalidateShadow];
	}
	 */
	[[NSColor redColor] set];
	NSRectFill([self frame]);
}

@end
