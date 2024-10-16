module StructDiff

using AbstractTrees

export compare

abstract type AbstractDiff end

abstract type AtomicDiff <: AbstractDiff end

xcolor(::AbstractDiff) = :blue
ycolor(::AbstractDiff) = :yellow
mismatch_color() = :red

Base.isempty(::AbstractDiff) = false

struct TypeDiff <: AtomicDiff
    T1::Type
    T2::Type
end

function AbstractTrees.printnode(io::IO, diff::TypeDiff)
    print(io, "type: ")
    printstyled(io, diff.T1; color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, diff.T2; color=ycolor(diff))
end

struct SizeDiff <: AtomicDiff
    s1::Tuple
    s2::Tuple
end

function AbstractTrees.printnode(io::IO, diff::SizeDiff)
    print(io, "size: ")
    printstyled(io, diff.s1; color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, diff.s2; color=ycolor(diff))
end

struct FieldDiff{T<:AbstractDiff} <: AbstractDiff
    name::Symbol
    diff::T
end

Base.isempty((; diff)::FieldDiff) = isempty(diff)
name((; name)::FieldDiff) = name
AbstractTrees.printnode(io::IO, (; name, diff)::FieldDiff) = print(io, name, ":")
function AbstractTrees.printnode(io::IO, (; name, diff)::FieldDiff{<:AtomicDiff})
    print(io, name, ": ")
    return AbstractTrees.printnode(io, diff)
end
AbstractTrees.children((; diff)::FieldDiff) = [diff]
AbstractTrees.children(::FieldDiff{<:AtomicDiff}) = ()

struct FieldsDiff <: AbstractDiff
    diffs::Vector{FieldDiff}
end

Base.isempty((; diffs)::FieldsDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::FieldsDiff) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, (; diffs)::FieldsDiff)
    print(io, "fields: ")
    return printstyled(io, map(name, filter(!isempty, diffs)); color=mismatch_color())
end

struct ComponentDiff{T<:AbstractDiff} <: AbstractDiff
    index::Int
    diff::T
end

Base.isempty((; diff)::ComponentDiff) = isempty(diff)
index((; index)::ComponentDiff) = index
AbstractTrees.printnode(io::IO, (; index)::ComponentDiff) = print(io, index, ":")
function AbstractTrees.printnode(io::IO, (; index, diff)::ComponentDiff{<:AtomicDiff})
    print(io, index, ": ")
    return AbstractTrees.printnode(io, diff)
end
AbstractTrees.children((; diff)::ComponentDiff) = [diff]
AbstractTrees.children((; diff)::ComponentDiff{<:AtomicDiff}) = ()

struct ArrayDiff <: AbstractDiff
    diffs::Vector{ComponentDiff}
end

Base.isempty((; diffs)::ArrayDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::ArrayDiff) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, (; diffs)::ArrayDiff)
    print(io, "components: ")
    return printstyled(io, map(index, filter(!isempty, diffs)); color=mismatch_color())
end

@kwdef struct StructSummary <: AbstractDiff
    x::Any
    y::Any
    diffs::Vector{AbstractDiff}
    prefix::String = ""
end

Base.isempty((; diffs)::StructSummary) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::StructSummary) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, diff::StructSummary)
    (; prefix, x, y) = diff
    print(io, prefix)
    printstyled(io, x; color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(io, y; color=ycolor(diff))
end

struct BitsDiff <: AtomicDiff
    x::Any
    y::Any
end

AbstractTrees.printnode(io::IO, (; x, y)::BitsDiff) = print(io, x, " ≠ ", y)

# Write your package code here.
function compare(x::T1, y::T2) where {T1,T2}
    diffs = AbstractDiff[]
    if isbits(x) && isbits(y)
        if x !== y
            return BitsDiff(x, y)
        end
    elseif nameof(T1) != nameof(T2)
        return TypeDiff(T1, T2)
    elseif isstructtype(T1) && isstructtype(T2)
        if T1 != T2
            push!(diffs, TypeDiff(T1, T2))
        end
        if fieldnames(T1) == fieldnames(T2)
            fields = map(collect(fieldnames(T1))) do field
                FieldDiff(field, compare(getfield(x, field), getfield(y, field)))
            end
            diff = FieldsDiff(fields)
            if !isempty(diff)
                push!(diffs, diff)
            end
        else
            push!(diffs, compare(collect(fieldnames(T1)), collect(fieldnames(T2))))
        end
    else
    end
    return StructSummary(x, y, diffs, "")
end

function compare(x::AbstractArray{T1}, y::AbstractArray{T2}) where {T1,T2}
    diffs = AbstractDiff[]
    if T1 != T2
        push!(diffs, TypeDiff(T1, T2))
    end
    if size(x) != size(y)
        push!(diffs, SizeDiff(size(x), size(y)))
    else
        fields = ArrayDiff(map(ComponentDiff, 1:length(x), vec(map(compare, x, y))))
        isempty(fields) || push!(diffs, fields)
    end
    return StructSummary(x, y, diffs, "")
end

function Base.show(io::IO, ::MIME"text/plain", diff::AbstractDiff)
    if isempty(diff)
        println(io, "Objects are equal.")
    else
        print_tree(io, diff)
    end
end

end
