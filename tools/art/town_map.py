"""Draws Highbank v2's wired areas as one map picture (Claude, 2026-10-28; Preston: "start town map ... First wire the
map though and the foundations of the town").

Each area is drawn from its own file in scripts/world/areas/ (dumped by tools/art/town_map_dump.gd), then the areas are
laid side by side by their exits: an exit on an area's west edge puts the area it leads to on the west, lined up so the
two ends of the exit meet. The areas are separate screens in the game, so the gaps between them are only for reading.

  python tools/art/town_map.py [--out=PATH]
"""
import json
import os
import subprocess
import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

GODOT = "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe"
OUT = Path("docs/design/town-map-2026-10-28/town_map_now.png")
START = "hall_rise"   # the Tower's area is placed first; the rest hang off it
T = 14                # px per tile
GAP = 3               # tiles between areas
PAD = 40

GROUND = {"grass": (106, 154, 74), "hedge": (47, 90, 44), "cliff": (128, 112, 96), "terrace": (150, 128, 92),
          "water": (59, 110, 165), "sand": (196, 178, 128)}
SOFT = (150, 138, 92)
PATH = {"lane": (201, 180, 138), "steps": (176, 160, 144), "boardwalk": (139, 106, 68)}
INK = (24, 22, 20)
PAPER = (236, 230, 214)


def dump():
    env = dict(os.environ, HT_HIGHBANK_V2="1")
    run = subprocess.run([GODOT, "--headless", "--path", ".", "--script", "res://tools/art/town_map_dump.gd"],
                         env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=300)
    line = next((l for l in run.stdout.splitlines() if l.startswith("TOWN_MAP_JSON ")), None)
    if line is None:
        sys.exit("town_map_dump.gd printed no map:\n" + run.stdout[-2000:] + run.stderr[-2000:])
    return json.loads(line[len("TOWN_MAP_JSON "):])


def side(size, rect):
    x, y, w, h = rect
    if x == 0:
        return "w"
    if x + w == size[0]:
        return "e"
    if y == 0:
        return "n"
    return "s"


def overlaps(a, b):
    return a[0] < b[0] + b[2] + GAP and b[0] < a[0] + a[2] + GAP and a[1] < b[1] + b[3] + GAP and b[1] < a[1] + a[3] + GAP


def layout(areas):
    """Tile offset of each area, walking the exits out from START."""
    at = {START: (0, 0)}
    queue = deque([START])
    while queue:
        a_id = queue.popleft()
        a = areas[a_id]
        ax, ay = at[a_id]
        for e in a["exits"]:
            b_id = e["to"]
            if b_id in at or b_id not in areas:
                continue
            b = areas[b_id]
            back = next((x for x in b["exits"] if x["to"] == a_id), None)
            br = back["rect"] if back else [0, 0, 1, 1]
            s = side(a["size"], e["rect"])
            if s in ("n", "s"):
                bx = ax + e["rect"][0] - br[0]
                by = ay - b["size"][1] - GAP if s == "n" else ay + a["size"][1] + GAP
                step = (0, -1 if s == "n" else 1)
            else:
                by = ay + e["rect"][1] - br[1]
                bx = ax - b["size"][0] - GAP if s == "w" else ax + a["size"][0] + GAP
                step = (0, -1)   # an east/west neighbour that collides moves up the bluff
            # Areas are separate screens; nudge one that would sit on top of another so both stay readable.
            for _ in range(60):
                box = (bx, by, *b["size"])
                if not any(overlaps(box, (*at[o], *areas[o]["size"])) for o in at):
                    break
                bx, by = bx + step[0], by + step[1]
            at[b_id] = (bx, by)
            queue.append(b_id)
    return at


def font(size):
    for f in ("C:/Windows/Fonts/arialbd.ttf", "C:/Windows/Fonts/arial.ttf"):
        if Path(f).exists():
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def label(d, xy, text, f, fill=INK, anchor="mm"):
    d.text(xy, text, font=f, fill=fill, anchor=anchor, stroke_width=2, stroke_fill=PAPER)


