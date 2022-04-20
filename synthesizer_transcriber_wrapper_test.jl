include("synthesizer_core.jl");
include("transcriber.jl")
include("synthchordUtil.jl")
using PortAudio;
using WAV;
out_stream = PortAudioStream(0, 2);


htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Triangle16"];
waveform, S = wavread("twinkle.wav");
waveform .= waveform ./maximum(waveform) 
#= write(out_stream, waveform) =#
#= 
waveform = (cos.(2pi*440/44100 * (1:(44100*3))));
waveform = [waveform; (cos.(2pi*880/44100 * (1:(44100*3))))] =#
S = 44100

notes = [(frequency("C",4),S*1),(frequency("C",4),S*1),(frequency("G",4),S*1),(frequency("G",4),S*1),(frequency("A",4),S*1),(frequency("A",4),S*1),(frequency("G",4),S*1)]

x = synthesize(notes, 44100, ht)

#= p1 = autocorrelate(waveform[1:3500], 44100)
xlims!((0,500))
title!("Autocorrelation of the first 3500 samples of Twinkle Twinkle Little Star", titlefontsize = 10)
xlabel!("Time Lag in Samples")
ylabel!("Correlation")
old_xticks = xticks(p1[1])
new_xticks = ([169], ["169"])
vline!(new_xticks[1], legend=:topright, label ="Maximum of Second Peak")
keep_indices = findall(x -> all(x .≠ new_xticks[1]), old_xticks[1])
merged_xticks = (old_xticks[1][keep_indices] ∪ new_xticks[1], old_xticks[2][keep_indices] ∪ new_xticks[2])
xticks!(merged_xticks) =#
y = transcribe(waveform, S);
z = synthesize(y, S, ht); 
write(out_stream, z)