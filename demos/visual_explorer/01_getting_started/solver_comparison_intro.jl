# Solver Comparison Introduction
# Compare different ODE solvers on various problems

using OrdinaryDiffEq
using Plots
using Printf
using BenchmarkTools

println("=" ^ 70)
println("Solver Comparison Demo - Comparing Different ODE Solvers")
println("=" ^ 70)

# =============================================================================
# Helper Functions
# =============================================================================

function benchmark_solver(prob, solver, name)
    """Benchmark a solver and return timing info"""
    b = @benchmark solve($prob, $solver) samples=100 evals=5
    return (name=name, 
            time=median(b).time / 1e6,  # Convert to ms
            memory=b.memory / 1024,  # Convert to KB
            allocs=b.allocs)
end

# =============================================================================
# Problem 1: Non-stiff (Lorenz System)
# =============================================================================
println("\n1. Non-stiff Problem: Lorenz System")

function lorenz!(du, u, p, t)
    σ, ρ, β = p
    du[1] = σ * (u[2] - u[1])
    du[2] = u[1] * (ρ - u[3]) - u[2]
    du[3] = u[1] * u[2] - β * u[3]
end

u0 = [1.0, 0.0, 0.0]
tspan = (0.0, 100.0)
p = [10.0, 28.0, 8/3]

prob_lorenz = ODEProblem(lorenz!, u0, tspan, p)

# Solvers to compare
solvers_nonstiff = [
    (Euler(), "Euler (1st order)"),
    (Heun(), "Heun (2nd order)"),
    (RK4(), "RK4 (4th order)"),
    (Tsit5(), "Tsit5 (5th order)"),
    (Vern7(), "Vern7 (7th order)"),
    (Vern9(), "Vern9 (9th order)")
]

println("\n  Benchmarking non-stiff solvers...")
results_nonstiff = []
for (solver, name) in solvers_nonstiff
    try
        sol = solve(prob_lorenz, solver, reltol=1e-8, abstol=1e-8, maxiters=1e7)
        result = benchmark_solver(prob_lorenz, solver, name)
        push!(results_nonstiff, (result..., steps=length(sol.t)))
        println("    ✓ $name: $(round(result.time, digits=2)) ms, $(length(sol.t)) steps")
    catch e
        println("    ✗ $name: Failed")
    end
end

# =============================================================================
# Problem 2: Stiff (Van der Pol, μ=1000)
# =============================================================================
println("\n2. Stiff Problem: Van der Pol Oscillator (μ=1000)")

function van_der_pol!(du, u, p, t)
    μ = p
    du[1] = u[2]
    du[2] = μ * (1 - u[1]^2) * u[2] - u[1]
end

u0 = [2.0, 0.0]
tspan = (0.0, 3000.0)
μ = 1000.0

prob_stiff = ODEProblem(van_der_pol!, u0, tspan, μ)

# Solvers for stiff problems
solvers_stiff = [
    (Rosenbrock23(), "Rosenbrock23"),
    (Rodas4P(), "Rodas4P"),
    (Rodas5P(), "Rodas5P"),
    (TRBDF2(), "TRBDF2"),
    (KenCarp4(), "KenCarp4")
]

println("\n  Benchmarking stiff solvers...")
results_stiff = []
for (solver, name) in solvers_stiff
    try
        sol = solve(prob_stiff, solver, reltol=1e-6, abstol=1e-8, maxiters=1e7)
        result = benchmark_solver(prob_stiff, solver, name)
        push!(results_stiff, (result..., steps=length(sol.t)))
        println("    ✓ $name: $(round(result.time, digits=2)) ms, $(length(sol.t)) steps")
    catch e
        println("    ✗ $name: Failed - $e")
    end
end

# =============================================================================
# Visualization 1: Lorenz Solutions
# =============================================================================

p1 = plot(title="Lorenz System - Solver Comparison", xlabel="Time", ylabel="x(t)",
    legend=:topright, dpi=300)

for (solver, name) in solvers_nonstiff[3:end]  # Skip low-order for clarity
    sol = solve(prob_lorenz, solver, reltol=1e-8, abstol=1e-8)
    plot!(p1, sol.t, [u[1] for u in sol.u], label=name, lw=2, alpha=0.8)
end

