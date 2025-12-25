# Adaptive Stepping Visualization
# This demo shows how adaptive timestepping works in OrdinaryDiffEq.jl

using OrdinaryDiffEq
using Plots
using Printf

println("=" ^ 70)
println("Adaptive Stepping Demo - Visualizing Adaptive Timesteps")
println("=" ^ 70)

# =============================================================================
# Problem: Van der Pol Oscillator (μ = 5, stiff behavior)
# =============================================================================
println("\nSolving Van der Pol Oscillator with adaptive stepping")

function van_der_pol!(du, u, p, t)
    μ = p
    du[1] = u[2]
    du[2] = μ * (1 - u[1]^2) * u[2] - u[1]
end

# Parameters
μ = 5.0  # Stiffness parameter
u0 = [2.0, 0.0]
tspan = (0.0, 30.0)

# Solve with adaptive stepping
prob = ODEProblem(van_der_pol!, u0, tspan, μ)
sol_adaptive = solve(prob, Tsit5(), reltol=1e-6, abstol=1e-8)

println("  ✓ Adaptive solution computed")
println("  ✓ Number of steps: $(length(sol_adaptive.t))")
println("  ✓ Average step size: $(tspan[2] / length(sol_adaptive.t))")

# =============================================================================
# Visualization 1: Solution with Step Markers
# =============================================================================

# Create dense solution for smooth curve
t_dense = range(tspan[1], tspan[2], length=1000)
u_dense = [sol_adaptive(t) for t in t_dense]
x_dense = [u[1] for u in u_dense]

p1 = plot(t_dense, x_dense, lw=2, label="Solution", xlabel="Time", ylabel="x(t)",
    title="Van der Pol Oscillator (μ=$μ)", legend=:topright, dpi=300)

# Mark the actual timesteps
scatter!(p1, sol_adaptive.t, [u[1] for u in sol_adaptive.u], 
    marker=:circle, markersize=3, label="Adaptive Steps", alpha=0.6)

# =============================================================================
# Visualization 2: Step Sizes Over Time
# =============================================================================

step_sizes = diff(sol_adaptive.t)
t_steps = sol_adaptive.t[1:end-1]

p2 = plot(t_steps, step_sizes, lw=2, marker=:circle, markersize=3,
    xlabel="Time", ylabel="Step Size Δt", 
    title="Adaptive Step Sizes", legend=false, 
    yscale=:log10, dpi=300)

println("\n  Step size statistics:")
println("    • Minimum: $(@sprintf("%.6f", minimum(step_sizes)))")
println("    • Maximum: $(@sprintf("%.6f", maximum(step_sizes)))")
println("    • Ratio (max/min): $(@sprintf("%.1f", maximum(step_sizes)/minimum(step_sizes)))")

# =============================================================================
# Visualization 3: Phase Portrait with Step Density
# =============================================================================

p3 = plot(xlabel="x", ylabel="dx/dt", title="Phase Portrait with Step Density",
    legend=:topright, dpi=300)

# Plot trajectory
x_vals = [u[1] for u in sol_adaptive.u]
v_vals = [u[2] for u in sol_adaptive.u]
plot!(p3, x_vals, v_vals, lw=2, label="Trajectory", color=:blue)

# Color code points by step size (red = small steps, blue = large steps)
colors = log10.(step_sizes ./ minimum(step_sizes))
scatter!(p3, x_vals[1:end-1], v_vals[1:end-1], 
    marker=:circle, markersize=4, zcolor=colors, 
    label="Step Sizes", alpha=0.7, colorbar=true)

# =============================================================================
# Visualization 4: Comparison with Fixed Stepping
# =============================================================================

# Solve with fixed step size equal to average adaptive step
dt_fixed = tspan[2] / length(sol_adaptive.t)
sol_fixed = solve(prob, RK4(), dt=dt_fixed, adaptive=false)

println("\n  Fixed vs Adaptive stepping:")
println("    • Adaptive steps: $(length(sol_adaptive.t))")
println("    • Fixed steps: $(length(sol_fixed.t))")

p4 = plot(xlabel="Time", ylabel="x(t)", 
    title="Adaptive vs Fixed Stepping", legend=:topright, dpi=300)

plot!(p4, sol_adaptive.t, [u[1] for u in sol_adaptive.u], 
    lw=2, label="Adaptive ($(length(sol_adaptive.t)) steps)")
