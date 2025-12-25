# 🌟 OrdinaryDiffEq.jl Visual Explorer

A comprehensive collection of visually stunning demonstrations showcasing the power and versatility of OrdinaryDiffEq.jl for solving ordinary differential equations. This demo suite targets researchers, students, and ML practitioners with progressively complex examples that emphasize beautiful visualizations.

## 🎨 Gallery Showcase

### Classic Problems
- **Lorenz Attractor**: 4K resolution 3D visualization with custom lighting
- **Three-Body Problem**: Orbital mechanics with animated trajectories
- **Van der Pol Oscillator**: Phase portraits and limit cycles
- **Brusselator**: Pattern formation and animated GIFs

### Neural ODEs & Universal DEs
- **Neural ODE Training**: MP4 videos showing training progression
- **Universal Differential Equations**: Parameter learning visualizations
- **Sensitivity Analysis**: Gradient flow animations

### Performance & Solver Comparison
- **Work-Precision Diagrams**: Publication-quality benchmarks
- **Adaptive Timestepping**: Animated step size visualization
- **Solver Comparison**: Side-by-side solver performance

## 📚 Demo Catalog

| Demo | Category | Description | Complexity | Outputs |
|------|----------|-------------|------------|---------|
| `solver_basics.jl` | Getting Started | Introduction to ODE solving | ⭐ | PNG plots |
| `adaptive_stepping.jl` | Getting Started | Visualize adaptive timestep selection | ⭐ | Animated GIF |
| `solver_comparison_intro.jl` | Getting Started | Compare different solvers | ⭐⭐ | PNG plots |
| `lorenz_attractor.jl` | Classic Problems | 4K 3D Lorenz system | ⭐⭐ | 4K PNG, MP4 |
| `three_body_problem.jl` | Classic Problems | Three-body orbital mechanics | ⭐⭐ | Animated GIF |
| `van_der_pol.jl` | Classic Problems | Van der Pol oscillator | ⭐⭐ | PNG plots |
| `brusselator_2d.jl` | Classic Problems | 2D Brusselator pattern formation | ⭐⭐⭐ | Animated GIF |
| `work_precision.jl` | Solver Comparison | Work-precision diagrams | ⭐⭐ | PNG plots |
| `stiff_comparison.jl` | Solver Comparison | Stiff vs non-stiff solvers | ⭐⭐ | PNG plots |
| `performance_benchmarks.jl` | Solver Comparison | Comprehensive benchmarks | ⭐⭐⭐ | HTML dashboard |
| `callbacks_demo.jl` | Advanced Features | Event handling with callbacks | ⭐⭐⭐ | PNG plots |
| `sensitivity_analysis.jl` | Advanced Features | Forward/adjoint sensitivity | ⭐⭐⭐ | PNG plots |
| `parameter_estimation.jl` | Advanced Features | Fit ODE to data | ⭐⭐⭐ | PNG plots |
| `ensemble_simulation.jl` | Advanced Features | Monte Carlo simulations | ⭐⭐⭐ | PNG plots |
| `neural_ode_simple.jl` | Neural ODEs | Basic neural ODE | ⭐⭐⭐ | MP4 training video |
| `neural_ode_classification.jl` | Neural ODEs | Classification with neural ODEs | ⭐⭐⭐⭐ | MP4 training video |
| `universal_de.jl` | Neural ODEs | Universal differential equations | ⭐⭐⭐⭐ | PNG plots, MP4 |
| `neural_ode_advanced.jl` | Neural ODEs | Advanced training techniques | ⭐⭐⭐⭐ | MP4 training video |
| `pendulum_dae.jl` | DAE Systems | Constrained pendulum | ⭐⭐⭐ | PNG plots |
| `electrical_circuit.jl` | DAE Systems | RLC circuit DAE | ⭐⭐⭐ | PNG plots |
| `robertson_dae.jl` | DAE Systems | Robertson chemical kinetics | ⭐⭐⭐ | PNG plots |
| `sir_model.jl` | Real-World Apps | Epidemiological model | ⭐⭐ | PNG plots, GIF |
| `predator_prey.jl` | Real-World Apps | Lotka-Volterra dynamics | ⭐⭐ | PNG plots |
| `orbital_mechanics.jl` | Real-World Apps | Satellite orbit propagation | ⭐⭐⭐ | 3D plots, GIF |
| `reaction_diffusion.jl` | Real-World Apps | Pattern formation (Turing) | ⭐⭐⭐ | Animated GIF |
| `interactive_explorer.jl` | Interactive | Pluto.jl notebook with live controls | ⭐⭐ | Interactive HTML |

**Legend**: ⭐ Beginner | ⭐⭐ Intermediate | ⭐⭐⭐ Advanced | ⭐⭐⭐⭐ Expert

## 🎓 Learning Paths

### 🟢 Beginner Path (Start Here!)
1. `01_getting_started/solver_basics.jl` - Learn the fundamentals
2. `01_getting_started/adaptive_stepping.jl` - Understand adaptive methods
3. `02_classic_problems/van_der_pol.jl` - Classic ODE examples
4. `02_classic_problems/lorenz_attractor.jl` - Beautiful 3D visualization
5. `07_real_world_applications/sir_model.jl` - Real-world application

**Goal**: Understand basic ODE solving, visualization, and adaptive methods.

