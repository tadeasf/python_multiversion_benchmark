import time
import os
import random
import logging
from datetime import datetime
import sys

# Capture Python version and create a log file name with it
python_version = (
    f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
)
log_file_name = f"benchmark_{python_version}.log"

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


def cpu_benchmark():
    logging.info("Starting CPU benchmark...")
    print("Starting CPU benchmark...")
    start_time = time.time()
    for _ in range(400):  # Increased by 20x
        fibonacci(30)
    end_time = time.time()
    duration = end_time - start_time
    logging.info(f"CPU benchmark completed in {duration:.2f} seconds")
    print(f"CPU benchmark completed in {duration:.2f} seconds")


# I/O Benchmark: File Read/Write
def io_benchmark():
    logging.info("Starting I/O benchmark...")
    print("Starting I/O benchmark...")
    filename = "test_io_benchmark.txt"
    data = "A" * (10**7)  # 10 MB of data

    # Write Benchmark
    start_time = time.time()
    for _ in range(5000):  # Increased to run for around a minute
        with open(filename, "w") as f:
            f.write(data)
    end_time = time.time()
    write_duration = end_time - start_time
    logging.info(f"I/O write benchmark completed in {write_duration:.2f} seconds")
    print(f"I/O write benchmark completed in {write_duration:.2f} seconds")

    # Read Benchmark
    start_time = time.time()
    for _ in range(25000):  # Increased to run for around a minute
        with open(filename, "r") as f:
            f.read()
    end_time = time.time()
    read_duration = end_time - start_time
    logging.info(f"I/O read benchmark completed in {read_duration:.2f} seconds")
    print(f"I/O read benchmark completed in {read_duration:.2f} seconds")

    # Clean up
    os.remove(filename)


# Memory Benchmark: List Operations
def memory_benchmark():
    logging.info("Starting Memory benchmark...")
    print("Starting Memory benchmark...")
    start_time = time.time()
    for _ in range(1000):  # Increased to run for around a minute
        lst = [random.random() for _ in range(10**6)]
    end_time = time.time()
    duration = end_time - start_time
    logging.info(f"Memory benchmark completed in {duration:.2f} seconds")
    print(f"Memory benchmark completed in {duration:.2f} seconds")


def main():
    start_time = datetime.now()
    logging.info(f"Benchmark started at {start_time}")
    print(f"Benchmark started at {start_time}")

    cpu_benchmark()
    io_benchmark()
    memory_benchmark()

    end_time = datetime.now()
    logging.info(f"Benchmark completed at {end_time}")
    print(f"Benchmark completed at {end_time}")


if __name__ == "__main__":
    main()
