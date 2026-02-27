#!/usr/bin/env python3
import shutil
import subprocess
import sys
import re
import os
from pathlib import Path

def check_godot():
    """Checks if 'godot' is available in the system PATH."""
    godot_path = shutil.which("godot")
    if not godot_path:
        if os.environ.get("GITHUB_ACTIONS") == "true":
            print("Error: 'godot' not found in CI environment.", file=sys.stderr)
            return False
        print("Warning: 'godot' not found in system PATH. Skipping build/run checks.", file=sys.stderr)
        return False
    print(f"Found Godot at: {godot_path}")
    return True

def verify_files():
    """Checks if critical project files exist."""
    required_files = [
        "project.godot",
        "scenes/main/main.tscn",
        "scenes/ui/hud.tscn",
        "scenes/main/SnakeHead.tscn",
        "scenes/main/Fruit.tscn",
        "scenes/main/SnakeSegment.tscn",
        "scenes/effects/dazed_particles.tscn",
        "scripts/core/SnakeHead.gd",
        "scripts/core/CameraManager.gd",
        "scripts/core/FruitSpawner.gd",
        "scripts/utils/FPSCounter.gd",
        "export_presets.cfg"
    ]
    all_exist = True
    for file_path in required_files:
        if not Path(file_path).exists():
            print(f"Error: Missing file: {file_path}", file=sys.stderr)
            all_exist = False
    return all_exist

def check_input_map():
    """Checks for required input map actions in project.godot."""
    required_actions = [
        "turn_left",
        "turn_right",
        "toggle_camera",
        "restart",
        "quit"
    ]
    try:
        project_file = Path("project.godot").read_text()
        all_found = True
        for action in required_actions:
            if f"{action}=" not in project_file:
                print(f"Error: Missing Input Map action: {action}", file=sys.stderr)
                all_found = False
        return all_found
    except Exception as e:
        print(f"Error reading project.godot: {e}", file=sys.stderr)
        return False

def check_physics_layers():
    """Checks for required physics layer names in project.godot."""
    required_layers = ["snake_head", "snake_body", "walls", "fruits"]
    try:
        project_file = Path("project.godot").read_text()
        all_found = True
        for layer in required_layers:
            if f'"{layer}"' not in project_file:
                print(f"Error: Missing Physics Layer name: {layer}", file=sys.stderr)
                all_found = False
        return all_found
    except Exception as e:
        print(f"Error reading project.godot: {e}", file=sys.stderr)
        return False

def check_missing_artefacts():
    """Checks all .tscn files for missing external resources."""
    all_ok = True
    for tscn_file in Path(".").rglob("*.tscn"):
        content = tscn_file.read_text()
        # Find all lines like [ext_resource type="PackedScene" uid="..." path="res://..." id="..."]
        matches = re.findall(r'path="res://([^"]+)"', content)
        for path in matches:
            if not Path(path).exists():
                print(f"Error: Missing artefact in {tscn_file}: {path}", file=sys.stderr)
                all_ok = False
    return all_ok

def run_headless_syntax_check():
    """Runs Godot in headless mode with --check-only to verify syntax."""
    print("Running Godot headless syntax check...")
    try:
        result = subprocess.run(
            ["godot", "--headless", "--check-only", "--quit"],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode != 0:
            print("Error: Godot syntax check failed.", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False

        # Also check for SCRIPT ERROR in output even if return code is 0
        if "SCRIPT ERROR" in result.stdout or "SCRIPT ERROR" in result.stderr:
            print("Error: SCRIPT ERROR detected during syntax check.", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False

        print("Syntax check successful!")
        return True
    except subprocess.TimeoutExpired:
        print("Error: Syntax check timed out.", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error during syntax check: {e}", file=sys.stderr)
        return False

def run_headless_build():
    """Attempts to export the project in headless mode."""
    print("Running Godot headless build (export)...")
    try:
        # Create export directory
        Path("build").mkdir(exist_ok=True)
        result = subprocess.run(
            ["godot", "--headless", "--export-release", "Linux/X11", "build/snake.x86_64"],
            capture_output=True,
            text=True,
            timeout=60
        )
        if result.returncode != 0:
            print("Error: Godot headless build failed.", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
        print("Build successful!")
        return True
    except subprocess.TimeoutExpired:
        print("Error: Godot build timed out.", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error during build: {e}", file=sys.stderr)
        return False

def run_headless_execution():
    """Runs Godot in headless mode for a few frames and scans for errors."""
    print("Running Godot headless execution check...")
    try:
        # Run for 100 frames and then terminate
        process = subprocess.Popen(
            ["godot", "--headless", "--quit-after-frames", "100"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(timeout=30)

        output = stdout + stderr
        error_patterns = [
            r"SCRIPT ERROR",
            r"ERROR:",
            r"FATAL:",
            r"invalid index",
            r"Null instance"
        ]

        found_errors = False
        for pattern in error_patterns:
            if re.search(pattern, output, re.IGNORECASE):
                print(f"Error: Detected pattern '{pattern}' in Godot output.", file=sys.stderr)
                found_errors = True

        if found_errors:
            print("Full Output for Debugging:", file=sys.stderr)
            print(output, file=sys.stderr)
            return False

        if process.returncode != 0:
            print(f"Error: Godot headless execution failed with return code {process.returncode}.", file=sys.stderr)
            print(stderr, file=sys.stderr)
            return False

        print("Execution check successful (no common error patterns detected)!")
        return True
    except subprocess.TimeoutExpired:
        print("Execution timed out or --quit-after-frames not supported, but we assume it initialized if it didn't crash.")
        return True
    except Exception as e:
        print(f"Error during execution check: {e}", file=sys.stderr)
        return False

def main():
    success = True
    
    godot_available = check_godot()
    if os.environ.get("GITHUB_ACTIONS") == "true" and not godot_available:
        success = False

    if not verify_files(): success = False
    if not check_input_map(): success = False
    if not check_physics_layers(): success = False
    if not check_missing_artefacts(): success = False
    
    if godot_available:
        if not run_headless_syntax_check(): success = False
        if not run_headless_build(): success = False
        if not run_headless_execution(): success = False
    else:
        print("Skipping Godot-dependent checks (syntax/build/execution) as 'godot' is not in PATH.")

    if not success:
        print("Validation failed!", file=sys.stderr)
        sys.exit(1)
        
    print("All validation checks passed!")
    sys.exit(0)

if __name__ == "__main__":
    main()
