# Wayline Tower blockout mock (proposal, 2026-10-27).
# Draws every planned part as a flat-shaded blockout in the house palette at real 1x,
# then writes four review images next to this file. Nothing here touches the game.
#   python mock_tower.py
import math
import os
import random
import colorsys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..'))
SPR = os.path.join(ROOT, 'assets', 'sprites')

T = 24
FW, FH = 432, 720            # assembly frame (18 x 30 tiles)
FO = (96, -504)              # frame origin in Tower Rise world px
BEACON = (216, 118)          # lamp glass centre, frame px
AREA_W, AREA_H, SKY = 624, 336, 528


def font(n):
    try:
        return ImageFont.load_default(size=n)
    except Exception:
        return ImageFont.load_default()


def hx(s):
    s = s.lstrip('#')
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


INK = '#0b0e11'
STONE = dict(hi='#f5d9a8', lit='#e6c697', mid='#ccb290', sh='#9c8c68', dk='#5f5e57')
BOULD = dict(hi='#c7a378', lit='#9c8c68', mid='#8e7f5e', sh='#5f5e57', dk='#3f2716')
BRICK = dict(hi='#c49b69', lit='#b06b3d', mid='#8c6545', sh='#663f23', dk='#3f2716')
TIMB = dict(hi='#92724b', lit='#8c6545', mid='#5d4b34', sh='#3f2716', dk='#23180e')
ROOTC = dict(hi='#c49b69', lit='#b06b3d', mid='#663f23', sh='#3f2716', dk='#23180e')
MOSS = dict(hi='#c6bb2a', lit='#908940', mid='#6b6f1d', sh='#44421a', dk='#44421a')
BRASS = dict(hi='#f2d27a', lit='#d4a94c', mid='#a37a32', sh='#6b4f1f', dk='#3f2716')
AMBER = dict(hi='#fbd490', lit='#f1c177', mid='#ecb36b', sh='#dca562', dk='#c49243')
PLAST = dict(hi='#f5d9a8', lit='#f5d9a8', mid='#e6c697', sh='#c7a378', dk='#9c8c68')
BRONZE = dict(hi='#dca562', lit='#b8793e', sh='#7c4a26')
OIL, PARCH, TWINE = '#6b6d45', '#e6c697', '#c49243'
TEAL = dict(hi='#5cc2b4', lit='#3a9a96', mid='#2a6f73', sh='#1b4a50')


def sample_teal():
    """Pull the courier's teal ramp from the walk sheet so the tower accent matches it."""
    p = os.path.join(SPR, 'player', 'retro_diffusion_chibi_walking_2026_10_01',
                     'male_chibi_walk_eight_directions_native80.png')
    if not os.path.exists(p):
        return None
    im = Image.open(p).convert('RGBA')
    w = min(im.width, 240)
    counts = {}
    for y in range(min(im.height, 80)):
        for x in range(w):
            r, g, b, a = im.getpixel((x, y))
            if a < 200:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if 0.43 <= h <= 0.58 and s > 0.28 and v > 0.18:
                counts[(r, g, b)] = counts.get((r, g, b), 0) + 1
    if len(counts) < 2:
        return None
    top = sorted(counts.items(), key=lambda kv: -kv[1])[:8]
    print('courier teal candidates (rgb, count):', top)
    cols = sorted([c for c, _ in top], key=lambda c: -(0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]))
    pick = [cols[0], cols[len(cols) // 3], cols[(2 * len(cols)) // 3], cols[-1]]
    hexes = ['#%02x%02x%02x' % c for c in pick]
    return dict(hi=hexes[0], lit=hexes[1], mid=hexes[2], sh=hexes[3])


st = sample_teal()
if st:
    TEAL = st
print('teal ramp used:', TEAL)


class Cv:
    """A part-sized RGBA image addressed in frame (or world) coordinates."""

    def __init__(s, rect):
        x, y, w, h = rect
        s.ox, s.oy, s.w, s.h = x, y, w, h
        s.im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        s.d = ImageDraw.Draw(s.im)

    def P(s, x, y):
        return (round(x - s.ox), round(y - s.oy))

    def rect(s, x0, y0, x1, y1, c):
        x0, y0, x1, y1 = round(x0), round(y0), round(x1), round(y1)
        if x1 < x0 or y1 < y0:
            return
        s.d.rectangle([x0 - s.ox, y0 - s.oy, x1 - s.ox, y1 - s.oy], fill=c)

    def ell(s, cx, cy, rx, ry, c):
        rx, ry = max(0, round(rx)), max(0, round(ry))
        cx, cy = round(cx), round(cy)
        s.d.ellipse([cx - rx - s.ox, cy - ry - s.oy, cx + rx - s.ox, cy + ry - s.oy], fill=c)

    def poly(s, pts, c):
        s.d.polygon([s.P(*p) for p in pts], fill=c)

    def line(s, pts, c, w=1):
        s.d.line([s.P(*p) for p in pts], fill=c, width=w)

    def px(s, x, y, c):
        X, Y = round(x - s.ox), round(y - s.oy)
        if 0 <= X < s.w and 0 <= Y < s.h:
            s.im.putpixel((X, Y), hx(c) if isinstance(c, str) else c)


CLEAR = (0, 0, 0, 0)


def ef(cx, r, ry, x):
    u = (x - cx) / r
    return ry * math.sqrt(max(0.0, 1 - u * u)) if abs(u) <= 1 else 0.0


def cyl_col(m, f):
    if 0.06 <= f < 0.12:
        return m['hi']
    if f < 0.32:
        return m['lit']
    if f < 0.66:
        return m['mid']
    if f < 0.90:
        return m['sh']
    return m['dk']


def cyl_cols(cx, r):
    """Absolute frame columns of the shading bands, for the doc."""
    x0 = cx - r
    n = 2 * r + 1
    return dict(lit=(x0, x0 + int(0.32 * n) - 1), hi=(x0 + int(0.06 * n), x0 + int(0.12 * n) - 1),
                mid=(x0 + int(0.32 * n), x0 + int(0.66 * n) - 1),
                shade=(x0 + int(0.66 * n), x0 + int(0.90 * n) - 1), dark=(x0 + int(0.90 * n), cx + r))


def cyl_face(cv, cx, r, ry, ytop, yfoot, m):
    for x in range(cx - r, cx + r + 1):
        f = (x - (cx - r)) / (2 * r + 1)
        e = ef(cx, r, ry, x)
        cv.rect(x, ytop + e, x, yfoot + e, cyl_col(m, f))


def band(cv, cx, r, ry, ytop, d0, d1, m, xa=None, xb=None):
    xa = cx - r if xa is None else xa
    xb = cx + r if xb is None else xb
    for x in range(xa, xb + 1):
        f = (x - (cx - r)) / (2 * r + 1)
        e = ef(cx, r, ry, x)
        cv.rect(x, ytop + e + d0, x, ytop + e + d1, cyl_col(m, f))


def deck(cv, cx, cy, rx, ry, top, lip=3, lipc=None, rng=None, moss=0):
    lipc = lipc or STONE['sh']
    cv.ell(cx, cy + lip, rx, ry, lipc)
    cv.ell(cx, cy, rx, ry, STONE['hi'] if top != MOSS['lit'] else MOSS['hi'])
    cv.ell(cx + 2, cy + 1, rx - 1, ry - 1, top)
    for x in range(cx - rx, cx + rx + 1):
        cv.px(x, cy + ef(cx, rx, ry, x) + lip + 1, INK)
    if rng:
        for _ in range(moss):
            a = rng.uniform(0, 2 * math.pi)
            k = rng.uniform(0.55, 0.95)
            mx, my = cx + math.cos(a) * rx * k, cy + math.sin(a) * ry * k
            cv.ell(mx, my, rng.randint(2, 4), rng.randint(1, 2), MOSS['lit'])
            cv.px(mx - 1, my - 1, MOSS['hi'])


def round_window(cv, x, y, r, lit=True, shutters=False, mull=True):
    if shutters:
        cv.rect(x - r - 4, y - r, x - r - 1, y + r, TIMB['lit'])
        cv.rect(x + r + 1, y - r, x + r + 4, y + r, TIMB['mid'])
    cv.ell(x, y, r + 1, r + 1, STONE['hi'])
    cv.ell(x + 1, y + 1, r + 1, r + 1, TIMB['sh'])
    cv.ell(x, y, r, r, AMBER['lit'] if lit else TIMB['dk'])
    if lit:
        cv.ell(x - 1, y - 1, max(1, r - 3), max(1, r - 3), AMBER['hi'])
    if mull:
        cv.rect(x, y - r, x, y + r, INK)
        cv.rect(x - r, y, x + r, y, INK)
    cv.rect(x - r, y + r + 1, x + r, y + r + 2, STONE['hi'])


def sample_path(pts, step=1.0):
    out = []
    for (x0, y0, t0), (x1, y1, t1) in zip(pts, pts[1:]):
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / step))
        for i in range(n):
            a = i / n
            out.append((x0 + (x1 - x0) * a, y0 + (y1 - y0) * a, t0 + (t1 - t0) * a))
    out.append(pts[-1])
    return out


