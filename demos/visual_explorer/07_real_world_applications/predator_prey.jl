# Predator-Prey Model (Lotka-Volterra)
# Classic ecological model

using OrdinaryDiffEq
using Plots

println("=" ^ 70)
println("Predator-Prey Model (Lotka-Volterra)")
println("=" ^ 70)

function lotka_volterra!(du, u, p, t)
    α, β, γ, δ = p
    x, y = u  # x=prey, y=predator
    du[1] = α*x - β*x*y
    du[2] = -γ*y + δ*x*y
end

u0 = [1.0, 0.5]
tspan = (0.0, 50.0)
p = [1.5, 1.0, 3.0, 1.0]

prob = ODEProblem(lotka_volterra!, u0, tspan, p)
sol = solve(prob, Tsit5())

println("✓ Predator-prey simulation completed")

p1 = plot(sol.t, [u[1] for u in sol.u], label="Prey", lw=2, dpi=300)
plot!(p1, sol.t, [u[2] for u in sol.u], label="Predator", lw=2)
xlabel!(p1, "Time"); ylabel!(p1, "Population")
title!(p1, "Predator-Prey Dynamics")

p2 = plot([u[1] for u in sol.u], [u[2] for u in sol.u], 
    label="Phase trajectory", lw=2, dpi=300)
xlabel!(p2, "Prey"); ylabel!(p2, "Predator")
title!(p2, "Phase Portrait")

combined = plot(p1, p2, layout=(1,2), size=(1600, 600), dpi=300)
mkpath("../outputs/images")
savefig(combined, "../outputs/images/21_predator_prey.png")

println("✓ Output saved!")
