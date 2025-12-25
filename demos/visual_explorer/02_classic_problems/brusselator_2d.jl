# Brusselator: 2D Pattern Formation
# Reaction-diffusion system showing Turing patterns

using OrdinaryDiffEq
using Plots
using SparseArrays
using LinearAlgebra

println("=" ^ 70)
println("Brusselator 2D - Pattern Formation via Turing Instability")
println("=" ^ 70)

# =============================================================================
# 2D Brusselator Model
# =============================================================================

"""
The Brusselator is a theoretical model for autocatalytic reactions:
    ∂u/∂t = A + u²v - (B+1)u + Du*∇²u
    ∂v/∂t = Bu - u²v + Dv*∇²v
"""

# Grid parameters
N = 32  # Grid size (N x N)
dx = 1.0
dy = 1.0

println("\nGrid configuration:")
println("  • Grid size: $(N)x$(N)")
println("  • Spatial step: dx=$dx, dy=$dy")

# =============================================================================
# Construct Laplacian Operator
# =============================================================================

function laplacian_2d(N)
    # 2D Laplacian with periodic boundary conditions
    Δx = sparse(Tridiagonal(ones(N-1), -2*ones(N), ones(N-1))) / dx^2
    Δy = sparse(Tridiagonal(ones(N-1), -2*ones(N), ones(N-1))) / dy^2
    
    # Periodic boundaries
    Δx[1, N] = 1/dx^2
    Δx[N, 1] = 1/dx^2
    Δy[1, N] = 1/dy^2
    Δy[N, 1] = 1/dy^2
    
    # Kronecker product for 2D
    Ix = sparse(I, N, N)
    Iy = sparse(I, N, N)
    Δ = kron(Iy, Δx) + kron(Δy, Ix)
    
    return Δ
end

Δ = laplacian_2d(N)

println("✓ Laplacian operator constructed")

# =============================================================================
# Brusselator RHS
# =============================================================================

function brusselator_2d!(du, u, p, t)
    A, B, Du, Dv, Δ = p
    N = Int(sqrt(length(u) ÷ 2))
    
    # Split into u and v components
    u_comp = @view u[1:N^2]
    v_comp = @view u[N^2+1:end]
    du_comp = @view du[1:N^2]
    dv_comp = @view du[N^2+1:end]
    
    # Reaction terms
    @. du_comp = A + u_comp^2 * v_comp - (B+1) * u_comp
    @. dv_comp = B * u_comp - u_comp^2 * v_comp
    
    # Diffusion terms
    du_comp .+= Du * (Δ * u_comp)
    dv_comp .+= Dv * (Δ * v_comp)
end

# =============================================================================
# Initial Conditions with Perturbation
# =============================================================================

# Parameters
A = 3.4
B = 1.0
Du = 0.01
Dv = 0.1

println("\nParameters:")
println("  • A = $A")
println("  • B = $B")
println("  • Du (u diffusion) = $Du")
println("  • Dv (v diffusion) = $Dv")

# Steady state values
u_ss = A
v_ss = B / A

# Initial conditions: steady state with random perturbations
u0 = zeros(2 * N^2)
u0[1:N^2] .= u_ss .+ 0.1 * randn(N^2)
u0[N^2+1:end] .= v_ss .+ 0.1 * randn(N^2)

tspan = (0.0, 20.0)
p = [A, B, Du, Dv, Δ]

# =============================================================================
# Solve
# =============================================================================

println("\nSolving Brusselator system...")
println("  • State dimension: $(length(u0))")
println("  • Time span: $(tspan[1]) to $(tspan[2])")

prob = ODEProblem(brusselator_2d!, u0, tspan, p)
sol = solve(prob, TRBDF2(), saveat=0.5)

println("✓ Solution computed")
println("  • Timesteps saved: $(length(sol.t))")

# =============================================================================
# Visualization
# =============================================================================

println("\nCreating visualizations...")

function extract_field(sol_u, component, N)
    if component == :u
        field = sol_u[1:N^2]
    else
        field = sol_u[N^2+1:end]
    end
    return reshape(field, N, N)
end

# Plot evolution of u field
times_to_plot = [1, 5, 10, 20, 30, 40]
plots = []

for (i, idx) in enumerate(times_to_plot)
    if idx <= length(sol.t)
        u_field = extract_field(sol.u[idx], :u, N)
        p_temp = heatmap(u_field, aspect_ratio=:equal, 
            title="t = $(round(sol.t[idx], digits=1))",
            colorbar=false, clims=(0, 2*A), dpi=200)
        push!(plots, p_temp)
    end
end

p1 = plot(plots..., layout=(2, 3), size=(1800, 1200), 
    plot_title="Brusselator: u field evolution")

# Plot final pattern (both u and v)
u_final = extract_field(sol.u[end], :u, N)
v_final = extract_field(sol.u[end], :v, N)

p2 = heatmap(u_final, aspect_ratio=:equal, title="u field (final)",
    xlabel="x", ylabel="y", dpi=300)
p3 = heatmap(v_final, aspect_ratio=:equal, title="v field (final)",
    xlabel="x", ylabel="y", dpi=300)

p_final = plot(p2, p3, layout=(1, 2), size=(1600, 700))

# Time series at center point
center_idx = N÷2 + (N÷2-1)*N
u_center = [sol.u[i][center_idx] for i in 1:length(sol.t)]
v_center = [sol.u[i][center_idx + N^2] for i in 1:length(sol.t)]

p4 = plot(sol.t, u_center, label="u", lw=2, 
    xlabel="Time", ylabel="Concentration", title="Center point dynamics",
    legend=:topright, dpi=300)
plot!(p4, sol.t, v_center, label="v", lw=2)

# Save
output_dir = "../outputs/images"
mkpath(output_dir)
savefig(p1, joinpath(output_dir, "07_brusselator_evolution.png"))
savefig(p_final, joinpath(output_dir, "07_brusselator_final.png"))
savefig(p4, joinpath(output_dir, "07_brusselator_timeseries.png"))

# =============================================================================
# Create Animation
# =============================================================================

println("\nCreating animation...")

anim = @animate for i in 1:length(sol.t)
    u_field = extract_field(sol.u[i], :u, N)
    heatmap(u_field, aspect_ratio=:equal, 
        title="Brusselator (t=$(round(sol.t[i], digits=1)))",
        clims=(0, 2*A), colorbar=true, dpi=150)
end

gif_file = joinpath("../outputs/animations", "brusselator_pattern.gif")
mkpath(dirname(gif_file))
gif(anim, gif_file, fps=10)

println("\n" * "=" ^ 70)
println("✓ Brusselator Demo Completed!")
println("=" ^ 70)

println("\nGenerated Files:")
println("  • Evolution: $(joinpath(output_dir, "07_brusselator_evolution.png"))")
println("  • Final pattern: $(joinpath(output_dir, "07_brusselator_final.png"))")
println("  • Time series: $(joinpath(output_dir, "07_brusselator_timeseries.png"))")
println("  • Animation: $gif_file")

println("\nPattern Formation:")
println("  • Turing patterns emerge from diffusion-driven instability")
println("  • Requires different diffusion rates (Du ≠ Dv)")
println("  • Patterns are self-organizing and stable")
println("  • Found in biology: animal coat patterns, embryo development")

println("\nNext: Explore more classical problems or advanced features!")
