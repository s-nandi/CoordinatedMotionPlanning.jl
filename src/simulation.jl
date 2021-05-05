const CoordType = Int
const directions = ["W", "N", "E", "S", "O"]
const dx = [0, -1, 0, 1, 0]
const dy = [-1, 0, 1, 0, 0]

robot_id = 0
struct Robot
    x::CoordType
    y::CoordType
    speed::Float32
    id::Int32
end

function Robot(x, y, speed)
    global robot_id
    curr_id = robot_id
    robot_id += 1
    Robot(x, y, speed, curr_id)
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

struct Configuration
    robots::Vector{Robot}
    grid::Grid
    Configuration(n_1, n_2) = new([], Grid(n_1, n_2))
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
    robot = Robot(randomcell..., speed)
    push!(configuration.robots, robot)
    robot
end

function addrandomrobot!(configuration)
    speed = rand(0.1:0.1:1.0)
    addrandomrobot!(configuration, speed)
end

function addrobot!(configuration, x, y, speed=1.)
    push!(configuration.robots, Robot(x, y, speed))
end

function traveltime(robot, distance)
    return CoordType(ceil(distance / robot.speed))
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

    max_time_taken = 0
    edges = []
    new_positions = []
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
    end
    for (prev, curr) in edges
        @assert (curr, prev) ∉ edges "Swap operations are not allowed: $curr to $prev and $prev to $curr attempted simultaneously"
    end
end