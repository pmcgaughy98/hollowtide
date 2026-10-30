"""Great tree, reading 2: "under its reach", at the vast scale (2026-10-27).

Design mocks only. Nothing here is installed. Run with:  python mock_tree-boughs.py
Writes, next to this file, a 1x and a 3x of each mock:
  title         the great tree painted into Codex's cx-15 title candidate (old 720 px Tower kept)
  title_guides  the same with the calm boxes and the taller-Tower column marked
  vista         the road home vista with the tree behind Highbank
  base          arriving at the tree, painted from scratch at 384x216
  influence     four town views with the tree's reach painted in (root ridge, leaves, shade, river root)
  map           top-down: Highbank, river, forest, the tree, its roots, the Tower's root, scale bar

All tree numbers are proposals. Preston's reference painting is used for scale only; nothing is
traced or copied from it, or from any other game or show. The title and vista paint over Codex's
candidate and our own in-game screenshots; the base is painted from scratch.
"""
from PIL import Image, ImageDraw, ImageFont
import math
import os
import json

ROOT = 'C:/Users/pmcga/dev/hollowtide'
OUT = ROOT + '/docs/design/vast-scale-2026-10-27/tree-boughs'
CX15 = ROOT + '/docs/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/prepared.png'
SHOTS = ROOT + '/docs/design/wayline-tower-2026-10-27/build/round2/'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
SPR = ROOT + '/assets/sprites/arena/'
REPORT = {}


# ---------------------------------------------------------------- helpers
def hx(s):
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def hn(x, y, s=0):
    n = (int(x) * 374761393 + int(y) * 668265263 + s * 982451653) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535.0


def vn(x, y, sc, s=0):
    """Smooth value noise, 0..1."""
    gx, gy = x / sc, y / sc
    x0, y0 = math.floor(gx), math.floor(gy)
    fx, fy = gx - x0, gy - y0
    fx = fx * fx * (3 - 2 * fx)
    fy = fy * fy * (3 - 2 * fy)
    a, b = hn(x0, y0, s), hn(x0 + 1, y0, s)
    c, d = hn(x0, y0 + 1, s), hn(x0 + 1, y0 + 1, s)
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy


def avn(x, y, sx, sy, s=0):
    """Stretched noise: sx, sy are the feature sizes across and along."""
    return vn(x / sx * 10.0, y / sy * 10.0, 10.0, s)


def catmull(pts, per=24):
    out = []
    P = [pts[0]] + list(pts) + [pts[-1]]
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = P[i - 1], P[i], P[i + 1], P[i + 2]
        for j in range(per):
            t = j / per
            t2, t3 = t * t, t * t * t
            out.append(tuple(0.5 * ((2 * p1[k]) + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2
                                    + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3) for k in (0, 1)))
    out.append(tuple(pts[-1]))
    return out


def save(img, name):
    img.save('%s/%s_1x.png' % (OUT, name))
    w, h = img.size
    img.resize((w * 3, h * 3), Image.NEAREST).save('%s/%s_3x.png' % (OUT, name))


def ncol(img):
    return len(img.convert('RGB').getcolors(1 << 20))


def lumstd(img, box):
    x0, y0, x1, y1 = box
    p = img.load()
    v = [lum(p[x, y]) for y in range(y0, y1) for x in range(x0, x1)]
    m = sum(v) / len(v)
    return round((sum((a - m) ** 2 for a in v) / len(v)) ** 0.5, 1)


def text(img, xy, s, col, shadow=None, size=8):
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, size)
    if shadow:
        d.text((xy[0] + 1, xy[1] + 1), s, fill=shadow, font=f)
    d.text(xy, s, fill=col, font=f)


