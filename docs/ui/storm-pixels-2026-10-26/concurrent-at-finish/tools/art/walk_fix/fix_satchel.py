"""Satchel and strap repair for the PixelLab courier walk (Claude, 2026-10-26, walk-fix lane 'satchel').

  python tools/art/walk_fix/fix_satchel.py IN_ATLAS OUT_ATLAS

What it fixes, the way a pixel artist would by hand:
  * The courier's satchel hangs on his LEFT hip and its strap crosses from his RIGHT shoulder
    (read off reference/courier_south_ref_80.png). That rule holds in every direction here, so
    the bag never swaps hips the way RD's mirrored right and up_right rows do.
  * Back views (up, up_left, up_right): PixelLab drew no bag. One bag is cut from RD's own back
    row (our art) with its outline, made smaller by dropping two columns and one row (no
    resampling), recoloured to the courier's leather browns, and pasted on the left side of
    the back. A 2 px strap with a dark edge runs from the right shoulder to the bag.
  * South view: the bag is fully drawn in only frames 2 and 7. The complete bag from frame 2
    is copied into every frame.

Every paste is placed per frame: the frame's torso is registered against a key frame of the
raw atlas (integer shifts only, within +-3 px, and only when the match is clearly better than
no shift), so the bag follows the hip if the art sways or another fix has moved the body.
Nothing is resampled, alpha stays 0 or 255, hands stay in front of the bag.

Inputs other than IN_ATLAS are fixed reference files: the raw PixelLab atlas (key frames and
the south bag) and the RD walk atlas (the back bag). Colour dependencies:
  * body parts are told apart by colour families (teal jacket, skin, leather brown, olive), not
    exact values, so a palette clamp or recolour that keeps those families is fine before this;
  * every pasted pixel is snapped to the nearest colour already used in that row of the input,
    so this step adds no colour to a row.
"""
import sys
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

HT = Path(__file__).resolve().parents[3]
RAW_ATLAS = HT / "docs/art/characters/sprite-tool-test-2026-10-26/pixellab_courier_walk_native80.png"
RD_ATLAS = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
CELL = 80
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]

# Colour families used for registration and cutting.
T_CLEAR, T_DARK, T_TEAL, T_SKIN, T_LEATHER, T_GOLD, T_OLIVE, T_OTHER = range(8)

# The courier's leather ramp, read off the raw PixelLab south bag and strap (frame 2) and the
# reference. RD's olive bag is recoloured onto it by luminance.
LEATHER = np.array([
    (0x1f, 0x14, 0x0e), (0x30, 0x1a, 0x10), (0x33, 0x27, 0x1a), (0x57, 0x46, 0x28),
    (0x68, 0x48, 0x22), (0x7e, 0x5c, 0x2c), (0x8f, 0x66, 0x2f), (0xaa, 0x7a, 0x45),
    (0xe7, 0xbf, 0x69),
])
STRAP_LIGHT = (0x7e, 0x5c, 0x2c)
STRAP_DARK = (0x68, 0x48, 0x22)
STRAP_EDGE = (0x1f, 0x14, 0x0e)

# The back bag: RD row 'up', frame 0. Inside box x 31-40, y 42-52 (clasp at x 34-35). Dropping
# columns 32 and 38 and row 45 makes it 8 x 10 inside (10 x 12 with outline), close to the
# 6-7 px wide front bag on PixelLab's narrower body, and centres the clasp.
RD_BAG = dict(row=4, frame=0, box=(31, 42, 40, 52), drop_cols=(32, 38), drop_rows=(45,))

