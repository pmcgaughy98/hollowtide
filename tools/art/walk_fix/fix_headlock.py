"""Head lock for an 8x8 walk atlas (Claude, 2026-10-26; the PixelLab courier walk test, fix lane "headlock").

The PixelLab walk redraws about half of the head's pixels every frame, so the head shimmers, and the side views
draw the eyes blue. A pixel artist fixes that by drawing one good head per direction and moving that same head
along with the body. This does exactly that, with no resampling and no new colours:

  1. find the head in every frame: everything above the teal collar (a per-column cut, so a chin that hangs in
     front of the collar stays part of the head)
  2. choose one master head per direction from nine candidates, the 8 frames and PixelLab's rotation image of that
     direction: fewest wrong eye pixels (blue, or shirt teal, in the face) first, then the head that is closest to
     all the others (so the fewest pixels change)
  3. a rotation head is snapped to the row's own colours (each colour the row does not use goes to its nearest row
     colour), so the row never gains a colour and a palette fix made earlier in a chain stays in effect
  4. in every frame: erase the old head and paste the master at an integer offset, so any motion the head and body
     already have is kept. Where each frame's head sits is measured against a proxy frame (the most typical frame
     head) by best fit; vertically the head top's move is the anchor, and the collar's move wins only if it fits 25%
     better. The master goes onto the proxy with one offset for the whole row, fitted over all 8 frames at once.
  5. repair the seam by hand rules: a 1-2 px hole between the new head and the body gets the darker of the two
     pixels around it; a body pixel newly left on the silhouette edge gets the row's outline colour

    python tools/art/walk_fix/fix_headlock.py IN_ATLAS OUT_ATLAS [--report report.json]

Atlas layout: 640x640, 80x80 cells, rows down, down_left, left, up_left, up, up_right, right, down_right.
Fixed reference files: the PixelLab rotation images in docs/art/characters/sprite-tool-test-2026-10-26/raw/rotations.
Depends on: a teal shirt (green and blue both at least 40 above red, within 30 of each other) to find the collar.
A row where no collar is found is copied through unchanged, and the report says so.
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HT = Path(__file__).resolve().parents[3]
ROT_DIR = HT / "docs/art/characters/sprite-tool-test-2026-10-26/raw/rotations"
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
PL_DIRS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]
CELL = 80


# ------------------------------------------------------------------ colour tests
def _ch(c):
    return [c[..., i].astype(int) for i in range(3)]


def teal(c):
    """The shirt's teal: green and blue both well above red, and close to each other."""
    r, g, b = _ch(c)
    return (c[..., 3] > 0) & (g > r + 40) & (np.abs(g - b) <= 30)


def wrong_eye(c, top, shoulder):
    """Eye pixels that are blue, or shirt teal, inside the face band (below the goggles, above the chin)."""
    r, g, b = _ch(c)
    m = (c[..., 3] > 0) & (((b > r + 25) & (b > g + 30)) | ((g > r + 40) & (np.abs(g - b) <= 30) & (g > 60)))
    m[:top + 12] = False
    m[max(0, shoulder - 3):] = False
    return m


def bluish_eye(c, top, shoulder):
    """A looser test (blue clearly above red, not below green), for the faint 1-2 px cases."""
    r, g, b = _ch(c)
    m = (c[..., 3] > 0) & (b > r + 15) & (b >= g)
    m[:top + 12] = False
    m[max(0, shoulder - 3):] = False
    return m


def value(c):
    return c[..., :3].max(-1).astype(int)


# ------------------------------------------------------------------ head finding
def segment(c):
    """(top, shoulder, cut, mask): head top row, first collar row, per-column cut row, and the head mask.

    The collar row is the first row at least 18 below the head top with 4 or more teal pixels. In each column the
    head ends at the first teal pixel found from 4 rows above the collar row down to it, or one row below the collar
    row where the column has none (hair at the side, the chin in a side view). Searching only that low keeps the
    goggle lenses and teal eye pixels from counting as collar."""
    op = c[..., 3] > 0
    ys = np.nonzero(op.any(1))[0]
    if len(ys) == 0:
        return None
    top = int(ys.min())
    t = teal(c)
    cnt = t.sum(1)
    shoulder = next((y for y in range(top + 18, CELL) if cnt[y] >= 4), None)
    if shoulder is None:
        return None
    limit = shoulder + 1
    cut = np.full(CELL, limit)
    lo = shoulder - 4
    for x in range(CELL):
        col = np.nonzero(t[lo:limit, x])[0]
        if len(col):
            cut[x] = lo + col[0]
    yy = np.arange(CELL)[:, None]
    return top, shoulder, cut, op & (yy < cut[None, :])


