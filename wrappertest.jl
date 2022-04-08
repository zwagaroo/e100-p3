include("synthesizer_core.jl");
include("transcriber.jl")
include("synthcoreUtil.jl")
using PortAudio;
out_stream = PortAudioStream(0, 2);


htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];

waveform = (cos.(2pi*440/44100 * (1:(44100*3))));
waveform = [waveform; (cos.(2pi*880/44100 * (1:(44100*3))))]
S = 44100

notes = [(frequency("C",4),S*1),(frequency("C",4),S*1),(frequency("G",4),S*1),(frequency("G",4),S*1),(frequency("A",4),S*1),(frequency("A",4),S*1),(frequency("G",4),S*1)]

a = synthesize(notes, 44100, ht)
a ./= maximum(a)
b = transcribe(a, 44100);
#= println(b)
write(out_stream, a)
 =#
