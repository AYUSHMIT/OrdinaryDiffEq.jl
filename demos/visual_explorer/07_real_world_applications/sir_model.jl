# SIR Epidemiological Model
# Susceptible-Infected-Recovered disease dynamics

using OrdinaryDiffEq
using Plots
using Printf

println("=" ^ 70)
println("SIR Model - Epidemiological Dynamics")
println("=" ^ 70)

# =============================================================================
# SIR Model
# =============================================================================

"""
The SIR model describes disease spread in a population:
    dS/dt = -β*S*I/N
    dI/dt = β*S*I/N - γ*I
    dR/dt = γ*I
    
Where:
    S = Susceptible individuals
    I = Infected individuals
    R = Recovered individuals
    N = Total population (S + I + R)
    β = Transmission rate
    γ = Recovery rate
    R₀ = β/γ = Basic reproduction number
"""

function sir!(du, u, p, t)
    S, I, R = u
    β, γ, N = p
    
    du[1] = -β * S * I / N  # dS/dt
    du[2] = β * S * I / N - γ * I  # dI/dt
    du[3] = γ * I  # dR/dt
end

# =============================================================================
# Baseline Scenario
# =============================================================================

println("\nSimulating baseline SIR model...")

# Parameters
N = 1000.0  # Total population
β = 0.5     # Transmission rate (contacts per day * probability of transmission)
γ = 0.1     # Recovery rate (1/infectious period in days)
R0 = β / γ  # Basic reproduction number

println("  • Population: $N")
println("  • Transmission rate β: $β per day")
println("  • Recovery rate γ: $γ per day")
println("  • R₀ (Basic reproduction number): $(round(R0, digits=2))")

# Initial conditions
I0 = 1.0      # Initially infected
S0 = N - I0   # Initially susceptible
R0_init = 0.0 # Initially recovered

u0 = [S0, I0, R0_init]
tspan = (0.0, 200.0)
p = [β, γ, N]

# Solve
prob = ODEProblem(sir!, u0, tspan, p)
sol = solve(prob, Tsit5())

println("✓ Simulation completed")
println("  • Duration: $(tspan[2]) days")
println("  • Peak infections: $(round(maximum([u[2] for u in sol.u]), digits=1))")
println("  • Final recovered: $(round(sol[end][3], digits=1))")

# =============================================================================
# Visualization: Time Evolution
# =============================================================================

S = [u[1] for u in sol.u]
I = [u[2] for u in sol.u]
R = [u[3] for u in sol.u]

p1 = plot(sol.t, S, label="Susceptible", lw=3, color=:blue,
    xlabel="Time (days)", ylabel="Population", 
    title="SIR Model: Disease Dynamics (R₀=$(round(R0, digits=1)))",
    legend=:right, dpi=300)
plot!(p1, sol.t, I, label="Infected", lw=3, color=:red)
plot!(p1, sol.t, R, label="Recovered", lw=3, color=:green)
hline!(p1, [N], label="Total Population", ls=:dash, color=:black, lw=2)

# Mark peak infection
peak_idx = argmax(I)
peak_time = sol.t[peak_idx]
peak_infections = I[peak_idx]
scatter!(p1, [peak_time], [peak_infections], 
    label="Peak: $(round(Int, peak_infections)) at day $(round(Int, peak_time))",
    color=:red, ms=10)

# =============================================================================
# Explore Different R₀ Values
# =============================================================================

println("\nExploring different R₀ values...")

R0_values = [0.5, 1.0, 1.5, 2.0, 3.0, 5.0]
colors_R0 = [:blue, :cyan, :green, :yellow, :orange, :red]

p2 = plot(xlabel="Time (days)", ylabel="Infected Population",
    title="Impact of R₀ on Disease Spread",
    legend=:topright, dpi=300)

for (i, R0_test) in enumerate(R0_values)
    β_test = R0_test * γ
    p_test = [β_test, γ, N]
    prob_test = ODEProblem(sir!, u0, tspan, p_test)
    sol_test = solve(prob_test, Tsit5())
    I_test = [u[2] for u in sol_test.u]
    plot!(p2, sol_test.t, I_test, 
        label="R₀ = $R0_test", lw=2, color=colors_R0[i])
end

hline!(p2, [0], color=:black, ls=:dot, label="")

# =============================================================================
# Herd Immunity Threshold
# =============================================================================

println("\nCalculating herd immunity threshold...")

# Herd immunity threshold: 1 - 1/R₀
herd_immunity_threshold = (1 - 1/R0) * N

println("  • Herd immunity threshold: $(round(herd_immunity_threshold, digits=1)) ($(round((1-1/R0)*100, digits=1))%)")
println("  • Final recovered: $(round(sol[end][3], digits=1))")
println("  • Attack rate: $(round(sol[end][3]/N*100, digits=1))%")

# =============================================================================
# Intervention Scenarios
# =============================================================================

println("\nSimulating intervention scenarios...")

# Scenario 1: No intervention
sol_no_intervention = sol

