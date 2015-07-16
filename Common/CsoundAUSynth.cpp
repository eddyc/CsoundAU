/*
 * CsoundAUSynth.cpp
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

#include "CsoundAUSynth.h"

CsoundAUSynth::CsoundAUSynth(AudioUnit inComponentInstance)
: AUInstrumentBase(inComponentInstance, 0, 1),
CsoundAUBase(this)
{
    CreateElements();
    const CAStreamBasicDescription& format = GetStreamFormat(kAudioUnitScope_Output, 0);
    format.IdentifyCommonPCMFormat(mCommonPCMFormat, NULL);
    midiCallbackData = (MidiCallbackData *)calloc(1, sizeof(MidiCallbackData));
    midiCallbackData->midiData = (MidiData *)calloc(MIDI_QUEUE_SIZE, sizeof(MidiData));
   	csoundSetHostImplementedMIDIIO(csound, 1);
    csoundSetExternalMidiInOpenCallback(csound, midiInOpen);
    csoundSetExternalMidiReadCallback(csound, midiDataRead);
    csoundSetExternalMidiInCloseCallback(csound, midiInClose);
}

CsoundAUSynth::~CsoundAUSynth() {
    
    free(midiCallbackData->midiData);
    free(midiCallbackData);
}

void CsoundAUSynth::Cleanup() {
    
    AUInstrumentBase::Cleanup();
}

OSStatus CsoundAUSynth::Initialize() {
    
    AUInstrumentBase::Initialize();
    
    return noErr;
}

OSStatus CsoundAUSynth::Render(AudioUnitRenderActionFlags &ioActionFlags,
                               const AudioTimeStamp &inTimeStamp,
                               UInt32 inNumberFrames)
{
    
    if (mCommonPCMFormat == CAStreamBasicDescription::kPCMFormatFloat32) {
        
            AUInstrumentBase::Render(ioActionFlags, inTimeStamp, inNumberFrames);
            AUScope &outputs = Outputs();
            UInt32 numOutputs = outputs.GetNumberOfElements();
            for (UInt32 j = 0; j < numOutputs; ++j) {
                
                GetOutput(j)->PrepareBuffer(inNumberFrames);	// AUBase::DoRenderBus() only does this for the first output element
                AudioBufferList& bufferList = GetOutput(j)->GetBufferList();
                Render(inNumberFrames, &bufferList);
            }
    }
    return noErr;
}

OSStatus CsoundAUSynth::Render(UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
    int nchnls = ioData->mNumberBuffers;
    int slices = inNumberFrames/csoundGetKsmps(csound);
    int ksmps = csoundGetKsmps(csound);
    MYFLT *spout = csoundGetSpout(csound);
    Float32 *buffer;
    
    for (int i = 0; i < slices; i++){
        
        for (UInt32 i = 0; i < parameters.size(); ++i) {
            
            Float32 value = Globals()->GetParameter(i);
            csoundSetControlChannel(csound, parameters[i].name.c_str(), value);
        }
        
        csoundPerformKsmps(csound);
        
        for (int k = 0; k < nchnls; k++) {
            
            buffer = (Float32 *) ioData->mBuffers[k].mData;
            
            for (int j = 0; j < ksmps; j++){
               
                buffer[j+i*ksmps] = (Float32) spout[j*nchnls+k];
            }
        }
    }
    
    return 0;
}

void CsoundAUSynth::pushMidiMessage(unsigned char status, unsigned char data1, unsigned char data2)
{
    midiCallbackData->midiData[midiCallbackData->p].status = status;
    midiCallbackData->midiData[midiCallbackData->p].data1 = data1;
    midiCallbackData->midiData[midiCallbackData->p].data2= data2;
    midiCallbackData->midiData[midiCallbackData->p].flag = 1;
    
    midiCallbackData->p++;
    if (midiCallbackData->p == MIDI_QUEUE_SIZE) {
        
        midiCallbackData->p = 0;
    }
}

int midiDataRead(CSOUND *csound, void *userData, unsigned char *mbuf, int nbytes)
{
    CsoundAUSynth *self = (CsoundAUSynth *)csoundGetHostData(csound);
    MidiCallbackData *data = self->midiCallbackData;
    
    MidiData *mdata = data->midiData;
    
    int *q = &data->q, st, d1, d2, n = 0;
    
    while (mdata[*q].flag) {
        st = (int) mdata[*q].status;
        d1 = (int) mdata[*q].data1;
        d2 = (int) mdata[*q].data2;
        
        if (st < 0x80)
            goto next;
        
        if (st >= 0xF0 &&
            !(st == 0xF8 || st == 0xFA || st == 0xFB ||
              st == 0xFC || st == 0xFF))
            goto next;
        nbytes -= (self->datbyts[(st - 0x80) >> 4] + 1);
        if (nbytes < 0) break;
        
        /* write to csound midi buffer */
        n += (self->datbyts[(st - 0x80) >> 4] + 1);
        switch (self->datbyts[(st - 0x80) >> 4]) {
            case 0:
                *mbuf++ = (unsigned char) st;
                break;
            case 1:
                *mbuf++ = (unsigned char) st;
                *mbuf++ = (unsigned char) d1;
                break;
            case 2:
                *mbuf++ = (unsigned char) st;
                *mbuf++ = (unsigned char) d1;
                *mbuf++ = (unsigned char) d2;
                break;
                
        }
    next:
        mdata[*q].flag = 0;
        (*q)++;
        if(*q== MIDI_QUEUE_SIZE) *q = 0;
        
    }
    
    return n;
}

