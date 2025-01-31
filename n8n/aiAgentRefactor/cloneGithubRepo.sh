#!/bin/sh  

# Assign command-line arguments to variables
gitUsername=$1  # First argument: GitHub username
gitPat=$2       # Second argument: GitHub personal access token (PAT)
gitRepo=$3      # Third argument: Repository name

# Clone the specified GitHub repository into a temporary directory
git clone https://$gitUsername:$gitPat@github.com/$gitUsername/$gitRepo /tmp/$gitRepo

# Print the repository name to the console
echo $gitRepo
