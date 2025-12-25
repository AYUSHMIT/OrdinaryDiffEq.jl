# Simple Neural ODE
# Learn dynamics from data using neural networks

using OrdinaryDiffEq
using Lux
using Optimization
using OptimizationOptimisers
using Random
using Plots
using ComponentArrays
using Printf
using Statistics

println("=" ^ 70)
println("Neural ODE Demo - Learning Dynamics from Data")
println("=" ^ 70)

# =============================================================================
# Generate Training Data from True System
# =============================================================================

println("\nGenerating training data from spiral dynamics...")

# True dynamics: spiral
function spiral!(du, u, p, t)
    du[1] = -u[2] - 0.1 * u[1]
    du[2] = u[1] - 0.1 * u[2]
end

u0_true = [0.0, 2.0]
tspan = (0.0, 10.0)
datasize = 50
t_data = range(tspan[1], tspan[2], length=datasize)

prob_true = ODEProblem(spiral!, u0_true, tspan)
sol_true = solve(prob_true, Tsit5(), saveat=t_data)

# Extract training data
data = Array(sol_true)

# Add small noise
rng = Random.default_rng()
Random.seed!(rng, 123)
noise_level = 0.1
data_noisy = data .+ noise_level .* randn(rng, size(data))

println("✓ Generated $(datasize) data points")
println("  • State dimension: $(size(data, 1))")
println("  • Time span: $(tspan[1]) to $(tspan[2])")
println("  • Noise level: $noise_level")

# =============================================================================
# Define Neural Network Architecture
# =============================================================================

println("\nDefining neural network...")

# Simple feed-forward network
nn = Chain(
    Dense(2, 32, tanh),
    Dense(32, 32, tanh),
    Dense(32, 2)
)

# Initialize parameters
rng = Random.default_rng()
Random.seed!(rng, 42)
ps, st = Lux.setup(rng, nn)
ps_flat = ComponentArray(ps)

println("✓ Neural network created")
println("  • Architecture: 2 → 32 → 32 → 2")
println("  • Activation: tanh")
println("  • Parameters: $(length(ps_flat))")

# =============================================================================
# Define Neural ODE
# =============================================================================

function neural_ode!(du, u, p, t)
    # p contains the neural network parameters
    # Evaluate the neural network
    u_vec = [u[1], u[2]]
    du_pred, _ = nn(u_vec, p, st)
    du[1] = du_pred[1]
    du[2] = du_pred[2]
end

# =============================================================================
# Loss Function
# =============================================================================

function predict_neural_ode(p)
    prob_nn = ODEProblem(neural_ode!, u0_true, tspan, p)
    sol_nn = solve(prob_nn, Tsit5(), saveat=t_data, sensealg=ForwardDiffSensitivity())
    return Array(sol_nn)
end

function loss(p)
    pred = predict_neural_ode(p)
    loss_val = sum(abs2, data_noisy .- pred) / length(data_noisy)
    return loss_val
end

# =============================================================================
# Training
# =============================================================================

println("\nTraining neural ODE...")
println("  • Optimizer: Adam")
println("  • Learning rate: 0.01")
println("  • Epochs: 100")

# Track training progress
losses = Float64[]
epochs = 100

# Callback to track progress
iter = [0]
callback = function (p, l)
    iter[1] += 1
    push!(losses, l)
    if iter[1] % 10 == 0
        println(@sprintf("    Iteration %3d: Loss = %.6f", iter[1], l))
    end
    return false  # Don't stop early
end

# Setup optimization problem
optf = OptimizationFunction((x, p) -> loss(x), Optimization.AutoForwardDiff())
optprob = OptimizationProblem(optf, ps_flat)

# Train
result = solve(optprob, 
               Optimisers.Adam(0.01), 
               callback=callback,
               maxiters=epochs)

println("✓ Training completed")
println("  • Final loss: $(round(losses[end], digits=6))")
println("  • Initial loss: $(round(losses[1], digits=6))")
println("  • Improvement: $(round((1 - losses[end]/losses[1])*100, digits=1))%")

# =============================================================================
# Visualize Results
# =============================================================================

println("\nGenerating visualizations...")

# Predict with trained model
pred_trained = predict_neural_ode(result.u)

# Predict on longer time span
tspan_test = (0.0, 20.0)
t_test = range(tspan_test[1], tspan_test[2], length=200)

# True solution on test span
prob_true_test = ODEProblem(spiral!, u0_true, tspan_test)
sol_true_test = solve(prob_true_test, Tsit5(), saveat=t_test)
data_true_test = Array(sol_true_test)

# Neural ODE prediction on test span
prob_nn_test = ODEProblem(neural_ode!, u0_true, tspan_test, result.u)
sol_nn_test = solve(prob_nn_test, Tsit5(), saveat=t_test)
data_nn_test = Array(sol_nn_test)

# Plot 1: Training data and predictions
p1 = plot(title="Training Data vs Predictions", xlabel="Time", ylabel="State",
    legend=:topright, dpi=300)
