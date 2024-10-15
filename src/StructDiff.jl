module StructDiff

export compare

struct TypeDifference
    T1::DataType
    T2::DataType
end

struct FieldDifferences
    f1::Vector{Symbol}
    f2::Vector{Symbol}
end

struct BitsDiff
    x::Any
    y::Any
end

# Write your package code here.
function compare(x::T1, y::T2) where {T1,T2}
    diffs = []
    if T1 != T2
        push!(diffs, TypeDifference(T1, T2))
    end
    if isbits(x) && isbits(y)
        if x !== y
            push!(diffs, BitsDiff(x, y))
        end
    elseif isstructtype(T1) && isstructtype(T2)
        if fieldnames(T1) == fieldnames(T2)
            fields = map(collect(fieldnames(T1))) do field
                compare(getfield(x, field), getfield(y, field))
            end
            push!(diffs, fields)
        else
            push!(diffs, FieldDifferences(fieldnames(T1), fieldnames(T2)))
        end
    end
    return diffs
end

end
