#!/bin/bash

# List of Python and PyPy versions to benchmark
VERSIONS=("3.5.10" "3.6.15" "3.7.17" "3.8.10" "3.9.17" "3.10.14" "3.11.9" "3.12.3" "3.13.0b1" "pypy3.8-7.3.11" "pypy3.9-7.3.16" "pypy3.10-7.3.16")

# Duration for each benchmark (in seconds)
BENCHMARK_DURATION=5
REPEATS=3

# Function to run the benchmark using the given Python or PyPy version
run_benchmark() {
	local version=$1
	local duration=$2

	if [[ $version == pypy* ]]; then
		# Switch to the specified PyPy version using pyenv
		pyenv local "$version"
	else
		# Switch to the specified Python version using pyenv
		pyenv local "$version"
	fi

	# Run the benchmark with the specified version
	python benchmark_temp.py "$duration"
}

# Create the temporary Python script with the adjusted benchmark values
cat <<EOF >benchmark_temp.py
import time
import os
import random
import logging
from datetime import datetime
import sys

# Capture Python version and create a log file name with it
python_version = "{}.{}.{}".format(sys.version_info.major, sys.version_info.minor, sys.version_info.micro)
log_file_name = "benchmark_{}.log".format(python_version)

# Setup logger
logging.basicConfig(
    filename=log_file_name,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(message)s",
)

# Robust CPU Benchmark
def cpu_benchmark(duration):
    logging.info("Starting CPU benchmark...")
    print("Starting CPU benchmark...")
    start_time = time.time()
    iterations = 0
    
    def fibonacci(n):
        if n <= 1:
            return n
        else:
            return fibonacci(n - 1) + fibonacci(n - 2)
    
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

# Robust I/O Benchmark
def io_benchmark(duration):
    logging.info("Starting I/O benchmark...")
    print("Starting I/O benchmark...")
    filename = "test_io_benchmark.txt"
    data = "A" * (10**7)  # 10 MB of data

    start_time = time.time()
    write_bytes = 0
    read_bytes = 0
    while time.time() - start_time < duration:
        with open(filename, "w") as f:
            f.write(data)
        write_bytes += len(data)
        with open(filename, "r") as f:
            f.read()
        read_bytes += len(data)
    
    logging.info("I/O write benchmark wrote {} bytes".format(write_bytes))
    print("I/O write benchmark wrote {} bytes".format(write_bytes))
    logging.info("I/O read benchmark read {} bytes".format(read_bytes))
    print("I/O read benchmark read {} bytes".format(read_bytes))

    os.remove(filename)
    return write_bytes, read_bytes

# Robust Memory Benchmark
def memory_benchmark(duration):
    logging.info("Starting Memory benchmark...")
    print("Starting Memory benchmark...")
    start_time = time.time()
    iterations = 0
    while time.time() - start_time < duration:
        lst = [random.random() for _ in range(10**6)]
        iterations += 1
    logging.info("Memory benchmark completed {} iterations".format(iterations))
    print("Memory benchmark completed {} iterations".format(iterations))
    return iterations

def main(duration):
    start_time_total = datetime.now()
    logging.info("Benchmark started at {}".format(start_time_total))
    print("Benchmark started at {}".format(start_time_total))

    cpu_iterations = cpu_benchmark(duration)
    write_bytes, read_bytes = io_benchmark(duration)
    memory_iterations = memory_benchmark(duration)

    end_time_total = datetime.now()
    logging.info("Benchmark completed at {}".format(end_time_total))
    print("Benchmark completed at {}".format(end_time_total))

    total_time = (end_time_total - start_time_total).total_seconds()
    logging.info("Total benchmark time: {:.2f} seconds".format(total_time))
    print("Total benchmark time: {:.2f} seconds".format(total_time))

    # Return results for logging
    return {
        "cpu_iterations": cpu_iterations,
        "write_bytes": write_bytes,
        "read_bytes": read_bytes,
        "memory_iterations": memory_iterations
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
	if (($len % 2 == 0)); then
		echo $(((${arr[len / 2 - 1]} + ${arr[len / 2]}) / 2))
	else
		echo ${arr[len / 2]}
	fi
}

# Function to convert bytes to a human-readable format
human_readable() {
	local bytes=$1
	local units=("B" "KB" "MB" "GB" "TB")

	for unit in "${units[@]}"; do
		if ((bytes < 1024)); then
			echo "$bytes $unit"
			return
		fi
		bytes=$((bytes / 1024))
	done
	echo "$bytes ${units[-1]}"
}

# Run the benchmark for each specified version and collect results
baseline_results=()
results=()

for version in "${VERSIONS[@]}"; do
	echo "Running benchmark for $version..."
	cpu_iterations=()
	write_bytes=()
	read_bytes=()
	memory_iterations=()

	for _ in $(seq 1 $REPEATS); do
		output=$(run_benchmark "$version" "$BENCHMARK_DURATION")

		cpu_iterations+=($(echo "$output" | grep 'cpu_iterations=' | cut -d'=' -f2))
		write_bytes+=($(echo "$output" | grep 'write_bytes=' | cut -d'=' -f2))
		read_bytes+=($(echo "$output" | grep 'read_bytes=' | cut -d'=' -f2))
		memory_iterations+=($(echo "$output" | grep 'memory_iterations=' | cut -d'=' -f2))
	done

	cpu_median=$(median "${cpu_iterations[@]}")
	write_median=$(median "${write_bytes[@]}")
	read_median=$(median "${read_bytes[@]}")
	memory_median=$(median "${memory_iterations[@]}")

	results+=("$version,$cpu_median,$write_median,$read_median,$memory_median")

	# If it's the first iteration, save it as the baseline
	if [ "$version" == "${VERSIONS[0]}" ]; then
		echo "Saving baseline results for $version..."
		baseline_results=("$version,$cpu_median,$write_median,$read_median,$memory_median")
	fi
done

# Log the final results
echo -e "\nBenchmark Results:\n"
baseline_result=(${baseline_results[0]//,/ })

for result in "${results[@]}"; do
	result_array=(${result//,/ })
	version=${result_array[0]}
	echo -e "Version: $version"
	for i in {1..4}; do
		benchmark_name=""
		case $i in
		1) benchmark_name="cpu_iterations" ;;
		2) benchmark_name="write_bytes" ;;
		3) benchmark_name="read_bytes" ;;
		4) benchmark_name="memory_iterations" ;;
		esac
		current_value=${result_array[$i]}
		baseline_value=${baseline_result[$i]}
		percentage=$(echo "scale=2; ($current_value / $baseline_value) * 100" | bc)
		performance_difference=$(echo "scale=2; $percentage - 100" | bc)
		if [[ $benchmark_name == "write_bytes" || $benchmark_name == "read_bytes" ]]; then
			current_value_hr=$(human_readable $current_value)
			baseline_value_hr=$(human_readable $baseline_value)
			echo -e "$benchmark_name: $current_value_hr (Baseline: $baseline_value_hr, Performance: $percentage%, Difference: $performance_difference%)"
		else
			echo -e "$benchmark_name: $current_value (Baseline: $baseline_value, Performance: $percentage%, Difference: $performance_difference%)"
		fi
	done
	echo -e "\n"
done

# Clean up temporary files
rm benchmark_temp.py
