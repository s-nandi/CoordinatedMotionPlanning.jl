using CoordinatedMotionPlanning

function multistop_planning(n_1, n_2, target_states)
    opt, configurations = multistop_solve(n_1, n_2, target_states)
    println("Can complete in ~ $opt time steps")
    plts = []
    for (t, c) in enumerate(configurations)
        push!(plts, show_configuration(c, n_1 * n_2))
        for (i, robot) in enumerate(c.robots)
            println("Robot $i positioned at cell ($(robot.x), $(robot.y)) at step $t")
        end
    end
    animate_frames(plts, "multistop_planning.gif")
end

multistop_planning(3, 3, [
    [(1, 1), (3, 3), (2, 3)],
    [(1, 2), (1, 3), (3, 1)],
    [(2, 1), (1, 1), (1, 2)]
])

# multistop_planning(3, 3, [
#     [(1, 1), (3, 3), (2, 3)],
#     [(1, 2), (1, 3), (3, 1)],
#     [(2, 1), (1, 1), (1, 2)],
#     [(1, 3), (2, 2)],
#     [(2, 2)],
#     [(1, 1)]
# ])