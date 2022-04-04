include("synthesizer_core.jl");
using Sound;
using PortAudio;
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]
out_stream = PortAudioStream(1, 1);


synthesizedWaveForm, releaseWaveform = synthesize(440, 44100, 4*44100, ht);

waveform = [synthesizedWaveForm; releaseWaveform];

PortAudioStream(0, 2; samplerate=Float64(S)) do stream
    write(stream, waveform)
end


#=  =#