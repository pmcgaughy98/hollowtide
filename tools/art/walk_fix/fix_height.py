"""Turn-height fix for an 8-direction walk atlas (Claude, 2026-10-26, walk-fix lane "height").

What it fixes: the PixelLab courier walk is shorter in some directions than others, so his head drops
when he turns (standing head tops 7,7,10,8,8,7,11,10 against RD's 7,7,8,8,8,8,8,9).

How, the way a pixel artist would do it by hand: in each short direction, duplicate single rows of the
body (one in the torso, one in the thighs, a third in the torso if needed) and move everything above
each duplicated row up by one. Nothing is resampled or repainted, no new colour appears, alpha stays
0 or 255, and every pixel at or below the duplicated row keeps its place, so the feet stay on y=72.

Usage:
    python tools/art/walk_fix/fix_height.py IN_ATLAS OUT_ATLAS [--plan PLAN.json]

Input: a 640x640 atlas of 80x80 cells, 8 rows (down, down_left, left, up_left, up, up_right, right,
down_right) by 8 frames, feet anchored at y=72. It is a pure function of the input atlas; it reads no
other file.

How much to add to each direction:
  head top of a direction = its highest head over the 8 frames (min bbox top), so a walk bob added by
  another fix first does not change the answer.
  target = the median of the 8 directions' head tops, rounded down (8 for the raw PixelLab atlas,
  which is also RD's side-view head top).
  rows to add = head top minus target, never negative, at most 3. Taller directions are left alone.

Which rows to duplicate: one fixed row per insertion for all 8 frames of a direction (so the walk
does not jitter), chosen from two bands measured as a share of the figure height from the head top:
torso 45-62 percent, thighs 66-82 percent. The chosen row is the one most like its neighbours
above and below, summed over the 8 frames, because duplicating such a row only lengthens runs that
are already vertical. A row that differs from both neighbours (a 1 px belt line or strap edge) and
any horizontal silhouette edge cost extra, since those would show as doubled lines. Duplicated rows
are kept at least 3 rows apart.

Dependencies on other fixes: none on colour. It only reads alpha and compares colours row to row,
so a palette clamp or recolour before it changes nothing in the plan. Run it before a bob fix if
possible: it still works after one (the plan uses the highest head over the cycle), but the fixed
duplicated row then sits 1 to 3 px higher or lower on the body in the bobbed frames.
"""
import argparse
import json

import numpy as np
from PIL import Image

CELL = 80
FOOT_Y = 72
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
MAX_INSERT = 3
MIN_GAP = 3
TORSO = (0.45, 0.62)
THIGH = (0.66, 0.82)


def cells_of(atlas, i):
    return [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] for f in range(8)]


def bbox(c):
    ys, xs = np.nonzero(c[..., 3] > 0)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def row_cost(c, y):
    """How visible a duplicate of row y would be in one frame."""
    a = c.astype(int)
    op = a[..., 3] > 0
    diffs = []
    for n in (y - 1, y + 1):
        alpha_d = op[y] != op[n]
        col_d = op[y] & op[n] & np.any(a[y, :, :3] != a[n, :, :3], axis=1)
        diffs.append((alpha_d, col_d))
    (a_up, c_up), (a_dn, c_dn) = diffs
    cost = 3 * (a_up.sum() + a_dn.sum()) + c_up.sum() + c_dn.sum()
    thin = (a_up | c_up) & (a_dn | c_dn)  # a 1 px horizontal feature: it would double
    return int(cost + 2 * thin.sum())


