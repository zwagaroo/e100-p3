include("synthesizer_core.jl");
include("transcriber.jl")
include("synthchordUtil.jl")
using PortAudio;
using WAV;
out_stream = PortAudioStream(0, 2);


htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];
waveform, S = wavread("twinkletwinkle.wav");
waveform .= waveform ./maximum(waveform) 
#= 
waveform = (cos.(2pi*440/44100 * (1:(44100*3))));
waveform = [waveform; (cos.(2pi*880/44100 * (1:(44100*3))))] =#
S = 44100

notes = [(frequency("C",4),S*1),(frequency("C",4),S*1),(frequency("G",4),S*1),(frequency("G",4),S*1),(frequency("A",4),S*1),(frequency("A",4),S*1),(frequency("G",4),S*1)]

x = synthesize(notes, 44100, ht)

#= autocorrelate(waveform[1:3500], 44100)
title!("Autocorrelation of the first 3500 samples of Twinkle Twinkle Little Star", titlefontsize = 10)
xlabel!("Time Lag in Samples")
ylabel!("Correlation") =#

y = transcribe(waveform, S);
z = synthesize(y, S, ht);
 write(out_stream, z)
#=  =#

