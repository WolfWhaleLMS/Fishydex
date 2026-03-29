#!/usr/bin/env python3
"""Generate the Fishface app icon (1024x1024) — lime green with blue cartoon fish + sunglasses."""

from PIL import Image, ImageDraw
import math
import os

SIZE = 1024
CORNER_RADIUS = 220

# Colors
LIME_TOP = (120, 230, 50)       # bright lime green
LIME_BOTTOM = (60, 180, 30)     # darker lime
BLUE_BODY = (50, 120, 230)      # bright blue fish body
BLUE_DARK = (30, 80, 180)       # darker blue for shading
BLUE_BELLY = (100, 170, 255)    # lighter blue belly
WHITE = (255, 255, 255)
BLACK = (20, 20, 20)
SUNGLASS = (30, 30, 35)         # near-black sunglasses
SUNGLASS_FRAME = (50, 50, 55)
SUNGLASS_SHINE = (100, 100, 110)
ORANGE_FIN = (255, 160, 40)     # fun accent color for fins
YELLOW_HIGHLIGHT = (200, 255, 80)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def make_gradient(size, c1, c2):
    img = Image.new("RGB", (size, size))
    for y in range(size):
        for x in range(size):
            t = (x * 0.3 + y * 0.7) / size
            img.putpixel((x, y), lerp_color(c1, c2, t))
    return img


