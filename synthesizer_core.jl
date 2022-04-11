using DelimitedFiles;
using Plots;
#harmonic template struct
#mutable so we can change it, just to hold data

mutable struct harmonicTemplate
    #in seconds
    attack::Float64;
    decay::Float64;
    sustain::Float64; #in decibels (dB) sustain must be a negative number as it's relative to peak gain
    release::Float64;
    #relative amplitudes
    #vector of 16 values harmonicAmplitudes[harmonic] gives the amplitude of harmonic,
    harmonicAmplitudes::Vector{Float64};
    harmonicTemplate(a,d,s,r) = new(a,d,s,r, 
        Vector{Float64}([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));

    harmonicTemplate(a,d,s,r,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16) = 
        new(a,d,s,r, [a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16]);
end

function harmonicTemplate(a,d,s,r, harmonicAmplitudes)
    ht = harmonicTemplate(a,d,s,r);
    for i in range(1,size(harmonicAmplitudes,1))
        ht.harmonicAmplitudes[i] = harmonicAmplitudes[i];
    end
    return ht;
end

#reads a file where we store harmonic templates and construct the corresponding harmonic template
#ultimately returns a dict that represents harmonic templates
function readHarmonicTemplates(filePath::String)::Dict{String, harmonicTemplate}
    data = readdlm(filePath, ',', Any, '\n');
    htDict = Dict{String, harmonicTemplate}();
    for row in eachrow(data)
        htTemp = harmonicTemplate(row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18],row[19],row[20],row[21]);
        merge!(htDict, Dict{String, harmonicTemplate}(row[1] => htTemp));
    end
    return htDict;
end

function writeHarmonicTemplates(filePath::String, htDict::Dict{String, harmonicTemplate})
    #clear file
    io = open("harmonicTemplates.txt", "w");
    write(io, "");
    close(io);
    #rewrite our harmonic templates
    io = open("harmonicTemplates.txt", "a");
    for key in keys(htDict)
        htTemp = htDict[key];
        write(io, key, ",", string(htTemp.attack), ",", string(htTemp.decay), ",", string(htTemp.sustain), ",", string(htTemp.release), ",");
        for harmonicAmplitude in htTemp.harmonicAmplitudes
            write(io, string(harmonicAmplitude), ",");
        end
        write(io,'\n');
    end
    close(io);
    return htDict;
end



function getAmplitude(ht::harmonicTemplate, harmonicNumber::Int)::Float64
    return ht.harmonicAmplitudes[harmonicNumber];
end


#synthesize function, used to perform synthesize on a particular harmonic template

#TODO: need to implement envelope into this. 
#attack is how long it goes from silence to original sound
#N is length not including the release(the release is like extra after the note ended)
function synthesize(f::Number, S::Number, N::Number, ht::harmonicTemplate)
    attackSamples = ht.attack*S;
    decaySamples = ht.decay*S;
    sustain = ht.sustain;
    releaseSamples = ht.release*S;
    harmonicFreqs::Vector{Number} = collect(f* (1:16));
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
    attackSamples = ht.attack*S;
    decaySamples = ht.decay*S;
    sustain = ht.sustain;
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
    releaseSamples = ht.release*S;
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
    p1 = plot(releaseQueue);
    p2 = plot(totalWaveform);
    p3 = plot(p1,p2)
    append!(totalWaveform,releaseQueue);
    totalWaveform = convert(Vector{Float64},totalWaveform);
    totalWaveform = totalWaveform ./ maximum(totalWaveform);
    return totalWaveform, p3;
end