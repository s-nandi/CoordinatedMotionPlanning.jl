using CoordinatedMotionPlanning
using Test

const dummy = 0.128980438

@testset "Construction configurations" begin
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(1, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(1, 2)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(2, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(2, 2)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(3, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Configuration(1, 3)
    @test Configuration(2, 3) !== dummy
    @test Configuration(3, 2) !== dummy
end

@testset "Adding random robots" begin
    c_1 = Configuration(3, 3)
    for x in 1:3, y in 1:3
    last_robot = addrandomrobot!(c_1)
    @test CoordinatedMotionPlanning.inbounds(last_robot, c_1.grid)
    @test 0. < last_robot.speed <= 1.
end
    @test_throws ErrorException(CoordinatedMotionPlanning.no_free_cell_message) addrandomrobot!(c_1)
end

@testset "Checking transition errors" begin
    function diagonalconfiguration()
    c = Configuration(5, 5)
    addrobot!(c, 1, 1)
    addrobot!(c, 2, 2)
    addrobot!(c, 5, 5)
    c
end
    function adjacentconfiguration()
    c = Configuration(3, 3)
    addrobot!(c, 1, 1)
    addrobot!(c, 2, 1)
    addrobot!(c, 2, 2)
    addrobot!(c, 1, 2)
    c
end
    testassertion(c, directions) = @test_throws AssertionError transition!(c, directions)
    testnoassertion(c, directions) = @test transition!(c, directions) !== dummy

    @testset "Invalid direction size" begin
        testassertion(diagonalconfiguration(), [5, 5, 5, 5])
        testassertion(diagonalconfiguration(), [5, 5])
        testnoassertion(diagonalconfiguration(), [5, 5, 5])
    end
    @testset "Movement out of bounds" begin
        testassertion(diagonalconfiguration(), [1, 5, 5])
        testassertion(diagonalconfiguration(), [2, 5, 5])
        testnoassertion(diagonalconfiguration(), [3, 5, 5])
        testnoassertion(diagonalconfiguration(), [4, 5, 5]) 
        testassertion(diagonalconfiguration(), [5, 5, 3])
        testassertion(diagonalconfiguration(), [5, 5, 4])
        testnoassertion(diagonalconfiguration(), [5, 5, 1])
        testnoassertion(diagonalconfiguration(), [5, 5, 2]) 
        testnoassertion(diagonalconfiguration(), [5, 1, 5]) 
        testnoassertion(diagonalconfiguration(), [5, 2, 5]) 
        testnoassertion(diagonalconfiguration(), [5, 3, 5]) 
        testnoassertion(diagonalconfiguration(), [5, 4, 5]) 
    end
    @testset "Move to same position" begin
        testassertion(adjacentconfiguration(), [5, 2, 5, 5])
        testassertion(adjacentconfiguration(), [3, 5, 2, 5])
        testnoassertion(adjacentconfiguration(), [3, 2, 1, 4])
    end
    @testset "Swap operation" begin
        testassertion(adjacentconfiguration(), [4, 2, 5, 5])
        testassertion(adjacentconfiguration(), [5, 3, 1, 5])
        testassertion(adjacentconfiguration(), [5, 5, 2, 4])
        testassertion(adjacentconfiguration(), [3, 5, 5, 1])
    end
end

@testset "Calculate transition time" begin
    c = Configuration(3, 3)
    addrobot!(c, 1, 1, 1)
    addrobot!(c, 1, 2, 1)
    addrobot!(c, 2, 2, 1)
    addrobot!(c, 2, 1, 1)
    addrobot!(c, 3, 3, 0.5)
    @test isapprox(transition!(c, [3, 4, 1, 2, 5]), 1.)
    @test isapprox(transition!(c, [4, 1, 2, 3, 2]), 2.)
    @test isapprox(transition!(c, [5, 5, 5, 5, 2]), 2.)
end