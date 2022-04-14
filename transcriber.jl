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
    #calculates the autocorrelate
    autocorr = real(ifft(abs2.(fft([waveform; zeros(length(waveform))])))) / sum(abs2, waveform);
    #autocorr mirrors so we remove the other half
    autocorr[(length(autocorr)÷2+2):end] .= 0; 
   #=  return plot(autocorr, label = "", legend=:bottomleft) =#
    #first we try to find peak2
    peak2start = nothing;
    #checking threshold starts at .95 but we subtract one in the beginning so it starts at .96
    checker = .96;
    peaks = [];
    #while it hasn't found a possible peak2
    while(peak2start === nothing)
        #move checker down a percentage point
        checker = checker - .01;
        #if the checker is below .85 then there isn't really
        #a good frequency because the second peak should really have
        #a fairly high value
        if(checker <= .85)
            #if we cannot determine the frequency we say it's zero
            return 0;
        end
        #find locations where autocorr is bigger than checker.
        peaks = autocorr .> checker;
        #it will set everything to 0 until the first peak ends
        #effectively removing the values from first peak
        peaks[1:findfirst(==(false), peaks)] .= false;
        #check if there is any true at this point
        peak2start = findfirst(==(true), peaks);
    end
    peak2end = findnext(==(false), peaks, peak2start);
    #if the second peak never ends, then that's 
    if(peak2end === nothing)
        return 0;
    end
    #else we set everything from second
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

#finds the next valid frequencies inside a list of frequencies with specific resolution and
#segment list, from a specific index in frequencies
#a valid frequency is when it lasts for longer than the segment length or else it could just be a part
#of the transition as a whole window size / resolution number of frequnncies
function findNextFrequency(frequencies,resolution, segmentLength, index)
    current_frequency = frequencies[index];
    initial_frequency = frequencies[index];
    current_count = 0;
    for i in range(index, size(frequencies,1))
        if(frequencies[i] <= current_frequency*(2^(1/24)) && frequencies[i] >= current_frequency*(2^(-1/24)))
            current_count+=1;
        else
            #this is a new note and it's not the initial frequency
            if(current_count*resolution > segmentLength && (current_frequency != initial_frequency))
                return current_frequency;
            end
            current_frequency = frequencies[i];
            current_count = 1;
        end
    end
end


#If any segment of frequency is less than a window / resolution then that frequency is clearly not real
#we will set that segment of frequency to the previous frequency
#due to releases which can increase the window that autocorrelate return either zero or bad values for transitions
#we will actually bump the threshold for this to around 5400 samples because the smallest we want to resolute it 16th notes at
#120 bpm or 2 bps. For 44100 that's 5512 samples. We also want to give it some tolerance room so 5400.
function smoother(frequencies, resolution)
    #keep track of the current_note_lengths
    #so we can make the decision of whether or not to remove
    current_note_length = 0;
    #we have to keep track of the previous frequencies
    previous_frequency = frequencies[1];
    #and the current frequency
    current_frequency = frequencies[1];

    #for all the frequencies
    for i in range(1, size(frequencies,1))
        #within 50 cents we consider it to be the same note, this is to account for possible deviations due to autocorrelating
        #within different windows.
        if(frequencies[i] <= current_frequency*(2^(1/24)) && frequencies[i] >= current_frequency*(2^(-1/24)))
            #we increase note length by one if within 50 cents
            current_note_length+=1;
        else
            #this is possibly a new note we need to check if it's larger than 5400 samples
            if(current_note_length*resolution > 5400)
                previous_frequency = current_frequency;
            else #this is not a new note, this is either transition or something with autocorrelate
                #we need to smooth this out
                #i is the note frequency a whole current note length before it must be set to the previous previous_frequency
                frequencies[(i-current_note_length):(i-1)] .= previous_frequency;
            end
            #no matter what we set the new current frequency
            current_frequency = frequencies[i];
            #because at i is the new frequency current_note_length is 1
            current_note_length = 1;
        end
    end
    #we return the smoothed frequency
    return frequencies;
end


#function to calculate average amplitude at waveform, called in a loop to find average envelope over time
function envelopeFollow(waveform)
    avgAmplitude = sum(abs.(waveform)) / length(waveform);
    return avgAmplitude;
end


