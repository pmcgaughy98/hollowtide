"""Wayline Tower at the vast scale: design mocks (proposal, 2026-10-27).

Preston, 2026-10-27: "for the tower its too small. Im thinking vast like the one from danmachi". That series is
used for SCALE ONLY. Nothing here copies its tower, nor the reference painting he shared for the great tree.

Draws six mocks into this folder, each as a 1x and a 3x (nearest neighbour):
  elevation    the whole 480-tile Tower at 1 px = 1 tile beside today's 720 px Tower, a house and a creature,
               with the cloud layer marked; plus the foot at quarter game scale (6 px a tile)
  title        Codex's cx-15 candidate with the Tower's foot running off the top and the right edge
  vista        the road home's vista (round2/13) with the whole Tower in one frame
  door_lean    the Tower Rise door view with today's 72 px lean (round2/02)
  street_band  the Street (round2/06) with the far band over its north edge
  top_hold     the reveal's top hold, the crown above the cloud sea
Hard edges, no anti-aliasing, painted colours snapped to the project palettes. Nothing here is canon.
Run: python mock_tower_scale.py   (reads only; writes only into this folder)
"""
import os, math, random
from collections import Counter, deque
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
DOCS = ROOT + '/docs'
OUT = DOCS + '/design/vast-scale-2026-10-27/tower'
PALS = DOCS + '/design/placeholder-factory-2026-10-26/refs/palettes/'
R2 = DOCS + '/design/wayline-tower-2026-10-27/build/round2/'
BLOCK = DOCS + '/design/wayline-tower-2026-10-27/build/assembled_blockout.png'
CROWN_REF = DOCS + '/art/slot-candidates/cx-14-tower-crown/static-assembled-reference.png'
TITLE = DOCS + '/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/prepared.png'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
SCRATCH = 'C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad'
REPORT = {}


# ------------------------------------------------------------------------------------------------ basics
def hx(s):
    s = s.lstrip('#')
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def rgb(c):
    return hx(c) if isinstance(c, str) else tuple(c[:3])


def mix(a, b, t):
    a, b = rgb(a), rgb(b)
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def lum(c):
    c = rgb(c)
    return 0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]


