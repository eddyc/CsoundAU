/*
 * CsoundAUSynth.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#ifndef CsoundAU_CsoundObject_h
#define CsoundAU_CsoundObject_h

#include "AUInstrumentBase.h"
#include "CsoundAUBase.h"
#include <CsoundLib64/csound.h>


#define kCsoundAudioUnitVersion 0x00010000

typedef struct {

    unsigned char status;
    unsigned char data1;
    unsigned char data2;
    unsigned char flag;

} MidiData;

#define MIDI_QUEUE_SIZE 1024
typedef struct  {

    MidiData *midiData;
    int p, q;

} MidiCallbackData;

int midiDataRead(CSOUND *csound, void *userData, unsigned char *mbuf, int nbytes);
int midiInOpen(CSOUND *csound, void **userData, const char *dev);
int midiInClose(CSOUND *csound, void *userData);
typedef CsoundAUSynth CsoundAU;
AUDIOCOMPONENT_ENTRY(AUMusicDeviceFactory, CsoundAU)

class CsoundAUSynth : public AUInstrumentBase, public CsoundAUBase
{
public:
    CsoundAUSynth(AudioUnit inComponentInstance);

    virtual ~CsoundAUSynth();

    virtual OSStatus Render(AudioUnitRenderActionFlags &ioActionFlags,
                            const AudioTimeStamp &inTimeStamp,
                            UInt32 inNumberFrames);
    virtual OSStatus Initialize();
    virtual void Cleanup();

    virtual OSStatus Version() {
        return kCsoundAudioUnitVersion;
    }

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

    MidiCallbackData *midiCallbackData;
    int datbyts[8] = {2, 2, 2, 2, 1, 1, 2, 0};
protected:

    OSStatus Render(UInt32 inNumberFrames,
                    AudioBufferList *ioData);


    virtual OSStatus MIDIEvent(UInt32 inStatus,
                               UInt32 inData1,
                               UInt32 inData2,
                               UInt32 inOffsetSampleFrame);
    void pushMidiMessage(unsigned char status, unsigned char data1, unsigned char data2);
    CAStreamBasicDescription::CommonPCMFormat mCommonPCMFormat;
};

#endif
