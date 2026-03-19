"""
    ReservoirTargetFeedforward(
        component_type::Type{<:PowerSystems.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        target_period::Int,
        penalty_cost::Float64,
        meta = CONTAINER_KEY_EMPTY_META
    ) where {T}

Adds a constraint to enforce a minimum reservoir level target with a slack
variable associated with a penalty term.

# Arguments:

  - `component_type::Type{<:`[`PowerSystems.Component`](@extref)`}` : Specify the type of component on which the Feedforward will be applied
  - `source::Type{T}` : Specify the VariableType, ParameterType or AuxVariableType as the source of values for the Feedforward
  - `affected_values::Vector{DataType}` : Specify the variable on which the reservoir target will be applied using the source values
  - `target_period::Int` : Specify the time step at which the reservoir target will be applied.
  - `penalty_cost::Float64` : Specify the penalty cost for not reaching the desired reservoir target.
"""
struct ReservoirTargetFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    target_period::Int
    penalty_cost::Float64
    function ReservoirTargetFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        target_period::Int,
        penalty_cost::Float64,
        meta = ISOPT.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.VariableKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.VariableType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "ReservoirTargetFeedforward is only compatible with VariableType or ParamterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
            target_period,
            penalty_cost,
        )
    end
end

PSI.get_default_parameter_type(::ReservoirTargetFeedforward, _) = ReservoirTargetParameter
PSI.get_optimization_container_key(ff::ReservoirTargetFeedforward) =
    ff.optimization_container_key

@doc raw"""
        add_feedforward_constraints(
            container::PSI.OptimizationContainer,
            ::PSI.DeviceModel,
            devices::IS.FlattenIteratorWrapper{T},
            ff::ReservoirTargetFeedforward,
        ) where {T <: PSY.Component}

Constructs a equality constraint to a fix a variable in one model using the variable value from other model results.


``` variable[var_name, t] + slack[var_name, t] >= param[var_name, t] ```

# LaTeX

`` x + slack >= param``

# Arguments
* `container::PSI.OptimizationContainer` : the optimization_container model built in PowerSimulations
* `model::`[`PowerSimulations.DeviceModel`](@extref) : the device model
* `devices::IS.FlattenIteratorWrapper{T}` : list of devices
* `ff::`[`ReservoirTargetFeedforward`](@ref) : a instance of the ReservoirTarget Feedforward
"""
function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    ::PSI.DeviceModel{T, U},
    devices::IS.FlattenIteratorWrapper{T},
    ff::ReservoirTargetFeedforward,
) where {T <: PSY.HydroReservoir, U <: AbstractHydroFormulation}
    time_steps = PSI.get_time_steps(container)
    parameter_type = PSI.get_default_parameter_type(ff, T)
    param = PSI.get_parameter_array(container, parameter_type(), T)
    multiplier = PSI.get_parameter_multiplier_array(container, parameter_type(), T)
    target_period = ff.target_period
    penalty_cost = ff.penalty_cost
    for var in PSI.get_affected_values(ff)
        variable = PSI.get_variable(container, var)
        slack_var = PSI.get_variable(container, HydroEnergyShortageVariable(), T)
        set_name, set_time = JuMP.axes(variable)
        IS.@assert_op set_name == [PSY.get_name(d) for d in devices]
        IS.@assert_op set_time == time_steps

        var_type = PSI.get_entry_type(var)
        con_ub = PSI.add_constraints_container!(
            container,
            PSI.FeedforwardEnergyTargetConstraint(),
            T,
            set_name;
            meta = "$(var_type)target",
        )

        for d in devices
            name = PSY.get_name(d)
            con_ub[name] = JuMP.@constraint(
                container.JuMPmodel,
                variable[name, target_period] + slack_var[name, target_period] >=
                param[name, target_period] * multiplier[name, target_period]
            )
            PSI.add_to_objective_invariant_expression!(
                container,
                slack_var[name, target_period] * penalty_cost,
            )
        end
    end
    return
end

function PSI._add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel{T, U},
    devices::IS.FlattenIteratorWrapper{T},
    ff::ReservoirTargetFeedforward,
) where {T <: PSY.HydroReservoir, U <: AbstractHydroFormulation}
    parameter_type = PSI.get_default_parameter_type(ff, T)
    PSI.add_parameters!(container, parameter_type, ff, model, devices)
    # Enabling this FF requires the addition of an extra variable
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        PSI.get_formulation(model)(),
    )
    return
end

