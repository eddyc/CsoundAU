/*
 * CsoundAUEffect.cpp
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include "CsoundAUEffect.h"

CsoundAUEffect::CsoundAUEffect(AudioUnit inComponentInstance)
:AUEffectBase(inComponentInstance),
CsoundAUBase(this)
{
    CreateElements();
    const CAStreamBasicDescription& format = GetStreamFormat(kAudioUnitScope_Output, 0);
    format.IdentifyCommonPCMFormat(mCommonPCMFormat, NULL);
}

OSStatus CsoundAUEffect::Render(UInt32 inNumberFrames,
                                const AudioBufferList &inputData,
                                AudioBufferList &outputData)
{
    int nchnls = inputData.mNumberBuffers;
    int slices = inNumberFrames/csoundGetKsmps(csound);
    int ksmps = csoundGetKsmps(csound);
    MYFLT *spout = csoundGetSpout(csound);
    MYFLT *spin = csoundGetSpin(csound);
    Float32 *buffer;

    for (int i = 0; i < slices; i++){

        for (int k = 0; k < nchnls; k++){

            buffer = (Float32 *) inputData.mBuffers[k].mData;

            for(int j = 0; j < ksmps; j++){

                spin[j*nchnls+k] = buffer[j+i*ksmps];
            }
        }

        for (UInt32 i = 0; i < parameters.size(); ++i) {

            Float32 value = GetParameter(i);
            csoundSetControlChannel(csound, parameters[i].name.c_str(), value);
        }

        csoundPerformKsmps(csound);

        for (int k = 0; k < nchnls; k++) {

            buffer = (Float32 *) outputData.mBuffers[k].mData;

            for (int j = 0; j < ksmps; j++){

                buffer[j+i*ksmps] = (Float32) spout[j*nchnls+k];
            }
        }
    }

    return 0;
}

OSStatus CsoundAUEffect::ProcessBufferLists(AudioUnitRenderActionFlags &ioActionFlags,
                                            const AudioBufferList &inBuffer,
                                            AudioBufferList &outBuffer,
                                            UInt32	inFramesToProcess)
{

    if (ShouldBypassEffect())
        return noErr;

    switch (mCommonPCMFormat) {
        case CAStreamBasicDescription::kPCMFormatFloat32 :
            Render(inFramesToProcess, inBuffer, outBuffer);
            break;
        default :
            throw CAException(kAudio_UnimplementedError);
    }


    return noErr;
}

ComponentResult CsoundAUEffect::GetParameterInfo(AudioUnitScope inScope,
                                                 AudioUnitParameterID inParameterID,
                                                 AudioUnitParameterInfo &outParameterInfo)
{
    return CsoundAUBase::GetParameterInfo(inScope, inParameterID, outParameterInfo);
}

ComponentResult CsoundAUEffect::GetParameterValueStrings(AudioUnitScope inScope,
                                                         AudioUnitParameterID inParameterID,
                                                         CFArrayRef *outStrings)
{
    return CsoundAUBase::GetParameterValueStrings(inScope, inParameterID, outStrings);
}

OSStatus CsoundAUEffect::GetParentPropertyInfo(AudioUnitPropertyID inID,
                                               AudioUnitScope inScope,
                                               AudioUnitElement inElement,
                                               UInt32 &outDataSize,
                                               Boolean &outWritable)
{
    return AUEffectBase::GetPropertyInfo(inID, inScope, inElement, outDataSize, outWritable);
}

OSStatus CallGetParentPropertyInfo(CsoundAUEffect *self,
                                   AudioUnitPropertyID inID,
                                   AudioUnitScope inScope,
                                   AudioUnitElement inElement,
                                   UInt32 &outDataSize,
                                   Boolean &outWritable)
{
    return self->GetParentPropertyInfo(inID, inScope, inElement, outDataSize, outWritable);
}

ComponentResult CsoundAUEffect::GetPropertyInfo (AudioUnitPropertyID inID,
                                                 AudioUnitScope inScope,
                                                 AudioUnitElement inElement,
                                                 UInt32 &outDataSize,
                                                 Boolean &outWritable)
{

    return CsoundAUBase::GetPropertyInfo (inID, inScope, inElement, outDataSize, outWritable, CallGetParentPropertyInfo);
}

OSStatus CsoundAUEffect::GetParentProperty(AudioUnitPropertyID inID,
                                           AudioUnitScope inScope,
                                           AudioUnitElement inElement,
                                           void *outData)
{
    return AUEffectBase::GetProperty(inID, inScope, inElement, outData);
}

OSStatus CallGetParentProperty(CsoundAUEffect *self,
                               AudioUnitPropertyID inID,
                               AudioUnitScope inScope,
                               AudioUnitElement inElement,
                               void *outData)
{
    return self->GetParentProperty(inID, inScope, inElement, outData);
}
ComponentResult CsoundAUEffect::GetProperty(AudioUnitPropertyID inID,
                                            AudioUnitScope inScope,
                                            AudioUnitElement inElement,
                                            void *outData)
{
    return CsoundAUBase::GetProperty(inID, inScope, inElement, outData, CallGetParentProperty);
}

ComponentResult	CsoundAUEffect::GetPresets(CFArrayRef *outData) const
{
    return CsoundAUBase::GetPresets(outData);
}
OSStatus CsoundAUEffect::NewFactoryPresetSet (const AUPreset &inNewFactoryPreset)
{
    return CsoundAUBase::NewFactoryPresetSet(inNewFactoryPreset);
}
