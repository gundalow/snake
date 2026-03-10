import subprocess
import os
import sys

def run_screenshot_test():
    godot_path = "/home/jules/bin/godot"
    if not os.path.exists(godot_path):
        print("Godot not found, skipping integration test.")
        return True

    print("Running screenshot integration test...")
    try:
        # We need to run with a fake display if in a headless environment that supports it,
        # or use --headless. But --headless might not render the viewport correctly for screenshots.
        # Actually, Godot 4 --headless can still capture viewports if using certain renderers,
        # but often it's better to use a virtual framebuffer.

        # Let's try --headless first as it's the simplest if it works.
        # If it doesn't, we might need xvfb-run.

        command = [
            godot_path,
            "--headless",
            "-s", "tools/screenshot_taker/screenshot_taker.gd"
        ]

        result = subprocess.run(command, capture_output=True, text=True, timeout=60)
        print(result.stdout)
        print(result.stderr)

        if os.path.exists("verification_screenshot.png"):
            print("Integration test passed: Screenshot captured.")
            return True
        else:
            print("Integration test failed: Screenshot NOT captured.")
            return False

    except Exception as e:
        print(f"Error during integration test: {e}")
        return False

if __name__ == "__main__":
    if run_screenshot_test():
        sys.exit(0)
    else:
        sys.exit(1)
