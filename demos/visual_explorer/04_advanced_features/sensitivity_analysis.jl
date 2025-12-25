# Sensitivity Analysis Demo
# Computing gradients with respect to parameters

using OrdinaryDiffEq
using DiffEqSensitivity
using ForwardDiff
using Plots

println("=" ^ 70)
println("Sensitivity Analysis - Parameter Gradients")
println("=" ^ 70)

# Simple exponential growth
function f!(du, u, p, t)
    du[1] = p[1] * u[1]
end

u0 = [1.0]
tspan = (0.0, 10.0)
p = [0.5]

prob = ODEProblem(f!, u0, tspan, p)

# Solve normally
sol = solve(prob, Tsit5())

# Define loss function
function loss_function(p)
    tmp_prob = remake(prob, p=p)
    tmp_sol = solve(tmp_prob, Tsit5(), saveat=1.0)
    return sum(abs2, tmp_sol.u[end])
end

# Compute gradient
grad = ForwardDiff.gradient(loss_function, p)

println("✓ Sensitivity computed")
println("  Parameter: $(p[1])")
println("  Gradient: $(grad[1])")

p1 = plot(sol.t, [u[1] for u in sol.u], lw=3, dpi=300,
    xlabel="Time", ylabel="u(t)", title="Solution with p=$(p[1])",
    legend=false)

mkpath("../outputs/images")
savefig(p1, "../outputs/images/12_sensitivity.png")

println("✓ Demo completed!")
println("Next: parameter_estimation.jl for inverse problems!")
