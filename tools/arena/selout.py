"""Sel-out outline and spark-wisp peel for a pale creature (Claude, 2026-10-10; Preston: "do sel out for
Starward's sprite too, the outline doesn't look the same as other sprites", and the tail "is still
lightning" in two places).

Two steps on every single-frame PNG of the form (stills, sets, walks, actions):
  1. Peel: thin pale lines hanging off the outline (what is left of the painted sparks; they touch the tail,
     so strip_floaters.py kept them) are peeled from their loose end: a light pixel beside transparency
     with 3 or fewer solid neighbours goes, repeated until nothing changes. Solid fur has more neighbours,
     and dark outline pixels are never touched.
  2. Sel-out, on the shrunk sets only (dungeon, town, small, boss, escort): shrinking loses most of a pale
     creature's 1-pixel outline, so each light edge pixel becomes a dark shade of its own colour, mixed
     with the line's darkest outline colour. Cream fur gets a warm mauve-brown edge, not black.
  python tools/arena/selout.py starward
  python tools/arena/selout.py starward --black   # a solid outline instead (Preston, 2026-10-10: "do black
                                                   # outline pass for Starward"), on every frame, full size too
Originals are kept once in docs/creatures/selout-2026-10-10/before/ and always read from there. Rerun after
any rebuild of the sets (build_dungeon_set.py, build_actions.py), like strip_floaters.py.
"""
import shutil, sys
from pathlib import Path
import numpy as np
from PIL import Image

SETS = {"dungeon", "town", "small", "boss", "escort"}
LIGHT = 90        # luma at or above this is fill, below is outline
MIX = 0.38        # how much of the fill colour stays in its sel-out pixel
EDGE_LIGHT = 90.0  # edge pixels at or above this luma are recoloured (black mode: all but the line)
BACK = Path("docs/creatures/selout-2026-10-10/before")
PEEL = {"starward"}   # only lines with leftover painted sparks; elsewhere thin lines are real (straps, feathers)


def luma(rgb):
    return rgb[..., 0] * 0.3 + rgb[..., 1] * 0.59 + rgb[..., 2] * 0.11


def peel(a):
    n = 0
    while True:
        m = a[..., 3] > 0
        p = np.pad(m, 1)
        near_clear = ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
        count = sum(np.roll(np.roll(p, dy, 0), dx, 1)[1:-1, 1:-1].astype(int)
                    for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dy or dx)
        go = m & near_clear & (count <= 3) & (luma(a[..., :3]) >= LIGHT)
        if not go.any():
            return n
        a[go] = 0
        n += int(go.sum())


def selout(a, dark):
    m = a[..., 3] > 0
    p = np.pad(m, 1)
    edge = m & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
    go = edge & (luma(a[..., :3]) >= EDGE_LIGHT)
    a[go, :3] = (a[go, :3] * MIX + np.array(dark) * (1 - MIX)).round()
    return int(go.sum())


if __name__ == "__main__":
    form = sys.argv[1]
    black = "--black" in sys.argv
    if black:
        MIX = 0.0
    root = Path("assets/sprites/arena") / form
    still = np.array(Image.open(root / "s.png").convert("RGBA")).astype(int)
    sm = still[..., 3] > 0
    dark = still[sm][luma(still[sm][:, :3]) == luma(still[sm][:, :3]).min()][0][:3]   # the line's outline colour
    if black:
        EDGE_LIGHT = float(luma(np.array(dark, float))) + 12.0   # every edge pixel not already the line's colour
    totals = [0, 0]
    for f in sorted(root.rglob("*.png")):
        keep = BACK / f
        if not keep.exists():
            keep.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(f, keep)
        a = np.array(Image.open(keep).convert("RGBA")).astype(int)
        if form in PEEL:
            totals[0] += peel(a)
        if black or f.parent.name in SETS:
            totals[1] += selout(a, dark)
        Image.fromarray(a.astype(np.uint8)).save(f)
    print(form, "outline colour", tuple(int(v) for v in dark), "wisp pixels peeled", totals[0], "edge pixels sel-out", totals[1])
