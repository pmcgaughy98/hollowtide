"""A solid dark outline round a creature's dialogue portraits (Claude, 2026-10-10; Preston: "do black outline
pass for Starward and its portraits"). Every pixel on the portrait's outer edge (touching transparency, not
the crop's border) that is lighter than the creature's own line colour becomes that colour, the same rule
tools/arena/selout.py --black uses on its sprites, so portrait and sprite match.
  python tools/ui/outline_portrait.py starward [form ...]
Run it after tools/ui/clean_fringe.py, which rebuilds the faces from their originals. Each file is kept
once, before its first outline, in docs/ui/expressions-2026-10-10/before_outline/.
"""
import glob, os, shutil, sys
import numpy as np
from PIL import Image

DIR = "assets/sprites/ui/dialogue/"
BACK = "docs/ui/expressions-2026-10-10/before_outline/"
def line_colour(form: str):
    # The line's own outline colour: the darkest pixel on its full-size still's edge, as selout.py takes it.
    s = np.array(Image.open(f"assets/sprites/arena/{form}/s.png").convert("RGBA")).astype(int)
    m = s[..., 3] > 0
    px = s[m][:, :3]
    return tuple(int(v) for v in px[np.argmin(luma(px))])


def luma(rgb):
    return rgb[..., 0] * 0.3 + rgb[..., 1] * 0.59 + rgb[..., 2] * 0.11


def outline(path: str, col) -> int:
    os.makedirs(BACK, exist_ok=True)
    keep = BACK + os.path.basename(path)
    if not os.path.exists(keep):
        shutil.copy2(path, keep)
    a = np.array(Image.open(path).convert("RGBA")).astype(int)
    m = a[..., 3] > 0
    p = np.pad(m, 1, constant_values=True)   # the crop's border is not an edge
    edge = m & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
    go = edge & (luma(a[..., :3]) > luma(np.array(col, float)) + 12)
    a[go, :3] = col
    a[go, 3] = 255
    Image.fromarray(a.astype(np.uint8)).save(path)
    return int(go.sum())


if __name__ == "__main__":
    for form in sys.argv[1:]:
        col = line_colour(form)
        print(form, "line colour", col)
        for f in sorted(glob.glob(DIR + form + ".png") + glob.glob(DIR + form + "_*.png")):
            print("  ", os.path.basename(f), "outlined", outline(f, col))
