# # HydroPumpTurbine with Energy Model
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

sys = build_system(PSITestSystems, "c_sys5_hydro_pump_energy")

# With a single [`PowerSystems.HydroPumpTurbine`](@extref) connected to two [`PowerSystems.HydroReservoir`](@extref) (head and tail reservoirs of the turbine):

hy = only(get_components(HydroPumpTurbine, sys))

res_head = get_component(HydroReservoir, sys, "Bat_head_reservoir")
res_tail = get_component(HydroReservoir, sys, "Bat_tail_reservoir")

# Note that the reservoirs has a `level_data_type` of `ENERGY`, that implies its storage level limits data are in MWh. That means that the available capacity of the head reservoir is between 5.0 and 400 MWh, while the tail reservoir is set to zero, implying an infinite tail reservoir.
#
# ## Decision Model
#
# Setting up the formulations based on [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Introduction/):

template = ProblemTemplate(PTDFPowerModel)
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template, PowerLoad, StaticPowerLoad)
set_device_model!(template, Line, StaticBranch)

# but, now we also include the HydroTurbine using [`HydroPumpEnergyDispatch`](@ref):

pump_model = DeviceModel(
    HydroPumpTurbine,
    HydroPumpEnergyDispatch;
    attributes = Dict{String, Any}(
        "reservation" => true,
        "energy_target" => false,
    ),
    time_series_names = Dict(),
)
set_device_model!(template, pump_model)

# The `HydroPumpEnergyDispatch`(@ref) is a closed model for turbine and must be connected to independent reservoirs (not connected with other `HydroTurbine`). For that reason it is not needed to include a model of [`HydroEnergyModelReservoir`](@ref). When the attribute `reservation` is set-up to `true` it does not allow to simultaneously use the pump and turbine, forcing one of those variables to zero. The `energy_target` attributes allow to include a final target for the head reservoir based on its `level_targets` field.
#
# In addition, the `time_series_names` is set-up to an empty dictionary. By default, the `HydroPumpEnergyDispatch`(@ref) model allows to include limits on the `capacity` and `max_active_power` at each time step if the user need it by properly setting up those time series (similar to a [`HydroDispatchRunOfRiver`](@ref) model)
#
# ```julia
# time_series_names = Dict(
#     ActivePowerTimeSeriesParameter => "max_active_power",
#     EnergyCapacityTimeSeriesParameter => "capacity",
# )
# ```
#
# With the template properly set-up, we construct, build and solve the optimization problem:

model = DecisionModel(template, sys; optimizer = HiGHS.Optimizer)
build!(model; output_dir = mktempdir())
solve!(model)

# ## Exploring Results
#
# Results can be explored using:

res = OptimizationProblemResults(model)

# Use [`read_variable`](@extref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

var = read_variable(
    res,
    "ActivePowerVariable__HydroPumpTurbine";
    table_format = TableFormat.WIDE,
)

# its pump usage

var = read_variable(
    res,
    "ActivePowerPumpVariable__HydroPumpTurbine";
    table_format = TableFormat.WIDE,
)

# and stored energy:

var =
    read_variable(res, "EnergyVariable__HydroPumpTurbine"; table_format = TableFormat.WIDE)
