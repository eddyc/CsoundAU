/*
 * CsoundAUEffectView_UIView.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUViewBase.h"

@interface CsoundAUEffectView_UIView : CsoundAUViewBase
{
    __weak IBOutlet NSSlider *mix;
    __weak IBOutlet NSSlider *time;
    __weak IBOutlet NSSlider *feedback;
}
@end

@implementation CsoundAUEffectView_UIView

- (void)registerParameters
{
    [self setParameter:@"Time" forOutlet:time];
    [self setParameter:@"Feedback" forOutlet:feedback];
    [self setParameter:@"Mix" forOutlet:mix];
}


@end