#outputs a list of tuples [(freq, length) .... ]
#groups sucessive frequencies together
function frequency_grouper(frequencies, resolution, segmentLength, envelopeCrossAboveThreshold) 
    #start the noteList empty
    noteList = []; 

    #Set the current frequency to consider
    current_frequency = frequencies[1];

    #set a counter for how many ticks of that frequency has been processed
    current_counter = 0;

    #we must process the first note different from the rest
    #since start off from i = segmentLength/2 in transcriber we must group it such that the first segmentLength÷2 is the same
    #as what the first frequency is
    first = true;

    #since we are using the envelope to detect repeated notes, we don't need to use the envelope at the beginning of each new frequency
    #because the frequency change will already generate a new note and envelope should usually come after change
    #only place where this doesn't occur is when release is really long, if this happends then we have a lot of zeros at that point, but
    #the smoother can either put zeros to previous frequency or leave zeros as is because it's a rest. It's possible here that the envelope
    #belonging to the next frequency is actually put at the end of the previous frequency due to the smoother. It's also possible the envelope ends up
    #in a series of zeros but it's acutally supposed to be the start of the next note. We must detect this and correct for this.
    firstNoteInFrequency = true;


    #we must loop through all frequencies
    for i in range(1, size(frequencies,1))
        #it's the same frequency if frequencies at i within 50 cents or that the current frequency is zero and frequencies at i is zero.
        if ((frequencies[i] < current_frequency*2^(1/24)) && (frequencies[i] > current_frequency*2^(-1/24)) || (current_frequency == 0 && frequencies[i] == 0))
            #if then envelope has crossed above the threshold but it's the first note in that frequency

            #if we crossed the envelope and it's the firstNoteInFrequency we don't do anything here because the frequency changes already accounted for this.
            if (envelopeCrossAboveThreshold[i] == true && firstNoteInFrequency == true)
                #After this, it's not the first note in this frequency anymore
                firstNoteInFrequency = false;
                #don't need to detect envelope for possible acutaly start of next note. First of all the smoother should have only kept the ones that are long enough
                #if we try to detect it here it's possible that for a shorter note it will just cause that note to be skipped, which is undesireable,
                #if it doesn't detect a change in frequency then it should be good so there is no reason to check here.
            #else it's not the firstNoteInFrequency
            elseif (envelopeCrossAboveThreshold[i] == true && firstNoteInFrequency == false)
                #if it's not the first note int the frequency then we seriously need to check and correct for our smoother here
                #since smoother will correct for 5400 samples at max. We check if 5400/resolution away from i where envelopeCrossAboveThreshold is true
                #is actually a different frequency, if so then that means that our smoother probably over corrected and we need to set all values from 
                #when envelopeCrossThreshold to 5400 away to be the frequency at 5400 away, frequencies shouldn't change faster than 5400 so there is no
                #problem with skipping frequencies in the middle
                #if frequency at 5400 away is 50 cents above the current frequency or the current frequency is zero and 5400 away it's not zero anymore
                if (((frequencies[i+(5400÷resolution)] > current_frequency*2^(1/24)) || (frequencies[i+(5400÷resolution)] < current_frequency*2^(-1/24))) || (current_frequency == 0 && frequencies[i+(5400÷resolution)] != 0))
                    #frequencies all the way from i to 5400/resolution must be the set the frequency at 5400/resolution
                    frequencies[i:i+(5400÷resolution)] .= frequencies[i+(5400÷resolution)];
                    #need to process the last note and push it into noteList
                    #if this is somehow the first note, we add half a segmentLength
                    if first
                        note = (current_frequency, (segmentLength÷2) + (current_counter-1) *resolution);
                    else
                        note = (current_frequency, (current_counter) *resolution);
                    end
                    first = false;
                    push!(noteList, note);
                    current_frequency = frequencies[i];
                    current_counter = 0; #will add one in the end anyway so start at zero
                    #first note in frequency is still false because we just detected the envelope that signifies the first note in this frequency
                else
                    #this just has to be a new note with the same frequency as before.
                    #push the old note to the noteList
                    if first
                        note = (current_frequency, (segmentLength÷2) + (current_counter-1) *resolution);
                    else
                        note = (current_frequency, (current_counter) *resolution);
                    end
                    first = false;
                    push!(noteList, note);
                    current_counter = 0;
                end
            end
            #counter +=1 no matter what if the frequency is the same as before
            current_counter += 1;
        #If we switched frequency, then it must be a new note, note that since we already changed the frequencies from when we checked if envelopeCrossAboveThreshold 
        #is actually corresponding to the next note, it won't actually detect a frequency change the next i it goes to so we don't have to worry about that.
        else

            if first
                note = (current_frequency, (segmentLength÷2) + (current_counter-1) *resolution);
            else
                note = (current_frequency, (current_counter) *resolution);
            end
            first = false;
            push!(noteList, note);
            current_counter = 1;
            current_frequency = frequencies[i];
            firstNoteInFrequency = true;
            #It's possbile that our envelope has crossed the threshold at the frequency change, which is good!
            if(envelopeCrossAboveThreshold[i]== true && firstNoteInFrequency == true)
                firstNoteInFrequency = false;
            end
        end
    end
    #push final note out
    note = (current_frequency,(segmentLength÷2) + (current_counter-1) *resolution);
    push!(noteList, note);
    return noteList;
