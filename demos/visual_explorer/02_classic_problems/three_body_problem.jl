# Three-Body Problem: Celestial Mechanics
# Simulate gravitational interactions between three bodies

using OrdinaryDiffEq
using GLMakie
using LinearAlgebra
using Printf

println("=" ^ 70)
println("Three-Body Problem - Gravitational Dynamics")
println("=" ^ 70)

# =============================================================================
# Three-Body Problem Setup
# =============================================================================

"""
The three-body problem with gravitational interactions.
State vector: [x1, y1, z1, x2, y2, z2, x3, y3, z3, vx1, vy1, vz1, vx2, vy2, vz2, vx3, vy3, vz3]
"""

function three_body!(du, u, p, t)
    G, m1, m2, m3 = p
    
    # Positions
    r1 = @view u[1:3]
    r2 = @view u[4:6]
    r3 = @view u[7:9]
    
    # Velocities
    v1 = @view u[10:12]
    v2 = @view u[13:15]
    v3 = @view u[16:18]
    
    # Distance vectors
    r12 = r2 - r1
    r13 = r3 - r1
    r23 = r3 - r2
    
    # Distances
    d12 = norm(r12)
    d13 = norm(r13)
    d23 = norm(r23)
    
    # Accelerations from gravitational forces
    # F = G * m1 * m2 / r^2, direction: toward other body
    a1 = G * m2 / d12^3 * r12 + G * m3 / d13^3 * r13
    a2 = -G * m1 / d12^3 * r12 + G * m3 / d23^3 * r23
    a3 = -G * m1 / d13^3 * r13 - G * m2 / d23^3 * r23
    
    # Position derivatives (velocities)
    du[1:3] = v1
    du[4:6] = v2
    du[7:9] = v3
    
    # Velocity derivatives (accelerations)
    du[10:12] = a1
    du[13:15] = a2
    du[16:18] = a3
end

# =============================================================================
# Configuration: Figure-8 Orbit
# =============================================================================

println("\nSetting up Figure-8 orbit configuration...")

# Parameters (normalized units)
G = 1.0
m1 = m2 = m3 = 1.0  # Equal masses

# Initial conditions for stable figure-8 orbit
# (discovered numerically by Moore in 1993, proven by Chenciner and Montgomery in 2000)
u0 = [
    # Positions (x, y, z)
    -0.97000436, 0.24308753, 0.0,  # Body 1
    0.0, 0.0, 0.0,                  # Body 2
    0.97000436, -0.24308753, 0.0,   # Body 3
    # Velocities (vx, vy, vz)
    0.466203685, 0.43236573, 0.0,   # Body 1
    -0.93240737, -0.86473146, 0.0,  # Body 2
    0.466203685, 0.43236573, 0.0    # Body 3
]

tspan = (0.0, 6.3)  # One complete period
p = [G, m1, m2, m3]

# =============================================================================
# Solve the System
# =============================================================================

println("Solving three-body system...")

prob = ODEProblem(three_body!, u0, tspan, p)
sol = solve(prob, Vern9(), reltol=1e-10, abstol=1e-12)

println("✓ Solution computed")
println("  • Time span: $(tspan[1]) to $(tspan[2])")
println("  • Number of timesteps: $(length(sol.t))")

# Extract trajectories
function extract_trajectory(sol, body_idx)
    offset = (body_idx - 1) * 3
    x = [u[offset + 1] for u in sol.u]
    y = [u[offset + 2] for u in sol.u]
    z = [u[offset + 3] for u in sol.u]
    return x, y, z
end

x1, y1, z1 = extract_trajectory(sol, 1)
x2, y2, z2 = extract_trajectory(sol, 2)
x3, y3, z3 = extract_trajectory(sol, 3)

# =============================================================================
# Verify Conservation Laws
# =============================================================================

println("\nChecking conservation laws...")

function total_energy(u, p)
    G, m1, m2, m3 = p
    r1, r2, r3 = u[1:3], u[4:6], u[7:9]
    v1, v2, v3 = u[10:12], u[13:15], u[16:18]
    
    # Kinetic energy
    KE = 0.5 * (m1 * norm(v1)^2 + m2 * norm(v2)^2 + m3 * norm(v3)^2)
    
    # Potential energy
    PE = -G * (m1 * m2 / norm(r2 - r1) + 
               m1 * m3 / norm(r3 - r1) + 
               m2 * m3 / norm(r3 - r2))
    
    return KE + PE
end

E0 = total_energy(sol.u[1], p)
E_final = total_energy(sol.u[end], p)
energy_error = abs((E_final - E0) / E0)

println("  • Initial energy: $(round(E0, digits=6))")
println("  • Final energy: $(round(E_final, digits=6))")
println("  • Relative error: $(round(energy_error * 100, digits=8))%")

# =============================================================================
# 3D Visualization
# =============================================================================

println("\nCreating 3D visualization...")

fig = Figure(size=(2400, 1800), fontsize=24)

# Main 3D view
ax = Axis3(fig[1, 1:2], 
    title="Three-Body Problem: Figure-8 Orbit",
    xlabel="X", ylabel="Y", zlabel="Z",
    aspect=:data,
    azimuth=π/4)

# Plot trajectories
lines!(ax, x1, y1, z1, color=:red, linewidth=3, label="Body 1")
lines!(ax, x2, y2, z2, color=:green, linewidth=3, label="Body 2")
lines!(ax, x3, y3, z3, color=:blue, linewidth=3, label="Body 3")

