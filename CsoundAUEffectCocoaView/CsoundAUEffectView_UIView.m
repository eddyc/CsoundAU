/*
 * CsoundAUEffectView_UIView.m
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
