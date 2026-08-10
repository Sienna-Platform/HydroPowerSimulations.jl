# # [Operation Problem with `HydroPowerSimulations.jl` using Market Bid Cost](@id op_problem_mbc)
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
using TimeSeries
using Dates

# ## Data
#
# !!! note
#
#     `PowerSystemCaseBuilder.jl` is a helper library that makes it easier to reproduce examples in the documentation and tutorials. Normally you would pass your local files to create the system data instead of calling the function `build_system`.
#     For more details visit [PowerSystemCaseBuilder README](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/blob/main/README.md)

sys = build_system(PSITestSystems, "c_sys5_hy"; add_single_time_series = true)

# ## Add a time-varying fuel cost for a thermal unit
#
# We will modify the cheapest unit Brighton to have time-varying fuel cost. First we add a `PowerSystems.FuelCurve`:

brighton = get_component(ThermalStandard, sys, "Brighton")
old_thermal_cost = get_operation_cost(brighton)
new_fuel_curve = FuelCurve(;
    value_curve = LinearCurve(8.0), ## Typical plant of 8 MMBTU/MWh heat rate. Piecewise heat rates can be used if needed.
    power_units = UnitSystem.NATURAL_UNITS,
    fuel_cost = 1.0, ## $/MMBTU default fuel cost to start
)
new_thermal_cost = ThermalGenerationCost(;
    variable = new_fuel_curve,
    fixed = old_thermal_cost.fixed,
    start_up = old_thermal_cost.start_up,
    shut_down = old_thermal_cost.shut_down,
)
set_operation_cost!(brighton, new_thermal_cost)

# Now we create a timeseries with random fuel prices. We first grab an existing timeseries:

existing_ts = get_time_series_array(
    SingleTimeSeries,
    first(get_components(PowerLoad, sys)),
    "max_active_power",
)
tstamps = timestamp(existing_ts)

# And add the timeseries with the `set_fuel_cost!` method.

fuel_cost_values = rand(length(tstamps)) .+ 1.0 ## Random fuel cost between 1.0 and 2.0 $/MMBTU
fuel_cost_tarray = TimeArray(tstamps, fuel_cost_values)
fuel_cost_ts = SingleTimeSeries(; name = "fuel_cost", data = fuel_cost_tarray)
set_fuel_cost!(sys, brighton, fuel_cost_ts)

# ## Add a market bid cost to the hydro unit
#
# We again grab the timestamps from an existing time series:

existing_ts = get_time_series_array(
    SingleTimeSeries,
    first(get_components(PowerLoad, sys)),
    "max_active_power",
)
tstamps = timestamp(existing_ts)

# And we add an empty market bid cost to the hydro:

hy = get_component(HydroDispatch, sys, "HydroDispatch")
## Create an empty market bid and set it
hydro_cost = MarketBidCost(;
    no_load_cost = 0.0,
    start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
    shut_down = 0.0,
)
set_operation_cost!(hy, hydro_cost)

# Now we create a time-varying piecewise linear bid cost:

psd1 = PiecewiseStepData([0.0, 600.0], [5.0])
psd2 = PiecewiseStepData([0.0, 300.0, 600.0], [10.0, 20.0])
psd3 = PiecewiseStepData([0.0, 600.0], [500.0])

## Cheap the first 10 hours, moderate next 4 hours, expensive last 34 hours
total_step_data = vcat([psd1 for x in 1:10], [psd2 for x in 1:4], [psd3 for x in 1:34])
mbid_tarray = TimeArray(tstamps, total_step_data)
ts_mbid = SingleTimeSeries(; name = "variable_cost", data = mbid_tarray)

set_variable_cost!(sys, hy, ts_mbid, UnitSystem.NATURAL_UNITS)

# It is also needed to create the initial input time series for market bid. That is the cost at 0 power at each time step. We will use zero for this example.

zero_input = zeros(length(tstamps))
zero_tarray = TimeArray(tstamps, zero_input)
ts_zero = SingleTimeSeries(; name = "variable_cost_initial_input", data = zero_tarray)
set_incremental_initial_input!(sys, hy, ts_zero)

# ## Running the single-stage problem
#
# We first transform the single time series to a 24 hour forecast

transform_single_time_series!(sys, Hour(24), Hour(24))

# And create the necessary templates for the system:

template = ProblemTemplate(
    NetworkModel(
        CopperPlatePowerModel;
        use_slacks = true,
        duals = [CopperPlateBalanceConstraint],
    ),
)
set_device_model!(template, ThermalStandard, ThermalBasicUnitCommitment)
set_device_model!(template, HydroDispatch, HydroDispatchRunOfRiver)
set_device_model!(template, PowerLoad, StaticPowerLoad)

# And then running the decision model:

model = DecisionModel(
    template,
    sys;
    name = "UC_MBCost",
    optimizer = optimizer_with_attributes(
        HiGHS.Optimizer,
    ),
    store_variable_names = true,
    optimizer_solve_log_print = false,
)
build!(model; output_dir = mktempdir())
solve!(model)

# And exploring results we confirm that the hydro is not dispatched when is more expensive, while the dual of the CopperPlate constraint showcase that the system become more expensive at those hours.

res = OptimizationProblemResults(model)
hy_p = read_variable(
    res,
    "ActivePowerVariable__HydroDispatch";
    table_format = TableFormat.WIDE,
);
show(hy_p; allrows = true)

dual_price =
    read_dual(res, "CopperPlateBalanceConstraint__System"; table_format = TableFormat.WIDE);
show(dual_price; allrows = true)