def plan_direction(frames, top, n):
    """Pick n rows to duplicate for one direction (same rows in all 8 frames)."""
    foot = max(bbox(c)[3] for c in frames)
    h = foot - top
    bands = {
        "torso": range(int(np.ceil(top + TORSO[0] * h)), int(np.floor(top + TORSO[1] * h)) + 1),
        "thigh": range(int(np.ceil(top + THIGH[0] * h)), int(np.floor(top + THIGH[1] * h)) + 1),
    }
    cost = {y: sum(row_cost(c, y) for c in frames) for b in bands.values() for y in b}
    chosen = []

    def best(names):
        cand = [(cost[y], y, b) for b in names for y in bands[b]
                if all(abs(y - cy) >= MIN_GAP for cy, _ in chosen)]
        return min(cand) if cand else None

    for k in range(n):
        if k == 0:
            pick = best(["torso", "thigh"])
        elif k == 1:
            other = "thigh" if chosen[0][1] == "torso" else "torso"
            pick = best([other]) or best(["torso", "thigh"])
        else:
            pick = best(["torso", "thigh"])
        if pick is None:
            raise SystemExit("no room left in the torso and thigh bands to duplicate another row")
        chosen.append((pick[1], pick[2]))
    return chosen, {b: [int(r.start), int(r.stop - 1)] for b, r in bands.items()}, {int(y): int(v) for y, v in cost.items()}


def lengthen(cell, rows):
    """Duplicate each row in `rows` (original coordinates) and drop the same number of empty rows at the top."""
    seq = []
    for y in range(CELL):
        seq.append(y)
        if y in rows:
            seq.append(y)
    n = len(seq) - CELL
    dropped = seq[:n]
    if np.any(cell[dropped, :, 3] > 0):
        raise SystemExit("lengthening would clip the head at the top of the cell")
    return cell[seq[n:]].copy()


def fix_atlas(atlas):
    if atlas.shape[:2] != (CELL * 8, CELL * 8):
        raise SystemExit(f"expected a {CELL * 8}x{CELL * 8} atlas, got {atlas.shape[1]}x{atlas.shape[0]}")
    tops = {}
    for i, r in enumerate(ROWS):
        boxes = [bbox(c) for c in cells_of(atlas, i)]
        tops[r] = min(b[1] for b in boxes if b)
    target = int(np.floor(np.median(list(tops.values()))))
    out = atlas.copy()
    plan = {"target_head_top": target, "head_top_rule": "min bbox top over the 8 frames",
            "directions": {}}
    for i, r in enumerate(ROWS):
        frames = cells_of(atlas, i)
        n = int(min(MAX_INSERT, max(0, tops[r] - target)))
        entry = {"head_top_before": tops[r], "rows_added": n}
        if n:
            chosen, bands, cost = plan_direction(frames, tops[r], n)
            rows = [y for y, _ in chosen]
            entry.update({"duplicated_rows": [{"y": int(y), "band": b, "cost": cost[y]} for y, b in chosen],
                          "bands": bands, "cost_by_row": cost})
            for f, c in enumerate(frames):
                out[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] = lengthen(c, set(rows))
        entry["head_top_after"] = min(bbox(c)[1] for c in cells_of(out, i))
        plan["directions"][r] = entry
    return out, plan


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("inp")
    ap.add_argument("out")
    ap.add_argument("--plan", help="write the chosen rows and costs to this JSON file")
    a = ap.parse_args()
    atlas = np.array(Image.open(a.inp).convert("RGBA"))
    out, plan = fix_atlas(atlas)
    # Sanity: no new colours, alpha still hard, feet untouched.
    assert set(map(tuple, out[out[..., 3] > 0][:, :3].tolist())) <= set(map(tuple, atlas[atlas[..., 3] > 0][:, :3].tolist()))
    assert set(np.unique(out[..., 3]).tolist()) <= set(np.unique(atlas[..., 3]).tolist())
    Image.fromarray(out, "RGBA").save(a.out)
    if a.plan:
        with open(a.plan, "w", encoding="utf-8") as fh:
            json.dump(plan, fh, indent=1)
    print(json.dumps({r: {k: v for k, v in e.items() if k not in ("cost_by_row", "bands")}
                      for r, e in plan["directions"].items()} | {"target_head_top": plan["target_head_top"]}, indent=1))


if __name__ == "__main__":
    main()
