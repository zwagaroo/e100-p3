include("synthesizer_core.jl");
using Sound;

ht = harmonicTemplate(.400, .200, -.1, 1);
ht.harmonicAmplitudes[2] = .5;

synthesizedWaveForm, releaseWaveform = synthesize(440, 8192, 3*8192, ht);
waveform = [synthesizedWaveForm; releaseWaveform]
soundsc(waveform, 8192);

