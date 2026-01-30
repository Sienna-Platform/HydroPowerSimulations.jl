#########################################
#### RESERVOIR BUDGET DISPATCH TESTS ####
#########################################
@testset "Hydro DCPLossLess with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 120, 0, 25, 24, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        use_slacks = true,
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 192, 0, 49, 48, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end

###########################################
#### RESERVOIR BUDGET COMMITMENT TESTS ####
###########################################

@testset "Hydro DCPLossLess with HydroTurbineEnergyCommitment and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 25, 24, 24, true)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyCommitment and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 168, 0, 49, 48, 24, true)
    psi_checkobjfun_test(model, GAEVF)
end

#########################################
#### RESERVOIR TARGET DISPATCH TESTS ####
#########################################

@testset "Hydro DCPLossLess with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with target) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => true,
            "hydro_budget" => false,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 120, 0, 24, 24, 25, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with target) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => true,
            "hydro_budget" => false,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 48, 48, 25, false)
    psi_checkobjfun_test(model, GAEVF)
end

#########################################
########### RUN OF RIVER TESTS ##########
#########################################

@testset "Solving ED Hydro System using Dispatch Run of River" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")
    networks = [ACPPowerModel, DCPPowerModel]

    test_results =
        Dict{Any, Float64}(ACPPowerModel => 136581.41, DCPPowerModel => 135382.37)

    for net in networks
        @testset "HydroRoR ED model $(net)" begin
            template = get_thermal_dispatch_template_network(net)
            set_device_model!(template, HydroDispatch, HydroDispatchRunOfRiver)
            ED = DecisionModel(
                EconomicDispatchProblem,
                template,
                sys;
                optimizer = ipopt_optimizer,
            )
            @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                  PSI.ModelBuildStatus.BUILT
            psi_checksolve_test(
                ED,
                [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                test_results[net],
                1000,
            )
        end
    end
end

@testset "Solving ED Hydro System using Commitment Run of River" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")
    net = CopperPlatePowerModel

    template = get_thermal_dispatch_template_network(net)
    set_device_model!(template, HydroDispatch, HydroCommitmentRunOfRiver)

    @testset "HydroRoR ED model $(net)" begin
        ED =
            DecisionModel(UnitCommitmentProblem, template, sys; optimizer = HiGHS_optimizer)
        @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
              PSI.ModelBuildStatus.BUILT
        psi_checksolve_test(ED, [MOI.OPTIMAL, MOI.LOCALLY_SOLVED], 135382.38, 1000)
    end
end

@testset "Test Reserves from Hydro with RunOfRiver" begin
    template = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroTurbine, HydroDispatchRunOfRiver)
    set_service_model!(
        template,
        ServiceModel(VariableReserve{ReserveUp}, RangeReserve, "Reserve5"),
    )
    set_service_model!(
        template,
        ServiceModel(VariableReserve{ReserveDown}, RangeReserve, "Reserve6"),
    )
    set_service_model!(
        template,
        ServiceModel(ReserveDemandCurve{ReserveUp}, StepwiseCostReserve, "ORDC1"),
    )

    c_sys5_hyd = PSB.build_system(
        PSITestSystems,
        "c_sys5_hyd";
        add_reserves = true,
        force_build = true,
    )
    model = DecisionModel(template, c_sys5_hyd)
    @test build!(model; output_dir = mktempdir(; cleanup = true)) ==
          PSI.ModelBuildStatus.BUILT
    # The value of this test needs to be revised
    # moi_tests(model, 240, 0, 48, 96, 72, false)
end

#########################################
###### RESERVOIR SYSTEM TESTS ###########
#########################################