end

#function to detect when envelopes cross threshold,
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

#to prevent envelopeNormalized from being very jagged(thus envelopeCrossThreshold may register for tiny random jumps)
#we smooth with sma
function sma(data, amount)
    #keep it as data for the first amount of samples
    sma = data[1:amount];
    for i in range(amount+1, size(data, 1))
        newVal = sum(data[(i-amount):(i-1)])/amount 
        sma = [sma; newVal];
    end
    return sma;
end

#we will correct for smoother just in case before the corrections occur in frequency grouper
function smootherCorrector(frequencies, envelopeCrossAboveThreshold, resolution, segmentLength)
    #looping through all the small segments of increment, envelop and frequencies should be same size.
    for i in range(1, size(frequencies,1))
        #note begins here
        if(envelopeCrossAboveThreshold[i] == true)
            current_frequency = frequencies[i];
            freq =  frequencies[(i+(5400÷resolution))];
            #if freq is 50 cents away from current freq or that the current freq is 0 (rest)
            #and freq is not current freq any more then clearly we have changed frequency
            #the next_frequency is the frequency that should be changed to and that 
            #the note beginning should represent. As smoother actually gives transitions
            #wholly to the previous frequency
            #thus we know if a note begins, if it's within a window where both frequencies coexist
            #then a window from where note begins must hit the
            if ((freq < current_frequency*2^(-1/24) && freq > current_frequency*2^(1/24)) || (current_frequency == 0 && freq != 0))
                frequencies[i:(i+(segmentLength÷resolution))] .= freq;
            end
        end
    end
    return frequencies;
end



#drive for the transcribe function 
function transcribe(audioFile, S::Number)
    #use sliding window
    #we choose a segment of 3500 because lowest note A0 necessarily need 3207 samples to be able to detect in the autocorr
    #we will give a bit more of a window for tolerance
    segmentLength = round(Int, 3500);
    #set threshold for envelopes 
    threshold = .5;
    #initalizes frequencies and envelope as emtpy vectors
    frequencies = [];
    envelope = [];
    #loop over sequence of intervals, each interval is center at i,
    #making i the supposid average
    resolution = 100;
    for i in (1+(segmentLength÷2)):resolution:(size(audioFile, 1)-(segmentLength÷2))
        frequencies = [frequencies; autocorrelate(audioFile[(i-segmentLength÷2):(i+segmentLength÷2)], S)];
        envelope = [envelope; envelopeFollow(audioFile[(i-segmentLength÷2):(i+segmentLength÷2)])];

    end
    #first we normalize the envelope for standarization of analysis
    envelopeNormalized = envelope/maximum(envelope);
    #calculate when envelopeCrossAboveThreshold
    envelopeCrossAboveThreshold = envelopeCrossThreshold(sma(envelopeNormalized,7), threshold);
    #smooth
    frequencies = smoother(frequencies, resolution);
    #correct 
    frequencies = smootherCorrector(frequencies, envelopeCrossAboveThreshold, resolution, segmentLength);
    #smooth again
    frequencies = smoother(frequencies, resolution);
    frequencies = smoother(frequencies, resolution);
    #group
    return frequency_grouper(frequencies, resolution,segmentLength, envelopeCrossAboveThreshold);
end