def shifted(c, m, dx, dy):
    """Integer translation of the masked pixels onto an empty cell (no resampling)."""
    out = np.zeros_like(c)
    om = np.zeros_like(m)
    ys, xs = np.nonzero(m)
    ny, nx = ys + dy, xs + dx
    ok = (ny >= 0) & (ny < CELL) & (nx >= 0) & (nx < CELL)
    out[ny[ok], nx[ok]] = c[ys[ok], xs[ok]]
    om[ny[ok], nx[ok]] = True
    return out, om


def head_diff(c1, m1, c2, m2, dx=0, dy=0):
    """Share of the union of both head masks whose pixel differs (alpha or colour), head 2 moved by (dx, dy)."""
    h2, mm2 = shifted(c2, m2, dx, dy)
    union = m1 | mm2
    if not union.any():
        return 0.0
    differ = (m1 != mm2) | (m1 & mm2 & np.any(c1[..., :3] != h2[..., :3], axis=2))
    return float(differ[union].mean())


def best_shift(c1, m1, c2, m2, r=3):
    best = (9.0, 0, 0)
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            d = head_diff(c1, m1, c2, m2, dx, dy)
            if d < best[0] - 1e-9:
                best = (d, dx, dy)
    return best


def fit_cost(frame, fm, master, mm, dx, dy):
    """How badly the master head sits on a frame's head: silhouette mismatch plus half the colour mismatch."""
    h, hm = shifted(master, mm, dx, dy)
    sil = int((fm != hm).sum())
    both = fm & hm
    col = int((both & np.any(frame[..., :3] != h[..., :3], axis=2)).sum())
    return sil + 0.5 * col


# ------------------------------------------------------------------ palette
def snap_to_palette(c, m, pal):
    """Each masked pixel whose colour is not in pal goes to the nearest pal colour (RGB distance)."""
    out = c.copy()
    key = pal[:, 0].astype(int) * 65536 + pal[:, 1].astype(int) * 256 + pal[:, 2]
    k = c[..., 0].astype(int) * 65536 + c[..., 1].astype(int) * 256 + c[..., 2]
    need = m & ~np.isin(k, key)
    if need.any():
        px = c[need][:, :3].astype(float)
        d = ((px[:, None, :] - pal[None].astype(float)) ** 2).sum(-1)
        out[need, :3] = pal[d.argmin(1)]
    return out, int(need.sum())


def row_palette(cells):
    return np.unique(np.concatenate([c[c[..., 3] > 0][:, :3] for c in cells]), axis=0)


def outline_colour(cells):
    """The colour the row puts on its silhouette edge most often."""
    counts = {}
    for c in cells:
        op = c[..., 3] > 0
        p = np.pad(op, 1)
        edge = op & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
        for col in c[edge][:, :3].tolist():
            counts[tuple(col)] = counts.get(tuple(col), 0) + 1
    return np.array(max(counts, key=counts.get), np.uint8)


