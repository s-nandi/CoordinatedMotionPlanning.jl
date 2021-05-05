using CoordinatedMotionPlanning

function demo_initialization(n1, n2)
    c = Configuration(n1, n2)
    plts = []
    for i in 1 : n1 * n2
        addrandomrobot!(c)
        plt = show_configuration(c, n1 * n2)
        push!(plts, plt)
    end
    animate_frames(plts, "demo_init.gif")
end

demo_initialization(5, 4)