# Back rows. Coordinates are inside an 80 x 80 cell of the RAW atlas, on the key frame.
#   win:     torso window used to register every frame against the key frame
#   at:      top-left corner of the bag patch (outline included)
#   strap:   shoulder end of the strap; the other end is set just under the bag's top edge
#   paint:   boxes holding PixelLab's own back straps (two backpack-like straps on 'up', one
#            over the wrong shoulder on 'up_left', a short one on 'up_right'); they are painted
#            out with the jacket colour next to them so all three back views carry one strap
BACK = {
    4: dict(key=0, win=(34, 28, 50, 55), at=(34, 44), strap=(47, 32),            # up
            paint=[(30, 33, 37, 45), (46, 32, 50, 41)]),
    3: dict(key=0, win=(34, 30, 49, 52), at=(32, 44), strap=(47, 33),            # up_left
            paint=[(35, 32, 42, 42)]),
    5: dict(key=0, win=(31, 30, 47, 52), at=(30, 44), strap=(44, 32),            # up_right
            paint=[(39, 32, 45, 43), (29, 31, 31, 35)]),
}
# Rows where PixelLab drew the bag in some frames only: the complete bag of the key frame
# (inside box, inclusive) is copied into every frame of that row. hand: "front" keeps the hand
# in front of the bag (the front 3/4 and side views, as PixelLab drew it there). "auto" (south,
# and every back row) follows the arm swing with hand_side(): a hand swung toward the camera
# stays in front, otherwise the bag covers it, as in the reference pose and raw frames 2 and 7.
SAME_ROW = {
    0: dict(key=2, win=(35, 30, 49, 49), box=(49, 44, 54, 53), hand="auto"),     # down
    1: dict(key=7, win=(40, 34, 52, 49), box=(49, 46, 54, 53), hand="front"),    # down_left
    2: dict(key=6, win=(37, 32, 47, 49), box=(37, 49, 45, 55), hand="front"),    # left: near hip
    7: dict(key=4, win=(36, 32, 50, 48), box=(49, 45, 52, 52), hand="front"),    # down_right: far hip
}


def load(path):
    return np.array(Image.open(path).convert("RGBA"))


def cell(atlas, r, f):
    return atlas[r * CELL:(r + 1) * CELL, f * CELL:(f + 1) * CELL]


def lum(rgb):
    rgb = np.asarray(rgb, float)
    return 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]


def classes(c):
    """Colour family of every pixel (vectorised)."""
    rgb = c[..., :3].astype(float) / 255.0
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx, mn = rgb.max(-1), rgb.min(-1)
    d = np.where(mx - mn == 0, 1, mx - mn)
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    h = np.where(mx - mn == 0, 0, h)
    s = np.where(mx > 0, (mx - mn) / np.where(mx > 0, mx, 1), 0)
    v = mx
    L = lum(c[..., :3])
    out = np.full(c.shape[:2], T_OTHER, np.int8)
    warm = (h >= 15) & (h <= 72) & (s > 0.3)
    out[warm & (h <= 40) & (v > 0.18)] = T_LEATHER
    out[warm & (h > 40) & (v > 0.3)] = T_OLIVE
    out[warm & (h >= 34) & (v > 0.75)] = T_GOLD
    out[(h >= 15) & (h <= 33) & (s > 0.15) & (s < 0.62) & (v > 0.8)] = T_SKIN
    out[(h >= 160) & (h <= 200) & (s > 0.4) & (L >= 48)] = T_TEAL
    out[L < 48] = T_DARK
    out[c[..., 3] == 0] = T_CLEAR
    return out


def register(frame, key, win, skip=None, search=3):
    """Integer (dx, dy) that lays the key frame's torso window onto this frame, the way a
    pixel artist lines up an onion skin: count the pixels that differ (alpha differs, or the
    colours are more than 24 apart, so a light palette clamp still lines up).

    Pixels where skip is set (key coordinates: the bag box grown by 1 px and the strap line)
    are not scored, so the fix's own pixels, or a bag another step drew, cannot pull the match.
    A shift is only taken when it is clearly better than none (15 percent fewer differing
    pixels); among near-equal shifts the smallest wins, so shimmer cannot jiggle the bag."""
    x0, y0, x1, y1 = win
    ref = key[y0:y1, x0:x1].astype(int)
    use = np.ones(ref.shape[:2], bool) if skip is None else ~skip[y0:y1, x0:x1]
    scores = {}
    for dy in range(-search, search + 1):
        for dx in range(-search, search + 1):
            if y0 + dy < 0 or x0 + dx < 0 or y1 + dy > CELL or x1 + dx > CELL:
                continue
            sub = frame[y0 + dy:y1 + dy, x0 + dx:x1 + dx].astype(int)
            a_diff = (sub[..., 3] > 0) != (ref[..., 3] > 0)
            c_diff = (np.abs(sub[..., :3] - ref[..., :3]).sum(-1) > 24) & (ref[..., 3] > 0)
            scores[(dx, dy)] = int(((a_diff | c_diff) & use).sum())
    zero = scores[(0, 0)]
    best = min(scores.values())
    if best > 0.85 * zero:
        return 0, 0
    near = [k for k, v in scores.items() if v <= best * 1.03 + 1]
    return min(near, key=lambda k: (abs(k[0]) + abs(k[1]), scores[k]))


