using ObjectDiff
using Test
using Aqua
using JET
using SafeTestsets

@testset "ObjectDiff.jl" begin
    @safetestset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ObjectDiff)
    end
    @safetestset "Code linting (JET.jl)" begin
        JET.test_package(ObjectDiff; target_defined_modules=true)
    end
    @safetestset "abstract_diff" include("abstract_diff.jl")
    @safetestset "atomic_diff" include("atomic_diff.jl")
    @safetestset "string_diff" include("string_diff.jl")
    @safetestset "diff_collection" include("diff_collection.jl")
    @safetestset "compare" include("compare.jl")
end
