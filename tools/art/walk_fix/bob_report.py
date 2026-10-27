"""Measure and show the bob fix: runs fix_bob on the raw PixelLab atlas, writes after.png,
metrics.json, compare_4x.png, ingame.png and walk_compare.gif into fix/bob/.

    python bob_report.py

Reads the raw atlas and the RD atlas, never writes to them. Measures use the same
definitions as build_compare.py (bbox head top, lowest opaque row as foot, dark outline
share over boundary pixels) so the numbers line up with measurements.json.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import fix_bob as fb  # noqa: E402

HT = Path("C:/Users/pmcga/dev/hollowtide")
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW = TEST / "pixellab_courier_walk_native80.png"
RD = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
OUT = TEST / "fix/bob"
FONT = HT / "assets/fonts/Silkscreen-Regular.ttf"
ROWS, C = fb.ROWS, fb.CELL
INGAME = 30.0 / 64.0 * 3.0     # CHIBI_SCALE x outdoor camera zoom = 1.40625 screen px per art px
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)


def font(n):
    try:
        return ImageFont.truetype(str(FONT), n)
    except OSError:
        return ImageFont.load_default()


def load(p):
    return np.array(Image.open(p).convert("RGBA"))


def cells(atlas):
    return {r: [atlas[i * C:(i + 1) * C, f * C:(f + 1) * C] for f in range(8)] for i, r in enumerate(ROWS)}


def outline_share(a):
    op = a[:, :, 3] > 0
    pad = np.pad(op, 1, constant_values=False)
    edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    v = a[:, :, :3].max(-1) / 255.0
    return float((edge & (v < 0.3)).sum() / max(1, edge.sum()))


def frame_diff(a, b):
    ma, mb = a[:, :, 3] > 0, b[:, :, 3] > 0
    union = ma | mb
    differ = (ma != mb) | (ma & mb & np.any(a[:, :, :3] != b[:, :, :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def colours(frames):
    return np.unique(np.concatenate([f[f[:, :, 3] > 0][:, :3] for f in frames]), axis=0)


def corr(x, y):
    x, y = np.asarray(x, float), np.asarray(y, float)
    if x.std() == 0 or y.std() == 0:
        return 0.0
    return float(np.corrcoef(x, y)[0, 1])


def head_redraw(a, b):
    """Share of head pixels that change between two frames after lining the heads up
    (best integer shift of the top 20 rows), so a rigid bob does not count as redraw."""
    ma, mb = a[:, :, 3] > 0, b[:, :, 3] > 0
    top = fb.bbox(ma)[1]
    band = slice(top, top + 20)
    best = None
    for dy in range(-4, 5):
        for dx in range(-3, 4):
            s = fb.shifted(mb, dy, dx)
            score = (int((ma[band] & s[band]).sum()) / max(1, int((ma[band] | s[band]).sum())), -(abs(dy) + abs(dx)))
            if best is None or score > best[0]:
                best = (score, dy, dx)
    _, dy, dx = best
    bs = np.zeros_like(b)
    h, w = mb.shape
    ys0, ys1, xs0, xs1 = max(0, -dy), min(h, h - dy), max(0, -dx), min(w, w - dx)
    bs[ys0 + dy:ys1 + dy, xs0 + dx:xs1 + dx] = b[ys0:ys1, xs0:xs1]
    return frame_diff(a[band], bs[band])


def row_metrics(frames, contact=None):
    masks = [fb.opaque(f) for f in frames]
    boxes = [fb.bbox(m) for m in masks]
    g = fb.gait(frames)
    k = g["contact"] if contact is None else contact
    wave = fb.rhythm(k)
    top = [b[1] for b in boxes]
    foot = [b[3] for b in boxes]
    mass = [fb.head_offset(masks[0], m, top[0]) for m in masks]
    con = [f for f in range(8) if wave[f] > 0]
    pas = [f for f in range(8) if wave[f] < 0]
    return {
        "head_top": top, "head_top_amplitude": max(top) - min(top),
        "head_mass_offset_vs_f0": mass, "head_mass_amplitude": max(mass) - min(mass),
        "foot_y": foot, "height": [ft - t + 1 for t, ft in zip(top, foot)],
        "contact_frames": con, "passing_frames": pas, "gait_method": g["method"],
        "stride": g["stride"],
        "head_top_contact_minus_passing": round(float(np.mean([top[f] for f in con]) - np.mean([top[f] for f in pas])), 2),
        "head_top_corr_with_rhythm": round(corr(top, wave), 3),
        "unique_colours": int(len(colours(frames))),
        "semi_transparent_px": int(sum(int(((f[:, :, 3] > 0) & (f[:, :, 3] < 255)).sum()) for f in frames)),
        "dark_outline_share_mean": round(float(np.mean([outline_share(f) for f in frames])), 4),
        "opaque_px": [int(m.sum()) for m in masks],
        "neighbour_diff_mean": round(float(np.mean([frame_diff(frames[i], frames[(i + 1) % 8]) for i in range(8)])), 4),
        "head_redraw_aligned_mean": round(float(np.mean([head_redraw(frames[i], frames[(i + 1) % 8]) for i in range(8)])), 4),
    }


def rd_motion(m):
    """Whole-sprite versus upper-body share of RD's head motion, over the 8 frame steps."""
    top, foot = m["head_top"], m["foot_y"]
    whole = upper = 0
    for f in range(8):
        dt = top[(f + 1) % 8] - top[f]
        df = foot[(f + 1) % 8] - foot[f]
        w = min(abs(dt), abs(df)) if dt * df > 0 else 0
        whole += w
        upper += abs(dt) - w
    tot = whole + upper
    return {"head_steps_px": tot, "moved_with_feet_px": whole, "moved_above_feet_px": upper,
            "share_whole_sprite": round(whole / tot, 2) if tot else None,
            "foot_y_range": max(foot) - min(foot)}


