#!/bin/bash

# List of Python and PyPy versions to benchmark
VERSIONS=("3.5.10" "3.6.15" "3.7.17" "3.8.10" "3.9.17" "3.10.14" "3.11.9" "3.12.3" "3.13.0b1")

# Duration for each benchmark (in seconds)
BENCHMARK_DURATION=1
REPEATS=10

# Function to run the benchmark using the given Python or PyPy version
run_benchmark() {
	local version=$1
	local duration=$2

	# Switch to the specified Python/PyPy version using pyenv
	pyenv local "$version"

	# Run the benchmark with the specified version
	python benchmark_temp.py "$duration"
}

# Create the temporary Python script with the adjusted benchmark values
cat <<EOF >benchmark_temp.py
import time
import logging
import random
from datetime import datetime
import sys
import json

# Capture Python version and create a log file name with it
python_version = "{}.{}.{}".format(sys.version_info.major, sys.version_info.minor, sys.version_info.micro)
log_file_name = "benchmark_{}.log".format(python_version)

# Setup logger
logging.basicConfig(
    filename=log_file_name,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(message)s",
)

# Convert time to a human-readable format
def human_readable_time(seconds):
    if seconds < 1:
        return "{:.2f} ms".format(seconds * 1000)
    elif seconds < 60:
        return "{:.2f} s".format(seconds)
    elif seconds < 3600:
        return "{:.2f} min".format(seconds / 60)
    else:
        return "{:.2f} hours".format(seconds / 3600)

# Robust CPU Benchmark
def cpu_benchmark(duration):
    logging.info("Starting CPU benchmark...")
    print("Starting CPU benchmark...")
    start_time = time.time()
    iterations = 0
    
    def fibonacci(n):
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a
    
    def is_prime(n):
        if n <= 1:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    while time.time() - start_time < duration:
        fibonacci(30)
        data = [random.random() for _ in range(10000)]
        data.sort()
        primes = [num for num in range(2, 1000) if is_prime(num)]
        iterations += 1
    
    logging.info("CPU benchmark completed {} iterations".format(iterations))
    print("CPU benchmark completed {} iterations".format(iterations))
    return iterations

# Memory Benchmark to measure read time
def memory_benchmark():
    logging.info("Starting Memory benchmark...")
    print("Starting Memory benchmark...")
    start_time = time.time()
    try:
        with open("daytrip.users.json", "r") as f:
            f.read()
    except json.JSONDecodeError as e:
        logging.error("JSONDecodeError: {}".format(e))
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Memory benchmark read duration: {} seconds ({})".format(duration, human_readable_time(duration)))
    print("Memory benchmark read duration: {} seconds ({})".format(duration, human_readable_time(duration)))
    return duration

def main(duration):
    start_time_total = datetime.now()
    logging.info("Benchmark started at {}".format(start_time_total))
    print("Benchmark started at {}".format(start_time_total))

    cpu_iterations = cpu_benchmark(duration)
    memory_duration = memory_benchmark()

    end_time_total = datetime.now()
    logging.info("Benchmark completed at {}".format(end_time_total))
    print("Benchmark completed at {}".format(end_time_total))

    total_time = (end_time_total - start_time_total).total_seconds()
    logging.info("Total benchmark time: {:.2f} seconds".format(total_time))
    print("Total benchmark time: {:.2f} seconds".format(total_time))

    # Return results for logging
    return {
        "cpu_iterations": cpu_iterations,
        "memory_duration": memory_duration,
    }

if __name__ == "__main__":
    # Pass the duration as an argument
    import sys
    duration = int(sys.argv[1])
    results = main(duration)
    
    # Print results for logging
    for key, value in results.items():
        print("{}={}".format(key, value))
EOF

# Function to calculate the median of an array
median() {
	arr=($(printf '%s\n' "$@" | sort -n))
	len=${#arr[@]}
	if [ $len -eq 0 ]; then
		echo 0
	elif (($len % 2 == 0)); then
		# Use `bc` for floating-point arithmetic
		echo "scale=10; (${arr[$((len / 2 - 1))]} + ${arr[$((len / 2))]}) / 2" | bc
	else
		echo ${arr[$((len / 2))]}
	fi
}

# Run the benchmark for each specified version and collect results
baseline_results=()
results=()

for version in "${VERSIONS[@]}"; do
	echo "Running benchmark for $version..."
	cpu_iterations=()
	memory_durations=()

	for _ in $(seq 1 $REPEATS); do
		output=$(run_benchmark "$version" "$BENCHMARK_DURATION")

		cpu_iterations+=($(echo "$output" | grep 'cpu_iterations=' | cut -d'=' -f2))
		memory_durations+=($(echo "$output" | grep 'memory_duration=' | cut -d'=' -f2))
	done

	cpu_median=$(median "${cpu_iterations[@]}")
	memory_median=$(median "${memory_durations[@]}")

	results+=("$version,$cpu_median,$memory_median")

	# If it's the first iteration, save it as the baseline
	if [ "$version" == "${VERSIONS[0]}" ]; then
		echo "Saving baseline results for $version..."
		baseline_results=("$version,$cpu_median,$memory_median")
	fi
done

# Log the final results
echo -e "\nBenchmark Results:\n"
baseline_result=(${baseline_results[0]//,/ })

log_file="benchmark.log"
echo -e "\nBenchmark Results:\n" >"$log_file"
for result in "${results[@]}"; do
	result_array=(${result//,/ })
	version=${result_array[0]}
	echo -e "Version: $version" | tee -a "$log_file"
	for i in {1..2}; do
		benchmark_name=""
		case $i in
		1) benchmark_name="cpu_iterations" ;;
		2) benchmark_name="memory_duration" ;;
		esac
		current_value=${result_array[$i]}
		baseline_value=${baseline_result[$i]}
		percentage=$(echo "scale=2; ($current_value / $baseline_value) * 100" | bc)
		performance_difference=$(echo "scale=2; $percentage - 100" | bc)
		if [[ $benchmark_name == "memory_duration" ]]; then
			current_value_hr=$(python3 -c "print('{:.2f} s'.format($current_value))")
			baseline_value_hr=$(python3 -c "print('{:.2f} s'.format($baseline_value))")
			echo -e "$benchmark_name: $current_value_hr (Baseline: $baseline_value_hr, Performance: $percentage%, Difference: $performance_difference%)" | tee -a "$log_file"
		else
			echo -e "$benchmark_name: $current_value (Baseline: $baseline_value, Performance: $percentage%, Difference: $performance_difference%)" | tee -a "$log_file"
		fi
	done
	echo -e "\n" | tee -a "$log_file"
done

# Clean up temporary files
rm benchmark_temp.py
