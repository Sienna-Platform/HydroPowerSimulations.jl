"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of served reserve up for energy calculations
"""
struct HydroServedReserveUpExpression <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of served reserve down for energy calculations
"""
struct HydroServedReserveDownExpression <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total power into a reservoir, from all the upstream turbines connected to it
"""
struct TotalHydroPowerReservoirIncoming <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total power out of a reservoir, from all the downstream turbines connected to it
"""
struct TotalHydroPowerReservoirOutgoing <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total spillage power into a reservoir, from all the upstream reservoirs connected to it
"""
struct TotalSpillagePowerReservoirIncoming <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir`](@extref) that keep track
of total water flow turbined into a reservoir, from all the upstream turbines connected to it
"""
struct TotalHydroFlowRateReservoirIncoming <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir`](@extref) that keep track
of total water turbined for a reservoir, from all the downstream turbines connected to it
"""
struct TotalHydroFlowRateReservoirOutgoing <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total spillage water flow rate into a reservoir, from all the upstream reservoirs connected to it
"""
struct TotalSpillageFlowRateReservoirIncoming <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of total water turbined for a turbine, coming from multiple reservoirs
"""
struct TotalHydroFlowRateTurbineOutgoing <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.System`](@extref) that keep track
of the energy balance for the system in medium term planning
"""
struct EnergyBalanceExpression <: PSI.ExpressionType end

PSI.should_write_resulting_value(::Type{HydroServedReserveUpExpression}) = true
PSI.should_write_resulting_value(::Type{HydroServedReserveDownExpression}) = true
PSI.should_write_resulting_value(::Type{TotalHydroFlowRateReservoirOutgoing}) = true
PSI.should_write_resulting_value(::Type{TotalHydroFlowRateTurbineOutgoing}) = true
PSI.should_write_resulting_value(::Type{TotalHydroFlowRateReservoirIncoming}) = true