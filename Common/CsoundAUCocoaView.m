/*
 * CsoundAUCocoaView.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUCocoaView.h"
#import "JSONParserObjC.h"

@interface CsoundAUCocoaView ()
{
    NSMutableArray *registeredParameters;
}
@end

@implementation CsoundAUCocoaView

- (void)setParameter:(NSString *)parameterName forOutlet:(NSControl *)outlet
{
    
    NSNumber *index = [parameterIndices objectForKey:parameterName][0];
    outlet.tag = [index integerValue];
    [registeredParameters replaceObjectAtIndex:outlet.tag withObject:outlet];
    
    [outlet setTarget:self];
    [outlet setAction:@selector(valueChanged:)];
    [self priv_synchroniseUIWithParameterValues:(UInt32)outlet.tag];
    
}

- (void)registerParameters
{
    
}

- (void)setAU:(AudioUnit)inAU parameters:(NSMutableArray *)parametersIn 
{
    parameters = parametersIn;
    registeredParameters = [[NSMutableArray alloc] initWithCapacity:parameters.count];
    parameterIndices = [[NSMutableDictionary alloc] initWithCapacity:parameters.count];
    
    for (size_t i = 0; i < parameters.count; ++i) {
        
        [parameterIndices insertValue:[NSNumber numberWithInteger:i] inPropertyWithKey:[parameters[i] valueForKey:@"name"]];
        [registeredParameters addObject:@false];
    }
    
    if (mAU) {
        
        [self priv_removeListeners];
    }
    
    mAU = inAU;
    
    [self priv_addListeners:parameters.count];
    
    [self registerParameters];
}

- (void)priv_synchroniseUIWithParameterValues:(UInt32)parameterIndex {
    
    
    Float32 value;
    NSAssert (AudioUnitGetParameter(mAU, parameterIndex, kAudioUnitScope_Global, 0, &value) == noErr,
              @"[CsoundAUView priv_synchronizeUIWithParameterValues] (x.1)");
    NSControl *control = (NSControl *)[registeredParameters objectAtIndex:parameterIndex];;
    [control setFloatValue:value];
}

- (void)priv_eventListener:(void *)inObject
                     event:(const AudioUnitEvent *)inEvent
                     value:(Float32)inValue
{
    switch (inEvent->mEventType) {
        case kAudioUnitEvent_ParameterValueChange: {
            
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
}



- (IBAction)valueChanged:(id)sender {
    float floatValue = [sender floatValue];
    AudioUnitParameter parameter = {mAU, (int)[sender tag], kAudioUnitScope_Global, 0 };
    
    NSAssert(AUParameterSet(mAUEventListener,
                            (__bridge void *)sender,
                            &parameter,
                            (Float32)floatValue, 0) == noErr,
             @"[CsoundAUView valueChanged:] AUParameterSet()");
}

@end
