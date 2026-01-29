############################ Hydro Generation Formulations #################################
# Defined in PSI copied here for reference
# abstract type PSI.AbstractHydroFormulation <: PSI.AbstractDeviceFormulation end
# abstract type PSI.AbstractHydroDispatchFormulation <: PSI.AbstractHydroFormulation end
# abstract type PSI.AbstractHydroUnitCommitment <: PSI.AbstractHydroFormulation end

abstract type AbstractHydroFormulation <: PSI.AbstractDeviceFormulation end
abstract type AbstractHydroDispatchFormulation <: AbstractHydroFormulation end
abstract type AbstractHydroReservoirFormulation <: AbstractHydroDispatchFormulation end
abstract type AbstractHydroUnitCommitment <: AbstractHydroFormulation end

"""
Formulation type to add injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroDispatchRunOfRiver <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref) and a budget
"""
struct HydroDispatchRunOfRiverBudget <: AbstractHydroDispatchFormulation end

"""
Formulation type to constrain hydropower production with an energy block optimization representation of the energy storage capacity and water inflow time series of a reservoir for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroWaterFactorModel <: AbstractHydroReservoirFormulation end

"""
Formulation type to add commitment and injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroCommitmentRunOfRiver <: AbstractHydroUnitCommitment end

"""
Formulation type to add reservoir methods with hydro turbines using water flow variables for [`PowerSystems.HydroReservoir`](@extref)
"""
struct HydroWaterModelReservoir <: AbstractHydroReservoirFormulation end

"""
Formulation type to add reservoir methods with hydro turbines using only energy inflow/outflow variables (no water flow variables) for [`PowerSystems.HydroReservoir`](@extref)
"""
struct HydroEnergyModelReservoir <: AbstractHydroReservoirFormulation end

"""
Formulation type to add injection variables for a HydroTurbine connected to reservoirs using a bilinear model (with water flow variables) [`PowerSystems.HydroGen`](@extref)
"""
struct HydroTurbineBilinearDispatch <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables for a HydroTurbine connected to reservoirs using a linear model [`PowerSystems.HydroGen`](@extref).
The model assumes a shallow reservoir. The head for the conversion between water flow and power can be approximated as a linear function of the water flow on which the head elevation is always the intake elevation.
"""
struct HydroTurbineWaterLinearDispatch <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables for a [`PowerSystems.HydroTurbine`](@extref) only using energy variables (no water flow variables)
"""
struct HydroTurbineEnergyDispatch <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables for a [`PowerSystems.HydroTurbine`](@extref) only using energy variables (no water flow variables) and commitment variables
"""
struct HydroTurbineEnergyCommitment <: AbstractHydroUnitCommitment end

abstract type AbstractHydroPumpFormulation <: AbstractHydroFormulation end
"""
Formulation type to add injection variables for a HydroPumpTurbine only using energy variables (no water flow variables)
"""
struct HydroPumpEnergyDispatch <: AbstractHydroPumpFormulation end

"""
Formulation type to add injection variables for a HydroPumpTurbine only using energy variables (no water flow variables) and commitment variables
"""
struct HydroPumpEnergyCommitment <: AbstractHydroPumpFormulation end
