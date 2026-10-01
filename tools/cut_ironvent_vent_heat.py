"""Cut Preston's nine Ironvent vent-fire drawings into registered Godot frames.

The Opal output is an irregular nine-pose layout, not an eight-cell atlas. Keep
the source file untouched and align every flame at the right-hand vent root.
"""

from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path

from PIL import Image


REGIONS = [
    ("00_charge", (95, 65, 275, 225)),
    ("01_ignite", (330, 30, 535, 230)),
    ("02_first_burst", (710, 10, 1020, 250)),
    ("03_open", (110, 255, 515, 515)),
    ("04_full", (530, 250, 1015, 520)),
    ("05_sustain", (20, 510, 515, 790)),
    ("06_turbulence", (545, 520, 1015, 790)),
    ("07_breakup", (70, 790, 515, 1015)),
    ("08_cool", (680, 790, 1010, 1015)),
]

CANVAS = (56, 48)
ROOT = (54, 32)
SCALE = 0.1


def is_magenta(rgb: tuple[int, int, int]) -> bool:
    red, green, blue = rgb
    return red >= 70 and blue >= 70 and red > green * 1.6 and blue > green * 1.6 and blue > red * 0.55


def snap_to_palette(rgb: tuple[int, int, int], palette: list[tuple[int, int, int]]) -> tuple[int, int, int]:
    return min(
        palette,
        key=lambda p: (rgb[0] - p[0]) ** 2 * 0.7
        + (rgb[1] - p[1]) ** 2
        + (rgb[2] - p[2]) ** 2 * 0.6,
    )


def cut_one(source: Image.Image, region: tuple[int, int, int, int], palette: list[tuple[int, int, int]]) -> Image.Image:
    crop = source.crop(region).convert("RGB")
    pixels = list(crop.getdata())
    mask = Image.new("L", crop.size)
    mask.putdata([0 if is_magenta(rgb) else 255 for rgb in pixels])
    bounds = mask.getbbox()
    if bounds is None:
        raise ValueError(f"No visible pixels in {region}")
    crop = crop.crop(bounds)
    mask = mask.crop(bounds)

    # The emitted material has its source at the pointed right edge. Position
    # that edge on the same vent-root pixel in all nine frames.
    root_band = max(1, crop.width // 12)
    near_root = [
        y
        for y in range(crop.height)
        for x in range(crop.width - root_band, crop.width)
        if mask.getpixel((x, y)) and crop.getpixel((x, y))[1] > 85
    ]
    root_y = sorted(near_root)[len(near_root) // 2] if near_root else crop.height // 2

    size = (max(1, round(crop.width * SCALE)), max(1, round(crop.height * SCALE)))
    scaled = Image.merge("RGBA", (*crop.split(), mask)).resize(size, Image.Resampling.NEAREST)
    output = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    x0 = ROOT[0] - size[0] + 1
    y0 = ROOT[1] - round(root_y * SCALE)
    if x0 < 0 or y0 < 0 or x0 + size[0] > CANVAS[0] or y0 + size[1] > CANVAS[1]:
        raise ValueError(f"Frame from {region} does not fit registered canvas: {(x0, y0, size)}")
    output.alpha_composite(scaled, (x0, y0))

    # Snap JPEG shades and any surviving edge pixels to Ironvent's established
    # opaque fire ramp. Alpha stays binary, so no pink halo can remain.
    fixed = []
    for red, green, blue, alpha in output.getdata():
        if alpha == 0:
            fixed.append((0, 0, 0, 0))
        else:
            fixed.append((*snap_to_palette((red, green, blue), palette), 255))
    output.putdata(fixed)
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("out_dir", type=Path)
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGB")
    if source.size != (1024, 1024):
        raise ValueError(f"Expected Preston's 1024x1024 Opal sheet, got {source.size}")
    fan = Image.open(Path(__file__).resolve().parents[1] / "assets/sprites/effects/ironvent/blowdown/fan.png").convert("RGBA")
    common = Counter(rgb[:3] for rgb in fan.getdata() if rgb[3])
    palette = [rgb for rgb, _ in common.most_common(28)]

    args.out_dir.mkdir(parents=True, exist_ok=True)
    for name, region in REGIONS:
        frame = cut_one(source, region, palette)
        frame.save(args.out_dir / f"{name}.png")
        print(name, frame.getbbox(), len(set(frame.getdata())))


if __name__ == "__main__":
    main()
