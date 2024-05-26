import time
import os
import random
import logging
from datetime import datetime
import sys

# Capture Python version and create a log file name with it
python_version = "{}.{}.{}".format(
    sys.version_info.major, sys.version_info.minor, sys.version_info.micro
)
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


def fibonacci_benchmark(duration):
    logging.info("Starting Fibonacci benchmark...")
    print("Starting Fibonacci benchmark...")
    start_time = time.time()
    iterations = 0
    while time.time() - start_time < duration:
        fibonacci(30)
        iterations += 1
    logging.info("Fibonacci benchmark completed {} iterations".format(iterations))
    print("Fibonacci benchmark completed {} iterations".format(iterations))
    return iterations


# CPU Benchmark: Sorting
def sort_benchmark(duration, size):
    logging.info("Starting Sorting benchmark...")
    print("Starting Sorting benchmark...")
    start_time = time.time()
    iterations = 0
    while time.time() - start_time < duration:
        data = [random.random() for _ in range(size)]
        data.sort()
        iterations += 1
    logging.info("Sorting benchmark completed {} iterations".format(iterations))
    print("Sorting benchmark completed {} iterations".format(iterations))
    return iterations


# CPU Benchmark: Prime Number Calculation
def is_prime(n):
    if n <= 1:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True


def prime_benchmark(duration, limit):
    logging.info("Starting Prime Number benchmark...")
    print("Starting Prime Number benchmark...")
    start_time = time.time()
    iterations = 0
    while time.time() - start_time < duration:
        primes = []
        for num in range(2, limit):
            if is_prime(num):
                primes.append(num)
        iterations += 1
    logging.info("Prime Number benchmark completed {} iterations".format(iterations))
    print("Prime Number benchmark completed {} iterations".format(iterations))
    return iterations


# CPU Benchmark: Factorial Calculation
def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n - 1)


def factorial_benchmark(duration):
    logging.info("Starting Factorial benchmark...")
    print("Starting Factorial benchmark...")
    start_time = time.time()
    iterations = 0
    while time.time() - start_time < duration:
        factorial(20)
        iterations += 1
    logging.info("Factorial benchmark completed {} iterations".format(iterations))
    print("Factorial benchmark completed {} iterations".format(iterations))
    return iterations


def cpu_benchmark(duration):
    fibonacci_iterations = fibonacci_benchmark(duration)
    sort_iterations = sort_benchmark(duration, 10000)
    prime_iterations = prime_benchmark(duration, 1000)
    factorial_iterations = factorial_benchmark(duration)
    return fibonacci_iterations, sort_iterations, prime_iterations, factorial_iterations


# I/O Benchmark: File Read/Write
def io_benchmark(duration):
    logging.info("Starting I/O benchmark...")
    print("Starting I/O benchmark...")
    filename = "test_io_benchmark.txt"
    data = "A" * (10**7)  # 10 MB of data

    # Write Benchmark
    start_time = time.time()
    write_bytes = 0
    while time.time() - start_time < duration:
        with open(filename, "w") as f:
            f.write(data)
        write_bytes += len(data)
    logging.info("I/O write benchmark wrote {} bytes".format(write_bytes))
    print("I/O write benchmark wrote {} bytes".format(write_bytes))

    # Read Benchmark
    start_time = time.time()
    read_bytes = 0
    while time.time() - start_time < duration:
        with open(filename, "r") as f:
            f.read()
        read_bytes += len(data)
    logging.info("I/O read benchmark read {} bytes".format(read_bytes))
    print("I/O read benchmark read {} bytes".format(read_bytes))

    # Clean up
    os.remove(filename)

    return write_bytes, read_bytes


# Memory Benchmark: List Operations
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

    fibonacci_iterations, sort_iterations, prime_iterations, factorial_iterations = (
        cpu_benchmark(duration)
    )
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
        "fibonacci_iterations": fibonacci_iterations,
        "sort_iterations": sort_iterations,
        "prime_iterations": prime_iterations,
        "factorial_iterations": factorial_iterations,
        "write_bytes": write_bytes,
        "read_bytes": read_bytes,
        "memory_iterations": memory_iterations,
    }


if __name__ == "__main__":
    # Pass the duration as an argument
    import sys

    duration = int(sys.argv[1])
    results = main(duration)

    # Print results for logging
    for key, value in results.items():
        print("{}={}".format(key, value))