def main():
    raw_atlas = load(RAW)
    rd_atlas = load(RD)
    after_atlas, report = fb.fix_atlas(raw_atlas)
    OUT.mkdir(parents=True, exist_ok=True)
    Image.fromarray(after_atlas, "RGBA").save(OUT / "after.png")
    assert np.array_equal(load(OUT / "after.png"), after_atlas)
    raw, aft, rd = cells(raw_atlas), cells(after_atlas), cells(rd_atlas)

    rows = {}
    changed = []
    for r in ROWS:
        k = report[r]["gait"]["contact"]
        mb = row_metrics(raw[r], k)
        ma = row_metrics(aft[r], k)
        mr = row_metrics(rd[r])
        rows_feet_same = []
        for f in range(8):
            foot = mb["foot_y"][f]
            rows_feet_same.append(bool(np.array_equal(raw[r][f][foot - fb.BAND_LO + 1:], aft[r][f][foot - fb.BAND_LO + 1:])))
        new_cols = colours(aft[r])
        old_set = {tuple(c) for c in colours(raw[r]).tolist()}
        added = sum(1 for c in new_cols.tolist() if tuple(c) not in old_set)
        alpha_vals = sorted({int(v) for f in aft[r] for v in np.unique(f[:, :, 3])})
        moved = [mv["move_px"] for mv in report[r]["moves"]]
        if any(moved):
            changed.append(r)
        rows[r] = {
            "gait": report[r]["gait"], "moves_px": moved,
            "seams": {f"f{mv['frame']}": mv["seams"] for mv in report[r]["moves"] if mv["seams"]},
            "before": mb, "after": ma, "rd": mr, "rd_motion": rd_motion(mr),
            "checks": {"feet_and_knees_untouched_all_frames": all(rows_feet_same),
                       "colours_added": added, "alpha_values": alpha_vals,
                       "px_changed": [int(np.any(raw[r][f] != aft[r][f], axis=2).sum()) for f in range(8)]},
        }

    def summ(key):
        return {r: rows[r][key]["head_top_amplitude"] for r in ROWS}
    summary = {
        "head_top_amplitude_before": summ("before"),
        "head_top_amplitude_after": summ("after"),
        "head_top_amplitude_rd": summ("rd"),
        "rows_with_flat_head_before": sum(1 for r in ROWS if rows[r]["before"]["head_top_amplitude"] == 0),
        "rows_with_flat_head_after": sum(1 for r in ROWS if rows[r]["after"]["head_top_amplitude"] == 0),
        "contact_minus_passing_before": {r: rows[r]["before"]["head_top_contact_minus_passing"] for r in ROWS},
        "contact_minus_passing_after": {r: rows[r]["after"]["head_top_contact_minus_passing"] for r in ROWS},
        "contact_minus_passing_rd_own_phase": {r: rows[r]["rd"]["head_top_contact_minus_passing"] for r in ROWS},
        "corr_with_rhythm_after": {r: rows[r]["after"]["head_top_corr_with_rhythm"] for r in ROWS},
        "corr_with_rhythm_rd_own_phase": {r: rows[r]["rd"]["head_top_corr_with_rhythm"] for r in ROWS},
        "rd_share_whole_sprite": {r: rows[r]["rd_motion"]["share_whole_sprite"] for r in ROWS},
        "unique_colours_before": {r: rows[r]["before"]["unique_colours"] for r in ROWS},
        "unique_colours_after": {r: rows[r]["after"]["unique_colours"] for r in ROWS},
        "dark_outline_share_before": {r: rows[r]["before"]["dark_outline_share_mean"] for r in ROWS},
        "dark_outline_share_after": {r: rows[r]["after"]["dark_outline_share_mean"] for r in ROWS},
        "neighbour_diff_before": {r: rows[r]["before"]["neighbour_diff_mean"] for r in ROWS},
        "neighbour_diff_after": {r: rows[r]["after"]["neighbour_diff_mean"] for r in ROWS},
        "head_redraw_aligned_before": {r: rows[r]["before"]["head_redraw_aligned_mean"] for r in ROWS},
        "head_redraw_aligned_after": {r: rows[r]["after"]["head_redraw_aligned_mean"] for r in ROWS},
        "feet_untouched_all_rows": all(rows[r]["checks"]["feet_and_knees_untouched_all_frames"] for r in ROWS),
        "colours_added_total": sum(rows[r]["checks"]["colours_added"] for r in ROWS),
        "seam_px_lost_or_doubled_total": sum(s["px_lost_or_doubled"] for r in ROWS for v in rows[r]["seams"].values() for s in v),
        "frames_moved": sum(1 for r in ROWS for m in rows[r]["moves_px"] if m),
        "frames_moved_2px": sum(1 for r in ROWS for m in rows[r]["moves_px"] if abs(m) == 2),
    }
    # ------------------------------------------------------------ chain tests
    # 1. Running the fix on its own output must change nothing (legs are untouched, so the
    #    phase reads the same and every head is already on its target).
    twice, _ = fb.fix_atlas(after_atlas)
    # 2. Another lane raising the side-view heads first: simulate by lifting everything
    #    above the hips of left/right/down_right by 2 px (whole-row shift, feet kept).
    pre = raw_atlas.copy()
    for r in ("left", "right", "down_right"):
        i = ROWS.index(r)
        for f in range(8):
            cell = pre[i * C:(i + 1) * C, f * C:(f + 1) * C]
            foot = fb.bbox(fb.opaque(cell))[3]
            moved, _ = fb.move_upper(cell, -2, foot)
            pre[i * C:(i + 1) * C, f * C:(f + 1) * C] = moved
    chained, chained_rep = fb.fix_atlas(pre)
    chained_cells = cells(chained)
    # 3. The RD atlas (other art, its own bob) must run without error.
    rd_fixed, rd_rep = fb.fix_atlas(rd_atlas)
    chain_tests = {
        "fix_twice_identical_to_once": bool(np.array_equal(twice, after_atlas)),
        "after_heads_raised_2px_first": {
            r: {"head_top": row_metrics(chained_cells[r], report[r]["gait"]["contact"])["head_top"],
                "same_contact_frame": chained_rep[r]["gait"]["contact"] == report[r]["gait"]["contact"],
                "moves_px": [m["move_px"] for m in chained_rep[r]["moves"]]}
            for r in ("left", "right", "down_right")},
        "runs_on_rd_atlas": {r: [m["move_px"] for m in rd_rep[r]["moves"]] for r in ROWS},
    }
    summary["chain_fix_twice_identical"] = chain_tests["fix_twice_identical_to_once"]

    metrics = {
        "chain_tests": chain_tests,
        "note": "bob lane, 2026-10-26. before = raw PixelLab atlas, after = fix_bob.py applied to it alone, rd = the in-game RD atlas. head_top is the bbox top row (same as measurements.json); contact/passing frames come from fix_bob's leg reading of the raw row (RD uses its own legs).",
        "definitions": {
            "head_top_amplitude": "max minus min of the bbox top row over the 8 frames",
            "head_top_contact_minus_passing": "mean head top on contact frames minus on passing frames; positive = lower on contact (the intended phase)",
            "head_top_corr_with_rhythm": "correlation of the head top with the +1 contact / -1 passing / 0 between pattern",
            "rd_share_whole_sprite": "share of RD's frame-to-frame head motion where the feet moved the same way by the same amount (whole sprite) rather than the body moving over still feet",
            "seams": "per moved frame, the hip row removed (lower) or duplicated (raise) and how many of its pixels differed from both neighbours",
        },
        "summary": summary, "rows": rows,
    }
    (OUT / "metrics.json").write_text(json.dumps(metrics, indent=1), encoding="utf-8")

    # ------------------------------------------------------------ compare_4x.png
    S, X0, X1, Y0, Y1 = 4, 14, 66, 2, 76
    cw, ch = (X1 - X0) * S, (Y1 - Y0) * S
    LM, HEAD, GAP = 150, 54, 10
    W = LM + 8 * (cw + 6)
    H = 70 + len(changed) * (HEAD + 3 * (ch + GAP) + 20)
    img = Image.new("RGBA", (W, H), PAGE + (255,))
    d = ImageDraw.Draw(img)
    d.text((12, 14), "Bob fix, 4x nearest. Per direction: RAW PixelLab, FIXED (fix_bob.py), RD (in game). Red line = foot anchor y72. "
           "Yellow tick = head top. C = contact, P = passing.", fill=TEXT, font=font(20))
    y = 70
    for r in changed:
        rep = rows[r]
        con, pas = rep["before"]["contact_frames"], rep["before"]["passing_frames"]
        d.text((12, y + 12), f"{r.upper()}   head top raw {rep['before']['head_top']}  fixed {rep['after']['head_top']}  "
               f"RD {rep['rd']['head_top']}   moves {rep['moves_px']}", fill=TEXT, font=font(20))
        y += HEAD
        for tag, cs, m in (("RAW", raw, rep["before"]), ("FIXED", aft, rep["after"]), ("RD", rd, rep["rd"])):
            d.text((12, y + ch // 2 - 12), tag, fill=TEXT, font=font(26))
            med = int(np.median(m["head_top"]))
            for f in range(8):
                x = LM + f * (cw + 6)
                d.rectangle([x, y, x + cw - 1, y + ch - 1], fill=GROUND + (255,))
                d.line([x, y + (med - Y0) * S, x + cw - 1, y + (med - Y0) * S], fill=(0x55, 0x63, 0x46, 255), width=1)
                d.rectangle([x, y + (73 - Y0) * S, x + cw - 1, y + (73 - Y0) * S + 1], fill=(200, 60, 60, 255))
                cell = cs[r][f][Y0:Y1, X0:X1]
                img.alpha_composite(Image.fromarray(np.ascontiguousarray(cell), "RGBA").resize((cw, ch), Image.NEAREST), (x, y))
                ty = y + (m["head_top"][f] - Y0) * S
                d.rectangle([x, ty, x + 14, ty + 1], fill=(255, 230, 0, 255))
                ph = "C" if f in m["contact_frames"] else ("P" if f in m["passing_frames"] else "")
                d.text((x + 6, y + 4), f"f{f} {ph}", fill=TEXT, font=font(18))
                d.text((x + cw - 40, y + 4), str(m["head_top"][f]), fill=(255, 230, 0, 255), font=font(18))
                if tag == "FIXED" and rep["moves_px"][f]:
                    mv = rep["moves_px"][f]
                    d.text((x + 6, y + ch - 26), f"{'down' if mv > 0 else 'up'} {abs(mv)}", fill=TEXT, font=font(16))
            y += ch + GAP
        y += 20
    img.save(OUT / "compare_4x.png")

    # ------------------------------------------------------------ ingame.png (1.40625 px per art px)
    def scale(a, s):
        im = Image.fromarray(np.ascontiguousarray(a), "RGBA")
        return im.resize((round(im.width * s), round(im.height * s)), Image.NEAREST)
    cs_ = round(C * INGAME)
    W2 = 120 + 8 * cs_ + 10
    H2 = 50 + 8 * (3 * cs_ + 16)
    img = Image.new("RGBA", (W2, H2), GROUND + (255,))
    d = ImageDraw.Draw(img)
    d.text((10, 10), f"In-game size outdoors ({INGAME} screen px per art px). Per direction: raw, fixed, RD.", fill=TEXT, font=font(16))
    y = 50
    for r in ROWS:
        for k2, (tag, cs) in enumerate((("raw", raw), ("fixed", aft), ("RD", rd))):
            d.text((10, y + 20), f"{r[:10]}\n{tag}", fill=TEXT, font=font(12))
            for f in range(8):
                img.alpha_composite(scale(cs[r][f], INGAME), (120 + f * cs_, y))
            y += cs_
        y += 16
    img.save(OUT / "ingame.png")

    # ------------------------------------------------------------ walk_compare.gif (2x, 8 fps)
    S2, GX0, GX1 = 2, 14, 66
    gw, gh = (GX1 - GX0) * S2, (Y1 - Y0) * S2
    frames = []
    for f in range(8):
        im = Image.new("RGBA", (70 + 8 * gw, 30 + 3 * (gh + 8)), GROUND + (255,))
        dd = ImageDraw.Draw(im)
        for c_, r in enumerate(ROWS):
            dd.text((70 + c_ * gw + 2, 6), r[:10], fill=TEXT, font=font(10))
        for k2, (tag, cs) in enumerate((("raw", raw), ("fixed", aft), ("RD", rd))):
            yy = 30 + k2 * (gh + 8)
            dd.text((6, yy + gh // 2), tag, fill=TEXT, font=font(14))
            for c_, r in enumerate(ROWS):
                dd.line([70 + c_ * gw, yy + (73 - Y0) * S2, 70 + (c_ + 1) * gw - 4, yy + (73 - Y0) * S2], fill=(0x55, 0x63, 0x46, 255))
                im.alpha_composite(scale(cs[r][f][Y0:Y1, GX0:GX1], S2), (70 + c_ * gw, yy))
        frames.append(im.convert("RGB"))
    pal = [fr.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE) for fr in frames]
    pal[0].save(OUT / "walk_compare.gif", save_all=True, append_images=pal[1:], duration=[130, 120] * 4, loop=0, disposal=1)

    print(json.dumps(summary, indent=1))
    print("changed rows:", changed)


if __name__ == "__main__":
    main()
