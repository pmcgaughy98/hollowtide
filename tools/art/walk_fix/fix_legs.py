"""Rebuild the north (up) and south (down) walk legs of the courier atlas from RD's stride (Claude, 2026-10-26).

Fix lane 5 of the PixelLab walk repair. PixelLab's up row is two poses held 4 frames each, and its down row is a
2 px shuffle with one arm frozen. This keeps PixelLab's upper body (head, jacket, hands, bag) and gives it the
lower body of our own RD walk, the way a pixel artist would paste a known-good stride under a new torso:

  1. find the hip line in every frame (the first trouser row under the belt, or under the jacket hem from behind)
     and the leg box under it, in the input and in RD
  2. lift RD's legs out of each RD frame (trouser, boot and outline pixels from the hip line down; hands, jacket,
     bag and their outlines stay behind)
  3. recolour them to the input's own trouser and boot colours: per zone (boot = the lowest 8 rows of each column,
     trouser = the rest), RD's colours map to the input's colours of the same zone by luminance rank (histogram
     matching), so only colours the input already uses come out
  4. fit them: one integer x shift per row puts RD's median leg centre on the input's; feet keep RD's rows over
     the input's ground; RD's legs get rows duplicated (or dropped) at the thigh so they reach the input's median hip
  5. erase the input's own legs, paste the fitted RD legs, then put the input's upper body back on top, shifted by
     RD's hip movement in that frame (so the body bobs with the stride; --no-bob keeps it still)
  6. arms (on by default, --no-arms turns it off), two modes picked by measuring the input's own arms:
     - re-time: if the input's hands already swing 6 rows or more over the cycle (PixelLab's up row), the input
       frames under each new leg pose are rotated by k frames, k chosen so the input's arm phase best matches RD's
       left-minus-right hand timing (the arms then swing against the new legs); the report says which k
     - hand move: otherwise (the down row, one arm frozen) each hand moves 1 px with RD's hand timing for that side
       (down when RD shows the hand, up when RD hides it), opposite to the legs; the sleeve cuff stretches to follow
  7. close holes the swap opened inside the silhouette and give any new edge pixel the dark outline

Everything is integer: copied pixels, whole-pixel shifts, duplicated rows. No resampling, no blur, alpha 0 or 255.

    python tools/art/walk_fix/fix_legs.py IN_ATLAS OUT_ATLAS [--report report.json] [--no-bob] [--no-arms]

IN_ATLAS is any 640x640 atlas in the RD walk layout (rows down, down_left, left, up_left, up, up_right, right,
down_right; 80 px cells; feet on y=72). Only the down and up rows change. It depends on colour classes, not exact
colours: trousers are a khaki hue (22 to 42 degrees, saturation over 0.3, value 0.33 to 0.74), the jacket teal
(160 to 215 degrees), skin warm and bright (value 0.74 and up). A palette fix that keeps those families is safe to
run first. A fix that already moved the upper body (a bob) is replaced by this one's bob on these two rows.
"""
import argparse
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

HT = Path(__file__).resolve().parents[3]
RD_PATH = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
CELL = 80
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
FIX_ROWS = ("down", "up")
BOOT_H = 8          # rows above a column's lowest leg pixel that count as boot
THIGH_K = 3         # RD rows below the hip line where rows are duplicated or dropped to fit leg length
HIP_MARGIN = 1      # RD rows above its hip line taken along, hidden under the input's belt, so no gap can open


# ------------------------------------------------------------------ colour classes
def hsv(a):
    c = a[..., :3].astype(float) / 255.0
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    mx, mn = c.max(-1), c.min(-1)
    d = mx - mn
    h = np.zeros_like(mx)
    m = d > 0
    rr = m & (mx == r)
    gg = m & (mx == g) & ~rr
    bb = m & ~rr & ~gg
    h[rr] = (60 * ((g - b)[rr] / d[rr])) % 360
    h[gg] = 60 * ((b - r)[gg] / d[gg]) + 120
    h[bb] = 60 * ((r - g)[bb] / d[bb]) + 240
    s = np.where(mx > 0, d / np.where(mx > 0, mx, 1), 0)
    return h, s, mx


