"""
An `AtomicDiff` is a leaf in the diff tree, i.e. it does not have any children differences.
`AtomicDiff` subtypes should implement:
- `Base.first(::AtomicDiff)`: the left element
- `Base.last(::AtomicDiff)`: the right element

Subtypes can also implement the `diff_prefix(::IO, ::AtomicDiff)` to print some additional prefix.
"""
abstract type AtomicDiff <: AbstractDiff end

diff_prefix(::IO, ::AtomicDiff) = nothing

function printdiff(io::IO, diff::AtomicDiff)
    max_length = get(io, :string_length, nothing)
    diff_prefix(io, diff)
    printstyled(io, truncate_string(repr(first(diff)), max_length); color=xcolor(diff))
    print(io, " ≠ ")
    return printstyled(
        io, truncate_string(repr(last(diff)), max_length); color=ycolor(diff)
    )
end

"Representation of different types."
struct TypeDiff <: AtomicDiff
    T1::Type
    T2::Type
end

diff_prefix(io::IO, ::TypeDiff) = print(io, "type: ")
Base.first((; T1)::TypeDiff) = T1
Base.last((; T2)::TypeDiff) = T2

"Representation of different sizes."
struct SizeDiff <: AtomicDiff
    s1::Tuple
    s2::Tuple
end

diff_prefix(io::IO, ::SizeDiff) = print(io, "size: ")
Base.first((; s1)::SizeDiff) = s1
Base.last((; s2)::SizeDiff) = s2

"Basic representation of different objects, also used as a fallback."
struct BitsDiff <: AtomicDiff
    x::Any
    y::Any
end

Base.first((; x)::BitsDiff) = x
Base.last((; y)::BitsDiff) = y
