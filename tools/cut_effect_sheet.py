"""Cut every piece out of an Opal effect sheet, whether it is laid out in
grid-line cells or as free-floating pieces on magenta.

Preston's Kingstone Rail projectile sheets (2026-09-29) mix both: some have
thin dark grid lines of uneven cells (4, 3, then 2 per row), one has none.
  - Horizontal lines that cross most of the sheet split it into bands.
  - Inside each band, vertical lines that cross most of the band split cells.
  - A sheet (or band) with no lines is split into pieces by the magenta gaps
    between them, with a generous reach so a ring's separate arcs stay one piece.
Each piece is then converted on its own drawn pixel grid by
tools/convert_forge_sprite.py (magenta removed, nothing resized).

  python tools/cut_effect_sheet.py <sheet> <out_dir> --prefix name
Writes <out_dir>/<prefix>_pNN.png in reading order. Originals are never changed.
"""
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402

LINE = 0.6      # share of a row or column that must be dark to count as a grid line
REACH = 14      # sheet pixels: parts closer than this belong to one piece
MIN_AREA = 400  # sheet pixels: smaller specks are crumbs


def dark(a):
    return a.max(axis=2) < 60


def magenta(a):
    r, g, b = (a[..., i].astype(int) for i in range(3))
    return (r > 150) & (b > 150) & (g < 110)


def runs(mask_1d):
    """Start and end of each run of True."""
    out, start = [], None
    for i, v in enumerate(list(mask_1d) + [False]):
        if v and start is None:
            start = i
        elif not v and start is not None:
            out.append((start, i - 1))
            start = None
    return out


def spans_between(lines, length):
    """The gaps between line runs (the cells), skipping slivers."""
    edges = [(-1, -1)] + lines + [(length, length)]
    return [(edges[i][1] + 1, edges[i + 1][0] - 1) for i in range(len(edges) - 1)
            if edges[i + 1][0] - edges[i][1] > 40]


def free_pieces(a, x0, y0):
    """Boxes of the pieces in a region with no grid lines."""
    ink = ~magenta(a) & ~dark(a) | (dark(a) & ~magenta(a))
    ink &= ~magenta(a)
    grown = ink.copy()
    for dy in range(-REACH, REACH + 1, 2):
        for dx in range(-REACH, REACH + 1, 2):
            grown |= np.roll(np.roll(ink, dy, 0), dx, 1)
    seen = np.zeros_like(grown)
    boxes = []
    h, w = grown.shape
    for sy, sx in zip(*np.where(grown)):
        if seen[sy, sx]:
            continue
        stack, ys, xs = [(sy, sx)], [], []
        seen[sy, sx] = True
        while stack:
            y, x = stack.pop()
            ys.append(y)
            xs.append(x)
            for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if 0 <= ny < h and 0 <= nx < w and grown[ny, nx] and not seen[ny, nx]:
                    seen[ny, nx] = True
                    stack.append((ny, nx))
        if len(ys) >= MIN_AREA:
            boxes.append((x0 + min(xs), y0 + min(ys), x0 + max(xs) + 1, y0 + max(ys) + 1))
    return boxes


def cells(img):
    a = np.asarray(img.convert("RGB"))
    h, w, _ = a.shape
    d = dark(a)
    rows = runs(d.mean(axis=1) > LINE)
    boxes = []
    for (y0, y1) in spans_between(rows, h) if rows else [(0, h - 1)]:
        band = d[y0:y1 + 1]
        cols = runs(band.mean(axis=0) > LINE)
        if not rows and not cols:
            return free_pieces(a, 0, 0)
        for (x0, x1) in spans_between(cols, w) if cols else [(0, w - 1)]:
            boxes.append((x0 + 3, y0 + 3, x1 - 2, y1 - 2))
    return boxes


def main():
    sheet, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    prefix = sys.argv[sys.argv.index("--prefix") + 1] if "--prefix" in sys.argv else sheet.stem
    out_dir.mkdir(parents=True, exist_ok=True)
    img = Image.open(sheet).convert("RGB")
    tmp = Path(tempfile.mkdtemp())
    n = 0
    for box in cells(img):
        crop = img.crop(box)
        a = np.asarray(crop)
        if (~magenta(a)).sum() < MIN_AREA:
            continue  # an empty cell
        path = tmp / f"c{n}.png"
        crop.save(path)
        convert_forge_sprite.convert(str(path), str(out_dir / f"{prefix}_p{n:02d}.png"))
        n += 1
    print(f"{prefix}: {n} pieces")


if __name__ == "__main__":
    main()
