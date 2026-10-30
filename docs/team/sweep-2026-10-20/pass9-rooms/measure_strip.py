"""Room key strip contrast on window stills (pass 9 rooms lane, R3 / A9-13; Claude, 2026-10-27).
python -I measure_strip.py shot.png [shot.png ...]
The strip sits in the bottom right over the room floor at 0.85: (847, 516) to (1146, 578) in a 1152x648 window, the same
in the storage, the home and the Hall (town_room.gd hint_now(), printed headless). Inside its frame (8 px in from the
sides, 6 from top and bottom) the words are the light pixels (relative luminance over 0.25) and the strip the dark ones
(under 0.12). For each still: the words' most common colour, the strip's most common colour, their WCAG ratio, and the
worst ratio, the words' colour against the strip's lightest 5% of pixels (the stone showing through most).
Body text needs 4.5. Pure measurement: it reads the stills and writes nothing."""
import sys
from collections import Counter
from PIL import Image

STRIP = (847, 516, 1146, 578)


def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lum(rgb):
    r, g, b = rgb[:3]
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def ratio(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def hexc(c):
    return "#%02x%02x%02x" % tuple(c[:3])


def measure(path):
    im = Image.open(path).convert("RGB")
    sx0, sy0, sx1, sy1 = STRIP
    # inside the frame (its brass edge is light too)
    ix0, iy0, ix1, iy1 = sx0 + 8, sy0 + 6, sx1 - 8, sy1 - 6
    words = []
    strip = []
    for y in range(iy0, iy1 + 1):
        for x in range(ix0, ix1 + 1):
            p = im.getpixel((x, y))
            if lum(p) > 0.25 and max(p) - min(p) < 48:   # the words are a pale grey-beige; the brass frame is saturated
                words.append((x, y, p))
            elif lum(p) < 0.12:
                strip.append(p)
    if not words:
        return "%s: no strip words found in x %d-%d y %d-%d" % (path, ix0, ix1, iy0, iy1)
    wx0, wx1, wy0, wy1 = ix0, ix1, iy0, iy1
    wc = Counter(p for _, _, p in words).most_common(1)[0][0]
    sc = Counter(strip).most_common(1)[0][0]
    light = sorted(strip, key=lum)
    worst_bg = light[int(len(light) * 0.95)] if light else sc
    return "%s: words %s (%d px), strip %s (%d px), ratio %.2f, worst %.2f against %s; box x %d-%d y %d-%d" % (
        path.replace("\\", "/").split("/")[-1], hexc(wc), len(words), hexc(sc), len(strip), ratio(wc, sc),
        ratio(wc, worst_bg), hexc(worst_bg), wx0, wx1, wy0, wy1)


for a in sys.argv[1:]:
    print(measure(a))
