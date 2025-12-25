### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ Cell order:
# ╟─intro
# ╟─setup
# ╠═imports
# ╟─problem_selection
# ╠═solver_controls
# ╟─visualization
# ╟─performance_metrics

# ╔═╡ intro
md"""
# 🌟 OrdinaryDiffEq.jl Interactive Explorer

Welcome to the interactive demonstration of OrdinaryDiffEq.jl!

This notebook allows you to:
- Select from classic ODE problems
- Compare different solvers in real-time
- Adjust parameters and see immediate results
- Analyze performance metrics

## Quick Start
1. Select a problem from the dropdown below
2. Adjust parameters using the sliders
3. Choose solvers to compare
4. Watch the live-updating plots!
"""

# ╔═╡ setup
begin
	# Setup code cell
	md"## Package Setup"
end

# ╔═╡ imports
begin
	using OrdinaryDiffEq
	using Plots
	using PlutoUI
	using Printf
	using Statistics
	using BenchmarkTools
	
	plotly()  # Interactive plots
	md"✓ Packages loaded successfully"
end

# ╔═╡ problem_selection
md"""
## Problem Selection

Choose an ODE system to explore:
"""

# ╔═╡ problem_dropdown
@bind problem_name Select([
	"Lorenz" => "Lorenz Attractor (Chaotic)",
	"VanDerPol" => "Van der Pol Oscillator",
	"Harmonic" => "Harmonic Oscillator",
	"Exponential" => "Exponential Growth",
	"Pendulum" => "Nonlinear Pendulum",
	"SIR" => "SIR Epidemic Model"
])

# ╔═╡ problem_params
begin
	if problem_name == "Lorenz"
		md"""
		### Lorenz Attractor Parameters
		- σ (Prandtl number): $(@bind σ Slider(1:0.5:20, default=10, show_value=true))
		- ρ (Rayleigh number): $(@bind ρ Slider(1:1:50, default=28, show_value=true))
		- β (Geometry): $(@bind β Slider(0.5:0.1:5, default=8/3, show_value=true))
		- Time span: $(@bind tspan_end_lorenz Slider(10:10:100, default=50, show_value=true)) seconds
		"""
	elseif problem_name == "VanDerPol"
		md"""
		### Van der Pol Oscillator Parameters
		- μ (Nonlinearity): $(@bind μ Slider(0.1:0.1:10, default=1.0, show_value=true))
		- Initial x: $(@bind vdp_x0 Slider(-3:0.5:3, default=2.0, show_value=true))
		- Initial velocity: $(@bind vdp_v0 Slider(-3:0.5:3, default=0.0, show_value=true))
		- Time span: $(@bind tspan_end_vdp Slider(10:5:100, default=30, show_value=true)) seconds
		"""
	elseif problem_name == "Harmonic"
		md"""
		### Harmonic Oscillator Parameters
		- ω (Frequency): $(@bind ω Slider(0.5:0.1:5, default=1.0, show_value=true))
		- Initial position: $(@bind harm_x0 Slider(-2:0.5:2, default=1.0, show_value=true))
		- Initial velocity: $(@bind harm_v0 Slider(-2:0.5:2, default=0.0, show_value=true))
		- Time span: $(@bind tspan_end_harm Slider(10:5:50, default=20, show_value=true)) seconds
		"""
	elseif problem_name == "Exponential"
		md"""
		### Exponential Growth Parameters
		- Growth rate: $(@bind growth_rate Slider(0.1:0.1:2, default=1.0, show_value=true))
		- Initial value: $(@bind exp_u0 Slider(0.1:0.1:2, default=0.5, show_value=true))
		- Time span: $(@bind tspan_end_exp Slider(5:1:20, default=10, show_value=true)) seconds
		"""
	elseif problem_name == "Pendulum"
		md"""
		### Nonlinear Pendulum Parameters
		- Initial angle (rad): $(@bind pend_θ0 Slider(0:0.1:π, default=π/4, show_value=true))
		- Damping: $(@bind pend_damp Slider(0:0.05:1, default=0.1, show_value=true))
		- Time span: $(@bind tspan_end_pend Slider(10:5:50, default=30, show_value=true)) seconds
		"""
	else  # SIR
		md"""
		### SIR Model Parameters
		- β (Transmission): $(@bind sir_β Slider(0.1:0.05:1, default=0.5, show_value=true))
		- γ (Recovery): $(@bind sir_γ Slider(0.05:0.01:0.5, default=0.1, show_value=true))
		- Initial infected: $(@bind sir_I0 Slider(1:1:50, default=10, show_value=true))
		- Time span: $(@bind tspan_end_sir Slider(50:10:300, default=150, show_value=true)) days
		"""
	end
