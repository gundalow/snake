#!/bin/bash

# Exit on any error
set -e

# Disable X11 Input Method (XIM) modifiers to prevent non-fatal log spam on Linux.
# This fixes the common Godot warning: "WARNING: XCreateIC couldn't create wd.xic."
# This warning occurs when Godot fails to create an input context for multiple 
# windows/popups. Since this game doesn't require complex text input, disabling 
# XMODIFIERS is safe and results in cleaner logs.
export XMODIFIERS=""

# Default behavior: don't clean unless requested
CLEAN=false
if [[ "$1" == "--clean" ]]; then
    CLEAN=true
    shift # Remove the flag from arguments so it isn't passed to godot
fi

if [ "$CLEAN" = true ]; then
    echo "--- Refreshing Godot Cache ---"
    # Remove UID cache and existing .uid files which often get out of sync during renames
    echo "Removing UID cache and stale .uid files..."
    rm -f .godot/uid_cache.bin
    find . -name "*.uid" -type f -delete

    # Trigger a headless import to regenerate UIDs and imports
    echo "Regenerating UIDs and imports (headless)..."
    timeout 15 godot --headless --editor --quit || echo "Note: Headless import timed out or finished."
fi

# Run the game
echo "--- Starting Snake 3D ---"
godot "$@"
