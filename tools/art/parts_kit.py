"""Legacy's way, for Hollowtide: variety from hand-made parts and palettes, not a renderer (Claude, 2026-10-13).

Zoids Legacy's decompilation (structure only) loads one hand-drawn body per Zoid with a palette variant and puts
equipment on as separate sprites at per-body anchor points. Every pixel here is already ours; this only recolours
and recombines.

  variant <views_dir> <out_dir> <scheme>     a palette variant: each colour family moves to a new hue, every pixel
                                            keeps its own lightness, the outline stays; the same rule on every view
                                            (and on every stage, so a line changes together)
  plant <recipient_dir> <donor_dir> <out_dir> [--family flanges]
                                            cut what sticks up above the donor's back line in each view (spikes, fins,
                                            horns, optionally one colour family only) and plant it on the recipient's
                                            top outline at the same place along the body, in the same view
  families <view.png>                       the view's colour families and their sizes, to choose what to cut

    python tools/art/parts_kit.py variant docs/design/new-creature-ballastak-2026-10-13/views_128 out/ballastak_clay clay
"""
import colorsys
import os
import sys
from collections import deque
import numpy as np
from PIL import Image

DIRS = ["e", "ne", "n", "nw", "w", "sw", "s", "se"]

# Schemes: (hue band in degrees, saturation floor) -> (new hue, saturation multiplier). Proposals for Preston.
SCHEMES = {
    "clay": [((15, 60), 0.10, 8, 1.35), ((180, 250), 0.08, 168, 1.1)],    # tan hide -> river-clay red, slate -> verdigris
    "moss": [((15, 60), 0.10, 88, 0.9), ((180, 250), 0.08, 28, 1.2)],     # tan hide -> moss, slate -> rusted bronze
    "night": [((15, 60), 0.10, 230, 0.55), ((180, 250), 0.08, 275, 1.3)], # tan hide -> blue-grey dusk, slate -> violet
}
FAMILIES = {"flanges": lambda h, s, v: s < 0.16 and 0.18 < v < 0.62}      # dark iron grey back spikes


def rgba(path):
    return np.array(Image.open(path).convert("RGBA"))


def outline_colour(a):
    m = a[..., 3] > 0
    pad = np.pad(m, 1)
    edge = m & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    cols, n = np.unique(a[edge][:, :3], axis=0, return_counts=True)
    return cols[n.argmax()]


def variant(src, out, scheme):
    rules = SCHEMES[scheme]
    os.makedirs(out, exist_ok=True)
    for d in DIRS:
        p = os.path.join(src, d + ".png")
        if not os.path.exists(p):
            continue
        a = rgba(p)
        line = outline_colour(a)
        cache = {}
        H, W, _ = a.shape
        for y in range(H):
            for x in range(W):
                if a[y, x, 3] == 0 or (a[y, x, :3] == line).all():
                    continue
                k = tuple(a[y, x, :3])
                if k not in cache:
                    r, g, b = (c / 255 for c in k)
                    h, l, s = colorsys.rgb_to_hls(r, g, b)
                    new = k
                    for (lo, hi), smin, to, mul in rules:
                        if lo / 360 <= h <= hi / 360 and s >= smin:
                            nr, ng, nb = colorsys.hls_to_rgb(to / 360, l, min(1.0, s * mul))
                            new = (round(nr * 255), round(ng * 255), round(nb * 255))
                            break
                    cache[k] = new
                a[y, x, :3] = cache[k]
        Image.fromarray(a).save(os.path.join(out, d + ".png"))
    print("variant '%s' written to %s" % (scheme, out))


def components(mask):
    H, W = mask.shape
    lab = np.full((H, W), -1)
    out = []
    for y in range(H):
        for x in range(W):
            if mask[y, x] and lab[y, x] < 0:
                k = len(out)
                q = deque([(y, x)])
                lab[y, x] = k
                pts = []
                while q:
                    cy, cx = q.popleft()
                    pts.append((cy, cx))
                    for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                        if 0 <= ny < H and 0 <= nx < W and mask[ny, nx] and lab[ny, nx] < 0:
                            lab[ny, nx] = k
                            q.append((ny, nx))
                out.append(pts)
    return out


