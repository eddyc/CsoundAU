/*
 * CsoundAUSynthView_UIView.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUView.h"

@interface CsoundAUSynthView_UIView : CsoundAUView
{
    __weak IBOutlet NSSlider *release;
    __weak IBOutlet NSSlider *attack;
}
@end

@implementation CsoundAUSynthView_UIView

- (void)registerParameters
{
    [self setParameter:@"Attack" forOutlet:attack];
    [self setParameter:@"Release" forOutlet:release];
}
@end
