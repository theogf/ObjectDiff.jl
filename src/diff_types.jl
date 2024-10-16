
abstract type AbstractDiff end

function AbstractTrees.printnode(io::IO, diff::AbstractDiff)
    return printdiff(
        IOContext(io, :compact => true, :limit => true, :string_length => 30), diff
    )
end

xcolor(::AbstractDiff) = :blue
ycolor(::AbstractDiff) = :yellow
mismatch_color() = :red

Base.isempty(::AbstractDiff) = false

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

struct TypeDiff <: AtomicDiff
    T1::Type
    T2::Type
end

diff_prefix(io::IO, ::TypeDiff) = print(io, "type: ")
Base.first((; T1)::TypeDiff) = T1
Base.last((; T2)::TypeDiff) = T2

struct SizeDiff <: AtomicDiff
    s1::Tuple
    s2::Tuple
end

diff_prefix(io::IO, ::SizeDiff) = print(io, "size: ")
Base.first((; s1)::SizeDiff) = s1
Base.last((; s2)::SizeDiff) = s2

struct BitsDiff <: AtomicDiff
    x::Any
    y::Any
end

Base.first((; x)::BitsDiff) = x
Base.last((; y)::BitsDiff) = y

struct NamedDiff{T<:AbstractDiff} <: AbstractDiff
    key::String
    diff::T
end

Base.isempty((; diff)::NamedDiff) = isempty(diff)
name((; key)::NamedDiff) = key
printdiff(io::IO, (; key, diff)::NamedDiff) = print(io, key, ":")
function printdiff(io::IO, (; key, diff)::NamedDiff{<:AtomicDiff})
    print(io, key, ": ")
    return printdiff(io, diff)
end
AbstractTrees.children((; diff)::NamedDiff) = [diff]
AbstractTrees.children(::NamedDiff{<:AtomicDiff}) = ()

abstract type DiffCollection <: AbstractDiff end

vals(diff::DiffCollection) = diff.diffs
function Base.isempty(diff::DiffCollection)
    return isempty(vals(diff)) || all(isempty, vals(diff))
end
AbstractTrees.children(diff::DiffCollection) = filter(!isempty, vals(diff))
function printdiff(io::IO, diff::DiffCollection)
    diff_prefix(io, diff)
    names = failed_names(diff, map(name, children(diff)))
    return printstyled(io, names; color=mismatch_color())
end
failed_names(::DiffCollection, names::Vector{String}) = names

struct FieldsDiff <: DiffCollection
    diffs::Vector{NamedDiff}
end

diff_prefix(io::IO, ::FieldsDiff) = print(io, "fields: ")

struct ArrayDiff <: AbstractDiff
    diffs::Vector{NamedDiff}
end
failed_names(::ArrayDiff, names::Vector{String}) = parse.(Int, names)

struct DictDiff <: DiffCollection
    diffs::Vector{NamedDiff}
end

function DictDiff(x::Dict, y::Dict)
    diffs = NamedDiff[]
    for k in keys(x)
        if !haskey(y, k)
            push!(diffs, NamedDiff(repr(k), BitsDiff(x[k], missing)))
        else
            push!(diffs, NamedDiff(repr(k), compare(x[k], y[k])))
        end
    end
    for k in keys(y)
        k_str = repr(k)
        if !haskey(x, k)
            push!(diffs, NamedDiff(k_str, BitsDiff(missing, y[k])))
        end
    end
    return DictDiff(diffs)
end
diff_prefix(io::IO, ::DictDiff) = print(io, "keys: ")

@kwdef struct StructSummary <: AbstractDiff
    x::Any
    y::Any
    diffs::Vector{AbstractDiff}
    prefix::String = ""
end

Base.isempty((; diffs)::StructSummary) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::StructSummary) = filter(!isempty, diffs)
function printdiff(io::IO, diff::StructSummary)
    (; prefix, x, y) = diff
    max_length = get(io, :string_length, nothing)
    print(io, prefix)
    printstyled(io, truncate_string(repr(x), max_length); color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, truncate_string(repr(y), max_length); color=ycolor(diff))
end
