"""Bake Vitrecrag's head-retract into the Molten Glass pour frames.

The pour frames in assets/sprites/creatures/attacks/vitrecrag_lava_pour/ are the
unchanged in-game sprite plus shell glow and lava. This script lifts the head out
(HEAD_POLY, in the official sprite's 128x128 coordinates), slides it up and back
by RETRACT per frame, and draws it only where the head itself used to be, so any
part that moves onto the shell is hidden by the shell. Lava stays on top. The
body, legs and feet are never touched, so the frames still line up with idle.

Writes new files into .../vitrecrag_lava_pour/head_retract/ and never edits the
originals. Run from the project root:  python tools/build_vitrecrag_head_retract.py [--preview out.png]
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour"
OUT = SRC / "head_retract"
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"
CANVAS_X = 6  # the official sprite sits at x+6 on the 140x128 pour canvas

HEAD_POLY = [(90, 72), (95, 69), (100, 71), (105, 73), (109, 77), (111, 84),
             (111, 93), (107, 97), (97, 97), (90, 93), (87, 82)]
# How far the head has pulled back on each beat (x, y); negative is up and back.
RETRACT = {"01_load": (-2, -1), "02_windup": (-6, -3), "03_launch": (-9, -4),
           "04_contact": (-9, -4), "05_recovery": (-4, -2)}
# The deeper the head goes, the more the shell shades it.
# Beats where the idle mouth flame is still lit.
FLAME_FRAMES = ("01_load", "05_recovery")
NO_FLAME_FRAMES = ("02_windup",)
# Area checked for stray one-pixel specks after the head moves.
HEAD_BOX = (86, 64, 116, 100)
# Vacated pixels at or right of this x open to air; left of it is the opening.
OPEN_FRONT_X = 104
# How dark the opening behind the head is (share of the original colour).
CAVITY_SHADE = 0.35
SHADE = {"01_load": 0.92, "02_windup": 0.8, "03_launch": 0.7,
         "04_contact": 0.7, "05_recovery": 0.85}


def build(name, official, mask):
    frame = Image.open(SRC / f"{name}.png").convert("RGBA")
    W, H = frame.size
    fp, op, mp = frame.load(), official.load(), mask.load()
    out = frame.copy()
    o = out.load()
    dx, dy = RETRACT[name]
    shade = SHADE[name]

    def in_hole(x, y):  # x, y in canvas coordinates
        ox = x - CANVAS_X
        return 0 <= ox < 128 and 0 <= y < 128 and mp[ox, y] > 0

    def is_extra(x, y):
        """Lava, flame or glow the pour frame adds on top of the official sprite."""
        ox = x - CANVAS_X
        base = op[ox, y] if 0 <= ox < 128 else (0, 0, 0, 0)
        return fp[x, y][3] > 0 and fp[x, y] != base

    # 1. Slide the head back. It draws only inside its old footprint, so any
    #    part that moves under the shell rim is hidden by the shell.
    moved = {}
    for y in range(H):
        for x in range(W):
            sx, sy = x - dx, y - dy  # where this pixel of the head came from
            if in_hole(x, y) and in_hole(sx, sy):
                c = op[sx - CANVAS_X, sy]
                if c[3]:
                    moved[(x, y)] = (int(c[0] * shade), int(c[1] * shade), int(c[2] * shade), c[3])
    front = {}  # rightmost head pixel on each row after the move
    for (x, y) in moved:
        front[y] = max(front.get(y, -1), x)
    # 2. Empty the old spot, keeping anything the frame added (lava). In front
    #    of the moved head is open air; behind and below it is the dark opening
    #    the head withdrew into, which keeps the forelegs joined to the body.
    for y in range(H):
        for x in range(W):
            if not in_hole(x, y) or is_extra(x, y):
                continue
            if y in front:
                air = x > front[y]
            else:
                air = x - CANVAS_X >= OPEN_FRONT_X
            if air:
                o[x, y] = (0, 0, 0, 0)
            else:  # what was there, deep in shadow, so it reads as an opening
                c = op[x - CANVAS_X, y]
                o[x, y] = (int(c[0] * CAVITY_SHADE), int(c[1] * CAVITY_SHADE), int(c[2] * CAVITY_SHADE), c[3])
    for (x, y), c in moved.items():
        if not is_extra(x, y):  # lava stays in front of the head
            o[x, y] = c
    # 3. The idle mouth flame follows the mouth on the shallow beats and goes
    #    out while the head is deep. Lava frames have no flame to touch.
    if name in FLAME_FRAMES or name in NO_FLAME_FRAMES:
        flame = []
        for y in range(H):
            for x in range(W):
                ox = x - CANVAS_X
                r, g, b, a = o[x, y]
                # The curl is part of the in-game sprite: bright orange just
                # in front of the mouth, outside the head's footprint.
                if a and ox > 108 and 74 <= y < 96 and not in_hole(x, y) and r > 150 and r > b + 80:
                    flame.append((x, y, (r, g, b, a)))
                    o[x, y] = (0, 0, 0, 0)
        if name in FLAME_FRAMES:
            for x, y, c in flame:
                tx, ty = x + dx, y + dy
                if 0 <= tx < W and 0 <= ty < H and o[tx, ty][3] == 0:
                    o[tx, ty] = c
    # 4. Rim specks left hanging in the air once the head is gone.
    x0, y0, x1, y1 = HEAD_BOX
    for y in range(y0, y1):
        for x in range(x0 + CANVAS_X, x1 + CANVAS_X):
            if o[x, y][3] and not is_extra(x, y):
                n = sum(1 for ax, ay in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1))
                        if 0 <= ax < W and 0 <= ay < H and o[ax, ay][3])
                if n <= 1:
                    o[x, y] = (0, 0, 0, 0)
    return out


def main():
    official = Image.open(OFFICIAL).convert("RGBA")
    mask = Image.new("L", official.size, 0)
    ImageDraw.Draw(mask).polygon(HEAD_POLY, fill=255)
    # Only the head's own pixels count, not transparent corners of the polygon.
    mp, op = mask.load(), official.load()
    for y in range(128):
        for x in range(128):
            if op[x, y][3] == 0:
                mp[x, y] = 0
    OUT.mkdir(exist_ok=True)
    frames = []
    for name in RETRACT:
        img = build(name, official, mask)
        img.save(OUT / f"{name}.png")
        frames.append(img)
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z, x0, y0, x1, y1 = 5, 76, 50, 140, 128
        panels = []
        for img in [Image.open(SRC / "04_contact.png").convert("RGBA")] + frames:
            bg = Image.new("RGBA", img.size, (40, 60, 70, 255))
            bg.alpha_composite(img)
            panels.append(bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * Z, (y1 - y0) * Z), Image.NEAREST))
        sheet = Image.new("RGBA", (sum(p.width + 6 for p in panels), panels[0].height), (0, 0, 0, 255))
        x = 0
        for p in panels:
            sheet.paste(p, (x, 0))
            x += p.width + 6
        sheet.save(dest)
    print("wrote", [str(OUT / f"{n}.png") for n in RETRACT])


if __name__ == "__main__":
    main()
