/*
 * CsoundAUViewBase.h
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


#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
@interface CsoundAUViewBase : NSView
{
    AudioUnit mAU;
    AUEventListenerRef mAUEventListener;
}

void checkError(OSStatus error);
void EventListenerDispatcher (void *inRefCon, void *inObject,
                              const AudioUnitEvent *inEvent, UInt64 inHostTime,
                              Float32 inValue);
void addParamListener(AUEventListenerRef listener, void *refCon, AudioUnitEvent *inEvent);
- (Float32)getParameterValue:(AudioUnitParameterID)parameterIndex;

- (void)priv_eventListener:(void *)inObject
                     event:(const AudioUnitEvent *)inEvent
                     value:(Float32)inValue;
- (void)priv_addListeners:(NSUInteger)parametersCount;
- (void)priv_removeListeners;
@end