#!/usr/bin/env python3
import subprocess
import sys
import os
import shutil

def run_command(command, cwd=None):
    try:
        result = subprocess.run(command, capture_output=True, text=True, cwd=cwd, shell=isinstance(command, str))
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return 1, "", str(e)

def print_stage(name):
    print(f"\n=== Stage: {name} ===")

def check_tool(tool_name):
    path = shutil.which(tool_name)
    if path:
        print(f"[OK] Found {tool_name} at {path}")
        return True
    else:
        print(f"[FAIL] {tool_name} not found in PATH")
        return False

def main():
    print("Starting Incremental Dependency Check...")

    # Stage 1: Tool existence
    print_stage("Basic Tool Existence")
    essential_tools = ["go", "gcc", "g++", "python3"]
    all_tools_ok = True
    for tool in essential_tools:
        if not check_tool(tool):
            all_tools_ok = False

    # Godot is special as it might be named godot or godot4
    godot_cmd = None
    for gcmd in ["godot", "godot4"]:
        if shutil.which(gcmd):
            godot_cmd = gcmd
            print(f"[OK] Found Godot as '{gcmd}'")
            break

    if not godot_cmd:
        print("[WARN] Godot not found in PATH. You may need to install it or add it to PATH.")

    if not all_tools_ok:
        print("\nEssential tools missing. Please install them.")
        # We continue as much as possible anyway

    # Stage 2: Version checks
    print_stage("Version Checks")
    if shutil.which("go"):
        rc, out, err = run_command(["go", "version"])
        if rc == 0:
            print(f"[INFO] Go Version: {out}")
            # Memory says Go 1.25+ is required (though current environment has 1.24)
            # Let's just report and maybe warn if it's too old
        else:
            print(f"[FAIL] Failed to get Go version: {err}")

    if godot_cmd:
        rc, out, err = run_command([godot_cmd, "--version"])
        if rc == 0:
            print(f"[INFO] Godot Version: {out}")
        else:
            print(f"[FAIL] Failed to get Godot version: {err}")

    # Stage 3: Go Runtime Test
    print_stage("Go Runtime Test")
    go_test_dir = os.path.join(os.path.dirname(__file__), "go_test")
    rc, out, err = run_command(["go", "run", "main.go"], cwd=go_test_dir)
    if rc == 0:
        print(f"[OK] Go run successful: {out}")
    else:
        print(f"[FAIL] Go run failed: {err}")

    # Stage 4: CGO and Shared Library build test
    print_stage("CGO and Shared Library Build Test")
    # This is crucial for GDExtension
    so_name = "libtest.so"
    if os.path.exists(os.path.join(go_test_dir, so_name)):
        os.remove(os.path.join(go_test_dir, so_name))

    rc, out, err = run_command(["go", "build", "-buildmode=c-shared", "-o", so_name, "main.go"], cwd=go_test_dir)
    if rc == 0:
        if os.path.exists(os.path.join(go_test_dir, so_name)):
            print(f"[OK] Shared library build successful: {so_name} created.")
        else:
            print(f"[FAIL] Build claimed success but {so_name} not found.")
    else:
        print(f"[FAIL] Shared library build failed. Is CGO enabled and GCC/G++ working?")
        print(f"Error: {err}")

    print("\nDependency check complete.")

if __name__ == "__main__":
    main()