# Scenario 2: Social distancing (reduce β by 50% after day 30)
function sir_intervention!(du, u, p, t)
    S, I, R = u
    β, γ, N, t_intervention, reduction = p
    
    β_effective = t < t_intervention ? β : β * (1 - reduction)
    
    du[1] = -β_effective * S * I / N
    du[2] = β_effective * S * I / N - γ * I
    du[3] = γ * I
end

t_intervention = 30.0
reduction = 0.5

prob_intervention = ODEProblem(sir_intervention!, u0, tspan, 
    [β, γ, N, t_intervention, reduction])
sol_intervention = solve(prob_intervention, Tsit5())

I_intervention = [u[2] for u in sol_intervention.u]

p3 = plot(title="Impact of Social Distancing",
    xlabel="Time (days)", ylabel="Infected Population",
    legend=:topright, dpi=300)
plot!(p3, sol_no_intervention.t, I, 
    label="No Intervention", lw=3, color=:red)
plot!(p3, sol_intervention.t, I_intervention, 
    label="50% Contact Reduction (day $t_intervention)", 
    lw=3, color=:blue)
vline!(p3, [t_intervention], label="Intervention Start", 
    ls=:dash, color=:black, lw=2)

println("  • Peak without intervention: $(round(Int, maximum(I)))")
println("  • Peak with intervention: $(round(Int, maximum(I_intervention)))")
println("  • Reduction: $(round((1 - maximum(I_intervention)/maximum(I))*100, digits=1))%")

# =============================================================================
# Phase Portrait
# =============================================================================

p4 = plot(S, I, lw=3, color=:purple,
    xlabel="Susceptible", ylabel="Infected",
    title="SIR Phase Portrait",
    legend=false, dpi=300)
scatter!(p4, [S[1]], [I[1]], color=:green, ms=15, label="Start")
scatter!(p4, [S[end]], [I[end]], color=:red, ms=15, label="End")

# Add isoclines
S_range = 0:10:N
I_threshold = N / R0
vline!(p4, [I_threshold], ls=:dash, color=:black, lw=2, 
    label="Epidemic threshold (S = N/R₀)")

# =============================================================================
# Daily New Cases
# =============================================================================

# Calculate daily new cases (dI/dt + γI = β*S*I/N)
new_cases = β * S .* I / N

p5 = plot(sol.t, new_cases, lw=3, color=:orange,
    xlabel="Time (days)", ylabel="Daily New Cases",
    title="Daily New Infections",
    legend=false, dpi=300)

peak_new_cases_idx = argmax(new_cases)
scatter!(p5, [sol.t[peak_new_cases_idx]], [new_cases[peak_new_cases_idx]],
    color=:red, ms=10, 
    label="Peak: $(round(Int, new_cases[peak_new_cases_idx])) cases/day")

# =============================================================================
# Create Animation
# =============================================================================

println("\nCreating animation...")

anim = @animate for i in 1:5:length(sol.t)
    p_sir = plot(sol.t[1:i], S[1:i], label="Susceptible", lw=3, color=:blue,
        xlabel="Time (days)", ylabel="Population",
        title="SIR Model (Day $(round(Int, sol.t[i])))",
        xlim=(0, tspan[2]), ylim=(0, N),
        legend=:right, dpi=150)
    plot!(p_sir, sol.t[1:i], I[1:i], label="Infected", lw=3, color=:red)
    plot!(p_sir, sol.t[1:i], R[1:i], label="Recovered", lw=3, color=:green)
    
    # Current population sizes
    annotate!(p_sir, tspan[2]*0.05, N*0.9, 
        text("S: $(round(Int, S[i]))\nI: $(round(Int, I[i]))\nR: $(round(Int, R[i]))", 
        :left, 12))
end

gif_file = joinpath("../outputs/animations", "sir_model.gif")
mkpath(dirname(gif_file))
gif(anim, gif_file, fps=20)

# =============================================================================
# Save Combined Figure
# =============================================================================

combined_plot = plot(p1, p2, p3, p4, p5, layout=(3, 2), size=(1600, 1800), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "20_sir_model.png")
savefig(combined_plot, output_file)

println("\n" * "=" ^ 70)
println("✓ SIR Model Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Visualization: $output_file")
println("  • Animation: $gif_file")

println("\nSIR Model Insights:")
println("  • R₀ > 1: Epidemic occurs")
println("  • R₀ < 1: Disease dies out")
println("  • Herd immunity: $(round((1-1/R0)*100, digits=1))% must be immune")
println("  • Peak infections: $(round(Int, maximum(I))) ($(round(maximum(I)/N*100, digits=1))%)")
println("  • Final attack rate: $(round(sol[end][3]/N*100, digits=1))%")
println("  • Interventions can significantly reduce peak infections")

println("\nApplications:")
println("  • COVID-19, influenza, measles modeling")
println("  • Evaluate intervention strategies")
println("  • Predict hospital capacity needs")
println("  • Design vaccination campaigns")

println("\nNext: Try predator_prey.jl for ecological modeling!")
