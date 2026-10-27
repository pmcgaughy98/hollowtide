"""Hollowtide's pixel-art UI frames, drawn by hand in code (Claude, 2026-10-10). Preston: "the text
boxes and the graphics for U.I look so plain... it doesn't blend with the game... I want it to look
really good and legit."

The fix for "doesn't blend": the UI is pixel art at the same 3x pixel scale as the world, in the
game's own colours, not smooth vector boxes laid over it. Structure from hand-made games' frames:
pokeemerald builds every text box from small frame tiles (corners, edges, a fill) it stretches to any
size, and Explorers of Sky frames a portrait beside a bordered box with the speaker's name. Every
pixel here is placed by these functions; nothing is generated.

Each frame is a 9-slice source drawn at 1x, then saved 3x with nearest sampling so a pixel of UI is a
pixel of the world. Godot draws them with StyleBoxTexture (scripts/ui/ui_style.gd).
  python tools/ui/build_frames.py      writes assets/sprites/ui/frame/*.png and docs/ui/frames_sheet.png
  python tools/ui/build_frames.py --slots   writes only the five ui.frame9 slot frames and docs/ui/frames_sheet_slots.png
"""
from pathlib import Path
from PIL import Image

OUT = Path("assets/sprites/ui/frame")
SCALE = 3
INK = (26, 20, 16, 255)          # the creatures' outline
BRASS_HI = (240, 214, 150, 255)
BRASS = (190, 156, 98, 255)
BRASS_LO = (128, 98, 58, 255)
GROOVE = (44, 34, 24, 255)
MOSS = (35, 43, 36)
MOSS_LO = (29, 36, 30)
MOSS_HI = (42, 51, 43)
PARCH = (239, 230, 210, 255)
PARCH_LO = (222, 208, 180, 255)


def px(im, x, y, c):
    if 0 <= x < im.width and 0 <= y < im.height:
        im.putpixel((x, y), c)


def border(im, inset=0, focus=False):
    """The bevelled brass band: ink outside, light on the top and left, shade on the bottom and right,
    a dark groove inside. `focus` brightens the brass for a chosen button."""
    w, h = im.size
    hi, mid, lo = (BRASS_HI, (255, 236, 176, 255), BRASS) if focus else (BRASS_HI, BRASS, BRASS_LO)
    for x in range(w):
        for y in range(h):
            d = min(x, y, w - 1 - x, h - 1 - y) - inset
            if d < 0:
                continue
            if d == 0:
                px(im, x, y, INK)
            elif d == 1:
                px(im, x, y, hi if (y - inset == 1 or x - inset == 1) and not (y == h - 2 - inset or x == w - 2 - inset) else lo)
            elif d == 2:
                px(im, x, y, mid)
            elif d == 3:
                px(im, x, y, GROOVE)
    # Rounded outer corners: knock the corner pixel out and ink the step.
    for cx, cy in [(inset, inset), (w - 1 - inset, inset), (inset, h - 1 - inset), (w - 1 - inset, h - 1 - inset)]:
        px(im, cx, cy, (0, 0, 0, 0))


def rivets(im, at=2):
    w, h = im.size
    for cx, cy in [(at, at), (w - 1 - at, at), (at, h - 1 - at), (w - 1 - at, h - 1 - at)]:
        px(im, cx, cy, BRASS_HI)


def moss_fill(im, x0, y0, x1, y1, alpha=236):
    for y in range(y0, y1):
        for x in range(x0, x1):
            # A woven dither: a faint diagonal grain every few pixels, like woven reed matting.
            k = (x + y * 2) % 6
            c = MOSS_HI if k == 0 else (MOSS_LO if k == 3 else MOSS)
            px(im, x, y, c + (alpha,))


STUD = ["...i...",
        "..ibi..",
        ".ibhbi.",
        "ibhwhbi",
        ".ibhbi.",
        "..ibi..",
        "...i..."]


def stud(im, cx, cy):
    """A brass diamond stud with a highlight, sitting over a frame corner."""
    for y, row in enumerate(STUD):
        for x, ch in enumerate(row):
            c = {"i": INK, "b": BRASS_LO, "h": BRASS, "w": BRASS_HI}.get(ch)
            if c:
                px(im, cx - 3 + x, cy - 3 + y, c)


