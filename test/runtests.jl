using CoordinatedMotionPlanning
using Test

@testset "Simulation Tests" begin
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(1, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(1, 2)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(2, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(2, 2)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(3, 1)
    @test_throws ErrorException(CoordinatedMotionPlanning.grid_too_small_message) Grid(1, 3)
    @test Grid(2, 3) !== nothing
    @test Grid(3, 2) !== nothing
end
