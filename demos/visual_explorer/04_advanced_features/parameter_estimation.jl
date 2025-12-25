# Parameter Estimation Demo
# Fit ODE parameters to data

using OrdinaryDiffEq
using Optimization
using OptimizationOptimJL
using Plots
using Random

println("=" ^ 70)
println("Parameter Estimation - Fitting ODE to Data")
println("=" ^ 70)

# True system
function f!(du, u, p, t)
    du[1] = p[1] * u[1]
end

p_true = [0.75]
u0 = [1.0]
tspan = (0.0, 10.0)
t_data = 0.0:1.0:10.0

prob_true = ODEProblem(f!, u0, tspan, p_true)
sol_true = solve(prob_true, Tsit5(), saveat=t_data)

# Add noise
Random.seed!(123)
data = Array(sol_true) .+ 0.05 * randn(size(Array(sol_true)))

# Loss function
function loss(p, _)
    prob = remake(prob_true, p=p)
    sol = solve(prob, Tsit5(), saveat=t_data)
    return sum(abs2, Array(sol) .- data)
end

# Optimize
optf = OptimizationFunction(loss, Optimization.AutoForwardDiff())
optprob = OptimizationProblem(optf, [0.5])
result = solve(optprob, BFGS())

println("✓ Parameter estimation completed")
println("  True parameter: $(p_true[1])")
println("  Estimated parameter: $(round(result.u[1], digits=4))")

# Plot
sol_fit = solve(remake(prob_true, p=result.u), Tsit5())
p1 = plot(sol_fit, lw=3, label="Fitted", dpi=300)
scatter!(p1, t_data, data[:], label="Data", ms=6)
plot!(p1, sol_true, lw=2, ls=:dash, label="True")
xlabel!(p1, "Time"); ylabel!(p1, "u(t)")
title!(p1, "Parameter Estimation Results")

mkpath("../outputs/images")
savefig(p1, "../outputs/images/13_parameter_estimation.png")

println("✓ Demo completed!")
