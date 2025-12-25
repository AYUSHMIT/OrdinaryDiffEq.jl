# Callbacks Demo: Event Handling in ODEs
# Demonstrate callback functionality for discontinuous changes

using OrdinaryDiffEq
using DiffEqCallbacks
using Plots
using Printf

println("=" ^ 70)
println("Callbacks Demo - Event Handling in ODEs")
println("=" ^ 70)

# =============================================================================
# Example 1: Bouncing Ball
# =============================================================================

println("\n1. Bouncing Ball with ContinuousCallback")

function ball!(du, u, p, t)
    g = p
    du[1] = u[2]  # dx/dt = v
    du[2] = -g    # dv/dt = -g
end

# Condition: ball hits ground (x = 0)
condition(u, t, integrator) = u[1]

# Action: reverse velocity with energy loss
function affect!(integrator)
    integrator.u[2] = -0.9 * integrator.u[2]  # 10% energy loss
end

bounce_cb = ContinuousCallback(condition, affect!)

# Initial conditions: 10m high, 0 initial velocity
u0 = [10.0, 0.0]
tspan = (0.0, 15.0)
p = 9.81

prob = ODEProblem(ball!, u0, tspan, p)
sol = solve(prob, Tsit5(), callback=bounce_cb)

println("✓ Bouncing ball simulated")
println("  • Initial height: $(u0[1]) m")
println("  • Number of bounces: $(length(sol.t) - length(unique(sol.t)))")

# Plot
p1 = plot(sol.t, [u[1] for u in sol.u], lw=3, label="Height",
    xlabel="Time (s)", ylabel="Height (m)", 
    title="Bouncing Ball (90% restitution)",
    legend=:topright, dpi=300)
hline!(p1, [0], lw=2, ls=:dash, label="Ground", color=:black)

# =============================================================================
# Example 2: Predator-Prey with Harvesting
# =============================================================================

println("\n2. Predator-Prey with Periodic Harvesting")

function predator_prey!(du, u, p, t)
    α, β, γ, δ = p
    x, y = u  # x=prey, y=predator
    du[1] = α*x - β*x*y
    du[2] = -γ*y + δ*x*y
end

# Harvest 20% of prey every 10 time units
harvest_times = 10.0:10.0:100.0

function harvest_affect!(integrator)
    integrator.u[1] *= 0.8  # Remove 20% of prey
    println("  • Harvesting at t=$(round(integrator.t, digits=1))")
end

harvest_cb = PresetTimeCallback(harvest_times, harvest_affect!)

u0 = [1.0, 0.5]
tspan = (0.0, 100.0)
p = [1.5, 1.0, 3.0, 1.0]  # α, β, γ, δ

prob = ODEProblem(predator_prey!, u0, tspan, p)
sol_no_harvest = solve(prob, Tsit5())
sol_harvest = solve(prob, Tsit5(), callback=harvest_cb)

println("✓ Predator-prey simulated")

# Plot comparison
p2 = plot(xlabel="Time", ylabel="Population", 
    title="Predator-Prey with Harvesting",
    legend=:topright, dpi=300)
plot!(p2, sol_no_harvest.t, [u[1] for u in sol_no_harvest.u], 
    label="Prey (no harvest)", lw=2, color=:blue)
plot!(p2, sol_harvest.t, [u[1] for u in sol_harvest.u], 
    label="Prey (with harvest)", lw=2, color=:cyan, ls=:dash)
plot!(p2, sol_no_harvest.t, [u[2] for u in sol_no_harvest.u], 
    label="Predator (no harvest)", lw=2, color=:red)
plot!(p2, sol_harvest.t, [u[2] for u in sol_harvest.u], 
    label="Predator (with harvest)", lw=2, color=:orange, ls=:dash)

for t in harvest_times
    if t <= tspan[2]
        vline!(p2, [t], color=:black, alpha=0.2, label="")
    end
end

# =============================================================================
# Example 3: Thermostat (Discontinuous Control)
# =============================================================================

println("\n3. Room Temperature with Thermostat")

function temperature!(du, u, p, t)
    T_outside, heater_on = p
    T = u[1]
    
    # Heat loss to outside
    heat_loss = 0.1 * (T - T_outside)
    
    # Heater input (when on)
    heater_power = heater_on ? 5.0 : 0.0
    
    du[1] = -heat_loss + heater_power
end

# Thermostat: turn on if T < 18, turn off if T > 22
T_low = 18.0
T_high = 22.0

condition_low(u, t, integrator) = u[1] - T_low
condition_high(u, t, integrator) = u[1] - T_high

function affect_low!(integrator)
    integrator.p[2] = 1  # Turn heater on
end

function affect_high!(integrator)
    integrator.p[2] = 0  # Turn heater off
end

cb_low = ContinuousCallback(condition_low, affect_low!)
cb_high = ContinuousCallback(condition_high, affect_high!)
thermostat_cb = CallbackSet(cb_low, cb_high)

u0 = [15.0]  # Start at 15°C
tspan = (0.0, 50.0)
p = [10.0, 1]  # T_outside=10°C, heater initially on

