/*
 * CsoundAUViewBase.h
 *
 * Copyright (C) 2015 Edward Costello
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
