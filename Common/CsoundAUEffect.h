/*
 * CsoundAUEffect.h
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

#include "AUEffectBase.h"
#include "CsoundAUBase.h"

using namespace std;

class CsoundAUBase;
typedef CsoundAUEffect CsoundAU;
AUDIOCOMPONENT_ENTRY(AUBaseFactory, CsoundAU)

class CsoundAUEffect : public AUEffectBase, public CsoundAUBase {
    
public:
    
    CsoundAUEffect(AudioUnit inComponentInstance);
    
    virtual OSStatus	 ProcessBufferLists(AudioUnitRenderActionFlags &ioActionFlags,
                                            const AudioBufferList &inBuffer,
                                            AudioBufferList &outBuffer,
                                            UInt32 inFramesToProcess );
    
    OSStatus Render(UInt32 inNumberFrames,
                           const AudioBufferList &inputData,
                           AudioBufferList &outputData);
    
    virtual	ComponentResult GetParameterValueStrings (AudioUnitScope inScope,
                                                      AudioUnitParameterID inParameterID,
                                                      CFArrayRef *outStrings);
    
    virtual	ComponentResult GetParameterInfo (AudioUnitScope inScope,
                                              AudioUnitParameterID inParameterID,
                                              AudioUnitParameterInfo &outParameterInfo);
    
    virtual ComponentResult GetPropertyInfo (AudioUnitPropertyID inID,
                                             AudioUnitScope inScope,
                                             AudioUnitElement inElement,
                                             UInt32 &outDataSize,
                                             Boolean &outWritable);
    OSStatus GetParentPropertyInfo(AudioUnitPropertyID inID,
                                                   AudioUnitScope inScope,
                                                   AudioUnitElement inElement,
                                                   UInt32 &outDataSize,
                                                   Boolean &outWritable);
    virtual ComponentResult GetProperty (AudioUnitPropertyID inID,
                                         AudioUnitScope inScope,
                                         AudioUnitElement inElement,
                                         void *outData);
    ComponentResult GetParentProperty (AudioUnitPropertyID inID,
                                         AudioUnitScope inScope,
                                         AudioUnitElement inElement,
                                         void *outData);
    
    virtual ComponentResult	GetPresets (CFArrayRef	*outData) const;
    virtual OSStatus NewFactoryPresetSet (const AUPreset	&inNewFactoryPreset);
    
    virtual	bool SupportsTail () {return true;}
  

private:
    CAStreamBasicDescription::CommonPCMFormat mCommonPCMFormat;
};