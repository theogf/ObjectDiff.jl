module StructDiff

using AbstractTrees

export compare

include("diff_types.jl")

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

function Base.show(io::IO, ::MIME"text/plain", diff::AbstractDiff; maxdepth=10)
    if isempty(diff)
        println(io, "Objects are equal.")
    else
        print_tree(io, diff; maxdepth)
    end
end

end
