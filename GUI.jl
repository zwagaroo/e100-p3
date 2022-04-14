using Gtk
using PortAudio
include("transcriber.jl")
include("synthesizer_core.jl")
include("synthchordUtil.jl")
global imported = false
global curr_sampling_rate = 44100
global song = Vector{Float64}([])
global import_song = Vector{Any}([])
htDict = readHarmonicTemplates("harmonicTemplates.txt");
global octave = 3
global note_duration = Float64(500.0)
out_stream = PortAudioStream(0, 2)
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
#pause_key = b["pause"]
save_amplitude = b["save_amplitude"]
clear_amplitude = b["clear_amplitude"]
delete_amplitude = b["delete_amplitude"]
save_button = b["save_button"]
load_button = b["load_button"]
octave_spin = b["octave_spin"]
ht_combo = b["instrument_chooser"]
length_slider = b["length_slider"]

amp1 = b["1"]
amp2 = b["2"]
amp3 = b["3"]
amp4 = b["4"]
amp5 = b["5"]
amp6 = b["6"]
amp7 = b["7"]
amp8 = b["8"]
amp9 = b["9"]
amp10 = b["10"]
amp11 = b["11"]
amp12 = b["12"]
amp13 = b["13"]
amp14 = b["14"]
amp15 = b["15"]
amp16 = b["16"]

a_slider = b["a_slider"]
d_slider = b["d_slider"]
s_slider = b["s_slider"]
r_slider = b["r_slider"]

amp_dlg = b["amp_dlg"]
amp_dlg_ok = b["ht_amp_dlg_ok"]
amp_entry_button = b["enter_amps_button"]

ht_dlg = b["filename_dlg_ht"]
ht_cancel_dlg = b["cancel_button_ht"]
ht_confirm_dlg = b["confirm_button_ht"]
ht_dlg_entry = b["filename_entry_ht_dlg"]

save_dlg = b["filename_save_dlg"]
save_cancel_dlg = b["cancel_button_save_dlg"]
save_confirm_dlg = b["confirm_button_save_dlg"]
save_dlg_entry = b["filename_entry_save_dlg"]

load_dlg = b["filename_load_dlg"]
load_cancel_dlg = b["cancel_button_load_dlg"]
load_confirm_dlg = b["confirm_button_load_dlg"]
load_dlg_entry = b["filename_entry_load_dlg"]

reset_button = b["reset_button"]
rest_button = b["rest_button"]

Keys = keys(htDict)
for key in Keys
    push!(ht_combo, key)
end

set_gtk_property!(ht_combo, :active, 0)
global curr_ht = htDict[Gtk.bytestring(GAccessor.active_text(ht_combo))]



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
#push!(GAccessor.style_context(pause_key), GtkStyleProvider(key), 600)
#set_gtk_property!(pause_key, :name, "kb")
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

function synth_gui(note::String)
    import_check = imported
    if import_check == true
        global song = Vector{Any}([])
        global imported = false
    end
    htDict = readHarmonicTemplates("harmonicTemplates.txt");
    ht = curr_ht
    current_length = 0;
    releaseVolume = 0; 
    freq = frequency(note, octave)
    
    S = 44100
    stream = PortAudioStream(0, 2; samplerate=Float64(S)) 
    releaseSamples = round(Int, (ht.release)*S);
    
    while current_length < S * Float64(note_duration/1000.0)
        global releaseVolume;
        global release;
        periodWaveform, releaseVolume = synthesize_period(freq,S, current_length, ht);
        global song = [song; periodWaveform]
        current_length = current_length + round(Int, (1/freq)*S) 
        write(stream, periodWaveform)

    end
    
    release_current_length = 0;
    while release_current_length < releaseSamples
        global releaseVolume;
        release = synthesize_release_period(releaseVolume, release_current_length, ht, freq, S, current_length);
        global song = [song; release]
        current_length = current_length + round(Int, (1/freq) *S);
        release_current_length += round(Int, (1/freq) *S);
        write(stream, release);
    end
end

#################################
#Callbacks below
#################################


id_combo = signal_connect(ht_combo, "changed") do widget
    ht_key = Gtk.bytestring(GAccessor.active_text(ht_combo))
    global curr_ht = htDict[ht_key]
end

id_fin = signal_connect(fin_key, "clicked") do widget
    print("FIN")
    exit()
end

id_c = signal_connect(key1, "clicked") do widget
    print("C")
    
    synth_gui("C")
end

id_d = signal_connect(key2, "clicked") do widget
    print("D")

    synth_gui("D")
end

id_e = signal_connect(key3, "clicked") do widget
    print("E")

    synth_gui("E")
end

id_f = signal_connect(key4, "clicked") do widget
    print("F")

    synth_gui("F")
end

id_g = signal_connect(key5, "clicked") do widget
    print("G")

    synth_gui("G")
end

id_a = signal_connect(key6, "clicked") do widget
    print("A")

    synth_gui("A")
end

id_b = signal_connect(key7, "clicked") do widget
    print("B")

    synth_gui("B")
end

