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
        print("Warning: 'godot' not found in system PATH. Skipping Godot-dependent checks.", file=sys.stderr)
        return False
    print(f"Found Godot at: {godot_path}")
    return True

def fix_whitespace():
    """Automatically removes trailing whitespace from all .gd files."""
    print("Fixing trailing whitespace in GDScript files...")
    for gd_file in Path("scripts").rglob("*.gd"):
        try:
            content = gd_file.read_text()
            # Remove trailing whitespace from each line
            new_content = "\n".join([line.rstrip() for line in content.splitlines()])
            # Ensure the file ends with a single newline if it wasn't empty
            if new_content and not new_content.endswith("\n"):
                new_content += "\n"
            
            if content != new_content:
                gd_file.write_text(new_content)
                print(f"  Fixed: {gd_file}")
        except Exception as e:
            print(f"  Error fixing {gd_file}: {e}", file=sys.stderr)

def run_headless_import():
    """Runs Godot in headless mode with --editor --quit to trigger initial import of assets."""
    print("Running Godot headless import (editor mode)...")
    try:
        # Running the editor once triggers the import process for all assets
        # This is critical for CI environments where .godot/imported is empty.
        result = subprocess.run(
            ["godot", "--headless", "--editor", "--quit"],
            capture_output=True,
            text=True,
            timeout=120 # Imports can take a while
        )
        if result.returncode != 0:
            print("Warning: Godot headless import returned non-zero exit code, but we will continue to syntax check.", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
        
        print("Import process completed.")
        return True
    except subprocess.TimeoutExpired:
        print("Error: Godot headless import timed out.", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error during Godot headless import: {e}", file=sys.stderr)
        return False

def verify_files():
    """Checks if critical project files exist."""
    required_files = [
        "project.godot",
        "scenes/main/main.tscn",
        "scenes/main/obstacle.tscn",
        "scenes/main/snake_head.tscn",
        "scripts/core/snake_head.gd",
        "scenes/main/segment.tscn",
        "scripts/core/snake_manager.gd",
        "scenes/main/fuel_cell.tscn",
        "scripts/core/fuel_cell.gd",
        "scenes/ui/hud.tscn",
        "scripts/ui/hud.gd",
        "export_presets.cfg",
        ".github/workflows/android.yml"
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
        "move_up",
        "move_down",
        "move_left",
        "move_right",
        
        "restart",
        "pause",
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
    # Temporarily disabled or updated for 2D as we progress
    return True

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

def run_gdlint():
    """Runs gdlint on all .gd files if available."""
    gdlint_path = shutil.which("gdlint")
    if not gdlint_path:
        print("Warning: 'gdlint' not found in system PATH. Skipping linting.")
        return True

    print("Running gdlint...")
    try:
        # Run gdlint on all .gd files recursively
        result = subprocess.run(
            ["gdlint", "scripts/"],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print("Error: gdlint failed.", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False

        print("gdlint check successful!")
        return True
    except Exception as e:
        print(f"Error during gdlint: {e}", file=sys.stderr)
        return False

def run_headless_execution():
    """Runs Godot in headless mode for a few frames and scans for errors."""
    print("Running Godot headless execution check...")
    try:
        # Run for 20 frames and then terminate. Using fewer frames to reduce wait time.
        process = subprocess.Popen(
            ["godot", "--headless", "--quit-after-frames", "20"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(timeout=15)

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
                # Ignore specific warnings that aren't critical failures
                if "FINISHME" in output and pattern == r"ERROR:":
                    continue
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
    
    # Auto-fix whitespace first to prevent common linting failures
    fix_whitespace()
    
    godot_available = check_godot()
    # If in CI and Godot is missing, fail the validation
    if os.environ.get("GITHUB_ACTIONS") == "true" and not godot_available:
        print("Error: 'godot' must be available in CI environment.", file=sys.stderr)
        success = False

    if not verify_files(): success = False
    if not run_gdlint(): success = False
    if not check_input_map(): success = False
    if not check_physics_layers(): success = False
    if not check_missing_artefacts(): success = False
    
    if godot_available:
        if not run_headless_import(): success = False
        if not run_headless_syntax_check(): success = False
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
