var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ObjectDiff","category":"page"},{"location":"#ObjectDiff","page":"Home","title":"ObjectDiff","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ObjectDiff.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ObjectDiff]","category":"page"},{"location":"#ObjectDiff.AbstractDiff","page":"Home","title":"ObjectDiff.AbstractDiff","text":"General abstract representation of a difference between two objects. Any AbstractDiff type should implement the following:\n\nprintdiff(::IO, ::AbstractDiff) \nnodiff(::AbstractDiff)::Bool whether there are differences to consider.\n\nOptionally you can implement:\n\nxcolor::Symbol color of the left object (default :blue).\nycolor::Symbol color of the right object (default :yellow).\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.ArrayDiff","page":"Home","title":"ObjectDiff.ArrayDiff","text":"Collection of array element differences.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.AtomicDiff","page":"Home","title":"ObjectDiff.AtomicDiff","text":"An AtomicDiff is a leaf in the diff tree, i.e. it does not have any children differences. AtomicDiff subtypes should implement:\n\nBase.first(::AtomicDiff): the left element\nBase.last(::AtomicDiff): the right element\n\nSubtypes can also implement the diff_prefix(::IO, ::AtomicDiff) to print some additional prefix.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.BitsDiff","page":"Home","title":"ObjectDiff.BitsDiff","text":"Basic representation of different objects, also used as a fallback.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.DictDiff","page":"Home","title":"ObjectDiff.DictDiff","text":"Collection of comparison of (key, value) pairs.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.DiffCollection","page":"Home","title":"ObjectDiff.DiffCollection","text":"As opposed to AtomicDiff, DiffCollection contains multiple diff objects.\n\nYou should implement vals(::DiffCollection) to return the unfiltered collection of diff elements. Note that it defaults to getproperty(::DiffCollection, :diffs).\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.FieldsDiff","page":"Home","title":"ObjectDiff.FieldsDiff","text":"Collection of fields differences, usually comes from comparing struct.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.NamedDiff","page":"Home","title":"ObjectDiff.NamedDiff","text":"Difference with a specific name indicator. The key can be of all types.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.SizeDiff","page":"Home","title":"ObjectDiff.SizeDiff","text":"Representation of different sizes.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.TypeDiff","page":"Home","title":"ObjectDiff.TypeDiff","text":"Representation of different types.\n\n\n\n\n\n","category":"type"},{"location":"#ObjectDiff.compare-Union{Tuple{T2}, Tuple{T1}, Tuple{T1, T2}} where {T1, T2}","page":"Home","title":"ObjectDiff.compare","text":"compare(x, y) -> AbstractDiff\n\nMain functionality of the package. Takes two argument and build a comparison tree that recursively checks different aspects of the compared objects. The obtained object can be checked for equality with nodiff.\n\n\n\n\n\n","category":"method"},{"location":"#ObjectDiff.nodiff-Tuple{ObjectDiff.AbstractDiff}","page":"Home","title":"ObjectDiff.nodiff","text":"Indicates if the given AbstractDiff object contains actual differences.\n\n\n\n\n\n","category":"method"},{"location":"#ObjectDiff.splitby-Tuple{Regex, AbstractString}","page":"Home","title":"ObjectDiff.splitby","text":"Splits text at regex matches, returning an array of substrings. The parts of the string that match the regular expression are also included at the ends of the returned strings.\n\n\n\n\n\n","category":"method"},{"location":"#ObjectDiff.@test_diff-Tuple{Any, Vararg{Any}}","page":"Home","title":"ObjectDiff.@test_diff","text":"Equivalent to the @test macro, that will print the difference tree if @test_diff is called on an equality call.\n\n\n\n\n\n","category":"macro"}]
}