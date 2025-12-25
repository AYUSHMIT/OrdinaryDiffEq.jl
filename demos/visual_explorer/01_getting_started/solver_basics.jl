# Solver Basics: Introduction to ODE Solving with OrdinaryDiffEq.jl
# This demo introduces the fundamental concepts of solving ODEs

using OrdinaryDiffEq
using Plots
using Printf

println("=" ^ 70)
println("Solver Basics Demo - Introduction to ODE Solving")
println("=" ^ 70)

# =============================================================================
# Problem 1: Simple Exponential Growth
# =============================================================================
println("\n1. Simple Exponential Growth: du/dt = 1.01u")

# Define the ODE: du/dt = 1.01 * u
function exponential_growth!(du, u, p, t)
    du[1] = 1.01 * u[1]
end

# Initial condition and time span
u0 = [0.5]
tspan = (0.0, 10.0)

# Create the ODE problem
prob = ODEProblem(exponential_growth!, u0, tspan)

# Solve with default solver (Tsit5)
sol = solve(prob)

# Analytical solution for comparison
analytical(t) = 0.5 * exp(1.01 * t)

# Create visualization
p1 = plot(sol, label="Numerical Solution", lw=3, xlabel="Time", ylabel="u(t)",
    title="Exponential Growth", legend=:topleft, dpi=300)
plot!(p1, sol.t, analytical.(sol.t), lw=2, ls=:dash, label="Analytical Solution")

println("  ✓ Solution computed successfully")
println("  ✓ Final value: $(sol[end][1])")
println("  ✓ Analytical: $(analytical(10.0))")
println("  ✓ Error: $(abs(sol[end][1] - analytical(10.0)))")

# =============================================================================
# Problem 2: Harmonic Oscillator
# =============================================================================
println("\n2. Harmonic Oscillator: d²x/dt² = -x")

# Convert second-order ODE to first-order system
# Let u[1] = x, u[2] = dx/dt
# Then: du[1]/dt = u[2], du[2]/dt = -u[1]
function harmonic_oscillator!(du, u, p, t)
    du[1] = u[2]
    du[2] = -u[1]
end

u0 = [1.0, 0.0]  # Initial position and velocity
tspan = (0.0, 20.0)

prob = ODEProblem(harmonic_oscillator!, u0, tspan)
sol = solve(prob)

# Analytical solution
analytical_x(t) = cos(t)

p2 = plot(sol, idxs=(0, 1), label="Position x(t)", lw=3, xlabel="Time", ylabel="x(t)",
    title="Harmonic Oscillator", legend=:topright, dpi=300)
plot!(p2, sol.t, analytical_x.(sol.t), lw=2, ls=:dash, label="Analytical x(t)")

println("  ✓ Oscillator solution computed")
println("  ✓ Period preserved: $(sol.t[end] / (10π))")

# =============================================================================
# Problem 3: Logistic Growth
# =============================================================================
println("\n3. Logistic Growth: du/dt = r*u*(1 - u/K)")

function logistic_growth!(du, u, p, t)
    r, K = p  # Growth rate and carrying capacity
    du[1] = r * u[1] * (1 - u[1] / K)
end

u0 = [0.1]
tspan = (0.0, 10.0)
p = [1.5, 10.0]  # r = 1.5, K = 10.0

prob = ODEProblem(logistic_growth!, u0, tspan, p)
sol = solve(prob)

p3 = plot(sol, label="Population", lw=3, xlabel="Time", ylabel="Population",
    title="Logistic Growth (Carrying Capacity K=10)", legend=:bottomright, dpi=300)
hline!(p3, [10.0], label="Carrying Capacity", ls=:dash, lw=2, color=:red)

println("  ✓ Logistic growth computed")
println("  ✓ Final population: $(sol[end][1])")
println("  ✓ Approaching carrying capacity: $(abs(sol[end][1] - 10.0) < 0.1)")

# =============================================================================
# Solver Options Demo
# =============================================================================
println("\n4. Comparing Different Solvers")

# Solve with different solvers
sol_tsit5 = solve(prob, Tsit5())
sol_vern7 = solve(prob, Vern7())
sol_euler = solve(prob, Euler(), dt=0.1)

p4 = plot(sol_tsit5, label="Tsit5 (Default)", lw=3, xlabel="Time", ylabel="Population",
    title="Solver Comparison", legend=:bottomright, dpi=300)
plot!(p4, sol_vern7, label="Vern7 (High Order)", lw=2, ls=:dash)
plot!(p4, sol_euler, label="Euler (Fixed Step)", lw=2, ls=:dot)

println("  ✓ Multiple solvers compared")
println("  ✓ Tsit5 steps: $(length(sol_tsit5.t))")
println("  ✓ Vern7 steps: $(length(sol_vern7.t))")
println("  ✓ Euler steps: $(length(sol_euler.t))")

# =============================================================================
# Save Combined Figure
# =============================================================================
combined_plot = plot(p1, p2, p3, p4, layout=(2, 2), size=(1200, 900), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "01_solver_basics.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ Demo completed successfully!")
println("✓ Output saved to: $output_file")
println("=" ^ 70)
println("\nKey Takeaways:")
println("  • ODEProblem(f, u0, tspan, p) defines the problem")
println("  • solve(prob, solver) computes the solution")
println("  • Default solver (Tsit5) works well for most problems")
println("  • Use higher-order solvers (Vern7) for higher accuracy")
println("  • Solutions can be plotted directly with plot(sol)")
println("\nNext: Try adaptive_stepping.jl to see how step sizes adapt!")
