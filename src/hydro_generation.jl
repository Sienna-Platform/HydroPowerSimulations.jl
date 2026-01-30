#! format: off
# These methods are defined in PowerSimulations
PSI.requires_initialization(::AbstractHydroReservoirFormulation) = false
PSI.requires_initialization(::AbstractHydroUnitCommitment) = true

PSI.get_variable_multiplier(_, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = 1.0
PSI.get_variable_multiplier(::ActivePowerPumpVariable, ::Type{<:PSY.HydroPumpTurbine}, ::AbstractHydroPumpFormulation) = -1.0
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = PSI.ActivePowerRangeExpressionUB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = PSI.ActivePowerRangeExpressionLB

########################### PSI.ActivePowerVariable, HydroGen #################################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = false
PSI.get_variable_warm_start_value(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).min
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroUnitCommitment) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).max

############## PSI.ReactivePowerVariable, HydroGen ####################
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroDispatchFormulation) = false
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroUnitCommitment) = false
PSI.get_variable_warm_start_value(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.get_variable_lower_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).min
PSI.get_variable_upper_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).max

############## PSI.EnergyVariable, HydroGen ####################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.EnergyVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_warm_start_value(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d)
PSI.get_variable_lower_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d)

########################### PSI.ActivePowerInVariable, HydroGen #################################
PSI.get_variable_binary(::PSI.ActivePowerInVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = nothing
PSI.get_variable_multiplier(::PSI.ActivePowerInVariable, d::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = -1.0

########################### PSI.ActivePowerOutVariable, HydroGen #################################
PSI.get_variable_binary(::PSI.ActivePowerOutVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = nothing
PSI.get_variable_multiplier(::PSI.ActivePowerOutVariable, d::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = 1.0

############## PSI.OnVariable, HydroGen ####################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.OnVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = true
PSI.get_variable_binary(::PSI.OnVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroUnitCommitment) = true
PSI.get_variable_warm_start_value(::PSI.OnVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d) > 0 ? 1.0 : 0.0

############## WaterSpillageVariable, HydroGen ####################
PSI.get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroGen, ::AbstractHydroFormulation) = 0.0
PSI.get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroReservoirFormulation) = false
function PSI.get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)
   spillage_limits = PSY.get_spillage_limits(d)
   if typeof(spillage_limits) <: PSY.MinMax
       return PSY.get_spillage_limits(d).min
   end
   return 0.0
end
function PSI.get_variable_upper_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)
    spillage_limits = PSY.get_spillage_limits(d)
    if typeof(spillage_limits) <: PSY.MinMax
        return PSY.get_spillage_limits(d).max
    end
    return nothing
end

############## PSI.ReservationVariable, HydroGen ####################
PSI.get_variable_binary(::PSI.ReservationVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = true

############## EnergyShortageVariable, HydroGen ####################
PSI.get_variable_binary(::HydroEnergyShortageVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::HydroEnergyShortageVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyShortageVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d)
PSI.get_variable_lower_bound(::HydroEnergyShortageVariable, d::PSY.HydroDispatch, ::HydroDispatchRunOfRiverBudget) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyShortageVariable, d::PSY.HydroDispatch, ::HydroDispatchRunOfRiverBudget) = nothing

