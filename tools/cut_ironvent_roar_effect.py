"""Cut Preston's Ironvent Furnace Roar impact effect sheet into eight frames.

Preston (2026-09-28) generated the sheet from the MODE ACTION brief in
docs/forges/ironvent-furnace-roar-impact-forge-prompt-2026-09-28.md and filed it as
"Furnace roar Effect for sure.jfif". Layout: 2 columns x 4 rows, F1 to F8 in
reading order, each with a small "F#" label in its bottom-left corner.

The labels are painted over with the background first. The whole sheet is then
converted at once (one pixel grid for every frame) and split into its eight
cells without cropping, so every frame keeps the same canvas and the effect
does not jump between frames. Originals stay untouched in OneDrive.

Writes assets/sprites/effects/ironvent/furnace_roar/f1..f8.png.
Run from the project root: python tools/cut_ironvent_roar_effect.py
"""
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SRC = Path.home() / "OneDrive/Documents/HollowTide Sprites/Effect Sheets/IronVent Effect/Furnace roar Effect for sure.jfif"
OUT = ROOT / "assets/sprites/effects/ironvent/furnace_roar"
COLS, ROWS = 2, 4
LABEL = (0, 196, 80, 256)  # label box inside each 512x256 cell: x0, y0, x1, y1


def main():
    sheet = np.asarray(Image.open(SRC).convert("RGB")).copy()
    bg = np.median(sheet[:8, :8].reshape(-1, 3), axis=0).astype(np.uint8)
    cw, ch = sheet.shape[1] // COLS, sheet.shape[0] // ROWS
    for r in range(ROWS):
        for c in range(COLS):
            x0, y0 = c * cw, r * ch
            sheet[y0 + LABEL[1]:y0 + LABEL[3], x0 + LABEL[0]:x0 + LABEL[2]] = bg
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        masked = Path(tmp) / "masked.png"
        native = Path(tmp) / "native.png"
        Image.fromarray(sheet).save(masked)
        convert_forge_sprite.convert(str(masked), str(native))
        img = Image.open(native).convert("RGBA")
    # The converter centres the drawing on its canvas and stands it on a floor,
    # which shifts everything off the sheet's cell lines. Shift it back: find
    # where the drawing started on the original sheet (in blocks) and where it
    # starts now.
    w, h = img.size
    px = sheet.shape[1] / w
    fg = ~convert_forge_sprite.background(sheet.astype(int))
    ys, xs = np.where(fg)
    was = (round(xs.min() / px), round(ys.min() / px))
    now = img.getbbox()[:2]
    placed = Image.new("RGBA", (w, h))
    placed.alpha_composite(img, (was[0] - now[0], was[1] - now[1]))
    img = placed
    print("native sheet", w, "x", h, "block", round(px, 2), "shifted by", was[0] - now[0], was[1] - now[1])
    ncw, nch = w / COLS, h / ROWS
    for r in range(ROWS):
        for c in range(COLS):
            n = r * COLS + c + 1
            cell = img.crop((round(c * ncw), round(r * nch), round((c + 1) * ncw), round((r + 1) * nch)))
            cell.save(OUT / f"f{n}.png")
            print(f"f{n}: {cell.size}, content {cell.getbbox()}")


if __name__ == "__main__":
    main()
