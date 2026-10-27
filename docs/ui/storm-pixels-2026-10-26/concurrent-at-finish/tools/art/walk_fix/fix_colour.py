"""Colour fix for the PixelLab courier walk (judges' faults 4 and 7).

usage: python fix_colour.py IN_ATLAS OUT_ATLAS [LOG_JSON]

IN_ATLAS is a 640x640 walk atlas: 80x80 cells, 8 rows (down, down_left, left, up_left, up, up_right,
right, down_right) by 8 frames. The output is the same atlas with only colours changed: alpha is
copied untouched (hardened to 0/255 if the input had soft alpha), so the silhouette and the outline
shape cannot move. The result depends only on the input atlas plus two fixed files: the reference
courier frame and the RD walk atlas (the source of five extra colours).

What it does, in order:
1. Palette. The 35 colours of the reference frame, plus five colours taken from the RD walk for parts
   the reference does not show: the olive satchel seen from behind (light, mid, shadow), a deep skin
   shadow (RD uses it on ears and hands in the back view) and the lit edge of the teal jacket.
   40 colours in all.
2. Lock. Every colour already in the palette stays exactly as it is. Every other colour moves to a
   palette colour, chosen by OKLab distance with hue and chroma weighted 3x over lightness, so a
   colour stays in its own ramp (trouser tan stays trouser tan) and only its lightness step changes.
   Then ramp protection: wherever two different colours touch in the input and differ clearly
   (a light/shadow step or a material edge), the lock tries not to merge them into one colour or to
   swap which one is lighter. It does this with a small local search that trades colour accuracy
   (pixels x OKLab error) against broken steps (number of touching pixel pairs).
3. Regional repairs, decided on the input pixels and written over the lock:
   - eyes: blue, teal or cool-white pixels in the face (skin right below them) become the reference
     eye colours: dark iris #181a18, one white glint #ffffff, eye white #ebd1b0;
   - side goggles (rows left and right): the lens inside the front gold ring is redrawn with the
     reference lens colours in the front view's order: glint at the top left, teal #12837f in the
     middle, dark teal #07515c along the bottom and the back of the top row; the gold rim is kept;
   - maroon far leg: maroon patches of 6 or more pixels below the hips become the trouser shadow
     #684822 (or the boot shade #33271a when the patch is a boot, near the foot).

Depends on: the row order above; the eye, lens and leg rules use hue/lightness bands measured on the
PixelLab output (see the constants below), not exact colours, so they still work after a fix that only
moves pixels. A fix that paints new colours far outside the courier's palette will have those colours
locked to the nearest palette ramp, which is the point, but check its compare image.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

HT = Path(__file__).resolve().parents[3]
REF_PATH = HT / "docs/art/characters/sprite-tool-test-2026-10-26/reference/courier_south_ref_80.png"
RD_PATH = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
CELL = 80
FACING = {"down": 0, "down_left": -1, "left": -1, "up_left": -1, "up": 0, "up_right": 1, "right": 1, "down_right": 1}
FACE_ROWS = {"down", "down_left", "left", "right", "down_right"}
SIDE_ROWS = {"left": -1, "right": 1}

# Five RD colours for parts the reference frame does not show. Each is checked against the RD atlas.
RD_EXTRAS = {
    "948236": "satchel light (RD up row, y42-52)",
    "7d6d2e": "satchel mid (RD up_left/up_right, y37-62)",
    "5e4f21": "satchel shadow and strap (RD up_left/up_right)",
    "da713f": "deep skin shadow, ears and hands (RD up row)",
    "1ba79c": "jacket lit edge (RD down_left/down_right)",
}
EYE_DARK, EYE_GLINT, EYE_WHITE = "181a18", "ffffff", "ebd1b0"
EYE_KEEP = {"181a18", "021511", "000000", "0d0a04", "03060b", "ffffff", "ebd1b0", "4b434e", "0b0c28"}
LENS_TEAL, LENS_DARK, LENS_GLINT = "12837f", "07515c", "ffffff"
TROUSER_SHADOW, BOOT_SHADE = "684822", "33271a"

K_CHROMA = 3.0      # weight of the OKLab a/b plane against lightness in the lock
ALPHA = 30.0        # pixels x OKLab error worth one broken step (one touching pixel pair)
STEP_DE = 0.03      # two touching colours this far apart in OKLab are a step or a material edge
STEP_DL = 0.03      # lightness difference that makes a light/shadow step (order must survive)


def hx(c):
    return "%02x%02x%02x" % tuple(int(v) for v in c[:3])


def rgb(h):
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.uint8)


def oklab(c):
    c = np.asarray(c, float) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    l = 0.4122214708 * c[..., 0] + 0.5363325363 * c[..., 1] + 0.0514459929 * c[..., 2]
    m = 0.2119034982 * c[..., 0] + 0.6806995451 * c[..., 1] + 0.1073969566 * c[..., 2]
    s = 0.0883024619 * c[..., 0] + 0.2817188376 * c[..., 1] + 0.6299787005 * c[..., 2]
    l, m, s = np.cbrt(l), np.cbrt(m), np.cbrt(s)
    return np.stack([0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
                     1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
                     0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s], -1)


def lch(c):
    lab = oklab(c)
    return lab[..., 0], np.hypot(lab[..., 1], lab[..., 2]), np.degrees(np.arctan2(lab[..., 2], lab[..., 1])) % 360


def load(path):
    return np.array(Image.open(path).convert("RGBA"))


def build_palette():
    ref = load(REF_PATH)
    ref_cols = np.unique(ref[ref[..., 3] > 0][:, :3], axis=0)
    rd = load(RD_PATH)
    rd_cols = {hx(c) for c in np.unique(rd[rd[..., 3] > 0][:, :3], axis=0)}
    for h in RD_EXTRAS:
        if h not in rd_cols:
            raise SystemExit(f"RD extra colour #{h} is not in {RD_PATH}; the palette would not be RD's")
    extras = [rgb(h) for h in RD_EXTRAS if h not in {hx(c) for c in ref_cols}]
    pal = np.concatenate([ref_cols, np.array(extras, np.uint8).reshape(-1, 3)])
    return pal, ref_cols


# ------------------------------------------------------------------ palette lock with ramp protection
def lock_map(atlas, pal):
    """Return {source hex: palette hex} for every opaque colour, plus diagnostics."""
    op = atlas[..., 3] > 0
    cols, inv, cnt = np.unique(atlas[..., :3][op], axis=0, return_inverse=True, return_counts=True)
    n = len(cols)
    idx = -np.ones(atlas.shape[:2], int)
    idx[op] = inv.ravel()
    S, P = oklab(cols), oklab(pal)
    d = S[:, None, :] - P[None, :, :]
    cost = np.sqrt(d[..., 0] ** 2 + K_CHROMA ** 2 * (d[..., 1] ** 2 + d[..., 2] ** 2))
    pal_hex = [hx(p) for p in pal]
    in_pal = np.array([pal_hex.index(hx(c)) if hx(c) in pal_hex else -1 for c in cols])

    # touching pairs of different colours inside each cell (4-neighbour)
    H, W = idx.shape
    a, b = idx[:, :-1], idx[:, 1:]
    mh = (a >= 0) & (b >= 0) & (a != b) & ((np.arange(W - 1) % CELL) != CELL - 1)[None, :]
    a2, b2 = idx[:-1, :], idx[1:, :]
    mv = (a2 >= 0) & (b2 >= 0) & (a2 != b2) & ((np.arange(H - 1) % CELL) != CELL - 1)[:, None]
    pa = np.concatenate([a[mh], a2[mv]])
    pb = np.concatenate([b[mh], b2[mv]])
    keys, w = np.unique(np.minimum(pa, pb) * n + np.maximum(pa, pb), return_counts=True)
    i1, i2 = keys // n, keys % n
    dE = np.linalg.norm(S[i1] - S[i2], axis=1)
    all_pairs = (i1, i2, w, dE)
    step = dE >= STEP_DE
    i1, i2, w = i1[step], i2[step], w[step]
    nbrs = [[] for _ in range(n)]
    for p, q, ww in zip(i1.tolist(), i2.tolist(), w.tolist()):
        nbrs[p].append((q, ww))
        nbrs[q].append((p, ww))

    nearest = cost.argmin(1)
    assign = np.where(in_pal >= 0, in_pal, nearest)
    movable = np.nonzero(in_pal < 0)[0]
    cands = {}
    for i in movable:
        best = cost[i].min()
        ok = np.nonzero((cost[i] <= best + 0.06) & (cost[i] <= max(0.16, best)))[0]
        cands[i] = ok[np.argsort(cost[i, ok])][:6]

    def broken(i, j, ai, aj):
        if ai == aj:
            return True
        dl = S[i, 0] - S[j, 0]
        if abs(dl) >= STEP_DL:
            dm = P[ai, 0] - P[aj, 0]
            if dm * dl < 0 and abs(dm) > 0.005:
                return True
        return False

    def local(i, ai):
        return ALPHA * cnt[i] * cost[i, ai] + sum(ww for j, ww in nbrs[i] if broken(i, j, ai, assign[j]))

    order = movable[np.argsort(-cnt[movable])]
    for _ in range(30):
        changed = 0
        for i in order:
            cur = assign[i]
            best_a, best_j = cur, local(i, cur)
            for c in cands[i]:
                jj = local(i, c)
                if jj < best_j - 1e-9:
                    best_a, best_j = c, jj
            if best_a != cur:
                assign[i] = best_a
                changed += 1
        if not changed:
            break

    def step_stats(asg):
        """Touching pixel pairs of two clearly different source colours, and the share whose two
        colours stay different (and, for light/shadow steps, keep which one is lighter) after the lock."""
        res = {}
        a1, a2, aw, ade = all_pairs
        for thr in (0.03, 0.05):
            tot = brk = tot_l = brk_l = 0
            for p, q, ww, de in zip(a1.tolist(), a2.tolist(), aw.tolist(), ade.tolist()):
                if de < thr:
                    continue
                b_ = broken(p, q, asg[p], asg[q])
                tot += ww
                brk += ww * b_
                if abs(S[p, 0] - S[q, 0]) >= STEP_DL:
                    tot_l += ww
                    brk_l += ww * b_
            res[f"oklab_dE_ge_{thr}"] = {
                "touching_pairs": tot, "kept_share": round(1 - brk / max(1, tot), 4),
                "light_shadow_pairs": tot_l, "light_shadow_kept_share": round(1 - brk_l / max(1, tot_l), 4)}
        return res

    naive = np.where(in_pal >= 0, in_pal, nearest)
    mapping = {hx(cols[i]): pal_hex[assign[i]] for i in range(n)}
    moved = {hx(cols[i]): {"nearest": pal_hex[nearest[i]], "chosen": pal_hex[assign[i]], "px": int(cnt[i])}
             for i in movable if assign[i] != nearest[i]}
    diag = {
        "source_colours": int(n), "already_in_palette": int((in_pal >= 0).sum()),
        "pixels_recoloured_by_lock": int(cnt[in_pal < 0].sum()),
        "steps_if_plain_nearest": step_stats(naive), "steps_after_ramp_protection": step_stats(assign),
        "moved_off_nearest_to_keep_a_step": moved,
        "mean_oklab_error_px_weighted": round(float((cost[np.arange(n), assign] * cnt).sum() / cnt.sum()), 4),
    }
    return mapping, diag


# ------------------------------------------------------------------ regional repairs
def bounds(cell):
    ys = np.nonzero((cell[..., 3] > 0).any(1))[0]
    return (int(ys[0]), int(ys[-1])) if len(ys) else (None, None)


def masks(cell):
    op = cell[..., 3] > 0
    L, C, Hh = lch(cell[..., :3])
    return op, L, C, Hh


def bright_gold(op, L, C, Hh):
    # saturated goggle rim gold (#e7bf69, #d0aa5f, #b29650): yellower than any skin tone. The pale
    # #e1c88f is left out on purpose: PixelLab also uses it as a cheek highlight next to the eye.
    return op & (Hh >= 76) & (Hh <= 100) & (C >= 0.09) & (L >= 0.6)


def shifted(mask, dy, dx):
    """out[y, x] = mask[y + dy, x + dx], False outside."""
    out = np.zeros_like(mask)
    H, W = mask.shape
    ys_s = slice(max(0, dy), H + min(0, dy))
    ys_d = slice(max(0, -dy), H - max(0, dy))
    xs_s = slice(max(0, dx), W + min(0, dx))
    xs_d = slice(max(0, -dx), W - max(0, dx))
    out[ys_d, xs_d] = mask[ys_s, xs_s]
    return out


def find_eyes(cell):
    """Eye pixels to recolour: ({(y, x): hex}, info). The eye must sit in the lower part of the face
    blob with skin right below it, away from the goggle gold."""
    op, L, C, Hh = masks(cell)
    y0, y1 = bounds(cell)
    if y0 is None:
        return {}, None
    band = np.zeros_like(op)
    band[y0:y0 + int(0.47 * (y1 - y0 + 1))] = True
    skin = op & (L >= 0.70) & (Hh >= 38) & (Hh <= 76) & (C >= 0.055) & (C <= 0.135)
    lab, n = ndimage.label(skin & band, np.ones((3, 3), bool))
    if n == 0:
        return {}, None
    big = int(np.argmax(ndimage.sum(np.ones_like(lab), lab, range(1, n + 1)))) + 1
    fy, fx = np.nonzero(lab == big)
    fy0, fy1, fx0, fx1 = int(fy.min()), int(fy.max()), int(fx.min()), int(fx.max())
    fh = fy1 - fy0 + 1
    win = np.zeros_like(op)
    win[max(fy0, int(fy1 - 0.65 * fh)):fy1 - 1, max(0, fx0 - 1):fx1 + 2] = True
    near_gold = ndimage.binary_dilation(bright_gold(op, L, C, Hh), np.ones((5, 5), bool))
    blue = op & (Hh >= 235) & (Hh <= 305) & (C >= 0.05) & (L >= 0.2)
    teal = op & (Hh >= 175) & (Hh < 235) & (C >= 0.035) & (L >= 0.28) & (L <= 0.72)
    cool = op & (L >= 0.78) & ((((Hh >= 140) & (Hh <= 310)) & (C <= 0.07)) | (C <= 0.015))
    sb = np.zeros_like(op)
    for dy in (1, 2):
        for dx in (-1, 0, 1):
            sb |= shifted(skin, dy, dx)
    seeds = (blue | teal) & win & ~near_gold & sb
    member = (blue | teal | cool) & band & ~near_gold   # growth may leave the window by up to 2 px
    eye = seeds.copy()
    for _ in range(2):
        eye |= ndimage.binary_dilation(eye, np.ones((3, 3), bool)) & member
    lab2, n2 = ndimage.label(eye, np.ones((3, 3), bool))
    out = {}
    for k in range(1, n2 + 1):
        ys, xs = np.nonzero(lab2 == k)
        if len(ys) > 8:   # an eye is a few pixels; a big blob is something else
            continue
        pale, dark = [], []
        for y, x in zip(ys.tolist(), xs.tolist()):
            (pale if L[y, x] >= 0.6 else dark).append((y, x, hx(cell[y, x])))
        for y, x, h in dark:
            if h not in EYE_KEEP:
                out[(y, x)] = EYE_DARK
        has_glint = any(h == EYE_GLINT for _, _, h in pale)
        for n_, (y, x, h) in enumerate(sorted(pale)):   # top first, then left: light from the top left
            if h not in EYE_KEEP:
                out[(y, x)] = EYE_GLINT if (n_ == 0 and not has_glint) else EYE_WHITE
    return out, {"face_rows": [fy0, fy1], "eye_window_rows": [max(fy0, int(fy1 - 0.65 * fh)), fy1 - 2]}


def lens_find(cell, locked, facing):
    """The lens of the front goggle in a side view. First choice: the hole inside the gold ring.
    Second choice: grey, cool or blue pixels touching the ring (where the ring is not closed).
    Returns (pixels, how, anchor); anchor = (front x of the head at goggle height, head top y).
    The ring is read from the palette-locked colours (gold, tan or cream), so a second run over the
    output finds the same hole; a pixel drawn grey or cool counts as lens even if the lock made it tan."""
    op, L, C, Hh = masks(cell)
    _, Lk, Ck, Hk = masks(locked)
    y0, _ = bounds(cell)
    if y0 is None:
        return [], "empty frame", None
    band = np.zeros_like(op)
    band[y0:y0 + 14] = True
    xs = np.nonzero(op & band)[1]
    xfront = int(xs.min()) if facing < 0 else int(xs.max())
    front = np.zeros_like(op)
    if facing < 0:
        front[:, xfront:xfront + 12] = True
    else:
        front[:, max(0, xfront - 11):xfront + 1] = True
    anchor = (xfront, y0)
    grey = (C < 0.03) & (L >= 0.45)   # includes white, so a painted glint still counts as lens
    cool = (Hh >= 150) & (Hh <= 310) & (C >= 0.025) & (L >= 0.35)
    # a grey or cool pixel is drawn lens even when the lock would turn it into a gold-brown
    ring = op & band & front & (Hk >= 55) & (Hk <= 100) & (Ck >= 0.05) & (Lk >= 0.5) & ~(grey | cool)
    holes = ndimage.binary_fill_holes(ring) & ~ring & op
    pts = set(zip(*[v.tolist() for v in np.nonzero(holes)]))
    if 0 < len(pts) <= 8:
        for (y, x) in list(pts):   # close one-pixel gaps inside a lens column
            if (y + 2, x) in pts and (y + 1, x) not in pts and op[y + 1, x] and L[y + 1, x] >= 0.15:
                pts.add((y + 1, x))
        return sorted(pts), "hole in the gold ring", anchor
    core = op & band & front & (grey | cool) & ndimage.binary_dilation(ring, np.ones((3, 3), bool))
    pts = sorted(zip(*[v.tolist() for v in np.nonzero(core)]))
    if 0 < len(pts) <= 8:
        return pts, "grey or cool pixels at the ring", anchor
    return [], "not found", anchor


def paint_lens(cell, pts):
    """Front-view lens order at side scale: glint top left, rest of the top row dark teal,
    teal in the middle, dark teal along the bottom (only when the lens is 3 or more rows tall)."""
    op, L, _, _ = masks(cell)
    pts = [(y, x) for (y, x) in pts if 0 <= y < CELL and 0 <= x < CELL and op[y, x] and L[y, x] >= 0.15]
    if not pts:
        return {}
    ymin, ymax = min(p[0] for p in pts), max(p[0] for p in pts)
    glint = min(p for p in pts if p[0] == ymin)
    out = {}
    for (y, x) in pts:
        if (y, x) == glint and (ymax > ymin or len(pts) > 1):
            out[(y, x)] = LENS_GLINT
        elif y == ymin and ymax - ymin >= 1:
            out[(y, x)] = LENS_DARK if ymax - ymin >= 2 else LENS_TEAL
        elif y == ymax and ymax - ymin >= 2:
            out[(y, x)] = LENS_DARK
        else:
            out[(y, x)] = LENS_TEAL
    return out


def lens_row(cells, lockeds, facing):
    """Per frame lens edits for one side row. A frame where no lens can be found borrows the lens
    pixels of the nearest frame that has one, moved with the head's front edge and top."""
    found = [lens_find(c, k, facing) for c, k in zip(cells, lockeds)]
    sizes = [len(fd[0]) for fd in found]
    med = float(np.median([s_ for s_ in sizes if s_])) if any(sizes) else 0.0
    edits, log = [], []
    for f, c in enumerate(cells):
        pts, how, anchor = found[f]
        if len(pts) < 0.5 * med and anchor is not None:
            # no lens, or a lens under half the row's usual size: take the nearest frame's lens too
            have = [g for g in range(len(cells)) if sizes[g] >= 0.5 * med and found[g][2] is not None]
            if have:
                g = min(have, key=lambda g: (min(abs(g - f), len(cells) - abs(g - f)), g))
                dx, dy = anchor[0] - found[g][2][0], anchor[1] - found[g][2][1]
                pts = sorted(set(pts) | {(y + dy, x + dx) for (y, x) in found[g][0]})
                how = f"{how}; filled out from f{g}"
        e = paint_lens(c, pts)
        edits.append(e)
        log.append({"source": how, "core_px": len(pts)})
    return edits, log


