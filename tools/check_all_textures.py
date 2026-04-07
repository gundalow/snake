import os
from PIL import Image

def check_seamless(filepath):
    img = Image.open(filepath)
    w, h = img.size

    # Create a 2x2 tiling
    tiled = Image.new(img.mode, (w * 2, h * 2))
    tiled.paste(img, (0, 0))
    tiled.paste(img, (w, 0))
    tiled.paste(img, (0, h))
    tiled.paste(img, (w, h))

    # Save a thumbnail/crop of the center where all 4 meet
    center_crop = tiled.crop((w // 2, h // 2, w + w // 2, h + h // 2))

    output_dir = "verification/seamless_checks"
    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.basename(filepath)
    center_crop.save(os.path.join(output_dir, f"check_{filename}"))
    print(f"Saved check for {filename}")

def main():
    texture_dir = "html/assets/textures"
    if not os.path.exists(texture_dir):
        print(f"Directory {texture_dir} not found")
        return

    for f in os.listdir(texture_dir):
        if f.endswith(".png"):
            check_seamless(os.path.join(texture_dir, f))

if __name__ == "__main__":
    main()
