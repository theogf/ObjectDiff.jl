using ObjectDiff
using Documenter

DocMeta.setdocmeta!(ObjectDiff, :DocTestSetup, :(using ObjectDiff); recursive=true)

makedocs(;
    modules=[ObjectDiff],
    authors="theogf <theo.galyfajou@gmail.com> and contributors",
    sitename="ObjectDiff.jl",
    format=Documenter.HTML(;
        canonical="https://theogf.github.io/ObjectDiff.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/theogf/ObjectDiff.jl", devbranch="main")
