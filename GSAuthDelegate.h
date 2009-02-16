//
//  GSAuthDelegate.h
//  Gisties
//
//  Created by Michael Schrag on 2/15/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol GSAuthDelegate
- (NSString *)gitPath;
- (NSString *)userName;
- (NSString *)token;
@end
