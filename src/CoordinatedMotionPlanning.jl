module CoordinatedMotionPlanning

using Plots
using Colors
using DataStructures
using GLPK
using JuMP

include("visualization.jl")
include("simulation.jl")
include("multistop.jl")

export Configuration
export addrandomrobot!, addrobot!, transition!
export show_configuration, save_configuration, animate_frames

end
