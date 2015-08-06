/*
 * CsoundAUView.mm
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
