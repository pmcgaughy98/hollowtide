"""Compare images and measurements for the fixed PixelLab courier walk (Claude, 2026-10-26, composer step).

    python tools/art/walk_fix/build_fixed_compare.py [FIXED_ATLAS]

FIXED_ATLAS defaults to docs/art/characters/sprite-tool-test-2026-10-26/fix/pixellab_courier_walk_fixed_native80.png
(the output of compose_walk.py). Writes, all new files:
  fix/compare/compare_rows_4x.png     for each direction: RD, raw PixelLab, fixed PixelLab, 8 frames at 4x
  fix/compare/compare_frame0_8x.png   frame 0 of every direction, RD / raw / fixed, plus the reference frame
  fix/compare/compare_ingame.png      the three atlases at 1.40625 screen px per art px on #6b7b5a
  fix/compare/compare_walk_all.gif    the three sets animated, 8 FPS, 3x
  fix/measurements_fixed.json         the fields of measurements.json, measured on the fixed atlas
The drawing follows the test's build_compare.py; only nearest-neighbour scaling is used.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import measure_walk as MW  # noqa: E402

HT = MW.HT
TEST = MW.TEST
FIXED = Path(sys.argv[1]) if len(sys.argv) > 1 else TEST / "fix/pixellab_courier_walk_fixed_native80.png"
OUT = TEST / "fix/compare"
MEAS_IN = TEST / "measurements.json"
MEAS_OUT = TEST / "fix/measurements_fixed.json"
STEPS = TEST / "fix/chain/step_metrics.json"
FONT_PATH = HT / "assets/fonts/Silkscreen-Regular.ttf"
ROWS = MW.ROWS
PL_DIRS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]
CELL, FOOT_Y = 80, 72
GROUND = (0x6B, 0x7B, 0x5A)
PAGE = (0x29, 0x25, 0x36)
TEXT = (0xFF, 0xF4, 0xE8)
GUIDE = (0x55, 0x63, 0x46)
CHIBI_SCALE, ZOOM_OUT, ZOOM_IN = 30.0 / 64.0, 3.0, 2.0
BASE_VIEW = (1152, 648)


def font(size):
    try:
        return ImageFont.truetype(str(FONT_PATH), size)
    except OSError:
        return ImageFont.load_default(size=size)


def up(a, s):
    im = Image.fromarray(a, "RGBA")
    return im.resize((round(im.width * s), round(im.height * s)), Image.NEAREST)


rd_atlas, raw_atlas, fx_atlas = MW.rgba(MW.RD_PATH), MW.rgba(MW.RAW_PATH), MW.rgba(FIXED)
ref = MW.rgba(MW.REF_PATH)
ref_cols = MW.colours(ref)
SETS = (("RD", MW.split(rd_atlas)), ("RAW", MW.split(raw_atlas)), ("FIXED", MW.split(fx_atlas)))
OUT.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------- a. rows at 4x
S = 4
LM, BAND, GAP = 150, 44, 18
cw = CELL * S
W = LM + 8 * cw
H = 60 + 8 * (BAND + 3 * cw + GAP)
img = Image.new("RGBA", (W, H), PAGE + (255,))
dr = ImageDraw.Draw(img)
dr.text((10, 12), "Per direction: RD (in game), raw PixelLab, fixed PixelLab. 4x nearest. Guide line = anchor row y=72.",
        fill=TEXT, font=font(24))
y = 60
for r, d in zip(ROWS, PL_DIRS):
    dr.text((10, y + 8), f"{r.upper()}   (PixelLab: {d})", fill=TEXT, font=font(24))
    y += BAND
    for tag, cells in SETS:
        dr.text((14, y + cw // 2 - 14), tag, fill=TEXT, font=font(26))
        for f in range(8):
            x = LM + f * cw
            dr.rectangle([x, y, x + cw - 1, y + cw - 1], fill=GROUND + (255,))
            dr.rectangle([x, y + (FOOT_Y + 1) * S, x + cw - 1, y + (FOOT_Y + 1) * S + 1], fill=GUIDE + (255,))
            img.alpha_composite(up(cells[r][f], S), (x, y))
            dr.text((x + 6, y + 4), f"f{f}", fill=(220, 225, 210, 255), font=font(16))
        y += cw
    y += GAP
img.save(OUT / "compare_rows_4x.png")

# ---------------------------------------------------------------- b. frame 0 at 8x
S = 8
CX0, CX1 = 12, 68
cw, ch = (CX1 - CX0) * S, CELL * S
LM, TOP, GAPC = 90, 70, 12
W = LM + 9 * (cw + GAPC)
H = TOP + 3 * (ch + 40)
img = Image.new("RGBA", (W, H), PAGE + (255,))
dr = ImageDraw.Draw(img)
dr.text((10, 14), "Frame 0 of every direction, 8x. Rows: RD (in game), raw PixelLab, fixed PixelLab. Left: the reference frame PixelLab was given.",
        fill=TEXT, font=font(26))
g = Image.new("RGBA", (cw, ch), GROUND + (255,))
g.alpha_composite(up(ref[:, CX0:CX1].copy(), S))
img.alpha_composite(g, (LM, TOP + ch + 40))
dr.text((LM, TOP + ch + 10), "REFERENCE (RD down f7)", fill=TEXT, font=font(20))
for k, (tag, cells) in enumerate(SETS):
    yy = TOP + k * (ch + 40)
    dr.text((8, yy + ch // 2), tag, fill=TEXT, font=font(24))
    for c, r in enumerate(ROWS):
        x = LM + (c + 1) * (cw + GAPC)
        g = Image.new("RGBA", (cw, ch), GROUND + (255,))
        gd = ImageDraw.Draw(g)
        gd.rectangle([0, (FOOT_Y + 1) * S, cw, (FOOT_Y + 1) * S + 2], fill=GUIDE + (255,))
        g.alpha_composite(up(cells[r][0][:, CX0:CX1].copy(), S))
        img.alpha_composite(g, (x, yy))
        dr.text((x + 8, yy + 6), r, fill=TEXT, font=font(22))
img.save(OUT / "compare_frame0_8x.png")

# ---------------------------------------------------------------- c. in-game size
s_out, s_in = CHIBI_SCALE * ZOOM_OUT, CHIBI_SCALE * ZOOM_IN
full = round(CELL * 8 * s_out)
W = 20 + 3 * (full + 30)
H = 110 + full + 30 + 34 + round(CELL * s_in) * 3 + 20
img = Image.new("RGBA", (W, H), GROUND + (255,))
dr = ImageDraw.Draw(img)
dr.text((20, 12), f"Real size in the {BASE_VIEW[0]}x{BASE_VIEW[1]} game view, outdoors: {s_out:.5f} screen px per art px (nearest). Ground #6b7b5a.",
        fill=TEXT, font=font(18))
dr.text((20, 40), "Left to right: RD atlas (in game now), raw PixelLab, fixed PixelLab.", fill=TEXT, font=font(18))
for k, (tag, _) in enumerate(SETS):
    dr.text((20 + k * (full + 30), 80), tag, fill=TEXT, font=font(18))
for k, a in enumerate((rd_atlas, raw_atlas, fx_atlas)):
    img.alpha_composite(up(a, full / 640.0), (20 + k * (full + 30), 110))
y = 110 + full + 30
dr.text((20, y), f"Indoors ({s_in:.4f} screen px per art px), frame 0 of each direction. Rows: RD, raw, fixed.", fill=TEXT, font=font(18))
y += 34
ci = round(CELL * s_in)
for k, (_, cells) in enumerate(SETS):
    for c, r in enumerate(ROWS):
        img.alpha_composite(up(cells[r][0], s_in), (20 + c * ci, y + k * ci))
img.save(OUT / "compare_ingame.png")

# ---------------------------------------------------------------- d. GIF, 8 FPS, 3x
S = 3
cw, ch = (CX1 - CX0) * S, CELL * S
LM, TOP = 80, 34
W, H = LM + 8 * cw, TOP + 3 * (ch + 30)
frames = []
for f in range(8):
    im = Image.new("RGBA", (W, H), GROUND + (255,))
    dr = ImageDraw.Draw(im)
    for c, r in enumerate(ROWS):
        dr.text((LM + c * cw + 4, 8), r, fill=TEXT, font=font(14))
    for k, (tag, cells) in enumerate(SETS):
        yy = TOP + k * (ch + 30)
        dr.text((8, yy + ch // 2), tag, fill=TEXT, font=font(16))
        for c, r in enumerate(ROWS):
            im.alpha_composite(up(cells[r][f][:, CX0:CX1].copy(), S), (LM + c * cw, yy))
    frames.append(im.convert("RGB"))
pal = [fr.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE) for fr in frames]
gif_err = max(float(np.abs(np.array(fr).astype(int) - np.array(q.convert("RGB")).astype(int)).max()) for fr, q in zip(frames, pal))
# GIF timing is in 1/100 s, so 125 ms cannot be stored; 130/120 alternating averages 8 FPS.
pal[0].save(OUT / "compare_walk_all.gif", save_all=True, append_images=pal[1:], duration=[130, 120] * 4, loop=0, disposal=1)

# ---------------------------------------------------------------- measurements_fixed.json
old = json.loads(MEAS_IN.read_text(encoding="utf-8"))
m_rd = MW.measure_set(SETS[0][1], ref_cols)
m_raw = MW.measure_set(SETS[1][1], ref_cols)
m_fx = MW.measure_set(SETS[2][1], ref_cols)
expect = {"down": 0, "down_left": -1, "left": -1, "up_left": -1, "up": 0, "up_right": 1, "right": 1, "down_right": 1}
facing = {}
for r in ROWS:
    o = {}
    for name, cells in (("rd", SETS[0][1]), ("pixellab", SETS[2][1])):
        n, off = MW.skin_side(cells[r][0])
        side = 0 if off is None or abs(off) < 1.5 else (1 if off > 0 else -1)
        o[name] = {"skin_px": n, "skin_offset_x": off, "side": side}
    e = expect[r]
    o["expected_side"] = e
    o["pixellab_agrees"] = (o["pixellab"]["side"] == e) if e != 0 else (o["pixellab"]["side"] == 0 or o["pixellab"]["skin_px"] < 15)
    facing[r] = o
med_rd = float(np.median(list(m_rd["summary"]["median_height_by_direction"].values())))
med_fx = float(np.median(list(m_fx["summary"]["median_height_by_direction"].values())))
chain = json.loads(STEPS.read_text(encoding="utf-8")) if STEPS.exists() else {}
defs = dict(old["definitions"])
defs.update({
    "faults.f1_satchel": "satchel lane's template measure: share of the bag patch drawn at its tracked place (torso registration within +-3 px against the raw key frame); strap_px = leather pixels on the strap line (back rows)",
    "faults.f2_bob": "bbox top row per frame; range = max minus min over the 8 frames",
    "faults.f3_turn_height": "standing head top = frame 0 bbox top; highest = min bbox top over 8 frames",
    "faults.f4_eyes": "colour lane's blue_px: OKLab hue 235-305, chroma >= 0.05, L >= 0.2, in the top 47% of the figure; side lenses = colour lane's lens_stats",
    "faults.f5_legs": "leg lane's measure_row (foot rows, distinct foot configurations, leg-zone shape change between neighbours)",
    "faults.f6_head_redraw": "head lane's head_pairs: share of head pixels that differ between neighbouring frames after the best whole-head shift",
    "faults.f7_colour": "unique opaque colours per frame and per row; maroon = colour lane's maroon_stats below the hips",
    "faults.craft": "alpha values present, frames touching the 80x80 cell edge, lowest foot row, enclosed transparent holes",
})
meas = {
    "note": "Measured by tools/art/walk_fix/build_fixed_compare.py on 2026-10-26 with the same definitions as measurements.json. "
            "RD = the in-game male atlas; pixellab = the FIXED atlas built by compose_walk.py from the raw PixelLab atlas; "
            "pixellab_raw_summary = the raw atlas, re-measured here.",
    "definitions": defs,
    "reference": old["reference"],
    "pixellab_input": {"fixed_atlas": str(FIXED), "raw_atlas": str(MW.RAW_PATH), "chain_order": chain.get("order"),
                       "bob_keep_rows": chain.get("bob_keep_rows"), "resampled": False, "integer_scale": 1},
    "registration": {"note": "No new registration. The fixed atlas keeps the raw atlas's per-direction translation "
                             "(see measurements.json); every lane works in place on the 80x80 cells.",
                     "per_direction": old["registration"]["per_direction"]},
    "direction_mapping": {"rows": dict(zip(ROWS, PL_DIRS)), "skin_side_check_frame0": facing,
                          "rd_mirror_note": old["direction_mapping"]["rd_mirror_note"]},
    "on_screen": {
        "chibi_scale": CHIBI_SCALE, "camera_zoom_outdoors": ZOOM_OUT, "camera_zoom_indoors": ZOOM_IN,
        "base_viewport": list(BASE_VIEW), "screen_px_per_source_px_outdoors": s_out, "screen_px_per_source_px_indoors": s_in,
        "rd_median_height_src_px": med_rd, "pixellab_median_height_src_px": med_fx,
        "rd_on_screen_height_outdoors": round(med_rd * s_out, 1), "pixellab_on_screen_height_outdoors": round(med_fx * s_out, 1),
    },
    "rd": m_rd,
    "pixellab": m_fx,
    "pixellab_raw_summary": m_raw["summary"],
    "faults": {"rd": MW.faults(rd_atlas, raw_atlas, ref_cols), "raw": MW.faults(raw_atlas, raw_atlas, ref_cols),
               "fixed": MW.faults(fx_atlas, raw_atlas, ref_cols)},
    "gif": {"fps": 8, "scale": 3, "max_channel_error_after_quantize": gif_err},
}
meas["pixellab_pale_debris_frames"] = [f"{r} f{p['frame']}: {p['pale_debris_px']} px" for r in ROWS
                                       for p in m_fx["directions"][r]["frames"] if p["pale_debris_px"]]
MEAS_OUT.write_text(json.dumps(meas, indent=1, default=str), encoding="utf-8")
print(json.dumps({"fixed_summary": m_fx["summary"], "gif_err": gif_err}, indent=1, default=str))