############## HydroEnergySurplusVariable, HydroGen ####################
PSI.get_variable_binary(::HydroEnergySurplusVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_upper_bound(::HydroEnergySurplusVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_lower_bound(::HydroEnergySurplusVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = - PSY.get_storage_capacity(d)

############## HydroReservoir ####################

PSI.get_variable_binary(::PSI.EnergyVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
PSI.get_variable_binary(::HydroEnergyShortageVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
PSI.get_variable_binary(::HydroEnergySurplusVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::PSI.EnergyVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).min / PSY.get_system_base_power(d)
PSI.get_variable_upper_bound(::PSI.EnergyVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).max / PSY.get_system_base_power(d)

############## HydroTurbine ####################
PSI.get_variable_binary(::HydroTurbineFlowRateVariable, ::Type{<:PSY.HydroTurbine}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::HydroTurbineFlowRateVariable, d::PSY.HydroTurbine, ::AbstractHydroFormulation) = isnothing(PSY.get_outflow_limits(d)) ? 0.0 : PSY.get_outflow_limits(d).min
PSI.get_variable_upper_bound(::HydroTurbineFlowRateVariable, d::PSY.HydroTurbine, ::AbstractHydroFormulation) = isnothing(PSY.get_outflow_limits(d)) ? nothing : PSY.get_outflow_limits(d).max

############## HydroWaterFactorModel ####################
PSI.get_variable_lower_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::HydroWaterFactorModel) = isnothing(PSY.get_storage_level_limits(d)) ? 0.0 : PSY.get_storage_level_limits(d).min
PSI.get_variable_upper_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::HydroWaterFactorModel) = isnothing(PSY.get_storage_level_limits(d)) ? nothing : PSY.get_storage_level_limits(d).max

############## HydroPumpTurbine ####################
PSI.get_variable_binary(::PSI.ReservationVariable, ::Type{<:PSY.HydroPumpTurbine}, ::AbstractHydroPumpFormulation) = true
PSI.get_variable_binary(::PSI.OnVariable, ::Type{<:PSY.HydroPumpTurbine}, ::HydroPumpEnergyCommitment) = true

# ActivePowerVariable
PSI.get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroPumpTurbine}, ::AbstractHydroPumpFormulation) = false
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_active_power_limits(d).min
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroPumpTurbine, ::HydroPumpEnergyCommitment) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_active_power_limits(d).max
# ActivePowerPumpVariable
PSI.get_variable_binary(::ActivePowerPumpVariable, ::Type{<:PSY.HydroPumpTurbine}, ::AbstractHydroPumpFormulation) = false
PSI.get_variable_lower_bound(::ActivePowerPumpVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_active_power_limits_pump(d).min
PSI.get_variable_lower_bound(::ActivePowerPumpVariable, d::PSY.HydroPumpTurbine, ::HydroPumpEnergyCommitment) = 0.0
PSI.get_variable_upper_bound(::ActivePowerPumpVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_active_power_limits_pump(d).max
# ReactivePowerVariable
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroPumpTurbine}, ::AbstractHydroPumpFormulation) = false
PSI.get_variable_lower_bound(::PSI.ReactivePowerVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_reactive_power_limits(d).min
PSI.get_variable_upper_bound(::PSI.ReactivePowerVariable, d::PSY.HydroPumpTurbine, ::AbstractHydroPumpFormulation) = PSY.get_reactive_power_limits(d).max


############## EnergyShortageVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroEnergyShortageVariable, ::Type{<:PSY.HydroReservoir}, ::HydroEnergyModelReservoir) = false
PSI.get_variable_lower_bound(::HydroEnergyShortageVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyShortageVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).max
PSI.get_variable_binary(::HydroWaterShortageVariable, ::Type{<:PSY.HydroReservoir}, ::HydroWaterModelReservoir) = false
PSI.get_variable_lower_bound(::HydroWaterShortageVariable, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = 0.0
PSI.get_variable_upper_bound(::HydroWaterShortageVariable, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = PSY.get_storage_level_limits(d).max

############## HydroEnergySurplusVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroEnergySurplusVariable, ::Type{<:PSY.HydroReservoir}, ::HydroEnergyModelReservoir) = false
PSI.get_variable_upper_bound(::HydroEnergySurplusVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = 0.0
PSI.get_variable_lower_bound(::HydroEnergySurplusVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = - PSY.get_storage_level_limits(d).max
PSI.get_variable_binary(::HydroWaterSurplusVariable, ::Type{<:PSY.HydroReservoir}, ::HydroWaterModelReservoir) = false
PSI.get_variable_upper_bound(::HydroWaterSurplusVariable, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = 0.0
PSI.get_variable_lower_bound(::HydroWaterSurplusVariable, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = - PSY.get_storage_level_limits(d).max

############## BalanceShortageVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroBalanceShortageVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::HydroBalanceShortageVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = 0.0
PSI.get_variable_upper_bound(::HydroBalanceShortageVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).max

############## BalanceSurplusVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroBalanceSurplusVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
PSI.get_variable_lower_bound(::HydroBalanceSurplusVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = 0.0
PSI.get_variable_upper_bound(::HydroBalanceSurplusVariable, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).max

############## HydroReservoirHeadVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroReservoirHeadVariable, ::Type{PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
function PSI.get_variable_upper_bound(::HydroReservoirHeadVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.HEAD
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).max
        end
    end
    return nothing
end
function PSI.get_variable_lower_bound(::HydroReservoirHeadVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.HEAD
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).min
        end
    end
    return 0.0
end

############## HydroReservoirVolumeVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroReservoirVolumeVariable, ::Type{PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
function PSI.get_variable_upper_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) || (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).max
        end
    end
    return nothing
end
function PSI.get_variable_lower_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) || (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).min
        end
    end
    return 0.0
end

########################### Parameter related set functions ################################
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
# PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroEnergyReservoir, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_storage_level_limits(d).max / PSY.get_system_base_power(d)
PSI.get_multiplier_value(::WaterBudgetTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = 1.0 # Data already in m3/s
PSI.get_multiplier_value(::EnergyTargetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::EnergyTargetTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_level_targets(d) * PSY.get_storage_level_limits(d).max / PSY.get_system_base_power(d)
PSI.get_multiplier_value(::WaterTargetTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroWaterModelReservoir) = 1.0 # Data already in head meters
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_inflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_outflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0 # Data already in m3/s
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0 # Data already in m3/s
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_inflow(d) # Data normalized
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroReservoir, ::HydroWaterFactorModel) = PSY.get_inflow(d)
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::PSI.FixedOutput) = PSY.get_max_active_power(d)
# next 2 needed to avoid ambiguity errors
PSI.get_multiplier_value(::PSI.AbstractPiecewiseLinearBreakpointParameter, d::PSY.HydroGen, ::PSI.FixedOutput) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::PSI.AbstractPiecewiseLinearBreakpointParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)

PSI.get_parameter_multiplier(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_initial_parameter_value(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_initial_parameter_value(::HydroUsageLimitParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1e6 #unbounded
PSI.get_initial_parameter_value(::WaterLevelBudgetParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1e6 #unbounded
PSI.get_expression_multiplier(::PSI.OnStatusParameter, ::PSI.ActivePowerRangeExpressionUB, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).max
PSI.get_expression_multiplier(::PSI.OnStatusParameter, ::PSI.ActivePowerRangeExpressionLB, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).min

#################### Initial Conditions for models ###############
PSI.initial_condition_default(::PSI.DeviceStatus, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d)
PSI.initial_condition_variable(::PSI.DeviceStatus, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()
PSI.initial_condition_default(::PSI.DevicePower, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.initial_condition_variable(::PSI.DevicePower, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.ActivePowerVariable()
PSI.initial_condition_default(::PSI.InitialEnergyLevel, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d)
PSI.initial_condition_variable(::PSI.InitialEnergyLevel, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.EnergyVariable()

PSI.initial_condition_default(::PSI.InitialTimeDurationOn, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d) ? PSY.get_time_at_status(d) :  0.0
PSI.initial_condition_variable(::PSI.InitialTimeDurationOn, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()
PSI.initial_condition_default(::PSI.InitialTimeDurationOff, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d) ? 0.0 : PSY.get_time_at_status(d)
PSI.initial_condition_variable(::PSI.InitialTimeDurationOff, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()

PSI.initial_condition_default(::PSI.InitialEnergyLevel, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSY.get_initial_level(d) * PSY.get_storage_level_limits(d).max / PSY.get_system_base_power(d)
PSI.initial_condition_variable(::PSI.InitialEnergyLevel, d::PSY.HydroReservoir, ::HydroEnergyModelReservoir) = PSI.EnergyVariable()
function PSI.initial_condition_default(
    ::InitialReservoirVolume,
    d::PSY.HydroReservoir,
    ::AbstractHydroFormulation)

    if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) || (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
        return PSY.get_initial_level(d) * PSY.get_storage_level_limits(d).max * M3_TO_KM3
    else
        return PSY.get_initial_level(d) * PSY.get_storage_level_limits(d).max * PSY.get_proportional_term(PSY.get_head_to_volume_factor(d)) * M3_TO_KM3
    end
end
PSI.initial_condition_variable(::InitialReservoirVolume, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = HydroReservoirVolumeVariable()

########################Objective Function##################################################
# FIXME: why is this first one (cost, gen, variable, formulation), when all others have variable 2nd and gen 3rd?
PSI.proportional_cost(cost::Nothing, ::PSY.HydroGen, ::PSI.ActivePowerVariable, ::AbstractHydroFormulation)=0.0
PSI.proportional_cost(cost::PSY.OperationalCost, ::PSI.OnVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_fixed(cost)
PSI.proportional_cost(cost::PSY.OperationalCost, ::HydroEnergySurplusVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.proportional_cost(cost::PSY.OperationalCost, ::HydroEnergyShortageVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.proportional_cost(cost::PSY.OperationalCost, ::HydroEnergyShortageVariable, ::PSY.HydroGen, ::HydroDispatchRunOfRiverBudget)=PSI.CONSTRAINT_VIOLATION_SLACK_COST
PSI.proportional_cost(cost::PSY.HydroReservoirCost, ::HydroEnergySurplusVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSY.get_level_surplus_cost(cost)
PSI.proportional_cost(cost::PSY.HydroReservoirCost, ::HydroEnergyShortageVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSY.get_level_shortage_cost(cost)
PSI.proportional_cost(cost::PSY.HydroReservoirCost, ::HydroWaterSurplusVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSY.get_level_surplus_cost(cost)
PSI.proportional_cost(cost::PSY.HydroReservoirCost, ::HydroWaterShortageVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSY.get_level_shortage_cost(cost)
PSI.proportional_cost(cost::PSY.HydroReservoirCost, ::WaterSpillageVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSY.get_spillage_cost(cost)
PSI.proportional_cost(::PSY.HydroReservoirCost, ::HydroBalanceSurplusVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSI.CONSTRAINT_VIOLATION_SLACK_COST
PSI.proportional_cost(::PSY.HydroReservoirCost, ::HydroBalanceShortageVariable, ::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)=PSI.CONSTRAINT_VIOLATION_SLACK_COST

PSI.objective_function_multiplier(::PSI.ActivePowerVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::ActivePowerPumpVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::PSI.OnVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroEnergyShortageVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroEnergySurplusVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_NEGATIVE
PSI.objective_function_multiplier(::HydroEnergyShortageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroBalanceSurplusVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroBalanceShortageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroWaterSurplusVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_NEGATIVE
PSI.objective_function_multiplier(::HydroWaterShortageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::WaterSpillageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
# PSI.objective_function_multiplier(::PSI.ActivePowerOutVariable, ::HydroWaterFactorModel)=PSI.OBJECTIVE_FUNCTION_POSITIVE

PSI.sos_status(::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSI.SOSStatusVariable.NO_VARIABLE
PSI.sos_status(::PSY.HydroGen, ::AbstractHydroUnitCommitment)=PSI.SOSStatusVariable.VARIABLE

PSI.variable_cost(::Nothing, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_variable(cost)
PSI.variable_cost(cost::PSY.OperationalCost, ::ActivePowerPumpVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_variable(cost)

# PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroTurbine, ::AbstractHydroFormulation)=PSY.get_variable(cost)

PSI.variable_cost(cost::PSY.StorageCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_discharge_variable_cost(cost)

#! format: on

# These methods are defined in PowerSimulations
function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroDispatchFormulation},
) where {T <: PSY.HydroGen}
    return model
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroReservoirFormulation},
) where {T <: PSY.HydroReservoir}
    return model
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    ::PSI.DeviceModel{T, U},
) where {T <: PSY.HydroDispatch, U <: HydroDispatchRunOfRiverBudget}
    return PSI.DeviceModel(PSY.HydroDispatch, HydroDispatchRunOfRiver)
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    ::PSI.DeviceModel{T, <:AbstractHydroReservoirFormulation},
) where {T <: PSY.HydroDispatch}
    return PSI.DeviceModel(PSY.HydroDispatch, HydroDispatchRunOfRiver)
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroUnitCommitment},
) where {T <: PSY.HydroGen}
    return model
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroPumpFormulation},
) where {T <: PSY.HydroPumpTurbine}
    return model
end

function PSI.get_default_time_series_names(
    ::Type{<:PSY.HydroGen},
    ::Type{
        <:Union{
            PSI.FixedOutput,
            AbstractHydroDispatchFormulation,
            AbstractHydroUnitCommitment,
        },
    },
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        PSI.ActivePowerTimeSeriesParameter => "max_active_power",
        PSI.ReactivePowerTimeSeriesParameter => "max_active_power",
    )
end

function PSI.get_default_time_series_names(
    ::Type{<:PSY.HydroGen},
    ::Type{<:HydroDispatchRunOfRiverBudget},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        PSI.ActivePowerTimeSeriesParameter => "max_active_power",
        PSI.ReactivePowerTimeSeriesParameter => "max_active_power",
        EnergyBudgetTimeSeriesParameter => "hydro_budget",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroReservoir},
    ::Type{<:HydroWaterFactorModel},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        InflowTimeSeriesParameter => "inflow",
        OutflowTimeSeriesParameter => "outflow",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroReservoir},
    ::Type{<:HydroWaterModelReservoir},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        InflowTimeSeriesParameter => "inflow",
        OutflowTimeSeriesParameter => "outflow",
        WaterTargetTimeSeriesParameter => "hydro_target",
        WaterBudgetTimeSeriesParameter => "hydro_budget",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroEnergyModelReservoir},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        EnergyTargetTimeSeriesParameter => "storage_target",
        InflowTimeSeriesParameter => "inflow",
        EnergyBudgetTimeSeriesParameter => "hydro_budget",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroPumpTurbine},
    ::Type{<:AbstractHydroPumpFormulation},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}()
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: Union{PSI.FixedOutput, AbstractHydroFormulation}}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: AbstractHydroUnitCommitment}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: AbstractHydroReservoirFormulation}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroTurbine, D <: HydroTurbineWaterLinearDispatch}
    return Dict{String, Any}("head_fraction_usage" => 0.0)
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroWaterFactorModel},
)
    return Dict{String, Any}()
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroEnergyModelReservoir},
)
    return Dict{String, Any}(
        "energy_target" => false,
        "hydro_budget" => false,
    )
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroWaterModelReservoir},
)
    return Dict{String, Any}(
        "hydro_target" => false,
        "hydro_budget" => false,
    )
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroPumpTurbine},
    ::Type{AbstractHydroPumpFormulation},
)
    return Dict{String, Any}(
        "reservation" => false,
    )
end

############################################################################
############################### Variables ##################################
############################################################################

function PSI.add_variables!(
    container::PSI.OptimizationContainer,
    variable_type::Type{T},
    turbines::U,
    reservoirs::W,
    formulation::X,
) where {
    T <: HydroTurbineFlowRateVariable,
    U <: Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    W <: Union{Vector{E}, IS.FlattenIteratorWrapper{E}},
    X <: Union{HydroTurbineBilinearDispatch, HydroTurbineWaterLinearDispatch},
} where {
    D <: PSY.HydroTurbine,
    E <: PSY.HydroReservoir,
}
    time_steps = PSI.get_time_steps(container)
    variable = PSI.add_variable_container!(
        container,
        variable_type(),
        D,
        [PSY.get_name(d) for d in turbines],
        [PSY.get_name(d) for d in reservoirs],
        time_steps,
    )

    for t in time_steps, d in turbines, r in reservoirs
        name = PSY.get_name(d)
        name_res = PSY.get_name(r)
        variable[name, name_res, t] = JuMP.@variable(
            PSI.get_jump_model(container),
            base_name = "$(T)_$(D)_{$(name), $(name_res), $(t)}",
        )
        ub = PSI.get_variable_upper_bound(variable_type(), d, formulation)
        ub !== nothing && JuMP.set_upper_bound(variable[name, name_res, t], ub)

        lb = PSI.get_variable_lower_bound(variable_type(), d, formulation)
        lb !== nothing && JuMP.set_lower_bound(variable[name, name_res, t], lb)
    end
end

##### Method commented due to issues with write results with time steps with different lengths
#=
function PSI.add_variables!(
    container::PSI.OptimizationContainer,
    variable_type::Type{T},
    reservoirs::W,
    formulation::X,
) where {
    T <: Union{HydroBalanceSurplusVariable, HydroBalanceShortageVariable},
    W <: Union{Vector{E}, IS.FlattenIteratorWrapper{E}},
    X <: Union{HydroEnergyModelReservoir},
} where {
    E <: PSY.HydroReservoir,
}
    time_steps = PSI.get_time_steps(container)
    end_time_steps = [time_steps[1], time_steps[end]]
    variable = PSI.add_variable_container!(
        container,
        variable_type(),
        E,
        [PSY.get_name(d) for d in reservoirs],
        end_time_steps,
    )

    for t in end_time_steps, r in reservoirs
        name_res = PSY.get_name(r)
        variable[name_res, t] = JuMP.@variable(
            PSI.get_jump_model(container),
            base_name = "$(T)_$(E)_{$(name_res), $(t)}",
        )
        ub = PSI.get_variable_upper_bound(variable_type(), r, formulation)
        ub !== nothing && JuMP.set_upper_bound(variable[name_res, t], ub)

        lb = PSI.get_variable_lower_bound(variable_type(), r, formulation)
        lb !== nothing && JuMP.set_lower_bound(variable[name_res, t], lb)
    end
end
=#

############################################################################
############################### Constraints ################################
############################################################################

"""
Time series constraints
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: Union{HydroDispatchRunOfRiver, HydroDispatchRunOfRiverBudget},
    X <: PM.AbstractPowerModel,
}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    PSI.add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintLBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: Union{HydroDispatchRunOfRiver, HydroDispatchRunOfRiverBudget},
    X <: PM.AbstractPowerModel,
}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

"""
Add semicontinuous range constraints for [`HydroCommitmentRunOfRiver`](@ref) formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, <:PSI.RangeConstraintLBExpressions}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    PSI.add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroTurbine,
    W <: HydroTurbineEnergyCommitment,
    X <: PM.AbstractPowerModel,
}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

"""
Min and max reactive Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroReservoirFormulation},
)
    return PSY.get_reactive_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroDispatchFormulation},
)
    return PSY.get_reactive_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroUnitCommitment},
)
    return PSY.get_reactive_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroFormulation},
)
    return PSY.get_active_power_limits(x)
end

"""
Min and max active Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroReservoirFormulation},
)
    return PSY.get_active_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:HydroDispatchRunOfRiver},
)
    return (min = 0.0, max = PSY.get_max_active_power(x))
end

"""
Min and max active Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroTurbine,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroUnitCommitment},
)
    return PSY.get_active_power_limits(x)
end

"""
Min and max active pump Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroPumpTurbine,
    ::Type{<:PSI.InputActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroPumpFormulation},
)
    return PSY.get_active_power_limits_pump(x)
