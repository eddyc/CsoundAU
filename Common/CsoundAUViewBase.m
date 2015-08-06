/*
 * CsoundAUViewBase.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUViewBase.h"
#import "JSONParserObjC.h"

@implementation CsoundAUViewBase

void checkError(OSStatus error)
{
    if (error != noErr) {
        
        printf("Error %d\nExiting\n", error);
        exit(-1);
    }
}

void EventListenerDispatcher (void *inRefCon, void *inObject,
                              const AudioUnitEvent *inEvent, UInt64 inHostTime,
                              Float32 inValue)
{
    CsoundAUViewBase *SELF = (__bridge CsoundAUViewBase *)inRefCon;
    [SELF priv_eventListener:inObject event: inEvent value: inValue];
}

- (void)priv_eventListener:(void *)inObject
                     event:(const AudioUnitEvent *)inEvent
                     value:(Float32)inValue
{}

void addParamListener(AUEventListenerRef listener, void *refCon, AudioUnitEvent *inEvent)
{
    inEvent->mEventType = kAudioUnitEvent_BeginParameterChangeGesture;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));
    
    inEvent->mEventType = kAudioUnitEvent_EndParameterChangeGesture;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));
    
    inEvent->mEventType = kAudioUnitEvent_ParameterValueChange;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));
}

- (Float32)getParameterValue:(AudioUnitParameterID)parameterIndex
{
    Float32 value;
    NSAssert (AudioUnitGetParameter(mAU, parameterIndex, kAudioUnitScope_Global, 0, &value) == noErr,
              @"[CsoundAUView priv_synchronizeUIWithParameterValues] (x.1)");
    return value;
}

- (void)priv_addListeners:(NSUInteger)parametersCount
{
    if (mAU) {
        
        checkError(AUEventListenerCreate(EventListenerDispatcher,
                                         (__bridge void *)self,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopDefaultMode,
                                         0.05,
                                         0.05,
                                         &mAUEventListener));
        
        for (size_t i = 0; i < parametersCount; ++i) {
            
            AudioUnitEvent auEvent;
            AudioUnitParameter parameter = {mAU, (int)i, kAudioUnitScope_Global, 0};
            auEvent.mArgument.mParameter = parameter;
            addParamListener(mAUEventListener, (__bridge void *)self, &auEvent);
        }
    }
}

- (void)priv_removeListeners
{
    if (mAUEventListener) {
        
        checkError(AUListenerDispose(mAUEventListener));
    }
    
    mAUEventListener = NULL;
    mAU = NULL;
}


- (void)dealloc {
    [self priv_removeListeners];
}

@end
