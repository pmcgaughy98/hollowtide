"""Final mocks for VAST_SCALE_DESIGN.md: the two giants of Highbank, side by side.

The Wayline Tower at 480 tiles (the tower designer's numbers, kept) and the great tree at 400 tiles,
340 tiles north-west of the Tower (the skyline reading's place, grown so its crown breaks the cloud sea).
Every number here is a proposal. Reads the repo, writes only into this folder.

Run:  python final_mocks.py            all mocks (about a minute)
      python final_mocks.py title      one of: title title_b road_far vista door street hold arrival
                                       elevation influence map reveal

Mocks (each _1x.png and _3x.png, nearest neighbour):
  title      Codex's cx-15 candidate: the round Stack behind the depot, the great tree behind the town
  vista      the road home: the whole Tower in one frame, looking up from the last hill; the tree to its left
  door_lean  the Tower Rise doors with today's 72 px lean (round2/02): the main root, plinth footing, the lift
  street     the Street's north rows (round2/06b) with the far band over the roofs (option B1)
  hold       the top of the reveal above the cloud sea, the tree's crown breaking it below to the left
  arrival    arriving at the tree (the tree-skyline base, its hanging vines removed)
  elevation  both giants side by side at 1 px = 1 tile, and the two feet at 3 px a tile
  influence  the tree around town, painted over four game captures
  map        top down, 1 px = 4 tiles, scale bar in tiles
"""
import math
import random
import inspect
import importlib.util
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
DOCS = ROOT + '/docs'
HERE = DOCS + '/design/vast-scale-2026-10-27'
OUT = HERE + '/final'
PALS = DOCS + '/design/placeholder-factory-2026-10-26/refs/palettes/'
R2 = DOCS + '/design/wayline-tower-2026-10-27/build/round2/'
CAND = DOCS + '/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/prepared.png'
CROWN_REF = DOCS + '/art/slot-candidates/cx-14-tower-crown/static-assembled-reference.png'
BLOCKOUT = DOCS + '/design/wayline-tower-2026-10-27/build/assembled_blockout.png'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
SKYLINE_PY = HERE + '/tree-skyline/mock_tree-skyline.py'
REPORT = {}


# ------------------------------------------------------------------------------------------ helpers
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
    """Nearest colour in a fixed palette, so every painted pixel is a palette colour."""
    def __init__(self, *pals):
        seen = []
        for p in pals:
            for c in p:
                c = rgb(c)
                if c not in seen:
                    seen.append(c)
        self.pal = seen
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


def hn(x, y, s=0):
    n = (int(x) * 374761393 + int(y) * 668265263 + int(s) * 982451653) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535.0


def vn(x, y, sc, s=0):
    """Smooth value noise, 0..1, feature size sc."""
    gx, gy = x / sc, y / sc
    x0, y0 = math.floor(gx), math.floor(gy)
    fx, fy = gx - x0, gy - y0
    fx = fx * fx * (3 - 2 * fx)
    fy = fy * fy * (3 - 2 * fy)
    a, b = hn(x0, y0, s), hn(x0 + 1, y0, s)
    c, d = hn(x0, y0 + 1, s), hn(x0 + 1, y0 + 1, s)
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy


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


FNT = ImageFont.truetype(FONT, 8)


def label(img, x, y, s, fg, bg=None):
    """1-bit text (no anti-aliasing), optional dark rim."""
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


def inside(W, H, x, y):
    return 0 <= x < W and 0 <= y < H


def catenary(p0, p1, sag, n=None):
    (x0, y0), (x1, y1) = p0, p1
    n = n or int(max(abs(x1 - x0), abs(y1 - y0)) * 1.5) + 2
    return [(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n + sag * 4 * (i / n) * (1 - i / n)) for i in range(n + 1)]