@testset "Solving ED Hydro System using Dispatch with Reservoir" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    networks = [ACPPowerModel, DCPPowerModel]
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    models = [
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => true,
                "hydro_budget" => false,
            ),
        ),
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => false,
                "hydro_budget" => true,
            ),
        ),
    ]
    test_results = Dict{Any, Float64}(
        (ACPPowerModel, HydroEnergyModelReservoir, true) => 136296.0,
        (DCPPowerModel, HydroEnergyModelReservoir, true) => 135404.0,
        (ACPPowerModel, HydroEnergyModelReservoir, false) => 131305.0,
        (DCPPowerModel, HydroEnergyModelReservoir, false) => 130479.0,
    )

    for net in networks
        for reservoir_model in models
            formulation = PSI.get_formulation(reservoir_model)
            attrs = PSI.get_attributes(reservoir_model)
            energy_target = get(attrs, "energy_target", false)
            hydro_budget = get(attrs, "hydro_budget", false)
            @testset "$(formulation) with energy_target: $energy_target, and hydro_budget: $hydro_budget, ED model on $(net)" begin
                template = get_thermal_dispatch_template_network(net)
                set_device_model!(template, turbine_model)
                set_device_model!(template, reservoir_model)

                ED = DecisionModel(
                    EconomicDispatchProblem,
                    template,
                    sys;
                    optimizer = ipopt_optimizer,
                )
                @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                      PSI.ModelBuildStatus.BUILT
                psi_checksolve_test(
                    ED,
                    [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                    test_results[(net, formulation, energy_target)],
                    1000,
                )
            end
        end
    end
end

@testset "Solving ED Hydro System using Commitment with Reservoir" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    net = DCPPowerModel
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    models = [
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => true,
                "hydro_budget" => false,
            ),
        ),
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => false,
                "hydro_budget" => true,
            ),
        ),
    ]
    test_results = Dict{Any, Float64}(
        (DCPPowerModel, HydroEnergyModelReservoir, true) => 141061.0,
        (DCPPowerModel, HydroEnergyModelReservoir, false) => 144109.0,
    )

    for reservoir_model in models
        formulation = PSI.get_formulation(reservoir_model)
        attrs = PSI.get_attributes(reservoir_model)
        energy_target = get(attrs, "energy_target", false)
        hydro_budget = get(attrs, "hydro_budget", false)
        @testset "$(formulation) with energy_target: $energy_target, and hydro_budget: $hydro_budget, ED model on $(net)" begin
            template = get_thermal_dispatch_template_network(net)
            set_device_model!(template, turbine_model)
            set_device_model!(template, reservoir_model)

            ED = DecisionModel(
                EconomicDispatchProblem,
                template,
                sys;
                optimizer = HiGHS_optimizer,
            )
            @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                  PSI.ModelBuildStatus.BUILT
            psi_checksolve_test(
                ED,
                [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                test_results[(net, formulation, energy_target)],
                10000, #update to 10k to handle the difference in Mac and Ubuntu. Likely a HiGHS issue.
            )
        end
    end
end

########################################################
####### Hydro DISPATCH RUN OF RIVER BUDGET TEST ########
########################################################
@testset "Test Hydro Dispatch Run Of River Formulations " begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
        use_slacks = true, attributes = Dict("hydro_budget_interval" => Hour(24)))

    sys = PSB.build_system(PSITestSystems, "c_sys5_hy"; add_single_time_series = true)
    hy = only(get_components(HydroDispatch, sys))
    max_power = get_max_active_power(hy)
    resolution = Dates.Hour(1)
    tstamp = range(DateTime("2024-01-01T00:00:00"); step = resolution, length = 48)
    data = ones(length(tstamp)) / (get_base_power(sys) * max_power)
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(sys, hy, ts)
    transform_single_time_series!(sys, Hour(24), Hour(24))

    model = DecisionModel(MockOperationProblem, CopperPlatePowerModel, sys)
    mock_construct_device!(model, device_model)
    moi_tests(model, 48, 0, 50, 24, 0, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Solve Hydro Dispatch Run Of River" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy"; add_single_time_series = true)

    hydro_budget = 24
    eps = 1e-6

    hy = only(get_components(HydroDispatch, c_sys5_hy))
    max_power = get_max_active_power(hy)

    tstamp = range(DateTime("2024-01-01T00:00:00"); step = Dates.Hour(1), length = 48)
    data = ones(length(tstamp)) / (get_base_power(c_sys5_hy) * max_power)
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(c_sys5_hy, first(get_components(HydroDispatch, c_sys5_hy)), ts)
    #remove_time_series!(c_sys5_hy, Deterministic)
    transform_single_time_series!(c_sys5_hy, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)
    set_device_model!(
        template_uc,
        DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
            attributes = Dict("hydro_budget_interval" => Hour(hydro_budget))),
    )
    model = DecisionModel(
        template_uc,
        c_sys5_hy;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)
    df = read_variable(res, "ActivePowerVariable__HydroDispatch")
    hydro_power_sum =
        sum(df[!, :value])

    @test abs(hydro_power_sum - hydro_budget) <= eps
