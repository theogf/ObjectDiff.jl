using StructDiff
using Test
using Aqua
using JET

@testset "StructDiff.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(StructDiff)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(StructDiff; target_defined_modules = true)
    end
    # Write your tests here.
end
