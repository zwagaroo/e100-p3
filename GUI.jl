using Gtk
using PortAudio
include("synthesizer_core.jl")
include("synthchordUtil.jl")

file = "GUI_FINAL.glade"
b = GtkBuilder(filename=file);
sharp = GtkCssProvider(data="#bb {background:black;}")
window_bg = GtkCssProvider(data="#wb {background-color:LightCyan;}")
key = GtkCssProvider(data="#kb {background-color:white;}")
sharp1 = b["blk_key1"]
sharp2 = b["blk_key2"]
sharp3 = b["blk_key3"]
sharp4 = b["blk_key4"]
sharp5 = b["blk_key5"]
push!(GAccessor.style_context(sharp1), GtkStyleProvider(sharp), 600)
set_gtk_property!(sharp1, :name, "bb")
push!(GAccessor.style_context(sharp2), GtkStyleProvider(sharp), 600)
set_gtk_property!(sharp2, :name, "bb")
push!(GAccessor.style_context(sharp3), GtkStyleProvider(sharp), 600)
set_gtk_property!(sharp3, :name, "bb")
push!(GAccessor.style_context(sharp4), GtkStyleProvider(sharp), 600)
set_gtk_property!(sharp4, :name, "bb")
push!(GAccessor.style_context(sharp5), GtkStyleProvider(sharp), 600)
set_gtk_property!(sharp5, :name, "bb")
win = b["window"];
push!(GAccessor.style_context(win), GtkStyleProvider(window_bg), 600)
set_gtk_property!(win,:name,"wb")
key1 = b["key1"]
key2 = b["key2"]
key3 = b["key3"]
key4 = b["key4"]
key5 = b["key5"]
key6 = b["key6"]
key7 = b["key7"]
fin_key = b["fin_button"]
play_key = b["play"]
pause_key = b["pause"]
save_amplitude = b["save_amplitude"]
clear_amplitude = b["clear_amplitude"]
delete_amplitude = b["delete_amplitude"]
save_button = b["save_button"]
save_entry = b["save_entry"]
amp_entry = b["amplitude_entry"]


push!(GAccessor.style_context(key1), GtkStyleProvider(key), 600)
set_gtk_property!(key1, :name, "kb")
push!(GAccessor.style_context(key2), GtkStyleProvider(key), 600)
set_gtk_property!(key2, :name, "kb")
push!(GAccessor.style_context(key3), GtkStyleProvider(key), 600)
set_gtk_property!(key3, :name, "kb")
push!(GAccessor.style_context(key4), GtkStyleProvider(key), 600)
set_gtk_property!(key4, :name, "kb")
push!(GAccessor.style_context(key5), GtkStyleProvider(key), 600)
set_gtk_property!(key5, :name, "kb")
push!(GAccessor.style_context(key6), GtkStyleProvider(key), 600)
set_gtk_property!(key6, :name, "kb")
push!(GAccessor.style_context(key7), GtkStyleProvider(key), 600)
set_gtk_property!(key7, :name, "kb")
push!(GAccessor.style_context(fin_key), GtkStyleProvider(key), 600)
set_gtk_property!(fin_key, :name, "kb")
push!(GAccessor.style_context(play_key), GtkStyleProvider(key), 600)
set_gtk_property!(play_key, :name, "kb")
push!(GAccessor.style_context(pause_key), GtkStyleProvider(key), 600)
set_gtk_property!(pause_key, :name, "kb")
push!(GAccessor.style_context(save_amplitude), GtkStyleProvider(key), 600)
set_gtk_property!(save_amplitude, :name, "kb")
push!(GAccessor.style_context(clear_amplitude), GtkStyleProvider(key), 600)
set_gtk_property!(clear_amplitude, :name, "kb")
push!(GAccessor.style_context(delete_amplitude), GtkStyleProvider(key), 600)
set_gtk_property!(delete_amplitude, :name, "kb")

showall(win)

#################################
#Functions below
#################################

function synth_gui(freq::Number)
    htDict = readHarmonicTemplates("harmonicTemplates.txt");
    ht = htDict["Saw16"];
    current_length = 0;
    releaseVolume = 0; 
    out_stream = PortAudioStream(0, 2)
    
    
    S = 44100
    stream = PortAudioStream(0, 2; samplerate=Float64(S)) 
    releaseSamples = round(Int, (ht.release)*S);
    
    while current_length < S
        global releaseVolume;
        global release;
        periodWaveform, releaseVolume = synthesize_period(freq,S, current_length, ht);
        current_length = current_length + round(Int, (1/freq)*S) 
        write(stream, periodWaveform)

    end
    
    release_current_length = 0;
    while release_current_length < releaseSamples
        ##global current_length;
        global releaseVolume;
        release = synthesize_release_period(releaseVolume, release_current_length, ht, freq, S, current_length);
        current_length = current_length + round(Int, (1/freq) *S);
        release_current_length += round(Int, (1/freq) *S);
        write(stream, release);
    end
end

#################################
#Callbacks below
#################################

id_fin = signal_connect(fin_key, "clicked") do widget
    print("FIN")
    
end

id_c = signal_connect(key1, "clicked") do widget
    print("C")
    
    synth_gui(262)
end

id_d = signal_connect(key2, "clicked") do widget
    print("D")

    synth_gui(294)
end

id_e = signal_connect(key3, "clicked") do widget
    print("E")

    synth_gui(323)
end

id_f = signal_connect(key4, "clicked") do widget
    print("F")

    synth_gui(349)
end

id_g = signal_connect(key5, "clicked") do widget
    print("G")

    synth_gui(392)
end

id_a = signal_connect(key6, "clicked") do widget
    print("A")

    synth_gui(440)
end

id_b = signal_connect(key7, "clicked") do widget
    print("B")

    synth_gui(494)
end

id_c_sharp = signal_connect(sharp1, "clicked") do widget
    print("C♯")

    synth_gui(277)
end

id_d_sharp = signal_connect(sharp2, "clicked") do widget
    print("D♯")

    synth_gui(311)
end

id_f_sharp = signal_connect(sharp3, "clicked") do widget
    print("F♯")

    synth_gui(370)
end

id_g_sharp = signal_connect(sharp4, "clicked") do widget
    print("G♯")
    
    synth_gui(415)
end

id_a_sharp = signal_connect(sharp5, "clicked") do widget
    print("A♯")

    synth_gui(466)
end

id_amp_save = signal_connect(save_amplitude, "clicked") do widget
    print("amp save")
end

id_amp_clear = signal_connect(clear_amplitude, "clicked") do widget
    print("amp clear")
    set_gtk_property!(amp_entry, :text, "")

end

id_amp_delete = signal_connect(delete_amplitude, "clicked") do widget
    print("amp delete")
    amp_entry_input = get_gtk_property(amp_entry,:text,String)
    amp_entry_input_sz = length(amp_entry_input)
    if amp_entry_input_sz == 1
        set_gtk_property!(amp_entry, :text, "")
    else
        set_gtk_property!(amp_entry, :text, amp_entry_input[1:amp_entry_input_sz-1])
    end
end

id_play = signal_connect(play_key, "clicked") do widget
    print("play")
end

id_pause = signal_connect(pause_key, "clicked") do widget
    print("pause")
end

id_file_save = signal_connect(save_button, "clicked") do widget
    print("filename: ",get_gtk_property(save_entry,:text,String), ".wav saved!")
    set_gtk_property!(save_entry,:text,"")

end


