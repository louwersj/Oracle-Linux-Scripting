#!/bin/sh

# Generate a random number between 0 and 99
PAGE=$(( RANDOM % 100 ))

# GitHub API URL with the random page number
URL="https://api.github.com/search/repositories?q=language:Python&order=desc&sort=updated&per_page=10&page=${PAGE}"

# Fetch the JSON data
JSON=$(curl -s "$URL")

# Check if the curl command succeeded
if [ $? -ne 0 ] || [ -z "$JSON" ]; then
  echo "Error: Unable to fetch data from GitHub API"
  exit 1
fi

# Extract 'html_url' values excluding those inside "owner" objects
URLS=$(echo "$JSON" | 
  tr -d '\n' | 
  sed 's/},/},\n/g' | 
  grep '"html_url"' | 
  grep -v '"owner":' | 
  sed -n 's/.*"html_url": "\([^"]*\)".*/\1/p')

# Check if any URLs were extracted
if [ -z "$URLS" ]; then
  echo "Error: No valid 'html_url' found in the JSON response"
  exit 1
fi

# Count the number of URLs
URL_COUNT=0
for URL in $URLS; do
  URL_COUNT=$((URL_COUNT + 1))
done

# Select a random URL index
RANDOM_INDEX=$(( RANDOM % URL_COUNT + 1 ))

# Retrieve the random URL by iterating through the list
CURRENT_INDEX=0
for URL in $URLS; do
  CURRENT_INDEX=$((CURRENT_INDEX + 1))
  if [ $CURRENT_INDEX -eq $RANDOM_INDEX ]; then
    HTML_URL=$URL
    break
  fi
done

# Output the selected URL
echo "$HTML_URL"
