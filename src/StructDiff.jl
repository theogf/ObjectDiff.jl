module StructDiff

using AbstractTrees

export compare, nodiff

include("diff_types.jl")
include("atomic_diff.jl")
include("diff_collection.jl")
include("compare.jl")

end
