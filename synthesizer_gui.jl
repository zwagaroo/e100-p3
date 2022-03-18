using Gtk

window = GtkWindow("Synthesizer", 1600, 1200) # 1600x1200 window for the GUI
keyGrid = GtkGrid()
set_gtk_property!(keyGrid, :row_spacing, 5)
set_gtk_property!(keyGrid, :column_spacing, 5)
set_gtk_property!(keyGrid, :row_homogeneous, false) # stretch with window height
set_gtk_property!(keyGrid, :column_homogeneous, false) # stretch buttons to window width

white = ["A";"B";"C";"D";"E";"F";"G"]
black = ["A" 2;"C" 6;"D" 8;"F" 12;"G" 14]

sharp = GtkCssProvider(data="#wb {color:white; background:black;}")

for i in 1:size(white,1)
    key = white[i]
    b = GtkButton(key)
    keyGrid[(1:2) .+ 2*(i-1), (1:2)] = b
end
for i in 1:size(black,1)
    key, start = black[i,1:2]
    c = GtkButton(key * "♯")
    push!(GAccessor.style_context(c), GtkStyleProvider(sharp),600)
    set_gtk_property!(c, :name, "wb")
    keyGrid[2*(i-1), 1] = c
end
push!(window, keyGrid)
showall(window);