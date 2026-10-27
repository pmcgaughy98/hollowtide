"""Apply fix_colour.py to the raw PixelLab atlas, measure before and after, draw the compare images.

usage: python colour_report.py [SCRATCH_DIR]

Writes (all new files):
  docs/art/characters/sprite-tool-test-2026-10-26/fix/colour/after.png
  docs/art/characters/sprite-tool-test-2026-10-26/fix/colour/compare_4x.png       raw / fixed / RD, every changed row
  docs/art/characters/sprite-tool-test-2026-10-26/fix/colour/compare_ingame.png   same rows at 1.40625 screen px per art px
  docs/art/characters/sprite-tool-test-2026-10-26/fix/colour/metrics.json
  docs/art/characters/sprite-tool-test-2026-10-26/fix/colour/fix_log.json          what each regional repair touched
SCRATCH_DIR (optional) gets 8x head and leg close-ups for review.

The palette distance numbers use the same formula as the test's build_compare.py (Euclidean RGB distance
of each colour, or each opaque pixel, to the nearest colour of the reference frame), so they compare
directly with measurements.json.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import fix_colour as fc  # noqa: E402

HT = fc.HT
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW_PATH = TEST / "pixellab_courier_walk_native80.png"
OUT_DIR = TEST / "fix/colour"
FONT_PATH = HT / "assets/fonts/Silkscreen-Regular.ttf"
ROWS, CELL = fc.ROWS, fc.CELL
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)
INGAME = 30.0 / 64.0 * 3.0   # CHIBI_SCALE x outdoor camera zoom = 1.40625


def font(size):
    try:
        return ImageFont.truetype(str(FONT_PATH), size)
    except OSError:
        return ImageFont.load_default(size=size)


def cell(a, r, f):
    return a[r * CELL:(r + 1) * CELL, f * CELL:(f + 1) * CELL]


def colours(a):
    return np.unique(a[a[..., 3] > 0][:, :3], axis=0)


def nearest_rgb(cols, ref_cols):
    d = np.sqrt(((cols[:, None, :].astype(float) - ref_cols[None, :, :].astype(float)) ** 2).sum(-1))
    return d.min(1)


def head_band(a):
    y0, y1 = fc.bounds(a)
    m = np.zeros(a.shape[:2], bool)
    if y0 is not None:
        m[y0:y0 + int(0.47 * (y1 - y0 + 1))] = True
    return m


def blue_px(a):
    op, L, C, Hh = fc.masks(a)
    return int((op & head_band(a) & (Hh >= 235) & (Hh <= 305) & (C >= 0.05) & (L >= 0.2)).sum())


def frame_diff(a, b, region=None):
    ma, mb = a[..., 3] > 0, b[..., 3] > 0
    union = ma | mb
    if region is not None:
        union &= region
    differ = (ma != mb) | (ma & mb & np.any(a[..., :3] != b[..., :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def outline_share(a):
    op = a[..., 3] > 0
    pad = np.pad(op, 1, constant_values=False)
    edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    v = a[..., :3].max(2) / 255.0
    return float((edge & (v < 0.3)).sum() / max(1, edge.sum()))


def measure(atlas, ref_cols, log):
    out = {"rows": {}}
    ref_hex = {fc.hx(c) for c in ref_cols}
    for r, row in enumerate(ROWS):
        frames = [cell(atlas, r, f) for f in range(8)]
        cols = np.unique(np.concatenate([colours(a) for a in frames]), axis=0)
        px = np.concatenate([a[a[..., 3] > 0][:, :3] for a in frames])
        upx, inv = np.unique(px, axis=0, return_inverse=True)
        nd = nearest_rgb(upx, ref_cols)
        per_px = nd[inv.ravel()]
        heads = [head_band(a) for a in frames]
        shimmer = [frame_diff(frames[f], frames[(f + 1) % 8], heads[f] | heads[(f + 1) % 8]) for f in range(8)]
        out["rows"][row] = {
            "colours_row": int(len(cols)),
            "colours_per_frame": [int(len(colours(a))) for a in frames],
            "palette_to_reference_mean_rgb_dist": round(float(nearest_rgb(cols, ref_cols).mean()), 2),
            "palette_to_reference_pixel_weighted_rgb_dist": round(float(per_px.mean()), 2),
            "off_reference_px_share": round(float(np.mean([fc.hx(c) not in ref_hex for c in upx[inv.ravel()]])), 4),
            "far_off_reference_px_share_gt24": round(float((per_px > 24).mean()), 4),
            "blue_px_in_head_per_frame": [blue_px(a) for a in frames],
            "head_pixels_changing_per_step_mean": round(float(np.mean(shimmer)), 4),
            "dark_outline_share_mean": round(float(np.mean([outline_share(a) for a in frames])), 4),
        }
    allc = colours(atlas)
    out["whole_set"] = {
        "colours": int(len(allc)),
        "palette_to_reference_mean_rgb_dist": round(float(nearest_rgb(allc, ref_cols).mean()), 2),
        "alpha_values": sorted(int(v) for v in np.unique(atlas[..., 3])),
        "opaque_px": int((atlas[..., 3] > 0).sum()),
    }
    return out


def region_colours(atlas, log, key, part):
    """Colours, before or after, at the pixels a regional repair found on the raw atlas."""
    res = {}
    for k, v in log[key].items():
        pts = v["px"] if key == "lens" else v
        if not pts:
            continue
        r = ROWS.index(k.rsplit("_f", 1)[0])
        f = int(k.rsplit("_f", 1)[1])
        c = cell(atlas, r, f)
        res[k] = ["#" + fc.hx(c[y, x]) for y, x, *_ in pts]
    return res


def lens_stats(atlas):
    """Independent of the repair: pale or grey pixels and teal pixels in the goggle band of the side rows."""
    res = {}
    for row, facing in fc.SIDE_ROWS.items():
        r = ROWS.index(row)
        pale, teal = [], []
        for f in range(8):
            a = cell(atlas, r, f)
            op, L, C, Hh = fc.masks(a)
            y0, _ = fc.bounds(a)
            band = np.zeros_like(op)
            band[y0:y0 + 13] = True
            xs = np.nonzero(op & band)[1]
            front = np.zeros_like(op)
            if facing < 0:
                front[:, xs.min():xs.min() + 12] = True
            else:
                front[:, xs.max() - 11:xs.max() + 1] = True
            m = op & band & front
            pale.append(int((m & (((C < 0.03) & (L >= 0.45) & (L < 0.99)) | ((Hh >= 150) & (Hh <= 310) & (C <= 0.07) & (L >= 0.78)))).sum()))
            teal.append(int((m & (Hh >= 180) & (Hh <= 225) & (C >= 0.06) & (L >= 0.35)).sum()))
        res[row] = {"pale_or_grey_px_per_frame": pale, "teal_px_per_frame": teal}
    return res


def maroon_stats(atlas):
    res = {}
    for r, row in enumerate(ROWS):
        counts = []
        for f in range(8):
            a = cell(atlas, r, f)
            op, L, C, Hh = fc.masks(a)
            y0, foot = fc.bounds(a)
            zone = np.zeros_like(op)
            zone[y0 + int(0.62 * (foot - y0 + 1)):] = True
            counts.append(int((op & zone & (Hh >= 12) & (Hh <= 46) & (C >= 0.065) & (L >= 0.2) & (L <= 0.36)).sum()))
        if any(counts):
            res[row] = counts
    return res


def up(a, s):
    im = Image.fromarray(np.ascontiguousarray(a), "RGBA")
    return im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.NEAREST)


def strips_image(rows, sets, scale, title, label_px):
    cw = round(CELL * scale)
    LM, BAND, GAP = int(label_px * 5.5), int(label_px * 1.8), int(label_px * 0.8)
    W = LM + 8 * cw
    H = int(label_px * 2.4) + len(rows) * (BAND + len(sets) * cw + GAP)
    img = Image.new("RGBA", (W, H), PAGE + (255,))
    dr = ImageDraw.Draw(img)
    dr.text((10, 10), title, fill=TEXT, font=font(label_px))
    y = int(label_px * 2.4)
    for r in rows:
        dr.text((10, y + 6), ROWS[r].upper(), fill=TEXT, font=font(label_px))
        y += BAND
        for tag, atlas in sets:
            dr.text((10, y + cw // 2 - label_px // 2), tag, fill=TEXT, font=font(int(label_px * 0.8)))
            for f in range(8):
                x = LM + f * cw
                dr.rectangle([x, y, x + cw - 1, y + cw - 1], fill=GROUND + (255,))
                img.alpha_composite(up(cell(atlas, r, f), scale), (x, y))
                if scale >= 2:
                    dr.text((x + 4, y + 2), f"f{f}", fill=(220, 225, 210, 255), font=font(int(label_px * 0.6)))
            y += cw
        y += GAP
    return img


def closeups(raw, after, rd, scratch):
    """8x heads for the face rows and legs for the right row, raw above fixed."""
    def crop(a, r, f, x0, y0, x1, y1, s):
        c = cell(a, r, f)[y0:y1, x0:x1]
        im = Image.new("RGBA", (x1 - x0, y1 - y0), GROUND + (255,))
        im.alpha_composite(Image.fromarray(np.ascontiguousarray(c), "RGBA"))
        return im.resize(((x1 - x0) * s, (y1 - y0) * s), Image.NEAREST)

    for name, r, box in (("left", 2, (24, 8, 54, 34)), ("right", 6, (26, 8, 56, 34)),
                         ("down_right", 7, (26, 8, 56, 34)), ("down_left", 1, (24, 8, 54, 34)),
                         ("right_legs", 6, (24, 40, 58, 76)), ("down", 0, (24, 6, 56, 34)), ("up", 4, (20, 6, 60, 74))):
        tiles = [[crop(a, r, f, *box, 6) for f in range(8)] for a in (raw, after)]
        w, h = tiles[0][0].size
        S = Image.new("RGBA", (8 * (w + 4), 2 * (h + 4)), PAGE + (255,))
        for k in range(2):
            for f in range(8):
                S.alpha_composite(tiles[k][f], (f * (w + 4), k * (h + 4)))
        S.save(Path(scratch) / f"close_{name}.png")


def main():
    scratch = sys.argv[1] if len(sys.argv) > 1 else None
    raw = fc.load(RAW_PATH)
    rd = fc.load(fc.RD_PATH)
    ref = fc.load(fc.REF_PATH)
    ref_cols = colours(ref)
    after, log = fc.fix_colour(raw)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    Image.fromarray(after, "RGBA").save(OUT_DIR / "after.png")
    (OUT_DIR / "fix_log.json").write_text(json.dumps(log, indent=1), encoding="utf-8")

    # chaining checks: the fix is a pure function, applying it twice changes nothing
    again, _ = fc.fix_colour(after)
    idempotent_px = int(np.any(again != after, axis=2).sum())

    changed_rows = [r for r in range(8) if np.any(raw[r * CELL:(r + 1) * CELL] != after[r * CELL:(r + 1) * CELL])]
    changed_px = {ROWS[r]: [int(np.any(cell(raw, r, f) != cell(after, r, f), axis=2).sum()) for f in range(8)] for r in range(8)}

    m_before, m_after = measure(raw, ref_cols, log), measure(after, ref_cols, log)
    m_rd = measure(rd, ref_cols, log)
    metrics = {
        "note": "colour lane (faults 4 and 7), fix_colour.py applied to the raw PixelLab atlas. "
                "Palette distances use build_compare.py's formula (RGB distance to the nearest reference colour).",
        "palette": {"size": log["palette_size"], "colours": ["#" + h for h in log["palette"]],
                    "from_reference": int(len(ref_cols)), "from_rd": {"#" + k: v for k, v in log["rd_extras"].items()}},
        "lock": log["lock"],
        "pixels_changed_per_frame": changed_px,
        "alpha_unchanged": bool(np.array_equal(raw[..., 3], after[..., 3])),
        "idempotent_second_pass_px_changed": idempotent_px,
        "before": m_before, "after": m_after, "rd_for_scale": m_rd,
        "eyes": {"pixels_found_on_raw": sum(len(v) for v in log["eyes"].values()),
                 "frames": len(log["eyes"]),
                 "before": region_colours(raw, log, "eyes", None), "after": region_colours(after, log, "eyes", None)},
        "lens": {"per_frame": {k: {"source": v["source"], "core_px": v["core_px"]} for k, v in log["lens"].items()},
                 "before": region_colours(raw, log, "lens", None), "after": region_colours(after, log, "lens", None),
                 "goggle_band_counts_before": lens_stats(raw), "goggle_band_counts_after": lens_stats(after)},
        "far_leg": {"repairs": log["far_leg"], "maroon_px_below_hips_before": maroon_stats(raw),
                    "maroon_px_below_hips_after": maroon_stats(after)},
    }
    (OUT_DIR / "metrics.json").write_text(json.dumps(metrics, indent=1), encoding="utf-8")

    sets = (("RAW", raw), ("FIXED", after), ("RD", rd))
    strips_image(changed_rows, sets, 4, "Colour fix: raw PixelLab (top), colour-fixed (middle), RD in game (bottom). 4x nearest.", 26) \
        .save(OUT_DIR / "compare_4x.png")
    strips_image(changed_rows, sets, INGAME, "In-game size, 1.40625 screen px per art px (outdoors). Raw / fixed / RD.", 14) \
        .save(OUT_DIR / "compare_ingame.png")
    if scratch:
        closeups(raw, after, rd, scratch)

    short = {row: {k: (m_before["rows"][row][k], m_after["rows"][row][k]) for k in
                   ("colours_row", "palette_to_reference_pixel_weighted_rgb_dist", "off_reference_px_share",
                    "head_pixels_changing_per_step_mean", "dark_outline_share_mean")} for row in ROWS}
    print(json.dumps(short, indent=0))
    print("colours per frame after:", {row: max(m_after["rows"][row]["colours_per_frame"]) for row in ROWS})
    print("blue before:", {row: m_before["rows"][row]["blue_px_in_head_per_frame"] for row in ROWS})
    print("blue after: ", {row: m_after["rows"][row]["blue_px_in_head_per_frame"] for row in ROWS})
    print("lens band before:", metrics["lens"]["goggle_band_counts_before"])
    print("lens band after: ", metrics["lens"]["goggle_band_counts_after"])
    print("maroon:", metrics["far_leg"]["maroon_px_below_hips_before"], metrics["far_leg"]["maroon_px_below_hips_after"])
    print("whole set:", m_before["whole_set"]["colours"], "->", m_after["whole_set"]["colours"], "| idempotent px", idempotent_px,
          "| alpha same", metrics["alpha_unchanged"], "| changed rows", [ROWS[r] for r in changed_rows])


if __name__ == "__main__":
    main()
