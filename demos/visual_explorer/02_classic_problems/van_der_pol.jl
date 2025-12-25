# Van der Pol Oscillator
# Classic nonlinear oscillator with limit cycles

using OrdinaryDiffEq
using Plots
using Printf

println("=" ^ 70)
println("Van der Pol Oscillator - Nonlinear Oscillations")
println("=" ^ 70)

# =============================================================================
# Van der Pol Oscillator
# =============================================================================

"""
The Van der Pol oscillator is a nonlinear oscillator:
    d²x/dt² - μ(1 - x²)dx/dt + x = 0
    
Rewritten as a system:
    dx/dt = y
    dy/dt = μ(1 - x²)y - x
    
μ controls the nonlinearity and damping
"""

function van_der_pol!(du, u, p, t)
    μ = p
    x, y = u
    du[1] = y
    du[2] = μ * (1 - x^2) * y - x
end

# =============================================================================
# Explore Different Values of μ
# =============================================================================

println("\nExploring different μ values...")

u0 = [2.0, 0.0]
tspan = (0.0, 30.0)

μ_values = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
colors_μ = [:blue, :cyan, :green, :yellow, :orange, :red]

# Solve for each μ
solutions = []
for μ in μ_values
    prob = ODEProblem(van_der_pol!, u0, tspan, μ)
    sol = solve(prob, Tsit5())
    push!(solutions, (μ=μ, sol=sol))
    println("  ✓ μ = $μ: $(length(sol.t)) timesteps")
end

# =============================================================================
# Time Series for Different μ
# =============================================================================

p1 = plot(title="Van der Pol: Time Series", xlabel="Time", ylabel="x(t)",
    legend=:topright, dpi=300)

for (i, (μ, sol)) in enumerate(solutions)
    plot!(p1, sol.t, [u[1] for u in sol.u], 
        label="μ = $μ", lw=2, color=colors_μ[i])
end

# =============================================================================
# Phase Portraits
# =============================================================================

p2 = plot(title="Van der Pol: Phase Portraits", xlabel="x", ylabel="dx/dt",
    legend=:topright, dpi=300, aspect_ratio=:equal)

for (i, (μ, sol)) in enumerate(solutions[3:5])  # Show μ=1,2,5
    x = [u[1] for u in sol.u]
    y = [u[2] for u in sol.u]
    plot!(p2, x, y, label="μ = $(μ)", lw=2, color=colors_μ[i+2])
end

# =============================================================================
# Limit Cycle Convergence
# =============================================================================

println("\nAnalyzing limit cycle for μ=1...")

μ = 1.0
tspan_long = (0.0, 100.0)

# Different initial conditions
initial_conditions = [
    [0.1, 0.1],
    [3.0, 0.0],
    [0.5, 2.0],
    [-2.0, -1.0]
]

p3 = plot(title="Limit Cycle Convergence (μ=1)", xlabel="x", ylabel="dx/dt",
    legend=:topright, dpi=300)

for (i, u0_ic) in enumerate(initial_conditions)
    prob = ODEProblem(van_der_pol!, u0_ic, tspan_long, μ)
    sol = solve(prob, Tsit5())
    x = [u[1] for u in sol.u]
    y = [u[2] for u in sol.u]
    plot!(p3, x, y, label="IC $i", lw=2, alpha=0.7)
end

# =============================================================================
# Stiffness Analysis
# =============================================================================

println("\nAnalyzing stiffness for large μ...")

μ_stiff = 100.0
prob_stiff = ODEProblem(van_der_pol!, u0, (0.0, 3000.0), μ_stiff)

# Try with explicit solver
println("  • Solving with Tsit5 (explicit)...")
sol_explicit = solve(prob_stiff, Tsit5())
println("    Steps: $(length(sol_explicit.t))")

# Try with implicit solver
println("  • Solving with Rodas5P (implicit)...")
sol_implicit = solve(prob_stiff, Rodas5P())
println("    Steps: $(length(sol_implicit.t))")

p4 = plot(title="Stiff Problem (μ=100)", xlabel="Time", ylabel="x(t)",
    legend=:topright, dpi=300)
plot!(p4, sol_explicit.t, [u[1] for u in sol_explicit.u], 
    label="Tsit5 ($(length(sol_explicit.t)) steps)", lw=2)
plot!(p4, sol_implicit.t, [u[1] for u in sol_implicit.u], 
    label="Rodas5P ($(length(sol_implicit.t)) steps)", lw=2, ls=:dash)

println("  • Efficiency gain: $(round(length(sol_explicit.t)/length(sol_implicit.t), digits=1))x")

# =============================================================================
# Amplitude vs μ
# =============================================================================

println("\nAnalyzing amplitude vs μ...")

μ_range = 0.1:0.5:10.0
amplitudes = []

for μ in μ_range
    prob = ODEProblem(van_der_pol!, u0, (0.0, 50.0), μ)
    sol = solve(prob, Tsit5())
    # Get amplitude from last few periods
    x_late = [u[1] for u in sol.u[end-100:end]]
    amplitude = (maximum(x_late) - minimum(x_late)) / 2
    push!(amplitudes, amplitude)
end

p5 = plot(μ_range, amplitudes, marker=:circle, lw=2,
    xlabel="μ (nonlinearity)", ylabel="Limit Cycle Amplitude",
    title="Amplitude vs Nonlinearity", legend=false, dpi=300)

# =============================================================================
# Relaxation Oscillations (large μ)
# =============================================================================

println("\nDemonstrating relaxation oscillations...")

μ_relax = 20.0
prob_relax = ODEProblem(van_der_pol!, [2.0, 0.0], (0.0, 50.0), μ_relax)
sol_relax = solve(prob_relax, Rodas5P())

p6 = plot(layout=(2,1), size=(800, 800), dpi=300)

# Time series
plot!(p6[1], sol_relax.t, [u[1] for u in sol_relax.u],
    xlabel="Time", ylabel="x(t)", title="Relaxation Oscillations (μ=$μ_relax)",
    lw=2, legend=false)

# Phase portrait
x_relax = [u[1] for u in sol_relax.u]
y_relax = [u[2] for u in sol_relax.u]
plot!(p6[2], x_relax, y_relax,
    xlabel="x", ylabel="dx/dt", title="Phase Portrait",
    lw=2, legend=false)

# =============================================================================
# Save All Figures
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, p5, p6[1], layout=(3, 2), size=(1600, 1800), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "06_van_der_pol.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ Van der Pol Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Visualization: $output_file")

println("\nVan der Pol Oscillator Properties:")
println("  • Self-sustained oscillations (limit cycle)")
println("  • Energy is added for small amplitudes, removed for large")
println("  • For small μ: nearly sinusoidal")
println("  • For large μ: relaxation oscillations (fast/slow dynamics)")
println("  • All trajectories converge to same limit cycle (attractor)")
println("  • Becomes stiff for μ >> 1")

println("\nNext: Try brusselator_2d.jl for pattern formation!")
