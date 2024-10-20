using StructDiff
using Test

struct Foo
    a
    b
end
struct Bar
    c
end
@testset "Compare testing" begin
    x = Foo(Foo(2, 4), 5)
    y = Foo("C", nothing)
    z = Foo(Foo(2, 4), nothing)
    @test !nodiff(compare(x, y))
    @test nodiff(compare(x, x))
    mktemp() do path, io
        @show path
        redirect_stderr(io) do
            @test_diff x == y broken = true
        end
        s = String(take!(io))
        @show s
        @test contains(s, "type: Foo ≠ String")
    end
end
