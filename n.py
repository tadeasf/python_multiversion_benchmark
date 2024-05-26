import ijson
import json


def remove_first_half(file_path):
    # First, count the total number of objects in the file
    with open(file_path, "r") as file:
        objects = ijson.items(file, "item")
        total_count = sum(1 for _ in objects)

    # Calculate the number of objects to skip
    half_count = total_count // 2

    # Open the file again to read and write the remaining objects
    with open(file_path, "r") as file:
        objects = ijson.items(file, "item")

        with open("temp_file.json", "w") as temp_file:
            for i, obj in enumerate(objects):
                if i >= half_count:
                    json.dump(obj, temp_file)
                    temp_file.write("\n")

    # Replace original file with the temporary file
    import os

    os.replace("temp_file.json", file_path)


# Specify the path to your JSON file
file_path = "daytrip.users.json"

remove_first_half(file_path)
