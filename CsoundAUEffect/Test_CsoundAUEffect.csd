<CsoundSynthesizer>
<CsOptions>
-+rtaudio=null -odac
</CsOptions>
<CsInstruments>
nchnls = 2
0dbfs = 1
ksmps = 64
sr = 44100


instr Delay

    iMaxDelayTime = 1.
    kDelayTime = 0.3
    kFeedback = 0.8
    kMix = 0.5
    aInputL, aInputR ins
    aInput = (aInputL + aInputR) / 2
    aDelayOut delayr iMaxDelayTime
    aDelayTap deltap kDelayTime
    delayw  aInput + aDelayTap * kFeedback
    aOut = aInput * kMix + aDelayTap * (1 - kMix)
    outs aOut, aOut
endin

schedule "Delay", 0, -1

</CsInstruments>
<CsScore>
e36000
</CsScore>
</CsoundSynthesizer>
