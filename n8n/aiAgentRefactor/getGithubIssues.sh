#!/bin/sh

# Script to fetch all open and closed issues from a given GitHub repository.
# It handles both full GitHub URLs and "owner/repo" pairs.
# It also ensures pagination is handled correctly.
# Output format: <issue_number> - <issue_status> - <creator_of_the_issue>

# Check if a repository name or URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <user/repository> OR <https://github.com/user/repository>"
    exit 1
fi

INPUT=$1

# Check if the input is a full GitHub URL
if echo "$INPUT" | grep -qE '^https://github\.com/[^/]+/[^/]+/?$'; then
    # Extract owner/repo from URL
    REPO=$(echo "$INPUT" | sed -E 's|https://github.com/||' | sed 's|/$||')
else
    # Assume it's already in owner/repo format
    REPO=$INPUT
fi

# Base API URL for GitHub issues
BASE_URL="https://api.github.com/repos/$REPO/issues"

# Function to fetch issues of a given state (open/closed)
fetch_issues() {
    STATE=$1  # Issue state: "open" or "closed"
    PAGE=1    # Reset page counter for each state

    while true; do
        # Fetch issues from GitHub API with pagination
        RESPONSE=$(curl -s "$BASE_URL?state=$STATE&per_page=100&page=$PAGE")

        # Count the number of issues in the response
        COUNT=$(echo "$RESPONSE" | jq 'length')

        # If no issues are returned, break the loop (no more pages)
        if [ "$COUNT" -eq 0 ]; then
            break
        fi

        # Extract issue number, status, and creator
        echo "$RESPONSE" | jq -r '.[] | select(.pull_request == null) | "\(.number) - '"$STATE"' - \(.user.login)"'

        # Increment page counter to fetch the next set of results
        PAGE=$((PAGE + 1))
    done
}

# Fetch and print all open issues
fetch_issues "open"

# Fetch and print all closed issues
fetch_issues "closed"
