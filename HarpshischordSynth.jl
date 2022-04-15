using DelimitedFiles;
using Plots;
#harmonic template struct
#mutable so we can change it, just to hold data
#= harmo = (
  (1, -15.8, -3., -15.3, -22.8, -40.7),
  (16, -15.8, -3., -15.3, -22.8, -40.7),
  (28, -5.7, -4.4, -17.7, -16., -38.7),
  (40, -6.8, -17.2, -22.4, -16.8, -75.6),
  (52, -8.4, -19.7, -23.5, -21.6, -76.8),
  (64, -9.3, -20.8, -37.2, -36.3, -76.4),
  (76, -18., -64.5, -74.4, -77.3, -80.8),
  (88, -24.8, -53.8, -77.2, -80.8, -90.),
)




    #check if input is in cents

#synthesize function, used to perform synthesize on a particular harmonic template

#TODO: need to implement envelope into this. 
#attack is how long it goes from silence to original sound
#N is length not including the release(the release is like extra after the note ended)
function synthesize(f::Number, S::Number, N::Number, ht::harmonicTemplate)

    #change pulse width to 40%
    #VCO 2 Saw tune + 1 octave oscillator balance 40/60
    # add low pass filter 24db/octave
    # Decrease resonance 85%
    

    attackSamples = 0
    decaySamples = (ht.decay*S)/2
    sustain = 0
    releaseSamples = (ht.release*S)*.45
    harmonicFreqs::Vector{Number} = collect(f* (1:16))
    synthesizedWaveform = sin.(2π * (1:N) * harmonicFreqs'/S) * ht.harmonicAmplitudes
    synthesizedWaveform = synthesizedWaveform .- sum(synthesizedWaveform)/N
#=     @show extrema(synthesizedWaveform);
    @show typeof(synthesizedWaveform)
    plot(synthesizedWaveform)
    gui()
    throw("hello") =#
    releaseWaveform = sin.(2π* (N+1:N+releaseSamples) * harmonicFreqs'/S) * ht.harmonicAmplitudes;
    #envelope generator downhere
    peakVolume = 1; #default
    sustainVolume = peakVolume * 10^(sustain);
    releaseVolume = 0;
    for i in range(1, size(synthesizedWaveform,1))
        if(i <= attackSamples) #within the range of attack portion
            synthesizedWaveform[i] = synthesizedWaveform[i] * (i/attackSamples)*peakVolume;
            releaseVolume = (i/attackSamples)*peakVolume;
        elseif(i > attackSamples && i <= attackSamples+decaySamples)
            synthesizedWaveform[i] = synthesizedWaveform[i] * peakVolume * 10^(sustain*(i-attackSamples)/decaySamples);
            releaseVolume = peakVolume * 10^(sustain*(i-attackSamples)/decaySamples);
        elseif(i > attackSamples+decaySamples)
            synthesizedWaveform[i] = synthesizedWaveform[i] * sustainVolume;
            releaseVolume = sustainVolume;
        end
    end
    for i in range(1,size(releaseWaveform, 1))
        releaseWaveform[i] = releaseWaveform[i] * releaseVolume * (1.0- i/releaseSamples);
    end
    return synthesizedWaveform, releaseWaveform;
end
#while new data is coming in, checking if they stopped pressing, i.e. no data is coming through
#check where we are on the envelope
#

#TODO: Need continuous synthesize function where it will continously give out sound when a key is continously pressed

#Sound file full synthesize function

#need to remember to increment current_length outside of this function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Let me know if we should do it in the function
function synthesize_period(f::Number, S::Number, current_length::Number, ht::harmonicTemplate)
    T = 1/f;
    numPeriodSamples = round(Int, T*S);
    attackSamples = 9;
    decaySamples = (ht.decay*S)/2;
    sustain = 0;

    harmonicFreqs::Vector{Number} = [f*i for i in range(1,16)];
    periodWaveform = vec(cos.(2π * (current_length+1:current_length+numPeriodSamples) * harmonicFreqs'/S) * ht.harmonicAmplitudes);
    #must normalize before applying harmonic
    periodWaveform = periodWaveform / maximum(abs, periodWaveform)
    peakVolume = 1; #default
    sustainVolume = peakVolume * 10^(sustain);
    releaseVolume = 0;
    for i in range(1, size(periodWaveform,1))
        if(current_length+i <= attackSamples) #within the range of attack portion
            periodWaveform[i] = periodWaveform[i] * ((i+current_length)/attackSamples)*peakVolume;
            releaseVolume = (i/attackSamples)*peakVolume;
        elseif((current_length+i) > attackSamples && (current_length+i) <= attackSamples+decaySamples)
            periodWaveform[i] = periodWaveform[i] * peakVolume * 10^(sustain*((i+current_length)-attackSamples)/decaySamples);
            releaseVolume = peakVolume * 10^(sustain*((i+current_length)-attackSamples)/decaySamples);
        elseif((current_length+i) > attackSamples+decaySamples)
            periodWaveform[i] = periodWaveform[i] * sustainVolume;
            releaseVolume = sustainVolume;
        end
    end
    return periodWaveform, releaseVolume;
end

function synthesize_release_period(releaseVolume::Number, release_current_length::Number, ht::harmonicTemplate, f::Number, S::Number, current_length::Number)
    T = 1/f;
    numPeriodSamples = round(Int, T*S);
    harmonicFreqs::Vector{Number} = [f*i for i in range(1,16)];
    print("hello")
    releaseSamples = (ht.release*S)*.45;
    releaseWaveform = vec(cos.(2π* (current_length+1:current_length+numPeriodSamples) * harmonicFreqs'/S) * ht.harmonicAmplitudes);
    releaseWaveform = releaseWaveform / maximum(abs, releaseWaveform)
    for i in range(1,size(releaseWaveform, 1))
        releaseWaveform[i] = releaseWaveform[i] * releaseVolume * (1.0 - (i+release_current_length)/releaseSamples);
    end
    return releaseWaveform;
end

#synthesize wrapper, generates whole entire song
#takes a total gain
function synthesize(notes, S::Number, ht::harmonicTemplate)
    totalWaveform = [];
    releaseQueue = zeros(round(Int,ht.release*S));
    for i in range(1,size(notes,1))
        #looping across all notes
        newWaveform, newRelease = synthesize(notes[i][1], S, notes[i][2], ht);
        #add any old release to newWaveform
        #eventually it will start adding zeros if newWaveform is bigger than the release stored
        for j in range(1,size(newWaveform,1))
            #get the first from the releaseQueue
            #then delete the first and add a zero to the end
            #a problem here is that it's possible for it to be clipped
            newWaveform[j] += releaseQueue[1];
            popfirst!(releaseQueue);
            push!(releaseQueue, 0);
        end
        #put new release on the old release.
        releaseQueue += newRelease;
        append!(totalWaveform,newWaveform);
    end
    append!(totalWaveform,releaseQueue);
    totalWaveform = convert(Vector{Float64},totalWaveform);
    totalWaveform = totalWaveform ./ maximum(totalWaveform);
    return totalWaveform;
end

=#

function generatePartialFrequencies(f, B, numPartials)
    partialFrequencies = [];
    for i in range(1,numPartials)
        partialFreq = i*f*sqrt(1+B*(i^2)); 
        partialFrequencies = [partialFrequencies, partialFreq];
    end
    return partialFrequencies;
end


function synthesize_harpsichord(f, S::Number, N::Number)
    attackSamples = (.5*N)*S;
    decaySamples = (S)/2;
    sustain  = ;
    releaseSamples = 100;
    harmonicFreqs::Vector{Number} = generatePartialFrequencies(f, 79, 12);
    synthesizedWaveform = sin.(2π * (1:N) * harmonicFreqs'/S) * ht.harmonicAmplitudes;
    synthesizedWaveform = synthesizedWaveform .- sum(synthesizedWaveform)/N;
#=     @show extrema(synthesizedWaveform);
    @show typeof(synthesizedWaveform)
    plot(synthesizedWaveform)
    gui()
    throw("hello") =#
    releaseWaveform = sin.(2π* (N+1:N+releaseSamples) * harmonicFreqs'/S) * ht.harmonicAmplitudes;
    #envelope generator downhere
    peakVolume = 1; #default
    sustainVolume = peakVolume * 10^(sustain/10);
    releaseVolume = 0;
    for i in range(1, size(synthesizedWaveform,1))
        if(i <= attackSamples) #within the range of attack portion
            synthesizedWaveform[i] = synthesizedWaveform[i] * (i/attackSamples)*peakVolume;
            releaseVolume = (i/attackSamples)*peakVolume;
        elseif(i > attackSamples && i <= attackSamples+decaySamples)
            synthesizedWaveform[i] = synthesizedWaveform[i] * peakVolume * 10^(sustain/10*(i-attackSamples)/decaySamples);
            releaseVolume = peakVolume * 10^(sustain/10*(i-attackSamples)/decaySamples);
        elseif(i > attackSamples+decaySamples)
            synthesizedWaveform[i] = synthesizedWaveform[i] * sustainVolume;
            releaseVolume = sustainVolume;
        end
    end
    for i in range(1,size(releaseWaveform, 1))
        releaseWaveform[i] = releaseWaveform[i] * releaseVolume * (1.0- i/releaseSamples);
    end
    return synthesizedWaveform, releaseWaveform;


end