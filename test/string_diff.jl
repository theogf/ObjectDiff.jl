using Test

using ObjectDiff
using ObjectDiff: StringDiff

@testset "basic string comparison" begin
    a = "abc"
    b = "abc."
    @test nodiff(compare(a, a))
    @test !nodiff(compare(a, b))
    c = "abc\nd."
    d = "abc\ne."
    @test nodiff(compare(c, c))
    @test !nodiff(compare(c, d))
end

struct Foo
    s::String
end

@testset "string is inner field" begin
    a = Foo("This is my sentence")
    b = Foo("This is our sentence")
    c = Foo("This is not our sentence")
end
