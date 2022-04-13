include("synthesizer_core.jl");
include("transcriber.jl");
include("synthchordUtil.jl");
using PortAudio;
using WAV;
using Plots;
out_stream = PortAudioStream(0, 2);
htDict = readHarmonicTemplates("harmonicTemplates.txt")
ht = htDict["Saw16"]
#= waveform, S = wavread("twinkletwinkle.wav");
waveform .= waveform ./maximum(waveform); =#
notes = [(262.5, 22050), (262.5, 22050), (393.75, 22050), (393.75, 22050), (441.0, 22050), (441.0, 22050), (393.75, 44100)];
waveform = synthesize(notes, 44100, ht)
errors = zeros(Int, 20); snr = zeros(20);
numtrialsperlevel = 10;

for level = 1:20 # 10 different noise levels
    noisesum = 0;
    for trial=1:numtrialsperlevel
        noise = .002 * level * randn(size(waveform));
        noisyWaveform = waveform + noise;
        noisesum += sum(noise.^2);
        result = transcribe(noisyWaveform, S);
        correct_result = [(262.5, 22050), (262.5, 22050), (393.75, 22050), (393.75, 22050), (441.0, 22050), (441.0, 22050), (393.75, 44100)];
        #it's okay for results to have some zeros, but it should have similar to this
        for note in result
            if(note[1] == 0)
                if(!(note[2] < 5500))
                    errors[level] += 1;
                    break;
                end
            end
            anycorrect = false;
            for correct_note in correct_result
                if(note[1] < correct_note[1] *2^(1/24) && note[1] > correct_note[1] * 2^(-1/24) || note[1] == 0 && correct_note[1] == 0)
                    if(note[2] < correct_note[2] +3500 && note[2] > correct_note[2]-3500)
                        anycorrect = true;
                    end
                end
            end
            if(anycorrect == false)
                errors[level]+=1;
                break;
            end
        end

    end
    errors[level] = errors[level]/numtrialsperlevel *100
    snr[level] = 10*log10(sum(waveform.^2) / (noisesum/numtrialsperlevel))
end
plot(snr, errors, marker=:circle, xlabel="Signal to Noise Ratio (dB)", ylabel="Error Rate (%)", title = "SNR vs Error Rate")