# CsoundAU
Enables running Csound instruments or effects as AudioUnits for use in Logic, GarageBand etc.

You can get an overview of how to use this framework in this video [here](https://www.youtube.com/watch?v=52rwayPxZDk)

## Dependencies
- Xcode 6+
- AU Lab (available as part of Audio Tools for Xcode from https://developer.apple.com/downloads/)
- Csound


## Description

This project will build two AudioUnit plugins: _CsoundAUEffect_ and _CsoundAUSynth_.
These plugins can be used as templates to create custom AudioUnit plugins with Cocoa UIs. 

Due to the differences in the way effects and instruments render audio and use MIDI, 
Csound effect plugins inherit from CsoundAUEffect and instruments inherit from CsoundAUSynth.
Each of these classes inherit from CsoundAUBase.
This class compiles .csd files and instantiates Csound. 
It is also responsible for configuring parameters and presets.

### Parameters

Parameters are the controls which are used for altering variables within Csound. 
Parameters are defined in the Parameters.json file.
The json is formatted as an array containing parameter objects.
Each object must contain a field for:

- **name** The name used in the chnget Csound opcode

- **minValue** The minimum value of the parameter

- **maxValue** The maximum value of the parameter

- **defaultValue** The default value of the parameter

Optional fields are: 

- **unit** which represents the kAudioUnitParameterUnit enum value

- **flag** which is the kAudioUnitParameterFlag enum value both found in AudioUnitProperties.h

- **strings** which is an array of strings useful for when the kAudioUnitParameterUnit_Indexed is used and the UI requires a drop down menu for example.

### Presets

Presets are used to store a configuration of parameters. 
They are found under the _Factory Presets_ heading within the AudioUnits preset list. 
Presets are defined in the Presets.json file.
The json is formatted as an array of preset objects.
Each object must contain a field for:

- **name** The presets name
- **preset** An object containing the presets parameter values

The parameter values are formatted as an object containing key/value pairs of the parameter and its corresponding value.

### Cocoa UI

Parameters are connected to Csound via the UI classes using the _setParameter forOutlet_ method found in _CsoundAUView_.
This method takes a string corresponding to the parameter defined in Csound and Parameters.json,
and the IBOutlet NSControl object which will be used to change the value. Examples of using this method can be found in the classes ending in UIView.m.
