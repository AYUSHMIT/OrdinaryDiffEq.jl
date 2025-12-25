# Orbital Mechanics - Kepler Problem
# Satellite orbit propagation

using OrdinaryDiffEq
using Plots
using LinearAlgebra

println("=" ^ 70)
println("Orbital Mechanics - Kepler Problem")
println("=" ^ 70)

function kepler!(du, u, p, t)
    μ = p  # Gravitational parameter
    r = u[1:3]
    v = u[4:6]
    
    r_norm = norm(r)
    
    du[1:3] = v
    du[4:6] = -μ / r_norm^3 * r
end

# Earth's gravitational parameter
μ = 398600.4418  # km³/s²

# Initial conditions for circular orbit at 400 km altitude
r0 = 6378.137 + 400.0  # km (Earth radius + altitude)
v0 = sqrt(μ / r0)  # Circular orbital velocity

u0 = [r0, 0.0, 0.0, 0.0, v0, 0.0]
tspan = (0.0, 2*π*sqrt(r0^3/μ) * 2)  # Two orbital periods

prob = ODEProblem(kepler!, u0, tspan, μ)
sol = solve(prob, Vern7())

println("✓ Orbit computed")
println("  Orbital period: $(round(2*π*sqrt(r0^3/μ)/60, digits=1)) minutes")

x = [u[1] for u in sol.u]
y = [u[2] for u in sol.u]
z = [u[3] for u in sol.u]

p1 = plot(x, y, lw=2, aspect_ratio=:equal, dpi=300,
    xlabel="X (km)", ylabel="Y (km)", title="Orbital Trajectory (XY plane)",
    legend=false)
scatter!(p1, [0], [0], ms=20, color=:blue, label="Earth")

mkpath("../outputs/images")
savefig(p1, "../outputs/images/22_orbital_mechanics.png")

println("✓ Output saved!")
