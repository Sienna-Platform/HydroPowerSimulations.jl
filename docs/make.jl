using Documenter, HydroPowerSimulations
import DataStructures: OrderedDict
using DocumenterInterLinks
using Literate

links = InterLinks(
    "PowerSystems" => "https://sienna-platform.github.io/PowerSystems.jl/stable/",
    "PowerSimulations" => "https://sienna-platform.github.io/PowerSimulations.jl/stable/",
    "InfrastructureSystems" => "https://sienna-platform.github.io/InfrastructureSystems.jl/stable/",
)

# Function to clean up old generated files
function clean_old_generated_files(dir::String; remove_all_md::Bool=false)
    if !isdir(dir)
        @warn "Directory does not exist: $dir"
        return
    end
    if remove_all_md
        generated_files = filter(f -> endswith(f, ".md"), readdir(dir))
    else
        generated_files = filter(f -> startswith(f, "generated_") && endswith(f, ".md"), readdir(dir))
    end
    for file in generated_files
        rm(joinpath(dir, file), force=true)
        @info "Removed old generated file: $file"
    end
end

# Function to add download links to generated markdown
function add_download_links(content, jl_file, ipynb_file)
    download_section = """

*To follow along, you can download this tutorial as a [Julia script (.jl)](../$(jl_file)) or [Jupyter notebook (.ipynb)]($(ipynb_file)).*

"""
    m = match(r"^(#+ .+)$"m, content)
    if m !== nothing
        heading = m.match
        content = replace(content, r"^(#+ .+)$"m => heading * download_section, count=1)
    end
    return content
end

# Process tutorials with Literate
# Exclude helper scripts that start with "_"
tutorial_files = filter(x -> occursin(".jl", x) && !startswith(x, "_"), readdir("docs/src/tutorials"))
if !isempty(tutorial_files)
    tutorial_outputdir = joinpath(pwd(), "docs", "src", "tutorials", "generated")
    clean_old_generated_files(tutorial_outputdir; remove_all_md=true)
    mkpath(tutorial_outputdir)
    
    for file in tutorial_files
        @show file
        infile_path = joinpath(pwd(), "docs", "src", "tutorials", file)
        execute = occursin("EXECUTE = TRUE", uppercase(readline(infile_path))) ? true : false
        execute && include(infile_path)
        
        outputfile = replace("$file", ".jl" => "")
        
        # Generate markdown
        Literate.markdown(infile_path,
                          tutorial_outputdir;
                          name = outputfile,
                          credit = false,
                          flavor = Literate.DocumenterFlavor(),
                          documenter = true,
                          postprocess = (content -> add_download_links(content, file, string(outputfile, ".ipynb"))),
                          execute = execute)
        
        # Generate notebook
        Literate.notebook(infile_path,
                          tutorial_outputdir;
                          name = outputfile,
                          credit = false,
                          execute = false)
    end
end

pages = OrderedDict(
    "Welcome Page" => "index.md",
    "Tutorials" => Any[
        "Operation problem with HydroDispatchRunOfRiver" => "tutorials/generated/single_stage_model.md",
        "HydroDispatch with Market Bid Cost" => "tutorials/generated/hydro_with_marketbidcost.md",
        "Energy Hydro Reservoir Operation" => "tutorials/generated/energy_model_hydroturbine_reservoir.md",
        "Water Hydro Reservoir Operation" => "tutorials/generated/water_model_hydroturbine_reservoir.md",
        "Hydro Pump Turbine Operation" => "tutorials/generated/hydro_pump_turbine.md",
        "HydroEnergyBlock model usage" => "tutorials/generated/hydro_energy_block.md",
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
