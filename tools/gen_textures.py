import numpy as np
from PIL import Image, ImageDraw, ImageFilter
import os
import random

# Optimized Noise using Numpy for faster baking
def create_tileable_noise_np(width, height, octaves=4, seed=1):
    # Very simple tileable noise substitute using numpy
    np.random.seed(seed)
    # Start with a small grid
    grid_size = octaves
    noise_grid = np.random.rand(grid_size, grid_size)
    # Tile it
    noise_grid = np.pad(noise_grid, ((0, 1), (0, 1)), mode='wrap')

    # Bilinear interpolation
    y, x = np.mgrid[0:height, 0:width]
    y_f = y * (grid_size) / height
    x_f = x * (grid_size) / width
    y0 = y_f.astype(int)
    x0 = x_f.astype(int)
    y1 = (y0 + 1)
    x1 = (x0 + 1)

    # Weights
    wy = y_f - y0
    wx = x_f - x0

    # Interpolate
    v00 = noise_grid[y0, x0]
    v10 = noise_grid[y1, x0]
    v01 = noise_grid[y0, x1]
    v11 = noise_grid[y1, x1]

    res = (1-wy)*( (1-wx)*v00 + wx*v01 ) + wy*( (1-wx)*v10 + wx*v11 )
    return res

def create_fbm_np(width, height, base_octaves=2, num_layers=4, seed=1):
    fbm_map = np.zeros((height, width))
    amplitude = 1.0
    frequency = 1.0
    for i in range(num_layers):
        layer = create_tileable_noise_np(width, height, octaves=int(base_octaves * frequency), seed=seed + i)
        fbm_map += layer * amplitude
        amplitude *= 0.5
        frequency *= 2.0

    min_v, max_v = np.min(fbm_map), np.max(fbm_map)
    return (fbm_map - min_v) / (max_v - min_v)

def add_cracks(pixels, seed=42):
    height, width, _ = pixels.shape
    random.seed(seed)
    for _ in range(8):
        x, y = random.randint(0, width-1), random.randint(0, height-1)
        for _ in range(80):
            nx, ny = (x + random.randint(-1, 1)) % width, (y + random.randint(-1, 1)) % height
            pixels[ny, nx] *= 0.2
            x, y = nx, ny

def add_pitting(pixels, noise_map, threshold=0.85):
    pitting = (noise_map > threshold).astype(float)[:, :, np.newaxis]
    pixels *= (1 - pitting * 0.5)

def add_grease_streaks(pixels, seed=99):
    h, w, _ = pixels.shape
    random.seed(seed)
    for _ in range(25):
        x = random.randint(0, w-1)
        y_start = random.randint(0, h-1)
        length = random.randint(40, 200)
        opacity = random.uniform(0.1, 0.4)
        for i in range(length):
            yy = (y_start + i) % h
            xx = (x + int(np.sin(i/8)*3)) % w
            pixels[yy, xx] *= (1 - opacity)

def gen_diamond_plate_base(width=1024, height=1024):
    img = Image.new('RGB', (width, height), (35, 35, 35))
    draw = ImageDraw.Draw(img)
    tile_size = 64
    for y in range(0, height, tile_size):
        for x in range(0, width, tile_size):
            offsets = [(tile_size//4, tile_size//4), (3*tile_size//4, 3*tile_size//4)]
            for ox, oy in offsets:
                px, py = x + ox, y + oy
                w, h = 18, 9
                # Simple diamond shadows/highlights
                draw.polygon([px, py-h-1, px+w+1, py, px, py+h+1, px-w-1, py], fill=(15, 15, 15))
                draw.polygon([px, py-h, px+w, py, px, py+h, px-w, py], fill=(55, 55, 55))
    return np.array(img).astype(float)

def main():
    os.makedirs('assets/textures', exist_ok=True)

    # FLOOR
    print("Baking floor_rusted.png...")
    pixels = gen_diamond_plate_base()
    fbm = create_fbm_np(1024, 1024, base_octaves=3, num_layers=6, seed=42)

    # Heavy Rust
    rust_color = np.array([120, 60, 25], dtype=float)
    rust_mask = np.clip((fbm - 0.5) / 0.5, 0, 1)[:, :, np.newaxis]
    pixels = pixels * (1 - rust_mask) + rust_color * rust_mask

    # Industrial Paint (Peeling Green-Grey)
    paint_color = np.array([45, 65, 60], dtype=float)
    paint_mask = ((fbm > 0.2) & (fbm < 0.4)).astype(float)[:, :, np.newaxis]
    pixels = pixels * (1 - paint_mask) + paint_color * paint_mask

    add_pitting(pixels, create_tileable_noise_np(1024, 1024, octaves=50, seed=123))
    add_grease_streaks(pixels)
    add_cracks(pixels)
    Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8)).save('assets/textures/floor_rusted.png')

    # SNAKE
    print("Baking snake_body_diffuse.png...")
    s_img = Image.new('RGB', (512, 512), (200, 120, 0))
    draw = ImageDraw.Draw(s_img)
    for i in range(-512, 1024, 60):
        draw.polygon([(i, 0), (i + 30, 0), (i + 30 + 512, 512), (i + 512, 512)], fill=(25, 25, 25))
    s_pixels = np.array(s_img).astype(float)
    s_fbm = create_fbm_np(512, 512, seed=7)
    s_pixels *= (0.5 + 0.5 * s_fbm[:, :, np.newaxis])
    add_grease_streaks(s_pixels)
    Image.fromarray(np.clip(s_pixels, 0, 255).astype(np.uint8)).save('assets/textures/snake_body_diffuse.png')

    # WALL
    print("Baking wall_beam_metal.png...")
    w_pixels = np.full((512, 512, 3), 90.0)
    w_fbm = create_fbm_np(512, 512, seed=99)
    w_pixels *= (0.7 + 0.3 * w_fbm[:, :, np.newaxis])
    # Add Rivets
    for ry in range(40, 512, 160):
        for rx in range(40, 512, 160):
            yy, xx = np.ogrid[-8:9, -8:9]
            mask = yy*yy + xx*xx < 64
            w_pixels[(ry-8):(ry+9), (rx-8):(rx+9)][mask] *= 0.4
    Image.fromarray(np.clip(w_pixels, 0, 255).astype(np.uint8)).save('assets/textures/wall_beam_metal.png')

    # LABEL
    print("Baking battery_label.png...")
    l_pixels = np.full((512, 512, 3), 190.0) # Aged paper
    l_fbm = create_fbm_np(512, 512, seed=33)
    l_pixels *= (0.8 + 0.2 * l_fbm[:, :, np.newaxis])
    l_pixels[20:80, 20:492] = [140, 30, 30] # Danger red block
    # Torn edges
    l_pixels[l_fbm < 0.15] = [20, 20, 20] # Background or missing
    add_grease_streaks(l_pixels)
    Image.fromarray(np.clip(l_pixels, 0, 255).astype(np.uint8)).save('assets/textures/battery_label.png')

    print("Success! Procedural textures baked.")

if __name__ == "__main__":
    main()