# =============================================================================
# Visualization 2: Performance Comparison (Non-stiff)
# =============================================================================

p2 = plot(title="Non-stiff Solver Performance", xlabel="Time (ms)", ylabel="Number of Steps",
    legend=:topright, dpi=300, xscale=:log10, yscale=:log10)

for result in results_nonstiff[3:end]  # Skip low-order
    scatter!(p2, [result.time], [result.steps], 
        label=result.name, markersize=10, marker=:circle)
end

# Add ideal line
plot!(p2, [0.1, 100], [10, 10000], ls=:dash, lw=2, label="Ideal", color=:gray, alpha=0.5)

# =============================================================================
# Visualization 3: Van der Pol Solutions
# =============================================================================

p3 = plot(title="Stiff Van der Pol (μ=1000)", xlabel="Time", ylabel="x(t)",
    legend=:topright, dpi=300)

for (solver, name) in solvers_stiff[1:3]  # Show first 3 for clarity
    sol = solve(prob_stiff, solver, reltol=1e-6, abstol=1e-8)
    t_sample = range(tspan[1], tspan[2], length=1000)
    u_sample = [sol(t)[1] for t in t_sample]
    plot!(p3, t_sample, u_sample, label=name, lw=2, alpha=0.8)
end

# =============================================================================
# Visualization 4: Performance Comparison (Stiff)
# =============================================================================

p4 = plot(title="Stiff Solver Performance", xlabel="Time (ms)", ylabel="Number of Steps",
    legend=:topright, dpi=300, xscale=:log10, yscale=:log10)

for result in results_stiff
    scatter!(p4, [result.time], [result.steps], 
        label=result.name, markersize=10, marker=:circle)
end

# =============================================================================
# Visualization 5: Memory Usage Comparison
# =============================================================================

p5 = bar([r.name for r in results_nonstiff[3:end]], 
    [r.memory for r in results_nonstiff[3:end]],
    title="Memory Usage (Non-stiff)", ylabel="Memory (KB)", 
    legend=false, dpi=300, xrotation=45)

p6 = bar([r.name for r in results_stiff], 
    [r.memory for r in results_stiff],
    title="Memory Usage (Stiff)", ylabel="Memory (KB)", 
    legend=false, dpi=300, xrotation=45)

# =============================================================================
# Visualization 7: Comparison Table
# =============================================================================

println("\n" * "=" ^ 70)
println("Performance Summary")
println("=" ^ 70)

println("\nNon-stiff Solvers (Lorenz System):")
println("-" ^ 70)
println(@sprintf("%-20s %10s %10s %15s", "Solver", "Time (ms)", "Steps", "Memory (KB)"))
println("-" ^ 70)
for result in results_nonstiff
    println(@sprintf("%-20s %10.2f %10d %15.1f", 
        result.name, result.time, result.steps, result.memory))
end

println("\nStiff Solvers (Van der Pol μ=1000):")
println("-" ^ 70)
println(@sprintf("%-20s %10s %10s %15s", "Solver", "Time (ms)", "Steps", "Memory (KB)"))
println("-" ^ 70)
for result in results_stiff
    println(@sprintf("%-20s %10.2f %10d %15.1f", 
        result.name, result.time, result.steps, result.memory))
end

# =============================================================================
# Save Combined Figure
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, p5, p6, layout=(3, 2), size=(1400, 1600), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "03_solver_comparison_intro.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ Demo completed successfully!")
println("✓ Output saved to: $output_file")
println("=" ^ 70)

println("\nKey Takeaways:")
println("  • Higher-order methods (Vern7, Vern9) are most efficient for non-stiff problems")
println("  • Stiff problems require specialized solvers (Rosenbrock, TRBDF2)")
println("  • Trade-off between accuracy, speed, and memory usage")
println("  • Tsit5() is a good default for non-stiff problems")
println("  • Rodas5P() or TRBDF2() are good for stiff problems")
println("\nRecommendations:")
println("  • Use Tsit5() as default (good balance)")
println("  • Switch to Vern7() or Vern9() for high accuracy needs")
println("  • Use Rodas5P() for stiff problems")
println("  • Use TRBDF2() for very stiff problems")
println("\nNext: Explore work_precision.jl for detailed performance analysis!")
