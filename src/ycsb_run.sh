#!/opt/homebrew/bin/bash
# This script is used to batch generate trace_run.txt for the corresponding workload.
# This script is in the YCSB directory, running on Linux.
# How to run:
#   0. wsl
#   1. export JAVA_OPTS="-Xms512m -Xmx4g"
#   2. bash ycsb_run.sh > record.txt

# Enable globstar to support ** matching
shopt -s globstar

# Define the root path of the target workload directory

TARGET_WORKLOAD_DIR="workloads/**"
# Iterate through each subdirectory of the workloads folder
for workload_subdir in $TARGET_WORKLOAD_DIR; do
    if [ -d "$workload_subdir" ]; then
        echo "process dir: $workload_subdir"

        # Use YCSB to generate trace files
        ./bin/ycsb.sh load kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_load.txt" -p "kvtracer.keymapfile=trace_keys.txt"
        ./bin/ycsb.sh run kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_run.txt" -p "kvtracer.keymapfile=trace_keys.txt"

        # Move the trace_run.txt file to the workload directory
        sudo mv "trace_run.txt" "$workload_subdir/"
    fi
done