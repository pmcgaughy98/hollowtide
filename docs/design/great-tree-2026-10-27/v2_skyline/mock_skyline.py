"""Reading 1, "the crown on the skyline": mocks for the great tree (working label; the name is Preston's).
Proposal only. Nothing in scripts/, scenes/ or assets/ is touched; this reads the 2026-10-27 build captures and
writes PNGs next to itself.

Preston, 2026-10-27: "like not too far from the town. Like the tree of life kind of like its so great and vasts its at
the center of the forest but its just so big its influence is everywhere around the town."

Placement and size (proposal):
  the great tree stands 320 tiles from the Wayline Tower, N 12 deg W, at the heart of the forest that begins at
  Tower Rise's north hedge. 66 tiles tall (2.2 Towers), crown 150 tiles across (5 Towers, nearly 3 Streets), trunk
  about 17 tiles thick above a buttress flare about 50 across.
Lens (same as the earlier proposal): a thing H tiles tall at d tiles shows H * 960 / d px at 1x.
  title    viewer 178 S of the Tower, d 491: 1.96 px per tile -> 129 px tall, crown 293 px
  vista    viewer 164 S,               d 477: 2.01 px per tile -> 133 px tall, crown 302 px
  hold     camera 40 S at the Tower top, d 353: 2.72 px per tile -> 180 px tall, crown 408 px (overflows 384)
  road far viewer 411 S,               d 724: 1.33 px per tile ->  88 px tall, crown 199 px (not mocked here)
Frame positions are composed (each camera's heading is free); sizes follow the lens.

Run:  python mock_skyline.py      Pixel rules: hard edges, no anti-aliasing, nearest-neighbour 3x.
"""
import importlib.util
import math
import random
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
GT = ROOT + '/docs/design/great-tree-2026-10-27'
OUT = GT + '/v2_skyline'
_spec = importlib.util.spec_from_file_location('final_mocks', GT + '/final/final_mocks.py')
fm = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(fm)  # helpers only; its __main__ block does not run
BUILD = fm.BUILD
FONT = fm.FONT
hx, lum, noise = fm.hx, fm.lum, fm.noise
REPORT = {}

DIST, BEARING_W = 320, 12
H_T, WEST, EAST = 66, 80, 70
LENS = 960
VIEWER = {'title': 178, 'vista': 164, 'hold': 40, 'road_far': 411}


def ppt(view):
    return LENS / (VIEWER[view] + DIST * math.cos(math.radians(BEARING_W)))


def save(img, name):
    img.save(f'{OUT}/{name}_1x.png')
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f'{OUT}/{name}_3x.png')


def hexs(c):
    return '%02x%02x%02x' % c


def colours(img, box=None):
    if box:
        img = img.crop(box)
    return set(img.getdata())


def edges(img, box):
    """Colour changes between neighbours inside a box: a plain measure of how busy an area is."""
    px = img.load()
    x0, y0, x1, y1 = box
    n = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            if x + 1 < x1 and px[x, y] != px[x + 1, y]:
                n += 1
            if y + 1 < y1 and px[x, y] != px[x, y + 1]:
                n += 1
    return n


# ============================================================================================ the great tree
# Shape (proposal, Hollowtide's own): one broad living dome of leaf clumps, wider than it is tall, its west side
# drooping lower than its east (the wind off the river); hanging moss and root curtains under it; a braided trunk
# that splits into a fan of limbs under the crown; crook-shaped buttress roots that hook down like the Reach. No face,
# no lights, no glow. Geometry in tiles, y up from the root flare.

# The crown is nine big rounded masses (x, y, radius in tiles), each built of small clumps: lit along its top,
# shaded under its belly, so the whole crown reads as one rounded living dome and not as stacked bands. The west
# masses droop lower than the east ones. Overall: 80 tiles west of the trunk, 70 east, top at 66.
MASSES = [(-6, 54, 15), (-30, 50, 15), (18, 51, 14), (-54, 41, 14), (40, 47, 12), (-70, 33, 10), (58, 44, 9),
          (-31, 36, 11), (24, 39, 10)]


def crown_bot(x):
    """The crown's underside at x (tiles), or a high value outside it."""
    best = None
    for (mx, my, R) in MASSES:
        if abs(x - mx) < R:
            b = my - 0.8 * R * math.sqrt(1 - ((x - mx) / R) ** 2)
            best = b if best is None else min(best, b)
    return best if best is not None else 99.0


def trunk_hw(y):
    hw = 8.4 - 2.4 * min(1.0, y / 40)
    if y < 9:
        hw += 9.0 * ((9 - y) / 9) ** 2
    return hw


def tree_model(seed=21):
    rnd = random.Random(seed)
    lobes = []
    for (mx, my, R) in sorted(MASSES, key=lambda m: -m[1]):  # top masses first; lower ones overlap their bellies
        cl = []
        for _ in range(int(R * R * 0.3) + 8):
            a, d = rnd.uniform(0, 2 * math.pi), math.sqrt(rnd.random())
            cl.append((mx + d * math.cos(a) * R * 0.84, my + d * math.sin(a) * R * 0.68,
                       rnd.uniform(3.6, 6.0) * (0.75 + 0.25 * R / 15)))
        k = max(4, int(R / 2.0))
        for i in range(k):  # clumps along the mass's upper edge give the lumpy outline
            a = math.pi * (0.04 + 0.92 * i / (k - 1))
            cl.append((mx + math.cos(a) * R * 0.86, my + math.sin(a) * R * 0.66, rnd.uniform(3.4, 5.0)))
        cl.sort(key=lambda c: -c[1])
        lobes += [(x, y, r, (y - my) / (0.8 * R), rnd.uniform(0, 6.28), rnd.uniform(0, 6.28)) for (x, y, r) in cl]
    curtains = []
    for _ in range(80):
        xx = rnd.uniform(-WEST + 4, EAST - 4)
        if abs(xx) < trunk_hw(40) + 5 or crown_bot(xx) > 90:
            continue
        curtains.append((xx, rnd.uniform(2.0, 9.0 if xx < 0 else 5.0)))
    limbs = [(mx, 1.0 if R > 12 else 0.8) for (mx, my, R) in MASSES]
    return dict(lobes=lobes, curtains=curtains, limbs=limbs, holes=[])


MODEL = tree_model()
# buttress roots: (side, height it leaves the trunk, reach, girth), all in tiles. Crook-shaped: out, then hooking down
BUTTRESS = [(-1, 8.5, 25, 2.6), (-1, 4.5, 15, 2.0), (1, 7.5, 22, 2.4), (1, 4.0, 13, 1.9), (-1, 11, 33, 1.9),
            (1, 10, 29, 1.8)]