def materials(c):
    h, s, v = hsv(c)
    op = c[..., 3] > 0
    teal = op & (h >= 160) & (h <= 215) & (s > 0.3) & (v > 0.12)
    skin = op & (h >= 10) & (h <= 45) & (s > 0.15) & (s < 0.78) & (v >= 0.74)
    khaki = op & (h >= 22) & (h <= 42) & (s > 0.3) & (v >= 0.33) & (v < 0.74)
    olive = op & ~skin & (h > 42) & (h <= 75) & (s > 0.3) & (v >= 0.2)
    dark = op & ~teal & ~skin & ~olive & (v < 0.33)
    return op, teal, skin, khaki, dark, olive


def lum(rgb):
    rgb = np.asarray(rgb, float)
    return 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]


def dilate4(m):
    p = np.pad(m, 1)
    return m | p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]


# ------------------------------------------------------------------ geometry
def find_hip(c):
    """First trouser row under the belt (front) or under the jacket hem, its shadow or a bag (back).

    Scans up from the shin: starts where the centre band (7 columns) is trouser, and stops under the first row in
    which 70% of the pixels within 9 columns of the centre are dark, jacket or bag (a belt, a hem shadow, a bag's
    bottom edge), or 3 of the band's 7 are jacket. One leg in shadow covers only half the width, so it does not stop.
    """
    op, teal, skin, khaki, dark, olive = materials(c)
    ys, xs = np.nonzero(op)
    foot = int(ys.max())
    xc = int((xs.min() + xs.max()) // 2)
    band = slice(xc - 3, xc + 4)
    wide = slice(xc - 9, xc + 10)
    y = foot - 12
    while y > 30 and khaki[y, band].sum() < 4:
        y -= 1
    while y > 30:
        a = y - 1
        n = op[a, wide].sum()
        hard = (dark[a, wide] | teal[a, wide] | olive[a, wide]).sum()
        if (n and hard / float(n) >= 0.7) or teal[a, band].sum() >= 3:
            break
        y = a
    return y, xc, foot


def runs(row):
    xs = np.nonzero(row)[0]
    out = []
    if len(xs) == 0:
        return out
    s = p = xs[0]
    for x in xs[1:]:
        if x != p + 1:
            out.append((int(s), int(p)))
            s = x
        p = x
    out.append((int(s), int(p)))
    return out


def leg_box(c, hip, xc):
    """Leg extent at the thighs: the opaque runs that cross the centre band, rows hip+5 to hip+8 (median)."""
    op = c[..., 3] > 0
    x0s, x1s = [], []
    for y in range(hip + 5, hip + 9):
        rr = [r for r in runs(op[y]) if r[1] >= xc - 3 and r[0] <= xc + 3]
        if rr:
            x0s.append(min(r[0] for r in rr))
            x1s.append(max(r[1] for r in rr))
    return int(np.median(x0s)), int(np.median(x1s))


def leg_mask(c, hip, box, margin=0):
    """Pixels that belong to the legs: from the hip line down, not jacket or skin, connected to the feet.

    In the 8 rows under the hip, only the leg box (plus 1) counts, so hands, flaps and the bag that hang there stay
    out. Dark pixels touching skin or jacket are those parts' outlines and stay out too.
    """
    op, teal, skin, khaki, dark, olive = materials(c)
    rows = np.arange(CELL)[:, None]
    hipzone = (rows >= hip) & (rows < hip + 8)
    # skin in the hip zone is a hand; lower down it is a bare ankle or a sole, which belongs to the leg
    mat = op & ~teal & ~olive & ~(skin & (rows < hip + 8))
    m = np.zeros_like(op)
    top = hip - margin
    m[top:] = mat[top:]
    b0, b1 = box
    for y in range(top, hip + 8):
        m[y, :max(0, b0 - 1)] = False
        m[y, b1 + 2:] = False
    m &= ~(dark & dilate4((skin & hipzone) | teal | olive) & (rows >= hip) & (rows < hip + 8))
    # keep what connects (4-neighbour) to the lowest rows of the figure
    ys, xs = np.nonzero(m)
    if len(ys) == 0:
        return m
    low = ys.max()
    seen = np.zeros_like(m)
    q = deque()
    for y, x in zip(ys, xs):
        if y >= low - 2:
            seen[y, x] = True
            q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < CELL and 0 <= nx < CELL and m[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                q.append((ny, nx))
    return seen


def geometry(c, margin=0, hip=None):
    found, xc, foot = find_hip(c)
    hip = found if hip is None else hip
    box = leg_box(c, hip, xc)
    mask = leg_mask(c, hip, box, margin)
    mid = (box[0] + box[1]) / 2.0
    left = mask & (np.arange(CELL)[None, :] <= mid)
    right = mask & (np.arange(CELL)[None, :] > mid)
    low = lambda m: int(np.nonzero(m)[0].max()) if m.any() else None
    top = int(np.nonzero(c[..., 3] > 0)[0].min())
    return {"hip": hip, "hip_found": found, "top": top, "xc": xc, "foot": foot, "box": box, "centre": mid,
            "mask": mask, "foot_left": low(left), "foot_right": low(right)}


def row_geometry(cells, margin=0, trust_found=True):
    """Per-frame geometry with a hip line that agrees with the head: the head top's movement is the body's bob,
    the hip base is the median of (found hip minus bob). With trust_found, a found hip within 1 row of base+bob is
    kept (RD: where its trousers really start); otherwise base+bob is used (the input: so a hem shadow or belt row
    that the finder took for trouser stays with the upper body)."""
    first = [geometry(c, margin) for c in cells]
    tops = [g["top"] for g in first]
    t_med = int(np.floor(np.median(tops)))
    bob = [t - t_med for t in tops]
    base = int(np.floor(np.median([g["hip_found"] - b for g, b in zip(first, bob)])))
    out = []
    for c, g, b in zip(cells, first, bob):
        want = base + b
        keep = trust_found and abs(g["hip_found"] - want) <= 1
        out.append(g if keep or g["hip"] == want else geometry(c, margin, hip=want))
    return out, bob, base


def extrude_up(layer, top, box):
    """Columns of the leg box that start below `top` (a bag or hand covered them) grow up to `top` in the colour
    of their first pixel, the way trouser fabric would continue under what hung in front of it."""
    out = layer.copy()
    n = 0
    for x in range(box[0], box[1] + 1):
        ys = np.nonzero(layer[top:top + 10, x, 3] > 0)[0]
        if len(ys) == 0 or ys[0] == 0:
            continue
        y0 = top + ys[0]
        out[top:y0, x] = layer[y0, x]
        n += y0 - top
    return out, n


# ------------------------------------------------------------------ recolour
def zones(mask):
    """Boot zone: the lowest BOOT_H rows of every column of the leg mask. The rest is trouser."""
    boot = np.zeros_like(mask)
    for x in range(CELL):
        ys = np.nonzero(mask[:, x])[0]
        if len(ys):
            boot[max(0, ys.max() - BOOT_H + 1):ys.max() + 1, x] = True
    return boot & mask, mask & ~boot


def zone_colours(cells, masks):
    """Colour counts per zone over a whole row."""
    out = {"boot": {}, "trouser": {}}
    for c, m in zip(cells, masks):
        # skin-coloured leg pixels (PixelLab's bare ankles from behind) are not trouser or boot colours
        m = m & ~materials(c)[2]
        boot, trou = zones(m)
        for name, z in (("boot", boot), ("trouser", trou)):
            for rgb in c[z][:, :3]:
                k = tuple(int(v) for v in rgb)
                out[name][k] = out[name].get(k, 0) + 1
    return out


def rank_map(src, dst):
    """Histogram matching by luminance: each source colour goes to the target colour at the same rank."""
    s_cols = sorted(src, key=lambda k: (lum(k), k))
    d_cols = sorted(dst, key=lambda k: (lum(k), k))
    s_tot = float(sum(src.values()))
    d_tot = float(sum(dst.values()))
    d_cum = np.cumsum([dst[k] for k in d_cols]) / d_tot
    out, acc = {}, 0.0
    for k in s_cols:
        q = (acc + src[k] / 2.0) / s_tot
        acc += src[k]
        i = int(np.searchsorted(d_cum, q, side="left"))
        out[k] = d_cols[min(i, len(d_cols) - 1)]
    return out


# ------------------------------------------------------------------ build
def shift_layer(a, dx, dy):
    out = np.zeros_like(a)
    h, w = a.shape[:2]
    ys0, ys1 = max(0, -dy), min(h, h - dy)
    xs0, xs1 = max(0, -dx), min(w, w - dx)
    if ys0 < ys1 and xs0 < xs1:
        out[ys0 + dy:ys1 + dy, xs0 + dx:xs1 + dx] = a[ys0:ys1, xs0:xs1]
    return out


def fit_rows(layer, hip, n):
    """Duplicate (n > 0) or drop (n < 0) |n| thigh rows (hip+3, hip+5, ...), keeping the feet where they are.

    Rows above the change move up by n, so the hip line rises by n and the feet stay on their rows.
    """
    if n == 0:
        return layer
    picks = {hip + THIGH_K + 2 * i for i in range(abs(n))}
    order = []
    for y in range(CELL):
        if n < 0 and y in picks:
            continue
        order.append(y)
        if n > 0 and y in picks:
            order.append(y)
    off = len(order) - CELL
    out = np.zeros_like(layer)
    for i, y in enumerate(order):
        t = i - off
        if 0 <= t < CELL:
            out[t] = layer[y]
    return out


def dilate8(m):
    p = np.pad(m, 1)
    out = m.copy()
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            out |= p[1 + dy:1 + dy + m.shape[0], 1 + dx:1 + dx + m.shape[1]]
    return out


MIN_HAND = 8        # a hand with fewer skin pixels than this is mostly hidden; it is left alone


def hand_pieces(c, box, hip):
    """Each hand: its skin pixels beside the leg box (row 40 to hip+10), plus every non-jacket pixel touching them
    (the hand's shading and its outline ring). Hands with fewer than MIN_HAND skin pixels are left out."""
    op, teal, skin, khaki, dark, olive = materials(c)
    pieces = {}
    cols = np.arange(CELL)[None, :]
    rows = np.arange(CELL)[:, None]
    for side, sel in (("left", cols < box[0] + 2), ("right", cols > box[1] - 2)):
        s = skin & sel & (rows >= 40) & (rows < hip + 10)
        if s.sum() < MIN_HAND:
            pieces[side] = None
            continue
        pieces[side] = s | (dilate8(s) & op & ~teal)
    return pieces


def hand_offsets(rd_cells, rd_geo):
    """RD's hand timing per side: +1 (hand shows, swung forward, sits lower) or -1 (swung back, sits higher)."""
    out = {}
    for side in ("left", "right"):
        counts = []
        for c, g in zip(rd_cells, rd_geo):
            op, teal, skin = materials(c)[:3]
            cols = np.arange(CELL)[None, :]
            rows = np.arange(CELL)[:, None]
            sel = (cols < g["box"][0] + 2) if side == "left" else (cols > g["box"][1] - 2)
            counts.append(int((skin & sel & (rows >= 40) & (rows < g["hip"] + 10)).sum()))
        med = float(np.median(counts))
        out[side] = [1 if n > med else -1 if n < med else 0 for n in counts]
        out[side + "_counts"] = counts
    return out


def arm_phase(cells, geo):
    """The input's own arm swing: per frame, (left hand height - its mean) - (right hand height - its mean), in
    rows below the head top, from whichever hands show at least 4 skin pixels (a bag or flap may hide one).
    Positive = left hand lower (nearer the camera). None when neither hand shows."""
    cols = np.arange(CELL)[None, :]
    rows = np.arange(CELL)[:, None]
    ys = {"left": [], "right": []}
    for c, g in zip(cells, geo):
        skin = materials(c)[2]
        for side, sel in (("left", cols < g["box"][0] + 2), ("right", cols > g["box"][1] - 2)):
            m = skin & sel & (rows >= 40) & (rows < g["hip"] + 6)
            ys[side].append(float(np.nonzero(m)[0].mean()) - g["top"] if m.sum() >= 4 else None)
    mean = {k: (np.mean([v for v in vals if v is not None]) if any(v is not None for v in vals) else 0.0)
            for k, vals in ys.items()}
    out = []
    for l, r in zip(ys["left"], ys["right"]):
        if l is None and r is None:
            out.append(None)
        else:
            out.append((0.0 if l is None else l - mean["left"]) - (0.0 if r is None else r - mean["right"]))
    return out


SWING_MIN = 6.0     # an input whose hands already swing this many rows keeps its own arms, re-timed


def retime_score(phase, rd_vis, k):
    return sum(phase[(f + k) % 8] * rd_vis[f] for f in range(8) if phase[(f + k) % 8] is not None)


def retime(phase, rd_vis):
    """Frame offset k so that input frame (f + k) % 8 has its arms where RD's are in frame f: the k with the
    largest sum of phase[(f + k) % 8] * rd_vis[f] (RD's left-minus-right visible hand pixels)."""
    best, best_k = None, 0
    for k in range(8):
        sc = sum(phase[(f + k) % 8] * rd_vis[f] for f in range(8) if phase[(f + k) % 8] is not None)
        if best is None or sc > best:
            best, best_k = sc, k
    return best_k, best


def move_hand(upper, piece, dy):
    """Move one hand piece by dy rows. Moving down stretches the cuff row above it; moving up just uncovers."""
    if piece is None or dy == 0:
        return upper
    out = upper.copy()
    pix = upper.copy()
    out[piece] = 0
    moved = shift_layer(np.where(piece[..., None], pix, 0).astype(np.uint8), 0, dy)
    mm = moved[..., 3] > 0
    out[mm] = moved[mm]
    if dy > 0:
        # cuff: the pixel just above the piece's top in each column fills the gap the move opened
        ys, xs = np.nonzero(piece)
        for x in np.unique(xs):
            top = ys[xs == x].min()
            for k in range(dy):
                y = top + k
                if out[y, x, 3] == 0 and top - 1 >= 0 and upper[top - 1, x, 3] > 0:
                    out[y, x] = upper[top - 1, x]
    return out


def fill_holes(a, leg):
    """Transparent pixels cut off from the outside (holes the swap opened) take a neighbouring leg colour."""
    op = a[..., 3] > 0
    outside = np.zeros_like(op)
    q = deque()
    for y in range(CELL):
        for x in (0, CELL - 1):
            if not op[y, x]:
                outside[y, x] = True
                q.append((y, x))
    for x in range(CELL):
        for y in (0, CELL - 1):
            if not op[y, x] and not outside[y, x]:
                outside[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < CELL and 0 <= nx < CELL and not op[ny, nx] and not outside[ny, nx]:
                outside[ny, nx] = True
                q.append((ny, nx))
    holes = ~op & ~outside
    n = int(holes.sum())
    out = a.copy()
    filled = op.copy()
    todo = holes.copy()
    while todo.any():
        done = []
        for y, x in zip(*np.nonzero(todo)):
            best = None
            for dy, dx in ((0, -1), (0, 1), (-1, 0), (1, 0)):
                ny, nx = y + dy, x + dx
                if 0 <= ny < CELL and 0 <= nx < CELL and filled[ny, nx]:
                    if best is None or leg[ny, nx, 3] > 0:
                        best = out[ny, nx].copy()
            if best is not None:
                done.append((y, x, best))
        if not done:
            break
        for y, x, best in done:
            out[y, x] = best
            filled[y, x] = True
            todo[y, x] = False
    return out, n


def edges(a):
    op = a[..., 3] > 0
    p = np.pad(op, 1)
    return op & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])


def outline_edges(a, outline_rgb, before):
    """New silhouette edge pixels that are not dark (HSV value 0.3 or more, as the outline metric counts) become the outline colour.

    `before` is the input frame moved the same way as the upper body: an edge pixel that was already an edge there,
    in the same colour, is the input's own drawing (a glint, a hand's light side) and is left alone."""
    edge = edges(a)
    _, _, v = hsv(a)
    same = (before[..., 3] > 0) & np.all(before[..., :3] == a[..., :3], axis=2) & edges(before)
    bad = edge & (v >= 0.3) & ~same
    out = a.copy()
    out[bad, :3] = outline_rgb
    out[bad, 3] = 255
    return out, int(bad.sum())


def fix_row(in_cells, rd_cells, bob=True, arms=True):
    gi, bob_in, base_in = row_geometry(in_cells, trust_found=False)
    gr, bob_rd, base_rd = row_geometry(rd_cells, margin=HIP_MARGIN)
    rep = {"input_hip": [g["hip"] for g in gi], "input_hip_found": [g["hip_found"] for g in gi],
           "input_top": [g["top"] for g in gi], "input_bob": bob_in, "input_hip_base": base_in,
           "rd_hip": [g["hip"] for g in gr], "rd_hip_found": [g["hip_found"] for g in gr],
           "rd_top": [g["top"] for g in gr], "rd_bob": bob_rd, "rd_hip_base": base_rd,
           "input_box": [g["box"] for g in gi], "rd_box": [g["box"] for g in gr]}

    # recolour map from RD's leg zones to the input's leg zones (whole row)
    src = zone_colours(rd_cells, [g["mask"] for g in gr])
    dst = zone_colours(in_cells, [g["mask"] for g in gi])
    cmap = {z: rank_map(src[z], dst[z]) for z in ("boot", "trouser")}

    ground_in = max(max(g["foot_left"] or 0, g["foot_right"] or 0) for g in gi)
    ground_rd = max(max(g["foot_left"] or 0, g["foot_right"] or 0) for g in gr)
    gy = ground_in - ground_rd
    dx = int(round(float(np.median([g["centre"] for g in gi]) - np.median([g["centre"] for g in gr]))))
    rep.update({"ground_input": ground_in, "ground_rd": ground_rd, "x_shift": dx, "y_shift_legs": gy})

    timing = hand_offsets(rd_cells, gr) if arms else None
    k = 0
    if timing:
        rep["rd_hand_pixels"] = {"left": timing["left_counts"], "right": timing["right_counts"]}
        phase = arm_phase(in_cells, gi)
        valid = [x for x in phase if x is not None]
        swing = (max(valid) - min(valid)) if len(valid) >= 6 else 0.0
        rep["input_arm_phase"] = [None if x is None else round(x, 2) for x in phase]
        rep["input_arm_swing_rows"] = round(swing, 2)
        if swing >= SWING_MIN:
            # the input's arms already swing: keep them and re-time the upper body to RD's arm timing
            vis = [a - b for a, b in zip(timing["left_counts"], timing["right_counts"])]
            k, score = retime(phase, vis)
            rep["arms"] = "re-timed: output frame f uses the input's upper body from frame (f + %d) %% 8" % k
            rep["retime_scores"] = {str(j): round(retime_score(phase, vis, j), 1) for j in range(8)}
            timing = None
        else:
            rep["arms"] = "frozen in the input: each hand moved 1 px with RD's hand timing"
            rep["hand_dy"] = {"left": timing["left"], "right": timing["right"]}
    rep["upper_body_frame_offset"] = k

    out_cells, dys, fits, extr, holes, edges = [], [], [], [], [], []
    for f, (r, g_r) in enumerate(zip(rd_cells, gr)):
        src = (f + k) % 8
        c, g_i = in_cells[src], gi[src]
        # where this frame's hip line goes: the input's base hip, moved by RD's bob (or still)
        target_hip = base_in + (bob_rd[f] if bob else 0)
        dy_up = (bob_rd[f] if bob else 0) - bob_in[src]
        # RD legs, recoloured by zone, fitted so their hip line lands on target_hip and the feet stay on RD's rows
        legs = np.zeros_like(r)
        boot, trou = zones(g_r["mask"])
        for z, zm in (("boot", boot), ("trouser", trou)):
            for y, x in zip(*np.nonzero(zm)):
                legs[y, x, :3] = cmap[z][tuple(int(v) for v in r[y, x, :3])]
                legs[y, x, 3] = 255
        legs, n_ext = extrude_up(legs, g_r["hip"] - HIP_MARGIN, g_r["box"])
        n_fit = g_r["hip"] + gy - target_hip
        legs = fit_rows(legs, g_r["hip"], n_fit)
        legs = shift_layer(legs, dx, gy)
        fits.append(int(n_fit))
        extr.append(int(n_ext))
        # input upper body = the input minus its own legs
        upper = c.copy()
        upper[g_i["mask"]] = 0
        upper = shift_layer(upper, 0, dy_up)
        if timing:
            pieces = hand_pieces(upper, g_i["box"], target_hip)
            for side in ("left", "right"):
                upper = move_hand(upper, pieces[side], timing[side][f])
        comp = legs.copy()
        um = upper[..., 3] > 0
        comp[um] = upper[um]
        comp, nh = fill_holes(comp, legs)
        # outline colour: the input's most common dark leg-edge colour
        comp, ne = outline_edges(comp, outline_rgb_of(c, g_i["mask"]), shift_layer(c, 0, dy_up))
        out_cells.append(comp)
        dys.append(int(dy_up))
        holes.append(nh)
        edges.append(ne)
    rep.update({"upper_body_dy": dys, "rows_fitted_at_thigh": fits, "rd_pixels_extruded_under_bag": extr,
                "holes_filled": holes,
                "edge_pixels_outlined": edges,
                "recolour": {z: {"%02x%02x%02x" % k: "%02x%02x%02x" % v for k, v in cmap[z].items()}
                             for z in cmap}})
    return out_cells, rep


def outline_rgb_of(c, mask):
    p = np.pad(c[..., 3] > 0, 1)
    edge = (c[..., 3] > 0) & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]) & mask
    cols, n = np.unique(c[edge][:, :3], axis=0, return_counts=True)
    if len(cols) == 0:
        return np.array([0, 0, 0], np.uint8)
    darkest = [i for i in np.argsort(-n) if lum(cols[i]) < 40]
    return cols[darkest[0] if darkest else int(n.argmax())]