# ------------------------------------------------------------------ the fix
def lock_row(cells, rot, log):
    segs = [segment(c) for c in cells]
    if any(s is None for s in segs):
        log["skipped"] = "no teal collar found in at least one frame"
        return [c.copy() for c in cells]
    pal = row_palette(cells)
    line = outline_colour(cells)

    # candidates: the 8 frames, then the rotation image snapped to the row's colours
    cands = [(f"frame{f}", cells[f], segs[f]) for f in range(8)]
    rseg = segment(rot) if rot is not None else None
    if rseg is not None:
        rot_s, n_snapped = snap_to_palette(rot, rot[..., 3] > 0, pal)
        rseg = segment(rot_s)
        if rseg is not None:
            cands.append(("rotation", rot_s, rseg))
            log["rotation_px_snapped_to_row_colours"] = n_snapped
    scores = []
    for name, c, s in cands:
        eye = int(wrong_eye(c, s[0], s[1]).sum())
        typical = float(np.mean([best_shift(cells[f], segs[f][3], c, s[3])[0] for f in range(8) if cands[f][0] != name]))
        scores.append((eye, typical, name))
    log["candidates"] = {n: {"wrong_eye_px": e, "mean_aligned_diff_to_frames": round(t, 4)} for e, t, n in scores}
    eye, typical, mname = min(scores)
    mi = [n for n, _, _ in cands].index(mname)
    _, master, (mtop, msh, mcut, mmask) = cands[mi]
    master = master.copy()
    log["master"] = mname

    # last resort, only when every candidate has blue eyes: paint the blue eye pixels with the row's darkest colour
    we = wrong_eye(master, mtop, msh) & mmask
    if we.any():
        dark = pal[pal.astype(int).sum(1).argmin()]
        master[we, :3] = dark
        log["eye_px_repainted"] = int(we.sum())

    # where each frame's head sits: measured against a proxy, the frame head closest to all the others, because two
    # drawings by the same generator match reliably (a rotation head is drawn differently and matches poorly, so
    # fitting it to each frame on its own jitters by a pixel). Vertical moves stay within 1 px of the collar's move.
    proxy = min(range(8), key=lambda k: [t for e, t, n in scores if n == f"frame{k}"][0])
    pc, (ptop, psh, pcut, pm) = cells[proxy], segs[proxy]

    def fit(c, fm, src, sm, dys, rx=4):
        best = None
        for dy in dys:
            for dx in range(-rx, rx + 1):
                cost = fit_cost(c, fm, src, sm, dx, dy) + 0.01 * abs(dx)
                if best is None or cost < best[0]:
                    best = (cost, dx, dy)
        return best

    def solid_top(m):
        """First row of the head with 3 or more pixels, so one stray hair tip does not count as the head moving."""
        return int(next(y for y in range(CELL) if m[y].sum() >= 3))

    # vertical: the head top's move is the anchor. When the collar moved by a different amount, the collar's move is
    # taken only if it fits at least 25% better; a redrawn chin alone must not make the head hop for one frame.
    rel = []
    ptop_s = solid_top(pm)
    for f in range(8):
        dy_top = solid_top(segs[f][3]) - ptop_s
        dy_col = segs[f][1] - psh
        a = fit(cells[f], segs[f][3], pc, pm, [dy_top])
        if dy_col != dy_top:
            b = fit(cells[f], segs[f][3], pc, pm, [dy_col])
            if b[0] * 1.25 < a[0]:
                a = b
        rel.append((a[1], a[2]))
    # the master's offset onto the proxy: one offset for the whole row, chosen over all 8 frames together
    dy0 = psh - msh
    best = None
    for my in (dy0 - 1, dy0, dy0 + 1):
        for mx in range(-4, 5):
            cost = sum(fit_cost(cells[f], segs[f][3], master, mmask, mx + rel[f][0], my + rel[f][1]) for f in range(8))
            cost += 0.01 * (abs(mx) + abs(my - dy0))
            if best is None or cost < best[0]:
                best = (cost, mx, my)
    _, mx, my = best
    log["proxy"] = f"frame{proxy}"
    log["master_to_proxy_offset"] = [mx, my]

    out = []
    log["frames"] = []
    for f, c in enumerate(cells):
        top, sh, cut, fm = segs[f]
        dy0 = sh - msh
        dx, dy = mx + rel[f][0], my + rel[f][1]
        h, hm = shifted(master, mmask, dx, dy)
        o = c.copy()
        o[fm] = 0
        shirt = teal(c) & ~fm
        put = hm & ~shirt
        o[put] = h[put]
        # seam: a transparent pixel that was opaque before, with opaque pixels within 2 above and below (or left
        # and right), is a hole between head and body: it takes the darker of the two nearest pixels
        filled = 0
        was = c[..., 3] > 0
        for _ in range(2):
            op = o[..., 3] > 0
            holes = []
            for y, x in zip(*np.nonzero(was & ~op)):
                pairs = []
                for (ay, ax), (by, bx) in (((-1, 0), (1, 0)), ((0, -1), (0, 1))):
                    up = next(((y + ay * k, x + ax * k) for k in (1, 2) if 0 <= y + ay * k < CELL and 0 <= x + ax * k < CELL and op[y + ay * k, x + ax * k]), None)
                    dn = next(((y + by * k, x + bx * k) for k in (1, 2) if 0 <= y + by * k < CELL and 0 <= x + bx * k < CELL and op[y + by * k, x + bx * k]), None)
                    if up and dn:
                        pairs.append((up, dn))
                if pairs:
                    up, dn = pairs[0]
                    pick = up if value(o[up])[()] <= value(o[dn])[()] else dn
                    holes.append((y, x, o[pick].copy()))
            for y, x, col in holes:
                o[y, x] = col
                filled += 1
            if not holes:
                break
        # a wider gap (the input's head reached lower than the master's, e.g. after a fix that lengthened the neck):
        # the input's own pixels come back there rather than leaving a hole between head and body
        restored = 0
        op = o[..., 3] > 0
        for y, x in zip(*np.nonzero(was & ~op & fm)):
            if hm[:y, x].any() and op[y + 1:, x].any():
                o[y, x] = c[y, x]
                restored += 1
        # outline: a body pixel (outside the new head) that now borders transparency where it did not before, and
        # is not already dark, becomes the row's outline colour
        op = o[..., 3] > 0
        p_new = np.pad(op, 1)
        p_old = np.pad(was, 1)
        relined = 0
        for y, x in zip(*np.nonzero(op & ~hm)):
            nb_new = [p_new[y, x + 1], p_new[y + 2, x + 1], p_new[y + 1, x], p_new[y + 1, x + 2]]
            nb_old = [p_old[y, x + 1], p_old[y + 2, x + 1], p_old[y + 1, x], p_old[y + 1, x + 2]]
            exposed = any((not n) and o_ for n, o_ in zip(nb_new, nb_old))
            if exposed and value(o[y, x]) >= 77:
                o[y, x, :3] = line
                relined += 1
        out.append(o)
        log["frames"].append({"frame": f, "dx": dx, "dy": dy, "collar_move": dy0,
                              "seam_holes_filled": filled, "gap_px_restored": restored, "edge_px_relined": relined,
                              "px_changed": int(np.any(o != c, axis=2).sum())})
    return out