def render_tree(cx, base_y, p, light=1, lamp_clear=None):
    """Pixel -> role for one view. p = px per tile. light = +1 (sun on the east, right) or -1 (west, left)."""
    R = {}

    def S(x, y):
        return cx + x * p, base_y - y * p

    def setp(X, Y, role):
        R[(int(X), int(Y))] = role

    # 1. buttress roots
    for (side, h0, reach, girth) in BUTTRESS:
        x0 = side * trunk_hw(h0) * 0.7
        n = int(reach * p * 2) + 10
        for k in range(n + 1):
            th = (k / n) * (math.pi / 2) * 1.18  # past straight down: the tip hooks back under, like the crook
            x = x0 + side * reach * math.sin(min(th, math.pi / 2)) - side * 2.5 * max(0.0, th - math.pi / 2)
            y = h0 * math.cos(min(th, math.pi / 2)) - 1.0 * max(0.0, th - math.pi / 2)
            r = max(0.55 / p, girth * (1 - 0.55 * k / n))
            X, Y = S(x, y)
            rr = r * p
            for yy in range(int(Y - rr) - 1, int(Y + rr) + 2):
                for xx in range(int(X - rr) - 1, int(X + rr) + 2):
                    dx, dy = xx - X, yy - Y
                    if dx * dx + dy * dy <= rr * rr + 0.25:
                        u = (dx * light) / max(rr, 0.5)
                        setp(xx, yy, 'trunk_lit' if (dy < -0.3 * rr and u > 0.1) else
                             ('trunk_shade' if (dy > 0.35 * rr or u < -0.5) else 'trunk'))
    # 2. the trunk, braided from three strands
    Ytop, Ybot = S(0, 44)[1], S(0, 0)[1]
    for Y in range(int(Ytop), int(Ybot) + 1):
        y = (base_y - Y) / p
        hw = trunk_hw(y) * p
        xc = cx + 1.0 * math.sin(y * 0.07) * p
        for X in range(int(math.floor(xc - hw)), int(math.ceil(xc + hw)) + 1):
            u = (X - xc) / max(hw, 0.5)
            if abs(u) > 1:
                continue
            role = 'trunk'
            if u * light > 0.68:
                role = 'trunk_lit'
            elif u * light < -0.42:
                role = 'trunk_shade'
            for k in range(3):
                ph = y * 0.15 + k * 2.094
                if math.cos(ph) > -0.2 and abs(u - 0.78 * math.sin(ph)) < 0.6 / max(hw, 1) + 0.035:
                    role = 'trunk_shade'  # the groove between two strands
            if role == 'trunk' and noise(X, int(Y // 3), 11) > 0.84:
                role = 'trunk_shade'  # bark grain, short vertical dashes
            setp(X, Y, role)
    # 3. limbs rising out of the trunk's top into the crown, like a vase, not a flat fan
    for (tx, w) in MODEL['limbs']:
        x0, y0 = 0.25 * tx / 10, 28.0 + abs(tx) * 0.03
        x1, y1 = tx * 0.9, crown_bot(tx) + 7.0
        L = math.hypot((x1 - x0) * p, (y1 - y0) * p)
        n = int(L * 1.5) + 2
        for k in range(n + 1):
            a = k / n
            x = x0 + (x1 - x0) * (a ** 1.25)
            y = y0 + (y1 - y0) * a + 4.0 * math.sin(math.pi * a)
            r = max(0.55, (1.7 - 1.0 * a) * w * p)
            X, Y = S(x, y)
            for yy in range(int(Y - r) - 1, int(Y + r) + 2):
                for xx in range(int(X - r) - 1, int(X + r) + 2):
                    dy = yy - Y
                    if (xx - X) ** 2 + dy * dy <= r * r + 0.25:
                        setp(xx, yy, 'limb_shade' if dy > 0.3 * r else 'limb')
    # 4. curtains: hanging moss and aerial roots, thin and broken
    for (x, ln) in MODEL['curtains']:
        X, Y0 = S(x, crown_bot(x) + 2.0)
        if lamp_clear and lamp_clear(X, Y0 + ln * p):
            continue
        for k in range(int((ln + 2.0) * p)):
            if noise(int(X), k // 3, 9) > 0.86:
                continue
            setp(X, Y0 + k, 'curtain')
    # 5. the clumps
    for (x, y, r, rel, ph1, ph2) in MODEL['lobes']:
        X, Y = S(x, y)
        rr = r * p
        for yy in range(int(Y - rr * 1.15) - 1, int(Y + rr * 1.15) + 2):
            for xx in range(int(X - rr * 1.15) - 1, int(X + rr * 1.15) + 2):
                dx, dy = xx - X, yy - Y
                d = math.hypot(dx, dy)
                th = math.atan2(dy, dx)
                re = rr * (1 + 0.08 * math.sin(5 * th + ph1) + 0.05 * math.sin(9 * th + ph2))
                if d > re:
                    continue
                nx, ny = dx / re, dy / re
                lit = nx * light * 0.5 - ny * 0.87
                rim = lit > 0.45 and d > 0.62 * re          # the clump's sunward top rim
                belly = ny > 0.3 and d > 0.4 * re           # the clump's underside
                if rel > -0.15:   # upper part of its mass: in the light
                    role = 'lit' if rim else ('shade' if belly else 'body')
                elif rel > -0.5:  # middle
                    role = 'shade' if belly else 'body'
                else:             # the mass's belly: in its own shade
                    role = 'body' if rim else ('under' if belly else 'shade')
                # leaf texture: a broken edge between tones, so a clump reads as leaves, not a disc
                if role == 'body' and rel > -0.15 and lit > 0.2 and d > 0.4 * re and noise(xx, yy, 5) > 0.7:
                    role = 'lit'
                elif role == 'body' and ny > 0.12 and noise(xx, yy, 6) > 0.62:
                    role = 'shade'
                elif role == 'shade' and rel < -0.5 and noise(xx, yy, 7) > 0.8:
                    role = 'body'
                setp(xx, yy, role)
    # 6. sky holes in the crown
    for (x, y, r) in MODEL['holes']:
        X, Y = S(x, y)
        rr = max(1.0, r * p)
        for yy in range(int(Y - rr), int(Y + rr) + 1):
            for xx in range(int(X - rr), int(X + rr) + 1):
                if (xx - X) ** 2 + (yy - Y) ** 2 <= rr * rr:
                    R.pop((xx, yy), None)
    return R


# Per view: role -> (colour, colour if the first equals the sky behind). Mossy green crown, warm bark (the Reach's
# own family, hazed), lit only by the day on its sunward clump tops; no glow, no point light.
# Title, golden hour: the sun is low in the west, so the crown's west-facing tops take a warm olive and its bellies
# go cool, the same sage as the far hills (the same haze).
TITLE_CMAP = {'lit': ('908940', '6b6d45'), 'body': ('6b6d45', '4f6858'), 'shade': ('4f6858', '43665a'),
              'under': ('303e37', '1d2925'), 'curtain': ('303e37', '1d2925'), 'limb': ('5d4b34', '3f2716'),
              'limb_shade': ('3f2716', '5d4b34'), 'trunk': ('5d4b34', '3f2716'), 'trunk_lit': ('8e7f5e', '5d4b34'),
              'trunk_shade': ('3f2716', '5d4b34')}
DAWN_CMAP = {'lit': ('979683', '838e87'), 'body': ('748471', '838e87'), 'shade': ('596d6f', '565b40'),
             'under': ('45502d', '565b40'), 'curtain': ('596d6f', '45502d'), 'limb': ('565b40', '45502d'),
             'limb_shade': ('45502d', '565b40'), 'trunk': ('565b40', '45502d'), 'trunk_lit': ('8c8466', '565b40'),
             'trunk_shade': ('45502d', '565b40')}
HOLD_CMAP = dict(DAWN_CMAP, lit=('838e87', '979683'), under=('45502d', '2d3729'), curtain=('45502d', '596d6f'))


def nearest(cands, tgt, exclude=None):
    best, bd = None, 1e18
    for c in cands:
        if c == exclude:
            continue
        d = 3 * (c[0] - tgt[0]) ** 2 + 4 * (c[1] - tgt[1]) ** 2 + 2 * (c[2] - tgt[2]) ** 2
        if d < bd:
            best, bd = c, d
    return best


def paint_tree(img, R, cmap, allowed, bgfn, calm=None):
    """Haze as a fixed, view-wide set of colours (one per role, picked from the view's own palette, hazed by hand
    toward that view's sky), so the crown is one even living thing and does not stripe with the sky bands. Where a
    role's colour equals the sky right behind it, its second colour is used so the silhouette always reads."""
    px = img.load()
    W, H = img.size
    box = [999, 999, -1, -1]
    n, tl, bl = 0, 0.0, 0.0
    for (X, Y), role in R.items():
        if not (0 <= X < W and 0 <= Y < H) or not allowed(X, Y):
            continue
        if calm and calm(X, Y):
            role = {'lit': 'body', 'curtain': 'shade'}.get(role, role)
        bg = bgfn(X, Y)
        a, b = cmap[role]
        c = hx(a) if hx(a) != bg else hx(b)
        px[X, Y] = c
        n += 1
        tl += lum(c)
        bl += lum(bg)
        box = [min(box[0], X), min(box[1], Y), max(box[2], X), max(box[3], Y)]
    return dict(box=box, painted=n, tree_lum=round(tl / max(1, n)), sky_behind_lum=round(bl / max(1, n)))


def treeline(img, skyline, x0, x1, peak_x, peak_h, base_h, cols, allowed, seed=4):
    """The forest on the far skyline: rounded canopy bumps standing on it, taller toward the great tree's foot, so
    the trunk goes down into the forest's middle. cols = (top, body)."""
    px = img.load()
    rnd = random.Random(seed)
    x = x0
    while x < x1:
        r = rnd.uniform(1.6, 3.2)
        h = base_h + (peak_h - base_h) * max(0.0, 1 - abs(x - peak_x) / 70.0) + rnd.uniform(-1, 1)
        top = skyline[int(min(max(x, 0), len(skyline) - 1))] - h
        for yy in range(int(top - r), int(skyline[int(min(max(x, 0), len(skyline) - 1))]) + 1):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if not (0 <= xx < img.width and 0 <= yy < img.height) or not allowed(xx, yy):
                    continue
                if yy >= skyline[xx]:
                    continue
                dy = max(0.0, top - yy)
                if (xx - x) ** 2 + (dy * 1.3) ** 2 <= r * r or yy >= top:
                    px[xx, yy] = hx(cols[0]) if (yy < top - r * 0.4 and noise(xx, yy, 1) > 0.5) else hx(cols[1])
        x += r * rnd.uniform(1.1, 1.6)


# ============================================================================================ 1. title
TITLE_SKY = ('1e302e', '263d3a', '33524e', '43665a', '61785c', '9f946d', 'dca562', '192726')
TITLE_TREE = ('1d2925', '263d3a', '303e37', '33524e', '43665a', '4f6858', '61785c', '5f5e57', '5d4b34', '6b6d45',
              '44421a', '8e7f5e', '9f946d', '3f2716', '663f23')
WORDMARK = (90, 0, 296, 53)
MENU = (21, 108, 129, 200)


def mock_title():
    img = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    sky = {hx(c) for c in TITLE_SKY}
    skyline = fm.skyline_of(src, sky, 95)
    dom = fm.row_sky(src, sky, 110, 270)
    clouds = fm.cloud_mask(src, sky, dom)

    def in_box(b, x, y):
        return b[0] <= x < b[2] and b[1] <= y < b[3]

    def allowed(x, y):
        return (orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and not in_box(MENU, x, y)
                and not (x >= 312 and y < 50) and x < 298)

    p = ppt('title')
    R = render_tree(cx=150, base_y=144, p=p, light=-1)
    # calm under the wordmark: no lit rims or curtains above y 56, across the whole width (no seam at the box edge)
    st = paint_tree(img, R, TITLE_CMAP, allowed, lambda x, y: orig[x, y],
                    calm=lambda x, y: y < 50 or (y < 64 and noise(x, y, 13) > (y - 50) / 14.0))
    # the forest on the far hills, rising toward the tree's foot (the dip, where the trunk goes down into it)
    tl_ok = lambda x, y: not in_box(MENU, x, y) and orig[x, y] in sky and (x, y) not in clouds
    treeline(img, skyline, 131, 298, 168, 9, 2, ('4f6858', '4f6858'), tl_ok)
    # the Tower's root: a faint seam with surfaced humps through the ridge woods, the dip to the Tower's west foot
    woods = {hx('303e37'), hx('1d2925')}
    fm.root_road(img, [(172, 122), (190, 128), (210, 135), (232, 143), (252, 150), (268, 156), (279, 162)],
                 [(0.08, 0.22), (0.38, 0.54), (0.72, 0.9)], lambda x, y: 1.2 + 0.03 * (y - 120),
                 dict(crest='43665a', crest_lit='61785c', bark='33524e', lit='61785c', dark='263d3a',
                      contact='1e302e', trail='33524e'),
                 lambda x, y: orig[x, y] in woods and x < 280 and y > 119,
                 seam=lambda c: hx('303e37') if c == hx('1d2925') else c)
    # roots reaching the river: three spill over the bluff wall into the water (the town sits on its drinking roots)
    px = img.load()
    for (x0, w0, seed) in ((153, 3, 1), (213, 4, 2), (258, 3, 3)):
        bluff_root(px, x0, 186, 204, w0, seed)
    save(img, 'title')
    a, b = src.load(), img.load()
    changed = [(x, y) for y in range(H) for x in range(W) if a[x, y] != b[x, y]]
    REPORT['title'] = dict(**st, crown_w=round(150 * p), tree_h=round(H_T * p), px_per_tile=round(p, 2),
                           changed=len(changed),
                           in_menu=sum(1 for x, y in changed if in_box(MENU, x, y)),
                           in_shade_box=sum(1 for x, y in changed if x >= 312 and y < 50),
                           wordmark_edges_before=edges(src, WORDMARK), wordmark_edges_after=edges(img, WORDMARK),
                           wordmark_colours_after=len(colours(img, WORDMARK)),
                           colours_before=len(colours(src)), colours_after=len(colours(img)),
                           new_colours=sorted(hexs(c) for c in colours(img) - colours(src)))


def bluff_root(px, x0, y0, y1, w0, seed):
    """A root spilling over the bluff wall into the river, seen from across the water: a moss lip where it comes over
    the edge, thick at the top and tapering, lit on its west side, one branch splitting off, rootlets gripping the
    stones, and a ripple where it goes in."""
    def strand(xs, ya, yb, wa, wb, drift):
        for y in range(ya, yb + 1):
            f = (y - ya) / max(1, yb - ya)
            w = max(1, int(round(wa * (1 - f) + wb * f)))
            x = xs + int(round(drift * f + 0.8 * math.sin(f * 5 + seed)))
            for j in range(w):
                c = 'b06b3d' if j == 0 else ('3f2716' if j == w - 1 else '663f23')
                if w == 1:
                    c = '663f23'
                if y >= 202:
                    c = '3f2716' if j else '663f23'
                px[x + j, y] = hx(c)
        return xs + int(round(drift))
    end = strand(x0, y0, y1, w0, 1, -1 + seed % 3)
    strand(x0 + w0 - 1, y0 + 4, y1 - 3, 2, 1, 3 if seed % 2 else -3)
    for k in (5, 11):
        px[x0 - 1, y0 + k] = hx('663f23')
        px[x0 + w0, y0 + k + 2] = hx('3f2716')
    for dx in range(-1, w0 + 1):
        px[x0 + dx, y0 - 1] = hx('6b6f1d' if dx % 2 else '908940')
    for dx in (-2, -1, 1, 2):
        px[end + dx, 206] = hx('2d9e9f')


# ============================================================================================ 2. vista
VISTA_TREE = ('56708e', '6a84a0', '879db0', 'a9b5ba', 'cdc6b4', '58708b', '66899d', '7a95a5', '596d6f', '758789',
              '7f9394', '838e87', '748471', '878b7c', '979683', '8c8466', '565b40', '45502d', 'a0adb0', '7a8993')


def mock_vista():
    img = fm.load_3x(f'{BUILD}/round2/13_road_vista.png')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    sky = {orig[x, y] for x in range(60, 220) for y in range(0, 117)} - {hx('a3b0ae'), hx('b8c2bc')}
    skyline = fm.skyline_of(src, sky, 50)
    dom = fm.row_sky(src, sky, 60, 220)
    clouds = fm.cloud_mask(src, sky, dom)

    def allowed(x, y):
        return orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and x < 224

    p = ppt('vista')
    R = render_tree(cx=78, base_y=146, p=p, light=1)
    st = paint_tree(img, R, DAWN_CMAP, allowed, lambda x, y: orig[x, y])
    tl_ok = lambda x, y: orig[x, y] in sky and (x, y) not in clouds and x < 224
    treeline(img, skyline, 0, 224, 80, 8, 2, ('b8c2bc', 'a3b0ae'), tl_ok, seed=6)
    land = {hx(c) for c in ('6f8455', 'a3b0ae', '7f9467', '93a77a', 'b8c2bc', '6a8848', '4b6634', '3e5629')}
    darker = {'a3b0ae': '7f9467', 'b8c2bc': 'a3b0ae', '7f9467': '6f8455', '93a77a': '7f9467', '6f8455': '4b6634',
              '6a8848': '4b6634', '4b6634': '3e5629', '3e5629': '3e5629'}
    # the Tower's root comes over the far hills from the tree's foot and down the open slope to the Tower's west foot
    fm.root_road(img, [(96, 121), (114, 134), (136, 148), (158, 161), (180, 173), (203, 183), (222, 189), (236, 186)],
                 [(0.03, 0.12), (0.2, 0.31), (0.39, 0.5), (0.58, 0.69), (0.77, 0.87), (0.93, 1.0)],
                 lambda x, y: 0.8 + 0.04 * (y - 121),
                 dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23',
                      contact='3e5629', trail='ccb290'),
                 lambda x, y: orig[x, y] in land,
                 seam=lambda c: hx(darker.get(hexs(c), hexs(c))))
    # a second root surfacing under the party's slope: the roots run under everything, not only the Tower's
    fm.root_road(img, [(20, 181), (60, 192), (104, 199), (150, 204), (190, 211)],
                 [(0.05, 0.3), (0.55, 0.82)], lambda x, y: 2.2,
                 dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23',
                      contact='3e5629', trail='4b6634'),
                 lambda x, y: orig[x, y] in land and not (70 <= x <= 145 and y < 180),
                 seam=lambda c: hx(darker.get(hexs(c), hexs(c))))
    save(img, 'vista')
    dawn = palette('dawn')
    REPORT['vista'] = dict(**st, crown_w=round(150 * p), tree_h=round(H_T * p), px_per_tile=round(p, 2),
                           colours_before=len(colours(src)), colours_after=len(colours(img)),
                           new_not_in_dawn_or_frame=sorted(hexs(c) for c in colours(img) - colours(src) - dawn))


def palette(name):
    im = Image.open(f'{ROOT}/docs/design/placeholder-factory-2026-10-26/refs/palettes/{name}.png').convert('RGB')
    return set(im.getdata())


# ============================================================================================ 3. reveal hold
HZ = 120
FOREST = ['979683', '878b7c', '838e87', '748471', '6f8455', '59753c', '4b6731', '3d542b', '2d3729']


def forest_band(y):
    """Land colour by row: hazed near the horizon, greener and darker nearer (lower)."""
    stops = [(121, 0), (124, 1), (129, 2), (136, 3), (148, 4), (165, 5), (186, 6), (204, 7)]
    i = 0
    for k, (y0, j) in enumerate(stops):
        if y >= y0:
            i = j
    return i


def build_hold_backdrop():
    W, H = 384, 216
    img = Image.new('RGB', (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            if y < HZ:
                px[x, y] = hx(fm.SKY_BANDS[fm.band_at(fm.SKY_BANDS, x, y)][1])
            else:
                i = forest_band(y)
                if y in (124, 129, 136, 148, 165, 186, 204) and (x + y) % 2 == 0:
                    i = max(0, i - 1)
                px[x, y] = hx(FOREST[i])
    rnd = random.Random(12)
    # the forest from above: ordinary crowns, tiny next to the great tree, bigger lower down (nearer)
    for _ in range(1500):
        y = rnd.uniform(HZ + 2, H + 4)
        s = (y - HZ) / 96.0
        r = 0.6 + 3.2 * s * s + rnd.uniform(0, 0.8 * s)
        x = rnd.uniform(-4, W + 4)
        i = forest_band(int(min(H - 1, y)))
        dark = hx(FOREST[min(len(FOREST) - 1, i + 1)])
        lite = hx(FOREST[max(0, i - 1)])
        for yy in range(int(y - r), int(y + r * 0.6) + 1):
            for xx in range(int(x - r), int(x + r) + 1):
                if 0 <= xx < W and HZ + 1 <= yy < H and ((xx - x) / r) ** 2 + ((yy - y) / (0.7 * r)) ** 2 <= 1:
                    px[xx, yy] = lite if (yy < y - 0.35 * r and xx > x - 0.2 * r and r > 1.2) else dark
    # mist banks under the eye: we are above them
    for (y, x0, x1) in ((140, 120, 300), (141, 100, 330), (158, 230, 384), (159, 250, 384), (176, 60, 200),
                        (177, 40, 180)):
        for x in range(x0, x1):
            if (x * 7 + y) % 19 != 0:
                px[x, y] = hx('c2d4df' if y in (140, 158, 176) else 'a0adb0')
    # roots radiating from the tree's foot: where they surface the forest parts in long rides
    seam = lambda c: hx(FOREST[min(len(FOREST) - 1, FOREST.index(hexs(c)) + 1)]) if hexs(c) in FOREST else c
    rcols = dict(crest='6f8455', crest_lit='979683', bark='8c6545', lit='b06b3d', dark='565b40', contact='2d3729',
                 trail='979683')
    fm.root_road(img, [(52, 197), (130, 182), (210, 166), (300, 150), (384, 140)],
                 [(0.04, 0.2), (0.36, 0.5), (0.66, 0.78)], lambda x, y: max(0.5, 0.03 * (y - HZ)), rcols,
                 lambda x, y: y > HZ, seam=seam)
    fm.root_road(img, [(50, 203), (150, 205), (250, 207), (384, 209)],
                 [(0.1, 0.3), (0.5, 0.64), (0.82, 0.95)], lambda x, y: max(0.5, 0.03 * (y - HZ)), rcols,
                 lambda x, y: y > HZ, seam=seam)
    # the Tower's root, toward us: out of the frame's bottom, under the reveal
    fm.root_road(img, [(46, 205), (70, 210), (92, 216)], [(0.0, 1.0)], lambda x, y: 2.6, rcols,
                 lambda x, y: y > HZ, seam=seam)
    # the great tree, left of the crook; its crown overflows the frame, the lamp side stays clear of curtains
    p = ppt('hold')
    lamp = lambda x, y: 150 <= x <= 240 and y > 92
    R = render_tree(cx=20, base_y=199, p=p, light=1, lamp_clear=lamp)
    src = img.copy()
    sp = src.load()
    st = paint_tree(img, R, HOLD_CMAP, lambda x, y: True, lambda x, y: sp[x, y])
    # ordinary forest in front of its foot: the buttress roots stand above the canopy, the trunk goes down into it
    for _ in range(140):
        x = rnd.uniform(-10, 120)
        y = rnd.uniform(193, 214)
        r = rnd.uniform(1.8, 3.4)
        for yy in range(int(y - r), int(y + r * 0.6) + 1):
            for xx in range(int(x - r), int(x + r) + 1):
                if 0 <= xx < W and yy < H and ((xx - x) / r) ** 2 + ((yy - y) / (0.7 * r)) ** 2 <= 1:
                    px[xx, yy] = hx('59753c' if yy < y - 0.35 * r else '4b6731')
    # a cloud strip crossing the trunk well below the crown: the tree stands taller than the weather
    for (y, x0, x1) in ((150, 0, 118), (151, 8, 104), (152, 20, 90)):
        for x in range(x0, x1):
            if (x * 5 + y) % 17 != 0:
                px[x, y] = hx('c2b58f' if y != 152 else 'a3a891')
    # two birds below the eye
    for (bx, by) in ((262, 168), (273, 163)):
        for (dx, dy) in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            px[bx + dx, by + dy] = hx('2d3729')
    return img, dict(**st, crown_w=round(150 * p), tree_h=round(H_T * p), px_per_tile=round(p, 2),
                     backdrop_colours=len(colours(img)))


def mock_hold():
    bd, st = build_hold_backdrop()
    save(bd, 'hold_backdrop')
    img = fm.load_3x(f'{BUILD}/round2/11_reveal_hold_top.png')
    src = img.copy().load()
    px = img.load()
    bp = bd.load()
    bgc = {hx(c) for c in fm.PLACEHOLDER_SKY}
    glow = {hx(c) for c in fm.GLOW}
    light = (236, 232, 208)
    pal = colours(bd) | {hx(c) for c in fm.GLOW}
    for y in range(img.height):
        for x in range(img.width):
            c = src[x, y]
            if c in bgc:
                px[x, y] = bp[x, y]
            elif c in glow:  # the lamp's glow, rebuilt over whatever is behind it now
                k = 0.42 if lum(c) > 165 else 0.22
                b = bp[x, y]
                px[x, y] = nearest(pal, tuple(b[i] * (1 - k) + light[i] * k for i in range(3)))
    save(img, 'hold')
    REPORT['hold'] = st


# ============================================================================================ 4. influence sheet
ROOTC = dict(lit='c49b69', body='b06b3d', knot='ad693c', dark='663f23', shadow='3f2716', line='181412',
             moss='908940', moss_dark='6b6f1d')


def ground_root(img, pts, r0, r1, bury=-0.38, allowed=lambda x, y: True, seed=3, crack='2a1a0f', heave=True,
                surf=(0.0, 1.0)):
    """A root lying in the ground, top-down, in the climbing root's own style: dark outline on its far edge, warm bark
    with grain along it, a lit far edge, moss in loose patches. Its near side runs under the ground (paving or flags
    heaved up around it: a crack line on both sides and the stones beside it tilted into the light). Outside surf
    (fractions of its length) it runs under the ground and only the heaved seam shows."""
    px = img.load()
    W, H = img.size
    S = fm.catmull([(x, y, 0) for x, y in pts], 40)
    T, along = fm.frame_of(S)
    L = along[-1]
    rnd = random.Random(seed)
    best = {}
    for i, (x, y, _) in enumerate(S):
        r = r0 + (r1 - r0) * along[i] / L
        nx, ny = -T[i][1], T[i][0]
        if ny > 0:
            nx, ny = -nx, -ny
        Rr = int(r) + 5
        for yy in range(int(y) - Rr, int(y) + Rr + 1):
            for xx in range(int(x) - Rr, int(x) + Rr + 1):
                dx, dy = xx - x, yy - y
                q = math.hypot(dx, dy) / r
                if q > 1 + 3.0 / r:
                    continue
                cur = best.get((xx, yy))
                if cur is None or q < cur[0]:
                    best[(xx, yy)] = (q, (dx * nx + dy * ny) / r, along[i] + dx * T[i][0] + dy * T[i][1], r)
    blobs = []
    s = 4.0
    while s < L:
        blobs.append((s, rnd.uniform(0.1, 0.5), rnd.uniform(3, 7), rnd.uniform(0.2, 0.35)))
        s += rnd.uniform(10, 20)
    orig = img.copy().load()
    for (xx, yy), (q, u, s, r) in best.items():
        if not (0 <= xx < W and 0 <= yy < H) or not allowed(xx, yy):
            continue
        b = bury - 0.12 * noise(int(s // 3), 3, seed)
        fs = s / L
        spans = surf if isinstance(surf[0], tuple) else [surf]
        gap = min(0.0 if a <= fs <= c else min(abs(fs - a), abs(fs - c)) for (a, c) in spans)
        if gap > 0:  # it dives: narrowing into the ground, then only the seam of heaved stones shows
            b = min(1.6, b + gap / 0.06 * 1.6)
        if q > 1.0:
            if heave and q <= 1 + 1.0 / r and noise(int(s), int(u * 4), seed) > 0.25:
                px[xx, yy] = hx(crack)
            elif heave and u > 0 and q <= 1 + 2.6 / r:
                c = orig[xx, yy]
                px[xx, yy] = tuple(min(255, int(v * 1.12)) for v in c)
            continue
        if u < b:
            if u > b - 0.16:
                px[xx, yy] = hx(crack)
            continue
        if q > 1 - 1.0 / r and u > 0:
            c = ROOTC['line']
        elif u > 0.62:
            c = ROOTC['lit']
        else:
            c = ROOTC['body']
            g = noise(int(s // 6), int((u + 1) * 4), seed)
            if g > 0.72:
                c = ROOTC['knot']
            elif g < 0.2:
                c = ROOTC['dark']
            if u < b + 0.14:
                c = ROOTC['dark']
            for (sc, uc, rs, ru) in blobs:
                if ((s - sc) / rs) ** 2 + ((u - uc) / ru) ** 2 < 0.8 + 0.3 * noise(int(s), int(u * 9), 6):
                    c = ROOTC['moss'] if u > uc + 0.06 else ROOTC['moss_dark']
        px[xx, yy] = hx(c)


# the great tree's leaf (proposal): broad and round with a notch at the top, bigger than any town tree's leaf
LEAF = ['..eee..', '.ebbbe.', 'ebbbmbe', 'ebbmbbe', 'ebmbbe.', '.eebe..', '.s.....']  # broad oval, stem low
SEED = ['f.f.f', '.fff.', 'ffsff', '.fff.', 'f.f.f']   # a seed tuft drifting on the wind


def stamp(img, x, y, rows, cmap, flip=False, shadow=None):
    px = img.load()
    for j, row in enumerate(rows):
        if flip:
            row = row[::-1]
        for i, ch in enumerate(row):
            if ch == '.':
                continue
            X, Y = x + i, y + j
            if shadow and 0 <= X + 1 < img.width and 0 <= Y + 2 < img.height:
                c = px[X + 1, Y + 2]
                px[X + 1, Y + 2] = tuple(int(v * 0.62) for v in c)
    for j, row in enumerate(rows):
        if flip:
            row = row[::-1]
        for i, ch in enumerate(row):
            if ch != '.' and 0 <= x + i < img.width and 0 <= y + j < img.height:
                px[x + i, y + j] = hx(cmap[ch])


GREEN_LEAF = dict(e='6b6f1d', b='908940', m='c6bb2a', s='663f23')
GOLD_LEAF = dict(e='a37a32', b='d4a94c', m='f2d27a', s='663f23')
SEED_C = dict(f='f5d9a8', s='663f23')


def is_grass(c):
    r, g, b = c
    return g > r + 4 and g > b + 10


def dapple(img, box, seed=8, k=0.7):
    """Evening shade from the forest edge west of the Rise: leaf shadows on the grass with sun flecks through them."""
    px = img.load()
    rnd = random.Random(seed)
    x0, y0, x1, y1 = box
    blots = [(rnd.uniform(x0, x1), rnd.uniform(y0, y1), rnd.uniform(5, 13), rnd.uniform(3, 7)) for _ in range(16)]
    for y in range(y0, y1):
        for x in range(x0, x1):
            inside = any(((x - bx) / rx) ** 2 + ((y - by) / ry) ** 2 <= 1 for (bx, by, rx, ry) in blots)
            if inside and noise(x // 2, y // 2, seed) > 0.12 and is_grass(px[x, y]):
                px[x, y] = tuple(int(v * k) for v in px[x, y])


def vignette_street():
    img = fm.load_3x(f'{BUILD}/round2/06_street_wayline.png')
    orig = img.copy().load()
    line = {hx('f2d27a'), hx('ddca86')}
    # a sister root of the Tower's comes under the north grass, heaves the Crossroads paving up through it and dives
    # under again; the waymark post and the partner stand on it (drawn in front)
    stand = [(156, 80, 182, 150), (176, 72, 210, 113)]
    ok = lambda x, y: orig[x, y] not in line and not any(a <= x < c and b <= y < d for (a, b, c, d) in stand)
    ground_root(img, [(84, 50), (110, 60), (134, 76), (160, 86), (190, 98), (214, 112), (240, 118), (266, 120),
                      (292, 128)], 7.0, 5.5, allowed=ok, seed=4, surf=((0.16, 0.4), (0.6, 0.82)))
    for (x, y, cm, fl) in ((122, 104, GOLD_LEAF, False), (236, 84, GREEN_LEAF, True), (212, 132, GOLD_LEAF, False)):
        stamp(img, x, y, LEAF, cm, fl)
    return img.crop((88, 36, 280, 144))


def vignette_rise():
    img = Image.open(f'{GT}/final/final_rise_root_1x.png').convert('RGB')
    dapple(img, (0, 100, 128, 208))
    for (x, y, cm, fl) in ((22, 118, GOLD_LEAF, False), (70, 150, GREEN_LEAF, True), (14, 178, GOLD_LEAF, True),
                           (104, 132, GREEN_LEAF, False), (48, 196, GOLD_LEAF, False)):
        stamp(img, x, y, LEAF, cm, fl)
    return img.crop((0, 100, 192, 208))


def vignette_ferry():
    img = fm.load_3x(f'{BUILD}/round2/07_ferry_ward_quiet_wayline.png')
    orig = img.copy().load()
    line = {hx('f2d27a'), hx('ddca86')}
    ok = lambda x, y: orig[x, y] not in line
    # two roots come down from the bluff, part around the Mouth and keep their distance from it (the Hollow is
    # absence: nothing living grows into it), then go down between the posts into the river
    ground_root(img, [(164, 38), (157, 62), (155, 86), (163, 108), (171, 128), (174, 152)], 6.5, 4.0, allowed=ok,
                seed=5, crack='3f2a19')
    ground_root(img, [(226, 38), (233, 62), (234, 86), (224, 108), (213, 128), (210, 152)], 6.0, 3.8, allowed=ok,
                seed=6, crack='3f2a19')
    px = img.load()
    for (x, y) in ((168, 149), (177, 151), (206, 150), (214, 152), (171, 153), (211, 154)):  # ripples
        for dx in range(3):
            if 0 <= x + dx < img.width and y < img.height:
                px[x + dx, y] = hx('a9d4d6')
    stamp(img, 252, 70, LEAF, GOLD_LEAF)
    return img.crop((140, 46, 332, 154))


def vignette_air():
    img = fm.load_3x(f'{BUILD}/round2/06_street_wayline.png')
    # fallen: gathered against the paving's edge and in the grass
    for (x, y, cm, fl) in ((210, 58, GREEN_LEAF, False), (302, 94, GOLD_LEAF, True), (340, 120, GREEN_LEAF, True),
                           (248, 132, GOLD_LEAF, False), (230, 104, GOLD_LEAF, True), (318, 126, GOLD_LEAF, False),
                           (370, 104, GREEN_LEAF, False)):
        stamp(img, x, y, LEAF, cm, fl)
    # in the air: leaves and seed tufts, each throwing a shadow a little below it
    for (x, y, cm, fl) in ((268, 56, GREEN_LEAF, True), (316, 70, GOLD_LEAF, False), (232, 84, GREEN_LEAF, False)):
        stamp(img, x, y, LEAF, cm, fl, shadow=True)
    for (x, y) in ((246, 44), (288, 80), (352, 92), (264, 112), (330, 48)):
        stamp(img, x, y, SEED, SEED_C, shadow=True)
    return img.crop((192, 36, 384, 144))


def mock_influence():
    cells = [('STREET: A ROOT HEAVES THE CROSSROADS PAVING, SURFACES AND DIVES UNDER AGAIN', vignette_street()),
             ("RISE WEST LANE: THE TOWER'S ROOT COMES IN FROM THE FOREST. ITS LEAVES, EVENING DAPPLE",
              vignette_rise()),
             ('FERRY WARD: TWO ROOTS PART AROUND THE MOUTH, NEVER INTO IT, AND DRINK THE RIVER', vignette_ferry()),
             ('STREET: ITS LEAVES AND SEED TUFTS COME IN ON THE NORTH WIND', vignette_air())]
    M, CW, CH, CAP = 4, 192, 108, 28
    W = 2 * CW + 3 * M
    H = 12 + 2 * (CAP + CH) + 3 * M
    img = Image.new('RGB', (W, H), hx('1a1410'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    d.text((M, 2), 'THE GREAT TREE IN TOWN (PROPOSALS)', font=f, fill=hx('f0d696'))
    for i, (cap, im) in enumerate(cells):
        x = M + (i % 2) * (CW + M)
        y = 12 + M + (i // 2) * (CAP + CH + M)
        lines, cur = [], ''
        for w in cap.split():
            t = (cur + ' ' + w).strip()
            if d.textlength(t, font=f) <= CW:
                cur = t
            else:
                lines.append(cur)
                cur = w
        lines.append(cur)
        assert len(lines) <= 3, cap
        for j, s in enumerate(lines):
            d.text((x, y + j * 9), s, font=f, fill=hx('be9c62'))
        img.paste(im, (x, y + CAP))
    save(img, 'influence')
    REPORT['influence'] = dict(size=img.size)


# ============================================================================================ 5. map
def mock_map():
    W, H = 420, 300
    img = Image.new('RGB', (W, H), hx('e6c697'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    ink, faint, rootc, water, panel = hx('3f2716'), hx('a37a32'), hx('7c4a26'), hx('07515c'), hx('f5d9a8')
    leaf_d, leaf, leaf_l = hx('44421a'), hx('6b6d45'), hx('908940')

    def text(x, y, s, c=ink, knock=True):
        if knock:
            w = d.textlength(s, font=f)
            d.rectangle((x - 1, y, x + w, y + 8), fill=panel)
        d.text((x, y), s, font=f, fill=c)

    # --- region panel, 1 px = 4 tiles; tile origin at the trunk
    PX0, PY0, PX1, PY1 = 3, 11, 243, 240
    d.rectangle((PX0, PY0, PX1, PY1), fill=panel, outline=faint)
    text(4, 1, 'REGION, 1 PX = 4 TILES', knock=False)
    TX, TY = 118, 98   # the trunk on the map

    def M(tx, ty):  # tiles east, tiles south of the trunk -> map px
        return TX + tx / 4.0, TY + ty / 4.0

    tower = M(320 * math.sin(math.radians(BEARING_W)), 320 * math.cos(math.radians(BEARING_W)))  # (16.6, 78.3)
    rise_n = tower[1] - 2          # the Rise's north hedge, about 8 tiles north of the Tower's base
    river_y = tower[1] + 10        # the river, about 40 tiles south of the Tower
    rnd = random.Random(9)

    def in_forest(x, y):
        dx, dy = x - TX, y - TY
        a = math.atan2(dy, dx)
        r = 84 + 7 * math.sin(3 * a + 0.6) + 5 * math.sin(5 * a + 1.9)
        if math.hypot(dx, dy) > r:
            return False
        if y > rise_n and abs(x - tower[0]) < 14:  # Highbank sits at its south edge
            return False
        if y > river_y - 1:
            return False
        return True

    # forest: a light wash, then tree dots, denser toward its heart
    for y in range(PY0 + 1, PY1):
        for x in range(PX0 + 1, PX1):
            if (x + 2 * y) % 4 == 0 and in_forest(x, y):
                img.putpixel((x, y), hx('ccb290'))
    for _ in range(9000):
        x, y = rnd.uniform(PX0 + 2, PX1 - 2), rnd.uniform(PY0 + 2, PY1 - 2)
        if not in_forest(x, y):
            continue
        dd = math.hypot(x - TX, y - TY) / 90
        if rnd.random() < 0.25 + 0.75 * (1 - dd):
            img.putpixel((int(x), int(y)), leaf if rnd.random() < 0.6 else leaf_l)
            if rnd.random() < 0.35:
                img.putpixel((int(x) + 1, int(y) + 1), leaf_d)
    # forest edge, dotted
    for k in range(720):
        a = k / 720 * 2 * math.pi
        r = 84 + 7 * math.sin(3 * a + 0.6) + 5 * math.sin(5 * a + 1.9)
        x, y = TX + r * math.cos(a), TY + r * math.sin(a)
        if k % 3 and PX0 < x < PX1 and PY0 < y < PY1 and y < river_y - 1:
            img.putpixel((int(x), int(y)), leaf_d)
    # springs among the roots
    for _ in range(18):
        x, y = rnd.uniform(40, 200), rnd.uniform(40, 170)
        if in_forest(x, y) and math.hypot(x - TX, y - TY) > 24:
            d.rectangle((int(x), int(y), int(x) + 1, int(y)), fill=hx('2d9e9f'))
    # the river
    riv = [(PX0 + 1, river_y + 4), (60, river_y + 1), (110, river_y + 2), (tower[0], river_y), (190, river_y + 3),
           (PX1 - 1, river_y + 1)]
    for (x, y, _) in fm.catmull([(x, y, 0) for x, y in riv], 40):
        for k in range(3):
            img.putpixel((int(x + 0.5), int(y + 0.5) + k), hx('2d9e9f') if k < 2 else hx('12837f'))
    # roots radiating from the tree: surfaced (solid) and underground (dotted)
    rnd2 = random.Random(3)
    tips = []
    for k in range(13):
        a = -math.pi / 2 + k * 2 * math.pi / 13 + rnd2.uniform(-0.12, 0.12)
        tips.append(a)
    for a in tips:
        L = rnd2.uniform(70, 96)
        pts = []
        for j in range(7):
            rr = 10 + (L - 10) * j / 6
            aa = a + 0.18 * math.sin(j * 1.3 + a * 3)
            pts.append((TX + rr * math.cos(aa), TY + rr * math.sin(aa)))
        S = fm.catmull([(x, y, 0) for x, y in pts], 20)
        for i, (x, y, _) in enumerate(S):
            f_ = i / (len(S) - 1)
            if not (PX0 < x < PX1 - 1 and PY0 < y < PY1 - 1):
                continue
            surfaced = noise(int(f_ * 9), int(a * 10), 2) > 0.55
            if surfaced:
                img.putpixel((int(x), int(y)), rootc)
            elif i % 3 == 0:
                img.putpixel((int(x), int(y)), hx('a37a32'))
    # the Tower's root: south from the trunk, then in from the west under the forest edge to the Rise's west lane
    troot = [M(-4, 14), M(-14, 90), M(-6, 170), M(-20, 240), M(-14, 290), (tower[0] - 6, tower[1] - 1),
             (tower[0] - 1, tower[1])]
    S = fm.catmull([(x, y, 0) for x, y in troot], 30)
    for i, (x, y, _) in enumerate(S):
        f_ = i / (len(S) - 1)
        surfaced = (int(f_ * 12) % 3 == 0) or f_ > 0.9
        if surfaced:
            d.rectangle((int(x), int(y), int(x) + 1, int(y) + 1), fill=hx('b06b3d'))
        elif i % 3 == 0:
            d.rectangle((int(x), int(y), int(x) + 1, int(y)), fill=hx('663f23'))
    # the tree from above: crown 150 tiles across = 37 px, as clumps lit from the south-east; trunk about 17 = 4 px
    rnd3 = random.Random(5)
    blobs = []
    for _ in range(40):
        a, r = rnd3.uniform(0, 2 * math.pi), 15 * math.sqrt(rnd3.random())
        blobs.append((TX - 1.2 + r * math.cos(a), TY + r * math.sin(a) * 0.95, rnd3.uniform(2.6, 4.4)))
    blobs.sort(key=lambda b: b[1])
    for (bx, by, br) in blobs:
        d.ellipse((bx - br - 1, by - br + 1, bx + br - 1, by + br + 1), fill=leaf_d)
    for (bx, by, br) in blobs:
        d.ellipse((bx - br, by - br, bx + br, by + br), fill=leaf)
        d.ellipse((bx - br * 0.2, by - br * 0.2, bx + br * 0.7, by + br * 0.7), fill=leaf_l)
    d.ellipse((TX - 2, TY - 2, TX + 2, TY + 2), outline=ink)
    # Highbank, to scale: about 22 x 12 px
    hx0, hy0 = tower[0] - 12, tower[1] - 2
    d.rectangle((hx0, hy0, hx0 + 22, hy0 + 11), fill=hx('c7a378'), outline=ink)
    d.rectangle((int(tower[0]) - 1, int(tower[1]) - 1, int(tower[0]), int(tower[1])), fill=ink)
    img.putpixel((int(tower[0]), int(tower[1]) - 2), hx('f2d27a'))
    # the far-bank viewpoints (title 178 tiles south of the Tower, vista 164), looking north at the tree
    for (name, dy, lx) in (('TITLE', 178, 4), ('VISTA', 164, -34)):
        e = (tower[0] - 3 + (3 if name == 'TITLE' else -3), tower[1] + dy / 4)
        d.rectangle((e[0] - 1, e[1] - 1, e[0] + 1, e[1] + 1), fill=water)
        S = fm.catmull([(e[0], e[1], 0), (TX, TY + 20, 0)], 120)
        for i, (x, y, _) in enumerate(S):
            if i % 6 < 3 and y > river_y + 4 and math.hypot(x - e[0], y - e[1]) > 2:
                img.putpixel((int(x + 0.5), int(y + 0.5)), hx('d4b483'))
        text(e[0] + lx, e[1] - 4, name, water)
    # labels
    d.polygon([(232, 16), (229, 24), (235, 24)], fill=ink)
    text(229, 26, 'N')
    text(TX + 22, TY - 30, 'THE GREAT TREE')
    text(TX + 22, TY - 21, '(WORKING LABEL)', faint)
    text(12, 60, "ITS FOREST", hx('44421a'))
    text(12, 69, 'ABOUT 680 ACROSS', faint)
    text(150, 150, '320 TILES', faint)
    text(150, 159, 'N 12 DEG W', faint)
    d.line(((146, 104), (146, 176)), fill=faint)
    d.line(((143, 104), (149, 104)), fill=faint)
    d.line(((143, 176), (149, 176)), fill=faint)
    text(160, 172, 'HIGHBANK')
    d.line(((158, 176), (tower[0] + 8, tower[1] + 2)), fill=ink)
    text(14, 150, "THE TOWER'S", hx('b06b3d'))
    text(14, 159, 'ROOT', hx('b06b3d'))
    d.line(((40, 163), (M(-17, 245)[0] - 2, M(-17, 245)[1])), fill=hx('b06b3d'))
    text(170, river_y + 6, 'RIVER', water)
    # legend and scale bar, top left
    d.rectangle((8, 17, 16, 18), fill=rootc)
    text(20, 14, 'ROOT, SURFACED')
    for x in range(8, 17, 3):
        img.putpixel((x, 28), hx('a37a32'))
    text(20, 25, 'UNDERGROUND')
    d.line(((8, 41), (33, 41)), fill=ink)
    d.line(((8, 38), (8, 44)), fill=ink)
    d.line(((33, 38), (33, 44)), fill=ink)
    text(37, 37, '100 TILES')

    # --- Highbank inset, 2 px = 1 tile, Street coordinates (Street col 0 at x0)
    QX0, QY0, QX1, QY1 = 247, 11, 417, 155
    d.rectangle((QX0, QY0, QX1, QY1), fill=panel, outline=faint)
    text(248, 1, 'HIGHBANK, 2 PX = 1 TILE', knock=False)
    x0, y0 = 250, 50

    def Q(c, r):
        return (x0 + 2 * c, y0 + 2 * r)

    # areas: Rise (Street cols 34-59, rows -14 to -1), Street 56x16, Ferry (cols 40-73, rows 16-31), East Quarter
    d.rectangle((*Q(34, -14), *Q(60, 0)), fill=hx('ccb290'), outline=ink)
    d.rectangle((*Q(0, 0), *Q(56, 16)), fill=hx('e6c697'), outline=ink)
    d.rectangle((*Q(56, 2), *Q(80, 16)), fill=hx('e6c697'), outline=faint)
    d.rectangle((*Q(40, 16), *Q(74, 29)), fill=hx('d4b483'), outline=ink)
    d.rectangle((*Q(0, 29), *Q(80, 32)), fill=hx('2d9e9f'))
    d.rectangle((*Q(41, -8), *Q(53, -5)), fill=panel, outline=ink)        # the Tower's base
    img.putpixel(Q(46, -7), hx('f2d27a'))
    for (c, r, w) in ((3, 5, 6), (12, 5, 6), (20, 5, 6), (28, 5, 6), (21, 11, 6)):
        d.rectangle((*Q(c, r - 2), *Q(c + w - 1, r + 1)), fill=hx('c7a378'), outline=faint)
    d.rectangle((*Q(12, 11), *Q(17, 14)), fill=hx('c6bb2a'), outline=faint)  # Growth Shrine
    d.ellipse((*Q(64.5, 24.5), *Q(66.5, 26.5)), fill=hx('0b0e11'))           # the Mouth
    # the forest edge north and west of town
    for c in range(-2, 82):
        for k in range(3):
            if noise(c, k, 3) > 0.35:
                yy = -15 if 34 <= c <= 60 else -1
                img.putpixel((Q(c, yy)[0], Q(c, yy)[1] - k), leaf if k else leaf_d)

    def rpath(pts, surf, w=1):
        S = fm.catmull([(x, y, 0) for x, y in pts], 20)
        for i, (x, y, _) in enumerate(S):
            f_ = i / (len(S) - 1)
            if any(a <= f_ <= b for a, b in surf):
                d.rectangle((int(x), int(y), int(x) + w, int(y) + w), fill=hx('b06b3d'))
            elif i % 3 == 0:
                img.putpixel((int(x), int(y)), hx('663f23'))

    # 1 the Tower's root: in from the west at full girth (as in the root note), across the lane, up the Tower
    rpath([Q(28, -10), Q(34, -8), Q(36, -7), Q(38.5, -6.5), Q(41, -7)], [(0.25, 1.0)], 2)
    # 2 the Crossroads root and 4 the bluff curtains, 5 around the Mouth to the river
    rpath([Q(39, -2), Q(40, 4), Q(42, 9), Q(43, 14), Q(45, 18), Q(52, 21), Q(61, 24), Q(64, 28), Q(66, 30)],
          [(0.18, 0.4), (0.5, 0.58), (0.78, 0.98)])
    # 3 the shrine root: under the north hedge between Home and the Item Shop, a knuckle under the Growth Shrine
    rpath([Q(10, -2), Q(10.5, 4), Q(11, 9), Q(13.5, 12), Q(13, 16), Q(12, 29)], [(0.3, 0.42), (0.55, 0.72),
                                                                                 (0.78, 0.95)])
    # 6 the East Quarter root along its south fence, 7 the Rise well
    rpath([Q(66, -4), Q(68, 4), Q(70, 12), Q(74, 15.5), Q(79, 16), Q(80, 29)], [(0.5, 0.85)])
    rpath([Q(36, -14), Q(40, -9), Q(42, -4)], [(0.75, 0.9)])
    for (n, c, r) in (('1', 31, -12), ('2', 36, 7), ('3', 7, 11), ('4', 15, 21), ('5', 58, 26), ('6', 75, 11),
                      ('7', 43, -2)):
        x, y = Q(c, r)
        d.rectangle((x - 1, y - 1, x + 5, y + 7), fill=ink)
        d.text((x, y - 1), n, font=f, fill=panel)
    text(Q(0, -8)[0], Q(0, -8)[1], 'FOREST EDGE', hx('44421a'))
    text(Q(46, -15)[0], Q(46, -15)[1] + 2, 'RISE', ink, knock=False)  # inside the Rise, clear of the hedge dots
    text(Q(1, 1)[0] + 1, Q(1, 1)[1] + 1, 'STREET')
    text(Q(57, 3)[0] + 1, Q(57, 3)[1] + 1, 'EAST Q.', faint)
    text(Q(41, 17)[0] + 1, Q(41, 17)[1] + 1, 'FERRY WARD')
    text(Q(2, 29)[0], Q(2, 29)[1] - 3, 'RIVER', panel, knock=False)
    d.line((Q(2, 33)[0], Q(2, 33)[1] + 2, Q(12, 33)[0], Q(12, 33)[1] + 2), fill=ink)
    text(Q(13, 33)[0] + 2, Q(13, 33)[1] - 2, '10 TILES')
    legend = ["1 TOWER'S ROOT (ROOT NOTE)", '2 ROOT HEAVES CROSSROADS', '3 SHRINE ON A ROOT KNUCKLE',
              '4 ROOT CURTAINS, BLUFF', '5 ROOTS PART AT THE MOUTH', '6 EAST Q. FENCE ON A ROOT',
              '7 ROOTLETS IN RISE WELL']
    d.rectangle((QX0, 158, QX1, PY1), fill=panel, outline=faint)
    for i, s in enumerate(legend):
        assert d.textlength(s, font=f) <= QX1 - QX0 - 4, s
        d.text((QX0 + 3, 160 + 9 * i), s, font=f, fill=ink)
    text(QX0 + 3, 160 + 9 * 7 + 3, 'ALL PROPOSALS', faint)

    # --- side view, 1 px = 2 tiles: the tree against the Tower (the gap between them is not to scale)
    d.rectangle((3, 244, 417, 297), fill=panel, outline=faint)
    gy = 292
    d.line(((6, gy), (300, gy)), fill=ink)
    d.line(((318, gy), (414, gy)), fill=ink)
    for xb in (303, 310):
        d.line(((xb, gy + 3), (xb + 5, gy - 3)), fill=ink)
    R = render_tree(cx=150, base_y=gy - 1, p=0.5, light=-1)
    cmap = dict(lit='908940', body='6b6d45', shade='44421a', under='44421a', curtain='44421a', limb='663f23',
                limb_shade='3f2716', trunk='7c4a26', trunk_lit='b06b3d', trunk_shade='3f2716')
    for (x, y), role in R.items():
        if 0 <= x < W and 245 <= y < gy:
            img.putpixel((x, y), hx(cmap[role]))
    xs = [x for (x, y) in R]
    ys = [y for (x, y) in R]
    tx = 370
    d.rectangle((tx - 3, gy - 15, tx + 2, gy - 1), fill=hx('c7a378'), outline=ink)  # the Tower, 30 tiles = 15 px
    img.putpixel((tx + 3, gy - 13), hx('f2d27a'))
    text(8, 247, 'SIDE VIEW, 1 PX = 2 TILES')
    text(198, 252, 'GREAT TREE: 66 TALL,')
    text(198, 261, 'CROWN 150 ACROSS,')
    text(198, 270, 'TRUNK ABOUT 17')
    text(344, 262, 'TOWER 30')
    text(216, 282, '320 TILES (NOT TO SCALE)', faint)
    REPORT['map'] = dict(side_tree_w_px=max(xs) - min(xs) + 1, side_tree_h_px=max(ys) - min(ys) + 1,
                         tower_px=tuple(round(v, 1) for v in tower))
    save(img, 'map')


def review():
    names = ['title', 'vista', 'hold']
    sheet = Image.new('RGB', (384, 648))
    for i, n in enumerate(names):
        sheet.paste(Image.open(f'{OUT}/{n}_1x.png').convert('RGB'), (0, 216 * i))
    sheet.resize((768, 1296), Image.NEAREST).save(f'{fm.SCRATCH}/v2_skyline_sheet.png')


if __name__ == '__main__':
    mock_title()
    mock_vista()
    mock_hold()
    mock_influence()
    mock_map()
    review()
    for k, v in REPORT.items():
        print(k, v)