def panel(size=28, focus=False, alpha=236):
    """A panel 9-slice (margin 8, a 12-pixel centre so the weave tiles without a seam): moss weave, a 4-pixel bevelled brass band, an inner shadow under
    the top and left edges so the fill sits inside the frame, and a stud on every corner."""
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    moss_fill(im, 4, 4, size - 4, size - 4, alpha)
    border(im, focus=focus)
    for x in range(4, size - 4):        # the inner shadow
        px(im, x, 4, (22, 27, 23, alpha))
        px(im, x, 5, (28, 34, 29, alpha))
    for y in range(4, size - 4):
        px(im, 4, y, (24, 30, 25, alpha))
    for cx, cy in [(3, 3), (size - 4, 3), (3, size - 4), (size - 4, size - 4)]:
        stud(im, cx, cy)
    return im


def nameplate():
    """The speaker's tab: a small brass plate with an ink rim, text sits on it in dark ink."""
    im = Image.new("RGBA", (14, 12), (0, 0, 0, 0))
    w, h = im.size
    for y in range(h):
        for x in range(w):
            d = min(x, y, w - 1 - x, h - 1 - y)
            # Flat brass with one light line under the top rim: it stretches to any name without hatching.
            px(im, x, y, INK if d == 0 else (BRASS_HI if d == 1 and (y == 1 or x == 1) else (BRASS_LO if d == 1 else ((214, 182, 122, 255) if y == 2 else BRASS))))
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        px(im, cx, cy, (0, 0, 0, 0))
    return im


def portrait_frame():
    """The portrait well: a thicker brass frame around a parchment square, leaf notches at the corners."""
    im = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
    w, h = im.size
    for y in range(5, h - 5):
        for x in range(5, w - 5):
            px(im, x, y, PARCH if (x * 3 + y) % 7 else PARCH_LO)
    border(im)
    for x in range(w):            # a second brass ring inside: the frame is heavier than a panel's
        for y in range(h):
            d = min(x, y, w - 1 - x, h - 1 - y)
            if d == 4:
                px(im, x, y, BRASS if (x + y) % 2 else BRASS_LO)
    for cx, cy, dx, dy in [(2, 2, 1, 1), (w - 3, 2, -1, 1), (2, h - 3, 1, -1), (w - 3, h - 3, -1, -1)]:
        px(im, cx, cy, (110, 150, 80, 255))          # a small leaf at each corner
        px(im, cx + dx, cy, (80, 120, 60, 255))
        px(im, cx, cy + dy, (80, 120, 60, 255))
    return im


def arrow():
    """The 'next' arrow: a small brass chevron pointing down."""
    im = Image.new("RGBA", (7, 5), (0, 0, 0, 0))
    rows = ["iiiiiii", "ibbbbbi", ".ibbbi.", "..ibi..", "...i..."]
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == "i":
                px(im, x, y, INK)
            elif ch == "b":
                px(im, x, y, BRASS_HI if y == 1 else BRASS)
    return im


# The last flat rects in the UI kit, as 9-slices (Claude, 2026-10-26, placeholder factory lane U; census K05, K06,
# K07 and X14; slots ui.frame9.* in scripts/art/slots/ui.gd). The colours are ui_style.gd's, so each reads as the
# flat piece it replaces, now with a pixel rim lit from the upper left. ui_style.gd draws them through ArtSlots, and
# draws the old flat rects again while a frame is on its placeholder.
EDGE = (182, 155, 109, 255)        # ui_style EDGE
EDGE_LIGHT = (228, 202, 142, 255)  # ui_style EDGE_LIGHT
EDGE_LO = (128, 108, 74, 255)      # the brass in shade
FOCUS = (63, 81, 64, 255)          # ui_style FOCUS
FOCUS_HI = (77, 98, 78, 255)
FOCUS_LO = (50, 65, 51, 255)
WELL_BG = (99, 169, 166, 255)      # ui_style PORTRAIT_BG, the river blue behind a headshot
WELL_LO = (74, 130, 127, 255)
PANEL = (36, 43, 37, 255)          # ui_style PANEL
PANEL_HI = (44, 53, 45, 255)
PANEL_LO = (27, 32, 28, 255)
SLOT = (18, 22, 19, 255)           # a gauge's well: the 0.55 black over the panel it used to be
SLOT_LO = (12, 15, 13, 255)

