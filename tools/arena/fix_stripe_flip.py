"""Swap a back view's flipped stripe pattern back to the front's (Claude, 2026-10-09; Preston:
"color is the only issue... some are darker with light stripes and vice versa"). No generation.

Sparkwick's front and sides have a light tan body with darker brown stripes; its back stills (n, nw)
and back walks came out the other way round (a darker body with light stripes) with a pale cream
tail. For each named sprite (or each cell of a 4x2 walk sheet):
  1. The lantern (its bright core, plus a ring round it for the cage) and the dark outline are kept.
  2. The rest is split at the middle of its own tones into a dark group and a light group.
  3. An exact colour swap measured from the palettes (SWAP below): the back's dull body tan becomes
     the front's warm body tan, its light and orange stripes the front's stripe browns, and cream
     outside the lantern (the wrong tail tip) body tan. (A first try split tones by brightness; the
     body is close to the lantern's glow, so the exact swap is safer.)
Only the front's own colours are used. Originals are copied once to <backup>/ and always re-read
from there.
  python tools/arena/fix_stripe_flip.py <front.png> <backup_dir> <file> [<file> ...]
A file ending _sheet.png is treated as a 4 x 2 walk sheet."""
import shutil, sys
from pathlib import Path
import numpy as np
from PIL import Image


def lum(rgb):
    return rgb[..., :3].astype(float).mean(axis=-1)


# Measured 2026-10-09 from the palettes (every Sparkwick view is locked to the same approved colours):
# front and sides: body (215,156,76) warm tan, stripes (156,103,58) / (143,92,54) brown.
# back views: body (180,139,91) dull tan, stripes (216,181,115) light and (217,128,37) bright orange,
# and cream on the tail. Each back colour on the left becomes the front colour on the right.
SWAP = {(180, 139, 91): (215, 156, 76), (216, 181, 115): (156, 103, 58), (217, 128, 37): (143, 92, 54)}
# The walk sheets' palette (a good side walk: body (202,152,89), stripes (156,103,58), (180,139,91) a
# legitimate mid shade there): the back walks' grey body and orange stripes swap to it.
WALK_SWAP = {(166, 137, 105): (202, 152, 89), (217, 128, 37): (156, 103, 58)}
CREAM = [(254, 240, 168), (247, 226, 157), (228, 210, 159)]
BODY = (215, 156, 76)
WALK_BODY = (202, 152, 89)


def lantern_ring(a):
    """The lantern: a disc round its bright yellow core (252,207,46 and brighter), covering the cage."""
    r, g, b = (a[..., k].astype(int) for k in range(3))
    core = (a[..., 3] > 0) & (r > 245) & (g > 195) & (b < 80)
    ring = np.zeros(core.shape, bool)
    if core.sum() > 4:
        ys, xs = np.nonzero(core)
        cy, cx = ys.mean(), xs.mean()
        rad = max(ys.max() - ys.min(), xs.max() - xs.min()) / 2 + 9
        yy, xx = np.mgrid[0:a.shape[0], 0:a.shape[1]]
        ring = (yy - cy) ** 2 + (xx - cx) ** 2 <= rad ** 2
    return ring


def recolour(a, walk=False):
    a = a.copy()
    alpha = a[..., 3] > 0
    ring = lantern_ring(a)
    rgb = a[..., :3]
    changed = 0
    for src, dst in (WALK_SWAP if walk else SWAP).items():
        sel = alpha & ~ring & np.all(rgb == src, axis=-1)
        rgb[sel] = dst
        changed += int(sel.sum())
    for c in CREAM:
        sel = alpha & ~ring & np.all(rgb == c, axis=-1)
        rgb[sel] = WALK_BODY if walk else BODY   # seen from behind there is no belly: cream outside the lantern is the tail
        changed += int(sel.sum())
    return a, changed


front_path, backup = Path(sys.argv[1]), Path(sys.argv[2])
front = np.array(Image.open(front_path).convert("RGBA"))
groups = None
backup.mkdir(parents=True, exist_ok=True)
for name in sys.argv[3:]:
    path = Path(name)
    keep = backup / path.name
    if not keep.exists():
        shutil.copy2(path, keep)
    a = np.array(Image.open(keep).convert("RGBA"))
    total = 0
    if path.name.endswith("_sheet.png"):
        ch, cw = a.shape[0] // 2, a.shape[1] // 4
        for r in range(2):
            for c in range(4):
                cell, n = recolour(a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw], True)
                a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw] = cell
                total += n
    else:
        a, total = recolour(a)
    Image.fromarray(a).save(path)
    print(path.name, "pixels recoloured:", total)
