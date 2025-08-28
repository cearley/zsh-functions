#!/usr/bin/env zsh

#
# Simple sync script for zsh functions
# Usage: ./sync.zsh
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"

# Load .env if it exists (relative to script location) and ZFUNC_SYNC_DIR isn't already set
if [[ -z "$ZFUNC_SYNC_DIR" && -f "$SCRIPT_DIR/.env" ]]; then
    source "$SCRIPT_DIR/.env"
fi

# Use ZFUNC_SYNC_DIR from environment/command line, or default
SYNC_DIR="${ZFUNC_SYNC_DIR:-~/.zsh_functions}"

# Expand tilde
SYNC_DIR="${SYNC_DIR/#\~/$HOME}"

# Create sync directory if it doesn't exist
mkdir -p "$SYNC_DIR"

# Exclude list (filenames only, no path)
EXCLUDE_LIST=(hello)

echo "Syncing functions from $SCRIPT_DIR/src/ to $SYNC_DIR, excluding: $EXCLUDE_LIST..."
for file in "$SCRIPT_DIR"/src/*; do
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
