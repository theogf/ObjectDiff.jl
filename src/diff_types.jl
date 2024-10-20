"""
General abstract representation of a difference between two objects.
Any `AbstractDiff` type should implement the following:
- `printdiff(::IO, ::AbstractDiff)` 
- `nodiff(::AbstractDiff)::Bool` whether there are differences to consider.

Optionally you can implement:
- `xcolor::Symbol` color of the left object (default `:blue`).
- `ycolor::Symbol` color of the right object (default `:yellow`).
"""
abstract type AbstractDiff end

function AbstractTrees.printnode(io::IO, diff::AbstractDiff)
    return printdiff(
        IOContext(io, :compact => true, :limit => true, :string_length => 30), diff
    )
end

xcolor(::AbstractDiff) = :blue
ycolor(::AbstractDiff) = :yellow
mismatch_color() = :red

nodiff(::AbstractDiff) = false

"""
An `AtomicDiff` is a leaf in the diff tree, i.e. it does not have any children differences.
`AtomicDiff` subtypes should implement:
- `Base.first(::AtomicDiff)`: the left element
- `Base.last(::AtomicDiff)`: the right element

Subtypes can also implement the `diff_prefix(::IO, ::AtomicDiff)` to print some additional prefix.
"""
abstract type AtomicDiff <: AbstractDiff end

diff_prefix(::IO, ::AtomicDiff) = nothing

function truncate_string(s::AbstractString, n::Int)
    if length(s) > n
        s[1:(min(n, end) - 1)] * "…"
    else
        s
    end
end
truncate_string(s::AbstractString, ::Nothing) = s

function printdiff(io::IO, diff::AtomicDiff)
    max_length = get(io, :string_length, nothing)
    diff_prefix(io, diff)
    printstyled(io, truncate_string(repr(first(diff)), max_length); color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(
        io, truncate_string(repr(last(diff)), max_length); color=ycolor(diff)
    )
end

"Representation of different types."
struct TypeDiff <: AtomicDiff
    T1::Type
    T2::Type
end

diff_prefix(io::IO, ::TypeDiff) = print(io, "type: ")
Base.first((; T1)::TypeDiff) = T1
Base.last((; T2)::TypeDiff) = T2

"Representation of different sizes."
struct SizeDiff <: AtomicDiff
    s1::Tuple
    s2::Tuple
end

diff_prefix(io::IO, ::SizeDiff) = print(io, "size: ")
Base.first((; s1)::SizeDiff) = s1
Base.last((; s2)::SizeDiff) = s2

"Basic representation of different objects, also used as a fallback."
struct BitsDiff <: AtomicDiff
    x::Any
    y::Any
end

Base.first((; x)::BitsDiff) = x
Base.last((; y)::BitsDiff) = y

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

struct ObjectDiff <: DiffCollection
    x::Any
    y::Any
    diffs::Vector{<:AbstractDiff}
end

function printdiff(io::IO, diff::ObjectDiff)
    (; x, y) = diff
    max_length = get(io, :string_length, nothing)
    printstyled(io, truncate_string(repr(x), max_length); color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, truncate_string(repr(y), max_length); color=ycolor(diff))
end