end

"""
Min and max active Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroPumpTurbine,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroPumpFormulation},
)
    return PSY.get_active_power_limits(x)
end

"""
Add power variable limits constraints for abstract hydro unit commitment formulations
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PSI.PowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: AbstractHydroUnitCommitment, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

"""
Add power variable limits constraints for abstract hydro dispatch formulations
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PSI.PowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroDispatchFormulation,
    X <: PM.AbstractPowerModel,
}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

######################## Energy balance constraints ############################

"""
This function defines the constraints for the energy level for the
[`PowerSystems.HydroReservoir`](@extref) using the [`HydroEnergyModelReservoir`](@ref) formulation.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{PSI.EnergyBalanceConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroEnergyModelReservoir,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions = PSI.get_initial_condition(container, PSI.InitialEnergyLevel(), V)
    energy_var = PSI.get_variable(container, PSI.EnergyVariable(), V)
    power_var = PSI.get_variable(container, PSI.ActivePowerVariable(), HydroTurbine)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)
    power_in_from_turbines =
        PSI.get_expression(container, TotalHydroPowerReservoirIncoming(), V)
    power_out_to_turbines =
        PSI.get_expression(container, TotalHydroPowerReservoirOutgoing(), V)
    spillage_in_from_reservoirs =
        PSI.get_expression(container, TotalSpillagePowerReservoirIncoming(), V)

    constraint = PSI.add_constraints_container!(
        container,
        PSI.EnergyBalanceConstraint(),
        V,
        names,
        time_steps,
    )
    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, InflowTimeSeriesParameter(), V)

    for ic in initial_conditions
        device = PSI.get_component(ic)
        name = PSY.get_name(device)
        param = PSI.get_parameter_column_values(param_container, name)
        if PSI.get_use_slacks(model)
            surplus_var =
                PSI.get_variable(container, HydroBalanceSurplusVariable(), V)[name, 1]
            shortage_var =
                PSI.get_variable(container, HydroBalanceShortageVariable(), V)[name, 1]
        else
            surplus_var = 0.0
            shortage_var = 0.0
        end
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            shortage_var - surplus_var +
            PSI.get_value(ic) +
            (power_in_from_turbines[name, 1] - power_out_to_turbines[name, 1]) *
            fraction_of_hour +
            (spillage_in_from_reservoirs[name, 1] - spillage_var[name, 1]) *
            fraction_of_hour + param[1] * multiplier[name, 1]
        )

        for t in time_steps[2:end]
            if t != time_steps[end]
                constraint[name, t] = JuMP.@constraint(
                    container.JuMPmodel,
                    energy_var[name, t] ==
                    energy_var[name, t - 1] + param[t] * multiplier[name, t] +
                    (power_in_from_turbines[name, t] - power_out_to_turbines[name, t]) *
                    fraction_of_hour +
                    (spillage_in_from_reservoirs[name, t] - spillage_var[name, t]) *
                    fraction_of_hour
                )
            else
                if PSI.get_use_slacks(model)
                    surplus_var =
                        PSI.get_variable(container, HydroBalanceSurplusVariable(), V)[
                            name,
                            t,
                        ]
                    shortage_var =
                        PSI.get_variable(container, HydroBalanceShortageVariable(), V)[
                            name,
                            t,
                        ]
                else
                    surplus_var = 0.0
                    shortage_var = 0.0
                end
                constraint[name, t] = JuMP.@constraint(
                    container.JuMPmodel,
                    energy_var[name, t] ==
                    shortage_var - surplus_var +
                    energy_var[name, t - 1] + param[t] * multiplier[name, t] +
                    (power_in_from_turbines[name, t] - power_out_to_turbines[name, t]) *
                    fraction_of_hour +
                    (spillage_in_from_reservoirs[name, t] - spillage_var[name, t]) *
                    fraction_of_hour
                )
            end
        end
    end
    return
end

