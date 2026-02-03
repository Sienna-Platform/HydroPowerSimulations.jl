function replace_with_hydro_dispatch!(
    sys::PSY.System,
    unit1::PSY.Generator,
)
    hydro = PSY.HydroDispatch(;
        name = "HD1",
        available = true,
        bus = get_bus(unit1),
        active_power = get_active_power(unit1),
        reactive_power = get_reactive_power(unit1),
        rating = get_rating(unit1),
        prime_mover_type = PSY.PrimeMovers.HA,
        active_power_limits = get_active_power_limits(unit1),
        reactive_power_limits = get_reactive_power_limits(unit1),
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = get_base_power(unit1),
        status = true,
        operation_cost = get_operation_cost(unit1),
    )
    add_component!(sys, hydro)
    transfer_mbc!(hydro, unit1, sys)
    remove_component!(sys, unit1)

    # add a max_active_power time series to the component
    load = first(PSY.get_components(PSY.PowerLoad, sys))
    load_ts = get_time_series(Deterministic, load, "max_active_power")
    num_windows = length(get_data(load_ts))
    num_forecast_steps =
        floor(Int, get_horizon(load_ts) / get_interval(load_ts))
    total_steps = num_windows + num_forecast_steps - 1
    dates = range(
        get_initial_timestamp(load_ts);
        step = get_interval(load_ts),
        length = total_steps,
    )
    magnitude = get_active_power_limits(unit1).max
    hydro_data = fill(magnitude, total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    return hydro
end

# currently unused.
function replace_with_hydro_turbine!(
    sys::PSY.System,
    unit1::PSY.Generator,
)
    hydro = PSY.HydroTurbine(;
        name = "HT1",
        available = true,
        bus = get_bus(unit1),
        active_power = get_active_power(unit1),
        reactive_power = get_reactive_power(unit1),
        rating = get_rating(unit1),
        active_power_limits = get_active_power_limits(unit1),
        reactive_power_limits = get_reactive_power_limits(unit1),
        base_power = get_base_power(unit1),
        operation_cost = get_operation_cost(unit1),
        powerhouse_elevation = 100.0,
    )
    add_component!(sys, hydro)
    transfer_mbc!(hydro, unit1, sys)
    remove_component!(sys, unit1)

    reservoir = PSY.HydroReservoir(;
        name = "R1",
        available = true,
        storage_level_limits = (min = 0.0, max = 100.0),
        initial_level = 50.0,
        inflow = 5.0,
    )
    reservoirs = get_reservoirs(hydro)
    push!(reservoirs, PSY.ReservoirRef("R1"))
    # add a max_active_power time series to the component
    load = first(PSY.get_components(PSY.PowerLoad, sys))
    load_ts = get_time_series(Deterministic, load, "max_active_power")
    num_windows = length(get_data(load_ts))
    num_forecast_steps =
        floor(Int, get_horizon(load_ts) / get_interval(load_ts))
    total_steps = num_windows + num_forecast_steps - 1
    dates = range(
        get_initial_timestamp(load_ts);
        step = get_interval(load_ts),
        length = total_steps,
    )
    magnitude = get_active_power_limits(unit1).max
    hydro_data = fill(magnitude, total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    # add a reservoir to the hydro turbine
    #=
    res_capacity = 10.0 * magnitude
    reservoir = PSY.Reservoir(;
        name = "R1",
        max_storage = res_capacity,
        min_storage = 0.0,
        initial_storage = 0.5 * res_capacity,
        max_inflow = 2.0 * magnitude,
    )=#
end

# functions for adjusting power/cost curves and manipulating time series
"""Moves inflow time series from each turbine to its upstream reservoir."""
function copy_inflow_time_series!(sys)
    for turb in get_components(HydroTurbine, sys)
        res = only(get_connected_head_reservoirs(sys, turb))
        name_map = Dict((PSY.get_name(turb), "inflow") => "inflow")
        copy_time_series!(res, turb; name_mapping = name_map)
    end
end

function load_sys_hydro()
    sys = load_sys_incr()
    replace_with_hydro_dispatch!(sys, get_component(SEL_INCR, sys))
    hd1 = get_component(PSY.HydroDispatch, sys, "HD1")
    zero_out_startup_shutdown_costs!(hd1)
    # zero_out_thermal_costs!(sys)
    # set the cost at minimum generation to 0.0.
    op_cost = get_operation_cost(hd1)
    old_curve = get_value_curve(get_incremental_offer_curves(op_cost))
    new_curve = PowerSystems.PiecewiseIncrementalCurve(
        0.0,
        get_x_coords(old_curve),
        get_slopes(old_curve),
    )
    set_incremental_offer_curves!(op_cost, CostCurve(new_curve))
    remove_thermal_mbcs!(sys)
    return sys
end

function build_sys_hydro(
    initial_varies::Bool,
    breakpoints_vary::Bool,
    slopes_vary::Bool;
    modify_baseline_pwl = nothing,
    do_override_min_x = true,
    create_extra_tranches = false,
    initial_input_names_vary = false,
    variable_cost_names_vary = false,
)
    sys = load_sys_hydro()
    @assert !initial_varies "Hydro components should have min gen cost of 0.0"

    extend_mbc!(
        sys,
        make_selector(PSY.HydroDispatch, "HD1"), ;
        initial_varies = initial_varies,
        breakpoints_vary = breakpoints_vary,
        slopes_vary = slopes_vary,
        modify_baseline_pwl = modify_baseline_pwl,
        do_override_min_x = do_override_min_x,
        create_extra_tranches = create_extra_tranches,
        initial_input_names_vary = initial_input_names_vary,
        variable_cost_names_vary = variable_cost_names_vary,
    )
    return sys
end

function build_hydro_with_both_pump_and_turbine()
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    head_res = get_component(HydroReservoir, sys, "HydroEnergyReservoir__reservoir")
    turbine = only(get_components(HydroTurbine, sys))
    set_active_power_limits!(turbine, (min = 0.3, max = 7.0))
    tail_res = HydroReservoir(;
        name = "Reservoir_tail",
        available = true,
        storage_level_limits = (min = 0.0, max = 50000.0), # MWh,
        initial_level = 0.5,
        spillage_limits = nothing,
        inflow = 0.0,
        outflow = 0.0,
        level_targets = 0.0,
        intake_elevation = 0.0,
        head_to_volume_factor = LinearCurve(0.0),
    )
    add_component!(sys, tail_res)
    copy_time_series!(tail_res, head_res)

    hpump = HydroPumpTurbine(;
        name = "PumpTurbine",
        available = true,
        bus = turbine.bus,
        active_power = 0.0,
        reactive_power = 0.0,
        rating = 4.0,
        active_power_limits = (min = 0.1, max = 4.0),
        reactive_power_limits = nothing,
        active_power_limits_pump = (min = 0.2, max = 4.0),
        outflow_limits = nothing,
        powerhouse_elevation = 0.0,
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = 100.0,
        active_power_pump = 0.0,
        efficiency = (turbine = 0.93, pump = 0.93),
    )

    add_component!(sys, hpump)

    set_downstream_turbines!(head_res, [turbine, hpump])
    set_upstream_turbines!(tail_res, [hpump])
    return sys
end

function run_fixed_forced_outage_sim_with_timeseries(;
    sys,
    networks,
    optimizers,
    outage_status_timeseries,
    device_type,
    device_names,
    renewable_formulation,
)
    sys_em = deepcopy(sys)
    sys_d1 = deepcopy(sys)
    sys_d2 = deepcopy(sys)
    transform_single_time_series!(sys_d1, Day(2), Day(1))
    transform_single_time_series!(sys_d2, Hour(4), Hour(1))
    event_model = EventModel(
        FixedForcedOutage,
        PSI.ContinuousCondition();
        timeseries_mapping = Dict(
            :outage_status => "outage_profile_1",
        ),
    )
    template_d1 = get_template_basic_uc_simulation()
    #pop!(PSI.get_device_models(template_d1), :HydroTurbine)
    pop!(PSI.get_device_models(template_d1), :HydroReservoir)
    set_network_model!(template_d1, NetworkModel(networks[1]))
    template_d2 = get_template_basic_uc_simulation()
    #pop!(PSI.get_device_models(template_d2), :HydroTurbine)
    pop!(PSI.get_device_models(template_d2), :HydroReservoir)
    set_network_model!(template_d2, NetworkModel(networks[2]))
    template_em = get_template_nomin_ed_simulation(networks[3])
    #pop!(PSI.get_device_models(template_em), :HydroTurbine)
    pop!(PSI.get_device_models(template_em), :HydroReservoir)

    set_device_model!(template_d1, RenewableDispatch, renewable_formulation)
    set_device_model!(template_d2, RenewableDispatch, renewable_formulation)
    set_device_model!(template_em, RenewableDispatch, renewable_formulation)
    set_device_model!(template_em, ThermalStandard, ThermalBasicDispatch)
    set_service_model!(template_d1, ServiceModel(ConstantReserve{ReserveUp}, RangeReserve))
    set_service_model!(template_d2, ServiceModel(ConstantReserve{ReserveUp}, RangeReserve))
    set_device_model!(template_em, InterruptiblePowerLoad, PowerLoadDispatch)
    set_device_model!(template_d1, InterruptiblePowerLoad, PowerLoadDispatch)
    set_device_model!(template_d2, InterruptiblePowerLoad, PowerLoadDispatch)
    set_device_model!(template_em, HydroDispatch, HydroDispatchRunOfRiver)
    set_device_model!(template_d1, HydroDispatch, HydroDispatchRunOfRiver)
    set_device_model!(template_d2, HydroDispatch, HydroDispatchRunOfRiver)
    pump_model = DeviceModel(
        HydroPumpTurbine,
        HydroPumpEnergyDispatch;
        attributes = Dict{String, Any}("energy_target" => true),
    )
    set_device_model!(template_em, pump_model)
    set_device_model!(template_d1, pump_model)
    set_device_model!(template_d2, pump_model)

    set_device_model!(template_d1, Line, StaticBranch)
    set_device_model!(template_d2, Line, StaticBranch)
    set_device_model!(template_em, Line, StaticBranch)

    for sys in [sys_d1, sys_d2, sys_em]
        for name in device_names
            g = get_component(device_type, sys, name)
            transition_data = PSY.FixedForcedOutage(;
                outage_status = 0.0,
            )
            add_supplemental_attribute!(sys, g, transition_data)
            PSY.add_time_series!(
                sys,
                transition_data,
                PSY.SingleTimeSeries("outage_profile_1", outage_status_timeseries),
            )
        end
    end

    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_d1,
                sys_d1;
                name = "D1",
                initialize_model = false,
                optimizer = optimizers[1],
            ),
            DecisionModel(
                template_d2,
                sys_d2;
                name = "D2",
                initialize_model = false,
                optimizer = optimizers[2],
                store_variable_names = true,
            ),
        ],
        emulation_model = EmulationModel(
            template_em,
            sys_em;
            name = "EM",
            optimizer = optimizers[3],
            calculate_conflict = true,
            store_variable_names = true,
        ),
    )
    sequence = SimulationSequence(;
        models = models,
        ini_cond_chronology = InterProblemChronology(),
        feedforwards = Dict(
            "EM" => [# This FeedForward will force the commitment to be kept in the emulator
                SemiContinuousFeedforward(;
                    component_type = ThermalStandard,
                    source = OnVariable,
                    affected_values = [ActivePowerVariable],
                ),
            ],
        ),
        events = [event_model],
    )

    sim = Simulation(;
        name = "no_cache",
        steps = 1,
        models = models,
        sequence = sequence,
        simulation_folder = mktempdir(; cleanup = true),
    )
    build_out = build!(sim; console_level = Logging.Error)
    @test build_out == PSI.SimulationBuildStatus.BUILT
    execute_out = execute!(sim; in_memory = true)
    @test execute_out == PSI.RunStatus.SUCCESSFULLY_FINALIZED
    results = SimulationResults(sim; ignore_status = true)
    return sim, results
end