end

# ╔═╡ solver_controls
md"""
## Solver Selection

Choose solvers to compare:

- $(@bind use_tsit5 CheckBox(default=true)) Tsit5 (Default, 5th order)
- $(@bind use_vern7 CheckBox(default=true)) Vern7 (High accuracy, 7th order)
- $(@bind use_rk4 CheckBox(default=false)) RK4 (Classic, 4th order)
- $(@bind use_rodas CheckBox(default=false)) Rodas5P (Stiff problems)

Tolerances:
- Relative tolerance: $(@bind reltol Select([1e-3 => "1e-3", 1e-6 => "1e-6", 1e-9 => "1e-9"], default=1e-6))
- Absolute tolerance: $(@bind abstol Select([1e-6 => "1e-6", 1e-9 => "1e-9", 1e-12 => "1e-12"], default=1e-9))
"""

# ╔═╡ create_problem
begin
	# Define the ODE problem based on selection
	local prob
	
	if problem_name == "Lorenz"
		function lorenz!(du, u, p, t)
			σ, ρ, β = p
			du[1] = σ * (u[2] - u[1])
			du[2] = u[1] * (ρ - u[3]) - u[2]
			du[3] = u[1] * u[2] - β * u[3]
		end
		prob = ODEProblem(lorenz!, [1.0, 0.0, 0.0], (0.0, tspan_end_lorenz), [σ, ρ, β])
		
	elseif problem_name == "VanDerPol"
		function van_der_pol!(du, u, p, t)
			μ = p
			du[1] = u[2]
			du[2] = μ * (1 - u[1]^2) * u[2] - u[1]
		end
		prob = ODEProblem(van_der_pol!, [vdp_x0, vdp_v0], (0.0, tspan_end_vdp), μ)
		
	elseif problem_name == "Harmonic"
		function harmonic!(du, u, p, t)
			ω = p
			du[1] = u[2]
			du[2] = -ω^2 * u[1]
		end
		prob = ODEProblem(harmonic!, [harm_x0, harm_v0], (0.0, tspan_end_harm), ω)
		
	elseif problem_name == "Exponential"
		function exponential!(du, u, p, t)
			r = p
			du[1] = r * u[1]
		end
		prob = ODEProblem(exponential!, [exp_u0], (0.0, tspan_end_exp), growth_rate)
		
	elseif problem_name == "Pendulum"
		function pendulum!(du, u, p, t)
			g, L, damp = p
			θ, ω = u
			du[1] = ω
			du[2] = -(g/L) * sin(θ) - damp * ω
		end
		prob = ODEProblem(pendulum!, [pend_θ0, 0.0], (0.0, tspan_end_pend), [9.81, 1.0, pend_damp])
		
	else  # SIR
		function sir!(du, u, p, t)
			S, I, R = u
			β, γ, N = p
			du[1] = -β * S * I / N
			du[2] = β * S * I / N - γ * I
			du[3] = γ * I
		end
		N = 1000.0
		prob = ODEProblem(sir!, [N - sir_I0, sir_I0, 0.0], (0.0, tspan_end_sir), [sir_β, sir_γ, N])
	end
	
	prob
end

# ╔═╡ solve_and_compare
begin
	# Solve with selected solvers
	local solutions = []
	local solvers = []
	local times = []
	
	if use_tsit5
		push!(solvers, "Tsit5")
		t = @elapsed sol = solve(prob, Tsit5(), reltol=reltol, abstol=abstol)
		push!(solutions, sol)
		push!(times, t)
	end
	
	if use_vern7
		push!(solvers, "Vern7")
		t = @elapsed sol = solve(prob, Vern7(), reltol=reltol, abstol=abstol)
		push!(solutions, sol)
		push!(times, t)
	end
	
	if use_rk4
		push!(solvers, "RK4")
		t = @elapsed sol = solve(prob, RK4(), reltol=reltol, abstol=abstol)
		push!(solutions, sol)
		push!(times, t)
	end
	
	if use_rodas
		push!(solvers, "Rodas5P")
		t = @elapsed sol = solve(prob, Rodas5P(), reltol=reltol, abstol=abstol)
		push!(solutions, sol)
		push!(times, t)
	end
	
	(solutions=solutions, solvers=solvers, times=times)
end

# ╔═╡ visualization
begin
	if length(solve_and_compare.solutions) > 0
		md"""
		## 📊 Live Visualization
		
		Problem: **$(problem_name)**
		"""
	else
		md"**Please select at least one solver above**"
	end
end

