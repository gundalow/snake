#!/bin/bash
set -e

# Configuration
GODOT_VERSION="4.3"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/android-sdk}"
TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
BUILD_DIR="build/android"
DEPLOY_DIR="deploy"

echo "=== Industrial Snake: Android Build Script ==="

# 1. Setup Android SDK if missing
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools" ]; then
    echo "--- Setting up Android SDK ---"
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip -d "$ANDROID_SDK_ROOT/cmdline-tools"
    mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
    rm cmdline-tools.zip

    export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
    # Use absolute path to sdkmanager to avoid confusion
    yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_SDK_ROOT" "platform-tools" "build-tools;34.0.0" "platforms;android-34"
fi

# 2. Setup Godot Templates if missing
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "--- Downloading Godot Export Templates ---"
    mkdir -p "$TEMPLATES_DIR"
    wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -O templates.tpz
    unzip -q templates.tpz
    # The .tpz usually contains a 'templates' directory
    if [ -d "templates" ]; then
        mv templates/* "$TEMPLATES_DIR/"
        rm -rf templates
    else
        # If it's flattened for some reason (unlikely but safe)
        mv *.apk "$TEMPLATES_DIR/" 2>/dev/null || true
        mv *.zip "$TEMPLATES_DIR/" 2>/dev/null || true
        mv version.txt "$TEMPLATES_DIR/" 2>/dev/null || true
    fi
    rm -f templates.tpz
fi

# 3. Configure Godot Editor Settings
echo "--- Configuring Godot Editor Settings ---"
mkdir -p "$HOME/.config/godot"
# JAVA_HOME is usually set in CI (e.g. by actions/setup-java or apt-get)
if [ -z "$JAVA_HOME" ]; then
    # Fallback to finding it via javac
    JAVA_SDK_PATH=$(dirname $(dirname $(readlink -f $(which javac))))
else
    JAVA_SDK_PATH="$JAVA_HOME"
fi

cat <<EOF > "$HOME/.config/godot/editor_settings-4.tres"
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$ANDROID_SDK_ROOT"
export/android/java_sdk_path = "$JAVA_SDK_PATH"
export/android/debug_keystore = "$(pwd)/debug.keystore"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
export/android/shutdown_adb_on_exit = true
EOF

# 4. Generate Debug Keystore if missing
if [ ! -f "debug.keystore" ]; then
    echo "--- Generating Debug Keystore ---"
    keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
fi

# 5. Build APK
echo "--- Building Android APK ---"
mkdir -p "$BUILD_DIR"
# First run ensures project is imported
godot --headless --editor --quit || true
# Export
godot --headless --export-debug "Android" "$BUILD_DIR/snake.apk"

# 6. Prepare Deployment
echo "--- Preparing Deployment Directory ---"
mkdir -p "$DEPLOY_DIR"
cp "$BUILD_DIR/snake.apk" "$DEPLOY_DIR/snake-game.apk"
cat <<EOF > "$DEPLOY_DIR/index.html"
<html>
<head>
    <title>Industrial Snake - Build</title>
    <style>body { font-family: sans-serif; background: #222; color: #eee; text-align: center; padding-top: 50px; }</style>
</head>
<body>
    <h1>Industrial Snake</h1>
    <p>Latest Android Build (2.5D Milestone 4)</p>
    <a href="snake-game.apk" style="display: inline-block; padding: 20px; background: #444; color: #0f0; text-decoration: none; border-radius: 8px; border: 2px solid #0f0;">Download APK</a>
</body>
</html>
EOF

echo "=== Build Complete: $DEPLOY_DIR/snake-game.apk ==="
