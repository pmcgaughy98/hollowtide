"""Add a walk bob to an 8x8 walk atlas by moving the body above the hips, not the feet.

Usage:
    python fix_bob.py IN_ATLAS OUT_ATLAS [--report REPORT.json]

What it does, per direction row (rows: down, down_left, left, up_left, up, up_right,
right, down_right; 80x80 cells, 8 frames each):

1. Gait phase from the legs (alpha only, so colour fixes before or after do not matter).
   Stride per frame = horizontal spread of the bottom 14 rows + 2 x the height gap
   between the two feet. Contact frames are where the stride peaks; a walk has two
   steps per 8-frame loop, so the script fits the period-4 wave of the stride and
   takes its peak as the contact frame. If that wave is too weak (the PixelLab north
   walk is two held poses, not a stride), it falls back to the frames where the leg
   band changes most (the moment a held pose switches, which is where a foot lands).
2. Rhythm: contact frames 1 px lower, passing frames (2 frames later) 1 px higher,
   the frames between at the middle height. That is a 2 px head-top range, which is
   RD's usual bob (RD measures 1 to 3 px, mostly 2).
3. Head position now: how far the whole head mass sits from frame 0 (best overlap of
   the top 20 rows), checked against the top outline row. When the two disagree (a
   redrawn head can sit half a pixel lower), the reading that needs the smaller move
   wins. The target height per frame is base + rhythm, with the base chosen to need
   the smallest moves, and the frame's move is target minus now, at most 2 px.
4. The move: one full-width row is removed (to lower) or duplicated (to raise) in the
   hip band, 9 to 20 rows above the lowest foot, and everything above it shifts with
   it. Rows below the band (knees and feet) are never touched, so planted feet stay
   planted. The row picked is the one where the fewest pixels are lost or doubled:
   a pixel counts only if it differs from both the row above and the row below
   (RGB distance over 24 or a different alpha), so cutting inside a flat run of
   cloth or empty space costs nothing and cutting through an outline costs a lot.

Only whole pixels are copied: no resampling, no blending, alpha stays 0 or 255, and no
colour is created. It does not depend on exact colours; the 24-unit tolerance only
decides which row is cheapest to cut.

Order note: run it after any fix that redraws or re-places heads or legs (head height,
shimmer, south or north leg redraws), because those would overwrite the bob.
"""
import argparse
import json
import math
import sys

import numpy as np
from PIL import Image

ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
CELL = 80
FRAMES = 8
MAX_MOVE = 2          # px, per frame
AMP = 1               # rhythm: contact +1 (lower), passing -1 (higher)
COLOUR_TOL = 24.0     # RGB distance under which two pixels count as the same
BAND_HI = 20          # seam band: from 20 rows above the lowest foot ...
BAND_LO = 9           # ... to 9 rows above it (feet and knees stay untouched)
BAND_PREF = 15        # preferred seam row above the lowest foot (hips / top of thighs)
WEAK_STRIDE = 1.0     # px; under this the stride wave is too weak to trust


# ------------------------------------------------------------------ measuring helpers
def opaque(cell):
    return cell[:, :, 3] > 0


def bbox(mask):
    ys, xs = np.nonzero(mask)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def leg_info(mask):
    """Stride numbers from the bottom 14 rows of one frame."""
    b = bbox(mask)
    foot = b[3]
    band = mask[foot - 13:foot + 1]
    cols = np.nonzero(band.any(0))[0]
    spread = int(cols.max() - cols.min() + 1)
    mid = (cols.min() + cols.max()) / 2.0
    lowest = {int(x): foot - 13 + int(np.nonzero(band[:, x])[0].max()) for x in cols}
    left = max(v for x, v in lowest.items() if x < mid)
    right = max(v for x, v in lowest.items() if x >= mid)
    return {"foot_y": foot, "spread": spread, "left_foot_y": left, "right_foot_y": right,
            "stride": spread + 2 * abs(left - right)}


