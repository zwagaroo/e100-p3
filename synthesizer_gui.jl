using Gtk

window = GtkWindow("Synthesizer", 1600, 1200) # 1600x1200 window for the GUI
keyGrid = GtkGrid()
set_gtk_property!(keyGrid, :row_spacing, 5)
set_gtk_property!(keyGrid, :column_spacing, 5)
set_gtk_property!(keyGrid, :row_homogeneous, false) # stretch with window
set_gtk_property!(keyGrid, :column_homogeneous, false)

white = ["A";"B";"C";"D";"E";"F";"G"]
black = ["A";"C";"D";"F";"G"]

sharp = GtkCssProvider(data="#wb {color:white; background:black;}")

for i in 1:size(white,1)
    key = white[i]
    b = GtkButton(key)
    keyGrid[(1:2) .+ 2*(i-1), 2] = b
end
 #=for i in 1:size(black)
    key = black[i]
    b = GtkButton(key * "♯")
    push!(GAccessor.style_context(b), GtkStyleProvider(sharp),600)
    set_gtk_property!(b, :name, "wb")
    keyGrid[(1:2) .+ 2*(i-1), 1] = b
end=#
push!(window, keyGrid)
showall(window);