def run(src, dst, report=None):
    a = np.array(Image.open(src).convert("RGBA"))
    if a.shape[:2] != (CELL * 8, CELL * 8):
        sys.exit(f"expected a 640x640 atlas, got {a.shape[1]}x{a.shape[0]}")
    out = a.copy()
    logs = {}
    for ri, row in enumerate(ROWS):
        cells = [a[ri * CELL:(ri + 1) * CELL, f * CELL:(f + 1) * CELL].copy() for f in range(8)]
        rp = ROT_DIR / f"{PL_DIRS[ri]}.png"
        rot = np.array(Image.open(rp).convert("RGBA")) if rp.exists() else None
        if rot is not None and rot.shape[:2] != (CELL, CELL):
            rot = None
        log = {}
        fixed = lock_row(cells, rot, log)
        for f in range(8):
            out[ri * CELL:(ri + 1) * CELL, f * CELL:(f + 1) * CELL] = fixed[f]
        logs[row] = log
    # hard alpha only, as the input
    out[..., 3] = np.where(out[..., 3] > 0, 255, 0)
    out[out[..., 3] == 0] = 0
    Path(dst).parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(out, "RGBA").save(dst)
    if report:
        Path(report).write_text(json.dumps(logs, indent=1), encoding="utf-8")
    return logs


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("inp")
    p.add_argument("out")
    p.add_argument("--report")
    args = p.parse_args()
    logs = run(args.inp, args.out, args.report)
    for row, lg in logs.items():
        if "skipped" in lg:
            print(f"{row:11s} skipped: {lg['skipped']}")
            continue
        fr = lg["frames"]
        print(f"{row:11s} master {lg['master']:9s} offsets {[(x['dx'], x['dy']) for x in fr]} "
              f"holes {sum(x['seam_holes_filled'] for x in fr)} relined {sum(x['edge_px_relined'] for x in fr)}")


if __name__ == "__main__":
    main()
