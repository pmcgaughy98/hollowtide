"""Strip the white background a Retro Diffusion take sometimes keeps (Claude, 2026-10-10).
  python tools/arena/strip_take_bg.py <take.png> [...]
Keeps the original as <take>_raw.png. Clears near-white pixels joined to the border (the background),
then any enclosed near-white patch of 6 or more pixels (background seen through a gap, like the space
under Troughspine's rib arches); smaller white specks stay, since they are eye shines and highlights."""
import sys
from pathlib import Path
import numpy as np
from PIL import Image
from collections import deque


def label(mask):
    lab = np.zeros(mask.shape, int)
    n = 0
    h, w = mask.shape
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not lab[y, x]:
                n += 1
                q = deque([(y, x)])
                lab[y, x] = n
                while q:
                    cy, cx = q.popleft()
                    for ny, nx in ((cy + 1, cx), (cy - 1, cx), (cy, cx + 1), (cy, cx - 1)):
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not lab[ny, nx]:
                            lab[ny, nx] = n
                            q.append((ny, nx))
    return lab, n

for f in sys.argv[1:]:
    p = Path(f)
    raw = p.with_name(p.stem + "_raw.png")
    src = raw if raw.exists() else p
    a = np.array(Image.open(src).convert("RGBA"))
    if not raw.exists():
        Image.fromarray(a).save(raw)
    rgb = a[..., :3].astype(int)
    white = (rgb.min(2) > 225) & (rgb.max(2) - rgb.min(2) < 18) & (a[..., 3] > 0)
    lab, n = label(white)
    edge = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    sizes = [int((lab == k).sum()) for k in range(1, n + 1)]
    clear = np.zeros_like(white)
    for k in range(1, n + 1):
        if k in edge or sizes[k - 1] >= 6:
            clear |= lab == k
    a[clear, 3] = 0
    Image.fromarray(a).save(p)
    print(p.name, "cleared", int(clear.sum()), "px; left", int((a[..., 3] > 0).sum()))
