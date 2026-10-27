"""Measure the leg fix: leg motion, feet, hands, bob and pixel discipline, raw against fixed against RD (Claude, 2026-10-26).

    python tools/art/walk_fix/measure_legs.py RAW_ATLAS FIXED_ATLAS OUT_DIR

Writes OUT_DIR/metrics.json and OUT_DIR/compare_4x.png (every changed row: raw, fixed, RD at 4x nearest, then the
raw and fixed rows at the game's outdoor size of 1.40625 screen px per art px). Definitions are in metrics.json.
The colour, outline and palette numbers use the same definitions as the 2026-10-26 test's build_compare.py, so they
compare with measurements.json.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import fix_legs as F  # noqa: E402

HT = F.HT
REF_PATH = HT / "docs/art/characters/sprite-tool-test-2026-10-26/reference/courier_south_ref_80.png"
FONT_PATH = HT / "assets/fonts/Silkscreen-Regular.ttf"
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)
GUIDE = (0x55, 0x63, 0x46)
GAME_SCALE = 30.0 / 64.0 * 3.0   # CHIBI_SCALE x outdoor camera zoom = 1.40625


def rgba(p):
    return np.array(Image.open(p).convert("RGBA"))


def shape_diff(a, b, top):
    """Share of pixels in the union of both silhouettes (rows >= top) where only one of them is opaque."""
    ma, mb = a[top:, :, 3] > 0, b[top:, :, 3] > 0
    union = ma | mb
    return float((ma != mb)[union].mean()) if union.any() else 0.0


def frame_diff(a, b, top):
    """Share of pixels in the union of both silhouettes (rows >= top) that differ in alpha or colour."""
    a, b = a[top:], b[top:]
    ma, mb = a[..., 3] > 0, b[..., 3] > 0
    union = ma | mb
    differ = (ma != mb) | (ma & mb & np.any(a[..., :3] != b[..., :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def nearest_dist(cols, ref_cols):
    d = np.sqrt(((cols[:, None, :].astype(float) - ref_cols[None, :, :].astype(float)) ** 2).sum(-1))
    return d.min(1)


def outline_share(a):
    op = a[..., 3] > 0
    p = np.pad(op, 1)
    edge = op & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
    _, _, v = F.hsv(a)
    return float((edge & (v < 0.3)).sum() / max(1, edge.sum()))


def hands(c, g):
    op, teal, skin = F.materials(c)[:3]
    cols = np.arange(F.CELL)[None, :]
    rows = np.arange(F.CELL)[:, None]
    out = {}
    for side, sel in (("left", cols < g["box"][0] + 2), ("right", cols > g["box"][1] - 2)):
        s = skin & sel & (rows >= 40) & (rows < g["hip"] + 6)
        ys, xs = np.nonzero(s)
        out[side] = None if len(ys) == 0 else [round(float(xs.mean()), 2), round(float(ys.mean()), 2), int(len(ys))]
    return out


def measure_row(cells, ref_cols, margin=0):
    geo, bob, base = F.row_geometry(cells, margin=margin, trust_found=True)
    hip_med = int(np.median([g["hip"] for g in geo]))
    per = []
    for f, (c, g) in enumerate(zip(cells, geo)):
        op = c[..., 3] > 0
        cols = np.unique(c[op][:, :3], axis=0)
        per.append({
            "frame": f, "head_top": g["top"], "hip": g["hip"],
            "foot_left": g["foot_left"], "foot_right": g["foot_right"],
            "foot_gap": None if g["foot_left"] is None or g["foot_right"] is None else g["foot_left"] - g["foot_right"],
            "leg_px": int(g["mask"].sum()), "hands": hands(c, g),
            "colours": int(len(cols)),
            "semi_alpha_px": int(((c[..., 3] > 0) & (c[..., 3] < 255)).sum()),
            "dark_outline_share": round(outline_share(c), 4),
        })
    legs = [frame_diff(cells[i], cells[(i + 1) % 8], hip_med) for i in range(8)]
    whole = [frame_diff(cells[i], cells[(i + 1) % 8], 0) for i in range(8)]
    shape = [shape_diff(cells[i], cells[(i + 1) % 8], hip_med) for i in range(8)]
    # distinct leg poses: leg zones that differ from every earlier frame by more than 10% of their pixels
    poses = []
    for i in range(8):
        if all(frame_diff(cells[i], cells[j], hip_med) > 0.10 for j in poses):
            poses.append(i)
    px = np.concatenate([c[c[..., 3] > 0][:, :3] for c in cells])
    upx, inv = np.unique(px, axis=0, return_inverse=True)
    weighted = float(nearest_dist(upx, ref_cols)[inv.ravel()].mean())
    hl = [p["hands"]["left"] for p in per]
    hr = [p["hands"]["right"] for p in per]

    def span(vals, k):
        v = [x[k] for x in vals if x is not None]
        return round(max(v) - min(v), 2) if v else None

    def moved(vals):
        return sum(1 for i in range(8) if vals[i] is not None and vals[(i + 1) % 8] is not None
                   and (vals[i][0] != vals[(i + 1) % 8][0] or vals[i][1] != vals[(i + 1) % 8][1]))

    fl = [p["foot_left"] for p in per]
    fr = [p["foot_right"] for p in per]
    gaps = [p["foot_gap"] for p in per]
    nz = [g for g in gaps if g]
    flips = sum(1 for i in range(len(nz)) if np.sign(nz[i]) != np.sign(nz[(i + 1) % len(nz)])) if nz else 0
    return {
        "frames": per,
        "leg_zone_from_row": hip_med,
        "leg_change_neighbours": [round(x, 4) for x in legs],
        "leg_change_mean": round(float(np.mean(legs)), 4), "leg_change_min": round(float(min(legs)), 4),
        "whole_change_mean": round(float(np.mean(whole)), 4),
        "distinct_leg_poses": len(poses),
        "foot_left_rows": fl, "foot_right_rows": fr, "foot_gap_rows": gaps,
        "foot_left_lift_range": max(fl) - min(fl), "foot_right_lift_range": max(fr) - min(fr),
        "foot_gap_sign_changes": flips,
        "foot_configurations": len(set(zip(fl, fr))),
        "leg_shape_change_neighbours": [round(x, 4) for x in shape],
        "leg_shape_change_mean": round(float(np.mean(shape)), 4),
        "leg_shape_change_min": round(float(min(shape)), 4),
        "head_top_rows": [p["head_top"] for p in per],
        "bob_range": max(p["head_top"] for p in per) - min(p["head_top"] for p in per),
        "hand_left_y_range": span(hl, 1), "hand_left_x_range": span(hl, 0),
        "hand_right_y_range": span(hr, 1), "hand_right_x_range": span(hr, 0),
        "hand_left_px": [None if h is None else h[2] for h in hl],
        "hand_right_px": [None if h is None else h[2] for h in hr],
        "hand_left_moves": moved(hl), "hand_right_moves": moved(hr),
        "colours_row": int(len(upx)), "colours_max_frame": max(p["colours"] for p in per),
        "semi_alpha_px_total": sum(p["semi_alpha_px"] for p in per),
        "alpha_values": sorted(int(v) for v in np.unique(np.concatenate([c[..., 3].ravel() for c in cells]))),
        "dark_outline_share_mean": round(float(np.mean([p["dark_outline_share"] for p in per])), 4),
        "palette_to_reference_pixel_weighted_rgb_dist": round(weighted, 2),
        "loop_seam_ratio": round(whole[7] / float(np.mean(whole[:7])), 3) if np.mean(whole[:7]) else None,
    }


def font(size):
    try:
        return ImageFont.truetype(str(FONT_PATH), size)
    except OSError:
        return ImageFont.load_default(size=size)


def up(a, s):
    im = Image.fromarray(a, "RGBA")
    return im.resize((round(im.width * s), round(im.height * s)), Image.NEAREST)


def compare_image(sets, rows, out):
    S = 4
    cw = F.CELL * S
    LM, BAND, GAP = 150, 40, 24
    g = round(F.CELL * GAME_SCALE)
    game_h = 34 + 2 * g + 10
    H = 70 + len(rows) * (BAND + 3 * cw + game_h + GAP)
    W = LM + 8 * cw
    img = Image.new("RGBA", (W, H), PAGE + (255,))
    dr = ImageDraw.Draw(img)
    dr.text((10, 14), "Leg fix (lane 5): raw PixelLab, fixed, RD for each changed row, 4x nearest. Line = feet row 72.",
            fill=TEXT, font=font(22))
    y = 70
    for r in rows:
        dr.text((10, y + 6), r.upper() + "  frames 0 to 7, left to right", fill=TEXT, font=font(22))
        y += BAND
        for tag, cells in sets:
            dr.text((12, y + cw // 2 - 12), tag, fill=TEXT, font=font(24))
            for f in range(8):
                x = LM + f * cw
                dr.rectangle([x, y, x + cw - 1, y + cw - 1], fill=GROUND + (255,))
                dr.rectangle([x, y + 73 * S, x + cw - 1, y + 73 * S + 1], fill=GUIDE + (255,))
                img.alpha_composite(up(cells[r][f], S), (x, y))
                dr.text((x + 6, y + 4), "f%d" % f, fill=(220, 225, 210, 255), font=font(16))
            y += cw
        dr.text((12, y + 8), "In game (1.40625 px per art px): raw on top, fixed below", fill=TEXT, font=font(16))
        y += 34
        for k, (tag, cells) in enumerate(sets[:2]):
            for f in range(8):
                x = LM + f * (g + 30)
                dr.rectangle([x, y + k * g, x + g - 1, y + (k + 1) * g - 1], fill=GROUND + (255,))
                img.alpha_composite(up(cells[r][f], GAME_SCALE), (x, y + k * g))
        y += 2 * g + 10 + GAP
    img.save(out)


def main():
    raw_p, fix_p, out_dir = sys.argv[1], sys.argv[2], Path(sys.argv[3])
    out_dir.mkdir(parents=True, exist_ok=True)
    raw, fix, rd = F.split(rgba(raw_p)), F.split(rgba(fix_p)), F.split(rgba(F.RD_PATH))
    ref = rgba(REF_PATH)
    ref_cols = np.unique(ref[ref[..., 3] > 0][:, :3], axis=0)
    metrics = {
        "note": "Measured by tools/art/walk_fix/measure_legs.py on 2026-10-26. before = raw PixelLab atlas, "
                "after = fix_legs.py output, rd = the in-game RD atlas (our own art, the target).",
        "inputs": {"before": raw_p, "after": fix_p, "rd": str(F.RD_PATH)},
        "definitions": {
            "leg_zone": "rows from the row's median hip line (first trouser row under the belt or hem) down",
            "leg_change_neighbours": "for frames f and f+1 (7 wraps to 0): share of pixels in the union silhouette of "
                                     "the leg zone that differ in alpha or colour",
            "distinct_leg_poses": "frames whose leg zone differs by more than 10% from every earlier kept frame",
            "foot_left/right": "lowest leg-mask row left / right of the leg box centre (screen sides); 72 = ground",
            "foot_gap": "foot_left minus foot_right; its sign flips when the feet trade places",
            "head_top": "first opaque row (body bob = its range)",
            "hands": "[x, y, n]: centroid and count of skin pixels beside the leg box, rows 40 to hip+5",
            "leg_shape_change_neighbours": "for frames f and f+1: share of the union silhouette of the leg zone where "
                                           "only one frame is opaque (outline motion; colour shimmer does not count)",
            "foot_configurations": "distinct (foot_left, foot_right) row pairs over the 8 frames",
            "foot_gap_sign_changes": "times the feet trade places around the loop (zero gaps skipped); a walk has 2",
            "hand_*_moves": "neighbour frame pairs where that hand's centroid changed",
            "colours": "unique opaque RGB per frame; colours_row = over the row's 8 frames",
            "dark_outline_share": "silhouette edge pixels with HSV value < 0.3 over all edge pixels (build_compare.py)",
            "palette_to_reference_pixel_weighted_rgb_dist": "mean RGB distance of every opaque pixel to the nearest "
                                                            "reference colour (build_compare.py)",
            "loop_seam_ratio": "whole-cell change f7 to f0 over the mean of the other 7 steps",
        },
        "rows": {},
    }
    for r in F.FIX_ROWS:
        metrics["rows"][r] = {
            "before": measure_row(raw[r], ref_cols),
            "after": measure_row(fix[r], ref_cols),
            "rd": measure_row(rd[r], ref_cols),
        }
    untouched = [r for r in F.ROWS if r not in F.FIX_ROWS]
    metrics["other_rows_identical"] = all(np.array_equal(np.stack(raw[r]), np.stack(fix[r])) for r in untouched)
    (out_dir / "metrics.json").write_text(json.dumps(metrics, indent=1), encoding="utf-8")
    compare_image([("RAW", raw), ("FIXED", fix), ("RD", rd)], list(F.FIX_ROWS), out_dir / "compare_4x.png")
    keys = ["leg_shape_change_mean", "leg_shape_change_min", "leg_change_mean", "foot_configurations", "foot_left_rows", "foot_right_rows",
            "foot_gap_sign_changes", "head_top_rows", "bob_range", "hand_left_y_range", "hand_right_y_range",
            "hand_left_moves", "hand_right_moves", "colours_row", "colours_max_frame", "alpha_values",
            "dark_outline_share_mean", "palette_to_reference_pixel_weighted_rgb_dist", "loop_seam_ratio"]
    for r in F.FIX_ROWS:
        print(r)
        for k in keys:
            print("  %-46s %-34s %-34s %s" % (k, metrics["rows"][r]["before"][k], metrics["rows"][r]["after"][k],
                                              metrics["rows"][r]["rd"][k]))
    print("other rows identical:", metrics["other_rows_identical"])


if __name__ == "__main__":
    main()
