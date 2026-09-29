"""Molten Glass pour frames built on the title-card (overload) pose.

Preston (2026-09-29): the lava should pour out of the mouth like the title card,
which shows the glowing mouth low in the collar with glass bulging and dripping.
The older pour frames pour from a higher opening with the head pulled in, so the
glass stream and pool are lifted out of each of them and laid under the overload
pose's mouth instead:
  - stream pixels: the glass colours at or below the overload mouth's row
  - shifted left so the stream falls from the overload mouth (x about 101)
  - pasted over the overload pose (the stream runs in front of the legs, as it
    does in the originals); the pool lands on the same foot line

Writes vitrecrag_lava_pour/overload_pour_a.png and overload_pour_b.png.
Run from the project root: python tools/build_vitrecrag_overload_pour.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour"
MOUTH_ROW = 88   # the overload mouth's lower edge; the stream starts here
SHIFT_X = -5     # the old stream falls about 5 px right of the overload mouth


def glass(a):
    """Molten glass colours: hot yellow through deep orange, not the rust straps."""
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (a[..., 3] > 0) & (r > 150) & (g > 50) & (b < 120) & (r - b > 110)


def main():
    overload = np.asarray(Image.open(BASE / "overload.png").convert("RGBA"))
    for name in ("pour_a", "pour_b"):
        src = np.asarray(Image.open(BASE / f"style_matched/{name}.png").convert("RGBA"))
        out = overload.copy()
        mask = glass(src)
        mask[:MOUTH_ROW] = False
        mask[:, :90] = False   # only the stream under the collar, not the window glow
        ys, xs = np.where(mask)
        for y, x in zip(ys, xs):
            tx = x + SHIFT_X
            if 0 <= tx < out.shape[1]:
                out[y, tx] = src[y, x]
        Image.fromarray(out, "RGBA").save(BASE / f"overload_{name}.png")
        print(f"overload_{name}: {len(ys)} stream pixels, x {xs.min()}-{xs.max()}, y {ys.min()}-{ys.max()}")


if __name__ == "__main__":
    main()