end

@testset "Make Hydro Dispatch Run Of River with Reserves" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(
        PSITestSystems,
        "c_sys5_hy";
        add_single_time_series = true,
        add_reserves = true,
    )

    # Fix reserve parameters
    reg_up = only(get_components(VariableReserve{ReserveUp}, c_sys5_hy))
    reg_dn = only(get_components(VariableReserve{ReserveDown}, c_sys5_hy))
    set_deployed_fraction!(reg_up, 0.0)
    set_deployed_fraction!(reg_dn, 0.0)
    set_requirement!(reg_up, 0.01)
    set_requirement!(reg_dn, 0.01)

    hydro_budget = 24
    eps = 1e-6

    hy = only(get_components(HydroDispatch, c_sys5_hy))

    # Update Service allocation
    # Remove reg up from hydro, but leave reg dn
    remove_service!(hy, reg_up)

    # Add reg up to thermals
    for th in get_components(ThermalStandard, c_sys5_hy)
        add_service!(th, reg_up, c_sys5_hy)
    end

    max_power = get_max_active_power(hy)
    tstamp = range(DateTime("2024-01-01T00:00:00"); step = Dates.Hour(1), length = 48)
    data = ones(length(tstamp)) / (get_base_power(c_sys5_hy) * max_power)
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(c_sys5_hy, first(get_components(HydroDispatch, c_sys5_hy)), ts)

    ## add extra hydro budget
    hy_copy = HydroDispatch(;
        name = "HydroDispatchCopy",
        available = get_available(hy),
        bus = get_bus(hy),
        active_power = get_active_power(hy),
        reactive_power = get_reactive_power(hy),
        rating = get_rating(hy),
        prime_mover_type = get_prime_mover_type(hy),
        active_power_limits = get_active_power_limits(hy),
        reactive_power_limits = get_reactive_power_limits(hy),
        ramp_limits = get_ramp_limits(hy),
        time_limits = get_time_limits(hy),
        base_power = get_base_power(hy),
    )
    add_component!(c_sys5_hy, hy_copy)
    copy_time_series!(hy_copy, hy)

    transform_single_time_series!(c_sys5_hy, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)
    set_device_model!(
        template_uc,
        DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
            attributes = Dict("hydro_budget_interval" => Hour(hydro_budget))),
    )
    set_service_model!(template_uc, VariableReserve{ReserveUp}, RangeReserve)
    set_service_model!(template_uc, VariableReserve{ReserveDown}, RangeReserve)
    model = DecisionModel(
        template_uc,
        c_sys5_hy;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end

################################################
####### Hydro PUMP ENERGY DISPATCH TEST ########
################################################
@testset "Test Hydro Pump Energy Dispatch Formulations " begin
    device_model = PSI.DeviceModel(
        HydroPumpTurbine,
        HPS.HydroPumpEnergyDispatch;
        attributes = Dict{String, Any}(
            "reservation" => true,
            "energy_target" => true,
        ),
    )

    c_sys5_bat =
        PSB.build_system(
            PSITestSystems,
            "c_sys5_hydro_pump_energy";
            add_reserves = true,
            add_single_time_series = true,
        )

    hy_pump = first(PSY.get_components(HydroPumpTurbine, c_sys5_bat))
    transform_single_time_series!(c_sys5_bat, Hour(24), Hour(24))

    model = DecisionModel(MockOperationProblem, CopperPlatePowerModel, c_sys5_bat)
    mock_construct_device!(model, device_model)
    moi_tests(model, 72, 0, 48, 24, 0, true)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Test Hydro Pump Energy Dispatch Formulations 2" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_bat =
        PSB.build_system(
            PSITestSystems,
            "c_sys5_hydro_pump_energy";
            add_reserves = true,
            add_single_time_series = true,
        )

    hy_pump = first(PSY.get_components(HydroPumpTurbine, c_sys5_bat))

    transform_single_time_series!(c_sys5_bat, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)
    set_device_model!(
        template_uc,
        DeviceModel(
            HydroPumpTurbine,
            HPS.HydroPumpEnergyDispatch;
            attributes = Dict{String, Any}(
                "reservation" => true,
                "energy_target" => true,
            ),
        ),
    )

    model = DecisionModel(
        template_uc,
        c_sys5_bat;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end

#########################################
######## HydroBlock model Tests #########
#########################################

@testset "Test Hydro Block Optimization Formulation" begin
    output_dir = mktempdir(; cleanup = true)
    modeling_horizon = 3 * 24 * 1

    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    res = first(PSY.get_components(HydroReservoir, sys))

    set_head_to_volume_factor!(res, LinearCurve(1.0))
    set_storage_level_limits!(res, (min = 4000, max = 6000))
    set_level_targets!(res, 0.9)
    template_ed = ProblemTemplate(
        NetworkModel(
            CopperPlatePowerModel;
        ),
    )

    set_device_model!(template_ed, ThermalStandard, ThermalBasicDispatch)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroReservoir, HydroWaterFactorModel)
    set_device_model!(template_ed, HydroTurbine, HydroWaterFactorModel)

    model = DecisionModel(
        template_ed,
        sys;
        name = "ED",
        optimizer = Ipopt_optimizer,
        optimizer_solve_log_print = true,
        store_variable_names = true,
        system_to_file = true,
        horizon = Hour(24),
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; optimizer = Ipopt_optimizer, output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    results = OptimizationProblemResults(model)
    power_load = read_parameter(results, "ActivePowerTimeSeriesParameter__PowerLoad")
    reservoir_inflow = read_parameter(results, "InflowTimeSeriesParameter__HydroReservoir")

    water_spillage = read_variable(results, "WaterSpillageVariable__HydroReservoir")
    thermal_power = read_variable(results, "ActivePowerVariable__ThermalStandard")
    hydro_power = read_variable(results, "ActivePowerVariable__HydroTurbine")

    turbine_output = read_aux_variable(results, "HydroEnergyOutput__HydroTurbine")
    reservoir_volume =
        read_variable(results, "HydroReservoirVolumeVariable__HydroReservoir")

    var = read_variable(
        results,
        "HydroReservoirVolumeVariable__HydroReservoir";
        table_format = TableFormat.WIDE,
    )

    # check the second step is equal to the first step + dispatch
end

################################################
######## HydroWaterModelReservoir TEST #########
################################################

@testset "Solve HydroWaterModelReservoir" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_head")
    reservoir = only(get_components(HydroReservoir, c_sys5_hy))
    hydro_inflow_ts = get_time_series_array(Deterministic, reservoir, "inflow")

    template = ProblemTemplate()
    set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)

    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)

    model = DecisionModel(
        template,
        c_sys5_hy;
        optimizer = Ipopt_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)

    moi_tests(model, 288, 0, 168, 168, 72, false)
    psi_checkobjfun_test(model, AffExpr)

    df_outflow = read_expression(res, "TotalHydroFlowRateTurbineOutgoing__HydroTurbine")
    hydro_vol_df =
        read_variables(res, [(HydroReservoirVolumeVariable, HydroReservoir)])["HydroReservoirVolumeVariable__HydroReservoir"]
    hydro_head_df =
        read_variables(res, [(HydroReservoirHeadVariable, HydroReservoir)])["HydroReservoirHeadVariable__HydroReservoir"]
    hydro_spillage_df =
        read_variables(res, [(WaterSpillageVariable, HydroReservoir)])["WaterSpillageVariable__HydroReservoir"]
    hydro_inflow_df =
        read_parameters(res, [(InflowTimeSeriesParameter, HydroReservoir)])["InflowTimeSeriesParameter__HydroReservoir"]

    total_inflow = sum(values(hydro_inflow_ts))
    total_outflow = sum(df_outflow[!, :value])
    total_spillage = sum(hydro_spillage_df[!, :value])

    calculated_vf =
        (hydro_vol_df[1, :value]) +
        ((total_inflow - total_outflow - total_spillage) * 3600 * 1e-9)

    @test abs(calculated_vf - hydro_vol_df[end, :value]) <= 1e-4

    psi_checksolve_test(
        model,
        [MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED],
        210949.49,
        1000,
    )
