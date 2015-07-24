/*
 * CsoundAUEffectView_ViewFactory.m
 *
 * Copyright (C) 2015 Edward Costello
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
