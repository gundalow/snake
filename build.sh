#!/usr/bin/env bash
set -e

echo "=== Building Snake Pilot GDExtension ==="

# Ensure we are in the project root
cd "$(dirname "$0")"

# 1. Dependency check
echo "Checking dependencies..."
python3 tools/dependency-test/check_deps.py

# 2. Build Go shared library
echo "Tidying Go modules..."
go mod tidy

echo "Compiling shared library for Linux x86_64..."
# Using c-shared mode for GDExtension.
# Explicitly including all source files in src directory.
go build -buildmode=c-shared -v -o project/libsnake.so src/*.go

echo "Build successful! Artifact: project/libsnake.so"

# 3. Running instructions
echo ""
echo "=== Running Instructions ==="
echo "To run the game, use the Godot 4 executable on the 'project' folder:"
echo "  godot --path project"
echo "Check the console output for [SnakeHead] and [GDExtension] logs."