def find_far_leg(cell):
    op, L, C, Hh = masks(cell)
    y0, foot = bounds(cell)
    if y0 is None:
        return {}, []
    zone = np.zeros_like(op)
    zone[y0 + int(0.62 * (foot - y0 + 1)):] = True
    maroon = op & zone & (Hh >= 12) & (Hh <= 46) & (C >= 0.065) & (L >= 0.2) & (L <= 0.36)
    lab, nlab = ndimage.label(maroon, np.ones((3, 3), bool))
    out, comps = {}, []
    for k in range(1, nlab + 1):
        ys, xs = np.nonzero(lab == k)
        if len(ys) < 6:
            continue
        boot = float(ys.mean()) >= foot - 6
        col = BOOT_SHADE if boot else TROUSER_SHADOW
        for y, x in zip(ys.tolist(), xs.tolist()):
            out[(y, x)] = col
        comps.append({"px": int(len(ys)), "y": [int(ys.min()), int(ys.max())], "part": "boot" if boot else "leg", "to": col})
    return out, comps


# ------------------------------------------------------------------ main
def fix_colour(atlas):
    atlas = atlas.copy()
    soft = int(((atlas[..., 3] > 0) & (atlas[..., 3] < 255)).sum())
    atlas[..., 3] = np.where(atlas[..., 3] >= 128, 255, 0).astype(np.uint8)
    atlas[atlas[..., 3] == 0] = 0
    pal, _ = build_palette()
    mapping, diag = lock_map(atlas, pal)
    out = atlas.copy()
    op = atlas[..., 3] > 0
    lut = {k: rgb(v) for k, v in mapping.items()}
    out[..., :3][op] = np.array([lut[hx(c)] for c in atlas[..., :3][op]], np.uint8)

    log = {"soft_alpha_px_hardened": soft, "palette_size": int(len(pal)),
           "palette": [hx(p) for p in pal], "rd_extras": RD_EXTRAS, "lock": diag,
           "eyes": {}, "lens": {}, "far_leg": {}}

    def cell(a, r, f):
        return a[r * CELL:(r + 1) * CELL, f * CELL:(f + 1) * CELL]

    for r, row in enumerate(ROWS):
        srcs = [cell(atlas, r, f) for f in range(8)]
        lens_edits = [{}] * 8
        if row in SIDE_ROWS:
            lens_edits, lens_log = lens_row(srcs, [cell(out, r, f).copy() for f in range(8)], SIDE_ROWS[row])
            for f in range(8):
                log["lens"][f"{row}_f{f}"] = dict(lens_log[f], px=[[y, x, hx(srcs[f][y, x]), v] for (y, x), v in sorted(lens_edits[f].items())])
        for f in range(8):
            src, dst, key = srcs[f], cell(out, r, f), f"{row}_f{f}"
            edits = {}
            if row in FACE_ROWS:
                e, _ = find_eyes(src)
                if e:
                    log["eyes"][key] = [[y, x, hx(src[y, x]), v] for (y, x), v in sorted(e.items())]
                edits.update(e)
            edits.update(lens_edits[f])
            leg, comps = find_far_leg(src)
            if leg:
                log["far_leg"][key] = comps
                edits.update(leg)
            for (y, x), v in edits.items():
                dst[y, x, :3] = rgb(v)
    assert np.array_equal(out[..., 3], atlas[..., 3])
    return out, log


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    a = load(sys.argv[1])
    if a.shape[:2] != (CELL * 8, CELL * 8):
        raise SystemExit(f"expected a 640x640 atlas, got {a.shape[1]}x{a.shape[0]}")
    out, log = fix_colour(a)
    Image.fromarray(out, "RGBA").save(sys.argv[2])
    if len(sys.argv) > 3:
        Path(sys.argv[3]).write_text(json.dumps(log, indent=1), encoding="utf-8")
    lk = log["lock"]
    print(f"palette {log['palette_size']} colours; {lk['source_colours']} source colours, "
          f"{lk['already_in_palette']} already in it; {lk['pixels_recoloured_by_lock']} px locked")
    print("steps kept, plain nearest:", lk["steps_if_plain_nearest"])
    print("steps kept, ramp-protected:", lk["steps_after_ramp_protection"])
    print(f"eyes repaired in {len(log['eyes'])} frames, lens in "
          f"{sum(1 for v in log['lens'].values() if v['px'])} frames, far leg in {len(log['far_leg'])} frames")


if __name__ == "__main__":
    main()