def shift_mask(mask, dx, dy):
    out = np.zeros_like(mask)
    h, w = mask.shape
    src = mask[max(0, -dy):h - max(0, dy), max(0, -dx):w - max(0, dx)]
    out[max(0, dy):h + min(0, dy), max(0, dx):w + min(0, dx)] = src
    return out


def placement(frame, raw, r, f, key_f, win, skip):
    """Shift of the bag for frame f of row r, in two steps that are each easy to trust:
      1. how far the raw art itself sways: raw frame f against the raw key frame;
      2. how far an earlier fix moved this frame: the input frame against raw frame f, the same
         pose, so a 1 px bob or lift shows up cleanly."""
    bx, by = register(cell(raw, r, f), cell(raw, r, key_f), win, skip)
    x0, y0, x1, y1 = win
    ex, ey = register(frame, cell(raw, r, f), (x0 + bx, y0 + by, x1 + bx, y1 + by),
                      shift_mask(skip, bx, by))
    return bx + ex, by + ey


def grow(mask, n):
    for _ in range(n):
        mask = dilate8(mask)
    return mask


def box_mask(boxes):
    m = np.zeros((CELL, CELL), bool)
    for (x0, y0, x1, y1) in boxes:
        m[max(0, y0):y1 + 1, max(0, x0):x1 + 1] = True
    return m


def back_skip(plan, bw, bh):
    """Registration skip zone of a back row: the bag box grown by 1 px and the strap line."""
    ax0, ay0 = plan["at"]
    bag = grow(box_mask([(ax0, ay0, ax0 + bw - 1, ay0 + bh - 1)]), 1)
    return bag | strap_line(plan["strap"], (ax0 + bw - 3, ay0 + 1))


def strap_line(p0, p1):
    m = np.zeros((CELL, CELL), bool)
    (xa, ya), (xb, yb) = p0, p1
    for y in range(ya, yb + 1):
        t = (y - ya) / max(1, yb - ya)
        xc = int(np.floor(xa + (xb - xa) * t + 0.5))
        m[y, max(0, xc - 1):xc + 3] = True
    return m


def flood(mask, seeds):
    """4-connected part of mask reachable from any seed pixel."""
    out = np.zeros_like(mask)
    q = deque(zip(*np.nonzero(seeds & mask)))
    for y, x in q:
        out[y, x] = True
    while q:
        y, x = q.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < mask.shape[0] and 0 <= nx < mask.shape[1] and mask[ny, nx] and not out[ny, nx]:
                out[ny, nx] = True
                q.append((ny, nx))
    return out


def fill_holes(mask):
    border = np.zeros(mask.shape, bool)
    border[0, :] = border[-1, :] = True
    border[:, 0] = border[:, -1] = True
    return mask | ~flood(~mask, border)


def dilate8(mask):
    p = np.pad(mask, 1)
    out = mask.copy()
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            out |= p[1 + dy:1 + dy + mask.shape[0], 1 + dx:1 + dx + mask.shape[1]]
    return out


def outline_colour(atlas):
    a = atlas[..., 3] > 0
    p = np.pad(a, 1)
    edge = a & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
    cols, n = np.unique(atlas[edge][:, :3], axis=0, return_counts=True)
    return tuple(int(v) for v in cols[n.argmax()])


