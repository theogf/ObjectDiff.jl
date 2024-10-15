using StructDiff
using Documenter

DocMeta.setdocmeta!(StructDiff, :DocTestSetup, :(using StructDiff); recursive=true)

makedocs(;
    modules=[StructDiff],
    authors="theogf <theo.galyfajou@gmail.com> and contributors",
    sitename="StructDiff.jl",
    format=Documenter.HTML(;
        canonical="https://theogf.github.io/StructDiff.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/theogf/StructDiff.jl",
    devbranch="main",
)
