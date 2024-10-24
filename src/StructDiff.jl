module ObjectDiff

using AbstractTrees
using Test: @test

export compare, nodiff
export @test_diff

include("abstract_diff.jl")
include("atomic_diff.jl")
include("diff_collection.jl")
include("compare.jl")
include("test.jl")

end
