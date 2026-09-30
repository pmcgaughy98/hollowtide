"""Build Oxbowarchon's Kingstone Rail frames from whole Opal poses.

Preston (2026-09-29): the rails swing up to point at the sky, a sphere of the
Kingstone's power builds between them while Oxbowarchon braces, then it
releases. Also Preston: use every good generation, repairing the inconsistent or
cut-off ones, rather than keeping only the best frame per beat.

Frames are cut from his "Kingstone rail 1-4" sheets into
.../oxbowarchon_kingstone_rail/frames/ (sheets 1, 2 and 4 on their 3x2 grid at
--block 2.62, which matches the in-game body width; sheet 3 by hand). Sheet 3
fires forward instead of at the sky, so it is reference only (see the README).

Each frame is cleaned and registered like Plate Lunge:
  - the sheet's grid lines at the cell edges are removed,
  - the pink cast left where glows were drawn over magenta is removed,
  - colours are snapped to the in-game sprite's palette plus four glow colours
    (the sphere and the release flash are brighter than anything on the idle),
    then any leftover magenta spill is cleaned (tools/clean_spill.py),
  - crumbs are cleared,
  - the lowest pixel sits on the in-game foot line, and the front edge of the
    lower body (head and front foot, the bottom BAND rows) on the in-game one.
    The tail end cannot be used: the bottom rows of sheets 2 and 4 clip the tail
    at the cell edge, and the sphere's rings reach past it.

Repairs:
  - Every frame gets the idle's own tail, grafted onto that frame's rump
    (graft_tail). Sheets 2 and 4 clip the tail at the cell edge, and each Opal
    pose draws the tail a little differently, so tails pasted from another
    frame did not connect and the tail jumped from frame to frame (Preston,
    2026-09-29: "its backside, backend and tail are wonky"). One tail, planted
    the same way in every frame, matches the idle and stays put.
  - The release flash was drawn past the cell edge in every sheet, so it is cut
    off in a straight line. The intact part is turned half a turn around the
    flash's bright core to fill the missing part (FLASH); a starburst is close
    to symmetric, so this reads as the whole burst.

The canvas is 256x216 so the completed flash fits. The 128x128 idle sits at the
bottom centre (x+64, y+88), and the battle lines the bottoms up (see
_drawn_attack_animation), so the feet do not move.

Writes .../oxbowarchon_kingstone_rail/built/<name>.png.
Run from the project root: python tools/build_oxbowarchon_kingstone_rail.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_plate_lunge import clear_crumbs, palette_of, snap  # noqa: E402
from clean_spill import clean as clean_spill  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail"
SRC = BASE / "frames"
OUT = BASE / "built"
OFFICIAL = ROOT / "assets/sprites/creatures/oxbowarchon.png"
W, H = 256, 216
SHIFT_X, SHIFT_Y = 64, 88  # where the 128x128 idle sits on the canvas
EDGE = 3                   # grid-line pixels at a cell's edges
BAND = 40                  # rows above the ground used to find the front edge
GLOW = np.array([[0x12, 0xB7, 0x6A], [0x7C, 0xF5, 0xB8], [0xCF, 0xFF, 0xE6], [0xFF, 0xFF, 0xFF]])

# Output name -> source frame, in attack order (see README). Near-duplicate
# poses (rail2_f00, rail2_f01, rail4_f00) are left out: the same pose redrawn
# adds jitter, not motion.
FRAMES = [
    ("rest", "rail1_f00"),         # rails forward, as the idle
    ("raise", "rail1_f01"),        # rails swung up to the sky
    ("glow", "rail4_f01"),         # the Kingstone starts to light the rails
    ("kindle", "rail2_f02"),       # a small sphere forms between the rail tops
    ("kindle_arcs", "rail4_f02"),  # the sphere with arcs reaching the rails
    ("swirl", "rail1_f03"),        # the sphere swells into a vortex
    ("full", "rail2_f03"),         # full sphere, rings orbiting it
    ("full_b", "rail4_f03"),       # full sphere, rings turned (alternates with full)
    ("burst", "rail2_f04"),        # release: the flash at the rail tips
    ("burst_b", "rail4_f04"),      # the shot leaving, flash high at the tips
    ("shot", "rail1_f04"),         # the shot streaks up and away
    ("spent", "rail1_f05"),        # rails lowering, afterglow between them
    ("afterglow", "rail4_f05"),    # rails forward, glow drifting off
    ("settle", "rail2_f05"),       # last puff of glow
]
# The tail-clipped frames take the tail from a frame where it is whole, in the
# box to the left of the haunch and above the rear leg (canvas pixels).
# The idle's tail, in idle-sprite pixels: everything left of TAIL_X between
# rows TAIL_Y0 and TAIL_Y1 (the wedge tip, the curl, and where it joins the
# rump). RUMP_ROW_UP: the rump's left edge is measured this many rows above
# the feet, as the start of the widest run of pixels (the tail is narrower).
TAIL_X, TAIL_Y0, TAIL_Y1 = 24, 40, 92
# Below the graft, the idle's tail base is carried down to BASE_Y1 in the
# columns left of BASE_X, filling only empty pixels (idle-sprite pixels).
BASE_X, BASE_Y1 = 34, 101
# Rows (idle-sprite pixels) where the tail and rump are clearly apart, used to
# measure whether a frame's rump sits further back than the idle's.
MEASURE_Y0, MEASURE_Y1 = 60, 76
# Some frames draw their own tail tip higher than the idle's; those leftovers
# end up as small detached pieces and are removed by drop_strays.
CLEAR_Y0 = TAIL_Y0
RUMP_ROW_UP = 40
SHIFT_SEARCH = 8  # frames are slid up to this many pixels to fit the idle's lower body
# Release frames whose flash is cut off. RADIUS limits the repair to the starburst.
FLASH = {"burst", "burst_b", "shot"}
RADIUS = 46
FLASH_ABOVE = 20 + SHIFT_Y  # flash pixels are above this canvas row (over the shell)


def clean(a):
    a = a.copy()
    a[:EDGE], a[-EDGE:], a[:, :EDGE], a[:, -EDGE:] = 0, 0, 0, 0
    r, g, b = (a[..., i].astype(int) for i in range(3))
    pink = (r > g + 25) & (b > g + 25)
    a[pink] = 0
    return a


def low_front(a):
    """The lowest opaque row and the front edge of the lower body."""
    ys, xs = np.where(a[..., 3] > 0)
    foot = ys.max()
    return foot, xs[ys > foot - BAND].max()


def register(a, foot_y, front_x, ref_low=None):
    """Feet on the idle's foot line, then slid sideways to where the lower
    body (legs, belly, rump) overlaps the idle's best, so neither the head end
    nor the tail end wobbles. Starts from the front-edge alignment."""
    ys, xs = np.where(a[..., 3] > 0)
    foot, front = low_front(a)
    dx, dy = front_x - front, foot_y - foot

    def place(ddx):
        canvas = np.zeros((H, W, 4), np.uint8)
        ty, tx = ys + dy, xs + ddx
        ok = (ty >= 0) & (ty < H) & (tx >= 0) & (tx < W)
        canvas[ty[ok], tx[ok]] = a[ys[ok], xs[ok]]
        return canvas

    if ref_low is None:
        return place(dx)
    best, best_dx = -1.0, dx
    for ddx in range(dx - SHIFT_SEARCH, dx + SHIFT_SEARCH + 1):
        low = place(ddx)[foot_y - BAND * 3:foot_y + 1, ..., 3] > 0
        score = (low & ref_low).sum() / max(1, (low | ref_low).sum())
        if score > best:
            best, best_dx = score, ddx
    return place(best_dx)


def body_left(idle, y):
    """Where the idle's body (not its tail) starts on canvas row y: the start
    of the widest run of pixels on that row (the tail is always narrower)."""
    row = list(idle[y, :, 3] > 0) + [False]
    runs, start = [], None
    for x, on in enumerate(row):
        if on and start is None:
            start = x
        elif not on and start is not None:
            runs.append((x - start, start))
            start = None
    return max(runs)[1] if runs else None


def drop_strays(c):
    """Removes small pieces floating by the tail (a frame's own tail tip drawn
    above the graft): detached from the body, left of the rump, under 150 pixels."""
    op = c[..., 3] > 0
    seen = np.zeros_like(op)
    h, w = op.shape
    for y0, x0 in zip(*np.where(op)):
        if seen[y0, x0]:
            continue
        stack, group = [(y0, x0)], []
        seen[y0, x0] = True
        while stack:
            y, x = stack.pop()
            group.append((y, x))
            for ny in (y - 1, y, y + 1):
                for nx in (x - 1, x, x + 1):
                    if 0 <= ny < h and 0 <= nx < w and op[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
        if len(group) < 150 and max(x for _, x in group) < SHIFT_X + 45:
            for y, x in group:
                c[y, x] = 0
    return c


def runs_of(row):
    runs, start = [], None
    for x, on in enumerate(list(row) + [False]):
        if on and start is None:
            start = x
        elif not on and start is not None:
            runs.append((start, x - 1))
            start = None
    return runs


def graft_tail(c, idle, foot_y):
    """Replace a frame's tail with the idle's, gaps and all.

    Frames are already slid onto the idle's lower body (register). On each
    tail row, everything left of the idle's rump outline is copied from the
    idle exactly, including the open gap between tail and rump. Opal draws
    some poses' tail base fused to the rump (shot, swirl, spent: a solid
    shelf between the tail loop and the body), so "left of this frame's own
    body" cannot find it; the idle's outline can. If this frame's rump sits
    further back than the idle's (measured on rows where tail and rump are
    clearly apart), the boundary moves back with it so that rump is never
    shaved (Preston, 2026-09-29)."""
    y0, y1 = TAIL_Y0 + SHIFT_Y, TAIL_Y1 + SHIFT_Y
    offsets = []
    for y in range(MEASURE_Y0 + SHIFT_Y, MEASURE_Y1 + SHIFT_Y):
        fr, ir = runs_of(c[y, :, 3] > 0), runs_of(idle[y, :, 3] > 0)
        if len(fr) >= 2 and len(ir) >= 2:
            offsets.append(max(fr, key=lambda r: r[1] - r[0])[0] - max(ir, key=lambda r: r[1] - r[0])[0])
    back = min(0, int(np.median(offsets))) if offsets else 0
    for y in range(CLEAR_Y0 + SHIFT_Y, y1):
        edge = body_left(idle, y)
        if edge is None:
            continue
        edge = max(0, edge + back)
        c[y, :edge] = idle[y, :edge]
    tail = idle[y0:y1, :TAIL_X + SHIFT_X]
    for yy, xx in zip(*np.where(tail[..., 3] > 0)):
        c[y0 + yy, xx] = tail[yy, xx]
    # The tail base: below the graft the idle's tail keeps curving down into
    # the rump beside the hind leg. Carry it on through those rows, filling only
    # empty pixels, so the tail sweeps into this frame's own rump instead of
    # ending in a flat shelf (Preston, 2026-09-29, poses where the rump sits
    # further in: swirl, shot, spent).
    b0, b1 = y1, BASE_Y1 + SHIFT_Y
    base = idle[b0:b1, :BASE_X + SHIFT_X]
    for yy, xx in zip(*np.where(base[..., 3] > 0)):
        if c[b0 + yy, xx, 3] == 0:
            c[b0 + yy, xx] = base[yy, xx]

def flash_mask(c):
    r, g, b = (c[..., i].astype(int) for i in range(3))
    bright = (np.minimum(np.minimum(r, g), b) >= 150) | ((g >= 180) & (g > r + 40))
    bright &= c[..., 3] > 0
    bright[FLASH_ABOVE:] = False
    return bright


def complete(c, mask):
    """Fills the cut-off part of the flash by turning the intact part half a turn
    around the flash's bright core, onto empty pixels only. The cut is always on
    the top or right, so the intact lower-left rays land where the missing
    upper-right ones were, and the beam leading in carries on out the far side."""
    ys, xs = np.where(mask)
    lum = c[ys, xs, :3].astype(int).sum(1)
    hot = lum >= np.percentile(lum, 85)
    cy, cx = ys[hot].mean(), xs[hot].mean()
    near = (xs - cx) ** 2 + (ys - cy) ** 2 <= RADIUS ** 2
    ty = np.round(2 * cy - ys[near]).astype(int)
    tx = np.round(2 * cx - xs[near]).astype(int)
    ok = (tx >= 0) & (tx < W) & (ty >= 0) & (ty < H)
    for y, x, sy, sx in zip(ty[ok], tx[ok], ys[near][ok], xs[near][ok]):
        if c[y, x, 3] == 0:
            c[y, x] = c[sy, sx]


def main():
    official = Image.open(OFFICIAL).convert("RGBA")
    palette = np.concatenate([palette_of(official), GLOW])
    oa = np.asarray(official)
    foot, front = low_front(oa)
    foot_y, front_x = foot + SHIFT_Y, front + SHIFT_X
    idle_canvas = np.zeros((H, W, 4), np.uint8)
    idle_canvas[SHIFT_Y:SHIFT_Y + oa.shape[0], SHIFT_X:SHIFT_X + oa.shape[1]] = oa
    idle_low = idle_canvas[foot_y - BAND * 3:foot_y + 1, ..., 3] > 0
    OUT.mkdir(exist_ok=True)
    built = {}
    for name, src in FRAMES:
        a = clean(np.asarray(Image.open(SRC / f"{src}.png").convert("RGBA")))
        a = clear_crumbs(clean_spill(snap(a, palette))[0])
        c = register(a, foot_y, front_x, idle_low)
        graft_tail(c, idle_canvas, foot_y)
        c = drop_strays(clear_crumbs(c))
        if name in FLASH:
            m = flash_mask(c)
            if m.any():
                complete(c, m)
                c = clear_crumbs(c)
        built[name] = c
        Image.fromarray(c, "RGBA").save(OUT / f"{name}.png")
        ys, xs = np.where(c[..., 3] > 0)
        print(f"{name:11s} <- {src}: box x {xs.min()}-{xs.max()} y {ys.min()}-{ys.max()}")
    for old in OUT.glob("*.png"):
        if old.stem not in built:
            old.unlink()
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 2
        idle = Image.new("RGBA", (W, H))
        idle.paste(official, (SHIFT_X, SHIFT_Y))
        ps = []
        for t in [idle] + [Image.fromarray(c, "RGBA") for c in built.values()]:
            bg = Image.new("RGBA", t.size, (40, 60, 70, 255))
            bg.alpha_composite(t)
            ps.append(bg.resize((W * Z, H * Z), Image.NEAREST))
        cols = 5
        rows = (len(ps) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * (W * Z + 6), rows * (H * Z + 6)), (0, 0, 0, 255))
        for i, p in enumerate(ps):
            sheet.paste(p, ((i % cols) * (W * Z + 6), (i // cols) * (H * Z + 6)))
        sheet.save(dest)


if __name__ == "__main__":
    main()
