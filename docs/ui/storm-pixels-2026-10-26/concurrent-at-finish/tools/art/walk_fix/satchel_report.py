"""Measure and show the satchel fix (Claude, 2026-10-26, walk-fix lane 'satchel').

  python tools/art/walk_fix/satchel_report.py [OUT_DIR]

Runs fix_satchel.fix on the raw PixelLab atlas and writes into OUT_DIR (default
docs/art/characters/sprite-tool-test-2026-10-26/fix/satchel):
  after.png        the fixed atlas
  compare_4x.png   each changed row: raw on top, fixed below, RD below that, 8 frames at 4x
  ingame.png       the same rows at the in-game size (1.40625 screen px per art px, nearest)
  metrics.json     before and after numbers

Bag presence is measured two ways, both on the bag's footprint in each frame (the footprint
follows the same torso registration the fix uses):
  match_pct  share of the bag template's inside pixels that the frame draws within an RGB
             distance of 48 of the template colour (100 = the whole bag is there)
  bag_px     pixels on that footprint in the leather/gold colour family (pants count too, so
             this never reaches 0 on rows where the bag overlaps the trousers)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).parent))
import fix_satchel as fs  # noqa: E402

HT = fs.HT
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else HT / "docs/art/characters/sprite-tool-test-2026-10-26/fix/satchel"
FONT = HT / "assets/fonts/Silkscreen-Regular.ttf"
INGAME = 1.40625  # 3x camera zoom times the 30/64 chibi scale, from build_compare.py

# Templates for rows the fix does not touch, to show whether the bag pops there: raw frame and
# inside box of the clearest bag in that row (read off 9x zooms of every frame).
CHECK_ONLY = {}   # every row with a visible bag is now fixed; 'right' hides it on the far hip


def font(size):
    try:
        return ImageFont.truetype(str(FONT), size)
    except OSError:
        return ImageFont.load_default()


def colours(c):
    return int(len(np.unique(c[c[..., 3] > 0][:, :3], axis=0)))


def edge_dark_share(c):
    e = fs.silhouette_edge(c)
    return round(float((fs.lum(c[..., :3])[e] < 60).mean()), 4)


def templates(raw, line):
    """Per row: (key frame, registration window, patch, mask, (x, y) where the patch sits on the key)."""
    t = {}
    bag, bag_mask = fs.back_bag(line)
    bh, bw = bag_mask.shape
    for r, plan in fs.BACK.items():
        t[r] = (plan["key"], plan["win"], fs.back_skip(plan, bw, bh), bag, bag_mask, plan["at"])
    for r, plan in list(fs.SAME_ROW.items()) + list(CHECK_ONLY.items()):
        key = fs.cell(raw, r, plan["key"])
        patch, mask, corner = fs.cut(key, plan["box"], line, teal_ring="drop")
        t[r] = (plan["key"], plan["win"], fs.grow(fs.box_mask([plan["box"]]), 1), patch, mask, corner)
    return t


def presence(atlas, raw, r, f, tpl):
    key_f, win, skip, patch, mask, (px, py) = tpl
    c = fs.cell(atlas, r, f)
    dx, dy = fs.placement(c, raw, r, f, key_f, win, skip)
    inside = mask.copy()
    p = np.pad(mask, 1)
    inside &= p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]
    hit, n, leather = 0, 0, 0
    cl = fs.classes(c)
    for y, x in zip(*np.nonzero(inside)):
        ty, tx = py + dy + y, px + dx + x
        if not (0 <= ty < fs.CELL and 0 <= tx < fs.CELL):
            continue
        n += 1
        if c[ty, tx, 3] > 0 and np.linalg.norm(c[ty, tx, :3].astype(float) - patch[y, x, :3]) <= 48:
            hit += 1
        if cl[ty, tx] in (fs.T_LEATHER, fs.T_GOLD):
            leather += 1
    return round(100.0 * hit / max(1, n), 1), leather


def strap_px(atlas, raw, r, f):
    """Strap pixels drawn by the fix's strap colours on the strap line, before or after."""
    plan = fs.BACK[r]
    c = fs.cell(atlas, r, f)
    bag_mask = fs.back_bag(fs.outline_colour(raw))[1]
    bh, bw = bag_mask.shape
    dx, dy = fs.placement(c, raw, r, f, plan["key"], plan["win"], fs.back_skip(plan, bw, bh))
    (xa, ya) = (plan["strap"][0] + dx, plan["strap"][1] + dy)
    (xb, yb) = (plan["at"][0] + dx + bw - 3, plan["at"][1] + dy + 1)
    cl = fs.classes(c)
    n = 0
    for y in range(ya, yb + 1):
        t = (y - ya) / max(1, yb - ya)
        xc = int(np.floor(xa + (xb - xa) * t + 0.5))
        n += int(sum(cl[y, x] == fs.T_LEATHER for x in (xc, xc + 1)))
    return n