def cut(src, box, line, teal_ring="outline", drop_cols=(), drop_rows=()):
    """Cut a part with its own outline. Returns (rgba patch, mask, (x, y) of the patch corner).

    box is the part's inside (inclusive). The inside is the 4-connected leather/olive/gold
    region there (skin-light highlights may join), holes filled so flap lines and the clasp
    shadow come along. The 1 px ring around it is the outline: the source pixel where it is
    already dark, the outline colour where it is not. teal_ring="drop" leaves out ring pixels
    that are jacket in the source (used when the target has the same jacket in the same place).
    drop_cols / drop_rows remove whole source columns or rows: the pixel artist's way to make a
    part smaller without resampling."""
    x0, y0, x1, y1 = box
    X0, Y0, X1, Y1 = x0 - 1, y0 - 1, x1 + 2, y1 + 2
    sub = src[Y0:Y1, X0:X1].copy()
    cl = classes(sub)
    inside_box = np.zeros(cl.shape, bool)
    inside_box[1:-1, 1:-1] = True
    allowed = np.isin(cl, [T_OLIVE, T_GOLD, T_LEATHER, T_SKIN, T_OTHER]) & inside_box
    seeds = allowed & np.isin(cl, [T_OLIVE, T_GOLD, T_LEATHER])
    interior = fill_holes(flood(allowed, seeds)) & inside_box
    ring = dilate8(interior) & ~interior
    mask = interior | ring
    if teal_ring == "drop":
        mask &= ~(ring & (cl == T_TEAL))
    patch = sub.copy()
    force = ring & mask & (cl != T_DARK)
    patch[force, :3] = line
    patch[..., 3] = 0
    patch[mask, 3] = 255
    keep_c = [i for i in range(patch.shape[1]) if X0 + i not in drop_cols]
    keep_r = [j for j in range(patch.shape[0]) if Y0 + j not in drop_rows]
    patch = patch[keep_r][:, keep_c]
    mask = mask[keep_r][:, keep_c]
    return patch, mask, (X0, Y0)


def recolour(patch, mask, ramp, line):
    """Each pixel to the ramp colour of nearest luminance; the near-black ones to the outline."""
    out = patch.copy()
    L = lum(patch[..., :3])
    rl = lum(ramp)
    for y, x in zip(*np.nonzero(mask)):
        if L[y, x] < 14:
            out[y, x, :3] = line
        else:
            out[y, x, :3] = ramp[int(np.abs(rl - L[y, x]).argmin())]
    return out


def nearest_in(rgb, palette):
    """Nearest palette colour by the 'redmean' distance (same rule as finish_back.py)."""
    p = palette.astype(float)
    c = np.asarray(rgb, float)
    rmean = (c[0] + p[:, 0]) / 2
    d = (2 + rmean / 256) * (c[0] - p[:, 0]) ** 2 + 4 * (c[1] - p[:, 1]) ** 2 \
        + (2 + (255 - rmean) / 256) * (c[2] - p[:, 2]) ** 2
    return palette[int(d.argmin())]


def hand_guard(frame):
    """Hands stay in front of a pasted bag: skin pixels and the dark outline pixels touching them."""
    cl = classes(frame)
    skin = cl == T_SKIN
    return skin | (dilate8(skin) & (cl == T_DARK))


def hand_side(frame, mask, ox, oy, big=14):
    """Is the hand in front of the bag or behind it? A hand that has swung toward the camera is
    drawn bigger: 14 or more skin pixels under the bag (raw south frames 4-6 have 16-22, the
    others 1-11; the back rows never pass 7) means in front, fewer means the bag covers it."""
    under = np.zeros(frame.shape[:2], bool)
    h, w = mask.shape
    ys, xs = np.nonzero(mask)
    ok = (oy + ys >= 0) & (oy + ys < CELL) & (ox + xs >= 0) & (ox + xs < CELL)
    under[oy + ys[ok], ox + xs[ok]] = True
    return "front" if int((under & (classes(frame) == T_SKIN)).sum()) >= big else "behind"


def paste(frame, patch, mask, ox, oy, protect=None):
    """Put the patch's masked pixels on the frame at (ox, oy); protected pixels stay.
    Returns the frame pixels written."""
    wrote = np.zeros(frame.shape[:2], bool)
    for y, x in zip(*np.nonzero(mask)):
        ty, tx = oy + y, ox + x
        if not (0 <= ty < CELL and 0 <= tx < CELL):
            continue
        if protect is not None and protect[ty, tx]:
            continue
        frame[ty, tx, :3] = patch[y, x, :3]
        frame[ty, tx, 3] = 255
        wrote[ty, tx] = True
    return wrote