def period4(values):
    """Peak frame (0..3, fractional) and amplitude of the period-4 wave in 8 values."""
    c = sum(v * complex(math.cos(-math.pi * f / 2), math.sin(-math.pi * f / 2)) for f, v in enumerate(values))
    amp = 2 * abs(c) / len(values)
    phase = (-math.atan2(c.imag, c.real) / (math.pi / 2)) % 4
    return phase, amp


def shifted(mask, dy, dx):
    """Integer shift with an empty border (no wrap)."""
    out = np.zeros_like(mask)
    h, w = mask.shape
    ys0, ys1 = max(0, -dy), min(h, h - dy)
    xs0, xs1 = max(0, -dx), min(w, w - dx)
    out[ys0 + dy:ys1 + dy, xs0 + dx:xs1 + dx] = mask[ys0:ys1, xs0:xs1]
    return out


def head_offset(ref_mask, mask, top, rows=20):
    """How many px lower (positive) the head mass of mask sits than ref_mask's."""
    band = slice(top, top + rows)
    best = None
    for dy in range(-4, 5):
        for dx in range(-3, 4):
            s = shifted(mask, dy, dx)
            inter = int((ref_mask[band] & s[band]).sum())
            union = int((ref_mask[band] | s[band]).sum())
            score = (inter / max(1, union), -(abs(dy) + abs(dx)))
            if best is None or score > best[0]:
                best = (score, dy)
    return -best[1]


def gait(frames):
    """Contact frame index (0..3; contacts are k and k+4) plus how it was found."""
    masks = [opaque(f) for f in frames]
    legs = [leg_info(m) for m in masks]
    stride = [l["stride"] for l in legs]
    phase, amp = period4(stride)
    method = "stride"
    change = None
    if amp < WEAK_STRIDE:
        # Fallback: leg-band change from the previous frame. Peaks where a held pose
        # switches, which is where the new foot lands.
        change = []
        for f in range(FRAMES):
            a, b = masks[f], masks[f - 1]
            foot = max(legs[f]["foot_y"], legs[f - 1]["foot_y"])
            band = slice(foot - 17, foot + 1)
            diff = (a[band] != b[band]) | (a[band] & b[band] & np.any(frames[f][band, :, :3] != frames[f - 1][band, :, :3], axis=2))
            change.append(int(diff.sum()))
        phase, amp = period4(change)
        method = "leg_change"
    k = int(round(phase)) % 4
    return {"contact": k, "phase": round(phase, 2), "wave_amp": round(amp, 2), "method": method,
            "stride": stride, "leg_change": change, "legs": legs}


def rhythm(k):
    """+1 lower on contact (k, k+4), -1 higher on passing (k+2, k+6), 0 between."""
    out = []
    for f in range(FRAMES):
        p = (f - k) % 4
        out.append(AMP if p == 0 else (-AMP if p == 2 else 0))
    return out


# ------------------------------------------------------------------ the row move
def pixel_same(p, q):
    ap, aq = p[..., 3] > 0, q[..., 3] > 0
    d = np.sqrt(((p[..., :3].astype(float) - q[..., :3].astype(float)) ** 2).sum(-1))
    return (ap == aq) & (~ap | (d <= COLOUR_TOL))


def seam_cost(cell, s):
    """Pixels of row s that are not repeated in the row above or below it."""
    lost = ~pixel_same(cell[s], cell[s - 1]) & ~pixel_same(cell[s], cell[s + 1])
    return int(lost.sum())


def pick_seam(cell, foot):
    best = None
    for s in range(foot - BAND_HI, foot - BAND_LO + 1):
        c = seam_cost(cell, s)
        key = (c + 0.2 * abs(s - (foot - BAND_PREF)), s)
        if best is None or key < best[0]:
            best = (key, s, c)
    return best[1], best[2]


def move_upper(cell, d, foot):
    """Lower (d > 0) or raise (d < 0) everything above a hip seam by |d| px."""
    out = cell.copy()
    seams = []
    for _ in range(abs(d)):
        s, cost = pick_seam(out, foot)
        new = out.copy()
        if d > 0:   # remove row s, rows above it come down one
            new[1:s + 1] = out[0:s]
            new[0] = 0
        else:       # duplicate row s, rows above it go up one
            new[0:s] = out[1:s + 1]
        out = new
        seams.append({"row": s, "px_lost_or_doubled": cost})
    return out, seams