int midiInOpen(CSOUND *csound, void **userData, const char *dev)
{
    return 0;
}

int midiInClose(CSOUND *csound, void *userData)
{
    return 0;
}
OSStatus CsoundAUSynth::MIDIEvent(UInt32 inStatus,
                                  UInt32 inData1,
                                  UInt32 inData2,
                                  UInt32 inOffsetSampleFrame)

{
    pushMidiMessage(inStatus, inData1, inData2);
    return AUMIDIBase::MIDIEvent (inStatus, inData1, inData2, inOffsetSampleFrame);
}

ComponentResult CsoundAUSynth::GetParameterInfo(AudioUnitScope inScope,
                                                AudioUnitParameterID inParameterID,
                                                AudioUnitParameterInfo &outParameterInfo)
{
    return CsoundAUBase::GetParameterInfo(inScope, inParameterID, outParameterInfo);
}

ComponentResult CsoundAUSynth::GetParameterValueStrings(AudioUnitScope inScope,
                                                        AudioUnitParameterID inParameterID,
                                                        CFArrayRef *outStrings)
{
    return CsoundAUBase::GetParameterValueStrings(inScope, inParameterID, outStrings);
}

OSStatus CsoundAUSynth::GetParentPropertyInfo(AudioUnitPropertyID inID,
                                              AudioUnitScope inScope,
                                              AudioUnitElement inElement,
                                              UInt32 &outDataSize,
                                              Boolean &outWritable)
{
    return AUInstrumentBase::GetPropertyInfo(inID, inScope, inElement, outDataSize, outWritable);
}

OSStatus CallGetParentPropertyInfo(CsoundAUSynth *self,
                                   AudioUnitPropertyID inID,
                                   AudioUnitScope inScope,
                                   AudioUnitElement inElement,
                                   UInt32 &outDataSize,
                                   Boolean &outWritable)
{
    return self->GetParentPropertyInfo(inID, inScope, inElement, outDataSize, outWritable);
}

ComponentResult CsoundAUSynth::GetPropertyInfo (AudioUnitPropertyID inID,
                                                AudioUnitScope inScope,
                                                AudioUnitElement inElement,
                                                UInt32 &outDataSize,
                                                Boolean &outWritable)
{
    
    return CsoundAUBase::GetPropertyInfo (inID, inScope, inElement, outDataSize, outWritable, CallGetParentPropertyInfo);
}

OSStatus CsoundAUSynth::GetParentProperty(AudioUnitPropertyID inID,
                                          AudioUnitScope inScope,
                                          AudioUnitElement inElement,
                                          void *outData)
{
    return AUInstrumentBase::GetProperty(inID, inScope, inElement, outData);
}

OSStatus CallGetParentProperty(CsoundAUSynth *self,
                               AudioUnitPropertyID inID,
                               AudioUnitScope inScope,
                               AudioUnitElement inElement,
                               void *outData)
{
    return self->GetParentProperty(inID, inScope, inElement, outData);
}
ComponentResult CsoundAUSynth::GetProperty(AudioUnitPropertyID inID,
                                           AudioUnitScope inScope,
                                           AudioUnitElement inElement,
                                           void *outData)
{
    return CsoundAUBase::GetProperty(inID, inScope, inElement, outData, CallGetParentProperty);
}

ComponentResult	CsoundAUSynth::GetPresets(CFArrayRef *outData) const
{
    return CsoundAUBase::GetPresets(outData);
}
OSStatus CsoundAUSynth::NewFactoryPresetSet (const AUPreset &inNewFactoryPreset)
{
    return CsoundAUBase::NewFactoryPresetSet(inNewFactoryPreset);
}