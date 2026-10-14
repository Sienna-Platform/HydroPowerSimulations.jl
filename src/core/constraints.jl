struct EnergyLimitConstraint <: PSI.ConstraintType end
"""
Struct to create the constraint that set-up the target for reservoir formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
e_t + e^\\text{shortage} + e^\\text{surplus} = \\text{EnergyTargetTimeSeriesParameter}_t, \\quad \\forall t \\in \\{1,\\dots, T\\}
```
"""
struct EnergyTargetConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that set-up the target for reservoir formulations. It can use head or volume as the storage variable.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
l_t + l^\\text{shortage} + l^\\text{surplus} = \\text{WaterTargetTimeSeriesParameter}_t, \\quad \\forall t \\in \\{1,\\dots, T\\}
```
"""
struct WaterTargetConstraint <: PSI.ConstraintType end
struct EnergyShortageVariableLimitsConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the budget for reservoir formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\sum_{t=1}^T p^\\text{hy}_t \\le \\sum_{t=1}^T \\text{EnergyBudgetTimeSeriesParameter}_t,
```
"""
struct EnergyBudgetConstraint <: PSI.ConstraintType end
"""
Struct to create the constraint that limits the budget for reservoir formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\sum_{t=1}^T f^\\text{hy}_t \\le \\sum_{t=1}^T \\text{WaterBudgetTimeSeriesParameter}_t,
```
"""
struct WaterBudgetConstraint <: PSI.ConstraintType end
struct EnergyCapacityConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the pump power  for hydro pump formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
p^\\text{pump}_t \\le \\text{ActivePowerTimeSeriesParameter}_t,
```
"""
struct ActivePowerPumpVariableLimitsConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the pump power based on the reservoir variable for hydro pump formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
p^\\text{pump}_t \\le P^\\text{max,pump} \\cdot (1 - \\text{ReservationVariable}_t),
```
"""
struct ActivePowerPumpReservationConstraint <: PSI.ConstraintType end

"""
Require `ReservationVariable` to be no greater than `OnVariable` for pump-turbine commitment.

Together with pumping bounds based on `OnVariable - ReservationVariable`, this permits off, pumping and generating states in [`HydroPumpEnergyCommitment`](@ref).
"""
struct HydroPumpReservationCommitmentConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the pump power  for hydro pump formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
e^\\text{pump}_t \\le \\text{EnergyCapacityTimeSeriesParameter}_t,
```
"""
struct EnergyCapacityTimeSeriesLimitsConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the hydro usage for hydro formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\sum_{t=1}^T E^\\text{hy}_t \\le  \\text{HydroUsageLimitParameter}_T,
```
"""
struct FeedForwardHydroUsageLimitConstraint <: PSI.ConstraintType end

"""
Struct to model turbine outflow limits

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\ p_{t} = \\Delta t (f^{Tu}_{t-1}(0.5 K_1 (v_{t} + v_{t-1}) + K_2))
```
"""
struct HydroPowerConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint for hydro reservoir storage

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\ v_{t} = v_{t-1} + \\Delta t (f^{UR}_{t-1} - f^{Sp}_{t-1} - f^{Tu}_{t-1})
```
"""
struct ReservoirInventoryConstraint <: PSI.ConstraintType end

"""
Struct to limit the turbine flow

```math
QW^{min} \\le \\sum_{j \\in J(i)}^T wq_{jt} \\le  QW^{max},
```
"""
struct TurbineFlowLimitConstraint <: PSI.ConstraintType end

"""
Struct to model turbine power output as a function of head

```math
p_{t} = \\eta \\rho g h_{t} f^{Tu}_{t},
```
"""
struct TurbinePowerOutputConstraint <: PSI.ConstraintType end

"""
Struct to model reservoir stored volume/head limits

```math
h_{t}^{min} \\le h_{t} \\le h_{t}^{max},
```
"""
struct ReservoirLevelLimitConstraint <: PSI.ConstraintType end

"""
Struct to model the final (target) volume/head storage constraint

```math
v_{T} = V^\\text{target},
```
"""
struct ReservoirLevelTargetConstraint <: PSI.ConstraintType end

"""
Struct to model the transformation from head to volume constraint

```math
v_{t} = h_{t} \\text{head_to_volume},
```
"""
struct ReservoirHeadToVolumeConstraint <: PSI.ConstraintType end

"""
Feedforward constraint to limit the water level budget for reservoir formulations.
"""
struct FeedForwardWaterLevelBudgetConstraint <: PSI.ConstraintType end

"""
Constraint to limit the active power pump variable during an event
"""
struct ActivePowerPumpOutageConstraint <: PSI.EventConstraint end
