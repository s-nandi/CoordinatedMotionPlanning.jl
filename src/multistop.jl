model = Model(GLPK.Optimizer)
@variable(model, x[1:3], binary = true)
@objective(model, Max, x[1] + 2x[2] - x[3])
@constraint(model, con, 2 <= sum(x) <= 3)
optimize!(model)
termination_status(model)
primal_status(model)
objective_value(model)
value.(x)


function generate_solver(n_1, n_2, target_states)
    nrobots = length(states)
    s = [length(target_states[i]) for i in range]
    T_max = n_1 * n_2 + 1
end