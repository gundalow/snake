import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from perlin_noise import PerlinNoise
import os
import random

def create_fbm_noise(width, height, octaves=4, seed=1):
    """Generates FBM noise using the perlin-noise library."""
    noise = PerlinNoise(octaves=octaves, seed=seed)
    # Generate noise at lower resolution and upscale for speed if needed,
    # but for 2048x2048 we might want full res or sampled.
    # To keep it fast, we'll sample a grid.
    res_x, res_y = 128, 128
    noise_grid = [[noise([i/res_x, j/res_y]) for j in range(res_y)] for i in range(res_x)]

    img = Image.fromarray(((np.array(noise_grid) + 0.5) * 255).astype(np.uint8))
    img = img.resize((width, height), resample=Image.Resampling.BICUBIC)
    return np.array(img).astype(float) / 255.0

def height_to_normal(height_map, strength=10.0):
    h, w = height_map.shape
    dy, dx = np.gradient(height_map)
    dx = dx * strength
    dy = dy * strength
    nx = -dx
    ny = -dy
    nz = np.ones_like(height_map)
    norm = np.sqrt(nx**2 + ny**2 + nz**2)
    nx /= norm
    ny /= norm
    nz /= norm
    res = np.zeros((h, w, 3), dtype=np.uint8)
    res[..., 0] = ((nx + 1.0) * 127.5).astype(np.uint8)
    res[..., 1] = ((ny + 1.0) * 127.5).astype(np.uint8)
    res[..., 2] = ((nz + 1.0) * 127.5).astype(np.uint8)
    return res

def gen_steel_planks(width=2048, height=2048):
    img = Image.new('RGB', (width, height), (40, 40, 40))
    h_map = np.full((height, width), 0.5)
    draw = ImageDraw.Draw(img)

    plank_width = 128
    for x in range(0, width, plank_width):
        # Base color variation for each plank
        base_v = random.randint(35, 55)
        draw.rectangle([x, 0, x + plank_width, height], fill=(base_v, base_v, base_v))

        # Plank highlights/shadows (vertical edges)
        draw.line([x, 0, x, height], fill=(20, 20, 20), width=2) # Shadow
        draw.line([x+1, 0, x+1, height], fill=(60, 60, 60), width=1) # Highlight

        # Recess the gap in height map
        h_map[:, x:x+2] = 0.3

        # Random horizontal seams to make them "planks" instead of long strips
        y_cursor = 0
        while y_cursor < height:
            plank_len = random.randint(400, 800)
            y_end = min(y_cursor + plank_len, height)

            # Draw seam
            draw.line([x, y_end, x + plank_width, y_end], fill=(20, 20, 20), width=2)
            h_map[y_end-1:y_end+1, x:x+plank_width] = 0.3

            # Add rivets near seams
            for rx in [x + 20, x + plank_width - 20]:
                for ry in [y_cursor + 20, y_end - 20]:
                    if ry < height and ry > 0:
                        # Draw rivet
                        draw.ellipse([rx-4, ry-4, rx+4, ry+4], fill=(70, 70, 70), outline=(20, 20, 20))
                        # Height for rivet
                        yy, xx = np.ogrid[-5:6, -5:6]
                        mask = yy*yy + xx*xx < 25
                        y_idx, x_idx = int(ry), int(rx)
                        h_map[max(0, y_idx-5):min(height, y_idx+6), max(0, x_idx-5):min(width, x_idx+6)][mask[:min(11, height-y_idx+5), :min(11, width-x_idx+5)]] = 0.8

            y_cursor = y_end

    return np.array(img).astype(float), h_map

