"""Convert a four-frame 2x2 Opal idle sheet to transparent Godot PNGs.

Usage:
    python tools/convert_idle_sheet.py SOURCE_CREATURE.png OPAL_SHEET.jpg OUTPUT_DIR

SOURCE_CREATURE is the approved transparent sprite already imported for Godot.
It determines the native frame size and palette. Frames keep their exact canvas
coordinates; none are cropped, centered, scaled independently, or flipped.
Review the four outputs before using them in battle.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

FRAME_NAMES = ("neutral", "inhale_start", "inhale_peak", "exhale")
FRAME_SECONDS = (0.55, 0.25, 0.45, 0.25)


def _frame_cells(frame: Image.Image, width: int, height: int) -> tuple[np.ndarray, np.ndarray]:
    """Sample the middle of each logical pixel to avoid JPEG edge bleed."""
    rgb = np.asarray(frame.convert("RGB"), dtype=np.float32)
    alpha = np.asarray(frame.getchannel("A"), dtype=np.float32) if "A" in frame.getbands() else None
    fh, fw = rgb.shape[:2]
    cells = np.empty((height, width, 3), dtype=np.float32)
    opacity = np.full((height, width), 255.0, dtype=np.float32)
    for y in range(height):
        y0, y1 = fh * y / height, fh * (y + 1) / height
        for x in range(width):
            x0, x1 = fw * x / width, fw * (x + 1) / width
            ya = min(fh - 1, int(y0 + (y1 - y0) * 0.25))
            yb = max(ya + 1, min(fh, int(y0 + (y1 - y0) * 0.75 + 0.5)))
            xa = min(fw - 1, int(x0 + (x1 - x0) * 0.25))
            xb = max(xa + 1, min(fw, int(x0 + (x1 - x0) * 0.75 + 0.5)))
            cells[y, x] = np.median(rgb[ya:yb, xa:xb], axis=(0, 1))
            if alpha is not None:
                opacity[y, x] = np.median(alpha[ya:yb, xa:xb])
    return cells, opacity


def convert(source_path: Path, sheet_path: Path, output_dir: Path) -> None:
    source = Image.open(source_path).convert("RGBA")
    width, height = source.size
    if width < 16 or height < 16 or width > 256 or height > 256:
        raise ValueError("Source must be a native-grid transparent creature PNG (16 to 256 pixels per side).")
    source_pixels = np.asarray(source)
    source_mask = source_pixels[:, :, 3] >= 128
    if not source_mask.any() or source_mask.all():
        raise ValueError("Source PNG must contain both creature pixels and transparency.")
    palette = np.unique(source_pixels[source_mask, :3], axis=0).astype(np.float32)
    if len(palette) > 256:
        raise ValueError("Source has too many colors for a native pixel sprite; use the approved converted PNG.")

    sheet = Image.open(sheet_path)
    sw, sh = sheet.size
    if sw != sh or sw % 2 or sh % 2:
        raise ValueError("Opal sheet must be square with a 2x2 layout and even dimensions.")
    if sw // 2 < width or sh // 2 < height:
        raise ValueError("Each Opal frame is smaller than the source sprite's native grid.")

    output_dir.mkdir(parents=True, exist_ok=True)
    frames = []
    for index, (name, row, col) in enumerate((
        ("neutral", 0, 0), ("inhale_start", 0, 1),
        ("inhale_peak", 1, 0), ("exhale", 1, 1),
    )):
        tile = sheet.crop((col * sw // 2, row * sh // 2,
                           (col + 1) * sw // 2, (row + 1) * sh // 2))
        # Opal sometimes paints a black divider across the sheet centre.
        # Trim only the divider-facing edges before sampling each frame.
        inner_trim = max(1, round(sw * 0.008))
        edge_pixels = np.asarray(tile.convert("RGB"))
        left_trim = inner_trim if col and np.median(edge_pixels[:, :inner_trim]) < 70 else 0
        top_trim = inner_trim if row and np.median(edge_pixels[:inner_trim, :]) < 70 else 0
        right_trim = inner_trim if not col and np.median(edge_pixels[:, -inner_trim:]) < 70 else 0
        bottom_trim = inner_trim if not row and np.median(edge_pixels[-inner_trim:, :]) < 70 else 0
        tile = tile.crop((left_trim, top_trim, tile.width - right_trim, tile.height - bottom_trim))
        cells, input_alpha = _frame_cells(tile, width, height)
        border = np.concatenate((cells[0], cells[-1], cells[:, 0], cells[:, -1]))
        background = np.median(border, axis=0)
        if not (background[0] > 120 and background[2] > 120 and background[1] < 150):
            raise ValueError(f"Frame {index} border is not magenta; inspect the Opal sheet layout.")
        bg_dist = np.sqrt(((cells - background) ** 2).sum(axis=2))
        nearest_index = np.argmin(((cells[:, :, None, :] - palette[None, None, :, :]) ** 2).sum(axis=3), axis=2)
        nearest = palette[nearest_index]
        palette_dist = np.sqrt(((cells - nearest) ** 2).sum(axis=2))
        is_background = (input_alpha < 128) | (bg_dist < 60) | (bg_dist < palette_dist * 0.82)
        pixels = np.zeros((height, width, 4), dtype=np.uint8)
        pixels[~is_background, :3] = nearest[~is_background].astype(np.uint8)
        pixels[~is_background, 3] = 255
        if not np.any(pixels[:, :, 3]):
            raise ValueError(f"Frame {index} contains no creature pixels.")
        file_name = f"idle_{index}_{name}.png"
        Image.fromarray(pixels, "RGBA").save(output_dir / file_name)
        frames.append({"file": file_name, "seconds": FRAME_SECONDS[index]})

    output = Image.new("RGBA", (width * 2, height * 2))
    for i, frame in enumerate(frames):
        output.paste(Image.open(output_dir / frame["file"]), ((i % 2) * width, (i // 2) * height))
    output.save(output_dir / "idle_sheet.png")
    manifest = {
        "source": str(source_path),
        "opal_sheet": str(sheet_path),
        "frame_size": [width, height],
        "layout": "2x2 row-major",
        "loop_seconds": sum(FRAME_SECONDS),
        "frames": frames,
    }
    (output_dir / "idle_animation.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Converted 4 frames at {width}x{height} without resizing or repositioning.")
    print(f"Review {output_dir / 'idle_sheet.png'} before importing it into Godot.")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    convert(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]))