def put(px, W, H, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        px[x, y] = c


def stamp_root(lp, W, H, pts, w0, w1, ramp, light=(-1.0, -0.4), streak_seed=0, outline=None):
    """A thick tapering limb or root along a path, with bark streaks running along it.
    ramp = colours dark to light (4 or more)."""
    ln = math.hypot(*light)
    lx, ly = light[0] / ln, light[1] / ln
    path = catmull(pts, 40)
    total = len(path) - 1
    n = len(ramp)
    owner = {}
    for i, (cx, cy) in enumerate(path):
        t = i / max(1, total)
        r = (w0 + (w1 - w0) * t) / 2.0
        if i < total:
            tx, ty = path[i + 1][0] - cx, path[i + 1][1] - cy
        else:
            tx, ty = cx - path[i - 1][0], cy - path[i - 1][1]
        tl = math.hypot(tx, ty) or 1
        nx, ny = -ty / tl, tx / tl
        for yy in range(int(cy - r) - 1, int(cy + r) + 2):
            for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                dx, dy = xx - cx, yy - cy
                if dx * dx + dy * dy > r * r:
                    continue
                s = (dx * nx + dy * ny) / max(r, 0.5)        # -1..1 across the limb
                lit = (dx * lx + dy * ly) / max(r, 0.5)       # how much this side faces the light
                k = int(round((lit + 1) / 2.0 * (n - 1) * 0.85 + 0.4))
                band = int((s + 1) * 4.5)
                if hn(band, i // 7, streak_seed) > 0.62:
                    k -= 1
                k = max(0, min(n - 1, k))
                lp[xx, yy] = ramp[k]
                owner[(xx, yy)] = True
    if outline:
        for (xx, yy) in list(owner):
            for (ax, ay) in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (xx + ax, yy + ay)
                if q not in owner and 0 <= q[0] < W and 0 <= q[1] < H:
                    lp[q[0], q[1]] = outline
    return owner


LEAF = ('e0b85a', 'b98a3a', '7a5a28', '4d3a1c')  # proposal: green-gold leaf, light, mid, rib, outline


def draw_leaf(img, cx, cy, L, ang, cols=None, shadow_k=None):
    """One leaf of the great tree (proposal: about 1 tile long). A pointed oval with a stem,
    a midrib and a dark outline so it reads as an object at game size."""
    cols = cols or tuple(hx(c) for c in LEAF)
    W, H = img.size
    p = img.load()
    ca, sa = math.cos(ang), math.sin(ang)
    hw_max = max(1.5, L * 0.19)
    inside = set()
    R = int(L / 2) + 3
    for y in range(int(cy - R), int(cy + R) + 1):
        for x in range(int(cx - R), int(cx + R) + 1):
            dx, dy = x - cx, y - cy
            u = (dx * ca + dy * sa) / (L / 2.0)
            v = (-dx * sa + dy * ca)
            if -1 <= u <= 1:
                prof = (1 - u * u) ** 0.55 * (1.0 - 0.35 * max(0.0, u)) + (0.08 if u < 0.9 else 0)
                if abs(v) <= hw_max * prof + 0.35:
                    inside.add((x, y))
            elif -1.3 <= u < -1 and abs(v) < 0.7:
                inside.add((x, y))
    if shadow_k:
        orig = img.copy().load()
        for (x, y) in inside:
            sx, sy = x + 3, y + 4
            if 0 <= sx < W and 0 <= sy < H and (sx, sy) not in inside:
                c = orig[sx, sy]
                p[sx, sy] = (int(c[0] * shadow_k[0]), int(c[1] * shadow_k[1]), int(c[2] * shadow_k[2]))
    for (x, y) in inside:
        if not (0 <= x < W and 0 <= y < H):
            continue
        dx, dy = x - cx, y - cy
        u = (dx * ca + dy * sa) / (L / 2.0)
        v = (-dx * sa + dy * ca)
        edge = any((x + a, y + b) not in inside for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        if edge and L >= 8:
            p[x, y] = cols[3]
        elif abs(v) < 0.6 and L >= 10:
            p[x, y] = cols[2]
        else:
            p[x, y] = cols[0] if v < 0 else cols[1]


def crown_field(W, H, edge, xmax, clumps_seed, x_range):
    """Crown underside mask: everything above a lobed lower edge."""
    clumps = []
    for i, x0 in enumerate(range(x_range[0], x_range[1], 11)):
        r = 7 + int(hn(i, 3, clumps_seed) * 6)
        clumps.append((x0 + int(hn(i, 4, clumps_seed) * 5) - 2, edge(x0) - r + 5, r))

    def inside(x, y):
        if x > xmax or x < -20:
            return False
        if y < edge(x) - 6:
            return True
        return any((x - cx) ** 2 + (y - cy) ** 2 <= r * r for (cx, cy, r) in clumps)
    return inside, clumps


def tiny_trees(lp, W, H, skyline, xs, seed, cols, sun_left=True, hmin=4, hmax=9):
    """Full-size forest trees seen from far off: a varied row along a skyline. cols = (body, top, rim)."""
    x = xs[0]
    i = 0
    made = []
    while x < xs[1]:
        h = hmin + int(hn(i, 1, seed) * (hmax - hmin + 1))
        w = h + 2 + int(hn(i, 2, seed) * 3)        # rounder and wider than tall: broadleaf crowns
        base = int(skyline(x)) + 3
        made.append(h)
        cx, cy = x, base - h / 2.0
        ax, ay = w / 2.0 + 0.3, h / 2.0 + 0.3
        for y in range(base - h - 1, base + 1):
            for xx in range(x - w, x + w + 1):
                # a crown made of two lumps, so the skyline is lumpy instead of a row of pegs
                d1 = ((xx - cx) / ax) ** 2 + ((y - cy) / ay) ** 2
                d2 = ((xx - cx - w * 0.3) / (ax * 0.7)) ** 2 + ((y - cy + h * 0.25) / (ay * 0.7)) ** 2
                if d1 > 1 and d2 > 1:
                    continue
                side = (xx - cx) < 0 if sun_left else (xx - cx) > 0
                upper = y < cy
                rim = side and upper and (((xx - cx + (1 if sun_left else -1)) / ax) ** 2 + ((y - cy - 1) / ay) ** 2 > 1 or d1 > 0.75)
                col = cols[2] if rim else (cols[1] if upper else cols[0])
                put(lp, W, H, xx, y, col)
        x += 3 + int(hn(i, 3, seed) * 5)
        i += 1
    return made


# ---------------------------------------------------------------- title
# Every colour used here is already in the highbank_title palette (47 of 48), so the title keeps
# its colour count. The tree is painted only onto sky and far-hill pixels, so the near left tree,
# the forest ridge, the houses, the waylines and the Tower all stay in front of it.
TBG = set(hx(c) for c in ['1e302e', '263d3a', '33524e', '43665a', '4f6858', '61785c', '8e7f5e', '9c8c68',
                          'c49243', 'd4a94c', 'ecb36b', 'b8793e', 'f1c177', 'f2d27a', 'fbd490', 'e6c697',
                          'dca562', 'f5d9a8'])
TSTREAK = set(hx(c) for c in ['908940', '6b6d45', '5f5e57', '92724b'])  # cloud streak edges, only high in the sky
WORDMARK = (90, 0, 296, 53)
MENU = (21, 108, 129, 200)


def mock_title():
    base = Image.open(CX15).convert('RGB')
    W, H = base.size
    bp = base.load()
    before = base.copy()
    lay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    lp = lay.load()
    C = lambda s: hx(s) + (255,)
    TR = [C(c) for c in ['192726', '1e302e', '263d3a', '33524e', '43665a']]  # haze bark ramp

    # trunk: wide, tapering upward, rooted behind the near forest ridge
    fork = 50

    def tcx(y):
        return 167 + (112 - y) * 0.05 + 2 * math.sin(y / 19.0)

    def thw(y):
        return 36 + (y - 40) * 0.22

    for y in range(fork - 4, 130):
        c, hw = tcx(y), thw(y)
        L, R = c - hw, c + hw
        for x in range(int(L), int(R) + 1):
            u = (x - L) / (R - L)
            k = 3 if u < 0.22 else (2 if u < 0.78 else 1)
            n = avn(x, y, 3.0, 28.0, 21)
            if abs(n - 0.5) < 0.05:
                k -= 1
            elif 0.05 <= n - 0.5 < 0.09 and u < 0.6:
                k += 1
            if hn(int(x / 6), int(y / 9), 22) > 0.93 and abs(n - 0.5) > 0.1:
                k -= 1  # a few plate breaks, not a grid
            col = TR[max(0, min(4, k))]
            if u < 0.03 and y > 58 and vn(x, y, 5, 23) > 0.42:
                col = C('8e7f5e' if y < 96 or hn(x, y, 24) < 0.6 else 'c49243')
            elif u > 0.975:
                col = C('43665a')
            lp[x, y] = col
    # the crotch where the limbs leave the trunk
    for y in range(fork - 2, fork + 6):
        for x in range(int(tcx(y) - 6 + (y - fork)), int(tcx(y) + 6 - (y - fork)) + 1):
            lp[x, y] = TR[0]
    # limbs, drawn before the leaves so they vanish into the crown
    limbs = [
        ([(140, 56), (126, 38), (110, 18), (96, -6)], 30, 18),
        ([(162, 52), (160, 30), (158, 8), (156, -8)], 24, 16),
        ([(184, 54), (198, 36), (218, 18), (236, -4)], 26, 16),
        ([(200, 62), (228, 50), (258, 40), (290, 30)], 16, 6),
    ]
    for i, (pts, w0, w1) in enumerate(limbs):
        stamp_root(lp, W, H, pts, w0, w1, [TR[0], TR[1], TR[2], TR[3]], light=(-1.0, 0.5), streak_seed=40 + i)

    # crown underside: one calm dark field across the top, lobed lower edge, ends short of the crook
    def edge(x):
        if x <= 244:
            return 47 + 6 * math.sin(x / 17.0 + 0.5) + 3 * math.sin(x / 6.1 + 2.0)
        return 47 - (x - 244) * 0.55 + 2 * math.sin(x / 5.0)

    incrown, clumps = crown_field(W, H, edge, 298, 11, (-8, 300))
    holes = [(262, 30, 2), (284, 22, 2), (240, 40, 2), (276, 14, 1)]
    for y in range(H):
        for x in range(W):
            if not incrown(x, y):
                continue
            if any((x - hx_) ** 2 + (y - hy) ** 2 <= hr * hr for (hx_, hy, hr) in holes):
                continue
            col = '1d2925'
            if not incrown(x, y + 1):
                col = '4f6858' if x > 76 else ('c49243' if hn(x // 2, y, 2) > 0.5 else '8e7f5e')
            elif not incrown(x, y + 2):
                col = '303e37'
            else:
                # each lobe gets a faint darker underline: leaf masses, kept to one tone step
                lobe_line = any(0 <= (y - cy) - (r - 1) < 1 and abs(x - cx) < r * 0.8 for (cx, cy, r) in clumps)
                inner = vn(x, y, 9, 4)
                if lobe_line or inner > 0.74:
                    col = '192726'
            lp[x, y] = C(col)
    # hanging leaf strands from the rim, toward the Tower but stopping short of it
    for x in range(190, 296, 3):
        if hn(x, 1, 5) < 0.35:
            continue
        n = 4 + int(hn(x, 2, 5) * 10)
        y0 = int(edge(x)) - 2
        for k in range(n):
            lp[x, y0 + k] = C('303e37' if k < n - 1 else '4f6858')

    # buttress roots: hills rising above the near forest ridge, tiny full-size trees along them
    bumps = [(84, 5, 22), (122, 16, 20), (214, 17, 18), (246, 9, 20), (278, 4, 16)]

    def B(x):
        return 112 - sum(h * math.exp(-((x - c) / w) ** 2) for c, h, w in bumps)

    for x in range(56, 300):
        top = int(round(B(x)))
        rising = B(x + 1) < B(x - 1)
        for y in range(top, 132):
            if lay.getpixel((x, y))[3]:
                continue
            col = '263d3a'
            if y == top:
                col = ('8e7f5e' if hn(x, 0, 14) < 0.7 else 'd4a94c') if (rising and vn(x, 0, 6, 15) > 0.35) else '43665a'
            elif abs(avn(x, y, 3.0, 12.0, 13) - 0.5) < 0.05:
                col = '1e302e'
            lp[x, y] = C(col)
    made = tiny_trees(lp, W, H, B, (58, 118), 31, (C('1d2925'), C('303e37'), C('8e7f5e')), hmin=4, hmax=7)
    made += tiny_trees(lp, W, H, B, (220, 298), 32, (C('1d2925'), C('303e37'), C('8e7f5e')), hmin=4, hmax=7)
    REPORT['title_tiny_trees_px'] = '%d to %d px tall, %d trees' % (min(made), max(made), len(made))

    nonbg = lambda c, y: not (c in TBG or (c in TSTREAK and y < 76))

    def protected(x, y):
        c = bp[x, y]
        if nonbg(c, y):
            return True
        if x >= 284 and y >= 48:
            return True
        if x < 78 and y < 186:
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and nonbg(bp[xx, yy], yy):
                        return True
        return False

    out = base.copy()
    op = out.load()
    for y in range(H):
        for x in range(W):
            a = lp[x, y]
            if a[3] and not protected(x, y):
                op[x, y] = a[:3]
    # a few of the tree's leaves drifting over the town (front, kept out of the menu box)
    for (lx, ly, flip) in [(152, 127, 0), (184, 139, 1), (216, 122, 0), (248, 133, 1), (264, 117, 0)]:
        put(op, W, H, lx, ly, hx('d4a94c'))
        put(op, W, H, lx + 1, ly + flip, hx('8e7f5e'))
    save(out, 'title')
    REPORT['title_colours'] = '%d before, %d after' % (ncol(before), ncol(out))
    REPORT['title_wordmark_lum_std'] = '%s before, %s after' % (lumstd(before, WORDMARK), lumstd(out, WORDMARK))
    REPORT['title_menu_lum_std'] = '%s before, %s after' % (lumstd(before, MENU), lumstd(out, MENU))
    REPORT['title_trunk_px'] = 'trunk %d px wide at y 60, %d at y 112; fork at y %d; crown to x 298; old Tower 162 px' % (
        2 * thw(60), 2 * thw(112), fork)

    # guides: calm boxes and the column the taller Tower will run up through
    g = out.copy()
    gp = g.load()
    pale = hx('f5d9a8')
    for (x0, y0, x1, y1) in (WORDMARK, MENU):
        for x in range(x0, x1):
            if x % 3 == 0:
                put(gp, W, H, x, y0, pale)
                put(gp, W, H, x, y1 - 1, pale)
        for y in range(y0, y1):
            if y % 3 == 0:
                put(gp, W, H, x0, y, pale)
                put(gp, W, H, x1 - 1, y, pale)
    for y in range(0, 12):
        if y % 2 == 0:
            put(gp, W, H, 306, y, pale)
            put(gp, W, H, 358, y, pale)
    for k in range(4):
        put(gp, W, H, 332 - k, 1 + k, pale)
        put(gp, W, H, 332 + k, 1 + k, pale)
    text(g, (94, 41), 'WORDMARK CALM', pale, shadow=hx('0b0e11'))
    text(g, (25, 187), 'MENU CALM', pale, shadow=hx('0b0e11'))
    text(g, (342, 2), 'TALLER', pale, shadow=hx('0b0e11'))
    text(g, (342, 11), 'TOWER', pale, shadow=hx('0b0e11'))
    text(g, (342, 20), 'GOES UP', pale, shadow=hx('0b0e11'))
    save(g, 'title_guides')


# ---------------------------------------------------------------- vista
VBG = set(hx(c) for c in ['56708e', '6a84a0', '879db0', 'a9b5ba', 'cdc6b4', '93a3b2', 'ead0a6', 'e4cba6',
                          'f0d59f', 'f7e3b5', 'a3b0ae', 'b8c2bc', 'a4b1af', 'afbab7'])
VLOW = set(hx(c) for c in ['7f9467', '93a77a', 'b1bea0', 'a5b295'])


def mock_vista():
    src = Image.open(SHOTS + '13_road_vista.png').convert('RGB')
    base = src.resize((384, 216), Image.NEAREST)
    W, H = base.size
    bp = base.load()
    lay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    lp = lay.load()
    C = lambda s: hx(s) + (255,)
    # dawn haze: hazy blue-green-greys between the near willows and the sky
    # (two new darks for the vista slot, 4a5c5c and 3c4b4b; the rest are dawn palette colours)
    DEEP, BODY, LIT, RIM, WARM = '3c4b4b', '4a5c5c', '596d6f', '7e9191', 'c1ac88'
    TR = [C(DEEP), C(BODY), C(LIT), C(RIM)]
    fork = 56

    def tcx(y):
        return 138 + (128 - y) * 0.04 + 2 * math.sin(y / 17.0)

    def thw(y):
        return 33 + (y - 44) * 0.22 + max(0, y - 116) ** 2 * 0.03

    for y in range(fork - 4, 134):
        c, hw = tcx(y), thw(y)
        L, R = c - hw, c + hw
        for x in range(int(L), int(R) + 1):
            u = (x - L) / (R - L)
            k = 0 if u < 0.05 else (1 if u < 0.36 else (2 if u < 0.76 else 3))
            n = avn(x, y, 3.0, 26.0, 23)
            if abs(n - 0.5) < 0.05:
                k -= 1
            elif 0.05 <= n - 0.5 < 0.09 and u > 0.4:
                k += 1
            col = TR[max(0, min(3, k))]
            if u > 0.97:
                col = C(WARM)
            lp[x, y] = col
    for y in range(fork - 2, fork + 6):
        for x in range(int(tcx(y) - 6 + (y - fork)), int(tcx(y) + 6 - (y - fork)) + 1):
            lp[x, y] = TR[0]
    limbs = [
        ([(114, 60), (98, 42), (76, 22), (54, -4)], 26, 16),
        ([(132, 58), (130, 36), (126, 12), (122, -8)], 22, 14),
        ([(152, 60), (166, 40), (184, 20), (200, -4)], 22, 14),
        ([(164, 66), (190, 54), (214, 42), (234, 32)], 14, 6),
    ]
    for i, (pts, w0, w1) in enumerate(limbs):
        stamp_root(lp, W, H, pts, w0, w1, TR, light=(1.0, 0.4), streak_seed=60 + i)

    def edge(x):
        if x <= 190:
            return 52 + 6 * math.sin(x / 17.0) + 3 * math.sin(x / 6.3 + 2)
        return 52 - (x - 190) * 0.62 + 2 * math.sin(x / 4.0)

    incrown, clumps = crown_field(W, H, edge, 240, 12, (-6, 242))
    holes = [(222, 34, 2), (232, 26, 2), (206, 44, 2), (236, 18, 1)]
    for y in range(H):
        for x in range(W):
            if not incrown(x, y):
                continue
            if any((x - a) ** 2 + (y - b) ** 2 <= r * r for (a, b, r) in holes):
                continue
            col = BODY
            if not incrown(x, y + 1):
                col = WARM if x > 200 else RIM
            elif not incrown(x, y + 2):
                col = LIT
            elif not incrown(x + 1, y) and x > 150:
                col = RIM
            else:
                # leaf masses: each lobe lit on its lower right (dawn from the east), a dark seam above it
                for (cx, cy, r) in clumps:
                    dd = (x - cx) ** 2 + (y - cy) ** 2
                    if dd <= r * r:
                        if (r - 1.2) ** 2 < dd and y > cy + r * 0.3 and x > cx:
                            col = LIT
                        break
                else:
                    if vn(x, y, 12, 8) > 0.76:
                        col = DEEP
            lp[x, y] = C(col)
    for x in range(140, 238, 3):
        if hn(x, 9, 6) < 0.4:
            continue
        n = 3 + int(hn(x, 8, 6) * 9)
        y0 = int(edge(x)) - 2
        for k in range(n):
            if y0 + k >= 0:
                lp[x, y0 + k] = C(LIT if k < n - 1 else RIM)
    bumps = [(66, 7, 22), (100, 15, 18), (180, 16, 17), (212, 9, 20), (240, 4, 14)]

    def B(x):
        return 124 - sum(h * math.exp(-((x - c) / w) ** 2) for c, h, w in bumps)

    for x in range(36, 262):
        top = int(round(B(x)))
        falling = B(x + 1) > B(x - 1)
        for y in range(top, 134):
            if lay.getpixel((x, y))[3]:
                continue
            col = BODY
            if y == top:
                col = WARM if falling else LIT
            elif abs(avn(x, y, 3.0, 12.0, 5) - 0.5) < 0.05:
                col = DEEP
            lp[x, y] = C(col)
    made = tiny_trees(lp, W, H, B, (40, 98), 41, (C(DEEP), C(BODY), C(RIM)), sun_left=False, hmin=3, hmax=6)
    made += tiny_trees(lp, W, H, B, (182, 258), 42, (C(DEEP), C(BODY), C(RIM)), sun_left=False, hmin=3, hmax=6)

    def protected(x, y):
        c = bp[x, y]
        if c in VBG:
            return False
        if c in VLOW and y < 128:
            return False
        return True

    out = base.copy()
    op = out.load()
    for y in range(H):
        for x in range(W):
            a = lp[x, y]
            if a[3] and not protected(x, y):
                op[x, y] = a[:3]
    for (lx, ly, flip) in [(176, 104, 0), (204, 118, 1), (150, 134, 0), (232, 128, 1)]:
        put(op, W, H, lx, ly, hx('e4bd6c'))
        put(op, W, H, lx + 1, ly + flip, hx('b18956'))
    draw_leaf(out, 152, 156, 16, 0.25, shadow_k=(0.72, 0.74, 0.8))
    save(out, 'vista')
    REPORT['vista_trunk_px'] = 'trunk %d px wide at y 64, %d at y 126; fork at y %d; crown to x 240; crook x 250 to 272; old Tower 176 px; tiny trees %d to %d px' % (
        2 * thw(64), 2 * thw(126), fork, min(made), max(made))


# ---------------------------------------------------------------- base (arriving at the tree)
BP = {k: hx(k) for k in [
    '2d3729', '45502d', '565b40', '73734d', '8c8466', '9b876c', 'b79b75', 'c9b38e',  # bark ramp (dawn)
    '23180e', '3f2a19', '5d4b34',                                                   # cleft, tree trunks
    '3d542b', '4b6731', '59753c', '6f8455', '908940',                               # moss and leaves
    'a0adb0', 'abc2d3', 'c2d4df', '7f9394', '7e9191', '758789', '596d6f',           # haze and mist
    'e4bd6c', 'b18956', '886346']}                                                  # leaf light
RAMP = ['2d3729', '45502d', '565b40', '73734d', '8c8466', '9b876c', 'b79b75', 'c9b38e']


def mock_base():
    W, H = 384, 216
    img = Image.new('RGB', (W, H), BP['a0adb0'])
    p = img.load()
    # far haze: the forest beyond, lit through the crown far above
    for y in range(H):
        for x in range(W):
            c = 'c2d4df' if y < 18 else ('abc2d3' if y < 46 else ('a0adb0' if y < 90 else '7f9394'))
            if 30 < y < 170 and vn(x, y * 1.4, 10, 61) > 0.56:
                c = '7e9191' if y < 110 else '758789'
            p[x, y] = BP[c]

    def L(y):
        return 40 - 0.0014 * y * y + 2 * math.sin(y / 17.0)

    def R(y):
        return 346 + 0.0014 * y * y + 2 * math.sin(y / 23.0 + 1)

    # trunk: cylinder light from the right, furrows from stretched noise so they wander, split and join
    for y in range(0, 190):
        l, r = L(y), R(y)
        for x in range(max(0, int(l)), min(W, int(r) + 1)):
            u = (x - l) / (r - l)
            u2 = u + 0.06 * (vn(x, y, 16, 72) - 0.5)
            t = 1 if u2 < 0.06 else 2 if u2 < 0.28 else 3 if u2 < 0.52 else 4 if u2 < 0.74 else 5 if u2 < 0.9 else 6 if u2 < 0.975 else 4
            n1 = avn(x, y, 4.0, 40.0, 70)
            n2 = avn(x + 500, y, 6.0, 55.0, 71)
            if abs(n1 - 0.5) < 0.032 or abs(n2 - 0.5) < 0.022:
                t -= 2
            elif (0.032 <= n1 - 0.5 < 0.06) and t >= 3:
                t += 1
            elif abs(avn(x, y, 22.0, 2.4, 73) - 0.5) < 0.018:
                t -= 1
            if vn(x, y, 30, 74) > 0.74:
                t -= 1
            t = max(0, min(7, t))
            col = RAMP[t]
            if y > 50 and u < 0.45 and vn(x, y, 9, 75) > 0.69:
                col = '3d542b' if u < 0.25 else '4b6731'
            elif u > 0.55 and vn(x, y, 7, 76) > 0.8:
                col = '59753c'
            p[x, y] = BP[col]
    # two old branch scars, high up
    for (bx, by, rx, ry) in [(104, 46, 5, 7), (292, 70, 4, 6)]:
        for y in range(by - ry - 1, by + ry + 3):
            for x in range(bx - rx - 1, bx + rx + 2):
                d = ((x - bx) / float(rx)) ** 2 + ((y - by) / float(ry)) ** 2
                if d <= 1:
                    p[x, y] = BP['2d3729' if d < 0.55 else '45502d']
                elif d <= 1.5 and y > by:
                    p[x, y] = BP['9b876c' if x > bx else '73734d']

    def poly_mask(pts):
        m = Image.new('L', (W, H), 0)
        ImageDraw.Draw(m).polygon([(int(a), int(b)) for a, b in pts], fill=255)
        return m.load()

    def crest_y(crest, x):
        for i in range(len(crest) - 1):
            (x0, y0), (x1, y1) = crest[i], crest[i + 1]
            if min(x0, x1) <= x <= max(x0, x1) and x1 != x0:
                return y0 + (y1 - y0) * (x - x0) / float(x1 - x0)
        return None

    tree_spots = []

    def ramp_crest(a, f, n=10, bow=0.0):
        """A concave buttress crest: steep where it leaves the trunk, flattening toward the ground."""
        pts = []
        for i in range(n + 1):
            t = i / float(n)
            x = a[0] + (f[0] - a[0]) * (t ** 0.85) + bow * math.sin(t * math.pi)
            y = a[1] + (f[1] - a[1]) * (1 - (1 - t) ** 1.8)
            pts.append((x, y))
        return pts

    def buttress(crest, faces, seed, far=False):
        """crest: points from the trunk to the ground. faces: (polygon, kind), kind 'lit' or 'shade'.
        Tone falls off with distance below the crest, so each face reads as a rounded flank."""
        segs = list(zip(crest[:-1], crest[1:]))

        def crest_dist(x, y):
            best = 1e9
            for (ax, ay), (bx, by) in segs:
                dx, dy = bx - ax, by - ay
                L2 = dx * dx + dy * dy or 1
                t = max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / L2))
                d2 = (x - ax - t * dx) ** 2 + (y - ay - t * dy) ** 2
                if d2 < best:
                    best = d2
            return best ** 0.5

        for poly, kind in faces:
            m = poly_mask(crest + poly)
            for y in range(H):
                for x in range(W):
                    if not m[x, y]:
                        continue
                    d = crest_dist(x, y)
                    d += 4 * (vn(x, y, 10, seed + 5) - 0.5)
                    if kind == 'lit':
                        t = 7 if d < 1 else 6 if d < 3 else 5 if d < 12 else 4 if d < 34 else 3
                    else:
                        t = 3 if d < 2 else 2 if d < 26 else 1
                    fur = (d + 3 * math.sin(x / 9.0 + seed) + 2 * math.sin(x / 3.7)) % 9
                    if fur < 1.0 and d > 3:
                        t -= 1
                    if far:
                        t = min(t, 4)
                    col = RAMP[max(0, min(7, t))]
                    if 1 <= d < 5 and vn(x, y, 5, seed + 1) > 0.4:
                        col = '59753c' if kind == 'lit' else '4b6731'
                    elif kind == 'lit' and d > 6 and vn(x, y, 7, seed + 2) > 0.7:
                        col = '6f8455' if d < 20 else '59753c'
                    elif kind == 'shade' and d > 6 and vn(x, y, 7, seed + 3) > 0.66:
                        col = '3d542b'
                    p[x, y] = BP[col]
        for i in range(len(crest) - 1):
            (x0, y0), (x1, y1) = crest[i], crest[i + 1]
            steps = int(max(abs(x1 - x0), abs(y1 - y0)))
            for s in range(0, steps, 1):
                f = s / float(max(1, steps))
                tree_spots.append((x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, i / float(len(crest) - 1) + f / (len(crest) - 1), far))

    # the two sideways buttresses, behind
    BLc = ramp_crest((78, 64), (-30, 172), bow=-4)
    buttress(BLc, [([(-30, 216), (104, 216), (100, 110)], 'shade')], 3, far=True)
    BRc = ramp_crest((310, 58), (420, 168), bow=4)
    buttress(BRc, [([(420, 216), (288, 216), (294, 110)], 'lit')], 5, far=True)
    # mist pooled in the far valleys, behind the near buttresses
    for x in range(W):
        if 168 < x < 240:
            continue  # the central valley is the cleft, no mist there
        top = 146 + 8 * vn(x, 0, 24, 85) + 3 * math.sin(x / 9.0)
        for y in range(int(top), 200):
            p[x, y] = BP['abc2d3' if y < top + 1 else ('a0adb0' if y < top + 22 else '7f9394')]
    # the cleft between the two near buttresses: the way in (dungeon hook, proposal)
    for y in range(112, 186):
        hw = 4 + (y - 112) * 0.3
        sway = 2 * math.sin(y / 9.0)
        for x in range(int(204 - hw + sway), int(204 + hw + sway) + 1):
            d = abs(x - 204 - sway) / max(hw, 1)
            p[x, y] = BP['23180e' if d < 0.72 else ('3f2a19' if d < 0.9 else '2d3729')]
    for k in range(10):
        x = 197 + k * 2 + int(hn(k, 1, 81) * 2)
        n = 5 + int(hn(k, 2, 81) * 22)
        for j in range(n):
            if 116 + j < 182:
                p[x, 116 + j] = BP['5d4b34' if j < n - 1 else '73734d']
    # the two near buttresses that the root road runs between
    BCLc = ramp_crest((162, 88), (40, 230), bow=-6)
    buttress(BCLc, [([(-4, 230), (40, 176), (96, 128), (144, 96)], 'shade'),
                    ([(146, 230), (176, 186), (184, 126)], 'lit')], 7)
    BCRc = ramp_crest((246, 86), (356, 230), bow=6)
    buttress(BCRc, [([(262, 230), (226, 186), (222, 124)], 'shade'),
                    ([(400, 230), (360, 178), (316, 126), (268, 92)], 'lit')], 9)

    # full-size forest trees growing on the buttresses: their size against the trunk is the scale cue
    def tree(tx, ty, h, seed, faded=False):
        tw = 1 if h < 20 else 2
        trunk_h = max(2, int(h * 0.32))
        for y in range(int(ty) - trunk_h, int(ty) + 1):
            for x in range(int(tx), int(tx) + tw):
                put(p, W, H, x, y, BP['3f2a19' if x == int(tx) else '5d4b34'])
        n = 2 + int(h / 9)
        for k in range(n):
            r = h * (0.2 + 0.1 * hn(k, seed, 87))
            cx = tx + (hn(k, seed + 1, 87) - 0.5) * h * 0.45
            cy = ty - trunk_h - r * 0.7 - k * h * 0.12
            for y in range(int(cy - r), int(cy + r) + 1):
                for x in range(int(cx - r), int(cx + r) + 1):
                    dx, dy = x - cx, y - cy
                    if dx * dx + dy * dy <= r * r:
                        s = (dx * 0.8 - dy * 0.6) / max(r, 1)
                        col = '59753c' if s > 0.4 else ('4b6731' if s > -0.25 else ('3d542b' if s > -0.75 else '2d3729'))
                        if s > 0.7 and hn(x, y, 88) > 0.5:
                            col = '6f8455'
                        if faded:
                            col = {'59753c': '7e9191', '4b6731': '758789', '3d542b': '596d6f', '2d3729': '596d6f', '6f8455': 'a0adb0'}[col]
                        put(p, W, H, x, y, BP[col])

    placed = []
    sizes_drawn = []
    for (x, y, f, far) in tree_spots:
        if f < 0.16 or 182 < x < 228 or y > 204:
            continue
        if vn(x, y, 22, 90) < 0.4:  # leave gaps, so they read as groves, not an avenue
            continue
        if any(abs(x - a) < 9 and abs(y - b) < 9 for a, b in placed):
            continue
        if hn(int(x), int(y), 89) > 0.45:
            continue
        h = (9 + f * 10) if far else (12 + f * 18) * (0.8 + 0.4 * hn(int(x), 1, 91))
        placed.append((x, y))
        sizes_drawn.append(int(h))
        tree(x, y + 1, int(h), int(x), faded=far)
    REPORT['base_trees'] = '%d trees, %d to %d px tall' % (len(placed), min(sizes_drawn), max(sizes_drawn))
    # the root road: a lateral root you walk along into the cleft
    for y in range(176, H):
        f = (y - 176) / 40.0
        c = 205 - 12 * f * f
        hw = 7 + 46 * f ** 1.25
        for x in range(int(c - hw), int(c + hw) + 1):
            v = (x - c) / hw
            if abs(v) > 1:
                continue
            col = '9b876c' if v > 0.25 else ('8c8466' if v > -0.45 else '73734d')
            if abs(v) > 0.9:
                col = '45502d'
            if -0.12 < v < 0.12 and hn(x, y, 93) > 0.55:
                col = 'b79b75'
            if abs(avn(x, y, 2.0, 18.0, 94) - 0.5) < 0.05 and abs(v) < 0.85:
                col = {'9b876c': '8c8466', '8c8466': '73734d', '73734d': '565b40'}.get(col, col)
            p[x, y] = BP[col]
    # ferns in the near corners
    for (bx, by, n, side) in [(14, 218, 7, 1), (46, 220, 5, 1), (370, 218, 7, -1), (338, 220, 5, -1)]:
        for k in range(n):
            ang = -math.pi / 2 + side * (0.2 + k * 0.19)
            ln_ = 16 + int(hn(k, bx, 95) * 14)
            for j in range(ln_):
                t = j / float(ln_)
                x = bx + math.cos(ang) * j + side * t * t * 10
                y = by + math.sin(ang) * j + t * t * 12
                put(p, W, H, int(x), int(y), BP['4b6731'])
                if j % 2 == 0 and 2 < j < ln_ - 1:
                    for q in (1, 2, 3):
                        if q <= 3 - t * 2:
                            put(p, W, H, int(x) + q, int(y) - q + 1, BP['6f8455' if q == 1 else '59753c'])
                            put(p, W, H, int(x) - q, int(y) - q + 1, BP['59753c' if q == 1 else '4b6731'])
    # birds against the lit bark
    for (bx, by) in [(250, 40), (262, 34), (273, 45), (92, 70)]:
        for (dx, dy) in [(-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)]:
            put(p, W, H, bx + dx, by + dy, BP['2d3729'])
    # leaves of the great tree: one the size of a starter near the pair, smaller ones farther off
    draw_leaf(img, 278, 160, 24, 0.55, shadow_k=(0.7, 0.72, 0.78))
    draw_leaf(img, 92, 112, 10, -0.4)
    draw_leaf(img, 326, 98, 8, 0.9)
    # two stage 1 starters on the root road, looking up at the tree
    sizes = {}
    for name, facing, footx, footy in [('rimefin', 'ne', 182, 208), ('kithflare', 'nw', 228, 206)]:
        s = Image.open('%s%s/town/%s.png' % (SPR, name, facing)).convert('RGBA')
        s = s.crop(s.getbbox())
        sizes[name] = s.size
        img.paste(s, (footx - s.size[0] // 2, footy - s.size[1]), s)
    save(img, 'base')
    REPORT['base'] = {'starters_px_wh': sizes, 'trunk_px_at_top': int(R(0) - L(0)), 'trunk_px_at_y100': int(R(100) - L(100)),
                      'colours': ncol(img)}


# ---------------------------------------------------------------- influence sheet
ROOTC = {k: hx(k) for k in ['c49b69', 'b06b3d', '663f23', '3f2716', '23180e', '59753c', '4b6731', 'c7a378']}


def shade(c, k=(0.58, 0.66, 0.8)):
    return (int(c[0] * k[0]), min(255, int(c[1] * k[1]) + 2), min(255, int(c[2] * k[2]) + 8))


def grassy(c):
    return c[1] > c[0] + 4 and c[1] >= c[2]


def root_topdown(img, pts, w, can_paint, mortar=None, seed=0):
    """A great root lying in the ground in the game's top-down 3/4 view: lit top, dark face, shadow."""
    W, H = img.size
    p = img.load()
    path = catmull(pts, 16)
    xs = [q[0] for q in path]
    ys = [q[1] for q in path]
    x0, x1 = int(min(xs) - w), int(max(xs) + w)
    y0, y1 = int(min(ys) - w), int(max(ys) + w + 5)
    orig = img.copy().load()
    for y in range(max(0, y0), min(H, y1)):
        for x in range(max(0, x0), min(W, x1)):
            if not can_paint(x, y):
                continue
            best, bi, sv = 1e9, 0, 0
            for i in range(len(path) - 1):
                ax, ay = path[i]
                bx, by = path[i + 1]
                dx, dy = bx - ax, by - ay
                L2 = dx * dx + dy * dy or 1
                t = max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / L2))
                px_, py_ = ax + t * dx, ay + t * dy
                d2 = (x - px_) ** 2 + (y - py_) ** 2
                if d2 < best:
                    nx, ny = -dy, dx
                    if ny < 0:
                        nx, ny = -nx, -ny
                    best, bi = d2, i
                    sv = ((x - px_) * nx + (y - py_) * ny) / (L2 ** 0.5)
            d = best ** 0.5
            half = w / 2.0
            if d <= half:
                v = sv
                if v < -half + 1.0:
                    col = ROOTC['3f2716']
                elif v < -half + 2.2:
                    col = ROOTC['c49b69']
                elif v < 0.25 * half:
                    col = ROOTC['b06b3d']
                    if hn(bi // 3, int(v + 20), seed + 1) > 0.66:
                        col = ROOTC['c49b69']
                    if vn(x, y, 4, seed + 2) > 0.72:
                        col = ROOTC['59753c']
                elif v < half - 1.2:
                    col = ROOTC['663f23']
                else:
                    col = ROOTC['3f2716']
                if abs(v) > half - 1.5 and hn(x, y, seed + 3) > 0.8:
                    col = orig[x, y]  # turf lip over the edge
                p[x, y] = col
            elif d <= half + 3 and sv > 0:
                p[x, y] = shade(orig[x, y])
            elif mortar and d <= half + 1:
                p[x, y] = mortar


def mock_influence():
    frames = []
    # (a) Tower Rise west lane: root ridge across the lane, evening shade with sunflecks, a fallen leaf
    a = Image.open(SHOTS + '05c_rise_side_west_col2_row3.png').convert('RGB').resize((384, 216), Image.NEAREST)
    ap = a.load()
    orig = a.copy().load()
    for y in range(36, 160):
        for x in range(0, 205):
            c = orig[x, y]
            if not grassy(c):
                continue
            edge = 128 - 24 * vn(x, 0, 30, 101) - x * 0.1 + 6 * math.sin(x / 7.0)
            if y < edge and vn(x, y, 14, 102) > 0.33:
                ap[x, y] = shade(c)
                if vn(x, y, 3, 103) > 0.82:
                    ap[x, y] = c
    root_topdown(a, [(124, 224), (100, 208), (66, 194), (30, 182), (-8, 172)], 22,
                 lambda x, y: grassy(orig[x, y]) or x < 100, seed=110)
    draw_leaf(a, 46, 98, 28, 0.35, shadow_k=(0.6, 0.66, 0.78))
    draw_leaf(a, 160, 48, 18, -0.8, shadow_k=(0.6, 0.66, 0.78))
    frames.append((a, 'TOWER RISE: ROOT RIDGE, EVENING SHADE, A LEAF'))

    # (b) Tower doors: leaves the size of a starter drift in and settle on the steps
    b = Image.open(SHOTS + '02_rise_door_lean.png').convert('RGB').resize((384, 216), Image.NEAREST)
    draw_leaf(b, 234, 200, 28, 0.2, shadow_k=(0.7, 0.72, 0.8))
    draw_leaf(b, 126, 62, 20, 1.0, shadow_k=(0.7, 0.72, 0.8))
    draw_leaf(b, 262, 112, 16, -0.5, shadow_k=(0.7, 0.72, 0.8))
    frames.append((b, 'TOWER DOORS: STARTER-SIZED LEAVES, A LEAF HUSH'))

    # (c) Street crossroads: a root hump the cobbles go around, the tree's evening shade edge
    c = Image.open(SHOTS + '06_street_wayline.png').convert('RGB').resize((384, 216), Image.NEAREST)
    cp = c.load()
    oc = c.copy().load()
    for y in range(36, 216):
        for x in range(384):
            line = 74 + x * 0.3 + 9 * math.sin(x / 11.0) + 6 * vn(x, y, 5, 120)
            if y < line - 3 or (y < line + 2 and vn(x, y, 2, 121) > 0.55):
                if not (x > 300 and y > 175):
                    cp[x, y] = shade(oc[x, y], (0.64, 0.7, 0.86))
    root_topdown(c, [(-8, 126), (52, 136), (118, 150), (180, 166), (232, 196), (252, 224)], 22,
                 lambda x, y: not (x > 300 and y > 175) and not (250 <= x <= 282 and 128 <= y <= 176), mortar=hx('5d4b34'), seed=130)
    draw_leaf(c, 280, 118, 18, 0.4, shadow_k=(0.7, 0.72, 0.8))
    draw_leaf(c, 62, 70, 14, -0.6, shadow_k=(0.7, 0.72, 0.8))
    draw_leaf(c, 214, 120, 28, 0.1, shadow_k=(0.7, 0.72, 0.8))
    frames.append((c, 'STREET: ROOT HUMP IN THE COBBLES, EVENING SHADE'))

    # (d) Old Ferry Ward: a root comes down the bluff wall and dives into the river; leaves ride the current
    d = Image.open(SHOTS + '07_ferry_ward_quiet_wayline.png').convert('RGB').resize((384, 216), Image.NEAREST)
    dp = d.load()
    od = d.copy().load()
    lay = Image.new('RGBA', (384, 216), (0, 0, 0, 0))
    lp = lay.load()
    ramp = [ROOTC['3f2716'] + (255,), ROOTC['663f23'] + (255,), ROOTC['b06b3d'] + (255,), ROOTC['c49b69'] + (255,)]
    own = stamp_root(lp, 384, 216, [(42, -14), (64, 22), (58, 60), (78, 96), (74, 124), (88, 146)], 36, 18, ramp,
                     light=(-0.7, -0.6), streak_seed=140, outline=ROOTC['3f2716'] + (255,))
    water_y = 140

    def rootlet(x0, y0, dirx, length, seed):
        """A thin rootlet crawling along a mortar line, with a slight droop and wiggle."""
        pts = []
        for j in range(length):
            pts.append((x0 + dirx * j, y0 + j * 0.18 + 1.2 * math.sin(j / 3.0 + seed)))
        for j, (x, y) in enumerate(pts):
            xi, yi = int(round(x)), int(round(y))
            if 0 <= xi < 384 and 0 <= yi < water_y and not lp[xi, yi][3]:
                dp[xi, yi] = ROOTC['b06b3d'] if (j + seed) % 4 else ROOTC['c49b69']
                if j < length * 0.6 and 0 <= yi + 1 < water_y and not lp[xi, yi + 1][3]:
                    dp[xi, yi + 1] = ROOTC['663f23']
                if 0 <= yi + 2 < water_y and not lp[xi, yi + 2][3]:
                    dp[xi, yi + 2] = shade(od[xi, yi + 2], (0.75, 0.75, 0.8))
            if j > 4 and hn(j, seed, 143) > 0.86:  # a side hair
                for q in range(1, 4):
                    xx, yy = xi + dirx * q, yi + q
                    if 0 <= xx < 384 and 0 <= yy < water_y and not lp[xx, yy][3]:
                        dp[xx, yy] = ROOTC['663f23']
    water_cut = {}
    for y in range(216):
        for x in range(384):
            q = lp[x, y]
            if not q[3]:
                continue
            col = q[:3]
            if y >= water_y:
                # below the waterline the root darkens to river teal and ends raggedly
                cut = water_cut.setdefault(x, water_y + 3 + int(hn(x, 0, 144) * 7))
                if y > cut:
                    continue
                col = hx('07515c') if q[:3] != ROOTC['3f2716'] else hx('00313a')
            elif vn(x, y, 4, 141) > 0.76 and q[:3] in (ROOTC['b06b3d'], ROOTC['c49b69']):
                col = ROOTC['59753c']
            dp[x, y] = col
    for i, (x0, y0, dirx, n) in enumerate([(46, 26, -1, 30), (42, 56, -1, 22), (78, 34, 1, 34), (86, 70, 1, 22),
                                            (64, 100, -1, 18), (88, 112, 1, 26), (66, 128, -1, 22)]):
        rootlet(x0, y0, dirx, n, i * 3 + 1)
    for (x0, dirx, n) in [(76, -1, 9), (86, 1, 11), (80, 1, 7)]:
        for j in range(n):
            put(dp, 384, 216, x0 + dirx * j, water_y + 4 + j // 2, hx('07515c'))
    # mortar lips where the wall was built around the root
    for y in range(0, water_y):
        for x in range(1, 383):
            if not lp[x, y][3] and (lp[x - 1, y][3] or lp[x + 1, y][3]) and hn(x, y, 142) > 0.3:
                dp[x, y] = ROOTC['c7a378']
    for (rx, ry, n) in [(76, 141, 10), (98, 143, 8), (84, 147, 12), (70, 152, 7)]:
        for j in range(n):
            put(dp, 384, 216, rx + j, ry, hx('6fb5a6'))
    for (lx, ly, L, ang) in [(150, 186, 14, 0.3), (226, 202, 12, -0.2), (186, 170, 10, 0.8)]:
        draw_leaf(d, lx, ly, L, ang)
        for j in range(L - 2):
            put(dp, 384, 216, lx - L // 2 + j + 2, ly + 4, hx('6fb5a6'))
    frames.append((d, 'FERRY WARD: A ROOT DIVES INTO THE RIVER'))

    sheet = Image.new('RGB', (768, 2 * (216 + 12)), hx('23180e'))
    for i, (im, label) in enumerate(frames):
        x0, y0 = (i % 2) * 384, (i // 2) * 228
        sheet.paste(im, (x0, y0))
        text(sheet, (x0 + 4, y0 + 217), label, hx('f5d9a8'))
    save(sheet, 'influence')
    REPORT['influence_colours'] = '%d (the in-game screenshots already carry about 30k each)' % ncol(sheet)


# ---------------------------------------------------------------- map
def mock_map():
    W, H = 384, 216
    S = 3.0  # tiles per pixel
    DX, DY = 240, 150  # the Tower doors
    TREE = (-40, -135)  # tiles from the doors: 135 north, 40 west (about 141 tiles, north by north-west)
    TX, TY = DX + TREE[0] / S, DY + TREE[1] / S
    img = Image.new('RGB', (W, H), hx('9f946d'))
    p = img.load()
    pale = hx('f5d9a8')
    sh = hx('0b0e11')

    def river_c(x):
        return 167.5 + 4 * math.sin((x - 240) / 40.0) + 1.5 * math.sin((x - 240) / 13.0)

    for y in range(H):
        for x in range(W):
            wx, wy = (x - DX) * S, (y - DY) * S
            d = math.hypot(wx - TREE[0], wy - TREE[1])
            edge = 400 + 70 * (vn(x, y, 14, 201) - 0.5)
            col = '9f946d' if vn(x, y, 8, 202) < 0.6 else '908940'
            if d < edge:
                col = '3d542b'
                if vn(x, y, 3, 203) > 0.62:
                    col = '4b6731'
                elif hn(x, y, 204) > 0.9:
                    col = '2d3729'
                if d < 130:
                    col = '2d3729' if vn(x, y, 4, 205) < 0.7 else '3d542b'
            if -60 < wx < 50 and -16 < wy < 44 and vn(x, y, 5, 206) > 0.22:
                col = '9f946d'
            rc = river_c(x)
            if abs(y - rc) <= 6:
                col = '12837f' if abs(y - rc) < 5 else 'c7a378'
                if abs(y - rc) < 5 and hn(x, y, 207) > 0.9:
                    col = '2d9e9f'
            p[x, y] = hx(col)
    for k in range(720):
        a = k / 720.0 * 2 * math.pi
        x, y = TX + 130 / S * math.sin(a), TY - 130 / S * math.cos(a)
        if k % 6 < 3:
            put(p, W, H, int(round(x)), int(round(y)), hx('a0adb0'))
    for a_deg in [20, 75, 130, 160, 190, 250, 310]:
        a = math.radians(a_deg)
        for j in range(0, 33):
            r = 45 / S + j * (50 / S) / 32.0
            wdt = 2 if j < 20 else 1
            x, y = TX + r * math.sin(a), TY - r * math.cos(a)
            for q in range(-wdt, wdt + 1):
                put(p, W, H, int(x + q * math.cos(a)), int(y + q * math.sin(a)), hx('b06b3d' if q == 0 else '663f23'))
    for y in range(H):
        for x in range(W):
            d = math.hypot(x - TX, y - TY)
            if d <= 45 / S:
                col = '663f23' if int(d) % 3 else '7c4a26'
                if d > 45 / S - 1.2 and (x - TX) + (y - TY) > 0:
                    col = 'c49b69'
                if d < 1.5:
                    col = '3f2716'
                p[x, y] = hx(col)

    def tip(a_deg, r_tiles=95):
        a = math.radians(a_deg)
        return (TX + r_tiles / S * math.sin(a), TY - r_tiles / S * math.cos(a))

    def T(tx, ty):
        return (DX + tx / S, DY + ty / S)

    roots = [
        ([tip(160), (233.5, 141), (234.5, 147.5), T(-8, 0)], 'c49b69', 2),
        ([tip(190), (227, 144), (231, 154), T(-2, 36)], 'c49b69', 2),
        ([tip(130), (256, 140), (252, 152), T(26, 14)], 'c49b69', 2),
        ([tip(250), (196, 140), (186, 152), (181, 160)], 'c49b69', 2),
        ([tip(20), (246, 50), (262, 20), (270, 2)], '8c6545', 1),
        ([tip(75), (290, 88), (330, 96), (372, 86)], '8c6545', 1),
        ([tip(310), (180, 70), (140, 52), (104, 40)], '8c6545', 1),
        ([tip(250), (170, 128), (130, 124), (90, 132)], '8c6545', 1),
        ([tip(130), (282, 132), (316, 140), (352, 150)], '8c6545', 1),
        ([tip(20), (226, 40), (214, 12)], '8c6545', 1),
    ]
    for pts, col, wdt in roots:
        path = catmull(pts, 20)
        n = len(path)
        for i, (x, y) in enumerate(path):
            ww = wdt if i < n * 0.7 else 1
            for q in range(ww):
                put(p, W, H, int(x) + q, int(y), hx(col))

    def rect(t0, t1, fill, edge):
        x0, y0 = T(*t0)
        x1, y1 = T(*t1)
        for y in range(int(y0), int(math.ceil(y1))):
            for x in range(int(x0), int(math.ceil(x1))):
                b = x in (int(x0), int(math.ceil(x1)) - 1) or y in (int(y0), int(math.ceil(y1)) - 1)
                put(p, W, H, x, y, hx(edge if b else fill))
    rect((-12, -8), (14, 6), 'e6c697', '7c4a26')
    rect((-46, 6), (10, 22), 'e6c697', '7c4a26')
    rect((10, 7), (40, 21), 'e6c697', '7c4a26')
    rect((-6, 22), (28, 38), 'e6c697', '7c4a26')
    for (x, y, c) in [(239, 148, 'c49b69'), (240, 148, 'c49b69'), (241, 148, 'c49b69'), (240, 147, 'fbd490'),
                      (239, 149, '23180e'), (240, 149, 'c49b69'), (241, 149, '23180e')]:
        put(p, W, H, x, y, hx(c))
    rr = catmull([T(-8, 0), (234, 144), (234, 138), tip(165, 70)], 14)
    for i, (x, y) in enumerate(rr):
        if i % 3 == 0:
            put(p, W, H, int(x) - 2, int(y), pale)
    for k in range(5):
        for q in range(-k, k + 1):
            put(p, W, H, 232 + q, 186 + k, pale)

    def leader(x0, y0, x1, y1):
        n = int(max(abs(x1 - x0), abs(y1 - y0)))
        for i in range(n + 1):
            f = i / float(max(1, n))
            put(p, W, H, int(x0 + (x1 - x0) * f), int(y0 + (y1 - y0) * f), pale)

    text(img, (TX + 20, TY - 30), 'THE GREAT TREE', pale, sh)
    text(img, (TX + 20, TY - 21), '90 WIDE, 300 TALL', pale, sh)
    text(img, (TX - 70, TY - 54), 'CROWN REACH 260 ACROSS', hx('c2d4df'), sh)
    text(img, (4, 4), 'FOREST, ABOUT 800 TILES ACROSS', pale, sh)
    text(img, (270, 128), 'WAYLINE TOWER', hx('fbd490'), sh)
    leader(268, 133, 242, 147)
    text(img, (262, 150), 'HIGHBANK', pale, sh)
    text(img, (150, 117), "TOWER'S ROOT", hx('e6c697'), sh)
    leader(216, 125, 233, 141)
    text(img, (138, 139), 'ROOTBANK', pale, sh)
    text(img, (138, 148), 'WARREN?', pale, sh)
    text(img, (300, 176), 'RIVER', pale, sh)
    text(img, (240, 186), 'TITLE VIEW', pale, sh)
    for k in range(6):
        put(p, W, H, 372, 4 + k, pale)
    for k in range(3):
        put(p, W, H, 372 - k, 5 + k, pale)
        put(p, W, H, 372 + k, 5 + k, pale)
    text(img, (369, 11), 'N', pale, sh)
    bx0, by0 = 300, 202
    blen = int(round(100 / S))
    for x in range(bx0, bx0 + blen + 1):
        put(p, W, H, x, by0, pale)
        put(p, W, H, x, by0 + 1, sh)
    for xx in (bx0, bx0 + blen // 2, bx0 + blen):
        for k in range(1, 4):
            put(p, W, H, xx, by0 - k, pale)
    text(img, (bx0 - 1, by0 - 14), '100 TILES', pale, sh)
    text(img, (bx0 - 1, by0 + 4), '1 PX = 3 TILES', pale, sh)

    # inset: the town at 1 px = 1 tile, showing where the roots come up
    IX, IY, IW, IH = 2, 120, 132, 94
    ox, oy = IX + 78, IY + 32
    for y in range(IY, IY + IH):
        for x in range(IX, IX + IW):
            tx, ty = x - ox, y - oy
            col = '9f946d' if vn(x, y, 6, 220) < 0.62 else '908940'
            if ty < -10 or (tx < -54 and ty < 4):
                col = '3d542b' if vn(x, y, 3, 221) < 0.6 else '4b6731'
            if math.hypot(tx - TREE[0], ty - TREE[1]) < 130:
                col = '2d3729' if vn(x, y, 3, 222) < 0.66 else '3d542b'
            if ty >= 36:
                col = '12837f' if hn(x, y, 223) < 0.92 else '2d9e9f'
            if ty == 35:
                col = 'c7a378'
            p[x, y] = hx(col)
    for k in range(1600):
        a = k / 1600.0 * 2 * math.pi
        x = ox + TREE[0] + 130 * math.sin(a)
        y = oy + TREE[1] - 130 * math.cos(a)
        if IX <= x < IX + IW and IY <= y < IY + IH and k % 8 < 4:
            p[int(x), int(y)] = hx('a0adb0')

    def irect(x0, y0, w, h, fill='e6c697', edge='7c4a26'):
        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                b = x in (x0, x0 + w - 1) or y in (y0, y0 + h - 1)
                put(p, W, H, ox + x, oy + y, hx(edge if b else fill))
    irect(-12, -8, 26, 14)
    irect(-46, 6, 56, 16)
    irect(10, 7, 30, 14)
    irect(-6, 22, 34, 14)
    irect(-5, -8, 12, 9, 'c49b69', '663f23')
    put(p, W, H, ox, oy - 7, hx('fbd490'))
    put(p, W, H, ox, oy - 1, hx('23180e'))

    def iroot(pts, wdt, col='b06b3d', top='c49b69'):
        for (x, y) in catmull(pts, 20):
            for q in range(wdt):
                put(p, W, H, ox + int(x), oy + int(y) + q, hx(top if q == 0 else col))
    iroot([(-34, -32), (-26, -14), (-16, -3), (-12, -2), (-8, 0)], 3)
    iroot([(-74, -26), (-50, -6), (-26, 12), (-10, 24), (0, 37)], 3)
    iroot([(52, -24), (36, -2), (28, 12), (20, 16)], 2)
    for (x, y) in catmull([(-26, 12), (-30, 15), (-34, 17)], 8)[::2]:
        put(p, W, H, ox + int(x), oy + int(y), hx('c49b69'))
    put(p, W, H, ox - 34, oy + 17, hx('fbd490'))
    for x in range(IX, IX + IW):
        put(p, W, H, x, IY, pale)
        put(p, W, H, x, IY + IH - 1, pale)
    for y in range(IY, IY + IH):
        put(p, W, H, IX, y, pale)
        put(p, W, H, IX + IW - 1, y, pale)
    text(img, (IX + 3, IY + 2), 'TOWN 1PX=1 TILE', pale, sh)
    text(img, (ox - 12, oy - 20), 'TOWER', pale, sh)
    text(img, (ox - 40, oy + 7), 'STREET', hx('3f2716'))
    text(img, (ox + 12, oy + 8), 'EAST', hx('3f2716'))
    text(img, (ox - 4, oy + 23), 'FERRY', hx('3f2716'))
    text(img, (ox - 58, oy + 20), 'SHRINE', pale, sh)
    save(img, 'map')
    REPORT['map'] = 'tree centre (%.1f, %.1f) px, doors (240,150), crown radius %.1f px, forest radius %.1f px' % (TX, TY, 130 / S, 400 / S)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    mock_title()
    mock_vista()
    mock_base()
    mock_influence()
    mock_map()
    print(json.dumps(REPORT, indent=1, default=str))
