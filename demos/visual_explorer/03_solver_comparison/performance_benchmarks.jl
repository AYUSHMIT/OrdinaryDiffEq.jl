# Performance Benchmarks Demo
# Comprehensive performance testing

using OrdinaryDiffEq
using BenchmarkTools
using Plots
using DataFrames
using Printf

println("=" ^ 70)
println("Performance Benchmarks - Comprehensive Testing")
println("=" ^ 70)

# Test problems
problems = Dict(
    "Simple" => (u0=[1.0], tspan=(0.0, 10.0), 
                 f=(du,u,p,t) -> (du[1] = p*u[1]), p=0.5),
    "Lorenz" => (u0=[1.0, 0.0, 0.0], tspan=(0.0, 10.0),
                 f=(du,u,p,t) -> (du[1]=10*(u[2]-u[1]); du[2]=u[1]*(28-u[3])-u[2]; du[3]=u[1]*u[2]-8/3*u[3]),
                 p=nothing)
)

solvers = [Euler(), RK4(), Tsit5(), Vern7()]

results = DataFrame(Problem=String[], Solver=String[], Time_ms=Float64[], Steps=Int[])

for (prob_name, prob_data) in problems
    prob = ODEProblem(prob_data.f, prob_data.u0, prob_data.tspan, prob_data.p)
    
    for solver in solvers
        try
            sol = solve(prob, solver, reltol=1e-6, abstol=1e-8)
            b = @benchmark solve($prob, $solver, reltol=1e-6, abstol=1e-8) samples=100
            
            push!(results, (prob_name, string(solver), median(b).time/1e6, length(sol.t)))
        catch
            println("  ✗ $(string(solver)) failed on $prob_name")
        end
    end
end

println("✓ Benchmarks completed")
println("\nResults:")
println(results)

# Plot
p1 = plot(title="Solver Performance", xlabel="Steps", ylabel="Time (ms)",
    xscale=:log10, yscale=:log10, dpi=300, legend=:topleft)

for prob_name in unique(results.Problem)
    subset = results[results.Problem .== prob_name, :]
    scatter!(p1, subset.Steps, subset.Time_ms, label=prob_name, ms=8)
end

mkpath("../outputs/images")
savefig(p1, "../outputs/images/08_performance_benchmarks.png")

println("✓ Benchmark visualization saved!")
