# Lorenz Attractor: 4K High-Resolution 3D Visualization
# The iconic chaotic system with beautiful 3D visualization

using OrdinaryDiffEq
using GLMakie
using Colors
using Printf

println("=" ^ 70)
println("Lorenz Attractor Demo - 4K High-Resolution 3D Visualization")
println("=" ^ 70)

# =============================================================================
# The Lorenz System
# =============================================================================

"""
The Lorenz system is a set of three coupled ODEs that exhibit chaotic behavior:
    dx/dt = σ(y - x)
    dy/dt = x(ρ - z) - y
    dz/dt = xy - βz
    
Classical parameters: σ=10, ρ=28, β=8/3
"""

function lorenz!(du, u, p, t)
    σ, ρ, β = p
    x, y, z = u
    du[1] = σ * (y - x)
    du[2] = x * (ρ - z) - y
    du[3] = x * y - β * z
end

# Classical parameters
σ, ρ, β = 10.0, 28.0, 8.0/3.0
u0 = [1.0, 0.0, 0.0]
tspan = (0.0, 100.0)
p = [σ, ρ, β]

# Create and solve the problem
prob = ODEProblem(lorenz!, u0, tspan, p)
sol = solve(prob, Vern9(), reltol=1e-10, abstol=1e-12)

println("\n✓ Lorenz system solved")
println("  • Time span: $(tspan[1]) to $(tspan[2])")
println("  • Number of timesteps: $(length(sol.t))")
println("  • Final position: ($(round(sol[end][1], digits=2)), $(round(sol[end][2], digits=2)), $(round(sol[end][3], digits=2)))")

# Extract trajectory
x = [u[1] for u in sol.u]
y = [u[2] for u in sol.u]
z = [u[3] for u in sol.u]

# =============================================================================
# Create 4K Resolution 3D Visualization with Custom Lighting
# =============================================================================

println("\n" * "=" ^ 70)
println("Creating 4K visualization...")
println("=" ^ 70)

# Set up high-resolution figure (4K: 3840x2160)
fig = Figure(size=(3840, 2160), fontsize=32)

# Create 3D axis with custom styling
ax = Axis3(fig[1, 1], 
    title="Lorenz Attractor (σ=$σ, ρ=$ρ, β=$(round(β, digits=2)))",
    xlabel="X", ylabel="Y", zlabel="Z",
    aspect=:data,
    azimuth=2.2,
    elevation=0.3)

# Color the trajectory by time (showing evolution)
n_points = length(x)
colors_trajectory = collect(1:n_points) ./ n_points

# Create the main 3D line with gradient coloring
lines!(ax, x, y, z, 
    color=colors_trajectory,
    colormap=:turbo,
    linewidth=3,
    transparency=false)

# Add starting point marker
scatter!(ax, [x[1]], [y[1]], [z[1]], 
    color=:green, markersize=30, label="Start")

# Add ending point marker  
scatter!(ax, [x[end]], [y[end]], [z[end]], 
    color=:red, markersize=30, label="End")

# Add colorbar to show time evolution
Colorbar(fig[1, 2], limits=(0, tspan[2]), colormap=:turbo,
    label="Time")

# Add legend
axislegend(ax, position=:lt)

# Save 4K image
output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "04_lorenz_attractor_4k.png")
save(output_file, fig)

println("✓ 4K image saved to: $output_file")

# =============================================================================
# Create Multiple Views
# =============================================================================

println("\nCreating multi-view visualization...")

fig_multi = Figure(size=(2400, 1800), fontsize=24)

# 3D view
ax1 = Axis3(fig_multi[1, 1], 
    title="3D View",
    xlabel="X", ylabel="Y", zlabel="Z",
    aspect=:data)
lines!(ax1, x, y, z, color=colors_trajectory, colormap=:viridis, linewidth=2)

# XY projection
ax2 = Axis(fig_multi[1, 2], 
    title="XY Projection (Butterfly Wings)",
    xlabel="X", ylabel="Y",
    aspect=DataAspect())
lines!(ax2, x, y, color=colors_trajectory, colormap=:viridis, linewidth=2)

# XZ projection
ax3 = Axis(fig_multi[2, 1], 
    title="XZ Projection",
    xlabel="X", ylabel="Z",
    aspect=DataAspect())
lines!(ax3, x, z, color=colors_trajectory, colormap=:viridis, linewidth=2)

# YZ projection
ax4 = Axis(fig_multi[2, 2], 
    title="YZ Projection",
    xlabel="Y", ylabel="Z",
    aspect=DataAspect())
lines!(ax4, y, z, color=colors_trajectory, colormap=:viridis, linewidth=2)

output_file_multi = joinpath(output_dir, "04_lorenz_multiview.png")
save(output_file_multi, fig_multi)

println("✓ Multi-view image saved to: $output_file_multi")

# =============================================================================
# Create Time Series Plots
# =============================================================================

