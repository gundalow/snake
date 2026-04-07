import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from perlin_noise import PerlinNoise
import os

def create_noise_map(width, height, octaves=4, seed=1):
    noise = PerlinNoise(octaves=octaves, seed=seed)
    noise_map = np.zeros((height, width))
    for y in range(height):
        for x in range(width):
            # To make it seamless, we map x, y to a circle in 3D or 4D space
            # Or use a simpler seamless tiling approach if the library supports it
            # Simple tiling for Perlin noise:
            val = noise([x/width, y/height])
            noise_map[y, x] = val

    # Normalize to 0-1
    min_val = np.min(noise_map)
    max_val = np.max(noise_map)
    noise_map = (noise_map - min_val) / (max_val - min_val)
    return noise_map

def create_tileable_noise(width, height, octaves=4, seed=1):
    # For a truly seamless 2D texture, we can sample the noise in 4D
    # or just blend the edges. Let's try a 4D approach if possible,
    # but the perlin-noise lib is simple.
    # Another way: noise(x, y) = n(x, y)*(1-x)*x*(1-y)*y ... no.

    noise = PerlinNoise(octaves=octaves, seed=seed)
    noise_map = np.zeros((height, width))

    for y in range(height):
        for x in range(width):
            # Seamless tiling trick: sample on a torus in 4D space
            u = x / width
            v = y / height
            # Angle for the circle
            pi2 = 2 * np.pi
            dx = np.cos(u * pi2) / pi2
            dy = np.sin(u * pi2) / pi2
            dz = np.cos(v * pi2) / pi2
            dw = np.sin(v * pi2) / pi2

            # Note: perlin-noise 1.14 supports list of coordinates
            val = noise([dx, dy, dz, dw])
            noise_map[y, x] = val

    # Normalize to 0-1
    min_val = np.min(noise_map)
    max_val = np.max(noise_map)
    noise_map = (noise_map - min_val) / (max_val - min_val)
    return noise_map

def gen_diamond_plate(width=1024, height=1024):
    base_color = (34, 34, 34) # #222222
    img = Image.new('RGB', (width, height), base_color)
    draw = ImageDraw.Draw(img)

    # Diamond pattern
    # Draw small diamonds in a grid
    tile_size = 64
    for y in range(0, height, tile_size):
        for x in range(0, width, tile_size):
            # Two diamonds per tile
            offsets = [(tile_size//4, tile_size//4), (3*tile_size//4, 3*tile_size//4)]
            for ox, oy in offsets:
                # Draw a diamond shape
                px = x + ox
                py = y + oy
                w, h = 20, 10
                # Highlight and shadow for 3D effect
                # Shadow
                draw.polygon([px, py-h-1, px+w+1, py, px, py+h+1, px-w-1, py], fill=(10, 10, 10))
                # Highlight
                draw.polygon([px, py-h+1, px+w-1, py, px, py+h-1, px-w+1, py], fill=(60, 60, 60))
                # Face
                draw.polygon([px, py-h, px+w, py, px, py+h, px-w, py], fill=(45, 45, 45))

    return img

def gen_hazard_stripes(width=512, height=512):
    # Orange #FF8C00 and Black
    img = Image.new('RGB', (width, height), (255, 140, 0))
    draw = ImageDraw.Draw(img)

    stripe_width = 40
    for i in range(-width, width + height, stripe_width * 2):
        draw.polygon([
            (i, 0),
            (i + stripe_width, 0),
            (i + stripe_width + height, height),
            (i + height, height)
        ], fill=(0, 0, 0))

    return img

def gen_scratched_metal(width=512, height=512):
    img = Image.new('RGB', (width, height), (100, 100, 100))
    draw = ImageDraw.Draw(img)

    import random
    for _ in range(200):
        x1 = random.randint(0, width)
        y1 = random.randint(0, height)
        length = random.randint(10, 50)
        angle = random.uniform(0, 3.14)
        x2 = x1 + length * np.cos(angle)
        y2 = y1 + length * np.sin(angle)

        opacity = random.randint(20, 50)
        draw.line((x1, y1, x2, y2), fill=(150, 150, 150), width=1)

    return img

def gen_technical_label(width=512, height=512):
    img = Image.new('RGB', (width, height), (200, 200, 200))
    draw = ImageDraw.Draw(img)

    # Border
    draw.rectangle([10, 10, width-10, height-10], outline=(0, 0, 0), width=5)

    # Header
    draw.rectangle([10, 10, width-10, 100], fill=(255, 0, 0))
    # Text placeholder
    draw.text((width//2 - 50, 40), "WARNING", fill=(255, 255, 255))

    # Content
    for i in range(120, height-20, 30):
        draw.rectangle([30, i, width-30, i+10], fill=(50, 50, 50))

    return img

def main():
    os.makedirs('assets/textures', exist_ok=True)

    print("Generating floor_rusted.png...")
    floor = gen_diamond_plate()
    noise_map = create_tileable_noise(1024, 1024, octaves=6, seed=42)
    # Re-implementing apply_grime with numpy for speed and correctness
    pixels = np.array(floor).astype(float)
    rust_color = np.array([139, 69, 19], dtype=float)

    # Rust overlay
    rust_mask = np.clip((noise_map - 0.7) / 0.3, 0, 1)
    # Expand dims for broadcasting
    rust_mask = rust_mask[:, :, np.newaxis]
    pixels = pixels * (1 - rust_mask) + rust_color * rust_mask

    # Oil overlay
    oil_mask = np.clip((0.2 - noise_map) / 0.2, 0, 1) * 0.5
    oil_mask = oil_mask[:, :, np.newaxis]
    pixels = pixels * (1 - oil_mask)

    Image.fromarray(pixels.astype(np.uint8)).save('assets/textures/floor_rusted.png')

    print("Generating snake_body_diffuse.png...")
    snake = gen_hazard_stripes()
    # Add some grime
    noise_map_snake = create_tileable_noise(512, 512, octaves=4, seed=123)
    pixels_snake = np.array(snake).astype(float)
    grime_mask = (1 - noise_map_snake[:, :, np.newaxis] * 0.3)
    pixels_snake *= grime_mask
    Image.fromarray(pixels_snake.astype(np.uint8)).save('assets/textures/snake_body_diffuse.png')

    print("Generating wall_beam_metal.png...")
    wall = gen_scratched_metal()
    Image.fromarray(np.array(wall)).save('assets/textures/wall_beam_metal.png')

    print("Generating battery_label.png...")
    label = gen_technical_label()
    Image.fromarray(np.array(label)).save('assets/textures/battery_label.png')

    print("All textures generated successfully.")

if __name__ == "__main__":
    main()