end

@testset "Solve HydroWaterModelReservoir with Budget" begin
    sys = PSB.build_system(
        PSITestSystems,
        "c_sys5_hy_turbine_head";
        force_build = true,
        add_single_time_series = true,
    )
    res = only(get_components(HydroReservoir, sys))
    inflow_array = get_time_series_array(SingleTimeSeries, res, "inflow")
    tstamp = timestamp(inflow_array)
    vals = values(inflow_array)
    budget_array = TimeArray(tstamp, vals .* 0.5)
    budget_ts = SingleTimeSeries("hydro_budget", budget_array)
    add_time_series!(sys, res, budget_ts)
    transform_single_time_series!(sys, Hour(24), Hour(24))

    template = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroTurbine, HydroTurbineWaterLinearDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroWaterModelReservoir;
        attributes = Dict("hydro_target" => false, "hydro_budget" => true),
    )
    set_device_model!(template, reservoir_model)

    model = DecisionModel(
        template,
        sys;
        name = "UC",
        optimizer = HiGHS_optimizer,
        system_to_file = false,
        store_variable_names = true,
        optimizer_solve_log_print = false,
    )
    @test build!(model; output_dir = mktempdir()) == PSI.ModelBuildStatus.BUILT
    @test solve!(model) == IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    sol = OptimizationProblemResults(model)
    flow = read_expression(sol, "TotalHydroFlowRateReservoirOutgoing__HydroReservoir")[
        !,
        "value",
    ]
    @test sum(flow) <= sum(vals) / 4.0
