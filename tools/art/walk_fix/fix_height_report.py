"""Apply fix_height.py to the raw PixelLab atlas and write the lane's evidence (Claude, 2026-10-26).

    python tools/art/walk_fix/fix_height_report.py

Writes into docs/art/characters/sprite-tool-test-2026-10-26/fix/height/:
  after.png       the fix applied to the raw atlas
  plan.json       which rows were duplicated in each direction, and the cost of every candidate row
  compare_4x.png  for each changed direction: raw, fixed, RD, all 8 frames at 4x nearest
  ingame.png      frames 0 and 2 of every direction at the game's 1.40625 screen px per art px
  metrics.json    before, after and RD numbers

Measurement definitions match the 2026-10-26 test's build_compare.py (bbox, height, dark outline share,
unique colours); the extra ones are written into metrics.json.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from fix_height import fix_atlas, ROWS, CELL  # noqa: E402

HT = Path("C:/Users/pmcga/dev/hollowtide")
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW = TEST / "pixellab_courier_walk_native80.png"
RD_PATH = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
OUT = TEST / "fix/height"
FONT_PATH = HT / "assets/fonts/Silkscreen-Regular.ttf"
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)
GUIDE = (0x55, 0x63, 0x46)
MARK = (0xE8, 0x9A, 0x3C)
INGAME = 30.0 / 64.0 * 3.0  # CHIBI_SCALE x outdoor camera zoom = 1.40625
MIRRORS = [("left", "right"), ("down_left", "down_right"), ("up_left", "up_right")]


def font(size):
    try:
        return ImageFont.truetype(str(FONT_PATH), size)
    except OSError:
        return ImageFont.load_default(size=size)


def load(p):
    return np.array(Image.open(p).convert("RGBA"))


def cells(atlas, i):
    return [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] for f in range(8)]


def bbox(c):
    ys, xs = np.nonzero(c[..., 3] > 0)
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def value(c):
    return c[..., :3].max(axis=2) / 255.0


def outline_stats(c):
    """Boundary = opaque pixel with a transparent 4-neighbour. Dark = HSV value < 0.3 (build_compare's rule).
    gaps = boundary pixels that are not dark. doubles = L-corners in the dark boundary line (finish_sprite's rule)."""
    op = c[..., 3] > 0
    pad = np.pad(op, 1, constant_values=False)
    edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    dark = edge & (value(c) < 0.3)
    d = dark
    doubles = int(((d[1:-1, 1:-1] & d[1:-1, :-2] & d[:-2, 1:-1] & ~d[:-2, :-2]) |
                   (d[1:-1, 1:-1] & d[1:-1, 2:] & d[:-2, 1:-1] & ~d[:-2, 2:])).sum())
    return int(edge.sum()), int(dark.sum()), int((edge & ~dark).sum()), doubles


def widths(c, top, foot):
    """Head width (widest row in the top 35 percent) and torso width (row at 53 percent of the height)."""
    op = c[..., 3] > 0
    h = foot - top
    head = max(int(np.ptp(np.nonzero(op[y])[0]) + 1) for y in range(top, top + int(0.35 * h)) if op[y].any())
    ty = top + int(round(0.53 * h))
    xs = np.nonzero(op[ty])[0]
    return head, int(np.ptp(xs) + 1) if len(xs) else 0


def frame_diff(a, b):
    """build_compare.py's rule: share of pixels in the union of both silhouettes that differ in alpha or colour."""
    ma, mb = a[..., 3] > 0, b[..., 3] > 0
    union = ma | mb
    differ = (ma != mb) | (ma & mb & np.any(a[..., :3] != b[..., :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def simulated_bob(atlas, pattern=(0, 1, 2, 1, 0, 1, 2, 1), cut=46):
    """Stand-in for a bob fix applied first: in each frame, delete b rows of the torso at y=cut and pad
    the top, so the head drops b px while the feet stay. Only used to test chaining."""
    out = atlas.copy()
    for i in range(8):
        for f, b in enumerate(pattern):
            c = atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL]
            keep = [y for y in range(CELL) if not cut <= y < cut + b]
            new = np.concatenate([np.zeros((b, CELL, 4), np.uint8), c[keep]])
            out[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] = new
    return out


def chain_tests(raw, fixed, plan):
    """Does fix_height still work when it runs on the output of other fixes?"""
    res = {}
    _, p2 = fix_atlas(fixed)
    res["run_twice_adds_rows"] = {r: e["rows_added"] for r, e in p2["directions"].items()}
    bob = simulated_bob(raw)
    bob_fixed, pb = fix_atlas(bob)
    mb, mbf = measure(bob), measure(bob_fixed)
    res["after_simulated_bob"] = {
        "rows_added": {r: e["rows_added"] for r, e in pb["directions"].items()},
        "duplicated_rows": {r: [d["y"] for d in e.get("duplicated_rows", [])] for r, e in pb["directions"].items()},
        "head_top_min_spread_before_after": [mb["summary"]["head_top_min_spread"], mbf["summary"]["head_top_min_spread"]],
        "bob_amplitude_kept": all(
            np.ptp(mb["rows"][r]["head_top_per_frame"]) == np.ptp(mbf["rows"][r]["head_top_per_frame"]) for r in ROWS),
        "lowest_foot_after": mbf["summary"]["lowest_foot_by_direction"],
    }
    clamp = (raw & np.array([0xF0, 0xF0, 0xF0, 0xFF], np.uint8))
    _, pc = fix_atlas(clamp)
    res["after_palette_clamp_to_4_bits"] = {
        "rows_added": {r: e["rows_added"] for r, e in pc["directions"].items()},
        "duplicated_rows": {r: [d["y"] for d in e.get("duplicated_rows", [])] for r, e in pc["directions"].items()},
        "same_rows_as_raw_plan": all(
            sorted(d["y"] for d in e.get("duplicated_rows", [])) == sorted(d["y"] for d in plan["directions"][r].get("duplicated_rows", []))
            for r, e in pc["directions"].items()),
    }
    return res


def measure(atlas):
    out = {}
    for i, r in enumerate(ROWS):
        fr = cells(atlas, i)
        bx = [bbox(c) for c in fr]
        tops = [b[1] for b in bx]
        feet = [b[3] for b in bx]
        hts = [b[3] - b[1] + 1 for b in bx]
        ol = [outline_stats(c) for c in fr]
        top_min, foot_max = min(tops), max(feet)
        hw = [widths(c, top_min, foot_max) for c in fr]
        cols = np.unique(np.concatenate([c[c[..., 3] > 0][:, :3] for c in fr]), axis=0)
        out[r] = {
            "standing_head_top_f0": tops[0],
            "head_top_min": top_min,
            "head_top_median": float(np.median(tops)),
            "head_top_per_frame": tops,
            "foot_y_per_frame": feet,
            "lowest_foot": foot_max,
            "figure_height_f0": hts[0],
            "figure_height_median": float(np.median(hts)),
            "figure_height_lowest_foot_to_highest_head": foot_max - top_min + 1,
            "head_width_median": float(np.median([h for h, _ in hw])),
            "torso_width_median": float(np.median([t for _, t in hw])),
            "unique_opaque_colours": int(len(cols)),
            "semi_transparent_px": int(sum(((c[..., 3] > 0) & (c[..., 3] < 255)).sum() for c in fr)),
            "neighbour_diff_mean": round(float(np.mean([frame_diff(fr[k], fr[k + 1]) for k in range(7)])), 4),
            "loop_seam_diff_f7_f0": round(frame_diff(fr[7], fr[0]), 4),
            "dark_outline_share_mean": round(float(np.mean([o[1] / max(1, o[0]) for o in ol])), 4),
            "outline_gap_px_total": int(sum(o[2] for o in ol)),
            "outline_doubles_total": int(sum(o[3] for o in ol)),
        }
    f0 = [out[r]["standing_head_top_f0"] for r in ROWS]
    mn = [out[r]["head_top_min"] for r in ROWS]
    mh = [out[r]["figure_height_median"] for r in ROWS]
    summary = {
        "standing_head_tops_f0": f0,
        "standing_head_top_spread": max(f0) - min(f0),
        "head_top_min_spread": max(mn) - min(mn),
        "median_height_by_direction": mh,
        "median_height_spread": max(mh) - min(mh),
        "lowest_foot_by_direction": [out[r]["lowest_foot"] for r in ROWS],
        "mirror_pair_head_top_gap_f0": {f"{a}/{b}": abs(out[a]["standing_head_top_f0"] - out[b]["standing_head_top_f0"]) for a, b in MIRRORS},
        "largest_head_drop_between_neighbouring_directions_f0": max(abs(f0[k] - f0[(k + 1) % 8]) for k in range(8)),
    }
    return {"rows": out, "summary": summary}


def up(a, s):
    im = Image.fromarray(np.ascontiguousarray(a), "RGBA")
    return im.resize((round(im.width * s), round(im.height * s)), Image.NEAREST)


def compare_image(raw, fixed, rd, plan, changed):
    S = 4
    LM, BAND, GAP = 150, 54, 26
    cw = CELL * S
    W = LM + 8 * cw
    H = 70 + len(changed) * (BAND + 3 * cw + GAP)
    img = Image.new("RGBA", (W, H), PAGE + (255,))
    dr = ImageDraw.Draw(img)
    tgt = plan["target_head_top"]
    dr.text((10, 14), f"Turn height fix, 4x nearest. Top line = target head top y={tgt}, bottom line = feet y=72. "
                      "Orange ticks = duplicated rows.", fill=TEXT, font=font(26))
    y = 70
    for r in changed:
        i = ROWS.index(r)
        e = plan["directions"][r]
        rows = [d["y"] for d in e["duplicated_rows"]]
        dr.text((10, y + 10), f"{r.upper()}: +{e['rows_added']} px, rows {rows} duplicated "
                              f"(head top {e['head_top_before']} -> {e['head_top_after']})", fill=TEXT, font=font(26))
        y += BAND
        for tag, atlas in (("RAW", raw), ("FIXED", fixed), ("RD", rd)):
            dr.text((12, y + cw // 2 - 16), tag, fill=TEXT, font=font(30))
            for f, c in enumerate(cells(atlas, i)):
                x = LM + f * cw
                dr.rectangle([x, y, x + cw - 1, y + cw - 1], fill=GROUND + (255,))
                dr.rectangle([x, y + tgt * S - 2, x + cw - 1, y + tgt * S - 1], fill=GUIDE + (255,))
                dr.rectangle([x, y + (72 + 1) * S, x + cw - 1, y + (72 + 1) * S + 1], fill=GUIDE + (255,))
                img.alpha_composite(up(c, S), (x, y))
                dr.text((x + 6, y + 4), f"f{f}", fill=(220, 225, 210, 255), font=font(16))
                if tag == "FIXED":
                    # tick the two copies of each duplicated row (they sit at y-k-1 and y-k after the shift)
                    for y0 in rows:
                        above = sum(1 for o in rows if o > y0)
                        for yy in (y0 - above - 1, y0 - above):
                            dr.rectangle([x, y + yy * S, x + 5, y + yy * S + S - 1], fill=MARK + (255,))
            y += cw
        y += GAP
    return img


def ingame_image(raw, fixed, rd):
    s = INGAME
    cw = round(CELL * s)
    LM = 70
    strips = [("raw f0", raw, 0), ("fixed f0", fixed, 0), ("RD f0", rd, 0),
              ("raw f2", raw, 2), ("fixed f2", fixed, 2), ("RD f2", rd, 2)]
    W, H = LM + 8 * cw + 10, 30 + len(strips) * cw
    img = Image.new("RGBA", (W, H), GROUND + (255,))
    dr = ImageDraw.Draw(img)
    dr.text((6, 6), f"In-game size, {s} screen px per art px (nearest). Directions left to right: " + ", ".join(ROWS),
            fill=TEXT, font=font(12))
    for k, (tag, atlas, f) in enumerate(strips):
        yy = 30 + k * cw
        dr.text((4, yy + cw // 2 - 6), tag, fill=TEXT, font=font(12))
        for i in range(8):
            img.alpha_composite(up(cells(atlas, i)[f], s), (LM + i * cw, yy))
    return img


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    raw, rd = load(RAW), load(RD_PATH)
    fixed, plan = fix_atlas(raw)
    Image.fromarray(fixed, "RGBA").save(OUT / "after.png")
    (OUT / "plan.json").write_text(json.dumps(plan, indent=1), encoding="utf-8")
    changed = [r for r in ROWS if plan["directions"][r]["rows_added"]]
    compare_image(raw, fixed, rd, plan, changed).save(OUT / "compare_4x.png")
    ingame_image(raw, fixed, rd).save(OUT / "ingame.png")

    # Integrity checks on the written file, not the array in memory.
    back = load(OUT / "after.png")
    unchanged_rows = [r for r in ROWS if r not in changed]
    checks = {
        "after_png_matches_memory": bool(np.array_equal(back, fixed)),
        "unchanged_directions_identical_to_raw": all(
            np.array_equal(fixed[ROWS.index(r) * CELL:(ROWS.index(r) + 1) * CELL], raw[ROWS.index(r) * CELL:(ROWS.index(r) + 1) * CELL])
            for r in unchanged_rows),
        "new_colours": int(len(set(map(tuple, fixed[fixed[..., 3] > 0][:, :3].tolist())) - set(map(tuple, raw[raw[..., 3] > 0][:, :3].tolist())))),
        "alpha_values_in_output": sorted(int(v) for v in np.unique(fixed[..., 3])),
        "pixels_below_the_lowest_duplicated_row_on_the_body_unchanged": all(
            np.array_equal(fixed[ROWS.index(r) * CELL + max(d["y"] for d in plan["directions"][r]["duplicated_rows"]) + 1:(ROWS.index(r) + 1) * CELL],
                           raw[ROWS.index(r) * CELL + max(d["y"] for d in plan["directions"][r]["duplicated_rows"]) + 1:(ROWS.index(r) + 1) * CELL])
            for r in changed),
        "opaque_px_added_per_direction": {r: int((fixed[ROWS.index(r) * CELL:(ROWS.index(r) + 1) * CELL, :, 3] > 0).sum()
                                                 - (raw[ROWS.index(r) * CELL:(ROWS.index(r) + 1) * CELL, :, 3] > 0).sum()) for r in changed},
    }
    m = {
        "note": "Turn-height lane, 2026-10-26. before = raw PixelLab atlas, after = fix/height/after.png, rd = in-game RD atlas. "
                "Row order everywhere: " + ", ".join(ROWS) + ".",
        "definitions": {
            "standing_head_top_f0": "bbox top of frame 0 (the number the judges quoted)",
            "head_top_min": "highest head over the 8 frames; this is what fix_height.py levels",
            "figure_height": "bbox bottom - bbox top + 1",
            "head_width / torso_width": "widest opaque row span in the top 35 percent of the figure / opaque span at 53 percent of the height (includes a swinging arm when it crosses that row)",
            "dark_outline_share_mean": "build_compare.py's rule: boundary pixels (opaque with a transparent 4-neighbour) with HSV value < 0.3, over all boundary pixels",
            "outline_gap_px_total": "boundary pixels that are not dark, summed over 8 frames",
            "outline_doubles_total": "L-corners in the dark boundary line (finish_sprite.py's doubles rule), summed over 8 frames",
        },
        "plan": {r: {k: v for k, v in e.items() if k != "cost_by_row"} for r, e in plan["directions"].items()},
        "target_head_top": plan["target_head_top"],
        "checks": checks,
        "chain_tests": chain_tests(raw, fixed, plan),
        "before": measure(raw),
        "after": measure(fixed),
        "rd": measure(rd),
    }
    (OUT / "metrics.json").write_text(json.dumps(m, indent=1), encoding="utf-8")
    print(json.dumps({k: m[k]["summary"] for k in ("before", "after", "rd")}, indent=1))
    print(json.dumps(checks, indent=1))
    for r in ROWS:
        b, a, d = m["before"]["rows"][r], m["after"]["rows"][r], m["rd"]["rows"][r]
        print(f"{r:11s} top f0 {b['standing_head_top_f0']}->{a['standing_head_top_f0']} (rd {d['standing_head_top_f0']})  "
              f"h med {b['figure_height_median']}->{a['figure_height_median']} (rd {d['figure_height_median']})  "
              f"headw {b['head_width_median']}/{d['head_width_median']} torsow {b['torso_width_median']}/{d['torso_width_median']}  "
              f"cols {b['unique_opaque_colours']}->{a['unique_opaque_colours']}  dark {b['dark_outline_share_mean']}->{a['dark_outline_share_mean']}  "
              f"gaps {b['outline_gap_px_total']}->{a['outline_gap_px_total']}  doubles {b['outline_doubles_total']}->{a['outline_doubles_total']}")


if __name__ == "__main__":
    main()
