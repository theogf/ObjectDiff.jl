using StructDiff
using Test
using Aqua
using JET

struct Foo
    a
    b
end
struct Bar
    c
end

@testset "StructDiff.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(StructDiff)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(StructDiff; target_defined_modules=true)
    end
    @testset "Compare testing" begin
        x = Foo(Foo(2, 4), 5)
        y = Foo("C", nothing)
        z = Foo(Foo(2, 4), nothing)
    end
    # Write your tests here.
end
