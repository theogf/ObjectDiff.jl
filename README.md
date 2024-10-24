# ObjectDiff

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://theogf.github.io/ObjectDiff.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://theogf.github.io/ObjectDiff.jl/dev/)
[![Build Status](https://github.com/theogf/ObjectDiff.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/theogf/ObjectDiff.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Explain through visuals why two objects do not satisfy `==`.

It can be frustrating for highly nested objects to just find out that `x == y` returns false.

`ObjectDiff.jl` is an attempt to make the comparison more detailed by going recursively through fields, elements or pairs (depending on the object) and compare different aspects (type, size, content, etc...).
The main function to use is `compare(x, y)`.

The final object is printed as a tree and instead of showing the first discrepancy that produced `false`, it shows all inconsistencies at once.

## Example

```julia
julia> struct Foo
 a
 b
end;

julia> x = Foo(Foo(2, 4), 5);
julia> y = Foo("C", nothing);
julia> compare(x, y)
Foo(Foo(2, 4), 5) ≠ Foo("C", nothing)
└─ fields: a, b
   ├─ a: type: Foo ≠ String
   └─ b: 5 ≠ nothing
```

## Test macro

To directly integrate it in your tests, you can use

```julia
@test_diff x == y
```

which will print the difference tree if they fail to satisfy equality.
