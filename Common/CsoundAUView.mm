/*
 * CsoundAUView.mm
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUView.h"
#import "JSONParser.h"

void checkError(OSStatus error)
{
    if (error != noErr) {

        printf("Error %d\nExiting\n", error);
        exit(-1);
    }
}

@interface CsoundAUView ()
{
    vector<Parameter> parameters;
    map<string, string> configuration;
    map<string, size_t> parameterIndices;
    NSMutableArray *registeredParameters;
}

@end

@implementation CsoundAUView

- (void)setParameter:(NSString *)parameterName forOutlet:(NSControl *)outlet
{
    const char *cString = [parameterName cStringUsingEncoding:NSUTF8StringEncoding];
    outlet.tag = parameterIndices[cString];
    [registeredParameters replaceObjectAtIndex:outlet.tag withObject:outlet];

    [outlet setTarget:self];
    [outlet setAction:@selector(valueChanged:)];
    [self priv_synchroniseUIWithParameterValues:(UInt32)outlet.tag];

}

- (void)registerParameters
{

}

- (void)setAU:(AudioUnit)inAU
{
    parameters = parseParameters([_auBundlePath cStringUsingEncoding:NSUTF8StringEncoding]);
    registeredParameters = [[NSMutableArray alloc] initWithCapacity:parameters.size()];

    for (size_t i = 0; i < parameters.size(); ++i) {

        parameterIndices[parameters[i].name] = i;
        [registeredParameters addObject:@false];
    }

    if (mAU) {

        [self priv_removeListeners];
    }

    mAU = inAU;

    [self priv_addListeners];

    [self registerParameters];
}

- (void)priv_synchroniseUIWithParameterValues:(UInt32)parameterIndex {

    Float32 value;
    NSAssert (AudioUnitGetParameter(mAU, static_cast<AudioUnitParameterID>(parameterIndex), kAudioUnitScope_Global, 0, &value) == noErr,
              @"[CsoundAUView priv_synchronizeUIWithParameterValues] (x.1)");
    NSControl *control = (NSControl *)[registeredParameters objectAtIndex:parameterIndex];;
    [control setFloatValue:value];
}

void EventListenerDispatcher (void *inRefCon, void *inObject,
                              const AudioUnitEvent *inEvent, UInt64 inHostTime,
                              Float32 inValue)
{
    CsoundAUView *SELF = (__bridge CsoundAUView *)inRefCon;
    [SELF priv_eventListener:inObject event: inEvent value: inValue];
}

- (void)priv_eventListener:(void *)inObject
                     event:(const AudioUnitEvent *)inEvent
                     value:(Float32)inValue
{
    switch (inEvent->mEventType) {
        case kAudioUnitEvent_ParameterValueChange:

            UInt32 parameterID = inEvent->mArgument.mParameter.mParameterID;
            NSObject *object = [registeredParameters objectAtIndex:parameterID];
            if ([object isEqualTo:@false]) {
                return;
            }
            else {

                NSControl *control = (NSControl *)object;
                [control setFloatValue:inValue];
            }

            break;
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

void addParamListener(AUEventListenerRef listener, void *refCon, AudioUnitEvent *inEvent)
{
    inEvent->mEventType = kAudioUnitEvent_BeginParameterChangeGesture;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));

    inEvent->mEventType = kAudioUnitEvent_EndParameterChangeGesture;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));

    inEvent->mEventType = kAudioUnitEvent_ParameterValueChange;
    checkError(AUEventListenerAddEventType(listener, refCon, inEvent));
}

- (void)priv_addListeners
{
    if (mAU) {

        checkError(AUEventListenerCreate(EventListenerDispatcher,
                                         (__bridge void *)self,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopDefaultMode,
                                         0.05,
                                         0.05,
                                         &mAUEventListener));

        for (size_t i = 0; i < parameters.size(); ++i) {

            AudioUnitEvent auEvent;
            AudioUnitParameter parameter = {mAU, static_cast<AudioUnitParameterID>(i), kAudioUnitScope_Global, 0};
            auEvent.mArgument.mParameter = parameter;
            addParamListener(mAUEventListener, (__bridge void *)self, &auEvent);
        }
    }
}

- (void)dealloc {
    [self priv_removeListeners];
}

- (IBAction)valueChanged:(id)sender {
    float floatValue = [sender floatValue];
    AudioUnitParameter parameter = {mAU, static_cast<AudioUnitParameterID>([sender tag]), kAudioUnitScope_Global, 0 };

    NSAssert(AUParameterSet(mAUEventListener,
                            (__bridge void *)sender,
                            &parameter,
                            (Float32)floatValue, 0) == noErr,
             @"[CsoundAUView valueChanged:] AUParameterSet()");
}
@end
