/*
 * Parameter.cpp
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include "Parameter.h"

Parameter::Parameter(string name,
                     Float32 minValue,
                     Float32 maxValue,
                     Float32 defaultValue,
                     AudioUnitParameterUnit unit,
                     UInt32 flags)
{
    this->name = name;
    this->minValue = minValue;
    this->maxValue = maxValue;
    this->defaultValue = defaultValue;
    this->unit = unit;
    this->flags = flags;
}

Parameter::Parameter(string name,
                      Float32 minValue,
                      Float32 maxValue,
                      Float32 defaultValue,
                      AudioUnitParameterUnit unit,
                      UInt32 flags,
                      vector <string> strings)
: Parameter(name, minValue, maxValue, defaultValue, unit, flags)
{
    this->strings = strings;
}
