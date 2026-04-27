#!/bin/bash
set -e

REPO_DIR="/home/admin/.openclaw/workspace/articlehub"
cd "$REPO_DIR"

# Pull latest changes
git pull origin main

# Add all new files
git add -A

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    git commit -m "auto: sync articlehub docs $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    echo "Changes committed and pushed"
fi
