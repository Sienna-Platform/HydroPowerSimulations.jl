# Welcome to HydroPowerSimulations.jl

## About

`HydroPowerSimulations.jl` is a [`Julia`](http://www.julialang.org) package that extends [`PowerSimulations.jl`](https://sienna-platform.github.io/PowerSimulations.jl/stable/) for modeling of hydro generation technology in operational simulations.

## About Sienna

`HydroPowerSimulations.jl` is part of the National Laboratory of the Rockies (formerly known as NREL)'s
[Sienna ecosystem](https://sienna-platform.github.io/Sienna/), an open source framework for
scheduling problems and dynamic simulations for power systems. The Sienna ecosystem can be
[found on GitHub](https://github.com/Sienna-Platform). It contains three applications:

  - [Sienna\Data](https://sienna-platform.github.io/Sienna/pages/applications/sienna_data.html) enables
    efficient data input, analysis, and transformation
  - [Sienna\Ops](https://sienna-platform.github.io/Sienna/pages/applications/sienna_ops.html) enables
    system scheduling simulations by formulating and solving optimization problems
  - [Sienna\Dyn](https://sienna-platform.github.io/Sienna/pages/applications/sienna_dyn.html) enables
    system transient analysis including small signal stability and full system dynamic
    simulations

Each application uses multiple packages in the [`Julia`](http://www.julialang.org)
programming language. `HydroPowerSimulations.jl` is part of Sienna\Ops: it extends
`PowerSimulations.jl` with hydro generation formulations for operations simulations.

## How to Use This Documentation

There are five main sections containing different information:

  - **Tutorials** - Detailed walk-throughs to help you *learn* how to use
    `HydroPowerSimulations.jl`
  - **How to...** - Directions to help *guide* your work for a particular task
  - **Explanation** - Additional details and background information to help you *understand*
    `HydroPowerSimulations.jl`, its structure, and how it works behind the scenes
  - **Reference** - Technical references and API for a quick *look-up* during your work
  - **Model Library** - Technical references of the data types and their functions that
    `HydroPowerSimulations.jl` uses to model power system components

`HydroPowerSimulations.jl` strives to follow the [Diátaxis](https://diataxis.fr/) documentation
framework.

## Installation and Quick Links

  - [Sienna installation page](https://sienna-platform.github.io/Sienna/SiennaDocs/docs/build/how-to/install/):
    Instructions to install `HydroPowerSimulations.jl` and other Sienna packages
  - [PowerSimulations.jl](https://sienna-platform.github.io/PowerSimulations.jl/stable/):
    Base operations models used with hydro models in `HydroPowerSimulations.jl`
  - [Central Sienna documentation](https://sienna-platform.github.io/Sienna/SiennaDocs/docs/build/index.html):
    Cross-linked documentation website for the core user-facing Sienna packages

* * *

HydroPowerSimulations has been developed as part of the Flexible Linked Analysis of Streamflow and Hydropower (FLASH), Reliability and Resilience of coordinated water Distribution and power Distribution (R2D2) and HydroWires-C projects at the U.S. Department of Energy's National Laboratory of the Rockies ([NLR](https://www.nlr.gov/), formerly NREL) Software Record SWR-23-110.


