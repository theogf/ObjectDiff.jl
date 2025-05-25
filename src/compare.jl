
"""
    compare(x, y) -> AbstractDiff

Main functionality of the package. Takes two argument and build a comparison tree that recursively checks
different aspects of the compared objects.
The obtained object can be checked for equality with [`nodiff`](@ref).
"""
function compare(x::T1, y::T2) where {T1,T2}
    diffs = AbstractDiff[]
    if isbits(x) && isbits(y)
        if x !== y
            return BitsDiff(x, y)
        end
    elseif nameof(T1) != nameof(T2)
        return TypeDiff(T1, T2)
    elseif isstructtype(T1) && isstructtype(T2)
        diffs = AbstractDiff[]
        if T1 != T2
            push!(diffs, TypeDiff(T1, T2))
        end
        if fieldnames(T1) == fieldnames(T2)
            fields = map(collect(fieldnames(T1))) do field
                NamedDiff(field, compare(getfield(x, field), getfield(y, field)))
            end
            diff = FieldsDiff(fields)
            if !nodiff(diff)
                push!(diffs, diff)
            end
        else
            push!(diffs, compare(collect(fieldnames(T1)), collect(fieldnames(T2))))
        end
        return StructDiff(x, y, diffs)
    elseif x != y
        # If we miss all other cases, we just return the comparison as objects
        return BitsDiff(x, y)
    end
    return StructDiff(x, y, AbstractDiff[])
end

function compare(x::AbstractArray, y::AbstractArray)
    diffs = AbstractDiff[]
    T1 = typeof(x)
    T2 = typeof(y)
    if T1 != T2
        push!(diffs, TypeDiff(T1, T2))
    end
    if size(x) != size(y)
        push!(diffs, SizeDiff(size(x), size(y)))
    else
        fields = ArrayDiff(map(NamedDiff, 1:length(x), vec(map(compare, x, y))))
        nodiff(fields) || push!(diffs, fields)
    end
    return StructDiff(x, y, diffs)
end

function compare(d1::AbstractDict, d2::AbstractDict)
    diffs = AbstractDiff[]
    T1 = typeof(d1)
    T2 = typeof(d2)
    if T1 != T2
        push!(diffs, TypeDiff(T1, T2))
    end
    if length(d1) != length(d2)
        push!(diffs, SizeDiff((length(d1),), (length(d2),)))
    end
    if d1 != d2
        push!(diffs, DictDiff(d1, d2))
    end
    return StructDiff(d1, d2, diffs)
end

function compare(s1::AbstractString, s2::AbstractString)
    if contains(s1, '\n') || contains(s2, '\n')
        StringDiff{Lines}(s1, s2)
    else
        StringDiff{Words}(s1, s2)
    end
end
