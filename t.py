import json


def append_json(file_path, repetitions=1):
    # Read the original content of the file
    with open(file_path, "r") as file:
        data = json.load(file)

    # Append the content to the data multiple times
    original_data = data[:]
    for _ in range(repetitions):
        data.extend(original_data)

    # Write the extended data back to the file
    with open(file_path, "w") as file:
        json.dump(data, file, indent=4)


# Specify the path to your JSON file
file_path = "daytrip.users.json"
append_json(file_path)
