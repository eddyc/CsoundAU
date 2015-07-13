/*
 * CsoundAUSynthView_ViewFactory.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#import "CsoundAUSynthView_ViewFactory.h"
#import "CsoundAUSynthView_UIView.h"

@implementation CsoundAUSynthView_ViewFactory

- (unsigned)interfaceVersion
{
	return 0;
}

- (NSString *)description
{
	return @"Csound AU Synth";
}

- (NSView *)uiViewForAudioUnit:(AudioUnit)inAU withSize:(NSSize)inPreferredSize
{

    if (![[NSBundle bundleForClass:[self class]] loadNibNamed:@"CsoundAUSynthView"
                                                        owner:self
                                              topLevelObjects:nil]) {
        NSLog (@"Unable to load nib for view.");
		return nil;
	}
    
    [uiFreshlyLoadedView setAU:inAU];
    
    NSView *returnView = uiFreshlyLoadedView;
    uiFreshlyLoadedView = nil;
    
    return returnView;
}

@end