def tube(cv, pts, m, treads=False, gloss=False, rng=None):
    s = sample_path(pts)
    for x, y, t in s:
        cv.ell(x + 1.5, y + 1.5, t / 2, t / 2, m['sh'])
    for x, y, t in s:
        cv.ell(x, y, t / 2 - 1.5, t / 2 - 1.5, m['mid'])
    for x, y, t in s:
        cv.ell(x - t * 0.17, y - t * 0.17, t * 0.24, t * 0.24, m['lit'])
    for x, y, t in s:
        if gloss and t * 0.09 >= 1:
            cv.ell(x - t * 0.28, y - t * 0.28, t * 0.09, t * 0.09, m['hi'])
    if rng:                                                   # bark grain along the root
        for _ in range(max(4, len(s) // 4)):
            i = rng.randint(1, len(s) - 2)
            x, y, t = s[i]
            dx, dy = s[i + 1][0] - s[i - 1][0], s[i + 1][1] - s[i - 1][1]
            L = math.hypot(dx, dy) or 1
            dx, dy = dx / L, dy / L
            off = rng.uniform(-0.32, 0.4) * t
            px_, py_ = x - dy * off, y + dx * off
            ln = rng.randint(3, 8)
            cv.line([(px_, py_), (px_ + dx * ln, py_ + dy * ln)], m['sh'] if off > -0.05 * t else m['mid'])
    if treads:
        for i, (x, y, t) in enumerate(s):
            if i % 9 == 4:
                cv.rect(x - t * 0.35, y - t * 0.3, x - t * 0.35 + 3, y - t * 0.3, STONE['hi'])
                cv.rect(x - t * 0.35, y - t * 0.3 + 1, x - t * 0.35 + 3, y - t * 0.3 + 1, ROOTC['sh'])


# ---------------------------------------------------------------- parts (frame coordinates)
PART = {
    'town.building.hall': (66, 528, 300, 192),
    'town.building.hall.drum': (104, 368, 225, 236),
    'town.building.hall.hoist': (304, 460, 88, 56),
    'town.building.hall.galleries': (88, 252, 217, 206),
    'town.building.hall.root_vein': (80, 326, 60, 296),
    'town.building.hall.chute': (244, 336, 88, 290),
    'town.building.hall.gable': (164, 560, 104, 53),
    'town.building.hall.reel_back': (88, 198, 225, 93),
    'town.building.hall.reach': (128, 24, 104, 300),
    'town.building.hall.ring_front': (84, 286, 232, 60),
    'town.building.hall.bell': (40, 232, 56, 90),
    'town.building.hall.lamp': (200, 92, 32, 42),
    'town.building.hall.vane': (164, 0, 48, 44),
    'town.building.hall.root_foot': (0, 600, 96, 120),
    'town.building.hall.yard': (360, 616, 72, 104),
}
LANTERN_T = [18, 42, 66, 90, 114, 138, 162]
LANTERN_STATE = ['lit', 'dark', 'lit', 'lit', 'dark', 'quiet', 'dark']   # pilot: Route 1 at 90 deg


def ring_pt(t, dy=0):
    a = math.radians(t)
    return 200 + 112 * math.cos(a), 290 + 44 * math.sin(a) + dy


def draw_depot(cv, rng):
    # roof deck top plane (seen from above), mostly hidden by the drum
    cv.rect(72, 536, 359, 599, STONE['mid'])
    cv.rect(72, 536, 359, 538, MOSS['lit'])
    for y in (552, 568, 584):
        cv.rect(72, y, 359, y, STONE['sh'])
    for x in range(84, 359, 22):
        cv.rect(x, 539, x, 599, STONE['sh'])
    # skylight, crates, oilcloth parcel stack, mess chimney
    cv.rect(78, 552, 100, 566, TIMB['mid']); cv.rect(80, 554, 98, 564, AMBER['lit']); cv.rect(89, 554, 89, 564, INK)
    cv.rect(78, 576, 98, 593, TIMB['lit']); cv.rect(78, 576, 98, 578, TIMB['hi']); cv.rect(88, 579, 88, 593, TIMB['sh'])
    cv.rect(330, 574, 356, 596, OIL); cv.rect(330, 574, 356, 576, MOSS['lit']); cv.rect(342, 574, 343, 596, TWINE)
    cv.rect(334, 528, 348, 566, BRICK['lit']); cv.rect(344, 528, 348, 566, BRICK['sh'])
    cv.rect(334, 528, 348, 530, INK); cv.rect(334, 540, 348, 540, BRICK['sh'])
    # rail posts on the visible deck strips
    for x in list(range(74, 108, 8)) + list(range(326, 360, 8)):
        cv.rect(x, 591, x + 1, 597, TIMB['lit'])
    cv.rect(72, 590, 107, 590, TIMB['hi']); cv.rect(324, 590, 359, 590, TIMB['hi'])
    # parapet lip
    cv.rect(66, 598, 365, 601, STONE['hi'])
    cv.rect(66, 602, 365, 607, STONE['lit'])
    cv.rect(66, 608, 365, 608, INK)
    # front wall: limestone, grime toward the ground, two loess brick courses
    cv.rect(72, 609, 359, 699, STONE['lit'])
    cv.rect(72, 609, 359, 611, STONE['sh'])
    cv.rect(72, 682, 359, 699, STONE['mid'])
    for y0, y1 in ((624, 628), (664, 667)):
        cv.rect(72, y0, 359, y1, BRICK['lit']); cv.rect(72, y1 + 1, 359, y1 + 1, BRICK['sh'])
    # boulder footing, flaring past the wall
    cv.rect(66, 700, 365, 719, BOULD['sh'])
    x = 66
    while x < 362:
        w = rng.randint(14, 26); h = rng.randint(12, 18)
        cv.ell(x + w / 2, 719 - h / 2 + 1, w / 2, h / 2, BOULD['mid'])
        cv.ell(x + w / 2 - 2, 719 - h / 2 - 1, w / 2 - 4, h / 2 - 4, BOULD['lit'])
        cv.px(x + 3, 719 - h + 3, BOULD['hi'])
        x += w - 2
    # left porch: moss awning roof, posts, satchel hooks, bench, round window
    round_window(cv, 124, 642, 6)
    cv.rect(94, 626, 96, 712, TIMB['mid']); cv.rect(152, 626, 154, 712, TIMB['mid'])
    cv.ell(124, 617, 35, 9, MOSS['mid']); cv.ell(122, 615, 33, 7, MOSS['lit']); cv.ell(110, 611, 10, 3, MOSS['hi'])
    cv.rect(89, 620, 159, 624, TIMB['lit']); cv.rect(89, 620, 159, 620, TIMB['hi']); cv.rect(89, 625, 159, 625, INK)
    for i, sx in enumerate((104, 116, 128, 140)):
        cv.rect(sx + 3, 652, sx + 4, 654, BRASS['lit'])
        if i != 2:
            cv.rect(sx, 655, sx + 7, 666, TEAL['lit']); cv.rect(sx + 5, 655, sx + 7, 666, TEAL['sh'])
            cv.rect(sx, 655, sx + 7, 656, TEAL['hi'])
    cv.rect(102, 690, 146, 694, TIMB['lit']); cv.rect(102, 695, 146, 696, TIMB['sh'])
    cv.rect(104, 697, 106, 704, TIMB['sh']); cv.rect(142, 697, 144, 704, TIMB['sh'])
    cv.rect(108, 683, 117, 689, OIL); cv.rect(112, 683, 112, 689, TWINE)
    # First Post: the old relay stone in the left jamb, with the touch-worn patch
    cv.rect(158, 668, 169, 717, BOULD['lit']); cv.ell(163, 668, 5, 4, BOULD['lit'])
    cv.rect(166, 666, 169, 717, BOULD['sh']); cv.rect(161, 684, 164, 690, STONE['hi'])
    # grand arch, fan-light with three-route mullions, double door
    cv.ell(216, 656, 46, 46, BRICK['lit']); cv.ell(218, 658, 44, 44, BRICK['mid'])
    cv.rect(170, 656, 261, 717, BRICK['lit']); cv.rect(258, 656, 261, 717, BRICK['sh'])
    cv.ell(216, 656, 40, 40, TIMB['dk']); cv.rect(176, 656, 256, 717, TIMB['dk'])
    cv.rect(170, 702, 261, 717, BOULD['mid'])
    cv.rect(176, 656, 256, 717, TIMB['dk'])
    cv.ell(216, 654, 34, 34, AMBER['lit']); cv.ell(212, 650, 24, 24, AMBER['hi'])
    cv.rect(176, 654, 256, 717, TIMB['dk'])
    cv.line([(216, 654), (216, 620)], INK); cv.line([(216, 654), (192, 630)], INK); cv.line([(216, 654), (240, 630)], INK)
    cv.rect(190, 652, 241, 653, TIMB['sh'])
    cv.rect(192, 654, 239, 717, TIMB['lit']); cv.rect(216, 654, 239, 717, TIMB['mid'])
    cv.rect(215, 654, 216, 717, INK)
    for y in (666, 700):
        cv.rect(194, y, 237, y + 2, BRASS['lit']); cv.rect(194, y + 2, 237, y + 2, BRASS['sh'])
    cv.rect(211, 684, 212, 687, BRASS['hi']); cv.rect(219, 684, 220, 687, BRASS['hi'])
    cv.rect(186, 716, 245, 719, STONE['hi'])
    cv.rect(211, 608, 221, 617, STONE['hi']); cv.line([(216, 615), (216, 610)], INK)
    cv.line([(216, 615), (213, 611)], INK); cv.line([(216, 615), (219, 611)], INK)
    # right side: depot bay, its canopy, chute bin, burrow hatch, high-water cuts
    cv.rect(272, 650, 332, 653, BRICK['lit'])
    cv.rect(276, 654, 328, 717, TIMB['lit']); cv.rect(302, 654, 328, 717, TIMB['mid'])
    cv.rect(301, 654, 302, 717, INK)
    cv.line([(278, 714), (299, 657)], TIMB['sh'], 2); cv.line([(305, 714), (326, 657)], TIMB['sh'], 2)
    cv.ell(302, 617, 33, 9, MOSS['mid']); cv.ell(300, 615, 31, 7, MOSS['lit']); cv.ell(290, 611, 9, 3, MOSS['hi'])
    cv.rect(268, 620, 336, 624, TIMB['lit']); cv.rect(268, 620, 336, 620, TIMB['hi']); cv.rect(268, 625, 336, 625, INK)
    cv.rect(272, 626, 274, 712, TIMB['mid'])
    round_window(cv, 346, 640, 6)
    cv.rect(316, 698, 334, 717, TIMB['mid']); cv.rect(316, 698, 334, 700, TIMB['hi'])
    cv.rect(319, 692, 331, 699, OIL); cv.rect(325, 692, 325, 699, TWINE)
    cv.ell(349, 709, 8, 8, TIMB['sh']); cv.ell(349, 709, 6, 6, TIMB['dk']); cv.rect(343, 708, 355, 708, TIMB['mid'])
    for y in (684, 692, 700):
        cv.rect(354, y, 359, y, INK)
    cv.rect(357, 676, 358, 712, BRASS['mid'])
    # moss on the footing tops and lower courses
    for _ in range(26):
        mx = rng.randint(68, 362); my = rng.randint(697, 703)
        cv.ell(mx, my, rng.randint(2, 4), 1, MOSS['lit'])


def draw_drum(cv, rng):
    cx, r, ry, yt, yf = 216, 108, 44, 416, 552
    cyl_face(cv, cx, r, ry, yt, yf, STONE)
    for x in range(cx - r, cx + r + 1):                       # contact shadow on the depot deck
        e = ef(cx, r, ry, x)
        cv.px(x, yf + e, INK)
        cv.rect(x, yf + e + 1, x, yf + e + 3, STONE['sh'])
    band(cv, cx, r, ry, yt, 12, 17, ROOTC)                    # root-beam ring
    band(cv, cx, r, ry, yt, 18, 18, dict(hi=INK, lit=INK, mid=INK, sh=INK, dk=INK))
    for wx in (150, 196, 242):                                # three round lit windows
        round_window(cv, wx, yt + ef(cx, r, ry, wx) + 34, 6)
    band(cv, cx, r, ry, yt, 58, 61, BRICK)                    # loess brick course
    # cubby wall: 6 x 3 sorting cubbies, two dark and empty
    fx0, fx1 = 146, 239
    for x in range(fx0, fx1 + 1):
        e = ef(cx, r, ry, x)
        cv.rect(x, yt + e + 76, x, yt + e + 119, TIMB['sh'])
    k = 0
    for row in range(3):
        for col in range(6):
            x0 = 150 + col * 15
            e = ef(cx, r, ry, x0 + 5)
            y0 = yt + e + 80 + row * 13
            empty = (row, col) in ((0, 4), (2, 1))
            cv.rect(x0, y0, x0 + 10, y0 + 9, TIMB['dk'] if empty else AMBER['mid'])
            if not empty:
                cv.rect(x0, y0, x0 + 10, y0 + 1, AMBER['hi'])
                cv.rect(x0 + 2, y0 + 5, x0 + 8, y0 + 9, PARCH if k % 3 else OIL)
                cv.rect(x0 + 5, y0 + 5, x0 + 5, y0 + 9, TWINE)
            k += 1
    # hoist door on the right flank
    for x in range(306, 321):
        e = ef(cx, r, ry, x)
        cv.rect(x, yt + e + 30, x, yt + e + 64, TIMB['mid'] if x < 314 else TIMB['sh'])
    # moss along the lower courses
    for _ in range(30):
        mx = rng.randint(cx - r + 4, cx + r - 4)
        e = ef(cx, r, ry, mx)
        cv.ell(mx, yt + e + rng.randint(124, 132), rng.randint(2, 4), 1, MOSS['lit'])
    deck(cv, cx, yt, r + 4, ry + 2, STONE['mid'], lip=3, rng=rng, moss=16)
    # the visible right-hand terrace of the drum deck is a working landing: rail, crates, a parcel
    for x in range(252, 327, 7):
        y = yt + ef(cx, r + 4, ry + 2, x)
        cv.rect(x, y - 6, x + 1, y - 1, TIMB['lit'])
    for x in range(252, 327):
        cv.px(x, yt + ef(cx, r + 4, ry + 2, x) - 6, TIMB['hi'])
    cv.rect(296, 418, 310, 431, TIMB['lit']); cv.rect(296, 418, 310, 419, TIMB['hi']); cv.rect(303, 420, 303, 431, TIMB['sh'])
    cv.rect(312, 424, 321, 432, OIL); cv.rect(316, 424, 316, 432, TWINE)


def draw_hoist(cv):
    cv.rect(306, 468, 322, 482, ROOTC['mid']); cv.rect(306, 468, 322, 469, ROOTC['lit'])
    cv.rect(316, 470, 386, 475, TIMB['lit']); cv.rect(316, 470, 386, 471, TIMB['hi']); cv.rect(316, 476, 386, 476, INK)
    for x in (334, 360):
        cv.rect(x, 470, x + 1, 475, BRASS['sh'])
    cv.line([(320, 508), (362, 477)], TIMB['mid'], 3); cv.line([(321, 510), (363, 479)], INK)
    cv.rect(378, 476, 391, 488, BRASS['mid']); cv.ell(384, 482, 4, 4, BRASS['lit']); cv.px(382, 480, BRASS['hi'])
    cv.rect(378, 488, 391, 488, INK)


def draw_galleries(cv, rng):
    cx, r, ry, yt, yf = 200, 84, 34, 288, 416
    cyl_face(cv, cx, r, ry, yt, yf, PLAST)
    band(cv, cx, r, ry, yt, 92, 128, STONE)                   # stone under the plaster
    for x in range(cx - r, cx + r + 1):
        e = ef(cx, r, ry, x)
        cv.px(x, yf + e, INK)
        cv.rect(x, yf + e + 1, x, yf + e + 3, STONE['sh'])
    for d0, d1 in ((0, 3), (44, 47), (88, 91)):
        band(cv, cx, r, ry, yt, d0, d1, TIMB)
    for vx in (132, 158, 184, 210, 236, 262):                 # timber posts
        for x in (vx, vx + 1, vx + 2):
            e = ef(cx, r, ry, x)
            cv.rect(x, yt + e + 4, x, yt + e + 88, TIMB['mid'] if x < cx + 30 else TIMB['sh'])
    for wx, d in ((171, 22), (225, 22), (198, 66), (171, 110), (225, 110)):   # 2-1-2 round shuttered windows
        round_window(cv, wx, yt + ef(cx, r, ry, wx) + d, 6, shutters=True)
    # timber walkway gallery wrapping the front right, with the chute mouth
    for x in range(204, 300):
        yo = 342 + 40 * math.sqrt(max(0, 1 - ((x - 200) / 98) ** 2))
        yi = 342 + 34 * math.sqrt(max(0, 1 - ((x - 200) / 84) ** 2)) if x <= 284 else 336
        cv.rect(x, min(yi, yo - 3), x, yo, TIMB['lit'])
        cv.rect(x, yo + 1, x, yo + 3, TIMB['mid'])
        cv.px(x, yo + 4, INK)
        if x % 8 == 0:
            cv.rect(x, yo - 7, x + 1, yo - 1, TIMB['hi'])
        cv.px(x, yo - 7, TIMB['hi'])
    # flyer landing boards and a ring perch on the left face (always empty)
    for bx0, by in ((92, 362), (96, 404)):
        cv.rect(bx0, by, 120, by + 2, TIMB['hi']); cv.rect(bx0, by + 3, 120, by + 4, TIMB['sh'])
        cv.line([(118, by + 12), (104, by + 5)], TIMB['mid'], 2)
    cv.ell(102, 334, 4, 4, BRASS['lit']); cv.ell(102, 334, 2, 2, CLEAR); cv.rect(106, 333, 118, 334, BRASS['sh'])
    deck(cv, cx, yt, r + 3, ry + 1, STONE['mid'], lip=2)


def knot(cv, x, y, r, m=ROOTC):
    cv.ell(x + 1, y + 1, r, r * 0.8, m['sh']); cv.ell(x, y, r - 1, (r - 1) * 0.8, m['mid'])
    cv.px(x - 1, y - 1, m['lit']); cv.px(x + r - 1, y + 1, INK)


def draw_root_vein(cv, rng):
    segs = [[(90, 608, 17), (97, 592, 17), (103, 574, 16), (106, 556, 15), (106, 542, 15)],
            [(107, 514, 15), (104, 494, 14), (103, 474, 14), (107, 452, 13), (113, 432, 13), (118, 410, 12)],
            [(124, 384, 11), (127, 366, 10), (132, 350, 10), (138, 336, 9)]]
    for s in segs:
        tube(cv, s, ROOTC, treads=True, rng=rng)
    for s in ([(105, 566, 6), (114, 570, 4), (121, 568, 3)], [(104, 486, 6), (113, 482, 4), (121, 484, 3)],
              [(116, 420, 5), (124, 416, 3)], [(128, 362, 5), (136, 366, 3)]):
        tube(cv, s, ROOTC)                                    # rootlets gripping the stone
    for x, y, r in ((101, 582, 4), (104, 462, 3)):
        knot(cv, x, y, r)
    for y, x0, x1 in ((542, 98, 114), (514, 99, 115), (410, 111, 125), (384, 117, 131)):
        cv.rect(x0, y, x1, y, INK)                            # ink lips where the root dives into the stone
    for mx, my in ((94, 596), (101, 532), (106, 446), (122, 378)):
        cv.ell(mx, my, 3, 2, MOSS['lit']); cv.px(mx - 1, my - 1, MOSS['hi'])


def draw_chute(cv):
    for y in range(344, 617):
        xc = 262 + 60 * (y - 344) / 272
        cv.rect(xc - 5, y, xc + 5, y, TIMB['lit'])
        cv.rect(xc - 5, y, xc - 4, y, TIMB['hi'])
        cv.rect(xc + 2, y, xc + 5, y, TIMB['sh'])
        cv.px(xc - 6, y, BRASS['lit']); cv.px(xc + 6, y, BRASS['sh']); cv.px(xc + 7, y, INK)
        if y % 14 == 0:
            cv.rect(xc - 5, y, xc + 5, y, TIMB['mid'])
        if y % 48 == 20:
            cv.rect(xc + 7, y - 2, xc + 11, y + 2, INK)
    cv.poly([(252, 338), (274, 338), (269, 350), (257, 350)], TIMB['mid']); cv.rect(252, 338, 274, 339, TIMB['hi'])
    cv.rect(314, 612, 330, 617, TIMB['mid']); cv.rect(314, 612, 330, 612, BRASS['lit'])
    cv.rect(317, 618, 327, 625, PARCH); cv.rect(317, 625, 327, 625, STONE['sh'])


def draw_gable(cv):
    cv.ell(216, 586, 48, 26, BRICK['lit']); cv.ell(216, 586, 44, 22, STONE['lit'])
    cv.rect(168, 586, 264, 612, STONE['lit']); cv.rect(168, 586, 171, 612, BRICK['lit'])
    cv.rect(261, 586, 264, 612, BRICK['sh'])
    for x in range(168, 265):                                 # moss lip along the arch top
        e = ef(216, 48, 26, x)
        cv.rect(x, 586 - e - 1, x, 586 - e, MOSS['lit'])
    cv.rect(168, 609, 264, 612, STONE['sh']); cv.rect(168, 612, 264, 612, INK)
    # Route Board: brass plate, waymark arms, 8 peg sockets (2 lit = runners out)
    cv.rect(190, 580, 241, 605, BRASS['sh']); cv.rect(191, 581, 240, 604, BRASS['lit'])
    cv.rect(191, 581, 240, 582, BRASS['hi'])
    knot = (215, 600)
    arms = [(196, 586), (215, 584), (236, 587)]
    for a in arms:
        cv.line([knot, a], BRASS['sh'], 2)
    pegs = []
    for a in arms:
        for k in (0.45, 0.8) if a != arms[1] else (0.4, 0.72, 0.98):
            pegs.append((knot[0] + (a[0] - knot[0]) * k, knot[1] + (a[1] - knot[1]) * k))
    for i, (x, y) in enumerate(pegs[:8]):
        cv.rect(x - 1, y - 1, x + 1, y + 1, AMBER['hi'] if i in (1, 4) else INK)


def draw_reel_back(cv, rng):
    ocx, ocy, orx, ory = 200, 290, 112, 44
    cv.ell(ocx, ocy, orx, ory, TIMB['lit'])
    cv.rect(ocx - orx - 1, ocy + 1, ocx + orx + 1, ocy + ory + 1, CLEAR)
    for a in range(190, 360, 12):                             # radial plank joints
        ax, ay = ocx + orx * math.cos(math.radians(a)), ocy + ory * math.sin(math.radians(a))
        cv.line([(ocx + 0.5 * (ax - ocx), ocy + 0.5 * (ay - ocy)), (ax, ay)], TIMB['mid'])
    for x in range(ocx - orx, ocx + orx + 1, 9):              # back rail posts
        y = ocy - ef(ocx, orx, ory, x)
        cv.rect(x, y - 6, x + 1, y, TIMB['hi'])
    for x in range(ocx - orx, ocx + orx + 1):
        cv.px(x, ocy - ef(ocx, orx, ory, x) - 6, TIMB['hi'])
    # the dispatcher's loft: timber and brass drum, one big round lit window, moss dome
    cx, r, ry, yt, yf = 196, 54, 22, 234, 290
    cyl_face(cv, cx, r, ry, yt, yf, TIMB)
    band(cv, cx, r, ry, yt, 4, 6, BRASS); band(cv, cx, r, ry, yt, 50, 52, BRASS)
    cv.ell(206, 262, 15, 15, BRASS['lit']); cv.ell(207, 263, 14, 14, BRASS['sh'])
    cv.ell(206, 262, 12, 12, AMBER['lit']); cv.ell(203, 259, 6, 6, AMBER['hi'])
    for a in (-90, 210, 330):
        cv.line([(206, 262), (206 + 12 * math.cos(math.radians(a)), 262 + 12 * math.sin(math.radians(a)))], INK)
    cv.ell(196, 236, 58, 22, MOSS['sh']); cv.ell(196, 230, 52, 26, MOSS['mid'])
    cv.ell(193, 227, 46, 22, MOSS['lit']); cv.ell(178, 218, 14, 7, MOSS['hi'])
    for x in range(138, 255):
        cv.px(x, 236 + ef(196, 58, 22, x) + 1, INK)


def draw_reach(cv, rng):
    pts = []
    for y in range(318, 83, -6):                              # a living shaft: gentle S-wobble, flared foot
        k = (y - 84) / 234
        tt = 24 + 10 * k ** 1.3 + (6 * (y - 296) / 22 if y > 296 else 0)
        pts.append((150 + 4 * math.sin((318 - y) / 38), y, tt))
    ax = pts[-1][0] + 32
    for a in range(180, 361, 6):
        tt = 24 - 8 * (a - 180) / 180
        pts.append((ax + 32 * math.cos(math.radians(a)), 84 + 32 * math.sin(math.radians(a)), tt))
    pts += [(215, 90, 14), (216, 96, 11)]
    tube(cv, pts, ROOTC, treads=False, rng=rng)
    # rootlets binding the loft: over the dome and across its face
    tube(cv, [(160, 262, 8), (170, 250, 6), (180, 240, 4), (188, 234, 3)], ROOTC, rng=rng)
    tube(cv, [(162, 292, 7), (172, 298, 5), (184, 301, 3)], ROOTC, rng=rng)
    tube(cv, [(138, 300, 8), (128, 302, 5), (122, 306, 3)], ROOTC, rng=rng)
    for x, y, r in ((147, 268, 5), (153, 196, 4), (149, 124, 4)):
        knot(cv, x, y, r)
    for mx, my in ((140, 236), (139, 220), (141, 160)):       # moss climbing the lit side
        cv.ell(mx, my, 2, 4, MOSS['lit']); cv.px(mx - 1, my - 2, MOSS['hi'])
    for y in (300, 246, 176):                                 # worn brass bands
        hw = 17 - (318 - y) * 0.04
        cv.rect(150 - hw, y, 150 + hw, y + 4, BRASS['lit'])
        cv.rect(150 + hw * 0.4, y, 150 + hw, y + 4, BRASS['sh'])
        cv.rect(150 - hw + 2, y + 1, 150 - hw + 3, y + 1, BRASS['hi'])
        cv.rect(150 - hw, y + 5, 150 + hw, y + 5, INK)
    for a in range(196, 300, 5):                              # moss along the lit top of the curl
        rr = 32 + 10
        cv.ell(182 + rr * math.cos(math.radians(a)), 84 + rr * math.sin(math.radians(a)), 2, 2, MOSS['lit'])
    for a in range(206, 290, 14):
        rr = 32 + 11
        cv.px(182 + rr * math.cos(math.radians(a)), 84 + rr * math.sin(math.radians(a)) - 1, MOSS['hi'])
    for lx, ly in ((160, 44), (226, 70)):                     # two small leaf tufts
        cv.ell(lx, ly, 4, 3, MOSS['mid']); cv.ell(lx - 1, ly - 1, 2, 2, MOSS['hi'])
    cv.rect(215, 94, 217, 97, BRASS['lit'])


def draw_ring_front(cv):
    ocx, ocy, orx, ory = 200, 290, 112, 44
    cv.ell(ocx, ocy, orx, ory, TIMB['lit'])
    cv.rect(ocx - orx - 1, ocy - ory - 1, ocx + orx + 1, ocy - 1, CLEAR)
    cv.ell(196, 290, 54, 22, CLEAR)                           # the loft stands in the middle
    for a in range(12, 180, 10):
        ax, ay = ocx + orx * math.cos(math.radians(a)), ocy + ory * math.sin(math.radians(a))
        cv.line([(ocx + 0.52 * (ax - ocx), ocy + 0.52 * (ay - ocy)), (ax, ay)], TIMB['mid'])
    cv.ell(196, 290, 54, 22, CLEAR)
    for x in range(ocx - orx, ocx + orx + 1):                 # rim face with brass band
        y = ocy + ef(ocx, orx, ory, x)
        cv.rect(x, y + 1, x, y + 7, TIMB['mid'])
        cv.rect(x, y + 3, x, y + 4, BRASS['lit'] if x < ocx + 40 else BRASS['sh'])
        cv.px(x, y + 8, INK)
    for x in range(ocx - orx + 3, ocx + orx - 2, 10):         # front rail at creature hip height
        y = ocy + ef(ocx, orx, ory, x)
        cv.rect(x, y - 7, x + 1, y, TIMB['hi'])
    for x in range(ocx - orx + 3, ocx + orx - 2):
        cv.px(x, ocy + ef(ocx, orx, ory, x) - 7, TIMB['hi'])
    for t in LANTERN_T:                                       # brass sheaves where the waylines tie off
        x, y = ring_pt(t, -2)
        cv.ell(x, y, 3, 3, BRASS['lit']); cv.px(x, y, INK); cv.px(x - 1, y - 2, BRASS['hi'])
    cv.ell(150, 318, 22, 7, MOSS['mid']); cv.ell(150, 317, 19, 5, MOSS['lit'])   # collar where the Reach rises
    cv.ell(150, 316, 15, 4, ROOTC['mid']); cv.ell(146, 315, 7, 2, ROOTC['lit'])


def draw_bell(cv):
    cv.rect(86, 248, 89, 320, TIMB['mid']); cv.rect(86, 248, 86, 320, TIMB['hi'])
    cv.rect(46, 248, 90, 252, TIMB['lit']); cv.rect(46, 248, 90, 248, TIMB['hi']); cv.rect(46, 253, 90, 253, INK)
    cv.line([(60, 254), (86, 282)], TIMB['mid'], 3)
    cv.poly([(50, 248), (63, 237), (76, 248)], TIMB['lit']); cv.poly([(63, 237), (76, 248), (66, 248)], TIMB['mid'])
    cv.line([(51, 247), (63, 237), (75, 247)], MOSS['lit'], 2); cv.px(60, 239, MOSS['hi'])
    cv.rect(50, 248, 76, 248, INK)
    cv.rect(61, 254, 63, 258, INK)
    cv.ell(62, 266, 10, 9, BRONZE['lit']); cv.rect(52, 266, 72, 276, BRONZE['lit'])
    cv.rect(64, 260, 72, 276, BRONZE['sh']); cv.rect(50, 276, 74, 279, BRONZE['sh'])
    cv.rect(54, 262, 55, 270, BRONZE['hi']); cv.rect(61, 280, 63, 283, INK)
    cv.rect(66, 280, 67, 320, TWINE)


def draw_lantern(state):
    cv = Cv((0, 0, 12, 20))
    cv.rect(5, 0, 6, 3, BRASS['sh'])
    cv.rect(2, 3, 9, 5, BRASS['lit']); cv.rect(2, 3, 9, 3, BRASS['hi'])
    glass = {'lit': AMBER['lit'], 'dark': TIMB['dk'], 'quiet': STONE['sh']}[state]
    cv.rect(2, 6, 9, 15, glass)
    if state == 'lit':
        cv.rect(3, 7, 5, 11, AMBER['hi'])
    if state == 'quiet':
        cv.rect(3, 7, 4, 8, STONE['mid']); cv.line([(6, 7), (8, 12)], INK)
    cv.rect(1, 6, 1, 15, BRASS['mid']); cv.rect(10, 6, 10, 15, BRASS['sh'])
    cv.rect(1, 16, 10, 18, BRASS['mid']); cv.rect(1, 18, 10, 18, BRASS['sh'])
    return cv.im


def draw_lamp(cv):
    cv.rect(215, 92, 216, 101, BRASS['sh'])
    for y in (93, 97):
        cv.px(215, y, BRASS['hi'])
    cv.line([(207, 107), (209, 103), (216, 101), (223, 103), (225, 107)], BRASS['lit'], 2)
    cv.rect(206, 105, 226, 109, BRASS['lit']); cv.rect(206, 105, 226, 105, BRASS['hi'])
    cv.rect(220, 106, 226, 109, BRASS['sh'])
    cv.rect(205, 110, 227, 127, AMBER['lit']); cv.rect(207, 111, 213, 120, AMBER['hi'])
    cv.rect(205, 110, 205, 127, BRASS['mid']); cv.rect(227, 110, 227, 127, BRASS['sh'])
    cv.rect(216, 110, 216, 127, INK)
    cv.rect(203, 127, 229, 130, BRASS['mid']); cv.rect(203, 130, 229, 130, BRASS['sh'])
    cv.rect(214, 131, 218, 133, BRASS['sh'])


def draw_vane(cv):
    cv.rect(181, 8, 182, 43, BRASS['lit']); cv.rect(182, 8, 182, 43, BRASS['sh'])
    cv.ell(182, 11, 2, 2, BRASS['lit'])
    cv.line([(181, 10), (169, 5)], BRASS['lit'], 2)
    cv.line([(183, 10), (200, 10)], BRASS['lit'], 2)
    cv.line([(182, 9), (184, 1)], BRASS['lit'], 2)
    cv.poly([(183, 16), (195, 16), (200, 18), (207, 17), (200, 21), (194, 24), (183, 24)], TEAL['lit'])
    cv.poly([(190, 19), (199, 19), (195, 22)], TEAL['sh'])
    cv.rect(183, 16, 194, 16, TEAL['hi'])


def draw_root_foot(cv, rng):
    # the Great Root arches out of the turf and climbs onto the depot's left corner (the Climb starts here)
    cv.ell(48, 714, 44, 5, MOSS['sh'])
    tube(cv, [(4, 718, 18), (12, 712, 21), (22, 702, 23), (32, 688, 24), (42, 670, 23), (52, 652, 22),
              (64, 636, 20), (78, 622, 18), (90, 610, 17)], ROOTC, treads=True, rng=rng)
    tube(cv, [(40, 672, 10), (44, 692, 8), (50, 708, 6), (52, 718, 4)], ROOTC, rng=rng)
    tube(cv, [(26, 698, 8), (20, 710, 6), (22, 719, 4)], ROOTC, rng=rng)
    tube(cv, [(64, 638, 9), (70, 658, 7), (72, 682, 5), (76, 704, 4)], ROOTC, rng=rng)
    for x, y, r in ((32, 688, 5), (64, 636, 4)):
        knot(cv, x, y, r)
    for mx, my in ((16, 702), (36, 674), (56, 644), (74, 624)):
        cv.ell(mx, my, 4, 2, MOSS['lit']); cv.px(mx - 2, my - 1, MOSS['hi'])
    cv.ell(34, 716, 7, 3, BOULD['mid']); cv.ell(32, 715, 4, 2, BOULD['lit'])


def draw_yard(cv):
    cv.rect(364, 664, 428, 699, TIMB['lit'])
    for y in range(668, 700, 6):
        cv.rect(364, y, 428, y, TIMB['mid'])
    cv.rect(364, 664, 428, 665, TIMB['hi'])
    cv.rect(364, 700, 428, 709, TIMB['mid']); cv.rect(364, 710, 428, 710, INK)
    for x in (366, 396, 424):
        cv.rect(x, 711, x + 2, 719, TIMB['sh'])
    cv.ell(388, 672, 8, 4, BRASS['mid']); cv.rect(380, 660, 396, 672, TIMB['mid'])
    cv.ell(388, 660, 8, 4, BRASS['lit']); cv.rect(386, 650, 390, 660, TIMB['sh'])
    cv.rect(396, 662, 404, 663, BRASS['sh'])
    cv.rect(404, 670, 424, 690, OIL); cv.rect(404, 670, 424, 672, MOSS['lit']); cv.rect(413, 670, 414, 690, TWINE)
    cv.rect(408, 662, 420, 670, PARCH); cv.rect(414, 662, 414, 670, TWINE)
    cv.rect(366, 678, 380, 692, TIMB['sh']); cv.rect(366, 678, 380, 680, TIMB['hi'])
    cv.ell(369, 696, 4, 4, BRASS['mid']); cv.ell(369, 696, 2, 2, TIMB['dk'])
    cv.rect(418, 636, 430, 662, TIMB['mid']); cv.rect(418, 638, 430, 640, BRASS['sh'])
    cv.ell(424, 636, 6, 3, TEAL['mid'])


def draw_post(state='strung'):
    cv = Cv((0, 0, 24, 64))
    cv.rect(4, 56, 19, 63, BOULD['mid']); cv.rect(4, 56, 19, 57, BOULD['lit'])
    cv.rect(10, 10, 14, 56, TIMB['lit']); cv.rect(13, 10, 14, 56, TIMB['mid'])
    cv.rect(8, 30, 16, 37, BRASS['lit']); cv.line([(12, 36), (12, 32)], INK); cv.line([(12, 36), (10, 32)], INK)
    cv.line([(12, 36), (14, 32)], INK)
    cv.ell(12, 7, 6, 6, BRASS['mid']); cv.ell(12, 7, 4, 4, BRASS['lit']); cv.px(12, 7, INK)
    cv.rect(16, 14, 19, 15, BRASS['sh'])
    cv.rect(16, 16, 20, 22, AMBER['lit'] if state == 'strung' else TIMB['dk'])
    cv.ell(10, 56, 4, 2, MOSS['lit'])
    return cv.im


def draw_stair():
    cv = Cv((0, 0, 48, 96))
    for i in range(8):
        y = i * 12
        cv.rect(0, y, 47, y + 7, STONE['lit']); cv.rect(0, y, 47, y + 1, STONE['hi'])
        cv.rect(0, y + 8, 47, y + 11, STONE['sh']); cv.rect(0, y + 11, 47, y + 11, INK)
        cv.rect(14 + (i % 3) * 6, y + 3, 30 + (i % 3) * 6, y + 5, STONE['mid'])
    cv.line([(24, 9), (24, 3)], STONE['hi'], 1); cv.line([(24, 9), (19, 4)], STONE['hi']); cv.line([(24, 9), (29, 4)], STONE['hi'])
    tube(cv, [(0, 40, 5), (10, 46, 4)], ROOTC); tube(cv, [(47, 70, 5), (38, 76, 4)], ROOTC)
    return cv.im


def draw_basket(full=True):
    cv = Cv((0, 0, 16, 16))
    cv.line([(8, 0), (3, 6)], TWINE); cv.line([(8, 0), (13, 6)], TWINE)
    cv.rect(2, 6, 13, 15, TIMB['hi']); cv.rect(9, 6, 13, 15, TIMB['lit'])
    for y in (8, 11, 14):
        cv.rect(2, y, 13, y, TIMB['mid'])
    if full:
        cv.rect(4, 3, 11, 7, OIL); cv.rect(7, 3, 7, 7, TWINE)
    return cv.im


def draw_cradle():
    cv = Cv((0, 0, 12, 14))
    cv.ell(6, 2, 2, 2, BRASS['lit']); cv.rect(5, 4, 6, 6, BRASS['sh'])
    cv.line([(6, 6), (2, 8)], TWINE); cv.line([(6, 6), (10, 8)], TWINE)
    cv.rect(2, 8, 10, 13, OIL); cv.rect(6, 8, 6, 13, TWINE)
    return cv.im


def draw_parcel(v):
    cv = Cv((0, 0, 10, 8))
    if v == 'a':
        cv.rect(0, 2, 9, 7, OIL); cv.rect(0, 2, 9, 2, MOSS['lit']); cv.rect(4, 2, 4, 7, TWINE)
    else:
        cv.rect(2, 0, 8, 7, PARCH); cv.rect(2, 0, 8, 0, STONE['hi']); cv.rect(5, 0, 5, 7, TWINE)
    return cv.im


BODY_ORDER = [
    ('town.building.hall', draw_depot, True),
    ('town.building.hall.drum', draw_drum, True),
    ('town.building.hall.hoist', draw_hoist, False),
    ('town.building.hall.galleries', draw_galleries, True),
    ('town.building.hall.root_vein', draw_root_vein, True),
    ('town.building.hall.chute', draw_chute, False),
    ('town.building.hall.gable', draw_gable, False),
    ('town.building.hall.reel_back', draw_reel_back, True),
    ('town.building.hall.reach', draw_reach, True),
    ('town.building.hall.ring_front', draw_ring_front, False),
    ('town.building.hall.bell', draw_bell, False),
    ('town.building.hall.lamp', draw_lamp, False),
    ('town.building.hall.vane', draw_vane, False),
]
GROUND_WINGS = [('town.building.hall.root_foot', draw_root_foot), ('town.building.hall.yard', draw_yard)]


def render_part(pid, fn, uses_rng):
    cv = Cv(PART[pid])
    if uses_rng:
        fn(cv, random.Random(hash(pid) % 1000 + 11))
    else:
        fn(cv)
    return cv.im


def build_frame():
    frame = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    parts = {}
    for pid, fn, rr in BODY_ORDER:
        im = render_part(pid, fn, rr)
        parts[pid] = im
        x, y, _, _ = PART[pid]
        frame.alpha_composite(im, (x, y))
        if pid == 'town.building.hall.ring_front':
            for t, stt in zip(LANTERN_T, LANTERN_STATE):
                lx, ly = ring_pt(t, 8)
                frame.alpha_composite(draw_lantern(stt), (round(lx - 6), round(ly - 1)))
    wings = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    for pid, fn in GROUND_WINGS:
        cv = Cv(PART[pid])
        fn(cv, random.Random(5)) if pid.endswith('root_foot') else fn(cv)
        parts[pid] = cv.im
        wings.alpha_composite(cv.im, PART[pid][:2])
    return frame, wings, parts


# ---------------------------------------------------------------- the area around it
def wpt(fx, fy):
    return fx + FO[0], fy + FO[1]


def cable(cv, p0, p1, sag, tag_every=40):
    n = int(math.hypot(p1[0] - p0[0], p1[1] - p0[1]))
    pts = []
    for i in range(n + 1):
        t = i / max(1, n)
        x = p0[0] + (p1[0] - p0[0]) * t
        y = p0[1] + (p1[1] - p0[1]) * t + sag * 4 * t * (1 - t)
        pts.append((x, y))
    for i, (x, y) in enumerate(pts):
        cv.px(x, y, INK); cv.px(x, y - 1, STONE['sh'])
        if i % tag_every == tag_every // 2:
            cv.rect(x, y + 1, x + 1, y + 3, TEAL['lit'])
    return pts


def compose_world(frame, wings, figures=True):
    rng = random.Random(3)
    W = Cv((0, -SKY, AREA_W, SKY + AREA_H))
    sky = ['#2e3a4f', '#3a4a60', '#4a5e73', '#5f7485', '#7d8f93', '#a7a68e']
    for i, c in enumerate(sky):
        y0 = -SKY + i * SKY // len(sky)
        W.rect(0, y0, AREA_W - 1, y0 + SKY // len(sky), c)
    # ground: hedge row 0, grass rows 1-12, cliff row 13
    W.rect(0, 0, AREA_W - 1, 311, '#6b6f1d')
    for _ in range(420):
        x, y = rng.randint(0, AREA_W - 1), rng.randint(24, 308)
        W.rect(x, y, x + 1, y, '#908940')
    W.rect(0, 0, AREA_W - 1, 23, MOSS['sh'])
    for x in range(0, AREA_W, 10):
        W.ell(x + 5, 12, 7, 9, '#55581c'); W.ell(x + 3, 9, 3, 3, '#6b6f1d')
    W.rect(0, 312, AREA_W - 1, 335, BOULD['sh']); W.rect(0, 312, AREA_W - 1, 314, BOULD['lit'])
    for x in range(0, AREA_W, 17):
        W.line([(x, 316), (x + 5, 335)], BOULD['dk'])
    # long shadow (coded): the assembled silhouette sheared down-right onto the plaza
    alpha = Image.new('L', (FW, FH)); alpha.paste(frame.split()[3]); alpha2 = wings.split()[3]
    mask = Image.new('L', (AREA_W, SKY + AREA_H), 0)
    md = mask.load(); a1 = alpha.load(); a2 = alpha2.load()
    for y in range(FH):
        h = 719 - y
        for x in range(FW):
            if a1[x, y] or a2[x, y]:
                wx = round(FO[0] + x + 0.30 * h); wy = round(215 + 0.13 * h)
                if 0 <= wx < AREA_W and 0 <= wy <= 311:
                    md[wx, wy + SKY] = 255
    shade = Image.new('RGBA', W.im.size, (0, 0, 0, 62))
    W.im.paste(Image.alpha_composite(W.im, shade), (0, 0), mask)
    # rise stair (painted ground part replacing the coded steps)
    W.im.alpha_composite(draw_stair(), (12 * T, 9 * T + SKY))
    # tower body, then the y-sorted ground wings (row 8)
    W.im.alpha_composite(frame, (FO[0], FO[1] + SKY))
    W.im.alpha_composite(wings, (FO[0], FO[1] + SKY))
    # props on rows 9+ draw in front of the tower: well, lamp posts, Job Board
    W.ell(216, 262, 20, 13, STONE['sh']); W.ell(216, 260, 19, 12, STONE['lit']); W.ell(216, 261, 12, 7, '#1b4a50')
    for lx in (11, 14):
        x = lx * T + 12
        W.rect(x - 1, 9 * T - 26, x + 1, 9 * T + 16, TIMB['mid']); W.rect(x - 4, 9 * T - 32, x + 4, 9 * T - 25, BRASS['lit'])
        W.rect(x - 3, 9 * T - 31, x + 3, 9 * T - 26, AMBER['hi'])
    W.rect(386, 9 * T - 26, 429, 9 * T + 6, TIMB['mid']); W.rect(390, 9 * T - 22, 425, 9 * T, PARCH)
    for nx in (394, 404, 414):
        W.rect(nx, 9 * T - 18, nx + 7, 9 * T - 10, STONE['hi'])
    W.rect(390, 9 * T + 6, 393, 9 * T + 16, TIMB['sh']); W.rect(422, 9 * T + 6, 425, 9 * T + 16, TIMB['sh'])
    # coded life: beacon glow, chimney smoke, hoist rope and basket, chute parcel
    bx, by = wpt(*BEACON)
    for rr, al in ((16, 40), (12, 70)):
        for a in range(0, 360, 4):
            W.px(bx + rr * math.cos(math.radians(a)), by + rr * 0.9 * math.sin(math.radians(a)), (251, 212, 144, al))
    for i, (sx, sy, r) in enumerate(((439, 18, 3), (443, 9, 3), (448, 0, 4), (455, -9, 4))):
        W.ell(sx, sy, r, r - 1, (214, 204, 184, 130 - i * 22))
    rx = wpt(385, 488)[0]
    W.rect(rx, wpt(0, 488)[1], rx, wpt(0, 652)[1], INK); W.rect(rx - 1, wpt(0, 488)[1], rx - 1, wpt(0, 652)[1], STONE['sh'])
    W.im.alpha_composite(draw_basket(True), (rx - 8, 84 + SKY))
    W.im.alpha_composite(draw_parcel('b'), (wpt(318, 0)[0], wpt(0, 626)[1] + SKY))
    # waylines (coded) from the sheaves to relay posts and off toward the Street
    posts = [(2, 10), (24, 10)]
    for px_, py_ in posts:
        W.im.alpha_composite(draw_post('strung'), (px_ * T, py_ * T + T - 64 + SKY))
    lines = [(LANTERN_T[6], (2 * T + 12, 10 * T + T - 57), 40),
             (LANTERN_T[0], (24 * T + 12, 10 * T + T - 57), 40),
             (LANTERN_T[5], (40, 336), 34),
             (LANTERN_T[1], (606, 336), 34)]
    for t, end, sag in lines:
        sx, sy = ring_pt(t, -2)
        pts = cable(W, wpt(sx, sy), end, sag)
        cx_, cy_ = pts[int(len(pts) * 0.62)]
        W.im.alpha_composite(draw_cradle(), (round(cx_ - 6), round(cy_ + SKY)))
    if figures:
        place_figures(W)
    return W.im


def load_sprite(path, cell=None):
    if not os.path.exists(path):
        return None
    im = Image.open(path).convert('RGBA')
    if cell:
        im = im.crop(cell)
    bb = im.getbbox()
    return im.crop(bb) if bb else None


def place_figures(W):
    figs = []
    cour = load_sprite(os.path.join(SPR, 'player', 'retro_diffusion_chibi_walking_2026_10_01',
                                    'male_chibi_walk_eight_directions_native80.png'), (0, 0, 80, 80))
    gale = load_sprite(os.path.join(SPR, 'arena', 'galeshear', 'town', 's.png'))
    cind = load_sprite(os.path.join(SPR, 'arena', 'cinderhide', 'town', 's.png'))
    if gale:
        figs.append((gale, 312, 214))              # in the doorway: 63x62 under a 48x64 door
    if cour:
        figs.append((cour, 10 * T + 12, 10 * T + 19))
    if cind:
        figs.append((cind, 14 * T + 12, 10 * T + 19))
    for im, fx, fy in figs:
        W.im.alpha_composite(im, (round(fx - im.width / 2), round(fy - im.height + SKY)))
    print('figures:', [(f[0].size) for f in figs])


def dashed_rect(d, x0, y0, x1, y1, c, on=4, off=3):
    for x in range(x0, x1 + 1):
        if (x - x0) % (on + off) < on:
            d.point((x, y0), fill=c); d.point((x, y1), fill=c)
    for y in range(y0, y1 + 1):
        if (y - y0) % (on + off) < on:
            d.point((x0, y), fill=c); d.point((x1, y), fill=c)


# ---------------------------------------------------------------- outputs
def mock_1x(world):
    M, R = 8, 300
    im = Image.new('RGBA', (AREA_W + R, SKY + AREA_H + 2 * M), hx('#16171a'))
    im.alpha_composite(world, (0, M))
    d = ImageDraw.Draw(im)
    f, fb = font(11), font(13)
    views = [((120, 120), '#ffffff', 'door view, normal play (view top 120)'),
             ((120, 48), '#f1c177', 'door view with the 72 px look-up lean'),
             ((120, -512), '#5cc2b4', 'reveal hold: apex +10 px margin')]
    for (vx, vy), c, _ in views:
        dashed_rect(d, vx, vy + SKY + M, vx + 383, vy + 215 + SKY + M, c)
    X = AREA_W + 14
    d.text((X, M), 'Wayline Tower blockout, real 1x (proposal)', fill='#f5d9a8', font=fb)
    d.text((X, M + 16), 'Tower Rise 26x14 tiles; frame 432x720 (18x30 tiles)', fill='#ccb290', font=f)
    rx = X + 6
    y_of = lambda wy: wy + SKY + M
    d.line([(rx, y_of(216)), (rx, y_of(-504))], fill='#ccb290')
    for k in range(0, 31):
        wy = 216 - k * 24
        d.line([(rx, y_of(wy)), (rx + 3, y_of(wy))], fill='#9c8c68')
    for k in range(0, 4):
        wy = 216 - k * 216
        d.line([(rx - 4, y_of(wy)), (rx + 8, y_of(wy))], fill='#f5d9a8')
        d.text((rx + 10, y_of(wy) - 7), '%d screen%s' % (k, '' if k == 1 else 's'), fill='#f5d9a8', font=f)
    tiers = [(-445, 'T5 the Reach and the Waiting Lamp'), (-250, 'T4 Reel Deck, loft, bell'),
             (-150, 'T3 Galleries, walkway, perches'), (-20, 'T2 Sorting Drum, hoist, chute'),
             (120, 'T1 Depot: arch, Route Board, porches'), (196, 'T0 roots, yard, stair, posts')]
    for wy, label in tiers:
        d.text((rx + 76, y_of(wy) - 6), label, fill='#e6c697', font=f)
        d.line([(AREA_W - 2, y_of(wy)), (rx + 72, y_of(wy))], fill='#5f5e57')
    ly = y_of(250)
    for (_, _), c, label in views:
        d.line([(X, ly + 5), (X + 18, ly + 5)], fill=c)
        d.text((X + 24, ly), label, fill=c, font=f)
        ly += 15
    d.text((X, ly + 4), 'sky above row 0 is drawn only in the reveal', fill='#9c8c68', font=f)
    d.text((X, ly + 18), 'Galeshear 63x62 in the 48x64 doorway', fill='#9c8c68', font=f)
    d.text((X, ly + 32), 'courier 66 px (10,10), Cinderhide (14,10)', fill='#9c8c68', font=f)
    im.save(os.path.join(HERE, 'mock_tower_1x.png'))


def mock_3x(world):
    crop = world.crop((120, 48 + SKY, 504, 264 + SKY)).resize((1152, 648), Image.NEAREST)
    im = Image.new('RGBA', (1152, 648 + 34), hx('#16171a'))
    im.alpha_composite(crop, (0, 0))
    d = ImageDraw.Draw(im)
    d.text((10, 656), 'At the doors with the 72 px look-up lean (world x 120-503, y 48-263), drawn at the game\'s 3x. '
           'Route Board on the gable, grand arch, First Post, porches, hoist basket, waylines from above.',
           fill='#e6c697', font=font(13))
    im.save(os.path.join(HERE, 'mock_tower_3x_crop.png'))


def far_slot():
    """road.backdrop.highbank_far, painted for its own 160x96 size (2 px minimum strokes)."""
    cv = Cv((0, 0, 160, 96))
    # bluff and Highbank roofs
    cv.poly([(30, 95), (40, 76), (60, 72), (128, 71), (146, 78), (156, 95)], BOULD['mid'])
    cv.poly([(40, 76), (60, 72), (128, 71), (146, 78), (140, 80), (52, 79)], BOULD['lit'])
    for i, rx in enumerate(range(44, 146, 9)):
        if 66 <= rx <= 112:
            continue
        hh = 5 + (i * 3) % 4
        cv.rect(rx, 71 - hh, rx + 6, 71, STONE['mid']); cv.rect(rx - 1, 71 - hh - 2, rx + 7, 71 - hh, BRICK['mid'])
        cv.px(rx + 3, 71 - hh // 2, AMBER['lit'])
    # the Tower: foot at (92, 72), apex at y 2 (70 px tall)
    cv.poly([(68, 72), (72, 66), (79, 61), (81, 64), (76, 72)], ROOTC['mid'])          # root slope, left
    cv.rect(78, 56, 106, 72, STONE['lit']); cv.rect(98, 56, 106, 72, STONE['sh'])
    cv.rect(78, 55, 106, 56, STONE['hi']); cv.rect(90, 64, 94, 72, TIMB['dk'])
    cv.rect(106, 66, 112, 72, TIMB['mid'])                                             # yard, right
    cv.rect(82, 38, 102, 56, STONE['lit']); cv.rect(96, 38, 102, 56, STONE['sh'])
    cv.rect(85, 46, 93, 48, AMBER['mid'])
    cv.rect(102, 46, 109, 47, TIMB['lit']); cv.rect(108, 48, 108, 60, INK)                # hoist tick and rope
    cv.rect(83, 28, 99, 38, PLAST['mid']); cv.rect(94, 28, 99, 38, STONE['sh'])
    cv.rect(79, 31, 101, 33, TIMB['lit']); cv.rect(79, 33, 101, 33, BRASS['sh'])        # Reel ring
    for lx in (82, 87, 92, 97, 100):
        cv.px(lx, 34, AMBER['hi'] if lx != 87 else TIMB['dk'])
    cv.rect(74, 26, 79, 27, TIMB['lit']); cv.rect(75, 28, 76, 30, BRONZE['lit'])          # bell tick, left
    cv.rect(86, 22, 96, 30, TIMB['mid']); cv.rect(86, 21, 96, 22, MOSS['lit'])
    # the Reach crook, 2-3 px strokes, and the hanging lamp under the hook
    cv.rect(84, 9, 86, 31, ROOTC['lit']); cv.rect(86, 9, 86, 31, ROOTC['mid'])
    for a in range(180, 361, 10):
        x = 89 + 4 * math.cos(math.radians(a)); y = 9 + 4 * math.sin(math.radians(a))
        cv.rect(x - 1, y - 1, x, y, ROOTC['lit'])
    cv.rect(92, 9, 93, 11, ROOTC['mid'])
    cv.rect(92, 13, 93, 15, AMBER['hi']); cv.rect(91, 14, 91, 15, AMBER['mid'])
    cv.rect(88, 1, 89, 4, BRASS['lit'])
    for x0, y0, x1, y1 in ((79, 33, 58, 66), (101, 33, 126, 64)):   # broken hair-thin waylines to the roofs
        n = int(math.hypot(x1 - x0, y1 - y0))
        for i in range(n):
            if i % 4 != 3:
                cv.px(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n + 3 * math.sin(math.pi * i / n), TIMB['sh'])
    return cv.im


def mock_far(frame, wings):
    road = Cv((0, 0, 384, 216))
    sky = ['#3a4a60', '#4a5e73', '#62788a', '#7f939a', '#a3a891', '#c2b58f']
    for i, c in enumerate(sky):
        road.rect(0, i * 24, 383, i * 24 + 24, c)
    road.rect(0, 144, 383, 215, sky[-1])  # fill below the last band so no transparent gap shows under the hills
    road.poly([(0, 150), (60, 132), (130, 140), (200, 128), (300, 138), (384, 126), (384, 216), (0, 216)], '#55604f')
    road.rect(0, 186, 383, 196, '#5f7f86'); road.rect(0, 186, 383, 186, '#9fb3ad')
    road.rect(0, 197, 383, 215, '#6b6f1d'); road.rect(0, 200, 383, 206, '#998965')
    slot = far_slot()
    hz = 0.30
    hazed = Image.new('RGBA', slot.size)
    sp, hp = slot.load(), hazed.load()
    haze = hx('#a3a891')
    for y in range(slot.height):
        for x in range(slot.width):
            r, g, b, a = sp[x, y]
            if a:
                hp[x, y] = (round(r + (haze[0] - r) * hz), round(g + (haze[1] - g) * hz), round(b + (haze[2] - b) * hz), 255)
    road.im.alpha_composite(hazed, (236, 108))
    lamp = (236 + 92, 108 + 14)
    for a in range(0, 360, 30):
        road.px(lamp[0] + 3 * math.cos(math.radians(a)), lamp[1] + 3 * math.sin(math.radians(a)), (251, 212, 144, 120))
    road.rect(300, 176, 302, 199, TIMB['mid']); road.rect(297, 172, 305, 177, BRASS['lit'])
    big = road.im.resize((1152, 648), Image.NEAREST)
    out = Image.new('RGBA', (1152, 648 + 420), hx('#16171a'))
    out.alpha_composite(big, (0, 0))
    d = ImageDraw.Draw(out)
    f = font(13)
    d.text((10, 656), 'Road home, 3x: road.backdrop.highbank_far at scale 1.0, haze 0.3 (placement approximate). '
           'Beacon anchor moves to the lamp at slot (92,14).', fill='#e6c697', font=f)
    out.alpha_composite(slot.resize((640, 384), Image.NEAREST), (10, 676))
    d.text((660, 680), 'the 160x96 slot at 4x, unhazed:', fill='#ccb290', font=f)
    d.text((660, 696), 'painted for its own size, 2 px minimum strokes', fill='#ccb290', font=f)
    sil = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    full = Image.alpha_composite(frame, wings)
    blk = Image.new('RGBA', (FW, FH), hx('#e6c697'))
    sil.paste(blk, (0, 0), full.split()[3])
    q = sil.resize((FW // 4, FH // 4), Image.NEAREST)
    t10 = sil.resize((round(FW * 0.1), round(FH * 0.1)), Image.NEAREST)
    out.alpha_composite(q, (700, 730))
    out.alpha_composite(t10, (840, 838))
    d.text((700, 912), 'flat fill at 25%       at 10%', fill='#ccb290', font=f)
    out.save(os.path.join(HERE, 'mock_far_view.png'))


def mock_parts(parts, frame, wings):
    S = 2
    items = []
    items.append(('town.building.hall.key (refs only)', Image.alpha_composite(frame, wings).resize((216, 360), Image.NEAREST), '216x360'))
    for pid, _, _ in BODY_ORDER:
        x, y, w, h = PART[pid]
        items.append((pid, parts[pid], '%dx%d' % (w, h)))
    for pid, _ in GROUND_WINGS:
        x, y, w, h = PART[pid]
        items.append((pid, parts[pid], '%dx%d' % (w, h)))
    lan = Image.new('RGBA', (60, 20), (0, 0, 0, 0))
    for i, s in enumerate(('lit', 'dark', 'quiet')):
        lan.alpha_composite(draw_lantern(s), (i * 20, 0))
    items.append(('town.building.hall.route_lantern (lit, dark, quiet)', lan, '12x20 x7'))
    items.append(('town.prop.hall.wayline_post (strung)', draw_post('strung'), '24x64'))
    items.append(('town.prop.hall.rise_stair', draw_stair(), '48x96'))
    mv = Image.new('RGBA', (60, 16), (0, 0, 0, 0))
    mv.alpha_composite(draw_basket(True), (0, 0)); mv.alpha_composite(draw_cradle(), (22, 1))
    mv.alpha_composite(draw_parcel('a'), (38, 4)); mv.alpha_composite(draw_parcel('b'), (50, 4))
    items.append(('basket 16x16, cradle 12x14, parcel 10x8 x2', mv, 'movers'))
    MAXW, pad = 1500, 18
    f = font(13)
    placed, x, y, rowh = [], pad, pad + 26, 0
    for name, im, size in items:
        w, h = im.width * S, im.height * S + 34
        tw = max(w, 8 * len(name) + 10)
        if x + tw > MAXW:
            x, y, rowh = pad, y + rowh + pad, 0
        placed.append((x, y, name, im, size))
        x += tw + pad
        rowh = max(rowh, h)
    H = y + rowh + pad
    sheet = Image.new('RGBA', (MAXW, H), hx('#1c1d21'))
    d = ImageDraw.Draw(sheet)
    d.text((pad, 8), 'Wayline Tower parts, blockout at 2x (proposal). Each cell is the slot size; dashed box = cell.', fill='#f5d9a8', font=font(15))
    for x, y, name, im, size in placed:
        big = im.resize((im.width * S, im.height * S), Image.NEAREST)
        dashed_rect(d, x - 1, y - 1, x + big.width, y + big.height, '#55575e')
        sheet.alpha_composite(big, (x, y))
        d.text((x, y + big.height + 4), name, fill='#e6c697', font=f)
        d.text((x, y + big.height + 18), size, fill='#9c8c68', font=f)
    sheet.save(os.path.join(HERE, 'mock_parts_sheet.png'))


def report():
    print('frame origin world', FO, 'beacon world', wpt(*BEACON), 'apex world', wpt(183, 1))
    for pid, r in PART.items():
        x, y, w, h = r
        print('%-36s frame (%d,%d) %dx%d  world (%d,%d)' % (pid, x, y, w, h, x + FO[0], y + FO[1]))
    for name, cx, r in (('drum', 216, 108), ('galleries', 200, 84), ('loft', 196, 54)):
        print('shading columns', name, cyl_cols(cx, r))
    for t in LANTERN_T:
        print('sheave', t, tuple(round(v) for v in ring_pt(t, -2)))


if __name__ == '__main__':
    frame, wings, parts = build_frame()
    world = compose_world(frame, wings)
    mock_1x(world)
    mock_3x(world)
    mock_far(frame, wings)
    mock_parts(parts, frame, wings)
    report()
    full = Image.alpha_composite(frame, wings)
    cols = len(set(c for c in full.getdata() if c[3]))
    print('assembled blockout colours:', cols)
