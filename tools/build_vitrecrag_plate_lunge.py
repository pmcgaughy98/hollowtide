"""Build Vitrecrag's Plate Lunge frames from whole Opal poses (v2).

Preston's review of v1 (2026-09-28): only the head changed, the plate did not
read, and the retract left stray pixels. v2 uses the whole Opal frames, body,
legs, lean and plate together, so Vitrecrag actually moves. The sheets are read
on their true grid (about 3.67 px per block) so the frames match the in-game
sprite's size, then each frame is:
  - snapped to the in-game sprite's 24 colours,
  - cleared of stray crumbs (small groups touching nothing),
  - registered on the in-game 128x128 canvas: lowest pixel on the in-game foot
    line, rear edge on the in-game rear edge, so the planted rear foot stays put.

Frames come from frames_fullsize/ (cut with tools/cut_forge_frames.py --block 3.67).
Writes .../vitrecrag_plate_lunge/built/<name>.png.
Run from the project root: python tools/build_vitrecrag_plate_lunge.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "assets/sprites/creatures/attacks/vitrecrag_plate_lunge"
SRC = BASE / "frames_fullsize"
OUT = BASE / "built"
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"

# Output name -> source frame, in attack order (see README).
FRAMES = [
    ("load", "sheet4_f01"),       # slight forward lean
    ("brace", "sheet4_f02"),      # head drops, draws in (code adds draw-back and tremble)
    ("launch", "sheet4_f03"),     # plate half out, body going forward
    ("contact", "sheet4_f04"),    # plate fully out, body tipped in, rear raised
    ("recover", "sheet4_f05"),    # plate retracting
]
CRUMB = 12  # groups of this many pixels or fewer that touch nothing are removed


def palette_of(img):
    a = np.asarray(img)
    return np.array(sorted({tuple(p) for p in a[a[..., 3] > 0][:, :3]}))


def snap(a, palette):
    op = a[..., 3] > 0
    px = a[op][:, :3].astype(int)
    idx = ((px[:, None, :] - palette[None]) ** 2).sum(-1).argmin(1)
    out = a.copy()
    out[op, :3] = palette[idx]
    out[..., 3] = np.where(op, 255, 0)
    return out


def clear_crumbs(a):
    op = a[..., 3] > 0
    h, w = op.shape
    seen = np.zeros_like(op)
    groups = []
    for y in range(h):
        for x in range(w):
            if op[y, x] and not seen[y, x]:
                stack, g = [(y, x)], []
                seen[y, x] = True
                while stack:
                    cy, cx = stack.pop()
                    g.append((cy, cx))
                    for ny in (cy - 1, cy, cy + 1):
                        for nx in (cx - 1, cx, cx + 1):
                            if 0 <= ny < h and 0 <= nx < w and op[ny, nx] and not seen[ny, nx]:
                                seen[ny, nx] = True
                                stack.append((ny, nx))
                groups.append(g)
    biggest = max(len(g) for g in groups)
    out = a.copy()
    for g in groups:
        if len(g) <= CRUMB and len(g) < biggest:
            for y, x in g:
                out[y, x] = 0
    return out


def register(a, foot_y, rear_x):
    ys, xs = np.where(a[..., 3] > 0)
    dx, dy = rear_x - xs.min(), foot_y - ys.max()
    canvas = np.zeros((128, 128, 4), np.uint8)
    for y, x in zip(ys, xs):
        ty, tx = y + dy, x + dx
        if 0 <= ty < 128 and 0 <= tx < 128:
            canvas[ty, tx] = a[y, x]
    return canvas


def main():
    official = Image.open(OFFICIAL).convert("RGBA")
    palette = palette_of(official)
    oa = np.asarray(official)
    oys, oxs = np.where(oa[..., 3] > 0)
    foot_y, rear_x = oys.max(), oxs.min()
    OUT.mkdir(exist_ok=True)
    for old in ("head_down", "plate_half", "plate_full"):
        (OUT / f"{old}.png").unlink(missing_ok=True)  # v1 frames, superseded
    built = []
    for name, src in FRAMES:
        a = np.asarray(Image.open(SRC / f"{src}.png").convert("RGBA")).copy()
        a = clear_crumbs(snap(a, palette))
        img = Image.fromarray(register(a, foot_y, rear_x), "RGBA")
        img.save(OUT / f"{name}.png")
        built.append((name, img))
        print(name, "<-", src)
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 3
        tiles = [("in-game", official)] + built + [("in-game", official)]
        ps = []
        for _, t in tiles:
            bg = Image.new("RGBA", t.size, (40, 60, 70, 255))
            bg.alpha_composite(t)
            ps.append(bg.crop((0, 20, 128, 128)).resize((128 * Z, 108 * Z), Image.NEAREST))
        sheet = Image.new("RGBA", (sum(p.width + 6 for p in ps), ps[0].height), (0, 0, 0, 255))
        x = 0
        for p in ps:
            sheet.paste(p, (x, 0))
            x += p.width + 6
        sheet.save(dest)


if __name__ == "__main__":
    main()
