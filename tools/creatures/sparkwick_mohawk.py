"""Give the big Sparkwick idle the mohawk its game sprites have (Claude, 2026-10-10; Preston: "fix the
mohawk for the big sprite that shows up for sparkwick when it evolves or idle animation", then chose
option 1, a hand-drawn crest).

One crest is drawn by hand in code, pixel by pixel, in Sparkwick's own colours: five spikes swept back
toward the tail, rooted along the top of the skull. It is laid *behind* each idle frame, so the head's
own outline covers the spike bases, and moved with the head's small breathing shift, which is measured
frame by frame against frame 0. Nothing is generated.
  python tools/creatures/sparkwick_mohawk.py     originals kept in docs/creatures/sparkwick-mohawk-2026-10-10/before/
"""
import shutil
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

SRC = Path("assets/sprites/creatures/idle_2026_10_10/sparkwick_palette_locked")
BACKUP = Path("docs/creatures/sparkwick-mohawk-2026-10-10/before")
INK = (17, 8, 5, 255)
BODY = (206, 157, 92, 255)
LIGHT = (238, 165, 66, 255)
PALE = (230, 216, 165, 255)
SHADE = (156, 98, 57, 255)
# (root x, root y, height, lean back): read off frame 0's head on a grid. The middle spikes stand tallest.
SPIKES = [(149, 54, 11, 6), (156, 52, 15, 7), (163, 51, 18, 8), (170, 52, 15, 7), (177, 54, 10, 5)]
HEAD = (138, 40, 196, 92)   # the region used to follow the head between frames


def crest(size) -> Image.Image:
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    mask = Image.new("L", size, 0)
    md = ImageDraw.Draw(mask)
    fill = Image.new("RGBA", size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fill)
    for rx, ry, h, lean in SPIKES:
        tip = (rx - lean, ry - h)
        poly = [(rx - 4, ry + 5), tip, (rx + 4, ry + 5)]
        md.polygon(poly, fill=255)
        fd.polygon(poly, fill=BODY)
        # A lit leading edge and a shaded trailing edge, like the spikes along its back.
        fd.line([(rx - 3, ry + 4), (tip[0] + 1, tip[1] + 2)], fill=LIGHT, width=1)
        fd.line([(rx + 3, ry + 4), (tip[0] + 2, tip[1] + 3)], fill=SHADE, width=1)
        fd.point([(tip[0] + 1, tip[1] + 1)], fill=PALE)
    m = np.array(mask) > 0
    a = np.array(fill)
    # The outline: every empty pixel touching the crest goes ink.
    edge = np.zeros_like(m)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        edge |= np.roll(np.roll(m, dy, 0), dx, 1)
    edge &= ~m
    a[edge] = INK
    return Image.fromarray(a)


def offset(f0: np.ndarray, fk: np.ndarray) -> tuple:
    x0, y0, x1, y1 = HEAD
    ref = f0[y0:y1, x0:x1, 3] > 25
    best, at = -1, (0, 0)
    for dy in range(-4, 5):
        for dx in range(-4, 5):
            win = fk[y0 + dy:y1 + dy, x0 + dx:x1 + dx, 3] > 25
            score = int((win & ref).sum())
            if score > best:
                best, at = score, (dx, dy)
    return at


if __name__ == "__main__":
    BACKUP.mkdir(parents=True, exist_ok=True)
    frames = sorted(SRC.glob("f*.png"))
    for f in frames:
        if not (BACKUP / f.name).exists():
            shutil.copy(f, BACKUP / f.name)
    f0 = np.array(Image.open(BACKUP / "f0.png").convert("RGBA"))
    layer = crest((f0.shape[1], f0.shape[0]))
    for f in frames:
        orig = Image.open(BACKUP / f.name).convert("RGBA")
        dx, dy = offset(f0, np.array(orig))
        out = Image.new("RGBA", orig.size, (0, 0, 0, 0))
        out.alpha_composite(layer, (dx, dy))
        out.alpha_composite(orig)   # the head in front: its outline covers the spike roots
        out.save(f)
        print(f.name, "head shift", (dx, dy))