"""
Add energy target constraints for [`PowerSystems.HydroGen`](@extref)
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint = PSI.add_constraints_container!(
        container,
        EnergyTargetConstraint(),
        V,
        set_name,
        time_steps,
    )

    e_var = PSI.get_variable(container, PSI.EnergyVariable(), V)
    shortage_var = PSI.get_variable(container, HydroEnergyShortageVariable(), V)
    surplus_var = PSI.get_variable(container, HydroEnergySurplusVariable(), V)
    param_container = PSI.get_parameter(container, EnergyTargetTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, EnergyTargetTimeSeriesParameter(), V)

    for d in devices
        name = PSY.get_name(d)
        cost_data = PSY.get_operation_cost(d)
        if isa(cost_data, PSY.StorageCost)
            shortage_cost = PSY.get_energy_shortage_cost(cost_data)
        else
            @debug "Data for device $name doesn't contain shortage costs"
            shortage_cost = 0.0
        end

        if shortage_cost == 0.0
            @warn(
                "Device $name has energy shortage cost set to 0.0, as a result the model will turnoff the EnergyShortageVariable to avoid infeasible/unbounded problem."
            )
            JuMP.delete_upper_bound.(shortage_var[name, :])
            JuMP.set_upper_bound.(shortage_var[name, :], 0.0)
        end
        param = PSI.get_parameter_column_values(param_container, name)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                e_var[name, t] + shortage_var[name, t] + surplus_var[name, t] ==
                multiplier[name, t] * param[t]
            )
        end
    end
    return
end

"""
Add energy target constraints for [`PowerSystems.HydroReservoir`](@extref)
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroEnergyModelReservoir,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint = PSI.add_constraints_container!(
        container,
        EnergyTargetConstraint(),
        V,
        set_name,
        [time_steps[end]],
    )

    e_var = PSI.get_variable(container, PSI.EnergyVariable(), V)
    shortage_var = PSI.get_variable(container, HydroEnergyShortageVariable(), V)
    surplus_var = PSI.get_variable(container, HydroEnergySurplusVariable(), V)
    param_container = PSI.get_parameter(container, EnergyTargetTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, EnergyTargetTimeSeriesParameter(), V)

    for d in devices
        name = PSY.get_name(d)
        cost_data = PSY.get_operation_cost(d)
        shortage_cost = PSY.get_level_shortage_cost(cost_data)

        if iszero(shortage_cost)
            @warn(
                "Device $name has energy shortage cost set to 0.0, as a result the model will turnoff the EnergyShortageVariable to avoid infeasible/unbounded problem."
            )
            JuMP.delete_upper_bound.(shortage_var[name, :])
            JuMP.set_upper_bound.(shortage_var[name, :], 0.0)
        end
        param = PSI.get_parameter_column_values(param_container, name)
        t_end = time_steps[end]
        constraint[name, t_end] = JuMP.@constraint(
            container.JuMPmodel,
            e_var[name, t_end] + shortage_var[name, t_end] + surplus_var[name, t_end] ==
            multiplier[name, t_end] * param[t_end]
        )
    end
    return
end

"""
Add water target constraints for [`PowerSystems.HydroReservoir`](@extref).
Only supported for HEAD type.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{WaterTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroWaterModelReservoir,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint = PSI.add_constraints_container!(
        container,
        WaterTargetConstraint(),
        V,
        set_name,
        [time_steps[end]],
    )

    h_var = PSI.get_variable(container, HydroReservoirHeadVariable(), V)
    shortage_var = PSI.get_variable(container, HydroWaterShortageVariable(), V)
    surplus_var = PSI.get_variable(container, HydroWaterSurplusVariable(), V)
    param_container = PSI.get_parameter(container, WaterTargetTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, WaterTargetTimeSeriesParameter(), V)
    for d in devices
        name = PSY.get_name(d)
        reservoir_type = PSY.get_level_data_type(d)
        if reservoir_type != PSY.ReservoirDataType.HEAD
            error(
                "Water target constraints are only supported for HEAD type reservoirs. Consider updating reservoir $name to HEAD type.",
            )
        end
        cost_data = PSY.get_operation_cost(d)
        shortage_cost = PSY.get_level_shortage_cost(cost_data)

        if iszero(shortage_cost)
            @warn(
                "Device $name has energy shortage cost set to 0.0, as a result the model will turnoff the EnergyShortageVariable to avoid infeasible/unbounded problem."
            )
            JuMP.delete_upper_bound.(shortage_var[name, :])
            JuMP.set_upper_bound.(shortage_var[name, :], 0.0)
        end
        param = PSI.get_parameter_column_values(param_container, name)
        t_end = time_steps[end]
        constraint[name, t_end] = JuMP.@constraint(
            container.JuMPmodel,
            h_var[name, t_end] + shortage_var[name, t_end] + surplus_var[name, t_end] ==
            multiplier[name, t_end] * param[t_end]
        )
    end
    return
end

##################################### Energy Block Optimization ############################
"""
This function defines the constraint for the hydro power generation
for the [`HydroWaterFactorModel`](@ref).
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{HydroPowerConstraint},
    devices::IS.FlattenIteratorWrapper{PSY.HydroTurbine},
    model::PSI.DeviceModel{PSY.HydroTurbine, W},
    ::PSI.NetworkModel{X},
) where {
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]

    energy_var =
        PSI.get_variable(container, HydroReservoirVolumeVariable(), PSY.HydroReservoir)
    turbined_out_flow_var =
        PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    hydro_power = PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroTurbine)

    constraint = PSI.add_constraints_container!(
        container,
        HydroPowerConstraint(),
        PSY.HydroTurbine,
        names,
        time_steps,
    )

    base_power = PSI.get_base_power(container)
    t_first = first(time_steps)
    t_final = last(time_steps)

    for d in devices
        name = PSY.get_name(d)
        reservoir = only(PSY.get_connected_head_reservoirs(sys, d))
        reservoir_name = PSY.get_name(reservoir)
        initial_level = PSY.get_initial_level(reservoir)
        elevation_head =
            PSY.get_intake_elevation(reservoir) - PSY.get_powerhouse_elevation(d)
        efficiency = PSY.get_efficiency(d)
        K = efficiency * WATER_DENSITY * GRAVITATIONAL_CONSTANT

        h2v_factor = PSY.get_proportional_term(PSY.get_head_to_volume_factor(reservoir))
        if isa(h2v_factor, PSY.PiecewisePointCurve)
            error(
                "EnergyBlockOptimization does not support piecewise head to volume factor",
            )
        end

        constraint[name, t_first] = JuMP.@constraint(
            container.JuMPmodel,
            hydro_power[name, t_first] ==
            fraction_of_hour * (
                K * turbined_out_flow_var[name, t_first] *
                (
                    0.5 * (energy_var[reservoir_name, t_first] + initial_level) *
                    h2v_factor + elevation_head
                )
            ) / base_power
        )
        for t in time_steps[(t_first + 1):t_final]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                hydro_power[name, t] ==
                fraction_of_hour * (
                    K * turbined_out_flow_var[name, t] *
                    (
                        h2v_factor * 0.5 *
                        (energy_var[reservoir_name, t] + energy_var[reservoir_name, t - 1])
                        +
                        elevation_head
                    )
                ) / base_power
            )
        end
    end
    return
end

"""
This function defines the constraints for the water level (or state of charge)
for the [`HydroWaterFactorModel`](@ref).
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{ReservoirInventoryConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroWaterFactorModel,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]

    energy_var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
    turbined_out_flow_var =
        PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        ReservoirInventoryConstraint(),
        V,
        names,
        time_steps,
    )

    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    t_first = first(time_steps)
    t_final = last(time_steps)

    for d in devices
        name = PSY.get_name(d)
        initial_level = PSY.get_initial_level(d)
        target_level = PSY.get_level_targets(d)

        turbines = get_downstream_turbines(d)
        turbine_names = [PSY.get_name(turbine) for turbine in turbines]

        constraint[name, t_first] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, t_first] ==
            initial_level
            +
            fraction_of_hour * SECONDS_IN_HOUR *
            (
                PSI.get_parameter_column_refs(param_container, name)[t_first] *
                multiplier[name, t_first] -
                (
                    sum(
                        turbined_out_flow_var[turbine_name, t_first] for
                        turbine_name in turbine_names
                    )
                    +
                    spillage_var[name, t_first]
                )
            )
        )

        for t in time_steps[(t_first + 1):(t_final)]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] +
                fraction_of_hour * SECONDS_IN_HOUR *
                (
                    PSI.get_parameter_column_refs(param_container, name)[t] *
                    multiplier[name, t] -
                    (
                        sum(
                            turbined_out_flow_var[turbine_name, t] for
                            turbine_name in turbine_names
                        )
                        +
                        spillage_var[name, t]
                    )
                )
            )
        end
    end
    return
end

##################################### Water/Energy Budget Constraint ############################
"""
This function define the budget constraint for the
active power budget formulation.
`` sum(P[t]) <= Budget ``
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroDispatchFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(container, EnergyBudgetConstraint(), V, set_name)

    variable_out = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    param_container = PSI.get_parameter(container, EnergyBudgetTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for d in devices
        name = PSY.get_name(d)
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([variable_out[name, t] for t in time_steps]) <=
            sum([multiplier[name, t] * param[t] for t in time_steps])
        )
    end
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: HydroDispatchRunOfRiverBudget,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(container, EnergyBudgetConstraint(), V, set_name)
    variable_out = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    param_container = PSI.get_parameter(container, EnergyBudgetTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)
    for d in devices
        name = PSY.get_name(d)
        if PSI.get_use_slacks(model)
            slack_var =
                sum(PSI.get_variable(container, HydroEnergyShortageVariable(), V)[name, :])
        else
            slack_var = 0.0
        end
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([variable_out[name, t] for t in time_steps]) <=
            sum([multiplier[name, t] * param[t] for t in time_steps]) + slack_var
        )
    end
    hydro_budget_interval = PSI.get_attribute(model, "hydro_budget_interval")
    if !isnothing(hydro_budget_interval)
        constraint_aux = PSI.add_constraints_container!(
            container,
            EnergyBudgetConstraint(),
            V,
            set_name;
            meta = "interval",
        )
        resolution = PSI.get_resolution(container)
        interval_length =
            Dates.Millisecond(hydro_budget_interval).value ÷
            Dates.Millisecond(resolution).value
        for d in devices
            name = PSY.get_name(d)
            param = PSI.get_parameter_column_values(param_container, name)
            constraint_aux[name] = JuMP.@constraint(
                container.JuMPmodel,
                sum([variable_out[name, t] for t in 1:interval_length]) <=
                sum([multiplier[name, t] * param[t] for t in 1:interval_length])
            )
        end
    end
    return
end