def split(atlas):
    return {r: [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL].copy() for f in range(8)]
            for i, r in enumerate(ROWS)}


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("inp")
    ap.add_argument("out")
    ap.add_argument("--report", default=None, help="write the fit numbers here as JSON")
    ap.add_argument("--no-bob", action="store_true", help="keep the upper body still (legs refitted per frame)")
    ap.add_argument("--no-arms", action="store_true", help="leave the hands where the input has them")
    args = ap.parse_args()

    atlas = np.array(Image.open(args.inp).convert("RGBA"))
    if atlas.shape[:2] != (CELL * 8, CELL * 8):
        raise SystemExit("expected a 640x640 atlas, got %s" % (atlas.shape[:2],))
    atlas[..., 3] = np.where(atlas[..., 3] >= 128, 255, 0)
    atlas[atlas[..., 3] == 0] = 0
    rd = np.array(Image.open(RD_PATH).convert("RGBA"))
    cells_in, cells_rd = split(atlas), split(rd)
    out = atlas.copy()
    report = {}
    for r in FIX_ROWS:
        i = ROWS.index(r)
        fixed, rep = fix_row(cells_in[r], cells_rd[r], bob=not args.no_bob, arms=not args.no_arms)
        report[r] = rep
        for f in range(8):
            out[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] = fixed[f]
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(out, "RGBA").save(args.out)
    if args.report:
        Path(args.report).write_text(json.dumps(report, indent=1), encoding="utf-8")
    print(json.dumps({r: {k: v for k, v in report[r].items() if k != "recolour"} for r in report}))


if __name__ == "__main__":
    main()
