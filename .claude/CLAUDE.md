# HydroPowerSimulations.jl — Claude Guide

Platform-wide Sienna conventions (performance, type stability, formatter, environments, code style) live in `.claude/Sienna.md` — read it too. This file is repo-specific and does not restate them.

## Purpose & place in the stack

`HydroPowerSimulations.jl` (HPS) is an **extension of PowerSimulations.jl** (PSI) that
provides device formulations for hydroelectric generation and reservoir storage. It does
not define its own operations/simulation framework — it registers hydro device models,
variables, constraints, expressions, parameters, initial conditions, and feedforwards
against PSI's interfaces, plus one decision model (`MediumTermHydroPlanning`).

Supports both **energy-based** (simplified, MW/MWh) and **water-based** (detailed: flow in
m³/s, volume in m³, hydraulic head in m) modeling, including nonlinear bilinear
power–flow–head relationships.

Dependencies (`Project.toml`): `PowerSimulations` (`^0.36`), `PowerSystems` (`5`),
`InfrastructureSystems` (`3`), `JuMP` (`1`), `Dates`. Julia `^1.10`. Current version `0.17.0`.

Note: there is **no `InfrastructureOptimizationModels` dependency**. The optimization
interfaces (`add_variables!`, `add_constraints!`, containers, keys) are reached through PSI,
and IS submodules are aliased as `ISSIM = InfrastructureSystems.Simulation` and
`ISOPT = InfrastructureSystems.Optimization`.

Standard import aliases in this package: `PSY`, `IS`, `ISSIM`, `ISOPT`, `PSI`, `JuMP`, and
`const PM = PSI.PM` (PowerModels reached via PSI to avoid a direct dep).

## PowerSystems.jl hydro type hierarchy

**CRITICAL:** `HydroReservoir` is NOT a subtype of `HydroGen`. They are separate branches
under `Device`. `HydroGen` is generation (no storage info); `HydroReservoir` is storage
(volume/head/spillage/inflows). Methods typed on `HydroGen` will NOT dispatch for
`HydroReservoir` — they need separate method definitions.

```
Device <: Component
├── HydroReservoir <: Device           # Storage (volume/head/spillage/inflows)
└── StaticInjection <: Device
    └── Generator <: StaticInjection
        └── HydroGen <: Generator      # Generation, no storage info
            ├── HydroDispatch <: HydroGen
            └── HydroUnit <: HydroGen   # abstract, unit-level turbines
                ├── HydroTurbine <: HydroUnit
                └── HydroPumpTurbine <: HydroUnit
```

## Formulation hierarchy (this package, `src/core/formulations.jl`)

These subtype PSI's `AbstractDeviceFormulation`:

```
AbstractHydroFormulation <: PSI.AbstractDeviceFormulation
├── AbstractHydroDispatchFormulation
│   └── AbstractHydroReservoirFormulation
├── AbstractHydroUnitCommitment
└── AbstractHydroPumpFormulation
```

| Formulation | Subtype of | Device | Notes |
|---|---|---|---|
| `HydroDispatchRunOfRiver` | Dispatch | HydroGen | basic run-of-river |
| `HydroDispatchRunOfRiverBudget` | Dispatch | HydroGen | run-of-river + energy budget |
| `HydroCommitmentRunOfRiver` | UnitCommitment | HydroGen | run-of-river + commitment |
| `HydroTurbineEnergyDispatch` | Dispatch | HydroTurbine | energy-only model |
| `HydroTurbineEnergyCommitment` | UnitCommitment | HydroTurbine | energy + commitment |
| `HydroTurbineBilinearDispatch` | Dispatch | HydroTurbine | nonlinear power–flow–head |
| `HydroTurbineWaterLinearDispatch` | Dispatch | HydroTurbine | linear power–flow (shallow reservoir, head ≈ intake elevation) |
| `HydroTurbineWaterLinearCommitment` | UnitCommitment | HydroTurbine | linear + `OnVariable` |
| `HydroEnergyModelReservoir` | Reservoir | HydroReservoir | reservoir energy balance |
| `HydroWaterModelReservoir` | Reservoir | HydroReservoir | reservoir water-flow balance |
| `HydroWaterFactorModel` | Reservoir | HydroGen | bilinear energy-block, variable head |
| `HydroPumpEnergyDispatch` | Pump | HydroPumpTurbine | pump-turbine dispatch |
| `HydroPumpEnergyCommitment` | Pump | HydroPumpTurbine | pump-turbine + commitment |

(`HydroTurbineWaterLinearCommitment` is exported but was missing from older docs — included
above.)

## How it plugs into PowerSimulations

HPS defines methods on PSI's generic functions, dispatched on `(model, formulation)`:

- `PSI.add_variables!`, `PSI.add_constraints!`, `PSI.add_to_expression!` — the bulk lives in
  `src/hydro_generation.jl` (~30+ constraint methods).
- Device-model setup / argument & model constructors in `src/hydrogeneration_constructor.jl`.
- `PSI.build_impl!(::PSI.DecisionModel{MediumTermHydroPlanning})` in `src/hydro_decision_model.jl`.
- Feedforwards subtype `PSI.AbstractAffectFeedforward` with `PSI.add_feedforward_arguments!`,
  `PSI.add_feedforward_constraints!`, `PSI.update_parameter_values!` overrides
  (`src/feedforwards.jl`).
- Event/contingency constraints via `PSI.add_event_constraints!` (`src/contingency_model.jl`).

## Main public API (all exports in `src/HydroPowerSimulations.jl`)

