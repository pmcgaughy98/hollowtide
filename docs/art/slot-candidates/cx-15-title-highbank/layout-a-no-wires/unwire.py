"""Paint the waylines and their three lane posts out of the installed title.
  python unwire.py <in.png> <out.png>
Wire = the long near-black (0b0e11) runs between the posts and the reel, plus the tan highlight row just above them and
the teal glints on them; posts = the 2 px brown columns from their caps to the lane. Each masked pixel is refilled from
its unmasked neighbours (horizontal ones weighted double, since the sky, hills and forest run in horizontal bands)."""
import sys
from collections import Counter
from PIL import Image

im = Image.open(sys.argv[1]).convert("RGB")
px = im.load()
W, H = im.size
DARK, TAN, TEAL = (0x0b, 0x0e, 0x11), (0x9c, 0x8c, 0x68), (0x2d, 0x9e, 0x9f)
X0, X1, Y0, Y1 = 170, 302, 72, 145          # the wires' span, stopping short of the reel ring and the deck

# connected runs of the wire's dark colour; the wires are the long ones
seen, wires = set(), set()
for y in range(Y0, Y1 + 1):
    for x in range(X0, X1 + 1):
        if px[x, y] != DARK or (x, y) in seen:
            continue
        comp, stack = [], [(x, y)]
        seen.add((x, y))
        while stack:
            cx, cy = stack.pop()
            comp.append((cx, cy))
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    n = (cx + dx, cy + dy)
                    if X0 <= n[0] <= X1 and Y0 <= n[1] <= Y1 and n not in seen and px[n] == DARK:
                        seen.add(n)
                        stack.append(n)
        xs = [p[0] for p in comp]
        if max(xs) - min(xs) >= 12:
            wires |= set(comp)
mask = set(wires)
for (x, y) in wires:
    for dx in (-1, 0, 1):
        for dy in (-2, -1, 0, 1):
            n = (x + dx, y + dy)
            if X0 - 2 <= n[0] <= X1 and n not in mask and (px[n] == TEAL or (px[n] == TAN and dy < 0)):
                mask.add(n)
# the three posts, caps to feet
for pxs in ((179, 180), (241, 242), (253, 254)):
    for y in range(142, 182):
        for x in range(pxs[0] - 1, pxs[1] + 2):
            if px[x, y] in (DARK, (0x3f, 0x27, 0x16), (0x8c, 0x65, 0x45), (0xd4, 0xa9, 0x4c)):
                mask.add((x, y))
print("wire pixels", len(wires), "masked", len(mask))

todo = set(mask)
while todo:
    fills = {}
    for (x, y) in todo:
        votes = Counter()
        for dx, dy, w in ((-1, 0, 2), (1, 0, 2), (0, -1, 1), (0, 1, 1), (-1, -1, 1), (1, -1, 1), (-1, 1, 1), (1, 1, 1)):
            n = (x + dx, y + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and n not in todo:
                votes[px[n]] += w
        if votes:
            fills[(x, y)] = votes.most_common(1)[0][0]
    for p, c in fills.items():
        px[p] = c
    todo -= set(fills)
im.save(sys.argv[2])
