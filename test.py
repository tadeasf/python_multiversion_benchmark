import json
import logging
import time


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


def memory_benchmark():
    logging.info("Starting Memory benchmark...")
    print("Starting Memory benchmark...")
    start_time = time.time()
    try:
        with open("daytrip.users.json", "r") as f:
            data = f.read()
            json.loads(data)  # Parsing JSON content
    except json.JSONDecodeError as e:
        logging.error("JSONDecodeError: {}".format(e))
    end_time = time.time()
    duration = end_time - start_time
    logging.info(
        "Memory benchmark read and parse duration: {} seconds ({})".format(
            duration, human_readable_time(duration)
        )
    )
    print(
        "Memory benchmark read and parse duration: {} seconds ({})".format(
            duration, human_readable_time(duration)
        )
    )
    return duration


# Example of running the benchmark
if __name__ == "__main__":
    memory_benchmark()
