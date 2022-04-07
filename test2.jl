include("synthesizer_core.jl");
using PortAudio
htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];
current_length = 0;
releaseVolume = 0; 
out_stream = PortAudioStream(0, 2)


S = 44100
stream = PortAudioStream(0, 2; samplerate=Float64(S)) 
releaseSamples = round(Int, (ht.release)*S);

while current_length < 4*S
    global current_length
    global releaseVolume;
    global release;
    # print(current_length)
    periodWaveform, releaseVolume = synthesize_period(440,S, current_length, ht);
    current_length = current_length + round(Int, (1/440)*S) 
    write(stream, periodWaveform)
    # if current_length >= 16384
    #     break
    # end
end

release_current_length = 0;
while release_current_length < releaseSamples
    global release_current_length;
    global current_length;
    global releaseVolume;
    release = synthesize_release_period(releaseVolume, release_current_length, ht, 440, S, current_length);
    current_length = current_length + round(Int, (1/440) *S);
    release_current_length += round(Int, (1/440) *S);
    write(stream, release);
end