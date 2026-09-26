"""Turn a Hollowtide Sprite Forge image into a transparent game sprite, 1:1.

Usage:
    python tools/convert_forge_sprite.py <input image> <output .png> [--compare <sheet.png>]

The Forge draws pixel art on a 100 by 100 block grid, enlarged to 1024x1024, on
a flat magenta background. This reads that grid back one pixel per block, so the
sprite is the Forge's art exactly, minus the magenta. Nothing is resized.

An earlier version shrank everything to 64x64. That cannot work: a creature
drawn 88 blocks wide has 88 pixels of detail, and squeezing it into 64 destroys
some of it no matter how the squeeze is done. So the output is 100x100.

--compare writes a side-by-side image, original on the left and the sprite on
the right at the same size, so the result can be judged against the source
instead of against itself.
"""
import sys
from collections import Counter

import numpy as np
from PIL import Image

FLOOR_GAP = 3  # empty rows under the feet


def grid_period(signal):
    """Block size along one axis, from where colour edges repeat."""
    best = (0.0, 10.24)
    idx = np.arange(1, len(signal) + 1)
    # 8 to 16px per block covers a 64 to 128 block grid. Searching wider finds
    # false matches: at 6px the JPEG noise alone scores higher than the real grid.
    for period in np.arange(8.0, 16.001, 0.005):
        bins = np.floor(np.mod(idx, period) / period * 40).astype(int)
        energy = np.bincount(bins, weights=signal, minlength=40)
        score = energy.max() / energy.mean()
        if score > best[0]:
            best = (score, period)
    return best


def is_magenta(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    return (r > 170) & (b > 170) & (g < 110) & (np.abs(r - b) < 70)


def convert(src, dst, compare=None):
    a = np.asarray(Image.open(src).convert("RGB")).astype(int)
    h, w, _ = a.shape

    col_strength, px = grid_period(np.abs(np.diff(a, axis=1)).sum(axis=(0, 2)))
    row_strength, py = grid_period(np.abs(np.diff(a, axis=0)).sum(axis=(1, 2)))
    nx, ny = round(w / px), round(h / py)
    xs = np.linspace(0, w, nx + 1)
    ys = np.linspace(0, h, ny + 1)

    bg = is_magenta(a)
    cells = np.zeros((ny, nx, 4), np.uint8)
    for j in range(ny):
        for i in range(nx):
            # Inner 60% of the block, clear of the JPEG smear at its edges.
            y0, y1, x0, x1 = ys[j], ys[j + 1], xs[i], xs[i + 1]
            my, mx = (y1 - y0) * 0.2, (x1 - x0) * 0.2
            sl = (slice(int(round(y0 + my)), max(int(round(y0 + my)) + 1, int(round(y1 - my)))),
                  slice(int(round(x0 + mx)), max(int(round(x0 + mx)) + 1, int(round(x1 - mx)))))
            fg = ~bg[sl]
            if fg.mean() < 0.5:
                continue
            cells[j, i, :3] = np.median(a[sl][fg], axis=0)
            cells[j, i, 3] = 255

    opaque = cells[..., 3] == 255
    if not opaque.any():
        raise SystemExit("No creature found: is the background magenta?")

    # JPEG blends magenta into the outline, leaving pink blocks on the rim.
    # Only rim blocks are checked, so a creature's own pinks and purples survive.
    c = cells[..., :3].astype(int)
    pink = (c[..., 0] > 140) & (c[..., 2] > 120) & (c[..., 1] < c[..., 0] - 60) & (c[..., 1] < c[..., 2] - 40)
    padded = np.pad(opaque, 1)
    interior = padded[:-2, 1:-1] & padded[2:, 1:-1] & padded[1:-1, :-2] & padded[1:-1, 2:]
    cells[opaque & ~interior & pink, 3] = 0
    opaque = cells[..., 3] == 255

    # JPEG makes one real colour into many near-copies. Snap each block to the
    # nearest colour that appears in at least two blocks, which keeps small
    # features like eyes while merging the noise.
    rounded = (cells[..., :3].astype(int) // 8) * 8 + 4
    counts = Counter(map(tuple, rounded[opaque]))
    palette = np.array([col for col, n in counts.most_common(48) if n >= 2] or
                       [col for col, _ in counts.most_common(8)])
    flat = cells[..., :3].reshape(-1, 3).astype(int)
    nearest = palette[np.argmin(((flat[:, None, :] - palette[None]) ** 2).sum(-1), axis=1)]
    cells[..., :3] = nearest.reshape(cells.shape[:2] + (3,)).astype(np.uint8)
    cells[~opaque] = 0

    # Same canvas size as the grid. Centre left to right, stand on a common floor,
    # so every creature lines up the same way in battle. Moving it loses nothing.
    rows = np.where(opaque.any(axis=1))[0]
    cols = np.where(opaque.any(axis=0))[0]
    crop = cells[rows[0]:rows[-1] + 1, cols[0]:cols[-1] + 1]
    ch, cw = crop.shape[:2]
    canvas = np.zeros((ny, nx, 4), np.uint8)
    top = max(0, ny - FLOOR_GAP - ch)
    left = (nx - cw) // 2
    canvas[top:top + ch, left:left + cw] = crop
    Image.fromarray(canvas, "RGBA").save(dst)

    # Fidelity: enlarge the sprite back onto the original grid and measure how far
    # its colours sit from the original, over the creature only.
    back = np.zeros_like(a)
    for j in range(ny):
        for i in range(nx):
            back[int(ys[j]):int(ys[j + 1]), int(xs[i]):int(xs[i + 1])] = cells[j, i, :3]
    creature = ~bg
    err = np.abs(back - a)[creature].mean()
    colours = len({tuple(p) for p in cells[..., :3][opaque]})

    print(src)
    print(f"  grid {nx} x {ny} blocks ({px:.3f}px each, edge strength {col_strength:.1f}/{row_strength:.1f})")
    print(f"  creature {cw} x {ch} blocks, {colours} colours, nothing resized")
    print(f"  average colour difference from the original: {err:.1f} of 255")
    print(f"  -> {dst}")

    if compare:
        dark = np.array([40, 40, 48])
        orig = a.copy()
        orig[bg] = dark
        left_img = Image.fromarray(orig.astype(np.uint8)).resize((nx * 5, ny * 5), Image.LANCZOS)
        spr = Image.fromarray(canvas, "RGBA").resize((nx * 5, ny * 5), Image.NEAREST)
        right_img = Image.new("RGB", spr.size, tuple(dark))
        right_img.paste(spr, (0, 0), spr)
        sheet = Image.new("RGB", (nx * 10 + 20, ny * 5), tuple(dark))
        sheet.paste(left_img, (0, 0))
        sheet.paste(right_img, (nx * 5 + 20, 0))
        sheet.save(compare)


if __name__ == "__main__":
    args = sys.argv[1:]
    cmp = None
    if "--compare" in args:
        k = args.index("--compare")
        cmp = args[k + 1]
        del args[k:k + 2]
    if len(args) != 2:
        raise SystemExit(__doc__)
    convert(args[0], args[1], cmp)
