module StructDiff

using AbstractTrees

export compare

abstract type AbstractDiff end

Base.isempty(::AbstractDiff) = false

struct TypeDiff <: AbstractDiff
    T1::DataType
    T2::DataType
end

AbstractTrees.nodevalue((; T1, T2)::TypeDiff) = "type: $(T1) ≠ $(T2)"

struct SizeDiff <: AbstractDiff
    s1::Tuple
    s2::Tuple
end

AbstractTrees.nodevalue((; s1, s2)::SizeDiff) = "size: $(s1) ≠ $(s2)"

struct FieldDiff <: AbstractDiff
    name::Symbol
    diff::AbstractDiff
end

Base.isempty((; diff)::FieldDiff) = isempty(diff)
name((; name)::FieldDiff) = name
AbstractTrees.nodevalue((; name, diff)::FieldDiff) = "$(name):"
AbstractTrees.children((; diff)::FieldDiff) = [diff]

struct FieldsDiff <: AbstractDiff
    diffs::Vector{FieldDiff}
end

Base.isempty((; diffs)::FieldsDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::FieldsDiff) = filter(!isempty, diffs)
function AbstractTrees.nodevalue((; diffs)::FieldsDiff)
    return "Fields $(map(name, filter(!isempty, diffs)))"
end

struct ArrayDiff <: AbstractDiff
    diffs::Vector{AbstractDiff}
end

Base.isempty((; diffs)::ArrayDiff) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::ArrayDiff) = filter(!isempty, diffs)
AbstractTrees.nodevalue(::ArrayDiff) = "Array"

struct StructSummary <: AbstractDiff
    summary::Union{Nothing,String}
    x::Any
    y::Any
    diffs::Vector{AbstractDiff}
end

Base.isempty((; diffs)::StructSummary) = isempty(diffs) || all(isempty, diffs)
AbstractTrees.children((; diffs)::StructSummary) = filter(!isempty, diffs)
function AbstractTrees.nodevalue((; summary, x, y)::StructSummary)
    return something(summary, "$(x) ≠ $(y)")
end

struct BitsDiff <: AbstractDiff
    x::Any
    y::Any
end

AbstractTrees.nodevalue((; x, y)::BitsDiff) = "$x ≠ $y"

# Write your package code here.
function compare(x::T1, y::T2) where {T1,T2}
    diffs = AbstractDiff[]
    if isbits(x) && isbits(y)
        if x !== y
            return BitsDiff(x, y)
        end
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
    elseif T1 <: AbstractArray && T2 <: AbstractArray
    end
    return StructSummary(nothing, x, y, diffs)
end

function compare(x::AbstractArray{T1}, y::AbstractArray{T2}) where {T1,T2}
    diffs = AbstractDiff[]
    if T1 != T2
        push!(diffs, TypeDiff(T1, T2))
    end
    if size(x) != size(y)
        push!(diffs, SizeDiff(size(x), size(y)))
    else
        fields = ArrayDiff(map(compare, x, y))
        isempty(fields) || push!(diffs, fields)
    end
    return StructSummary(nothing, x, y, diffs)
end

function Base.show(io::IO, ::MIME"text/plain", diff::AbstractDiff)
    return print_tree(io, diff)
end

end
