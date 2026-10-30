"""Final v2 mocks for the great tree (working label), after Preston's 2026-10-27 answer:
"like not too far from the town. Like the tree of life ... its at the center of the forest but its just so big its
influence is everywhere around the town."

Pick: the v2_skyline reading (the tree stands at the heart of its own forest, 320 tiles N 12 W of the Tower, crown on
the northern skyline, roots and leaves all over town, never overhead). Grafts from v2_boughs: the trunk goes DOWN into
its forest (foot hidden by woods, never floating on a mist bar), a hazed trunk instead of a near-looking brown one,
limbs that end inside the crown, finger-cluster roots on the bluff, a clear window around the lamp, no mist bars.

Run from anywhere:  python -W ignore final_v2_mocks.py
It reuses v2_skyline/mock_skyline.py (which reuses final/final_mocks.py) for helpers, the influence sheet and the map,
writes every mock here as name_1x.png and name_3x.png, and prints the measurements.
Design and mocks only: nothing under scripts/, scenes/ or assets/ is read for writing or changed.
"""
import importlib.util
import math
import random
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
GT = ROOT + '/docs/design/great-tree-2026-10-27'
OUT = GT + '/final_v2'

_spec = importlib.util.spec_from_file_location('mock_skyline', GT + '/v2_skyline/mock_skyline.py')
ms = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ms)  # helpers only; its __main__ block does not run
ms.OUT = OUT                  # ms.save() now writes into final_v2
fm = ms.fm
hx, lum, noise = fm.hx, fm.lum, fm.noise
BUILD = ms.BUILD
REPORT = {}


def save(img, name):
    img.save(f'{OUT}/{name}_1x.png')
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f'{OUT}/{name}_3x.png')


