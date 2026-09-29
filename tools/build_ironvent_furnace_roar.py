"""Build Ironvent's Furnace Roar frames from whole Opal poses.

Preston (2026-09-28): build Furnace Roar from his three sheets. Frames are cut
by tools/cut_ironvent_furnace_roar_sheets.py. The battle frames all come from
sheet 1, which holds the whole action with full bodies at one scale: the ridge
fills with heat, the head rears, the jaws open. Sheet 3's fire-burst frames are
cut off above the legs, so the burst itself is drawn in code, and sheet 2's big
close-up becomes a cut-in (see the move README).

Each frame is snapped to the in-game sprite's colours, cleared of crumbs and
registered like Plate Lunge: lowest pixel on the in-game foot line, rear edge
(the tail club) on the in-game rear edge, on the in-game 100x100 canvas.
The close-up is snapped to the same colours and saved as cutin.png.

Writes .../ironvent_furnace_roar/built/<name>.png.
Run from the project root: python tools/build_ironvent_furnace_roar.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_plate_lunge import clear_crumbs, palette_of, snap  # noqa: E402
from recolor_ironvent_head import recolor as dark_head  # noqa: E402  (Preston 2026-09-29: head matches the Cinderhide line)

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar"
SRC = BASE / "frames"
OUT = BASE / "built"
OFFICIAL = ROOT / "assets/sprites/creatures/ironvent.png"
CANVAS = 100

# Output name -> source frame, in attack order (see README).
FRAMES = [
    ("rest", "roar1_f00"),      # idle
    ("warm", "roar1_f01"),      # heat rising in the ridge
    ("pressure", "roar1_f02"),  # ridge full and bright
    ("rear", "roar1_f03"),      # head rears, glow in the mouth
    ("open", "roar1_f04"),      # jaws opening wider
    ("roar", "roar1_f07"),      # jaws wide: the release
    ("settle", "roar1_f06"),    # jaws closing
    ("cool", "roar1_f08"),      # back down, ridge still warm
]


def register(a, foot_y, rear_x):
    ys, xs = np.where(a[..., 3] > 0)
    dx, dy = rear_x - xs.min(), foot_y - ys.max()
    canvas = np.zeros((CANVAS, CANVAS, 4), np.uint8)
    for y, x in zip(ys, xs):
        ty, tx = y + dy, x + dx
        if 0 <= ty < CANVAS and 0 <= tx < CANVAS:
            canvas[ty, tx] = a[y, x]
    return canvas


def main():
    official = Image.open(OFFICIAL).convert("RGBA")
    palette = palette_of(official)
    oa = np.asarray(official)
    oys, oxs = np.where(oa[..., 3] > 0)
    foot_y, rear_x = oys.max(), oxs.min()
    OUT.mkdir(exist_ok=True)
    built = []
    for name, src in FRAMES:
        a = np.asarray(Image.open(SRC / f"{src}.png").convert("RGBA")).copy()
        a = clear_crumbs(snap(a, palette))
        img, _ = dark_head(Image.fromarray(register(a, foot_y, rear_x), "RGBA"))
        img.save(OUT / f"{name}.png")
        built.append(img)
        ys, xs = np.where(np.asarray(img)[..., 3] > 0)
        print(f"{name:8s} <- {src}: {xs.max() - xs.min() + 1}x{ys.max() - ys.min() + 1}, box x {xs.min()}-{xs.max()} y {ys.min()}-{ys.max()}")
    cut = np.asarray(Image.open(SRC / "closeup.png").convert("RGBA")).copy()
    dark_head(Image.fromarray(clear_crumbs(snap(cut, palette)), "RGBA"))[0].save(OUT / "cutin.png")
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 3
        ps = []
        for t in [official] + built + [official]:
            bg = Image.new("RGBA", t.size, (40, 60, 70, 255))
            bg.alpha_composite(t)
            ps.append(bg.resize((CANVAS * Z, CANVAS * Z), Image.NEAREST))
        cols = 5
        rows = (len(ps) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * (ps[0].width + 6), rows * (ps[0].height + 6)), (0, 0, 0, 255))
        for i, p in enumerate(ps):
            sheet.paste(p, ((i % cols) * (p.width + 6), (i // cols) * (p.height + 6)))
        sheet.save(dest)


if __name__ == "__main__":
    main()
