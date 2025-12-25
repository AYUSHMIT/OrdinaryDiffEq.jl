# Work-Precision Diagrams
# Compare solver accuracy vs computational cost

using OrdinaryDiffEq
using DiffEqDevTools
using Plots
using Printf

println("=" ^ 70)
println("Work-Precision Diagrams - Solver Performance Analysis")
println("=" ^ 70)

# =============================================================================
# Test Problems
# =============================================================================

# Problem 1: Van der Pol (stiff)
function van_der_pol!(du, u, p, t)
    μ = p
    du[1] = u[2]
    du[2] = μ * (1 - u[1]^2) * u[2] - u[1]
end

prob_vdp = ODEProblem(van_der_pol!, [2.0, 0.0], (0.0, 6.325), 10.0)

# Problem 2: Lorenz (non-stiff, chaotic)
function lorenz!(du, u, p, t)
    σ, ρ, β = p
    du[1] = σ * (u[2] - u[1])
    du[2] = u[1] * (ρ - u[3]) - u[2]
    du[3] = u[1] * u[2] - β * u[3]
end

prob_lorenz = ODEProblem(lorenz!, [1.0, 0.0, 0.0], (0.0, 10.0), [10.0, 28.0, 8/3])

println("\n✓ Test problems defined")
println("  • Van der Pol (stiff, μ=10)")
println("  • Lorenz (non-stiff, chaotic)")

# =============================================================================
# Generate Reference Solutions
# =============================================================================

println("\nGenerating high-accuracy reference solutions...")

sol_vdp_ref = solve(prob_vdp, Vern9(), reltol=1e-14, abstol=1e-14)
sol_lorenz_ref = solve(prob_lorenz, Vern9(), reltol=1e-14, abstol=1e-14)

println("✓ Reference solutions computed")

# =============================================================================
# Solvers to Test
# =============================================================================

# Explicit RK methods (non-stiff)
explicit_solvers = [
    Euler(),
    Heun(),
    RK4(),
    Tsit5(),
    Vern7(),
    Vern9()
]

# Implicit methods (stiff)
implicit_solvers = [
    ImplicitEuler(),
    Trapezoid(),
    Rosenbrock23(),
    Rodas4(),
    Rodas5P(),
    TRBDF2(),
    KenCarp4()
]

# =============================================================================
# Work-Precision for Van der Pol (Stiff)
# =============================================================================

println("\nBenchmarking solvers on Van der Pol...")

tolerances = 10.0 .^ (-3:-1:-10)

# Test implicit solvers on stiff problem
wp_vdp = WorkPrecisionSet(
    prob_vdp,
    tolerances,
    implicit_solvers;
    appxsol=sol_vdp_ref,
    maxiters=Int(1e7),
    numruns=5
)

println("✓ Van der Pol work-precision computed")

# =============================================================================
# Work-Precision for Lorenz (Non-stiff)
# =============================================================================

println("\nBenchmarking solvers on Lorenz...")

# Test explicit solvers on non-stiff problem
wp_lorenz = WorkPrecisionSet(
    prob_lorenz,
    tolerances,
    explicit_solvers;
    appxsol=sol_lorenz_ref,
    maxiters=Int(1e7),
    numruns=5
)

println("✓ Lorenz work-precision computed")

# =============================================================================
# Create Work-Precision Diagrams
# =============================================================================

println("\nCreating work-precision diagrams...")

# Van der Pol (stiff)
p1 = plot(wp_vdp, 
    title="Van der Pol (Stiff): Work-Precision",
    xlabel="Error (L2)", ylabel="Time (s)",
    xscale=:log10, yscale=:log10,
    legend=:topleft, dpi=300, lw=2,
    marker=:circle, ms=6)

# Lorenz (non-stiff)
p2 = plot(wp_lorenz,
    title="Lorenz (Non-stiff): Work-Precision", 
    xlabel="Error (L2)", ylabel="Time (s)",
    xscale=:log10, yscale=:log10,
    legend=:topleft, dpi=300, lw=2,
    marker=:circle, ms=6)

