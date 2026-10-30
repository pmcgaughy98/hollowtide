"""Concept C, "horizon": the root as a road. Mocks for the great tree (working label, a proposal).

The great tree stands far north of Highbank (N 7 deg E of the Wayline Tower, about 6,600 tiles away) and is
about 480 tiles tall (16 Towers). It is so far away that it reads about the same size in every view, roughly
65 to 70 px tall at 1x, while the Tower changes size from view to view. Its root runs south to Highbank,
mostly underground, and surfaces as long mossy ridges with a worn path on top: the root road. Between the
ridges the trail keeps to the root's line, so from high up the whole thing reads as one road to the tree.

Run:  python mock_c-horizon.py   (writes *_1x.png and *_3x.png next to this file)

Pixel rules: hard edges, no anti-aliasing, nearest-neighbour scaling only. The title uses only colours already in
the highbank_title palette. The vista and the reveal hold reuse each shot's own sky ramp, with the land and root
drawn from the dawn and wayline_tower palettes. Nothing here is installed in the game.

Size math (one shared lens): a thing H tiles tall at distance d tiles shows as H * 24 * 40 / d px at 1x, where the
reveal camera (scale 1.0) sits 40 tiles from the Tower. Tower 30 tiles: title 162 px -> viewer 178 tiles away;
vista 176 px -> 164 tiles; road far layer 70 px -> 411 tiles. Tree 480 tiles at ~6,600 to 6,800 tiles -> 66 to 70 px
in all of them.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
OUT = ROOT + '/docs/design/great-tree-2026-10-27/concept_c-horizon'
BUILD = ROOT + '/docs/design/wayline-tower-2026-10-27/build'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
SCRATCH = 'C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad'


def hx(s):
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def lum(c):
    return 0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]


def noise(a, b, seed=0):
    h = ((a * 73856093) ^ (b * 19349663) ^ (seed * 83492791)) & 0xffffffff
    h = ((h ^ (h >> 13)) * 1274126177) & 0xffffffff
    return (h & 0xffff) / 65535.0


def save(img, name):
    img.save(f'{OUT}/{name}_1x.png')
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f'{OUT}/{name}_3x.png')


def load_3x(path):
    # In-game shots are exact 3x of a 384x216 frame (block test: offset 0,0 is uniform), so NEAREST picks
    # the middle pixel of each 3x3 block.
    im = Image.open(path).convert('RGB')
    return im.resize((im.width // 3, im.height // 3), Image.NEAREST)


class Ramp:
    """A sky ramp, dark to light. Tree pixels take the sky colour behind them shifted darker by one or two steps,
    so the tree always reads as a hazy silhouette a little darker than the air around it, at every height."""

    def __init__(self, cols):
        self.cols = [hx(c) for c in cols]
        self.l = [lum(c) for c in self.cols]

    def idx(self, c):
        if c in self.cols:
            return self.cols.index(c)
        L = lum(c)
        return min(range(len(self.cols)), key=lambda i: abs(self.l[i] - L))

    def get(self, i):
        return self.cols[max(0, min(len(self.cols) - 1, i))]


# ---------------------------------------------------------------------------------------------- the great tree
# Shape (proposal): a massive fluted trunk on a buttress flare, carrying five flat, lumpy shelves of crown that
# narrow toward the top, with aerial roots hanging in curtains under every shelf: a tree whose roots hang from
# the sky as well as running under the ground. Not an oak: no round dome, no single mass.
TIERS = [  # (height of shelf centre as a fraction of H, width fraction, thickness fraction, x offset fraction)
    (0.44, 1.00, 0.110, 0.00),
    (0.59, 0.84, 0.105, -0.07),
    (0.73, 0.62, 0.100, 0.08),
    (0.86, 0.40, 0.100, -0.03),
    (0.96, 0.16, 0.060, 0.03),
]
SHIFT = {'body': -1, 'rim': -1, 'shade': -2, 'curtain': -2, 'trunk': -1, 'trunk_shade': -2, 'limb': -2}


def tree_roles(cx, base_y, Ht, light=1, seed=3):
    rnd = random.Random(seed)
    R = {}

    def setp(x, y, role, ref=None):
        # ref = the rows of sky this part is judged against: a whole shelf takes one colour, darker than the
        # darkest sky band behind it, so shelves read solid instead of striped by the sky's bands
        yy = int(math.floor(y + 0.5))
        R[(int(math.floor(x + 0.5)), yy)] = (role, ref or (yy, yy))

    Wc = 1.46 * Ht
    for y in range(int(base_y - 0.9 * Ht), int(base_y) + 1):  # trunk, up inside the crown
        t = (base_y - y) / Ht
        hw = (0.10 - 0.035 * t) * Ht
        if t < 0.12:
            hw += 0.20 * Ht * ((0.12 - t) / 0.12) ** 2  # buttress flare
        for x in range(int(math.floor(cx - hw)), int(math.ceil(cx + hw)) + 1):
            u = (x - cx) / max(hw, 0.5)
            if abs(u) > 1.0:
                continue
            role = 'trunk'
            if u * light < -0.3:
                role = 'trunk_shade'
            if ((x - int(cx)) * 2 + int((base_y - y) * 0.5)) % 9 == 0 and abs(u) < 0.8:
                role = 'trunk_shade'  # spiral flutes
            if u * light > 0.78:
                role = 'warm'
            setp(x, y, role)
    shelves = [(base_y - fy * Ht, fw * Wc / 2, ft * Ht, cx + fx * Wc, rnd.random() * 6, rnd.random() * 6)
               for (fy, fw, ft, fx) in TIERS]
    for i, (yc, w, th, x0, ph, ph2) in enumerate(shelves[:4]):  # limbs out to the shelf undersides
        ys = base_y - (0.34 + 0.13 * i) * Ht
        for side in (-1, 1):
            xe, ye = x0 + side * 0.45 * w, yc + 0.15 * th
            n = int(max(abs(xe - cx), abs(ye - ys)) * 2) + 1
            for k in range(n + 1):
                a = k / n
                for d in range(max(1, int(0.025 * Ht))):
                    setp(cx + (xe - cx) * a, ys + (ye - ys) * a + d, 'limb')
    for (yc, w, th, x0, ph, ph2) in shelves:  # hanging root curtains, behind the shelves
        for x in range(int(x0 - 0.9 * w), int(x0 + 0.9 * w) + 1):
            if rnd.random() < 0.5:
                continue
            s = (x - x0) / w
            yb = yc + 0.3 * th * math.sqrt(max(0.0, 1 - s * s)) + 0.3 * th * s ** 4
            for k in range(1, int(rnd.uniform(0.02, 0.12) * Ht) + 1):
                setp(x, yb + k, 'curtain', (int(yc - 1.5 * th), int(yc + 0.6 * th)))
    for (yc, w, th, x0, ph, ph2) in shelves:
        ref = (int(yc - 1.5 * th), int(yc + 0.6 * th))
        for x in range(int(math.floor(x0 - w)), int(math.ceil(x0 + w)) + 1):
            s = (x - x0) / w
            if abs(s) > 1:
                continue
            c = math.sqrt(max(0.0, 1 - s * s))
            f = 66 / Ht
            bump = 1 + 0.3 * abs(math.sin(x * 0.7 * f + ph)) + 0.18 * abs(math.sin(x * 1.9 * f + ph2))
            ytop = yc - th * c * bump
            ybot = yc + 0.3 * th * c + 0.3 * th * s ** 4
            for y in range(int(math.floor(ytop + 0.5)), int(math.floor(ybot + 0.5)) + 1):
                role = 'body'
                if y >= ybot - max(1.0, 0.3 * th):
                    role = 'shade'
                elif y <= ytop + 1.0:
                    role = 'warm' if s * light > 0.1 else 'rim'
                setp(x, y, role, ref)
    return R


def row_sky(img, sky, x0, x1):
    """The most common sky colour in each row (no dither), carried down past the skyline."""
    px = img.load()
    out, last = [], None
    for y in range(img.height):
        cnt = {}
        for x in range(x0, x1):
            if px[x, y] in sky:
                cnt[px[x, y]] = cnt.get(px[x, y], 0) + 1
        if cnt:
            last = max(cnt, key=cnt.get)
        out.append(last)
    return out


def paint_tree(img, roles, ramp, allowed, warm, ref_sky):
    px = img.load()
    W, H = img.size
    box = [999, 999, -1, -1]
    for (x, y), (role, (y0, y1)) in roles.items():
        if not (0 <= x < W and 0 <= y < H) or not allowed(x, y):
            continue
        if role == 'warm':
            px[x, y] = hx(warm)
        else:
            i = min(ramp.idx(ref_sky[max(0, min(H - 1, yy))]) for yy in range(y0, y1 + 1))
            px[x, y] = ramp.get(i + SHIFT[role])
        box = [min(box[0], x), min(box[1], y), max(box[2], x), max(box[3], y)]
    return box


# ---------------------------------------------------------------------------------------------- the root road
def catmull(pts, per=60):
    P = [pts[0]] + list(pts) + [pts[-1]]
    out = []
    for i in range(len(pts) - 1):
        p0, p1, p2, p3 = P[i], P[i + 1], P[i + 2], P[i + 3]
        for k in range(per):
            t = k / per
            t2, t3 = t * t, t * t * t
            out.append(tuple(0.5 * (2 * p1[j] + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t2
                                    + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t3) for j in range(len(p1))))
    out.append(tuple(pts[-1]))
    return out


def root_tube(img, pts, humps, cols, allowed, light=(1.0, -0.3), key=None, per=80, treads=False):
    """Draw the root along pts (x, y, half-width), far end first, as a tube seen from above: shadow side, bark,
    a mossy crest and the pale worn path on top. It is above ground only inside `humps` (ranges of key(f, x, y),
    default f = 0..1 along the line); each surfaced stretch rises and dives back with a taper. Between stretches
    the trail colour (if given) keeps to the root's line on the ground."""
    px = img.load()
    W, H = img.size
    S = catmull(pts, per)
    N = len(S)
    ln = math.hypot(*light)
    L = (light[0] / ln, light[1] / ln)
    T, along = [], [0.0]
    for i in range(N):
        a, b = S[max(0, i - 1)], S[min(N - 1, i + 1)]
        tx, ty = b[0] - a[0], b[1] - a[1]
        m = math.hypot(tx, ty) or 1.0
        T.append((tx / m, ty / m))
        if i:
            along.append(along[-1] + math.hypot(S[i][0] - S[i - 1][0], S[i][1] - S[i - 1][1]))
    reff = []
    for i, (x, y, r) in enumerate(S):
        k = key(i / (N - 1), x, y) if key else i / (N - 1)
        e = 0.0
        for (a, b) in humps:
            lo, hi = min(a, b), max(a, b)
            if lo <= k <= hi:
                # blunt ends: a ridge breaks out of the turf at near full width, it does not taper to a point
                e = r * max(0.5, math.sin(math.pi * min(1.0, (k - lo) / (hi - lo))) ** 0.3)
                if treads:  # close up, a root swells and pinches; it is not a plank
                    e *= 1 + 0.12 * math.sin(along[i] / 9.0) + 0.06 * math.sin(along[i] / 4.3)
                break
        reff.append(e)

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H and allowed(x, y):
            px[x, y] = hx(c)

    if cols.get('trail'):
        for i, (x, y, r) in enumerate(S):
            if reff[i] <= 0 and i % 2 == 0:
                put(int(math.floor(x + 0.5)), int(math.floor(y + 0.5)), cols['trail'])
                if r >= 3:
                    put(int(math.floor(x + 1.5)), int(math.floor(y + 0.5)), cols['trail'])
    best = {}
    pad = 3.5 if cols.get('lip') else 1.6
    for i, (x, y, r) in enumerate(S):
        if reff[i] <= 0:
            continue
        e = max(reff[i], 0.5)
        nx, ny = -T[i][1], T[i][0]
        nl = nx * L[0] + ny * L[1]
        Rr = int(math.ceil(e + pad)) + 1
        for yy in range(int(y) - Rr, int(y) + Rr + 2):
            for xx in range(int(x) - Rr, int(x) + Rr + 2):
                dx, dy = xx - x, yy - y
                q = math.hypot(dx, dy) / e
                if q > 1 + pad / e:
                    continue
                cur = best.get((xx, yy))
                if cur is None or q < cur[0]:
                    best[(xx, yy)] = (q, (dx * nx + dy * ny) / e, along[i] + dx * T[i][0] + dy * T[i][1], e, nl)
    for (xx, yy), (q, u, s, e, nl) in best.items():
        lit = u * nl > 0
        a = abs(u)
        if treads and (a > 0.5 or q > 0.8) and noise(int(s // 4), int(u * 2 + 7), 11) > 0.62:
            continue  # turf grows over its edges in places: half buried
        if q > 1.0:
            if cols.get('lip') and q <= 1 + 3.0 / e:
                c = cols['lip'] if lit else cols['lip_dark']
            elif not lit and q <= 1 + 1.4 / e:
                c = cols['contact']
            else:
                continue
        elif e < 1.0:
            c = cols['moss_lit']
        elif cols.get('outline') and q > 1 - 1.0 / e:
            c = cols['outline']
        elif a > 0.55:
            c = cols['bark_lit'] if lit else cols['bark_dark']
        elif a > 0.34:
            c = cols['bark']
        else:
            c = cols['moss_lit'] if lit else cols['moss']
            if treads:
                # close up (Tower Rise): bark crest with patchy moss, a worn strip along the length, a few knots
                c = cols['bark']
                if noise(int(s // 5), int(u * 3 + 9), 2) > 0.62:
                    c = cols['moss_lit'] if lit else cols['moss']
                if abs(u + 0.12) < 0.13 and noise(int(s // 4), 1, 5) > 0.45:
                    c = cols['path']
                if noise(int(s // 9), int(u * 2 + 5), 7) > 0.93:
                    c = cols['bark_dark']
            elif e >= 1.5 and (a < 0.17 or (e < 2.6 and a < 0.34)):
                c = cols['path']
        put(xx, yy, c)
    return best


# ---------------------------------------------------------------------------------------------- 1. title
def mock_title():
    img = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
    orig = img.copy().load()
    W, H = img.size
    ramp = Ramp(['1e302e', '263d3a', '33524e', '43665a', '61785c', '9f946d', 'dca562'])
    sky = set(ramp.cols) | {hx('192726')}
    # skyline: from row 95 down, the first pixel that is not sky. The tree only replaces sky above it, so the
    # far hills, the ridge, the cables, the Tower and the left tree all stay in front.
    skyline = []
    for x in range(W):
        y = 95
        while y < H and orig[x, y] in sky:
            y += 1
        skyline.append(y)

    def allowed(x, y):
        return orig[x, y] in sky and y < skyline[x] and x >= 70

    roles = tree_roles(cx=186, base_y=122, Ht=65, light=-1, seed=5)
    box = paint_tree(img, roles, ramp, allowed, warm='9f946d', ref_sky=row_sky(img, sky, 120, 260))
    # No root line here: between the far hills and the Rise the root runs under the wooded ridge (a first try
    # drew its humps on the ridge and they read as floating leaves). The Tower's own root carries it.
    save(img, 'title_tree')
    return box


# ---------------------------------------------------------------------------------------------- 2. vista
def mock_vista():
    img = load_3x(f'{BUILD}/round2/13_road_vista.png')
    orig = img.copy().load()
    W, H = img.size
    sky = {orig[x, y] for x in range(90, 200) for y in range(0, 117)}
    # the main bands only, so "one step darker" is always a real step (the dither and cloud tones map by value)
    ramp = Ramp(['56708e', '6a84a0', '879db0', 'a9b5ba', 'cdc6b4', 'e4cba6', 'f0d59f', 'f7e3b5'])
    skyline = []
    for x in range(W):
        y = 60
        while y < H and orig[x, y] in sky:
            y += 1
        skyline.append(y)

    def allowed(x, y):
        return orig[x, y] in sky and y < skyline[x]

    roles = tree_roles(cx=138, base_y=125, Ht=67, light=1, seed=5)
    box = paint_tree(img, roles, ramp, allowed, warm='f0d59f', ref_sky=row_sky(img, sky, 90, 200))
    land = {hx(c) for c in ('6f8455', 'a3b0ae', '7f9467', '93a77a', 'b8c2bc', '6a8848', '4b6634')}
    root_tube(img, [(142, 124, 0.6), (156, 129, 0.9), (172, 137, 1.4), (189, 147, 2.0), (204, 158, 2.7),
                    (216, 169, 3.4), (226, 180, 4.0)],
              [(0.0, 0.12), (0.22, 0.38), (0.48, 0.64), (0.74, 0.93)],
              dict(contact='3e5629', bark='8c6545', bark_lit='c49b69', bark_dark='663f23', moss='6f8455',
                   moss_lit='93a77a', path='e6c697', trail='e6c697'),
              lambda x, y: orig[x, y] in land, light=(1.0, -0.4))
    save(img, 'vista_tree')
    return box


# ---------------------------------------------------------------------------------------------- 3. reveal hold
HZ = 120  # the horizon sits at eye level, just above the lamp
SKY_BANDS = [(0, '2e3b52'), (16, '3a4a60'), (32, '4a5e73'), (50, '566c80'), (66, '62788a'), (82, '7f939a'),
             (95, 'a3a891'), (105, 'c2b58f'), (113, 'd9bf94')]
LAND_BANDS = [(120, 'c2b58f'), (122, 'a3a891'), (126, '979683'), (131, '878b7c'), (138, '838e87'),
              (146, '748471'), (156, '6f8455'), (170, '59753c'), (188, '4b6731')]
LAND_EXT = [c for _, c in LAND_BANDS] + ['3d542b', '2d3729']


def band_at(bands, x, y):
    i = 0
    for k, (y0, _) in enumerate(bands):
        if y >= y0:
            i = k
    if i + 1 < len(bands) and y == bands[i + 1][0] - 1 and (x + y) % 2 == 0:
        i += 1  # one dithered row at each band edge, like the existing sky
    return i


def mock_hold():
    img = load_3x(f'{BUILD}/round2/11_reveal_hold_top.png')
    src = img.copy().load()
    px = img.load()
    W, H = img.size
    sky = {src[x, y] for x in range(230, 384) for y in range(0, 216)}
    glow = {hx(c) for c in ('97a8a6', '92a2a2', '7a8d96', 'afbdb2', '6e818c', 'b6c1b5', 'd3dcc5', '869698')}
    bg = [[src[x, y] in sky or src[x, y] in glow for y in range(H)] for x in range(W)]
    # 1. sky above the horizon: the same tones, packed so the brightest band sits at eye level
    for y in range(0, HZ):
        for x in range(W):
            if bg[x][y]:
                px[x, y] = hx(SKY_BANDS[band_at(SKY_BANDS, x, y)][1])
    for (y, x0, x1) in ((24, 232, 290), (25, 244, 300), (58, 12, 70)):  # two thin high streaks
        for x in range(x0, x1):
            if bg[x][y]:
                px[x, y] = hx('8d95a6')
    # 2. the land far below. Ground at distance d tiles from the Tower top shows at y = HZ + 28800 / d
    # (eye 720 px up, lens 40 tiles), so the bottom edge of the frame is ground 300 tiles out.
    for y in range(HZ, H):
        for x in range(W):
            if bg[x][y]:
                px[x, y] = hx(LAND_EXT[band_at(LAND_BANDS, x, y)])
    rnd = random.Random(11)

    def blob(cx, cy, rx, ry, col, hi=None):
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if 0 <= xx < W and HZ + 1 <= yy < H and bg[xx][yy] and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1:
                    px[xx, yy] = hx(col)
                    if hi and ((xx - cx - 0.35 * rx) / rx) ** 2 + ((yy - cy + 0.5 * ry) / ry) ** 2 <= 0.25:
                        px[xx, yy] = hx(hi)

    def depth_y():
        d = math.exp(rnd.uniform(math.log(300), math.log(7000)))
        return HZ + 28800 / d

    for _ in range(26):  # grass openings, a shade lighter
        y = depth_y()
        if y < H:
            s = y - HZ
            i = band_at(LAND_BANDS, 0, int(y))
            blob(rnd.uniform(0, W), y, max(1.5, rnd.uniform(0.6, 1.4) * s * 0.5), max(0.6, 0.25 * s * 0.5),
                 LAND_EXT[max(0, i - 1)])
    for _ in range(80):  # woods: clusters of dark clumps, smaller toward the horizon, lit from the east
        y = depth_y()
        if y >= H:
            continue
        s = y - HZ
        i = band_at(LAND_BANDS, 0, int(y))
        x = rnd.uniform(0, W)
        r0 = max(1.0, rnd.uniform(0.12, 0.32) * s * 0.5)
        col = LAND_EXT[min(len(LAND_EXT) - 1, i + 2)]
        for _k in range(rnd.randint(2, 5)):
            rr = r0 * rnd.uniform(0.55, 1.0)
            blob(x + rnd.uniform(-1.8, 1.8) * r0, y + rnd.uniform(-0.15, 0.15) * r0, rr, max(0.6, rr * 0.4), col,
                 LAND_EXT[i] if rr > 2.5 else None)
    for _ in range(16):  # upland springs: little pale glints
        y = depth_y()
        if y < H:
            x = rnd.uniform(0, W)
            for j in range(max(1, int((y - HZ) * 0.06))):
                xx, yy = int(x) + j, int(y)
                if xx < W and bg[xx][yy]:
                    px[xx, yy] = hx('c2d4df' if j else 'deded0')
    # 3. the root road. A line running straight away from the eye shows as a vertical line on screen, so it rises
    # from the bottom of the frame to the tree's foot, meandering and thinning with distance (4 tiles wide).
    def rr_(y):
        return max(0.45, 0.067 * (y - HZ) * 0.5 + 0.2)
    pts = [(300, 124.3), (299, 125.6), (305, 128), (296, 132), (304, 139), (317, 148), (300, 160), (271, 176),
           (284, 195), (262, 216)]
    root_tube(img, [(x, y, rr_(y)) for x, y in pts],
              [(124.0, 127.4), (130.0, 132.6), (138.0, 142.0), (149.0, 156.0), (166.0, 181.0), (196.0, 217.0)],
              dict(contact='2d3729', bark='796145', bark_lit='b18956', bark_dark='565b40', moss='6f8455',
                   moss_lit='8c8466', path='e6d1ae', trail='c9b38e'),
              lambda x, y: bg[x][y] and y > HZ, light=(1.0, -0.3), key=lambda f, x, y: y, per=60)
    # 4. low mist lying over the land, under the eye, and two birds below us: both say "high up"
    for (y, x0, x1) in ((151, 196, 296), (152, 188, 306), (153, 236, 384), (154, 230, 384), (171, 0, 74), (172, 8, 96)):
        for x in range(x0, x1):
            if bg[x][y] and (x * 7 + y) % 23 != 0:
                px[x, y] = hx('c2d4df' if y in (151, 153, 171) else 'a0adb0')
    for (bx, by) in ((226, 192), (236, 186)):
        for (dx, dy) in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            if bg[bx + dx][by + dy]:
                px[bx + dx, by + dy] = hx('2d3729')
    # 5. the great tree on the horizon, right of the crook: hazy, one step darker than the air behind it
    ramp = Ramp([c for _, c in SKY_BANDS])
    ref = [hx(SKY_BANDS[band_at(SKY_BANDS, 1, y)][1]) if y < HZ else hx(LAND_EXT[min(1, y - HZ)]) for y in range(H)]
    roles = tree_roles(cx=300, base_y=124, Ht=70, light=1, seed=5)
    box = paint_tree(img, roles, ramp, lambda x, y: bg[x][y], warm='e2c0a4', ref_sky=ref)
    # 6. the lamp's glow, rebuilt over the new sky and land (it was baked over the old sky bands)
    for x in range(W):
        for y in range(H):
            c = src[x, y]
            if c in glow:
                strong = lum(c) > 165
                if y < HZ:
                    px[x, y] = ramp.get(ramp.idx(px[x, y]) + (2 if strong else 1))
                else:
                    i = band_at(LAND_BANDS, x, y)
                    px[x, y] = hx(LAND_EXT[max(0, i - (3 if strong else 2))])
    save(img, 'hold_tree')
    return box


# ---------------------------------------------------------------------------------------------- 4. Tower Rise
def mock_rise():
    img = load_3x(f'{BUILD}/round2/05c_rise_side_west_col2_row3.png')
    orig = img.copy().load()
    keep = {hx(c) for c in ('b06b3d', '181412', '663f23', '0b0e11', '8e7f5e', '908940', '241b16', '9c8c68',
                            '2a1a0f', 'ad693c', 'c49b69', '3f2716', '23180e', '101006', '0f0905', '44421a')}
    line = {hx('f2d27a'), hx('ddca86')}

    def allowed(x, y):
        if y < 37 or (43 <= x <= 75 and 47 <= y <= 84):  # dialogue box, the partner
            return False
        if orig[x, y] in line:  # waylines stay in front
            return False
        if x >= 92 and orig[x, y] in keep:  # the existing root foot stays in front of the ridge
            return False
        return True

    # In this shot the screen is world space: the side lane is x 0..96, the root foot meets the ground at
    # world (100, 214). The ridge comes in low along the ground from past the west edge (tile row 6) and rears
    # up into the foot: one root, bending from the ground into the climb. Low and walkable, not a wall.
    cols = dict(outline='181412', bark='b06b3d', bark_lit='c49b69', bark_dark='663f23', moss='6b6f1d',
                moss_lit='908940', path='c7a378', lip='7b8643', lip_dark='44421a', contact='181412')
    for tip, base in (((24, 196, 2.0), (32, 170, 4.5)), ((50, 160, 1.8), (46, 179, 4.0)),
                      ((70, 214, 2.2), (68, 194, 4.5))):  # rootlets diving into the turf
        root_tube(img, [tip, ((tip[0] + base[0]) / 2 + 2, (tip[1] + base[1]) / 2, (tip[2] + base[2]) / 2), base],
                  [(0.0, 2.0)], cols, allowed, light=(-0.7, -0.7), per=20, treads=True)
    root_tube(img, [(-12, 146, 9.0), (12, 152, 9.5), (34, 170, 10.0), (58, 182, 10.5), (80, 201, 11.0),
                    (103, 214, 11.0)],
              [(-1.0, 2.0)], cols, allowed, light=(-0.7, -0.7), per=40, treads=True)
    save(img, 'rise_root')


# ---------------------------------------------------------------------------------------------- 5. map
def mock_map():
    W, H = 384, 216
    img = Image.new('RGB', (W, H), hx('e6c697'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    ink, faint, rootc = hx('3f2716'), hx('a37a32'), hx('7c4a26')

    def text(x, y, s, c=ink):
        d.text((x, y), s, font=f, fill=c)

    def dashed(pts, c, on=2, off=2):
        S = catmull([(x, y, 0) for x, y in pts], 30)
        for i, (x, y, _) in enumerate(S):
            if i % (on + off) < on:
                img.putpixel((int(x + 0.5), int(y + 0.5)), c)

    # --- region panel: 1 px = 40 tiles
    d.rectangle((3, 11, 227, 212), fill=hx('f5d9a8'), outline=faint)
    text(4, 1, 'ROOT ROAD: REGION (PROPOSAL)')
    rnd = random.Random(4)
    for _ in range(60):  # woods
        x, y = rnd.uniform(8, 222), rnd.uniform(34, 180)
        d.rectangle((int(x), int(y), int(x) + 2, int(y) + 1), fill=hx('908940'))
    for _ in range(14):  # upland springs
        x, y = rnd.uniform(60, 200), rnd.uniform(50, 150)
        d.rectangle((int(x), int(y), int(x) + 1, int(y)), fill=hx('2d9e9f'))
    for yy in (150, 112, 74):  # the land rising north (contours)
        dashed([(6, yy + 4), (60, yy - 2), (120, yy + 3), (180, yy - 3), (224, yy + 2)], faint, 3, 3)
    river = [(4, 191), (40, 194), (80, 192), (118, 194), (160, 197), (200, 195), (226, 198)]
    for (x, y, _) in catmull([(x, y, 0) for x, y in river], 40):
        for k in range(3):
            img.putpixel((int(x + 0.5), int(y + 0.5) + k), hx('2d9e9f') if k < 2 else hx('12837f'))
    tree = (139, 22)
    d.ellipse((tree[0] - 9, tree[1] - 9, tree[0] + 9, tree[1] + 9), fill=hx('6b6d45'), outline=hx('44421a'))
    d.ellipse((tree[0] - 5, tree[1] - 5, tree[0] + 5, tree[1] + 5), outline=hx('908940'))
    d.rectangle((tree[0] - 1, tree[1] - 1, tree[0] + 1, tree[1] + 1), fill=hx('3f2716'))
    # the root: surfaced stretches solid (the root road), underground stretches dashed
    rpts = [(139, 31), (134, 45), (142, 60), (128, 78), (137, 96), (121, 114), (131, 132), (114, 150), (104, 166),
            (107, 178), (116, 185)]
    S = catmull([(x, y, 0) for x, y in rpts], 30)
    N = len(S)
    surf = [(0.0, 0.07), (0.17, 0.27), (0.38, 0.47), (0.58, 0.67), (0.78, 0.86), (0.93, 1.0)]
    for i, (x, y, _) in enumerate(S):
        X, Y = int(x + 0.5), int(y + 0.5)
        if any(a <= i / (N - 1) <= b for a, b in surf):
            d.rectangle((X - 1, Y - 1, X + 1, Y + 1), fill=hx('b06b3d'))
        elif i % 4 < 2:
            img.putpixel((X, Y), hx('663f23'))
    for i, (x, y, _) in enumerate(S):
        if any(a <= i / (N - 1) <= b for a, b in surf) and i % 3 == 0:
            img.putpixel((int(x + 0.5), int(y + 0.5)), hx('e6c697'))
    d.rectangle((104, 186, 116, 189), fill=hx('c7a378'), outline=ink)  # Highbank
    d.rectangle((117, 181, 119, 189), fill=hx('b06b3d'), outline=ink)  # the Tower
    img.putpixel((118, 180), hx('f2d27a'))
    eye = (112, 204)  # far-bank viewpoint for the title and the vista, with its view cone
    d.line((eye, (100, 13)), fill=hx('c7a378'))
    d.line((eye, (178, 13)), fill=hx('c7a378'))
    d.rectangle((eye[0] - 1, eye[1] - 1, eye[0] + 1, eye[1] + 1), fill=hx('07515c'))
    d.line(((206, 22), (206, 186)), fill=faint)  # dimension line, Tower to tree
    d.line(((203, 22), (209, 22)), fill=faint)
    d.line(((203, 186), (209, 186)), fill=faint)
    text(152, 13, 'GREAT TREE')
    text(152, 22, '480 TALL')
    text(166, 100, '6,600', faint)
    text(166, 109, 'TILES', faint)
    text(8, 70, 'UPLAND')
    text(8, 79, 'SPRINGS')
    text(150, 152, 'ROOT', rootc)
    text(150, 161, 'ROAD', rootc)
    d.line(((148, 156), (126, 140)), fill=rootc)
    text(8, 176, 'HIGHBANK')
    d.line(((58, 180), (102, 187)), fill=ink)
    text(8, 199, 'RIVER', hx('07515c'))
    text(121, 201, 'FAR BANK VIEW', hx('07515c'))
    d.rectangle((8, 132, 18, 134), fill=hx('b06b3d'))  # legend and scale
    text(22, 129, 'SURFACED')
    for x in range(8, 19, 4):
        img.putpixel((x, 144), hx('663f23'))
        img.putpixel((x + 1, 144), hx('663f23'))
    text(22, 140, 'UNDERGROUND')
    d.line(((8, 160), (33, 160)), fill=ink)
    d.line(((8, 157), (8, 163)), fill=ink)
    d.line(((33, 157), (33, 163)), fill=ink)
    text(38, 156, '1000 TILES')
    d.polygon([(214, 16), (211, 24), (217, 24)], fill=ink)
    text(211, 26, 'N')

    # --- Highbank inset: 2 px = 1 tile. Rise col c -> x 302 + 2c; Street col c -> x 234 + 2c (the steps line up)
    d.rectangle((230, 11, 381, 212), fill=hx('f5d9a8'), outline=faint)
    text(232, 1, 'HIGHBANK, 2 PX = 1 TILE')
    rx0, ry0 = 302, 64
    sx0, sy0 = 234, ry0 + 28

    def R(c, r):
        return (int(rx0 + 2 * c), int(ry0 + 2 * r))

    d.rectangle((rx0, ry0, rx0 + 52, ry0 + 28), fill=hx('ccb290'), outline=ink)         # Tower Rise 26x14
    d.rectangle((rx0 + 1, ry0 + 1, rx0 + 51, ry0 + 2), fill=hx('6b6d45'))              # back hedge, row 0
    d.rectangle((*R(7, 6), *R(19, 9)), fill=hx('f5d9a8'), outline=ink)                 # Tower base (7,6) 12x3
    d.rectangle((*R(4, 1), *R(7, 9)), fill=hx('b06b3d'))                               # root foot cols 4-6
    for k in range(9):                                                                 # new ridge, side lane
        x, y = R(4 - k * 0.5, 8 - k * 0.28)
        d.rectangle((x, y, x + 2, y + 2), fill=hx('b06b3d'))
        img.putpixel((x + 1, y), hx('6b6f1d'))
    d.rectangle((*R(2, 10), R(2, 10)[0] + 1, R(2, 10)[1] + 1), fill=ink)               # post (2,10)
    img.putpixel(R(12, 7), hx('f2d27a'))                                               # the lamp, over the base
    d.rectangle((sx0, sy0, sx0 + 112, sy0 + 32), fill=hx('e6c697'), outline=ink)       # Street 56x16
    for (c, r) in ((3, 5), (12, 5), (20, 5), (28, 5), (12, 11), (21, 11)):
        d.rectangle((sx0 + 2 * c - 2, sy0 + 2 * r - 2, sx0 + 2 * c + 3, sy0 + 2 * r + 2), fill=hx('c7a378'),
                    outline=faint)
    d.rectangle((sx0, sy0 + 34, sx0 + 140, sy0 + 37), fill=hx('2d9e9f'))               # the river, south
    dashed([R(0, 6), (294, 72), (289, 56), (287, 38), (287, 26)], hx('663f23'))         # past the west edge
    d.polygon([(287, 20), (284, 25), (290, 25)], fill=hx('663f23'))
    text(234, 22, 'TO THE TREE', rootc)
    text(234, 31, '(UNDERGROUND)', rootc)
    text(334, 52, 'RISE')
    text(240, 104, 'STREET')
    text(240, 130, 'RIVER', hx('07515c'))
    text(234, 46, 'RIDGE (NEW)', rootc)
    d.line(((278, 55), (301, 78)), fill=rootc)
    d.line(((236, 146), (256, 146)), fill=ink)
    d.line(((236, 143), (236, 149)), fill=ink)
    d.line(((256, 143), (256, 149)), fill=ink)
    text(260, 142, '10 TILES')
    for i, s in enumerate(['TREE: N 7 DEG E', 'OF THE TOWER', '6,600 TILES AWAY', '480 TILES TALL', '= 16 TOWERS',
                           'CROWN ~720 WIDE']):
        text(236, 158 + 9 * i, s)
    save(img, 'map')


if __name__ == '__main__':
    print('title tree box', mock_title())
    print('vista tree box', mock_vista())
    print('hold tree box', mock_hold())
    mock_rise()
    mock_map()
    # one contact sheet to review everything at once (scratch, not a deliverable)
    names = ['title_tree', 'vista_tree', 'hold_tree', 'rise_root', 'map']
    ims = [Image.open(f'{OUT}/{n}_1x.png').convert('RGB') for n in names]
    sheet = Image.new('RGB', (768, 648), (0, 0, 0))
    for i, im in enumerate(ims):
        sheet.paste(im, ((i % 2) * 384, (i // 2) * 216))
    sheet.resize((1536, 1296), Image.NEAREST).save(f'{SCRATCH}/c_sheet.png')
    # close-ups at 3x of the parts that matter most
    t = Image.open(f'{OUT}/title_tree_1x.png').crop((120, 40, 300, 160))
    h = Image.open(f'{OUT}/hold_tree_1x.png').crop((200, 40, 384, 216))
    r = Image.open(f'{OUT}/rise_root_1x.png').crop((0, 30, 140, 216))
    zoom = Image.new('RGB', (180 + 184 + 140, 186), (0, 0, 0))
    zoom.paste(t, (0, 0))
    zoom.paste(h, (180, 0))
    zoom.paste(r, (364, 0))
    zoom.resize((zoom.width * 3, zoom.height * 3), Image.NEAREST).save(f'{SCRATCH}/c_zoom.png')
    print('done')
