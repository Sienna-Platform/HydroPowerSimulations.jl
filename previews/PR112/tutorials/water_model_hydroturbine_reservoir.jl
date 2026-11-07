# # HydroTurbine + Reservoir for WaterModel
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
using Ipopt ## solver

# ## Data
#
# !!! note
#
#     `PowerSystemCaseBuilder.jl` is a helper library that makes it easier to reproduce examples in the documentation and tutorials. Normally you would pass your local files to create the system data instead of calling the function `build_system`.
#     For more details visit [PowerSystemCaseBuilder README](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/blob/main/README.md)

sys = build_system(PSITestSystems, "c_sys5_hy_turbine_head")

# With a single [`PowerSystems.HydroTurbine`](@extref) connected downstream to a [`PowerSystems.HydroReservoir`](@extref):

hy = only(get_components(HydroTurbine, sys))

res = only(get_components(HydroReservoir, sys))

# Note that the reservoir has a `level_data_type` of `HEAD`, that implies its storage level limits data are in meters (above the sea level) and refer to the hydraulic head levels. That means that its available capacity lies with its hydraulic head being within 463.5 and 555.5 meters, and its intake elevation is at 463.3 meters. In addition note that the elevation of the turbine is on 317.12 meters above the sea level.
#
# ## Decision Model
#
# Setting up the formulations based on [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Introduction/):

template = ProblemTemplate(PTDFPowerModel)
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template, PowerLoad, StaticPowerLoad)
set_device_model!(template, Line, StaticBranch)

# but, now we also include the HydroTurbine using [`HydroTurbineBilinearDispatch`](@ref):

set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)

# This is a nonlinear model that to compute its output power requires the bilinear term `head` times `water flow`. For that purpose the non-convex Ipopt solver will be used to solve this problem.
#
# In addition, we need to use the water model for the HydroReservoir via [`HydroWaterModelReservoir`](@ref).

set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)

# With the template properly set-up, we construct, build and solve the optimization problem:

model = DecisionModel(template, sys; optimizer = Ipopt.Optimizer)
build!(model; output_dir = mktempdir())
solve!(model)

# ## Exploring Results
#
# Results can be explored using:

res = OptimizationProblemResults(model)

# Use [`read_variable`](@extref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

var =
    read_variable(res, "ActivePowerVariable__HydroTurbine"; table_format = TableFormat.WIDE)

# or the water flowing through the turbine (in m³/s):

var = read_expression(
    res,
    "TotalHydroFlowRateTurbineOutgoing__HydroTurbine";
    table_format = TableFormat.WIDE,
)

# and the head level of the reservoir:

hydraulic_head = read_variable(
    res,
    "HydroReservoirHeadVariable__HydroReservoir";
    table_format = TableFormat.WIDE,
)

# Note that since the water outflow limit of the turbine is limited on 30 m³/s, the optimal solution decides to flow as much water as possible producing power around 190 MW with that flow and hydraulic head.
