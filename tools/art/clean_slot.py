"""Light clean-up of a generated slot candidate, made again from its raw (Claude, 2026-10-28, placeholder factory;
written for Grok's gb-01 to gb-07 batches, which tools/art/validate_slot.py failed on C9 specks, C8 frame health,
C2 colours and C6 seams).

    python tools/art/clean_slot.py <slot_id> <slot_folder> [--flip STATE] [--mixed 0.5] [--thin-outline 0.6]
                                                                           writes <slot_folder>/cleaned.png
    python tools/art/clean_slot.py <slot_id> <raw.png> <out.png>
    python tools/art/clean_slot.py --sheet <batch_folder>     writes <batch_folder>/cleanup_sheet.png from cleaned.png
    python tools/art/clean_slot.py --hold <slot_folder> --reason "why"   marks cleaned.png as held (not to install)

With a folder it reads raw_<state>.png for each state row when they all exist (the lamp's raw_unlit.png and
raw_lit.png, in the slot's state_order), otherwise raw.png cut into the slot's grid as prepare_slot.py cuts it. It
never touches prepared.png. Beside cleaned.png it writes cleaned.png.clean.json (settings and what was changed).
Then run tools/art/validate_slot.py <slot_id> <slot_folder>/cleaned.png, then --sheet.

--hold writes <slot_folder>/cleaned.png.hold.json; the sheet then shows HOLD in red under the cleaned piece. It is a
note for whoever installs, not a lock (install_slot.py does not read it). A clean-up rerun keeps it; delete the file
to lift the hold.

Settings used on 2026-10-28 for the 29 gb-01 to gb-07 slots: the defaults (--mixed 0.5 --keep 40) for all, and
--flip lit for town.lamp.post (Grok drew its lit lamp with the bracket on the left, the unlit one on the right).
After the look pass the same day: town.prop.fence_v made again with --thin-outline 0.5 (the first clean-up had more
black on its lower rail than prepared.png: in this palette the next darker shade of the dark-brown rail is the black
outline, so step 3 split the rail with black. With --mixed 0.5 a block under half one colour already takes its mean,
so at 0.5 the block rule changes nothing and only step 3's no-outline rule acts; 0.6 and up also thinned the
bottom post tip and failed C6). Both town.prop.fence_v (drawn corner to corner, so a vertical run
leaves gaps) and title.hud_piece.menu_cursor (points up, not right at the menu item) put on --hold for a redraw.

What it does, in order. All of it is light finishing: Preston's 2026-10-13 call was that heavy finishing made
generated art worse, so nothing is repainted, sharpened or re-outlined.
 1. Keys the backdrop. Grok's backdrops are hot pinks from about #E6248C to #F95ED4, wider than prepare_slot.py's
    key (60 from #FF00FF), so its pink was snapped into flat beige, grey or orange boxes (the C8 failures). Here a
    pixel is backdrop-like when min(R, B) - G >= 60; every backdrop-like patch joined to the picture's border is keyed,
    and so is an enclosed patch whose mean is within 90 of the border's backdrop (the gaps between fence rails),
    plus the pinkish edge blend (min(R, B) - G >= 30) within 3 raw pixels of it. Pinks inside the object stay.
    Raw specks under 0.02% of the picture are dropped before the content box is measured.
 2. Snaps every raw pixel to the slot's palette strip (the same nearest-colour snap as prepare_slot.py), then
    downscales by mode: each output pixel takes the palette colour most of its raw block shows. A box filter
    averages, and averages snap to stray in-between colours, which are the specks C9 counts. With --mixed 0.5, a
    block whose commonest colour covers under half of it (all fine detail: jars, lettering-like marks, chains) takes
    its snapped mean instead, which keeps those details reading as they did in prepared.png rather than as black
    blobs of outline. With --thin-outline SHARE (off by default), an outline colour (palette luma under 40) wins a
    block only when it covers SHARE or more of it; otherwise the block takes its commonest other colour, and step 3
    never shades into an outline colour. That is for a raw drawn with outlines so thick that the mode keeps more
    black than the art shows at game size. A block is opaque when at least half of it is. The fit is prepare_slot.py's: the content box
    scaled into the space the slot's edges allow, on the foot row, clear of edges it may not touch. Every cell of a
    sheet shares one content box and one scale; state rows drawn as separate pictures are first moved so their feet
    meet (--flip mirrors a state drawn facing the other way), so the game's state swap does not jump.
 3. Only when one flat colour still covers 25% or more of a cell (C8): splits that flat with a lighter and a darker
    palette shade where the raw itself is lighter or darker (its block brightness, smoothed), so the light stays
    where the art drew it (upper-left, as C12 checks). Each shade is the palette colour, lighter or darker than the
    flat, nearest to the raw's own mean colour there. No new detail.
 4. Keeps to the slot's colour budget (C2) by folding the rarest colour into its nearest used colour.
 5. Removes orphan pixels (no same-coloured neighbour up, down, left or right; C9) by majority: an orphan takes the
    colour most of its eight neighbours share, among the colours touching its sides (ties go to the nearest colour).
    A pixel touching nothing at its sides is dropped. With --keep 40, an orphan at least 40 brighter or darker (luma)
    than the colour that would swallow it is a detail (a jar rim, a highlight, a rope strand): it is kept by giving it
    a partner instead, the side neighbour nearest its colour, when that orphans nothing else. Steps 3 and 5 repeat
    (up to four times) until both hold.
 6. Tiling slots (C6): a span drawn sloping (its far tiling edge the same run of pixels as its near edge, shifted)
    is levelled by shearing the raw so columns stay upright, then made again; when the edges then differ by at most
    a one-pixel step, the far edge line is set to the near one so the tile meets itself. Anything else is left
    alone and reported.
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402
from finish_sprite import components  # noqa: E402

BG_MAGENTA = 60       # min(R, B) - G at or above this is backdrop-like
BG_NEAR = 90          # an enclosed backdrop-like patch is keyed when its mean is this close to the border's backdrop
FRINGE = 3            # raw pixels of pinkish edge blend keyed next to the backdrop
FRINGE_MAGENTA = 30
SPECK_SHARE = 0.0002  # raw specks below this share of the picture are dropped before the content box
FLAT = 0.25           # C8: one colour region at or above this share of a cell fails
OUTLINE_LUMA = 40     # palette colours darker than this are outline colours (--thin-outline)


def luma(rgb):
    rgb = np.asarray(rgb, float)
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


def backdrop(rgb: np.ndarray) -> np.ndarray:
    """True where the raw shows backdrop (step 1)."""
    c = rgb.astype(int)
    m = np.minimum(c[..., 0], c[..., 2]) - c[..., 1]
    lab, n = ndimage.label(m >= BG_MAGENTA)
    edge = np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))
    edge = edge[edge > 0]
    bg = np.isin(lab, edge)
    if bg.any() and n:
        ref = np.median(c[bg], axis=0)
        ids = np.arange(1, n + 1)
        means = np.stack([ndimage.mean(c[..., k], lab, ids) for k in range(3)], 1)
        near = ids[np.sqrt(((means - ref) ** 2).sum(1)) < BG_NEAR]
        bg |= np.isin(lab, near)
        bg |= ndimage.binary_dilation(bg, iterations=FRINGE) & (m >= FRINGE_MAGENTA)
    lab, n = ndimage.label(~bg, structure=np.ones((3, 3)))
    if n:
        sizes = ndimage.sum(np.ones_like(lab), lab, np.arange(1, n + 1))
        small = np.arange(1, n + 1)[sizes < SPECK_SHARE * bg.size]
        bg |= np.isin(lab, small)
    return bg


def snap_index(rgb: np.ndarray, pal: np.ndarray) -> np.ndarray:
    """Palette index of every pixel, nearest colour in RGB (prepare_slot.py's snap)."""
    c = rgb.astype(np.int64)
    key = (c[..., 0] << 16) | (c[..., 1] << 8) | c[..., 2]
    uniq, inv = np.unique(key.reshape(-1), return_inverse=True)
    cols = np.stack([(uniq >> 16) & 255, (uniq >> 8) & 255, uniq & 255], 1)
    out = np.empty(len(uniq), int)
    p = pal.astype(np.int64)
    for i in range(0, len(cols), 32768):
        out[i:i + 32768] = ((cols[i:i + 32768, None, :] - p[None]) ** 2).sum(-1).argmin(1)
    return out[inv.reshape(-1)].reshape(key.shape)


def own_palette(parts, budget: int) -> np.ndarray:
    """No strip yet: the raw's own colours cut to the budget by median cut, as prepare_slot.py does."""
    px = np.concatenate([p[~bg] for p, bg in parts])[:, :3]
    strip = Image.fromarray(px.reshape(-1, 1, 3).astype(np.uint8), "RGB")
    q = strip.quantize(colors=min(budget, 256), method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    return np.array(q.getpalette()[: 3 * len(q.getcolors())], dtype=np.uint8).reshape(-1, 3)


def raw_parts(s: dict, folder: Path = None, raw: Path = None) -> list:
    """One RGB array per cell, in sheet order (row by row, frame by frame)."""
    rows, frames = s["rows"], s["frames"]
    states = s.get("state_order") or []
    if folder is not None and rows > 1 and frames == 1 and len(states) == rows \
            and all((folder / f"raw_{st}.png").is_file() for st in states):
        return [np.asarray(Image.open(folder / f"raw_{st}.png").convert("RGB")) for st in states]
    img = np.asarray(Image.open(raw if raw is not None else folder / "raw.png").convert("RGB"))
    h, w = img.shape[:2]
    return [img[h * r // rows:h * (r + 1) // rows, w * f // frames:w * (f + 1) // frames]
            for r in range(rows) for f in range(frames)]


def mode_down(idx, bg, rgb, box, nw, nh, pal, mixed=0.0, outline=0.0):
    """Step 2: one palette index per output pixel, the most common in its raw block; -1 where under half is solid.
    With mixed > 0, a block whose commonest colour covers less than that share takes its snapped mean instead
    (prepare_slot.py's look, for blocks that are all fine detail). With outline > 0, an outline colour wins a block
    only when it covers that share of it; otherwise the block's commonest other colour wins (--thin-outline)."""
    dark = luma(pal) < OUTLINE_LUMA
    x0, y0, x1, y1 = box
    xs = np.floor(np.arange(nw + 1) * (x1 - x0) / nw).astype(int) + x0
    ys = np.floor(np.arange(nh + 1) * (y1 - y0) / nh).astype(int) + y0
    out = np.full((nh, nw), -1, int)
    bright = np.full((nh, nw), np.nan)
    meanc = np.full((nh, nw, 3), np.nan)
    lum = luma(rgb)
    p = pal.astype(int)
    for j in range(nh):
        for i in range(nw):
            sl = (slice(ys[j], max(ys[j + 1], ys[j] + 1)), slice(xs[i], max(xs[i + 1], xs[i] + 1)))
            solid = ~bg[sl]
            if solid.size == 0 or solid.mean() < 0.5:
                continue
            counts = np.bincount(idx[sl][solid], minlength=len(pal))
            out[j, i] = int(counts.argmax())
            if outline and dark[out[j, i]] and counts.max() < outline * solid.sum():
                rest = np.where(dark, 0, counts)
                if rest.max() > 0:
                    out[j, i] = int(rest.argmax())
            mean = rgb[sl][solid].astype(float).mean(0)
            if mixed and counts.max() < mixed * solid.sum():
                out[j, i] = int(((p - mean) ** 2).sum(1).argmin())
            bright[j, i] = float(lum[sl][solid].mean())
            meanc[j, i] = mean
    return out, bright, meanc


def shear(p: np.ndarray, bg: np.ndarray, box, drop: float, axis: str):
    """Shifts each raw column (axis h) down by drop * its place across the content box, or each row (axis v)
    right, so a span drawn sloping meets itself when tiled. Columns stay upright."""
    x0, y0, x1, y1 = box
    n = int(np.ceil(abs(drop))) + 1
    if axis == "h":
        H, W = bg.shape
        P = np.zeros((H + 2 * n, W, 3), p.dtype)
        B = np.ones((H + 2 * n, W), bool)
        for x in range(W):
            t = min(max((x - x0) / max(1, x1 - x0 - 1), 0.0), 1.0)
            dy = n + int(round(drop * t))
            P[dy:dy + H, x] = p[:, x]
            B[dy:dy + H, x] = bg[:, x]
        return P, B
    P2, B2 = shear(np.swapaxes(p, 0, 1), bg.T, (y0, x0, y1, x1), drop, "h")
    return np.swapaxes(P2, 0, 1), B2.T


def seam_offset(g, tiling: str):
    """How far the far tiling edge line sits from the near one (output pixels), when the two are the same run of
    pixels shifted; None when they are not."""
    if tiling not in ("h", "v"):
        return None
    a, b = (g[:, 0] >= 0, g[:, -1] >= 0) if tiling == "h" else (g[0] >= 0, g[-1] >= 0)
    if not a.any() or not b.any():
        return None
    best, best_d = 0.0, 0
    for d in range(-len(a) // 2, len(a) // 2 + 1):
        s = np.roll(a, d)
        iou = (s & b).sum() / max(1, (s | b).sum())
        if iou > best:
            best, best_d = iou, d
    return best_d if best >= 0.6 else None


def place(s: dict, nw: int, nh: int, foot_x=None):
    """Top-left of the content in its cell, and the cell's foot row: prepare_slot.py's fit, except that a foot slot
    puts the middle of the content's foot (foot_x, from the content's left) on the anchor rather than the middle of
    its box, so a lamp with a bracket out to one side still stands its post on the anchor."""
    cw, ch = s["size"]
    allowed = reg.allowed_sides(s["edges"])
    left = 0 if "left" in allowed else 1
    top = 0 if "top" in allowed else 1
    right = cw - (0 if "right" in allowed else 1)
    foot = s["anchor"][1] if s.get("anchor_mode") == "foot" else ch - (0 if "bottom" in allowed else 1) - 1
    bw, bh = right - left, foot + 1 - top
    if s.get("anchor_mode") == "foot":
        mid = nw / 2 if foot_x is None else foot_x
        x = min(max(left, int(round(s["anchor"][0] - mid))), right - nw)
    else:
        x = left + (bw - nw) // 2
    y = foot + 1 - nh
    if s.get("anchor_mode") != "foot" and s["kind"] in ("hud_piece", "hud_icon", "effect", "character"):
        y = top + (bh - nh) // 2
    return x, y, foot, (left, top, right, foot)


def neighbours8(g, y, x):
    H, W = g.shape
    side, ring = [], []
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dy == 0 and dx == 0:
                continue
            ny, nx = y + dy, x + dx
            v = g[ny, nx] if 0 <= ny < H and 0 <= nx < W else -1
            ring.append(v)
            if dy == 0 or dx == 0:
                side.append(v)
    return side, ring


def orphan_mask(g):
    pad = np.pad(g, 1, constant_values=-2)
    H, W = g.shape
    same = np.zeros(g.shape, bool)
    for dy, dx in ((0, 1), (2, 1), (1, 0), (1, 2)):
        same |= pad[dy:dy + H, dx:dx + W] == g
    return (g >= 0) & ~same


def _pair(g, y, x, p, keep):
    """A detail orphan (keep or more brighter or darker than what would swallow it: a highlight, a jar's rim, a
    lettering-like mark) is kept by giving it a partner instead: the side neighbour closest to its colour takes its
    colour, unless that would orphan one of the neighbour's own partners. Returns True when it paired."""
    H, W = g.shape
    c = g[y, x]
    best = None
    for qy, qx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
        if not (0 <= qy < H and 0 <= qx < W) or g[qy, qx] < 0:
            continue
        q = g[qy, qx]
        safe = True
        for ry, rx in ((qy - 1, qx), (qy + 1, qx), (qy, qx - 1), (qy, qx + 1)):
            if (ry, rx) == (y, x) or not (0 <= ry < H and 0 <= rx < W) or g[ry, rx] != q:
                continue
            others = [(sy, sx) for sy, sx in ((ry - 1, rx), (ry + 1, rx), (ry, rx - 1), (ry, rx + 1))
                      if (sy, sx) != (qy, qx) and 0 <= sy < H and 0 <= sx < W and g[sy, sx] == q]
            if not others:
                safe = False
        if safe:
            d = int(((p[q] - p[c]) ** 2).sum())
            if best is None or d < best[0]:
                best = (d, qy, qx)
    if best is None:
        return False
    g[best[1], best[2]] = c
    return True


def clear_orphans(g, pal, keep=0.0):
    """Step 5, in place, one pixel at a time so two neighbouring orphans cannot swap colours forever."""
    p = pal.astype(int)
    lum = luma(pal)
    for _ in range(12):
        ys, xs = np.nonzero(orphan_mask(g))
        if not len(ys):
            break
        for y, x in zip(ys.tolist(), xs.tolist()):
            c = g[y, x]
            side, ring = neighbours8(g, y, x)
            if c < 0 or c in side:
                continue
            opts = sorted({v for v in side if v >= 0})
            if not opts:
                g[y, x] = -1
                continue
            score = [(ring.count(v), -int(((p[v] - p[c]) ** 2).sum())) for v in opts]
            m = opts[max(range(len(opts)), key=lambda i: score[i])]
            if keep and abs(lum[c] - lum[m]) >= keep and _pair(g, y, x, p, keep):
                continue
            g[y, x] = m
    return g


def shade(pal, c, lighter: bool, allowed=None, near=None):
    """The palette colour lighter (or darker) than colour c by a visible step that is nearest to near (the raw's
    own mean colour where it is lighter or darker), or to c itself when there is no such mean."""
    lum = luma(pal)
    p = pal.astype(int)
    ok = lum > lum[c] + 6 if lighter else lum < lum[c] - 6
    if allowed is not None:
        ok &= allowed
    if not ok.any():
        return None
    ref = p[c] if near is None or not np.isfinite(near).all() else np.asarray(near, float)
    d = ((p - ref) ** 2).sum(1).astype(float)
    d[~ok] = np.inf
    return int(d.argmin())


def biggest_flat(g):
    m = g >= 0
    if not m.any():
        return 0.0, None
    lab, sizes = components(g, True)
    k = int(np.argmax(sizes))
    return sizes[k] / m.sum(), lab == k


def break_flats(g, bright, pal, allowed=None, meanc=None, target=FLAT - 0.03):
    """Step 3: split a flat of FLAT or more by the raw's own light and dark, with neighbouring palette shades.
    It aims a little under FLAT, because the orphan pass afterwards folds some split pixels back."""
    if biggest_flat(g)[0] < FLAT:
        return g
    for _ in range(6):
        share, region = biggest_flat(g)
        if share < target:
            break
        c = int(g[region][0])
        # Smooth the raw's block brightness inside the flat, so the split follows its shading, not its noise.
        b = np.where(region, np.nan_to_num(bright, nan=0.0), 0.0)
        w = ndimage.uniform_filter(region.astype(float), 3)
        sm = np.where(region, ndimage.uniform_filter(b, 3) / np.maximum(w, 1e-6), np.nan)
        vals = sm[region]
        changed = False
        # Thin bands first; wider ones only while the flat still covers the target share.
        for q in (0.2, 1 / 3, 0.4, 0.45, 0.5):
            hi = np.quantile(vals, 1 - q)
            lo = np.quantile(vals, q)
            up = region & (sm >= hi) & (sm > lo)
            down = region & (sm <= lo) & (sm < hi)
            hi_c = shade(pal, c, True, allowed, meanc[up].mean(0) if meanc is not None and up.any() else None)
            lo_c = shade(pal, c, False, allowed, meanc[down].mean(0) if meanc is not None and down.any() else None)
            trial = g.copy()
            if hi_c is not None:
                trial[up] = hi_c
            if lo_c is not None:
                trial[down] = lo_c
            if (trial != g).any():
                share2, _ = biggest_flat(trial)
                if share2 < target or q == 0.5:
                    g[:] = trial
                    changed = True
                    break
        if not changed:
            break
    return g


def fold_budget(cells, pal, budget):
    """Step 4: fold the rarest colour into its nearest used colour until the sheet keeps to the budget."""
    if budget <= 0:
        return cells
    p = pal.astype(int)
    while True:
        allv = np.concatenate([c[c >= 0] for c in cells])
        used, counts = np.unique(allv, return_counts=True)
        if len(used) <= budget:
            return cells
        rare = int(used[counts.argmin()])
        others = used[used != rare]
        to = int(others[((p[others] - p[rare]) ** 2).sum(1).argmin()])
        for c in cells:
            c[c == rare] = to


def match_seam(g, tiling: str):
    """Step 6: a tiling edge line set to its partner when the two differ by at most a one-pixel step."""
    if tiling not in ("h", "v", "hv"):
        return g, "no tiling"
    notes = []
    for axis in (("h",) if tiling == "h" else ("v",) if tiling == "v" else ("h", "v")):
        a, b = (g[:, 0], g[:, -1]) if axis == "h" else (g[0], g[-1])
        diff = int((a != b).sum())
        if diff == 0:
            notes.append(f"{axis} seam already meets")
            continue
        # Opaque runs on each side; allow only a one-pixel shift of the same pattern.
        ok = any(np.array_equal(np.roll(a >= 0, k), b >= 0) for k in (-1, 0, 1))
        if not ok:
            notes.append(f"{axis} seam left: {diff} of {len(a)} pixels differ in shape, not a one-pixel step")
            continue
        if axis == "h":
            g[:, -1] = g[:, 0]
        else:
            g[-1] = g[0]
        notes.append(f"{axis} seam matched ({diff} pixels)")
    return g, "; ".join(notes)


def align_feet(keyed):
    """State rows drawn as separate pictures put the post in different places. Each part is moved so its foot (the
    middle of its lowest 8% of rows) sits where the first part's foot sits, so the game's state swap does not jump."""
    feet = []
    for p, bg in keyed:
        ys, xs = np.nonzero(~bg)
        if not ys.size:
            feet.append((0, 0))
            continue
        y1, y0 = ys.max(), ys.min()
        low = ys >= y1 - max(1, int(0.08 * (y1 - y0)))
        feet.append((int(round(xs[low].mean())), int(y1)))
    offs = [(feet[0][0] - fx, feet[0][1] - fy) for fx, fy in feet]
    mx, my = min(o[0] for o in offs), min(o[1] for o in offs)
    W = max(bg.shape[1] + o[0] - mx for (p, bg), o in zip(keyed, offs))
    H = max(bg.shape[0] + o[1] - my for (p, bg), o in zip(keyed, offs))
    out = []
    for (p, bg), (ox, oy) in zip(keyed, offs):
        P = np.zeros((H, W, 3), p.dtype)
        B = np.ones((H, W), bool)
        x, y = ox - mx, oy - my
        P[y:y + p.shape[0], x:x + p.shape[1]] = p
        B[y:y + p.shape[0], x:x + p.shape[1]] = bg
        out.append((P, B))
    return out, offs


def content_box(keyed):
    """One content box for every cell (the union, in each part's own coordinates), so state rows stay aligned."""
    boxes = []
    for p, bg in keyed:
        ys, xs = np.nonzero(~bg)
        if ys.size:
            boxes.append((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    if not boxes:
        raise ValueError("nothing left after keying the backdrop")
    return (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))


def render(s, keyed, pal, budget, mixed, keep, outline=0.0):
    """Steps 2 to 5 for every cell: (cells as palette-index grids, the scale used, the content size)."""
    box = content_box(keyed)
    cw, ch = s["size"]
    area = place(s, 1, 1)[3]
    bw, bh = area[2] - area[0], area[3] + 1 - area[1]
    k = min(bw / (box[2] - box[0]), bh / (box[3] - box[1]))
    nw, nh = max(1, int((box[2] - box[0]) * k)), max(1, int((box[3] - box[1]) * k))
    foot_x = None
    if s.get("anchor_mode") == "foot":
        ys, xs = np.nonzero(~keyed[0][1][box[1]:box[3], box[0]:box[2]])
        low = ys >= ys.max() - max(1, int(0.08 * (ys.max() - ys.min())))
        foot_x = (xs[low].mean() + 0.5) * k
    x, y, foot, _ = place(s, nw, nh, foot_x)
    cells, brights = [], []
    for p, bg in keyed:
        idx = snap_index(p, pal)
        small, bright, meanc = mode_down(idx, bg, p, box, nw, nh, pal, mixed, outline)
        g = np.full((ch, cw), -1, int)
        b = np.full((ch, cw), np.nan)
        mc = np.full((ch, cw, 3), np.nan)
        g[y:y + nh, x:x + nw] = small
        b[y:y + nh, x:x + nw] = bright
        mc[y:y + nh, x:x + nw] = meanc
        cells.append(g)
        brights.append((b, mc))
    fold_budget(cells, pal, budget)
    used = np.zeros(len(pal), bool)
    for g in cells:
        used[np.unique(g[g >= 0])] = True
    # At the budget, the flat-breaking shades come from colours the sheet already uses.
    allowed = used if budget and used.sum() >= budget else None
    if outline:
        # --thin-outline: a flat is never split into an outline colour (that is a jump, not a neighbouring shade).
        allowed = (np.ones(len(pal), bool) if allowed is None else allowed) & (luma(pal) >= OUTLINE_LUMA)
    stats ={"orphans": sum(int(orphan_mask(g).sum()) for g in cells), "split": 0}
    for g, (b, mc) in zip(cells, brights):
        for _ in range(4):
            before = g.copy()
            break_flats(g, b, pal, allowed, mc)
            stats["split"] += int((before != g).sum())
            clear_orphans(g, pal, keep)
            if biggest_flat(g)[0] < FLAT:
                break
    fold_budget(cells, pal, budget)
    for g in cells:
        clear_orphans(g, pal, keep)
    return cells, k, (nw, nh, x, y, foot), stats


def clean(slot_id: str, folder: Path = None, raw: Path = None, out: Path = None, log=print,
          flip=(), mixed=0.5, keep=40.0, outline=0.0) -> Path:
    s = reg.spec(slot_id)
    if s["alpha"] == "opaque":
        raise ValueError(f"{slot_id} is an opaque slot; clean_slot.py handles cut-out props")
    parts = raw_parts(s, folder, raw)
    # --flip: a state row drawn facing the other way is mirrored, so the states line up when the game swaps them.
    states = s.get("state_order") or []
    parts = [p[:, ::-1] if (i < len(states) and states[i] in flip) else p for i, p in enumerate(parts)]
    keyed = [(p, backdrop(p)) for p in parts]
    notes = [f"flipped {', '.join(flip)}"] if flip else []
    if len(keyed) > 1 and len(states) == len(keyed) and s.get("anchor_mode") == "foot":
        keyed, offs = align_feet(keyed)
        notes.append("state feet aligned (raw shifts " + ", ".join(f"{a:+d},{b:+d}" for a, b in offs) + ")")
    pal = reg.palette(s)
    budget = int(s["palette"].get("max", 0))
    pal = own_palette(keyed, budget or 256) if pal is None else np.asarray(pal, np.uint8)
    tiling = s.get("tiling", "none")
    cw, ch = s["size"]
    cells, k, (nw, nh, x, y, foot), stats = render(s, keyed, pal, budget, mixed, keep, outline)
    # Step 6: a span drawn sloping cannot meet itself; level it with a shear of the raw (columns stay upright).
    d = seam_offset(cells[0], tiling)
    if d:
        box = content_box(keyed)
        drop = -d / k
        keyed = [shear(p, bg, box, drop, tiling) for p, bg in keyed]
        cells, k, (nw, nh, x, y, foot), stats = render(s, keyed, pal, budget, mixed, keep, outline)
        notes.append(f"{tiling} span levelled: its far edge sat {d:+d} px from its near edge")
    notes.append(f"{stats['orphans']} orphans after the downscale, cleared")
    if stats["split"]:
        notes.append(f"{stats['split']} px re-shaded to break a flat (C8)")
    for i, g in enumerate(cells):
        if tiling in ("h", "v", "hv"):
            _, note = match_seam(g, tiling)
            notes.append(note)
            clear_orphans(g, pal, keep)
            match_seam(g, tiling)
        if s.get("anchor_mode") == "foot":
            rows = np.nonzero((g >= 0).any(axis=1))[0]
            if rows.size and rows.max() != foot:
                cells[i] = np.roll(g, foot - int(rows.max()), axis=0)
    sheet = np.zeros((s["sheet_size"][1], s["sheet_size"][0], 4), np.uint8)
    n = 0
    for r in range(s["rows"]):
        for f in range(s["frames"]):
            g = cells[n]
            n += 1
            cell = np.zeros((ch, cw, 4), np.uint8)
            m = g >= 0
            cell[m, :3] = pal[g[m]]
            cell[m, 3] = 255
            sheet[r * ch:(r + 1) * ch, f * cw:(f + 1) * cw] = cell
    if out is None:
        out = folder / "cleaned.png"
    Image.fromarray(sheet, "RGBA").save(out)
    # What was done and with which settings, beside the picture, so the sheet and a later rerun can read it.
    record = {"slot": slot_id, "source": str(folder or raw), "date_tool": "clean_slot.py 2026-10-28",
              "settings": {"mixed": mixed, "keep": keep, "flip": list(flip), "thin_outline": outline},
              "notes": notes}
    Path(str(out) + ".clean.json").write_text(json.dumps(record, indent=1) + "\n", encoding="utf-8")
    m = sheet[..., 3] > 0
    ncol = len(np.unique(sheet[m][:, :3], axis=0)) if m.any() else 0
    log(f"cleaned {slot_id}: content {nw}x{nh} at ({x},{y}), {ncol} colours, {int(m.sum())} opaque pixels -> {out}"
        + (f"; {'; '.join(notes)}" if notes else ""))
    return out


# ---- the before/after sheet for Preston ----------------------------------------------------------------------

BACK, PANEL, INK, DIM = (28, 31, 28), (36, 43, 37), (255, 244, 232), (150, 150, 140)
COLOURS = {"PASS": (120, 200, 120), "WARN": (232, 196, 90), "FAIL": (232, 96, 80)}


def font(size: int):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def checker(w, h):
    img = Image.new("RGBA", (w, h), (52, 56, 58, 255))
    d = ImageDraw.Draw(img)
    for yy in range(0, h, 8):
        for xx in range((yy // 8) % 2 * 8, w, 16):
            d.rectangle([xx, yy, xx + 7, yy + 7], fill=(64, 68, 70, 255))
    return img


def change_notes(d: Path) -> list:
    """Plain lines for the changes beyond the clean-up itself, from cleaned.png.clean.json and the picture."""
    out = []
    rec = d / "cleaned.png.clean.json"
    data = json.loads(rec.read_text(encoding="utf-8")) if rec.is_file() else {}
    notes = data.get("notes", [])
    if data.get("settings", {}).get("thin_outline"):
        out.append("Thinner outline: a pixel is black only where the raw is mostly black there "
                   f"(--thin-outline {data['settings']['thin_outline']}).")
    for n in notes:
        if n.startswith("flipped"):
            out.append(f"Mirrored the {n.split(' ', 1)[1]} row so both rows face the same way.")
        elif n.startswith("state feet aligned"):
            out.append("Both rows stand on the same spot, so the swap does not jump.")
        elif "span levelled" in n:
            out.append("Rails levelled so the span meets itself when tiled (" + n.split(": ", 1)[1] + ").")
    s = reg.spec(d.name)
    t = s.get("tiling", "none")
    a = np.asarray(Image.open(d / "cleaned.png").convert("RGBA"))[..., 3] > 0
    if t in ("v", "hv") and (not a[0].any() or not a[-1].any()):
        out.append("Does not reach both the top and bottom edges, so a vertical stack will not join (C6 passes on "
                   "numbers only).")
    if t in ("h", "hv") and (not a[:, 0].any() or not a[:, -1].any()):
        out.append("Does not reach both side edges, so a row will not join (C6 passes on numbers only).")
    return [(INK, x) for x in out]


def hold(folder: Path, reason: str) -> Path:
    """Marks a slot's cleaned.png as held: it passes or not, it should not be installed until redrawn or decided."""
    out = folder / "cleaned.png.hold.json"
    out.write_text(json.dumps({"slot": folder.name, "hold": True, "reason": reason,
                               "date_tool": "clean_slot.py --hold 2026-10-28"}, indent=1) + "\n", encoding="utf-8")
    return out


def hold_lines(d: Path) -> list:
    rec = d / "cleaned.png.hold.json"
    if not rec.is_file():
        return []
    return [(COLOURS["FAIL"], "HOLD, do not install: " + json.loads(rec.read_text(encoding="utf-8"))["reason"])]


def check_summary(path: Path) -> list:
    """(colour, text) lines: the verdict, then every line that is not a PASS."""
    if not path.is_file():
        return [(DIM, "no check yet")]
    rep = json.loads(path.read_text(encoding="utf-8"))
    bad = [r for r in rep["results"] if r["result"] != "PASS"]
    n = len(rep["results"])
    head = (COLOURS["PASS"], f"PASS, all {n} scripted checks") if rep["pass"] else \
        (COLOURS["FAIL"], "FAIL: " + ", ".join(r["id"] for r in bad if r["result"] == "FAIL"))
    return [head] + [(COLOURS[r["result"]], f"{r['result']} {r['id']} {r['name']}: {r['detail']}") for r in bad]


def wrap(text: str, width: int) -> list:
    out, line = [], ""
    for word in text.split(" "):
        if len(line) + len(word) + 1 > width and line:
            out.append(line)
            line = word
        else:
            line = (line + " " + word).strip()
    return out + [line] if line else out


def sheet(batch: Path) -> Path:
    f, fb = font(13), font(17)
    slots = sorted(p for p in batch.iterdir() if p.is_dir() and (p / "cleaned.png").is_file())
    review = {}
    if (batch / "review.json").is_file():
        review = json.loads((batch / "review.json").read_text(encoding="utf-8")).get("slots", {})
    rows = []
    for d in slots:
        imgs = []
        for path in (reg.DOC / "refs" / f"{d.name}.png", d / "prepared.png", d / "cleaned.png"):
            if path.is_file():
                im = Image.open(path).convert("RGBA")
                kk = 8 if max(im.size) <= 16 else 4
                imgs.append(im.resize((im.width * kk, im.height * kk), Image.NEAREST))
            else:
                imgs.append(None)
        rows.append((d, imgs))
    col_w = max(330, max((im.width for _, ims in rows for im in ims if im is not None), default=0) + 16)
    pad = 12

    def row_h(ims, texts):
        ih = max((im.height for im in ims if im is not None), default=40)
        return 26 + 18 + ih + 8 + 16 * max(len(t) for t in texts) + pad

    layout = []
    for d, ims in rows:
        ans = review.get(d.name, {})
        said = f"Preston: {ans.get('answer', '?')} ({ans.get('date', '')})"
        texts = [[(DIM, "the placeholder in the game now")],
                 [(INK, said)] + check_summary(d / "prepared.png.check.json"),
                 hold_lines(d) + check_summary(d / "cleaned.png.check.json") + change_notes(d)]
        texts = [[(c, w) for c, t in col for w in wrap(t, col_w // 7)] for col in texts]
        layout.append((d, ims, texts, row_h(ims, texts)))
    W = pad + 3 * col_w + pad
    H = 40 + sum(h for *_, h in layout) + pad
    img = Image.new("RGBA", (W, H), BACK + (255,))
    dr = ImageDraw.Draw(img)
    dr.text((pad, 10), f"Clean-up sheet: {batch.name}  (placeholder, prepared = what you said yes to, cleaned = made "
                       "again from the raw by tools/art/clean_slot.py; all at 4x, the cursor at 8x)", fill=INK, font=f)
    top = 40
    for d, ims, texts, h in layout:
        dr.rectangle([4, top, W - 5, top + h - 6], fill=PANEL + (255,))
        s = reg.spec(d.name)
        dr.text((pad, top + 4), f"{d.name}  ({s['kind']}, {s['size'][0]}x{s['size'][1]}"
                + (f", rows {', '.join(s.get('state_order') or [])}" if s["rows"] > 1 else "") + ")", fill=INK, font=fb)
        for i, (label, im) in enumerate(zip(("placeholder", "prepared (your yes)", "cleaned"), ims)):
            x0 = pad + i * col_w
            dr.text((x0, top + 26), label, fill=DIM, font=f)
            yy = top + 44
            if im is None:
                dr.text((x0, yy), "missing", fill=DIM, font=f)
                ih = 20
            else:
                back = checker(im.width, im.height)
                back.alpha_composite(im)
                img.paste(back, (x0, yy))
                ih = im.height
            ty = top + 44 + max((m.height for m in ims if m is not None), default=40) + 8
            for c, t in texts[i]:
                dr.text((x0, ty), t, fill=c, font=f)
                ty += 16
        top += h
    out = batch / "cleanup_sheet.png"
    img.convert("RGB").save(out)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description="Light clean-up of a generated slot candidate, from its raw.")
    ap.add_argument("slot_id", nargs="?")
    ap.add_argument("source", nargs="?", help="the slot's candidate folder, or a raw.png")
    ap.add_argument("out", nargs="?", help="output png when source is a raw.png")
    ap.add_argument("--sheet", help="a batch folder: write its cleanup_sheet.png from the cleaned.png already made")
    ap.add_argument("--flip", action="append", default=[], metavar="STATE",
                    help="mirror this state row's raw left to right first (a pair drawn facing opposite ways)")
    ap.add_argument("--mixed", type=float, default=0.5, metavar="SHARE",
                    help="blocks whose commonest colour covers under this share take their snapped mean (0 = off)")
    ap.add_argument("--keep", type=float, default=40.0, metavar="LUMA",
                    help="an orphan this much brighter or darker than its surroundings gets a partner, not erased (0 = off)")
    ap.add_argument("--thin-outline", type=float, default=0.0, metavar="SHARE",
                    help="an outline colour wins a block only when it covers this share of it (0 = off)")
    ap.add_argument("--hold", metavar="SLOT_FOLDER", help="mark this slot's cleaned.png as held (with --reason)")
    ap.add_argument("--reason", default="", help="why the slot is held, shown on the sheet")
    a = ap.parse_args()
    if a.sheet:
        print(f"sheet -> {sheet(Path(a.sheet))}")
        return 0
    if a.hold:
        if not a.reason:
            ap.error("--hold needs --reason")
        print(f"held -> {hold(Path(a.hold), a.reason)}")
        return 0
    if not a.slot_id or not a.source:
        ap.error("give a slot id and its folder (or raw.png and out.png), or --sheet <batch folder>")
    src = Path(a.source)
    try:
        if src.is_dir():
            out = clean(a.slot_id, folder=src, out=Path(a.out) if a.out else None, flip=tuple(a.flip), keep=a.keep,
                        mixed=a.mixed, outline=a.thin_outline)
        else:
            if not a.out:
                ap.error("with a raw.png, give the output path too")
            out = clean(a.slot_id, raw=src, out=Path(a.out), flip=tuple(a.flip), mixed=a.mixed, keep=a.keep,
                        outline=a.thin_outline)
    except (reg.StaleRegistry, KeyError, ValueError) as e:
        print(f"refused: {e}", file=sys.stderr)
        return 2
    print(f"next: python tools/art/validate_slot.py {a.slot_id} {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
