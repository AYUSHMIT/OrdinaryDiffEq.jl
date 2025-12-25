# Robertson DAE Problem
# Classic stiff chemical kinetics example

using OrdinaryDiffEq
using Plots

println("=" ^ 70)
println("Robertson Problem - Stiff Chemical Kinetics DAE")
println("=" ^ 70)

# Robertson problem: 3 species chemical reaction
# dy1/dt = -0.04*y1 + 1e4*y2*y3
# dy2/dt = 0.04*y1 - 1e4*y2*y3 - 3e7*y2^2
# 0 = y1 + y2 + y3 - 1  (conservation)

function robertson_dae!(residual, du, u, p, t)
    y1, y2, y3 = u
    dy1, dy2, dy3 = du
    
    residual[1] = dy1 + 0.04*y1 - 1e4*y2*y3
    residual[2] = dy2 - 0.04*y1 + 1e4*y2*y3 + 3e7*y2^2
    residual[3] = y1 + y2 + y3 - 1.0  # Algebraic constraint
end

u0 = [1.0, 0.0, 0.0]
du0 = [-0.04, 0.04, 0.0]
tspan = (0.0, 1e5)  # Very long time scale

differential_vars = [true, true, false]  # y3 is algebraic

prob = DAEProblem(robertson_dae!, du0, u0, tspan, nothing, 
    differential_vars=differential_vars)

sol = solve(prob, IDA())

println("✓ Robertson problem solved")
println("  Timesteps: $(length(sol.t))")
println("  Final time: $(sol.t[end])")

y1 = [u[1] for u in sol.u]
y2 = [u[2] for u in sol.u]
y3 = [u[3] for u in sol.u]

p1 = plot(sol.t, y1, xscale=:log10, lw=2, label="y₁", 
    xlabel="Time", ylabel="Concentration", 
    title="Robertson Chemical Kinetics", dpi=300, legend=:right)
plot!(p1, sol.t, y2, xscale=:log10, lw=2, label="y₂")
plot!(p1, sol.t, y3, xscale=:log10, lw=2, label="y₃")

# Check conservation
conservation = [u[1] + u[2] + u[3] for u in sol.u]
p2 = plot(sol.t, abs.(conservation .- 1.0), xscale=:log10, yscale=:log10,
    lw=2, xlabel="Time", ylabel="|Conservation Error|",
    title="Conservation of Mass", legend=false, dpi=300)

combined = plot(p1, p2, layout=(2,1), size=(1200, 800), dpi=300)
mkpath("../outputs/images")
savefig(combined, "../outputs/images/19_robertson_dae.png")

println("✓ Robertson DAE demonstration completed!")
println("\nProblem characteristics:")
println("  • Very stiff (time scales from 1e-3 to 1e5)")
println("  • Classic DAE benchmark problem")
println("  • Mass conservation constraint")
println("  • Requires implicit DAE solver")
