using Gtk
using Sound: sound
using MAT: matwrite

# initialize two global variables used throughout
S = 7999 # sampling rate (samples/second) for this low-fi project
song = Float32[] # initialize "song" as an empty vector

function miditone(midi::Int; nsample::Int = 2000)
    f = 440 * 2^((midi-69)/12) # compute frequency from midi number - FIXED
    x = cos.(2pi*(1:nsample)*f/S) # generate sinusoidal tone
    sound(x, S) # play note so that user can hear it immediately
    global song = [song; x] # append note to the (global) song vector
    return nothing
end

# define the white and black keys and their midi numbers - FIXED!
white = ["G" 67; "A" 69; "B" 71; "C" 72; "D" 74; "E" 76; "F" 77; "G" 79]
black = ["G" 68 2; "A" 70 4; "C" 73 8; "D" 75 10; "F" 78 14]

g = GtkGrid() # initialize a grid to hold buttons
set_gtk_property!(g, :row_spacing, 5) # gaps between buttons
set_gtk_property!(g, :column_spacing, 5)
set_gtk_property!(g, :row_homogeneous, true) # stretch with window resize
set_gtk_property!(g, :column_homogeneous, true)

# define the "style" of the black keys
sharp = GtkCssProvider(data="#wb {color:white; background:black;}")
# FIXME! add a style for the end button
end_button = GtkCssProvider(data="#yb {color:yellow; background:blue;}")

for i in 1:size(white,1) # add the white keys to the grid
    key, midi = white[i,1:2]
    b = GtkButton(key) # make a button for this key
    signal_connect((w) -> miditone(midi), b, "clicked") # callback
    g[(1:2) .+ 2*(i-1), 2] = b # put the button in row 2 of the grid
end
for i in 1:size(black,1) # add the black keys to the grid
    key, midi, start = black[i,1:3]
    b = GtkButton(key * "♯") # to make ♯ symbol, type \sharp then hit <tab>
    push!(GAccessor.style_context(b), GtkStyleProvider(sharp), 600)
    set_gtk_property!(b, :name, "wb") # set "style" of black key
    signal_connect((w) -> miditone(midi), b, "clicked") # callback
    g[start .+ (0:1), 1] = b # put the button in row 1 of the grid
end


function end_button_clicked(w) # callback function for "end" button
    println("The end button")
    sound(song, S) # play the entire song when user clicks "end"
    matwrite("proj1.mat", Dict("song" => song); compress=true) # save song to file
end

ebutton = GtkButton("end") # make an "end" button
g[1:16, 3] = ebutton # fill up entire row 3 of grid - why not?
signal_connect(end_button_clicked, ebutton, "clicked") # callback
# FIXED set style of the "end" button
push!(GAccessor.style_context(ebutton), GtkStyleProvider(end_button), 600)
set_gtk_property!(ebutton, :name, "yb")

win = GtkWindow("gtk3", 400, 300) # 400×300 pixel window for all the buttons
push!(win, g) # put button grid into the window
showall(win); # display the window full of buttons
