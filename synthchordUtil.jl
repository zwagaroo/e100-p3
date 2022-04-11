global midi_to_frequency = Dict()
for i in 1:127
    midi_to_frequency[i] = 440*2^((i-69)/12)
end

note_name_to_midi = Dict()
note_name_to_midi["C"] = 12;
note_name_to_midi["C#"] = 13;
note_name_to_midi["D"] = 14;
note_name_to_midi["D#"] = 15;
note_name_to_midi["E"] = 16;
note_name_to_midi["F"] = 17;
note_name_to_midi["F#"] = 18;
note_name_to_midi["G"] = 19;
note_name_to_midi["G#"] = 20;
note_name_to_midi["A"] = 21;
note_name_to_midi["A#"] = 22;
note_name_to_midi["B"] = 23;

function frequency(noteName, octave)
    return  midi_to_frequency[note_name_to_midi[noteName] + octave*12];
    
end

function frequency(rest)
    if(rest == "rest")
        return 0
    end
end