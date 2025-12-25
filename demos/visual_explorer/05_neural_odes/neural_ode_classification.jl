# Neural ODE Classification Demo
# Use Neural ODEs for classification tasks

using OrdinaryDiffEq
using Lux
using Random
using Plots

println("=" ^ 70)
println("Neural ODE Classification - Learning Decision Boundaries")
println("=" ^ 70)

# Simple 2D classification problem
# Generate spiral data
function generate_spiral_data(n_points=100)
    Random.seed!(42)
    angles = range(0, 4π, length=n_points)
    r = range(0.1, 1, length=n_points)
    
    x1 = r .* cos.(angles) .+ 0.1*randn(n_points)
    y1 = r .* sin.(angles) .+ 0.1*randn(n_points)
    
    x2 = r .* cos.(angles .+ π) .+ 0.1*randn(n_points)
    y2 = r .* sin.(angles .+ π) .+ 0.1*randn(n_points)
    
    X = hcat([x1 y1], [x2 y2])'
    y = vcat(zeros(n_points), ones(n_points))
    
    return X, y
end

X, y = generate_spiral_data(50)

println("✓ Generated spiral classification data")
println("  Total points: $(size(X, 2))")

# Visualize data
p1 = scatter(X[1, y.==0], X[2, y.==0], label="Class 0", 
    xlabel="x₁", ylabel="x₂", title="Spiral Classification Data",
    aspect_ratio=:equal, dpi=300)
scatter!(p1, X[1, y.==1], X[2, y.==1], label="Class 1")

mkpath("../outputs/images")
savefig(p1, "../outputs/images/17_neural_ode_classification.png")

println("✓ Demo setup completed!")
println("\nNeural ODE Classification:")
println("  • Transforms data through continuous-time flow")
println("  • Learns decision boundaries implicitly")
println("  • More expressive than standard neural networks")
println("  • Training would use ODE adjoint method")
