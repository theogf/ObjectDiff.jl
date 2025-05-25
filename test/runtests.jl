using ObjectDiff
using Test
using Aqua
using JET

@testset "ObjectDiff.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ObjectDiff)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(ObjectDiff; target_defined_modules=true)
    end
    include("abstract_diff.jl")
    include("atomic_diff.jl")
    include("string_diff.jl")
    include("diff_collection.jl")
    include("compare.jl")
end