# One character per pixel, "." clear. Each map is the 1x frame; the slot's margins (in 3x pixels) are in ui.gd.
FOCUS_ROW = [".TTTTTT.",          # margins 6: a light brass rim, a highlight inside its top and left,
             "ThhhhhhS",           # a shade inside its bottom and right, flat moss in the middle
             "ThFFFFdS",
             "ThFFFFdS",
             "ThFFFFdS",
             "ThFFFFdS",
             "ThdddddS",
             ".SSSSSS."]
HEADSHOT = [".EEEE.",              # margins 6 for the well; ui_style's rim pass uses only the outer ring (3)
            "EssssL",
            "EsPPPL",
            "EsPPPL",
            "EsPPPL",
            ".LLLL."]
BAR_WELL = ["bkkkkB",              # margins l6 t3 r6 b3: brass end caps, an ink lip, the dark slot the fill sits in
            "bwwwwB",
            "bddddB"]
BAR_FILL = ["W",                   # margins t3: a lit top row over the fill; tinted by the gauge's colour
            "g"]
BANNER = ["P...P...",              # margins t12 b12: the band feathers in and out, no rule across it (pass 3 D5)
          ".P.P.P.P",
          "hhhhhhhh",
          "PPPPPPPP",
          "PPPPPPPP",
          "PPPPPPPP",
          "PPPPPPPP",
          "PPPPPPPP",
          "PPPPPPPP",
          "llllllll",
          "P.P.P.P.",
          "..P...P."]


