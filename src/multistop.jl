# model = Model(GLPK.Optimizer)
# @variable(model, x[1:3], binary = true)
# @objective(model, Max, x[1] + 2x[2] - x[3])
# @constraint(model, con, 2 <= sum(x) <= 3)
# optimize!(model)
# termination_status(model)
# primal_status(model)
# objective_value(model)
# value.(x)


function multistop_solve(n_1, n_2, target_states)
    nrobots = length(target_states)
    ncells = n_1 * n_2
    cellindex(x, y) = Int((x - 1) * n_1 + y)
    indextocell(ind) = (div(ind - 1, n_1) + 1, mod(ind - 1, n_1) + 1)
    s = [length(state) for state in target_states]
    s_max = maximum(s)
    T_max = min(sum(s), 2 * s_max) 


    # Define constants
    D = zeros(ncells, ncells)
    P = zeros(Int, nrobots, s_max)
    INIT = zeros(Int, nrobots)
    for i in 1:nrobots
        INIT[i] = cellindex(target_states[i][1]...)
        for j in 1:s_max
            P[i, j] = cellindex(target_states[i][min(j, s[i])]...)
        end
    end
    for x_1 in 1:n_2, y_1 in 1:n_1, x_2 in 1:n_2, y_2 in 1:n_1
        index_1 = cellindex(x_1, y_1)
        index_2 = cellindex(x_2, y_2)
        D[index_1, index_2] = manhattandistance((x_1, y_1), (x_2, y_2))
    end

    model = Model(GLPK.Optimizer)

    # Define variables
    @variables(model, begin
        at[1:nrobots, 1:ncells, 1:T_max], Bin
        trav[1:nrobots, 1:ncells, 1:ncells, 1:T_max - 1], Bin
        vis[i=1:nrobots, 1:s[i], 1:T_max], Bin
        m[1:T_max - 1] >= 0
    end)

    # Define objective
    @objective(model, Min, sum(m))

    # Define constraints
    @constraints(model, begin
        # Initial condition
        init_position[i=1:nrobots], at[i, INIT[i], 1] == 1
        # Overlap constraints
        robot_at_one_place[i=1:nrobots, t=1:T_max], sum(at[i, j, t] for j in 1:ncells) == 1
        no_overlap_cell[j=1:ncells, t=1:T_max], sum(at[i, j, t] for i = 1:nrobots) <= 1
        # # Consistency constraints
        vis_implies_at[i=1:nrobots, k=1:s[i], t=1:T_max], at[i, P[i, k], t] >= vis[i, k, t]
        set_max_dist[i=1:nrobots, t=1:T_max - 1, j_1=1:ncells, j_2=1:ncells], m[t] >= D[j_1, j_2] * trav[i, j_1, j_2, t]
        trav_implies_at_1[i=1:nrobots, j_1=1:ncells, j_2=1:ncells, t=1:T_max - 1], at[i, j_1, t] >= trav[i, j_1, j_2, t]
        trav_implies_at_2[i=1:nrobots, j_1=1:ncells, j_2=1:ncells, t=1:T_max - 1], at[i, j_2, t + 1] >= trav[i, j_1, j_2, t]
        at_implies_trav_[i=1:nrobots, j_1=1:ncells, j_2=1:ncells, t=1:T_max - 1],  at[i, j_1, t] + at[i, j_2, t + 1] <= 1 + trav[i, j_1, j_2, t]
        # # Goal constraints
        ordering_requirement[i=1:nrobots, k=2:s[i], t_1=1:T_max, t_2=t_1 + 1:T_max], vis[i, k, t_1] + vis[i, k - 1, t_2] <= 1
        achieve_all_goals[i=1:nrobots, k in 1:s[i]], sum(vis[i, k, t] for t in 1:T_max) == 1
    end)
    optimize!(model)

    termination_status(model)
    primal_status(model)
    opt = objective_value(model)

    configurations = []
    for t in 1:T_max
        c = Configuration(n_1, n_2)
        for i in 1:nrobots
            j = filter(j -> isapprox(value(at[i, j, t]), 1), 1:ncells)[1]
            addrobot!(c, indextocell(j)...)
            println("Robot $i positioned at cell $j at step $t")
        end
        push!(configurations, c)
    end

    opt, configurations
end