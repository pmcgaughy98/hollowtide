"""Wayburn front: smooth the back line over the hips (Claude, 2026-10-05).

The installed front had a 6 px vertical drop in its back outline at x 94 and a
flat stretch to x 77, so the top of the back looked cut off near the rear.
Each column from x 77 to 94 has its top band (outline and the texture just
under it) lifted so the outline follows a straight slope from (95, 66) to
(66, 77). Nothing else changes.
"""
import sys
from PIL import Image
SRC = "assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/wayburn_front.png"
BAND = 7
img = Image.open(SRC).convert("RGBA")
src = img.copy().load()
p = img.load()
for x in range(77, 95):
    # Start below the tail arch that crosses these columns higher up.
    y_old = next(y for y in range(56, img.height) if src[x, y][3] > 0)
    y_new = round(66 + (95 - x) * 11 / 29)
    d = y_old - y_new
    if d <= 0:
        continue
    for y in range(y_old, y_old + BAND):
        p[x, y - d] = src[x, y]
    print(x, y_old, "->", y_new)
img.save(sys.argv[1])
