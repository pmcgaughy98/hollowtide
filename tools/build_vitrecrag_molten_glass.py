"""Build Vitrecrag's Molten Glass front-view frames from whole Opal poses (v2).

Same approved method as Plate Lunge v2 (docs/attack-sheet-protocol.md): whole
poses, cut on their true grid to match the in-game size, snapped to the in-game
24 colours, crumbs cleared, registered on the in-game foot line and rear edge.

Sheet 2 is the backbone because it holds a complete sequence in one drawing, so
the body never switches drawings mid-attack. Added: sheet 4's head-retraction
hole glowing with lava (Preston's pick) and sheet 1's pour (sheet 2's sister
sheet) to alternate with sheet 2's for a flowing pour.

Frames come from vitrecrag_lava_pour/body_frames/ (sheets 1-2 cut with
--block 3.67 --grid 2x3, sheets 3-4 with --block 4 --grid 2x3).
Writes vitrecrag_lava_pour/v2/<name>.png.
Run from the project root: python tools/build_vitrecrag_molten_glass.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_plate_lunge import clear_crumbs, palette_of, snap  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour"
SRC = BASE / "body_frames"
OUT = BASE / "v2"
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"

FRAMES = [
    ("load", "sheet2_f01"),       # head lowers
    ("hole", "sheet4_f01"),       # head recessed, the opening glows with lava
    ("flood", "sheet2_f02"),      # whole shell floods with molten glow (brace)
    ("breakout", "sheet2_f03"),   # glass breaks out of the hole, first stream
    ("pour_a", "sheet2_f04"),     # thick pour with pool
    ("pour_b", "sheet1_f04"),     # sister sheet's pour, alternated for flow
    ("recover", "sheet2_f05"),    # head back out with a drip
]


CANVAS_W, CANVAS_X = 140, 6  # 140-wide canvas, in-game sprite centred at x+6 (as the pour frames always were)


def register(a, foot_y, rear_x):
    """Lowest pixel on the in-game foot line, rear edge on the in-game rear edge."""
    ys, xs = np.where(a[..., 3] > 0)
    dx, dy = rear_x + CANVAS_X - xs.min(), foot_y - ys.max()
    canvas = np.zeros((128, CANVAS_W, 4), np.uint8)
    for y, x in zip(ys, xs):
        ty, tx = y + dy, x + dx
        if 0 <= ty < 128 and 0 <= tx < CANVAS_W:
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
        img = Image.fromarray(register(a, foot_y, rear_x), "RGBA")
        img.save(OUT / f"{name}.png")
        built.append(img)
        ys, xs = np.where(np.asarray(img)[..., 3] > 0)
        print(f"{name} <- {src}: body {xs.max() - xs.min() + 1} x {ys.max() - ys.min() + 1}")
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 3
        ps = []
        wide = Image.new("RGBA", (CANVAS_W, 128), (0, 0, 0, 0))
        wide.alpha_composite(official, (CANVAS_X, 0))
        for t in [wide] + built + [wide]:
            bg = Image.new("RGBA", t.size, (40, 60, 70, 255))
            bg.alpha_composite(t)
            ps.append(bg.crop((0, 20, CANVAS_W, 128)).resize((CANVAS_W * Z, 108 * Z), Image.NEAREST))
        sheet = Image.new("RGBA", (sum(p.width + 6 for p in ps), ps[0].height), (0, 0, 0, 255))
        x = 0
        for p in ps:
            sheet.paste(p, (x, 0))
            x += p.width + 6
        sheet.save(dest)


if __name__ == "__main__":
    main()
