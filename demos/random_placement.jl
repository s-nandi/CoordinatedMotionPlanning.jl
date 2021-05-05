using CoordinatedMotionPlanning

function random_placement(n1, n2)
    c = Configuration(n1, n2)
    plts = []
    for i in 1 : n1 * n2
        r = addrandomrobot!(c)
        println("Placed robot at $r.x $r.y")
        plt = show_configuration(c, n1 * n2)
        push!(plts, plt)
    end
    animate_frames(plts, "random_placement.gif")
end

random_placement(3, 2)