"""Cut Preston's Molten Cannon and Molten Beam Opal sheets into single frames.

Preston (2026-09-28): Molten Cannon is built from its four sheets by the
attack-sheet protocol, and Molten Beam is dropped, so its four sheets are cut
too as spare poses for the cannon. The sheets use different layouts (some have
black cell borders, some three creatures to a row), so each sheet's cells are
listed here by hand instead of detected, and each cell is converted at its own
block size so the creature comes out at the approved in-game height (93 px).

Originals stay untouched in OneDrive. Writes
assets/sprites/creatures/attacks/vitrecrag_molten_cannon/frames/<sheet>_fNN.png,
numbered in reading order.

Run from the project root: python tools/cut_vitrecrag_cannon_sheets.py
"""
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SRC = Path.home() / "OneDrive/Documents/HollowTide Sprites/Effect Sheets/Vitecrag Effect"
OUT = ROOT / "assets/sprites/creatures/attacks/vitrecrag_molten_cannon/frames"
BODY_HEIGHT = 93   # the approved front's visible height
INSET = 10         # keeps black cell borders out of a cell


def grid(cols, rows, top=0, bottom=1024):
    h = (bottom - top) / rows
    return [(c * 1024 / cols, top + r * h, (c + 1) * 1024 / cols, top + (r + 1) * h)
            for r in range(rows) for c in range(cols)]


SHEETS = {
    "cannon1": ("Molten Cannon Animation/Molten Cannon animation sheet 1.jfif",
                [(0, 0, 340, 340), (340, 0, 682, 340), (682, 0, 1024, 340),
                 (0, 340, 340, 682), (340, 340, 1024, 682),
                 (0, 682, 512, 1024), (512, 682, 1024, 1024)]),
    "cannon2": ("Molten Cannon Animation/Molten Cannon Animation Sheet 2.jfif", grid(3, 2, 0, 682)),
    "cannon3": ("Molten Cannon Animation/Molten Cannon Animation Sheet 3.jfif", grid(2, 3)),
    "cannon4": ("Molten Cannon Animation/Molten Cannon Animatinon 4.jfif", grid(3, 2, 0, 682)),
    "beam1": ("Molten Beam Attack Animation/Molten Beam attack animation sheet 1.jfif", grid(3, 3)),
    "beam2": ("Molten Beam Attack Animation/Molten Beam attack animation 2.jfif", grid(1, 3)),
    "beam3": ("Molten Beam Attack Animation/Molten Beam attack aniamtion sheet 3.jfif", grid(2, 3)),
    "beam4": ("Molten Beam Attack Animation/Molten Beam Attack animation 4.jfif",
              grid(3, 1, 0, 315) + [(0, 315, 340, 665), (340, 315, 1024, 665)]),
}


def body_height(cell):
    """Height in sheet pixels of the creature in a cell: the rows where the
    foreground is at least a fifth as wide as its widest row, so a thin smoke
    curl or flame above the shell does not count."""
    fg = ~convert_forge_sprite.background(np.asarray(cell.convert("RGB")).astype(int))
    fg &= np.asarray(cell.convert("L")) > 30   # black borders are not creature
    widths = fg.sum(axis=1)
    rows = np.where(widths >= widths.max() * 0.2)[0]
    return rows.max() - rows.min() + 1 if len(rows) else 0


def opaque_height(img):
    """The same body measure on a converted frame: rows at least a fifth as full
    as its fullest row, so smoke or a flame tip does not count."""
    widths = (np.asarray(img)[..., 3] > 0).sum(axis=1)
    rows = np.where(widths >= widths.max() * 0.2)[0]
    return rows.max() - rows.min() + 1 if len(rows) else 0


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # The approved front measured the same way, so like is compared with like.
    target = opaque_height(Image.open(ROOT / "assets/sprites/creatures/vitrecrag_official.png").convert("RGBA"))
    print("in-game body height", target)
    for old in OUT.glob("*.png"):
        old.unlink()
    for old in OUT.glob("*.json"):
        old.unlink()
    with tempfile.TemporaryDirectory() as tmp:
        for name, (rel, cells) in SHEETS.items():
            sheet = Image.open(SRC / rel).convert("RGB")
            for n, (x0, y0, x1, y1) in enumerate(cells):
                cell = sheet.crop((int(x0) + INSET, int(y0) + INSET, int(x1) - INSET, int(y1) - INSET))
                h = body_height(cell)
                if h < 40:
                    print(f"{name} cell {n}: empty, skipped")
                    continue
                block = h / BODY_HEIGHT
                src = Path(tmp) / f"{name}_{n}.png"
                dst = Path(tmp) / f"{name}_{n}_out.png"
                cell.save(src)
                convert_forge_sprite.convert(str(src), str(dst), block=block)
                img = Image.open(dst).convert("RGBA")
                box = img.getbbox()
                if box is None:
                    continue
                # The estimate counts the body only; if the converted creature still
                # stands taller than the in-game one, convert again at the exact
                # scale, so the attack does not swell when it starts.
                tall = opaque_height(img)
                if tall > target + 1:
                    block *= tall / target
                    convert_forge_sprite.convert(str(src), str(dst), block=block)
                    img = Image.open(dst).convert("RGBA")
                    box = img.getbbox()
                img.crop(box).save(OUT / f"{name}_f{n:02d}.png")
                print(f"{name}_f{n:02d}: block {block:.2f} -> {box[2] - box[0]}x{box[3] - box[1]}")


if __name__ == "__main__":
    main()
