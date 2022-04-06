using WAV
using FFTW
using LinearAlgebra:dot



#=function filename(a)
    
    file = a
    (x,S,_,_) = wavread(file)

    
end=#

#= file = "victors_msu.wav"
(x,S,_,_) = wavread(file) =#


#= #not a function, but returns total note length 
N1 = 8192 
y=mod(x,N1)
a1 = reshape(y, N1, :) 
b1 = a1[end-99:end,:]     
c1 = sum(abs, b1, dims=1)
e1 = findall(==(0), vec(c1))
f1 = [0; e1[1:end-1]]
 =#



#call user inputted filename (might be better to move into gui)
 

# Check if note frequency is above certain limit 
#(might need a helper function to find that actual limit), 
#if it is above the frequency, mark node, find time() between node (i, i+1)
#return that as note length
# if 50 above or below, we say change in note, 
#this might not work if we have the same note played back to back
# 


#=function transcriber(x, S)
    
    N = length(x)
    buttons_pressed = N ÷ (S÷2)
    n = Int(S/2)
    numbers = 1:buttons_pressed
  
    Tone_arr = [Tone_Generator(i,x, S) for i in numbers]

    

    freqs2 = [a,b,c] 

    local phone = ""
    for i in numbers
        y = Tone_Generator(i,x,Int(S))
        c1 = [dot(cos.(2pi*f1*(0:n-1)/S), y) for f1 in freqs1]
        s1 = [dot(sin.(2pi*f1*(0:n-1)/S), y) for f1 in freqs1]
        corr1 = vec(c1.^2 + s1.^2)
        row = argmax(corr1)
        c2 = [dot(cos.(2pi*f2*(0:n-1)/S), y) for f2 in freqs2]
        s2 = [dot(sin.(2pi*f2*(0:n-1)/S), y) for f2 in freqs2]
        corr2 = vec(c2.^2 + s2.^2)
        column = argmax(corr2)
        phone = phone * string(determine_Number(row, column))
    end

    return phone
    
end

print(phone_tone_transcriber(x, 8192))=#

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
        #if our checker goes below zero than clearly there is nothing here
        if(checker <= .8 )
            return nothing
        end
        peaks = autocorr .> checker;
        peaks[1:findfirst(==(false), peaks)] .= false;
        #check if there is any true
        peak2start = findfirst(==(true), peaks);
    end
    peak2end = findnext(==(false), peaks, peak2start);
    if(peak2end === nothing)
        return nothing;
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

#outputs a list of tuples [(freq, length) .... ]
#assume for now that length is constantly 44100 samples, eventually we will split into even smaller segments

#this function groups anything within 50 cents to one frequency 
#at the average of of all frequencies that are within 50 cents.
function frequency_grouper(frequencies) 
    println(frequencies);
    println(size(frequencies,1));
    noteList = []; 
    current_frequency = frequencies[1];
    current_counter = 0;
    for i in range(1, size(frequencies,1))
        #if frequency is less than or more than 50 cents from the original
        #frequencies of nothing results from changing notes where autocorr fails
        #thus we assume that during the note change, the last note is around still running here
        #this may cause an error of around .07 seconds. Though it's non trivial, but not significant enough
        if( frequencies[i] === nothing)
            current_counter +=1;
            #cannot check anything else for this one so we just continue
            continue;
        end
        if ((frequencies[i] < current_frequency*2^(1/24)) && (frequencies[i] > current_frequency*2^(-1/24)))
            current_counter += 1;
        else
            note = (current_frequency, current_counter *3000);
            push!(noteList, note);
            current_counter = 1;
            current_frequency = frequencies[i];
        end

    end
    #push final note out
    note = (current_frequency, current_counter*3000);
    push!(noteList, note);
    return noteList;
end

#we will say everything is the same note if it's within 50 cents
function transcribe(audioFile, S::Number)
    #for now look at segments of 1 second
    #need to solve the problem of the sample space smaller than the sample sample_rate,
    #can I guess add a series of zeros for reshape to keep all of the segments the same length
    segmentLength = round(Int, 3000);
    requiredAdditionalLength = (segmentLength - (length(audioFile) % segmentLength)) % segmentLength;
    audioFile = [audioFile; zeros(requiredAdditionalLength)];
    #now we can reshape without fail
    audioFile = reshape(audioFile, segmentLength, :)
    frequencies = [];
    for i in range(1,size(audioFile, 2))
        #assumes the last segment of 3000 samples is the same as the one before
        #will work in most cases
        if (i == size(audioFile,2))
            frequencies = [frequencies; frequencies[end]];
        else
            frequencies = [frequencies; autocorrelate(audioFile[:,i],S)];
            println(autocorrelate(audioFile[:,i],S))
        end
    end

    return frequency_grouper(frequencies)
end


