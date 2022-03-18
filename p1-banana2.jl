using Plots; default(markerstrokecolor=:auto, label="")
using MAT: matread
using Statistics: mean

song = matread("proj1.mat")["song"];
y = reshape(song, 2000, :);
notes = size(y,2);
V = [0 .5 .75 1 1.25 1.5 1.75 2 2.5 2.75 3 3.25 3.5 4 4.25 4.5];

n = 500;
F = (S/2pi) * acos.((y[n + 1,:] .+ y[n - 1,:]) ./ 2y[n,:]);

midi = 69 .+ round.(Int, 12 * log2.(F/440));
v = V[midi .- 63];

#v = rand(-0.5:0.5:4.5, 30)=#

plot(v, line=:stem, marker=:circle, markersize = 10, color=:black)
plot!(size = (800,200)) # size of plot
plot!(widen=true) # try not to cut off the markers
plot!(xticks = [], ylims = (-0.7,4.7)) # for staff
yticks!(0:4, ["E", "G", "B", "D", "F"]) # helpful labels for staff lines
#plot!(axis=nothing, border=:none) # ignore this
plot!(yforeground_color_grid = :blue) # blue staff, just for fun
plot!(foreground_color_border = :white) # make border "invisible"
plot!(gridlinewidth = 1.5) # sets the width of the staff ledger
plot!(gridalpha = 0.9) # make grid lines more visible