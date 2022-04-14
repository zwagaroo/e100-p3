include("transcriber.jl")
include("synthchordUtil.jl")
include("synthesizer_core.jl")
include("GUI.jl")

#read in the 
htDict = readHarmonicTemplates("harmonicTemplates.txt");
ht = htDict["Saw16"];


