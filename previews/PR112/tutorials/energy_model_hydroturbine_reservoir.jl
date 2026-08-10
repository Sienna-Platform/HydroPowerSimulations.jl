# # HydroTurbine + Reservoir for EnergyModel
#
# !!! note
#
#     `HydroPowerSimulations.jl` is an extension library of [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/) for modeling hydro units. Users are encouraged to review the [single-step tutorial in `PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) before this tutorial.
#
# ## Load packages

using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using PowerSystemCaseBuilder
using HiGHS ## solver

# ## Data
#
# !!! note
#
#     `PowerSystemCaseBuilder.jl` is a helper library that makes it easier to reproduce examples in the documentation and tutorials. Normally you would pass your local files to create the system data instead of calling the function `build_system`.
#     For more details visit [PowerSystemCaseBuilder README](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/blob/main/README.md)

sys = build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

# With a single [`PowerSystems.HydroTurbine`](@extref) connected downstream to a [`PowerSystems.HydroReservoir`](@extref):

hy = only(get_components(HydroTurbine, sys))

res = only(get_components(HydroReservoir, sys))

# Note that the reservoir has a `level_data_type` of `ENERGY`, that implies its storage level limits data are in MWh. That means that its maximum capacity is 5000 MWh, and its initial energy capacity is ``0.5 \cdot 5000 = 2500`` MWh.
#
# ## Decision Model
#
# Setting up the formulations based on [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Introduction/):

template = ProblemTemplate(PTDFPowerModel)
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template, PowerLoad, StaticPowerLoad)
set_device_model!(template, Line, StaticBranch)

# but, now we also include the HydroTurbine using [`HydroTurbineEnergyDispatch`](@ref):

set_device_model!(template, HydroTurbine, HydroTurbineEnergyDispatch)

# and we need to use the energy model for the HydroReservoir via [`HydroEnergyModelReservoir`](@ref). For this example we will ignore end targets of hydro budgets, but they can be included by setting up the attributes to `true`. It is not recommended to set both `energy_target` and `hydro_budget` to `true` simultaneously since it may create an infeasible problem:

reservoir_model = DeviceModel(
    HydroReservoir,
    HydroEnergyModelReservoir;
    attributes = Dict{String, Any}(
        "energy_target" => false,
        "hydro_budget" => false,
    ),
)
set_device_model!(template, reservoir_model)

# With the template properly set-up, we construct, build and solve the optimization problem:

model = DecisionModel(template, sys; optimizer = HiGHS.Optimizer)
build!(model; output_dir = mktempdir())
solve!(model)

# ## Exploring Results
#
# Results can be explored using:

res = OptimizationProblemResults(model)

# Use [`read_variable`](@extref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

var =
    read_variable(res, "ActivePowerVariable__HydroTurbine"; table_format = TableFormat.WIDE)

# or the energy capacity of the reservoir

energy =
    read_variable(res, "EnergyVariable__HydroReservoir"; table_format = TableFormat.WIDE)

# Note that since we have ignored the energy targets in the reservoir model, the optimal solution decides to deplete the reservoir.
