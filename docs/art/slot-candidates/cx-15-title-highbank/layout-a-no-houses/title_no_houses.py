"""Paint the four street houses out of the installed title backdrop (Preston 2026-10-29: "get rid of the buildings in
title screen photo"). The lower forest from the strip west of the houses is laid over them in random chunks, the three
waylines keep their ends and drop onto tall timber posts standing on the lane instead of roof posts.
  python -I title_no_houses.py <src.png> <out.png>"""
import random, sys
from PIL import Image
src, out = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGBA")
a = im.load()
orig = im.copy().load()
TOP, FOOT = 141, 181          # rows replaced (chimney tops are row 142; the lane starts at 182)
X0, X1 = 88, 284              # the houses and the bush after the last one
SRC0, SRC1 = 30, 88           # the forest strip west of the houses
rng = random.Random(29)
x = X0
while x < X1:
    w = rng.randint(7, 13)
    sx = rng.randint(SRC0, SRC1 - w)
    flip = rng.random() < 0.5
    for i in range(w):
        if x + i >= X1:
            break
        cx = sx + (w - 1 - i if flip else i)
        for y in range(TOP, FOOT + 1):
            a[x + i, y] = orig[cx, y]
    x += w
# Keep the waylines' last few rows (their ink crosses rows 141 to 143).
for y in range(TOP, 144):
    for x in range(X0, X1):
        p = orig[x, y]
        if p[0] < 20 and p[1] < 20 and p[2] < 25:
            a[x, y] = p
# Wayline posts on the lane where each line ends: a dark timber pole lit on its west side, a brass pulley on top.
DK, LIT, BRASS, INK = (63, 39, 22, 255), (140, 101, 69, 255), (212, 169, 76, 255), (11, 14, 17, 255)
for px in (180, 242, 254):
    for y in range(144, FOOT + 1):
        a[px, y] = DK
        a[px - 1, y] = LIT if y % 6 else DK
    a[px, 143] = BRASS
    a[px - 1, 143] = INK
    a[px + 1, FOOT] = DK      # a foot block where it stands on the lane
    a[px - 2, FOOT] = DK
im.save(out)
print("saved", out)
