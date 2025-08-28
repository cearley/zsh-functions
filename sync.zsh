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

# Use ZFUNC_SYNC_DIR from environment or default to ~/.zsh_functions
SYNC_DIR="${ZFUNC_SYNC_DIR:-~/.zsh_functions}"

# Expand tilde
SYNC_DIR="${SYNC_DIR/#\~/$HOME}"

# Create sync directory if it doesn't exist
mkdir -p "$SYNC_DIR"

# Exclude list (filenames only, no path)
EXCLUDE_LIST=(hello)

echo "Syncing functions from src/ to $SYNC_DIR, excluding: $EXCLUDE_LIST..."
for file in src/*; do
    fname="${file:t}"
    skip=false
    for exclude in $EXCLUDE_LIST; do
        if [[ "$fname" == "$exclude" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        cp -v "$file" "$SYNC_DIR/"
    fi
done

echo "✓ Functions synced to $SYNC_DIR"
