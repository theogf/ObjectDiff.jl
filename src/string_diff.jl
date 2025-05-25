# The original code is from the Documenter.jl package licensed under the MIT License.
# https://github.com/JuliaDocs/Documenter.jl/blob/master/src/utilities/TextDiff.jl
# It has been modified with respect to the package.

function lcs(old_tokens::Vector, new_tokens::Vector)
    m = length(old_tokens)
    n = length(new_tokens)
    weights = zeros(Int, m + 1, n + 1)
    for i in 2:(m + 1), j in 2:(n + 1)
        weights[i, j] = if old_tokens[i - 1] == new_tokens[j - 1]
            weights[i - 1, j - 1] + 1
        else
            max(weights[i, j - 1], weights[i - 1, j])
        end
    end
    return weights
end

function makediff(weights::Matrix, old_tokens::Vector, new_tokens::Vector)
    m = length(old_tokens)
    n = length(new_tokens)
    diff = Vector{Pair{Symbol,SubString{String}}}()
    makediff!(diff, weights, old_tokens, new_tokens, m + 1, n + 1)
    return diff
end

function makediff!(out, weights, X, Y, i, j)
    if i > 1 && j > 1 && X[i - 1] == Y[j - 1]
        makediff!(out, weights, X, Y, i - 1, j - 1)
        # push!(out, :normal => X[i - 1])
    else
        if j > 1 && (i == 1 || weights[i, j - 1] >= weights[i - 1, j])
            makediff!(out, weights, X, Y, i, j - 1)
            push!(out, :blue => Y[j - 1])
        elseif i > 1 && (j == 1 || weights[i, j - 1] < weights[i - 1, j])
            makediff!(out, weights, X, Y, i - 1, j)
            push!(out, :yellow => X[i - 1])
        end
    end
    return out
end

"""
Splits `text` at `regex` matches, returning an array of substrings. The parts of the string
that match the regular expression are also included at the ends of the returned strings.
"""
function splitby(reg::Regex, text::AbstractString)
    out = SubString{String}[]
    token_first = 1
    for each in eachmatch(reg, text)
        token_last = each.offset + lastindex(each.match) - 1
        push!(out, SubString(text, token_first, token_last))
        token_first = nextind(text, token_last)
    end
    laststr = SubString(text, token_first)
    isempty(laststr) || push!(out, laststr)
    return out
end

# Diff Type.

struct Lines end
struct Words end

splitter(::Type{Lines}) = r"\n"
splitter(::Type{Words}) = r"\s+"

struct StringDiff{T} <: AbstractDiff
    old_tokens::Vector{SubString{String}}
    new_tokens::Vector{SubString{String}}
    weights::Matrix{Int}
    diffs::Vector{Pair{Symbol,SubString{String}}}

    function StringDiff{T}(old_text::AbstractString, new_text::AbstractString) where {T}
        reg = splitter(T)
        old_tokens = splitby(reg, old_text)
        new_tokens = splitby(reg, new_text)
        weights = lcs(old_tokens, new_tokens)
        diff = makediff(weights, old_tokens, new_tokens)
        return new{T}(old_tokens, new_tokens, weights, diff)
    end
end

# Display.
nodiff((; diffs)::StringDiff) = isempty(diffs)
function printdiff(io::IO, sdiff::StringDiff{T}) where {T}
    max_length = get(io, :string_length, nothing)
    s1 = truncate_string(join(sdiff.old_tokens), max_length)
    s2 = truncate_string(join(sdiff.new_tokens), max_length)
    printstyled(io, s1; color=:blue)
    print(io, " ≠ ")
    printstyled(io, s2; color=:yellow)
    println(io)
    for (color, text) in sdiff.diffs
        indicator = color == :yellow ? '+' : '-'
        printstyled(io, indicator, text; color=color)
        println(io)
        # !isempty(text) && println(io)
    end
end
