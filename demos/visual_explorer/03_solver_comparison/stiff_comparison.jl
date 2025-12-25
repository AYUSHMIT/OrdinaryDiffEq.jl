# Stiff Problem Comparison
# Compare explicit vs implicit solvers on stiff problems

using OrdinaryDiffEq
using Plots
using BenchmarkTools
using Printf

println("=" ^ 70)
println("Stiff Problem Comparison - Explicit vs Implicit Solvers")
println("=" ^ 70)

# Van der Pol with μ=1000 (very stiff)
function van_der_pol!(du, u, p, t)
    μ = p
    du[1] = u[2]
    du[2] = μ * (1 - u[1]^2) * u[2] - u[1]
end

μ = 1000.0
u0 = [2.0, 0.0]
tspan = (0.0, 3000.0)
prob = ODEProblem(van_der_pol!, u0, tspan, μ)

println("\nProblem: Van der Pol with μ=$μ (very stiff)")

# Test solvers
explicit_solvers = [
    (Tsit5(), "Tsit5 (Explicit RK)"),
    (Vern7(), "Vern7 (Explicit RK)")
]

implicit_solvers = [
    (Rosenbrock23(), "Rosenbrock23"),
    (Rodas4P(), "Rodas4P"),
    (Rodas5P(), "Rodas5P"),
    (TRBDF2(), "TRBDF2")
]

println("\n" * "=" ^ 70)
println("Benchmarking Solvers")
println("=" ^ 70)

results = []

# Explicit solvers
println("\nExplicit Solvers:")
for (solver, name) in explicit_solvers
    try
        sol = solve(prob, solver, reltol=1e-6, abstol=1e-8, maxiters=1e7)
        t = @elapsed solve(prob, solver, reltol=1e-6, abstol=1e-8, maxiters=1e7)
        println("  ✓ $name: $(length(sol.t)) steps, $(round(t*1000, digits=1)) ms")
        push!(results, (name=name, steps=length(sol.t), time=t, type="explicit", sol=sol))
    catch e
        println("  ✗ $name: FAILED or too slow")
    end
end

# Implicit solvers
println("\nImplicit Solvers:")
for (solver, name) in implicit_solvers
    try
        sol = solve(prob, solver, reltol=1e-6, abstol=1e-8)
        t = @elapsed solve(prob, solver, reltol=1e-6, abstol=1e-8)
        println("  ✓ $name: $(length(sol.t)) steps, $(round(t*1000, digits=1)) ms")
        push!(results, (name=name, steps=length(sol.t), time=t, type="implicit", sol=sol))
    catch e
        println("  ✗ $name: FAILED")
    end
end

# Plot comparison
p1 = plot(title="Solver Efficiency (Stiff Problem)", 
    xlabel="Number of Steps", ylabel="Time (s)",
    xscale=:log10, yscale=:log10, dpi=300, legend=:topleft)

for r in results
    color = r.type == "explicit" ? :red : :blue
    marker = r.type == "explicit" ? :circle : :square
    scatter!(p1, [r.steps], [r.time], label=r.name, 
        color=color, marker=marker, markersize=10)
end

# Plot solutions
p2 = plot(title="Solutions Comparison", xlabel="Time", ylabel="x(t)", dpi=300)
for r in results[1:min(3, length(results))]
    t_sample = range(tspan[1], tspan[2], length=1000)
    x_sample = [r.sol(t)[1] for t in t_sample]
    plot!(p2, t_sample, x_sample, label=r.name, lw=2, alpha=0.7)
end

combined = plot(p1, p2, layout=(1, 2), size=(1600, 600), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
savefig(combined, joinpath(output_dir, "09_stiff_comparison.png"))

println("\n✓ Stiff comparison demo completed!")
println("\nKey Finding: Implicit solvers are essential for stiff problems!")
