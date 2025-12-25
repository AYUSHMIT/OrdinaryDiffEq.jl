# Electrical Circuit DAE Demo
# RLC circuit as differential-algebraic equation

using OrdinaryDiffEq
using Plots

println("=" ^ 70)
println("Electrical Circuit - RLC Circuit DAE")
println("=" ^ 70)

# RLC circuit with current as algebraic variable
function rlc_circuit!(residual, du, u, p, t)
    R, L, C, V_in = p
    V_C, I = u  # Capacitor voltage, current
    dV_C, dI = du
    
    # Kirchhoff's voltage law (algebraic)
    residual[1] = V_in - R*I - L*dI - V_C
    
    # Capacitor equation (differential)
    residual[2] = dV_C - I/C
end

# Parameters
R = 100.0    # Resistance (Ω)
L = 0.1      # Inductance (H)
C = 1e-4     # Capacitance (F)
V_in = 10.0  # Input voltage (V)

u0 = [0.0, 0.0]   # Initial: V_C=0, I=0
du0 = [0.0, V_in/L]  # Initial derivatives
tspan = (0.0, 0.1)   # 100ms
p = [R, L, C, V_in]

differential_vars = [true, false]  # V_C is differential, I is algebraic

prob = DAEProblem(rlc_circuit!, du0, u0, tspan, p, differential_vars=differential_vars)
sol = solve(prob, IDA())

println("✓ RLC circuit simulated")
println("  Natural frequency: $(round(1/sqrt(L*C)/2π, digits=1)) Hz")

V_C = [u[1] for u in sol.u]
I = [u[2] for u in sol.u]

p1 = plot(sol.t*1000, V_C, lw=2, label="Capacitor Voltage", 
    xlabel="Time (ms)", ylabel="Voltage (V)", dpi=300)
hline!(p1, [V_in], ls=:dash, label="Input Voltage", color=:red)

p2 = plot(sol.t*1000, I*1000, lw=2, label="Current", 
    xlabel="Time (ms)", ylabel="Current (mA)", dpi=300, legend=:topright)

combined = plot(p1, p2, layout=(2,1), size=(1200, 800), dpi=300)
mkpath("../outputs/images")
savefig(combined, "../outputs/images/19_electrical_circuit.png")

println("✓ Circuit simulation completed!")