prob = ODEProblem(temperature!, u0, tspan, p)
sol = solve(prob, Tsit5(), callback=thermostat_cb)

println("✓ Thermostat simulation completed")

p3 = plot(sol.t, [u[1] for u in sol.u], lw=3, label="Temperature",
    xlabel="Time", ylabel="Temperature (°C)",
    title="Room Temperature with Thermostat Control",
    legend=:right, dpi=300)
hline!(p3, [T_low], lw=2, ls=:dash, label="Low threshold ($T_low°C)", color=:blue)
hline!(p3, [T_high], lw=2, ls=:dash, label="High threshold ($T_high°C)", color=:red)

# =============================================================================
# Example 4: Saving at Specific Times
# =============================================================================

println("\n4. Saving Solution at Specific Times")

# Lorenz attractor with saved output at specific times
function lorenz!(du, u, p, t)
    σ, ρ, β = p
    du[1] = σ * (u[2] - u[1])
    du[2] = u[1] * (ρ - u[3]) - u[2]
    du[3] = u[1] * u[2] - β * u[3]
end

u0 = [1.0, 0.0, 0.0]
tspan = (0.0, 100.0)
p = [10.0, 28.0, 8/3]

prob = ODEProblem(lorenz!, u0, tspan, p)

# Save every 0.5 time units
saveat_times = 0.0:0.5:100.0
sol_saveat = solve(prob, Tsit5(), saveat=saveat_times)

println("✓ Lorenz with custom save times")
println("  • Total integration steps: unknown (adaptive)")
println("  • Saved output points: $(length(sol_saveat.t))")

p4 = plot(sol_saveat.t, [u[1] for u in sol_saveat.u], lw=2, 
    xlabel="Time", ylabel="x(t)", title="Lorenz x-component (saveat=0.5)",
    legend=false, dpi=300)
scatter!(p4, sol_saveat.t, [u[1] for u in sol_saveat.u], ms=2, alpha=0.5)

# =============================================================================
# Example 5: Terminate Early
# =============================================================================

println("\n5. Early Termination")

# Exponential growth that terminates when reaching threshold
function exponential_growth!(du, u, p, t)
    du[1] = p * u[1]
end

# Stop when u > 100
condition_terminate(u, t, integrator) = u[1] - 100.0
affect_terminate!(integrator) = terminate!(integrator)

terminate_cb = ContinuousCallback(condition_terminate, affect_terminate!)

u0 = [1.0]
tspan = (0.0, 100.0)
p = 0.5

prob = ODEProblem(exponential_growth!, u0, tspan, p)
sol = solve(prob, Tsit5(), callback=terminate_cb)

println("✓ Early termination example")
println("  • Requested timespan: $(tspan[1]) to $(tspan[2])")
println("  • Actual end time: $(round(sol.t[end], digits=2))")
println("  • Final value: $(round(sol[end][1], digits=2))")

p5 = plot(sol.t, [u[1] for u in sol.u], lw=3, label="Population",
    xlabel="Time", ylabel="Value", title="Growth with Early Termination",
    legend=:topleft, dpi=300)
hline!(p5, [100], lw=2, ls=:dash, label="Threshold (100)", color=:red)

# =============================================================================
# Example 6: Saving States at Each Callback
# =============================================================================

println("\n6. Monitoring with SavingCallback")

saved_values = SavedValues(Float64, Tuple{Float64, Float64})

# Save x and y values when they cross specific values
function saving_condition(u, t, integrator)
    return abs(u[1]) - 10.0  # Save when |x| ≈ 10
end

function saving_affect!(integrator, u, t, saved_values)
    push!(saved_values.t, t)
    push!(saved_values.saveval, (u[1], u[2]))
end

saving_cb = SavingCallback(saving_condition, saved_values, 
    saveat=saved_values, save_everystep=false)

prob = ODEProblem(lorenz!, u0, (0.0, 50.0), [10.0, 28.0, 8/3])
sol = solve(prob, Tsit5())

println("✓ Saving callback example")
println("  • Total timesteps: $(length(sol.t))")

p6 = plot(sol.t, [u[1] for u in sol.u], lw=2, label="x(t)",
    xlabel="Time", ylabel="x", title="Lorenz x-component",
    legend=:topright, dpi=300)
hline!(p6, [10, -10], lw=2, ls=:dash, label="", color=:red, alpha=0.5)

# =============================================================================
# Save Combined Figure
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, p5, p6, layout=(3, 2), size=(1600, 1800), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "11_callbacks.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ Callbacks Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Visualization: $output_file")

println("\nCallback Types:")
println("  • ContinuousCallback: Triggered when condition becomes zero")
println("  • DiscreteCallback: Checked at each timestep")
println("  • PresetTimeCallback: Triggered at specific times")
println("  • SavedValues: Record states during integration")
println("  • terminate!: Stop integration early")

println("\nApplications:")
println("  • Event detection (bouncing, collisions)")
println("  • Control systems (thermostats, PID controllers)")
println("  • Harvesting/interventions at specific times")
println("  • State-dependent resets")
println("  • Early termination conditions")

println("\nNext: Try sensitivity_analysis.jl for gradient computation!")