def pieces(a, family=None, window=21, min_h=3):
    """The donor's crest pieces: whatever sticks up above its back line, each as a small sprite with its own outline.
    The back line is a deep percentile of the top edge over a wide window, so narrow spikes, fins and horns stand
    above it while the body's own slopes follow it; only solid pieces on the upper half count (not outline arcs). family, when given, keeps only pieces
    that are mostly that colour family."""
    m = a[..., 3] > 0
    ys, xs = np.where(m)
    H, W = m.shape
    top = np.full(W, H)
    for x in range(xs.min(), xs.max() + 1):
        col = np.where(m[:, x])[0]
        if len(col):
            top[x] = col.min()
    back = np.array([np.percentile(top[max(0, x - window // 2):x + window // 2 + 1], 80) for x in range(W)]).astype(int)
    span = ys.max() - ys.min()
    crest = np.zeros_like(m)
    for x in range(W):
        if top[x] < H:
            crest[top[x]:max(top[x], back[x] - 1), x] = True
    crest &= m
    test = FAMILIES.get(family) if family else None
    out = []
    for pts in components(crest):
        py = [p[0] for p in pts]
        px = [p[1] for p in pts]
        h, w = max(py) - min(py) + 1, max(px) - min(px) + 1
        if h < min_h or w < 3 or len(pts) < 0.35 * h * w or max(py) > ys.min() + 0.5 * span:
            continue
        if test:
            hits = sum(test(*colorsys.rgb_to_hsv(*(c / 255 for c in a[y, x, :3]))) for y, x in pts)
            if hits < 0.5 * len(pts):
                continue
        y0, y1, x0, x1 = min(py), max(py) + 2, min(px), max(px)
        piece = np.zeros((y1 - y0 + 1, x1 - x0 + 1, 4), np.uint8)
        for y, x in pts:
            piece[y - y0, x - x0] = a[y, x]
        # two rows of the donor's body under the crest, so the piece roots into the recipient's outline
        for x in range(x0, x1 + 1):
            for y in (back[x] - 1, back[x]):
                if y0 <= y <= y1 and m[y, x]:
                    piece[y - y0, x - x0] = a[y, x]
        out.append({"img": piece, "x": (x0 + x1) / 2, "w": x1 - x0 + 1})
    return out, (xs.min(), xs.max())


def plant(rdir, ddir, out, family):
    os.makedirs(out, exist_ok=True)
    for d in DIRS:
        rp, dp = os.path.join(rdir, d + ".png"), os.path.join(ddir, d + ".png")
        if not (os.path.exists(rp) and os.path.exists(dp)):
            continue
        r = rgba(rp)
        donor = rgba(dp)
        ps, (dx0, dx1) = pieces(donor, family)
        rm = r[..., 3] > 0
        rys, rxs = np.where(rm)
        rx0, rx1 = rxs.min(), rxs.max()
        canvas = Image.fromarray(r)
        placed = 0
        for p in sorted(ps, key=lambda q: q["x"]):
            # the same relative position across the body, standing on the recipient's top outline at that column
            fx = (p["x"] - dx0) / max(1, dx1 - dx0)
            cx = int(round(rx0 + fx * (rx1 - rx0)))
            col = np.where(rm[:, cx])[0] if 0 <= cx < rm.shape[1] else []
            if len(col) == 0:
                continue
            ty = col.min()
            img = Image.fromarray(p["img"])
            canvas.alpha_composite(img, (int(round(cx - img.width / 2)), int(ty - img.height + 3)))
            placed += 1
        canvas.save(os.path.join(out, d + ".png"))
        print("%s: %d crest pieces planted" % (d, placed))


def families(path):
    a = rgba(path)
    m = a[..., 3] > 0
    bins = {}
    for c in a[m][:, :3].tolist():
        h, s, v = colorsys.rgb_to_hsv(*(x / 255 for x in c))
        key = ("grey" if s < 0.16 else "hue %03d" % (int(h * 360) // 30 * 30)) + (" dark" if v < 0.35 else (" mid" if v < 0.7 else " light"))
        bins[key] = bins.get(key, 0) + 1
    for k, n in sorted(bins.items(), key=lambda t: -t[1]):
        print("  %-16s %5d px" % (k, n))


def main():
    cmd = sys.argv[1]
    if cmd == "variant":
        variant(sys.argv[2], sys.argv[3], sys.argv[4])
    elif cmd == "plant":
        fam = sys.argv[sys.argv.index("--family") + 1] if "--family" in sys.argv else None
        plant(sys.argv[2], sys.argv[3], sys.argv[4], fam)
    elif cmd == "families":
        families(sys.argv[2])


if __name__ == "__main__":
    main()