plot!(p4, sol_fixed.t, [u[1] for u in sol_fixed.u], 
    lw=2, ls=:dash, label="Fixed ($(length(sol_fixed.t)) steps)", alpha=0.8)

# =============================================================================
# Visualization 5: Step Rejection Regions
# =============================================================================

# Identify regions with small steps (likely rejected steps or stiff regions)
threshold = median(step_sizes)
small_step_regions = findall(step_sizes .< threshold)

p5 = plot(t_dense, x_dense, lw=2, label="Solution", xlabel="Time", ylabel="x(t)",
    title="Regions Requiring Small Steps", legend=:topright, dpi=300)

# Highlight regions with small steps
for i in small_step_regions
    vspan!(p5, [sol_adaptive.t[i], sol_adaptive.t[i+1]], 
        alpha=0.2, color=:red, label=(i==small_step_regions[1] ? "Small Steps" : ""))
end

# =============================================================================
# Visualization 6: Error Estimation and Control
# =============================================================================

# Compare solutions with different tolerances
sol_low = solve(prob, Tsit5(), reltol=1e-3, abstol=1e-5)
sol_med = solve(prob, Tsit5(), reltol=1e-6, abstol=1e-8)
sol_high = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-11)

p6 = plot(xlabel="Number of Steps", ylabel="Relative Tolerance",
    title="Steps vs Tolerance Trade-off", legend=:topright, dpi=300)

tols = [1e-3, 1e-6, 1e-9]
steps = [length(sol_low.t), length(sol_med.t), length(sol_high.t)]

plot!(p6, steps, tols, marker=:circle, markersize=8, lw=2,
    xscale=:log10, yscale=:log10, label="Tsit5()")

println("\n  Tolerance vs Steps:")
println("    • reltol=1e-3:  $(length(sol_low.t)) steps")
println("    • reltol=1e-6:  $(length(sol_med.t)) steps")
println("    • reltol=1e-9:  $(length(sol_high.t)) steps")

# =============================================================================
# Create Combined Figure
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, p5, p6, layout=(3, 2), size=(1400, 1600), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "02_adaptive_stepping.png")
savefig(combined_plot, output_file)

# =============================================================================
# Create Animation
# =============================================================================

println("\n" * "=" ^ 70)
println("Creating animation of adaptive stepping...")
println("=" ^ 70)

anim = @animate for i in 1:5:length(sol_adaptive.t)
    # Solution up to current time
    t_current = sol_adaptive.t[1:i]
    x_current = [u[1] for u in sol_adaptive.u[1:i]]
    
    # Current step sizes
    if i > 1
        steps_current = diff(t_current)
        t_steps_current = t_current[1:end-1]
    else
        steps_current = []
        t_steps_current = []
    end
    
    # Create two-panel plot
    p_sol = plot(t_current, x_current, lw=3, label="Solution", 
        xlabel="Time", ylabel="x(t)", title="Van der Pol Oscillator",
        xlim=tspan, ylim=(-3, 3), legend=:topright, dpi=150)
    scatter!(p_sol, t_current, x_current, marker=:circle, markersize=3, 
        label="Steps", alpha=0.6)
    
    p_steps = plot(xlabel="Time", ylabel="Step Size Δt",
        title="Adaptive Step Sizes", xlim=tspan, legend=false, 
        yscale=:log10, dpi=150)
    if length(steps_current) > 0
        plot!(p_steps, t_steps_current, steps_current, lw=2, marker=:circle, markersize=3)
    end
    
    plot(p_sol, p_steps, layout=(2, 1), size=(800, 800))
end

gif_file = joinpath("../outputs/animations", "adaptive_stepping.gif")
mkpath(dirname(gif_file))
gif(anim, gif_file, fps=15)

println("\n" * "=" ^ 70)
println("✓ Demo completed successfully!")
println("✓ Static plot saved to: $output_file")
println("✓ Animation saved to: $gif_file")
println("=" ^ 70)

println("\nKey Takeaways:")
println("  • Adaptive stepping adjusts step size based on local error")
println("  • Small steps are used in regions with rapid changes")
println("  • Large steps are used in smooth regions for efficiency")
println("  • Tolerance controls the accuracy vs speed trade-off")
println("  • Van der Pol oscillator shows ~$(round(Int, maximum(step_sizes)/minimum(step_sizes)))x variation in step sizes")
println("\nNext: Try solver_comparison_intro.jl to compare different solvers!")
