# # HydroWaterFactorModel model tutorial
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

sys = build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

# With a single [`PowerSystems.HydroTurbine`](@extref) connected downstream to a [`PowerSystems.HydroReservoir`](@extref):

reservoir = only(get_components(HydroReservoir, sys))

# Set the storage level limits using `set_storage_level_limits!`. Here the limits are set between ``4000 and 6000 m^3`` .

set_storage_level_limits!(reservoir, (min = 4000, max = 6000))

# Set the lower bound of reservoir volume using `set_level_targets!`. Here the level target is set at ``0.9 \cdot 6000 = 5400 m^3``.

set_level_targets!(reservoir, 0.9)

# Set the head_to_volume factor to 1.0 using `set_head_to_volume_factor!`, since is an energy model and no conversion is needed.
set_head_to_volume_factor!(reservoir, LinearCurve(1.0))

# ## Decision Model
#
# Setting up the formulations based on [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Introduction/):

template = ProblemTemplate(CopperPlatePowerModel)
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template, PowerLoad, StaticPowerLoad)

# but, now we also include the HydroReservoir and HydroTurbine using [`HydroWaterFactorModel`](@ref):

set_device_model!(template, HydroReservoir, HydroWaterFactorModel)
set_device_model!(template, HydroTurbine, HydroWaterFactorModel)

# With the template properly set-up, we construct, build and solve the optimization problem:

model = DecisionModel(template, sys; optimizer = Ipopt.Optimizer)
build!(model; output_dir = mktempdir())
solve!(model)

# ## Exploring Results
#
# Results can be explored using:

results = OptimizationProblemResults(model)

# Use [`read_variable`](@extref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

power =
    read_variable(
        results,
        "ActivePowerVariable__HydroTurbine";
        table_format = TableFormat.WIDE,
    )

# or the volume level of the reservoir

volume =
    read_variable(
        results,
        "HydroReservoirVolumeVariable__HydroReservoir";
        table_format = TableFormat.WIDE,
    )

# Note that the final reservoir level is between the set level target and the maximum storage level.
