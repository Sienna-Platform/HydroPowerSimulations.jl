module HydroPowerSimulations

#################################################################################

###### Hydro Decision Models #######
export MediumTermHydroPlanning

######## Hydro Formulations ########
export HydroDispatchRunOfRiver
export HydroDispatchRunOfRiverBudget
export HydroCommitmentRunOfRiver
export HydroWaterFactorModel
export HydroWaterModelReservoir
export HydroTurbineBilinearDispatch
export HydroTurbineWaterLinearDispatch
export HydroEnergyModelReservoir
export HydroTurbineEnergyDispatch
export HydroTurbineEnergyCommitment
export HydroPumpEnergyDispatch
export HydroPumpEnergyCommitment

######## Hydro Variables ########
export WaterSpillageVariable
export HydroEnergyShortageVariable
export HydroEnergySurplusVariable
export HydroWaterShortageVariable
export HydroWaterSurplusVariable
export HydroReservoirHeadVariable
export HydroReservoirVolumeVariable
export HydroTurbineFlowRateVariable
export HydroBalanceShortageVariable
export HydroBalanceSurplusVariable
export ActivePowerPumpVariable

######## Hydro Aux Variables ########
export HydroEnergyOutput

######## Hydro parameters #######
export EnergyTargetTimeSeriesParameter
export EnergyBudgetTimeSeriesParameter
export WaterTargetTimeSeriesParameter
export WaterBudgetTimeSeriesParameter
export InflowTimeSeriesParameter
export OutflowTimeSeriesParameter
export ReservoirTargetParameter
export ReservoirLimitParameter
export HydroUsageLimitParameter
export WaterLevelBudgetParameter

######## Hydro Initial Conditions #######
export InitialReservoirVolume

######## Hydro Constraints #######
export EnergyTargetConstraint
export WaterTargetConstraint
export ActivePowerPumpReservationConstraint
export ActivePowerPumpVariableLimitsConstraint
export EnergyCapacityTimeSeriesLimitsConstraint
export EnergyBudgetConstraint
export WaterBudgetConstraint
export ReservoirLevelLimitConstraint
export ReservoirLevelTargetConstraint
export TurbinePowerOutputConstraint
export ReservoirHeadToVolumeConstraint
export ReservoirInventoryConstraint
export FeedForwardWaterLevelBudgetConstraint

######## Hydro feedforwards #######
export ReservoirTargetFeedforward
export ReservoirLimitFeedforward
export HydroUsageLimitFeedforward
export WaterLevelBudgetFeedforward

####### Hydro Expressions ########
export HydroServedReserveUpExpression
export HydroServedReserveDownExpression
export TotalHydroPowerReservoirIncoming
export TotalHydroPowerReservoirOutgoing
export TotalSpillagePowerReservoirIncoming
export TotalHydroFlowRateReservoirIncoming
export TotalHydroFlowRateReservoirOutgoing
export TotalSpillageFlowRateReservoirIncoming
export TotalHydroFlowRateTurbineOutgoing

#################################################################################
# Imports
import PowerSystems as PSY
import InfrastructureSystems as IS
import InfrastructureSystems.Simulation as ISSIM
import InfrastructureSystems.Optimization as ISOPT
import Dates
import PowerSimulations as PSI
import JuMP

# Import PM types this way to avoid dependency issues with PowerSimulations
const PM = PSI.PM

# import PowerSimulations: HydroDispatchRunOfRiver, HydroCommitmentRunOfRiver
# import PowerSimulations: HydroCommitmentRunOfRiver
# export HydroCommitmentRunOfRiver
# export HydroDispatchRunOfRiver

#################################################################################
# Includes
# Core includes
include("core/definitions.jl")
include("core/formulations.jl")
include("core/variables.jl")
include("core/constraints.jl")
include("core/expressions.jl")
include("core/parameters.jl")
include("core/initial_conditions.jl")
include("core/decision_models.jl")

# Models
include("hydro_generation.jl")
include("hydrogeneration_constructor.jl")
include("hydro_decision_model.jl")
include("feedforwards.jl")
include("contingency_model.jl")

# Utils
include("utils.jl")

end # module
