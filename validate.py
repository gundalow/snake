#!/usr/bin/env python3
import shutil
import subprocess
import sys
from pathlib import Path

def check_godot():
    """Checks if 'godot' is available in the system PATH."""
    godot_path = shutil.which("godot")
    if not godot_path:
        print("Error: 'godot' not found in system PATH.", file=sys.stderr)
        return False
    print(f"Found Godot at: {godot_path}")
    return True

def verify_files():
    """Checks if critical project files exist."""
    required_files = [
        "project.godot",
        "scenes/main/main.tscn",
        "scenes/ui/hud.tscn",
        "scripts/core/Spinner.gd",
        "scripts/utils/FPSCounter.gd"
    ]
    all_exist = True
    for file_path in required_files:
        if not Path(file_path).exists():
            print(f"Error: Missing file: {file_path}", file=sys.stderr)
            all_exist = False
    return all_exist

def run_headless_parse():
    """Runs Godot in headless mode to catch syntax errors."""
    print("Running Godot headless validation...")
    try:
        # Use --headless --editor --quit --check-only to validate the project
        result = subprocess.run(
            ["godot", "--headless", "--editor", "--quit", "--check-only"],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode != 0:
            print("Error: Godot headless validation failed.", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
        return True
    except subprocess.TimeoutExpired:
        print("Error: Godot validation timed out.", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error: An unexpected error occurred: {e}", file=sys.stderr)
        return False

def main():
    if not check_godot():
        sys.exit(1)
    
    if not verify_files():
        sys.exit(1)
    
    if not run_headless_parse():
        sys.exit(1)
        
    print("All validation checks passed!")
    sys.exit(0)

if __name__ == "__main__":
    main()
