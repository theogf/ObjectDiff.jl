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
    string_length = get(io, :string_length, 30)
    return printdiff(
        IOContext(io, :compact => true, :limit => true, :string_length => string_length),
        diff,
    )
end

xcolor(::AbstractDiff) = :blue
ycolor(::AbstractDiff) = :yellow
mismatch_color() = :red

"Indicates if the given `AbstractDiff` object contains actual differences."
nodiff(::AbstractDiff) = false
function Base.show(io::IO, ::MIME"text/plain", diff::AbstractDiff; maxdepth::Int=10)
    if nodiff(diff)
        printstyled(io, "Objects are equal."; color=:green)
    else
        print_tree(io, diff; maxdepth)
    end
end
g
function truncate_string(s::AbstractString, n::Int)
    if length(s) > n
        s[1:(min(n, end) - 1)] * "…"
    else
        s
    end
end
truncate_string(s::AbstractString, ::Nothing) = s
