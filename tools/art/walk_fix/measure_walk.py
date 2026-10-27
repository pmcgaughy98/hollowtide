"""Measure a walk atlas the same way the 2026-10-26 sprite tool test did, plus one number per judged fault.

    python tools/art/walk_fix/measure_walk.py ATLAS [OUT_JSON]

measure_set() is copied from the test's build_compare.py (scratchpad st_compare) with the same definitions, so its
numbers compare directly with docs/art/characters/sprite-tool-test-2026-10-26/measurements.json. The fault numbers
reuse the fix lanes' own measuring functions (colour_report, headlock_report, satchel_report, measure_legs,
bob_report), so they compare with each lane's metrics.json. Nothing here writes an image.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import colour_report as CR  # noqa: E402
import headlock_report as HR  # noqa: E402
import satchel_report as SR  # noqa: E402
import measure_legs as ML  # noqa: E402
import bob_report as BR  # noqa: E402

HT = HERE.parents[2]
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW_PATH = TEST / "pixellab_courier_walk_native80.png"
REF_PATH = TEST / "reference/courier_south_ref_80.png"
RD_PATH = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
CELL, FOOT_Y = 80, 72


def rgba(path):
    return np.array(Image.open(path).convert("RGBA"))


def split(atlas):
    return {r: [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL].copy() for f in range(8)]
            for i, r in enumerate(ROWS)}


# ---------------------------------------------------------------- copied from build_compare.py
def bbox(a):
    ys, xs = np.nonzero(a[:, :, 3] > 0)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def hsv_sv(rgb):
    r, g, b = rgb[..., 0] / 255.0, rgb[..., 1] / 255.0, rgb[..., 2] / 255.0
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    s = np.where(mx > 0, (mx - mn) / np.where(mx > 0, mx, 1), 0)
    return s, mx


def colours(a):
    m = a[:, :, 3] > 0
    return np.unique(a[m][:, :3], axis=0)


def nearest_dist(cols, ref_cols):
    d = np.sqrt(((cols[:, None, :].astype(float) - ref_cols[None, :, :].astype(float)) ** 2).sum(-1))
    return d.min(1)


def hist(a):
    m = a[:, :, 3] > 0
    q = (a[m][:, :3] >> 4).astype(int)
    h = np.bincount(q[:, 0] * 256 + q[:, 1] * 16 + q[:, 2], minlength=4096).astype(float)
    return h / max(1.0, h.sum())


def frame_diff(a, b):
    """Share of pixels in the union of both silhouettes that differ in alpha or colour."""
    ma, mb = a[:, :, 3] > 0, b[:, :, 3] > 0
    union = ma | mb
    differ = (ma != mb) | (ma & mb & np.any(a[:, :, :3] != b[:, :, :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def skin_side(a):
    b = bbox(a)
    x0, y0, x1, y1 = b
    band = a[y0:y0 + int((y1 - y0) * 0.38)]
    r, g, bl, al = [band[..., i].astype(int) for i in range(4)]
    skin = (al > 0) & (r > 190) & (g > 135) & (bl > 95) & (r - g >= 15) & (r - g <= 80) & (g - bl >= 10) & (g - bl <= 70)
    head = band[..., 3] > 0
    if skin.sum() == 0:
        return 0, None
    hx = np.nonzero(head)[1]
    sx = np.nonzero(skin)[1]
    return int(skin.sum()), round(float(sx.mean() - (hx.min() + hx.max()) / 2.0), 2)


def measure_set(cells, ref_cols):
    out = {"directions": {}}
    all_cols = []
    for r in ROWS:
        frames = cells[r]
        f0h = hist(frames[0])
        per = []
        for f, a in enumerate(frames):
            b = bbox(a)
            op = a[:, :, 3] > 0
            n = int(op.sum())
            semi = int(((a[:, :, 3] > 0) & (a[:, :, 3] < 255)).sum())
            s, v = hsv_sv(a[:, :, :3].astype(float))
            pale = op & (s < 0.15) & (v > 0.85)
            pale_cols = a[pale][:, :3]
            off = int((nearest_dist(pale_cols, ref_cols) > 24).sum()) if len(pale_cols) else 0
            pad = np.pad(op, 1, constant_values=False)
            edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
            dark = edge & (v < 0.3)
            per.append({
                "frame": f, "bbox": list(b), "width": b[2] - b[0] + 1, "height": b[3] - b[1] + 1,
                "foot_y": b[3], "centre_x": (b[0] + b[2]) / 2.0,
                "opaque_px": n, "semi_transparent_px": semi,
                "pale_px": int(pale.sum()), "pale_debris_px": off,
                "pale_debris_share": round(off / n, 5),
                "boundary_px": int(edge.sum()), "dark_outline_share": round(float(dark.sum() / max(1, edge.sum())), 4),
                "hist_similarity_to_f0": round(float(np.minimum(f0h, hist(a)).sum()), 4),
            })
        cols = np.unique(np.concatenate([colours(a) for a in frames]), axis=0)
        all_cols.append(cols)
        nd = nearest_dist(cols, ref_cols)
        px = np.concatenate([a[a[:, :, 3] > 0][:, :3] for a in frames])
        nd_px = nearest_dist(np.unique(px, axis=0), ref_cols)
        lookup = {tuple(c): d for c, d in zip(np.unique(px, axis=0).tolist(), nd_px)}
        weighted = float(np.mean([lookup[tuple(c)] for c in px.tolist()]))
        neigh = [frame_diff(frames[i], frames[i + 1]) for i in range(7)]
        seam = frame_diff(frames[7], frames[0])
        feet = [p["foot_y"] for p in per]
        heights = [p["height"] for p in per]
        out["directions"][r] = {
            "frames": per,
            "unique_opaque_colours": int(len(cols)),
            "semi_transparent_px_total": int(sum(p["semi_transparent_px"] for p in per)),
            "pale_debris_share_mean": round(float(np.mean([p["pale_debris_share"] for p in per])), 5),
            "dark_outline_share_mean": round(float(np.mean([p["dark_outline_share"] for p in per])), 4),
            "palette_to_reference_mean_rgb_dist": round(float(nd.mean()), 2),
            "palette_to_reference_pixel_weighted_rgb_dist": round(weighted, 2),
            "hist_similarity_mean_f1_to_f7": round(float(np.mean([p["hist_similarity_to_f0"] for p in per[1:]])), 4),
            "hist_similarity_min": round(float(min(p["hist_similarity_to_f0"] for p in per[1:])), 4),
            "median_height": float(np.median(heights)),
            "median_width": float(np.median([p["width"] for p in per])),
            "foot_y_values": feet, "foot_y_drift": max(feet) - min(feet),
            "centre_x_drift": max(p["centre_x"] for p in per) - min(p["centre_x"] for p in per),
            "loop_seam_diff_f7_f0": round(seam, 4),
            "neighbour_diff_mean": round(float(np.mean(neigh)), 4),
            "loop_seam_ratio": round(seam / float(np.mean(neigh)), 3) if np.mean(neigh) > 0 else None,
            "skin_side_f0": dict(zip(["skin_px", "skin_offset_x"], skin_side(frames[0]))),
        }
    D = out["directions"]
    allc = np.unique(np.concatenate(all_cols), axis=0)
    med_h = [D[r]["median_height"] for r in ROWS]
    out["summary"] = {
        "unique_opaque_colours_whole_set": int(len(allc)),
        "palette_to_reference_mean_rgb_dist_whole_set": round(float(nearest_dist(allc, ref_cols).mean()), 2),
        "semi_transparent_px_total": int(sum(D[r]["semi_transparent_px_total"] for r in ROWS)),
        "pale_debris_share_mean": round(float(np.mean([D[r]["pale_debris_share_mean"] for r in ROWS])), 5),
        "pale_debris_share_max_frame": max(p["pale_debris_share"] for r in ROWS for p in D[r]["frames"]),
        "dark_outline_share_mean": round(float(np.mean([D[r]["dark_outline_share_mean"] for r in ROWS])), 4),
        "hist_similarity_mean": round(float(np.mean([D[r]["hist_similarity_mean_f1_to_f7"] for r in ROWS])), 4),
        "hist_similarity_min": min(D[r]["hist_similarity_min"] for r in ROWS),
        "median_height_by_direction": dict(zip(ROWS, med_h)),
        "height_consistency_max_minus_min": max(med_h) - min(med_h),
        "foot_y_drift_by_direction": {r: D[r]["foot_y_drift"] for r in ROWS},
        "foot_y_drift_max": max(D[r]["foot_y_drift"] for r in ROWS),
        "lowest_foot_by_direction": {r: max(D[r]["foot_y_values"]) for r in ROWS},
        "loop_seam_ratio_by_direction": {r: D[r]["loop_seam_ratio"] for r in ROWS},
        "loop_seam_ratio_mean": round(float(np.mean([D[r]["loop_seam_ratio"] for r in ROWS])), 3),
        "neighbour_diff_mean": round(float(np.mean([D[r]["neighbour_diff_mean"] for r in ROWS])), 4),
    }
    return out


# ---------------------------------------------------------------- fault and craft numbers
def holes(a):
    """Transparent pixels fully enclosed by the figure (4-connected, not reaching the cell border)."""
    tr = a[..., 3] == 0
    seen = np.zeros_like(tr)
    stack = [(y, x) for y in range(CELL) for x in (0, CELL - 1) if tr[y, x]]
    stack += [(y, x) for x in range(CELL) for y in (0, CELL - 1) if tr[y, x]]
    for y, x in stack:
        seen[y, x] = True
    while stack:
        y, x = stack.pop()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < CELL and 0 <= nx < CELL and tr[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                stack.append((ny, nx))
    return int((tr & ~seen).sum())


def faults(atlas, raw, ref_cols):
    cells = split(atlas)
    res = {}
    # 1. back satchel: share of the lane's bag template drawn at its tracked place, and strap pixels
    line = SR.fs.outline_colour(raw)
    tpl = SR.templates(raw, line)
    bag = {}
    for r_i, t in sorted(tpl.items()):
        pres = [SR.presence(atlas, raw, r_i, f, t)[0] for f in range(8)]
        d = {"bag_drawn_pct": pres, "min": min(pres), "mean": round(float(np.mean(pres)), 1)}
        if r_i in SR.fs.BACK:
            d["strap_px"] = [SR.strap_px(atlas, raw, r_i, f) for f in range(8)]
        bag[ROWS[r_i]] = d
    res["f1_satchel"] = bag
    # 2 and 3. head tops (bbox top) per frame, bob range, standing (f0) and highest head per direction
    tops = {r: [bbox(c)[1] for c in cells[r]] for r in ROWS}
    f0 = [tops[r][0] for r in ROWS]
    hi = [min(tops[r]) for r in ROWS]
    res["f2_bob"] = {"head_top_rows": tops, "range": {r: max(tops[r]) - min(tops[r]) for r in ROWS},
                     "flat_rows": [r for r in ROWS if max(tops[r]) == min(tops[r])]}
    res["f3_turn_height"] = {"standing_head_top_f0": f0, "standing_spread": max(f0) - min(f0),
                             "highest_head_top": hi, "highest_spread": max(hi) - min(hi),
                             "largest_neighbour_drop_f0": max(abs(f0[i] - f0[(i + 1) % 8]) for i in range(8)),
                             "median_height": {r: float(np.median([bbox(c)[3] - bbox(c)[1] + 1 for c in cells[r]])) for r in ROWS},
                             "median_width": {r: float(np.median([bbox(c)[2] - bbox(c)[0] + 1 for c in cells[r]])) for r in ROWS}}
    # 4. blue eyes (colour lane's measure) and side goggle lenses
    res["f4_eyes"] = {"blue_eye_px_per_frame": {r: [CR.blue_px(c) for c in cells[r]] for r in ROWS},
                      "side_lenses": CR.lens_stats(atlas)}
    # 5. south and north walk (leg lane's measure)
    legs = {}
    for r in ("down", "up"):
        m = ML.measure_row(cells[r], ref_cols)
        legs[r] = {k: m[k] for k in ("distinct_leg_poses", "foot_configurations", "foot_left_rows", "foot_right_rows",
                                     "leg_shape_change_mean", "leg_shape_change_min", "bob_range",
                                     "hand_left_y_range", "hand_right_y_range", "hand_left_moves", "hand_right_moves")}
    res["f5_legs"] = legs
    # 6. head shimmer: head lane's aligned redraw share (best whole-head shift) and the bob lane's top-20-row version
    shim = {}
    for r in ROWS:
        _, un, al = HR.head_pairs(cells[r])
        hb = [BR.head_redraw(cells[r][f], cells[r][(f + 1) % 8]) for f in range(8)]
        shim[r] = {"headlock_aligned_mean": round(float(np.mean(al)), 3), "headlock_unaligned_mean": round(float(np.mean(un)), 3),
                   "bob_top20_aligned_mean": round(float(np.mean(hb)), 3)}
    res["f6_head_redraw"] = shim
    # 7. colours per frame, maroon far leg
    res["f7_colour"] = {"colours_per_frame_max": {r: max(len(colours(c)) for c in cells[r]) for r in ROWS},
                        "colours_per_row": {r: int(len(np.unique(np.concatenate([colours(c) for c in cells[r]]), axis=0))) for r in ROWS},
                        "maroon_below_hips": CR.maroon_stats(atlas)}
    # craft rules
    alpha_vals = sorted(int(v) for v in np.unique(atlas[..., 3]))
    clip = {r: sum(1 for c in cells[r] if (c[0, :, 3].any() or c[-1, :, 3].any() or c[:, 0, 3].any() or c[:, -1, 3].any()))
            for r in ROWS}
    res["craft"] = {"alpha_values": alpha_vals,
                    "frames_touching_cell_edge": clip,
                    "lowest_foot": {r: max(bbox(c)[3] for c in cells[r]) for r in ROWS},
                    "any_pixel_below_72": any(bbox(c)[3] > FOOT_Y for r in ROWS for c in cells[r]),
                    "enclosed_holes_px": {r: sum(holes(c) for c in cells[r]) for r in ROWS}}
    return res


def measure_atlas(atlas, raw=None, ref=None):
    raw = rgba(RAW_PATH) if raw is None else raw
    ref = rgba(REF_PATH) if ref is None else ref
    ref_cols = colours(ref)
    return {"set": measure_set(split(atlas), ref_cols), "faults": faults(atlas, raw, ref_cols)}


def headline(m):
    """A short per-step summary for the chain log."""
    s, F = m["set"]["summary"], m["faults"]
    D = m["set"]["directions"]
    return {
        "colours_whole_set": s["unique_opaque_colours_whole_set"],
        "colours_per_row": [D[r]["unique_opaque_colours"] for r in ROWS],
        "colours_per_frame_max": [F["f7_colour"]["colours_per_frame_max"][r] for r in ROWS],
        "palette_px_weighted": [D[r]["palette_to_reference_pixel_weighted_rgb_dist"] for r in ROWS],
        "dark_outline_share": [D[r]["dark_outline_share_mean"] for r in ROWS],
        "head_top_f0": F["f3_turn_height"]["standing_head_top_f0"],
        "highest_head_top": F["f3_turn_height"]["highest_head_top"],
        "bob_range": [F["f2_bob"]["range"][r] for r in ROWS],
        "head_redraw_aligned": [F["f6_head_redraw"][r]["headlock_aligned_mean"] for r in ROWS],
        "blue_eye_px_total": {r: sum(F["f4_eyes"]["blue_eye_px_per_frame"][r]) for r in ROWS},
        "bag_min_mean": {r: [v["min"], v["mean"]] for r, v in F["f1_satchel"].items()},
        "legs": {r: [v["distinct_leg_poses"], v["foot_configurations"], v["leg_shape_change_min"]] for r, v in F["f5_legs"].items()},
        "maroon": F["f7_colour"]["maroon_below_hips"],
        "lowest_foot": [F["craft"]["lowest_foot"][r] for r in ROWS],
        "alpha_values": F["craft"]["alpha_values"],
        "edge_touch": sum(F["craft"]["frames_touching_cell_edge"].values()),
        "holes_px": sum(F["craft"]["enclosed_holes_px"].values()),
        "loop_seam_ratio": [D[r]["loop_seam_ratio"] for r in ROWS],
    }


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    m = measure_atlas(rgba(sys.argv[1]))
    out = json.dumps({"headline": headline(m), **m}, indent=1, default=str)
    if len(sys.argv) > 2:
        Path(sys.argv[2]).write_text(out, encoding="utf-8")
    print(json.dumps(headline(m), default=str))


if __name__ == "__main__":
    main()
