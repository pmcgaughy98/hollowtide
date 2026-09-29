"""Build Vitrecrag's Molten Cannon frames from whole Opal poses.

Preston (2026-09-28): build Molten Cannon from its own four sheets by the
attack-sheet protocol, and take what is useful from the dropped Molten Beam
sheets. Frames are cut by tools/cut_vitrecrag_cannon_sheets.py; the sequence
below uses only cannon sheet 3 and beam sheet 3, which are drawn at the same
scale, so there is no size jump between poses (see the move README).

Each frame is snapped to the in-game sprite's colours, cleared of crumbs and
registered like Plate Lunge (lowest pixel on the in-game foot line, rear edge on
the in-game rear edge), on a 176 px wide canvas: the brace pose spreads its legs
to about 147 px, and a 148 canvas cut off the near front leg (Preston,
2026-09-28). The in-game sprite sits at x+24 on that canvas, so the centre is
unchanged and aim points measured on the in-game sprite still line up.

Writes .../vitrecrag_molten_cannon/built/<name>.png.
Run from the project root: python tools/build_vitrecrag_molten_cannon.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_plate_lunge import clear_crumbs, palette_of, snap  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/vitrecrag_molten_cannon"
SRC = BASE / "frames"
OUT = BASE / "built"
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"
CANVAS = 176
SHIFT = 24

# Output name -> source frame, in attack order (see README).
FRAMES = [
    ("rest", "cannon3_f00"),      # idle with the mouth flame
    ("brace", "cannon3_f01"),     # head pulled in, legs spread wide
    ("charge", "cannon3_f02"),    # core brightening
    ("swirl", "cannon3_f03"),     # fire swirling in the core
    ("blaze", "cannon3_f04"),     # core blazing
    ("kindle", "beam3_f02"),      # fire kindles in the open collar
    ("loaded", "beam3_f03"),      # fireball formed in the muzzle: the shot
    ("spent", "cannon3_f05"),     # core dark, smoke curling from the collar
    ("vent", "beam3_f05"),        # core relit, last smoke at the collar
]


def register(a, foot_y, rear_x):
    ys, xs = np.where(a[..., 3] > 0)
    dx, dy = rear_x - xs.min(), foot_y - ys.max()
    canvas = np.zeros((128, CANVAS, 4), np.uint8)
    for y, x in zip(ys, xs):
        ty, tx = y + dy, x + dx
        if 0 <= ty < 128 and 0 <= tx < CANVAS:
            canvas[ty, tx] = a[y, x]
    return canvas


def main():
    official = Image.open(OFFICIAL).convert("RGBA")
    palette = palette_of(official)
    oa = np.asarray(official)
    oys, oxs = np.where(oa[..., 3] > 0)
    foot_y, rear_x = oys.max(), oxs.min() + SHIFT
    OUT.mkdir(exist_ok=True)
    built = []
    for name, src in FRAMES:
        a = np.asarray(Image.open(SRC / f"{src}.png").convert("RGBA")).copy()
        a = clear_crumbs(snap(a, palette))
        img = Image.fromarray(register(a, foot_y, rear_x), "RGBA")
        img.save(OUT / f"{name}.png")
        built.append((name, img))
        ys, xs = np.where(np.asarray(img)[..., 3] > 0)
        print(f"{name:7s} <- {src}: {xs.max() - xs.min() + 1}x{ys.max() - ys.min() + 1}, right edge {xs.max()}")
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 3
        ingame = Image.new("RGBA", (CANVAS, 128))
        ingame.alpha_composite(official, (SHIFT, 0))
        ps = []
        for t in [ingame] + [b for _, b in built] + [ingame]:
            bg = Image.new("RGBA", t.size, (40, 60, 70, 255))
            bg.alpha_composite(t)
            ps.append(bg.crop((0, 20, CANVAS, 128)).resize((CANVAS * Z, 108 * Z), Image.NEAREST))
        cols = 4
        rows = (len(ps) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * (ps[0].width + 6), rows * (ps[0].height + 6)), (0, 0, 0, 255))
        for i, p in enumerate(ps):
            sheet.paste(p, ((i % cols) * (p.width + 6), (i // cols) * (p.height + 6)))
        sheet.save(dest)


if __name__ == "__main__":
    main()