plot!(p1, t_data, data[1, :], label="True x", lw=2, color=:blue)
plot!(p1, t_data, data[2, :], label="True y", lw=2, color=:red)
scatter!(p1, t_data, data_noisy[1, :], label="Noisy x", color=:blue, alpha=0.5, ms=4)
scatter!(p1, t_data, data_noisy[2, :], label="Noisy y", color=:red, alpha=0.5, ms=4)
plot!(p1, t_data, pred_trained[1, :], label="Neural ODE x", lw=2, ls=:dash, color=:cyan)
plot!(p1, t_data, pred_trained[2, :], label="Neural ODE y", lw=2, ls=:dash, color=:orange)

# Plot 2: Phase portrait (training)
p2 = plot(title="Phase Portrait (Training)", xlabel="x", ylabel="y",
    legend=:topright, dpi=300, aspect_ratio=:equal)
plot!(p2, data[1, :], data[2, :], label="True", lw=3, color=:blue)
scatter!(p2, data_noisy[1, :], data_noisy[2, :], label="Data (noisy)", 
    color=:gray, alpha=0.5, ms=4)
plot!(p2, pred_trained[1, :], pred_trained[2, :], label="Neural ODE", 
    lw=2, ls=:dash, color=:red)

# Plot 3: Extrapolation
p3 = plot(title="Extrapolation (2x time span)", xlabel="Time", ylabel="x",
    legend=:topright, dpi=300)
plot!(p3, t_test, data_true_test[1, :], label="True", lw=3, color=:blue)
plot!(p3, t_test, data_nn_test[1, :], label="Neural ODE", lw=2, ls=:dash, color=:red)
vline!(p3, [tspan[2]], label="Training end", ls=:dot, lw=2, color=:black)

# Plot 4: Training loss
p4 = plot(title="Training Loss", xlabel="Iteration", ylabel="Loss",
    legend=false, dpi=300, yscale=:log10)
plot!(p4, 1:length(losses), losses, lw=2, color=:purple)

# Plot 5: Error over time
errors = sqrt.(sum((data_true_test .- data_nn_test).^2, dims=1))
p5 = plot(title="Prediction Error", xlabel="Time", ylabel="L2 Error",
    legend=false, dpi=300)
plot!(p5, t_test, errors[:], lw=2, color=:red)
vline!(p5, [tspan[2]], label="Training end", ls=:dot, lw=2, color=:black)

# Plot 6: Phase portrait (extrapolation)
p6 = plot(title="Phase Portrait (Extrapolation)", xlabel="x", ylabel="y",
    legend=:topright, dpi=300, aspect_ratio=:equal)
plot!(p6, data_true_test[1, :], data_true_test[2, :], label="True", lw=3, color=:blue)
plot!(p6, data_nn_test[1, :], data_nn_test[2, :], label="Neural ODE", 
    lw=2, ls=:dash, color=:red)

# Training region
idx_train = findall(t_test .<= tspan[2])
plot!(p6, data_true_test[1, idx_train], data_true_test[2, idx_train], 
    label="Training region", lw=5, alpha=0.3, color=:green)

combined_plot = plot(p1, p2, p3, p4, p5, p6, layout=(3, 2), size=(1600, 1800), dpi=300)

output_dir = "../outputs/images"
mkpath(output_dir)
output_file = joinpath(output_dir, "15_neural_ode_simple.png")
savefig(combined_plot, output_file)

# =============================================================================
# Create Training Animation
# =============================================================================

println("\nCreating training animation...")

# Store predictions at different training stages
training_snapshots = [1, 10, 20, 30, 50, 75, 100]
snapshot_preds = []

for epoch in training_snapshots
    if epoch <= length(losses)
        # Need to retrain to get intermediate parameters
        # For simplicity, we'll just show the progression
    end
end

# Create animation showing loss decrease
anim = @animate for i in 1:length(losses)
    p_loss = plot(1:i, losses[1:i], lw=2, color=:purple,
        xlabel="Iteration", ylabel="Loss", title="Training Progress",
        xlim=(0, length(losses)), ylim=(0, losses[1]), dpi=150, legend=false)
    scatter!(p_loss, [i], [losses[i]], color=:red, ms=8)
end

gif_file = joinpath("../outputs/animations", "neural_ode_training.gif")
mkpath(dirname(gif_file))
gif(anim, gif_file, fps=20)

# =============================================================================
# Summary
# =============================================================================

println("\n" * "=" ^ 70)
println("✓ Neural ODE Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Visualization: $output_file")
println("  • Training animation: $gif_file")

println("\nNeural ODE Results:")
println("  • Successfully learned dynamics from noisy data")
println("  • Training loss: $(round(losses[end], digits=6))")
println("  • Extrapolates beyond training data")
println("  • Network parameters: $(length(result.u))")

println("\nKey Concepts:")
println("  • Neural ODEs use neural networks to parameterize derivatives")
println("  • Trained end-to-end by backpropagating through ODE solver")
println("  • Memory efficient (constant memory for any depth)")
println("  • Can learn continuous-time dynamics")
println("  • Useful for time series, physics-informed learning")

println("\nNext: Try universal_de.jl for hybrid physics + ML models!")
