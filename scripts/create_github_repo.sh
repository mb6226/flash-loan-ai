#!/usr/bin/env bash
set -euo pipefail

# Create a GitHub repository from the current workspace and push the current branch.
# Uses GitHub CLI `gh` if available, otherwise uses the REST API and the `GITHUB_TOKEN` env var.

print_usage() {
  echo "Usage: $0 [-p|--private] [-n|--name name] [-d|--description 'desc']"
}

PRIVATE=false
REPO_NAME=""
DESCRIPTION=""
ORG=""
    -o|--org)
      ORG="$2"
      shift 2
      ;;

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--private)
      PRIVATE=true
      shift
      ;;
    -n|--name)
      REPO_NAME="$2"
      shift 2
      ;;
    -d|--description)
      DESCRIPTION="$2"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

set -o errexit

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git not found. Please install Git and re-run this script." >&2
  exit 1
fi

if [[ -z "$REPO_NAME" ]]; then
  # default to current directory name
  REPO_NAME=$(basename "$(pwd)")
fi

# Initialize git repo if needed
if [ ! -d .git ]; then
  git init
  git add --all
  git commit -m "chore: initial commit"
fi

echo "Creating GitHub repo: $REPO_NAME (private=$PRIVATE)"

if command -v gh >/dev/null 2>&1; then
  echo "Using GitHub CLI 'gh' to create the repo..."
  # gh will set origin remote and push
  if [[ -n "$ORG" ]]; then
    if [ "$PRIVATE" = true ]; then
      gh repo create "$ORG/$REPO_NAME" --private --source=. --remote=origin --push --confirm
    else
      gh repo create "$ORG/$REPO_NAME" --public --source=. --remote=origin --push --confirm
    fi
  else
    if [ "$PRIVATE" = true ]; then
      gh repo create "$REPO_NAME" --private --source=. --remote=origin --push --confirm
    else
      gh repo create "$REPO_NAME" --public --source=. --remote=origin --push --confirm
    fi
  fi
  else
    gh repo create "$REPO_NAME" --public --source=. --remote=origin --push --confirm
  fi
  echo "Repository created successfully with gh."
  exit 0
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GitHub CLI not found and GITHUB_TOKEN is not set. Install GitHub CLI 'gh' or set environment variable GITHUB_TOKEN." >&2
  echo "To set GITHUB_TOKEN, export it like: export GITHUB_TOKEN='your_token_here'" >&2
  exit 1
fi

if [[ -n "$ORG" ]]; then
  API_URL="https://api.github.com/orgs/$ORG/repos"
else
  API_URL="https://api.github.com/user/repos"
fi
BODY="{\"name\": \"$REPO_NAME\", \"description\": \"$DESCRIPTION\", \"private\": $([ "$PRIVATE" = true ] && echo true || echo false)}"

echo "Creating via REST API..."
RESPONSE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -d "$BODY" "$API_URL")

CLONE_URL=$(echo "$RESPONSE" | grep -o '"clone_url": *"[^"]*"' | sed -E 's/"clone_url": *"([^"]*)"/\1/;s/"//g')
if [[ -z "$CLONE_URL" ]]; then
  echo "Failed to create repo via API. Response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$CLONE_URL"
git branch -M main || true
git push -u origin main

echo "Repository created and pushed: $CLONE_URL"
