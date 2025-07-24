#!/usr/bin/env zsh

#
# Simple sync script for zsh functions
# Usage: ./sync.zsh
#

set -e

# Load .env if it exists
if [[ -f .env ]]; then
    source .env
fi

# Use ZFUNC_SYNC_DIR from environment or default to ~/.zfunc
SYNC_DIR="${ZFUNC_SYNC_DIR:-~/.zfunc}"

# Expand tilde
SYNC_DIR="${SYNC_DIR/#\~/$HOME}"

# Create sync directory if it doesn't exist
mkdir -p "$SYNC_DIR"

# Sync all files from src/ to sync directory
echo "Syncing functions from src/ to $SYNC_DIR..."
cp -v src/* "$SYNC_DIR/"

echo "✓ Functions synced to $SYNC_DIR"