"""
This function define the budget constraint for the
active power budget formulation.
`` sum(P[t]) <= Budget ``
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{EnergyBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroEnergyModelReservoir,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(container, EnergyBudgetConstraint(), V, set_name)

    total_power_out = PSI.get_expression(container, TotalHydroPowerReservoirOutgoing(), V)
    param_container = PSI.get_parameter(container, EnergyBudgetTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for d in devices
        name = PSY.get_name(d)
        if PSI.get_use_slacks(model)
            slack_var =
                sum(PSI.get_variable(container, HydroEnergyShortageVariable(), V)[name, :])
        else
            slack_var = 0.0
        end
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([total_power_out[name, t] for t in time_steps]) <=
            sum([multiplier[name, t] * param[t] for t in time_steps]) + slack_var
        )
    end
    return
end

"""
This function define the budget constraint for the
active power budget formulation.
`` sum(f[t]) <= Budget ``
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{WaterBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroWaterModelReservoir,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(container, WaterBudgetConstraint(), V, set_name)

    total_flow_out = PSI.get_expression(container, TotalHydroFlowRateReservoirOutgoing(), V)
    param_container = PSI.get_parameter(container, WaterBudgetTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for d in devices
        name = PSY.get_name(d)
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([total_flow_out[name, t] for t in time_steps]) <=
            sum([multiplier[name, t] * param[t] for t in time_steps])
        )
    end
    return
end

############################################################################
###################### Medium Term Constraints #############################
############################################################################

"""
This function defines the constraints for the energy balance in a medium term planning problem.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBalanceExpression},
    ::Type{PSI.EnergyBalanceConstraint},
    ::PSI.NetworkModel{X},
) where {
    X <: PM.AbstractPowerModel,
}
    bal_expr = PSI.get_expression(container, EnergyBalanceExpression(), PSY.System)
    buses_ax, times_ax = axes(bal_expr)

    constraint = PSI.add_constraints_container!(
        container,
        PSI.EnergyBalanceConstraint(),
        PSY.System,
        buses_ax,
        times_ax,
    )

    for bus in buses_ax, t in times_ax
        constraint[bus, t] = JuMP.@constraint(
            container.JuMPmodel,
            bal_expr[bus, t] == 0.0,
        )
    end
    return
end

"""
This function define the level (head or volume) limits for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirLevelLimitConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = [PSY.get_name(d) for d in devices]
    constraint_ub =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelLimitConstraint(),
            V,
            names,
            time_steps;
            meta = "ub",
        )
    constraint_lb =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelLimitConstraint(),
            V,
            names,
            time_steps;
            meta = "lb",
        )

    for d in devices
        name = PSY.get_name(d)
        if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) ||
           (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
            var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
        else
            var = PSI.get_variable(container, HydroReservoirHeadVariable(), V)
        end
        level_limits = PSY.get_storage_level_limits(d)
        if isa(level_limits, PSY.TimeSeriesKey)
            error("Level limits are not supported with timeseries yet")
        end
        for t in time_steps
            constraint_ub[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                var[name, t] <= level_limits.max
            )
            constraint_lb[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                var[name, t] >= level_limits.min
            )
        end
    end
    return
end

"""
This function define the level (head or volume) limits for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirInventoryConstraint},
    ::Type{HydroReservoirVolumeVariable},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    resolution = PSI.get_resolution(container)
    hourly_resolution = Float64(Dates.Hour(resolution).value)
    time_steps = PSI.get_time_steps(container)
    names = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirInventoryConstraint(),
            V,
            names,
            time_steps,
        )
    turbine_in = PSI.get_expression(container, TotalHydroFlowRateReservoirIncoming(), V)
    turbine_out = PSI.get_expression(container, TotalHydroFlowRateReservoirOutgoing(), V)
    volume = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)
    spillage_in = PSI.get_expression(container, TotalSpillageFlowRateReservoirIncoming(), V)
    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    param_container_outflow = PSI.get_parameter(container, OutflowTimeSeriesParameter(), V)

    initial_conditions = PSI.get_initial_condition(
        container,
        InitialReservoirVolume(),
        PSY.HydroReservoir,
    )

    for ic in initial_conditions
        d = PSI.get_component(ic)
        name = PSY.get_name(d)
        inflow = PSI.get_parameter_column_refs(param_container, name)

        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            volume[name, 1] ==
            PSI.get_value(ic) -
            hourly_resolution * SECONDS_IN_HOUR *
            (
                spillage_var[name, 1] - spillage_in[name, 1] + turbine_out[name, 1] -
                turbine_in[name, 1] - inflow[1]
            )
            * M3_TO_KM3
        )
        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                volume[name, t] ==
                volume[name, t - 1] -
                (
                    hourly_resolution * SECONDS_IN_HOUR *
                    (
                        spillage_var[name, t] - spillage_in[name, t] +
                        turbine_out[name, t] - turbine_in[name, t] - inflow[t]
                    )
                ) * M3_TO_KM3
            )
        end
    end
    return
end

"""
This function define the target level constraint for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirLevelTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelTargetConstraint(),
            V,
            names,
        )

    for d in devices
        name = PSY.get_name(d)
        level_targets = PSY.get_level_targets(d) * PSY.get_storage_level_limits(d).max
        if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) ||
           (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
            var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
        else
            var = PSI.get_variable(container, HydroReservoirHeadVariable(), V)
        end

        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            var[name, time_steps[end]] >= level_targets
        )
    end
    return
end

"""
This function define the target level constraint for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirLevelTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: HydroWaterFactorModel,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelTargetConstraint(),
            V,
            names,
        )

    for d in devices
        name = PSY.get_name(d)
        level_targets = PSY.get_level_targets(d) * PSY.get_storage_level_limits(d).max
        h2v_factor = PSY.get_proportional_term(PSY.get_head_to_volume_factor(d))
        if isa(h2v_factor, PSY.PiecewisePointCurve)
            error(
                "EnergyBlockOptimization does not support piecewise head to volume factor",
            )
        end
        if (PSY.get_level_data_type(d) == PSY.ReservoirDataType.USABLE_VOLUME) ||
           (PSY.get_level_data_type(d) == PSY.ReservoirDataType.TOTAL_VOLUME)
            var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
        else
            var =
                PSI.get_variable(container, HydroReservoirVolumeVariable(), V) / h2v_factor
        end

        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            level_targets <= var[name, time_steps[end]] <=
            PSY.get_storage_level_limits(d).max
        )
    end
    return
end

"""
This function define the relationship between head and volume for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirHeadToVolumeConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirHeadToVolumeConstraint(),
            V,
            names,
            time_steps,
        )
    volume = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
    head = PSI.get_variable(container, HydroReservoirHeadVariable(), V)

    for d in devices
        name = PSY.get_name(d)
        h2v_factor = PSY.get_proportional_term(PSY.get_head_to_volume_factor(d))
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                volume[name, t] == h2v_factor * head[name, t] * M3_TO_KM3
            )
        end
    end
    return
end

"""
This function define the relationship between turbined flow and power produced
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{TurbinePowerOutputConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroTurbine,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    base_power = PSI.get_base_power(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            TurbinePowerOutputConstraint(),
            V,
            names,
            time_steps,
        )
    power = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    flow = PSI.get_variable(container, HydroTurbineFlowRateVariable(), V)
    head = PSI.get_variable(container, HydroReservoirHeadVariable(), PSY.HydroReservoir)
    for d in devices
        name = PSY.get_name(d)
        conversion_factor = PSY.get_conversion_factor(d)
        reservoirs = filter(PSY.get_available, PSY.get_connected_head_reservoirs(sys, d))
        powerhouse_elevation = PSY.get_powerhouse_elevation(d)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                power[name, t] ==
                GRAVITATIONAL_CONSTANT * WATER_DENSITY * conversion_factor *
                sum(
                    (
                        head[PSY.get_name(res), t] - powerhouse_elevation
                    ) * flow[name, PSY.get_name(res), t] for res in reservoirs
                ) / (1e6 * base_power)
            )
        end
    end
    return
end

"""
This function define the relationship between turbined flow and power produced with constant head
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{TurbinePowerOutputConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroTurbine,
    W <: HydroTurbineWaterLinearDispatch,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    base_power = PSI.get_base_power(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            TurbinePowerOutputConstraint(),
            V,
            names,
            time_steps,
        )
    power = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    flow = PSI.get_variable(container, HydroTurbineFlowRateVariable(), V)
    fraction_max_head = PSI.get_attribute(model, "head_fraction_usage")
    for d in devices
        name = PSY.get_name(d)
        conversion_factor = PSY.get_conversion_factor(d)
        reservoirs = filter(PSY.get_available, PSY.get_connected_head_reservoirs(sys, d))
        powerhouse_elevation = PSY.get_powerhouse_elevation(d)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                power[name, t] ==
                GRAVITATIONAL_CONSTANT * WATER_DENSITY * conversion_factor *
                sum(
                    (
                        fraction_max_head * (
                            PSY.get_storage_level_limits(res).max -
                            PSY.get_intake_elevation(res)
                        ) +
                        PSY.get_intake_elevation(res) -
                        powerhouse_elevation
                    ) * flow[name, PSY.get_name(res), t] for res in reservoirs
                ) / (1e6 * base_power)
            )
        end
    end
    return
end

