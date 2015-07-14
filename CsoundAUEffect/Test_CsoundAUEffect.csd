<CsoundSynthesizer>
<CsOptions>
-+rtaudio=null

</CsOptions>
<CsInstruments>
nchnls = 2
0dbfs = 1
ksmps = 64
sr = 44100

schedule 1, 0, -1

instr 1

kFrequency chnget "Frequency"
kDepth chnget "Depth"
kWaveform chnget "Waveform"

aInputL, aInputR ins
aLFOSin lfo 1, kFrequency, 1
aLFOSaw lfo 1, kFrequency, 4

if kWaveform == 1 then

aLFO = aLFOSin

else

aLFO = aLFOSaw

endif

kDepth =  kDepth / 100
aOutputL = (aLFO * aInputL * kDepth) + (aInputL * (1 - kDepth))
aOutputR = (aLFO * aInputR * kDepth) + (aInputR * (1 - kDepth))

outs aOutputL, aOutputR
endin

</CsInstruments>
</CsoundSynthesizer>