"""
    ReservoirLimitFeedforward(
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        number_of_periods::Int,
        meta = CONTAINER_KEY_EMPTY_META
    ) where {T}

Adds a constraint to limit the sum of a variable over the number of periods to the source value.

# Arguments:

  - `component_type::Type{<:`[`PowerSystems.Component`](@extref)`}` : Specify the type of component on which the Feedforward will be applied
  - `source::Type{T}` : Specify the VariableType, ParameterType or AuxVariableType as the source of values for the Feedforward
  - `affected_values::Vector{DataType}` : Specify the variable on which the reservoir limit will be applied using the source values
  - `number_of_periods::Int` : Specify the total number of periods that are added on which the limits are applied. For example, in a 24-step simulation if `number_of_periods = 24`, it will add only one constraint over the sum of 24 periods on which the reservoir limit will be applied. If `number_of_periods = 12`, it will create two constraints, one for the first 12 steps and one for the 13:24 steps. It is mandatory that `number_of_periods` can divide the total number of simulation steps.
"""
struct ReservoirLimitFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    number_of_periods::Int
    function ReservoirLimitFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        number_of_periods::Int,
        meta = ISOPT.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.VariableKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.VariableType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "ReservoirLimitFeedforward is only compatible with VariableType or ParamterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
            number_of_periods,
        )
    end
end

PSI.get_default_parameter_type(::ReservoirLimitFeedforward, _) = ReservoirLimitParameter
PSI.get_optimization_container_key(ff::ReservoirLimitFeedforward) =
    ff.optimization_container_key
get_number_of_periods(ff::ReservoirLimitFeedforward) = ff.number_of_periods

@doc raw"""
        add_feedforward_constraints(container::PSI.OptimizationContainer,
                        model::PSI.DeviceModel,
                        devices,
                        ff::ReservoirLimitFeedforward)

Constructs a parameterized integral limit constraint to implement feedforward from other models.
The Parameters are initialized using the upper boundary values of the provided variables.


``` sum(variable[var_name, t] for t in 1:affected_periods)/affected_periods <= param_reference[var_name] ```

# LaTeX

`` \sum_{t} x \leq param^{max}``

# Arguments
* `container::PowerSimulations.OptimizationContainer` : the optimization_container model built in PowerSimulations
* `model::`[`PowerSimulations.DeviceModel`](@extref) : the device model
* `devices::IS.FlattenIteratorWrapper{T}` : list of devices
* `ff::`[`ReservoirLimitFeedforward`](@ref) : a instance of the Reservoir Limit Feedforward
"""
function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    ::PSI.DeviceModel,
    devices::IS.FlattenIteratorWrapper{T},
    ff::ReservoirLimitFeedforward,
) where {T <: PSY.Component}
    time_steps = PSI.get_time_steps(container)
    parameter_type = PSI.get_default_parameter_type(ff, T)
    param = PSI.get_parameter_array(container, parameter_type(), T)
    multiplier = PSI.get_parameter_multiplier_array(container, parameter_type(), T)
    affected_periods = get_number_of_periods(ff)
    for var in PSI.get_affected_values(ff)
        variable = PSI.get_variable(container, var)
        set_name, set_time = JuMP.axes(variable)
        IS.@assert_op set_name == [PSY.get_name(d) for d in devices]
        IS.@assert_op set_time == time_steps

        if affected_periods > set_time[end]
            error(
                "The number of affected periods $affected_periods is larger than the periods available $(set_time[end])",
            )
        end
        no_trenches = set_time[end] ÷ affected_periods
        var_type = PSI.get_entry_type(var)
        con_ub = PSI.add_constraints_container!(
            container,
            PSI.FeedforwardIntegralLimitConstraint(),
            T,
            set_name,
            1:no_trenches;
            meta = "$(var_type)integral",
        )

        for name in set_name, i in 1:no_trenches
            con_ub[name, i] = JuMP.@constraint(
                container.JuMPmodel,
                sum(
                    variable[name, t] for
                    t in (1 + (i - 1) * affected_periods):(i * affected_periods)
                ) <= sum(
                    param[name, t] * multiplier[name, t] for
                    t in (1 + (i - 1) * affected_periods):(i * affected_periods)
                )
            )
        end
    end
    return
end

