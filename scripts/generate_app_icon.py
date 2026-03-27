#!/usr/bin/env python3
"""Generate the Fishydex app icon (1024x1024) — Pokédex-inspired with fish silhouette."""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

SIZE = 1024
BORDER = 40
CORNER_RADIUS = 180

# Colors
RED_TOP = (220, 10, 45)       # #DC0A2D
RED_BOTTOM = (160, 0, 32)     # #A00020
DARK_BORDER = (120, 0, 20)
BLUE_LENS = (59, 130, 246)    # #3B82F6
BLUE_DARK = (30, 80, 180)
WHITE = (255, 255, 255)
WHITE_SEMI = (255, 255, 255, 180)


def lerp_color(c1, c2, t):
    """Linear interpolate between two RGB colors."""
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_rounded_rect(draw, bbox, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = bbox
    draw.rounded_rectangle(bbox, radius=radius, fill=fill)


def make_gradient(size, c1, c2):
    """Create a diagonal gradient image."""
    img = Image.new("RGB", (size, size))
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            img.putpixel((x, y), lerp_color(c1, c2, t))
    return img


def draw_fish(draw, cx, cy, scale=1.0):
    """Draw a stylized fish silhouette using polygons."""
    # Fish body — an elongated ellipse-like shape built from points
    body_points = []
    # Top arc of body
    for angle in range(0, 181, 5):
        rad = math.radians(angle)
        x = cx + math.cos(rad) * 180 * scale
        y = cy - math.sin(rad) * 95 * scale
        body_points.append((x, y))
    # Bottom arc of body
    for angle in range(180, 361, 5):
        rad = math.radians(angle)
        x = cx + math.cos(rad) * 180 * scale
        y = cy - math.sin(rad) * 95 * scale
        body_points.append((x, y))

    draw.polygon(body_points, fill=WHITE)

    # Tail fin — a triangular shape on the left side
    tail_x = cx - 180 * scale
    tail_points = [
        (tail_x, cy),
        (tail_x - 90 * scale, cy - 70 * scale),
        (tail_x - 90 * scale, cy + 70 * scale),
    ]
    draw.polygon(tail_points, fill=WHITE)

    # Fill the gap between body and tail
    gap_points = [
        (tail_x - 10 * scale, cy - 50 * scale),
        (tail_x + 20 * scale, cy - 60 * scale),
        (tail_x + 20 * scale, cy + 60 * scale),
        (tail_x - 10 * scale, cy + 50 * scale),
    ]
    draw.polygon(gap_points, fill=WHITE)

    # Dorsal fin (top)
    dorsal_points = [
        (cx + 20 * scale, cy - 90 * scale),
        (cx - 30 * scale, cy - 155 * scale),
        (cx - 80 * scale, cy - 90 * scale),
    ]
    draw.polygon(dorsal_points, fill=WHITE)

    # Ventral fin (bottom, smaller)
    ventral_points = [
        (cx + 10 * scale, cy + 85 * scale),
        (cx - 20 * scale, cy + 130 * scale),
        (cx - 60 * scale, cy + 85 * scale),
    ]
    draw.polygon(ventral_points, fill=WHITE)

    # Pectoral fin (side, small)
    pec_points = [
        (cx + 40 * scale, cy + 20 * scale),
        (cx + 80 * scale, cy + 75 * scale),
        (cx + 20 * scale, cy + 60 * scale),
    ]
    draw.polygon(pec_points, fill=WHITE)

    # Eye — dark circle on the fish
    eye_cx = cx + 110 * scale
    eye_cy = cy - 15 * scale
    eye_r = 22 * scale
    draw.ellipse(
        [eye_cx - eye_r, eye_cy - eye_r, eye_cx + eye_r, eye_cy + eye_r],
        fill=RED_TOP,
    )
    # Eye pupil
    pupil_r = 12 * scale
    draw.ellipse(
        [eye_cx - pupil_r, eye_cy - pupil_r, eye_cx + pupil_r, eye_cy + pupil_r],
        fill=DARK_BORDER,
    )
    # Eye highlight
    hl_r = 6 * scale
    hl_cx = eye_cx - 5 * scale
    hl_cy = eye_cy - 6 * scale
    draw.ellipse(
        [hl_cx - hl_r, hl_cy - hl_r, hl_cx + hl_r, hl_cy + hl_r],
        fill=WHITE,
    )


def draw_lens(draw, cx, cy, radius):
    """Draw the Pokédex-style scanner lens."""
    # Outer ring (darker blue)
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=BLUE_DARK,
    )
    # Inner lens
    inner_r = radius * 0.82
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=BLUE_LENS,
    )
    # Highlight reflection
    hl_r = radius * 0.25
    hl_cx = cx - radius * 0.25
    hl_cy = cy - radius * 0.25
    draw.ellipse(
        [hl_cx - hl_r, hl_cy - hl_r, hl_cx + hl_r, hl_cy + hl_r],
        fill=(140, 200, 255),
    )
    # Small bright dot
    dot_r = radius * 0.1
    dot_cx = cx - radius * 0.3
    dot_cy = cy - radius * 0.35
    draw.ellipse(
        [dot_cx - dot_r, dot_cy - dot_r, dot_cx + dot_r, dot_cy + dot_r],
        fill=WHITE,
    )


