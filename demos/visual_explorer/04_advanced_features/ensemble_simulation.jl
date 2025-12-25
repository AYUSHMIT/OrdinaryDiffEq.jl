# Ensemble Simulation Demo
# Monte Carlo simulations with parameter uncertainty

using OrdinaryDiffEq
using Plots
using Random

println("=" ^ 70)
println("Ensemble Simulation - Monte Carlo with Uncertainty")
println("=" ^ 70)

function exponential_growth!(du, u, p, t)
    r = p
    du[1] = r * u[1]
end

u0 = [1.0]
tspan = (0.0, 5.0)

# Generate ensemble with parameter uncertainty
Random.seed!(123)
n_trajectories = 100
p_samples = 0.5 .+ 0.2 * randn(n_trajectories)

prob = ODEProblem(exponential_growth!, u0, tspan, p_samples[1])

function prob_func(prob, i, repeat)
    remake(prob, p=p_samples[i])
end

ensemble_prob = EnsembleProblem(prob, prob_func=prob_func)
ensemble_sol = solve(ensemble_prob, Tsit5(), trajectories=n_trajectories)

println("✓ Ensemble simulation completed")
println("  Trajectories: $n_trajectories")

p1 = plot(xlabel="Time", ylabel="u(t)", title="Ensemble Simulation", 
    legend=false, dpi=300)

for sol in ensemble_sol
    plot!(p1, sol.t, [u[1] for u in sol.u], alpha=0.1, color=:blue)
end

# Add mean
mean_sol = [mean([sol(t)[1] for sol in ensemble_sol]) for t in 0:0.1:tspan[2]]
plot!(p1, 0:0.1:tspan[2], mean_sol, lw=3, color=:red, label="Mean")

mkpath("../outputs/images")
savefig(p1, "../outputs/images/14_ensemble.png")

println("✓ Output saved!")
