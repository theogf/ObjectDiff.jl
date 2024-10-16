module StructDiff

using AbstractTrees

export compare

abstract type AbstractDiff end

Base.isempty(::AbstractDiff) = false

struct TypeDiff <: AbstractDiff
    T1::Type
    T2::Type
end

AbstractTrees.printnode(io::IO, (; T1, T2)::TypeDiff) = print(io, "type:", T1, " ≠ ", T2)

struct SizeDiff <: AbstractDiff
    s1::Tuple
    s2::Tuple
end

AbstractTrees.printnode(io::IO, (; s1, s2)::SizeDiff) = print(io, "size: $(s1) ≠ $(s2)")

struct FieldDiff <: AbstractDiff
    name::Symbol
    diff::AbstractDiff
end

Base.isempty((; diff)::FieldDiff) = isempty(diff)
name((; name)::FieldDiff) = name
AbstractTrees.printnode(io::IO, (; name, diff)::FieldDiff) = print(io, "$(name):")
AbstractTrees.children((; diff)::FieldDiff) = [diff]

struct FieldsDiff <: AbstractDiff
    diffs::Vector{FieldDiff}
end

Base.isempty((; diffs)::FieldsDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::FieldsDiff) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, (; diffs)::FieldsDiff)
    return print(io, "Fields $(map(name, filter(!isempty, diffs)))")
end

struct ComponentDiff <: AbstractDiff
    index::Int
    diff::AbstractDiff
end

Base.isempty((; diff)::ComponentDiff) = isempty(diff)
index((; index)::ComponentDiff) = index
AbstractTrees.printnode(io::IO, (; index, diff)::ComponentDiff) = print(io, index, ":")
AbstractTrees.children((; diff)::ComponentDiff) = [diff]

struct ArrayDiff <: AbstractDiff
    diffs::Vector{ComponentDiff}
end

Base.isempty((; diffs)::ArrayDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::ArrayDiff) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, (; diffs)::ArrayDiff)
    return print(io, "Array: ", map(index, filter(!isempty, diffs)))
end

@kwdef struct StructSummary <: AbstractDiff
    x::Any
    y::Any
    diffs::Vector{AbstractDiff}
    prefix::String = ""
end

Base.isempty((; diffs)::StructSummary) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::StructSummary) = filter(!isempty, diffs)
function AbstractTrees.printnode(io::IO, (; prefix, x, y)::StructSummary)
    return print(io, prefix, "$(x) ≠ $(y)")
end

struct BitsDiff <: AbstractDiff
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
    return print_tree(io, diff)
end

end