# ╔═╡ plot_solutions
begin
	if length(solve_and_compare.solutions) > 0
		local p
		
		if problem_name == "Lorenz"
			# 3D plot for Lorenz
			p = plot(xlabel="X", ylabel="Y", zlabel="Z", 
				title="Lorenz Attractor", size=(700, 500))
			for (i, (sol, solver)) in enumerate(zip(solve_and_compare.solutions, solve_and_compare.solvers))
				x = [u[1] for u in sol.u]
				y = [u[2] for u in sol.u]
				z = [u[3] for u in sol.u]
				plot!(p, x, y, z, label=solver, lw=2, alpha=0.8)
			end
			
		elseif problem_name in ["VanDerPol", "Harmonic", "Pendulum"]
			# Phase portrait
			p = plot(xlabel="Position", ylabel="Velocity", 
				title="$problem_name Phase Portrait", size=(700, 500),
				aspect_ratio=:equal)
			for (sol, solver) in zip(solve_and_compare.solutions, solve_and_compare.solvers)
				x = [u[1] for u in sol.u]
				y = [u[2] for u in sol.u]
				plot!(p, x, y, label=solver, lw=2, alpha=0.8)
			end
			
		elseif problem_name == "Exponential"
			# Time series
			p = plot(xlabel="Time", ylabel="Value", 
				title="Exponential Growth", size=(700, 500))
			for (sol, solver) in zip(solve_and_compare.solutions, solve_and_compare.solvers)
				plot!(p, sol.t, [u[1] for u in sol.u], label=solver, lw=2, alpha=0.8)
			end
			
		else  # SIR
			p = plot(xlabel="Time (days)", ylabel="Population", 
				title="SIR Epidemic Model", size=(700, 500))
			sol = solve_and_compare.solutions[1]
			S = [u[1] for u in sol.u]
			I = [u[2] for u in sol.u]
			R = [u[3] for u in sol.u]
			plot!(p, sol.t, S, label="Susceptible", lw=2)
			plot!(p, sol.t, I, label="Infected", lw=2)
			plot!(p, sol.t, R, label="Recovered", lw=2)
		end
		
		p
	end
end

# ╔═╡ performance_metrics
begin
	if length(solve_and_compare.solutions) > 0
		md"""
		## ⚡ Performance Metrics
		
		Comparison of solver performance:
		"""
	end
end

# ╔═╡ metrics_table
begin
	if length(solve_and_compare.solutions) > 0
		# Create performance table
		local data = []
		for (i, (sol, solver, time)) in enumerate(zip(solve_and_compare.solutions, 
													   solve_and_compare.solvers, 
													   solve_and_compare.times))
			push!(data, (
				Solver=solver,
				Steps=length(sol.t),
				Time_ms=round(time * 1000, digits=2),
				Step_Size_Avg=round((sol.t[end] - sol.t[1]) / length(sol.t), digits=4)
			))
		end
		
		# Display as markdown table
		local header = "| Solver | Steps | Time (ms) | Avg Step Size |\n|--------|-------|-----------|---------------|\n"
		local rows = ["|$(d.Solver)|$(d.Steps)|$(d.Time_ms)|$(d.Step_Size_Avg)|" for d in data]
		Markdown.parse(header * join(rows, "\n"))
	end
end

# ╔═╡ step_distribution
begin
	if length(solve_and_compare.solutions) > 0
		local p = plot(xlabel="Time", ylabel="Step Number", 
			title="Timestep Distribution", size=(700, 400))
		for (sol, solver) in zip(solve_and_compare.solutions, solve_and_compare.solvers)
			plot!(p, sol.t, 1:length(sol.t), label=solver, lw=2, alpha=0.8)
		end
		p
	end
end

# ╔═╡ info_box
md"""
---
### 💡 Tips

- **Lorenz**: Try σ=10, ρ=28, β=8/3 for classic chaotic behavior
- **Van der Pol**: Large μ (>5) shows stiff behavior - use Rodas5P
- **Harmonic**: Should show perfect oscillations with any solver
- **SIR**: R₀ = β/γ determines epidemic behavior (R₀>1: epidemic, R₀<1: dies out)

### 📚 Learn More

- Adjust parameters and see how solutions change
- Compare solver efficiency (steps vs time)
- Stiff problems need implicit solvers (Rodas5P)
- Non-stiff problems work well with Tsit5 or Vern7

---
**OrdinaryDiffEq.jl** - Part of the SciML ecosystem
"""

# ╔═╡ footer
md"""
<div style="text-align: center; padding: 20px; color: #666;">
	Made with ❤️ using Pluto.jl and OrdinaryDiffEq.jl
</div>
"""
