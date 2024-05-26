import time
import logging
import random
from datetime import datetime
import sys
import json

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
    logging.info(
        "Memory benchmark read duration: {} seconds ({})".format(
            duration, human_readable_time(duration)
        )
    )
    print(
        "Memory benchmark read duration: {} seconds ({})".format(
            duration, human_readable_time(duration)
        )
    )
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