def silhouette_edge(frame):
    """Opaque pixels with a transparent 4-neighbour (the outer outline)."""
    a = frame[..., 3] > 0
    p = np.pad(a, 1)
    return a & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])


def draw_strap(frame, p0, p1):
    """A 2 px strap with a dark edge each side, from the shoulder p0 down to the bag p1.

    One centre x per row (a clean stair), light core on the upper-left side. Painted only on
    the body, never over skin and never over the outer outline. Returns the pixels written."""
    (xa, ya), (xb, yb) = p0, p1
    cl = classes(frame)
    edge = silhouette_edge(frame)
    wrote = np.zeros(frame.shape[:2], bool)
    for y in range(ya, yb + 1):
        t = (y - ya) / max(1, yb - ya)
        xc = int(np.floor(xa + (xb - xa) * t + 0.5))
        for x, col in ((xc - 1, STRAP_EDGE), (xc, STRAP_LIGHT), (xc + 1, STRAP_DARK), (xc + 2, STRAP_EDGE)):
            if 0 <= x < CELL and frame[y, x, 3] > 0 and cl[y, x] != T_SKIN and not edge[y, x]:
                frame[y, x, :3] = col
                wrote[y, x] = True
    return wrote


def paint_out(frame, box):
    """Paint PixelLab's own strap out of a box: every pixel that is not jacket, not dark and not
    on the outer outline takes the colour of the nearest jacket pixel (same row first, then the
    rows next to it, at most 3 px away). Returns the pixels written."""
    x0, y0, x1, y1 = box
    cl = classes(frame)
    edge = silhouette_edge(frame)
    src = frame.copy()
    wrote = np.zeros(frame.shape[:2], bool)
    for y in range(max(0, y0), min(CELL, y1 + 1)):
        for x in range(max(0, x0), min(CELL, x1 + 1)):
            if cl[y, x] in (T_TEAL, T_DARK, T_CLEAR) or edge[y, x]:
                continue
            best = None
            for ny in range(y - 3, y + 4):
                for nx in range(x - 3, x + 4):
                    if not (0 <= ny < CELL and 0 <= nx < CELL) or cl[ny, nx] != T_TEAL:
                        continue
                    if x0 <= nx <= x1 and y0 <= ny <= y1 and cl[ny, nx] != T_TEAL:
                        continue
                    d = (abs(ny - y) * 2 + abs(nx - x), abs(nx - x))
                    if best is None or d < best[0]:
                        best = (d, ny, nx)
            if best is not None:
                frame[y, x, :3] = src[best[1], best[2], :3]
                wrote[y, x] = True
    return wrote


def drop_hand_remnant(before, frame, box, line):
    """After a bag is pasted over a hand, erase the scraps of that hand left just below or right
    of the bag, the way a pixel artist would. box = (x0, y0, x1, y1) of the pasted patch. Only
    two strips are touched: 2 rows under the bag (not its first column, which meets the leg) and
    2 columns right of it. A scrap is skin, or any non-jacket pixel touching skin, in the frame
    before the paste. Cleared pixels go transparent; a light pixel left on the new edge becomes
    outline. Returns the pixels changed."""
    x0, y0, x1, y1 = box
    cl = classes(before)
    skin = cl == T_SKIN
    handish = (skin | dilate8(skin)) & (cl != T_TEAL) & (before[..., 3] > 0)
    zone = np.zeros(frame.shape[:2], bool)
    zone[y1 + 1:y1 + 3, x0 + 1:x1 + 1] = True
    zone[y0:y1 + 1, x1 + 1:x1 + 3] = True
    scraps = zone & handish & (frame[..., 3] > 0)
    changed = scraps.copy()
    frame[scraps] = 0
    edge = silhouette_edge(frame)
    fix_edge = edge & dilate8(scraps) & (classes(frame) != T_DARK) & ~scraps
    frame[fix_edge, :3] = line
    return changed | fix_edge


