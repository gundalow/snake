#!/bin/bash

# Exit on any error
set -e

echo "--- Refreshing Godot Cache ---"

# 1. Remove UID cache and existing .uid files which often get out of sync during renames
echo "Removing UID cache and stale .uid files..."
rm -f .godot/uid_cache.bin
find . -name "*.uid" -type f -delete

# 2. Trigger a headless import to regenerate UIDs and imports
# We use a timeout because sometimes the editor headless process hangs on exit
echo "Regenerating UIDs and imports (headless)..."
timeout 15 godot --headless --editor --quit || echo "Note: Headless import timed out or finished."

# 3. Run the game
echo "--- Starting Snake 3D ---"
godot
