/*
 * CsoundAUHTMLView.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */


#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CsoundAUViewBase.h"

@interface CsoundAUHTMLView : CsoundAUViewBase

- (CsoundAUHTMLView *)initWithBundle:(NSBundle *)bundle
                       configuration:(NSDictionary *)configuration
                          parameters:(NSMutableArray *)parameters
                           audioUnit:(AudioUnit)inAU;

@end