def from_rows(rows, key):
    im = Image.new("RGBA", (len(rows[0]), len(rows)), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                px(im, x, y, key[ch])
    return im


def slot_frames():
    """The five ui.frame9 slots, at 1x."""
    return {
        "focus_row": from_rows(FOCUS_ROW, {"T": EDGE_LIGHT, "S": EDGE, "h": FOCUS_HI, "d": FOCUS_LO, "F": FOCUS}),
        "headshot": from_rows(HEADSHOT, {"E": EDGE, "L": EDGE_LO, "s": WELL_LO, "P": WELL_BG}),
        "bar_well": from_rows(BAR_WELL, {"k": INK, "b": EDGE, "B": EDGE_LO, "w": SLOT, "d": SLOT_LO}),
        "bar_fill": from_rows(BAR_FILL, {"W": (255, 255, 255, 255), "g": (204, 204, 204, 255)}),
        "banner": from_rows(BANNER, {"P": PANEL, "h": PANEL_HI, "l": PANEL_LO}),
    }


def nine_tile(src, w, h, l, t, r, b, centre=True):
    """A 9-slice drawn as the game draws it (RenderingServer NINE_PATCH_TILE): corners kept, edges and middle tiled.
    `centre` False leaves the middle out, as ui_style's headshot rim pass does."""
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sw, sh = src.size
    cols = [(0, l, 0, l), (l, sw - r, l, w - r), (sw - r, sw, w - r, w)]
    rows = [(0, t, 0, t), (t, sh - b, t, h - b), (sh - b, sh, h - b, h)]
    for i, (sx0, sx1, dx0, dx1) in enumerate(cols):
        for j, (sy0, sy1, dy0, dy1) in enumerate(rows):
            if sx1 <= sx0 or sy1 <= sy0 or dx1 <= dx0 or dy1 <= dy0 or (i == 1 and j == 1 and not centre):
                continue
            piece = src.crop((sx0, sy0, sx1, sy1))
            for y in range(dy0, dy1, sy1 - sy0):
                for x in range(dx0, dx1, sx1 - sx0):
                    cut = piece.crop((0, 0, min(sx1 - sx0, dx1 - x), min(sy1 - sy0, dy1 - y)))
                    out.alpha_composite(cut, (x, y))
    return out


def tint(im, col, gain=1.25):
    """The fill as ui_style tints it: each channel times the gauge colour times 1.25, clamped."""
    out = im.copy()
    for y in range(out.height):
        for x in range(out.width):
            p = out.getpixel((x, y))
            if p[3]:
                out.putpixel((x, y), tuple(min(255, round(p[i] * col[i] / 255 * gain)) for i in range(3)) + (p[3],))
    return out


def slot_sheet(made):
    """docs/ui/frames_sheet_slots.png: each slot frame at its size in the game, on the panel, at screen pixels."""
    big = {k: up(v) for k, v in made.items()}
    sheet = Image.new("RGBA", (420, 260), (60, 70, 62, 255))
    sheet.alpha_composite(nine_tile(up(panel()), 400, 240, 24, 24, 24, 24), (10, 10))
    sheet.alpha_composite(nine_tile(big["focus_row"], 360, 40, 6, 6, 6, 6), (30, 30))
    well = nine_tile(big["headshot"], 48, 48, 6, 6, 6, 6)
    sheet.alpha_composite(well, (30, 84))
    face = Image.new("RGBA", (48, 48), (0, 0, 0, 0))   # a stand-in face over the well, then the rim pass over it
    face.paste((214, 160, 96, 255), (9, 12, 39, 45))
    sheet.alpha_composite(well, (90, 84))
    sheet.alpha_composite(face, (90, 84))
    sheet.alpha_composite(nine_tile(big["headshot"], 48, 48, 3, 3, 3, 3, centre=False), (90, 84))
    for i, (frac, col) in enumerate([(0.62, (111, 212, 134)), (0.3, (232, 87, 74)), (0.8, (242, 193, 78))]):
        y = 146 + i * 18
        sheet.alpha_composite(nine_tile(big["bar_well"], 170, 9, 6, 3, 6, 3), (30, y))
        fw = int((170 - 6) * frac)
        sheet.alpha_composite(nine_tile(tint(big["bar_fill"], col), fw, 6, 0, 3, 0, 0), (33, y + 3))
    sheet.alpha_composite(nine_tile(big["banner"], 360, 48, 0, 12, 0, 12), (30, 200))
    return sheet


def up(im):
    return im.resize((im.width * SCALE, im.height * SCALE), Image.NEAREST)


if __name__ == "__main__":
    import sys
    OUT.mkdir(parents=True, exist_ok=True)
    slots = slot_frames()
    for name, im in slots.items():
        up(im).save(OUT / f"{name}.png")
    slot_sheet(slots).save("docs/ui/frames_sheet_slots.png")
    if "--slots" in sys.argv:   # only the five slot frames; the panels and tabs stay as they are on disk
        print("slot frames:", ", ".join(slots))
        raise SystemExit(0)
    made = {
        "panel": panel(),
        "panel_focus": panel(focus=True),
        "panel_dim": panel(alpha=200),
        "nameplate": nameplate(),
        "portrait": portrait_frame(),
        "arrow": arrow(),
    }
    for name, im in made.items():
        up(im).save(OUT / f"{name}.png")
    # A review sheet: each piece stretched as the game will stretch it.
    sheet = Image.new("RGBA", (300, 120), (60, 70, 62, 255))
    def nine(src, w, h, m):
        out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        sw, sh = src.size
        for (sx0, sx1, dx0, dx1) in [(0, m, 0, m), (m, sw - m, m, w - m), (sw - m, sw, w - m, w)]:
            for (sy0, sy1, dy0, dy1) in [(0, m, 0, m), (m, sh - m, m, h - m), (sh - m, sh, h - m, h)]:
                piece = src.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.NEAREST)
                out.alpha_composite(piece, (dx0, dy0))
        return out
    sheet.alpha_composite(nine(made["panel"], 120, 50, 8), (6, 6))
    sheet.alpha_composite(nine(made["panel_focus"], 80, 24, 8), (6, 62))
    sheet.alpha_composite(nine(made["nameplate"], 50, 12, 4), (140, 6))
    sheet.alpha_composite(nine(made["portrait"], 40, 40, 7), (140, 26))
    sheet.alpha_composite(made["arrow"], (200, 30))
    up(up(sheet)).save("docs/ui/frames_sheet.png")
    print("frames:", ", ".join(made))