############################################################################
############################### Expressions ################################
############################################################################

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    U <: Union{TotalHydroFlowRateReservoirIncoming, TotalHydroFlowRateReservoirOutgoing},
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        U(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    variable = PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    for d in devices
        turbines = get_available_turbines(d, U)
        isempty(turbines) && continue
        turbine_names = PSY.get_name.(turbines)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            expression[reservoir_name, t] =
                sum(variable[name, reservoir_name, t] for name in turbine_names)
        end
    end
end

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{TotalHydroFlowRateTurbineOutgoing},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    V <: PSY.HydroTurbine,
    W <: AbstractHydroFormulation,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        TotalHydroFlowRateTurbineOutgoing(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    variable = PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    for d in devices
        reservoirs = filter(PSY.get_available, PSY.get_connected_head_reservoirs(sys, d))
        reservoir_names = PSY.get_name.(reservoirs)
        name = PSY.get_name(d)
        for t in time_steps
            expression[name, t] =
                sum(variable[name, reservoir_name, t] for reservoir_name in reservoir_names)
        end
    end
end

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    U <: TotalHydroPowerReservoirIncoming,
    V <: PSY.HydroReservoir,
    W <: HydroEnergyModelReservoir,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        U(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    ## Add power incoming from upstream turbines
    for d in devices
        turbines = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroTurbine),
            PSY.get_upstream_turbines(d),
        )
        isempty(turbines) && continue
        variable = PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroTurbine)
        turbine_names = PSY.get_name.(turbines)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(variable[name, t] for name in turbine_names))
        end
    end
    ## Add power incoming from upstream PumpTurbines
    for d in devices
        pumps = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroPumpTurbine),
            PSY.get_upstream_turbines(d),
        )
        isempty(pumps) && continue
        turbine_power =
            PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroPumpTurbine)
        pump_names = PSY.get_name.(pumps)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(turbine_power[name, t] for name in pump_names))
        end
    end
    ## Add pumped power incoming from downstream PumpTurbines
    for d in devices
        pumps = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroPumpTurbine),
            PSY.get_downstream_turbines(d),
        )
        isempty(pumps) && continue
        pump_power =
            PSI.get_variable(container, ActivePowerPumpVariable(), PSY.HydroPumpTurbine)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(
                    pump_power[PSY.get_name(pump), t] * PSY.get_efficiency(pump).pump for
                    pump in pumps
                ))
        end
    end
    return
end

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    U <: TotalHydroPowerReservoirOutgoing,
    V <: PSY.HydroReservoir,
    W <: HydroEnergyModelReservoir,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        U(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    ## Add power going to downstream turbines
    for d in devices
        turbines = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroTurbine),
            PSY.get_downstream_turbines(d),
        )
        isempty(turbines) && continue
        variable = PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroTurbine)
        turbine_names = PSY.get_name.(turbines)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(variable[name, t] for name in turbine_names))
        end
    end
    ## Add power going to downstream PumpTurbines
    for d in devices
        pumps = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroPumpTurbine),
            PSY.get_downstream_turbines(d),
        )
        isempty(pumps) && continue
        turbine_power =
            PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroPumpTurbine)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            # More power has to be taken from the head reservoir to produce the turbine power in the PumpTurbine
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(
                    turbine_power[PSY.get_name(pump), t] / PSY.get_efficiency(pump).turbine
                    for pump in pumps
                ))
        end
    end
    ## Add pumped power leaving the tail reservoir into the PumpTurbine
    for d in devices
        pumps = filter(
            x -> PSY.get_available(x) && isa(x, PSY.HydroPumpTurbine),
            PSY.get_upstream_turbines(d),
        )
        isempty(pumps) && continue
        pump_power =
            PSI.get_variable(container, ActivePowerPumpVariable(), PSY.HydroPumpTurbine)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(expression[reservoir_name, t],
                sum(pump_power[PSY.get_name(pump), t] for pump in pumps))
        end
    end
    return
end

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    U <: Union{TotalSpillagePowerReservoirIncoming, TotalSpillageFlowRateReservoirIncoming},
    V <: PSY.HydroReservoir,
    W <: AbstractHydroReservoirFormulation,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        U(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    variable = PSI.get_variable(container, WaterSpillageVariable(), PSY.HydroReservoir)

    for d in devices
        upstream_reservoirs = filter(PSY.get_available, get_upstream_reservoirs(d))
        isempty(upstream_reservoirs) && continue
        upstream_reservoir_names = PSY.get_name.(upstream_reservoirs)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            expression[reservoir_name, t] =
                sum(variable[name, t] for name in upstream_reservoir_names)
        end
    end
end

function add_to_balance_expression!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    ::Type{V},
    devices::IS.FlattenIteratorWrapper{W},
    model::PSI.DeviceModel{W, X},
    ::PSI.NetworkModel{Y},
    resolution::Float64,
) where {
    U <: EnergyBalanceExpression,
    V <: PSI.ActivePowerVariable,
    W <: PSY.Generator,
    X <: PSI.AbstractDeviceFormulation,
    Y <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.get_expression(container, U(), PSY.System)
    ref_buses, time_ax = axes(expression)
    ref_bus = only(ref_buses)
    variable = PSI.get_variable(container, V(), W)

    for d in devices
        name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(
                expression[ref_bus, t],
                resolution * variable[name, t],
            )
        end
    end
end

function add_to_balance_expression!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    ::Type{V},
    devices::IS.FlattenIteratorWrapper{W},
    model::PSI.DeviceModel{W, X},
    ::PSI.NetworkModel{Y},
) where {
    U <: EnergyBalanceExpression,
    V <: PSI.ActivePowerTimeSeriesParameter,
    W <: PSY.ElectricLoad,
    X <: PSI.AbstractDeviceFormulation,
    Y <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.get_expression(container, U(), PSY.System)
    ref_buses, time_ax = axes(expression)
    ref_bus = only(ref_buses)
    param_container = PSI.get_parameter(container, V(), W)
    param_multiplier = PSI.get_parameter_multiplier_array(
        container,
        V(),
        W,
    )

    for d in devices
        name = PSY.get_name(d)
        param = PSI.get_parameter_column_refs(param_container, name)
        for t in time_steps
            JuMP.add_to_expression!(
                expression[ref_bus, t],
                param_multiplier[name, t] * param[t],
            )
        end
    end
end

function add_slack_to_balance_expression!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    resolution::Float64,
) where {
    U <: PSY.System,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.get_expression(container, EnergyBalanceExpression(), PSY.System)
    ref_buses, time_ax = axes(expression)
    sl_up = PSI.add_variable_container!(
        container,
        PSI.SystemBalanceSlackUp(),
        PSY.System,
        ref_buses,
        time_steps,
    )
    sl_dn = PSI.add_variable_container!(
        container,
        PSI.SystemBalanceSlackDown(),
        PSY.System,
        ref_buses,
        time_steps,
    )
    ref_num = only(ref_buses)
    for t in time_steps
        sl_up[ref_num, t] = JuMP.@variable(
            PSI.get_jump_model(container),
            base_name = "slack_{$(PSI.SystemBalanceSlackUp), $(ref_num), $t}",
            lower_bound = 0.0
        )
        sl_dn[ref_num, t] = JuMP.@variable(
            PSI.get_jump_model(container),
            base_name = "slack_{$(PSI.SystemBalanceSlackDown), $(ref_num), $t}",
            lower_bound = 0.0
        )
    end

    for t in time_steps
        JuMP.add_to_expression!(
            expression[ref_num, t],
            resolution * sl_up[ref_num, t],
        )
        JuMP.add_to_expression!(
            expression[ref_num, t],
            -resolution * sl_dn[ref_num, t],
        )
    end
end

##################################### Auxillary Variables ############################
function PSI.calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::PSI.AuxVarKey{HydroEnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroGen}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    p_variable_results = PSI.get_variable(container, PSI.ActivePowerVariable(), T)
    aux_variable_container = PSI.get_aux_variable(container, HydroEnergyOutput(), T)
    devices_names = axes(aux_variable_container, 1)
    for name in devices_names
        d = PSY.get_component(T, system, name)
        for t in time_steps
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regup = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveUpExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regup = 0.0
            end
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regdn = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveDownExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regdn = 0.0
            end
            aux_variable_container[name, t] =
                (
                    PSI.jump_value(p_variable_results[name, t]) +
                    served_regup - served_regdn
                ) * fraction_of_hour
        end
    end

    return
end

function PSI.update_decision_state!(
    state::PSI.SimulationState,
    key::PSI.AuxVarKey{HydroEnergyOutput, T},
    store_data::PSI.DenseAxisArray{Float64, 2},
    simulation_time::Dates.DateTime,
    model_params::PSI.ModelStoreParams,
) where {T <: PSY.Component}
    state_data = PSI.get_decision_state_data(state, key)
    model_resolution = PSI.get_resolution(model_params)
    state_resolution = PSI.get_data_resolution(state_data)
    resolution_ratio = model_resolution ÷ state_resolution
    state_timestamps = state_data.timestamps
    IS.@assert_op resolution_ratio >= 1

    if simulation_time > PSI.get_end_of_step_timestamp(state_data)
        state_data_index = 1
        state_data.timestamps[:] .= range(
            simulation_time;
            step = state_resolution,
            length = PSI.get_num_rows(state_data),
        )
    else
        state_data_index = PSI.find_timestamp_index(state_timestamps, simulation_time)
    end

    offset = resolution_ratio - 1
    result_time_index = axes(store_data)[2]
    PSI.set_update_timestamp!(state_data, simulation_time)
    column_names = axes(state_data.values)[1]
    for t in result_time_index
        state_range = state_data_index:(state_data_index + offset)
        for name in column_names, i in state_range
            state_data.values[name, i] = store_data[name, t] / resolution_ratio
        end
        PSI.set_last_recorded_row!(state_data, state_range[end])
        state_data_index += resolution_ratio
    end

    return
end

##################################### Hydro generation cost ############################
function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: AbstractHydroUnitCommitment}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    PSI.add_proportional_cost!(container, PSI.OnVariable(), devices, U())
    return
