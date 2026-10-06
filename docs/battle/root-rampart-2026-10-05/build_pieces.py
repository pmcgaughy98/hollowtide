"""Root Rampart effect pieces (Claude, 2026-10-05). Free; run from the repo root.
The eruption is RD Pro take 2 (roots with pale husk spikes) with its flat ground
slab removed: ground colours are cleared outside the root column, and the column
fades into a ragged crater edge. eruption_alt is its mirror (the two alternate);
the field burst is a small copy."""
from collections import Counter
from pathlib import Path
from PIL import Image, ImageOps
D = "docs/battle/root-rampart-2026-10-05/"
OUT = Path("assets/sprites/effects/tallowroot3/root_rampart"); OUT.mkdir(parents=True, exist_ok=True)
im = Image.open(D + "eruption_front_take2.png").convert("RGBA"); px = im.load(); W, H = im.size
ground = Counter(px[x, H - 2][:3] for x in range(W)).most_common(6)
gcols = [c for c, _ in ground]
def is_ground(p):
    return any(abs(p[0] - c[0]) + abs(p[1] - c[1]) + abs(p[2] - c[2]) < 40 for c in gcols)
# The root column: columns that are dark brown wood in the upper half.
wood_cols = [x for x in range(W) if sum(1 for y in range(H // 2) if px[x, y][3] and sum(px[x, y][:3]) < 330) > H // 6]
left, right = min(wood_cols), max(wood_cols)
for y in range(H):
    for x in range(W):
        p = px[x, y]
        inside = left - 3 <= x <= right + 3
        if p[3] and is_ground(p) and (not inside or y > H - 6):
            px[x, y] = (0, 0, 0, 0)
im.save(OUT / "eruption.png"); ImageOps.mirror(im).save(OUT / "eruption_alt.png")
im.resize((32, 32), Image.NEAREST).save(OUT / "field_roots.png")
print("column", left, right, "ground colours", gcols[:3], "bbox", im.getbbox())
