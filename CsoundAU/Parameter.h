/*
 * Parameter.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import <string>
#import <vector>
#import <AudioUnit/AudioUnitProperties.h>
using namespace std;

class Parameter{
public:
    Parameter();
    Parameter(string name,
              Float32 minValue,
              Float32 maxValue,
              Float32 defaultValue,
              AudioUnitParameterUnit unit,
              UInt32 flags);

    Parameter(string name,
              Float32 minValue,
              Float32 maxValue,
              Float32 defaultValue,
              AudioUnitParameterUnit unit,
              UInt32 flags,
              vector <string> strings);

    string name;
    Float32 minValue;
    Float32 maxValue;
    Float32 defaultValue;
    AudioUnitParameterUnit unit;
    UInt32 flags;
    size_t index;
    vector <string> strings;
};
