using Peaks;
using FFTW;
using Plots;
include("transcriber.jl")

waveform = (cos.(2pi*440/44100 * (1:(44100*3))));
waveform = [waveform; (1cos.(2pi*174/44100 * (1:(32413))))]
waveform = [waveform; (cos.(2pi*3423/44100 * (1:(5492))))]
waveform = [waveform; (cos.(2pi*1500/44100 * (1:(44100÷2))))]
waveform = [waveform; (cos.(2pi*1000/44100 * (1:(44100÷8))))]
waveform = [waveform; (cos.(2pi*2000/44100 * (1:(44100÷2))))]
#= waveform = waveform[1:2100] =#
#= M = length(waveform)÷3
hps = x[1:M] .* x[1:2:2M] .* x[1:3:3M];
hps ./= maximum(hps);

plot(hps)
x = real(ifft(hps)) =#
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

