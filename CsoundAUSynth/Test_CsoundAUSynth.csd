<CsoundSynthesizer>
<CsOptions>
-+rtmidi=null -+rtaudio=null -M0
</CsOptions>
<CsInstruments>
nchnls = 2
0dbfs = 1
ksmps = 64
sr = 44100


giSine  ftgen     0,0,2^10,10,1 ;a function table with a sine wave
instr 1
kFrequency chnget "Frequency"
iCps    cpsmidi   ;get the frequency from the key pressed
iAmp    ampmidi   0dbfs * 0.3 ;get the amplitude
aOut    poscil    iAmp, iCps + kFrequency * 10, giSine ;generate a sine tone
outs      aOut, aOut ;write it to the output
endin



</CsInstruments>
<CsScore>
i1 0 100000

</CsScore>
</CsoundSynthesizer>
