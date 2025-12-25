# Reaction-Diffusion Pattern Formation
# Turing patterns in 1D

using OrdinaryDiffEq
using Plots

println("=" ^ 70)
println("Reaction-Diffusion - Turing Pattern Formation")
println("=" ^ 70)

# 1D reaction-diffusion with Schnakenberg kinetics
function reaction_diffusion!(du, u, p, t)
    N = length(u) ÷ 2
    a, b, Du, Dv, dx = p
    
    U = @view u[1:N]
    V = @view u[N+1:end]
    dU = @view du[1:N]
    dV = @view du[N+1:end]
    
    # Reaction terms
    @. dU = a - U + U^2 * V
    @. dV = b - U^2 * V
    
    # Diffusion (using finite differences)
    for i in 2:N-1
        dU[i] += Du * (U[i-1] - 2U[i] + U[i+1]) / dx^2
        dV[i] += Dv * (V[i-1] - 2V[i] + V[i+1]) / dx^2
    end
    
    # Periodic boundaries
    dU[1] += Du * (U[N] - 2U[1] + U[2]) / dx^2
    dU[N] += Du * (U[N-1] - 2U[N] + U[1]) / dx^2
    dV[1] += Dv * (V[N] - 2V[1] + V[2]) / dx^2
    dV[N] += Dv * (V[N-1] - 2V[N] + V[1]) / dx^2
end

N = 100
L = 10.0
dx = L / N

a, b = 0.1, 0.9
Du, Dv = 0.1, 1.0

# Initial conditions: uniform + small perturbation
U_ss = a + b
V_ss = b / (a + b)^2
u0 = vcat(U_ss .+ 0.1*randn(N), V_ss .+ 0.1*randn(N))

tspan = (0.0, 50.0)
p = [a, b, Du, Dv, dx]

prob = ODEProblem(reaction_diffusion!, u0, tspan, p)
sol = solve(prob, TRBDF2(), saveat=5.0)

println("✓ Pattern formation simulated")

# Visualize evolution
x = range(0, L, length=N)
anim = @animate for sol_u in sol.u
    U = sol_u[1:N]
    plot(x, U, ylim=(0, 2*U_ss), xlabel="Space", ylabel="U concentration",
        title="Turing Pattern", lw=2, legend=false, dpi=150)
end

mkpath("../outputs/animations")
gif(anim, "../outputs/animations/reaction_diffusion.gif", fps=5)

println("✓ Animation created!")