def snap_to_row(atlas_in, out, r, written):
    """Snap every written pixel of row r to the nearest colour the input row already uses."""
    rows = atlas_in[r * CELL:(r + 1) * CELL]
    pal = np.unique(rows[rows[..., 3] > 0][:, :3], axis=0)
    cache = {}
    for f in range(8):
        c = cell(out, r, f)
        for y, x in zip(*np.nonzero(written[f])):
            k = tuple(int(v) for v in c[y, x, :3])
            if k not in cache:
                cache[k] = nearest_in(k, pal)
            c[y, x, :3] = cache[k]


def back_bag(line):
    rd = load(RD_ATLAS)
    b = RD_BAG
    patch, mask, _ = cut(cell(rd, b["row"], b["frame"]), b["box"], line,
                         drop_cols=b["drop_cols"], drop_rows=b["drop_rows"])
    return recolour(patch, mask, LEATHER, line), mask


def fix(atlas_in):
    """Returns (fixed atlas, per-frame report). Bag boxes in the report are frame coordinates."""
    raw = load(RAW_ATLAS)
    line = outline_colour(raw)
    out = atlas_in.copy()
    report = {}
    bag, bag_mask = back_bag(line)
    bh, bw = bag_mask.shape
    for r, plan in BACK.items():
        key = cell(raw, r, plan["key"])
        skip = back_skip(plan, bw, bh)
        written, rows = [], []
        for f in range(8):
            c = cell(out, r, f)
            dx, dy = placement(c, raw, r, f, plan["key"], plan["win"], skip)
            w = np.zeros(c.shape[:2], bool)
            for (x0, y0, x1, y1) in plan["paint"]:
                w |= paint_out(c, (x0 + dx, y0 + dy, x1 + dx, y1 + dy))
            ax, ay = plan["at"][0] + dx, plan["at"][1] + dy
            sx, sy = plan["strap"][0] + dx, plan["strap"][1] + dy
            w |= draw_strap(c, (sx, sy), (ax + bw - 3, ay + 1))
            hand = hand_side(c, bag_mask, ax, ay)
            w |= paste(c, bag, bag_mask, ax, ay, hand_guard(c) if hand == "front" else None)
            written.append(w)
            rows.append(dict(frame=f, shift=[dx, dy], bag_box=[ax, ay, ax + bw - 1, ay + bh - 1],
                             hand=hand, pixels_written=int(w.sum())))
        snap_to_row(atlas_in, out, r, written)
        report[ROWS[r]] = rows
    for r, plan in SAME_ROW.items():
        key = cell(raw, r, plan["key"])
        patch, mask, (bx, by) = cut(key, plan["box"], line, teal_ring="drop")
        ph, pw = mask.shape
        skip = grow(box_mask([plan["box"]]), 1)
        written, rows = [], []
        for f in range(8):
            c = cell(out, r, f)
            dx, dy = placement(c, raw, r, f, plan["key"], plan["win"], skip)
            before = c.copy()
            box = (bx + dx, by + dy, bx + dx + pw - 1, by + dy + ph - 1)
            hand = plan["hand"]
            if hand == "auto":
                hand = hand_side(c, mask, box[0], box[1])
            guard = hand_guard(c) if hand == "front" else None
            w = paste(c, patch, mask, bx + dx, by + dy, guard)
            if hand == "behind":
                w |= drop_hand_remnant(before, c, box, line)
            written.append(w & (c[..., 3] > 0))
            rows.append(dict(frame=f, shift=[dx, dy], bag_box=list(box), hand=hand,
                             pixels_written=int(w.sum())))
        snap_to_row(atlas_in, out, r, written)
        report[ROWS[r]] = rows
    return out, report


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    atlas_in = load(sys.argv[1])
    if atlas_in.shape[:2] != (CELL * 8, CELL * 8):
        sys.exit(f"expected a 640x640 atlas, got {atlas_in.shape[1]}x{atlas_in.shape[0]}")
    out, report = fix(atlas_in)
    assert set(np.unique(out[..., 3]).tolist()) <= {0, 255}
    Image.fromarray(out).save(sys.argv[2])
    for row, frames in report.items():
        print(f"{row:10s}", " ".join(f"f{d['frame']}:{d['shift'][0]:+d}{d['shift'][1]:+d}/{d['pixels_written']}"
                                     for d in frames))


if __name__ == "__main__":
    main()
