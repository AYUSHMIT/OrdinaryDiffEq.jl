# Pendulum DAE - Constrained Mechanical System
# Differential-Algebraic Equation for a simple pendulum

using OrdinaryDiffEq
using Plots
using LinearAlgebra
using Printf

println("=" ^ 70)
println("Pendulum DAE - Constrained Mechanical System")
println("=" ^ 70)

# =============================================================================
# Pendulum as DAE System
# =============================================================================

"""
Pendulum constrained to move on a circle (length L):
Variables: (x, y, vx, vy, λ) where λ is Lagrange multiplier
    
DAE system:
    dx/dt = vx
    dy/dt = vy
    m*dvx/dt = -λ*x
    m*dvy/dt = -λ*y - m*g
    0 = x² + y² - L²  (constraint)
"""

function pendulum_dae!(residual, du, u, p, t)
    m, g, L = p
    x, y, vx, vy, λ = u
    dx, dy, dvx, dvy, dλ = du
    
    # Differential equations
    residual[1] = dx - vx
    residual[2] = dy - vy
    residual[3] = m * dvx + λ * x
    residual[4] = m * dvy + λ * y + m * g
    
    # Algebraic constraint
    residual[5] = x^2 + y^2 - L^2
end

# =============================================================================
# Initial Conditions
# =============================================================================

m = 1.0  # Mass
g = 9.81 # Gravity
L = 1.0  # Length

# Start at angle θ₀ = 60° from vertical
θ0 = π/3
x0 = L * sin(θ0)
y0 = -L * cos(θ0)

# Initial velocity (release from rest)
vx0 = 0.0
vy0 = 0.0

# Initial Lagrange multiplier (computed from constraint)
λ0 = m * g * cos(θ0) / L

u0 = [x0, y0, vx0, vy0, λ0]
du0 = [vx0, vy0, 0.0, 0.0, 0.0]

tspan = (0.0, 10.0)
p = [m, g, L]

println("\nInitial conditions:")
println("  • Initial angle: $(round(rad2deg(θ0), digits=1))°")
println("  • Mass: $m kg")
println("  • Length: $L m")
println("  • Gravity: $g m/s²")

# =============================================================================
# Define as DAE Problem
# =============================================================================

# Differential variables: indices 1-4 (x, y, vx, vy)
# Algebraic variable: index 5 (λ)
differential_vars = [true, true, true, true, false]

prob = DAEProblem(pendulum_dae!, du0, u0, tspan, p, 
    differential_vars=differential_vars)

# =============================================================================
# Solve
# =============================================================================

println("\nSolving DAE system...")

sol = solve(prob, IDA(), reltol=1e-8, abstol=1e-10)

println("✓ Solution computed")
println("  • Timesteps: $(length(sol.t))")
println("  • Solution time: $(tspan[1]) to $(tspan[2]) seconds")

# Extract components
x = [u[1] for u in sol.u]
y = [u[2] for u in sol.u]
vx = [u[3] for u in sol.u]
vy = [u[4] for u in sol.u]
λ = [u[5] for u in sol.u]

# =============================================================================
# Verify Constraint
# =============================================================================

println("\nVerifying constraint satisfaction:")

constraint_error = [sqrt(u[1]^2 + u[2]^2) - L for u in sol.u]
max_error = maximum(abs.(constraint_error))

println("  • Maximum constraint violation: $(max_error)")
println("  • Constraint satisfied: $(max_error < 1e-6 ? "✓" : "✗")")

# =============================================================================
# Energy Conservation
# =============================================================================

function total_energy(u, p)
    m, g, L = p
    x, y, vx, vy = u[1:4]
    KE = 0.5 * m * (vx^2 + vy^2)
    PE = m * g * y
    return KE + PE
end

energies = [total_energy(u, p) for u in sol.u]
E0 = energies[1]
energy_drift = (energies .- E0) / abs(E0)

println("\nEnergy conservation:")
println("  • Initial energy: $(round(E0, digits=6)) J")
println("  • Final energy: $(round(energies[end], digits=6)) J")
println("  • Relative drift: $(round(maximum(abs.(energy_drift)) * 100, digits=4))%")

# =============================================================================
# Visualization
# =============================================================================

println("\nCreating visualizations...")