def draw_fish(draw, cx, cy, s=1.0):
    """Draw a large cartoon fish facing right with sunglasses."""

    # === TAIL FIN (drawn first, behind body) ===
    tail_x = cx - 195 * s
    tail_pts = [
        (tail_x + 10 * s, cy),
        (tail_x - 110 * s, cy - 100 * s),
        (tail_x - 60 * s, cy - 30 * s),
        (tail_x - 75 * s, cy),
        (tail_x - 60 * s, cy + 30 * s),
        (tail_x - 110 * s, cy + 100 * s),
    ]
    draw.polygon(tail_pts, fill=ORANGE_FIN)

    # === BODY (oval) ===
    body_pts = []
    for angle in range(360):
        rad = math.radians(angle)
        x = cx + math.cos(rad) * 210 * s
        y = cy - math.sin(rad) * 130 * s
        body_pts.append((x, y))
    draw.polygon(body_pts, fill=BLUE_BODY)

    # Belly highlight (lighter blue lower half)
    belly_pts = []
    for angle in range(180, 361):
        rad = math.radians(angle)
        x = cx + math.cos(rad) * 195 * s
        y = cy - math.sin(rad) * 110 * s + 15 * s
        belly_pts.append((x, y))
    draw.polygon(belly_pts, fill=BLUE_BELLY)

    # === DORSAL FIN (top) ===
    dorsal = [
        (cx + 40 * s, cy - 125 * s),
        (cx - 10 * s, cy - 210 * s),
        (cx - 60 * s, cy - 195 * s),
        (cx - 100 * s, cy - 125 * s),
    ]
    draw.polygon(dorsal, fill=ORANGE_FIN)

    # === PECTORAL FIN (side) ===
    pec = [
        (cx + 20 * s, cy + 30 * s),
        (cx + 70 * s, cy + 110 * s),
        (cx - 10 * s, cy + 95 * s),
    ]
    draw.polygon(pec, fill=BLUE_DARK)

    # === VENTRAL FIN (bottom) ===
    ventral = [
        (cx - 30 * s, cy + 120 * s),
        (cx - 55 * s, cy + 175 * s),
        (cx - 100 * s, cy + 120 * s),
    ]
    draw.polygon(ventral, fill=ORANGE_FIN)

    # === MOUTH (smile) ===
    mouth_cx = cx + 180 * s
    mouth_cy = cy + 25 * s
    # Draw a curved smile using arc
    draw.arc(
        [mouth_cx - 55 * s, mouth_cy - 25 * s, mouth_cx + 20 * s, mouth_cy + 35 * s],
        start=10, end=160, fill=BLACK, width=int(5 * s)
    )

    # === SUNGLASSES ===
    # Left lens (on fish's right eye - facing us)
    gl_cx = cx + 85 * s
    gl_cy = cy - 20 * s
    gl_w = 68 * s
    gl_h = 52 * s
    # Frame
    draw.rounded_rectangle(
        [gl_cx - gl_w, gl_cy - gl_h, gl_cx + gl_w, gl_cy + gl_h],
        radius=int(20 * s), fill=SUNGLASS_FRAME
    )
    # Lens
    draw.rounded_rectangle(
        [gl_cx - gl_w + 5 * s, gl_cy - gl_h + 5 * s, gl_cx + gl_w - 5 * s, gl_cy + gl_h - 5 * s],
        radius=int(16 * s), fill=SUNGLASS
    )
    # Shine on lens
    draw.rounded_rectangle(
        [gl_cx - gl_w + 12 * s, gl_cy - gl_h + 10 * s, gl_cx - 10 * s, gl_cy - gl_h + 28 * s],
        radius=int(8 * s), fill=SUNGLASS_SHINE
    )

    # Right lens (fish's left eye — further back)
    gr_cx = cx - 10 * s
    gr_cy = cy - 20 * s
    gr_w = 55 * s
    gr_h = 45 * s
    draw.rounded_rectangle(
        [gr_cx - gr_w, gr_cy - gr_h, gr_cx + gr_w, gr_cy + gr_h],
        radius=int(18 * s), fill=SUNGLASS_FRAME
    )
    draw.rounded_rectangle(
        [gr_cx - gr_w + 5 * s, gr_cy - gr_h + 5 * s, gr_cx + gr_w - 5 * s, gr_cy + gr_h - 5 * s],
        radius=int(14 * s), fill=SUNGLASS
    )
    draw.rounded_rectangle(
        [gr_cx - gr_w + 10 * s, gr_cy - gr_h + 8 * s, gr_cx - 5 * s, gr_cy - gr_h + 24 * s],
        radius=int(7 * s), fill=SUNGLASS_SHINE
    )

    # Bridge between lenses
    bridge_x0 = min(gr_cx + gr_w - 5 * s, gl_cx - gl_w + 5 * s)
    bridge_x1 = max(gr_cx + gr_w - 5 * s, gl_cx - gl_w + 5 * s)
    draw.rounded_rectangle(
        [bridge_x0, gl_cy - 8 * s, bridge_x1, gl_cy + 8 * s],
        radius=int(6 * s), fill=SUNGLASS_FRAME
    )

    # Temple arm (goes back toward tail)
    draw.rounded_rectangle(
        [gr_cx - gr_w - 60 * s, gr_cy - 6 * s, gr_cx - gr_w, gr_cy + 6 * s],
        radius=int(4 * s), fill=SUNGLASS_FRAME
    )

    # === BODY HIGHLIGHT (top) ===
    for i in range(15):
        opacity = int(60 * (1 - i / 15))
        y = cy - 120 * s + i * 2
        x_extent = 180 * s * math.sqrt(max(0, 1 - ((y - cy) / (130 * s)) ** 2))
        if x_extent > 20:
            draw.line(
                [(cx - x_extent + 40, y), (cx + x_extent - 40, y)],
                fill=(*YELLOW_HIGHLIGHT, opacity), width=2
            )


def main():
    # 1. Lime green gradient background
    print("Generating lime green gradient...")
    img = make_gradient(SIZE, LIME_TOP, LIME_BOTTOM)

    # Apply rounded corner mask
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=CORNER_RADIUS, fill=255)

    img = img.convert("RGBA")
    alpha = mask.copy()
    img.putalpha(alpha)

    draw = ImageDraw.Draw(img)

    # 2. Subtle radial glow in center
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    for r in range(300, 0, -2):
        opacity = int(25 * (r / 300))
        glow_draw.ellipse(
            [SIZE // 2 - r, SIZE // 2 - r, SIZE // 2 + r, SIZE // 2 + r],
            fill=(255, 255, 255, opacity)
        )
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    # 3. Draw the big cartoon fish (centered)
    print("Drawing cartoon fish with sunglasses...")
    draw_fish(draw, SIZE // 2 + 30, SIZE // 2 + 10, s=1.3)

    # 4. Save
    output_dir = "/Users/rylanddupre/Fishydex/Fishface/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, "AppIcon.png")
    img.save(output_path, "PNG")
    print(f"Icon saved to {output_path}")
    print(f"Size: {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main()
