
"Difference with a specific name indicator. The key can be of all types."
struct NamedDiff{S,T<:AbstractDiff} <: AbstractDiff
    key::S
    diff::T
end

nodiff((; diff)::NamedDiff) = nodiff(diff)
name((; key)::NamedDiff) = key
printdiff(io::IO, (; key, diff)::NamedDiff) = print(io, key, ":")
function printdiff(io::IO, (; key, diff)::NamedDiff{S,<:AtomicDiff}) where {S}
    print(io, key, ": ")
    return printdiff(io, diff)
end
AbstractTrees.children((; diff)::NamedDiff) = [diff]
AbstractTrees.children(::NamedDiff{S,<:AtomicDiff}) where {S} = ()

"""
As opposed to [`AtomicDiff`](@ref), `DiffCollection` contains multiple diff objects.

You should implement `vals(::DiffCollection)` to return the unfiltered collection of diff elements.
Note that it defaults to `getproperty(::DiffCollection, :diffs)`.
"""
abstract type DiffCollection <: AbstractDiff end

vals(diff::DiffCollection) = diff.diffs
function nodiff(diff::DiffCollection)
    return isempty(vals(diff)) || all(nodiff, vals(diff))
end
AbstractTrees.children(diff::DiffCollection) = filter(!nodiff, vals(diff))
function printdiff(io::IO, diff::DiffCollection)
    diff_prefix(io, diff)
    names = map(name, children(diff))
    return printstyled(io, join(names, ", "); color=mismatch_color())
end

"Collection of fields differences, usually comes from comparing `struct`."
struct FieldsDiff <: DiffCollection
    diffs::Vector{<:NamedDiff{Symbol}}
end

diff_prefix(io::IO, ::FieldsDiff) = print(io, "fields: ")

"Collection of array element differences."
struct ArrayDiff <: DiffCollection
    diffs::Vector{<:NamedDiff{Int}}
end

diff_prefix(io::IO, ::ArrayDiff) = print(io, "indices: ")

"Collection of comparison of (key, value) pairs."
struct DictDiff <: DiffCollection
    diffs::Vector{NamedDiff}
end

function DictDiff(x::Dict, y::Dict)
    diffs = NamedDiff[]
    for k in keys(x)
        if !haskey(y, k)
            push!(diffs, NamedDiff(k, BitsDiff(x[k], missing)))
        else
            push!(diffs, NamedDiff(k, compare(x[k], y[k])))
        end
    end
    for k in keys(y)
        if !haskey(x, k)
            push!(diffs, NamedDiff(k, BitsDiff(missing, y[k])))
        end
    end
    return DictDiff(diffs)
end
diff_prefix(io::IO, ::DictDiff) = print(io, "keys: ")

struct StructDiff <: DiffCollection
    x::Any
    y::Any
    diffs::Vector{<:AbstractDiff}
end

function printdiff(io::IO, diff::StructDiff)
    (; x, y) = diff
    max_length = get(io, :string_length, nothing)
    printstyled(io, truncate_string(repr(x), max_length); color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, truncate_string(repr(y), max_length); color=ycolor(diff))
end
