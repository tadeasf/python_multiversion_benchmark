#!/bin/bash

# List of Python and PyPy versions to benchmark
VERSIONS=("3.5.10" "3.6.15" "3.7.17" "3.8.10" "3.9.17" "3.10.14" "3.11.9" "3.12.3" "3.13.0b1" "pypy3.8-7.3.11" "pypy3.9-7.3.16" "pypy3.10-7.3.16")

# Initial benchmark values set for the lowest Python version
CPU_ITERATIONS=400
IO_WRITE_ITERATIONS=5000
IO_READ_ITERATIONS=25000
MEMORY_ITERATIONS=1000

# Function to run the benchmark using the given Python or PyPy version
run_benchmark() {
	local version=$1
	local cpu_iterations=$2
	local io_write_iterations=$3
	local io_read_iterations=$4
	local memory_iterations=$5

	if [[ $version == pypy* ]]; then
		# Switch to the specified PyPy version using pyenv
		pyenv local "$version"
	else
		# Switch to the specified Python version using pyenv
		pyenv local "$version"
	fi

	# Run the benchmark with the specified version
	python benchmark_temp.py "$cpu_iterations" "$io_write_iterations" "$io_read_iterations" "$memory_iterations"
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

# CPU Benchmark: Fibonacci Calculation
def fibonacci(n):
    if n <= 1:
        return n
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)

def fibonacci_benchmark(iterations):
    logging.info("Starting Fibonacci benchmark...")
    print("Starting Fibonacci benchmark...")
    start_time = time.time()
    for _ in range(iterations):
        fibonacci(30)
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Fibonacci benchmark completed in {:.2f} seconds".format(duration))
    print("Fibonacci benchmark completed in {:.2f} seconds".format(duration))
    return duration

# CPU Benchmark: Sorting
def sort_benchmark(iterations, size):
    logging.info("Starting Sorting benchmark...")
    print("Starting Sorting benchmark...")
    start_time = time.time()
    for _ in range(iterations):
        data = [random.random() for _ in range(size)]
        data.sort()
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Sorting benchmark completed in {:.2f} seconds".format(duration))
    print("Sorting benchmark completed in {:.2f} seconds".format(duration))
    return duration

# CPU Benchmark: Prime Number Calculation
def is_prime(n):
    if n <= 1:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

def prime_benchmark(iterations, limit):
    logging.info("Starting Prime Number benchmark...")
    print("Starting Prime Number benchmark...")
    start_time = time.time()
    for _ in range(iterations):
        primes = []
        for num in range(2, limit):
            if is_prime(num):
                primes.append(num)
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Prime Number benchmark completed in {:.2f} seconds".format(duration))
    print("Prime Number benchmark completed in {:.2f} seconds".format(duration))
    return duration

# CPU Benchmark: Factorial Calculation
def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n - 1)

def factorial_benchmark(iterations):
    logging.info("Starting Factorial benchmark...")
    print("Starting Factorial benchmark...")
    start_time = time.time()
    for _ in range(iterations):
        factorial(20)
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Factorial benchmark completed in {:.2f} seconds".format(duration))
    print("Factorial benchmark completed in {:.2f} seconds".format(duration))
    return duration

def cpu_benchmark(cpu_iterations):
    total_duration = 0
    total_duration += fibonacci_benchmark(cpu_iterations)
    total_duration += sort_benchmark(cpu_iterations, 10000)
    total_duration += prime_benchmark(cpu_iterations, 1000)
    total_duration += factorial_benchmark(cpu_iterations)
    return total_duration

# I/O Benchmark: File Read/Write
def io_benchmark(io_write_iterations, io_read_iterations):
    logging.info("Starting I/O benchmark...")
    print("Starting I/O benchmark...")
    filename = "test_io_benchmark.txt"
    data = "A" * (10**7)  # 10 MB of data

    # Write Benchmark
    start_time = time.time()
    for _ in range(io_write_iterations):
        with open(filename, "w") as f:
            f.write(data)
    end_time = time.time()
    write_duration = end_time - start_time
    logging.info("I/O write benchmark completed in {:.2f} seconds".format(write_duration))
    print("I/O write benchmark completed in {:.2f} seconds".format(write_duration))

    # Read Benchmark
    start_time = time.time()
    for _ in range(io_read_iterations):
        with open(filename, "r") as f:
            f.read()
    end_time = time.time()
    read_duration = end_time - start_time
    logging.info("I/O read benchmark completed in {:.2f} seconds".format(read_duration))
    print("I/O read benchmark completed in {:.2f} seconds".format(read_duration))

    # Clean up
    os.remove(filename)
    
    return write_duration + read_duration

# Memory Benchmark: List Operations
def memory_benchmark(memory_iterations):
    logging.info("Starting Memory benchmark...")
    print("Starting Memory benchmark...")
    start_time = time.time()
    for _ in range(memory_iterations):
        lst = [random.random() for _ in range(10**6)]
    end_time = time.time()
    duration = end_time - start_time
    logging.info("Memory benchmark completed in {:.2f} seconds".format(duration))
    print("Memory benchmark completed in {:.2f} seconds".format(duration))
    return duration

def main(cpu_iterations, io_write_iterations, io_read_iterations, memory_iterations):
    start_time_total = datetime.now()
    logging.info("Benchmark started at {}".format(start_time_total))
    print("Benchmark started at {}".format(start_time_total))

    total_duration = 0
    total_duration += cpu_benchmark(cpu_iterations)
    total_duration += io_benchmark(io_write_iterations, io_read_iterations)
    total_duration += memory_benchmark(memory_iterations)

    end_time_total = datetime.now()
    logging.info("Benchmark completed at {}".format(end_time_total))
    print("Benchmark completed at {}".format(end_time_total))

    total_time = (end_time_total - start_time_total).total_seconds()
    logging.info("Total benchmark time: {:.2f} seconds".format(total_time))
    print("Total benchmark time: {:.2f} seconds".format(total_time))

if __name__ == "__main__":
    # Pass the iteration values as arguments
    import sys
    cpu_iterations = int(sys.argv[1])
    io_write_iterations = int(sys.argv[2])
    io_read_iterations = int(sys.argv[3])
    memory_iterations = int(sys.argv[4])
    main(cpu_iterations, io_write_iterations, io_read_iterations, memory_iterations)
EOF

# Run the benchmark for each specified version
for version in "${VERSIONS[@]}"; do
	echo "Running benchmark for $version..."
	run_benchmark "$version" "$CPU_ITERATIONS" "$IO_WRITE_ITERATIONS" "$IO_READ_ITERATIONS" "$MEMORY_ITERATIONS"

	# If it's the first iteration, adjust the benchmark values based on the lowest version
	if [ "$version" == "${VERSIONS[0]}" ]; then
		echo "Adjusting benchmark values based on the lowest version ($version)..."
		CPU_ITERATIONS=400
		IO_WRITE_ITERATIONS=5000
		IO_READ_ITERATIONS=25000
		MEMORY_ITERATIONS=1000
	fi
done

# Clean up temporary files
rm benchmark_temp.py
