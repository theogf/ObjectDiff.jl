using ObjectDiff
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
    @test !nodiff(compare(x, z))
    mktemp() do path, io
        redirect_stderr(io) do
            @test_diff x == y broken = true
        end
        flush(io)
        s = read(path, String)
        @test contains(s, "Foo ≠ String")
        @test contains(s, "5 ≠ nothing")
    end
end
