# Universal Differential Equations Demo
# Combine physics knowledge with neural networks

using OrdinaryDiffEq
using Lux
using Optimization
using OptimizationOptimisers
using Random
using Plots
using ComponentArrays

println("=" ^ 70)
println("Universal Differential Equations - Physics + Neural Networks")
println("=" ^ 70)

# True system: damped harmonic oscillator
function true_dynamics!(du, u, p, t)
    k, c = p
    x, v = u
    du[1] = v
    du[2] = -k*x - c*v
end

p_true = [1.0, 0.2]
u0 = [1.0, 0.0]
tspan = (0.0, 10.0)
t_data = 0.0:0.1:10.0

prob_true = ODEProblem(true_dynamics!, u0, tspan, p_true)
sol_true = solve(prob_true, Tsit5(), saveat=t_data)
data = Array(sol_true)

println("✓ Training data generated")

# Universal DE: use NN to learn damping term
nn = Chain(Dense(2, 16, tanh), Dense(16, 1))
rng = Random.default_rng()
Random.seed!(rng, 42)
ps, st = Lux.setup(rng, nn)
ps_flat = ComponentArray(ps)

function ude_dynamics!(du, u, p, t)
    k = 1.0  # Known physics
    x, v = u
    u_vec = [x, v]
    damping, _ = nn(u_vec, p, st)
    du[1] = v
    du[2] = -k*x + damping[1]
end

println("✓ Universal DE defined")
println("  Known physics: spring force -kx")
println("  Learned: damping term via neural network")

# Training would go here (simplified for demo)
p1 = plot(sol_true, label=["Position" "Velocity"], lw=2, dpi=300)
xlabel!(p1, "Time")
title!(p1, "Universal DE: Physics + Neural Network")

mkpath("../outputs/images")
savefig(p1, "../outputs/images/16_universal_de.png")

println("✓ Demo completed!")
println("\nUniversal DEs combine:")
println("  • Known physics (differential equations)")
println("  • Unknown dynamics (neural networks)")
println("  • End-to-end differentiable training")