def label(img, text, xy, size=14, fill=(255, 244, 232)):
    ImageDraw.Draw(img).text(xy, text, fill=fill, font=font(size))


def flat(c, bg):
    m = c[..., 3:4] / 255.0
    return (c[..., :3] * m + np.array(bg) * (1 - m)).astype(np.uint8)


def strip(atlas, r, k, crop=(14, 4, 66, 78), bg=(0x6B, 0x7B, 0x5A)):
    x0, y0, x1, y1 = crop
    tiles = [flat(fs.cell(atlas, r, f)[y0:y1, x0:x1], bg) for f in range(8)]
    gap = np.full((y1 - y0, 2, 3), 0x29, np.uint8)
    row = np.concatenate(sum([[t, gap] for t in tiles], [])[:-1], axis=1)
    im = Image.fromarray(row)
    if isinstance(k, int):
        return im.resize((im.width * k, im.height * k), Image.NEAREST)
    return im.resize((round(im.width * k), round(im.height * k)), Image.NEAREST)


def compare_sheet(raw, after, rd, rows, k, name, title):
    blocks = []
    for r in rows:
        parts = [("raw PixelLab", strip(raw, r, k)), ("fixed", strip(after, r, k)),
                 ("RD (game now)", strip(rd, r, k))]
        note = {6: "  (RD row is a mirror of left)", 5: "  (RD row is a mirror of up_left: bag on the wrong hip)"}
        blocks.append((fs.ROWS[r] + note.get(r, ""), parts))
    w = max(p.width for _, parts in blocks for _, p in parts) + 150
    h = sum(sum(p.height + 4 for _, p in parts) + 30 for _, parts in blocks) + 40
    sheet = Image.new("RGB", (w, h), (0x29, 0x25, 0x36))
    label(sheet, title, (8, 8), 16)
    y = 36
    for row_name, parts in blocks:
        label(sheet, f"row: {row_name}", (8, y), 16, (255, 220, 120))
        y += 26
        for name_p, p in parts:
            label(sheet, name_p, (6, y + p.height // 2 - 8), 12)
            sheet.paste(p, (146, y))
            y += p.height + 4
        y += 4
    sheet.save(OUT / name)
    return sheet.size


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    raw = fs.load(fs.RAW_ATLAS)
    rd = fs.load(fs.RD_ATLAS)
    line = fs.outline_colour(raw)
    after, report = fs.fix(raw)
    Image.fromarray(after).save(OUT / "after.png")

    # Chained run: the fix must leave an already-fixed atlas almost unchanged.
    again, _ = fs.fix(after)
    rerun_changed = int(np.any(again != after, axis=-1).sum())

    tpl = templates(raw, line)
    metrics = {
        "note": "Satchel lane, 2026-10-26. Fix applied to the raw PixelLab atlas only. 'before' is "
                "the raw atlas, 'after' is after.png. Rows: down, down_left, left, up_left, up, "
                "up_right, right, down_right.",
        "rule": "Bag on the courier's LEFT hip, strap over his RIGHT shoulder (reference south frame: "
                "bag at viewer's right hip, strap from viewer's left shoulder).",
        "definitions": {
            "match_pct": "share of the bag template's inside pixels drawn within RGB distance 48 at "
                         "the bag's place in the frame (place follows torso registration)",
            "bag_px": "pixels on the bag footprint in the leather or gold colour family; trousers "
                      "count too where the footprint overlaps them",
            "strap_px": "strap-line pixels (2 per row) in the leather colour family, back rows",
            "colours": "distinct RGB colours among opaque pixels",
            "edge_dark_share": "share of outer-outline pixels darker than luminance 60",
            "changed_px": "pixels that differ from the raw frame",
        },
        "hard_alpha_after": sorted(int(v) for v in np.unique(after[..., 3])),
        "rerun_on_fixed_changed_px": rerun_changed,
        "rows": {},
    }
    for r in range(8):
        name = fs.ROWS[r]
        row = {"frames": []}
        for f in range(8):
            cb, ca = fs.cell(raw, r, f), fs.cell(after, r, f)
            d = {"frame": f, "changed_px": int(np.any(cb != ca, axis=-1).sum()),
                 "colours": [colours(cb), colours(ca)],
                 "edge_dark_share": [edge_dark_share(cb), edge_dark_share(ca)]}
            if r in tpl:
                mb, lb = presence(raw, raw, r, f, tpl[r])
                ma, la = presence(after, raw, r, f, tpl[r])
                d["match_pct"] = [mb, ma]
                d["bag_px"] = [lb, la]
            if r in fs.BACK:
                d["strap_px"] = [strap_px(raw, raw, r, f), strap_px(after, raw, r, f)]
            row["frames"].append(d)
        rb = raw[r * 80:(r + 1) * 80]
        ra = after[r * 80:(r + 1) * 80]
        row["row_colours"] = [colours(rb), colours(ra)]
        row["fixed_by_this_lane"] = r in fs.BACK or r in fs.SAME_ROW
        if name in report:
            row["placement"] = report[name]
        if r in tpl:
            row["match_pct_min_mean"] = {
                "before": [min(d["match_pct"][0] for d in row["frames"]),
                           round(float(np.mean([d["match_pct"][0] for d in row["frames"]])), 1)],
                "after": [min(d["match_pct"][1] for d in row["frames"]),
                          round(float(np.mean([d["match_pct"][1] for d in row["frames"]])), 1)]}
        metrics["rows"][name] = row
    rd_cols = [colours(fs.cell(rd, r, f)) for r in range(8) for f in range(8)]
    metrics["rd_frame_colours_min_max"] = [min(rd_cols), max(rd_cols)]
    (OUT / "metrics.json").write_text(json.dumps(metrics, indent=1))

    changed = [r for r in range(8) if np.any(raw[r * 80:(r + 1) * 80] != after[r * 80:(r + 1) * 80])]
    s1 = compare_sheet(raw, after, rd, changed, 4, "compare_4x.png",
                       "Satchel fix, 4x nearest: raw PixelLab / fixed / RD, frames 0-7")
    s2 = compare_sheet(raw, after, rd, changed, INGAME, "ingame.png",
                       "Satchel fix at game size (1.40625 px per art px)")
    print("changed rows:", [fs.ROWS[r] for r in changed], "compare", s1, "ingame", s2,
          "rerun changed px:", rerun_changed)
    for name, row in metrics["rows"].items():
        if "match_pct_min_mean" in row:
            print(f"{name:10s} match min/mean before {row['match_pct_min_mean']['before']} "
                  f"after {row['match_pct_min_mean']['after']}  row colours {row['row_colours']}")


if __name__ == "__main__":
    main()
