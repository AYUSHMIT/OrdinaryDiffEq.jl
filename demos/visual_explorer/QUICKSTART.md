# Quick Start Guide for Visual Explorer

## Installation

From the visual_explorer directory:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

This will install all required dependencies.

## Running Individual Demos

### Beginner Demos (Start Here!)

```julia
# Navigate to the demo directory
cd("demos/visual_explorer")

# Activate environment
using Pkg; Pkg.activate(".")

# Run your first demo
include("01_getting_started/solver_basics.jl")
```

### Classic Problems

```julia
# Beautiful 4K Lorenz attractor
include("02_classic_problems/lorenz_attractor.jl")

# Three-body orbital mechanics
include("02_classic_problems/three_body_problem.jl")
```

### Interactive Exploration

```julia
# Launch Pluto notebook
using Pluto
Pluto.run(notebook="08_interactive/interactive_explorer.jl")
```

Then open your browser and interact with the live controls!

## Running All Demos

To generate all visualizations:

```julia
include("generate_all_outputs.jl")
```

Note: This will take 20-30 minutes and requires significant compute resources.

## Output Locations

After running demos, find your visualizations in:

- `outputs/images/` - PNG plots (including 4K resolution)
- `outputs/animations/` - Animated GIFs
- `outputs/videos/` - MP4 videos

## Troubleshooting

### Missing Dependencies

If you get package errors:

```julia
using Pkg
Pkg.activate(".")
Pkg.resolve()
Pkg.instantiate()
```

### GLMakie Display Issues

If GLMakie doesn't display properly, use CairoMakie instead:

```julia
# In any demo, replace:
# using GLMakie
# with:
using CairoMakie
```

### Memory Issues

Some demos (especially 2D pattern formation) require significant memory. If you encounter issues:

1. Close other applications
2. Reduce grid size in the demo (look for `N = 32` or similar)
3. Run demos individually rather than all at once

## Demo Categories

1. **Getting Started** (⭐) - Perfect for beginners
   - solver_basics.jl
   - adaptive_stepping.jl
   - solver_comparison_intro.jl

2. **Classic Problems** (⭐⭐) - Iconic ODE systems
   - lorenz_attractor.jl (4K visualization!)
   - three_body_problem.jl
   - van_der_pol.jl
   - brusselator_2d.jl

3. **Solver Comparison** (⭐⭐) - Performance analysis
   - work_precision.jl
   - stiff_comparison.jl
   - performance_benchmarks.jl

4. **Advanced Features** (⭐⭐⭐) - Expert techniques
   - callbacks_demo.jl
   - sensitivity_analysis.jl
   - parameter_estimation.jl
   - ensemble_simulation.jl

5. **Neural ODEs** (⭐⭐⭐⭐) - Machine learning integration
   - neural_ode_simple.jl
   - neural_ode_classification.jl
   - universal_de.jl
   - neural_ode_advanced.jl

6. **DAE Systems** (⭐⭐⭐) - Constrained dynamics
   - pendulum_dae.jl
   - electrical_circuit.jl
   - robertson_dae.jl

7. **Real-World Applications** (⭐⭐) - Practical examples
   - sir_model.jl
   - predator_prey.jl
   - orbital_mechanics.jl
   - reaction_diffusion.jl

8. **Interactive** (⭐⭐) - Live exploration
   - interactive_explorer.jl (Pluto notebook)

## Learning Paths

### Path 1: Beginner (2-3 hours)
1. solver_basics.jl
2. adaptive_stepping.jl
3. van_der_pol.jl
4. lorenz_attractor.jl
5. sir_model.jl

### Path 2: Intermediate (5-6 hours)
1. All beginner demos
2. solver_comparison_intro.jl
3. work_precision.jl
4. three_body_problem.jl
5. callbacks_demo.jl
6. predator_prey.jl

### Path 3: Advanced (10+ hours)
1. All intermediate demos
2. sensitivity_analysis.jl
3. parameter_estimation.jl
4. neural_ode_simple.jl
5. universal_de.jl
6. pendulum_dae.jl

## Tips

- Start with beginner demos even if you're experienced
- Each demo is self-contained and can be run independently
- Read the code comments - they contain valuable insights
- Experiment by changing parameters
- Use the interactive notebook for real-time exploration
- Check the README.md for comprehensive documentation

## Getting Help

- Read the inline documentation in each script
- Check the main README.md for detailed explanations
- Visit [Julia Discourse](https://discourse.julialang.org/)
- Join [SciML Zulip](https://julialang.zulipchat.com/)

## Next Steps

After exploring these demos:

1. Modify parameters to see how solutions change
2. Try your own ODE problems
3. Combine techniques from multiple demos
4. Create your own visualizations
5. Contribute improvements back to the repository!

Happy exploring! 🚀✨
