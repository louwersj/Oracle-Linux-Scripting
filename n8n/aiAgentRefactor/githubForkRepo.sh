#!/bin/sh
# Fork a githuib repo automatically to for with a random (UID based) name
# by providing two parameters;
# 1) A full github repo url (https)
# 2) A PAT to authenticate against github

# Check if both input 1 and input 2 are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Both input 1 and input 2 are required."
  exit 1
fi

# Check if parameter 2 starts with one of the valid prefixes
case "$2" in
  ghp_*|gho_*|ghu_*|ghs_*|ghr_*) 
    # Valid token format, continue
    ;;
  *)
    echo "Parameter 2 is not a valid GitHub Personal Access Token."
    exit 1
    ;;
esac

# Check if $1 matches the GitHub repository URL pattern
case "$1" in
  https://github.com/*/*)
    # Valid GitHub repository URL format, continue
    ;;
  *)
    echo "Parameter 1 is not a valid GitHub repository URL."
    exit 1
    ;;
esac

newRepoId=$(cat /proc/sys/kernel/random/uuid | awk '{print toupper($0)}')

# Uncomment and run the following to fork the repo
echo $2 | gh auth login --with-token
gh repo fork "$1" --fork-name "PR_$newRepoId" --remote=false --clone=false
gh auth logout 

#print the fork name
echo "PR_$newRepoId"
