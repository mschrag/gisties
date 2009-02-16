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
	//erase whatever graphics were there before with clear
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	[[NSColor clearColor] set];
	NSRect frame = [self frame];
	NSRectFill(frame);

	[[NSColor colorWithDeviceRed:0.996 green:0.957 blue:0.612 alpha:1.0] set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path appendBezierPathWithRoundedRect:frame xRadius:5 yRadius:5];
	[path fill];
	[path addClip];

	[[NSColor colorWithDeviceRed:0.926 green:0.897 blue:0.542 alpha:1.0] set];
	float headerHeight = 25.0f;
	NSRectFill(NSMakeRect(0.0f, frame.size.height - headerHeight, frame.size.width, headerHeight));
	
	[context restoreGraphicsState];
	

	/*
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
	[[self window] invalidateShadow];
	
	[super drawRect:rect];
	
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
	NSBezierPath *resizePath = [NSBezierPath bezierPath];
	float margin = 2.0f;
	[resizePath moveToPoint:NSMakePoint(frame.size.width - margin, 14.0f)];
	[resizePath lineToPoint:NSMakePoint(frame.size.width - 14.0f, margin)];

	[resizePath moveToPoint:NSMakePoint(frame.size.width - margin, 10.0f)];
	[resizePath lineToPoint:NSMakePoint(frame.size.width - 10.0f, margin)];
	
	[resizePath moveToPoint:NSMakePoint(frame.size.width - margin, 6.0f)];
	[resizePath lineToPoint:NSMakePoint(frame.size.width - 6.0f, margin)];
	
	[resizePath stroke];
}

@end
