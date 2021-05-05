using CoordinatedMotionPlanning
using Documenter

DocMeta.setdocmeta!(CoordinatedMotionPlanning, :DocTestSetup, :(using CoordinatedMotionPlanning); recursive=true)

makedocs(;
    modules=[CoordinatedMotionPlanning],
    authors="Saujas Nandi",
    repo="https://github.com/s-nandi/CoordinatedMotionPlanning.jl/blob/{commit}{path}#{line}",
    sitename="CoordinatedMotionPlanning.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://s-nandi.github.io/CoordinatedMotionPlanning.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/s-nandi/CoordinatedMotionPlanning.jl",
)