end

@testset "Solve HydroWaterModelReservoir with Target" begin
    sys = PSB.build_system(
        PSITestSystems,
        "c_sys5_hy_turbine_head";
        force_build = true,
        add_single_time_series = true,
    )
    res = only(get_components(HydroReservoir, sys))
    hydro_cost = HydroReservoirCost(1e5, 0.0, 0.0)
    set_operation_cost!(res, hydro_cost)
    inflow_array = get_time_series_array(SingleTimeSeries, res, "inflow")
    tstamp = timestamp(inflow_array)
    vals = values(inflow_array)
    head_array = TimeArray(tstamp, 490.0 * ones(length(vals)))
    target_ts = SingleTimeSeries("hydro_target", head_array)
    add_time_series!(sys, res, target_ts)
    transform_single_time_series!(sys, Hour(24), Hour(24))

    template = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroTurbine, HydroTurbineWaterLinearDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroWaterModelReservoir;
        attributes = Dict("hydro_target" => true, "hydro_budget" => false),
    )
    set_device_model!(template, reservoir_model)

    model = DecisionModel(
        template,
        sys;
        name = "UC",
        optimizer = HiGHS_optimizer,
        system_to_file = false,
        store_variable_names = true,
        optimizer_solve_log_print = false,
    )
    @test build!(model; output_dir = mktempdir()) == PSI.ModelBuildStatus.BUILT
    @test solve!(model) == IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    sol = OptimizationProblemResults(model)
    head = read_variable(sol, "HydroReservoirHeadVariable__HydroReservoir")[!, "value"]
    @test head[24] >= 490
end

#####################################################
######## HydroWaterModelReservoir Cascading #########
#####################################################

@testset "Solve Cascading HydroWaterModelReservoir" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy_cascading_turbine_head")

    template = ProblemTemplate()
    set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)

    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)

    model = DecisionModel(
        template,
        c_sys5_hy;
        optimizer = Ipopt_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)

    moi_tests(model, 504, 0, 216, 216, 120, false)
    psi_checkobjfun_test(model, AffExpr)
end

@testset "Solve Cascading HydroEnergyModelReservoir" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy_cascading_turbine_head")

    template = ProblemTemplate()
    set_device_model!(template, HydroTurbine, HydroTurbineEnergyDispatch)
    set_device_model!(template, HydroReservoir, HydroEnergyModelReservoir)

    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)

    model = DecisionModel(
        template,
        c_sys5_hy;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)

    moi_tests(model, 360, 0, 168, 168, 72, false)
    psi_checkobjfun_test(model, AffExpr)
end
