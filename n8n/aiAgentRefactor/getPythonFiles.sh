#!/bin/sh

# Function to find all .py files recursively, excluding certain files and directories
find_python_files() {
    dir="$1"
    exclude_list="__init__.py conftest.py setup.py"
    special_chars='[!@#$%^&*(){}\[\];:"\'"'"'\\|~`<>?,]'

    # Check if the directory exists
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' not found." >&2
        exit 1
    fi

    # Use find to exclude files within any directory containing '.venv' or 'venv' in its path
    find "$dir" -type f -name "*.py" | while read -r file; do
        # Skip files if their path contains '/venv/' or '/.venv/'
        case "$file" in
            *"/venv/"*|*"/.venv/"*) continue ;;
        esac

        base_name=$(basename "$file")
        lower_base_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')
        
        # Skip files with special characters in their name
        if echo "$base_name" | grep -qE "$special_chars"; then
            continue
        fi

        for exclude in $exclude_list; do
            if [ "$base_name" = "$exclude" ]; then
                continue 2  # Skip this file and move to the next one
            fi
        done

        # Case-insensitive exclusion for files starting with GeeksforGeeks or Leetcode
        case "$lower_base_name" in
            geeksforgeeks*|leetcode*) continue ;; 
        esac
        
        echo "$file"
    done
}

# Main script flow
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

find_python_files "$1"
