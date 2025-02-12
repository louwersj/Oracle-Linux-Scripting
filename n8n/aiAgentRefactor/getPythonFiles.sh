#!/bin/sh

# Function to find all .py files recursively, excluding certain files
find_python_files() {
    dir="$1"
    exclude_list="__init__.py conftest.py setup.py"

    # Check if the directory exists
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' not found." >&2
        exit 1
    fi

    # Use find and filter out excluded files
    find "$dir" -type f -name "*.py" | while read -r file; do
        base_name=$(basename "$file")
        for exclude in $exclude_list; do
            if [ "$base_name" = "$exclude" ]; then
                continue 2  # Skip this file and move to the next one
            fi
        done
        echo "$file"
    done
}

# Main script flow
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

find_python_files "$1"
