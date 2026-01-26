####################################################################################################
##################################### FixedOutput ##################################################
####################################################################################################

"""
Construct model for [`PowerSystems.HydroGen``](@extref) with [`PowerSimulations.FixedOutput`](@extref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, PSI.FixedOutput},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, PSI.ReactivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    # Expression
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    ::PSI.OptimizationContainer,
    ::PSY.System,
    ::PSI.ModelConstructStage,
    ::PSI.DeviceModel{H, PSI.FixedOutput},
    ::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    # FixedOutput doesn't add any constraints to the model. This function covers
    # AbstractPowerModel and AbstractActivePowerModel
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, PSI.FixedOutput},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    # Expression
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

####################################################################################################
############################### HydroDispatchRunOfRiver ############################################
####################################################################################################

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiver`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiver`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

####################################################################################################
############################ HydroDispatchRunOfRiverBudget #########################################
####################################################################################################

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiverBudget`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroDispatchRunOfRiverBudget,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)
    if PSI.get_use_slacks(model)
        PSI.add_variables!(
            container,
            HydroEnergyShortageVariable,
            devices,
            D(),
        )
    end
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroDispatchRunOfRiverBudget,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiverBudget`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroDispatchRunOfRiverBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)
    if PSI.get_use_slacks(model)
        PSI.add_variables!(
            container,
            HydroEnergyShortageVariable,
            devices,
            D(),
        )
    end
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroDispatchRunOfRiverBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

################################################################################################
############################ HydroCommitmentRunOfRiver #########################################
################################################################################################

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentRunOfRiver`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentRunOfRiver, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentRunOfRiver`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    # this is erroring when there's a market bid cost.
    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

################################################################################################
############################ HydroEnergyModelReservoir #########################################
################################################################################################

"""
Construct model for [`PowerSystems.HydroReservoir`](@extref) with [`HydroEnergyModelReservoir`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroReservoir,
    D <: HydroEnergyModelReservoir,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_reservoirs(sys)
    T = HydroEnergyModelReservoir
    PSI.add_variables!(
        container,
        PSI.EnergyVariable,
        devices,
        T(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        T(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        T(),
    )
    PSI.add_variables!(
        container,
        HydroEnergySurplusVariable,
        devices,
        T(),
    )

    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)
    if PSI.get_attribute(model, "energy_target")
        PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    end
    if PSI.get_attribute(model, "hydro_budget")
        PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)
    end

    if PSI.get_use_slacks(model)
        PSI.add_variables!(
            container,
            HydroBalanceSurplusVariable,
            devices,
            T(),
        )
        PSI.add_variables!(
            container,
            HydroBalanceShortageVariable,
            devices,
            T(),
        )
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroReservoir,
    D <: HydroEnergyModelReservoir,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_reservoirs(sys)

    PSI.add_initial_condition!(
        container,
        devices,
        HydroEnergyModelReservoir(),
        PSI.InitialEnergyLevel(),
    )
    # Update expressions that depend on turbine variables
    PSI.add_expressions!(
        container,
        TotalHydroPowerReservoirIncoming,
        devices,
        model,
    )

    PSI.add_expressions!(
        container,
        TotalHydroPowerReservoirOutgoing,
        devices,
        model,
    )

    PSI.add_expressions!(
        container,
        TotalSpillagePowerReservoirIncoming,
        devices,
        model,
    )

    # Energy Balance Constraint
    PSI.add_constraints!(
        container,
        sys,
        PSI.EnergyBalanceConstraint,
        devices,
        model,
        network_model,
    )
    if PSI.get_attribute(model, "energy_target")
        PSI.add_constraints!(
            container,
            EnergyTargetConstraint,
            devices,
            model,
            network_model,
        )
    end

    if PSI.get_attribute(model, "hydro_budget")
        PSI.add_constraints!(
            container,
            sys,
            EnergyBudgetConstraint,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

########################################################################################
########################### HydroTurbineEnergyDispatch #################################
########################################################################################

"""
Construct model for [`PowerSystems.HydroTurbine`](@extref) with [`HydroTurbineEnergyDispatch`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyDispatch,
    S <: PM.AbstractPowerModel,
}
    # why is there no add_parameters here?
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyDispatch,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroTurbine`](@extref) with [`HydroTurbineEnergyDispatch`](@ref) Formulation with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyDispatch,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyDispatch,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

##########################################################################################
############################ HydroTurbineEnergyCommitment ################################
##########################################################################################

"""
Construct model for [`PowerSystems.HydroTurbine`](@extref) with [`HydroTurbineEnergyCommitment`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyCommitment,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyCommitment,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroTurbine`](@extref) with [`HydroTurbineEnergyCommitment`](@ref) Formulation with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyCommitment,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    PSI.process_market_bid_parameters!(container, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroTurbineEnergyCommitment,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

################################################################################################
########################### New Hydro Block Optimization Model #################################
################################################################################################
# HydroReservoir
"""
Construct model for [`PowerSystems.HydroReservoir`](@extref) with [`HydroWaterFactorModel`](@ref) Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroWaterFactorModel},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_reservoirs(sys)

    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroWaterFactorModel(),
    )
    PSI.add_variables!(
        container,
        HydroReservoirVolumeVariable,
        devices,
        HydroWaterFactorModel(),
    )

    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroWaterFactorModel},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_reservoirs(sys)

    PSI.add_initial_condition!(
        container,
        devices,
        HydroWaterFactorModel(),
        InitialReservoirVolume(),
    )

    PSI.add_constraints!(
        container,
        sys,
        ReservoirInventoryConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirLevelTargetConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)
    return
end

"""
Construct model for [`PowerSystems.HydroTurbine`](@extref) with [`HydroWaterFactorModel`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroWaterFactorModel,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        HydroTurbineFlowRateVariable,
        devices,
        HydroWaterFactorModel(),
    )

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.process_market_bid_parameters!(container, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: HydroWaterFactorModel,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        sys,
        HydroPowerConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

################################################################################################
############################## New Hydro Bilinear Model ########################################
################################################################################################

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, R},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroReservoir, R <: HydroWaterModelReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_reservoirs(sys)

    PSI.add_variables!(
        container,
        HydroReservoirHeadVariable,
        devices,
        R(),
    )
    PSI.add_variables!(
        container,
        HydroReservoirVolumeVariable,
        devices,
        R(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        R(),
    )
    PSI.add_variables!(
        container,
        HydroWaterShortageVariable,
        devices,
        R(),
    )
    PSI.add_variables!(
        container,
        HydroWaterSurplusVariable,
        devices,
        R(),
    )

    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, OutflowTimeSeriesParameter, devices, model)
    if PSI.get_attribute(model, "hydro_target")
        PSI.add_parameters!(container, WaterTargetTimeSeriesParameter, devices, model)
    end
    if PSI.get_attribute(model, "hydro_budget")
        PSI.add_parameters!(container, WaterBudgetTimeSeriesParameter, devices, model)
    end
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, R},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroReservoir, R <: HydroWaterModelReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_reservoirs(sys)

    PSI.add_expressions!(
        container,
        TotalHydroFlowRateReservoirOutgoing,
        devices,
        model,
    )

    PSI.add_expressions!(
        container,
        TotalHydroFlowRateReservoirIncoming,
        devices,
        model,
    )

    PSI.add_expressions!(
        container,
        TotalSpillageFlowRateReservoirIncoming,
        devices,
        model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        R(),
        InitialReservoirVolume(),
    )

    PSI.add_constraints!(
        container,
        ReservoirInventoryConstraint,
        HydroReservoirVolumeVariable,
        devices,
        model,
        network_model,
    )

    """
    if !has_waterbudget_feedforward(model)
        PSI.add_constraints!(
            container,
            ReservoirLevelTargetConstraint,
            devices,
            model,
            network_model,
        )
    end
    """

    PSI.add_constraints!(
        container,
        ReservoirLevelLimitConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirHeadToVolumeConstraint,
        devices,
        model,
        network_model,
    )

    if PSI.get_attribute(model, "hydro_target")
        PSI.add_constraints!(
            container,
            WaterTargetConstraint,
            devices,
            model,
            network_model,
        )
    end

    if PSI.get_attribute(model, "hydro_budget")
        PSI.add_constraints!(
            container,
            sys,
            WaterBudgetConstraint,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_feedforward_constraints!(container, model, devices)
    PSI.objective_function!(container, devices, model, S)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: Union{HydroTurbineBilinearDispatch, HydroTurbineWaterLinearDispatch},
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)
    reservoirs = get_available_reservoirs(sys)

    PSI.add_variables!(
        container,
        HydroTurbineFlowRateVariable,
        devices,
        reservoirs,
        D(),
    )

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.process_market_bid_parameters!(container, devices, model)
    if PSI.has_service_model(model)
        error("$D does not support service models yet")
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroTurbine,
    D <: Union{HydroTurbineBilinearDispatch, HydroTurbineWaterLinearDispatch},
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_expressions!(
        container,
        sys,
        TotalHydroFlowRateTurbineOutgoing,
        devices,
        model,
    )

    if PSI.has_service_model(model)
        error("$D does not support service models yet")
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        sys,
        TurbinePowerOutputConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)
    return
end

##########################################################
########### Hydro Pump Turbine Models ####################
##########################################################

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroPumpTurbine,
    D <: HydroPumpEnergyDispatch,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)
    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, ActivePowerPumpVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())

    if PSI.get_attribute(model, "reservation")
        PSI.add_variables!(container, PSI.ReservationVariable, devices, D())
    end

    PSI.process_market_bid_parameters!(container, devices, model)
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        ActivePowerPumpVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroPumpTurbine,
    D <: HydroPumpEnergyDispatch,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)
    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, ActivePowerPumpVariable, devices, D())

    if PSI.get_attribute(model, "reservation")
        PSI.add_variables!(container, PSI.ReservationVariable, devices, D())
    end

    PSI.process_market_bid_parameters!(container, devices, model)
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        ActivePowerPumpVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    PSI.add_event_arguments!(container, devices, model, network_model)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroPumpTurbine,
    D <: HydroPumpEnergyDispatch,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    if PSI.get_attribute(model, "reservation")
        PSI.add_constraints!(
            container,
            ActivePowerPumpReservationConstraint,
            devices,
            model,
            network_model,
        )
    end

    PSI.objective_function!(container, devices, model, S)
    PSI.add_event_constraints!(container, devices, model, network_model)
    PSI.add_constraint_dual!(container, sys, model)

    return
end
