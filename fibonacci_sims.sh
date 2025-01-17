#!/bin/bash

# Base parameters
OUTPUT_DIR="fibonacci_sims"
GEM5_BINARY="./build/ARM/gem5.opt"
SCRIPT="configs/example/se.py"
PROGRAM="tests/test-progs/fibonacci/bin/fibonacci_arm"
PROGRAM_ARGS="-n 100"

# Configs to test
# Configurations to test
CPU_MODELS=("MinorCPU" "TimingSimpleCPU")
CPU_CLOCKS=("1GHz" "3GHz")
MEM_TYPES=("DDR3_1600_8x8" "DDR4_2400_16x4")

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Iterate over CPU models, clock frequencies, and memory types
for CPU in "${CPU_MODELS[@]}"; do
    for CLOCK in "${CPU_CLOCKS[@]}"; do
        for MEM in "${MEM_TYPES[@]}"; do
            # Create a unique name for the configuration
            CONFIG_NAME="${CPU}_${CLOCK}_${MEM}"
            OUTPUT_SUBDIR="$OUTPUT_DIR/$CONFIG_NAME"

            echo "Running simulation for configuration: $CONFIG_NAME"
            echo "CPU: $CPU, Clock: $CLOCK, Memory: $MEM"
            echo "Output directory: $OUTPUT_SUBDIR"

            # Create the subdirectory for this configuration
            mkdir -p "$OUTPUT_SUBDIR"

            # Run gem5 with the specified configuration
            $GEM5_BINARY -d "$OUTPUT_SUBDIR" $SCRIPT \
                --caches --l2cache \
                --cpu-type=$CPU --cpu-clock=$CLOCK --mem-type=$MEM \
                -c $PROGRAM \
                -o "$PROGRAM_ARGS"

            echo "Simulation for $CONFIG_NAME completed. Results stored in $OUTPUT_SUBDIR."
        done
    done
done