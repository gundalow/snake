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
    yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" "platform-tools" "build-tools;34.0.0" "build-tools;33.0.2" "platforms;android-34" "platforms;android-33"
fi

# 2. Setup Godot Templates if missing
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "--- Downloading Godot Export Templates ---"
    mkdir -p "$TEMPLATES_DIR"
    wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -O templates.tpz
    unzip -q templates.tpz
    mv templates/* "$TEMPLATES_DIR/"
    rm -rf templates templates.tpz
fi

# 3. Configure Godot Editor Settings
echo "--- Configuring Godot Editor Settings ---"
mkdir -p "$HOME/.config/godot"
JAVA_SDK_PATH=$(dirname $(dirname $(readlink -f $(which javac))))

cat <<EOF > "$HOME/.config/godot/editor_settings-4.tres"
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$ANDROID_SDK_ROOT"
export/android/java_sdk_path = "$JAVA_SDK_PATH"
export/android/debug_keystore = "$(pwd)/debug.keystore"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
EOF

# 4. Generate Debug Keystore if missing
if [ ! -f "debug.keystore" ]; then
    echo "--- Generating Debug Keystore ---"
    keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
fi

# 5. Build APK
echo "--- Building Android APK ---"
mkdir -p "$BUILD_DIR"
echo "Current Directory: $(pwd)"
echo "HOME: $HOME"
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "JAVA_SDK_PATH: $JAVA_SDK_PATH"
echo "Godot Version:"
godot --version || echo "Godot not found in path"

echo "--- Exporting ---"
godot --headless --editor --quit --verbose || echo "Editor quit with error (might be okay)"
godot --headless --export-debug "Android" "$BUILD_DIR/snake.apk" --verbose

# 6. Prepare Deployment
echo "--- Preparing Deployment Directory ---"
mkdir -p "$DEPLOY_DIR"
cp "$BUILD_DIR/snake.apk" "$DEPLOY_DIR/snake-game.apk"
cat <<EOF > "$DEPLOY_DIR/index.html"
<html>
<head><title>Industrial Snake - Build</title></head>
<body>
    <h1>Industrial Snake</h1>
    <p>Latest Android Build</p>
    <a href="snake-game.apk">Download APK</a>
</body>
</html>
EOF

echo "=== Build Complete: $DEPLOY_DIR/snake-game.apk ==="