# ============================================================================================ the tree, v2 limbs
def render_tree2(cx, base_y, p, light=1, lamp_clear=None, skip_clump=None):
    """mock_skyline.render_tree with two changes: limbs rise steeply and end inside the crown (no flat T-shaped
    limbs), and clumps can be skipped per view (skip_clump) to keep the lamp's window clear."""
    R = {}
    MODEL, MASSES, crown_bot, trunk_hw = ms.MODEL, ms.MASSES, ms.crown_bot, ms.trunk_hw

    def S(x, y):
        return cx + x * p, base_y - y * p

    def setp(X, Y, role):
        R[(int(X), int(Y))] = role

    for (side, h0, reach, girth) in ms.BUTTRESS:  # buttress roots, crook-shaped
        x0 = side * trunk_hw(h0) * 0.7
        n = int(reach * p * 2) + 10
        for k in range(n + 1):
            th = (k / n) * (math.pi / 2) * 1.18
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
    Ytop, Ybot = S(0, 44)[1], S(0, 0)[1]  # the braided trunk
    for Y in range(int(Ytop), int(Ybot) + 1):
        y = (base_y - Y) / p
        hw = trunk_hw(y) * p
        xc = cx + 1.0 * math.sin(y * 0.07) * p
        for X in range(int(math.floor(xc - hw)), int(math.ceil(xc + hw)) + 1):
            u = (X - xc) / max(hw, 0.5)
            if abs(u) > 1:
                continue
            role = 'trunk'
            if u * light > 0.74:
                role = 'trunk_lit'
            elif u * light < -0.42:
                role = 'trunk_shade'
            for k in range(3):
                ph = y * 0.15 + k * 2.094
                if math.cos(ph) > -0.2 and abs(u - 0.78 * math.sin(ph)) < 0.6 / max(hw, 1) + 0.035:
                    role = 'trunk_shade'
            if role == 'trunk' and noise(X, int(Y // 3), 11) > 0.84:
                role = 'trunk_shade'
            setp(X, Y, role)
    # limbs: only to the inner and middle masses, leaving the trunk high and rising steeply, so they disappear into
    # the crown's belly instead of running out flat under it
    for (mx, my, Rm) in MASSES:
        if abs(mx) > 58:
            continue
        w = 1.0 if Rm > 12 else 0.75
        x0, y0 = 0.02 * mx, 31.0
        x1, y1 = 0.8 * mx, min(my - 1.0, crown_bot(mx * 0.8) + 10.0)
        L = math.hypot((x1 - x0) * p, (y1 - y0) * p)
        n = int(L * 1.5) + 2
        for k in range(n + 1):
            a = k / n
            x = x0 + (x1 - x0) * (a ** 1.6)
            y = y0 + (y1 - y0) * (a ** 0.8)
            r = max(0.55, (1.3 - 0.8 * a) * w * p)
            X, Y = S(x, y)
            for yy in range(int(Y - r) - 1, int(Y + r) + 2):
                for xx in range(int(X - r) - 1, int(X + r) + 2):
                    dy = yy - Y
                    if (xx - X) ** 2 + dy * dy <= r * r + 0.25:
                        setp(xx, yy, 'limb_shade' if dy > 0.3 * r else 'limb')
    for (x, ln) in MODEL['curtains']:  # hanging moss and aerial roots
        X, Y0 = S(x, crown_bot(x) + 2.0)
        if lamp_clear and lamp_clear(X, Y0 + ln * p):
            continue
        if skip_clump and skip_clump(X, Y0):
            continue
        for k in range(int((ln + 2.0) * p)):
            if noise(int(X), k // 3, 9) > 0.86:
                continue
            setp(X, Y0 + k, 'curtain')
    for (x, y, r, rel, ph1, ph2) in MODEL['lobes']:  # the clumps
        X, Y = S(x, y)
        rr = r * p
        if skip_clump and skip_clump(X, Y):
            continue
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
                rim = lit > 0.45 and d > 0.62 * re
                belly = ny > 0.3 and d > 0.4 * re
                if rel > -0.15:
                    role = 'lit' if rim else ('shade' if belly else 'body')
                elif rel > -0.5:
                    role = 'shade' if belly else 'body'
                else:
                    role = 'body' if rim else ('under' if belly else 'shade')
                if role == 'body' and rel > -0.15 and lit > 0.2 and d > 0.4 * re and noise(xx, yy, 5) > 0.7:
                    role = 'lit'
                elif role == 'body' and ny > 0.12 and noise(xx, yy, 6) > 0.62:
                    role = 'shade'
                elif role == 'shade' and rel < -0.5 and noise(xx, yy, 7) > 0.8:
                    role = 'body'
                setp(xx, yy, role)
    return R


ms.render_tree = render_tree2  # the map's side view uses the same limbs


def forest_crowns(img, top_line, bottom_line, x0, x1, peak_x, peak_h, spread, tiers, ok, seed=4, rr=(1.6, 3.0)):
    """The great tree's forest around its foot: round crowns standing on top_line, rising toward the trunk (peak_x),
    filled down to bottom_line. tiers = (top, body, shade) colours, nearest the trunk first, so the edges fade into
    the far haze instead of stopping. Each crown has a lit cap and a dark left edge, so the band reads as many trees
    and not as one flat strip of mist."""
    px = img.load()
    W, H = img.size
    rnd = random.Random(seed)
    x = float(x0)
    while x < x1:
        d = abs(x - peak_x) / spread
        if d >= 1:
            x += 2
            continue
        r = rnd.uniform(*rr)
        h = peak_h * (1 - d) ** 1.5 + rnd.uniform(-1.6, 1.6)
        top_c, body_c, shade_c = tiers[min(len(tiers) - 1, int(d * len(tiers)))]
        xi = int(min(max(x, 0), W - 1))
        top = top_line[xi] - max(0.5, h)
        for yy in range(max(0, int(top - r) - 1), H):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if not (0 <= xx < W) or yy >= bottom_line[xx] or not ok(xx, yy):
                    continue
                dy = max(0.0, top - yy)
                if not ((xx - x) ** 2 + dy * dy <= r * r or (yy >= top and abs(xx - x) <= r)):
                    continue
                if yy < top - r * 0.15 and xx > x - 0.3 * r and noise(xx, yy, 1) > 0.3:
                    c = top_c      # the crown's lit cap
                elif xx < x - 0.45 * r and top - r * 0.6 <= yy <= top + r * 0.7:
                    c = shade_c    # its shaded left flank, near the top only (lower down it is all one wood)
                elif yy > top + r and noise(xx, yy, 3) > 0.84:
                    c = shade_c    # a few dark gaps deeper in
                else:
                    c = body_c
                px[xx, yy] = hx(c)
        x += r * rnd.uniform(1.1, 1.5)


def finger_roots(px, x0, y0, y1, n, seed):
    """Graft from v2_boughs: a cluster of roots breaking out under the walkway lip and splaying down the quay wall
    into the river, thick at the top, one pixel at the water, a moss lip over them and a ripple at each tip."""
    rnd = random.Random(seed)
    for dx in range(-1, n * 2 + 1):
        px[x0 + dx, y0 - 1] = hx('6b6f1d' if dx % 2 else '908940')
    ends = []
    for i in range(n):
        xs = x0 + i * 2
        fan = (i - (n - 1) / 2) * rnd.uniform(1.8, 2.8)
        x = xs
        for y in range(y0, y1 + 1):
            f = (y - y0) / max(1, y1 - y0)
            x = xs + int(round(fan * f ** 1.2 + 0.6 * math.sin(f * 6 + seed + i)))
            w = 2 if f < 0.45 else 1
            for j in range(w):
                c = 'b06b3d' if (j == 0 and w == 2) else '663f23'
                if y >= 202:
                    c = '3f2716'
                px[x + j, y] = hx(c)
        ends.append(x)
    for e in ends:
        for dx in (-1, 1):
            px[e + dx, y1 + 2] = hx('2d9e9f')


def tops_of(src, cols, y0, W, H):
    """First row at or below y0 in each column whose colour is in cols (H if none)."""
    o = src.load()
    out = []
    for x in range(W):
        t = H
        for y in range(y0, H):
            if o[x, y] in cols:
                t = y
                break
        out.append(t)
    return out


def role_extent(R, roles, painted):
    ys = [Y for (X, Y), r in R.items() if r in roles and (X, Y) in painted]
    return (min(ys), max(ys)) if ys else None


# ============================================================================================ 1. title
TITLE_CMAP2 = dict(ms.TITLE_CMAP, trunk=('5f5e57', '4f6858'), trunk_lit=('6b6d45', '5f5e57'),
                   trunk_shade=('4f6858', '43665a'), limb=('5f5e57', '4f6858'), limb_shade=('4f6858', '43665a'))


def mock_title():
    img = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    sky = {hx(c) for c in ms.TITLE_SKY}
    skyline = fm.skyline_of(src, sky, 95)
    dom = fm.row_sky(src, sky, 110, 270)
    clouds = fm.cloud_mask(src, sky, dom)
    woods = {hx('303e37'), hx('1d2925')}
    woods_top = tops_of(src, woods, 90, W, H)
    MENU, WORDMARK = ms.MENU, ms.WORDMARK

    def in_box(b, x, y):
        return b[0] <= x < b[2] and b[1] <= y < b[3]

    def crown_ok(x, y):
        return (orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and not in_box(MENU, x, y)
                and not (x >= 312 and y < 50) and x < 298)

    def allowed(x, y):  # the trunk may also stand in front of the far hills, down to the ridge woods
        if crown_ok(x, y):
            return True
        return (105 <= x < 200 and skyline[x] <= y < woods_top[x] and (x, y) not in clouds
                and orig[x, y] not in woods and not in_box(MENU, x, y))

    p = ms.ppt('title')
    R = render_tree2(cx=150, base_y=144, p=p, light=-1)
    before = img.copy()
    st = ms.paint_tree(img, R, TITLE_CMAP2, allowed, lambda x, y: orig[x, y],
                       calm=lambda x, y: y < 50 or (y < 64 and noise(x, y, 13) > (y - 50) / 14.0))
    bp, ip = before.load(), img.load()
    painted = {(x, y) for (x, y) in R if 0 <= x < W and 0 <= y < H and bp[x, y] != ip[x, y]}
    trunk_rows = role_extent(R, {'trunk', 'trunk_lit', 'trunk_shade'}, painted)
    # its forest rising around its foot, a step hazier than the ridge woods; the trunk goes down into it
    fok = lambda x, y: not in_box(MENU, x, y) and orig[x, y] not in woods and x < 292 and (x, y) not in clouds
    forest_crowns(img, woods_top, woods_top, 96, 250, 150, 11, 70,
                  [('4f6858', '33524e', '303e37'), ('43665a', '33524e', '303e37'), ('33524e', '303e37', '303e37')],
                  fok, seed=5)
    # the Tower's root: a faint seam with surfaced humps through the ridge woods to the Tower's west foot
    fm.root_road(img, [(172, 122), (190, 128), (210, 135), (232, 143), (252, 150), (268, 156), (279, 162)],
                 [(0.08, 0.22), (0.38, 0.54), (0.72, 0.9)], lambda x, y: 1.2 + 0.03 * (y - 120),
                 dict(crest='43665a', crest_lit='61785c', bark='33524e', lit='61785c', dark='263d3a',
                      contact='1e302e', trail='33524e'),
                 lambda x, y: orig[x, y] in woods and x < 280 and y > 119,
                 seam=lambda c: hx('303e37') if c == hx('1d2925') else c)
    # roots holding the bank: finger clusters over the quay wall, drinking at the river
    px = img.load()
    finger_roots(px, 150, 186, 204, 3, 1)
    finger_roots(px, 213, 186, 204, 4, 2)
    finger_roots(px, 258, 186, 203, 2, 3)
    # a few of its leaves on the north wind over the Street (never on the Tower, the menu or the wordmark)
    rnd = random.Random(31)
    n_leaves = 0
    for _ in range(40):
        x, y = rnd.randint(140, 285), rnd.randint(120, 178)
        if n_leaves >= 9 or in_box(MENU, x, y) or x > 286:
            continue
        if orig[x, y] in woods or orig[x, y] in sky:
            continue
        px[x, y] = hx('908940')
        px[x + 1, y] = hx('6b6d45')
        n_leaves += 1
    save(img, 'title')
    a, b = src.load(), img.load()
    changed = [(x, y) for y in range(H) for x in range(W) if a[x, y] != b[x, y]]
    REPORT['title'] = dict(px_per_tile=round(p, 2), tree_box=st['box'], tree_lum=st['tree_lum'],
                           sky_lum=st['sky_behind_lum'], trunk_rows=trunk_rows,
                           woods_top_at_trunk=woods_top[150], crown_w=round(150 * p), tree_h=round(ms.H_T * p),
                           changed=len(changed), in_menu=sum(1 for x, y in changed if in_box(MENU, x, y)),
                           in_shade_box=sum(1 for x, y in changed if x >= 312 and y < 50),
                           right_of_298_above_150=sum(1 for x, y in changed if x >= 298 and y < 150),
                           wordmark_edges_before=ms.edges(src, WORDMARK), wordmark_edges_after=ms.edges(img, WORDMARK),
                           colours_before=len(ms.colours(src)), colours_after=len(ms.colours(img)),
                           new_colours=sorted(ms.hexs(c) for c in ms.colours(img) - ms.colours(src)))


# ============================================================================================ 2. vista
def mock_vista():
    img = fm.load_3x(f'{BUILD}/round2/13_road_vista.png')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    farhill = {hx('a3b0ae'), hx('b8c2bc'), hx('f7e3b5')}  # f7e3b5: the bright haze line on the far hills' top
    sky = {orig[x, y] for x in range(60, 220) for y in range(0, 117)} - farhill
    skyline = fm.skyline_of(src, sky, 50)
    dom = fm.row_sky(src, sky, 60, 220)
    # only real cloud streaks (high in the sky) pass in front; the dithered band edges low down are not clouds,
    # and treating them as clouds striped the trunk and the forest in the first pass
    clouds = {(x, y) for (x, y) in fm.cloud_mask(src, sky, dom) if y < 95}
    land_top = []
    for x in range(W):
        t = H
        for y in range(skyline[x], H):
            if orig[x, y] not in sky and orig[x, y] not in farhill:
                t = y
                break
        land_top.append(t)

    def crown_ok(x, y):
        return orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and x < 224

    def allowed(x, y):
        if crown_ok(x, y):
            return True
        return 30 <= x < 130 and skyline[x] <= y < land_top[x] and orig[x, y] in farhill

    p = ms.ppt('vista')
    R = render_tree2(cx=78, base_y=146, p=p, light=1)
    before = img.copy()
    # warm khaki rims instead of near-white ones, so the crown reads as leaves and not as a cumulus cloud
    st = ms.paint_tree(img, R, dict(ms.DAWN_CMAP, lit=('8c8466', '979683')), allowed, lambda x, y: orig[x, y])
    bp, ip = before.load(), img.load()
    painted = {(x, y) for (x, y) in R if 0 <= x < W and 0 <= y < H and bp[x, y] != ip[x, y]}
    trunk_rows = role_extent(R, {'trunk', 'trunk_lit', 'trunk_shade'}, painted)
    # its forest on the far hills, rising around the trunk's foot and fading into the haze at the edges
    fok = lambda x, y: x < 224 and (orig[x, y] in sky or orig[x, y] in farhill) and (x, y) not in clouds
    forest_crowns(img, skyline, land_top, 0, 224, 78, 10, 85,
                  [('748471', '596d6f', '45502d'), ('838e87', '748471', '596d6f'), ('a3b0ae', '838e87', '748471'),
                   ('b8c2bc', 'a3b0ae', '838e87')], fok, seed=6, rr=(2.0, 3.6))
    land = {hx(c) for c in ('6f8455', 'a3b0ae', '7f9467', '93a77a', 'b8c2bc', '6a8848', '4b6634', '3e5629')}
    darker = {'a3b0ae': '7f9467', 'b8c2bc': 'a3b0ae', '7f9467': '6f8455', '93a77a': '7f9467', '6f8455': '4b6634',
              '6a8848': '4b6634', '4b6634': '3e5629', '3e5629': '3e5629'}
    # the Tower's root comes out of the forest at the tree's foot and down the open slope to the Tower's west foot
    fm.root_road(img, [(96, 121), (114, 134), (136, 148), (158, 161), (180, 173), (203, 183), (222, 189), (236, 186)],
                 [(0.03, 0.12), (0.2, 0.31), (0.39, 0.5), (0.58, 0.69), (0.77, 0.87), (0.93, 1.0)],
                 lambda x, y: 0.8 + 0.04 * (y - 121),
                 dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23',
                      contact='3e5629', trail='ccb290'),
                 lambda x, y: orig[x, y] in land and orig[x, y] not in farhill,
                 seam=lambda c: hx(darker.get(ms.hexs(c), ms.hexs(c))))
    # a second root under the party's slope: the roots run under everything, not only the Tower's
    fm.root_road(img, [(20, 181), (60, 192), (104, 199), (150, 204), (190, 211)],
                 [(0.05, 0.3), (0.55, 0.82)], lambda x, y: 2.2,
                 dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23',
                      contact='3e5629', trail='4b6634'),
                 lambda x, y: orig[x, y] in land and not (70 <= x <= 145 and y < 180),
                 seam=lambda c: hx(darker.get(ms.hexs(c), ms.hexs(c))))
    save(img, 'vista')
    dawn = ms.palette('dawn')
    REPORT['vista'] = dict(px_per_tile=round(p, 2), tree_box=st['box'], tree_lum=st['tree_lum'],
                           sky_lum=st['sky_behind_lum'], trunk_rows=trunk_rows, land_top_at_trunk=land_top[78],
                           crown_w=round(150 * p), tree_h=round(ms.H_T * p),
                           tree_px_right_of_224=sum(1 for (x, y) in painted if x >= 224),
                           colours_before=len(ms.colours(src)), colours_after=len(ms.colours(img)),
                           new_not_in_dawn_or_frame=sorted(ms.hexs(c) for c in ms.colours(img) - ms.colours(src) - dawn))


# ============================================================================================ 3. reveal hold
HZ = ms.HZ
FOREST = ms.FOREST
LAMP_WIN = (160, 80, 245, 152)  # the lamp, its hook and its glow in the hold frame (1x)


def build_hold_backdrop():
    """mock_skyline.build_hold_backdrop without the mist bars (they read as glitch lines), with the v2 limbs, and
    with no crown or curtain on the lamp's side, so the lamp sits in clean sky."""
    W, H = 384, 216
    img = Image.new('RGB', (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            if y < HZ:
                px[x, y] = hx(fm.SKY_BANDS[fm.band_at(fm.SKY_BANDS, x, y)][1])
            else:
                i = ms.forest_band(y)
                if y in (124, 129, 136, 148, 165, 186, 204) and (x + y) % 2 == 0:
                    i = max(0, i - 1)
                px[x, y] = hx(FOREST[i])
    rnd = random.Random(12)
    for _ in range(1500):  # the forest from above, ordinary crowns, tiny next to the great tree
        y = rnd.uniform(HZ + 2, H + 4)
        s = (y - HZ) / 96.0
        r = 0.6 + 3.2 * s * s + rnd.uniform(0, 0.8 * s)
        x = rnd.uniform(-4, W + 4)
        i = ms.forest_band(int(min(H - 1, y)))
        dark = hx(FOREST[min(len(FOREST) - 1, i + 1)])
        lite = hx(FOREST[max(0, i - 1)])
        for yy in range(int(y - r), int(y + r * 0.6) + 1):
            for xx in range(int(x - r), int(x + r) + 1):
                if 0 <= xx < W and HZ + 1 <= yy < H and ((xx - x) / r) ** 2 + ((yy - y) / (0.7 * r)) ** 2 <= 1:
                    px[xx, yy] = lite if (yy < y - 0.35 * r and xx > x - 0.2 * r and r > 1.2) else dark
    seam = lambda c: hx(FOREST[min(len(FOREST) - 1, FOREST.index(ms.hexs(c)) + 1)]) if ms.hexs(c) in FOREST else c
    rcols = dict(crest='6f8455', crest_lit='979683', bark='8c6545', lit='b06b3d', dark='565b40', contact='2d3729',
                 trail='979683')
    fm.root_road(img, [(52, 197), (130, 182), (210, 166), (300, 150), (384, 140)],
                 [(0.04, 0.2), (0.36, 0.5), (0.66, 0.78)], lambda x, y: max(0.5, 0.03 * (y - HZ)), rcols,
                 lambda x, y: y > HZ, seam=seam)
    fm.root_road(img, [(50, 203), (150, 205), (250, 207), (384, 209)],
                 [(0.1, 0.3), (0.5, 0.64), (0.82, 0.95)], lambda x, y: max(0.5, 0.03 * (y - HZ)), rcols,
                 lambda x, y: y > HZ, seam=seam)
    fm.root_road(img, [(46, 205), (70, 210), (92, 216)], [(0.0, 1.0)], lambda x, y: 2.6, rcols,
                 lambda x, y: y > HZ, seam=seam)
    p = ms.ppt('hold')
    lamp = lambda x, y: x >= 150 and y > 70
    R = render_tree2(cx=16, base_y=199, p=p, light=1, lamp_clear=lamp,
                     skip_clump=lambda X, Y: X > 150 or (X > 128 and Y > 70))
    src = img.copy()
    sp = src.load()
    st = ms.paint_tree(img, R, ms.HOLD_CMAP, lambda x, y: True, lambda x, y: sp[x, y])
    for _ in range(140):  # ordinary forest in front of its foot
        x = rnd.uniform(-10, 120)
        y = rnd.uniform(193, 214)
        r = rnd.uniform(1.8, 3.4)
        for yy in range(int(y - r), int(y + r * 0.6) + 1):
            for xx in range(int(x - r), int(x + r) + 1):
                if 0 <= xx < W and yy < H and ((xx - x) / r) ** 2 + ((yy - y) / (0.7 * r)) ** 2 <= 1:
                    px[xx, yy] = hx('59753c' if yy < y - 0.35 * r else '4b6731')
    for (y, x0, x1) in ((150, 0, 96), (151, 8, 84), (152, 20, 70)):  # a cloud strip across the trunk
        for x in range(x0, x1):
            if (x * 5 + y) % 17 != 0:
                px[x, y] = hx('c2b58f' if y != 152 else 'a3a891')
    for (bx, by) in ((262, 168), (273, 163)):  # two birds below the eye
        for (dx, dy) in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            px[bx + dx, by + dy] = hx('2d3729')
    tree_in_lamp = sum(1 for (x, y) in R if LAMP_WIN[0] <= x < LAMP_WIN[2] and LAMP_WIN[1] <= y < LAMP_WIN[3]
                       and y < HZ)
    xs = [x for (x, y) in R if 0 <= x < W and 0 <= y < H]
    return img, dict(tree_box=st['box'], tree_lum=st['tree_lum'], sky_lum=st['sky_behind_lum'],
                     px_per_tile=round(p, 2), crown_w_lens=round(150 * p), tree_h=round(ms.H_T * p),
                     crown_right_edge=max(xs), tree_px_in_lamp_window=tree_in_lamp,
                     backdrop_colours=len(ms.colours(img)))


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
    # warm candidates only (red at least blue), so the rebuilt glow stays a warm halo and never a cool blue ring
    pal = {c for c in ms.colours(bd) if c[0] >= c[2]} | glow
    for y in range(img.height):
        for x in range(img.width):
            c = src[x, y]
            if c in bgc:
                px[x, y] = bp[x, y]
            elif c in glow:  # the lamp's glow, rebuilt over whatever is behind it now
                k = 0.42 if lum(c) > 165 else 0.22
                b = bp[x, y]
                px[x, y] = ms.nearest(pal, tuple(b[i] * (1 - k) + light[i] * k for i in range(3)))
    save(img, 'hold')
    REPORT['hold'] = dict(**st, frame_colours=len(ms.colours(img)))


# ============================================================================================ 4. influence sheet
def mock_influence():
    """mock_skyline's four in-town vignettes (unchanged pictures) with taller caption strips, so no third caption
    line is clipped by the picture under it."""
    cells = [('STREET: A ROOT HEAVES THE CROSSROADS PAVING, SURFACES AND DIVES UNDER AGAIN', ms.vignette_street()),
             ("RISE WEST LANE: THE TOWER'S ROOT COMES IN FROM THE FOREST. ITS LEAVES, EVENING DAPPLE",
              ms.vignette_rise()),
             ('FERRY WARD: TWO ROOTS PART AROUND THE MOUTH, NEVER INTO IT, AND DRINK THE RIVER',
              ms.vignette_ferry()),
             ('STREET: ITS LEAVES AND SEED TUFTS COME IN ON THE NORTH WIND', ms.vignette_air())]
    M, CW, CH, CAP = 4, 192, 108, 32
    W = 2 * CW + 3 * M
    H = 12 + 2 * (CAP + CH) + 3 * M
    img = Image.new('RGB', (W, H), hx('1a1410'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(fm.FONT, 8)
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


def fix_map_break():
    """The side view's '320 TILES (NOT TO SCALE)' label sat on top of the scale-break mark; redraw the label and move
    the break mark just past its end."""
    img = Image.open(f'{OUT}/map_1x.png').convert('RGB')
    px = img.load()
    bg = px[214, 283]
    gy = min(range(286, 296), key=lambda y: lum(px[200, y]))
    gc = px[200, gy]
    tc = next((px[x, y] for y in range(281, 291) for x in range(216, 226) if px[x, y] != bg), hx('be9c62'))
    for y in range(280, 296):
        for x in range(214, 356):
            px[x, y] = gc if y == gy else bg
    for x in range(343, 351):
        px[x, gy] = bg
    for x0 in (342, 346):
        for k in range(5):
            px[x0 + k // 2 + 1, gy + 2 - k] = gc
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    d.text((216, 282), '320 TILES (NOT TO SCALE)', font=ImageFont.truetype(fm.FONT, 8), fill=tc)
    save(img, 'map')


# ============================================================================================ 6. side by side
def mock_compare():
    """The new pick against the earlier concept C, title / vista / hold, at 1x."""
    ImageDraw.ImageDraw.fontmode = '1'
    font = ImageFont.truetype(fm.FONT, 8)
    rows = [('TITLE', 'final/final_title_1x.png', 'final_v2/title_1x.png'),
            ('ROAD VISTA', 'final/final_vista_1x.png', 'final_v2/vista_1x.png'),
            ('REVEAL HOLD', 'final/final_hold_1x.png', 'final_v2/hold_1x.png')]
    M, G, HEAD, LAB = 6, 8, 16, 12
    W = M * 2 + 384 * 2 + G
    H = HEAD + len(rows) * (LAB + 216) + M
    sheet = Image.new('RGB', (W, H), hx('16130f'))
    d = ImageDraw.Draw(sheet)
    ink, dim = hx('f2d27a'), hx('c49b69')
    d.text((M, 4), 'EARLIER PICK (C): FAR, ABOUT 100 PX', font=font, fill=dim)
    d.text((M + 384 + G, 4), 'NEW: HEART OF ITS FOREST, 320 TILES OUT', font=font, fill=ink)
    y = HEAD
    for (label, a, b) in rows:
        d.text((M, y + 1), label, font=font, fill=dim)
        sheet.paste(Image.open(f'{GT}/{a}').convert('RGB'), (M, y + LAB))
        sheet.paste(Image.open(f'{GT}/{b}').convert('RGB'), (M + 384 + G, y + LAB))
        y += LAB + 216
    save(sheet, 'compare_c')
    REPORT['compare_c'] = dict(size=sheet.size)


if __name__ == '__main__':
    mock_title()
    mock_vista()
    mock_hold()
    mock_influence()
    ms.mock_map()
    fix_map_break()
    REPORT['map'] = ms.REPORT.get('map')
    mock_compare()
    for k, v in REPORT.items():
        print(k, v)
