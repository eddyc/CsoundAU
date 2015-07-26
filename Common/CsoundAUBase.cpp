/*
 * CsoundAUBase.cpp
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include "CsoundAUBase.h"
#include "JSONParser.h"

CsoundAUBase::CsoundAUBase(AUBase *parent)
{
    map<string, string> configuration = parseConfiguration(BUNDLEID);
    bundleID = CFStringCreateWithCString(kCFAllocatorDefault, BUNDLEID, kCFStringEncodingASCII);
    guiBundleID = CFStringCreateWithCString(kCFAllocatorDefault, configuration["ViewBundleID"].c_str(), kCFStringEncodingASCII);
    string csdName = configuration["csd"].c_str();

    this->parent = parent;
    CFBundleRef bundle = CFBundleGetBundleWithIdentifier(bundleID);
    CFStringRef csdNameString = CFStringCreateWithCString(kCFAllocatorDefault, csdName.c_str(), kCFStringEncodingASCII);
    CFURLRef csdURL = CFBundleCopyResourceURL(bundle,
                                                 csdNameString,
                                                 CFSTR("csd"),
                                                 NULL);

    CFStringRef csdStringRef = CFURLCopyPath(csdURL);
    char *filePathString = (char *)CFStringGetCStringPtr(csdStringRef, kCFStringEncodingUTF8);
    char *argv[2] = {(char *)"csound", filePathString};
    csound = csoundCreate(parent);
    int result = csoundCompile(csound, 2, argv);
    if (result != 0) {

        printf("compilation failed\n");
        exit(-1);
    }
    csoundSetHostImplementedAudioIO(csound, 1, 0);

    vector<Parameter> parameters = parseParameters(BUNDLEID);
    vector<pair<string, Preset>> presets = parsePresets(BUNDLEID);
    SetParameters(parameters);
    if (presets.size() > 0) {
        SetPresets(presets);
    }
}


CsoundAUBase::~CsoundAUBase()
{
    csoundCleanup(csound);
    csoundDestroy(csound);
}

void CsoundAUBase::NewParameter(string name,
                                Float32 minValue,
                                Float32 maxValue,
                                Float32 defaultValue,
                                AudioUnitParameterUnit unit,
                                UInt32 flags)
{
    CsoundAUBase::NewParameter(name, minValue, maxValue, defaultValue, unit, flags, {});
}

void CsoundAUBase::NewParameter(string name,
                                Float32 minValue,
                                Float32 maxValue,
                                Float32 defaultValue,
                                AudioUnitParameterUnit unit,
                                UInt32 flags,
                                std::vector <string> strings)
{
    UInt32 index = (UInt32)parameters.size();
    parameterIndices[name] = index;
    parameters.push_back(Parameter(name, minValue, maxValue, defaultValue, unit, flags, strings));
    defaultPreset[name] = defaultValue;
}

void CsoundAUBase::SetParameters(vector<Parameter> parameters)
{
    for (size_t i = 0; i < parameters.size(); ++i) {

        Parameter parameter = parameters[i];

        if (parameter.strings.size() == 0) {

            NewParameter(parameter.name, parameter.minValue, parameter.maxValue, parameter.defaultValue, parameter.unit, parameter.flags);
        }
        else {

            NewParameter(parameter.name, parameter.minValue, parameter.maxValue, parameter.defaultValue, parameter.unit, parameter.flags, parameter.strings);
        }
    }

    for (UInt32 i = 0; i < parameters.size(); ++i) {

        parent->Globals()->SetParameter(i, parameters[i].defaultValue);
    }

    parent->Globals()->UseIndexedParameters((int)parameters.size());
}
void CsoundAUBase::NewPreset(string name, Preset preset)
{
    Preset newPreset = defaultPreset;

    for(auto const &iterator : preset) {

        string key = iterator.first;
        Float32 value = preset[key];
        newPreset[key] = value;
    }

    presets.push_back({name, newPreset});
}

void CsoundAUBase::SetPresets(vector<pair<string, Preset>> presetsIn)
{
    for (size_t i = 0; i < presetsIn.size(); ++i) {

        string name = presetsIn[i].first;
        Preset preset = presetsIn[i].second;
        NewPreset(name, preset);
    }

    const char *presetName = (char *)presets[0].first.c_str();
    AUPreset p = {0};
    p.presetNumber = 0;
    p.presetName = CFStringCreateWithCString(kCFAllocatorDefault, presetName, kCFStringEncodingASCII);
    parent->SetAFactoryPresetAsCurrent(p);


    for (size_t i = 0; i < presets.size(); ++i) {

        AUPreset preset = {0};
        preset.presetNumber = (UInt32)i;
        preset.presetName = CFStringCreateWithCString(kCFAllocatorDefault, presets[i].first.c_str(), kCFStringEncodingASCII);
        auPresetMenuEntries.push_back(preset);
    }

}

ComponentResult CsoundAUBase::GetPresets (CFArrayRef	*outData) const
{
    if (outData == NULL) return noErr;

    CFMutableArrayRef presetsArray = CFArrayCreateMutable (NULL,
                                                           auPresetMenuEntries.size(),
                                                           NULL);
    for (int i = 0; i < auPresetMenuEntries.size(); ++i) {

        CFArrayAppendValue (presetsArray, &auPresetMenuEntries[i]);
    }

    *outData = (CFArrayRef)presetsArray;
    return noErr;
}

OSStatus CsoundAUBase::NewFactoryPresetSet (const AUPreset &inNewFactoryPreset)
{
    SInt32 chosenPreset = inNewFactoryPreset.presetNumber;

    Preset preset = presets[chosenPreset].second;

    for(auto const &iterator : preset) {

        string key = iterator.first;
        Float32 value = preset[key];
        UInt32 index = parameterIndices[key];

        parent->Globals()->SetParameter(index, value);
    }

    const char *presetName = (char *)presets[chosenPreset].first.c_str();
    AUPreset p = {0};
    p.presetNumber = chosenPreset;
    p.presetName = CFStringCreateWithCString(kCFAllocatorDefault, presetName, kCFStringEncodingASCII);
    parent->SetAFactoryPresetAsCurrent(p);

    return noErr;
}

ComponentResult CsoundAUBase::GetProperty (AudioUnitPropertyID inID,
                                           AudioUnitScope inScope,
                                           AudioUnitElement inElement,
                                           void *outData,
                                           OSStatus (*CallGetParentProperty)(CsoundAUEffect *self,
                                                                             AudioUnitPropertyID inID,
                                                                             AudioUnitScope inScope,
                                                                             AudioUnitElement inElement,
                                                                             void *outData))
{
    if (inScope == kAudioUnitScope_Global) {

        switch (inID) {

            case kAudioUnitProperty_CocoaUI: {

                CFBundleRef bundle = CFBundleGetBundleWithIdentifier(bundleID);

                if (bundle == NULL) return fnfErr;

                CFURLRef bundleURL = CFBundleCopyResourceURL(bundle,
                                                             guiBundleID,
                                                             CFSTR("bundle"),
                                                             NULL);

                if (bundleURL == NULL) return fnfErr;

                AudioUnitCocoaViewInfo cocoaInfo = {bundleURL, {CFSTR("CsoundAUViewFactory")}};
                *((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;

                return noErr;
            }
        }
    }

    return CallGetParentProperty((CsoundAUEffect *)parent, inID, inScope, inElement, outData);
}

ComponentResult CsoundAUBase::GetPropertyInfo (AudioUnitPropertyID inID,
                                               AudioUnitScope inScope,
                                               AudioUnitElement inElement,
                                               UInt32 &outDataSize,
                                               Boolean &outWritable,
                                               ComponentResult (*CallGetParentPropertyInfo) (CsoundAUEffect *self,
                                                                                             AudioUnitPropertyID inID,
                                                                                             AudioUnitScope inScope,
                                                                                             AudioUnitElement inElement,
                                                                                             UInt32 &outDataSize,
                                                                                             Boolean &outWritable))
{
    if (inScope == kAudioUnitScope_Global) {

        switch (inID) {

            case kAudioUnitProperty_CocoaUI: {

                outWritable = false;
                outDataSize = sizeof(AudioUnitCocoaViewInfo);
                return noErr;
            }
        }
    }
    return CallGetParentPropertyInfo ((CsoundAUEffect *)parent, inID, inScope, inElement, outDataSize, outWritable);
}

ComponentResult CsoundAUBase::GetProperty (AudioUnitPropertyID inID,
                                           AudioUnitScope inScope,
                                           AudioUnitElement inElement,
                                           void *outData,
                                           OSStatus (*CallGetParentProperty)(CsoundAUSynth *self,
                                                                             AudioUnitPropertyID inID,
                                                                             AudioUnitScope inScope,
                                                                             AudioUnitElement inElement,
                                                                             void *outData))
{
    if (inScope == kAudioUnitScope_Global) {

        switch (inID) {

            case kAudioUnitProperty_CocoaUI: {

                CFBundleRef bundle = CFBundleGetBundleWithIdentifier(bundleID);

                if (bundle == NULL) return fnfErr;

                CFURLRef bundleURL = CFBundleCopyResourceURL(bundle,
                                                             guiBundleID,
                                                             CFSTR("bundle"),
                                                             NULL);

                if (bundleURL == NULL) return fnfErr;

                AudioUnitCocoaViewInfo cocoaInfo = {bundleURL, {CFSTR("CsoundAUViewFactory")}};
                *((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;

                return noErr;
            }
        }
    }

    return CallGetParentProperty((CsoundAUSynth *)parent, inID, inScope, inElement, outData);
}

ComponentResult CsoundAUBase::GetPropertyInfo (AudioUnitPropertyID inID,
                                               AudioUnitScope inScope,
                                               AudioUnitElement inElement,
                                               UInt32 &outDataSize,
                                               Boolean &outWritable,
                                               ComponentResult (*CallGetParentPropertyInfo) (CsoundAUSynth *self,
                                                                                             AudioUnitPropertyID inID,
                                                                                             AudioUnitScope inScope,
                                                                                             AudioUnitElement inElement,
                                                                                             UInt32 &outDataSize,
                                                                                             Boolean &outWritable))
{
    if (inScope == kAudioUnitScope_Global) {

        switch (inID) {

            case kAudioUnitProperty_CocoaUI: {

                outWritable = false;
                outDataSize = sizeof(AudioUnitCocoaViewInfo);
                return noErr;
            }
        }
    }
    return CallGetParentPropertyInfo ((CsoundAUSynth *)parent, inID, inScope, inElement, outDataSize, outWritable);
}

ComponentResult CsoundAUBase::GetParameterInfo(AudioUnitScope inScope,
                                               AudioUnitParameterID inParameterID,
                                               AudioUnitParameterInfo &outParameterInfo)
{
    ComponentResult result = noErr;
    outParameterInfo.flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable;

    if (inParameterID >= parameters.size()) {

        result =  kAudioUnitErr_InvalidParameter;
    }

    if (inScope == kAudioUnitScope_Global) {

        Parameter parameter = parameters[inParameterID];
        CFStringRef cfsName = CFStringCreateWithCString(kCFAllocatorDefault, parameter.name.c_str(), kCFStringEncodingASCII);
        outParameterInfo.cfNameString = cfsName;
        outParameterInfo.flags |= kAudioUnitParameterFlag_HasCFNameString;
        CFStringGetCString (cfsName, outParameterInfo.name, offsetof (AudioUnitParameterInfo, clumpID), kCFStringEncodingUTF8);

        outParameterInfo.unit = parameter.unit;
        outParameterInfo.minValue = parameter.minValue;
        outParameterInfo.maxValue = parameter.maxValue;
        outParameterInfo.defaultValue = parameter.defaultValue;
        outParameterInfo.flags |= parameter.flags;
    }
    else {

        result = kAudioUnitErr_InvalidParameter;
    }

    return result;
}

ComponentResult CsoundAUBase::GetParameterValueStrings(AudioUnitScope inScope,
                                                       AudioUnitParameterID inParameterID,
                                                       CFArrayRef *outStrings)
{
    if (inScope == kAudioUnitScope_Global
        &&
        parameters[inParameterID].strings.size() > 0) {

        if (outStrings == NULL) return noErr;

        size_t stringsCount = parameters[inParameterID].strings.size();
        CFStringRef strings[stringsCount];

        for (size_t i = 0; i < stringsCount; ++i) {

            strings[i] = CFStringCreateWithCString(kCFAllocatorDefault,
                                                   parameters[inParameterID].strings[i].c_str(),
                                                   kCFStringEncodingASCII);
        }

        *outStrings = CFArrayCreate(NULL,
                                    (const void **)strings,
                                    stringsCount,
                                    NULL);
        return noErr;
    }
    return kAudioUnitErr_InvalidParameter;
}