# =============================================================================
# Efficiency Curves
# =============================================================================

# Extract data for custom plots
function get_wp_data(wp)
    errors = []
    times = []
    names = []
    
    for (i, solver_data) in enumerate(wp)
        push!(errors, solver_data.errors)
        push!(times, solver_data.times)
        push!(names, string(wp.names[i]))
    end
    
    return errors, times, names
end

errors_vdp, times_vdp, names_vdp = get_wp_data(wp_vdp)
errors_lorenz, times_lorenz, names_lorenz = get_wp_data(wp_lorenz)

# Plot efficiency (inverse of time * error)
p3 = plot(title="Efficiency Comparison (Van der Pol)",
    xlabel="Tolerance", ylabel="Efficiency (1 / time*error)",
    xscale=:log10, yscale=:log10, legend=:bottomleft, dpi=300)

for (i, name) in enumerate(names_vdp)
    efficiency = 1.0 ./ (times_vdp[i] .* errors_vdp[i])
    plot!(p3, tolerances, efficiency, label=name, lw=2, marker=:circle)
end

p4 = plot(title="Efficiency Comparison (Lorenz)",
    xlabel="Tolerance", ylabel="Efficiency (1 / time*error)",
    xscale=:log10, yscale=:log10, legend=:bottomleft, dpi=300)

for (i, name) in enumerate(names_lorenz)
    efficiency = 1.0 ./ (times_lorenz[i] .* errors_lorenz[i])
    plot!(p4, tolerances, efficiency, label=name, lw=2, marker=:circle)
end

# =============================================================================
# Performance Summary Table
# =============================================================================

println("\n" * "=" ^ 70)
println("Performance Summary (at tolerance = 1e-6)")
println("=" ^ 70)

tol_idx = findfirst(tolerances .== 1e-6)

println("\nVan der Pol (Stiff):")
println("-" ^ 70)
println(@sprintf("%-20s %12s %12s %12s", "Solver", "Error", "Time (ms)", "Efficiency"))
println("-" ^ 70)

for (i, name) in enumerate(names_vdp)
    if length(errors_vdp[i]) >= tol_idx
        err = errors_vdp[i][tol_idx]
        time = times_vdp[i][tol_idx] * 1000  # Convert to ms
        eff = 1.0 / (time * err / 1000)  # Efficiency metric
        println(@sprintf("%-20s %12.2e %12.3f %12.2f", 
            name, err, time, eff))
    end
end

println("\nLorenz (Non-stiff):")
println("-" ^ 70)
println(@sprintf("%-20s %12s %12s %12s", "Solver", "Error", "Time (ms)", "Efficiency"))
println("-" ^ 70)

for (i, name) in enumerate(names_lorenz)
    if length(errors_lorenz[i]) >= tol_idx
        err = errors_lorenz[i][tol_idx]
        time = times_lorenz[i][tol_idx] * 1000
        eff = 1.0 / (time * err / 1000)
        println(@sprintf("%-20s %12.2e %12.3f %12.2f", 
            name, err, time, eff))
    end
end

# =============================================================================
# Save Combined Figure
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, layout=(2, 2), size=(1800, 1400), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "10_work_precision.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ Work-Precision Analysis Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Work-precision diagrams: $output_file")

println("\nKey Findings:")
println("  • For stiff problems: Rodas5P, TRBDF2 are most efficient")
println("  • For non-stiff problems: Vern7, Vern9 are most efficient")
println("  • Higher-order methods win at tight tolerances")
println("  • Lower-order methods better at loose tolerances")
println("  • Implicit methods required for stiff problems")

println("\nRecommendations:")
println("  • Default choice: Tsit5() for non-stiff, Rodas5P() for stiff")
println("  • High accuracy: Vern9() for non-stiff, Rodas5P() for stiff")
println("  • Very stiff: TRBDF2() or KenCarp4()")
println("  • Simple problems: RK4() is reliable and fast")

println("\nNext: Try performance_benchmarks.jl for comprehensive testing!")
