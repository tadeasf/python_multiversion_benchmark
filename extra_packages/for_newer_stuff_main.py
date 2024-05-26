import time
import os
import random
from rich.console import Console
from rich.progress import track, Progress
from rich.traceback import install
from loguru import logger

# Setup rich traceback
install()

# Setup logger
logger.add("benchmark.log", format="{time} {level} {message}", level="DEBUG")

console = Console()


# CPU Benchmark: Fibonacci Calculation
def fibonacci(n):
    if n <= 1:
        return n
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)


def cpu_benchmark():
    logger.info("Starting CPU benchmark...")
    console.print("[bold blue]Starting CPU benchmark...[/bold blue]")
    start_time = time.time()
    for _ in track(range(20), description="Calculating Fibonacci..."):
        fibonacci(30)
    end_time = time.time()
    duration = end_time - start_time
    logger.success(f"CPU benchmark completed in {duration:.2f} seconds")
    console.print(
        f"[bold green]CPU benchmark completed in {duration:.2f} seconds[/bold green]"
    )


# I/O Benchmark: File Read/Write
def io_benchmark():
    logger.info("Starting I/O benchmark...")
    console.print("[bold blue]Starting I/O benchmark...[/bold blue]")
    filename = "test_io_benchmark.txt"
    data = "A" * (10**7)  # 10 MB of data

    # Write Benchmark
    start_time = time.time()
    with open(filename, "w") as f:
        for _ in track(range(10), description="Writing to file..."):
            f.write(data)
    end_time = time.time()
    write_duration = end_time - start_time
    logger.success(f"I/O write benchmark completed in {write_duration:.2f} seconds")
    console.print(
        f"[bold green]I/O write benchmark completed in {write_duration:.2f} seconds[/bold green]"
    )

    # Read Benchmark
    start_time = time.time()
    with open(filename, "r") as f:
        for _ in track(range(10), description="Reading from file..."):
            f.read()
    end_time = time.time()
    read_duration = end_time - start_time
    logger.success(f"I/O read benchmark completed in {read_duration:.2f} seconds")
    console.print(
        f"[bold green]I/O read benchmark completed in {read_duration:.2f} seconds[/bold green]"
    )

    # Clean up
    os.remove(filename)


# Memory Benchmark: List Operations
def memory_benchmark():
    logger.info("Starting Memory benchmark...")
    console.print("[bold blue]Starting Memory benchmark...[/bold blue]")
    start_time = time.time()
    for _ in track(range(20), description="Allocating memory..."):
        lst = [random.random() for _ in range(10**6)]
    end_time = time.time()
    duration = end_time - start_time
    logger.success(f"Memory benchmark completed in {duration:.2f} seconds")
    console.print(
        f"[bold green]Memory benchmark completed in {duration:.2f} seconds[/bold green]"
    )


def main():
    cpu_benchmark()
    io_benchmark()
    memory_benchmark()


if __name__ == "__main__":
    main()
