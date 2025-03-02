#!/bin/sh

# ===================================================================
# Script Name: cleanN8NJson.sh
# Author: Johan Louwers
# Description: This script processes an N8N JSON output file that may
#              contain formatting issues. The script ensures the JSON 
#              structure is properly formatted by performing the following:
#
#              1. **Remove the first line** - N8N sometimes adds an 
#                 extra "output" line before the JSON content.
#              2. **Trim first and last character** - In some cases, 
#                 the JSON output is wrapped in extra double quotes.
#              3. **Fix double double-quotes** - Some improperly formatted 
#                 JSON structures may contain `""` instead of `"`.
#
# Usage: ./cleanN8NJson.sh <file_path>
#
# Parameters:
#   file_path - The path to the JSON file that needs to be cleaned.
#
# Example:
#   ./cleanN8NJson.sh /path/to/n8n_output.json
#
# Notes:
#   - This script modifies the file **in place**.
#   - Ensure you have a backup before running if necessary.
# ===================================================================

# Validate input
if [ -z "$1" ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

file="$1"
temp_file="${file}.tmp"

# Ensure the file exists
if [ ! -f "$file" ]; then
    exit 1
fi

# Step 1: Remove the first line (if present)
sed -i '1d' "$file"

# Step 2: Remove first and last character if the file is not empty
if [ -s "$file" ]; then
    tail -c +2 "$file" | head -c -1 > "$temp_file"
    mv "$temp_file" "$file"
else
    exit 1  # Exit if file is empty after line removal
fi

# Step 3: Replace all occurrences of "" with "
sed -i 's/""/"/g' "$file"