def line_px(px, W, H, pts, col, ok=None, dotted=0):
    seen = set()
    for (x, y) in pts:
        q = (int(round(x)), int(round(y)))
        if q in seen or not inside(W, H, *q):
            continue
        seen.add(q)
        if dotted and (len(seen) // dotted) % 2:
            continue
        if ok and not ok(*q):
            continue
        px[q] = col


def blob(px, W, H, S, cx, cy, rx, ry, col_fn, ok=None):
    for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if not inside(W, H, xx, yy) or (ok and not ok(xx, yy)):
                continue
            dx, dy = (xx + 0.5 - cx) / rx, (yy + 0.5 - cy) / ry
            if dx * dx + dy * dy <= 1:
                px[xx, yy] = S(col_fn(dx, dy, xx, yy))


def cloud_col(dx, dy, light=-1):
    lit = -dy * 0.8 + dx * 0.5 * light
    return 'f5e5c0' if lit > 0.5 else 'e2c59b' if lit > 0.05 else 'bdbdb5' if lit > -0.45 else '9cabb1'


# ------------------------------------------------------------------------------------------ camera
class Proj:
    """Pinhole camera looking north and pitched up by theta (radians). h: tiles up; X: tiles across;
    dz: extra depth in tiles beyond the camera's distance D to the Tower. Level: Proj.level(ppt, ax, foot)."""
    def __init__(self, f, cx, cy, D, theta=0.0, cam_h=0.0):
        self.f, self.cx, self.cy, self.D, self.cam_h = f, cx, cy, D, cam_h
        self.ct, self.st = math.cos(theta), math.sin(theta)

    @classmethod
    def level(cls, ppt, ax, foot):
        return cls(ppt * 10000.0, ax, foot, 10000.0)

    def z(self, h, dz=0.0):
        return (self.D + dz) * self.ct + (h - self.cam_h) * self.st

    def sy(self, h, dz=0.0):
        return self.cy - self.f * ((h - self.cam_h) * self.ct - (self.D + dz) * self.st) / self.z(h, dz)

    def s(self, h, dz=0.0):
        return self.f / self.z(h, dz)

    def sx(self, X, h, dz=0.0):
        return self.cx + self.f * X / self.z(h, dz)

    def h_at(self, y, dz=0.0):
        lo, hi = -200.0, 900.0
        for _ in range(36):
            mid = (lo + hi) / 2
            if self.sy(mid, dz) > y:
                lo = mid
            else:
                hi = mid
        return (lo + hi) / 2


# ------------------------------------------------------------------------------------------ the giants
# Wayline Tower (the tower designer's numbers, kept). Heights and widths in tiles of 24 px.
H_T, LAMP_T, CROWN_T = 480, 475, 461
BANDS = [(0, 8, 52, 'P1'), (8, 16, 42, 'P2'), (16, 114, 34, 'A'), (114, 210, 28, 'B'), (210, 296, 22, 'C'),
         (296, 344, 19, 'W'), (344, 404, 15, 'N'), (404, 458, 12, 'N'), (458, 461, 9.5, 'K')]
STATIONS = [112, 208, 292]
CLOUD_LAYER, COLLAR = (280, 360), (296, 344)
ROOT_GIRTH = [(0, 4.0), (16, 3.4), (114, 2.8), (210, 2.3), (296, 1.9), (344, 1.7), (461, 1.5)]

# The great tree (this design). Tiles. The Tower is at (0, 0); x east, n north.
TREE_DIST, TREE_BEAR = 340, -35.0
TREE_E = TREE_DIST * math.sin(math.radians(TREE_BEAR))       # about -195 (west)
TREE_N = TREE_DIST * math.cos(math.radians(TREE_BEAR))       # about 278 (north)
TREE_H, TRUNK_W, FLARE_W = 400, 100, 260
CROWN_W, CROWN_OFF, UNDER_C, UNDER_RIM = 440, 0, 165, 140   # crown centred on the trunk (Preston, 2026-10-28; was -65)
SPURS = ((-1, 150, 46), (-1, 108, 28), (1, 138, 40), (1, 100, 24))   # side, reach from the axis, height at the trunk
FOREST_W = 800

STONE = {  # lit, mid, shade, dark  (wayline_tower / town_stone colours)
    'P1': ['c7a378', '9c8c68', '8e7f5e', '5d4b34'], 'P2': ['ccb290', 'c7a378', '9c8c68', '5d4b34'],
    'A': ['e6c697', 'ccb290', 'c49b69', '8e7f5e'], 'B': ['f5d9a8', 'e6c697', 'ccb290', '9c8c68'],
    'C': ['f5d9a8', 'e6c697', 'c7a378', '92724b'], 'W': ['908940', '6b6d45', '5f5e57', '44421a'],
    'N': ['f5d9a8', 'e6c697', 'ccb290', '9c8c68'], 'K': ['f2d27a', 'd4a94c', 'a37a32', '6b4f1f']}
ROOTR = ['23180e', '3f2716', '663f23', '8c6545', 'b06b3d', 'c49b69']
MOSSR = ['44421a', '6b6f1d', '908940', 'c6bb2a']


def width_at(t):
    for a, b, w, m in BANDS:
        if a <= t < b:
            return w, m
    return 0, None


def girth_at(t):
    for (t0, g0), (t1, g1) in zip(ROOT_GIRTH, ROOT_GIRTH[1:]):
        if t0 <= t <= t1:
            return g0 + (g1 - g0) * (t - t0) / (t1 - t0)
    return ROOT_GIRTH[-1][1]


def paint_tower(px, W, H, S, P, X0, sky, haze0=0.1, haze1=0.5, light=1, lit_win=0.2, seed=3, collar=True,
                lamp_glow=False, ok=None, t_min=0.0, root=True, ystop=None):
    """The Wayline Tower through camera P, its axis X0 tiles across. Round shaft, cylinder shading,
    porthole windows climbing in a spiral (like Codex's drum), cornices every 3 stories, the Stations,
    the wet collar band, the neck, a simplified crown, and the great tree's root up the west side."""
    def hz(t, c, x, y):
        h = haze0 + (haze1 - haze0) * max(0.0, min(1.0, t / H_T))
        return S(mix(c, sky(x, y), h))

    def can(x, y):
        return inside(W, H, x, y) and (ok is None or ok(x, y))
    rnd = random.Random(seed)
    lumps = []
    if collar:
        for i in range(30):
            t = COLLAR[0] + rnd.uniform(0, COLLAR[1] - COLLAR[0])
            spread = 64 * max(0.15, 1 - abs(t - 320) / 26) ** 0.6
            lumps.append((rnd.uniform(-spread, spread), t, rnd.uniform(8, 14), rnd.random() < 0.5))

    def draw_lumps(front):
        for lx, lt, lr, back in lumps:
            if back == front:
                continue
            s = P.s(lt)
            cx, cy, r = P.sx(X0 + lx, lt), P.sy(lt), max(1.2, lr * s)
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r * 1.6) - 1, int(cx + r * 1.6) + 2):
                    if not can(xx, yy):
                        continue
                    dx, dy = (xx + 0.5 - cx) / (r * 1.6), (yy + 0.5 - cy) / r
                    if dx * dx + dy * dy > 1:
                        continue
                    if front and P.h_at(yy + 0.5) > COLLAR[0] + 24:
                        continue
                    px[xx, yy] = hz(lt, cloud_col(dx, dy, light), xx, yy)
    draw_lumps(False)
    y0 = max(0, int(P.sy(CROWN_T)) - 1)
    y1 = min(H, int(P.sy(t_min)) + 1) if ystop is None else ystop
    rows = {}
    for y in range(y0, y1):
        t = P.h_at(y + 0.5)
        if t < t_min or t > CROWN_T:
            continue
        w, m = width_at(t)
        if not w:
            continue
        s = P.s(t)
        ax = P.sx(X0, t)
        hw = w * s / 2
        rows[y] = (t, s, ax, hw)
        ramp = STONE[m]
        story = int(t // 4)
        tin = t % 4
        for x in range(int(round(ax - hw)), max(int(round(ax - hw)) + 1, int(round(ax + hw)))):
            if not can(x, y):
                continue
            u = max(-1.0, min(1.0, (x + 0.5 - ax) / max(hw, 0.5)))
            nz = math.sqrt(max(0.0, 1 - u * u))
            b = u * light * 0.72 + nz * 0.62
            k = 0 if b > 0.8 else 1 if b > 0.5 else 2 if b > 0.18 else 3
            c = ramp[k]
            if m in ('P1', 'P2'):
                # boulder footing on step 1, big ashlar on step 2
                if s >= 1.2 and ((t % 2.0) < 1.0 / s or hn(int((u + 3) * w / 3), int(t // 2), 5) < 0.0):
                    c = ramp[min(3, k + 1)]
                if m == 'P1' and t < 3 and vn(x, y, 3, 7) > 0.55:
                    c = '6b6d45' if k < 2 else '44421a'
            else:
                if s >= 2.0 and (t % 4) < 1.0 / s and k < 3:
                    c = ramp[k + 1]                                              # one faint line a story
                if (t % 12) < max(1.0, 1.2 / s) * 1.0 and m in 'ABCN':
                    c = ramp[max(0, k - 1)]                                      # cornice catches the light
                elif (t % 12) > 12 - 1.0 / s and m in 'ABCN':
                    c = ramp[min(3, k + 1)]
                # porthole windows on a spiral stair
                if m in 'ABCN' and 1.0 <= tin <= 2.8 and hn(story, 1, seed) < 0.8:
                    for kk in range(7):
                        ph = story * 0.55 + kk * (2 * math.pi / 7) + 0.3
                        cph = math.cos(ph)
                        if cph < 0.2:
                            continue
                        uk = math.sin(ph)
                        half = max(0.5, 0.75 * cph * s)
                        if abs((x + 0.5) - (ax + uk * hw)) < half:
                            if s < 1.2 and hn(story, kk, seed + 2) > 0.3:
                                continue
                            lit = hn(story, kk, seed + 9) < lit_win
                            c = 'fbd490' if lit else ('3f2716' if s >= 1.2 else ramp[3])
                            if s >= 2.5 and abs(tin - 1.9) < 0.6 / s and abs((x + 0.5) - (ax + uk * hw)) < 0.6:
                                c = 'f1c177' if lit else '5d4b34'                    # the cross bar
                if m == 'W' and vn(x, y, 3, 4) > 0.6:
                    c = '6b6f1d' if k < 2 else '44421a'
                if m in 'ABC' and (t % 12) > 9.5 and vn(x, t, 2.5, 11) > 0.78:
                    c = '908940' if k < 2 else '6b6d45'                              # moss under a cornice
            px[x, y] = hz(t, c, x, y)
        # cornice lip a pixel wider than the shaft
        if m in 'ABCN' and (t % 12) < 1.0 / s and s > 0.5:
            for x in (int(round(ax - hw)) - 1, int(round(ax + hw))):
                if can(x, y):
                    px[x, y] = hz(t, ramp[1], x, y)
    # era lips and the three Stations (ring balconies)
    for a, b, w, m in BANDS[:-1]:
        if b < t_min:
            continue
        y = int(round(P.sy(b)))
        s = P.s(b)
        hw = w * s / 2 + max(1, s)
        ax = P.sx(X0, b)
        col = '908940' if m in ('W', 'P1', 'P2') else 'd4a94c'
        for x in range(int(round(ax - hw)), int(round(ax + hw)) + 1):
            if can(x, y):
                px[x, y] = hz(b, col, x, y)
    for st in STATIONS:
        if st < t_min:
            continue
        w, _ = width_at(st)
        s = P.s(st)
        hw = (w + 10) * s / 2
        ax = P.sx(X0, st)
        y = int(round(P.sy(st)))
        th = max(1, int(round(1.0 * s)))
        for x in range(int(round(ax - hw)), int(round(ax + hw)) + 1):
            for dy in range(th + 1):
                col = ('f2d27a' if (x - ax) * light > 0 else 'd4a94c') if dy < th else '6b4f1f'
                if can(x, y + dy):
                    px[x, y + dy] = hz(st, col, x, y + dy)
            if s >= 1.5 and (x - int(ax)) % max(2, int(3 * s)) == 0:
                for dy in range(1, int(2 * s) + 1):
                    if can(x, y - dy):
                        px[x, y - dy] = hz(st, '6b4f1f', x, y - dy)
    # the root: one root of the great tree, up the west side to the crook
    if root:
        for y, (t, s, ax, hw) in rows.items():
            g = max(1.0, girth_at(t) * s)
            rc = ax - hw + g * (0.25 + 0.35 * (0.5 + 0.5 * math.sin(t / 37.0 + 1.3)))
            for x in range(int(round(rc - g / 2)), int(round(rc + g / 2)) + (0 if g >= 1.5 else 1)):
                if not can(x, y):
                    continue
                q = (x + 0.5 - rc) / max(g / 2, 0.5)
                c = ROOTR[4] if q * light > 0.35 and g >= 3 else ROOTR[2] if g >= 2 and q * light > -0.4 else ROOTR[1]
                if g >= 4 and vn(x, t * s, 3, 9) > 0.72 and q * light > -0.2:
                    c = MOSSR[1]
                if any(abs(t - e) < 0.8 / s + 0.4 for e in (16, 114, 210, 296, 344)):
                    c = 'd4a94c'                                        # brass bands where the builders tied it
                px[x, y] = hz(t, c, x, y)
    draw_lumps(True)

    # crown, simplified for far views: galleries, ring deck, the Reach crook, lamp, vane
    def blk(t0, t1, w, col, dx=0.0):
        for y in range(int(round(P.sy(t1))), int(round(P.sy(t0))) + 1):
            s = P.s(t0)
            ax = P.sx(X0 + dx, t0)
            for x in range(int(round(ax - w * s / 2)), int(round(ax + w * s / 2)) + 1):
                if can(x, y):
                    px[x, y] = hz(t0, col, x, y)
    blk(461, 466, 11, 'e6c697')
    blk(466, 467, 17, 'b06b3d')
    hook = [(-6, 467), (-6.5, 473), (-4, 478), (0, 479), (3, 477), (4, 475.5)]
    for (a0, b0), (a1, b1) in zip(hook, hook[1:]):
        for i in range(9):
            hh = b0 + (b1 - b0) * i / 8
            s = P.s(hh)
            xx = P.sx(X0 + a0 + (a1 - a0) * i / 8, hh)
            yy = int(round(P.sy(hh)))
            for ox in range(int(round(xx - 0.75 * s)), int(round(xx + 0.75 * s)) + 1):
                if can(ox, yy):
                    px[ox, yy] = hz(470, ROOTR[2], ox, yy)
    lx, ly = int(round(P.sx(X0 + 4, LAMP_T))), int(round(P.sy(LAMP_T))) + 1
    if lamp_glow:
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            if can(lx + dx, ly + dy):
                px[lx + dx, ly + dy] = S(mix(px[lx + dx, ly + dy], 'eeb970', 0.6))
    if can(lx, ly):
        px[lx, ly] = S('f5e4bd' if lamp_glow else 'd4a94c')
    vx = int(round(P.sx(X0 - 1, 479)))
    for y in range(int(round(P.sy(481))), int(round(P.sy(478))) + 1):
        if can(vx, y):
            px[vx, y] = hz(470, '6b4f1f', vx, y)


def tree_model(seed=5, crown_off=CROWN_OFF):
    """Leaf clumps (X, h, r) in tiles, drawn high first so lower clumps show their lit tops."""
    rnd = random.Random(seed)
    hw = CROWN_W / 2
    cl = []

    def under(d):
        return UNDER_C - (UNDER_C - UNDER_RIM) * d * d

    def top(d):
        return UNDER_RIM + (TREE_H - UNDER_RIM) * math.sqrt(max(0.0, 1 - d * d))
    # every clump stays inside the crown's width (440) and above its underside (140 to 165)
    def fit(d, r):
        off = max(-(hw - r), min(hw - r, d * hw))
        return crown_off + off, off / hw
    for i in range(90):
        d = rnd.uniform(-0.93, 0.93)
        r = rnd.uniform(26, 46)
        X, d = fit(d, r)
        lo, hi = under(d) + r, top(d) - r
        if hi > lo:
            cl.append((X, rnd.uniform(lo, hi), r))
    for i in range(26):
        d = -math.cos(math.pi * (i + 0.5) / 26)
        r = rnd.uniform(22, 36)
        X, d2 = fit(d, r)
        cl.append((X, max(under(d2) + r, top(d2) - r), r))
    for i in range(22):
        d = -0.94 + 1.88 * (i + 0.5) / 22
        r = rnd.uniform(15, 27)
        X, d2 = fit(d + rnd.uniform(-6, 6) / hw, r)
        cl.append((X, under(d2) + r, r))
    cl.sort(key=lambda c: -c[1])
    limbs = [([(-6, 112), (-30, 132), (-70, 150), (-110, UNDER_C + 4)], 26, 12),
             ([(8, 120), (34, 140), (70, 156), (96, UNDER_C + 2)], 22, 10),
             ([(0, 128), (-12, 150), (-34, 172)], 20, 12),
             ([(-20, 125), (-60, 136), (-150, UNDER_RIM + 10)], 14, 8)]
    return cl, limbs


def trunk_hw(h):
    if h >= 45:
        return TRUNK_W / 2 - 5 * (h - 45) / 130
    return TRUNK_W / 2 + (FLARE_W / 2 - TRUNK_W / 2) * ((45 - h) / 45) ** 2.4


class Dome:
    """The crown as one even dome on screen (2026-10-28, Preston: the vista's crown top was "a little too uneven").
    Sized from camera P: 440 tiles across at its widest line (BELLY tiles over the rim, 170 up), its top at 400, its
    lowest leaves at the rim (140), the underside rising to 165 where the trunk goes in. Drawn level and symmetric
    on screen, so a camera looking up does not lean it. Above the widest line a half ellipse; below it a shallow
    half ellipse (the belly), so the sides round under. Small leaf breaks all round the top (a rounded bump about
    every a/9 px, leaf_d px deep at the notch) and hanging lobes under the belly (lobe_d px)."""
    BELLY = 30.0

    def __init__(self, P, X0, dz, crown_off=CROWN_OFF, seed=5, leaf_d=2.0, lobe_d=2.0):
        hw = CROWN_W / 2
        hwid = UNDER_RIM + self.BELLY
        xl = P.sx(X0 + crown_off - hw, hwid, dz)
        xr = P.sx(X0 + crown_off + hw, hwid, dz)
        self.cx, self.a = (xl + xr) / 2, (xr - xl) / 2
        self.yw = P.sy(hwid, dz)                         # the widest line
        self.yr = P.sy(UNDER_RIM, dz)                    # the lowest leaves
        self.b = self.yw - P.sy(TREE_H, dz)
        self.c = self.yr - self.yw
        self.notch = self.yr - P.sy(UNDER_C, dz)
        self.seed, self.leaf_d, self.lobe_d = seed, leaf_d, lobe_d
        self.leaf_p, self.lobe_p = max(5.0, self.a / 9.0), max(7.0, self.a / 6.5)
        self.x0, self.x1 = int(self.cx - self.a) - 1, int(self.cx + self.a) + 2
        self.y0, self.y1 = int(self.yw - self.b) - 1, int(self.yr + lobe_d) + 2

    def upper(self, x, y):
        """Inside the top half ellipse, less a leaf break: bumps every leaf_p px along the arc, all the way round."""
        nx, ny = (x + 0.5 - self.cx) / self.a, (self.yw - y - 0.5) / self.b
        rho = math.hypot(nx, ny)
        if rho >= 1.0:
            return False
        arc = math.atan2(ny, nx) * (self.a + self.b) / 2
        u = arc / self.leaf_p + 0.5 + 0.25 * (vn(arc, 0, 30, self.seed) - 0.5)
        f = u - math.floor(u) - 0.5                      # -0.5 .. 0.5 across one leaf bump, 0 on its crest
        return rho <= 1.0 - self.leaf_d * (2 * f) ** 2 / ((self.a + self.b) / 2)

    def bottom(self, x):
        """The underside: the belly's half ellipse, raised in the middle where the trunk goes in, hanging lobes."""
        d = (x + 0.5 - self.cx) / self.a
        if abs(d) >= 1.0:
            return self.yw
        lobes = self.lobe_d * abs(math.sin(math.pi * (x + 0.5 - self.cx) / self.lobe_p + 0.6))
        return self.yw + (self.c + lobes) * math.sqrt(1 - d * d) - self.notch * math.exp(-(d / 0.3) ** 2)

    def __call__(self, x, y):
        if abs(x + 0.5 - self.cx) >= self.a or y + 0.5 > self.bottom(x):
            return False
        return y + 0.5 > self.yw or self.upper(x, y)

    def rim(self, x, y, light):
        """An edge pixel of the dome facing up or toward the light (light -1: the left, 1: the right)."""
        return self(x, y) and (not self(x, y - 1) or not self(x + (1 if light > 0 else -1), y))

    def gd(self, x):
        return (x + 0.5 - self.cx) / self.a          # -1 at the left edge, 1 at the right

    def gv(self, y):
        return (self.yr - y - 0.5) / (self.yr - self.yw + self.b)   # 0 at the lowest leaves, 1 at the top


def paint_tree(px, W, H, S, P, X0, dz, ok, pal, sky, haze=0.0, light=1, calm=None, seed=5, crown_off=CROWN_OFF,
               forest=True, crown_haze=None, dome=False):
    """The great tree through camera P: axis X0 tiles across, dz tiles deeper than the Tower.
    ok(x, y) says where it may paint (behind nearer things). pal: colour lists dark to light.
    dome: the crown is one even dome (crown_top, crown_bottom) filled solid, its clumps kept inside it."""
    ch = haze if crown_haze is None else crown_haze

    def put(x, y, c, hh=haze):
        px[x, y] = S(mix(c, sky(x, y), hh))

    def quiet(x, y):
        return calm and calm[0] <= x < calm[2] and calm[1] <= y < calm[3]
    clumps, limbs = tree_model(seed, crown_off)
    # trunk (with its flare) row by row
    y_lo = int(P.sy(0, dz)) + 1
    y_hi = int(P.sy(190, dz))
    for y in range(max(0, y_hi), min(H, y_lo + 1)):
        h = P.h_at(y + 0.5, dz)
        if h < 0 or h > 190:
            continue
        s = P.s(h, dz)
        ax = P.sx(X0, h, dz)
        hwp = (trunk_hw(h) + 2.5 * math.sin(h / 11.0 + seed)) * s
        for x in range(int(ax - hwp), int(ax + hwp) + 1):
            if not inside(W, H, x, y) or not ok(x, y):
                continue
            u = max(-1.0, min(1.0, (x + 0.5 - ax) / hwp))
            nz = math.sqrt(max(0.0, 1 - u * u))
            b = u * light * 0.7 + nz * 0.6
            bl = pal['bark']
            k = 4 if b > 0.85 else 3 if b > 0.55 else 2 if b > 0.25 else 1
            if not quiet(x, y):
                # long furrows that curve a little and deepen into buttress folds at the flare
                ang = math.asin(u)
                for f in range(11):
                    ph = f * (2 * math.pi / 11) + 0.35 * math.sin(h / 31.0 + f) + seed
                    dph = (ang - math.sin(ph) * 1.0)
                    if math.cos(ph) > 0.05 and abs(math.sin(ph) - u) * hwp < (0.6 + (1.6 if h < 40 else 0) * s * (45 - min(45, h)) / 45):
                        k = max(0, k - 2)
                if u * light > 0.2 and vn(x, h * s, 4, seed + 8) > 0.68:
                    put(x, y, pal['moss'][1 if b > 0.7 else 0])
                    continue
            put(x, y, bl[max(0, min(len(bl) - 1, k))])
    # buttress spurs: ridges running out from the flare, forested on their crests
    for side, reach, hk in SPURS:
        for X in [TRUNK_W / 2 + i * 0.5 for i in range(int((reach - TRUNK_W / 2) * 2))]:
            r = (reach - X) / (reach - TRUNK_W / 2)
            hr = hk * r ** 1.5
            ytop, ybot = P.sy(hr, dz), P.sy(0, dz)
            x = int(round(P.sx(X0 + side * X, hr, dz)))
            for y in range(int(ytop), int(ybot) + 1):
                if not inside(W, H, x, y) or not ok(x, y):
                    continue
                f = (ybot - y) / max(1.0, ybot - ytop)
                sl = pal['spur']
                c = sl[2] if f > 0.85 else sl[1] if side * light > 0 else sl[0]
                put(x, y, c)
    # limbs, under the crown
    for pts, w0, w1 in limbs:
        path = catmull([(P.sx(X0 + a, b, dz), P.sy(b, dz)) for a, b in pts], 20)
        s = P.s(150, dz)
        for i, (cx, cy) in enumerate(path):
            r = (w0 + (w1 - w0) * i / len(path)) * s / 2
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if inside(W, H, xx, yy) and ok(xx, yy) and (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= r * r:
                        q = (xx + 0.5 - cx) / max(r, 0.5) * light
                        put(xx, yy, pal['bark'][2 if q > 0.3 else 1 if q > -0.4 else 0])
    # crown: the even dome first (solid, shaded by place), then the leaf clumps inside it
    in_dome = None
    if dome:
        in_dome = Dome(P, X0, dz, crown_off, seed)
        cls = pal['crown']
        for yy in range(max(0, in_dome.y0), min(H, in_dome.y1)):
            for xx in range(max(0, in_dome.x0), min(W, in_dome.x1)):
                if not ok(xx, yy) or not in_dome(xx, yy):
                    continue
                lit = in_dome.gv(yy) * 0.9 - 0.35 + in_dome.gd(xx) * light * 0.45
                put(xx, yy, cls[3 if lit > 0.35 else 2 if lit > -0.05 else 1 if lit > -0.45 else 0], ch)
    for (X, h, r) in clumps:
        s = P.s(h, dz)
        cx, cy, rp = P.sx(X0 + X, h, dz), P.sy(h, dz), r * s
        gd = (X - crown_off) / (CROWN_W / 2)
        low = h < UNDER_C + 45
        for yy in range(int(cy - rp) - 1, int(cy + rp) + 2):
            for xx in range(int(cx - rp) - 1, int(cx + rp) + 2):
                if not inside(W, H, xx, yy) or not ok(xx, yy):
                    continue
                if in_dome and not in_dome(xx, yy):
                    continue
                dx, dy = (xx + 0.5 - cx) / rp, (yy + 0.5 - cy) / rp
                rr = dx * dx + dy * dy
                wob = 0.12 * (vn(xx, yy, max(2.0, rp * 0.35), seed + 3) - 0.5)
                if rr > (1 + wob) ** 2:
                    continue
                lit = -dy * 0.78 + dx * light * 0.5 + gd * light * 0.25
                cls = pal['crown']
                k = 4 if lit > 0.62 else 3 if lit > 0.25 else 2 if lit > -0.15 else 1 if lit > -0.55 else 0
                if low:
                    k = max(0, k - 1)
                if quiet(xx, yy):
                    k = min(k, 2)
                c = cls[k]
                if k == 4 and rr > 0.7 and not quiet(xx, yy):
                    c = pal['rim'][0]
                put(xx, yy, c, ch)
    if dome:
        # one lit line along the dome's top on its sunward side, so the canopy line reads as one even edge
        for yy in range(max(0, in_dome.y0), min(H, int(in_dome.yr))):
            for xx in range(max(0, in_dome.x0), min(W, in_dome.x1)):
                if ok(xx, yy) and in_dome.gd(xx) * light > -0.3 and in_dome.rim(xx, yy, light):
                    put(xx, yy, pal['rim'][0], ch)
    # its own forest round the foot: full-size trees, tiny at this scale
    if forest:
        s0 = P.s(0, dz)
        th = 10 * s0
        if th >= 2.5:
            for side, reach, hk in SPURS:
                X = TRUNK_W / 2 + 6
                i = 0
                while X < reach - 4:
                    r = (reach - X) / (reach - TRUNK_W / 2)
                    hr = hk * r ** 1.5
                    x, y = P.sx(X0 + side * X, hr, dz), P.sy(hr, dz)
                    small_tree(px, W, H, S, int(round(x)), int(round(y)) + 1, max(3, int(round(th * (0.8 + 0.4 * hn(i, reach, seed))))),
                               pal['forest'], ok, sky, haze, light)
                    X += 11 + 8 * hn(i, reach, seed + 1)
                    i += 1
            X = -FLARE_W / 2 - 40
            i = 0
            while X < FLARE_W / 2 + 40:
                x, y = P.sx(X0 + X, 0, dz), P.sy(0, dz)
                small_tree(px, W, H, S, int(round(x)), int(round(y)) + 1, max(3, int(round(th * (0.9 + 0.5 * hn(i, 9, seed))))),
                           pal['forest'], ok, sky, haze, light)
                X += 9 + 6 * hn(i, 3, seed)
                i += 1


def small_tree(px, W, H, S, x, base, h, cols, ok, sky, haze, light=1):
    """One full-size forest tree seen from far off: a round two-lump crown (Hollowtide's tree shape)."""
    w = h * 0.75
    cx, cy = x, base - h * 0.55
    for yy in range(int(base - h) - 1, int(base) + 1):
        for xx in range(int(x - w) - 1, int(x + w) + 2):
            if not inside(W, H, xx, yy) or not ok(xx, yy):
                continue
            d1 = ((xx + 0.5 - cx) / (w * 0.8)) ** 2 + ((yy + 0.5 - cy) / (h * 0.45)) ** 2
            d2 = ((xx + 0.5 - cx - light * w * 0.35) / (w * 0.55)) ** 2 + ((yy + 0.5 - cy + h * 0.18) / (h * 0.36)) ** 2
            if d1 > 1 and d2 > 1:
                continue
            sun = (xx - cx) * light > 0 and yy < cy
            c = cols[2] if sun else cols[1] if yy < cy + 1 else cols[0]
            px[xx, yy] = S(mix(c, sky(xx, yy), haze))


# ------------------------------------------------------------------------------------------ roots, near
def draw_root(px, W, H, S, pts, w0, w1, light=(-0.55, -0.83), seed=1, moss=0.3, ok=None, soil=None,
              swell=0.14, ramp=ROOTR, mramp=MOSSR, outline=True, per=40, profile=None):
    """A living root along a path: tapers w0 -> w1, swells and pinches, long bark streaks along it,
    moss on its sunward top, a dark rim. soil: colour for a ragged soil lip (a half-buried root).
    profile(t): extra width factor along the path (a root that rises out of the ground and dives back)."""
    path = catmull(pts, per)
    n = len(path)
    ln = math.hypot(*light)
    lx, ly = light[0] / ln, light[1] / ln
    owner = {}
    for i, (cx, cy) in enumerate(path):
        t = i / max(1, n - 1)
        r = (w0 + (w1 - w0) * t) / 2 * (1 + swell * (2 * vn(i, 0, 23, seed) - 1))
        if profile:
            r *= profile(t)
            if r < 0.6:
                continue
        j = min(n - 1, i + 1)
        tx_, ty_ = path[j][0] - path[max(0, j - 1)][0], path[j][1] - path[max(0, j - 1)][1]
        tl = math.hypot(tx_, ty_) or 1
        nx, ny = -ty_ / tl, tx_ / tl
        for yy in range(int(cy - r) - 1, int(cy + r) + 2):
            for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                dx, dy = xx + 0.5 - cx, yy + 0.5 - cy
                if dx * dx + dy * dy > r * r or not inside(W, H, xx, yy):
                    continue
                if ok and not ok(xx, yy):
                    continue
                s = (dx * nx + dy * ny) / max(r, 0.5)
                lit = (dx * lx + dy * ly) / max(r, 0.5)
                prev = owner.get((xx, yy))
                if prev is not None and abs(s) > abs(prev[1]):
                    continue
                owner[(xx, yy)] = (lit, s, i, r)
    nr = len(ramp)
    for (xx, yy), (lit, s, i, r) in owner.items():
        k = 5 if lit > 0.62 else 4 if lit > 0.2 else 3 if lit > -0.25 else 2 if lit > -0.65 else 1
        k = min(nr - 1, k)
        nb = max(3, int(r / 1.8))
        sb = (s + 1) / 2 * nb
        band = int(sb)
        L = 50 + int(r * 5)
        if hn(band, (i + band * 17) // L, seed) > 0.55:
            k = max(1, k - 1)                       # a long darker strand of bark
        if r > 3.5 and abs(sb % 1 - 0.5) > 0.4 and hn(band, (i + band * 29) // (L // 2), seed + 3) > 0.35:
            k = max(1, k - 1)                       # the furrow between strands
        c = ramp[k]
        if lit > 0.15 and vn(xx, yy, 5, seed + 11) > 1 - moss:
            c = mramp[2 if lit > 0.55 else 1]
        px[xx, yy] = S(c)
    if outline:
        for (xx, yy) in owner:
            for ax_, ay_ in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (xx + ax_, yy + ay_)
                if q not in owner and inside(W, H, *q) and (not ok or ok(*q)):
                    px[q] = S(soil if soil and hn(q[0], q[1], seed) < 0.7 else ramp[0])
    return owner


def leaf(px, W, H, S, cx, cy, L, ang, cols=('e2c59b', 'c49243', '7c4a26', '3f2716'), shadow=None):
    """One leaf of the great tree, about a tile long: a pointed oval with a stem and a midrib."""
    ca, sa = math.cos(ang), math.sin(ang)
    hw = max(1.5, L * 0.2)
    ins = set()
    R = int(L / 2) + 3
    for y in range(int(cy - R), int(cy + R) + 1):
        for x in range(int(cx - R), int(cx + R) + 1):
            dx, dy = x - cx, y - cy
            u = (dx * ca + dy * sa) / (L / 2.0)
            v = -dx * sa + dy * ca
            if -1 <= u <= 1:
                prof = (1 - u * u) ** 0.55 * (1.0 - 0.3 * max(0.0, u))
                if abs(v) <= hw * prof + 0.35:
                    ins.add((x, y))
            elif -1.35 <= u < -1 and abs(v) < 0.7:
                ins.add((x, y))
    if shadow:
        for (x, y) in ins:
            q = (x + 2, y + 3)
            if q not in ins and inside(W, H, *q):
                c = px[q]
                px[q] = S((int(c[0] * 0.6), int(c[1] * 0.64), int(c[2] * 0.72)))
    for (x, y) in ins:
        if not inside(W, H, x, y):
            continue
        dx, dy = x - cx, y - cy
        v = -dx * sa + dy * ca
        edge = any((x + a, y + b) not in ins for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        px[x, y] = S(cols[3] if edge else cols[2] if abs(v) < 0.6 and L >= 10 else cols[0] if v < 0 else cols[1])


REPORT_EXTRA = {}


# ================================================================================================ view helpers
SHADE_END = (312, 50)          # creature_opening.gd: 38% dark over x < 312, y < 50 (title.gd anchor shade_end)
CALM = (90, 0, 296, 52)        # the wordmark's calm box
MENU = (21, 108, 129, 200)     # the menu buttons
VISTA_BEAR = 202.5             # the road home comes in from the south-south-west


def cam_rel(bearing, D, E=None, N=None):
    """A camera D tiles from the Tower on compass bearing `bearing` (degrees clockwise from north), looking
    at the Tower. Returns (X across to the right, dz deeper than the Tower) of the ground point (E, N)."""
    E = TREE_E if E is None else E
    N = TREE_N if N is None else N
    b = math.radians(bearing)
    ce, cn = D * math.sin(b), D * math.cos(b)
    fe, fn = -math.sin(b), -math.cos(b)
    ve, vv = E - ce, N - cn
    return ve * fn - vv * fe, ve * fe + vv * fn - D


def ground_point(P, bearing, x, y, dz=None):
    """Back-project a screen pixel onto the ground: (E, N, depth), or None above the horizon."""
    if dz is None:
        lo, hi = -P.D + 2.0, 60000.0
        if P.sy(0, hi) >= y:
            return None
        for _ in range(40):
            mid = (lo + hi) / 2
            if P.sy(0, mid) > y:
                lo = mid
            else:
                hi = mid
        dz = (lo + hi) / 2
    X = (x + 0.5 - P.cx) * P.z(0, dz) / P.f
    b = math.radians(bearing)
    ce, cn = P.D * math.sin(b), P.D * math.cos(b)
    fe, fn = -math.sin(b), -math.cos(b)
    dep = P.D + dz
    return ce + X * fn + dep * fe, cn - X * fe + dep * fn, dep


def river_n(E):
    """The river's middle, north coordinate in tiles (south of the Tower); the same line as the map."""
    m = 300 + E * 0.25
    return -(22 + 6 * math.sin(m / 40.0) + 3 * math.sin(m / 13.0) + 2.5) / 0.25


def tiny_tree(px, W, H, S, x, base, h, cols, ok, sky, haze, light=1):
    """A forest tree 2 to 4 px tall: a dark body with a lit top on its sun side."""
    if h >= 4.5:
        small_tree(px, W, H, S, x, base, h, cols, ok or (lambda a, b: True), sky, haze, light)
        return
    hh = max(2, int(round(h)))
    ww = max(2, int(round(h * 0.95)))
    for dy in range(hh):
        for dx in range(ww):
            xx, yy = x - ww // 2 + dx, base - 1 - dy
            if not inside(W, H, xx, yy) or (ok and not ok(xx, yy)):
                continue
            if dy == hh - 1 and dx in (0, ww - 1) and ww >= 3:
                continue
            top = dy >= hh - 1 - (1 if hh >= 3 else 0)
            c = cols[2] if top and (dx - (ww - 1) / 2) * light >= 0 else cols[1] if top else cols[0]
            px[xx, yy] = S(mix(c, sky(xx, yy), haze))


def forest_points(bearing, D, step=12.0, seed=7, clear=((0.0, 0.0, 46.0),)):
    """Full-size forest trees over the forest disc round the great tree, as (depth, X across, dz, r),
    far to near. Highbank is a clearing round the Tower; the forest stops at the river; the trunk's own
    footprint is left out."""
    b = math.radians(bearing)
    ce, cn = D * math.sin(b), D * math.cos(b)
    fe, fn = -math.sin(b), -math.cos(b)
    R = FOREST_W / 2
    n = int(R / step) + 1
    out = []
    for i in range(-n, n + 1):
        for j in range(-n, n + 1):
            e = TREE_E + (i + (hn(i, j, seed) - 0.5) * 0.8) * step
            nn = TREE_N + (j + (hn(j, i, seed + 1) - 0.5) * 0.8) * step
            d = math.hypot(e - TREE_E, nn - TREE_N)
            if d > R * (0.9 + 0.1 * vn(e, nn, 70, seed)) or d < FLARE_W / 2 - 8 or nn < river_n(e) + 8:
                continue
            if any(math.hypot(e - a, nn - c) < r * (0.85 + 0.3 * hn(i, j, seed + 5)) for a, c, r in clear):
                continue
            ve, vv = e - ce, nn - cn
            X, dz = ve * fn - vv * fe, ve * fe + vv * fn - D
            if D + dz > 20:
                out.append((D + dz, X, dz, hn(i, j, seed + 3)))
    out.sort(key=lambda p: -p[0])
    return out


def paint_forest(px, W, H, S, P, pts, cols, sky, ok=None, haze=lambda z: 0.0, tree_h=11.0, light=1):
    for (z, X, dz, r) in pts:
        s = P.s(0, dz)
        x, y = P.sx(X, 0, dz), P.sy(0, dz)
        if not (-6 <= x < W + 6 and -6 <= y < H + 6):
            continue
        tiny_tree(px, W, H, S, int(round(x)), int(round(y)) + 1, tree_h * s * (0.8 + 0.45 * r), cols, ok, sky,
                  haze(z), light)


def changed(a, b, box=None):
    """How many pixels differ between two images, optionally only inside box (x0, y0, x1, y1)."""
    ap, bp = a.load(), b.load()
    x0, y0, x1, y1 = box or (0, 0, a.width, a.height)
    return sum(1 for y in range(y0, y1) for x in range(x0, x1) if ap[x, y] != bp[x, y])


def box_stats(img, box):
    """Colours and edges (neighbour pairs that differ) inside a box: how calm the wordmark's area is."""
    p = img.load()
    x0, y0, x1, y1 = box
    cols = {p[x, y] for y in range(y0, y1) for x in range(x0, x1)}
    edges = sum(1 for y in range(y0, y1) for x in range(x0, x1)
                for (a, b) in ((x + 1, y), (x, y + 1)) if a < x1 and b < y1 and p[a, b] != p[x, y])
    return len(cols), edges


def game_preview(img, name, note):
    """What the title screen would show: the shade band over the wordmark, then the wordmark, menu and
    hint line, taken from the round-2 title capture where it differs from Codex's candidate."""
    g = img.copy()
    gp = g.load()
    for y in range(SHADE_END[1]):
        for x in range(SHADE_END[0]):
            c = gp[x, y]
            gp[x, y] = (int(c[0] * 0.62), int(c[1] * 0.62), int(c[2] * 0.62))
    cap = to1x(R2 + '14_title_menu.png')
    cand = Image.open(CAND).convert('RGB')
    cp, kp = cap.load(), cand.load()
    for y in range(cap.height):
        for x in range(cap.width):
            in_ui = (CALM[0] <= x < CALM[2] and y < CALM[3]) or (MENU[0] <= x < MENU[2] and MENU[1] <= y < MENU[3]) \
                or y >= 201
            if not in_ui:
                continue
            k = kp[x, y]
            if x < SHADE_END[0] and y < SHADE_END[1]:
                k = (int(k[0] * 0.62), int(k[1] * 0.62), int(k[2] * 0.62))
            c = cp[x, y]
            if max(abs(c[i] - k[i]) for i in range(3)) > 22:
                gp[x, y] = c
    save(g, name, note)
    return g


def preshade(px, pre, W):
    """Codex preshaded the sky right of x 312 above row 50 so the shade band runs the full width.
    Anything newly painted there gets the same 38% shade, so there is no seam at x 312."""
    S = Snap(load_pal('highbank_title.png'))
    pp = pre.load()
    for y in range(SHADE_END[1]):
        for x in range(SHADE_END[0], W):
            if px[x, y] != pp[x, y]:
                c = px[x, y]
                px[x, y] = S((int(c[0] * 0.62), int(c[1] * 0.62), int(c[2] * 0.62)))


# ================================================================================================ 1. TITLE
T_SKYC = {hx(c) for c in ['192726', '1e302e', '263d3a', '33524e', '43665a', '4f6858', '61785c']}
T_WARM = {hx(c) for c in ['8e7f5e', 'c49243', 'd4a94c', 'ecb36b', 'f1c177', '9c8c68', 'dca562', 'fbd490', '9f946d',
                          'e6c697', 'f5d9a8', '6b6d45', '908940', '5f5e57', 'f2d27a']}
T_DARK = {hx(c) for c in ['263d3a', '1d2925', '1e302e', '303e37', '192726']}
TITLE_BARK = ['23180e', '3f2716', '5d4b34', '7c4a26', 'b8793e']
TITLE_CROWN = ['192726', '1d2925', '303e37', '44421a', '6b6d45', '908940']


def title_tree(px, W, H, S, TP, bg, light=-1, calm=CALM, seed=5, X0=0.0, dz=0.0, pal=None, tint=None, sun_k=0.55,
               rise=0.22):
    """The great tree on the title: trunk and limbs in warm bark lit from the sunset side, then the whole crown as
    one even dome of leaf lobes. Inside the wordmark's calm box the crown keeps to two dark colours. pal swaps its
    colours for another time of day ({title colour: new colour}); tint(c, x, y) then hazes them. sun_k weighs the
    low sun across the dome and rise the height (lit low below rise); the hold's cap, seen from above with only
    its top showing, takes its light from the sun alone (mock_hold)."""
    def C(c, x, y):
        c = (pal or {}).get(c, c)
        return tint(c, x, y) if tint else c
    def quiet(x, y):
        return calm and calm[0] <= x < calm[2] and calm[1] <= y < calm[3]
    clumps, limbs = tree_model(seed, CROWN_OFF)
    y_lo, y_hi = int(TP.sy(0, dz)) + 1, int(TP.sy(UNDER_C + 10, dz))
    for y in range(max(0, y_hi), min(H, y_lo + 1)):
        h = TP.h_at(y + 0.5, dz)
        if h < 0:
            continue
        s = TP.s(h, dz)
        ax = TP.sx(X0, h, dz)
        hwp = (trunk_hw(h) + 2.5 * math.sin(h / 11.0 + seed)) * s
        for x in range(int(ax - hwp), int(ax + hwp) + 1):
            if not inside(W, H, x, y) or not bg(x, y):
                continue
            u = max(-1.0, min(1.0, (x + 0.5 - ax) / hwp))
            b = u * light * 0.7 + math.sqrt(max(0.0, 1 - u * u)) * 0.6
            k = 4 if b > 0.88 else 3 if b > 0.6 else 2 if b > 0.3 else 1 if b > -0.1 else 0
            if (u * 6.0 + 0.5 * math.sin(h / 23.0)) % 1.0 < 0.2 and k > 0:
                k -= 1                                          # long furrows
            c = TITLE_BARK[k]
            if u * light > 0.25 and vn(x, h * s, 3, seed + 8) > 0.7:
                c = '6b6d45' if b > 0.7 else '44421a'
            if quiet(x, y):
                c = '23180e'
            px[x, y] = S(C(c, x, y))
    for pts, w0, w1 in limbs:
        path = catmull([(TP.sx(X0 + a, b, dz), TP.sy(b, dz)) for a, b in pts], 20)
        s = TP.s(150, dz)
        for i, (cx, cy) in enumerate(path):
            r = max(0.7, (w0 + (w1 - w0) * i / len(path)) * s / 2)
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if inside(W, H, xx, yy) and bg(xx, yy) and (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= r * r:
                        q = (yy + 0.5 - cy) / max(r, 0.5)        # the low sun lights the limbs from below
                        px[xx, yy] = S(C('23180e' if quiet(xx, yy) or q < -0.45 else '3f2716' if q < 0.35 else '7c4a26', xx, yy))
    # The crown (2026-10-28, Preston: "need the leaves and branch top"): one even dome (Dome). Its big masses come
    # from the clump model; its leaves are clusters (4 to 6 px) on a staggered grid, each lower one over the one
    # above, so every cluster shows a lit top arc and a dark lower edge. Lit low from the sunset side, so the
    # lower west part is the bright one; the texture fades out toward the wordmark's calm box, where the crown is
    # only its dark body and a teal rim along the top.
    dm = Dome(TP, X0, dz, CROWN_OFF, seed, lobe_d=3.0)
    lobe = {}
    for i, (X, h, r) in enumerate(clumps):
        s = TP.s(h, dz)
        cx, cy, rp = TP.sx(X0 + X, h, dz), TP.sy(h, dz), r * s
        for yy in range(int(cy - rp) - 1, int(cy + rp) + 2):
            for xx in range(int(cx - rp) - 1, int(cx + rp) + 2):
                if dm(xx, yy) and ((xx + 0.5 - cx) / rp) ** 2 + ((yy + 0.5 - cy) / rp) ** 2 <= 1:
                    lobe[(xx, yy)] = ((xx + 0.5 - cx) / rp, (yy + 0.5 - cy) / rp)   # the lowest clump shows
    rnd = random.Random(seed + 17)
    leaves = []
    for j, gy in enumerate(range(dm.y0, dm.y1 + 4, 6)):
        for gx in range(dm.x0 - 4, dm.x1 + 5, 8):
            leaves.append((gy + rnd.uniform(-1.5, 1.5), gx + (4 if j % 2 else 0) + rnd.uniform(-2.0, 2.0),
                           rnd.uniform(4.0, 6.0)))
    leaves.sort()
    own = {}
    for i, (cy, cx, r) in enumerate(leaves):
        for yy in range(int(cy - r) - 1, int(cy + r) + 2):
            for xx in range(int(cx - r * 1.15) - 1, int(cx + r * 1.15) + 2):
                dx, dy = (xx + 0.5 - cx) / (r * 1.15), (yy + 0.5 - cy) / r
                if dx * dx + dy * dy <= 1 and dm(xx, yy):
                    own[(xx, yy)] = (i, dx, dy)
    for yy in range(max(0, dm.y0), min(H, dm.y1)):
        for xx in range(max(0, dm.x0), min(W, dm.x1)):
            if not dm(xx, yy) or not bg(xx, yy):
                continue
            if quiet(xx, yy):
                px[xx, yy] = S(C('33524e' if not dm(xx, yy - 1) else '1d2925', xx, yy))
                continue
            sun = dm.gd(xx) * light                  # 1 at the rim on the sunset side, -1 on the far side
            gv = dm.gv(yy)                           # 0 at the rim, 1 at the top
            big = lobe.get((xx, yy), (0.0, 0.0))
            L = own.get((xx, yy), (-1, 0.0, 0.0))
            up, dn = own.get((xx, yy - 1), (-2,)), own.get((xx, yy + 1), (-2,))
            score = sun * sun_k + (rise - gv) * 1.5 + (-big[1] * 0.7 + big[0] * light * 0.6) * 0.25
            score += (-L[2] * 0.6 + L[1] * light * 0.5) * 0.3
            if up[0] != L[0] and L[2] < -0.2 and L[1] * light > -0.6:
                score += 0.35                        # a cluster's lit top arc
            if dn[0] != L[0] and L[2] > 0.2:
                score -= 0.4                         # its lower edge, in the shadow of the one below
            if not dm(xx, yy - 1) or dm.rim(xx, yy, light):
                score += 0.3
            if calm:
                score -= 0.8 * max(0.0, (calm[3] + 16 - yy) / 16.0)    # fade to the calm box's flat body
            if score < -0.2:
                c = '1d2925'
            elif score < 0.15:
                c = '303e37'
            elif score < 0.45:
                c = '44421a' if sun > 0.1 else '303e37'
            elif score < 0.8:
                c = '6b6d45'
            else:
                c = '908940'
            if not dm(xx, yy + 1):
                c = '44421a' if sun > 0.2 else '1d2925'   # the underside
            px[xx, yy] = S(C(c, xx, yy))


def title_ridge(bp, W, H):
    ridge = {}
    for x in range(W):
        r = H
        for y in range(70, H - 5):
            if bp[x, y] in T_DARK and bp[x, y + 2] in T_DARK and bp[x, y + 4] in T_DARK:
                r = y
                break
        ridge[x] = r
    return ridge


TREE_PPT, TREE_AX, TREE_FOOT = 0.36, 209, 150     # title A's great tree: px a tile, trunk axis x, foot row (hidden)
AXT, PPT, T_FOOT = 357, 2.6, 168                  # title A's giant: axis x, px a tile, foot (the Rise's top row)
OLD_X0 = 283                                      # Codex's older tower starts here (its root's west edge)
BUSH = (266, 146, 284, 168)                       # Codex's garden bushes beside house 4: kept as painted
TOWN_BOXES = {'left tree': (0, 0, 76, 190), 'houses': (86, 143, 266, 168), 'bushes': BUSH,
              'Rise, quay and river': (0, 168, 384, 216)}


def mock_title():
    """Title A (Preston's pick, 2026-10-28): Codex's cx-15 houses, river and left tree kept as painted. Codex's
    older tower in front is taken out (depot, drum, hoist, chute, crook, its root and the yard shed). The giant
    round Stack stands in its place at 2.6 px a tile, west face at x 313, off the top, down to the Rise on its
    own stepped plinth with the doors at the top of the Rise stair; the Low Reel deck at 34 tiles with the town's
    waylines; the great tree's root up its west face from the west-north-west. The great tree stands behind the
    town at 0.36 px a tile with its whole crown, an even dome under the wordmark."""
    base = Image.open(CAND).convert('RGB')
    img = base.copy()
    px, bp = img.load(), base.load()
    W, H = img.size
    S = Snap(load_pal('highbank_title.png'))
    ridge = title_ridge(bp, W, H)

    def is_bg(x, y):
        if MENU[0] <= x < MENU[2] and MENU[1] <= y < MENU[3]:
            return False
        if y >= ridge[x] or x >= 296:
            return False
        c = bp[x, y]
        if c in T_SKYC:
            return True
        if c in T_WARM and not (52 <= y <= 92 and x > 100):     # the sunset horizon, but not Codex's streaks
            return y > 86
        return False

    # ---- the great tree: trunk axis x 209, foot hidden behind the ridge woods, crown top at y 6
    TPT = Proj.level(TREE_PPT, TREE_AX, TREE_FOOT)
    title_tree(px, W, H, S, TPT, is_bg)
    for x in range(80, 266, 4):            # its own forest over the trunk's foot, along the ridge
        g = min(130, ridge[x])
        small_tree(px, W, H, S, x + int(hn(x, 1, 3) * 3), g + 2, 5 + int(hn(x, 2, 3) * 3),
                   ['1d2925', '263d3a', '43665a'], lambda a, b: b < ridge[a] and (is_bg(a, b) or b >= 118) and not (MENU[0] <= a < MENU[2] and MENU[1] <= b < MENU[3]),
                   lambda a, b: bp[a, b], 0.0, -1)

    # ---- take Codex's older tower out: its sky comes back from the sky beside it, its woods from the woods
    def keep(x, y):                                      # the Rise and below, the houses, the gardens
        return y >= T_FOOT or (x < BUSH[0] and y >= 143) or (x < BUSH[2] and y >= BUSH[1])
    rowL, rowR = {}, {}
    for y in range(H):
        a = [bp[x, y] for x in range(240, 283) if bp[x, y] in T_SKYC]
        b = [bp[x, y] for x in range(372, W) if bp[x, y] in T_SKYC]
        rowL[y] = max(set(a), key=a.count) if a else hx('1e302e')
        rowR[y] = max(set(b), key=b.count) if b else rowL[y]
    for y in range(T_FOOT):
        for x in range(OLD_X0, W):
            if keep(x, y):
                continue
            if y < 99:
                if bp[x, y] not in T_SKYC:                       # Codex's own sky stays as painted
                    px[x, y] = rowR[y] if x >= SHADE_END[0] else rowL[y]
            else:
                px[x, y] = bp[x - 34, y] if y < 140 else hx('1d2925')
    pre = img.copy()

    # ---- the giant: plinth steps 0 to 16 tiles, then the Stack, off the top
    PT = Proj.level(PPT, AXT, T_FOOT)
    paint_tower(px, W, H, S, PT, 0, lambda x, y: bp[x, y], haze0=0.0, haze1=0.0, light=-1, lit_win=0.3, seed=6,
                collar=False, ok=lambda x, y: not keep(x, y), root=False)
    y8, y16 = int(round(PT.sy(8))), int(round(PT.sy(16)))
    for yr, x0 in ((y8 - 3, int(round(AXT - 26 * PPT))), (y16 - 3, int(round(AXT - 21 * PPT)))):
        for x in range(x0 + 1, W):                       # a brass rail along each step's ledge
            px[x, yr] = S('d4a94c' if x < AXT else 'a37a32')
            if (x - AXT) % 6 == 0:
                px[x, yr + 1] = S('6b4f1f')
                px[x, yr + 2] = S('6b4f1f')
    DX = 333                                             # the doors, on the Rise stair's axis
    door = set()
    for y in range(y8 + 6, T_FOOT):
        half = 5 if y > y8 + 7 else 4 if y == y8 + 7 else 2
        for x in range(DX - half, DX + half + 1):
            door.add((x, y))
    for (x, y) in door:
        if x <= DX - 4 or x >= DX + 4:
            c = '7c4a26'                                  # the open leaves
        else:
            c = 'fbd490' if y < T_FOOT - 4 else 'f1c177'
        px[x, y] = S(c)
    for (x, y) in list(door):
        for a, b in ((1, 0), (-1, 0), (0, -1)):
            if (x + a, y + b) not in door:
                px[x + a, y + b] = S('5d4b34')
    px[DX, y8 + 4] = S('e6c697')                          # the keystone
    for lx in (DX - 9, DX + 9):                           # a lamp each side of the doors
        px[lx, y8 + 9] = S('6b4f1f')
        px[lx, y8 + 10] = S('fbd490')
        px[lx, y8 + 11] = S('c49243')
    for i, wx in enumerate((DX - 13, DX, DX + 13)):      # three hall windows on the upper step
        for y in range(y16 + 6, y16 + 11):
            for x in range(wx - 1, wx + 2):
                if y == y16 + 6 and x != wx:
                    continue
                px[x, y] = S('3f2716' if i == 0 else 'fbd490')
        for y in range(y16 + 5, y16 + 12):
            for x in (wx - 2, wx + 2):
                if y > y16 + 6:
                    px[x, y] = S('5d4b34')
        px[wx, y16 + 5] = S('5d4b34')

    # ---- the great tree's root: in from the west-north-west behind the gardens, over the first step, up the
    # second step's west side and onto the Stack's west face, off the top
    def root_ok(x, y):
        return not keep(x, y) and (x, y) not in door
    draw_root(px, W, H, S, [(260, 166), (275, 158), (288, 151), (297, 143), (304, 133), (310, 123), (315, 108),
                            (317, 86), (317, 60), (315, 34), (317, 10), (319, -10)], 11, 8, light=(-0.85, -0.5),
              seed=12, moss=0.26, ok=root_ok, swell=0.08)
    rootc = {S(c) for c in ROOTR + MOSSR}
    for y in (y8, y16):                                  # brass bands where the builders tied it
        for x in range(284, 330):
            if px[x, y] in rootc and root_ok(x, y):
                px[x, y] = S('d4a94c')
    for pts in (((320, 105), (330, 105), (339, 106), (345, 107)), ((319, 43), (328, 43), (336, 44), (341, 45))):
        draw_root(px, W, H, S, list(pts), 2.2, 0.8, light=(-0.3, -0.95), seed=pts[0][1], moss=0.0, ok=root_ok,
                  swell=0.0, outline=False)                # thin rootlets along two cornices

    # ---- the Low Reel: a ring deck round the Stack at 34 tiles, the reel and its sheaves at its west end
    yd = int(round(PT.sy(34)))
    dx0 = int(round(AXT - (34 + 10) * PPT / 2))
    for x in range(dx0, W):
        px[x, yd - 1] = S('f2d27a' if x < AXT - 20 else 'd4a94c')
        px[x, yd] = S('d4a94c' if x < AXT - 20 else 'a37a32')
        px[x, yd + 1] = S('a37a32')
        px[x, yd + 2] = S('6b4f1f')
        px[x, yd - 4] = S('d4a94c' if x < AXT else 'a37a32')
        if (x - dx0) % 5 == 0:
            px[x, yd - 3] = S('6b4f1f')
            px[x, yd - 2] = S('6b4f1f')
        if (x - dx0) % 9 == 4 and x < W - 2:              # route lanterns under the rim
            px[x, yd + 3] = S('6b4f1f')
            px[x, yd + 4] = S('fbd490')
    face = int(round(AXT - 17 * PPT))                    # a brace from the Stack's face out under the deck's edge
    for i in range(7):
        x, y = face - 1 - 2 * i, yd + 9 - i
        if x > dx0 and root_ok(x, y):
            px[x, y] = S('5d4b34')
            px[x - 1, y] = S('5d4b34')
    rcx, rcy, rr = dx0 + 6, yd - 9, 5.5                  # the reel: a spoked wheel standing on the deck
    for y in range(int(rcy - rr) - 1, int(rcy + rr) + 2):
        for x in range(int(rcx - rr) - 1, int(rcx + rr) + 2):
            d = math.hypot(x + 0.5 - rcx, y + 0.5 - rcy)
            if rr - 1.3 <= d <= rr:
                px[x, y] = S('7c4a26' if (x + 0.5 - rcx) * -1 + (rcy - y - 0.5) > 0 else '3f2716')
            elif d < rr - 1.3:
                ang = math.atan2(y + 0.5 - rcy, x + 0.5 - rcx)
                if d < 1.2:
                    px[x, y] = S('d4a94c')
                elif abs(math.sin(ang * 3)) < 0.28:
                    px[x, y] = S('5d4b34')
    for y in range(int(rcy + rr), yd - 1):              # its post down to the deck
        px[int(rcx), y] = S('3f2716')
    # the town's waylines, from the reel's sheaves to the roof ridges of the houses
    # one pixel thick: dark on the sky, catching the sunset where it crosses the dark woods
    ends = [(250, 141), (204, 141)]
    for j, (ex, ey) in enumerate(ends):
        pts = catenary((dx0 + 1 + 2 * j, yd - 2 - j), (ex, ey), 10 + 4 * j)
        seen = set()
        for (x, y) in pts:
            q = (int(round(x)), int(round(y)))
            if q in seen or not (q[1] < 143 and q[0] < dx0 + 3 and root_ok(*q)):
                continue
            seen.add(q)
            px[q] = S('8e7f5e' if lum(px[q]) < 60 else '3f2716')
    # two thin sunset wisps cross the Stack: it stands in the sky, not against it
    for (wy, x0, x1, sd) in ((22, 300, W, 3), (41, 300, W, 5)):
        for x in range(x0, x1):
            if vn(x, wy, 9, sd) < 0.32:
                continue
            yy = wy + int(1.5 * math.sin(x / 31.0 + sd))
            px[x, yy] = S('9f946d' if vn(x, 0, 4, sd + 1) > 0.5 else '8e7f5e')
            if vn(x, 1, 6, sd + 2) > 0.55:
                px[x, yy + 1] = S('5d4b34')
    preshade(px, pre, W)

    cc, ce = box_stats(img, CALM)
    cc0, ce0 = box_stats(base, CALM)
    town = ', '.join('%s %d' % (k, changed(img, base, b)) for k, b in TOWN_BOXES.items())
    dmc = Dome(TPT, 0, 0)
    REPORT_EXTRA['title'] = ('calm box %d colours %d edges (Codex %d, %d); menu box pixels changed %d; town pixels '
                             'changed: %s; backdrop colours %d; stack west face x %.0f; plinth foot row %d, step tops '
                             'y %d and %d; Low Reel deck y %d from x %d; doors x %d to %d; crown x %d to %d, top y %d, '
                             'rim y %.0f, %.0f px across; trunk %.0f px'
                             % (cc, ce, cc0, ce0, changed(img, base, MENU), town, len(img.getcolors(1 << 16)),
                                AXT - 17 * PPT, T_FOOT - 1, y8, y16, yd, dx0, DX - 6, DX + 6,
                                dmc.cx - dmc.a, dmc.cx + dmc.a, dmc.yw - dmc.b, dmc.yr, 2 * dmc.a,
                                TRUNK_W * TREE_PPT))
    save(img, 'title', "title A: Codex's town kept, the older tower out, the giant down to the Rise, the great tree's crown")
    game_preview(img, 'title_a_game', 'title A as the screen shows it: shade band, wordmark and menu from round2/14')
    return img, base


def title_b_camera(bearing, D=110.0, th=30.0, cam_h=6.0, foot_y=192.0, vane_y=6.0, ax=332.0):
    t = math.radians(th)
    pr = Proj(1.0, 0, 0, D, t, cam_h)
    g0, g1 = -pr.sy(0), -pr.sy(480)
    f = (foot_y - vane_y) / (g1 - g0)
    return Proj(f, ax, foot_y + f * g0, D, t, cam_h)


def mock_title_b():
    """Title B: the whole Tower. The camera stands back across the river and tilts up 30 degrees so the
    Stack, the wet collar in the cloud layer, the neck and the lit lamp all show; Codex's houses, quay and
    left tree stay as the near bank; the great tree stands to the left, its crown cap above the clouds."""
    base = Image.open(CAND).convert('RGB')
    bp = base.load()
    W, H = base.size
    S = Snap(load_pal('highbank_title.png'))
    img = Image.new('RGB', (W, H))
    px = img.load()
    best = None
    for bear in range(196, 264, 2):
        P = title_b_camera(bear)
        X, dz = cam_rel(bear, P.D)
        tx = P.sx(X, 0, dz)
        if best is None or abs(tx - 160) < best[0]:
            best = (abs(tx - 160), bear, P, X, dz)
    _, BEAR, P, TXX, TDZ = best
    HZ = P.cy + P.f * P.st / P.ct
    SKYB = [(0, '192726'), (16, '1e302e'), (38, '263d3a'), (62, '33524e'), (88, '43665a'), (108, '4f6858'),
            (124, '61785c'), (136, '9f946d'), (146, 'dca562'), (154, 'f1c177')]

    def sky(x, y):
        c = SKYB[0][1]
        for y0, cc in SKYB:
            if y >= y0:
                c = cc
        return hx(c)

    def calm(x, y):
        return CALM[0] <= x < CALM[2] and y < CALM[3]
    for y in range(H):
        for x in range(W):
            c = sky(x, y)
            if not calm(x, y) and any(y == y0 - 1 for y0, _ in SKYB[1:]) and (x + y) % 2:
                c = sky(x, y + 1)
            px[x, y] = S(c)
    for (sy0, x0, x1, sd) in ((128, 0, 230, 2), (139, 60, 300, 4), (147, 0, 160, 6)):   # low sunset streaks
        for x in range(x0, x1):
            if vn(x, sy0, 14, sd) > 0.4:
                px[x, sy0 + int(math.sin(x / 40.0 + sd))] = S('c49243' if sy0 > 140 else '9f946d')
    # its forest at the horizon, the great tree, then the cloud layer level with the collar
    pts = forest_points(BEAR, P.D)
    tz = P.D + TDZ
    fcols = ['1d2925', '303e37', '5f5e57']
    paint_forest(px, W, H, S, P, [p for p in pts if p[0] > tz], fcols, sky, haze=lambda z: 0.12)
    pal = {'crown': ['1d2925', '303e37', '44421a', '6b6d45', '908940'], 'bark': TITLE_BARK,
           'spur': ['3f2716', '5d4b34', '6b6d45'], 'rim': ['9f946d'], 'moss': ['44421a', '6b6d45'],
           'forest': fcols}
    paint_tree(px, W, H, S, P, TXX, TDZ, lambda x, y: not calm(x, y), pal, sky, haze=0.1, light=-1, seed=5,
               crown_haze=0.14, forest=False)
    paint_forest(px, W, H, S, P, [p for p in pts if p[0] <= tz], fcols, sky, haze=lambda z: 0.08)
    for (Xa, Xb, hh, sd) in ((-330, -150, 334, 3), (-240, -60, 304, 4), (40, 150, 326, 5), (-120, 10, 352, 7)):
        cloud_bank(px, W, H, S, P.sx(Xa, hh), P.sx(Xb, hh), P.sy(hh + 10), 12 * P.s(hh), light=-1, seed=sd,
                   ok=lambda a, b: not calm(a, b))
    paint_tower(px, W, H, S, P, 0, sky, haze0=0.0, haze1=0.22, light=-1, lit_win=0.3, seed=6, lamp_glow=True)
    for y in range(150, 169):                     # the forest's own edge behind the houses
        for x in range(60, 292):
            px[x, y] = S('1d2925')
    for x in range(60, 292, 5):
        small_tree(px, W, H, S, x + int(hn(x, 1, 5) * 4), 154 + int(hn(x, 2, 5) * 6), 12 + int(hn(x, 3, 5) * 8),
                   ['1d2925', '263d3a', '303e37'], lambda a, b: a < 292, sky, 0.0, -1)
    # the near bank from Codex: houses, the left tree, the quay and the river
    def solid(x, y):
        c = bp[x, y]
        return c not in T_SKYC and c not in T_DARK
    for y in range(H):
        for x in range(W):
            c = bp[x, y]
            near = y >= 169 or (x < 70 and c not in T_SKYC)
            if not near and 80 <= x < 272 and y >= 136 and c not in T_SKYC:
                near = solid(x, y) or any(inside(W, H, x + a, y + b) and solid(x + a, y + b)
                                          for a in (-1, 0, 1) for b in (-1, 0, 1))
            if near:
                px[x, y] = c
    lr = (P.sx(-12, 34), P.sy(34))
    for p in ((253, 152), (213, 150), (164, 151)):
        line_px(px, W, H, catenary(lr, p, 6), S('3f2716'), ok=lambda a, b: b < 169 and bp[a, b] in T_SKYC | T_DARK)
    pre = Image.open(CAND).convert('RGB')                 # everything here is new paint: shade it all
    pre.paste((1, 2, 3), (SHADE_END[0], 0, W, SHADE_END[1]))
    preshade(px, pre, W)
    REPORT_EXTRA['title_b'] = ('camera bearing %d, %d tiles back, tilted up 30 degrees; tree trunk x %.0f, %.0f px '
                               'wide; crown %.0f px; stack %.0f px at its foot, lamp y %.0f; calm box %d colours %d edges'
                               % (BEAR, P.D, P.sx(TXX, 0, TDZ), TRUNK_W * P.s(0, TDZ), CROWN_W * P.s(300, TDZ),
                                  34 * P.s(16), P.sy(LAMP_T), *box_stats(img, CALM)))
    save(img, 'title_b', 'title B: the whole Tower, camera back and tilted up; tree left, crown cap over the clouds')
    game_preview(img, 'title_b_game', 'title B as the screen shows it')
    return img



# ================================================================================================ 2. VISTA
def vista_camera():
    """The last hill of the road home: about 650 tiles south-south-west of the Tower, 120 tiles above the
    valley, pitched up 20 degrees so the whole Tower fits from its foot (y 200) to its vane (y 8)."""
    th, D, ch = math.radians(20), 653.0, 120.0
    probe = Proj(1.0, 0, 0, D, th, ch)
    g0 = -(probe.sy(0) - 0)
    g1 = -(probe.sy(480) - 0)
    f = (200 - 8) / (g1 - g0)
    cy = 200 + f * g0
    return Proj(f, 285, cy, D, th, ch)


def cloud_bank(px, W, H, S, x0, x1, ytop, depth, light=1, seed=1, ok=None):
    """A flat-bottomed bank of cloud between x0 and x1: lumps along a line, tops uneven, bottom cut level."""
    rnd = random.Random(seed)
    ybot = ytop + depth
    x = x0
    while x < x1:
        r = rnd.uniform(depth * 0.55, depth * 1.0)
        cx, cy = x + r, ybot - r * rnd.uniform(0.35, 0.75)
        blob(px, W, H, S, cx, cy, r * 1.7, r,
             lambda dx, dy, a, b: cloud_col(dx, dy, light),
             ok=lambda a, b: b <= ybot and (ok is None or ok(a, b)))
        x += r * rnd.uniform(1.4, 2.4)


def paint_ground(px, W, H, S, P, bearing, sky, y0, y1, seed=7):
    """The land below the horizon, back-projected tile by tile: the forest floor round the great tree, the
    Highbank clearing, the river, fields beyond, far woods, all hazed by distance."""
    for y in range(y0, y1):
        lo, hi = -P.D + 2.0, 60000.0
        if P.sy(0, hi) >= y + 0.5:
            continue
        for _ in range(40):
            mid = (lo + hi) / 2
            if P.sy(0, mid) > y + 0.5:
                lo = mid
            else:
                hi = mid
        dz = (lo + hi) / 2
        for x in range(W):
            E, N, dep = ground_point(P, bearing, x, y, dz)
            hz = min(0.62, max(0.0, (dep - 420) / 2400))
            dt = math.hypot(E - TREE_E, N - TREE_N)
            rn = river_n(E)
            if abs(N - rn) < 7:
                c = '6c8b96' if abs(N - rn) > 4.5 else ('f5e4bd' if hn(x, y, seed) > 0.93 else '12837f')
            elif N > rn + 7 and math.hypot(E, N) < 46 + 6 * vn(E, N, 9, seed):
                c = 'a3a891' if vn(E, N, 6, seed + 1) > 0.5 else '8b9284'
            elif N > rn + 7 and dt < FOREST_W / 2 * (0.9 + 0.1 * vn(E, N, 70, 7)):
                c = '2f372a' if vn(E, N, 9, seed + 2) < 0.8 else '3c532b'
                hz = min(hz, 0.22)
            elif dep > 2600:
                c = '5e6f63' if vn(E, N, 160, seed + 3) < 0.55 else '7a8d81'
            else:
                v = vn(E, N, 55, seed + 4)
                c = '5c7149' if v < 0.4 else '75895d' if v < 0.7 else '8b9284'
                if abs((vn(E, N, 90, seed + 5) * 6) % 1.0 - 0.5) < 0.06:
                    c = '3c532b'                                   # hedgerows
            px[x, y] = S(mix(c, sky(x, y), hz))


def mock_vista():
    base = to1x(R2 + '13_road_vista.png')
    bp = base.load()
    W, H = base.size
    S = Snap(load_pal('dawn.png'), load_pal('wayline_tower.png'))
    img = Image.new('RGB', (W, H))
    px = img.load()
    P = vista_camera()
    HZ = int(round(P.cy + P.f * P.st / P.ct))           # the horizon (eye level, far away)
    SKY = [(0, '4d6582'), (22, '556c83'), (44, '5d758f'), (66, '6c8b96'), (86, '738f97'), (102, '8da2aa'),
           (116, '9cabb1'), (126, 'bdbdb5'), (134, 'e2c59b'), (139, 'f5e4bd')]

    def sky(x, y):
        c = SKY[0][1]
        for y0, cc in SKY:
            if y >= y0:
                c = cc
        if y >= 130 and x > 250:
            c = 'f5e4bd'                                      # dawn glow in the east
        return hx(c)
    for y in range(H):
        for x in range(W):
            c = sky(x, y)
            for y0, _ in SKY[1:]:
                if y == y0 - 1 and (x + y) % 2:
                    c = sky(x, y + 1)
            px[x, y] = S(c)
    TX, TDZ = cam_rel(VISTA_BEAR, P.D)
    tz = P.D + TDZ
    # a pale far ridge on the horizon, then the land, tile by tile
    for x in range(W):
        top = int(HZ - 2 + 1.5 * math.sin(x / 23.0) + 1.5 * vn(x, 0, 11, 2))
        for y in range(top, HZ + 1):
            px[x, y] = S('a3a891' if y == top else '8b9284')
    paint_ground(px, W, H, S, P, VISTA_BEAR, sky, HZ + 1, H)
    # the forest: full-size trees, 3 to 5 px here; far ones first, the great tree, then the nearer ones
    pts = forest_points(VISTA_BEAR, P.D, step=9.0)
    fcols = ['2f372a', '4a6530', '75895d']

    def fhaze(z):
        return min(0.2, max(0.0, (z - 700) / 4000))
    paint_forest(px, W, H, S, P, [p for p in pts if p[0] > tz], fcols, sky, haze=fhaze, tree_h=20.0)
    # The great tree as the title paints it (2026-10-28, Preston: the same tree in both): the crown one even dome
    # centred on its trunk, leaf clusters each with a lit top arc, limbs under it; in the morning's greens and bark,
    # lit from the east, hazed a third toward the sky.
    day = dict(zip(TITLE_BARK + TITLE_CROWN[1:], ['4c4a40', '574c32', '796145', '8b6d4d', 'a28862',
                                                  '2f372a', '3c532b', '4a6530', '5c7149', '75895d']))
    title_tree(px, W, H, S, P, lambda x, y: True, light=1, calm=None, seed=5, X0=TX, dz=TDZ, pal=day,
               tint=lambda c, x, y: mix(c, sky(x, y), 0.32))
    paint_forest(px, W, H, S, P, [p for p in pts if P.D < p[0] <= tz], fcols, sky, haze=fhaze, tree_h=20.0)
    # a waypost of a few roofs at the trunk's foot, on the root road: a house is 5 tiles (proposal)
    for k, (de, dn) in enumerate(((-150, -118), (-142, -122), (-146, -112), (-135, -116))):
        X, dz = cam_rel(VISTA_BEAR, P.D, TREE_E + de * 0.6 + 0.0, TREE_N + dn)
        x, y = int(round(P.sx(X, 0, dz))), int(round(P.sy(0, dz)))
        for a in range(2):
            px[x + a, y - 1] = S(mix('b06b3d', sky(x, y), 0.3))
            px[x + a, y] = S(mix('c49b69', sky(x, y), 0.3))
    # the cloud layer: flat banks level with the collar (280 to 360 tiles); the crown's cap rises above them
    dx = TX + 301
    for (Xa, Xb, hh, dzz, sd) in ((-560, -380, 330, TDZ, 3), (-330, -150, 318, TDZ, 4), (-430, -340, 300, TDZ, 9),
                                  (60, 200, 336, 0, 5), (150, 330, 300, 80, 6)):
        if dzz:
            Xa, Xb = Xa + dx, Xb + dx
        cloud_bank(px, W, H, S, P.sx(Xa, hh, dzz), P.sx(Xb, hh, dzz), P.sy(hh + 10, dzz), 13 * P.s(hh, dzz),
                   light=1, seed=sd)
    # the Wayline Tower: whole, foot at y 200, vane at y 8
    paint_tower(px, W, H, S, P, 0, sky, haze0=0.02, haze1=0.3, light=1, lit_win=0.22, lamp_glow=True)
    beacon = (int(round(P.sx(4, LAMP_T))), int(round(P.sy(LAMP_T))) + 1)
    px[beacon] = S('eeb970')                       # the Waiting Lamp's amber heart (the slot's beacon anchor)
    AXV = int(round(P.sx(0, 0)))
    sy, sxL, sxR = P.sy(208), P.sx(-16, 208), P.sx(16, 208)
    for p0, end, sag in (((sxR, sy), (384, HZ + 4), 14),):
        line_px(px, W, H, catenary(p0, end, sag), S('5d4b34'), dotted=2)
    paint_forest(px, W, H, S, P, [p for p in pts if p[0] <= P.D], fcols, sky, haze=fhaze, tree_h=20.0)
    # Highbank, painted after the nearer trees so it sits in its own clearing: its roofs set back to the west of the Tower and beyond it, 90 to 190 tiles north, so they show over
    # the party's hill and leave open ground round the Tower's foot (2026-10-28, Preston: no other buildings by the
    # Tower); a house is 5 tiles, 2 or 3 px here (proposal). Every seventh holds a lamp.
    rnd = random.Random(8)
    lamps = []
    for k in range(30):
        X, dz = cam_rel(VISTA_BEAR, P.D, -60.0 - rnd.uniform(0.0, 70.0), 90.0 + rnd.uniform(0.0, 100.0))
        x, yb = int(round(P.sx(X, 0, dz))), int(round(P.sy(0, dz)))
        w = rnd.choice((2, 3, 3))
        col = rnd.choice(('b06b3d', 'a7774e', '8b6d4d', '9b8c68', 'a37a32'))
        for a in range(-1, w + 1):
            px[x + a, yb + 1] = S(mix('a3a891', sky(x, yb), 0.2))   # the cleared ground
        for a in range(w):
            px[x + a, yb - 1] = S(col)
            px[x + a, yb] = S('e2c59b' if hn(x + a, yb, 2) < 0.7 else 'eeb970')
        lamps.append((x + 1, yb))
    # foreground, repainted darker and lower: the party's hill, dark lobed framing trees, the party itself
    HILLC = {hx(c) for c in ('3e5629', '2f3d2a', '315d1f', '51822b', '5b9331')}
    VALC = {hx('7f9467'), hx('6f8455')}
    SKYCAP = {hx(c) for c in ('9cabb1', 'bdbdb5', 'a3b0ae', 'b8c2bc', '8da2aa', 'e2c59b', 'f5e4bd', '738f97')}

    def strong(x, y):
        c = bp[x, y]
        return c not in HILLC and c not in VALC and c not in SKYCAP
    party = {}
    feet = 0
    for (xa, xb) in ((78, 106), (113, 141)):
        for y in range(134, 187):
            xs = [x for x in range(xa, xb) if strong(x, y)]
            if len(xs) > 14 and len({bp[x, y] for x in xs}) <= 2:
                continue                                   # a flat line of the old capture, not a creature
            if len(xs) >= 2:
                for x in range(min(xs), max(xs) + 1):
                    if bp[x, y] not in VALC and bp[x, y] not in SKYCAP:
                        party[(x, y)] = bp[x, y]
                feet = max(feet, y)

    def hill_top(x):
        return feet + 1 + max(0, x - 150) * 0.24 + max(0, 66 - x) * 0.06 + 1.2 * math.sin(x / 9.0)
    for x in range(0, 260):
        t = int(hill_top(x))
        for y in range(max(0, t), H):
            d = y - t
            c = '5c7149' if d == 0 else '3c532b' if d < 3 else '2f372a'
            if d >= 3 and vn(x, y, 3, 4) > 0.72:
                c = '3c532b'
            elif d >= 6 and vn(x, y, 5, 9) < 0.18:
                c = '25301f'
            px[x, y] = S(c)
        if hn(x, 7, 3) > 0.7 and t - 1 >= 0:
            px[x, t - 1] = S('3c532b')
    for (cx, cy, r) in ((-4, 8, 22), (20, -2, 20), (38, 22, 16), (8, 40, 18), (30, 52, 12), (-6, 70, 14)):
        blob(px, W, H, S, cx, cy, r * 1.05, r, lambda a, b, xx, yy: '3c532b' if a > 0.55 and b > -0.2 else '2a3326'
             if vn(xx, yy, 4, 2) > 0.7 else '2f372a')
    for y in range(40, H):
        for x in range(6, 14 + (y - 40) // 40):
            px[x, y] = S('2a3326' if x > 10 else '2f372a')
    for (cx, cy, r) in ((396, 6, 26), (372, 20, 18), (390, 44, 20), (364, 52, 12), (392, 74, 14)):
        blob(px, W, H, S, cx, cy, r * 1.05, r, lambda a, b, xx, yy: '3c532b' if a < -0.6 and b > -0.2 else '2a3326'
             if vn(xx, yy, 4, 3) > 0.7 else '2f372a')
    for y in range(60, H):
        for x in range(374, 383):
            px[x, y] = S('2a3326' if x < 378 else '2f372a')
    # The slot road.backdrop.vista: this picture without the party (the game draws them), at most 64 colours. Its
    # house lamps: up to five lit walls still in sight over the hill, spread along the town.
    walls = {S('e2c59b'), S('eeb970')}
    seen = sorted({p for p in lamps if px[p] in walls})
    lamps = [seen[round(i * (len(seen) - 1) / 4)] for i in range(5)] if len(seen) >= 5 else seen
    slot = img.copy()
    sp = slot.load()
    cnt = {}
    for y in range(H):
        for x in range(W):
            cnt[sp[x, y]] = cnt.get(sp[x, y], 0) + 1
    S64 = Snap(sorted(cnt, key=lambda c: -cnt[c])[:64])
    for y in range(H):
        for x in range(W):
            sp[x, y] = S64(sp[x, y])
    slot.save(f'{OUT}/slot_vista.png')
    REPORT_EXTRA['vista_slot'] = ('%d colours; beacon %s; lamps %s' % (len(slot.getcolors(1 << 16)),
                                  beacon, sorted(set(lamps))))
    for (x, y), c in party.items():
        px[x, y] = c
    REPORT_EXTRA['vista'] = ('tree across %.0f tiles, %.0f deeper; trunk x %.0f, %.0f px wide; crown %.0f px; foot y %.0f; '
                             'forest trees %.1f to %.1f px; party feet y %d'
                             % (TX, TDZ, P.sx(TX, 0, TDZ), TRUNK_W * P.s(0, TDZ), CROWN_W * P.s(300, TDZ), P.sy(0, TDZ),
                                11 * P.s(0, TDZ + 300), 11 * P.s(0, -200), feet))
    save(img, 'vista', 'road home: the whole Tower looking up from the last hill, the tree in its forest; dawn + wayline_tower')
    return img, P, HZ


def mock_road_far():
    """The far beat of the road home, from 3,000 tiles out: the slot road.backdrop.highbank_far (160 x 96, dawn,
    at most 24 colours), exported to final/slot_highbank_far.png (the key colour transparent), at 1.0 on a plain sky,
    and placed in the round-2 capture 12b at 0.82.

    2026-10-28 (slice 2 of "fix the cliff tree and tower and everything else so codex can go ham"): the great tree is
    the title's tree (title_tree in the morning's colours, its crown one even dome centred on its trunk), the whole
    480-tile Tower stands alone in open ground with Highbank's roofs in a clearing west of it and beyond it, both
    giants over the forest band, and one broken wayline runs from the Low Reel down to the roofs (the scene's glint
    runs on it). The scene stands the slot's bottom row at y 108, behind the far hills (road.backdrop.far, tops at
    y 92 to 107), so the Tower's foot, the forest band and the town sit at rows 68 to 76, above the hills: the Tower
    is 70 px tall (vane row 5, foot row 75), not the 88 px first proposed, which put all of that behind the hills."""
    SW, SH = 160, 96
    AX, FOOT_Y = 104, 75                     # the Tower's axis and its foot row
    ANCHOR = (AX, SH - 1)                    # the slot's foot anchor: the bottom row, under the Tower
    D, CAMH = 3000.0, 150.0
    ppt = 70.0 / 480                         # 1 px for 6.9 tiles
    f = ppt * D
    P = Proj(f, AX, FOOT_Y - f * CAMH / D, D, 0.0, CAMH)
    KEY = (255, 0, 255)
    slot = Image.new('RGB', (SW, SH), KEY)
    sp = slot.load()
    # The dawn palette as committed at bf1a288 (refs/palettes/dawn.png), frozen here: render_slot_refs rebuilds that
    # file from every dawn placeholder, this slot among them, so snapping to the live file drifts a little with
    # each render of the ref and the export never settles.
    DAWN = ['f6e6c0', 'deded0', 'e6d1ae', 'c2d4df', 'e4bd6c', 'abc2d3', 'debb76', 'c9b38e', 'c1ac88', 'a0adb0',
            'b79b75', '979683', '7a95a5', '7f9394', 'b18956', '7e9191', '838e87', 'ad8459', '9b876c', '878b7c',
            'ac8258', '7a8993', '8c8466', '758789', '66899d', '748471', '6f8455', '8d6c4d', '73734d', '58708b',
            '59753c', '596d6f', '886346', '866144', '796145', '4b6731', '565b40', '3d542b', '45502d', '2d3729']
    S = Snap(DAWN, load_pal('wayline_tower.png'))

    def sky(x, y):
        return KEY                            # painted clear: the scene hazes the whole layer

    TX, TDZ = cam_rel(VISTA_BEAR, D)
    FAR_CUT = D + 600.0                       # land beyond the forest band is left to the sky (the scene's haze)
    TOWN = (-240.0, 200.0)                    # Highbank's open ground: east of E -240, from the river to N 200

    def open_ground(E, N):
        return E > TOWN[0] and N < TOWN[1]
    # The land, back-projected pixel by pixel: the forest floor round the great tree, along the band and on the near
    # bank, Highbank's open ground (the town's fields and the Tower's clearing) and the river. Below the band it runs
    # to the bottom edge, so nothing floats where the hills dip.
    for y in range(SH):
        lo, hi = -P.D + 2.0, 60000.0
        if P.sy(0, hi) >= y + 0.5:
            continue
        for _ in range(40):
            mid = (lo + hi) / 2
            if P.sy(0, mid) > y + 0.5:
                lo = mid
            else:
                hi = mid
        dz = (lo + hi) / 2
        if D + dz > FAR_CUT:
            continue
        for x in range(SW):
            E, N, dep = ground_point(P, VISTA_BEAR, x, y, dz)
            rn = river_n(E)
            if abs(N - rn) < 9:
                c = '9cabb1'
            elif open_ground(E, N) and N > rn:
                c = 'a3a891' if vn(E, N, 30, 5) > 0.45 else '8b9284'
            else:
                c = '2f372a'
            sp[x, y] = S(c)
    # The forest: full-size trees round the great tree (20 tiles) and a band of woods behind Highbank (16 tiles),
    # far to near, none on the open ground.
    fcols = ['2f372a', '3c532b', '4a6530']              # darker than the vista's: the lit '75895d' snaps to a grey here
    pts = [p for p in forest_points(VISTA_BEAR, D, step=11.0, clear=((0.0, 0.0, 46.0),))]
    band = []
    b = math.radians(VISTA_BEAR)
    ce, cn = D * math.sin(b), D * math.cos(b)
    fe, fn = -math.sin(b), -math.cos(b)
    rnd = random.Random(11)
    for k in range(2400):
        E, N = rnd.uniform(-900.0, 700.0), rnd.uniform(TOWN[1], 700.0)
        if math.hypot(E - TREE_E, N - TREE_N) < FOREST_W / 2:
            continue                                      # the great tree's own forest is forest_points'
        ve, vv = E - ce, N - cn
        X, dz = ve * fn - vv * fe, ve * fe + vv * fn - D
        if D + dz < FAR_CUT:
            band.append((D + dz, X, dz, hn(k, 3, 9)))
    # the woods on the near bank, from the river down to the bottom edge (behind the scene's far hills), smaller
    # trees so the town's roofs still show over them
    near = []
    for i in range(80):
        for j in range(-60, 61):
            dz = -1460.0 + i * 18.0 + (hn(i, j, 21) - 0.5) * 14.0
            X = j * 14.0 + (hn(j, i, 22) - 0.5) * 12.0
            E, N = ce + X * fn + (D + dz) * fe, cn - X * fe + (D + dz) * fn
            if N < river_n(E) - 9 and abs(P.sx(X, 0, dz) - SW / 2) < SW / 2 + 6:
                near.append((D + dz, X, dz, hn(i, j, 23)))
    def en(X, dz):                                        # a point's ground place (E, N) back from (X, dz)
        return ce + X * fn + (D + dz) * fe, cn - X * fe + (D + dz) * fn
    pts = sorted([p for p in pts if not open_ground(*en(p[1], p[2]))] + band, key=lambda p: -p[0])
    tz = D + TDZ
    paint_forest(sp, SW, SH, S, P, [p for p in pts if p[0] > tz], fcols, sky, tree_h=18.0)
    # The great tree as the title paints it, in the morning's greens and bark (mock_vista's colours), unhazed.
    day = dict(zip(TITLE_BARK + TITLE_CROWN[1:], ['4c4a40', '574c32', '796145', '8b6d4d', 'a28862',
                                                  '2f372a', '3c532b', '4a6530', '5c7149', '75895d']))
    title_tree(sp, SW, SH, S, P, lambda x, y: True, light=1, calm=None, seed=5, X0=TX, dz=TDZ, pal=day)
    paint_forest(sp, SW, SH, S, P, [p for p in pts if D < p[0] <= tz], fcols, sky, tree_h=18.0)
    # Highbank: mock_vista's thirty roofs (the same seed and ground), 1 or 2 px here, west of the Tower and beyond it.
    rnd = random.Random(8)
    houses = []
    for k in range(30):
        X, dz = cam_rel(VISTA_BEAR, D, -60.0 - rnd.uniform(0.0, 70.0), 90.0 + rnd.uniform(0.0, 100.0))
        x, yb = int(round(P.sx(X, 0, dz))), int(round(P.sy(0, dz)))
        w = 1 if rnd.choice((2, 3, 3)) == 2 else 2
        col = rnd.choice(('b06b3d', 'a7774e', '8b6d4d', '9b8c68', 'a37a32'))
        houses.append((dz, x, yb, w, col))
    for dz, x, yb, w, col in sorted(houses, reverse=True):
        for a in range(w):
            if inside(SW, SH, x + a, yb):
                sp[x + a, yb - 1] = S(col)
                sp[x + a, yb] = S('e2c59b')
    # The cloud layer at the collar (280 to 360 tiles): banks across the crown and either side of the Tower.
    for (Xa, Xb, hh, dzz, sd) in ((-520, -330, 322, TDZ, 3), (-300, -150, 300, TDZ, 4), (40, 230, 330, 0, 5),
                                  (150, 300, 296, 0, 6)):
        cloud_bank(sp, SW, SH, S, P.sx(Xa, hh, dzz), P.sx(Xb, hh, dzz),
                   P.sy(hh + 10, dzz), 12 * P.s(hh, dzz), light=1, seed=sd)
    # The Wayline Tower, whole, alone in its clearing; the Waiting Lamp's amber heart on the beacon.
    tower = Image.new('RGB', (SW, SH), KEY)
    paint_tower(tower.load(), SW, SH, S, P, 0, sky, haze0=0.0, haze1=0.0, light=1, lit_win=0.15, lamp_glow=False,
                root=False)
    tp = tower.load()
    # The root, 1 px here (paint_tower's root is 2 px under 1.5 px of girth, the whole neck at this size): up the
    # Stack's west edge, and outside the narrow collar and neck so they keep their stone, to the crook.
    for y in range(int(P.sy(CROWN_T)), FOOT_Y + 1):
        t = P.h_at(y + 0.5)
        w, m = width_at(t)
        if not w:
            continue
        rc = P.sx(0, t) - w * P.s(t) / 2
        x = int(rc + 0.5) if w * P.s(t) >= 3.5 else int(rc + 0.5) - 1
        tp[x, y] = S(ROOTR[2])
    for y in range(SH):
        for x in range(SW):
            if tp[x, y] != KEY:
                sp[x, y] = tp[x, y]
    beacon = (int(round(P.sx(4, LAMP_T))), int(round(P.sy(LAMP_T))) + 1)
    sp[beacon] = S('eeb970')
    # One wayline: a broken 1 px cable from the Low Reel's west side (34 tiles up) down to a roof in the middle of
    # the town, sagging 3 px at its middle; route_scene.far_wayline_at is the same curve, so the glint runs on it.
    # Lit by the low sun, so it shows against the dark forest band behind it.
    top = (int(round(P.sx(-17, 34))) - 1, int(round(P.sy(34))))
    mid_house = sorted(houses, key=lambda h: h[1])[len(houses) // 2]
    end = (mid_house[1], mid_house[2] - 1)
    n = int(math.hypot(end[0] - top[0], end[1] - top[1]))
    for i in range(n):
        if i % 4 != 3:
            t = i / n
            x = top[0] + (end[0] - top[0]) * t
            y = top[1] + (end[1] - top[1]) * t + 3.0 * math.sin(math.pi * t)
            sp[int(x), int(y)] = S('9c8c68')
    # the nearer woods last, so the Tower's foot stands in its trees, then the near bank's
    paint_forest(sp, SW, SH, S, P, [p for p in pts if p[0] <= D], fcols, sky, tree_h=18.0)
    paint_forest(sp, SW, SH, S, P, sorted(near, key=lambda p: -p[0]), ['2f372a', '2f372a', '3c532b'], sky, tree_h=13.0)
    # Under the band, valley mist: in the scene the far hills (road.backdrop.far) stand in front of the lower rows,
    # but where they dip the land shows down to about row 90, so it thins into mist the colour of the hazed hills
    # instead of ending in a dark edge. The Tower, the town and the cable stay as painted.
    keep = {(x, y) for y in range(SH) for x in range(SW) if tp[x, y] != KEY}
    for dz, x, yb, w, col in houses:
        keep |= {(x + a, yy) for a in range(w) for yy in (yb - 1, yb)}
    for y in range(76, SH):
        for x in range(SW):
            if sp[x, y] == KEY or (x, y) in keep:
                continue
            r = hn(x, y, 41)
            if y >= 79 or r < (0.35, 0.6, 0.85)[y - 76]:
                sp[x, y] = S('bdbdb5' if (y < 80 and r < 0.5) or vn(x, y * 4, 9, 42) > 0.78 else '9cabb1')
    # The slot may touch only its bottom edge (a single picture, not a strip): toward both sides the land's top
    # rounds down, the forest band sinking into the mist and the mist to the bottom edge, so its edge columns stay
    # empty and no side of it ends in a cut.
    TAPER = 34.0
    for x in range(SW):
        e = min(x, SW - 1 - x)
        if e >= TAPER:
            continue
        k = e / TAPER
        k = k * k * (3 - 2 * k)
        lim = 69.0 + (SH + 1 - 69.0) * (1 - k) ** 1.6 + (1.5 * vn(x, 0, 3, 31) if e > 0 else 0)
        for y in range(60, SH):
            if y < lim and (x, y) not in keep:
                sp[x, y] = KEY
    # At most 24 colours: the lamp's amber, the cable, the roofs and the fields always, then the most used.
    cnt = {}
    for y in range(SH):
        for x in range(SW):
            if sp[x, y] != KEY:
                cnt[sp[x, y]] = cnt.get(sp[x, y], 0) + 1
    must = [S('eeb970'), S('9c8c68'), S('b06b3d'), S('a3a891')]
    top24 = must + [c for c in sorted(cnt, key=lambda c: -cnt[c]) if c not in must][:24 - len(must)]
    S24 = Snap(top24)
    for y in range(SH):
        for x in range(SW):
            if sp[x, y] != KEY:
                sp[x, y] = S24(sp[x, y])
    # The box the scene and its checks measure (route_scene.gd FAR_BODY): the Tower's own pixels still showing, as
    # wide as its Stack (the collar's cloud lumps left out), from the vane down to the Low Reel (where the forest band
    # and the cable begin).
    xs, ys = [], []
    for y in range(SH):
        for x in range(SW):
            if (tp[x, y] != KEY and sp[x, y] == S24(tp[x, y]) and y <= top[1]
                    and abs(x + 0.5 - AX) <= 17 * ppt + 1.5):
                xs.append(x)
                ys.append(y)
    body = (min(xs), min(ys), max(xs) - min(xs) + 1, max(ys) - min(ys) + 1)
    out = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    op = out.load()
    for y in range(SH):
        for x in range(SW):
            if sp[x, y] != KEY:
                op[x, y] = sp[x, y] + (255,)
    out.save(f'{OUT}/slot_highbank_far.png')
    anchors = {'foot': ANCHOR, 'beacon': beacon, 'wayline_top': top, 'wayline_end': end}
    REPORT_EXTRA['highbank_far_slot'] = ('%d colours; anchors %s; tower body box (x, y, w, h) %s; beacon colour %s'
                                         % (len(out.getcolors(1 << 16)) - 1, anchors, body, sp[beacon]))
    view = Image.new('RGB', (SW, SH))
    vp = view.load()
    for y in range(SH):
        for x in range(SW):
            vp[x, y] = sp[x, y] if sp[x, y] != KEY else S(mix('8da2aa', 'e2c59b', y / SH))
    save(view, 'road_far_slot', 'slot road.backdrop.highbank_far at 1.0 (160x96) on a plain sky; anchors %s' % anchors)
    # into the capture at 0.82: the old far Tower, its bluff and its roofs painted out with the road's sky slot (the
    # sky layer does not scroll, so it is the same sky), the willows kept; then the slot drawn only on that sky, its
    # Tower's foot where the old one stood, so the willows and the far hills stay in front of it
    cap = to1x(R2 + '12b_road_far_tower_beat.png')
    cp = cap.load()
    W, H = cap.size
    skyref = Image.open(DOCS + '/design/placeholder-factory-2026-10-26/refs/road.backdrop.sky.png').convert('RGB').load()

    def green(c):
        return c[1] > c[0] + 6 and c[1] > c[2] + 6
    open_sky = set()
    for y in range(H):
        for x in range(W):
            if 236 <= x <= 328 and y <= 95 and not green(cp[x, y]):
                cp[x, y] = skyref[x, y]
            if cp[x, y] == skyref[x, y]:
                open_sky.add((x, y))
    sc = 0.82
    small = slot.resize((int(SW * sc), int(SH * sc)), Image.NEAREST)
    mp = small.load()
    FX, FY = 283, 97                                      # where the old far Tower stood
    ox, oy = FX - int(AX * sc), FY - int(FOOT_Y * sc)
    for y in range(small.height):
        for x in range(small.width):
            c = mp[x, y]
            X, Y = ox + x, oy + y
            if c == KEY or (X, Y) not in open_sky:
                continue
            cp[X, Y] = S(mix(c, cp[X, Y], 0.35))
    REPORT_EXTRA['road_far'] = ('tree across %.0f, %.0f deeper; in the slot tower %.0f px, tree %.0f px tall, crown %.0f px, '
                                'trunk %.0f px; forest trees %.1f px; at 0.82: tower %.0f px, tree %.0f px'
                                % (TX, TDZ, 480 * ppt, TREE_H * P.s(0, TDZ), CROWN_W * P.s(300, TDZ), TRUNK_W * P.s(0, TDZ),
                                   18 * P.s(0, TDZ), 480 * ppt * sc, TREE_H * P.s(0, TDZ) * sc))
    save(cap, 'road_far', 'road far (round2/12b) with the slot at 0.82: both giants over the forest band')
    return cap


def mock_door():
    base = to1x(R2 + '02_rise_door_lean.png')
    img = base.copy()
    px, bp = img.load(), base.load()
    W, H = img.size
    S = Snap(load_pal('town_stone.png'), load_pal('wayline_tower.png'))

    def grassy(c):
        return (c[1] > c[0] + 4 and c[1] > c[2] + 8) or c in {hx('2a361d'), hx('3a4624'), hx('313c26'), hx('12837f')}
    # plinth step 1's face: the turf north of the depot's wings becomes footing (side lanes, rows 0 to 3)
    for y in range(0, 60):
        for x in list(range(0, 96)) + list(range(300, W)):
            fy = (46 + int(3 * math.sin(x / 9.0))) if x < 96 else (44 + int(2 * math.sin(x / 7.0)))
            if y >= fy or not grassy(bp[x, y]):
                continue
            course = y // 13
            blk = (x + course * 23) % 41
            k = 1
            if y % 13 == 0 or blk == 0:
                k = 3
            elif y % 13 == 1:
                k = 0
            elif y % 13 >= 11:
                k = 2
            c = ['ccb290', 'c7a378', '9c8c68', '5d4b34'][k]
            if y > fy - 7 and vn(x, y, 4, 3) > 0.45:
                c = '6b6d45' if y > fy - 3 else '908940'
            elif k == 1 and vn(x, y, 3, 5) > 0.8:
                c = 'c49b69'
            px[x, y] = S(c)
        if y in (45, 46):
            for x in list(range(0, 96)) + list(range(300, W)):
                if grassy(bp[x, y]) and hn(x, y, 1) < 0.5:
                    px[x, y] = S('44421a')
    # paint out today's diagonal root_foot first (it would show as a second root): turf west of the hall's
    # wall, hall wall east of it, each smeared in from its own side
    OLDROOT = {hx(c) for c in ('b06b3d', '663f23', '8c6545', '181412', '0b0e11', 'ad693c', 'a8673b', '4b392a',
                               '2a1a0f', '241b16')}
    A, B = (30, 172), (106, 18)
    L2 = (B[0] - A[0]) ** 2 + (B[1] - A[1]) ** 2

    def near_old(x, y):
        t = max(0.0, min(1.0, ((x - A[0]) * (B[0] - A[0]) + (y - A[1]) * (B[1] - A[1])) / L2))
        return math.hypot(x - A[0] - t * (B[0] - A[0]), y - A[1] - t * (B[1] - A[1])) < 19
    wall_x = lambda y: 70 if y >= 145 else 60
    for y in range(H):
        for x in range(0, 130):
            if not (near_old(x, y) and bp[x, y] in OLDROOT):
                continue
            if x < wall_x(y):
                c = ('2a361d', '3a4624', '313c26')[int(hn(x, y, 4) * 2.99)]
            else:
                c = 'ccb290' if y % 9 == 0 or (x + (y // 9) * 7) % 17 == 0 else 'e6c697'
            px[x, y] = S(c)
    filled = img.copy()
    fp = filled.load()
    # the main root: arrives from the west-north-west along the ground, half buried, then climbs the
    # footing out of the top of the frame. 4 tiles thick at the ground; the depot stays in front of it
    keep = {}
    for y in range(H):
        for x in range(36, 300):
            if not grassy(fp[x, y]):
                keep[(x, y)] = True

    def ok(x, y):
        return (x, y) not in keep
    draw_root(px, W, H, S, [(-80, 96), (-30, 92), (10, 80), (30, 58), (36, 30), (34, 0), (36, -30)],
              92, 72, light=(-0.7, -0.7), seed=31, moss=0.34, ok=ok, swell=0.1, soil='3f2716')
    for pts, w0 in (([(26, 104), (44, 114), (62, 118)], 8), ([(4, 112), (2, 128), (8, 140)], 7),
                    ([(50, 40), (70, 44), (86, 42)], 5)):
        draw_root(px, W, H, S, pts, w0, 1.5, light=(-0.7, -0.7), seed=int(pts[0][0]) + 3, moss=0.0, ok=ok,
                  swell=0.0, soil='3f2716')
    for (tx_, ty_) in ((20, 76), (27, 64), (31, 52)):        # treads cut into its lower run (the Climb)
        for a in range(-8, 9):
            if inside(W, H, tx_ + a, ty_) and ok(tx_ + a, ty_):
                px[tx_ + a, ty_] = S('c49b69')
                px[tx_ + a, ty_ + 1] = S('3f2716')
    save(img, 'door_lean', 'Tower Rise doors, 72 px lean (round2/02): the main root and the plinth footing')
    return img


# ================================================================================================ 4. STREET
def mock_street():
    """The Street's north rows (round2/06b) under a 60 px far band (proposal B1, taller): the map's top rows
    move down 70 px; the quest panels and controls stay where they are on screen."""
    base = to1x(R2 + '06b_street_wayline_top_rows.png')
    bp = base.load()
    W, H = base.size
    BAND = 60
    SHIFT = BAND + 10
    S = Snap(load_pal('dawn.png'), load_pal('wayline_tower.png'), load_pal('town_stone.png'))
    img = Image.new('RGB', (W, H))
    px = img.load()
    SKYB = [(0, '738f97'), (14, '8da2aa'), (28, '9cabb1'), (44, 'bdbdb5'), (58, 'd1b590')]

    def sky(x, y):
        c = SKYB[0][1]
        for y0, cc in SKYB:
            if y >= y0:
                c = cc
        return hx(c)
    for y in range(BAND + 12):
        for x in range(W):
            c = sky(x, y)
            if any(y == y0 - 1 for y0, _ in SKYB[1:]) and (x + y) % 2:
                c = sky(x, y + 1)
            px[x, y] = S(c)
    def green(c):
        return (c[1] > c[0] + 4 and c[1] > c[2] + 8) or c[1] > 120 and c[0] < 120
    for y in range(BAND + 12, H):
        for x in range(W):
            c = bp[x, y - SHIFT]
            if y - SHIFT < 38 and x < 206:
                sx = 206 + x % 110                     # hedge east of the panels, short of the stone pillar
                c = bp[sx, y - SHIFT]
            px[x, y] = c

    def band(x, y):
        return y < BAND + 12
    # the great tree: trunk 42 px, its crown's underside a dark ceiling across the band's top
    pal = {'crown': ['2f372a', '3c532b', '4a6530', '5c7149', '75895d'],
           'bark': ['4c4a40', '574c32', '796145', '8b6d4d', 'a28862'],
           'spur': ['3c532b', '4a6530', '5c7149'], 'rim': ['a3a891'], 'moss': ['5c6a3b', '73754e'],
           'forest': ['2f372a', '3c532b', '516b38']}
    TP = Proj.level(0.42, 196, 110)
    paint_tree(px, W, H, S, TP, 0, 0, band, pal, sky, haze=0.16, light=1, seed=5, crown_haze=0.22, forest=False)
    # the Wayline Tower: 1.5 px a tile, the Stack off the top; today's drum on the plinth, 9.5 tiles west,
    # with Codex's ring deck on it as the Low Reel (34 tiles up), the town's waylines leaving from it
    AX = 338
    PT = Proj.level(1.5, AX, BAND + 20)
    paint_tower(px, W, H, S, PT, 0, sky, haze0=0.1, haze1=0.14, light=1, lit_win=0.12, collar=False, ok=band)
    DX = AX - 9.5 * 1.5
    y16, y30, y34, y38 = (int(round(PT.sy(h))) for h in (16, 30, 34, 38))
    for y in range(y30, y16 + 1):
        for x in range(int(DX - 10), int(DX + 11)):
            u = (x + 0.5 - DX) / 10.5
            c = 'f5d9a8' if u > 0.35 else 'e6c697' if u > -0.3 else 'ccb290'
            if (y - y30) % 6 == 3 and abs(u) < 0.8:
                c = 'fbd490' if hn(x // 3, y, 4) < 0.3 else '5d4b34'
            px[x, y] = S(c)
    for y in range(y34, y30 + 1):
        for x in range(int(DX - 15), int(DX + 16)):
            px[x, y] = S('d4a94c' if y < y30 - 1 else '6b4f1f')
    for y in range(y38, y34):
        hw = 10 * (y - y38 + 1) / (y34 - y38 + 1)
        for x in range(int(DX - hw), int(DX + hw) + 1):
            px[x, y] = S('908940' if x > DX else '6b6d45')
    for x in range(292, W):                       # a mist wisp across the Stack
        if vn(x, 0, 10, 4) < 0.3:
            continue
        yy = 9 + int(1.5 * math.sin(x / 17.0))
        px[x, yy] = S('f5e4bd')
        if vn(x, 1, 7, 5) > 0.4:
            px[x, yy + 1] = S('bdbdb5')
    # rooftops of the Rise and the yard over the hedge: gables, chimneys, a few trees between
    rnd = random.Random(3)
    x = -6
    while x < W:
        w = rnd.choice((10, 12, 16, 18, 22, 26))
        h = max(3, min(9, int(w * rnd.uniform(0.28, 0.4))))
        wall = rnd.choice((2, 3, 3, 5))
        roof = rnd.choice(('b06b3d', '8c6545', '5b6671', '92724b', 'a37a32'))
        yb = BAND + 12 - rnd.choice((0, 0, 1, 2))
        if rnd.random() < 0.3:
            for k in range(rnd.choice((1, 2))):
                small_tree(px, W, H, S, x + 5 + k * 7, BAND + 12, rnd.choice((8, 10, 12)), ['3e5629', '516b38', '75895d'],
                           lambda a, b: True, sky, 0.1, 1)
            x += 10 + rnd.choice((0, 6))
            continue
        for yy in range(yb - wall - h, BAND + 12):
            for xx in range(x, x + w):
                if not inside(W, H, xx, yy):
                    continue
                if yy >= yb - wall:
                    c = 'e6c697' if (xx - x) % 6 not in (2, 3) else '5d4b34'
                    if xx in (x, x + w - 1):
                        c = '9c8c68'
                else:
                    d = yy - (yb - wall - h)
                    inset = max(0, int((h - d) * 0.8) - 1)
                    if xx < x + inset or xx >= x + w - inset:
                        continue
                    c = roof
                    if d == 0 or xx in (x + inset, x + w - inset - 1):
                        c = '3f2716'
                    elif d == h - 1:
                        c = '5d4b34'
                    elif (xx + d) % 3 == 0:
                        c = mix(roof, '3f2716', 0.3)
                px[xx, yy] = S(c)
        cx_ = x + w // 3
        for yy in range(yb - wall - h - 3, yb - wall - h + 2):
            if inside(W, H, cx_, yy):
                px[cx_, yy] = S('5d4b34')
                px[cx_ + 1, yy] = S('3f2716')
        x += w + rnd.choice((1, 3, 5))
    # the waylines fan down from the Low Reel's west sheave to the Street's own line and the roofs
    sheave = (int(DX - 15), y34)
    own = None
    for xx in range(150, 320):
        c = bp[xx, 3]
        if c[0] > 200 and c[1] > 180 and c[2] < 150:
            own = (xx, 3 + SHIFT)
            break
    own = own or (250, BAND + 14)
    for end, sag in ((own, 5), ((60, BAND + 6), 6), ((246, BAND + 7), 3)):
        line_px(px, W, H, catenary(sheave, end, sag), S('3f2716'))
    # the quest panels and the controls stay on top, where they are on screen
    for (x0, y0, x1, y1) in ((0, 0, 206, 34), (296, 176, 384, 216)):
        for y in range(y0, y1):
            for x in range(x0, x1):
                c = bp[x, y]
                if not ((c[1] > c[0] + 4 and c[1] > c[2] + 8) or c[1] > 120 and c[0] < 120):
                    px[x, y] = c
    REPORT_EXTRA['street'] = ('band 60 px; tree trunk %.0f px, crown %.0f px, underside y %.0f to %.0f; stack %.0f px'
                              % (TRUNK_W * TP.s(0), CROWN_W * TP.s(300), TP.sy(UNDER_C), TP.sy(UNDER_RIM), 34 * 1.5))
    save(img, 'street', 'Street north rows (round2/06b) under a 60 px far band: the Tower and the tree over the roofs')
    return img


# ================================================================================================ 5. HOLD
# The reveal's hold (2026-10-28, slice 4 of "fix the cliff tree and tower and everything else so codex can go ham"):
# story.backdrop.tower_sky is this backdrop, in its own fixed colours so the export never drifts with the live palette
# strips (render_slot_refs rebuilds refs/palettes/dawn.png from every dawn placeholder, this one among them).
HOLD_W, HOLD_H = 384, 216
HOLD_BANDS = [(0, '2e3b52'), (20, '3c4d56'), (40, '4a5e73'), (60, '4d6582'), (78, '556c83'), (96, '5d758f'),
              (110, '6c8b96'), (124, '738f97'), (134, '8da2aa'), (140, '9cabb1'), (143, 'bdbdb5')]
HOLD_HZ = 146                      # the cloud sea's far edge
HOLD_LAMP = (192, 127)             # the Waiting Lamp's glass at the scene's hold (tower_reveal.gd, TowerParts.BEACON)
HOLD_TREE = (100, 188, 0.79)       # the great tree's trunk axis x, the cloud top's row there, px a tile
HOLD_DAY = dict(zip(TITLE_CROWN[1:], ['2f372a', '3c532b', '4a6530', '5c7149', '75895d']))   # mock_vista's greens
HOLD_HAZE = ('9cabb1', 0.15)       # the tree hazed this far toward the sky at the horizon
HOLD_PAL = ([c for _, c in HOLD_BANDS] + ['f5e4bd', 'e2c59b']
            + ['%02x%02x%02x' % mix(c, HOLD_HAZE[0], HOLD_HAZE[1]) for c in HOLD_DAY.values()])


def hold_backdrop():
    """story.backdrop.tower_sky: what the reveal's hold sees behind the Tower, with no Tower and no lamp glow (the
    scene draws both). A banded dawn sky, a calm cool blue behind the Waiting Lamp, over a flat sea of cloud: the
    cloud layer's top (360 tiles) seen from the lamp (475), its far edge at HOLD_HZ. On the left the great tree's
    crown cap breaks the sea: the title's tree (title_tree: one even dome centred on its trunk, leaf clusters each
    with a lit top arc) in the morning's greens, lit from the east by the low sun, hazed a little toward the sky. At
    the true 0.79 px a tile, but composed higher than the lens (which puts its top at y 205) so it reads. No
    building: the town is under the clouds."""
    W, H = HOLD_W, HOLD_H
    S = Snap(HOLD_PAL)
    img = Image.new('RGB', (W, H))
    px = img.load()
    HZ = HOLD_HZ

    def sky(x, y):
        c = HOLD_BANDS[0][1]
        for y0, cc in HOLD_BANDS:
            if y >= y0:
                c = cc
        return hx(c)
    for y in range(H):
        for x in range(W):
            c = sky(x, y)
            if any(y == y0 - 1 for y0, _ in HOLD_BANDS[1:]) and (x + y) % 2:
                c = sky(x, y + 1)
            px[x, y] = S(c)
    for y in range(HZ, H):
        for x in range(W):
            px[x, y] = S('9cabb1')
    for x in range(W):
        px[x, HZ] = S('8da2aa')
    rnd = random.Random(11)
    lumps = []
    y, r = HZ + 2, 1.3
    while y < 236:
        x = -rnd.uniform(0, r * 3)
        while x < W + r * 3:
            n = rnd.randint(2, 5)
            for k in range(n):
                s = r * rnd.uniform(0.55, 1.5)
                lumps.append((x + k * r * 1.5 + rnd.uniform(-r * 0.3, r * 0.3), y + rnd.uniform(-r * 0.3, r * 0.2) - (s - r) * 0.6, s))
            x += n * r * 1.5 + r * rnd.uniform(1.2, 4.5)
        y += r * 0.8 + 1
        r *= 1.3
    for hx_, by, hgt, wid in ((338, 168, 24, 12), (196, 158, 10, 7)):
        yy = by
        while yy > by - hgt:
            lumps.append((hx_ + rnd.uniform(-wid * 0.18, wid * 0.18), yy, wid * (0.62 - 0.28 * (by - yy) / hgt)))
            yy -= wid * 0.33
    lumps.sort(key=lambda l: l[1])

    def draw_lump(lx, ly, rr):
        blob(px, W, H, S, lx, ly, rr * 1.5, rr,
             lambda dx, dy, a, b: 'f5e4bd' if dy - 0.35 * dx < -0.55 else 'e2c59b' if dy - 0.35 * dx < -0.1 else
             'bdbdb5' if dy - 0.35 * dx < 0.4 else '9cabb1' if dy - 0.35 * dx < 0.8 else '8da2aa',
             ok=lambda a, b: b >= HZ - 40)
    for l in lumps:
        draw_lump(*l)
    # The great tree's crown cap: the title's tree on a level lens at 0.79 px a tile, the cloud top (360 tiles) on row
    # CLOUD_Y at its trunk; only what stands above the cloud top is painted, then the sea laps round it.
    CX, CLOUD_Y, PPT = HOLD_TREE
    P = Proj.level(PPT, CX, CLOUD_Y + CLOUD_LAYER[1] * PPT)
    title_tree(px, W, H, S, P, lambda x, y: y + 0.5 < CLOUD_Y + 2.0 * (vn(x, 0, 7, 4) - 0.5), light=1, calm=None,
               seed=5, pal=HOLD_DAY, tint=lambda c, x, y: mix(c, HOLD_HAZE[0], HOLD_HAZE[1]), sun_k=1.0, rise=0.95)
    rnd2 = random.Random(5)
    for i in range(34):                                # the cloud sea laps round the cap's foot
        lx = CX + rnd2.uniform(-130, 130)
        ly = CLOUD_Y + rnd2.uniform(-1, 8)
        draw_lump(lx, ly, rnd2.uniform(4, 9))
    for i in range(12):                                # and fills in under it, nearer
        draw_lump(CX + rnd2.uniform(-100, 100), CLOUD_Y + rnd2.uniform(10, 26), rnd2.uniform(6, 11))
    greens = {hx(c) for c in HOLD_PAL[-len(HOLD_DAY):]}
    cap = [(x, y) for y in range(H) for x in range(W) if px[x, y] in greens]
    xs, ys = [p[0] for p in cap], [p[1] for p in cap]
    lx, ly = HOLD_LAMP
    cool = all(px[x, y][2] > px[x, y][0] for y in range(ly - 8, ly + 9) for x in range(lx - 8, lx + 9))
    REPORT_EXTRA['tower_sky'] = ('cap x %d to %d (%d px), rows %d to %d (dome top at y %.0f; the true lens puts it at '
                                 'y 205); %d colours; sky in the 17 px box round the lamp (%d, %d) blue over red: %s'
                                 % (min(xs), max(xs), max(xs) - min(xs) + 1, min(ys), max(ys), P.sy(TREE_H),
                                    len(img.getcolors(1 << 16)), lx, ly, cool))
    return img


def mock_hold():
    """The reveal's hold as the scene shows it: the slot's backdrop (hold_backdrop, exported as slot_tower_sky.png),
    the lamp's glow as the scene adds it (TowerParts.glow_image), and Codex's cx-14 crown where the camera holds it."""
    img = hold_backdrop()
    W, H = img.size
    img.save(f'{OUT}/slot_tower_sky.png')
    px = img.load()
    # TowerParts' glow: GLOW_HALF (25, 27) round the lamp's middle (2 px under the glass), amber added in three steps.
    gx, gy, ghx, ghy = HOLD_LAMP[0], HOLD_LAMP[1] + 2, 25, 27
    for yy in range(gy - ghy, gy + ghy + 1):
        for xx in range(gx - ghx, gx + ghx + 1):
            d = math.hypot((xx - gx) / ghx, (yy - gy) / ghy)
            for reach, amt, col in ((0.62, 0.35, 'ecb36b'), (0.82, 0.2, 'dca562'), (1.0, 0.1, 'c49243')):
                if d <= reach:
                    if inside(W, H, xx, yy):
                        a, c = px[xx, yy], hx(col)
                        px[xx, yy] = tuple(min(255, int(round(a[i] + c[i] * amt))) for i in range(3))
                    break
    crown = Image.open(CROWN_REF).convert('RGBA')
    cp = crown.load()
    for fy in range(0, H - 9):
        for fx in range(24, min(crown.width, W + 24)):
            c = cp[fx, fy]
            if c[3] > 128:
                px[fx - 24, fy + 9] = c[:3]
    save(img, 'hold', "reveal hold above the cloud sea, the great tree's crown cap breaking it; Codex's cx-14 crown")
    return img


# ================================================================================================ 6. ARRIVAL
def mock_arrival():
    spec = importlib.util.spec_from_file_location('skyline_mod', SKYLINE_PY)
    sk = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(sk)
    src = inspect.getsource(sk.build_base)
    a = src.index('    # two banks of low cloud')
    b = src.index('    # buttress roots, far to near')
    src = src[:a] + src[b:]                 # no low cloud, hanging vines or moss curtains
    old_h = 'for y in range(148, 178):\n        t = (y - 148) / 30.0\n        half = 7 + 8 * math.sqrt(t)'
    if old_h not in src:
        raise SystemExit('arrival: the hollow block in the skyline script has changed')
    src = src.replace(old_h, 'for y in range(110, 178):\n        t = (y - 110) / 68.0\n        half = 8 + 13 * math.sqrt(t)')
    pst = 'img.paste(sp, (fx - sw // 2, fy - sh + 1), sp)'
    src = src.replace(pst, pst + '; SPRITES.append((fx - sw // 2, fy - sh + 1, sp))')
    sk.SPRITES = []
    exec(compile(src, 'build_base_final', 'exec'), sk.__dict__)
    got = {}
    sk.save2 = lambda im, name: got.__setitem__(name, im.copy())
    sk.log = lambda *a: None
    sk.build_base()
    img = got['base'].convert('RGB')
    W, H = img.size
    px = img.load()
    S = Snap(load_pal('highbank_title.png'), load_pal('dawn.png'))
    mask = set()
    for (x0, y0, sp) in sk.SPRITES:
        ap = sp.load()
        for yy in range(sp.height):
            for xx in range(sp.width):
                if ap[xx, yy][3] > 0:
                    mask.add((x0 + xx, y0 + yy))

    def tcx(y):                          # the skyline base's trunk (its own helpers are inside build_base)
        return 196 + 3 * math.sin(y / 40.0)

    def thw(y):
        return 150 + 0.10 * y if y <= 100 else 160 + ((y - 100) / 72.0) ** 2 * 260

    def trunk(x, y):
        return abs(x + 0.5 - tcx(y)) < thw(y)
    skyset = {px[x, y] for y in range(0, 110) for x in list(range(0, 20)) + list(range(W - 20, W)) if not trunk(x, y)}
    rnd = random.Random(4)
    lobes = []
    x = -12.0
    while x < W + 12:
        r = rnd.uniform(9, 17)
        lobes.append((x, rnd.uniform(92, 108), r))
        x += r * rnd.uniform(1.0, 1.5)

    def ceil_bottom(x):
        return max([cy + math.sqrt(max(0.0, r * r - (x - cx) ** 2)) for cx, cy, r in lobes if abs(x - cx) < r] + [88])
    for y in range(H):
        for x in range(W):
            if (x, y) in mask:
                continue
            c = px[x, y]
            if trunk(x, y) and y < 96:
                k = 0.42 + 0.58 * (y / 96.0) ** 0.8          # the trunk goes up into the crown's shade
                px[x, y] = S((int(c[0] * k), int(c[1] * k), int(c[2] * k)))
            elif not trunk(x, y) and y < ceil_bottom(x):
                d = ceil_bottom(x) - y
                cc = '3c532b' if d < 1.5 else '2f372a' if d < 4 else '1d2925'
                if d >= 4 and hn(x, y, 9) > 0.965:
                    cc = '303e37'
                px[x, y] = S(cc)
            elif c in skyset and y < 172:
                px[x, y] = S(mix(c, '33524e', 0.5))          # the dim air under the crown, out to its edge
    for y in range(H):
        for x in range(W):
            if (x, y) not in mask:
                c = px[x, y]
                px[x, y] = S((int(c[0] * 0.86), int(c[1] * 0.86), int(c[2] * 0.86)))
    REPORT_EXTRA['arrival'] = 'hollow 68 px tall, 42 px across at its foot; starters 36 and 32 px; crown shade from the top'
    save(img, 'arrival', 'arriving at the great tree under its crown: the skyline base, no cloud or vines, a bigger hollow')
    return img


# ================================================================================================ 7. ELEVATION
def mock_elevation():
    W, H = 1120, 610
    S = Snap(load_pal('dawn.png'), load_pal('wayline_tower.png'), load_pal('highbank_title.png'))
    img = Image.new('RGB', (W, H), hx('2e3b52'))
    px = img.load()
    GA, AW = 560, 690
    BAND_Y = [(0, '2e3b52'), (90, '3c4d56'), (170, '4a5e73'), (250, '556c83'), (330, '5d758f'), (410, '6c8b96'),
              (470, '8da2aa'), (520, 'bdbdb5')]

    def skyA(x, y):
        c = BAND_Y[0][1]
        for y0, cc in BAND_Y:
            if y >= y0:
                c = cc
        return hx(c)
    for y in range(H):
        for x in range(0, AW):
            px[x, y] = S(skyA(x, y))
    for y in range(GA - CLOUD_LAYER[1], GA - CLOUD_LAYER[0]):
        for x in range(34, AW):
            if (x + y) % 4 == 0:
                px[x, y] = S(mix(px[x, y], 'bdbdb5', 0.45))
    AX = 600
    TX = AX + int(round(TREE_E))
    pal = {'crown': ['2f372a', '3c532b', '4a6530', '5c7149', '75895d'],
           'bark': ['23180e', '3f2716', '663f23', '8c6545', 'b06b3d'],
           'spur': ['3f2716', '663f23', '5c7149'], 'rim': ['a3a891'], 'moss': ['5c7149', '75895d'],
           'forest': ['2f372a', '3c532b', '5c7149']}
    paint_tree(px, W, H, S, Proj.level(1.0, TX, GA), 0, 0, lambda x, y: x < AW, pal, skyA, haze=0.0, light=1, seed=5)
    paint_tower(px, W, H, S, Proj.level(1.0, AX, GA), 0, skyA, haze0=0.0, haze1=0.0, light=1, lit_win=0.3,
                lamp_glow=True)
    rnd = random.Random(2)
    for (cx, cy) in ((110, GA - 302), (250, GA - 334), (420, GA - 318), (670, GA - 344), (52, GA - 348)):
        for i in range(5):
            blob(px, W, H, S, cx + rnd.uniform(-22, 22), cy + rnd.uniform(-3, 3), rnd.uniform(9, 14), rnd.uniform(4, 7),
                 lambda dx, dy, a, b: cloud_col(dx, dy, 1), ok=lambda a, b: a < AW)
    for y in range(GA, H):
        for x in range(0, AW):
            px[x, y] = S('3c532b' if y < GA + 3 else '2f372a')
    # today's Tower (30 tiles), a house (5), a creature (about 1.3)
    for y in range(GA - 30, GA):
        t = GA - y
        w = 18 if t < 12 else 12 if t < 24 else 7
        for x in range(650 - w // 2, 650 + w // 2):
            px[x, y] = S('e6c697' if x < 650 else 'c49b69')
    for y in range(GA - 5, GA):
        for x in range(666, 672):
            px[x, y] = S('b06b3d' if y < GA - 3 else 'e6c697')
    px[677, GA - 1] = S('f1c177')
    px[677, GA - 2] = S('f1c177')
    for t in range(0, 501, 10):
        y = GA - t
        for x in range(18, 22 if t % 100 else 28):
            px[x, y] = S('f5e5c0')
        if t % 100 == 0 and t:
            label(img, 30, y - 4, str(t), '#f5e5c0', '#2e3b52')
    for y in range(GA - 500, GA):
        px[18, y] = S('f5e5c0')
    lb, bg = '#f5e5c0', '#2e3b52'
    label(img, 14, 12, 'THE TWO GIANTS (PROPOSAL)   1 PX = 1 TILE', lb, bg)
    label(img, 14, 26, 'SEEN FROM THE SOUTH. THE TREE STANDS 278 TILES FURTHER NORTH.', '#bdbdb5', bg)
    label(img, AX - 128, GA - 488, 'WAYLINE TOWER 480', lb, bg)
    label(img, AX - 82, GA - 474, 'LAMP 475', '#f1c177', bg)
    label(img, AX + 34, GA - 304, 'COLLAR', lb, bg)
    label(img, AX + 26, GA - 216, 'STATION', lb, bg)
    label(img, AX + 24, GA - 30, 'TODAY 30', lb, bg)
    label(img, 40, GA - 372, 'CLOUD LAYER 280-360', lb, bg)
    label(img, TX - 58, GA - 424, 'GREAT TREE 400', lb, bg)
    label(img, TX - 160, GA - 128, 'CROWN 440 ACROSS', lb, bg)
    label(img, TX - 34, GA - 72, 'TRUNK 100', lb, '#3f2716')
    label(img, TX - 58, GA + 14, 'ROOTS FLARE 260', lb, '#2f372a')
    label(img, 600, GA + 14, 'HOUSE  CREATURE', lb, '#2f372a')
    # ---- panel B: the two feet at 3 px a tile
    BX0, GB, Pp = AW + 8, 560, 3
    for y in range(H):
        for x in range(AW, W):
            px[x, y] = S('3c4d56') if x >= BX0 else S('2e3b52')
    for y in range(GB, H):
        for x in range(BX0, W):
            px[x, y] = S('3c532b' if y < GB + 3 else '2f372a')
    PAX = BX0 + 92
    paint_tower(px, W, H, S, Proj.level(Pp, PAX, GB), 0, lambda x, y: hx('3c4d56'), haze0=0.0, haze1=0.0, light=1,
                lit_win=0.3, collar=False, ok=lambda x, y: x >= BX0 and y > GB - 180, root=False)
    # the root: along the ground from the west, up the two plinth steps, onto the Stack's west side
    draw_root(px, W, H, S, [(BX0 - 4, GB - 4), (PAX - 86, GB - 6), (PAX - 81, GB - 20), (PAX - 72, GB - 28),
                            (PAX - 66, GB - 40), (PAX - 57, GB - 53), (PAX - 52, GB - 90), (PAX - 50, GB - 140),
                            (PAX - 49, GB - 185)], 12, 9,
              light=(0.6, -0.8), seed=4, moss=0.25, ok=lambda x, y: x >= BX0 and y > GB - 180)
    # today's Tower (the blockout at 3 px a tile): its foot, kept, stands ON the plinth's top (16 tiles) with
    # its door 9.5 tiles west of the new axis; its old crown is not used here (the crown goes to tile 461)
    blk = Image.open(BLOCKOUT).convert('RGBA')
    small = blk.resize((blk.width // 8, blk.height // 8), Image.NEAREST)
    foot = small.crop((0, small.height - 51, small.width, small.height))
    img.paste(foot, (int(PAX - 9.5 * Pp - small.width / 2), GB - 16 * Pp - foot.height), foot)
    img.paste(small, (PAX + 92, GB - small.height), small)          # today's whole Tower, for size
    for y in range(GB - 15, GB):
        for x in range(PAX + 154, PAX + 170):
            px[x, y] = S('b06b3d' if y < GB - 9 else 'e6c697')
            if GB - 7 <= y < GB and PAX + 160 <= x < PAX + 163:
                px[x, y] = S('3f2716')
    for y in range(GB - 4, GB):
        for x in range(PAX + 178, PAX + 181):
            px[x, y] = S('f1c177' if y > GB - 4 else '3f2716')
    TB0 = PAX + 236
    for y in range(GB - 230, GB):
        dd = (y - (GB - 70)) / 70 if y > GB - 70 else 0
        flare = int(40 * dd ** 2.2)
        for x in range(TB0 - flare, W):
            u = (x - TB0 + flare) / 70.0
            fur = vn(x * 1.0, y * 0.22, 5, 7)
            c = 'b06b3d' if u < 0.25 else '8c6545' if u < 0.9 else '663f23'
            if fur > 0.62:
                c = '3f2716'
            if x < TB0 - flare + 2:
                c = '23180e'
            if u < 0.7 and vn(x, y, 7, 3) > 0.7:
                c = '6b6f1d'
            px[x, y] = S(c)
    small_tree(px, W, H, S, TB0 - 30, GB - 1, 30, ['2f372a', '3c532b', '5c7149'], lambda x, y: True,
               lambda x, y: hx('3c4d56'), 0.0, 1)
    lb2 = '#3c4d56'
    label(img, BX0 + 8, 12, 'THE FEET, 3 PX A TILE', lb, lb2)
    label(img, BX0 + 8, 26, 'PLINTH 52 WIDE, STACK 34, ROOT 4', '#bdbdb5', lb2)
    label(img, PAX + 84, GB - small.height - 14, "TODAY 30", lb, lb2)
    label(img, BX0 + 8, 40, "TODAY'S FOOT KEPT, ON THE PLINTH", "#bdbdb5", lb2)
    label(img, TB0 + 6, GB - 250, 'THE TRUNK, 300 PX', lb, lb2)
    label(img, TB0 + 6, GB - 264, 'HERE, RUNS ON', lb, lb2)
    label(img, TB0 - 74, GB + 14, 'FOREST TREE 10', lb, '#2f372a')
    label(img, PAX + 142, GB + 26, 'HOUSE CREATURE', lb, '#2f372a')
    save(img, 'elevation', 'both giants at 1 px = 1 tile; the feet at 3 px a tile')
    return img


# ================================================================================================ 8. INFLUENCE
def mock_influence():
    S = Snap(load_pal('town_stone.png'), load_pal('wayline_tower.png'), load_pal('dawn.png'))
    panels = []
    # (1) Street crossroads: one root surfaces twice through the paving, broken stones where it dives
    a = to1x(R2 + '06_street_wayline.png')
    ap = a.load()
    W, H = a.size
    def prof(t):                                         # full width, then it dives under at both ends
        return min(1.0, max(0.0, math.sin(math.pi * t) * 2.4)) ** 0.6

    def shadow(px_, pts, w0, w1, off=(3, 4), amt=0.6, profile=None):
        sp = catmull(pts, 30)
        done = set()
        for i, (cx, cy) in enumerate(sp):
            t = i / max(1, len(sp) - 1)
            r = (w0 + (w1 - w0) * t) / 2 * (profile(t) if profile else 1.0)
            for yy in range(int(cy + off[1] - r) - 1, int(cy + off[1] + r) + 2):
                for xx in range(int(cx + off[0] - r) - 1, int(cx + off[0] + r) + 2):
                    if (xx, yy) in done or not inside(W, H, xx, yy):
                        continue
                    if (xx + 0.5 - cx - off[0]) ** 2 + (yy + 0.5 - cy - off[1]) ** 2 <= r * r:
                        q = px_[xx, yy]
                        px_[xx, yy] = S((int(q[0] * amt), int(q[1] * amt), int(q[2] * amt * 1.08)))
                        done.add((xx, yy))
    segs = (([(70, 90), (98, 86), (128, 94), (160, 100)], 14, 3), ([(206, 118), (236, 115), (270, 124), (304, 122), (334, 128)], 13, 7))
    for seg, w0, sd in segs:
        sp = catmull(seg, 30)
        shadow(ap, seg, w0, w0 * 0.85, profile=prof)
        rnd = random.Random(sd)
        for k in range(10):                              # cracks run out through the paving from the lifted ground
            i = rnd.randrange(len(sp))
            cx, cy = sp[i]
            ang = rnd.choice((-1, 1)) * math.pi / 2 + rnd.uniform(-0.7, 0.7)
            x, y = cx, cy
            for step in range(rnd.randint(7, 15)):
                ang += rnd.uniform(-0.5, 0.5)
                x, y = x + math.cos(ang), y + math.sin(ang)
                if inside(W, H, int(x), int(y)):
                    ap[int(x), int(y)] = S('5d4b34' if step % 5 else '3f2716')
        for i, (cx, cy) in enumerate(sp):                # the split ground round it: dark soil, ragged
            t = i / max(1, len(sp) - 1)
            r = w0 / 2 * prof(t) + 2.5
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if inside(W, H, xx, yy) and (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= (r - hn(xx, yy, sd)) ** 2:
                        ap[xx, yy] = S('3f2716' if hn(xx, yy, sd + 1) < 0.7 else '23180e')
        for k, ((cx, cy), side) in enumerate((q, s_) for q in sp[5:-5:9] for s_ in (-1, 1)):
            t = (5 + (k // 2) * 9) / max(1, len(sp) - 1)      # tipped paving stones on both sides, lit edge up
            off = w0 / 2 * prof(t) + 4
            bx, by = int(cx - 3), int(cy + side * off - 2)
            for yy in range(by, by + 4):
                for xx in range(bx, bx + 6):
                    if inside(W, H, xx, yy):
                        edge = yy == (by if side > 0 else by + 3)
                        ap[xx, yy] = S('f5d9a8' if edge else 'c7a378' if (xx + yy) % 5 else '9c8c68')
            for xx in range(bx, bx + 6):
                if inside(W, H, xx, by + 4):
                    ap[xx, by + 4] = S('3f2716')
        for (hx0, hy0) in (sp[0], sp[-1]):               # the holes it comes out of and dives back into
            for yy in range(int(hy0 - 7), int(hy0 + 8)):
                for xx in range(int(hx0 - 10), int(hx0 + 11)):
                    d = ((xx + 0.5 - hx0) / 9.5) ** 2 + ((yy + 0.5 - hy0) / 6.5) ** 2
                    if d <= 1 and inside(W, H, xx, yy):
                        ap[xx, yy] = S('0b0e11' if d < 0.55 else '23180e' if d < 0.8 else '5d4b34')
        draw_root(ap, W, H, S, seg, w0, w0 * 0.85, light=(-0.35, -0.94), seed=sd, moss=0.2, soil='23180e',
                  swell=0.1, profile=prof)
        for (hx0, hy0) in (sp[0], sp[-1]):               # the far lip of each hole lies over the root's end
            for xx in range(int(hx0 - 9), int(hx0 + 10)):
                yy = int(hy0 - 6 * math.sqrt(max(0.0, 1 - ((xx + 0.5 - hx0) / 9.5) ** 2)))
                if inside(W, H, xx, yy):
                    ap[xx, yy] = S('5d4b34')
                    if inside(W, H, xx, yy + 1):
                        ap[xx, yy + 1] = S('23180e')
    for k in range(8):                                   # where it runs under the paving between: stones lifted
        x = 172 + k * 4
        y = int(104 + (k / 7) * 13)
        for xx in range(x, x + 3):
            ap[xx, y] = S('f5d9a8')
            ap[xx, y + 1] = S('3f2716')
    panels.append((a, '1 CROSSROADS: ONE ROOT HEAVES THE PAVING TWICE'))
    # (2) Ferry Ward: two roots come in from the west-north-west along the quay, bend over its wall and drink;
    # a rootlet stops a stone short of the Mouth
    b = to1x(R2 + '07_ferry_ward_quiet_wayline.png')
    bp = b.load()
    roots = (([(-16, 62), (28, 64), (72, 72), (102, 92), (112, 120), (110, 146), (112, 166)], 22, 12, 3),
             ([(-16, 100), (22, 103), (52, 112), (66, 130), (64, 152), (66, 172)], 18, 10, 5))
    for pts, w0, w1, sd in roots:
        shadow(bp, pts, w0, w1)
    for pts, w0, w1, sd in roots:
        draw_root(bp, W, H, S, pts, w0, w1, light=(-0.6, -0.8), seed=sd, moss=0.3, swell=0.1)
        ex, ey = pts[-1]
        for ring, half in ((0, 11), (5, 16)):            # ripples where it drinks
            for k in range(int(half * 2)):
                xx = int(ex - half + k)
                yy = int(ey + 4 + ring + 1.5 * (1 - ((xx - ex) / half) ** 2))
                if inside(W, H, xx, yy) and k % 4 != 3:
                    bp[xx, yy] = S('f5e5c0' if ring == 0 else 'bdbdb5')
    for pts in (((104, 118), (96, 128), (92, 138)), ((116, 124), (126, 132), (130, 142)), ((58, 126), (48, 136), (44, 146)),
                ((70, 128), (80, 138), (82, 148))):          # rootlets that grip the quay stones as they go over
        draw_root(bp, W, H, S, list(pts), 5, 1.5, light=(-0.6, -0.8), seed=pts[0][1], moss=0.0, swell=0.0)
    rl = [(92, 82), (118, 77), (144, 73), (164, 72)]    # the rootlet that stops a stone short of the Mouth
    shadow(bp, rl, 5, 2, off=(2, 2))
    draw_root(bp, W, H, S, rl, 5, 2, light=(-0.6, -0.8), seed=9, moss=0.0, swell=0.0)
    panels.append((b, '2 FERRY WARD: ROOTS DRINK. ONE STOPS SHORT OF THE MOUTH'))
    # (3) Tower doors: leaves the size of a starter on the steps and the grass, a seed tuft drifting
    c = to1x(R2 + '01_rise_door_level.png')
    cp = c.load()
    for (lx, ly, L, ang) in ((70, 160, 22, 0.5), (232, 196, 24, -0.4), (300, 150, 20, 2.2), (150, 184, 18, 1.2),
                             (205, 120, 16, -1.0)):
        leaf(cp, W, H, S, lx, ly, L, ang, shadow=True)
    for (dx, dy) in ((0, 0), (1, -1), (-1, -1), (0, -2), (2, -2), (-2, -2), (0, 1), (1, -3), (-1, -3)):
        cp[262 + dx, 70 + dy] = S('f5e5c0')
    panels.append((c, '3 TOWER DOORS: LEAVES THE SIZE OF A STARTER'))
    # (4) Summer evenings: the crown's shade reaches the Street before sunset
    d = to1x(R2 + '06b_street_wayline_top_rows.png')
    dp = d.load()
    for y in range(H):
        for x in range(W):
            edge = 120 + 50 * math.sin(y / 70.0) + 10 * vn(x, y, 14, 4) + 14 * vn(x, y, 5, 8) - x * 0.25
            if x < edge and not (y < 32 and x < 210) and not (x > 296 and y > 176):
                if not (vn(x, y, 4, 12) > 0.74 and x < edge - 12):
                    q = dp[x, y]
                    dp[x, y] = S((int(q[0] * 0.58), int(q[1] * 0.64), int(q[2] * 0.82)))
    for (lx, ly, L, ang) in ((250, 120, 20, 0.9), (330, 60, 18, -0.6)):
        leaf(dp, W, H, S, lx, ly, L, ang, shadow=True)
    panels.append((d, "4 SUMMER EVENINGS: THE CROWN'S SHADE REACHES TOWN"))
    CW, CH = 384, 216
    sheet = Image.new('RGB', (CW * 2 + 18, (CH + 22) * 2 + 34), hx('1e302e'))
    label(sheet, 8, 8, 'THE GREAT TREE AROUND TOWN (PROPOSALS, PAINTED OVER GAME CAPTURES)', '#f5d9a8')
    for i, (im, cap) in enumerate(panels):
        x = 6 + (i % 2) * (CW + 6)
        y = 26 + (i // 2) * (CH + 22)
        sheet.paste(im, (x, y))
        label(sheet, x + 2, y + CH + 6, cap, '#f5d9a8')
    save(sheet, 'influence', 'four town captures with the tree reaching in')
    return sheet


# ================================================================================================ 9. MAP
def mock_map():
    W, H = 480, 330
    S = Snap(load_pal('dawn.png'), load_pal('highbank_title.png'))
    img = Image.new('RGB', (W, H))
    px = img.load()
    P = 0.25                                           # px per tile
    TWX, TWY = 300, 236
    TRX, TRY = TWX + TREE_E * P, TWY - TREE_N * P
    for y in range(H):
        for x in range(W):
            px[x, y] = S('c4b48f' if vn(x, y, 9, 1) > 0.5 else 'bfb28e')
    FR = FOREST_W / 2 * P
    for y in range(H):
        for x in range(W):
            d = math.hypot(x - TRX, y - TRY) + 9 * vn(x, y, 12, 3)
            if d < FR:
                v = vn(x, y, 3, 5)
                px[x, y] = S('3c532b' if v < 0.4 else '4a6530' if v < 0.75 else '5c7149')
    for x in range(W):
        ry = int(TWY + 22 + 6 * math.sin(x / 40.0) + 3 * math.sin(x / 13.0))
        for y in range(ry, ry + 5):
            px[x, y] = S('12837f' if y in (ry + 1, ry + 2, ry + 3) else '6c8b96')
    for y in range(TWY - 10, TWY + 20):
        for x in range(TWX - 26, TWX + 26):
            dd = ((x - TWX) / 26) ** 2 + ((y - TWY - 5) / 15) ** 2
            if dd < 1:
                px[x, y] = S('a3a891' if dd < 0.7 else '8b9284')
    for (x0, y0, x1, y1) in ((TWX - 18, TWY + 6, TWX + 10, TWY + 10), (TWX + 10, TWY + 4, TWX + 22, TWY + 12),
                             (TWX - 8, TWY + 14, TWX + 8, TWY + 18)):
        for y in range(y0, y1):
            for x in range(x0, x1):
                px[x, y] = S('c49b69')
    CR = CROWN_W / 2 * P
    ccx = TRX + CROWN_OFF * P
    for i in range(720):
        a = i / 720 * 2 * math.pi
        x, y = int(ccx + CR * math.cos(a)), int(TRY + CR * math.sin(a))
        if (i // 6) % 2 == 0 and inside(W, H, x, y):
            px[x, y] = S('f5e5c0')
    for i in range(6):
        a = i / 6 * 2 * math.pi + 0.3
        for r in range(int(TRUNK_W / 2 * P), int(FLARE_W / 2 * P)):
            for w in (-1, 0, 1):
                x, y = int(TRX + r * math.cos(a) - w * math.sin(a)), int(TRY + r * math.sin(a) + w * math.cos(a))
                if inside(W, H, x, y):
                    px[x, y] = S('8c6545')
    for y in range(int(TRY - 14), int(TRY + 14)):
        for x in range(int(TRX - 14), int(TRX + 14)):
            dd = math.hypot(x - TRX, y - TRY)
            if dd <= TRUNK_W / 2 * P:
                px[x, y] = S('663f23' if dd > TRUNK_W / 2 * P - 2 else '8c6545' if int(dd) % 3 else '7c4a26')
    roots = [([(TRX, TRY), (TRX + 10, TRY + 22), (TRX + 22, TRY + 50), (TWX - 22, TWY - 6), (TWX - 4, TWY)], 'b06b3d', 3, False),
             ([(TRX, TRY), (TRX + 30, TRY + 30), (TWX - 6, TWY + 6), (TWX - 2, TWY + 8)], 'c49b69', 1, True),
             ([(TRX, TRY), (TRX - 10, TRY + 40), (TRX - 6, TWY + 20), (TRX - 4, TWY + 26)], 'c49b69', 1, True),
             ([(TRX, TRY), (TRX + 50, TRY + 20), (TWX + 16, TWY - 4), (TWX + 16, TWY + 8)], 'c49b69', 1, True),
             ([(TRX, TRY), (TRX - 60, TRY - 20), (TRX - 110, TRY - 10)], 'c49b69', 1, True),
             ([(TRX, TRY), (TRX + 40, TRY - 50), (TRX + 90, TRY - 80)], 'c49b69', 1, True)]
    for pts, col, w, dotted in roots:
        for i, (x, y) in enumerate(catmull(pts, 30)):
            if dotted and math.hypot(x - TRX, y - TRY) > 34 and (i // 4) % 2:
                continue
            for a in range(-(w // 2), w // 2 + 1):
                if inside(W, H, int(x) + a, int(y)):
                    px[int(x) + a, int(y)] = S(col)
    for y in range(TWY - 7, TWY + 6):
        for x in range(TWX - 6, TWX + 7):
            px[x, y] = S('f5d9a8' if abs(x - TWX) < 4 and abs(y - TWY) < 4 else 'ccb290')
    px[TWX, TWY] = S('f1c177')
    # the title camera stands across the river, south-south-west of the Tower, looking north-north-east
    cx, cy = TWX - 14, TWY + 46
    for k in range(10):
        for s in (-1, 1):
            x, y = int(cx + s * k * 0.45 + k * 0.4), int(cy - k)
            if inside(W, H, x, y):
                px[x, y] = S('f5e5c0')
    label(img, int(cx) - 70, int(cy) - 2, 'TITLE VIEW', '#f5e5c0', '#2f372a')
    label(img, 8, 32, '340 TILES = 8,160 PX, ABOUT 21 SCREENS OF WALKING', '#f5e5c0', '#2f372a')
    for k in range(8):
        px[int(TWX - 300 * P * 0.4) - k // 3, H - 4 - k] = S('f5e5c0')
    label(img, int(TWX - 300 * P * 0.4) + 6, H - 28, 'ROAD FAR: 3,000 SSW', '#f5e5c0', '#2f372a')
    VX = int(TWX - 300 * P)
    for k in range(12):
        px[VX + k // 2, H - 4 - k] = S('f5e5c0')
    label(img, VX - 150, H - 16, 'VISTA HILL: 650 TILES SSW', '#f5e5c0', '#2f372a')
    label(img, int(TRX) - 46, int(TRY) - 30, 'THE GREAT TREE', '#f5e5c0', '#2f372a')
    label(img, int(TRX) - 40, int(TRY) + 18, '400 TALL, TRUNK 100', '#f5e5c0', '#2f372a')
    label(img, int(ccx - CR) + 2, int(TRY - CR) - 10, 'CROWN 440 ACROSS', '#f5e5c0', '#2f372a')
    label(img, TWX + 10, TWY - 12, 'WAYLINE TOWER', '#f5e5c0', '#2f372a')
    label(img, TWX + 30, TWY + 2, 'HIGHBANK', '#f5e5c0', '#2f372a')
    label(img, 8, 8, 'THE TWO GIANTS, TOP DOWN (PROPOSAL)', '#f5e5c0', '#2f372a')
    label(img, 8, 20, 'FOREST 800 ACROSS. TREE 340 TILES N35W OF THE TOWER', '#f5e5c0', '#2f372a')
    label(img, int(TRX) + 26, int((TRY + TWY) / 2) + 6, "TOWER'S ROOT", '#f1c177', '#2f372a')
    for x in range(10, 10 + int(200 * P) + 1):
        for y in (H - 40, H - 39):
            px[x, y] = S('f5e5c0' if (x - 10) < 100 * P else 'bdbdb5')
    for xx in (10, 10 + int(100 * P), 10 + int(200 * P)):
        for y in range(H - 43, H - 36):
            px[xx, y] = S('f5e5c0')
    label(img, 10, H - 54, '0   100   200 TILES', '#f5e5c0', '#2f372a')
    for k in range(10):
        px[W - 14, 40 - k] = S('f5e5c0')
    for k in range(4):
        px[W - 14 - k, 31 + k] = S('f5e5c0')
        px[W - 14 + k, 31 + k] = S('f5e5c0')
    label(img, W - 18, 44, 'N', '#f5e5c0', '#2f372a')
    save(img, 'map', 'top down, 1 px = 4 tiles')
    return img


# ================================================================================================ 10. REVEAL BOARD
def mock_reveal():
    """A storyboard for climbing 480 tiles in about 15.6 s: pan the foot, the Low Reel, the Stack streaming by
    with a lift cabin, a Station, a cloud wipe at the collar, then the hold. Half-size frames."""
    S = Snap(load_pal('dawn.png'), load_pal('wayline_tower.png'))
    FW, FH = 192, 108

    def make(h0, ppt, ax=104, extra=None):
        im = Image.new('RGB', (FW, FH))
        p = im.load()
        P = Proj.level(ppt, ax, FH + h0 * ppt)

        def sky(x, y):
            t = max(0.0, min(1.0, P.h_at(y + 0.5) / 480.0))
            return S(mix('bdbdb5', '4d6582', t ** 0.7))
        for y in range(FH):
            for x in range(FW):
                p[x, y] = sky(x, y)
        paint_tower(p, FW, FH, S, P, 0, sky, haze0=0.0, haze1=0.0, light=1, lit_win=0.2, seed=3, collar=True,
                    lamp_glow=True, t_min=max(0.0, h0 - 2))
        if extra:
            extra(im, p, P)
        return im

    def drum(im, p, P, ax=104):
        dx = ax - 9.5 * P.s(0)
        s = P.s(0)
        for h in range(16 * 4, 30 * 4):
            y = int(round(P.sy(h / 4.0)))
            for x in range(int(dx - 7 * s), int(dx + 7 * s) + 1):
                if inside(FW, FH, x, y):
                    u = (x + 0.5 - dx) / (7 * s)
                    p[x, y] = S('f5d9a8' if u > 0.35 else 'e6c697' if u > -0.3 else 'ccb290')
        for h in range(30 * 4, 34 * 4):
            y = int(round(P.sy(h / 4.0)))
            for x in range(int(dx - 11 * s), int(dx + 11 * s) + 1):
                if inside(FW, FH, x, y):
                    p[x, y] = S('d4a94c' if h < 33 * 4 else 'f2d27a')
        for h in range(34 * 4, 38 * 4):
            y = int(round(P.sy(h / 4.0)))
            hw = 7 * s * (1 - (h / 4.0 - 34) / 4.5)
            for x in range(int(dx - hw), int(dx + hw) + 1):
                if inside(FW, FH, x, y):
                    p[x, y] = S('908940' if x > dx else '6b6d45')
        y16 = int(round(P.sy(16)))
        for y in range(y16 - int(4 * s), y16 + 1):
            for x in range(int(dx - 1.6 * s), int(dx + 1.6 * s) + 1):
                if inside(FW, FH, x, y):
                    p[x, y] = S('3f2716')
        return dx, s

    def f_doors(im, p, P):
        drum(im, p, P)

    def f_reel(im, p, P):
        dx, s = drum(im, p, P)
        y34 = P.sy(32)
        for k, end in enumerate(((-10, FH + 6), (-10, 70), (30, FH + 10))):
            line_px(p, FW, FH, catenary((dx - 11 * s, y34), end, 8 + 4 * k), S('3f2716'))

    def f_stack(im, p, P):
        x = int(round(P.sx(17, 160))) + 2
        for y in range(FH):
            p[x, y] = S('6b4f1f')
        for y in range(40, 56):
            for xx in range(x - 6, x + 7):
                p[xx, y] = S('d4a94c' if 41 < y < 54 and x - 5 < xx < x + 5 else '6b4f1f')
        for y in range(44, 50):
            for xx in range(x - 3, x + 4):
                p[xx, y] = S('fbd490')
        for k, sx_ in enumerate((8, 18, 176, 186)):
            for y in range(FH):
                if (y + k * 13) % 26 < 9:
                    p[sx_, y] = S('e2c59b')

    def f_wipe(im, p, P):
        rnd = random.Random(3)
        for i in range(40):
            cx, cy, r = rnd.uniform(-10, FW + 10), rnd.uniform(20, FH + 10), rnd.uniform(10, 24)
            blob(p, FW, FH, S, cx, cy, r * 1.4, r, lambda dx, dy, a, b: cloud_col(dx, dy, 1))
    frames = [(make(-2, 2.0, extra=f_doors), '0-2.5 S  THE DOORS, THE FOOT'),
              (make(18, 3.0, extra=f_reel), '2.5-4.5  LOW REEL, WAYLINES LEAVE'),
              (make(150, 3.0, extra=f_stack), '4.5-8.5  STACK STREAMS, LIFT CLIMBS'),
              (make(194, 3.0), '8.5-9.5  STATION 2 (208) GOES PAST'),
              (make(296, 3.0, extra=f_wipe), '9.5-11  CUT ON CLOUD AT THE COLLAR')]
    try:
        hold = Image.open(f'{OUT}/hold_1x.png').convert('RGB')
        frames.append((hold.resize((FW, FH), Image.NEAREST), '11-15.6  THE HOLD'))
    except OSError:
        pass
    SW = 3 * FW + 4 * 6
    sheet = Image.new('RGB', (SW, 26 + 2 * (FH + 18) + 4), hx('1e302e'))
    label(sheet, 6, 7, 'THE REVEAL, 480 TILES IN ABOUT 15.6 S (PROPOSAL): PAN, STREAM, CUT ON CLOUD, HOLD', '#f5d9a8')
    for i, (im, cap) in enumerate(frames):
        x = 6 + (i % 3) * (FW + 6)
        y = 22 + (i // 3) * (FH + 18)
        sheet.paste(im, (x, y))
        label(sheet, x + 1, y + FH + 5, cap, '#f5d9a8')
    save(sheet, 'reveal', 'storyboard for the 480-tile climb, half-size frames')
    return sheet


# ================================================================================================ run
if __name__ == '__main__':
    import sys
    only = sys.argv[1:]
    jobs = [('title', mock_title), ('title_b', mock_title_b), ('road_far', mock_road_far), ('vista', mock_vista),
            ('door', mock_door), ('street', mock_street), ('hold', mock_hold), ('arrival', mock_arrival),
            ('elevation', mock_elevation), ('influence', mock_influence), ('map', mock_map), ('reveal', mock_reveal)]
    for name, fn in jobs:
        if not only or name in only:
            fn()
    for k, (size, n, note) in REPORT.items():
        print(f'{k:14s} {size[0]}x{size[1]}  {n:5d} colours  {note}')
    for k, v in REPORT_EXTRA.items():
        print(f'  {k}: {v}')
    P = vista_camera()
    print('vista camera: f %.1f cy %.1f horizon %.1f; tower foot y %.1f vane y %.1f; s(0) %.3f s(480) %.3f; stack %.1f px'
          % (P.f, P.cy, P.cy + P.f * P.st / P.ct, P.sy(0), P.sy(480), P.s(0), P.s(480), 34 * P.s(16)))
