"""Text contrast measured on screenshots (pass 9 audit, scratch, read-only; the pixel version of pass 7's measure.py).
python -I contrast.py shot.png "label" x0 y0 x1 y1 [more boxes as: label x0 y0 x1 y1 ...]
For each box: the panel colour (the most common colour), then the most common colours that are not it, each with its
WCAG contrast ratio against the panel. Body text needs 4.5, large text 3.0. A box should hold one panel and its text."""
import sys
from collections import Counter
from PIL import Image


def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lum(rgb):
    r, g, b = rgb
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def cr(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


im = Image.open(sys.argv[1]).convert("RGB")
args = sys.argv[2:]
for i in range(0, len(args), 5):
    label = args[i]
    x0, y0, x1, y1 = map(int, args[i + 1:i + 5])
    px = list(im.crop((x0, y0, x1, y1)).getdata())
    cnt = Counter(px)
    bg, nbg = cnt.most_common(1)[0]
    # neighbours of the panel colour (texture, dither) within 12 per channel are panel too
    rest = Counter()
    for c, n in cnt.items():
        if max(abs(c[k] - bg[k]) for k in range(3)) > 12:
            rest[c] += n
    total = len(px)
    tops = rest.most_common(6)
    best = max(tops, key=lambda t: cr(t[0], bg)) if tops else ((0, 0, 0), 0)
    print(f"{label}: panel #{bg[0]:02x}{bg[1]:02x}{bg[2]:02x} ({100 * nbg / total:.0f}% of the box)")
    for c, n in tops:
        print(f"    #{c[0]:02x}{c[1]:02x}{c[2]:02x}  {n:5d} px  contrast {cr(c, bg):5.2f}")
    print(f"    highest-contrast common colour: {cr(best[0], bg):.2f}")
