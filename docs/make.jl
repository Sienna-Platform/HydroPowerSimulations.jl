using Documenter, HydroPowerSimulations
import DataStructures: OrderedDict
using DocumenterInterLinks
using Literate

# UPDATE FOR CURRENT MODULE NAME HERE
const _DOCS_BASE_URL = "https://nrel-sienna.github.io/HydroPowerSimulations.jl/stable"

links = InterLinks(
    "PowerSystems" => "https://sienna-platform.github.io/PowerSystems.jl/stable/",
    "PowerSimulations" => "https://sienna-platform.github.io/PowerSimulations.jl/stable/",
    "InfrastructureSystems" => "https://sienna-platform.github.io/InfrastructureSystems.jl/stable/",
)

include(joinpath(@__DIR__, "make_tutorials.jl"))
make_tutorials()

pages = OrderedDict(
    "Welcome Page" => "index.md",
    "Tutorials" => Any[
        "Operation problem with HydroDispatchRunOfRiver" => "tutorials/generated_single_stage_model.md",
        "HydroDispatch with Market Bid Cost" => "tutorials/generated_hydro_with_marketbidcost.md",
        "Energy Hydro Reservoir Operation" => "tutorials/generated_energy_model_hydroturbine_reservoir.md",
        "Water Hydro Reservoir Operation" => "tutorials/generated_water_model_hydroturbine_reservoir.md",
        "Hydro Pump Turbine Operation" => "tutorials/generated_hydro_pump_turbine.md",
        "HydroWaterFactorModel model usage" => "tutorials/generated_hydro_energy_block.md",
    ],
    "How to..." => Any[
        "...format input data for Hydro models" => "how_to/format_input_data.md",
        "...include budget limit and storage targets to Hydro models" => "how_to/include_limits_and_targets.md",
    ],
    "Explanation" => Any[
        "Difference between Energy and Water models" => "explanation/difference_between_energy_water_models.md",
    ],        
    "Formulation Library" => "model_library/formulation.md",
    "Reference" => Any[
        "Public API Reference" => "api/public.md",
        "Internal API Reference" => "api/internal.md",
    ]    
)

makedocs(
    modules=[HydroPowerSimulations],
    format=Documenter.HTML(;
        mathengine=Documenter.MathJax(),
        prettyurls=haskey(ENV, "GITHUB_ACTIONS"),
    ),
    sitename="HydroPowerSimulations.jl",
    pages=Any[p for p in pages],
    plugins=[links],
)

deploydocs(
    repo="github.com/Sienna-Platform/HydroPowerSimulations.jl.git",
    target="build",
    branch="gh-pages",
    devbranch="main",
    devurl="dev",
    push_preview=true,
    versions=["stable" => "v^", "v#.#"],
)
