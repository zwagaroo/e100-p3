using Gtk

file = "GUIFinal.glade"

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