def draw(data, out):
    areas, classes = data["areas"], data["classes"]
    at = layout(areas)
    min_x = min(at[i][0] for i in at)
    min_y = min(at[i][1] for i in at)
    max_x = max(at[i][0] + areas[i]["size"][0] for i in at)
    max_y = max(at[i][1] + areas[i]["size"][1] for i in at)
    img = Image.new("RGB", ((max_x - min_x) * T + PAD * 2, (max_y - min_y) * T + PAD * 2 + 30), PAPER)
    d = ImageDraw.Draw(img)
    f_small, f_mid, f_big = font(11), font(13), font(17)

    def px(a_id, x, y):
        return PAD + (at[a_id][0] - min_x + x) * T, PAD + 30 + (at[a_id][1] - min_y + y) * T

    def box(a_id, r, **kw):
        x0, y0 = px(a_id, r[0], r[1])
        d.rectangle([x0, y0, x0 + r[2] * T - 1, y0 + r[3] * T - 1], **kw)
        return x0, y0

    exits_px = {}
    for a_id in at:
        a = areas[a_id]
        w, h = a["size"]
        g = a["ground"]
        box(a_id, [0, 0, w, h], fill=GROUND.get(g.get("base", "grass"), GROUND["grass"]))
        for band in g.get("bands", []):
            box(a_id, [0, band["from"], w, band["to"] - band["from"] + 1], fill=GROUND.get(band["kind"], (90, 90, 90)))
        for r in g.get("soft", []):
            box(a_id, r, fill=SOFT)
        for r in g.get("rects", []):
            box(a_id, r["rect"], fill=GROUND.get(r["kind"], (90, 90, 90)))
        for p in a["paths"]:
            box(a_id, p["rect"], fill=PATH.get(p["kind"], (200, 200, 200)))
        for p in a["places"]:
            r = p["rect"]
            if p["kind"] == "area":
                box(a_id, r, outline=(250, 236, 170), width=2)
            else:
                colour = (170, 60, 170) if p["service"] == "dungeon" else (90, 90, 90) if p["service"] == "closed" else (240, 200, 80)
                box(a_id, r, fill=colour, outline=INK)
        for lot in a.get("lots", []):
            x0, y0 = box(a_id, lot["base"], fill=(214, 200, 150), outline=(140, 110, 40), width=2)
        for b in a["buildings"]:
            x0, y0 = box(a_id, b["base"], fill=(30, 90, 120) if b["class"] == "hall" else (122, 74, 58), outline=INK, width=2)
        for pr in a.get("props", []):
            x, y = px(a_id, pr["tile"][0], pr["tile"][1])
            sw, sh = pr.get("size", [1, 1])
            c = (255, 214, 90) if pr.get("light") else (84, 58, 36) if "trunk" in pr["slot"] else (60, 50, 40)
            d.ellipse([x + 2, y + 2, x + sw * T - 3, y + sh * T - 3], fill=c, outline=INK)
        for e in a["exits"]:
            x0, y0 = box(a_id, e["rect"], fill=(200, 50, 40), outline=INK)
            r = e["rect"]
            exits_px[(a_id, e["to"])] = (x0 + r[2] * T / 2, y0 + r[3] * T / 2)
        x0, y0 = px(a_id, 0, 0)
        d.rectangle([x0, y0, x0 + w * T - 1, y0 + h * T - 1], outline=INK, width=2)
        label(d, (x0 + 4, y0 - 4), "%s  (%s, %dx%d tiles)" % (a["name"], a_id, w, h), f_big, anchor="ld")

    # Joins between areas, then the labels on top of everything.
    for (a_id, b_id), p0 in exits_px.items():
        p1 = exits_px.get((b_id, a_id))
        if p1 and a_id < b_id:
            d.line([p0, p1], fill=(200, 50, 40), width=3)
    for a_id in at:
        a = areas[a_id]
        for lot in a.get("lots", []):
            r = lot["base"]
            x, y = px(a_id, r[0] + r[2] / 2, r[1] + r[3] / 2)
            label(d, (x, y), lot["id"], f_small)
        for b in a["buildings"]:
            r = b["base"]
            x, y = px(a_id, r[0] + r[2] / 2, r[1] + r[3] / 2)
            if b["class"] == "hall":
                d.text((x, y), b["name"], font=f_mid, fill=(255, 255, 255), anchor="mm", stroke_width=2, stroke_fill=INK)
            else:
                label(d, (x, y), "%s (%s)" % (b["name"], b["class"]), f_mid)
        for p in a["places"]:
            r = p["rect"]
            x, y = px(a_id, r[0] + r[2] / 2, r[1] + r[3] + (0.6 if p["kind"] != "area" else -0.5))
            label(d, (x, y), p["name"], f_small)
    label(d, (PAD, 18), "Highbank v2 as wired, %d areas. Red: exits and the joins between them. Brown: buildings. "
          "Pale: empty lots. Gold: spots. Yellow outline: open areas. Purple: the Hollow's mouth. Yellow dots: lamps. "
          "Brown ovals: tree trunks."
          % len(at), f_mid, anchor="lm")
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    return img.size


def main():
    out = Path(next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--out=")), OUT))
    print(out, draw(dump(), out))


if __name__ == "__main__":
    main()