function PSI.update_parameter_values!(
    model::PSI.DecisionModel,
    key::PSI.ParameterKey{T, U},
    input::PSI.DatasetContainer{PSI.InMemoryDataset},
) where {T <: ReservoirLimitParameter, U <: PSY.HydroGen}
    # Enable again for detailed debugging
    # TimerOutputs.@timeit RUN_SIMULATION_TIMER "$T $U Parameter Update" begin
    optimization_container = PSI.get_optimization_container(model)
    # Note: Do not instantite a new key here because it might not match the param keys in the container
    # if the keys have strings in the meta fields
    parameter_array = PSI.get_parameter_array(optimization_container, key)
    parameter_attributes = PSI.get_parameter_attributes(optimization_container, key)
    internal = PSI.get_internal(model)
    execution_count = internal.execution_count
    current_time = PSI.get_current_time(model)
    state_values =
        PSI.get_dataset_values(input, PSI.get_attribute_key(parameter_attributes))
    component_names, time = axes(parameter_array)
    resolution = PSI.get_resolution(model)
    interval_time_steps = Int(PSI.get_interval(PSI.get_store_params(model)) / resolution)
    state_data = PSI.get_dataset(input, PSI.get_attribute_key(parameter_attributes))
    state_timestamps = state_data.timestamps
    max_state_index = PSI.get_num_rows(state_data)

    state_data_index = PSI.find_timestamp_index(state_timestamps, current_time)
    sim_timestamps = range(current_time; step = resolution, length = time[end])
    old_parameter_values = PSI.jump_value.(parameter_array)
    # The current method uses older parameter values because when passing the energy output from one stage
    # to the next, the aux variable values gets over-written by the lower level model after its solve.
    # This approach is a temporary hack and will be replaced in future versions.
    for t in time
        timestamp_ix = min(max_state_index, state_data_index + 1)
        @debug "parameter horizon is over the step" max_state_index > state_data_index + 1
        if state_timestamps[timestamp_ix] <= sim_timestamps[t]
            state_data_index = timestamp_ix
        end
        for name in component_names
            # the if statement checks if its the first solve of the model and uses the values stored in the state
            # and for subsequent solves uses the state data to update the parameter values for the last set of time periods
            # that are equal to the length of the interval i.e. the time periods that dont overlap between each solves.
            if execution_count == 0 || t > time[end] - interval_time_steps
                # Pass indices in this way since JuMP DenseAxisArray don't support view()
                state_value = state_values[name, state_data_index]
                if !isfinite(state_value)
                    error(
                        "The value for the system state used in $(encode_key_as_string(key)) is not a finite value $(state_value) \
                         This is commonly caused by referencing a state value at a time when such decision hasn't been made. \
                         Consider reviewing your models' horizon and interval definitions",
                    )
                end
                PSI._set_param_value!(parameter_array, state_value, name, t)
            else
                # Currently the update method relies on using older parameter values of the EnergyLimitParameter
                # to update the parameter for overlapping periods between solves i.e. we ingoring the parameter values
                # in the model interval time periods.
                state_value = state_values[name, state_data_index]
                if !isfinite(state_value)
                    error(
                        "The value for the system state used in $(encode_key_as_string(key)) is not a finite value $(state_value) \
                         This is commonly caused by referencing a state value at a time when such decision hasn't been made. \
                         Consider reviewing your models' horizon and interval definitions",
                    )
                end
                PSI._set_param_value!(
                    parameter_array,
                    old_parameter_values[name, t + interval_time_steps],
                    name,
                    t,
                )
            end
        end
    end

    IS.@record :execution PSI.ParameterUpdateEvent(
        T,
        U,
        parameter_attributes,
        PSI.get_current_timestamp(model),
        PSI.get_name(model),
    )
    return
end

"""
    HydroUsageLimitFeedforward(
        component_type::Type{<:PowerSystems.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = CONTAINER_KEY_EMPTY_META
    ) where {T}

Adds a constraint to enforce a maximum usage of hydro energy based on the source value.
It is recommended to use the Auxiliary Variable HydroEnergyOutput as Source, affecting the HydroUsageLimitParameter.

# Arguments:

  - `component_type::Type{<:`[`PowerSystems.Component`](@extref)`}` : Specify the type of component on which the Feedforward will be applied
  - `source::Type{T}` : Specify the VariableType, ParameterType or AuxVariableType as the source of values for the Feedforward
  - `affected_values::Vector{DataType}` : Specify the variable on which the hydro limit will be applied using the source values
"""
struct HydroUsageLimitFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    function HydroUsageLimitFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = ISOPT.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.ParameterKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.ParameterType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "HydroUsageLimitFeedforward is only compatible with VariableType or ParameterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
        )
    end
