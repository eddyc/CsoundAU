/*
 * CsoundAUEffectView_ViewFactory.m
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

#import "CsoundAUViewFactory.h"
#import "JSONParser.h"

@implementation CsoundAUViewFactory

- (unsigned)interfaceVersion
{
	return 0;
}

- (NSString *)description
{
	return @"Csound AU";
}

- (NSView *)uiViewForAudioUnit:(AudioUnit)inAU withSize:(NSSize)inPreferredSize
{
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@BUNDLEID];
    NSString *bundlePath = [[[[bundle bundlePath]
                              stringByDeletingLastPathComponent]
                             stringByDeletingLastPathComponent]
                            stringByDeletingLastPathComponent];
    string auBundlePath = [[[NSBundle bundleWithPath:bundlePath] bundleIdentifier] cStringUsingEncoding:NSUTF8StringEncoding];
    map<string, string> configuration = parseConfiguration(auBundlePath);
    NSString *nibName = [NSString stringWithUTF8String:configuration["NibName"].c_str()];
    if (![[NSBundle bundleForClass:[self class]] loadNibNamed:nibName
                                                        owner:self
                                              topLevelObjects:nil]) {
        NSLog (@"Unable to load nib for view.");
        return nil;
    }
    
    uiFreshlyLoadedView.auBundlePath = [NSString stringWithCString:auBundlePath.c_str() encoding:NSUTF8StringEncoding];
    [uiFreshlyLoadedView setAU:inAU];
    
    NSView *returnView = uiFreshlyLoadedView;
    uiFreshlyLoadedView = nil;
    
    return returnView;
}

@end
