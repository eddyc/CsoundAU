<CsoundSynthesizer>
<CsInstruments>
instr Gain

    aInputL, aInputR ins
    kGain chnget "Gain"
    aOutputL = aInputL * kGain
    aOutputR = aInputR * kGain
    outs aOutputL, aOutputR
endin
</CsInstruments>
</CsoundSynthesizer>
