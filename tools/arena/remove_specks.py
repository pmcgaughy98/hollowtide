"""Remove detached specks from a creature's sprites (Claude, 2026-10-09, Preston: "the little
circle dots of dust on Dustkite's line need removing... it generated with it like an effect of
dust around it, but we don't need it"). Recolours stray magenta, strips light outline-less dust clinging to the
body, then keeps every island of pixels at least KEEP of the largest island in its frame; a walk sheet is treated cell by cell (4 x 2 cells).
Originals are copied once to docs/creatures/speck-backup-2026-10-09/<name>/.
  python tools/arena/remove_specks.py <name> [name ...]
Then rebuild the small set: python tools/arena/build_small.py <name>
"""
import shutil, sys
from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image

KEEP = 0.15
ART = Path("assets/sprites/arena")
WALK = Path("docs/creatures/arena-starters-2026-10-07/walk")
BACKUP = Path("docs/creatures/speck-backup-2026-10-09")


def clean(a: np.ndarray) -> int:
    op = a[..., 3] > 0
    h, w = op.shape
    label = np.zeros((h, w), dtype=np.int32)
    sizes = [0]
    for y in range(h):
        for x in range(w):
            if op[y, x] and label[y, x] == 0:
                lab = len(sizes)
                q = deque([(y, x)])
                label[y, x] = lab
                n = 0
                while q:
                    cy, cx = q.popleft()
                    n += 1
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < h and 0 <= nx < w and op[ny, nx] and label[ny, nx] == 0:
                                label[ny, nx] = lab
                                q.append((ny, nx))
                sizes.append(n)
    if len(sizes) <= 2:
        return 0
    big = max(sizes)
    removed = 0
    for lab in range(1, len(sizes)):
        if sizes[lab] < big * KEEP:
            a[label == lab, 3] = 0
            removed += sizes[lab]
    return removed


DUST_MAX = 0.06    # a light patch with no outline is dust only if it is this small next to the body


def strip_dust(a: np.ndarray) -> int:
    """Light patches whose edge is mostly bare background rather than dark outline: the dust
    curls that cling to the toes. Dust shares the body's palette, so the test is shape: a leg or
    throat with a gap in its outline still borders mostly outline, a dust curl borders mostly
    nothing. The size cap guards the rest."""
    alpha = a[..., 3] > 0
    rgb = a[..., :3].astype(int)
    light = alpha & (rgb.min(axis=2) > 110)
    dark = alpha & (rgb.max(axis=2) < 70)
    h, w = light.shape
    body = int(alpha.sum())
    seen = np.zeros_like(light)
    removed = 0
    for y in range(h):
        for x in range(w):
            if not light[y, x] or seen[y, x]:
                continue
            q = deque([(y, x)])
            seen[y, x] = True
            region = []
            bare = 0
            lined = 0
            while q:
                cy, cx = q.popleft()
                region.append((cy, cx))
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ny, nx = cy + dy, cx + dx
                    if not (0 <= ny < h and 0 <= nx < w) or not alpha[ny, nx]:
                        bare += 1
                        continue
                    if dark[ny, nx]:
                        lined += 1
                    if light[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
            if bare > 2 * lined and len(region) <= body * DUST_MAX:
                for cy, cx in region:
                    a[cy, cx, 3] = 0
                removed += len(region)
    return removed


def fix_magenta(a: np.ndarray) -> int:
    """Stray magenta left from the generator's background, recoloured to the body's dark shadow."""
    rgb = a[..., :3].astype(int)
    pink = (a[..., 3] > 0) & (rgb[..., 0] > 140) & (rgb[..., 2] > 110) & (rgb[..., 1] < 100)
    a[pink, 0] = 58
    a[pink, 1] = 52
    a[pink, 2] = 62
    return int(pink.sum())


def do_file(path: Path, cells: tuple, name: str) -> int:
    dest = BACKUP / name / path.name
    dest.parent.mkdir(parents=True, exist_ok=True)
    if not dest.exists():
        shutil.copy2(path, dest)
    a = np.array(Image.open(dest).convert("RGBA"))   # always clean from the original
    cols, rows = cells
    ch, cw = a.shape[0] // rows, a.shape[1] // cols
    removed = 0
    for r in range(rows):
        for c in range(cols):
            cell = a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw]
            removed += fix_magenta(cell)
            removed += strip_dust(cell)
            removed += clean(cell)   # dust stripped off a toe can leave a detached speck
    Image.fromarray(a).save(path)
    return removed


for name in sys.argv[1:]:
    total = 0
    for f in sorted((ART / name).glob("*.png")):
        total += do_file(f, (1, 1), name)
    for f in sorted(WALK.glob(f"{name}_*_sheet.png")):
        total += do_file(f, (4, 2), name)
    print(name, "pixels of specks removed:", total)
