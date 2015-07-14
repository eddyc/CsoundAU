<CsoundSynthesizer>
<CsOptions>
-+rtmidi=null -+rtaudio=null -M0
</CsOptions>
<CsInstruments>
nchnls = 2
0dbfs = 1
ksmps = 64
sr = 44100

instr 1
kFrequency chnget "Frequency"
iCps    cpsmidi   ;get the frequency from the key pressed
iAmp    ampmidi   0dbfs * 0.3 ;get the amplitude
aOut    poscil    iAmp, iCps + kFrequency * 10, giSine ;generate a sine tone
outs      aOut, aOut ;write it to the output
endin

</CsInstruments>
</CsoundSynthesizer>
