function get_available_reservoirs(sys::PSY.System)
    pump_turbines = PSY.get_components(PSY.get_available, PSY.HydroPumpTurbine, sys)
    available_reservoirs = PSY.get_components(get_available, PSY.HydroReservoir, sys)
    if isempty(pump_turbines)
        return available_reservoirs
    end
    reservoirs_in_pumps = Set{PSY.HydroReservoir}()
    for res in available_reservoirs
        upstream_turbines = PSY.get_upstream_turbines(res)
        downstream_turbines = PSY.get_downstream_turbines(res)
        for turb in vcat(upstream_turbines, downstream_turbines)
            if isa(turb, PSY.HydroPumpTurbine)
                push!(reservoirs_in_pumps, res)
                break
            end
        end
    end
    return PSY.get_components(
        x -> (PSY.get_available(x)) && (x ∉ reservoirs_in_pumps),
        PSY.HydroReservoir,
        sys,
    )
end

function get_available_turbines(
    d::PSY.HydroReservoir,
    ::Type{U},
) where {U <: Union{TotalHydroPowerReservoirIncoming, TotalHydroFlowRateReservoirIncoming}}
    return filter(PSY.get_available, PSY.get_upstream_turbines(d))
end

function get_available_turbines(
    d::PSY.HydroReservoir,
    ::Type{U},
) where {U <: Union{TotalHydroPowerReservoirOutgoing, TotalHydroFlowRateReservoirOutgoing}}
    return filter(PSY.get_available, PSY.get_downstream_turbines(d))
end
