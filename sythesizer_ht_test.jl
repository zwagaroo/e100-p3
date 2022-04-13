include("synthesizer_core.jl");
using Sound;
using PortAudio;
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]
S = 44100
out_stream = PortAudioStream(0, 2; samplerate=Float64(S))


#= synthesizedWaveForm, releaseWaveform = synthesize(440, 44100, round(Int,.3*44100), ht); =#
#= 
waveform = [synthesizedWaveForm; releaseWaveform]; =#


notes = [(frequency("C",4),S*1),(frequency("C",4),S*1),(frequency("G",4),S*1),(frequency("G",4),S*1),(frequency("A",4),S*1),(frequency("A",4),S*1),(frequency("G",4),S*1)]
waveform = synthesize(notes,44100, ht)
#= soundsc(waveform, 44100) =#

y = waveform / maximum(abs, waveform)
plot(y, label = "", title = "Generated Waveform of Multple Notes", xlabel = "Samples", ylabel = "Amplitude")
plot(abs.(fft(y)))
#= write(out_stream, y) =#


#=  =#