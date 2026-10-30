"""Concept A, "Across the water": the great tree on a river island upriver (NNW) of Highbank.

Proposal mocks only. Nothing here is canon or wired into the game.
Draws on copies of the Wayline Tower look-pass renders and writes 1x and 3x PNGs
next to this script. Hard pixels, nearest-neighbour scaling, colours picked from
the project palettes (wayline_tower, highbank_title, dawn) or the source render.

Run:  python mock_a-upriver.py
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
DES = "C:/Users/pmcga/dev/hollowtide/docs/design"
BUILD = DES + "/wayline-tower-2026-10-27/build"
PALS = DES + "/placeholder-factory-2026-10-26/refs/palettes"


# ------------------------------------------------------------------ helpers
def hx(s):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def hexs(c):
    return "#%02x%02x%02x" % c


def pal(name):
    im = Image.open(os.path.join(PALS, name)).convert("RGB")
    px = im.load()
    out = []
    for y in range(im.height):
        for x in range(im.width):
            if px[x, y] not in out:
                out.append(px[x, y])
    return out


def load1x(path):
    im = Image.open(path).convert("RGB")
    if im.size == (1152, 648):
        im = im.resize((384, 216), Image.NEAREST)
    return im


def save(im, stem):
    p1 = os.path.join(HERE, stem + "_1x.png")
    p3 = os.path.join(HERE, stem + "_3x.png")
    im.save(p1)
    im.resize((im.width * 3, im.height * 3), Image.NEAREST).save(p3)
    print("saved", p1, p3)


def count_colours(im, box=None):
    if box:
        im = im.crop(box)
    px = im.load()
    s = set()
    for y in range(im.height):
        for x in range(im.width):
            s.add(px[x, y])
    return len(s)


def mix(a, b, t):
    return tuple(a[i] * (1 - t) + b[i] * t for i in range(3))


def mul(a, k):
    return tuple(min(255.0, max(0.0, a[i] * k)) for i in range(3))


_near_cache = {}


def nearest(c, palette, exclude=()):
    key = (tuple(int(v) for v in c), tuple(palette), tuple(exclude))
    if key in _near_cache:
        return _near_cache[key]
    best, bd = None, 1e18
    for p in palette:
        if p in exclude:
            continue
        d = 2 * (p[0] - c[0]) ** 2 + 4 * (p[1] - c[1]) ** 2 + 3 * (p[2] - c[2]) ** 2
        if d < bd:
            best, bd = p, d
    _near_cache[key] = best
    return best


def line_pts(x0, y0, x1, y1):
    """Bresenham, hard pixels."""
    pts = []
    x0, y0, x1, y1 = int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))
    dx, dy = abs(x1 - x0), -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    while True:
        pts.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy
    return pts


def polyline_samples(pts, step=0.5):
    out = []
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / step))
        for i in range(n):
            t = i / n
            out.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t))
    out.append(pts[-1])
    return out


# ------------------------------------------------------------------ the tree
# Proposal look: a braided trunk (several root strands twisted into one column),
# a crown of stacked flat shelves ("tiers") that read as floors from far off,
# moss curtains hanging under every shelf, and crook-shaped surface roots at the
# foot that rhyme with the Reach. No faces, no lights: the Waiting Lamp stays the
# only lit point in every view.
TIER_W = [0.84, 1.0, 0.74, 0.42]


def build_tree(cx, top, cb, ground, wd, tw_top, tw_base, seed, lean=0.0, arches=False,
               th_k=1.18, dither_u=0.5, arch_r=(5.0, 3.5)):
    rng = random.Random(seed)
    mat = {}
    n = len(TIER_W)
    span = max(1.0, ground - top)

    def lx(y):
        return lean * (ground - y) / span

    def put(x, y, r):
        mat[(int(x), int(y))] = r

    # trunk and central leader
    for y in range(int(top + (cb - top) * 0.35), int(ground) + 1):
        if y >= cb:
            t = (y - cb) / max(1.0, ground - cb)
            hw = tw_top + (tw_base - tw_top) * t
            if t > 0.8:
                hw += ((t - 0.8) / 0.2) ** 2 * tw_base * 0.7
        else:
            t2 = (cb - y) / max(1.0, cb - top)
            hw = tw_top * (1 - 0.65 * t2)
        c = cx + lx(y)
        # braided strands: one family of spiral grooves, like roots twisted into a column
        period = max(3.5, hw * 0.95)
        for x in range(int(round(c - hw)), int(round(c + hw)) + 1):
            u = (x - c) / max(1.0, hw)
            if ((x - c) + (ground - y) * 0.7) % period < 1.0 and abs(u) < 0.85:
                r = "groove"
            elif u < -0.5:
                r = "trunk_lit"
            elif u > 0.4:
                r = "trunk_shade"
            else:
                r = "trunk"
            put(x, y, r)

    # crook roots arching out of the ground at the foot (they rhyme with the Reach)
    if arches:
        base_hw = tw_base * 1.7
        for side in (-1, 1):
            for i, rad in enumerate(arch_r):
                ax = cx + side * (base_hw + rad * 0.6 + i * (arch_r[0] * 1.9))
                for y in range(int(ground - rad - 2), int(ground) + 1):
                    for x in range(int(ax - rad - 2), int(ax + rad + 3)):
                        d = math.hypot(x - ax, y - ground)
                        if rad - 1.6 <= d <= rad + 0.4 and y <= ground:
                            put(x, y, "trunk_lit" if y < ground - rad * 0.6 else "trunk")
                # little hooked tip on the outer arch, like the Reach's curl
                if i == 1:
                    put(ax + side * (rad + 1), ground - rad - 1, "trunk")

    sp = (cb - top) / n
    tiers = []
    for k in range(n):
        yb = cb - k * sp
        w = wd * TIER_W[k]
        ccx = cx + lx(yb) + rng.uniform(-1, 1) * wd * 0.05
        if k == n - 1:
            th = (yb - top) / 1.07
        else:
            th = sp * th_k
        tiers.append((k, yb, w, ccx, th, rng.randint(3, 5), rng.uniform(0, math.pi)))

    # branches from the leader out to each shelf (show in the gaps)
    for (k, yb, w, ccx, th, nb, ph) in tiers:
        y0 = yb + sp * 0.55
        c0 = cx + lx(y0)
        for side in (-1, 1):
            for (x, y) in line_pts(c0, y0, ccx + side * w * 0.5, yb - 1):
                put(x, y, "trunk_shade")

    # shelves, top first so lower shelves overlap the moss above them
    for (k, yb, w, ccx, th, nb, ph) in reversed(tiers):
        for x in range(int(ccx - w) - 1, int(ccx + w) + 2):
            u = (x - ccx) / w
            if abs(u) >= 1:
                continue
            prof = (1 - u * u) ** 0.5
            lobe = abs(math.sin(u * math.pi * nb / 2 + ph)) * 0.22
            ytop = yb - th * (0.22 + 0.78 * prof) * (0.85 + lobe)
            ybot = yb - th * 0.32 * u ** 4
            for y in range(int(math.ceil(ytop)), int(math.floor(ybot)) + 1):
                d = y - ytop
                e = ybot - y
                if d < 1:
                    r = "lit"
                elif u < -0.68 and d < 3:
                    r = "rim"
                elif e < 1.5:
                    r = "shade"
                elif lobe < 0.035 and d < th * 0.4:
                    r = "shade"
                elif u > dither_u and (x + y) % 2 == 0:
                    r = "shade"
                elif u > dither_u + 0.25:
                    r = "shade"
                elif e < 3.0 and (x + y) % 2 == 0:
                    r = "shade"
                elif d < 2.5 and u < 0.25:
                    r = "mid"
                else:
                    r = "body"
                put(x, y, r)
        # moss curtains
        for x in range(int(ccx - w * 0.92), int(ccx + w * 0.92) + 1):
            u = (x - ccx) / w
            if rng.random() < 0.42:
                ybot = yb - th * 0.32 * u ** 4
                ln = int(rng.uniform(1, sp * 0.62) * (0.35 + 0.65 * (1 - abs(u))))
                for j in range(1, ln + 1):
                    put(x, int(math.floor(ybot)) + j, "moss")
    return mat


G = hx("#4b6731")
BARK = hx("#663f23")
WARM = hx("#dca562")
MOSS = hx("#59753c")


def role_colour(role, s, h, wl=0.45, dark=1.0, th=None):
    th = h if th is None else th          # trunk haze can differ from crown haze
    base = mix(G, s, h)
    bark = mix(BARK, s, th)
    if role == "body":
        return mul(base, 0.84 * dark)
    if role == "mid":
        return mul(mix(base, WARM, 0.12), 0.97 * dark)
    if role == "shade":
        return mul(base, 0.64 * dark)
    if role == "lit":
        return mix(mix(G, WARM, wl), s, h * 0.8)
    if role == "rim":
        return mix(WARM, s, h * 0.55)
    if role == "moss":
        return mul(mix(MOSS, s, h), 0.80 * dark)
    if role == "trunk":
        return mul(bark, 0.9 * dark)
    if role == "trunk_lit":
        return mix(mix(BARK, WARM, 0.35), s, th)
    if role == "trunk_shade":
        return mul(bark, 0.68 * dark)
    if role == "groove":
        return mul(bark, 0.52 * dark)
    return s


def paint_tree(img, mat, paintable, sky_at, palette, h, wl=0.45, dark=1.0, th=None):
    px = img.load()
    for (x, y), role in mat.items():
        if not (0 <= x < img.width and 0 <= y < img.height):
            continue
        if not paintable(x, y):
            continue
        s = sky_at(x, y)
        c = role_colour(role, s, h, wl, dark, th)
        px[x, y] = nearest(c, palette, exclude=(s,))


def row_sky(img, sky_set, x0, x1, last_default):
    """Dominant sky colour of each row (dithered band edges pick one side)."""
    px = img.load()
    rows = []
    last = last_default
    for y in range(img.height):
        cnt = {}
        for x in range(x0, x1):
            c = px[x, y]
            if c in sky_set:
                cnt[c] = cnt.get(c, 0) + 1
        if cnt:
            last = max(cnt, key=cnt.get)
        rows.append(last)
    return rows


# ------------------------------------------------------------------ 1. title
def mock_title():
    src = load1x(BUILD + "/title_highbank_1x.png")
    img = src.copy()
    sp = src.load()
    SKY = {hx(c) for c in ["#1e302e", "#263d3a", "#33524e", "#43665a", "#61785c", "#9f946d", "#dca562"]}
    HILL = {hx(c) for c in ["#4f6858", "#303e37", "#44421a", "#1d2925"]}
    hill_top = []
    for x in range(img.width):
        ht = img.height
        for y in range(98, img.height):
            if sp[x, y] in HILL:
                ht = y
                break
        hill_top.append(ht)

    def is_cloud(x, y):
        c = sp[x, y]
        if c in (hx("#9f946d"), hx("#dca562")) and y < 99:
            return True
        if c == hx("#61785c") and y < 86:
            return True
        return False

    def paintable(x, y):
        return sp[x, y] in SKY and not is_cloud(x, y) and y < hill_top[x] and y >= 54

    rows = row_sky(src, SKY, 100, 280, hx("#1e302e"))
    palette = [hx(c) for c in [
        "#1e302e", "#263d3a", "#33524e", "#43665a", "#61785c", "#9f946d", "#dca562", "#4f6858",
        "#303e37", "#1d2925", "#192726", "#44421a", "#6b6d45", "#6b6f1d", "#908940", "#5f5e57",
        "#5d4b34", "#663f23", "#7c4a26", "#8c6545", "#3f2716", "#c7a378", "#8e7f5e", "#9c8c68"]]
    title_pal = pal("highbank_title.png")
    assert all(c in title_pal for c in palette)
    mat = build_tree(cx=186, top=56, cb=96, ground=150, wd=72, tw_top=8, tw_base=11, seed=7, lean=5,
                     th_k=1.4, dither_u=0.45)
    # wl low: no gold rims on the title shelves, or they read as the gold-edged clouds
    paint_tree(img, mat, paintable, lambda x, y: rows[y], palette, h=0.5, wl=0.1, dark=0.9, th=0.45)
    n = count_colours(img)
    print("title colours after:", n, "(limit 48)")
    save(img, "title_tree")
    return img


# ------------------------------------------------------------------ 2. vista
def mock_vista():
    src = load1x(BUILD + "/round2/13_road_vista.png")
    img = src.copy()
    sp = src.load()
    SKY = {hx(c) for c in ["#56708e", "#6a84a0", "#879db0", "#a9b5ba", "#cdc6b4", "#e4cba6", "#f0d59f", "#f7e3b5"]}
    FAR = {hx(c) for c in ["#b8c2bc", "#a3b0ae"]}
    hill_top = []
    for x in range(img.width):
        ht = img.height
        for y in range(100, img.height):
            if sp[x, y] in FAR or sp[x, y] in (hx("#93a77a"), hx("#7f9467")):
                ht = y
                break
        hill_top.append(ht)

    def paintable(x, y):
        return sp[x, y] in SKY and y < hill_top[x]

    rows = row_sky(src, SKY, 60, 230, hx("#56708e"))
    palette = pal("dawn.png") + [hx("#4a5e73"), hx("#3a4a60")] + sorted(SKY)
    mat = build_tree(cx=140, top=26, cb=88, ground=148, wd=76, tw_top=8, tw_base=12, seed=11, lean=5,
                     th_k=1.3, dither_u=0.5)
    paint_tree(img, mat, paintable, lambda x, y: rows[y], palette, h=0.55, dark=0.95, th=0.5)
    # the upper river glinting at the island's foot, inside the pale far-hill band
    px = img.load()
    for x in range(92, 200):
        y = hill_top[x] + 1
        if y < img.height and sp[x, y] in FAR:
            px[x, y] = hx("#f6e6c0") if (x * 7) % 11 == 0 else hx("#c2d4df")
            if y + 1 < img.height and sp[x, y + 1] in FAR and x % 3 == 0:
                px[x, y + 1] = hx("#abc2d3")
    save(img, "vista_tree")
    return img


# ------------------------------------------------------------------ 3. reveal top hold
HOR = 150


def mock_hold():
    src = load1x(BUILD + "/round2/11_reveal_hold_top.png")
    img = src.copy()
    sp = src.load()
    px = img.load()
    LAD = ["#2e3b52", "#3a4a60", "#4a5e73", "#566c80", "#62788a", "#7f939a", "#a3a891", "#c2b58f", "#d9bf94"]
    SKY = {hx(c) for c in LAD}

    def paintable(x, y):
        if not (0 <= x < img.width and 0 <= y < img.height):
            return False
        if sp[x, y] in SKY:
            return True
        # the two thin cloud strips that sat low in the old frame are now land
        return y >= HOR - 8 and (x < 107 or x > 226)

    band = [sp[240, y] for y in range(img.height)]

    def sky_at(x, y):
        return band[y] if y < HOR else hx("#7f939a")

    rng = random.Random(3)
    # far ridge on the horizon
    ridge = [HOR - int(2 + 3 * abs(math.sin(x / 23.0)) + 2 * abs(math.sin(x / 9.0 + 1))) for x in range(img.width)]
    LAND = [(HOR, "#838e87", "#758789"), (158, "#748471", "#596d6f"), (170, "#6f8455", "#565b40"),
            (186, "#59753c", "#3d542b"), (202, "#4b6731", "#2d3729")]

    def land_band(y):
        idx = 0
        for i, (y0, _, _) in enumerate(LAND):
            if y >= y0:
                idx = i
        return idx

    for y in range(HOR - 8, img.height):
        for x in range(img.width):
            if not paintable(x, y):
                continue
            if y < HOR:
                if y >= ridge[x]:
                    px[x, y] = hx("#a0adb0") if y == ridge[x] else hx("#7a8993")
                continue
            i = land_band(y)
            c = hx(LAND[i][1])
            # one dithered row at each band edge
            if i > 0 and y == LAND[i][0] and (x + y) % 2 == 0:
                c = hx(LAND[i - 1][1])
            px[x, y] = c
    # woods and field dabs, bigger when nearer
    for _ in range(260):
        y = rng.randint(HOR + 1, img.height - 1)
        x = rng.randint(0, img.width - 1)
        i = land_band(y)
        size = 1 + (y - HOR) // 22
        dark = hx(LAND[i][2])
        for dy in range(size):
            for dx in range(size + 1 + (y - HOR) // 30):
                xx, yy = x + dx, y + dy
                if xx < img.width and yy < img.height and paintable(xx, yy):
                    px[xx, yy] = dark

    # far channel behind the island
    for x in range(0, 96):
        y = HOR + 3 + int(1.5 * math.sin(x / 13.0))
        if paintable(x, y):
            px[x, y] = hx("#c2d4df") if x % 9 else hx("#f6e6c0")

    # near channel of the upper river: from the left horizon, past the island's foot,
    # down toward Highbank (it runs on behind the Reach's shaft)
    river = [(0, 161), (28, 172), (62, 178), (95, 184), (118, 193), (150, 204), (176, 216)]
    rsamp = polyline_samples(river)
    for (x, y) in rsamp:
        hw = 1 + (y - HOR) / 14.0
        for xx in range(int(x - hw), int(x + hw) + 1):
            yy = int(y)
            if 0 <= xx < img.width and yy < img.height and paintable(xx, yy):
                px[xx, yy] = hx("#c2d4df")
        for xx in (int(x - hw) - 1, int(x + hw) + 1):
            yy = int(y) + 1
            if 0 <= xx < img.width and yy < img.height and paintable(xx, yy) and px[xx, yy] != hx("#c2d4df"):
                px[xx, yy] = hx("#7a95a5")
    for (x, y) in rsamp[::9]:
        if paintable(int(x), int(y)):
            px[int(x), int(y)] = hx("#f6e6c0")

    # the root's line: from up here you see it break the surface in humps, in a
    # straight run from behind the shaft to the island; at the river its back
    # shows at low water (foam on the upstream side)
    root = [(128, 215), (104, 199), (81, 181), (66, 175), (55, 171)]
    WATER = (hx("#c2d4df"), hx("#f6e6c0"), hx("#7a95a5"))
    for idx, (x, y) in enumerate(polyline_samples(root, 0.4)):
        along = idx * 0.4
        surfaced = (along % 20) < 12
        wdt = 1 + int((y - HOR) / 24)
        xi, yi = int(round(x)), min(img.height - 1, int(round(y)))
        in_river = px[xi, yi] in WATER
        for j in range(-wdt, wdt + 1):
            yy = yi + j
            if not (0 <= xi < img.width and yy < img.height) or not paintable(xi, yy):
                continue
            if in_river or px[xi, yy] in WATER:
                px[xi, yy] = hx("#886346") if j < 0 else hx("#796145")
                if j == -wdt and yy - 1 >= 0:
                    px[xi, yy - 1] = hx("#deded0")
            elif surfaced:
                if j == -wdt:
                    px[xi, yy] = hx("#73734d") if (xi + yy) % 4 == 0 else hx("#886346")
                elif j == wdt:
                    px[xi, yy] = hx("#2d3729")
                else:
                    px[xi, yy] = hx("#796145")
            elif j == 0:
                px[xi, yy] = hx("#565b40")        # buried stretch: only a faint seam
    # darker growth along the root's line
    for (x, y) in polyline_samples(root, 6.0)[1:-1]:
        for (dx, dy) in ((2, -2), (-3, 2)):
            if paintable(int(x) + dx, int(y) + dy):
                px[int(x) + dx, int(y) + dy] = hx("#3d542b")

    mat = build_tree(cx=44, top=72, cb=122, ground=168, wd=54, tw_top=6, tw_base=9, seed=5, lean=4,
                     arches=True, arch_r=(7.0, 5.0), th_k=1.3, dither_u=0.5)
    palette = pal("dawn.png") + [hx(c) for c in LAD]
    paint_tree(img, mat, paintable, sky_at, palette, h=0.45, th=0.4)

    # low cloud below the climber: soft lens streaks, which say "you are above this"
    for (x0, x1, y, thick) in [(236, 330, 166, 3), (250, 372, 189, 4), (300, 350, 178, 2)]:
        for x in range(x0, x1):
            t = (x - x0) / float(x1 - x0)
            half = thick * math.sin(math.pi * t) ** 0.6 / 2.0
            ys = range(int(round(y - half)), int(round(y + half)) + 1)
            for k, yy in enumerate(ys):
                if paintable(x, yy):
                    px[x, yy] = hx("#deded0") if k == 0 else hx("#c2d4df")
    print("hold colours:", count_colours(img), "(sky slot limit 32; this count includes the Tower)")
    save(img, "hold_tree")
    return img


# ------------------------------------------------------------------ 4. map
def font():
    try:
        return ImageFont.load_default_imagefont()
    except Exception:
        return ImageFont.load_default()


def mock_map():
    W, H = 384, 320
    img = Image.new("RGB", (W, H), hx("#6f8455"))
    d = ImageDraw.Draw(img)
    px = img.load()
    f = font()
    rng = random.Random(9)
    # land texture
    for _ in range(1400):
        x, y = rng.randrange(W), rng.randrange(H)
        px[x, y] = hx("#748471") if rng.random() < 0.6 else hx("#59753c")
    # 1 px = 2 tiles. Street origin (tile 0,0) at map (268,254)
    def T(c, r):
        return (268 + c / 2.0, 254 + r / 2.0)

    # rivers: upper river from the north, split around the island, bend at Highbank's west, east along the south
    def river(pts, wdt, col=hx("#7a95a5"), mid=hx("#abc2d3")):
        for (x, y) in polyline_samples(pts, 0.5):
            d.ellipse([x - wdt, y - wdt, x + wdt, y + wdt], fill=col)
        for (x, y) in polyline_samples(pts, 0.5):
            if wdt >= 2:
                d.point((x, y), fill=mid)

    river([(182, -4), (188, 18)], 3)
    river([(188, 18), (160, 34), (154, 60), (170, 86), (206, 100)], 2)   # west channel
    river([(188, 18), (228, 30), (240, 58), (226, 88), (206, 100)], 2)   # east channel
    river([(206, 100), (222, 150), (238, 205), (250, 248), (262, 268), (300, 274), (340, 276), (390, 278)], 3)
    # island and the great tree
    d.ellipse([168, 34, 230, 86], fill=hx("#59753c"), outline=hx("#3d542b"))
    tx, ty = 200, 58
    for y in range(ty - 39, ty + 40):
        for x in range(tx - 39, tx + 40):
            if (x - tx) ** 2 + (y - ty) ** 2 <= 39 ** 2 and (x + y) % 2 == 0 and 0 <= y < H:
                px[x, y] = hx("#3d542b")
    for a in range(0, 360, 6):
        x = tx + 39 * math.cos(math.radians(a))
        y = ty + 39 * math.sin(math.radians(a))
        d.point((x, y), fill=hx("#2d3729"))
    d.ellipse([tx - 6, ty - 6, tx + 6, ty + 6], fill=hx("#886346"), outline=hx("#45502d"))

    # Highbank
    d.rectangle([*T(0, 0), *T(56, 16)], fill=hx("#c9b38e"), outline=hx("#8d6c4d"))      # Street
    d.rectangle([*T(34, -14), *T(60, 0)], fill=hx("#debb76"), outline=hx("#8d6c4d"))    # Tower Rise
    d.rectangle([*T(40, 16), *T(74, 32)], fill=hx("#b79b75"), outline=hx("#8d6c4d"))    # Ferry Ward
    d.rectangle([*T(56, 1), *T(86, 15)], fill=hx("#c1ac88"), outline=hx("#8d6c4d"))     # East Quarter
    river([(262, 268), (300, 271), (340, 271), (390, 272)], 2)  # water rows of the Ferry Ward
    tower = T(34 + 12.5, -14 + 6.5)
    d.rectangle([tower[0] - 3, tower[1] - 2, tower[0] + 3, tower[1] + 1], fill=hx("#f6e6c0"), outline=hx("#45502d"))
    lamp = (tower[0] + 2, tower[1] - 1)
    d.point(lamp, fill=hx("#e4bd6c"))

    # the root: surfaces in Tower Rise's west lane, underground under the land,
    # its back shows across the river at low water, then up onto the island
    entry = T(34 + 4, -14 + 8)            # Rise tile (4,8)
    corner = T(34 + 0.5, -14 + 0.5)       # Rise NW corner, under the hedge
    under = [corner, (262, 200), (240, 150), (226, 116), (214, 103)]
    island_leg = [(214, 103), (206, 82), (203, 64)]
    for (x0, y0), (x1, y1) in zip(under, under[1:]):
        for i, (x, y) in enumerate(line_pts(x0, y0, x1, y1)):
            if (i // 3) % 2 == 0:
                d.point((x, y), fill=hx("#4b392a"))
                d.point((x + 1, y), fill=hx("#886346"))
    for (x0, y0), (x1, y1) in zip(island_leg, island_leg[1:]):
        for (x, y) in line_pts(x0, y0, x1, y1):
            d.point((x, y), fill=hx("#886346"))
            d.point((x + 1, y), fill=hx("#4b392a"))
    for (x, y) in line_pts(*entry, *corner):
        d.point((x, y), fill=hx("#663f23"))
        d.point((x, y + 1), fill=hx("#663f23"))
    # low-water crossing bar where the root passes under the rejoined river
    for (x, y) in line_pts(207, 99, 221, 107):
        d.point((x, y), fill=hx("#3f2716"))
        d.point((x, y - 1), fill=hx("#deded0"))

    # title camera on the south bank, looking north-north-west
    vx, vy = 283, 300
    d.rectangle([vx - 1, vy - 1, vx + 1, vy + 1], fill=hx("#f6e6c0"))
    for bearing in (-56, 21):
        a = math.radians(bearing)
        for i, (x, y) in enumerate(line_pts(vx, vy, vx + 70 * math.sin(a), vy - 70 * math.cos(a))):
            if i % 3 == 0:
                d.point((x, y), fill=hx("#f6e6c0"))
    def label(x, y, s, col=hx("#f6e6c0"), sh=hx("#2d3729")):
        d.text((x + 1, y + 1), s, font=f, fill=sh)
        d.text((x, y), s, font=f, fill=col)

    label(4, 4, "CONCEPT A: ACROSS THE WATER (proposal)")
    label(4, 16, "north up, 1 px = 2 tiles")
    # scale bar: 100 tiles = 50 px
    d.rectangle([4, 32, 54, 34], fill=hx("#f6e6c0"))
    d.rectangle([4, 32, 29, 34], fill=hx("#2d3729"))
    label(58, 29, "100 tiles")
    label(238, 40, "THE GREAT TREE", hx("#f6e6c0"))
    label(238, 51, "(working label)", hx("#deded0"))
    label(238, 62, "on a river island", hx("#deded0"))
    label(238, 73, "110-130 tiles tall", hx("#deded0"))
    label(108, 104, "root shows at", hx("#deded0"))
    label(108, 114, "low water", hx("#deded0"))
    label(250, 150, "root runs", hx("#deded0"))
    label(250, 160, "underground", hx("#deded0"))
    label(250, 170, "380-480 tiles", hx("#f6e6c0"))
    label(300, 236, "HIGHBANK", hx("#f6e6c0"))
    label(300, 246, "(inset)", hx("#deded0"))
    label(292, 304, "title camera", hx("#f6e6c0"))
    label(84, 128, "upper river runs south", hx("#deded0"))
    label(84, 138, "to Highbank, bends east", hx("#deded0"))
    label(84, 148, "under the bluff", hx("#deded0"))
    d.polygon([(370, 6), (366, 16), (374, 16)], fill=hx("#f6e6c0"))
    label(367, 18, "N")

    # ---- Highbank inset, 2 px = 1 tile, north up
    ix0, iy0, ix1, iy1 = 4, 186, 206, 316
    d.rectangle([ix0, iy0, ix1, iy1], fill=hx("#748471"), outline=hx("#f6e6c0"))

    def S(c, r):  # Street tile -> inset px
        return (24 + 2 * c, 232 + 2 * r)

    d.rectangle([*S(40, 16), *S(74, 32)], fill=hx("#b79b75"), outline=hx("#8d6c4d"))   # Ferry Ward
    for (x0, y0, x1, y1) in [(14, 190, 14, 292), (14, 292, 40, 300), (40, 300, 205, 300)]:
        for (x, y) in line_pts(x0, y0, x1, y1):
            d.rectangle([x - 3, y - 3, x + 3, y + 3], fill=hx("#7a95a5"))
    for (x0, y0, x1, y1) in [(14, 190, 14, 292), (14, 292, 40, 300), (40, 300, 205, 300)]:
        for (x, y) in line_pts(x0, y0, x1, y1):
            d.point((x, y), fill=hx("#abc2d3"))
    d.rectangle([*S(0, 0), *S(56, 16)], fill=hx("#c9b38e"), outline=hx("#8d6c4d"))     # Street
    d.rectangle([*S(34, -14), *S(60, 0)], fill=hx("#debb76"), outline=hx("#8d6c4d"))   # Tower Rise
    d.rectangle([*S(56, 1), *S(86, 15)], fill=hx("#c1ac88"), outline=hx("#8d6c4d"))    # East Quarter
    d.rectangle([*S(41, -8), *S(53, -5)], fill=hx("#f6e6c0"), outline=hx("#45502d"))   # Tower base
    d.point(S(52, -9), fill=hx("#e4bd6c"))                                             # lamp side
    d.rectangle([*S(38, -13), *S(41, -6)], fill=hx("#886346"), outline=hx("#45502d"))  # root foot
    # proposed root ridge across the west lane, NW corner to tile (4,8)
    for (x, y) in line_pts(*S(34.5, -13.5), *S(38, -6)):
        d.rectangle([x, y, x + 1, y + 1], fill=hx("#663f23"))
        d.point((x - 1, y), fill=hx("#c49b69"))
    for i, (x, y) in enumerate(line_pts(*S(34.5, -13.5), *S(31, -18))):
        if i % 3 < 2:
            d.point((x, y), fill=hx("#4b392a"))
    lk = S(1, 11)
    d.rectangle([lk[0] - 1, lk[1] - 1, lk[0] + 1, lk[1] + 1], fill=hx("#e4bd6c"))
    post = S(36, -4)
    d.point(post, fill=hx("#e4bd6c"))
    dock = S(70, 28)
    d.rectangle([dock[0] - 2, dock[1], dock[0] + 2, dock[1] + 2], fill=hx("#5d4b34"))

    label(8, 188, "HIGHBANK, 2 px = 1 tile")
    label(146, 202, "TOWER RISE")
    label(8, 200, "root from")
    label(8, 210, "the great")
    label(8, 220, "tree (NNW)")
    label(36, 238, "STREET")
    label(146, 242, "EAST QTR")
    label(110, 268, "FERRY WARD")
    label(22, 268, "Bluff Lookout", hx("#e4bd6c"))
    label(22, 278, "sees the tree", hx("#e4bd6c"))
    label(112, 304, "ferry upriver?", hx("#f6e6c0"))
    save(img, "map")
    return img


# ------------------------------------------------------------------ 5. root profile (for the cx-12 re-brief)
def tube(img, pts, radii, ox, oy):
    """Shaded bark tube along a polyline; radius interpolated per sample."""
    px = img.load()
    samp = polyline_samples(pts, 0.5)
    n = len(samp)
    rs = [radii[0] + (radii[1] - radii[0]) * i / max(1, n - 1) for i in range(n)]
    xs = [p[0] for p in samp]
    ys = [p[1] for p in samp]
    x0, x1 = int(min(xs) - max(rs) - 2), int(max(xs) + max(rs) + 2)
    y0, y1 = int(min(ys) - max(rs) - 2), int(max(ys) + max(rs) + 2)
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            best = None
            for i in range(0, n, 2):
                dd = (x - samp[i][0]) ** 2 + (y - samp[i][1]) ** 2
                if best is None or dd < best[0]:
                    best = (dd, i)
            dd, i = best
            r = rs[i]
            dist = math.sqrt(dd)
            if dist > r + 0.5:
                continue
            j = min(n - 1, i + 2)
            tx_, ty_ = samp[j][0] - samp[max(0, i - 2)][0], samp[j][1] - samp[max(0, i - 2)][1]
            tl = math.hypot(tx_, ty_) or 1
            nx, ny = ty_ / tl, -tx_ / tl          # left normal
            if ny > 0:
                nx, ny = -nx, -ny                  # make it point up
            proj = ((x - samp[i][0]) * nx + (y - samp[i][1]) * ny) / max(1, r)
            if dist > r - 1:
                c = "#3f2716"
            elif proj > 0.55:
                c = "#c49b69"
            elif proj < -0.45:
                c = "#663f23"
            else:
                c = "#b06b3d"
            X, Y = ox + x, oy + y
            if 0 <= X < img.width and 0 <= Y < img.height:
                px[X, Y] = hx(c)


def mock_root_profile():
    W, H = 384, 300
    img = Image.new("RGB", (W, H), hx("#2d3729"))
    d = ImageDraw.Draw(img)
    f = font()

    def label(x, y, s, col=hx("#f6e6c0")):
        d.text((x, y), s, font=f, fill=col)

    def cell(ox, oy):
        d.rectangle([ox, oy, ox + 95, oy + 119], fill=hx("#6f8455"))
        p = img.load()
        for yy in range(oy, oy + 120):
            for xx in range(ox, ox + 96):
                if (xx * 5 + yy * 3) % 17 == 0:
                    p[xx, yy] = hx("#59753c")

    label(4, 3, "ROOT FOOT 96x120: cx-12 today vs proposal (both schematic)")
    # left: today, flared base and a footing stone, own base inside the cell
    ox, oy = 14, 18
    cell(ox, oy)
    tube(img, [(10, 108), (40, 70), (70, 32), (90, 8)], (10, 8), ox, oy)
    for (a, b) in [((8, 110), (0, 118)), ((10, 112), (6, 119)), ((14, 110), (20, 119)), ((6, 106), (0, 110))]:
        for (x, y) in line_pts(ox + a[0], oy + a[1], ox + b[0], oy + b[1]):
            d.rectangle([x, y, x + 1, y + 1], fill=hx("#7c4a26"))
    d.ellipse([ox + 20, oy + 108, ox + 32, oy + 118], fill=hx("#9c8c68"), outline=hx("#5f5e57"))
    tube(img, [(52, 54), (60, 84), (62, 112)], (4, 3), ox, oy)
    label(ox, oy + 123, "TODAY: own base,")
    label(ox, oy + 133, "stone, flare.")
    label(ox, oy + 143, "Touches west edge")
    label(ox, oy + 153, "rows 107-119 only")

    # right: proposal, arrives through the west edge at full width
    ox2 = 200
    cell(ox2, oy)
    tube(img, [(-30, 96), (0, 82), (34, 58), (66, 30), (90, 8)], (20, 15), ox2, oy)
    tube(img, [(52, 48), (60, 84), (62, 112)], (4, 3), ox2, oy)
    p = img.load()
    # torn turf lip along both edges where the half-buried root breaks out of the ground
    for x in range(0, 26):
        fade = x / 26.0
        yt = int(round(62 - 0.62 * x))          # top edge of the tube
        lip = 3 if fade < 0.6 else 2
        for y in range(yt - lip, yt + 2):
            p[ox2 + x, oy + y] = hx("#908940") if y == yt - lip else hx("#6b6f1d")
        p[ox2 + x, oy + yt + 2] = hx("#23180e")
        if x < 20:
            yb = int(round(102 - 0.62 * x))     # bottom edge of the tube
            for y in range(yb - 1, yb + 3):
                p[ox2 + x, oy + y] = hx("#6b6f1d") if y > yb - 1 else hx("#23180e")
    # clip anything the tube drew west of the cell
    d.rectangle([ox2 - 70, oy, ox2 - 1, oy + 119], fill=hx("#2d3729"))
    for i, (x, y) in enumerate(line_pts(ox2 - 4, oy + 84, ox2 - 36, oy + 100)):
        if i % 3 < 2:
            p[x, y] = hx("#f6e6c0")
    label(ox2 - 74, oy + 104, "from the")
    label(ox2 - 74, oy + 114, "great tree")
    label(ox2, oy + 123, "PROPOSAL: leaves the")
    label(ox2, oy + 133, "west edge at full width,")
    label(ox2, oy + 143, "under a torn-turf lip.")
    label(ox2, oy + 153, "No stone, no flare.")

    # thickness profile along the whole root, foot to hook
    stations = ["foot in", "foot top", "vein low", "vein top", "collar", "y84", "curl", "hook"]
    now = [18, 17, 17, 9, 37, 24, 20, 16]
    prop = [38, 36, 32, 26, 30, 24, 18, 12]
    label(4, 200, "THICKNESS in px along the root, foot to hook")
    for row, vals, col, name in ((0, now, "#b06b3d", "today"), (1, prop, "#c49b69", "proposal")):
        cy = 230 + row * 34
        for i in range(len(vals) - 1):
            xa, xb = 14 + i * 42, 14 + (i + 1) * 42
            for x in range(xa, xb + 1):
                t = (x - xa) / 42.0
                hh = (vals[i] + (vals[i + 1] - vals[i]) * t) / 4.0
                d.line([(x, cy - hh), (x, cy + hh)], fill=hx(col))
                d.point((x, cy - hh), fill=hx("#3f2716"))
                d.point((x, cy + hh), fill=hx("#3f2716"))
        for i, v in enumerate(vals):
            label(14 + i * 42 - 4, cy - 22, str(v))
        label(14 + 7 * 42 + 8, cy - 4, name, hx("#deded0"))
    for i, s in enumerate(stations):
        label(6 + i * 42, H - 20 + (i % 2) * 10, s, hx("#deded0"))
    save(img, "root_profile")
    return img


if __name__ == "__main__":
    mock_title()
    mock_vista()
    mock_hold()
    mock_map()
    mock_root_profile()
