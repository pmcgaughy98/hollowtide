"""The Guildmaster's desk in Wayline Hall, drawn by hand in code (Claude, 2026-10-10; Preston: "replace the desk
as it doesn't look right anyway; we'll custom make the asset for the Guildmaster and the scene").
A proposal for Preston's approval. Every pixel is placed by the rules below, in a locked palette of about
18 colours taken from the Hall's wood and brass, lit from the top left, with a dark outline round the
silhouette like the creatures'. No generator is involved.

The desk sits where the old counter was (room pixels x 168..360, y 46..98; the counter's solid tiles are
row 3, x tiles 7..14). The Guildmaster stands behind it on row 2; scripts/town/town_room.gd draws the desk
over row 2 and under row 3 and below.
  python tools/art/guild_desk.py
Writes assets/sprites/world/guild_desk/desk.png (192 x 52) and a 4x preview desk_preview.png beside it.
"""
from pathlib import Path
import numpy as np
from PIL import Image

W, H = 192, 52
OUT = Path("assets/sprites/world/guild_desk")

P = {   # the locked palette
    "line": (36, 19, 10), "wood0": (62, 33, 16), "wood1": (88, 47, 22), "wood2": (118, 64, 29),
    "wood3": (150, 86, 40), "wood4": (186, 118, 58), "grain": (100, 54, 25),
    "brass0": (110, 74, 22), "brass1": (176, 130, 44), "brass2": (230, 196, 96),
    "paper0": (176, 160, 128), "paper1": (232, 220, 192), "ink": (40, 40, 58),
    "parcel0": (120, 88, 52), "parcel1": (164, 124, 78), "parcel2": (196, 156, 104), "string": (62, 118, 74),
    "red": (150, 46, 40),
}

img = np.zeros((H, W, 4), np.uint8)


def px(x, y, c, a=255):
    if 0 <= x < W and 0 <= y < H:
        img[y, x] = (*P[c], a) if isinstance(c, str) else (*c, a)


def rect(x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1):
            px(x, y, c)


def hline(x0, x1, y, c):
    rect(x0, y, x1, y + 1, c)


# --- the body ---------------------------------------------------------------------------------------
TOP0, TOP1 = 6, 26      # the desktop, seen from above at the room's angle
FACE0, FACE1 = 26, 46   # the front, facing the room
L, R = 2, W - 2         # the ends are rounded by a pixel or two

# Desktop planks, running the desk's length: a light wood with a darker seam every 5 rows and grain flecks.
for y in range(TOP0, TOP1):
    for x in range(L, R):
        k = (y - TOP0) % 5
        c = "wood3" if k else "wood2"                      # plank seams
        if k == 1:
            c = "wood4"                                    # each plank's lit upper edge (light from the top left)
        if (x * 7 + y * 13) % 29 == 0 and k not in (0, 1):
            c = "grain"
        if x < L + 3 or x > R - 4:
            c = "wood2" if k else "wood1"                  # the ends turn away from the light
        px(x, y, c)
hline(L + 1, R - 1, TOP0, "wood2")                         # the far edge, in shade
hline(L, R, TOP1 - 2, "brass1")                            # a brass lip along the front edge
hline(L, R, TOP1 - 1, "brass0")
for x in range(L + 6, R - 6, 18):
    px(x, TOP1 - 2, "brass2")                              # glints where the light catches the lip

# Front face: dark panels between lighter stiles every 24 pixels, each panel with an inset frame.
for y in range(FACE0, FACE1):
    for x in range(L, R):
        px(x, y, "wood1")
for s in range(L, R + 1, 24):
    rect(s, FACE0, min(s + 3, R), FACE1, "wood2")          # the stiles
    rect(s, FACE0, min(s + 1, R), FACE1, "wood3")          # lit on their left edge
for s in range(L + 3, R - 3, 24):
    x0, x1 = s + 3, min(s + 18, R - 3)
    hline(x0, x1, FACE0 + 4, "wood0")                      # inset frame: shadow above
    rect(x0, FACE0 + 4, x0 + 1, FACE1 - 4, "wood0")       # and on the left
    hline(x0, x1, FACE1 - 5, "wood2")                      # light below
    rect(x1 - 1, FACE0 + 4, x1, FACE1 - 4, "wood2")       # and on the right
