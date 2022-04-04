include("synthesizer_core.jl");
using Sound 
using PortAudio
htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];
current_length = 0;
releaseVolume = 0; 
out_stream = PortAudioStream(0, 2)

function sound(x::AbstractMatrix, S::Real = framerate(x))
    if size(x,1) == 1 # row "vector"
        x = vec(x) # convenience
    end
    size(x,2) ≤ 2 || throw("size(x,2) = $(size(x,2)) is too many channels")
    PortAudioStream(0, 2; samplerate=Float64(S)) do stream
        write(stream, x)
    end
end

S = 44100
stream = PortAudioStream(0, 2; samplerate=Float64(S)) 
while current_length < 4*S
    global current_length
    global releaseVolume;
    # print(current_length)
    periodWaveform, releaseVolume = synthesize_period(440, 44100, current_length, ht);
    current_length = current_length + round(Int, (1/440)*44100) 

    write(stream, periodWaveform)
    # if current_length >= 16384
    #     break
    # end
end
