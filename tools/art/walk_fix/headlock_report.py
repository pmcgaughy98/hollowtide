"""Measure and picture the head-lock fix (Claude, 2026-10-26). Writes, under
docs/art/characters/sprite-tool-test-2026-10-26/fix/headlock/:
  after.png          fix_headlock.py applied to the raw PixelLab atlas
  compare_4x.png     every changed row: raw, fixed, RD, 8 frames at 4x nearest
  compare_ingame.png the three atlases at the game's outdoor size (1.40625 screen px per art px)
  heads_8x.png       frame 0 to 7 heads of every row, raw above fixed, 8x (seam and eye check)
  walk_headlock.gif  raw above fixed, all 8 rows, 8 fps (the only view that shows shimmer)
  metrics.json       before and after numbers

Frame-level formulas (dark outline share, colours, palette distance, neighbour difference, loop seam) are the same as
build_compare.py's from the 2026-10-26 test, so the numbers stay comparable with measurements.json.

    python tools/art/walk_fix/headlock_report.py
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import fix_headlock as hl  # noqa: E402

HT = Path(__file__).resolve().parents[3]
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW = TEST / "pixellab_courier_walk_native80.png"
RD = HT / "assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
REF = TEST / "reference/courier_south_ref_80.png"
OUT = TEST / "fix/headlock"
FONT = HT / "assets/fonts/Silkscreen-Regular.ttf"
ROWS = hl.ROWS
CELL = 80
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)
INGAME = 30.0 / 64.0 * 3.0


def font(n):
    try:
        return ImageFont.truetype(str(FONT), n)
    except OSError:
        return ImageFont.load_default(size=n)


def rgba(p):
    return np.array(Image.open(p).convert("RGBA"))


def cells(atlas):
    return {r: [atlas[i * CELL:(i + 1) * CELL, f * CELL:(f + 1) * CELL] for f in range(8)] for i, r in enumerate(ROWS)}


# ---------------------------------------------------------------- build_compare.py formulas
def colours(a):
    return np.unique(a[a[..., 3] > 0][:, :3], axis=0)


def nearest_dist(cols, ref_cols):
    d = np.sqrt(((cols[:, None, :].astype(float) - ref_cols[None, :, :].astype(float)) ** 2).sum(-1))
    return d.min(1)


def frame_diff(a, b):
    ma, mb = a[:, :, 3] > 0, b[:, :, 3] > 0
    union = ma | mb
    differ = (ma != mb) | (ma & mb & np.any(a[:, :, :3] != b[:, :, :3], axis=2))
    return float(differ[union].mean()) if union.any() else 0.0


def dark_outline_share(a):
    op = a[:, :, 3] > 0
    pad = np.pad(op, 1, constant_values=False)
    edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    v = a[..., :3].max(-1) / 255.0
    return float((edge & (v < 0.3)).sum() / max(1, edge.sum()))


def weighted_palette_dist(frames, ref_cols):
    px = np.concatenate([a[a[:, :, 3] > 0][:, :3] for a in frames])
    u, inv = np.unique(px, axis=0, return_inverse=True)
    return float(nearest_dist(u, ref_cols)[inv.ravel()].mean())


# ---------------------------------------------------------------- head measures
def head_pairs(frames):
    segs = [hl.segment(c) for c in frames]
    un, al = [], []
    for f in range(8):
        g = (f + 1) % 8
        un.append(hl.head_diff(frames[f], segs[f][3], frames[g], segs[g][3]))
        al.append(hl.best_shift(frames[f], segs[f][3], frames[g], segs[g][3])[0])
    return segs, un, al


def measure(atlas, ref_cols, raw_atlas=None):
    C = cells(atlas)
    R = cells(raw_atlas) if raw_atlas is not None else None
    out = {}
    for r in ROWS:
        fr = C[r]
        segs, un, al = head_pairs(fr)
        neigh = [frame_diff(fr[i], fr[i + 1]) for i in range(7)]
        seam = frame_diff(fr[7], fr[0])
        d = {
            "head_redraw_unaligned_mean": round(float(np.mean(un)), 4),
            "head_redraw_aligned_mean": round(float(np.mean(al)), 4),
            "head_redraw_aligned_max": round(float(np.max(al)), 4),
            "head_redraw_aligned_pairs": [round(x, 3) for x in al],
            "head_top_per_frame": [s[0] for s in segs],
            "collar_row_per_frame": [s[1] for s in segs],
            "head_px_per_frame": [int(s[3].sum()) for s in segs],
            "wrong_eye_px_per_frame": [int(hl.wrong_eye(c, s[0], s[1]).sum()) for c, s in zip(fr, segs)],
            "bluish_eye_px_per_frame": [int(hl.bluish_eye(c, s[0], s[1]).sum()) for c, s in zip(fr, segs)],
            "unique_colours_row": int(len(np.unique(np.concatenate([colours(a) for a in fr]), axis=0))),
            "colours_per_frame": [int(len(colours(a))) for a in fr],
            "semi_transparent_px": int(sum(((a[..., 3] > 0) & (a[..., 3] < 255)).sum() for a in fr)),
            "dark_outline_share_mean": round(float(np.mean([dark_outline_share(a) for a in fr])), 4),
            "palette_to_reference_pixel_weighted_rgb_dist": round(weighted_palette_dist(fr, ref_cols), 2),
            "neighbour_diff_mean": round(float(np.mean(neigh)), 4),
            "loop_seam_ratio": round(seam / float(np.mean(neigh)), 3) if np.mean(neigh) > 0 else None,
            "foot_y": [int(np.nonzero((a[..., 3] > 0).any(1))[0].max()) for a in fr],
            "opaque_px": [int((a[..., 3] > 0).sum()) for a in fr],
        }
        if R is not None:
            rs = [hl.segment(c) for c in R[r]]
            ch = [np.any(a != b, axis=2) for a, b in zip(fr, R[r])]
            d["px_changed_vs_raw"] = [int(c.sum()) for c in ch]
            # body untouched: changes more than 2 rows below the raw collar row
            d["px_changed_below_collar_plus2"] = [int(c[s[1] + 3:].sum()) for c, s in zip(ch, rs)]
        out[r] = d
    return out


# ---------------------------------------------------------------- pictures
def up(a, s):
    im = Image.fromarray(np.ascontiguousarray(a), "RGBA")
    return im.resize((round(im.width * s), round(im.height * s)), Image.NEAREST)


def compare_4x(raw, fix, rd, changed, path):
    S, X0, X1 = 4, 12, 68
    cw, chh = (X1 - X0) * S, CELL * S
    LM, BAND, GAP = 150, 40, 20
    W = LM + 8 * (cw + 4)
    H = 56 + len(changed) * (BAND + 3 * (chh + 4) + GAP)
    img = Image.new("RGBA", (W, H), PAGE + (255,))
    dr = ImageDraw.Draw(img)
    dr.text((10, 12), "Head lock: raw PixelLab (top), head-locked (middle), RD in game (bottom). 4x nearest, frames f0-f7.", fill=TEXT, font=font(22))
    y = 56
    Cr, Cf, Cd = cells(raw), cells(fix), cells(rd)
    for r in changed:
        dr.text((10, y + 6), r.upper(), fill=TEXT, font=font(24))
        y += BAND
        for tag, C in (("RAW", Cr), ("FIXED", Cf), ("RD", Cd)):
            dr.text((12, y + chh // 2 - 12), tag, fill=TEXT, font=font(22))
            for f in range(8):
                x = LM + f * (cw + 4)
                dr.rectangle([x, y, x + cw - 1, y + chh - 1], fill=GROUND + (255,))
                img.alpha_composite(up(C[r][f][:, X0:X1], S), (x, y))
                dr.text((x + 4, y + 2), f"f{f}", fill=(220, 225, 210, 255), font=font(14))
            y += chh + 4
        y += GAP
    img.save(path)


def heads_8x(raw, fix, path):
    S, X0, X1, Y0, Y1 = 8, 20, 60, 4, 40
    cw, chh = (X1 - X0) * S, (Y1 - Y0) * S
    img = Image.new("RGBA", (8 * (cw + 4), 16 * (chh + 4)), GROUND + (255,))
    Cr, Cf = cells(raw), cells(fix)
    for i, r in enumerate(ROWS):
        for k, C in enumerate((Cr, Cf)):
            for f in range(8):
                img.alpha_composite(up(C[r][f][Y0:Y1, X0:X1], S), (f * (cw + 4), (2 * i + k) * (chh + 4)))
    img.save(path)


def ingame(raw, fix, rd, path):
    s = INGAME
    side = round(CELL * 8 * s)
    img = Image.new("RGBA", (3 * side + 80, side + 60), GROUND + (255,))
    dr = ImageDraw.Draw(img)
    for k, (tag, a) in enumerate((("raw PixelLab", raw), ("head-locked", fix), ("RD in game", rd))):
        dr.text((20 + k * (side + 20), 14), tag + f"  ({s:.5f} screen px per art px)", fill=TEXT, font=font(16))
        img.alpha_composite(up(a, side / 640.0), (20 + k * (side + 20), 44))
    img.save(path)


def gif(raw, fix, path):
    S, X0, X1 = 3, 12, 68
    cw, chh = (X1 - X0) * S, CELL * S
    LM, TOP = 90, 30
    W, H = LM + 8 * cw, TOP + 2 * (chh + 24)
    Cr, Cf = cells(raw), cells(fix)
    frames = []
    for f in range(8):
        im = Image.new("RGBA", (W, H), GROUND + (255,))
        dr = ImageDraw.Draw(im)
        for c, r in enumerate(ROWS):
            dr.text((LM + c * cw + 4, 8), r, fill=TEXT, font=font(14))
        for k, (tag, C) in enumerate((("RAW", Cr), ("LOCK", Cf))):
            yy = TOP + k * (chh + 24)
            dr.text((8, yy + chh // 2), tag, fill=TEXT, font=font(18))
            for c, r in enumerate(ROWS):
                im.alpha_composite(up(C[r][f][:, X0:X1], S), (LM + c * cw, yy))
        frames.append(im.convert("RGB").quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=[130, 120] * 4, loop=0, disposal=1)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    after = OUT / "after.png"
    logs = hl.run(str(RAW), str(after))
    raw, fix, rd, ref = rgba(RAW), rgba(after), rgba(RD), rgba(REF)
    ref_cols = colours(ref)
    changed = [r for r in ROWS if any(np.any(a != b) for a, b in zip(cells(raw)[r], cells(fix)[r]))]
    m_raw = measure(raw, ref_cols)
    m_fix = measure(fix, ref_cols, raw)
    m_rd = measure(rd, ref_cols)
    keys = ["head_redraw_unaligned_mean", "head_redraw_aligned_mean", "head_top_per_frame", "wrong_eye_px_per_frame",
            "bluish_eye_px_per_frame", "unique_colours_row", "dark_outline_share_mean",
            "palette_to_reference_pixel_weighted_rgb_dist", "neighbour_diff_mean", "loop_seam_ratio"]
    summary = {r: {k: {"raw": m_raw[r][k], "fixed": m_fix[r][k], "rd": m_rd[r][k]} for k in keys} for r in ROWS}
    whole = {}
    for tag, a in (("raw", raw), ("fixed", fix), ("rd", rd)):
        whole[tag] = {
            "unique_colours_atlas": int(len(colours(a))),
            "semi_transparent_px": int(((a[..., 3] > 0) & (a[..., 3] < 255)).sum()),
            "alpha_values": sorted(int(v) for v in np.unique(a[..., 3])),
        }
    doc = {
        "note": "headlock lane, 2026-10-26. raw = pixellab_courier_walk_native80.png, fixed = fix/headlock/after.png, rd = the in-game RD atlas.",
        "definitions": {
            "head": "per frame, opaque pixels above the teal collar: per column, rows above the first teal pixel found between 4 rows above the collar row and the collar row (or above collar row + 1 where the column has none). Collar row = first row 18+ below the head top with 4+ teal pixels. Same code as fix_headlock.segment.",
            "head_redraw_unaligned": "for each consecutive pair f0-f1 ... f6-f7 and the loop f7-f0: share of the union of both head masks whose pixel differs in alpha or colour, no shift. Includes whole-head motion.",
            "head_redraw_aligned": "the same share after the best integer shift of the second head within +-3 px: what is redrawn, not moved. 0 means the same head moved as a whole.",
            "wrong_eye_px": "face band (head top + 12 to collar row - 3): pixels that are blue (b > r+25 and b > g+30) or shirt teal (g > r+40, |g-b| <= 30, g > 60)",
            "bluish_eye_px": "same band, looser: b > r+15 and b >= g",
            "frame formulas": "dark_outline_share, colours, palette distance, neighbour_diff, loop_seam_ratio as in build_compare.py",
        },
        "summary_by_row": summary,
        "whole_atlas": whole,
        "fix_log": logs,
        "raw": m_raw, "fixed": m_fix, "rd": m_rd,
        "rows_changed": changed,
    }
    (OUT / "metrics.json").write_text(json.dumps(doc, indent=1), encoding="utf-8")
    compare_4x(raw, fix, rd, changed, OUT / "compare_4x.png")
    heads_8x(raw, fix, OUT / "heads_8x.png")
    ingame(raw, fix, rd, OUT / "compare_ingame.png")
    gif(raw, fix, OUT / "walk_headlock.gif")
    for r in ROWS:
        s = summary[r]
        print(f"{r:11s} redraw al {s['head_redraw_aligned_mean']['raw']:.3f}->{s['head_redraw_aligned_mean']['fixed']:.3f} "
              f"(rd {s['head_redraw_aligned_mean']['rd']:.3f})  unal {s['head_redraw_unaligned_mean']['raw']:.3f}->{s['head_redraw_unaligned_mean']['fixed']:.3f}  "
              f"eye {sum(s['wrong_eye_px_per_frame']['raw'])}->{sum(s['wrong_eye_px_per_frame']['fixed'])}  "
              f"bluish {sum(s['bluish_eye_px_per_frame']['raw'])}->{sum(s['bluish_eye_px_per_frame']['fixed'])}  "
              f"cols {s['unique_colours_row']['raw']}->{s['unique_colours_row']['fixed']} (rd {s['unique_colours_row']['rd']})  "
              f"outline {s['dark_outline_share_mean']['raw']:.3f}->{s['dark_outline_share_mean']['fixed']:.3f}  "
              f"pal {s['palette_to_reference_pixel_weighted_rgb_dist']['raw']}->{s['palette_to_reference_pixel_weighted_rgb_dist']['fixed']}  "
              f"tops {s['head_top_per_frame']['fixed']}  below {m_fix[r]['px_changed_below_collar_plus2']}")
    print("whole", whole)


if __name__ == "__main__":
    main()
