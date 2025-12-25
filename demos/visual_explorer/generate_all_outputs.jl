# Generate All Outputs
# Master script to run all demonstrations and generate visualizations

using Pkg

println("=" ^ 80)
println("OrdinaryDiffEq.jl Visual Explorer - Generate All Outputs")
println("=" ^ 80)

# Activate the project environment
Pkg.activate(@__DIR__)

println("\nActivating project environment...")
println("Installing/updating dependencies...")

try
    Pkg.instantiate()
    println("✓ Dependencies installed successfully")
catch e
    println("⚠ Warning: Some dependencies may not be installed")
    println("  Error: $e")
    println("  Continuing anyway...")
end

# =============================================================================
# Demo Scripts by Category
# =============================================================================

demos = Dict(
    "01_getting_started" => [
        "solver_basics.jl",
        "adaptive_stepping.jl",
        "solver_comparison_intro.jl"
    ],
    "02_classic_problems" => [
        "lorenz_attractor.jl",
        "three_body_problem.jl",
        "van_der_pol.jl",
        "brusselator_2d.jl"
    ],
    "03_solver_comparison" => [
        "work_precision.jl"
    ],
    "04_advanced_features" => [
        "callbacks_demo.jl"
    ],
    "05_neural_odes" => [
        "neural_ode_simple.jl"
    ],
    "06_dae_systems" => [
        "pendulum_dae.jl"
    ],
    "07_real_world_applications" => [
        "sir_model.jl"
    ]
)

# =============================================================================
# Run Demos
# =============================================================================

println("\n" * "=" ^ 80)
println("Running Demonstrations")
println("=" ^ 80)

total_demos = sum(length(scripts) for scripts in values(demos))
completed = 0
failed = []

for (category, scripts) in sort(collect(demos))
    println("\n📁 Category: $category")
    println("-" ^ 80)
    
    for script in scripts
        completed += 1
        script_path = joinpath(@__DIR__, category, script)
        
        print("  [$completed/$total_demos] Running $script... ")
        
        if !isfile(script_path)
            println("❌ NOT FOUND")
            push!(failed, (category, script, "File not found"))
            continue
        end
        
        try
            # Run in a separate process to isolate errors
            result = run(pipeline(`julia --project=$(@__DIR__) $script_path`, 
                                stdout=devnull, stderr=devnull))
            println("✓")
        catch e
            println("❌ FAILED")
            push!(failed, (category, script, string(e)))
        end
    end
end

# =============================================================================
# Summary
# =============================================================================

println("\n" * "=" ^ 80)
println("Summary")
println("=" ^ 80)

successful = total_demos - length(failed)
success_rate = round(successful / total_demos * 100, digits=1)

println("\n📊 Results:")
println("  • Total demos: $total_demos")
println("  • Successful: $successful ($success_rate%)")
println("  • Failed: $(length(failed))")

if length(failed) > 0
    println("\n❌ Failed Demos:")
    for (category, script, error) in failed
        println("  • $category/$script")
        println("    Error: $error")
    end
end

# =============================================================================
# Check Outputs
# =============================================================================

println("\n" * "=" ^ 80)
println("Checking Generated Outputs")
println("=" ^ 80)

output_dirs = [
    "outputs/images",
    "outputs/animations",
    "outputs/videos"
]

for dir in output_dirs
    full_path = joinpath(@__DIR__, dir)
    if isdir(full_path)
        files = readdir(full_path)
        println("\n📂 $dir:")
        println("  • Files: $(length(files))")
        
        # List some files
        if length(files) > 0
            println("  • Examples:")
            for file in files[1:min(5, length(files))]
                size_kb = round(stat(joinpath(full_path, file)).size / 1024, digits=1)
                println("    - $file ($(size_kb) KB)")
            end
            if length(files) > 5
                println("    ... and $(length(files)-5) more")
            end
        end
    else
        println("\n📂 $dir: NOT FOUND")
    end
end

# =============================================================================
# Final Message
# =============================================================================

println("\n" * "=" ^ 80)
if length(failed) == 0
    println("✨ All demos completed successfully!")
else
    println("⚠ Some demos failed. Check the errors above.")
end
println("=" ^ 80)

println("\n📚 Next Steps:")
println("  • View generated images in outputs/images/")
println("  • Watch animations in outputs/animations/")
println("  • View videos in outputs/videos/")
println("  • Run individual demos: julia --project=. 01_getting_started/solver_basics.jl")
println("  • Try interactive notebook: using Pluto; Pluto.run(notebook=\"08_interactive/interactive_explorer.jl\")")

println("\n🎉 Happy Exploring!")
