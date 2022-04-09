include("synthesizer_core.jl");
using Sound;
using PortAudio;
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]
S = 44100
out_stream = PortAudioStream(0, 2; samplerate=Float64(S))


synthesizedWaveForm, releaseWaveform = synthesize(440, 44100, 4*44100, ht);

waveform = [synthesizedWaveForm; releaseWaveform];

#= soundsc(waveform, 44100) =#

y = waveform / maximum(abs, waveform)
write(out_stream, y)


#=  =#