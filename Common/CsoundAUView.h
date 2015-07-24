/*
 * CsoundAUView.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */


#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
@interface CsoundAUView : NSView
{
    AudioUnit mAU;
    AUEventListenerRef mAUEventListener;
}
@property NSString *auBundlePath;
- (void)setAU:(AudioUnit)inAU;
- (void)setParameter:(NSString *)parameterName forOutlet:(NSControl *)outlet;
- (void)registerParameters;
@end