# ------------------------------------------------------------------ main
def fix_row(frames):
    g = gait(frames)
    target_wave = rhythm(g["contact"])
    masks = [opaque(f) for f in frames]
    top0 = bbox(masks[0])[1]
    by_mass = [head_offset(masks[0], m, top0) for m in masks]
    by_top = [bbox(m)[1] - top0 for m in masks]

    def choose_base(cur):
        # integer base that needs the least total move; ties go to the smaller largest move,
        # then to fewer edited frames, then to the base nearest the median head position
        med = float(np.median(cur))
        cands = []
        for b in range(min(cur) - 2, max(cur) + 3):
            d = [b + t - c for t, c in zip(target_wave, cur)]
            cands.append((sum(abs(x) for x in d), max(abs(x) for x in d), sum(1 for x in d if x), abs(b - med), b))
        return min(cands)[-1]

    # Head position now. The head mass (overlap) and the top outline row usually agree.
    # PixelLab redraws heads every frame, so sometimes half the outline is 1 px lower and
    # the two readings split; then take the reading that needs the smaller move.
    base = choose_base(by_mass)
    cur = []
    for f in range(FRAMES):
        a, b = by_mass[f], by_top[f]
        if a == b:
            cur.append(a)
        else:
            cur.append(min((a, b), key=lambda c: (abs(base + target_wave[f] - c), c)))
    base = choose_base(cur)
    out_frames, moves = [], []
    for f in range(FRAMES):
        d = base + target_wave[f] - cur[f]
        d = max(-MAX_MOVE, min(MAX_MOVE, d))
        foot = g["legs"][f]["foot_y"]
        if d == 0:
            out_frames.append(frames[f].copy())
            moves.append({"frame": f, "move_px": 0, "seams": []})
            continue
        new, seams = move_upper(frames[f], d, foot)
        out_frames.append(new)
        moves.append({"frame": f, "move_px": d, "seams": seams})
    return out_frames, {"gait": {k: v for k, v in g.items() if k != "legs"},
                        "foot_y": [l["foot_y"] for l in g["legs"]],
                        "head_offset_by_mass": by_mass, "head_offset_by_top_row": by_top,
                        "head_offset_before": cur, "rhythm": target_wave, "base": base, "moves": moves}


def fix_atlas(atlas):
    atlas = np.asarray(atlas)
    if atlas.shape[0] < CELL * len(ROWS) or atlas.shape[1] < CELL * FRAMES:
        raise ValueError(f"atlas is {atlas.shape[1]}x{atlas.shape[0]}, expected 640x640 (8 rows x 8 frames of 80 px)")
    out = atlas.copy()
    report = {}
    for i, r in enumerate(ROWS):
        frames = [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL].copy() for f in range(FRAMES)]
        if any(bbox(opaque(f)) is None for f in frames):
            report[r] = {"skipped": "empty frame"}
            continue
        new, rep = fix_row(frames)
        for f in range(FRAMES):
            out[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] = new[f]
        report[r] = rep
    return out, report


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("in_atlas")
    ap.add_argument("out_atlas")
    ap.add_argument("--report", help="write the per-row decisions to this JSON file")
    a = ap.parse_args(argv)
    src = np.array(Image.open(a.in_atlas).convert("RGBA"))
    out, report = fix_atlas(src)
    Image.fromarray(out, "RGBA").save(a.out_atlas)
    if a.report:
        with open(a.report, "w", encoding="utf-8") as fh:
            json.dump(report, fh, indent=1)
    for r in ROWS:
        rep = report[r]
        if "skipped" in rep:
            print(f"{r:10s} skipped: {rep['skipped']}")
            continue
        g = rep["gait"]
        mv = [m["move_px"] for m in rep["moves"]]
        print(f"{r:10s} contact f{g['contact']}/f{g['contact'] + 4} ({g['method']}, wave {g['wave_amp']} px)  head before {rep['head_offset_before']}  moves {mv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
