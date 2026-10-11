"""Remove painted-on effects that float apart from a creature's body (Claude, 2026-10-10; Preston: the sparks
on Starward's tail "don't look right because it's standing still... made to look like there's active
lighting"). Frozen sparks read as a still frame of lightning; the game draws a live flicker in their place
(scripts/arena/static_sparks.gd).

Pieces of the sprite that do not touch the body (8-way) and sit more than GAP pixels from it are taken
out. A piece that nearly touches (an arm a pixel off the chest) stays. The centre of what was removed in
each full-size facing is written to assets/sprites/arena/<form>/sparks.json, as fractions of the image,
so the flicker is drawn where the sparks were.
  python tools/arena/strip_floaters.py <form> [--dry]
Rewrites every single-frame PNG of the form (stills, sets, walks, actions); rerun it after any rebuild from
the sheets. Originals are kept
once in docs/creatures/floaters-2026-10-10/before/.
"""
import json, shutil, sys
from collections import deque
from pathlib import Path
from PIL import Image

GAP = 0   # anything not touching the body; 2 left the strokes hugging Starward's tail
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]


def components(img):
    w, h = img.size
    a = img.getchannel("A").load()
    seen = [[False] * w for _ in range(h)]
    comps = []
    for y in range(h):
        for x in range(w):
            if a[x, y] == 0 or seen[y][x]:
                continue
            q = deque([(x, y)])
            seen[y][x] = True
            pts = []
            while q:
                cx, cy = q.popleft()
                pts.append((cx, cy))
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and not seen[ny][nx] and a[nx, ny] > 0:
                            seen[ny][nx] = True
                            q.append((nx, ny))
            comps.append(pts)
    return comps


def floaters(img, gap):
    comps = components(img)
    if len(comps) < 2:
        return []
    body = set(max(comps, key=len))
    out = []
    for c in comps:
        if len(c) >= len(body):
            continue
        near = any((x + dx, y + dy) in body for (x, y) in c for dx in range(-gap, gap + 1) for dy in range(-gap, gap + 1))
        if not near:
            out.extend(c)
    return out


def files(form):
    # Single frames only: on a sheet the largest frame would count as "the body" and the rest would go.
    # So the sheets keep their sparks, and a rebuild from them (build_dungeon_set.py, build_actions.py)
    # needs this run again afterwards.
    return sorted(Path("assets/sprites/arena").joinpath(form).rglob("*.png"))


if __name__ == "__main__":
    form = sys.argv[1]
    dry = "--dry" in sys.argv
    back = Path("docs/creatures/floaters-2026-10-10/before")
    anchors = {}
    total = 0
    for p in files(form):
        keep = back / p
        if not keep.exists() and not dry:
            keep.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, keep)
        img = Image.open(keep if keep.exists() else p).convert("RGBA")
        pts = floaters(img, GAP)
        total += len(pts)
        if p.parent.name == form and p.stem in FACINGS and pts:
            cx = sum(x for x, _ in pts) / len(pts) / img.width
            cy = sum(y for _, y in pts) / len(pts) / img.height
            anchors[p.stem] = [round(cx, 3), round(cy, 3)]
        if dry:
            continue
        px = img.load()
        for x, y in pts:
            px[x, y] = (0, 0, 0, 0)
        img.save(p)
    if not dry:
        (Path("assets/sprites/arena") / form / "sparks.json").write_text(json.dumps(anchors, indent=1))
    print(form, "files", len(files(form)), "pixels removed", total, "anchors", anchors)
