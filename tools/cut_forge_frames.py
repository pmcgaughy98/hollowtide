"""Cut every frame out of a Forge sheet into its own transparent PNG.

Preston's workflow (2026-09-28): cut each sheet into a library of separate,
clean frames first, and only later decide how to combine them, so more motion
can be built from the pieces without re-generating.

The sheet is read 1:1 on its drawn block grid by convert_forge_sprite.py
(magenta removed, colours cleaned). Frames are then separated as groups of
pixels that sit close together, so a creature whose legs are drawn apart still
comes out as one frame. Output is ordered left to right, top to bottom.

  python tools/cut_forge_frames.py <sheet> <out_dir> [--prefix name] [--block px] [--grid COLSxROWS]

Writes <out_dir>/<prefix>_fNN.png (cropped to the frame) and
<out_dir>/<prefix>_frames.json (each frame's box on the converted sheet, so
frames can be put back in their drawn positions relative to one another).
"""
import json
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402

GAP = 3        # pixels closer than this belong to the same frame
MIN_PIXELS = 60  # smaller groups are crumbs, not frames


def grow(mask, r):
    """Every pixel within r of an opaque one (a square neighbourhood)."""
    out = mask.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            out |= np.roll(np.roll(mask, dy, 0), dx, 1)
    return out


def label(mask):
    h, w = mask.shape
    labels = np.zeros((h, w), int)
    n = 0
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not labels[y, x]:
                n += 1
                stack = [(y, x)]
                labels[y, x] = n
                while stack:
                    cy, cx = stack.pop()
                    for ny, nx in ((cy + 1, cx), (cy - 1, cx), (cy, cx + 1), (cy, cx - 1)):
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not labels[ny, nx]:
                            labels[ny, nx] = n
                            stack.append((ny, nx))
    return labels, n


def is_background(a):
    """Magenta or near it, as Opal draws the backdrop (JPEG noise included)."""
    r, g, b = a[..., 0].astype(int), a[..., 1].astype(int), a[..., 2].astype(int)
    return (r > 150) & (b > 150) & (g < 110)


def gaps(profile, min_gap):
    """Spans of the profile that hold content, split where it is empty for min_gap."""
    spans, start, empty = [], None, 0
    for i, v in enumerate(profile):
        if v:
            if start is None:
                start = i
            empty = 0
        elif start is not None:
            empty += 1
            if empty >= min_gap:
                spans.append((start, i - empty + 1))
                start, empty = None, 0
    if start is not None:
        spans.append((start, len(profile) - empty))
    return spans


def main():
    args = sys.argv[1:]
    prefix = "frame"
    block = None
    grid = None
    if "--grid" in args:
        k = args.index("--grid")
        grid = tuple(int(v) for v in args[k + 1].lower().split("x"))  # columns x rows
        del args[k:k + 2]
    if "--block" in args:
        k = args.index("--block")
        block = float(args[k + 1])
        del args[k:k + 2]
    if "--prefix" in args:
        k = args.index("--prefix")
        prefix = args[k + 1]
        del args[k:k + 2]
    sheet, out_dir = Path(args[0]), Path(args[1])
    out_dir.mkdir(parents=True, exist_ok=True)
    raw = Image.open(sheet).convert("RGB")
    a = np.asarray(raw)
    content = ~is_background(a)
    # Rows of frames first (split on horizontal magenta bands), then frames
    # within each row (split on vertical bands). Frames are converted one by one
    # so each is read on its own drawn grid.
    manifest = []
    i = 0
    if grid:
        # Frames that touch each other: cut equal cells instead of magenta gaps.
        cols, rows = grid
        cw, ch = a.shape[1] / cols, a.shape[0] / rows
        cells = [(int(r * ch), int((r + 1) * ch), int(c * cw), int((c + 1) * cw)) for r in range(rows) for c in range(cols)]
    else:
        cells = [(y0, y1, x0, x1) for y0, y1 in gaps(content.sum(axis=1) > 2, 6)
                 for x0, x1 in gaps(content[y0:y1].sum(axis=0) > 1, 6)]
    for y0, y1, x0, x1 in cells:
        if True:
            if (x1 - x0) * (y1 - y0) < 2000:
                continue  # crumbs
            pad = 0 if grid else 10
            box = (max(0, x0 - pad), max(0, y0 - pad), min(a.shape[1], x1 + pad), min(a.shape[0], y1 + pad))
            name = f"{prefix}_f{i:02d}.png"
            with tempfile.TemporaryDirectory() as tmp:
                crop_path = Path(tmp) / "crop.png"
                raw.crop(box).save(crop_path)
                convert_forge_sprite.convert(str(crop_path), str(out_dir / name), block=block)
            manifest.append({"file": name, "sheet_box": list(box)})
            i += 1
    (out_dir / f"{prefix}_frames.json").write_text(json.dumps(
        {"source": str(sheet), "frames": manifest}, indent=1))
    print(f"{prefix}: {i} frames")


if __name__ == "__main__":
    main()
