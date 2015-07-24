/*
 * CsoundAUEffect.h
 *
 * Copyright (C) 2015 Edward Costello
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