end

PSI.get_default_parameter_type(::HydroUsageLimitFeedforward, _) =
    HydroUsageLimitParameter
PSI.get_optimization_container_key(ff::HydroUsageLimitFeedforward) =
    ff.optimization_container_key

function PSI.add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
) where {D <: PSY.HydroGen}
    for ff in PSI.get_feedforwards(model)
        PSI._add_feedforward_arguments!(container, model, devices, ff)
    end
    return
end

function PSI._add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    device_model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    ff::U,
) where {
    D <: PSY.HydroGen,
    U <: HydroUsageLimitFeedforward,
}
    parameter_type = PSI.get_default_parameter_type(ff, D)
    PSI._add_parameters!(container, parameter_type, devices, device_model)
    return
end

function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel,
    devices::Vector{V},
) where {V <: PSY.HydroGen}
    for ff in PSI.get_feedforwards(model)
        PSI.add_feedforward_constraints!(container, model, devices, ff)
    end
    return
end

function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    device_model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    ::HydroUsageLimitFeedforward,
) where {D <: PSY.HydroGen}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(d) for d in devices]
    power_var = PSI.get_variable(container, PSI.ActivePowerVariable(), D)
    T = FeedForwardHydroUsageLimitConstraint
    con_reservoir_ff = PSI.add_constraints_container!(container, T(), D, names)
    for device in devices
        ci_name = PSY.get_name(device)
        if PSI.built_for_recurrent_solves(container)
            param_value =
                PSI.get_parameter_array(container, HydroUsageLimitParameter(), D)[
                    ci_name,
                    time_steps[end],
                ]
            if PSI.has_service_model(device_model)
                served_reg_dn =
                    PSI.get_expression(container, HydroServedReserveDownExpression(), D)
                served_reg_up =
                    PSI.get_expression(container, HydroServedReserveUpExpression(), D)
                con_reservoir_ff[ci_name] = JuMP.@constraint(
                    PSI.get_jump_model(container),
                    fraction_of_hour * sum(
                        power_var[ci_name, :] + served_reg_up[ci_name, :] -
                        served_reg_dn[ci_name, :],
                    ) <= param_value
                )
            else
                con_reservoir_ff[ci_name] = JuMP.@constraint(
                    PSI.get_jump_model(container),
                    fraction_of_hour * sum(power_var[ci_name, :]) <= param_value
                )
            end
        end
    end
    return
end

function PSI.update_container_parameter_values!(
    optimization_container::PSI.OptimizationContainer,
    model::PSI.DecisionModel,
    key::PSI.ParameterKey{T, U},
    input::PSI.DatasetContainer{PSI.InMemoryDataset},
) where {
    T <: HydroUsageLimitParameter,
    U <: PSY.HydroGen,
}
    # Note: Do not instantiate a new key here because it might not match the param keys in the container
    # if the keys have strings in the meta fields
    parameter_array = PSI.get_parameter_array(optimization_container, key)
    parameter_attributes = PSI.get_parameter_attributes(optimization_container, key)
    current_time = PSI.get_current_time(model)
    state_values =
        PSI.get_dataset_values(input, PSI.get_attribute_key(parameter_attributes))
    component_names = axes(parameter_array)[1]
    model_resolution = PSI.get_resolution(optimization_container)
    state_data = PSI.get_dataset(input, PSI.get_attribute_key(parameter_attributes))
    state_timestamps = state_data.timestamps
    end_of_horizon_time =
        current_time +
        (PSI.get_time_steps(optimization_container)[end] - 1) * model_resolution
    state_data_index_start = PSI.find_timestamp_index(state_timestamps, current_time)
    state_data_index_end = PSI.find_timestamp_index(state_timestamps, end_of_horizon_time)
    for name in component_names
        param_value =
            max.(state_values[name, state_data_index_start:state_data_index_end], 1e-6)
        PSI.fix_parameter_value(
            parameter_array[name, state_data_index_end],
            sum(param_value),
        )
    end

    IS.@record :execution PSI.ParameterUpdateEvent(
        T,
        U,
        parameter_attributes,
        PSI.get_current_timestamp(model),
        PSI.get_name(model),
    )
    return
end

