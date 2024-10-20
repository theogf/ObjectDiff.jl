
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
end
