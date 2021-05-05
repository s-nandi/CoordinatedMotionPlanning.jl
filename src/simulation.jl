const CoordType = Int
const directions = ["W", "N", "E", "S", "O"]
const dx = [0, -1, 0, 1, 0]
const dy = [-1, 0, 1, 0, 0]
const noop = 5

struct Robot
    x::CoordType
    y::CoordType
    speed::Float32
    id::Int32
end

const grid_too_small_message = "Grid too small; need 2x3 / 3x2 grid or bigger"
struct Grid
    n_1::CoordType
    n_2::CoordType
    function Grid(n_1, n_2)
        if n_1 < 2 || n_2 < 2 || (n_1 == 2 && n_2 == 2)
            error(grid_too_small_message)
        else 
            new(n_1, n_2)
        end
    end
end

mutable struct Configuration
    robots::Vector{Robot}
    grid::Grid
    robot_id::Int32
    Configuration(n_1, n_2) = new([], Grid(n_1, n_2), 0)
end

function addrobot!(configuration, x, y, speed=1.)
    id = configuration.robot_id
    configuration.robot_id += 1
    robot = Robot(x, y, speed, id)
    push!(configuration.robots, robot)
    robot
end

const no_free_cell_message = "Cannot place robot on saturated grid"
function addrandomrobot!(configuration, speed)
    allcells = Set((x, y) for x in 1:configuration.grid.n_1, y in 1:configuration.grid.n_2)
    occupied = Set((robot.x, robot.y) for robot in configuration.robots)
    freecells = setdiff(allcells, occupied)
    if isempty(freecells)
        error(no_free_cell_message)
    end
    randomcell = rand(freecells)
    addrobot!(configuration, randomcell..., speed)
end

function addrandomrobot!(configuration)
    speed = rand(0.1:0.1:1.0)
    addrandomrobot!(configuration, speed)
end

function traveltime(speed, distance)
    return CoordType(ceil(distance / speed))
end

function inbounds(robot, grid)
    return robot.x >= 1 && robot.y >= 1 && robot.x <= grid.n_1 && robot.y <= grid.n_2
end

function moverobot(robot, direction)
    new_x = robot.x + dx[direction]
    new_y = robot.y + dy[direction]
    Robot(new_x, new_y, robot.speed, robot.id)
end

function transition!(configuration, directions)
    nrobots = length(configuration.robots)
    @assert length(directions) == nrobots "The number of given directions must match the number of robots"
    n_1, n_2 = configuration.grid.n_1, configuration.grid.n_2

    edges = []
    new_positions = []
    dsu = IntDisjointSets(nrobots)
    at_position = Dict((robot.x, robot.y) => i for (i, robot) in enumerate(configuration.robots))
    for i in 1:nrobots
        x_prev, y_prev = configuration.robots[i].x, configuration.robots[i].y
        configuration.robots[i] = moverobot(configuration.robots[i], directions[i])
        x, y = configuration.robots[i].x, configuration.robots[i].y
        @assert inbounds(configuration.robots[i], configuration.grid) "Robot $i moved to ($x, $y) which is out of bounds; grid size $n_1 x $n_2"
        @assert (x, y) ∉ new_positions "Cannot move multiple robots to the same cell ($x, $y)"
        push!(new_positions, (x, y))
        if (x_prev, y_prev) != (x, y)
            push!(edges, ((x_prev, y_prev), (x, y)))
        end
        if (x, y) ∈ keys(at_position)
            blocking_robot = at_position[(x, y)]
            union!(dsu, i, blocking_robot)
        end
    end
    for (prev, curr) in edges
        @assert (curr, prev) ∉ edges "Swap operations are not allowed: $curr to $prev and $prev to $curr attempted simultaneously"
    end

    # calculate bottlenecked speed 
    speeds = [dir == noop ? Inf : robot.speed for (dir, robot) in zip(directions, configuration.robots)]
    traveltime(minimum(speeds), 1)
end

function toscene(configuration, max_robots)
    nrobots = length(configuration.robots)
    @assert nrobots <= max_robots "Cannot have more than $max_robots when visualizing"
    colors = distinguishable_colors(max_robots)

    scene = []
    properties = []

    n_1, n_2 = configuration.grid.n_1, configuration.grid.n_2
    push!(scene, [Point2(0, 0), Point2(n_1, 0), Point2(n_1, n_2), Point2(0, n_2)])
    push!(properties, box_properties)

    for i in 1:(n_1 - 1)
        push!(scene, Line(Point2(i, 0), Point2(i, n_2)))
        push!(properties, box_gridline_properties)
    end
    for i in 1:(n_2 - 1)
        push!(scene, Line(Point2(0, i), Point2(n_1, i)))
        push!(properties, box_gridline_properties)
    end

    for (i, robot) in enumerate(configuration.robots)
        x, y = robot.x, robot.y
        x -= 0.5
        y -= 0.5
        color = colors[i]
        push!(scene, Point2(x, y))
        actual_properties = Any[]
        append!(actual_properties, disk_properties)
        push!(actual_properties, (:color, color))
        push!(properties, actual_properties)
    end
    scene, properties
end

function show_configuration(configuration, max_robots = 10)
    save_frame(toscene(configuration, max_robots)...)
end

function save_configuration(configuration, ofile, max_robots = 10)
    visualize_frame(toscene(configuration, max_robots)..., ofile)
end