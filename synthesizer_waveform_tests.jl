include("synthesizer_core.jl");
include("synthchordUtil.jl")
using FFTW
using Sound;
using PortAudio;
using Plots;
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]
S = 44100
out_stream = PortAudioStream(0, 2; samplerate=Float64(S))


#= synthesizedWaveForm, releaseWaveform = synthesize(440, 44100, round(Int,.3*44100), ht); =#
#= 
waveform = [synthesizedWaveForm; releaseWaveform]; =#


notes = [(frequency("A",4),S*1)]
waveform = synthesize(notes,44100, ht)
#= soundsc(waveform, 44100) =#

y = waveform / maximum(abs, waveform)
plot(y, label = "", title = "Generated Waveform of A440", xlabel = "Samples", ylabel = "Amplitude")
#= FFT = 2/size(waveform,1) *abs.(fft(y));
freqs = (((1:(length(FFT)))) .-1) .* S/length(FFT);
p1 = plot(freqs[1:10000], FFT[1:10000],label = "", title = "FFT of A440 Saw16", xlabel = "Frequencies (Hz)", ylabel = "Amplitude")
old_xticks = xticks(p1[1])
new_xticks = ([440, 880, 1320], ["440", "880", "1320"])
keep_indices = findall(x -> all(x .≠ new_xticks[1]), old_xticks[1])
merged_xticks = (old_xticks[1][keep_indices] ∪ new_xticks[1], old_xticks[2][keep_indices] ∪ new_xticks[2])
xticks!(merged_xticks) =#
#= write(out_stream, y) =#


#=  =#