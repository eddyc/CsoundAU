/*
 * CsoundAUBase.h
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

#include <CsoundLib64/csound.h>
#include "Parameter.h"
#include <string>
#include <CoreFoundation/CoreFoundation.h>
#include "AUBase.h"
using namespace std;
typedef map<string, Float32> Preset;
class CsoundAUEffect;
class CsoundAUSynth;
class AUEffectBase;
class CsoundAUBase {
    
public:
    CsoundAUBase(AUBase *parent);
    ~CsoundAUBase();
    
    void SetPresets(vector<pair<string, Preset>> presets);
    void NewPreset(string name, Preset preset);
    void NewParameter(string name,
                      Float32 minValue,
                      Float32 maxValue,
                      Float32 defaultValue,
                      AudioUnitParameterUnit unit,
                      UInt32 flags);
    
    void NewParameter(string name,
                      Float32 minValue,
                      Float32 maxValue,
                      Float32 defaultValue,
                      AudioUnitParameterUnit unit,
                      UInt32 flags,
                      std::vector <string> strings);
    ComponentResult	GetPresets (CFArrayRef	*outData) const;
    OSStatus NewFactoryPresetSet (const AUPreset	&inNewFactoryPreset);
    ComponentResult GetProperty (AudioUnitPropertyID inID,
                                 AudioUnitScope inScope,
                                 AudioUnitElement inElement,
                                 void *outData,
                                 OSStatus (*CallGetParentProperty)(CsoundAUEffect *self,
                                                                   AudioUnitPropertyID inID,
                                                                   AudioUnitScope inScope,
                                                                   AudioUnitElement inElement,
                                                                   void *outData));
    ComponentResult GetPropertyInfo (AudioUnitPropertyID inID,
                                     AudioUnitScope inScope,
                                     AudioUnitElement inElement,
                                     UInt32 &outDataSize,
                                     Boolean &outWritable,
                                     ComponentResult (*CallGetParentPropertyInfo) (CsoundAUEffect *self,
                                                                                   AudioUnitPropertyID inID,
                                                                                   AudioUnitScope inScope,
                                                                                   AudioUnitElement inElement,
                                                                                   UInt32 &outDataSize,
                                                                                   Boolean &outWritable));
    
    ComponentResult GetProperty (AudioUnitPropertyID inID,
                                 AudioUnitScope inScope,
                                 AudioUnitElement inElement,
                                 void *outData,
                                 OSStatus (*CallGetParentProperty)(CsoundAUSynth *self,
                                                                   AudioUnitPropertyID inID,
                                                                   AudioUnitScope inScope,
                                                                   AudioUnitElement inElement,
                                                                   void *outData));
    ComponentResult GetPropertyInfo (AudioUnitPropertyID inID,
                                     AudioUnitScope inScope,
                                     AudioUnitElement inElement,
                                     UInt32 &outDataSize,
                                     Boolean &outWritable,
                                     ComponentResult (*CallGetParentPropertyInfo) (CsoundAUSynth *self,
                                                                                   AudioUnitPropertyID inID,
                                                                                   AudioUnitScope inScope,
                                                                                   AudioUnitElement inElement,
                                                                                   UInt32 &outDataSize,
                                                                                   Boolean &outWritable));
    virtual ComponentResult GetParameterInfo(AudioUnitScope inScope,
                                             AudioUnitParameterID inParameterID,
                                             AudioUnitParameterInfo &outParameterInfo);
    ComponentResult GetParameterValueStrings(AudioUnitScope inScope,
                                             AudioUnitParameterID inParameterID,
                                             CFArrayRef *outStrings);
    CSOUND *csound;
    CFStringRef bundleID;
    CFStringRef guiBundleID;
    
    void SetParameters(vector<Parameter> parameters);
    AUBase *parent;
    Preset defaultPreset;
    vector<Parameter> parameters;
    map<string, UInt32> parameterIndices;
    vector<pair<string, Preset>> presets;
};

