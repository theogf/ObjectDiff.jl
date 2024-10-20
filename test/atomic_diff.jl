using Test
using StructDiff
using StructDiff: TypeDiff, SizeDiff, BitsDiff

@testset "AtomicDiff" begin
    @testset "TypeDiff" begin
        d = TypeDiff(Float64, Int64)
        @test !nodiff(d)
        @test repr(MIME"text/plain"(), d) == "type: Float64 ≠ Int64\n"
    end
    @testset "SizeDiff" begin
        d = SizeDiff((1, 2), (1, 3))
        @test !nodiff(d)
        @test repr(MIME"text/plain"(), d) == "size: (1, 2) ≠ (1, 3)\n"
    end
    @testset "BitsDiff" begin
        d = BitsDiff(2, 4)
        @test !nodiff(d)
        @test repr(MIME"text/plain"(), d) == "2 ≠ 4\n"
    end
    @testset "Truncation" begin
        s1 = "a"^64
        s2 = "b"^64
        d = BitsDiff(s1, s2)
        for n in [3, 5, 10, 30]
            @test repr(MIME"text/plain"(), d; context=:string_length => n) ==
                "\"" * "a"^(n - 2) * "… ≠ \"" * "b"^(n - 2) * "…\n"
        end
    end
end
