#!/bin/bash

# List of benchmarks
benchmarks=("specbzip" "specmcf" "spechmmer" "specsjeng" "speclibm")

# Paths to executables and inputs
executables=("spec_cpu2006/401.bzip2/src/specbzip"
             "spec_cpu2006/429.mcf/src/specmcf"
             "spec_cpu2006/456.hmmer/src/spechmmer"
             "spec_cpu2006/458.sjeng/src/specsjeng"
             "spec_cpu2006/470.lbm/src/speclibm")
inputs=("spec_cpu2006/401.bzip2/data/input.program 10"
        "spec_cpu2006/429.mcf/data/inp.in"
        "--fixed 0 --mean 325 --num 45000 --sd 200 --seed 0 spec_cpu2006/456.hmmer/data/bombesin.hmm"
        "spec_cpu2006/458.sjeng/data/test.txt"
        "20 spec_cpu2006/470.lbm/data/lbm.in 0 1 spec_cpu2006/470.lbm/data/100_100_130_cf_a.of")

# Simulation parameters
frequencies=("1GHz" "3GHz")
simulation_steps="-I 100000000"

# gem5 binary and config
gem5_binary="./build/ARM/gem5.opt"
gem5_config="configs/example/se.py"

# Directory to store results
results_dir="spec_results"

# Function to run a benchmark
run_benchmark() {
    local benchmark=$1
    local executable=$2
    local input=$3
    local freq=$4

    # Create output directory
    local output_dir="${results_dir}/${benchmark}/${freq}"
    mkdir -p "$output_dir"

    # Run gem5 simulation
    $gem5_binary -d "$output_dir" \
        $gem5_config \
        --cpu-type=MinorCPU \
        --cpu-clock="$freq" \
        --caches --l2cache \
        -c "$executable" \
        -o "$input" \
        $simulation_steps

    echo "Simulation for $benchmark at $freq completed."
}

for i in "${!benchmarks[@]}"; do
    benchmark=${benchmarks[i]}
    executable=${executables[i]}
    input=${inputs[i]}

    # Run at 3GHz
    run_benchmark "$benchmark" "$executable" "$input" "3GHz"

    # Optionally skip 1GHz if already run
    if [ ! -d "${results_dir}/${benchmark}/1GHz" ]; then
        echo "Running $benchmark at 1GHz (not previously run)."
        run_benchmark "$benchmark" "$executable" "$input" "1GHz"
    else
        echo "Skipping $benchmark at 1GHz (already exists)."
    fi
done