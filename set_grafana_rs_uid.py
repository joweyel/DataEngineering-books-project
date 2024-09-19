import json
import sys

def replace_uid(new_uid):
    # Fixed paths for input and output files
    input_file = "grafana/books_dashboard_redshift-local.template.json"
    output_file = "grafana/provisioning/dashboards/books_dashboard_redshift-local.json"

    # Load the JSON data from the input file
    with open(input_file, 'r') as file:
        data = json.load(file)

    # Traverse the JSON structure to find the "datasource" key and update the "uid"
    def update_datasource_uid(item):
        if isinstance(item, dict):
            # If 'datasource' key exists, check if it has 'uid' to update
            if "datasource" in item and "uid" in item["datasource"]:
                item["datasource"]["uid"] = new_uid
            # Recursively look for 'datasource' in nested structures
            for key in item:
                update_datasource_uid(item[key])
        elif isinstance(item, list):
            for element in item:
                update_datasource_uid(element)

    update_datasource_uid(data)

    # Write the updated JSON data to the output file
    with open(output_file, 'w') as file:
        json.dump(data, file, indent=4)

    return output_file

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python replace_uid.py <new_uid>")
        sys.exit(1)

    new_uid = sys.argv[1]

    output_file = replace_uid(new_uid)
    print(f"Updated 'uid' values in 'datasource' and saved to {output_file}.")