- **Decision model:** `MediumTermHydroPlanning`
- **Formulations:** the 13 structs in the table above
- **Variables:** `WaterSpillageVariable`, `HydroTurbineFlowRateVariable`,
  `HydroReservoirVolumeVariable`, `HydroReservoirHeadVariable`, `ActivePowerPumpVariable`,
  `HydroEnergyShortageVariable`/`Surplus`, `HydroWaterShortageVariable`/`Surplus`,
  `HydroBalanceShortageVariable`/`Surplus`; aux var `HydroEnergyOutput`
- **Parameters:** `EnergyTargetTimeSeriesParameter`, `EnergyBudgetTimeSeriesParameter`,
  `WaterTargetTimeSeriesParameter`, `WaterBudgetTimeSeriesParameter`,
  `InflowTimeSeriesParameter`, `OutflowTimeSeriesParameter`, `ReservoirTargetParameter`,
  `ReservoirLimitParameter`, `HydroUsageLimitParameter`, `WaterLevelBudgetParameter`
- **Initial conditions:** `InitialReservoirVolume`
- **Constraints:** `EnergyTargetConstraint`, `WaterTargetConstraint`, `EnergyBudgetConstraint`,
  `WaterBudgetConstraint`, `ReservoirInventoryConstraint`, `ReservoirHeadToVolumeConstraint`,
  `ReservoirLevelLimitConstraint`, `ReservoirLevelTargetConstraint`,
  `TurbinePowerOutputConstraint`, `ActivePowerPumpReservationConstraint`,
  `ActivePowerPumpVariableLimitsConstraint`, `EnergyCapacityTimeSeriesLimitsConstraint`,
  `FeedForwardWaterLevelBudgetConstraint`
- **Feedforwards:** `ReservoirTargetFeedforward`, `ReservoirLimitFeedforward`,
  `HydroUsageLimitFeedforward`, `WaterLevelBudgetFeedforward`
- **Expressions:** `Total{Hydro,Spillage}{Power,FlowRate}Reservoir{Incoming,Outgoing}` family,
  `TotalHydroFlowRateTurbineOutgoing`, `HydroServedReserve{Up,Down}Expression`

## Source layout (`src/`)

```
HydroPowerSimulations.jl           # module: exports, imports, include order
core/
  definitions.jl                   # constants (SECONDS_IN_HOUR, GRAVITATIONAL_CONSTANT, WATER_DENSITY, M3_TO_KM3)
  formulations.jl                  # formulation abstract types + structs
  variables.jl  constraints.jl  expressions.jl  parameters.jl  initial_conditions.jl
  decision_models.jl               # MediumTermHydroPlanning type
hydro_generation.jl                # PSI.add_variables!/add_constraints!/add_to_expression! methods
hydrogeneration_constructor.jl     # device model construction
hydro_decision_model.jl            # PSI.build_impl! for MediumTermHydroPlanning
feedforwards.jl                    # feedforward structs + PSI overrides
contingency_model.jl               # PSI.add_event_constraints! for contingencies
utils.jl
```

Include order is significant (Sienna rule): `core/definitions.jl` and `core/formulations.jl`
are included before everything else — new constants/types go there before any file that
references them.

## Optimization Model Construction Conventions

### `add_*!()` methods must not return collections
Methods that create variables, constraints, or expressions (`add_variables!`,
`add_constraints!`, `add_expressions!`, etc.) must always end with a bare `return` (i.e.,
return `nothing`). They must never return dicts or collections of JuMP objects. Instead,
instantiate the appropriate container via `add_*_container!` and store all created objects
there.

### Inline expressions when possible
Expression construction should be inlined at the point of use. Only store an expression in a
container when it is intended to be reused across multiple constraints or objective terms.
Avoid creating expression containers solely as intermediate computation steps.

## Conventions & gotchas

- `HydroReservoir` vs `HydroGen` dispatch split (see hierarchy) — the single most common
  source of "method not defined" surprises.
- Turbine power = efficiency × density × gravity × head × flow. Water-based formulations use
  the constants in `core/definitions.jl` (`GRAVITATIONAL_CONSTANT = 9.81`,
  `WATER_DENSITY = 1000.0`, `SECONDS_IN_HOUR = 3600`, `M3_TO_KM3 = 1e-9`).
- Bilinear (`HydroWaterFactorModel`, `HydroTurbineBilinearDispatch`) and water-linear models
  are not interchangeable with energy models — they introduce flow/head/volume variables.
- PM types are accessed via `const PM = PSI.PM`, never a direct PowerModels dep.

## Commands (verified)

Default branch is `main`. Always use `julia --project=<env>`.

```sh
# Tests — runner scans test/ and includes all test_*.jl via @includetests ARGS
julia --project=test test/runtests.jl
# Single test file (without the test_ prefix or .jl), e.g. test_hydro_simulations.jl:
julia --project=test test/runtests.jl hydro_simulations
# Instantiate test env
julia --project=test -e 'using Pkg; Pkg.instantiate()'

# Docs
julia --project=docs docs/make.jl

# Formatter (script lives at scripts/formatter/, has its own Project.toml that it activates)
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'
```

The test suite reuses PSI test utilities (`PSI_DIR/test/test_utils/*`), uses
`PowerSystemCaseBuilder` (PSB) for systems, runs Aqua checks, and uses a classic
`@includetests` runner (not ReTest). Mind PSB shared-state gotchas — see `.claude/Sienna.md`
and the `sienna-test-environment` guidance.

Test files: `test_device_hydro_constructors.jl`, `test_device_hydro_feedforwards.jl`,
`test_events.jl`, `test_hydro_simulations.jl`, `test_hydro_usage_ff.jl`,
`test_market_bid_cost.jl`, plus `testing_utils.jl`.
