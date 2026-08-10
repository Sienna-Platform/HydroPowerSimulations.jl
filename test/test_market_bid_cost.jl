# we're including several files from PowerSimulations/test/test_utils.
# those make this work: if things break, look there.
HYDRO_DEVICE_TO_FORMULATION =
    Dict{
        Type{<:Device},
        Union{Type{<:PowerSimulations.AbstractDeviceFormulation}, DeviceModel},
    }(
        HydroDispatch => HydroCommitmentRunOfRiver,
    )

@testset "MBC HydroDispatch: no time series versus constant time series" begin
    sys_no_ts = load_sys_hydro()
    # Keep the constant time-series breakpoints identical to the fixed curve.
    sys_constant_ts = build_sys_hydro(false, false, false; do_override_min_x = false)

    sel = make_selector(PSY.HydroDispatch, "HD1") # hard-coded. make global?
    hd = first(get_components(sel, sys_no_ts))
    @assert get_operation_cost(hd) isa PSY.MarketBidCost
    hd_with_ts = first(get_components(sel, sys_constant_ts))
    mbc = get_operation_cost(hd_with_ts)
    @assert get_incremental_offer_curves(mbc) isa IS.TimeSeriesKey
    test_generic_mbc_equivalence(
        sys_no_ts,
        sys_constant_ts;
        device_to_formulation = HYDRO_DEVICE_TO_FORMULATION,
    )
end

# work-in-progress: focusing on HydroDispatch with RunOfRiver for now.
#=
@testset "MBC HydroTurbine: no time series" begin
    device_to_formulation = Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(
        PSY.HydroTurbine => HydroTurbineEnergyCommitment,
        PSY.HydroReservoir => HydroEnergyModelReservoir,
    )
    sys = build_system(PSITestSystems, "test_RTS_GMLC_sys")
    # replace cost data at HydroTurbine with MarketBidCost
    ht1 = first(get_components(PSY.HydroTurbine, sys))
    add_mbc!(
        sys,
        make_selector(PSY.HydroTurbine, get_name(ht1)),
    )
    # RTS GMLC has the inflow time series attached to the HydroTurbine, but we need it on the reservoir.
    copy_inflow_time_series!(sys)
    # this takes about a minute, rather long for a test case.. is there a smaller system that works?
    run_generic_mbc_prob(sys; device_to_formulation = device_to_formulation)
end=#

# TODO test other device types [e.g. HydroTurbine] and other formulations.
device_models = [HydroCommitmentRunOfRiver, HydroDispatchRunOfRiver]
comp_type = PSY.HydroDispatch
adj = "HydroDispatch"
comp_name = "HD1"
build_func = build_sys_hydro
nonzero_min_gen_cost = false # we assume min gen cost is 0 for hydro.
@testset for device_model in device_models
    device_to_formulation =
        Dict{
            Type{<:Device},
            Union{Type{<:PowerSimulations.AbstractDeviceFormulation}, DeviceModel},
        }(
            comp_type => device_model,
        )
    test_case_to_inputs = Dict(
        "min_gen_cost" => (true, false, false),
        "breakpoints" => (false, true, false),
        "slopes" => (false, false, true),
        "everything" => (nonzero_min_gen_cost, true, true),
    )
    for (test_case, inputs) in test_case_to_inputs
        if test_case == "min_gen_cost" && !nonzero_min_gen_cost
            # skip because min gen cost must be zero.
            continue
        end
        baseline = build_func(false, false, false)
        varying = build_func(inputs...)
        @testset "MarketBidCost $(adj) with time varying $(test_case)" begin
            baseline = build_func(false, false, false)
            varying = build_func(inputs...)
            set_name!(baseline, "baseline_$(test_case)")
            set_name!(varying, "varying_$(test_case)")
            for use_simulation in (false, true)
                in_memory_store_opts = use_simulation ? [false, true] : [false]
                for in_memory_store in in_memory_store_opts
                    decisions1, decisions2 =
                        run_mbc_obj_fun_test(
                            baseline,
                            varying,
                            comp_name,
                            comp_type;
                            has_initial_input = nonzero_min_gen_cost,
                            simulation = use_simulation,
                            in_memory_store = in_memory_store,
                            device_to_formulation = device_to_formulation,
                        )
                    if !all(isapprox.(decisions1, decisions2))
                        @show decisions1
                        @show decisions2
                    end
                    @assert all(approx_geq_1.(decisions1))
                end
            end
        end
    end

    @testset "MarketBidCost $(adj) with variable number of tranches" begin
        baseline = build_func(false, true, true)
        set_name!(baseline, "baseline_tranches")
        variable_tranches = build_func(false, true, true; create_extra_tranches = true)
        set_name!(variable_tranches, "variable_tranches")
        test_generic_mbc_equivalence(
            baseline,
            variable_tranches;
            filename = nothing,
            device_to_formulation = device_to_formulation,
        )
    end
end

@testset "MarketBidCost thermal and hydro agree" begin
    sys = load_sys_incr()
    replace_with_hydro_dispatch!(sys, get_component(SEL_INCR, sys))
    remove_thermal_mbcs!(sys)
    hd1 = get_component(PSY.HydroDispatch, sys, "HD1")
    zero_out_startup_shutdown_costs!(hd1)
    set_name!(sys, "sys_hydro")

    sys_thermal = load_sys_incr()
    remove_thermal_mbcs!(sys_thermal)
    unit1 = get_component(SEL_INCR, sys_thermal)
    transfer_mbc!(unit1, hd1, sys_thermal)
    set_name!(sys_thermal, "sys_thermal")
    test_generic_mbc_equivalence(
        sys,
        sys_thermal;
        device_to_formulation = HYDRO_DEVICE_TO_FORMULATION,
    )
end
