<CsoundSynthesizer>
<CsOptions>
-+rtaudio=null -odac

</CsOptions>
<CsInstruments>
nchnls = 2
0dbfs = 1
ksmps = 64
sr = 44100

schedule 1, 0, -1


opcode Delay, a, aikkk

    aInput, iMaxDelayTime, kDelayTime, kFeedback, kMix xin
    aDelayOut delayr	 iMaxDelayTime
    aDelayTap deltapi kDelayTime
    delayw	aInput + aDelayTap * kFeedback
    xout aDelayTap * (1 - kMix) + aInput * kMix
endop

instr 1

kTime chnget "Time"
kFeedback chnget "Feedback"
kMix chnget "Mix"

aInputL, aInputR ins

aOutputL Delay aInputL, 10, kTime, kFeedback, kMix
aOutputR Delay aInputR, 10, kTime, kFeedback, kMix

outs aOutputL, aOutputR
endin

</CsInstruments>
</CsoundSynthesizer>
