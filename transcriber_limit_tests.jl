using Peaks;
using FFTW;
using Plots;
include("transcriber.jl")
include("synthesizer_core.jl")
using Sound

htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];


waveform =  (0cos.(2pi*2000/44100 * (1:(44100÷2)))) 
waveform = [waveform; (2cos.(2pi*800/44100 * (1:(44100÷2))))]
waveform = [waveform; (2cos.(2pi*900/44100 * (1:(44100÷3))))]
#= waveform = waveform[1:2100] =#
#= autocorrelate(waveform, 44100) =#

#= autocorr = real(ifft(abs2.(fft([waveform; zeros(length(waveform))])))) / sum(abs2, waveform);
plot(autocorr[1:500]) =#
#= big1 = autocorr .> 0.99
big1[1:findfirst(==(false), big1)] .= false
peak2start= findfirst(==(true), big1)
peak2end = findnext(==(false), big1, peak2start)
big1[peak2end:end] .= false
m = argmax(big1 .* autocorr)-1
f= 44100/m =#

a = transcribe(waveform, 44100)
println(a)
#= b = synthesize(a, 44100, ht)
soundsc(b, 44100) =#