end

# MarketBidCost proportional_cost args: (container, cost, variable, device, formulation, time)
# HydroGenerationCost proportional_cost args: (cost, variable, device, formulation)
# this ties the two together by ignoring the container and time args
PSI.proportional_cost(
    ::PSI.OptimizationContainer,
    cost::PSY.HydroGenerationCost,
    ::U,
    comp::PSY.HydroGen,
    ::V,
    ::Int,
) where {U <: PSI.OnVariable, V <: AbstractHydroUnitCommitment} =
    PSI.proportional_cost(cost, U(), comp, V())

# copy-paste from PSI, just with types changed (HydroFoo => ThermalFoo):
PSI.is_time_variant_term(
    ::PSI.OptimizationContainer,
    ::PSY.HydroGenerationCost,
    ::PSI.OnVariable,
    ::PSY.HydroGen,
    ::AbstractHydroFormulation,
    t::Int,
) = false

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {T <: PSY.HydroGen, U <: PSI.OnVariable, V <: AbstractHydroUnitCommitment}
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        for t in PSI.get_time_steps(container)
            cost_term = PSI.proportional_cost(container, op_cost_data, U(), d, V(), t)
            add_as_time_variant =
                PSI.is_time_variant_term(container, op_cost_data, U(), d, V(), t)
            iszero(cost_term) && continue
            cost_term *= multiplier
            exp = if d isa PSY.HydroPumpTurbine && PSY.get_must_run(d)
                cost_term  # note we do not add this to the objective function
            else
                PSI._add_proportional_term_maybe_variant!(
                    Val(add_as_time_variant), container, U(), d, cost_term, t)
            end
            PSI.add_to_expression!(container, PSI.ProductionCostExpression, exp, d, t)
        end
    end
    return
end

PSI.proportional_cost(
    container::PSI.OptimizationContainer,
    cost::PSY.MarketBidCost,
    ::PSI.OnVariable,
    comp::PSY.HydroGen,
    ::AbstractHydroUnitCommitment,
    t::Int,
) =
    PSI._lookup_maybe_time_variant_param(container, comp, t,
        Val(PSI.is_time_variant(PSY.get_incremental_initial_input(cost))),
        PSY.get_initial_input ∘ PSY.get_incremental_offer_curves ∘ PSY.get_operation_cost,
        PSI.IncrementalCostAtMinParameter())

PSI.is_time_variant_term(
    ::PSI.OptimizationContainer,
    cost::PSY.MarketBidCost,
    ::PSI.OnVariable,
    ::PSY.HydroGen,
    ::AbstractHydroUnitCommitment,
    t::Int,
) =
    PSI.is_time_variant(PSY.get_incremental_initial_input(cost))

# end copy-paste

# These _include_{constant}_min_gen_power functions are needed for MarketBidCost.
# Commitment has an on/off choice, so add OnVariable * breakpoint1 to power constraint.
PSI._include_min_gen_power_in_constraint(
    ::PSY.HydroGen,
    ::PSI.ActivePowerVariable,
    ::HydroCommitmentRunOfRiver,
) = true
# Dispatch with ActivePower (not PowerAboveMinimum) means generator is on,
# so add constant breakpoint1 to power constraint.
PSI._include_min_gen_power_in_constraint(
    ::PSY.HydroGen,
    ::PSI.ActivePowerVariable,
    ::HydroDispatchRunOfRiver,
) = false

PSI._include_constant_min_gen_power_in_constraint(
    ::PSY.HydroGen,
    ::PSI.ActivePowerVariable,
    ::HydroDispatchRunOfRiver,
) = true

PSI._include_min_gen_power_in_constraint(
    ::PSY.EnergyReservoirStorage,
    ::PSI.ActivePowerInVariable,
    ::PSI.AbstractDeviceFormulation,
) = false
PSI._include_min_gen_power_in_constraint(
    ::PSY.EnergyReservoirStorage,
    ::PSI.ActivePowerOutVariable,
    ::PSI.AbstractDeviceFormulation,
) = false

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: AbstractHydroDispatchFormulation}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    model::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: HydroDispatchRunOfRiverBudget}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    if PSI.get_use_slacks(model)
        PSI.add_proportional_cost!(container, HydroEnergyShortageVariable(), devices, U())
    end
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    model::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroReservoir, U <: HydroEnergyModelReservoir}
    PSI.add_proportional_cost!(container, HydroEnergySurplusVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergyShortageVariable(), devices, U())
    PSI.add_proportional_cost!(container, WaterSpillageVariable(), devices, U())
    if PSI.get_use_slacks(model)
        PSI.add_proportional_cost!(container, HydroBalanceShortageVariable(), devices, U())
        PSI.add_proportional_cost!(container, HydroBalanceSurplusVariable(), devices, U())
    end
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroReservoir, U <: HydroWaterModelReservoir}
    PSI.add_proportional_cost!(container, HydroWaterSurplusVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroWaterShortageVariable(), devices, U())
    PSI.add_proportional_cost!(container, WaterSpillageVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroPumpTurbine, U <: AbstractHydroPumpFormulation}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    PSI.add_variable_cost!(container, ActivePowerPumpVariable(), devices, U())
    return
end

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {
    T <: PSY.Component,
    U <:
    Union{HydroEnergySurplusVariable, HydroEnergyShortageVariable, WaterSpillageVariable},
    V <: PSI.AbstractDeviceFormulation,
}
    base_p = PSI.get_base_power(container)
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        cost_term = PSI.proportional_cost(op_cost_data, U(), d, V())
        iszero(cost_term) && continue
        for t in PSI.get_time_steps(container)
            PSI._add_proportional_term!(
                container,
                U(),
                d,
                cost_term * multiplier * base_p,
                t,
            )
        end
    end
    return
end

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {
    T <: PSY.HydroReservoir,
    U <:
    Union{HydroEnergySurplusVariable, HydroEnergyShortageVariable, WaterSpillageVariable},
    V <: HydroEnergyModelReservoir,
}
    base_p = PSI.get_base_power(container)
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        cost_term = PSI.proportional_cost(op_cost_data, U(), d, V())
        iszero(cost_term) && continue
        for t in PSI.get_time_steps(container)
            PSI._add_proportional_term!(
                container,
                U(),
                d,
                cost_term * multiplier * base_p,
                t,
            )
        end
    end
    return
end

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {
    T <: PSY.HydroReservoir,
    U <: Union{HydroBalanceShortageVariable, HydroBalanceSurplusVariable},
    V <: HydroEnergyModelReservoir,
}
    base_p = PSI.get_base_power(container)
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        cost_term = PSI.proportional_cost(op_cost_data, U(), d, V())
        iszero(cost_term) && continue
        time_steps = PSI.get_time_steps(container)
        for t in time_steps
            PSI._add_proportional_term!(
                container,
                U(),
                d,
                cost_term * multiplier * base_p,
                t,
            )
        end
    end
    return
end

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {
    T <: PSY.HydroReservoir,
    U <: Union{HydroWaterSurplusVariable, HydroWaterShortageVariable},
    V <: HydroWaterModelReservoir,
}
    base_p = PSI.get_base_power(container)
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        cost_term = PSI.proportional_cost(op_cost_data, U(), d, V())
        iszero(cost_term) && continue
        for t in PSI.get_time_steps(container)
            PSI._add_proportional_term!(
                container,
                U(),
                d,
                cost_term * multiplier * base_p,
                t,
            )
        end
    end
    return
end

############################################################################
##################### Update Initial Conditions ############################
############################################################################