def add_damage(pixels, h_map, width, height):
    draw_p = Image.fromarray(pixels.astype(np.uint8))
    draw = ImageDraw.Draw(draw_p)

    # Scratches
    for _ in range(100):
        x1, y1 = random.randint(0, width), random.randint(0, height)
        length = random.randint(20, 100)
        angle = random.uniform(0, np.pi * 2)
        x2, y2 = x1 + np.cos(angle) * length, y1 + np.sin(angle) * length
        draw.line([x1, y1, x2, y2], fill=(100, 100, 100, 128), width=1)
        # Recess height slightly
        # (For simplicity we won't update h_map for every scratch, but could)

    # Dents / Impact marks
    for _ in range(30):
        rx, ry = random.randint(0, width), random.randint(0, height)
        size = random.randint(5, 15)
        draw.ellipse([rx-size, ry-size, rx+size, ry+size], fill=(20, 20, 20))
        # Update height map
        yy, xx = np.ogrid[-size:size+1, -size:size+1]
        mask = yy*yy + xx*xx < size*size
        y_start, y_end = max(0, ry-size), min(height, ry+size+1)
        x_start, x_end = max(0, rx-size), min(width, rx+size+1)
        h_map[y_start:y_end, x_start:x_end][mask[:(y_end-y_start), :(x_end-x_start)]] = 0.2

    return np.array(draw_p).astype(float), h_map

