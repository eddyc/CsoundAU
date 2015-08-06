/*
 * CsoundAUView.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */


#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CsoundAUViewBase.h"

@interface CsoundAUCocoaView : CsoundAUViewBase

@property NSString *auBundlePath;
- (void)setParameter:(NSString *)parameterName forOutlet:(NSControl *)outlet;
- (void)setAU:(AudioUnit)inAU parameters:(NSMutableArray *)parametersIn;
@end