# Plot current positions
scatter!(ax, [x1[end]], [y1[end]], [z1[end]], color=:red, markersize=30)
scatter!(ax, [x2[end]], [y2[end]], [z2[end]], color=:green, markersize=30)
scatter!(ax, [x3[end]], [y3[end]], [z3[end]], color=:blue, markersize=30)

axislegend(ax, position=:lt)

# XY projection
ax_xy = Axis(fig[2, 1], 
    title="XY Projection (Top View)",
    xlabel="X", ylabel="Y",
    aspect=DataAspect())
lines!(ax_xy, x1, y1, color=:red, linewidth=2)
lines!(ax_xy, x2, y2, color=:green, linewidth=2)
lines!(ax_xy, x3, y3, color=:blue, linewidth=2)
scatter!(ax_xy, [x1[end]], [y1[end]], color=:red, markersize=15)
scatter!(ax_xy, [x2[end]], [y2[end]], color=:green, markersize=15)
scatter!(ax_xy, [x3[end]], [y3[end]], color=:blue, markersize=15)

# Energy conservation
energies = [total_energy(u, p) for u in sol.u]
ax_energy = Axis(fig[2, 2],
    title="Energy Conservation",
    xlabel="Time", ylabel="Total Energy")
lines!(ax_energy, sol.t, energies, color=:purple, linewidth=2)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "05_three_body.png")
save(output_file, fig)

println("✓ Visualization saved to: $output_file")

# =============================================================================
# Create Animation
# =============================================================================

println("\nCreating animation...")

video_dir = "../outputs/videos"
mkpath(video_dir)
video_file = joinpath(video_dir, "three_body.mp4")

# Create animation showing orbital motion
fig_anim = Figure(size=(1200, 1200))
ax_anim = Axis3(fig_anim[1, 1],
    title="Three-Body Problem: Figure-8 Orbit",
    xlabel="X", ylabel="Y", zlabel="Z",
    aspect=:data)

n_frames = length(sol.t)
skip = max(1, n_frames ÷ 300)  # Limit to ~300 frames

record(fig_anim, video_file, 1:skip:n_frames; framerate=30) do frame
    empty!(ax_anim)
    
    # Plot trails up to current frame
    lines!(ax_anim, x1[1:frame], y1[1:frame], z1[1:frame], 
        color=:red, linewidth=2, transparency=true, alpha=0.3)
    lines!(ax_anim, x2[1:frame], y2[1:frame], z2[1:frame], 
        color=:green, linewidth=2, transparency=true, alpha=0.3)
    lines!(ax_anim, x3[1:frame], y3[1:frame], z3[1:frame], 
        color=:blue, linewidth=2, transparency=true, alpha=0.3)
    
    # Plot current positions with larger markers
    scatter!(ax_anim, [x1[frame]], [y1[frame]], [z1[frame]], 
        color=:red, markersize=30)
    scatter!(ax_anim, [x2[frame]], [y2[frame]], [z2[frame]], 
        color=:green, markersize=30)
    scatter!(ax_anim, [x3[frame]], [y3[frame]], [z3[frame]], 
        color=:blue, markersize=30)
    
    # Add time annotation
    text!(ax_anim, 0, 1.5, 0.5, text="t = $(round(sol.t[frame], digits=2))", 
        fontsize=20)
end

println("✓ Animation saved to: $video_file")

# =============================================================================
# Create GIF Animation (top view)
# =============================================================================

println("\nCreating GIF animation...")

anim_dir = "../outputs/animations"
mkpath(anim_dir)

using Plots
anim = @animate for i in 1:5:n_frames
    Plots.plot(x1[1:i], y1[1:i], color=:red, lw=2, label="Body 1",
        xlabel="X", ylabel="Y", title="Three-Body Figure-8 (t=$(round(sol.t[i], digits=2)))",
        xlim=(-1.5, 1.5), ylim=(-1.5, 1.5), aspect_ratio=:equal, dpi=150,
        legend=:topright)
    Plots.plot!(x2[1:i], y2[1:i], color=:green, lw=2, label="Body 2")
    Plots.plot!(x3[1:i], y3[1:i], color=:blue, lw=2, label="Body 3")
    Plots.scatter!([x1[i]], [y1[i]], color=:red, ms=10, label="")
    Plots.scatter!([x2[i]], [y2[i]], color=:green, ms=10, label="")
    Plots.scatter!([x3[i]], [y3[i]], color=:blue, ms=10, label="")
end

gif_file = joinpath(anim_dir, "three_body_figure8.gif")
Plots.gif(anim, gif_file, fps=20)

println("✓ GIF animation saved to: $gif_file")

# =============================================================================
# Summary
# =============================================================================

println("\n" * "=" ^ 70)
println("✓ Three-Body Problem Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Static visualization: $output_file")
println("  • MP4 animation: $video_file")
println("  • GIF animation: $gif_file")

println("\nThree-Body Problem Facts:")
println("  • No general closed-form solution exists")
println("  • Figure-8 orbit discovered numerically in 1993")
println("  • Requires high precision to maintain stability")
println("  • Energy conserved to $(round(energy_error * 100, digits=6))%")
println("  • Period: ≈ 6.3 time units")

println("\nNext: Try van_der_pol.jl for nonlinear oscillations!")
