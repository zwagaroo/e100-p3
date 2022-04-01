using WAV
using FFTW
using LinearAlgebra:dot



#=function filename(a)
    
    file = a
    (x,S,_,_) = wavread(file)

    
end=#
file = "victors_msu.wav"
(x,S,_,_) = wavread(file)


#not a function, but returns total note length 
N1 = 8192 
y=mod(x,N1)
a1 = reshape(y, N1, :) 
b1 = a1[end-99:end,:]     
c1 = sum(abs, b1, dims=1)
e1 = findall(==(0), vec(c1))
f1 = [0; e1[1:end-1]]


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