function PSI.update_initial_conditions!(
    ics::Vector{T},
    store::PSI.EmulationModelStore,
    ::Dates.Millisecond,
) where {
    T <: Union{
        PSI.InitialCondition{InitialReservoirVolume, Float64},
        PSI.InitialCondition{InitialReservoirVolume, JuMP.VariableRef},
        PSI.InitialCondition{InitialReservoirVolume, Nothing},
    },
}
    for ic in ics
        var_val = PSI.get_variable_value(
            store,
            HydroReservoirVolumeVariable(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(
            ic,
            PSI.get_last_recorded_value(var_val)[PSI.get_component_name(ic)],
        )
    end
    return
end

function PSI.update_initial_conditions!(
    ics::Vector{T},
    state::PSI.SimulationState,
    ::Dates.Millisecond,
) where {
    T <: Union{
        PSI.InitialCondition{InitialReservoirVolume, Float64},
        PSI.InitialCondition{InitialReservoirVolume, JuMP.VariableRef},
        PSI.InitialCondition{InitialReservoirVolume, Nothing},
    },
}
    for ic in ics
        var_val = PSI.get_system_state_value(
            state,
            HydroReservoirVolumeVariable(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(ic, var_val[PSI.get_component_name(ic)])
    end
    return
end

##### Pump Turbine Constraints #####

"""
Add semicontinuous LB range constraints for [`HydroPumpEnergyDispatch`](@ref) formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintLBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyDispatch,
    X <: PM.AbstractPowerModel,
}
    if !PSI.get_attribute(model, "reservation")
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    else
        array = PSI.get_expression(container, U(), V)
        reservation = PSI.get_variable(container, PSI.ReservationVariable(), V)
        time_steps = PSI.get_time_steps(container)
        device_names = [PSY.get_name(d) for d in devices]
        con_lb = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "lb",
        )
        for device in devices, t in time_steps
            ci_name = PSY.get_name(device)
            limits = PSI.get_min_max_limits(device, T, W)
            con_lb[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] >= limits.min * reservation[ci_name, t]
                )
        end
    end
    return
end

"""
Add semicontinuous UB range constraints for [`HydroPumpEnergyDispatch`](@ref) formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintUBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyDispatch,
    X <: PM.AbstractPowerModel,
}
    if !PSI.get_attribute(model, "reservation")
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    else
        array = PSI.get_expression(container, U(), V)
        reservation = PSI.get_variable(container, PSI.ReservationVariable(), V)
        time_steps = PSI.get_time_steps(container)
        device_names = [PSY.get_name(d) for d in devices]
        con_ub = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "ub",
        )
        for device in devices, t in time_steps
            ci_name = PSY.get_name(device)
            limits = PSI.get_min_max_limits(device, T, W)
            con_ub[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] <= limits.max * reservation[ci_name, t]
                )
        end
    end
    return
end

"""
Add semicontinuous LB range constraints for [`HydroPumpEnergyCommitment`](@ref) formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintLBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyCommitment,
    X <: PM.AbstractPowerModel,
}
    if !PSI.get_attribute(model, "reservation")
        PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    else
        array = PSI.get_expression(container, U(), V)
        reservation = PSI.get_variable(container, PSI.ReservationVariable(), V)
        onvar = PSI.get_variable(container, PSI.OnVariable(), V)
        time_steps = PSI.get_time_steps(container)
        device_names = [PSY.get_name(d) for d in devices]
        con_lb = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "lb",
        )
        con_lb_aux = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "lb_aux",
        )
        for device in devices, t in time_steps
            ci_name = PSY.get_name(device)
            limits = PSI.get_min_max_limits(device, T, W)
            con_lb[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] >= limits.min * reservation[ci_name, t]
                )
            con_lb_aux[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] >= limits.min * onvar[ci_name, t]
                )
        end
    end
    return
end

"""
Add semicontinuous UB range constraints for [`HydroPumpEnergyCommitment`](@ref) formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintUBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyCommitment,
    X <: PM.AbstractPowerModel,
}
    if !PSI.get_attribute(model, "reservation")
        PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    else
        array = PSI.get_expression(container, U(), V)
        reservation = PSI.get_variable(container, PSI.ReservationVariable(), V)
        onvar = PSI.get_variable(container, PSI.OnVariable(), V)
        time_steps = PSI.get_time_steps(container)
        device_names = [PSY.get_name(d) for d in devices]
        con_ub = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "ub",
        )
        con_ub_aux = PSI.add_constraints_container!(
            container,
            T(),
            V,
            device_names,
            time_steps;
            meta = "ub_aux",
        )
        for device in devices, t in time_steps
            ci_name = PSY.get_name(device)
            limits = PSI.get_min_max_limits(device, T, W)
            con_ub[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] <= limits.max * reservation[ci_name, t]
                )
            con_ub_aux[ci_name, t] =
                JuMP.@constraint(
                    PSI.get_jump_model(container),
                    array[ci_name, t] <= limits.max * onvar[ci_name, t]
                )
        end
    end
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.InputActivePowerVariableLimitsConstraint},
    U::Type{ActivePowerPumpVariable},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyCommitment,
    X <: PM.AbstractPowerModel,
}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

"""
This function defines the constraints for the pump power
for the [`PowerSystems.HydroPumpTurbine`](@extref).
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ActivePowerPumpReservationConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpTurbine,
    W <: AbstractHydroPumpFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    power_var = PSI.get_variable(container, ActivePowerPumpVariable(), V)
    reservation_var = PSI.get_variable(container, PSI.ReservationVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        ActivePowerPumpReservationConstraint(),
        V,
        names,
        time_steps,
    )

    for device in devices
        name = PSY.get_name(device)
        pump_max = PSI.get_variable_upper_bound(ActivePowerPumpVariable(), device, W())
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                power_var[name, t] <= pump_max * (1 - reservation_var[name, t])
            )
        end
    end
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    T <: PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
    U <: PSI.ActivePowerRangeExpressionUB,
    V <: PSY.HydroPumpTurbine,
    W <: HydroPumpEnergyDispatch,
    X <: PM.AbstractPowerModel,
}
    PSI.add_parameterized_upper_bound_range_constraints(
        container,
        T,
        U,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    T <: HydroServedReserveUpExpression,
    U <: PSI.ActivePowerReserveVariable,
    V <: PSY.HydroGen,
    W <: PSI.AbstractDeviceFormulation,
    X <: PM.AbstractPowerModel,
}
    expression = PSI.get_expression(container, T(), V)
    for d in devices
        name = PSY.get_name(d)
        service_models = PSI.get_services(model)
        for service_model in service_models
            service_name = PSI.get_service_name(service_model)
            services = PSY.get_services(d)
            service_ix = findfirst(x -> PSY.get_name(x) == service_name, services)
            if isnothing(service_ix)
                #Device does not participate in this service but others might. Skipping.
                continue
            end
            service = services[service_ix]
            if isa(service, PSY.Reserve{PSY.ReserveUp})
                deployed_fraction = PSY.get_deployed_fraction(service)
                variable = PSI.get_variable(
                    container,
                    U(),
                    typeof(service),
                    service_name,
                )
                for t in PSI.get_time_steps(container)
                    PSI._add_to_jump_expression!(
                        expression[name, t],
                        variable[name, t],
                        deployed_fraction,
                    )
                end
            end
        end
    end
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    T <: HydroServedReserveDownExpression,
    U <: PSI.ActivePowerReserveVariable,
    V <: PSY.HydroGen,
    W <: PSI.AbstractDeviceFormulation,
    X <: PM.AbstractPowerModel,
}
    expression = PSI.get_expression(container, T(), V)
    for d in devices
        name = PSY.get_name(d)
        service_models = PSI.get_services(model)
        for service_model in service_models
            service_name = PSI.get_service_name(service_model)
            # Find service with the same name of the service_model, that should exist in the device
            services = PSY.get_services(d)
            service_ix = findfirst(x -> PSY.get_name(x) == service_name, services)
            if isnothing(service_ix)
                #Device does not participate in this service but others might. Skipping.
                continue
            end
            service = services[service_ix]
            if isa(service, PSY.Reserve{PSY.ReserveDown})
                deployed_fraction = PSY.get_deployed_fraction(service)
                variable = PSI.get_variable(
                    container,
                    U(),
                    typeof(service),
                    service_name,
                )
                for t in PSI.get_time_steps(container)
                    PSI._add_to_jump_expression!(
                        expression[name, t],
                        variable[name, t],
                        deployed_fraction,
                    )
                end
            end
        end
    end
end

###################################################################
##################### Hydro Usage Parameters ######################
###################################################################

function PSI._add_parameters!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    devices::V,
    model::PSI.DeviceModel{D, W},
) where {
    T <: HydroUsageLimitParameter,
    V <: Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    W <: AbstractHydroFormulation,
} where {D <: PSY.HydroGen}
    #@debug "adding" T D U _group = LOG_GROUP_OPTIMIZATION_CONTAINER
    names = [PSY.get_name(device) for device in devices]
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    HOURS_IN_DAY = 24
    mult = fraction_of_hour * length(time_steps) / HOURS_IN_DAY
    key = PSI.AuxVarKey{HydroEnergyOutput, D}("")
    parameter_container =
        PSI.add_param_container!(container, T(), D, key, names, [time_steps[end]])
    jump_model = PSI.get_jump_model(container)

    for d in devices
        name = PSY.get_name(d)
        PSI.set_multiplier!(parameter_container, 1.0, name, time_steps[end])
        PSI.set_parameter!(
            parameter_container,
            jump_model,
            mult * PSI.get_initial_parameter_value(T(), d, W()),
            name,
            time_steps[end],
        )
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: HydroServedReserveUpExpression,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveUp},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], 1.0)
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: HydroServedReserveDownExpression,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveDown},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], -1.0)
    end
    return
end

#### WaterBudget Parameters ###

function PSI._add_parameters!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    devices::V,
    model::PSI.DeviceModel{D, W},
) where {
    T <: WaterLevelBudgetParameter,
    V <: Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    W <: AbstractHydroFormulation,
} where {D <: PSY.HydroReservoir}
    #@debug "adding" T D U _group = LOG_GROUP_OPTIMIZATION_CONTAINER
    names = [PSY.get_name(device) for device in devices]
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    HOURS_IN_DAY = 24
    mult = fraction_of_hour * length(time_steps) / HOURS_IN_DAY
    key = PSI.ExpressionKey{TotalHydroFlowRateReservoirOutgoing, D}("")
    parameter_container =
        PSI.add_param_container!(container, T(), D, key, names, time_steps)
    jump_model = PSI.get_jump_model(container)

    for d in devices
        name = PSY.get_name(d)
        for t in time_steps
            PSI.set_multiplier!(parameter_container, 1.0, name, t)
            PSI.set_parameter!(
                parameter_container,
                jump_model,
                mult * PSI.get_initial_parameter_value(T(), d, W()),
                name,
                t,
            )
        end
    end
    return
end