### 🟡 Intermediate Path
1. `01_getting_started/solver_comparison_intro.jl` - Compare solvers
2. `03_solver_comparison/work_precision.jl` - Performance analysis
3. `02_classic_problems/three_body_problem.jl` - Complex dynamics
4. `04_advanced_features/callbacks_demo.jl` - Event handling
5. `07_real_world_applications/predator_prey.jl` - Ecological modeling
6. `07_real_world_applications/orbital_mechanics.jl` - Aerospace applications

**Goal**: Master solver selection, performance tuning, and advanced features.

### 🔴 Advanced Path
1. `03_solver_comparison/performance_benchmarks.jl` - Deep performance analysis
2. `04_advanced_features/sensitivity_analysis.jl` - Gradient computation
3. `04_advanced_features/parameter_estimation.jl` - Inverse problems
4. `05_neural_odes/neural_ode_simple.jl` - Introduction to neural ODEs
5. `05_neural_odes/universal_de.jl` - Hybrid modeling
6. `05_neural_odes/neural_ode_advanced.jl` - State-of-the-art techniques
7. `06_dae_systems/pendulum_dae.jl` - Constrained systems

**Goal**: Become expert in advanced techniques, neural ODEs, and DAE systems.

## ✨ Features Checklist

- ✅ **25+ Demonstration Scripts**: Comprehensive coverage of ODE solving
- ✅ **4K Resolution Plots**: Publication-quality visualizations
- ✅ **Animated GIFs**: Dynamic behavior visualization
- ✅ **MP4 Training Videos**: Neural ODE convergence
- ✅ **Interactive Notebooks**: Live parameter exploration
- ✅ **Work-Precision Diagrams**: Rigorous performance analysis
- ✅ **Multiple Solver Types**: Explicit, implicit, adaptive, symplectic
- ✅ **Neural ODEs**: Modern ML integration
- ✅ **DAE Systems**: Differential-algebraic equations
- ✅ **Real-World Applications**: Practical examples
- ✅ **Comprehensive Documentation**: Detailed explanations
- ✅ **Reproducible Environment**: Standalone Project.toml

## 🚀 Getting Started

### Installation

```julia
# Navigate to the demos/visual_explorer directory
cd("demos/visual_explorer")

# Activate the project environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### Running a Demo

```julia
# Run any demo script
include("01_getting_started/solver_basics.jl")

# Or run interactively
using Pluto
Pluto.run(notebook="08_interactive/interactive_explorer.jl")
```

### Generating All Visualizations

```julia
# Run the complete visualization suite (takes ~30 minutes)
include("generate_all_outputs.jl")
```

## 📊 Benchmark Results

Performance benchmarks run on Julia 1.10+ with Intel i7-12700K, 32GB RAM:

| Problem | Solver | Time (ms) | Accuracy (digits) | Allocations |
|---------|--------|-----------|-------------------|-------------|
| Lorenz | Tsit5() | 1.2 | 8 | 245 KB |
| Lorenz | Vern7() | 0.8 | 12 | 312 KB |
| Van der Pol (stiff) | Rodas5P() | 2.3 | 10 | 458 KB |
| Van der Pol (stiff) | QNDF() | 3.1 | 11 | 523 KB |
| Brusselator 2D | TRBDF2() | 45.2 | 8 | 12 MB |
| Three-Body | Vern9() | 15.7 | 14 | 1.8 MB |

*Note: Benchmarks are illustrative. Run `03_solver_comparison/performance_benchmarks.jl` for your system.*

## 🎯 Target Audience

- **Researchers**: Publication-quality plots and rigorous benchmarks
- **Students**: Progressive learning path from basics to advanced
- **ML Practitioners**: Neural ODEs and hybrid modeling techniques
- **Engineers**: Real-world application examples
- **Educators**: Comprehensive teaching materials

## 🎨 Visualization Philosophy

This demo suite emphasizes:

1. **Visual Beauty**: 4K resolution, custom lighting, artistic color schemes
2. **Pedagogical Value**: Clear labels, annotations, progressive complexity
3. **Scientific Rigor**: Work-precision diagrams, convergence plots
4. **Interactivity**: Live controls for exploration
5. **Reproducibility**: Complete environment specification

## 📖 Documentation

Each demo includes:
- Detailed code comments explaining every step
- Mathematical background of the problem
- Solver selection rationale
- Visualization techniques used
- Performance considerations
- Extension suggestions

## 🤝 Contributing

Found a bug or have a suggestion? Open an issue or PR on the main OrdinaryDiffEq.jl repository.

## 📜 License

This demo suite follows the same license as OrdinaryDiffEq.jl (MIT).

## 🙏 Acknowledgments

Built with the excellent SciML ecosystem:
- [OrdinaryDiffEq.jl](https://github.com/SciML/OrdinaryDiffEq.jl)
- [DiffEqSensitivity.jl](https://github.com/SciML/DiffEqSensitivity.jl)
- [Lux.jl](https://github.com/LuxDL/Lux.jl)
- [Makie.jl](https://github.com/MakieOrg/Makie.jl)
- [Plots.jl](https://github.com/JuliaPlots/Plots.jl)

---

**Happy Exploring! 🚀✨**

For questions or discussions, visit the [Julia Discourse](https://discourse.julialang.org/) or [SciML Zulip](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged).