def load_pal(name):
    im = Image.open(PALS + name).convert('RGBA')
    out = []
    for x in range(im.width):
        c = im.getpixel((x, im.height // 2))
        if c[3] and c[:3] not in out:
            out.append(c[:3])
    return out


def cdist(a, b):
    rm = (a[0] + b[0]) / 2
    dr, dg, db = a[0] - b[0], a[1] - b[1], a[2] - b[2]
    return (2 + rm / 256) * dr * dr + 4 * dg * dg + (2 + (255 - rm) / 256) * db * db


class Snap:
    """Nearest colour in a fixed palette (cached), so every painted pixel is a palette colour."""
    def __init__(self, pal):
        self.pal = [rgb(p) for p in pal]
        self.cache = {}

    def __call__(self, c):
        c = rgb(c)
        if c not in self.cache:
            self.cache[c] = min(self.pal, key=lambda p: cdist(p, c))
        return self.cache[c]


def to1x(path):
    """Round2 screens are the 384x216 view at 3x: take the centre pixel of each 3x3 cell."""
    im = Image.open(path).convert('RGB')
    w, h = im.width // 3, im.height // 3
    out = Image.new('RGB', (w, h))
    sp, op = im.load(), out.load()
    for y in range(h):
        for x in range(w):
            op[x, y] = sp[x * 3 + 1, y * 3 + 1]
    return out


def save(img, name, note=''):
    img = img.convert('RGB')
    img.save(f'{OUT}/{name}_1x.png')
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f'{OUT}/{name}_3x.png')
    REPORT[name] = (img.size, len(img.getcolors(1 << 22)), note)


def hsh(*a):
    h = 2166136261
    for v in a:
        h = ((h ^ (int(v) & 0xffffffff)) * 16777619) & 0xffffffff
    return h / 0xffffffff


FNT = ImageFont.truetype(FONT, 8)


def label(img, x, y, s, fg, bg):
    """1-bit text (no anti-aliasing) with a dark rim."""
    m = Image.new('1', (len(s) * 8 + 12, 14), 0)
    ImageDraw.Draw(m).text((2, 1), s, font=FNT, fill=1)
    bb = m.getbbox()
    if not bb:
        return 0
    m = m.crop(bb)
    if bg is not None:
        sh = Image.new('RGB', m.size, rgb(bg))
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
            img.paste(sh, (x + dx, y + dy), m)
    img.paste(Image.new('RGB', m.size, rgb(fg)), (x, y), m)
    return m.size[0]


# ------------------------------------------------------------------------------------------------ the Tower
# Heights in tiles above the Tower Rise ground; widths in tiles. Proposal.
H_T = 480          # foot to vane tip, 11,520 px
LAMP_T = 475       # lamp glass, 11,400 px
CROWN_T = 461      # Codex's crown (galleries, ring deck, Reach, lamp, vane, bell) sits on the neck cap from here
DOOR_FROM_AXIS = -9.5  # the doors stand 9.5 tiles west of the Tower's axis
BANDS = [  # (from, to, width, material)
    (0, 8, 52, 'plinth'),    # plinth step 1, boulder footing and limestone; the depot stands in front of it
    (8, 16, 42, 'plinth'),   # plinth step 2; the Sorting Drum stands in front of it; its top is the Low Reel deck
    (16, 114, 34, 'A'),      # the Stack, era A: limestone and loess brick
    (114, 210, 28, 'B'),     # era B: cream river stone
    (210, 296, 22, 'C'),     # era C: cream stone with timber balconies
    (296, 344, 19, 'wet'),   # inside the cloud collar: damp, mossy stone
    (344, 404, 15, 'N'),     # the neck, above the clouds
    (404, 458, 12, 'N'),
    (458, 461, 9.5, 'N'),    # neck cap: the Galleries' seat
]
STATIONS = [112, 208, 292]   # Wayline Stations: balconies where the long lines leave
ERA_LINES = [16, 114, 210, 296, 344, 404]
ROOT_KNOTS = [(0, 5.0), (16, 4.0), (114, 3.0), (210, 2.5), (296, 2.0), (344, 1.8), (458, 1.6), (461, 1.5)]
CLOUD_LAYER = (280, 360)
COLLAR = (296, 344)

RAMP = {  # hi, lit, mid, shade, dark (wayline_tower / town_stone colours)
    'plinth': ['ccb290', '9b8a69', '8e7f5e', '5f5e57', '5d4b34'],
    'A': ['e6c697', 'c7a378', '9c8c68', '8e7f5e', '5d4b34'],
    'B': ['f5d9a8', 'e6c697', 'ccb290', '9c8c68', '5f5e57'],
    'C': ['f5d9a8', 'e6c697', 'c7a378', '92724b', '5d4b34'],
    'wet': ['9c8c68', '8e7f5e', '6b6d45', '5f5e57', '44421a'],
    'N': ['f5d9a8', 'e6c697', 'ccb290', '9c8c68', '5f5e57'],
}
ROOT_RAMP = ['c49b69', 'b06b3d', '663f23', '3f2716', '23180e']
MOSS = ['908940', '6b6d45', '44421a']
BRASS = ['f2d27a', 'd4a94c', 'a37a32', '6b4f1f']
WARM = ['fbd490', 'f1c177', 'ecb36b']
CLOUD = ['f5e5c0', 'd1cbbf', 'bdbdb5', '9cabb1']


def band_at(t):
    for b in BANDS:
        if b[0] <= t < b[1]:
            return b
    return None


def width_at(t):
    b = band_at(t)
    return b[2] if b else 0


def root_w(t):
    for (t0, w0), (t1, w1) in zip(ROOT_KNOTS, ROOT_KNOTS[1:]):
        if t0 <= t <= t1:
            return w0 + (w1 - w0) * (t - t0) / (t1 - t0)
    return ROOT_KNOTS[-1][1]


def _edge_cx(t):
    if t < 16:   # up the plinth face from where it surfaces, west of the depot (door - 8 tiles)
        return -17.5 + (-17 + 4.0 * 0.35 + 17.5) * t / 16
    w = width_at(t) if t < CROWN_T else 9.5
    # about 15% of its girth stands proud of the wall; it wanders a little onto the face, never off it
    return -w / 2 + root_w(t) * 0.35 + 0.6 + 0.6 * math.sin((t - 16) / 23.0 - 1.57)


def root_cx(t):
    """Root centre (tiles from the axis), eased over each setback so it bends over the lips."""
    if t < 16:
        return _edge_cx(t)
    s = [_edge_cx(max(16, t + d)) for d in (-4, -2, 0, 2, 4)]
    return sum(s) / len(s)


def rootlets(ppt, t_max):
    """Short side roots gripping the face every ~30 tiles: (t, length tiles, thickness tiles)."""
    out = []
    t = 24
    while t < t_max:
        out.append((t, 2.2 + 1.6 * hsh(t, 3), 0.55))
        t += 26 + 10 * hsh(t, 9)
    return out


def shade_idx(f):
    # the fixed cylinder columns of TOWER_DESIGN section 10, as fractions of the width: rim, highlight, lit, mid, shade, dark
    if f < 0.025:
        return 2
    if 0.08 <= f < 0.14:
        return 0
    if f < 0.32:
        return 1
    if f < 0.65:
        return 2
    if f < 0.88:
        return 3
    return 4


# crown stamps, painted for their size (bottom row sits on the neck cap; 'axis' is the axis column)
CROWN_1 = {'axis': 6, 'rows': [
    "......v......",
    "......vpp....",
    "....RRRr.....",
    "...RRr..rr...",
    "...Rr....r...",
    "...Rr...gLLg.",
    "...Rr...gLlg.",
    "...Rr....g...",
    "...Rr........",
    "...Rr........",
    "...RrMMm.....",
    "KbBBBBBBBBBb.",
    "K.TTTTTTTTT..",
    "..RrGGHHHHH..",
    "..RrWGHWHHH..",
    "..RrGGHHHHH..",
    ".TRrTTTTTTTT.",
    "..RrGGHHHHH..",
    "..RrWGHWHHH..",
    "..RrGGHHHHH..",
    "..RrGGHHHHH.."]}
CROWN_3 = {'axis': 3, 'rows': [
    "...v...",
    "..RRR..",
    ".R...R.",
    ".R..gLg",
    ".R...L.",
    ".R.....",
    "BBBBBB.",
    ".RGGH..",
    ".RGGH.."]}
STAMP_COL = {'v': 'd4a94c', 'p': '2d9e9f', 'R': 'b06b3d', 'r': '663f23', 'L': 'fbd490', 'l': 'f1c177',
             'M': '908940', 'm': '6b6d45', 'B': 'd4a94c', 'b': 'a37a32', 'T': '7c4a26', 'G': 'e6c697',
             'H': 'b8a07c', 'W': '5d4b34', 'K': 'b8793e'}


def paint_far_tower(img, S, cx, foot, ppt, sky_at, haze_at, lit=0.0, crown=None, keep=None, seed=1,
                    ground_run=True):
    """The whole Tower at ppt pixels per tile: plinth, Stack, collar shaft, neck, root, stations, lift, crown."""
    px = img.load()
    W, Hh = img.size

    def put(x, y, c, hz):
        if 0 <= x < W and 0 <= y < Hh and (keep is None or keep(x, y)):
            px[x, y] = S(mix(c, sky_at(y), max(0.0, min(1.0, hz))))

    story = 8 if ppt < 1.2 else 4
    rows = []
    for y in range(min(Hh, foot) - 1, -1, -1):
        t = (foot - y - 0.5) / ppt
        if t >= CROWN_T:
            break
        rows.append((y, t))
    top_y = rows[-1][0] if rows else foot
    for y, t in rows:
        b = band_at(t)
        w = b[2] * ppt
        ramp = RAMP[b[3]]
        x0 = int(round(cx - w / 2))
        x1 = max(x0 + 1, int(round(cx + w / 2)))
        hz = haze_at(t)
        top_row = (t + 1.0 / ppt) >= b[1] and b[1] < CROWN_T
        win_row = ppt >= 0.9 and b[3] in ('A', 'B', 'C', 'N') and (t % story) < 1.0 / ppt and t > b[0] + 1.5
        for x in range(x0, x1):
            f = (x + 0.5 - x0) / (x1 - x0)
            i = shade_idx(f)
            c = ramp[i]
            if top_row and ppt >= 0.9:
                c = (BRASS[1] if f < 0.5 else BRASS[2]) if b[1] == 16 else MOSS[0 if f < 0.32 else 1 if f < 0.7 else 2]
            elif win_row and (x - x0) % max(3, int(round(2 * ppt))) == 1 and 0.08 < f < 0.86:
                c = WARM[0 if f < 0.5 else 1] if hsh(x, y, seed) < lit else ramp[min(4, i + 2)]
            put(x, y, c, hz * (0.5 if c in WARM else 1.0))
    if ppt >= 0.9:
        for ts in STATIONS:   # Wayline Stations, half-ring balconies
            y = int(round(foot - ts * ppt))
            w = width_at(ts - 0.5) * ppt
            ext = 2.5 * ppt
            for dy in range(max(1, int(round(ppt * 0.8)))):
                for x in range(int(round(cx - w / 2 - ext)), int(round(cx + w / 2 + ext))):
                    put(x, y + dy, BRASS[1] if dy == 0 else BRASS[3], haze_at(ts))
        lx = int(round(cx + 4 * ppt))   # the Long Lift's rails on the east face
        for y, t in rows:
            if t < 458:
                put(lx, y, BRASS[3], haze_at(t))
                if ppt >= 1.4:
                    put(lx + 1, y, BRASS[2], haze_at(t))
        for tc in (60, 175, 330 - 70):  # two cabins riding
            y = int(round(foot - tc * ppt))
            for dy in range(max(2, int(2 * ppt))):
                for dx in range(max(2, int(1.5 * ppt))):
                    put(lx - 1 + dx, y + dy, '8c6545' if dy else WARM[1], haze_at(tc) * 0.6)
    # the root: one root of the great tree, thickest at the ground
    for y, t in rows:
        rw = max(1.0, root_w(t) * ppt)
        rc = cx + root_cx(t) * ppt
        xa = int(round(rc - rw / 2))
        xb = max(xa + 1, int(round(rc + rw / 2)))
        n = xb - xa
        brass_row = ppt >= 0.9 and any(t - 0.5 / ppt <= e < t + 0.5 / ppt for e in ERA_LINES)
        for x in range(xa, xb):
            g = (x + 0.5 - xa) / n
            if n <= 1:
                c = ROOT_RAMP[2]
            elif n == 2:
                c = ROOT_RAMP[1] if g < 0.5 else ROOT_RAMP[3]
            else:
                c = ROOT_RAMP[0 if g < 0.2 else 1 if g < 0.5 else 2 if g < 0.78 else 3 if g < 0.93 else 4]
            if brass_row:
                c = BRASS[1] if g < 0.6 else BRASS[2]
            put(x, y, c, haze_at(t) * 0.7)
    if ppt >= 0.9:   # rootlets gripping the face, east from the root's edge and a little upward
        for tr, L, th in rootlets(ppt, min(CROWN_T - 4, (foot - top_y) / ppt)):
            re = cx + root_cx(tr) * ppt + root_w(tr) * ppt / 2
            n = max(2, int(round(L * ppt)))
            for i in range(n):
                u = i / n
                yc = int(round(foot - tr * ppt - u * L * ppt * 0.3))
                tk = max(1, int(round(th * ppt * (1 - 0.6 * u))))
                for k in range(tk):
                    put(int(round(re - 0.5 + i)), yc - k, ROOT_RAMP[1 if (k == tk - 1 and tk > 1) else 2],
                        haze_at(tr) * 0.7)
    if ground_run and ppt >= 0.9:   # it arrives along the ground from the west, half buried
        xr = cx + root_cx(0) * ppt
        xa = cx - 40 * ppt
        h0 = root_w(0) * ppt * 0.6
        for x in range(int(xa), int(xr) + 1):
            u = (x - xa) / max(1, xr - xa)
            h = max(1, int(round(h0 * (0.35 + 0.65 * u ** 1.5))))
            for k in range(h):
                c = ROOT_RAMP[0 if k == h - 1 else 1 if k > h * 0.5 else 2 if k > 0 else 3]
                put(x, foot - 1 - k, c, 0)
    if crown:
        rows_c = crown['rows']
        yb = top_y - 1
        for r, line in enumerate(rows_c):
            y = yb - (len(rows_c) - 1 - r)
            for ci, ch in enumerate(line):
                if ch == '.':
                    continue
                x = cx - crown['axis'] + ci
                if ch == 'g':
                    put(x, y, mix(WARM[0], sky_at(y), 0.45), 0)
                else:
                    put(x, y, STAMP_COL[ch], 0 if ch in 'LlgK' else haze_at(470) * 0.8)
    return top_y


def collar_lumps(seed, part):
    rnd = random.Random(seed)
    lumps = []
    if part == 'back':
        for _ in range(18):
            x = rnd.uniform(-64, 64)
            lumps.append((x, rnd.uniform(322, 338) - abs(x) * 0.07, rnd.uniform(8, 14) * (1 - abs(x) / 150)))
    else:
        for _ in range(20):
            x = rnd.uniform(-62, 62)
            lumps.append((x, rnd.uniform(300, 316) + abs(x) * 0.05, rnd.uniform(8, 14) * (1 - abs(x) / 160)))
        for x in (-10, 0, 10):   # caps over the shaft: it goes into the cloud and comes out above it
            lumps.append((x + rnd.uniform(-2, 2), rnd.uniform(321, 326), rnd.uniform(10, 11.5)))
    return sorted(lumps, key=lambda l: -l[1])


def paint_collar(img, S, cx, foot, ppt, part, sky_at, haze, seed=7, cols=CLOUD):
    px = img.load()
    W, Hh = img.size
    for lx, lt, r in collar_lumps(seed, part):
        cxp, cyp, rp = cx + lx * ppt, foot - lt * ppt, max(1.2, r * ppt)
        for y in range(int(cyp - rp) - 1, int(cyp + rp) + 2):
            for x in range(int(cxp - rp * 1.35) - 1, int(cxp + rp * 1.35) + 2):
                dx, dy = (x + 0.5 - cxp) / (rp * 1.35), (y + 0.5 - cyp) / rp
                if dx * dx + dy * dy <= 1 and 0 <= x < W and 0 <= y < Hh:
                    k = 0 if dy < -0.45 else 1 if dy < 0.1 else 2 if dy < 0.55 else 3
                    px[x, y] = S(mix(cols[k], sky_at(y), haze))


def paint_wisps(img, S, specs, sky_at, haze, cols=CLOUD):
    px = img.load()
    W, Hh = img.size
    for x0, y0, wl, hl in specs:
        for y in range(int(y0 - hl) - 1, int(y0 + hl) + 2):
            for x in range(int(x0 - wl) - 1, int(x0 + wl) + 2):
                dx, dy = (x + 0.5 - x0) / wl, (y + 0.5 - y0) / hl
                if dx * dx + dy * dy <= 1 and 0 <= x < W and 0 <= y < Hh:
                    k = 0 if dy < -0.3 else 1 if dy < 0.35 else 2
                    px[x, y] = S(mix(cols[k], sky_at(y), haze))


def catenary(p0, p1, sag):
    (x0, y0), (x1, y1) = p0, p1
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    pts = []
    for i in range(n + 1):
        u = i / n
        x = x0 + (x1 - x0) * u
        y = y0 + (y1 - y0) * u + sag * 4 * u * (1 - u)
        p = (int(round(x)), int(round(y)))
        if not pts or pts[-1] != p:
            pts.append(p)
    return pts


def draw_wayline(img, S, p0, p1, sag, ink, top, tag='2d9e9f', tag_every=12, dotted=False):
    px = img.load()
    W, Hh = img.size
    for i, (x, y) in enumerate(catenary(p0, p1, sag)):
        if dotted and i % 3 == 2:
            continue
        if 0 <= x < W and 0 <= y < Hh:
            px[x, y] = S(ink)
        if top and 0 <= x < W and 0 <= y - 1 < Hh:
            px[x, y - 1] = S(tag if (tag and i % tag_every == tag_every // 2) else top)


# ------------------------------------------------------------------------------------------------ 1. elevation
def mock_elevation():
    dawn, tower = load_pal('dawn.png'), load_pal('wayline_tower.png')
    S = Snap(dawn + tower)
    W, Hh = 790, 580
    img = Image.new('RGB', (W, Hh), S('2a3426'))
    px = img.load()
    GA, CXA, PA = 548, 136, 322         # panel A ground row, axis, width
    SKY = ['2e3b52', '3c4d56', '4a5e73', '4d6582', '556c83', '5d758f', '6c8b96', '738f97', '8da2aa', '9cabb1',
           'bdbdb5', 'e2c59b']

    def skyA(y):
        f = max(0.0, min(0.9999, y / GA))
        return SKY[int(f * len(SKY))]
    for y in range(Hh):
        for x in range(W):
            if x == PA or x == PA + 1:
                px[x, y] = S('0b0e11')
            elif y < GA:
                px[x, y] = S(skyA(y)) if x < PA else S('3c4d56')
            else:
                px[x, y] = S('516b38' if y < GA + 2 else '3c532b' if y < GA + 6 else '2f372a')
    ppt = 1.0
    hz = lambda t: 0.10 + 0.12 * t / H_T
    sky = lambda y: skyA(y)
    # the cloud layer, 280 to 360 tiles: flat wisps away from the collar
    paint_wisps(img, S, [(40, GA - 300, 18, 2.5), (270, GA - 352, 26, 3), (292, GA - 286, 16, 2),
                         (48, GA - 344, 12, 2)], sky, 0.15)
    # the long lines from the 208 station out over the land (proposal)
    for side in (-1, 1):
        x_st = CXA + side * (width_at(207) / 2 + 2.5)
        draw_wayline(img, S, (int(x_st), GA - 208), (CXA + side * 128, GA - 6), 40, '4b5350', None, dotted=True)
    paint_collar(img, S, CXA, GA, ppt, 'back', sky, 0.0)
    top = paint_far_tower(img, S, CXA, GA, ppt, sky, hz, lit=0.0, crown=CROWN_1)
    paint_collar(img, S, CXA, GA, ppt, 'front', sky, 0.0)
    # lamp glow, one halo ring
    lx, ly = CXA - CROWN_1['axis'] + 9, top - 1 - (len(CROWN_1['rows']) - 1 - 5)
    # today's Tower, a house and a creature at the same 1 px = 1 tile
    blk = Image.open(BLOCK).convert('RGBA')
    small = blk.resize((18, 30), Image.BOX)
    sp = small.load()
    ox, oy = 210, GA - 30
    for y in range(30):
        for x in range(18):
            c = sp[x, y]
            if c[3] > 110:
                px[ox + x, oy + y] = S(c)
    for x in range(232, 236):          # a house, 4 x 4 tiles
        for y in range(GA - 4, GA):
            px[x, y] = S('e6c697' if y > GA - 3 else 'b06b3d')
    px[240, GA - 1] = S('c49243')       # a creature, about one tile
    # ruler
    for t in range(0, 501, 10):
        y = GA - t
        ln = 6 if t % 100 == 0 else 4 if t % 50 == 0 else 2
        for x in range(30 - ln, 30):
            px[x, y] = S('f5e5c0')
        if t % 100 == 0 and t:
            label(img, 4, y - 3, str(t), 'f5e5c0', '2e3b52')
    for y in range(GA - 500, GA + 1):
        px[30, y] = S('f5e5c0')
    lb = lambda x, y, s, c='f5e5c0', bg='2e3b52': label(img, x, y, s, c, bg)
    lb(4, 8, 'WAYLINE TOWER AT 480 TILES (PROPOSAL)')
    lb(4, 20, '1 PX = 1 TILE (24 PX).  11,520 PX FOOT TO VANE', 'e2c59b')
    lb(150, GA - 481 - 4, 'VANE 480', 'e2c59b')
    lb(150, GA - LAMP_T - 1, 'LAMP 475', 'fbd490')
    lb(196, GA - 344 - 3, 'COLLAR 296-344', 'f5e5c0')
    lb(196, GA - 334 + 6, 'CLOUD LAYER 280-360', 'bdbdb5')
    lb(166, GA - 420, 'NECK 344-461', 'f5e5c0')
    lb(166, GA - 250, 'STACK ERA C', 'f5e5c0')
    lb(166, GA - 165, 'STACK ERA B', 'f5e5c0')
    lb(166, GA - 70, 'STACK ERA A', 'f5e5c0')
    lb(166, GA - 214, 'STATION', 'e2c59b')
    lb(186, GA - 50, "TODAY'S TOWER 30", 'f5e5c0')
    lb(232, GA - 22, 'HOUSE', 'f5e5c0')
    lb(240, GA - 12, 'CREATURE', 'f5e5c0')
    lb(36, GA + 10, 'ROOT ARRIVES FROM THE WEST', 'c49b69', '2a3426')
    # ---------------------------------------------------------------- panel B: the foot at 1 px = 1/4 tile
    q = 6.0
    GB, CXB = 548, 586
    bsky = lambda y: '3c4d56'
    paint_far_tower(img, S, CXB, GB, q, bsky, lambda t: 0.0, lit=0.0, keep=lambda x, y: x > PA + 1 and y > 290,
                    ground_run=False)
    # the root's ground run from the west, half buried: a long low hump, not a wedge
    xr = CXB + root_cx(0) * q
    for x in range(PA + 2, int(xr) + 1):
        u = (x - (PA + 2)) / (xr - (PA + 2))
        h = max(2, int(round(q * 5 * 0.40 * (0.8 + 0.2 * u) + 1.5 * math.sin(x / 13.0))))
        for k in range(h):
            c = ROOT_RAMP[0 if k >= h - 2 else 1 if k > h * 0.45 else 2 if k > 1 else 3]
            if x > PA + 1:
                px[x, GB - 1 - k] = S(c)
    # today's foot (depot, drum, hoist, chute, yard, and the old vein as a rootlet) at 1/4, at the doors
    foot = blk.crop((66, 368, 432, 720))
    fs = foot.reduce(4)
    fp = fs.load()
    dx0 = int(round(CXB + DOOR_FROM_AXIS * q - (150 / 4)))
    dy0 = GB - fs.height
    for y in range(fs.height):
        for x in range(fs.width):
            c = fp[x, y]
            if c[3] > 128:
                px[dx0 + x, dy0 + y] = S(c)
    # today's whole Tower at 1/4, standing beside the new foot
    whole = blk.reduce(4)
    wp = whole.load()
    wx0, wy0 = PA + 10, GB - whole.height
    for y in range(whole.height):
        for x in range(whole.width):
            c = wp[x, y]
            if c[3] > 128:
                px[wx0 + x, wy0 + y] = S(c)
    for x in range(746, 770):   # a house, 4 x 4 tiles, roof and wall
        for y in range(GB - 24, GB):
            px[x, y] = S('b06b3d' if y < GB - 14 else 'e6c697')
    for x in range(752, 757):
        for y in range(GB - 10, GB):
            px[x, y] = S('5d4b34')
    for x in range(778, 784):   # a creature, about 1.25 tiles
        for y in range(GB - 8, GB):
            px[x, y] = S('c49243' if (x + y) % 5 else '663f23')
    lb(PA + 8, 8, 'THE FOOT AT 1/4 GAME SCALE (6 PX A TILE)')
    lb(PA + 8, 20, 'DOORS, DRUM, HOIST, YARD UNCHANGED', 'e2c59b')
    lb(PA + 8, wy0 - 12, "TODAY'S WHOLE TOWER", 'f5e5c0')
    lb(PA + 8, wy0 - 3 + 0, '(30 TILES)', 'bdbdb5')
    lb(CXB + 104, GB - 100, 'LOW REEL 16', 'f2d27a')
    lb(CXB + 104, GB - 50, 'PLINTH', 'f5e5c0')
    lb(CXB - 18, GB - 300 + 2, 'STACK ERA A, 34 WIDE', 'f5e5c0')
    lb(PA + 128, GB + 10, 'ROOT 5 TILES AT THE GROUND', 'c49b69', '2a3426')
    lb(735, GB - 36, 'HOUSE', 'f5e5c0')
    lb(735, GB + 10, 'CREATURE', 'f5e5c0', '2a3426')
    save(img, 'elevation', '1 px = 1 tile, and the foot at quarter game scale')


# ------------------------------------------------------------------------------------------------ 2. title
def mock_title():
    base = Image.open(TITLE).convert('RGB')
    img = base.copy()
    px, bp = img.load(), base.load()
    S = Snap(load_pal('highbank_title.png'))
    FOOT, PPT, CX = 167, 4.8, 377     # door axis at x 331 = CX - 9.5 tiles
    yof = lambda t: FOOT - t * PPT
    B = set(bp[x, y] for y in range(0, 132) for x in range(150, 262))
    # flood mask of the background (sky, hills, forest) in the Tower's region, from its open edges
    X0, X1, Y1 = 248, 384, 168
    mask = set()
    q = deque((x, 0) for x in range(X0, X1) if bp[x, 0] in B)
    q.extend((x, y) for y in range(Y1) for x in (X0, X1 - 1) if bp[x, y] in B)
    while q:
        x, y = q.popleft()
        if (x, y) in mask or not (X0 <= x < X1 and 0 <= y < Y1) or bp[x, y] not in B:
            continue
        mask.add((x, y))
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    def zone_ramp(y, x, kind):
        if kind == 'plinth':
            return ['c7a378', '9c8c68', '8e7f5e', '5f5e57', '303e37']
        z = 0 if y >= 70 else 1 if y >= 36 else 2
        if y in (69, 70, 35, 36) and (x + y) % 2:
            z = max(0, z - 1) if y in (35, 36) else min(2, z + 1)
        return [['e6c697', 'ccb290', '9f946d', '8e7f5e', '5f5e57'],
                ['ccb290', '9f946d', '8e7f5e', '61785c', '4f6858'],
                ['9f946d', '61785c', '4f6858', '43665a', '33524e']][z]

    def arc(t, a, dx):
        b = 0.12 * a
        v = 1 - (dx / a) ** 2
        return yof(t) + b * math.sqrt(v) if v > 0 else None

    # 1. clear the old tower's remains left of the new Stack with each row's own sky
    for y in range(0, 100):
        row = [bp[x, y] for x in range(236, 262)]
        m = Counter(row).most_common(1)[0][0]
        for x in range(262, 300):
            if (x, y) in mask or y < 92:
                px[x, y] = bp[236 + ((x - 236) % 26), y] if bp[236 + ((x - 236) % 26), y] in B else m
    # 2. plinth steps (behind the depot, drum, Rise and yard: background pixels only)
    for (t0, t1, wt) in ((0, 8, 52), (8, 16, 42)):
        a = wt / 2 * PPT
        for x in range(X0, X1):
            dx = x + 0.5 - CX
            top, bot = arc(t1, a, dx), arc(t0, a, dx)
            if top is None:
                continue
            f = (dx + a) / (2 * a)
            ramp = zone_ramp(0, x, 'plinth')
            for y in range(int(math.ceil(top)), min(Y1, int(bot) + 1)):
                if (x, y) not in mask:
                    continue
                i = shade_idx(f)
                c = ramp[i]
                ry = y - top
                course = int(ry // 5)
                if ry % 5 < 1:
                    c = ramp[min(4, i + 1)]
                elif (x + 5 * (course % 2)) % 11 == 0:
                    c = ramp[min(4, i + 1)]
                if t0 == 0 and y > FOOT - 9:   # boulder footing
                    c = ramp[min(4, i + 1 + int(hsh(x // 4, y // 3) * 2))]
                    if y == FOOT - 9 or hsh(x // 3, 1) < 0.3 and y == FOOT - 8:
                        c = MOSS[0]
                if ry < 2 and hsh(x // 2, t0) < 0.55:   # moss lip and drips under the deck edge
                    c = MOSS[0] if ry < 1 else MOSS[1]
                px[x, y] = S(c)
        # the step's deck, a thin ring seen almost edge on
        for x in range(X0, X1):
            dx = x + 0.5 - CX
            outer = arc(t1, a, dx)
            if outer is None:
                continue
            inner_a = (42 if t1 == 8 else 34) / 2 * PPT
            inner = arc(t1, inner_a, dx)
            back = yof(t1) - 0.12 * a * math.sqrt(max(0, 1 - (dx / a) ** 2))
            ytop = inner if inner is not None else back
            for y in range(int(math.ceil(ytop)), int(math.ceil(outer))):
                if (x, y) in mask or (t1 == 16 and y < 100):
                    px[x, y] = S(MOSS[0] if t1 == 8 else ('8c6545' if y % 2 else '7c4a26'))
    # vault arches in step 1
    for ax in (264, 377):
        for y in range(141, 157):
            for x in range(ax - 4, ax + 4):
                ddx = (x + 0.5 - ax) / 4
                if (y >= 145 or ddx * ddx + ((y - 145) / 4) ** 2 <= 1) and (x, y) in mask:
                    edge = abs(ddx) > 0.62 or (y < 145 and ddx * ddx + ((y - 145) / 4) ** 2 > 0.5)
                    px[x, y] = S('8e7f5e' if edge else '1d2925')
    # 3. the Stack, everything above the Low Reel deck
    a = 17 * PPT
    for x in range(290, 384):
        dx = x + 0.5 - CX
        base = arc(16, a, dx)
        if base is None:
            continue
        f = (dx + a) / (2 * a)
        for y in range(0, int(math.ceil(base))):
            ramp = zone_ramp(y, x, 'stack')
            i = shade_idx(f)
            c = ramp[i]
            ry = base - y
            if int(ry) % 5 == 0 and f < 0.4:
                c = ramp[min(4, i + 1)]
            px[x, y] = S(c)
    # window rows, one per story (4 tiles), 2 x 3 px, some lit at dusk
    for xw in range(305, 384, 8):
        base = arc(16, a, xw + 0.5 - CX)
        for k in range(1, 9):
            yw = int(round(base - k * 4 * PPT + 3))
            on = hsh(xw, k) < 0.38
            for dy in range(3):
                for dxw in range(2):
                    yy, xx = yw - dy, xw + dxw
                    if 0 <= yy < 216 and xx < 384:
                        col = (WARM[0] if dy == 2 else WARM[1]) if on else ('1e302e' if yy < 60 else '303e37')
                        if yy < 30 and on:
                            col = WARM[2]
                        px[xx, yy] = S(col)
            for dxw in range(-1, 3):
                if 0 <= yw + 1 < 216 and xw + dxw < 384:
                    px[xw + dxw, yw + 1] = S(zone_ramp(yw, xw, 'stack')[0])
    # Low Reel rail, sheaves and route lanterns on step 2's rim
    a2 = 21 * PPT
    for x in range(272, 384):
        dx = x + 0.5 - CX
        r = arc(16, a2, dx)
        if r is None:
            continue
        yr = int(math.ceil(r))
        for y in (yr - 3, yr - 2):
            if 0 <= y < 216:
                px[x, y] = S(BRASS[1] if y == yr - 3 else BRASS[3])
        if x % 6 == 0:
            px[x, yr - 1] = S(BRASS[3])
            px[x, yr - 4] = S(BRASS[0])     # a sheave
        if x % 12 == 4 and x < 368:
            lit_l = x not in (304, 340)
            for dy in range(2):
                if (x, yr + 1 + dy) in mask or True:
                    px[x, yr + 1 + dy] = S((WARM[0] if dy == 0 else WARM[2]) if lit_l else '5f5e57')
    # 4. the root, 5 tiles at the ground, climbing the west face (behind the depot, in front of the stone)
    redge = {}
    for y in range(0, FOOT + 1):
        t = (FOOT - y - 0.5) / PPT
        rw = root_w(t) * PPT
        rc = CX + root_cx(t) * PPT
        nl = int(round(1.2 * math.sin(y / 6.3) + 0.8 * math.sin(y / 2.7 + 1)))   # knobbly bark, not a pole
        nr = int(round(1.0 * math.sin(y / 5.1 + 2) + 0.7 * math.sin(y / 3.3)))
        xa, xb = int(round(rc - rw / 2)) + nl, int(round(rc + rw / 2)) + nr
        if y < 53:
            xa = max(xa, 291)   # clear of the wordmark
        redge[y] = xb
        for x in range(xa, xb):
            if y >= 100 and not ((x, y) in mask or x < 300):
                continue
            if y >= 100 and x >= 300:
                continue
            g = (x + 0.5 - xa) / (xb - xa)
            c = ROOT_RAMP[0 if g < 0.18 else 1 if g < 0.45 else 2 if g < 0.75 else 3 if g < 0.92 else 4]
            fis = (x - xa + int(2 * math.sin(y / 9.0 + x))) % 6 == 0 and 0.15 < g < 0.85
            if fis:
                c = ROOT_RAMP[min(4, ROOT_RAMP.index(c) + 1)]
            if g < 0.35 and hsh(x // 3, y // 5) < 0.12:
                c = MOSS[0]
            if abs(t - 16) < 0.3:
                c = BRASS[1] if g < 0.6 else BRASS[2]
            if y < 60:   # the high root fades into the dusk with the stone
                c = mix(c, '43665a', 0.35 if y >= 30 else 0.55)
            px[x, y] = S(c)
    # its cast shadow on the stone, and rootlets gripping the face (above the Low Reel)
    for y, xb in redge.items():
        if y < 88:
            for x in (xb, xb + 1):
                if x < 384:
                    px[x, y] = S(mix(px[x, y], '1d2925', 0.45 if x == xb else 0.25))
    for y0, L, rise in ((12, 24, -0.32), (40, 17, 0.22), (70, 21, -0.28)):
        xs = redge[y0] - 2
        for i in range(L):
            u = i / L
            yc = int(round(y0 + rise * i + 1.2 * math.sin(i / 3.0)))
            tk = max(1, int(round(3.4 * (1 - 0.7 * u))))
            for k in range(tk):
                yy, xx = yc + k, xs + i
                if 0 <= yy < 216 and xx < 384:
                    c = ROOT_RAMP[1] if k == 0 else ROOT_RAMP[2] if k < tk - 1 else ROOT_RAMP[3]
                    if yy < 60:
                        c = mix(c, '43665a', 0.35 if yy >= 30 else 0.55)
                    px[xx, yy] = S(c)
            if 0 <= yc + tk < 216 and xs + i < 384:
                px[xs + i, yc + tk] = S(mix(px[xs + i, yc + tk], '1d2925', 0.4))
    # its ground run, arriving from the west behind the last house
    xr = CX + root_cx(0) * PPT
    for x in range(250, int(xr)):
        u = (x - 250) / (xr - 250)
        h = int(round(4 + 8 * u ** 1.4))
        for k in range(h):
            y = FOOT - 1 - k
            if (x, y) in mask or bp[x, y] in (hx('c49b69'), hx('b06b3d'), hx('7c4a26'), hx('663f23'), hx('3f2716'),
                                               hx('8c6545'), hx('92724b')):
                px[x, y] = S(ROOT_RAMP[0 if k == h - 1 else 1 if k > h * 0.5 else 2 if k > 1 else 3])
    # 5. a low evening cloud the Stack runs into, near the top
    sky_t = lambda y: bp[200, y]
    # sunset light catches the undersides, so they read against the dusk stone
    paint_wisps(img, S, [(346, 16, 52, 2.6), (370, 41, 24, 1.5)], sky_t, 0.0,
                cols=['8e7f5e', 'c7a378', 'eeb970'])
    # 6. the town's waylines from the Low Reel's west sheaves (coded in game; drawn here to show the fan)
    for p0, p1, sag in (((292, 92), (248, 146), 5), ((306, 96), (204, 147), 8), ((324, 99), (160, 146), 11)):
        draw_wayline(img, S, p0, p1, sag, '1d2925', 'a37a32', tag='2d9e9f', tag_every=12)
    save(img, 'title', "on Codex's cx-15 candidate; palette highbank_title")


# ------------------------------------------------------------------------------------------------ 3. vista
def mock_vista():
    base = to1x(R2 + '13_road_vista.png')
    img = base.copy()
    px, bp = img.load(), base.load()
    tower_bits = ['c49b69', 'b06b3d', '663f23', '3f2716', 'd4a94c', 'a37a32', 'fbd490', 'f1c177', 'e6c697',
                  'f5d9a8', '9c8c68', '8e7f5e', '5f5e57', '908940', '2d9e9f', '7c4a26', '5d4b34']
    S = Snap(load_pal('dawn.png') + [hx(c) for c in tower_bits])
    slope = bp[100, 212]
    last_land = bp[150, 126]
    # clear the old tower, its lines and the ring of houses
    for y in range(0, 212):
        x1 = 350 if y < 104 else 368
        if y < 126:
            for x in range(150, x1):
                px[x, y] = bp[150 + ((x - 150) % 50), y]
        else:
            # the row's own land colour from the untouched land west of the clearing (green only, no roofs)
            # (lit land only, so tree trunks and shadow rows cannot win; rows with none carry the last land colour)
            row = [bp[x, y] for x in range(0, 150)
                   if bp[x, y] != slope and bp[x, y][1] > bp[x, y][0] and lum(bp[x, y]) > 75]
            if row:
                last_land = Counter(row).most_common(1)[0][0]
            mode = last_land
            edge = max([x for x in range(0, 330) if bp[x, y] == slope] or [-1])
            for x in range(max(150, edge + 1), x1):
                px[x, y] = mode
    sky_at = lambda y: bp[160, max(0, min(124, y))]
    CX, FOOT, PPT = 268, 170, 1.0 / 3
    hz = lambda t: 0.04 + 0.22 * t / H_T
    # the river along the town's south and the bluff
    river_x0 = max([x for x in range(0, 330) if bp[x, 183] == slope] or [149]) + 1   # it slips behind the hill
    for x in range(river_x0, 368):
        for y in range(182, 185):
            px[x, y] = S('12837f' if y == 183 else '8da2aa' if y == 182 else '556c83')
        px[x, 181] = S('5c7149')
    # the general cloud layer, a few flat clouds level with the collar
    paint_wisps(img, S, [(118, 66, 16, 2), (176, 58, 9, 1.5), (338, 70, 11, 1.6)], sky_at, 0.25)
    # the long lines leaving the stations (bonus, broken)
    for side, end in ((-1, (176, 112)), (1, (346, 113))):
        draw_wayline(img, S, (int(CX + side * 5), int(FOOT - 208 * PPT)), end, 6, '4b5350', None, dotted=True)
    paint_collar(img, S, CX, FOOT, PPT, 'back', sky_at, 0.12)
    top = paint_far_tower(img, S, CX, FOOT, PPT, sky_at, hz, lit=0.0, crown=CROWN_3)
    paint_collar(img, S, CX, FOOT, PPT, 'front', sky_at, 0.12)
    # Highbank at the foot: roofs and walls 2 x 3 px, a few lamps still lit at dawn
    rnd = random.Random(4)
    spots = []
    for _ in range(140):
        x = int(rnd.gauss(CX - 12, 14))
        y = int(rnd.gauss(FOOT + 4, 3.2))
        if abs(x - CX) < 10 and y < FOOT + 2:
            continue
        if 226 <= x <= 304 and FOOT - 3 <= y <= FOOT + 9 and all(abs(x - a) > 3 or abs(y - b) > 2 for a, b in spots):
            spots.append((x, y))
    for x, y in sorted(spots, key=lambda p: p[1]):   # 3 px houses: roof row, wall row, a lit window or two
        for dx in range(3):
            px[x + dx, y] = S('b06b3d' if dx < 2 else '7c4a26')
            px[x + dx, y + 1] = S('f5d9a8' if dx == 0 else 'e6c697' if dx == 1 else 'c49b69')
        px[x + 1, y + 2] = S('5d4b34')
        if rnd.random() < 0.35:
            px[x + 1, y + 1] = S('fbd490')
    save(img, 'vista', 'road.backdrop.vista re-brief, 1 px = 3 tiles')


# ------------------------------------------------------------------------------------------------ 4. door lean
def mock_door():
    base = to1x(R2 + '02_rise_door_lean.png')
    img = base.copy()
    px, bp = img.load(), base.load()
    S = Snap(load_pal('wayline_tower.png') + load_pal('town_stone.png'))
    RX = 60   # the depot's west wall in this view; the main root passes behind it

    def is_line(c):
        r, g, b = c
        return (r > 175 and g > 140 and b < 120 and r - b > 80)
    lines = {(x, y): bp[x, y] for y in range(216) for x in list(range(0, RX + 2)) + list(range(340, 384))
             if is_line(bp[x, y])}
    # the main root: 5 tiles thick, comes in from the west and climbs the plinth behind the depot
    for y in range(0, 216):
        bot = 166 + int(round(3 * math.sin(0.0)))
        for x in range(0, RX):
            ybot = 164 + int(round(3 * math.sin(x / 9.0)))
            if y > ybot:
                continue
            xr = 50 + (175 - y) * 0.05
            if x > xr:
                continue
            g = (x + 62) / (xr + 62)   # its west half is off screen
            i = 0 if g < 0.2 else 1 if g < 0.48 else 2 if g < 0.8 else 3 if g < 0.93 else 4
            if y > ybot - 12:          # its south flank curving under
                i = min(4, i + 1 + (1 if y > ybot - 5 else 0))
            c = ROOT_RAMP[i]
            for f0 in (6, 19, 31, 43):
                if x == f0 + int(round(2 * math.sin(y / 17.0 + f0))):
                    c = ROOT_RAMP[min(4, i + 1)]
                if x == f0 - 1 + int(round(2 * math.sin(y / 17.0 + f0))) and i > 0:
                    c = ROOT_RAMP[i - 1]
            for (kx, ky) in ((20, 58), (38, 128), (10, 98)):
                d = ((x - kx) / 5.0) ** 2 + ((y - ky) / 4.0) ** 2
                if d <= 1:
                    c = ROOT_RAMP[3] if d > 0.45 else ROOT_RAMP[1]
            if x < 22 and hsh(x // 4, y // 6) < 0.22 and y < ybot - 14:
                c = MOSS[0] if hsh(x, y) < 0.6 else MOSS[1]
            if any(abs(y - ty) <= 1 and 21 + (ty % 3) <= x <= 33 + (ty % 3) for ty in (148, 120, 92, 64, 36, 8)):
                c = '8c6545' if any(y == ty - 1 for ty in (148, 120, 92, 64, 36, 8)) else '6b4f1f'   # treads
            px[x, y] = S(c)
        # contact shadow on the turf under the flank, and rootlets into it
    for x in range(0, RX):
        ybot = 164 + int(round(3 * math.sin(x / 9.0)))
        for y in (ybot + 1, ybot + 2):
            if y < 216:
                r, g, b = bp[x, y]
                px[x, y] = S((int(r * 0.7), int(g * 0.7), int(b * 0.72)))
        if x in (9, 33, 51):
            for k in range(1, 10):
                xx = x + (k // 4)
                if ybot + k < 216:
                    px[xx, ybot + k] = S(ROOT_RAMP[2] if k < 6 else ROOT_RAMP[3])
    # the rootlet (today's root vein) leaves the main root's flank and climbs the depot's corner
    for y in range(76, 104):
        for x in range(46, 64):
            d = abs((x - 46) - (103 - y) * 0.62)
            if d < 5 - (103 - y) * 0.06:
                px[x, y] = S(ROOT_RAMP[1] if d < 2 else ROOT_RAMP[2])
    # the plinth: boulder footing at row 4 and limestone blocks above it, top right
    for y in range(0, 50):
        for x in range(347, 384):
            c0 = bp[x, y]
            if not (c0[1] > c0[0] and c0[1] > c0[2] and c0[1] > 70) and not is_line(c0):
                continue
            if y >= 37:   # boulders
                bx = (x - 347) // 9
                cxb, cyb = 347 + bx * 9 + 4.5, 44
                d = ((x + 0.5 - cxb) / 5.2) ** 2 + ((y + 0.5 - cyb) / 6.5) ** 2
                c = '9b8a69' if d < 0.35 else '8e7f5e' if d < 0.8 else '5f5e57'
                if y in (37, 38) and d < 1:
                    c = MOSS[0] if y == 37 else MOSS[1]
                if y > 46:
                    c = '5d4b34'
            else:
                course = (36 - y) // 12
                ry = (36 - y) % 12
                jx = (x - 347 + (12 if course % 2 else 0)) % 24
                c = 'ccb290' if ry > 8 else '9b8a69' if ry > 1 else '8e7f5e'
                if jx == 0 or ry == 0:
                    c = '5f5e57'
                if ry == 11 and hsh(x // 3, course) < 0.5:
                    c = MOSS[0]
            px[x, y] = S(c)
    # the Long Lift's rails up the plinth, a cabin waiting
    for y in range(0, 37):
        for x in (366, 367, 377, 378):
            px[x, y] = S(BRASS[3] if x in (366, 377) else BRASS[2])
        if y % 12 == 3:
            for x in range(366, 379):
                px[x, y] = S(BRASS[3])
    for y in range(8, 24):
        for x in range(368, 377):
            edge = y in (8, 23) or x in (368, 376)
            px[x, y] = S('6b4f1f' if edge else ('fbd490' if 12 <= y <= 16 and 370 <= x <= 374 else '8c6545'))
    for (x, y), c in lines.items():   # the waylines draw over the world
        px[x, y] = c
        if y + 1 < 216 and not is_line(bp[x, y + 1]):
            px[x, y + 1] = S('0b0e11')
    save(img, 'door_lean', 'Tower Rise doors, 72 px lean, from round2/02')


# ------------------------------------------------------------------------------------------------ 5. street band
def mock_street():
    src = to1x(R2 + '06_street_wayline.png')
    img = src.copy()
    px, sp = img.load(), src.load()
    S = Snap(load_pal('dawn.png') + load_pal('wayline_tower.png'))
    BAND = 72
    # where 06's wayline crosses the band's foot
    hits = [x for x in range(384) for y in range(BAND, BAND + 3)
            if sp[x, y][0] > 175 and sp[x, y][1] > 140 and sp[x, y][2] < 130]
    line_x = int(sum(hits) / len(hits)) if hits else 214
    SKYB = [(0, '6c8b96'), (12, '738f97'), (24, '8da2aa'), (36, '9cabb1'), (46, 'bdbdb5'), (54, 'e2c59b')]

    def sky_at(y):
        c = SKYB[0][1]
        for y0, cc in SKYB:
            if y >= y0:
                c = cc
        return c
    for y in range(BAND):
        for x in range(384):
            c = sky_at(y)
            if y in (11, 23, 35, 45, 53) and (x + y) % 2:
                c = sky_at(y + 1)
            px[x, y] = S(c)
    # far ridge
    for x in range(384):
        rt = 56 + int(round(3 * math.sin(x / 23.0) + 2 * math.sin(x / 7.3)))
        for y in range(rt, BAND):
            px[x, y] = S('7a8d81' if y < rt + 2 else '5e6f63')
    # the Tower as a far layer: 1 px = 2/3 tile, axis at parallax 0.15 from the camera
    CX, FOOT, PPT = 236, 72, 1.5
    hz = lambda t: 0.10 + 0.22 * min(1, t / 48)
    paint_far_tower(img, S, CX, FOOT, PPT, sky_at, hz, lit=0.0, keep=lambda x, y: y < 70)
    # the town lines fan down from the Low Reel to the band's foot and on to 06's own line
    reel_y = int(FOOT - 16 * PPT) + 1
    for p0, p1, sag in (((CX - 22, reel_y), (line_x, BAND + 1), 4), ((CX - 26, reel_y), (96, BAND), 6),
                        ((CX + 20, reel_y + 1), (330, BAND), 4)):
        draw_wayline(img, S, p0, p1, sag, '23180e', 'd4a94c', tag='2d9e9f', tag_every=10)
    # the Street's north hedge along the band's foot
    for x in range(384):
        ht = 66 + (1 if hsh(x // 3, 2) < 0.5 else 0)
        for y in range(ht, 75):
            c = '75895d' if y == ht else '516b38' if y < 70 else '3e5629' if y < 73 else '2f372a'
            if hsh(x // 2, y // 2) < 0.2 and y > ht:
                c = '5c7149'
            px[x, y] = S(c)
    # the HUD panels slid up during the look (as on the Rise); the bottom-right buttons stay
    save(img, 'street_band', 'far band over the north edge (proposal), from round2/06')


# ------------------------------------------------------------------------------------------------ 6. top hold
def mock_hold():
    S = Snap(load_pal('dawn.png'))
    img = Image.new('RGB', (384, 216))
    px = img.load()
    HZ = 156
    # the pale bands are pressed down to the horizon so the lamp (y 127) sits in blue sky and its glow reads
    BANDS_Y = [(0, '2e3b52'), (20, '3c4d56'), (40, '4a5e73'), (60, '4d6582'), (78, '556c83'), (96, '5d758f'),
               (112, '6c8b96'), (126, '738f97'), (136, '8da2aa'), (144, '9cabb1'), (149, 'bdbdb5'), (153, 'e2c59b')]

    def sky_at(y):
        c = BANDS_Y[0][1]
        for y0, cc in BANDS_Y:
            if y >= y0:
                c = cc
        return c
    for y in range(216):
        for x in range(384):
            c = sky_at(y)
            if any(y == y0 - 1 for y0, _ in BANDS_Y[1:]) and (x + y) % 2:
                c = sky_at(y + 1)
            px[x, y] = S(c)
    # thin high streaks
    paint_wisps(img, S, [(70, 30, 30, 1), (300, 52, 40, 1), (150, 78, 26, 1)], sky_at, 0.55)
    # the cloud sea: far rows small and flat at the horizon, near rows big
    for y in range(HZ, 216):
        for x in range(384):
            px[x, y] = S('9cabb1')
    for x in range(384):   # the horizon line, far land under haze
        px[x, HZ] = S('8da2aa')
        px[x, HZ - 1] = S('bdbdb5') if x % 2 else px[x, HZ - 1]
    rnd = random.Random(11)
    # the cloud sea: clusters of lumps with lower cloud showing between them, far rows small, near rows big
    lumps = []
    y, r = HZ + 2, 1.3
    while y < 236:
        x = -rnd.uniform(0, r * 3)
        while x < 384 + r * 3:
            n = rnd.randint(2, 5)
            for k in range(n):
                s = r * rnd.uniform(0.55, 1.5)
                lumps.append((x + k * r * 1.5 + rnd.uniform(-r * 0.3, r * 0.3),
                              y + rnd.uniform(-r * 0.3, r * 0.2) - (s - r) * 0.6, s))
            x += n * r * 1.5 + r * rnd.uniform(1.2, 4.5)
        y += r * 0.8 + 1
        r *= 1.3
    # a few towering heads standing up out of the sea, away from the crown
    for hx_, by, hgt, wid in ((44, 176, 34, 17), (342, 170, 24, 12), (124, 166, 12, 8)):
        j, yy = 0, by
        while yy > by - hgt:
            lumps.append((hx_ + rnd.uniform(-wid * 0.18, wid * 0.18), yy, wid * (0.62 - 0.28 * (by - yy) / hgt)))
            yy -= wid * 0.33
            j += 1
    # thin, ragged gaps down to the land, one with the river's glint: (x, y, half width, river)
    gaps = [(70, 190, 15, False), (262, 204, 22, True), (356, 181, 9, False)]
    lumps.sort(key=lambda l: l[1])
    gi = 0

    def draw_gap(gx, gy, gw, river):
        for xx in range(gx - gw, gx + gw + 1):
            u = abs(xx - gx) / gw
            th = 1 + (1 if u < 0.55 else 0) + (1 if u < 0.3 and hsh(xx // 3, gy) < 0.5 else 0)
            y0 = gy + int(round(1.1 * math.sin(xx / 4.0) + 0.6 * math.sin(xx / 1.7)))
            for k in range(th):
                if 0 <= xx < 384 and 0 <= y0 + k < 216:
                    px[xx, y0 + k] = S('2f372a' if k else '3c532b')
            if river and u < 0.6 and th > 1 and xx % 3:
                px[xx, y0 + 1] = S('12837f')
    for lx, ly, rr in lumps:
        while gi < len(gaps) and ly > gaps[gi][1] + 2:
            draw_gap(*gaps[gi])
            gi += 1
        for yy in range(int(ly - rr) - 1, int(ly + rr) + 2):
            for xx in range(int(lx - rr * 1.5) - 1, int(lx + rr * 1.5) + 2):
                if not (0 <= xx < 384 and HZ - 40 <= yy < 216):
                    continue
                dx, dy = (xx + 0.5 - lx) / (rr * 1.5), (yy + 0.5 - ly) / rr
                if dx * dx + dy * dy <= 1:
                    lit = dy - 0.35 * dx   # low sun from the west
                    k = 'f5e4bd' if lit < -0.55 else 'e2c59b' if lit < -0.1 else 'bdbdb5' if lit < 0.4 else \
                        '9cabb1' if lit < 0.8 else '8da2aa'
                    px[xx, yy] = S(k)
    while gi < len(gaps):
        draw_gap(*gaps[gi])
        gi += 1
    # the lamp's coded glow: three steps of warm light behind the glass
    LX, LY = 192, 127
    for rad, col, amt in ((18, 'e2c59b', 0.45), (12, 'eeb970', 0.6), (7, 'f5e4bd', 0.8)):
        for yy in range(LY - rad, LY + rad + 1):
            for xx in range(LX - rad, LX + rad + 1):
                if (xx - LX) ** 2 + (yy - LY) ** 2 <= rad * rad and 0 <= yy < 216:
                    px[xx, yy] = S(mix(px[xx, yy], col, amt))
    # Codex's crown (cx-14 assembled reference), at today's hold offset: frame + (-24, 9)
    crown = Image.open(CROWN_REF).convert('RGBA')
    cp = crown.load()
    for fy in range(0, 216 - 9):
        for fx in range(24, 408):
            c = cp[fx, fy]
            if c[3] > 128:
                px[fx - 24, fy + 9] = c[:3]
    save(img, 'top_hold', "reveal hold above the cloud sea; crown is Codex's cx-14 reference")


# ------------------------------------------------------------------------------------------------ run
if __name__ == '__main__':
    mock_elevation()
    mock_title()
    mock_vista()
    mock_door()
    mock_street()
    mock_hold()
    for k, (size, n, note) in REPORT.items():
        print(f'{k:12s} {size[0]}x{size[1]}  {n:4d} colours  {note}')
    # a review sheet for checking by eye (scratch, not part of the design folder)
    shots = [Image.open(f'{OUT}/{k}_1x.png') for k in ('title', 'vista', 'door_lean', 'street_band', 'top_hold')]
    sheet = Image.new('RGB', (384 * 2 + 4, 216 * 3 + 8), (255, 0, 255))
    for i, s in enumerate(shots):
        sheet.paste(s, ((i % 2) * 388, (i // 2) * 220))
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(SCRATCH + '/vast_review.png')
