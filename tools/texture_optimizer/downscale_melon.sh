#!/bin/bash

# Define the target directory for the melon textures
TEXTURE_DIR="assets/models/food/mega_melon/textures"

# Check if the directory exists
if [ ! -d "$TEXTURE_DIR" ]; then
    echo "Error: Texture directory $TEXTURE_DIR not found!"
    exit 1
fi

echo "Optimizing Mega Melon textures..."

# Define the textures to resize
TEXTURES=(
    "Melon_baseColor.jpeg"
    "Melon_metallicRoughness.png"
    "Melon_normal.png"
)

for texture in "${TEXTURES[@]}"; do
    input_path="$TEXTURE_DIR/$texture"
    output_name="${texture%.*}_1k.${texture##*.}"
    output_path="$TEXTURE_DIR/$output_name"

    if [ -f "$input_path" ]; then
        echo "Resizing $texture to 1k..."
        magick "$input_path" -resize 1024x1024 "$output_path"
        echo "Created $output_name"
    else
        echo "Warning: $input_path not found!"
    fi
done

echo "Optimization complete!"
