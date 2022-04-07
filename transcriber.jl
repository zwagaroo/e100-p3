using WAV
using FFTW
using LinearAlgebra:dot

#= #not a function, but returns total note length 
N1 = 8192 
y=mod(x,N1)
a1 = reshape(y, N1, :) 
b1 = a1[end-99:end,:]     
c1 = sum(abs, b1, dims=1)
e1 = findall(==(0), vec(c1))
f1 = [0; e1[1:end-1]]
 =#



#this function finds the fundamental frequency of a small quasi periodic waveform
function autocorrelate(waveform, S::Number)
    autocorr = real(ifft(abs2.(fft([waveform; zeros(length(waveform))])))) / sum(abs2, waveform);
    #autocorr mirrors
    autocorr[(length(autocorr)÷2+2):end] .= 0; 
    peak2start = nothing;
    checker = .96;
    peaks = [];
    while(peak2start === nothing)
        checker = checker - .01;
        #Is 
        if(checker <= .9)
            return 0;
        end
        peaks = autocorr .> checker;
        peaks[1:findfirst(==(false), peaks)] .= false;
        #check if there is any true
        peak2start = findfirst(==(true), peaks);
    end
    peak2end = findnext(==(false), peaks, peak2start);
    if(peak2end === nothing)
        return 0;
    end
    peaks[peak2end:end] .= false;
    #= m = argmax(peaks .* autocorr)-1; =# 
#=     peaks = peaks.*autocorr; =#
#=     #evaluate average value of m
    discreteIntegral = 0;
    m = 0;
    for i in range(peak2start,peak2end-1)
        discreteIntegral += peaks[i];
        m += peaks[i] * i;
    end
    m /= discreteIntegral;
    m -= 1; =#
    #= m = ((peak2start + peak2end -1) /2) -1; =#
    m = argmax(peaks .* autocorr) -1;
    return S/m;
end

#if it's less than segment length we can call bs,
#because we expect notes to be longer than segmentLength
#this does stop us from resoluting any note below 3000 samples
function smoother(frequencies, resolution, segmentLength)
    current_note_length = 0;
    previous_frequency = frequencies[1];
    current_frequency = frequencies[1];
    for i in range(1, size(frequencies,1))
        #50 cents
        if(frequencies[i] <= current_frequency*(2^(1/24)) && frequencies[i] >= current_frequency*(2^(-1/24)))
            current_note_length+=1;
        else
            #this is a new note
            if(current_note_length*resolution > segmentLength)
                previous_frequency = current_frequency;
            else #this note is bs
                # all the things we looked at must just be the previous frequency actually,
                #can later implement half goes to the previous_frequency and half goes to new frequency at
                #frequencies[i]
                frequencies[(i-current_note_length):(i-1)] .= previous_frequency;
                println("current length: ", current_note_length);
                println("bounds: ", (i-current_note_length), ":",(i-1));
            end
            current_frequency = frequencies[i];
            current_note_length = 1;
        end
    end
    return frequencies;
end

function splitter()
end

function envelopeFollow(waveform)
    avgAmplitude = sum(abs.(waveform)) / length(waveform);
    return avgAmplitude;
end

function envelopeNoteDet(envelope)

end



#outputs a list of tuples [(freq, length) .... ]
#assume for now that length is constantly 44100 samples, eventually we will split into even smaller segments

#this function groups anything within 50 cents to one frequency 
#at the average of of all frequencies that are within 50 cents.
#don't know if I assigned the correct number of samples for the grouper to each
function frequency_grouper(frequencies, resolution, segmentLength) 
    println(frequencies);
    println(size(frequencies,1));
    noteList = []; 
    current_frequency = frequencies[1];
    current_counter = 0;
    first = true;
    for i in range(1, size(frequencies,1))
        if ((frequencies[i] < current_frequency*2^(1/24)) && (frequencies[i] > current_frequency*2^(-1/24))|| (current_frequency == 0 && frequencies[i] == 0))
            current_counter += 1;
        else
            first = false;
            if first
                note = (current_frequency, segmentLength + (current_counter-1) *resolution);
            else
                note = (current_frequency, (current_counter) *resolution);
            end
            push!(noteList, note);
            current_counter = 1;
            current_frequency = frequencies[i];
        end

    end
    #push final note out
    note =  note = (current_frequency,segmentLength + (current_counter-1) *resolution);
    push!(noteList, note);
    return noteList;
end

function envelopeCrossThreshold(envelopeNormalized, threshold)
    envelopeAboveThreshold = envelopeNormalized .> threshold;
    for i in range(1, size(envelopeAboveThreshold,1))
        if(envelopeAboveThreshold[i] == true)
            nextFalse = findnext(==(false), envelopeAboveThreshold, i)
            if(nextFalse !== nothing)
                envelopeAboveThreshold[(i+1):nextFalse] .=0;
            else
                envelopeAboveThreshold[(i+1):end] .=0;
            end
        end
    end
    return envelopeAboveThreshold;
end

#correction to the smoother results based on envelope crossing envelopeAboveThreshold
#threshold as new notes.
function smootherCorrector(frequencies, envelopeCrossAboveThreshold, resolution, segmentLength)
    #looping through all the small segments of increment
    for i in range(1, size(frequencies,1))
        #note begins here
        if(envelopeCrossAboveThreshold[i] == true)
            #we check the next segmentlength if it's all the same note
            #then do nothing because it means this note is the same frequency
            #else this envelope cross signifies a change into the next frequency
            current_frequency = frequencies[i];
            #assume do nothing
            #check in the next segmentLength (which is segmentLength÷resolution ticks
            #in frequencies)
            freq =  frequencies[(i+(segmentLength÷resolution))];
            #if freq is 50 cents away from current freq or that the current freq is 0 (rest)
            #and freq is not current freq any more then clearly we have changed frequency
            #the next_frequency is the frequency that should be changed to and that 
            #the note beginning should represent. As smoother actually gives transitions
            #wholly to the previous frequency
            #thus we know if a note begins, if it's within a window where both frequencies coexist
            #then a window from where note begins must hit the
            if ((freq <= current_frequency*2^(-1/24) && freq >= current_frequency*2^(1/24)) || (current_frequency == 0 && freq != 0))
                frequencies[i:(i+(segmentLength÷resolution))] .= freq;
            end
        end
    end
    return frequencies;
end


#we will say everything is the same note if it's within 50 cents
function transcribe(audioFile, S::Number)
    #for now look at segments of 1 second
    #need to solve the problem of the sample space smaller than the sample sample_rate,
    #can I guess add a series of zeros for reshape to keep all of the segments the same length

    #use sliding window
    segmentLength = round(Int, 3000);
    threshold = .5;
    frequencies = [];
    envelope = [];
    #loop over sequence of intervals, each interval is center at i,
    #making i the supposid average
    resolution = 100;
    for i in (1+(segmentLength÷2)):resolution:(size(audioFile, 1)-(segmentLength÷2))
        frequencies = [frequencies; autocorrelate(audioFile[(i-segmentLength÷2):(i+segmentLength÷2)], S)];
        envelope = [envelope; envelopeFollow(audioFile[(i-segmentLength÷2):(i+segmentLength÷2)])];

    end
    envelopeNormalized = envelope/maximum(envelope);
    envelopeCrossAboveThreshold = envelopeCrossThreshold(envelopeNormalized, threshold);
    frequencies = smoother(frequencies, resolution, segmentLength);
    frequencies = smootherCorrector(frequencies, envelopeCrossAboveThreshold, resolution, segmentLength);
    return frequency_grouper(frequencies, resolution,segmentLength);
end


