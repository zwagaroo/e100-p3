include("synthesizer_core.jl");
using Sound 
htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["A"];
current_length = 0;
releaseVolume = 0; 

while current_length < 16384
    global current_length
    global releaseVolume;
    # print(current_length)
    periodWaveform, releaseVolume = synthesize(ht, 440, 8192, current_length);
    soundsc(periodWaveform, 8192);
    current_length =current_length + round(Int, (1/440)*8192)*200 
    println(current_length)
    # if current_length >= 16384
    #     break
    # end
end

# while(current_length < 16384)
#     global current_length;
#     global releaseVolume;
#     print(current_length)
#     periodWaveform, releaseVolume = synthesize(ht, 440, 8192, current_length);
#     soundsc(periodWaveform, 8192);
#     current_length =current_length + round(Int, 1/440*8192) 
#     println(current_length)
# end
releaseWaveform = synthesize_release(releaseVolume,ht,current_length);
write(out_stream, releaseWaveform);