hline(L, R, FACE0, "wood0")                                # the shadow under the brass lip
rect(L, FACE1 - 3, R, FACE1, "wood0")                      # the plinth
hline(L, R, FACE1 - 3, "wood2")

# The Guildmaster's star, in brass, on the centre panel (proposal: Starward's mark).
cx, cy = W // 2, (FACE0 + FACE1) // 2
star = ["....2....", "...212...", "...212...", "211111112", ".2111112.", "..21112..", ".211.112.", ".21...12.", "2.......2"]
for j, row in enumerate(star):
    for i, ch in enumerate(row):
        if ch == "1":
            px(cx - 4 + i, cy - 4 + j, "brass1")
        elif ch == "2":
            px(cx - 4 + i, cy - 4 + j, "brass0")
px(cx - 1, cy - 2, "brass2")
px(cx - 2, cy, "brass2")

# --- what sits on it ---------------------------------------------------------------------------------
# A stack of string-tied parcels at the left end.
for (x0, y0, w, h) in [(10, 8, 22, 12), (14, 0, 16, 9)]:
    rect(x0, y0, x0 + w, y0 + h, "parcel1")
    hline(x0, x0 + w, y0, "parcel2")
    rect(x0 + w - 2, y0, x0 + w, y0 + h, "parcel0")
    hline(x0, x0 + w, y0 + h - 1, "parcel0")
    rect(x0 + w // 2, y0, x0 + w // 2 + 1, y0 + h, "string")
    hline(x0, x0 + w, y0 + h // 2, "string")
# The open ledger, left of centre, tilted to the reader.
lx, ly = 64, 9
rect(lx, ly, lx + 30, ly + 12, "paper1")
rect(lx + 14, ly, lx + 16, ly + 12, "paper0")              # the spine's fold
for k in range(3):
    hline(lx + 3, lx + 12, ly + 3 + k * 3, "paper0")       # lines of entries
    hline(lx + 18, lx + 27, ly + 3 + k * 3, "paper0")
hline(lx, lx + 30, ly + 12, "wood1")                       # its shadow on the desk
px(lx + 22, ly + 9, "ink")
px(lx + 23, ly + 8, "ink")                                 # a fresh mark
# The stamp and its ink pad, right of centre.
sx, sy = 112, 12
rect(sx, sy + 4, sx + 12, sy + 9, "ink")
hline(sx, sx + 12, sy + 4, (70, 70, 96))
rect(sx + 15, sy, sx + 19, sy + 7, "wood2")                # the stamp's handle
rect(sx + 14, sy + 7, sx + 20, sy + 9, "red")
hline(sx + 15, sx + 19, sy, "wood4")
# The brass bell at the right end.
bx, by = 160, 8
for j, w in enumerate([2, 4, 6, 8, 8, 10]):
    hline(bx - w // 2, bx + w // 2, by + j, "brass1")
    px(bx - w // 2, by + j, "brass2")
    px(bx + w // 2 - 1, by + j, "brass0")
hline(bx - 6, bx + 6, by + 6, "brass0")
px(bx, by - 1, "brass2")
hline(bx - 5, bx + 6, by + 7, "wood1")                     # its shadow

# --- outline and floor shadow -------------------------------------------------------------------------
solid = img[..., 3] > 0
edge = solid & ~(np.roll(solid, 1, 0) & np.roll(solid, -1, 0) & np.roll(solid, 1, 1) & np.roll(solid, -1, 1))
edge[0, :] |= solid[0, :]
edge[:, 0] |= solid[:, 0]
edge[:, -1] |= solid[:, -1]
img[edge] = (*P["line"], 255)
for y in range(FACE1, FACE1 + 4):                          # a soft shadow cast on the floor in front
    for x in range(L + 2, R - 1):
        if not img[y, x, 3]:
            img[y, x] = (0, 0, 0, 90 - (y - FACE1) * 20)

OUT.mkdir(parents=True, exist_ok=True)
Image.fromarray(img).save(OUT / "desk.png")
Image.fromarray(img).resize((W * 4, H * 4), Image.NEAREST).save(OUT / "desk_preview.png")
used = {tuple(c) for c in img[img[..., 3] == 255][:, :3]}
print("desk.png", W, "x", H, "colours", len(used))
