using DelimitedFiles;
#harmonic template struct
#mutable so we can change it, just to hold data

mutable struct harmonicTemplate
    #in seconds
    attack::Float64;
    decay::Float64;
    sustain::Float64; 
    release::Float64;
    #relative amplitudes
    #vector of 16 values harmonicAmplitudes[harmonic] gives the amplitude of harmonic,
    harmonicAmplitudes::Vector{Float64};
    harmonicTemplate(a,d,s,r) = new(a,d,s,r, Vector{Float64}([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
    harmonicTemplate(a,d,s,r,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16) = new(a,d,s,r, [a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16]);
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


function getAmplitude(ht::harmonicTemplate, harmonicNumber::Int)::Float64
    return ht.harmonicAmplitudes[harmonicNumber];
end


#synthesize function, used to perform synthesize on a particular harmonic template
function synthesize(f::Number, S::Number, N::Number, ht::harmonicTemplate)
    harmonicFreqs::Vector{Number} = [f*i for i in range(1,16)];
    synthesizedWaveform = cos.(2π * (1:N) * harmonicFreqs'/S) * ht.harmonicAmplitudes;
    return synthesizedWaveform;
end

