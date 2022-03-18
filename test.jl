include("synthesizer_core.jl");
using Sound;
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]

synthesizedWaveForm, releaseWaveform = synthesize(440, 8192, 3*8192, ht);
waveform = [synthesizedWaveForm; releaseWaveform];
soundsc(waveform, 8192);


