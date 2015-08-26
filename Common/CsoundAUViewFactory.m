/*
 * CsoundAUView_ViewFactory.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUViewFactory.h"
#import "CsoundAUHTMLView.h"
#import "JSONParserObjC.h"

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
    NSString *bundleID = @BUNDLEID;
    NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleID];
    NSString *bundlePath = [[[[bundle bundlePath]
                              stringByDeletingLastPathComponent]
                             stringByDeletingLastPathComponent]
                            stringByDeletingLastPathComponent];
    NSBundle *auBundle = [NSBundle bundleWithPath:bundlePath];
    NSDictionary *result = synchroniseArchivedObjects(auBundle);
    NSMutableArray *parameters = result[@"Parameters"];
    NSMutableDictionary *configuration = result[@"Configuration"];
    
    if ([configuration[@"ViewType"] compare:@"Cocoa"] == 0) {

        if (![[NSBundle bundleForClass:[self class]] loadNibNamed:configuration[@"ViewFileName"]
                                                            owner:self
                                                  topLevelObjects:nil]) {
            NSLog (@"Unable to load nib for view.");
            return nil;
        }
        
        uiFreshlyLoadedView.auBundlePath = bundlePath;
        [uiFreshlyLoadedView setAU:inAU parameters:parameters];
        
        NSView *returnView = uiFreshlyLoadedView;
        uiFreshlyLoadedView = nil;
        return returnView;
    }
    else {
        
        CsoundAUHTMLView *view= [[CsoundAUHTMLView alloc] initWithBundle:bundle
                                                           configuration:configuration
                                                              parameters:parameters
                                                               audioUnit:inAU];
        return view;
    }
    
    return nil;
}

@end
