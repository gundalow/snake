#!/usr/bin/env bash
set -e
echo "=== Building Snake Pilot GDExtension ==="
cd "$(dirname "$0")"
python3 tools/dependency-test/check_deps.py
go mod tidy
echo "Compiling shared library..."
CGO_ENABLED=1 go build -buildmode=c-shared -v -o project/libsnake.so src/main.go
echo "Build successful! Artifact: project/libsnake.so"
