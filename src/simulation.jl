const CoordType = Int
const directions = ["W", "N", "E", "S"]
const dx = [0, -1, 0, 1]
const dy = [-1, 0, 1, 0]

robot_id = 0
struct Robot
    x :: CoordType
    y :: CoordType
    speed :: Float32
    id :: Int32

    function Robot(x, y, speed)
        curr_id = robot_id
        robot_id += 1
        new(x, y, speed, curr_id)
    end
end

grid_too_small_message = "Grid too small; need 2x3 / 3x2 grid or bigger"
struct Grid
    n_1 :: CoordType
    n_2 :: CoordType
    function Grid(n_1, n_2)
        if n_1 < 2 || n_2 < 2 || (n_1 == 2 && n_2 == 2)
            error(grid_too_small_message)
        else 
            new(n_1, n_2)
        end
    end
end

struct Configuration
    robots ::  Vector{Robot}
    grid :: Grid
end

function traveltime(robot, distance)
    return CoordType(ceil(distance / robot.speed))
end

function inbounds(robot, grid)
    return robot.x >= 1 && robot.y >= 1 && robot.x <= grid.n_1 && robot.y <= grid.n_2
end
