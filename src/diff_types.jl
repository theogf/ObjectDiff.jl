
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

struct ComposedDiff{T<:AbstractDiff} <: AbstractDiff
    key::String
    diff::T
end

Base.isempty((; diff)::ComposedDiff) = isempty(diff)
name((; key)::ComposedDiff) = key
printdiff(io::IO, (; key, diff)::ComposedDiff) = print(io, key, ":")
function printdiff(io::IO, (; key, diff)::ComposedDiff{<:AtomicDiff})
    print(io, key, ": ")
    return printdiff(io, diff)
end
AbstractTrees.children((; diff)::ComposedDiff) = [diff]
AbstractTrees.children(::ComposedDiff{<:AtomicDiff}) = ()

struct FieldsDiff <: AbstractDiff
    diffs::Vector{ComposedDiff}
end

Base.isempty((; diffs)::FieldsDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::FieldsDiff) = filter(!isempty, diffs)
function printdiff(io::IO, (; diffs)::FieldsDiff)
    print(io, "fields: ")
    return printstyled(io, map(name, filter(!isempty, diffs)); color=mismatch_color())
end

struct ArrayDiff <: AbstractDiff
    diffs::Vector{ComposedDiff}
end

Base.isempty((; diffs)::ArrayDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::ArrayDiff) = filter(!isempty, diffs)
function printdiff(io::IO, (; diffs)::ArrayDiff)
    print(io, "components: ")
    return printstyled(
        io,
        map(Base.Fix1(parse, Int) ∘ name, filter(!isempty, diffs));
        color=mismatch_color(),
    )
end

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
