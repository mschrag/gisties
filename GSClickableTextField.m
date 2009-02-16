//
//  MDTClickableTextField.m
//  Gisties
//
//  Created by Michael Schrag on 2/14/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSClickableTextField.h"


@implementation GSClickableTextField
- (BOOL)isActive {
	return [self isEditable];
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
	if ([self isEditable]) {
		[self makeInactive];		
	}
	return [super sendAction:theAction to:theTarget];
}


- (void)makeActive {
	[self setEditable:YES];
	[self setSelectable:YES];
	[self setDrawsBackground:YES];
	[self setBezeled:YES];
	NSRect frame = [self frame];
	[self setFrame:NSMakeRect(frame.origin.x - 2, frame.origin.y + 1, frame.size.width + 4, frame.size.height + 2)];
	[self selectText:self];
}

- (void)makeInactive {
	[self setEditable:NO];
	[self setSelectable:NO];
	[self setDrawsBackground:NO];
	[self setBezeled:NO];
	NSRect frame = [self frame];
	[self setFrame:NSMakeRect(frame.origin.x + 2, frame.origin.y - 1, frame.size.width - 4, frame.size.height - 2)];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (![self isActive]) {
		[self makeActive];
	}
	else {
		[super mouseDown:theEvent];
	}
}

@end
