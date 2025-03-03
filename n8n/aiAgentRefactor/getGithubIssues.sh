#!/bin/sh

# Script to fetch all open and closed issues from a given GitHub repository.
# It handles pagination to ensure all issues are retrieved.
# Output format: <issue_number> - <issue_status> - <creator_of_the_issue>

# Check if a repository name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <user/repository>"
    exit 1
fi

REPO=$1
BASE_URL="https://api.github.com/repos/$REPO/issues"
PAGE=1

fetch_issues() {
    STATE=$1
    while true; do
        RESPONSE=$(curl -s "$BASE_URL?state=$STATE&per_page=100&page=$PAGE")
        COUNT=$(echo "$RESPONSE" | jq 'length')

        if [ "$COUNT" -eq 0 ]; then
            break
        fi

        echo "$RESPONSE" | jq -r '.[] | select(.pull_request == null) | "\(.number) - '"$STATE"' - \(.user.login)"'

        PAGE=$((PAGE + 1))
    done
}

# Fetch all open issues
fetch_issues "open"

# Reset page counter
PAGE=1

# Fetch all closed issues
fetch_issues "closed"
