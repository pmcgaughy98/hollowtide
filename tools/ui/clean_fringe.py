"""Clean the white and yellow fringe off expression faces (Claude, 2026-10-10; Preston: "lots of yellow and
white fringe on the portraits"). The edits sometimes lighten the dark outline, and the background clear then
leaves pale specks along it. Each face is compared with the creature's plain portrait:
  - on the plain portrait's outline, a face pixel that is pale or yellow where the plain one is dark gets
    the plain outline pixel back;
  - just outside the plain silhouette, a pale or yellow pixel that touches transparency is cleared;
  - a pale halo left on the face's own edge (Warden, Rimefin: a grey-teal ring the yellow/white test
    missed) is turned into the outline colour beside it, where the plain portrait has outline or nothing.
Rule 1 only acts on the face's own edge too: a face drawn at a tilt (Mirekit joyous) had the plain snout
outline painted across its middle (Preston, 2026-10-10: "black line drawn down from its left eye").
Always run from the originals: it copies them from BACKUP first, so a rerun starts clean.
Real white fur (Mirekit, Starward) and an open jaw past the outline are left alone: the first rule only acts
where the plain portrait is dark, the second only on light specks at the very edge.
  python tools/ui/clean_fringe.py [form ...]      every face of those forms (default: all with faces)
"""
import glob, os, shutil, sys
import numpy as np
from PIL import Image

DIR = "assets/sprites/ui/dialogue/"
BACKUP = "docs/ui/expressions-2026-10-10/before_fringe/"
# Forms whose faces keep the plain portrait's body shape (rd_expressions.py BASE_SHAPE). Their outline is the
# plain one everywhere but an open mouth, so it is put back wherever the face went pale, whether or not it is
# the face's own edge (Preston, 2026-10-10: "fringe in Starward's portraits... during the scene").
SAME_SHAPE = {"starward"}


def light(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    pale = rgb.min(2) > 185
    yellow = (r > 185) & (g > 150) & (b < 150)
    return pale | yellow


def luma(rgb):
    return rgb[..., 0] * 0.3 + rgb[..., 1] * 0.59 + rgb[..., 2] * 0.11


def blobs(m):
    # 8-connected pieces of a mask, as lists of (y, x).
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
                    if 0 <= ny < m.shape[0] and 0 <= nx < m.shape[1] and m[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
        out.append(pts)
    return out


def edge(m):
    # Pixels touching transparency. Outside the image counts as solid: the crop border is not an outline.
    p = np.pad(m, 1, constant_values=True)
    return m & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])


def clean(form: str) -> int:
    base = np.array(Image.open(DIR + form + ".png").convert("RGBA")).astype(int)
    bm = base[..., 3] > 0
    ring = edge(bm)                                        # the plain portrait's outline pixels
    bl = luma(base[..., :3])
    changed = 0
    for f in sorted(glob.glob(DIR + form + "_*.png")):
        keep = BACKUP + os.path.basename(f)
        if os.path.exists(keep):
            shutil.copy2(keep, f)
        a = np.array(Image.open(f).convert("RGBA")).astype(int)
        m = a[..., 3] > 0
        lt = light(a[..., :3])
        own = edge(m)                                      # the face's own outline pixels
        # 1. Outline pixels turned pale: restore the dark outline.
        fix = ring & own & lt & (bl < luma(a[..., :3]) - 60)
        if form in SAME_SHAPE:
            # Past the plain outline, a shape of 8 pixels or more with a dark pixel in it is an open mouth (kept, with the outline
            # within 2 pixels of it); pale pieces are fringe and go.
            mouth = np.zeros_like(m)
            stray = np.zeros_like(m)
            for c in blobs(~bm & m):
                dark = min(luma(a[y, x, :3]) for y, x in c) < 120
                (mouth if len(c) >= 8 and dark else stray)[tuple(np.array(c).T)] = True
            near = mouth.copy()
            for _ in range(2):
                near = near | np.roll(near, 1, 0) | np.roll(near, -1, 0) | np.roll(near, 1, 1) | np.roll(near, -1, 1)
            fl = luma(a[..., :3])
            fix = ring & m & ~near & (fl > 110) & (bl < fl - 30)   # the lighter, broken outline the edits left
            a[fix] = base[fix]
            a[stray] = 0
        a[fix] = base[fix]
        # 2. Pale specks hanging just outside the silhouette, touching the clear background.
        out = ~bm & m & lt
        touch = ~(np.roll(m, 1, 0) & np.roll(m, -1, 0) & np.roll(m, 1, 1) & np.roll(m, -1, 1))
        drop = out & touch
        a[drop] = 0
        # 3. A pale halo on the face's edge where the plain portrait is outline or empty: darken it to the
        #    darkest colour among its solid neighbours, so the outline stays closed in its own hue.
        m = a[..., 3] > 0
        own = edge(m)
        fl = luma(a[..., :3])
        halo = own & (fl > 110) & (~bm | (bl < fl - 40))
        halo_n = 0
        for y, x in zip(*np.nonzero(halo)):
            best = None
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = y + dy, x + dx
                    if (dy or dx) and 0 <= ny < m.shape[0] and 0 <= nx < m.shape[1] and m[ny, nx] and fl[ny, nx] < 80:
                        if best is None or fl[ny, nx] < fl[best]:
                            best = (ny, nx)
            if best is not None:
                a[y, x] = a[best]
                halo_n += 1
        n = int(fix.sum() + drop.sum()) + halo_n
        Image.fromarray(a.astype(np.uint8)).save(f)
        if n:
            changed += n
            print(os.path.basename(f), "outline restored", int(fix.sum()), "specks cleared", int(drop.sum()), "halo darkened", halo_n)
    return changed


if __name__ == "__main__":
    forms = sys.argv[1:] or sorted({os.path.basename(f).split("_")[0] for f in glob.glob(DIR + "*_*.png")})
    total = sum(clean(f) for f in forms if os.path.exists(DIR + f + ".png"))
    print("pixels fixed", total)
