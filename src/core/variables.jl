"""
Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network

Docs abbreviation: ``s``
"""
struct WaterSpillageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels < target storage levels

Docs abbreviation: ``e^\\text{shortage}``
"""
struct HydroEnergyShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels > target storage levels

Docs abbreviation: ``e^\\text{surplus}``
"""
struct HydroEnergySurplusVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for shortage on balance constraints

Docs abbreviation: ``e^\\text{b,shortage}``
"""
struct HydroBalanceShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for surplus on balance constraints

Docs abbreviation: ``e^\\text{b,surplus}``
"""
struct HydroBalanceSurplusVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for water storage levels < target storage levels

Docs abbreviation: ``l^\\text{shortage}``
"""
struct HydroWaterShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for water storage levels > target storage levels

Docs abbreviation: ``l^\\text{surplus}``
"""
struct HydroWaterSurplusVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for turbined flow rate (in m3/s).
"""
struct HydroTurbineFlowRateVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for volume stored in a hydro reservoir (in m3).
"""
struct HydroReservoirVolumeVariable <: PSI.VariableType end

"""
Aux variable which keeps track of water level (head) of hydro reservoirs (in m)
"""
struct HydroReservoirHeadVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for pumped power in a hydro pump turbine (in MWh).
"""
struct ActivePowerPumpVariable <: PSI.VariableType end

"""
Auxiliary Variable for Hydro Models that solve for total energy output

Docs abbreviation: ``E^\\text{hy,out}``
"""
struct HydroEnergyOutput <: PSI.AuxVariableType end

PSI.should_write_resulting_value(::Type{HydroTurbineFlowRateVariable}) = false
PSI.convert_result_to_natural_units(::Type{ActivePowerPumpVariable}) = true