"""
    LevelTargetFeedforward(
        component_type::Type{<:PowerSystems.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = CONTAINER_KEY_EMPTY_META
    ) where {T}

Adds a constraint to enforce a minimum level (head or volume) for reservoirs based on the source value.
It is recommended to use the Volume or Head variable as Source, affecting the LevelTargetParameter.

# Arguments:

  - `component_type::Type{<:`[`PowerSystems.Component`](@extref)`}` : Specify the type of component on which the Feedforward will be applied
  - `source::Type{T}` : Specify the VariableType, ParameterType or AuxVariableType as the source of values for the Feedforward
  - `affected_values::Vector{DataType}` : Specify the variable on which the hydro limit will be applied using the source values
"""
struct LevelTargetFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    function LevelTargetFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = ISOPT.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.ParameterKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.ParameterType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "LevelTargetFeedforward is only compatible with VariableType or ParameterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
        )
    end
end

function PSI.get_optimization_container_key(
    ::T,
    ::Type{U},
    meta::String,
) where {T <: PSI.ExpressionType, U <: PSY.Component}
    return PSI.ExpressionKey(T, U, meta)
end

"""
    WaterLevelBudgetFeedforward(
        component_type::Type{<:PowerSystems.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = CONTAINER_KEY_EMPTY_META
    ) where {T}

Adds a constraint to enforce a maximum usage of hydro level volume based on the source value.
It is recommended to use the Auxiliary Variable TotalHydroFlowRateReservoirOutgoing as Source, affecting the WaterLevelBudgetParameter.

# Arguments:

  - `component_type::Type{<:`[`PowerSystems.Component`](@extref)`}` : Specify the type of component on which the Feedforward will be applied
  - `source::Type{T}` : Specify the VariableType, ParameterType or AuxVariableType as the source of values for the Feedforward
  - `affected_values::Vector{DataType}` : Specify the variable on which the hydro limit will be applied using the source values
"""
struct WaterLevelBudgetFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    function WaterLevelBudgetFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        meta = ISOPT.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.ParameterKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.ParameterType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "WaterLevelBudgetFeedforward is only compatible with VariableType or ParameterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
        )
    end
end

PSI.get_default_parameter_type(::WaterLevelBudgetFeedforward, _) =
    WaterLevelBudgetParameter
PSI.get_optimization_container_key(ff::WaterLevelBudgetFeedforward) =
    ff.optimization_container_key

function PSI.add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
) where {D <: PSY.HydroReservoir}
    for ff in PSI.get_feedforwards(model)
        PSI._add_feedforward_arguments!(container, model, devices, ff)
    end
    return
end

function PSI._add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    device_model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    ff::U,
) where {
    D <: PSY.HydroReservoir,
    U <: WaterLevelBudgetFeedforward,
}
    parameter_type = PSI.get_default_parameter_type(ff, D)
    PSI._add_parameters!(container, parameter_type, devices, device_model)
    return
end

function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel,
    devices::Vector{V},
) where {V <: PSY.HydroReservoir}
    for ff in PSI.get_feedforwards(model)
        PSI.add_feedforward_constraints!(container, model, devices, ff)
    end
    return
end

function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    device_model::PSI.DeviceModel,
    devices::Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    ::WaterLevelBudgetFeedforward,
) where {D <: PSY.HydroReservoir}
    #time_steps = PSI.get_time_steps(container)
    #resolution = PSI.get_resolution(container)
    #fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(d) for d in devices]
    water_out = PSI.get_expression(container, TotalHydroFlowRateReservoirOutgoing(), D)
    T = FeedForwardWaterLevelBudgetConstraint
    con_reservoir_ff = PSI.add_constraints_container!(container, T(), D, names)
    param_value =
        PSI.get_parameter_array(container, WaterLevelBudgetParameter(), D)
    #parameter_type = PSI.get_default_parameter_type(ff, T)
    #param = PSI.get_parameter_array(container, parameter_type(), T)
    #multiplier = PSI.get_parameter_multiplier_array(container, parameter_type(), T)
    for device in devices
        ci_name = PSY.get_name(device)
        if PSI.built_for_recurrent_solves(container)
            con_reservoir_ff[ci_name] = JuMP.@constraint(
                PSI.get_jump_model(container),
                sum(water_out[ci_name, :]) <= sum(param_value[ci_name, :])
            )
        end
    end
    return
end

function has_waterbudget_feedforward(
    model::PSI.DeviceModel,
)::Bool
    if isempty(model.feedforwards)
        return false
    end
    wb_feedforwards = [x for x in model.feedforwards if isa(x, WaterLevelBudgetFeedforward)]
    if isempty(wb_feedforwards)
        return false
    end
    return true
end