println("\nCreating time series visualization...")

fig_ts = Figure(size=(2000, 1200), fontsize=20)

# X component
ax_x = Axis(fig_ts[1, 1], 
    title="X Component", ylabel="X", xlabel="Time")
lines!(ax_x, sol.t, x, color=:red, linewidth=2)

# Y component
ax_y = Axis(fig_ts[2, 1], 
    title="Y Component", ylabel="Y", xlabel="Time")
lines!(ax_y, sol.t, y, color=:green, linewidth=2)

# Z component
ax_z = Axis(fig_ts[3, 1], 
    title="Z Component", ylabel="Z", xlabel="Time")
lines!(ax_z, sol.t, z, color=:blue, linewidth=2)

output_file_ts = joinpath(output_dir, "04_lorenz_timeseries.png")
save(output_file_ts, fig_ts)

println("✓ Time series image saved to: $output_file_ts")

# =============================================================================
# Create Animation (rotating view)
# =============================================================================

println("\nCreating rotation animation...")

# Create animation with rotating viewpoint
anim_dir = "../outputs/animations"
mkpath(anim_dir)

n_frames = 120
angles = range(0, 2π, length=n_frames)

# Create video
video_dir = "../outputs/videos"
mkpath(video_dir)
video_file = joinpath(video_dir, "lorenz_rotation.mp4")

record(fig, video_file, 1:n_frames; framerate=30) do frame
    ax.azimuth[] = angles[frame]
end

println("✓ Rotation video saved to: $video_file")

# =============================================================================
# Sensitivity to Initial Conditions
# =============================================================================

println("\nDemonstrating sensitivity to initial conditions...")

# Solve with slightly perturbed initial conditions
ε = 1e-8
u0_perturbed = u0 .+ [ε, 0, 0]
prob_perturbed = ODEProblem(lorenz!, u0_perturbed, tspan, p)
sol_perturbed = solve(prob_perturbed, Vern9(), reltol=1e-10, abstol=1e-12)

x_pert = [u[1] for u in sol_perturbed.u]
y_pert = [u[2] for u in sol_perturbed.u]
z_pert = [u[3] for u in sol_perturbed.u]

# Calculate divergence over time
divergence = sqrt.((x .- x_pert).^2 .+ (y .- y_pert).^2 .+ (z .- z_pert).^2)

# Plot divergence
fig_chaos = Figure(size=(1600, 800), fontsize=20)

ax_div = Axis(fig_chaos[1, 1],
    title="Sensitivity to Initial Conditions (Δx₀ = $ε)",
    xlabel="Time", ylabel="Distance between trajectories",
    yscale=log10)
lines!(ax_div, sol.t, divergence, color=:purple, linewidth=2)

# Add reference line for exponential growth
λ = 0.9  # Approximate Lyapunov exponent for Lorenz
exp_growth = ε * exp.(λ * sol.t)
lines!(ax_div, sol.t, exp_growth, color=:red, linewidth=2, 
    linestyle=:dash, label="Exponential (λ≈0.9)")
axislegend(ax_div)

# Show 3D comparison
ax_compare = Axis3(fig_chaos[1, 2],
    title="Original vs Perturbed Trajectory",
    xlabel="X", ylabel="Y", zlabel="Z")
lines!(ax_compare, x, y, z, color=:blue, linewidth=2, label="Original")
lines!(ax_compare, x_pert, y_pert, z_pert, color=:red, linewidth=2, label="Perturbed")
axislegend(ax_compare, position=:lt)

output_file_chaos = joinpath(output_dir, "04_lorenz_chaos.png")
save(output_file_chaos, fig_chaos)

println("✓ Chaos demonstration saved to: $output_file_chaos")

# Calculate when trajectories diverge significantly
divergence_threshold = 1.0
diverge_idx = findfirst(divergence .> divergence_threshold)
if diverge_idx !== nothing
    diverge_time = sol.t[diverge_idx]
    println("\n  • Trajectories diverge (distance > $divergence_threshold) at t = $(round(diverge_time, digits=2))")
    println("  • Starting from Δx₀ = $ε, exponential growth leads to chaos")
end

# =============================================================================
# Summary
# =============================================================================

println("\n" * "=" ^ 70)
println("✓ Lorenz Attractor Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • 4K main visualization: $output_file")
println("  • Multi-view projection: $output_file_multi")
println("  • Time series plots: $output_file_ts")
println("  • Rotation animation: $video_file")
println("  • Chaos demonstration: $output_file_chaos")

println("\nLorenz System Properties:")
println("  • Chaotic attractor with fractal dimension ≈ 2.06")
println("  • Sensitive dependence on initial conditions")
println("  • Positive Lyapunov exponent λ ≈ 0.9")
println("  • Never repeats but stays in bounded region")
println("  • Exhibits 'butterfly effect' - small changes grow exponentially")

println("\nNext: Try three_body_problem.jl for celestial mechanics!")
