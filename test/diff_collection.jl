using Test
using ObjectDiff
using ObjectDiff: AbstractDiff, NamedDiff, FieldsDiff, ArrayDiff, ObjectDiff

@testset "DiffCollection" begin
    mime = MIME"text/plain"()
    x = 2
    y = 3
    atom_d = BitsDiff(x, y)
    @testset "NamedDiff" begin
        d = NamedDiff(1, atom_d)
        @test !nodiff(d)
        @test repr(mime, d) == "1: " * repr(mime, atom_d)
    end
    @testset "FieldsDiff" begin
        d = FieldsDiff(NamedDiff{Symbol}[])
        @test nodiff(d)
        d = FieldsDiff([NamedDiff(:a, atom_d)])
        @test !nodiff(d)
    end
    @testset "ArrayDiff" begin
        d = ArrayDiff(NamedDiff{Int}[])
        @test nodiff(d)
        d = ArrayDiff([NamedDiff(1, atom_d)])
        @test !nodiff(d)
    end
    @testset "ObjectDiff" begin
        d = ObjectDiff(x, y, AbstractDiff[])
        @test nodiff(d)
        d = ObjectDiff(x, y, [atom_d])
        @test !nodiff(d)
    end
end