def main():
    base_path = 'html/assets/textures'
    os.makedirs(base_path, exist_ok=True)
    random.seed(42)

    # --- FLOOR (2048x2048 Unique) ---
    print("Baking 2048x2048 Industrial Floor...")
    W, H = 2048, 2048
    pixels, h_map = gen_steel_planks(W, H)
    pixels, h_map = add_damage(pixels, h_map, W, H)

    # Large-scale color variation
    large_noise = create_fbm_noise(W, H, octaves=2, seed=999)
    pixels *= (0.9 + 0.2 * large_noise[:, :, np.newaxis])

    # Rust and Oil Noise - using multiple octaves for variety
    rust_noise = create_fbm_noise(W, H, octaves=8, seed=123)
    oil_noise = create_fbm_noise(W, H, octaves=5, seed=456)

    # Rust Layer - more varied and "patchy"
    rust_mask = np.clip((rust_noise - 0.55) / 0.45, 0, 1)
    # Varied rust colors
    rust_color_1 = np.array([139, 69, 19], dtype=float) # Dark Rust
    rust_color_2 = np.array([160, 82, 45], dtype=float) # Light Rust
    rust_color_mix = rust_color_1 * (1 - rust_noise[:,:,np.newaxis]) + rust_color_2 * rust_noise[:,:,np.newaxis]

    pixels = pixels * (1 - rust_mask[:,:,np.newaxis]) + rust_color_mix * rust_mask[:,:,np.newaxis]
    h_map += rust_mask * 0.15 # Rust has some volume

    # Oil Layer - darker, more viscous looking
    oil_mask = np.clip((oil_noise - 0.65) / 0.35, 0, 1)
    pixels = pixels * (1 - oil_mask[:,:,np.newaxis]) * 0.3 # Deep darkening for oil

    # Roughness
    roughness = np.full((H, W), 0.4) # Base metal
    roughness = roughness * (1 - rust_mask) + 0.9 * rust_mask # Rust is rough
    roughness = roughness * (1 - oil_mask) + 0.05 * oil_mask # Oil is VERY smooth/glossy

    Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8)).save(os.path.join(base_path, 'floor_rusted.png'))
    Image.fromarray(height_to_normal(h_map, strength=15.0)).save(os.path.join(base_path, 'floor_normal.png'))
    Image.fromarray((roughness * 255).astype(np.uint8)).save(os.path.join(base_path, 'floor_roughness.png'))

    # --- SNAKE (512x512) ---
    print("Baking Snake Body...")
    SW, SH = 512, 512
    s_pixels = np.full((SH, SW, 3), [220, 100, 0], dtype=float) # Bright Orange
    s_h = np.full((SH, SW), 0.5)
    s_draw_img = Image.fromarray(s_pixels.astype(np.uint8))
    s_draw = ImageDraw.Draw(s_draw_img)
    # Hazard Stripes
    for i in range(-512, 1024, 80):
        poly = [(i, 0), (i + 40, 0), (i + 40 + 512, 512), (i + 512, 512)]
        s_draw.polygon(poly, fill=(20, 20, 20))
        # Recess stripes
        stripe_mask = Image.new('L', (SW, SH), 0)
        ImageDraw.Draw(stripe_mask).polygon(poly, fill=255)
        s_h[np.array(stripe_mask) > 0] = 0.4

    s_noise = create_fbm_noise(SW, SH, octaves=8, seed=99)
    s_pixels = np.array(s_draw_img).astype(float)
    s_pixels *= (0.8 + 0.2 * s_noise[:, :, np.newaxis]) # Grime
    s_rough = 0.3 + 0.4 * s_noise # Variable roughness

    Image.fromarray(np.clip(s_pixels, 0, 255).astype(np.uint8)).save(os.path.join(base_path, 'snake_body_diffuse.png'))
    Image.fromarray(height_to_normal(s_h, strength=8.0)).save(os.path.join(base_path, 'snake_body_normal.png'))
    Image.fromarray((s_rough * 255).astype(np.uint8)).save(os.path.join(base_path, 'snake_body_roughness.png'))

    # --- BEAM (512x512) ---
    print("Baking Metal Beams...")
    BW, BH = 512, 512
    b_pixels = np.full((BH, BW, 3), [80, 80, 85], dtype=float)
    b_h = np.full((BH, BW), 0.5)
    b_noise = create_fbm_noise(BW, BH, octaves=5, seed=777)
    b_pixels *= (0.7 + 0.3 * b_noise[:, :, np.newaxis])
    # Add some scratches to beams
    b_draw_img = Image.fromarray(b_pixels.astype(np.uint8))
    b_draw = ImageDraw.Draw(b_draw_img)
    for _ in range(40):
        x1, y1 = random.randint(0, BW), random.randint(0, BH)
        x2, y2 = x1 + random.randint(-50, 50), y1 + random.randint(-50, 50)
        b_draw.line([x1, y1, x2, y2], fill=(120, 120, 125), width=1)

    # Rivets
    for ry in [64, 256, 448]:
        for rx in [64, 256, 448]:
            b_draw.ellipse([rx-15, ry-15, rx+15, ry+15], fill=(60, 60, 60), outline=(30, 30, 30))
            yy, xx = np.ogrid[-16:17, -16:17]
            mask = yy*yy + xx*xx < 256
            b_h[ry-16:ry+17, rx-16:rx+17][mask] = 0.8

    Image.fromarray(np.array(b_draw_img)).save(os.path.join(base_path, 'wall_beam_metal.png'))
    Image.fromarray(height_to_normal(b_h)).save(os.path.join(base_path, 'wall_beam_normal.png'))
    Image.fromarray(np.full((BH, BW), 180, dtype=np.uint8)).save(os.path.join(base_path, 'wall_beam_roughness.png'))

    # --- BATTERY (256x256) ---
    print("Baking Battery Label...")
    # Keep it simple but clean
    l_img = Image.new('RGB', (256, 256), (220, 220, 220))
    l_draw = ImageDraw.Draw(l_img)
    l_draw.rectangle([0, 0, 256, 256], outline=(150, 0, 0), width=8)
    l_draw.rectangle([10, 10, 246, 50], fill=(150, 0, 0))
    # technical text blobs
    for i in range(60, 240, 25):
        l_draw.rectangle([20, i, 236, i+8], fill=(40, 40, 40))
    l_draw.polygon([128, 70, 110, 130, 128, 130, 115, 190, 150, 110, 130, 110, 145, 70], fill=(255, 215, 0))
    l_img.save(os.path.join(base_path, 'battery_label.png'))

    print("All textures baked successfully!")

if __name__ == "__main__":
    main()