id_c_sharp = signal_connect(sharp1, "clicked") do widget
    print("C♯")

    synth_gui("C#")
end

id_d_sharp = signal_connect(sharp2, "clicked") do widget
    print("D♯")

    synth_gui("D#")
end

id_f_sharp = signal_connect(sharp3, "clicked") do widget
    print("F♯")

    synth_gui("F#")
end

id_g_sharp = signal_connect(sharp4, "clicked") do widget
    print("G♯")
    
    synth_gui("G#")
end

id_a_sharp = signal_connect(sharp5, "clicked") do widget
    print("A♯")

    synth_gui("A#")
end

id_rest = signal_connect(rest_button, "clicked") do widget
    print("*snore*")

    secs = Float64(Float64(note_duration)/1000.0)
    samples = Float64(secs * 44100)
    rest = zeros(Int(round(samples)))
    global song = [song; rest]
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
    if imported == true
    z = synthesize(import_song, curr_sampling_rate, curr_ht)
    else
    z = song
    end
    write(out_stream, z)
end

#=
id_pause = signal_connect(pause_key, "clicked") do widget
    print("pause")
    close(out_stream)
end
=#

id_spin_octave = signal_connect(octave_spin, "value-changed") do widget
    octave_num = GAccessor.value(octave_spin)
    global octave = octave_num
end

id_length_slider = signal_connect(length_slider, "value-changed") do widget
    slider_value = GAccessor.value(length_slider)
    global note_duration = slider_value
end

id_ht_save_dlg = signal_connect(save_amplitude, "clicked") do widget
    showall(ht_dlg)
end

id_ht_dlg_close = signal_connect(ht_cancel_dlg, "clicked") do widget
    destroy(ht_dlg)
end

id_ht_dlg_confirm = signal_connect(ht_confirm_dlg, "clicked") do widget
    print(get_gtk_property(ht_dlg_entry,:text,String), " saved to harmonic templates!")
    htname = get_gtk_property(ht_dlg_entry,:text,String)
    set_gtk_property!(ht_dlg_entry,:text,"")
    a = GAccessor.value(a_slider)
    d = GAccessor.value(d_slider)
    s = GAccessor.value(s_slider)
    r = GAccessor.value(r_slider)
    a1 = GAccessor.value(amp1)
    a2 = GAccessor.value(amp1)
    a3 = GAccessor.value(amp1)
    a4 = GAccessor.value(amp1)
    a5 = GAccessor.value(amp1)
    a6 = GAccessor.value(amp1)
    a7 = GAccessor.value(amp1)
    a8 = GAccessor.value(amp1)
    a9 = GAccessor.value(amp1)
    a10 = GAccessor.value(amp1)
    a11 = GAccessor.value(amp1)
    a12 = GAccessor.value(amp1)
    a13 = GAccessor.value(amp1)
    a14 = GAccessor.value(amp1)
    a15 = GAccessor.value(amp1)
    a16 = GAccessor.value(amp1)
    amp_vec = Vector{Float64}([a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16])
    new_ht = harmonicTemplate(a,d,s,r,amp_vec)
    merge!(htDict,Dict(htname => new_ht))
    push!(ht_combo, htname)
    destroy(ht_dlg)
end

id_save_dlg = signal_connect(save_button, "clicked") do widget
    showall(save_dlg)
end

id_save_dlg_close = signal_connect(save_cancel_dlg, "clicked") do widget
    destroy(save_dlg)
end

id_file_save = signal_connect(save_confirm_dlg, "clicked") do widget
    print("filename: ",get_gtk_property(save_dlg_entry,:text,String), ".wav saved!")
    filename = get_gtk_property(save_dlg_entry,:text,String)
    filename = filename * ".wav"
    if imported == true
        global song = synthesize(import_song, curr_sampling_rate, curr_ht)
    end

    wavwrite(song, filename, Fs=curr_sampling_rate)
    set_gtk_property!(save_dlg_entry,:text,"")
    destroy(save_dlg)
end

id_load_dlg = signal_connect(load_button, "clicked") do widget
    showall(load_dlg)
end

id_load_dlg_close = signal_connect(load_cancel_dlg, "clicked") do widget
    destroy(load_dlg)
end

id_load_dlg_confirm = signal_connect(load_confirm_dlg, "clicked") do widget
    print("filename: ",get_gtk_property(load_dlg_entry,:text,String), " loaded!")
    filename = get_gtk_property(load_dlg_entry,:text,String)
    set_gtk_property!(load_dlg_entry,:text,"")
    waveform, sampling_rate = wavread(filename)
    waveform .= waveform ./maximum(waveform) 
    global curr_sampling_rate = sampling_rate
    global import_song = transcribe(waveform, curr_sampling_rate)
    global imported = true
    destroy(load_dlg)
end

id_amp_dlg_open = signal_connect(amp_entry_button, "clicked") do widget
    showall(amp_dlg)
end

id_amp_dlg_close = signal_connect(amp_dlg_ok, "clicked") do widget
    destroy(amp_dlg)
end

id_song_reset = signal_connect(reset_button, "clicked") do widget
    global song = Vector{Any}([])
end




