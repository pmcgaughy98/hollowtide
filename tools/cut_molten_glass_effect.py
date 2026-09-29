"""Cut Vitrecrag's Molten Glass effect pieces out of Preston's Forge sheet.

Source (kept in OneDrive, never edited):
  Effect Sheets/Vitecrag Effect/Molten Glass Animation/Molten Glass(Effect) Sheet.jfif
It is a 2-wide by 4-tall sheet of eight frames on magenta, drawn on a 5-pixel block grid.

convert_forge_sprite.py reads the grid 1:1 and removes the magenta. This script then
separates the blobs and keeps the ones the attack uses:
  eruption.png     frame 0's big bulging glob (bursts out of the collar)
  lob_a/b/c.png    teardrop globs in flight from frames 3-4 (the volley), tail on the left
  splash.png       frame 6's splash (each lob landing on the target)
  crust.png        frame 7's cooled crust with glowing cracks (lingers on the target)
Frames 1-2 are skipped: their rope is cut off by a hard maroon block at the cell edge.

Run from the project root: python tools/cut_molten_glass_effect.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path.home() / "OneDrive/Documents/HollowTide Sprites/Effect Sheets/Vitecrag Effect/Molten Glass Animation/Molten Glass(Effect) Sheet.jfif"
OUT = ROOT / "assets/sprites/effects/vitrecrag/forge_molten_glass"
MIN_BLOCKS = 12  # smaller blobs are spatter, kept only as part of the crust


def components(alpha):
    """Label 8-connected opaque regions. Returns a label grid and the count."""
    h, w = alpha.shape
    labels = np.zeros((h, w), int)
    n = 0
    for y in range(h):
        for x in range(w):
            if alpha[y, x] and not labels[y, x]:
                n += 1
                stack = [(y, x)]
                labels[y, x] = n
                while stack:
                    cy, cx = stack.pop()
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < h and 0 <= nx < w and alpha[ny, nx] and not labels[ny, nx]:
                                labels[ny, nx] = n
                                stack.append((ny, nx))
    return labels, n


def crop(img, mask):
    ys, xs = np.where(mask)
    piece = np.zeros_like(img)
    piece[mask] = img[mask]
    return piece[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    native = OUT / "sheet_native.png"
    convert_forge_sprite.convert(str(SOURCE), str(native))
    img = np.asarray(Image.open(native).convert("RGBA"))
    alpha = img[..., 3] > 0
    labels, n = components(alpha)
    ys, xs = np.where(alpha)
    top, bottom, left, right = ys.min(), ys.max(), xs.min(), xs.max()
    cell_w, cell_h = (right - left + 1) / 2, (bottom - top + 1) / 4

    blobs = []  # (frame, size, label, centre)
    for k in range(1, n + 1):
        m = labels == k
        size = int(m.sum())
        cy, cx = [float(v.mean()) for v in np.where(m)]
        frame = int((cy - top) // cell_h) * 2 + int((cx - left) // cell_w)
        blobs.append((frame, size, k, (cx, cy)))

    def largest(frame, count=1):
        found = sorted((b for b in blobs if b[0] == frame and b[1] >= MIN_BLOCKS), key=lambda b: -b[1])
        return found[:count]

    pieces = {}
    pieces["eruption"] = crop(img, labels == largest(0)[0][2])
    flight = sorted(largest(3, 3) + largest(4, 3), key=lambda b: -b[1])
    for name, blob in zip(("lob_a", "lob_b", "lob_c"), flight[:3]):
        pieces[name] = crop(img, labels == blob[2])
    pieces["splash"] = crop(img, labels == largest(6)[0][2])
    pieces["crust"] = crop(img, np.isin(labels, [b[2] for b in blobs if b[0] == 7]))

    # Ropes: frames 1 and 2 whole, minus the hard maroon stub where Opal's cell
    # edge cut the rope off. The stub is the dark block at the rope's source
    # corner; dropping those blocks leaves the rope starting cleanly, and the
    # battle anchors that start at the mouth.
    for name, frame, stub in (("rope_1", 1, (0, 6, 16, 32)), ("rope_2", 2, (0, 5, 16, 32))):
        mask = np.isin(labels, [b[2] for b in blobs if b[0] == frame])
        ys_f, xs_f = np.where(mask)
        fx0, fy0 = xs_f.min(), ys_f.min()
        x0, x1, y0, y1 = stub
        stub_mask = np.zeros_like(mask)
        stub_mask[fy0 + y0:fy0 + y1, fx0 + x0:fx0 + x1] = True
        dark = (img[..., 0] < 150) & (img[..., 1] < 60)
        mask &= ~(stub_mask & dark)
        pieces[name] = crop(img, mask)
    # Beads: the small outlined droplets between globs, for particle textures.
    beads = sorted((b for b in blobs if b[0] in (3, 4, 5, 6) and 4 <= b[1] < MIN_BLOCKS), key=lambda b: -b[1])
    for name, blob in zip(("bead_a", "bead_b", "bead_c"), beads[:3]):
        pieces[name] = crop(img, labels == blob[2])

    for name, arr in pieces.items():
        Image.fromarray(arr, "RGBA").save(OUT / f"{name}.png")
        print(f"{name}: {arr.shape[1]} x {arr.shape[0]} blocks")

    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 4
        tiles = [Image.fromarray(a, "RGBA").resize((a.shape[1] * Z, a.shape[0] * Z), Image.NEAREST) for a in pieces.values()]
        sheet = Image.new("RGBA", (sum(t.width + 12 for t in tiles), max(t.height for t in tiles)), (40, 60, 70, 255))
        x = 0
        for t in tiles:
            sheet.alpha_composite(t, (x, 0))
            x += t.width + 12
        sheet.save(dest)


if __name__ == "__main__":
    main()
