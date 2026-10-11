"""Cut a perch post out from under a creature (Claude, 2026-10-10; Preston: "trim wayling's post").
Wayling's takes came back standing on a wooden post, and the rotations and walks kept it. In town it
should stand on the ground itself.

How the post is found, per frame: the post is the solid block at the bottom of the sprite whose rows all
span about the same width. From the bottom row up, rows that still span at least 60% of that width belong
to the post, as long as nothing in the row reaches outside the post's columns; the first narrower row is
the legs, and the first wider one is the body or a wing. Everything from there down inside the post's columns is
cleared, except the claw colours (CLAWS) that touch the legs, so the feet keep their toes.
  python tools/arena/strip_post.py wayling
Rewrites the full-size stills (assets/sprites/arena/<form>/<facing>.png) and the walk sheets
(docs/creatures/arena-starters-2026-10-07/walk/<form>_<facing>_sheet.png, 128 px cells). Originals are
kept once in docs/creatures/post-trim-2026-10-10/before/ and always read from there, so a rerun is clean.
Then rebuild the sets: python tools/arena/build_dungeon_set.py <form> --set=town --scale=1.5
"""
import shutil, sys
from pathlib import Path
import numpy as np
from PIL import Image

CELL = 128
CLAWS = {(13, 2, 0), (32, 17, 5)}   # Wayling's toe colours; the post's own outline is pure black
GREYS = {(146, 151, 131), (172, 168, 164), (225, 223, 220)}   # the post's weathered sides, nowhere on the bird
WOOD = GREYS | {(218, 200, 170), (195, 177, 144), (101, 83, 71), (123, 106, 79), (102, 95, 77), (124, 96, 89),
                (132, 106, 97), (0, 0, 0)}   # sides, cut top and rim; the bag and strap share some of these
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
BACK = Path("docs/creatures/post-trim-2026-10-10/before")


def trim(cell: np.ndarray) -> int:
    m = cell[..., 3] > 0
    rows = np.nonzero(m.any(1))[0]
    if rows.size == 0:
        return 0
    bottom = rows.max()
    xs = np.nonzero(m[bottom])[0]
    x0, x1 = xs.min(), xs.max()
    width = x1 - x0 + 1
    top = bottom
    while top - 1 >= 0:
        r = np.nonzero(m[top - 1])[0]
        # A post row stays inside the post's columns and keeps most of its width; the legs are narrower
        # and the body or wings reach outside it.
        if r.size == 0 or r.min() < x0 - 3 or r.max() > x1 + 3 or (r.max() - r.min() + 1) < 0.6 * width:
            break
        top -= 1
    # Claws: claw-coloured pixels in the post's top rows that connect up to the legs.
    keep = np.zeros_like(m)
    for y in range(top, min(top + 4, bottom + 1)):
        for x in range(x0 - 2, x1 + 3):
            if m[y, x] and tuple(cell[y, x, :3]) in CLAWS:
                above = (keep[y - 1, x - 1:x + 2].any() or
                         (m[y - 1, x - 1:x + 2].any() and y - 1 < top))
                if above:
                    keep[y, x] = True
    cut = np.zeros_like(m)
    cut[top:bottom + 1, max(0, x0 - 2):x1 + 3] = True
    cut &= m & ~keep
    # Second pass, for frames where a tail or wing hangs over the post and stopped the row walk: inside the
    # post's box, from 4 rows above its highest grey side down, clear every post colour. The box keeps the
    # bag and strap safe, since they share the post's browns and creams.
    lo, hi = max(0, x0 - 3), x1 + 4
    grey_rows = [y for y in range(bottom + 1) if any(tuple(cell[y, x, :3]) in GREYS and m[y, x] for x in range(lo, min(hi, m.shape[1])))]
    if grey_rows:
        g = bottom
        while g - 1 in grey_rows:
            g -= 1
        for y in range(max(0, g - 4), bottom + 1):
            for x in range(lo, min(hi, m.shape[1])):
                if m[y, x] and not keep[y, x] and tuple(cell[y, x, :3]) in WOOD:
                    cut[y, x] = True
    cell[cut] = 0
    n = int(cut.sum())
    # Specks left floating (a rim pixel, a lone toe) go too: anything small not joined to the body.
    m = cell[..., 3] > 0
    comps = components(m)
    if len(comps) > 1:
        body = max(comps, key=len)
        for c in comps:
            if c is not body and len(c) < 15:
                for y, x in c:
                    cell[y, x] = 0
                n += len(c)
    return n


def components(m):
    h, w = m.shape
    seen = np.zeros_like(m)
    out = []
    for sy, sx in zip(*np.nonzero(m)):
        if seen[sy, sx]:
            continue
        seen[sy, sx] = True
        stack, pts = [(sy, sx)], []
        while stack:
            y, x = stack.pop()
            pts.append((y, x))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < h and 0 <= nx < w and m[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
        out.append(pts)
    return out


def run(path: Path, sheet: bool) -> int:
    orig = BACK / path
    if not orig.exists():
        orig.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, orig)
    a = np.array(Image.open(orig).convert("RGBA"))
    n = 0
    if sheet:
        for y in range(0, a.shape[0], CELL):
            for x in range(0, a.shape[1], CELL):
                n += trim(a[y:y + CELL, x:x + CELL])
    else:
        n = trim(a)
    Image.fromarray(a).save(path)
    return n


if __name__ == "__main__":
    form = sys.argv[1]
    for f in FACINGS:
        p = Path("assets/sprites/arena") / form / (f + ".png")
        if p.exists():
            print(p, "cleared", run(p, False))
        s = Path("docs/creatures/arena-starters-2026-10-07/walk") / f"{form}_{f}_sheet.png"
        if s.exists():
            print(s, "cleared", run(s, True))