# Trajectory
p1 = plot(x, y, lw=2, label="Trajectory", aspect_ratio=:equal,
    xlabel="x (m)", ylabel="y (m)", title="Pendulum Trajectory",
    legend=:topright, dpi=300)
scatter!(p1, [x[1]], [y[1]], color=:green, ms=10, label="Start")
scatter!(p1, [x[end]], [y[end]], color=:red, ms=10, label="End")

# Circle constraint
θ_circle = range(0, 2π, length=100)
plot!(p1, L*sin.(θ_circle), L*cos.(θ_circle), 
    ls=:dash, color=:black, alpha=0.3, label="Constraint circle")

# Pivot point
scatter!(p1, [0], [0], color=:black, ms=15, shape=:circle, label="Pivot")

# Position vs time
p2 = plot(sol.t, x, label="x", lw=2, xlabel="Time (s)", ylabel="Position (m)",
    title="Position Components", legend=:topright, dpi=300)
plot!(p2, sol.t, y, label="y", lw=2)

# Velocity vs time
p3 = plot(sol.t, vx, label="vx", lw=2, xlabel="Time (s)", ylabel="Velocity (m/s)",
    title="Velocity Components", legend=:topright, dpi=300)
plot!(p3, sol.t, vy, label="vy", lw=2)

# Energy
p4 = plot(sol.t, energies, lw=2, label="Total Energy",
    xlabel="Time (s)", ylabel="Energy (J)", title="Energy Conservation",
    legend=:topright, dpi=300)
hline!(p4, [E0], ls=:dash, color=:red, label="Initial Energy")

# Constraint error
p5 = plot(sol.t, abs.(constraint_error), lw=2,
    xlabel="Time (s)", ylabel="|Constraint Error| (m)",
    title="Constraint Violation", legend=false, dpi=300, yscale=:log10)

# Lagrange multiplier (tension force)
p6 = plot(sol.t, λ, lw=2, xlabel="Time (s)", ylabel="λ (N)",
    title="Constraint Force (Tension)", legend=false, dpi=300)

# Combine
combined_plot = plot(p1, p2, p3, p4, p5, p6, layout=(3, 2), size=(1600, 1800), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "18_pendulum_dae.png")
savefig(combined_plot, output_file)

# =============================================================================
# Create Animation
# =============================================================================

println("\nCreating animation...")

anim = @animate for i in 1:5:length(sol.t)
    # Draw pendulum
    p_anim = plot([0, x[i]], [0, y[i]], lw=3, color=:black,
        xlim=(-1.2*L, 1.2*L), ylim=(-1.2*L, 0.2*L),
        aspect_ratio=:equal, legend=false, dpi=150,
        title="Pendulum (t=$(round(sol.t[i], digits=2)) s)")
    
    # Pivot
    scatter!(p_anim, [0], [0], color=:black, ms=15)
    
    # Bob
    scatter!(p_anim, [x[i]], [y[i]], color=:blue, ms=20)
    
    # Trail
    if i > 10
        plot!(p_anim, x[max(1,i-50):i], y[max(1,i-50):i], 
            alpha=0.3, color=:blue, lw=1)
    end
    
    # Reference circle
    θ_circle = range(0, 2π, length=100)
    plot!(p_anim, L*sin.(θ_circle), L*cos.(θ_circle), 
        ls=:dash, color=:gray, alpha=0.3)
end

gif_file = joinpath("../outputs/animations", "pendulum_dae.gif")
mkpath(dirname(gif_file))
gif(anim, gif_file, fps=20)

println("\n" * "=" ^ 70)
println("✓ Pendulum DAE Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Visualization: $output_file")
println("  • Animation: $gif_file")

println("\nDAE System Properties:")
println("  • 4 differential equations (positions and velocities)")
println("  • 1 algebraic constraint (fixed length)")
println("  • Lagrange multiplier represents constraint force (tension)")
println("  • Energy conserved to $(round(maximum(abs.(energy_drift)) * 100, digits=4))%")
println("  • Constraint satisfied to $(max_error) m")

println("\nApplications:")
println("  • Constrained mechanical systems")
println("  • Multibody dynamics")
println("  • Robotics (kinematic constraints)")
println("  • Molecular dynamics (bond constraints)")

println("\nNext: Try electrical_circuit.jl for circuit DAEs!")