def main():
    # 1. Create gradient background
    print("Generating gradient background...")
    img = make_gradient(SIZE, RED_TOP, RED_BOTTOM)
    draw = ImageDraw.Draw(img)

    # 2. Draw darker border/frame
    # We draw the border by drawing the dark rounded rect first, then the inner area
    # Create a mask for rounded corners
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=CORNER_RADIUS, fill=255)

    # Dark border frame
    frame = Image.new("RGB", (SIZE, SIZE), DARK_BORDER)
    frame_draw = ImageDraw.Draw(frame)

    # Inner gradient area (inset by border width)
    inner_gradient = make_gradient(SIZE, RED_TOP, RED_BOTTOM)
    inner_mask = Image.new("L", (SIZE, SIZE), 0)
    inner_mask_draw = ImageDraw.Draw(inner_mask)
    inner_mask_draw.rounded_rectangle(
        [BORDER, BORDER, SIZE - BORDER - 1, SIZE - BORDER - 1],
        radius=CORNER_RADIUS - 20,
        fill=255,
    )

    # Composite: frame with inner gradient
    img = Image.composite(inner_gradient, frame, inner_mask)

    # Apply rounded corner mask
    bg = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    img = Image.composite(img, bg, mask)

    # Add alpha channel with rounded corners
    img = img.convert("RGBA")
    alpha = mask.copy()
    img.putalpha(alpha)

    draw = ImageDraw.Draw(img)

    # 3. Add subtle inner shine/highlight along top edge
    for i in range(20):
        opacity = int(40 * (1 - i / 20))
        y = BORDER + 10 + i
        draw.line(
            [(BORDER + CORNER_RADIUS, y), (SIZE - BORDER - CORNER_RADIUS, y)],
            fill=(255, 255, 255, opacity),
        )

    # 4. Draw the fish silhouette (centered, slightly above middle)
    fish_cy = SIZE // 2 - 50
    fish_cx = SIZE // 2 + 10
    print("Drawing fish silhouette...")
    draw_fish(draw, fish_cx, fish_cy, scale=1.15)

    # 5. Draw the scanner lens below the fish
    lens_cy = SIZE // 2 + 200
    lens_cx = SIZE // 2
    print("Drawing scanner lens...")
    draw_lens(draw, lens_cx, lens_cy, radius=55)

    # 6. Add subtle shadow under the fish for depth
    # (drawn as a semi-transparent ellipse)
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.ellipse(
        [SIZE // 2 - 160, fish_cy + 100, SIZE // 2 + 160, fish_cy + 130],
        fill=(0, 0, 0, 30),
    )
    img = Image.alpha_composite(img, shadow)

    # 7. Save
    output_dir = "/Users/rylanddupre/Fishydex/Fishydex/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, "AppIcon.png")
    img.save(output_path, "PNG")
    print(f"Icon saved to {output_path}")
    print(f"Size: {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main()
