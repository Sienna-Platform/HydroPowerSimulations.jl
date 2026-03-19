# HydroPowerSimulations.jl Repository Guide

> **Development Guidelines:** Always load [Sienna.md](./Sienna.md) development preferences, style conventions, and best practices for projects using Sienna. Before running tests confirm that the [Sienna.md](./Sienna.md) file has been read.

## Overview

HydroPowerSimulations.jl is an extension of PowerSimulations.jl that provides optimization models for hydroelectric generation technology. It is part of the Sienna ecosystem and was developed at NREL under the FLASH, R2D2, and HydroWires-C projects.

The package supports both **energy-based** (simplified, using MW/MWh) and **water-based** (detailed, using flow rates in m3/s, volumes in m3, and hydraulic head in meters) modeling approaches, including nonlinear bilinear power-flow-head relationships.

## Supported Device Types

Models are defined for the following PowerSystems.jl hydro device types:

- **HydroGen** - Abstract top level type for Hydro Power in Sienna
- **HydroDispatch** - Dispatch-only hydro supports Run of River and Energy Budgets, it is commonly used to aggregate hydro.
- **HydroTurbine** - Individual turbines in cascaded systems
- **HydroReservoir** - Reservoir storage with volume/head tracking, spillage, and inflows
- **HydroPumpTurbine** - Bidirectional pump-storage units connected to HydroReservoirs

## Key Formulations

| Formulation | Device | Description |
|---|---|---|
| HydroDispatchRunOfRiver | HydroGen/HydroDispatch | Basic run-of-river dispatch |
| HydroDispatchRunOfRiverBudget | HydroGen/HydroDispatch | Run-of-river with energy budget |
| HydroCommitmentRunOfRiver | HydroGen/HydroDispatch | Run-of-river with unit commitment |
| HydroTurbineEnergyDispatch | HydroTurbine | Turbine dispatch (energy model) |
| HydroTurbineEnergyCommitment | HydroTurbine | Turbine with commitment (energy model) |
| HydroTurbineBilinearDispatch | HydroTurbine | Nonlinear power-flow-head model |
| HydroTurbineWaterLinearDispatch | HydroTurbine | Linear power-flow model |
| HydroEnergyModelReservoir | HydroReservoir | Reservoir with energy balance |
| HydroWaterModelReservoir | HydroReservoir | Reservoir with water flow balance |
| HydroWaterFactorModel | HydroReservoir | Bilinear energy-block model with variable head |
| HydroPumpEnergyDispatch | HydroPumpTurbine | Pump-turbine dispatch |
| HydroPumpEnergyCommitment | HydroPumpTurbine | Pump-turbine with commitment |

## How It Extends PowerSimulations.jl

The package hooks into PowerSimulations via:

- **Custom formulations** registered for hydro device types
- **Hydro-specific variables**: `WaterSpillageVariable`, `HydroTurbineFlowRateVariable`, `HydroReservoirVolumeVariable`, `HydroReservoirHeadVariable`, energy shortage/surplus slacks, `ActivePowerPumpVariable`
- **Hydro-specific constraints**: reservoir inventory balance, turbine power output (efficiency x density x gravity x head x flow), head-to-volume conversion, energy/water budgets and targets, pump reservation
- **Expressions** tracking power and water flows into/out of reservoirs
- **Feedforward mechanisms** for hierarchical multi-stage optimization: `ReservoirTargetFeedforward`, `ReservoirLimitFeedforward`, `HydroUsageLimitFeedforward`, `WaterLevelBudgetFeedforward`
- **MediumTermHydroPlanning** decision model for medium-term planning

## Source Layout

```
src/
  core/                            # Type definitions (formulations, variables, constraints, expressions, parameters, initial conditions)
  hydro_generation.jl              # Variable and constraint constructors
  hydrogeneration_constructor.jl   # Device model setup
  hydro_decision_model.jl          # Medium-term planning model
  feedforwards.jl                  # Feedforward mechanisms
  contingency_model.jl             # Contingency modeling
```
