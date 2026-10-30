"""Great tree, concept B "Over the bluff": design mocks (proposal only).

Paints the great tree into four existing renders and draws a map sketch.
Hard pixels only: every shape is stamped pixel by pixel, no anti-aliasing,
and every colour comes from the palettes already in use (wayline_tower,
highbank_title, dawn) or from the source render itself. Each mock is saved
at 1x and at 3x (nearest neighbour).

Run:  python mock_b-bluff.py
Reads from docs/design/wayline-tower-2026-10-27/build/ (never writes there).
"""
import math
import random
from PIL import Image, ImageDraw, ImageFont

HERE = "C:/Users/pmcga/dev/hollowtide/docs/design/great-tree-2026-10-27/concept_b-bluff"
BUILD = "C:/Users/pmcga/dev/hollowtide/docs/design/wayline-tower-2026-10-27/build"
FONT = "C:/Users/pmcga/dev/hollowtide/assets/fonts/Silkscreen-Regular.ttf"

# Real size of the great tree, in tiles (1 tile = 24 px). Proposal numbers.
TREE_H = 96        # base to crown top
TRUNK_W = 10       # trunk width at chest height
SHELF_1 = 22       # lowest shelf of foliage, height above the base


def C(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def setp(lp, size, x, y, c):
    x = int(round(x))
    y = int(round(y))
    if 0 <= x < size[0] and 0 <= y < size[1]:
        lp[x, y] = c


def disc(lp, size, cx, cy, r, c):
    ri = int(math.ceil(r)) + 1
    for dy in range(-ri, ri + 1):
        for dx in range(-ri, ri + 1):
            if dx * dx + dy * dy <= r * r + 0.35:
                setp(lp, size, cx + dx, cy + dy, c)


def chaikin(pts, n=2):
    for _ in range(n):
        out = [pts[0]]
        for a, b in zip(pts, pts[1:]):
            out.append((a[0] * 0.75 + b[0] * 0.25, a[1] * 0.75 + b[1] * 0.25))
            out.append((a[0] * 0.25 + b[0] * 0.75, a[1] * 0.25 + b[1] * 0.75))
        out.append(pts[-1])
        pts = out
    return pts


def walk(pts, step=0.5):
    """Points along a polyline with their fraction of the total length."""
    seg = [math.dist(a, b) for a, b in zip(pts, pts[1:])]
    total = sum(seg) or 1
    out = []
    run = 0.0
    for (a, b), L in zip(zip(pts, pts[1:]), seg):
        n = max(1, int(L / step))
        for i in range(n):
            t = i / n
            out.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t,
                        (run + L * t) / total))
        run += L
    out.append((pts[-1][0], pts[-1][1], 1.0))
    return out


def tube(L, pts, r0, r1, P, seed, moss=True, shadow=None, treads=None, bury=None, humps=()):
    """A shaded root or limb: under-shadow, body, lit top band, bark furrows
    that run along its length, moss specks on top.

    pts is the line where the root meets the ground. bury (0..1) sinks the
    root into the ground: everything below that line is erased so the real
    ground in the render shows, and a dark contact line is drawn. humps is a
    list of (f0, f1, lift_px): stretches where the root arches up out of the
    ground, leaving a gap under it with a shadow on the ground."""
    lp = L.load()
    size = L.size
    rnd = random.Random(seed)
    base = walk(chaikin(pts, 3))
    rad = lambda f: r0 + (r1 - r0) * f

    def lift(f):
        a = 0.0
        for f0, f1, A in humps:
            if f0 < f < f1:
                a = max(a, A * math.sin(math.pi * (f - f0) / (f1 - f0)))
        return a
    path = [(x, y - lift(f), f) for x, y, f in base]
    # unit normals (pointing "down" the screen side) for furrows
    norms = []
    for i in range(len(path)):
        a = path[max(0, i - 3)]
        b = path[min(len(path) - 1, i + 3)]
        tx, ty = b[0] - a[0], b[1] - a[1]
        n = math.hypot(tx, ty) or 1
        nx, ny = -ty / n, tx / n
        if ny < 0:
            nx, ny = -nx, -ny
        norms.append((nx, ny))
    if shadow:
        for x, y, f in path:
            disc(lp, size, x + 1, y + rad(f) * 0.55 + 1.5, rad(f) * 0.8, shadow)
    for x, y, f in path:
        disc(lp, size, x, y + 1, rad(f) + 0.6, P["r_out"])
    for x, y, f in path:
        disc(lp, size, x, y, rad(f), P["r_dark"])
    for x, y, f in path:
        r = rad(f)
        disc(lp, size, x, y - r * 0.18, r * 0.78, P["r_body"])
    for x, y, f in path:
        r = rad(f)
        disc(lp, size, x - r * 0.1, y - r * 0.5, max(0.6, r * 0.36), P["r_lit"])
    # bark furrows running along the root, broken into plates
    for off, col in ((-0.62, "r_body"), (-0.2, "r_dark"), (0.22, "r_dark"), (0.58, "r_out")):
        run = 0
        for (x, y, f), (nx, ny) in zip(path, norms):
            r = rad(f)
            if r < 2.5:
                continue
            run -= 1
            if run < -rnd.randint(6, 14):
                run = rnd.randint(4, 10)
            if run > 0:
                setp(lp, size, x + nx * off * r, y + ny * off * r, P[col])
    # knots
    for _ in range(max(1, len(path) // 90)):
        x, y, f = path[rnd.randint(len(path) // 6, len(path) - 1 - len(path) // 6)]
        r = rad(f)
        if r >= 3:
            kr = max(1.0, min(2.2, r * 0.11))
            disc(lp, size, x, y - r * 0.1, kr + 0.8, P["r_dark"])
            disc(lp, size, x, y - r * 0.1, kr - 0.6, P["r_out"])
            setp(lp, size, x - 1, y - r * 0.1 - kr - 1, P["r_lit"])
            setp(lp, size, x, y - r * 0.1 - kr - 1, P["r_lit"])
    if bury is not None:
        for x, y, f in base:
            r = rad(f)
            cut = y + r * (1 - 2 * bury)
            for xx in (int(round(x)) - 1, int(round(x)), int(round(x)) + 1):
                for yy in range(int(round(cut)) + 1, int(round(cut + r * 2 + 4))):
                    if 0 <= xx < size[0] and 0 <= yy < size[1]:
                        lp[xx, yy] = (0, 0, 0, 0)
        for x, y, f in base:
            r = rad(f)
            cut = y + r * (1 - 2 * bury)
            setp(lp, size, x, cut, P["r_out"])
            if lift(f) > r * 0.6:
                setp(lp, size, x, cut - 1, P.get("r_gap", P["r_out"]))
    if moss:
        for x, y, f in path[::2]:
            r = rad(f)
            if rnd.random() < 0.45:
                setp(lp, size, x, y - r + 0.4, P["r_moss"])
                if r > 4 and rnd.random() < 0.5:
                    setp(lp, size, x + 1, y - r + 1.4, P["r_moss2"])
    if treads:
        for tx in treads:
            # nearest path point to this x: cut a worn step across the top
            best = min(path, key=lambda q: abs(q[0] - tx))
            x, y, f = best
            r = rad(f)
            for k in range(-2, 3):
                setp(lp, size, x + k, y - r + 1, P["tread"])
                setp(lp, size, x + k, y - r + 2, P["tread2"])
    return path


def shelf(L, cx, yb, hw, th, P, seed, droop=None):
    """One flat tier of the crown: domed clumpy top, flat drooping underside,
    warm-lit under rim and hanging moss curtains."""
    lp = L.load()
    size = L.size
    rnd = random.Random(seed)
    droop = max(2, th * 0.35) if droop is None else droop
    bumps = []
    x = cx - hw
    while x < cx + hw:
        r = rnd.randint(max(2, int(th * 0.28)), max(3, int(th * 0.55)))
        bumps.append((x, r))
        x += r * 1.4 + rnd.randint(0, 2)

    def top_at(xx):
        t = (xx - cx) / hw
        y = yb - th * (1 - 0.6 * t * t)
        b = 0
        for bx, r in bumps:
            d = abs(xx - bx)
            if d < r:
                b = max(b, math.sqrt(r * r - d * d) * 0.55)
        return y - b

    cols = {}
    for xx in range(int(cx - hw), int(cx + hw) + 1):
        t = (xx - cx) / hw
        if abs(t) > 1:
            continue
        ybot = yb + droop * t * t + (1 if rnd.random() < 0.15 else 0)
        ytop = top_at(xx)
        if abs(t) > 0.9:
            ytop = max(ytop, ybot - th * 0.35)
        cols[xx] = (int(round(ytop)), int(round(ybot)))
        for yy in range(cols[xx][0], cols[xx][1] + 1):
            setp(lp, size, xx, yy, P["c_body"])
    # clump arcs inside the body (leaf masses), lit on their upper rim
    n = int(hw * th / 26)
    for _ in range(n):
        xx = rnd.randint(int(cx - hw * 0.9), int(cx + hw * 0.9))
        if xx not in cols:
            continue
        yt, ybot = cols[xx]
        if ybot - yt < 6:
            continue
        yy = rnd.randint(yt + 3, max(yt + 3, ybot - 4))
        r = rnd.randint(2, 4)
        for dx in range(-r, r + 1):
            dy = int(round(math.sqrt(max(0, r * r - dx * dx))))
            if (xx + dx) in cols and cols[xx + dx][0] < yy - dy < cols[xx + dx][1] - 2:
                setp(lp, size, xx + dx, yy - dy, P["c_mid"])
    # rims: lit top, dark band above the underside, warm under rim
    for xx, (yt, ybot) in cols.items():
        setp(lp, size, xx, yt, P["c_lit"])
        if rnd.random() < 0.55:
            setp(lp, size, xx, yt + 1, P["c_lit2"])
        for yy in range(max(yt + 2, ybot - 3), ybot):
            setp(lp, size, xx, yy, P["c_dark"])
        setp(lp, size, xx, ybot, P["c_under"])
    # moss curtains
    for xx, (yt, ybot) in cols.items():
        if rnd.random() < 0.3:
            Ln = rnd.randint(2, max(3, int(th * 0.45)))
            for k in range(1, Ln + 1):
                setp(lp, size, xx, ybot + k, P["c_moss"] if k < Ln else P["c_moss2"])
    return cols


def buttress(L, cx, yb, w, P, spec, front):
    """One buttress root: a curved wedge from the trunk down to the ground."""
    lp = L.load()
    size = L.size
    u, hfrac, foot, fw = spec
    top = (cx + u * w * 0.5, yb - hfrac * w)
    fx = cx + foot * w * 0.5
    fl, fr = fx - fw * w * 0.5, fx + fw * w * 0.5
    ctrl = (cx + u * w * 0.35, yb - 0.15 * w)

    def bez(p0, p1, p2, t):
        return ((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
                (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])
    left = [bez(top, ctrl, (fl, yb), t / 40) for t in range(41)]
    right = [bez(top, ctrl, (fr, yb), t / 40) for t in range(41)]
    rows = {}
    for x, y in left + right:
        yy = int(round(y))
        a, b = rows.get(yy, (9999, -9999))
        rows[yy] = (min(a, int(round(x))), max(b, int(round(x))))
    lit = u < 0 or front
    for yy, (a, b) in rows.items():
        for xx in range(a, b + 1):
            setp(lp, size, xx, yy, P["t_body"] if lit else P["t_dark"])
        setp(lp, size, a, yy, P["t_lit"] if lit else P["t_body"])
        setp(lp, size, b, yy, P["t_deep"])
        if b - a > 3:
            setp(lp, size, b - 1, yy, P["t_dark"])
    # moss along the buttress spine
    for x, y in left[::3]:
        setp(lp, size, x + 1, y, P["t_moss"])


def trunk(L, cx, yb, ytop, w, P, seed, ring_step=None, lean=-0.05):
    """The bole: slightly leaning, burled edges, long bark plates, patches of
    pale lichen, moss streaks, knots; buttress roots at the foot."""
    lp = L.load()
    size = L.size
    rnd = random.Random(seed)
    span = max(1, yb - ytop)
    outer = [(-0.95, 0.55, -1.75, 0.3), (0.95, 0.5, 1.7, 0.28)]
    front = [(-0.35, 0.42, -0.95, 0.32), (0.4, 0.34, 0.85, 0.3)]
    for spec in outer:
        buttress(L, cx, yb, w, P, spec, False)
    rows = {}
    for yy in range(int(ytop), int(yb) + 1):
        h = yb - yy
        cxh = cx + lean * h
        half = w / 2 * (1 - 0.16 * h / span)
        half *= 1 + 0.3 * max(0.0, 1 - h / (w * 0.9)) ** 2
        xl = cxh - half + 1.3 * math.sin(h * 0.11 + seed) + 0.7 * math.sin(h * 0.31 + 2 * seed)
        xr = cxh + half + 1.3 * math.sin(h * 0.09 + 3 * seed) + 0.7 * math.sin(h * 0.27 + seed)
        rows[yy] = (int(round(xl)), int(round(xr)))
    for yy, (xl, xr) in rows.items():
        width = max(1, xr - xl)
        for xx in range(xl, xr + 1):
            u = (xx - xl) / width
            if u < 0.06:
                c = P["t_lit"]
            elif u < 0.5:
                c = P["t_body"]
            elif u < 0.8:
                c = P["t_dark"]
            else:
                c = P["t_deep"]
            setp(lp, size, xx, yy, c)
    # long bark plates: furrows that wander and break
    K = max(3, int(w / 5))
    for k in range(K):
        u0 = 0.1 + 0.8 * k / (K - 1) + rnd.uniform(-0.03, 0.03)
        ph = rnd.uniform(0, 6.28)
        gap = 0
        for yy, (xl, xr) in rows.items():
            if gap > 0:
                gap -= 1
                continue
            if rnd.random() < 0.035:
                gap = rnd.randint(2, 5)
                continue
            u = u0 + 0.04 * math.sin(yy * 0.045 + ph)
            col = P["t_furrow"] if u < 0.5 else P["t_deep"]
            setp(lp, size, xl + u * (xr - xl), yy, col)
    # pale lichen patches on the lit half (broken, never full rings)
    for _ in range(int(span / 7)):
        yy = rnd.randint(int(ytop) + 3, int(yb) - int(w * 0.5))
        xl, xr = rows[yy]
        x0 = xl + 1 + rnd.randint(0, max(1, int((xr - xl) * 0.25)))
        ln = rnd.randint(2, max(3, int((xr - xl) * 0.22)))
        for k in range(ln):
            if rnd.random() < 0.8:
                setp(lp, size, x0 + k, yy + (1 if (k // 3) % 2 else 0), P["t_ring"])
    # moss streaks running down the lit side from the crown
    for _ in range(max(2, int(w / 8))):
        xl, xr = rows[int(ytop)]
        x0 = xl + rnd.randint(1, max(2, int((xr - xl) * 0.45)))
        y0 = int(ytop) + rnd.randint(0, int(span * 0.3))
        for k in range(rnd.randint(4, max(5, int(span * 0.35)))):
            if rnd.random() < 0.75:
                setp(lp, size, x0 + (k // 7) % 2, y0 + k, P["t_moss"])
    # knots
    for _ in range(2):
        yy = rnd.randint(int(ytop) + int(span * 0.2), int(yb) - int(w * 0.8))
        xl, xr = rows[yy]
        kx = xl + (xr - xl) * rnd.uniform(0.25, 0.6)
        r = max(1.2, w * 0.06)
        disc(lp, size, kx, yy, r, P["t_deep"])
        setp(lp, size, kx - 1, yy - r, P["t_lit"])
    for spec in front:
        buttress(L, cx, yb, w, P, spec, True)


def limb(L, pts, r0, r1, P, seed, hook=None):
    """A great limb (bark, no moss) with an optional hooked tip."""
    Q = {"r_out": P["t_deep"], "r_dark": P["t_dark"], "r_body": P["t_body"],
         "r_lit": P["t_lit"], "r_moss": P["t_moss"], "r_moss2": P["t_moss"]}
    tube(L, pts, r0, r1, Q, seed, moss=True)
    if hook:
        hx, hy, hr, side = hook
        lp = L.load()
        for a in range(0, 200, 4):
            ang = math.radians(a)
            x = hx + side * hr * math.sin(ang)
            y = hy - hr * (1 - math.cos(ang)) * 0.9
            disc(lp, L.size, x, y, max(1.0, r1 * (1 - a / 260)), P["t_body"])
            setp(lp, L.size, x, y - 1, P["t_lit"])


def composite(out, orig, layer, ok):
    op = out.load()
    gp = orig.load()
    lp = layer.load()
    W, H = out.size
    for y in range(H):
        for x in range(W):
            c = lp[x, y]
            if c[3] and ok(x, y, gp[x, y]):
                op[x, y] = c[:3]


def save(img, name):
    img.save(f"{HERE}/{name}_1x.png")
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f"{HERE}/{name}_3x.png")


def down3(path):
    im = Image.open(path).convert("RGB")
    return im.resize((im.width // 3, im.height // 3), Image.NEAREST)


def rgbset(*hexes):
    return {C(h)[:3] for h in hexes}


# ---------------------------------------------------------------- title
def mock_title():
    orig = Image.open(BUILD + "/title_highbank_1x.png").convert("RGB")
    out = orig.copy()
    W, H = orig.size
    s = 3.86  # px per tile for the tree (tower is 0.225 x, tree sits ~36 tiles further back)
    P = {
        "c_body": C("1d2925"), "c_dark": C("192726"), "c_lit": C("33524e"),
        "c_lit2": C("303e37"), "c_mid": C("263d3a"), "c_under": C("5d4b34"),
        "c_moss": C("303e37"), "c_moss2": C("44421a"),
        "t_lit": C("8c6545"), "t_body": C("5d4b34"), "t_dark": C("3f2716"),
        "t_deep": C("23180e"), "t_furrow": C("3f2716"), "t_ring": C("9c8c68"),
        "t_moss": C("6b6d45"),
    }
    cx, by = 205, 133
    w = TRUNK_W * s
    L = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    # back tiers first, then limbs, trunk, front tiers
    shelf(L, cx - 62, 14, 93, 26, P, 3, droop=6)
    limb(L, [(cx - 4, 70), (cx - 30, 52), (cx - 70, 44), (cx - 112, 40)], 6, 3, P, 11)
    limb(L, [(cx + 6, 66), (cx + 26, 52), (cx + 60, 44), (cx + 84, 40)], 5, 2.5, P, 12,
         hook=(cx + 84, 40, 6, 1))
    trunk(L, cx, by, 50, w, P, 5)
    shelf(L, cx - 39, 49, 100, 22, P, 1, droop=8)
    shelf(L, cx + 48, 40, 42, 17, P, 2, droop=6)

    sky = rgbset("192726", "1e302e", "263d3a", "33524e", "43665a", "61785c", "9f946d")
    far = rgbset("4f6858", "303e37")
    warm = rgbset("dca562", "f1c177", "ecb36b", "e6c697", "c7a378")

    def ok_tree(x, y, c):
        if x < 73 and y < 200:      # the near frame tree on the left stays in front
            return False
        if 280 <= x and y < 175:    # tower frame: only true sky pixels
            return c in sky
        if c in sky:
            return True
        if c in far and y < 130:
            return True
        return c in warm and y < 100 and x < 280   # clouds behind the crown
    composite(out, orig, L, ok_tree)

    # the root: leaves the trunk flare, rolls over the ridge woods, reaches the Rise
    R = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    RP = {"r_out": C("23180e"), "r_dark": C("3f2716"), "r_body": C("5d4b34"),
          "r_lit": C("8c6545"), "r_moss": C("6b6d45"), "r_moss2": C("44421a")}
    tube(R, [(cx + 16, 128), (cx + 40, 132), (cx + 58, 141), (cx + 74, 154), (cx + 88, 166)],
         5, 3, RP, 21, bury=0.3, humps=((0.04, 0.3, 5), (0.56, 0.78, 3)))
    ridge = rgbset("1d2925", "303e37", "4f6858", "44421a") | sky

    def ok_root(x, y, c):
        return c in ridge and 110 <= y < 172 and 190 <= x < 300
    composite(out, orig, R, ok_root)
    op = out.load()
    # ridge woods stand in front of the root where it dips (two crowns)
    for wx, wy, wr in ((cx + 47, 138, 4), (cx + 54, 142, 3)):
        for dy in range(-wr, wr + 1):
            for dx in range(-wr, wr + 1):
                x, y = wx + dx, wy + dy
                if dx * dx + dy * dy <= wr * wr and orig.getpixel((x, y)) in ridge:
                    top = dy == -int(math.sqrt(max(0, wr * wr - dx * dx)))
                    op[x, y] = C("303e37" if top else "1d2925")[:3]

    # keep the wordmark zone calm: no warm lights above y 46, fewer clumps
    calm = rgbset("8c6545", "9c8c68", "5d4b34")
    for y in range(0, 46):
        for x in range(90, 296):
            if orig.getpixel((x, y)) == op[x, y]:
                continue
            if op[x, y] in calm:
                op[x, y] = C("263d3a")[:3]
            elif op[x, y] == C("263d3a")[:3]:
                op[x, y] = C("1d2925")[:3]
    save(out, "title_tree")
    return out


# ---------------------------------------------------------------- vista
def mock_vista():
    orig = down3(BUILD + "/round2/13_road_vista.png")
    out = orig.copy()
    s = 3.86
    P = {
        "c_body": C("565b40"), "c_dark": C("45502d"), "c_lit": C("7a8993"),
        "c_lit2": C("748471"), "c_mid": C("596d6f"), "c_under": C("9b876c"),
        "c_moss": C("596d6f"), "c_moss2": C("748471"),
        "t_lit": C("ad8459"), "t_body": C("866144"), "t_dark": C("796145"),
        "t_deep": C("565b40"), "t_furrow": C("565b40"), "t_ring": C("9b876c"),
        "t_moss": C("73734d"),
    }
    cx, by = 150, 131
    L = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    shelf(L, cx - 30, -8, 77, 24, P, 13, droop=5)
    shelf(L, cx - 62, 18, 93, 26, P, 14, droop=6)
    limb(L, [(cx - 4, 64), (cx - 30, 52), (cx - 72, 44), (cx - 108, 40)], 6, 3, P, 15)
    limb(L, [(cx + 6, 62), (cx + 24, 50), (cx + 54, 42), (cx + 72, 38)], 5, 2.5, P, 16,
         hook=(cx + 72, 38, 5, 1))
    trunk(L, cx, by, 52, TRUNK_W * s, P, 7)
    shelf(L, cx - 39, 47, 100, 22, P, 17, droop=8)
    shelf(L, cx + 44, 39, 36, 16, P, 18, droop=5)

    sky = rgbset("56708e", "6a84a0", "879db0", "a9b5ba", "cdc6b4", "e4cba6", "f0d59f",
                 "f7e3b5", "b8c2bc", "93a3b2", "a3b0ae", "93a77a")

    def ok_tree(x, y, c):
        return c in sky and y < 136
    composite(out, orig, L, ok_tree)

    R = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    RP = {"r_out": C("3f2716"), "r_dark": C("663f23"), "r_body": C("8c6545"),
          "r_lit": C("c49b69"), "r_moss": C("908940"), "r_moss2": C("6b6d45")}
    # over the hill crest (trunk base hidden behind it), down the near slope
    tube(R, [(cx + 22, 129), (cx + 36, 136), (cx + 50, 148), (cx + 64, 160), (cx + 76, 172),
             (cx + 84, 180)], 6, 4, RP, 23, bury=0.4, humps=((0.3, 0.46, 3), (0.7, 0.84, 3)))
    fields = rgbset("7f9467", "6f8455", "93a77a")

    def ok_root(x, y, c):
        return c in fields and y >= 124
    composite(out, orig, R, ok_root)
    save(out, "vista_tree")
    return out


# ---------------------------------------------------------------- reveal top hold
def mock_hold():
    orig = down3(BUILD + "/round2/11_reveal_hold_top.png")
    out = orig.copy()
    W, H = orig.size
    sky = rgbset("2e3b52", "3a4a60", "4a5e73", "566c80", "62788a", "7f939a", "a3a891",
                 "c2b58f", "d9bf94", "8d95a6", "e2c0a4")
    gp = orig.load()
    op = out.load()
    horizon = 136
    rnd = random.Random(40)

    # 1. dawn glow pulled up to sit just over a low horizon
    glow = [(118, "7f939a"), (126, "a3a891"), (131, "c2b58f"), (134, "d9bf94")]
    for y in range(116, horizon + 1):
        band = None
        for y0, h in glow:
            if y >= y0 - (1 if (y % 2) else 0):
                band = h
        for x in range(W):
            if gp[x, y] in sky and band:
                op[x, y] = C(band)[:3]

    # 2. the upland seen from above: hazy far hills, then field bands, hedgerows
    bands = [(0, "8d95a6"), (5, "7a8993"), (13, "878b7c"), (26, "8c8466"), (44, "748471"),
             (62, "6f8455")]
    for x in range(W):
        top = horizon + 1 + int(round(1.6 * math.sin(x * 0.045) + math.sin(x * 0.13 + 1)))
        for y in range(top, H):
            if gp[x, y] not in sky:
                continue
            d = y - horizon
            wob = int(round(1.5 * math.sin(x * 0.07 + d * 0.3)))
            col = bands[0][1]
            for d0, h in bands:
                if d + wob >= d0:
                    col = h
            # one-pixel dither on band edges
            for d0, h in bands[1:]:
                if d + wob == d0 - 1 and (x + y) % 2 == 0:
                    col = h
            op[x, y] = C(col)[:3]
    # field patches break up the bands (bigger as they come closer)
    for _ in range(46):
        y = rnd.randint(horizon + 10, H - 4)
        x = rnd.randint(0, W - 1)
        d = y - horizon
        rw = 4 + d // 3 + rnd.randint(0, 6)
        rh = 1 + d // 18
        col = C(rnd.choice(["979683", "8c8466", "878b7c", "748471", "6f8455"]))[:3]
        for dy in range(-rh, rh + 1):
            for dx in range(-rw, rw + 1):
                if (dx / rw) ** 2 + (dy / max(1, rh)) ** 2 <= 1 and (abs(dx) < rw - 1 or (x + dx + y + dy) % 2):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and gp[xx, yy] in sky:
                        op[xx, yy] = col
    # a far woodline along the horizon and the river bend glinting far off
    for x in range(W):
        if math.sin(x * 0.09) + math.sin(x * 0.23 + 2) > 0.6 and gp[x, horizon + 2] in sky:
            for yy in (horizon + 1, horizon + 2):
                op[x, yy] = C("7a8993")[:3]
    for x in range(286, 336):
        if (x // 4) % 3 != 0 and gp[x, horizon + 5] in sky:
            op[x, horizon + 5] = C("c2d4df")[:3]
    # hedgerows and field lines, longer as they come closer
    for _ in range(60):
        y = rnd.randint(horizon + 8, H - 2)
        x = rnd.randint(0, W - 1)
        ln = 2 + (y - horizon) // 12 + rnd.randint(0, 3)
        for k in range(ln):
            if 0 <= x + k < W and gp[x + k, y] in sky:
                op[x + k, y] = C("596d6f")[:3]
    # low cloud wisps lying below eye level (lens shapes, two tones)
    for wx, wy, wl in ((230, 160, 52), (318, 168, 40), (150, 172, 30), (16, 163, 26)):
        for dy, frac, col in ((-1, 0.55, "c2d4df"), (0, 1.0, "deded0"), (1, 0.7, "c2d4df")):
            half = int(wl * frac / 2)
            for x in range(wx - half, wx + half + 1):
                if 0 <= x < W and gp[x, wy + dy] in sky:
                    op[x, wy + dy] = C(col)[:3]
    # a few birds flying below the eye line
    for bx, byy in ((236, 150), (244, 154), (252, 149), (262, 152)):
        for dx, dy in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            if gp[bx + dx, byy + dy] in sky:
                op[bx + dx, byy + dy] = C("45502d")[:3]

    # 3. the great tree on the left, lowest boughs just above the lamp line
    s = 3.12
    P = {
        "c_body": C("3d542b"), "c_dark": C("2d3729"), "c_lit": C("596d6f"),
        "c_lit2": C("45502d"), "c_mid": C("45502d"), "c_under": C("ad8459"),
        "c_moss": C("45502d"), "c_moss2": C("596d6f"),
        "t_lit": C("ad8459"), "t_body": C("796145"), "t_dark": C("565b40"),
        "t_deep": C("45502d"), "t_furrow": C("565b40"), "t_ring": C("b79b75"),
        "t_moss": C("73734d"),
    }
    cx, by = 45, 192
    L = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    shelf(L, cx - 40, 3, 44, 28, P, 31, droop=5)
    shelf(L, cx - 62, 36, 56, 30, P, 32, droop=6)
    shelf(L, cx - 25, 67, 62, 28, P, 33, droop=6)
    shelf(L, cx - 50, 98, 75, 24, P, 34, droop=6)
    limb(L, [(cx - 2, 132), (cx - 18, 120), (cx - 44, 114)], 5, 3, P, 35)
    limb(L, [(cx + 4, 130), (cx + 22, 120), (cx + 50, 112), (cx + 70, 110)], 4.5, 2.2, P, 36,
         hook=(cx + 70, 110, 4, 1))
    trunk(L, cx, by, 112, TRUNK_W * s, P, 9, ring_step=10)
    shelf(L, cx - 31, 124, 81, 19, P, 37, droop=7)
    shelf(L, cx + 44, 117, 37, 15, P, 38, droop=5)
    # ordinary trees at the giant's feet, for scale
    for tx, ty, tr in ((78, 189, 4), (86, 191, 3), (12, 191, 4), (100, 193, 3), (3, 194, 3)):
        lp = L.load()
        setp(lp, L.size, tx, ty + tr, P["t_dark"])
        setp(lp, L.size, tx, ty + tr + 1, P["t_dark"])
        disc(lp, L.size, tx, ty, tr, P["c_body"])
        for dx in range(-tr + 1, tr):
            setp(lp, L.size, tx + dx, ty - tr + 1 + abs(dx) // 2, P["c_lit"])

    def ok(x, y, c):
        return c in sky
    composite(out, orig, L, ok)

    # 4. the root's line: from the trunk flare toward the Tower's foot below us
    R = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    RP = {"r_out": C("45502d"), "r_dark": C("565b40"), "r_body": C("866144"),
          "r_lit": C("ad8459"), "r_moss": C("73734d"), "r_moss2": C("6f8455")}
    tube(R, [(cx + 16, 193), (cx + 40, 197), (cx + 66, 200), (cx + 92, 206), (cx + 112, 213),
             (cx + 126, 223)], 4, 8, RP, 39, bury=0.35, humps=((0.08, 0.3, 5), (0.5, 0.7, 7)))
    composite(out, orig, R, ok)
    save(out, "hold_tree")
    return out


# ---------------------------------------------------------------- Tower Rise walking
def mock_rise():
    orig = down3(BUILD + "/round2/05c_rise_side_west_col2_row3.png")
    out = orig.copy()
    gp = orig.load()
    keep = rgbset("f2d27a", "2d9e9f", "12837f", "fff4e8")   # waylines stay in front

    def warm(c):
        return c[0] > c[1] + 12

    R = Image.new("RGBA", orig.size, (0, 0, 0, 0))
    RP = {"r_out": C("181412"), "r_dark": C("663f23"), "r_body": C("b06b3d"),
          "r_lit": C("c49b69"), "r_moss": C("908940"), "r_moss2": C("6b6f1d"),
          "tread": C("e6c697"), "tread2": C("ccb290")}
    tube(R, [(-14, 178), (18, 183), (52, 191), (84, 200), (108, 204), (124, 198), (136, 186)],
         19, 14, RP, 51, shadow=C("2f4a22"), treads=(40, 47, 54))

    def ok(x, y, c):
        if c in keep:
            return False
        if x >= 112 and warm(c):
            return False
        return y > 120
    composite(out, orig, R, ok)

    # fallen leaves of the great tree: a broad paddle with a hooked tip
    lp = out.load()
    def leaf(x0, y0, flip):
        body = [(0, 0), (1, -1), (2, -2), (3, -2), (4, -3), (5, -3), (6, -3), (7, -3), (8, -3),
                (9, -2), (10, -2), (11, -1), (12, -1), (13, 0)]
        for i, (dx, dy) in enumerate(body):
            for k in range(0, -dy * 2 + 1):
                x = x0 + (dx if not flip else -dx)
                y = y0 + dy + k
                c = C("908940") if k < -dy else C("6b6f1d")
                if 0 <= x < 384 and 0 <= y < 216:
                    lp[x, y] = c[:3]
        for dx in range(1, 13):
            x = x0 + (dx if not flip else -dx)
            lp[x, y0] = C("c6bb2a")[:3]
        # hooked tip
        for dx, dy in ((14, -1), (15, -2), (15, -3), (14, -4)):
            x = x0 + (dx if not flip else -dx)
            lp[x, y0 + dy] = C("6b6f1d")[:3]
        for dx in range(0, 14):
            x = x0 + (dx if not flip else -dx)
            if 0 <= y0 + 4 < 216:
                lp[x, y0 + 4] = C("2f4a22")[:3]
    leaf(10, 118, False)
    leaf(92, 150, True)
    save(out, "rise_root")
    return out


# ---------------------------------------------------------------- map
def mock_map():
    W, H = 512, 288
    im = Image.new("RGB", (W, H), C("1d2925")[:3])
    d = ImageDraw.Draw(im)
    d.fontmode = "1"
    font = ImageFont.truetype(FONT, 8)
    S = 2
    OX, OY = 4, 20
    TX0, TY0 = -34, -66   # tile at the panel's top-left (Highbank Street coordinates)

    def P(x, y):
        return (OX + int(round((x - TX0) * S)), OY + int(round((y - TY0) * S)))

    def rect(x0, y0, x1, y1, c):
        a = P(x0, y0)
        b = P(x1, y1)
        d.rectangle([a, (b[0] - 1, b[1] - 1)], fill=C(c)[:3])

    def text(xy, s, c="f5d9a8"):
        d.text(xy, s, font=font, fill=C(c)[:3])

    # land: upland behind town rises to a crest at the tree
    rect(TX0, TY0, 75, 42, "6b6d45")
    for ring, col in ((22, "6b6f1d"), (14, "908940")):
        pass
    # crest contour lines (dotted) around the tree
    for r in (14, 24, 34):
        for a in range(0, 360, 6):
            x = 13.5 + r * 1.2 * math.cos(math.radians(a))
            y = -32 + r * math.sin(math.radians(a))
            px, py = P(x, y)
            if OX <= px < OX + 216 and OY <= py < OY + 216 and y < -2:
                im.putpixel((px, py), C("908940")[:3])
    # river along the south, far bank below
    rect(TX0, 29, 75, 35, "12837f")
    rect(TX0, 29, 75, 30, "07515c")
    rect(TX0, 35, 75, 42, "44421a")
    # Ferry Ward on the lower terraces, bluff edge above it
    rect(40, 16, 74, 29, "8e7f5e")
    rect(58, 25, 74, 28, "c7a378")
    rect(TX0, 16, 75, 17, "3f2716")
    # Highbank Street on the bluff top
    rect(0, 0, 56, 16, "c7a378")
    rect(0, 8, 56, 10, "8e7f5e")
    for hx in (3, 12, 20, 28):
        rect(hx - 1, 3, hx + 4, 7, "663f23")
    for hx in (1, 12, 21):
        rect(hx, 11, hx + 4, 15, "663f23")
    rect(12, 12, 14, 14, "fbd490")   # Growth Shrine
    rect(41, 7, 53, 15, "e6c697")    # Crossroads
    # East Quarter beyond the road east (clipped)
    rect(56, 2, 75, 16, "ccb290")
    # Tower Rise, one step higher, hedge on its back edge
    rect(34, -14, 60, -1, "908940")
    rect(34, -14, 60, -13, "44421a")
    rect(34, -1, 60, 0, "3f2716")
    # the great tree's crown footprint (dithered), leaning west
    for py in range(OY, OY + 216):
        for px in range(OX, OX + 216):
            tx = (px - OX) / S + TX0
            ty = (py - OY) / S + TY0
            if ((tx - 2) / 36) ** 2 + ((ty + 36) / 28) ** 2 <= 1 and (px + py) % 2 == 0:
                im.putpixel((px, py), C("303e37")[:3])
    # root: surfaced ridge from the trunk, behind the Street, up onto the Rise
    root = [(16, -28), (18, -22), (20, -14), (22, -7), (25, -4), (30, -3), (33, -6), (35, -8),
            (38, -8), (40, -8), (41, -7)]
    path = walk(chaikin([P(x, y) for x, y in root], 3), 0.5)
    for x, y, f in path:
        r = 5 - 3.2 * f
        for dy in range(-6, 7):
            for dx in range(-6, 7):
                if dx * dx + dy * dy <= r * r:
                    im.putpixel((int(x + dx), int(y + dy)), C("663f23")[:3])
    for x, y, f in path:
        r = 5 - 3.2 * f
        im.putpixel((int(x), int(y - r * 0.4)), C("c49b69")[:3])
    # trunk and root flare
    tx, ty = P(13.5, -32)
    d.ellipse([tx - 18, ty - 18, tx + 18, ty + 18], outline=C("8c6545")[:3])
    d.ellipse([tx - 10, ty - 10, tx + 10, ty + 10], fill=C("663f23")[:3], outline=C("3f2716")[:3])
    d.ellipse([tx - 4, ty - 4, tx + 4, ty + 4], fill=C("8c6545")[:3])
    # dungeon entrance under the shoulder of the town root
    ex, ey = P(17.5, -27.5)
    d.rectangle([ex - 2, ey - 2, ex + 2, ey + 2], fill=C("0b0e11")[:3])
    # Rise: root foot, Tower base, lamp
    rect(38, -13, 41, -5, "b06b3d")
    rect(41, -8, 53, -5, "f5d9a8")
    lx, ly = P(47, -6.5)
    d.rectangle([lx - 1, ly - 1, lx + 1, ly + 1], fill=C("fbd490")[:3])
    # root path to the tree (later), from a closed gate at the Rise's back corner
    gate = P(34, -12)
    for x, y, f in walk([gate, P(28, -17), P(22, -23), P(19, -27)], 1):
        if int(f * 40) % 2 == 0:
            im.putpixel((int(x), int(y)), C("f5d9a8")[:3])
    d.rectangle([gate[0] - 1, gate[1] - 1, gate[0] + 1, gate[1] + 1], fill=C("f2d27a")[:3])
    # crossing treads where the root runs over the Rise's side lane
    cx_, cy_ = P(36, -8)
    d.line([cx_ - 1, cy_ - 2, cx_ - 1, cy_ + 2], fill=C("f5d9a8")[:3])
    d.line([cx_ + 1, cy_ - 2, cx_ + 1, cy_ + 2], fill=C("f5d9a8")[:3])

    # numbered markers
    marks = {"1": (13.5, -40.5), "2": (-14, -50), "3": (20, -29), "4": (18.5, -14),
             "5": (36, -11), "6": (48, -11), "7": (31, -13.5), "8": (24, 0.5)}
    for k, (x, y) in marks.items():
        px, py = P(x, y)
        d.rectangle([px - 1, py - 1, px + 5, py + 7], fill=C("0b0e11")[:3])
        text((px, py - 1), k, "fbd490")
    text((P(20, 3)[0], P(20, 3)[1]), "STREET", "3f2716")
    text((P(55, 20)[0], P(55, 20)[1]), "FERRY", "f5d9a8")
    text((P(-30, 31)[0], P(-30, 31)[1] - 2), "RIVER", "f5d9a8")
    text((P(60, 4)[0], P(60, 4)[1]), "EAST", "3f2716")
    text((P(53.5, -13)[0], P(53.5, -13)[1]), "RISE", "3f2716")

    # frame, compass, scale bar
    d.rectangle([OX - 1, OY - 1, OX + 216, OY + 216], outline=C("c7a378")[:3])
    nx, ny = OX + 206, OY + 4
    d.polygon([(nx, ny), (nx - 3, ny + 7), (nx + 3, ny + 7)], fill=C("f5d9a8")[:3])
    text((nx - 2, ny + 8), "N")
    sx, sy = OX, OY + 224
    d.rectangle([sx, sy, sx + 20 * S - 1, sy + 2], fill=C("f5d9a8")[:3])
    d.rectangle([sx + 10 * S, sy, sx + 20 * S - 1, sy + 2], fill=C("8e7f5e")[:3])
    for t in (0, 10, 20):
        d.line([sx + t * S, sy - 2, sx + t * S, sy + 4], fill=C("f5d9a8")[:3])
    text((sx - 1, sy + 6), "0")
    text((sx + 10 * S - 4, sy + 6), "10")
    text((sx + 20 * S - 4, sy + 6), "20 TILES  (1 TILE = 24 PX)")
    text((OX, 4), "GREAT TREE  CONCEPT B: OVER THE BLUFF  (PROPOSAL, WORKING LABEL)")

    # legend
    lx0, ly0 = 232, 22
    legend = [
        ("1", "GREAT TREE TRUNK, 10 TILES WIDE"),
        ("", "96 TILES TALL, ON THE UPLAND CREST"),
        ("", "12 TILES ABOVE THE RISE, 42 TILES NW"),
        ("", "OF THE TOWER DOOR (33 W, 26 N)"),
        ("2", "CROWN SHADE, LEANS WEST, OFF THE LAMP"),
        ("3", "DUNGEON ENTRANCE UNDER THE TOWN ROOT"),
        ("4", "ROOT RIDGE, SURFACED ALL THE WAY"),
        ("5", "ROOT CROSSES THE SIDE LANE (TREADS)"),
        ("6", "ROOT FOOT, CLIMBS THE TOWER, HOLDS LAMP"),
        ("7", "GATE TO THE ROOT PATH (CLOSED FOR NOW)"),
        ("8", "HEDGE RIDES OVER THE ROOT'S BACK"),
    ]
    for i, (k, s) in enumerate(legend):
        y = ly0 + i * 10
        if k:
            d.rectangle([lx0 - 1, y - 1, lx0 + 5, y + 7], fill=C("0b0e11")[:3])
            text((lx0, y - 1), k, "fbd490")
        text((lx0 + 10, y - 1), s)

    # side profile, looking west: river, bluff, Street, Rise + Tower, slope, crest + tree
    px0, py0 = 236, 280          # profile origin: n = -36 at x px0, elevation -8 at py0
    def Q(n, e):
        return (px0 + int(round(n + 36)), py0 - int(round(e + 8)))
    text((px0, 140), "SIDE PROFILE, LOOKING WEST, 1 PX = 1 TILE", "e6c697")
    ground = [(-36, -8), (-29, -8), (-29, -5), (-21, -5), (-20, -2), (-16, -2), (-16, 0), (0, 0),
              (1, 2), (14, 2), (32, 12), (46, 12), (60, 10), (72, 10)]
    poly = [Q(n, e) for n, e in ground] + [Q(72, -8), Q(-36, -8)]
    d.polygon(poly, fill=C("6b6d45")[:3])
    d.rectangle([Q(-36, -8)[0], Q(-36, -6)[1], Q(-29, -8)[0], Q(-36, -8)[1]], fill=C("12837f")[:3])
    # tower: 30 tiles on the Rise at n = 6
    t0 = Q(5, 2)
    t1 = Q(8, 32)
    d.rectangle([t0[0], t1[1], t1[0], t0[1]], fill=C("f5d9a8")[:3])
    hx, hy = Q(6, 32)
    d.line([hx, hy, hx, hy - 3], fill=C("b06b3d")[:3])
    d.line([hx, hy - 3, hx + 3, hy - 3], fill=C("b06b3d")[:3])
    im.putpixel((hx + 3, hy - 1), C("fbd490")[:3])
    # tree: trunk at n 32, base +12, bole to +34, tiers to +108
    b0 = Q(27, 12)
    b1 = Q(37, 34)
    d.rectangle([b0[0], b1[1], b1[0], b0[1]], fill=C("663f23")[:3])
    # flat tiers with sky between them, broad and drooping, not a cone
    tiers = [(34, 40, 13, 58), (44, 52, 15, 66), (56, 66, 12, 62), (70, 80, 18, 64),
             (84, 94, 16, 56), (98, 108, 22, 48)]
    for e0, e1, n0, n1 in tiers:
        a_ = Q(n0, e1)
        b_ = Q(n1, e0)
        d.rectangle([a_[0] + 2, a_[1], b_[0] - 2, b_[1]], fill=C("303e37")[:3])
        d.rectangle([a_[0], a_[1] + 2, b_[0], b_[1]], fill=C("303e37")[:3])
        d.line([a_[0], b_[1], b_[0], b_[1]], fill=C("5d4b34")[:3])
        for k in range(a_[0], b_[0], 3):
            d.line([k, b_[1] + 1, k, b_[1] + 1 + (k * 7) % 3], fill=C("44421a")[:3])
    # limbs from the bole into the tiers
    d.line([Q(32, 34), Q(20, 38)], fill=C("663f23")[:3])
    d.line([Q(32, 34), Q(50, 39)], fill=C("663f23")[:3])
    d.line([Q(32, 30), Q(32, 99)], fill=C("663f23")[:3])
    # root line in profile, from the flare down to the Tower
    for x, y, f in walk(chaikin([Q(27, 12), Q(18, 6), Q(10, 3), Q(8, 2)], 2), 0.5):
        im.putpixel((int(x), int(y)), C("c49b69")[:3])
    # dimension notes
    text((Q(68, 100)[0] + 2, Q(68, 100)[1]), "TREE 96", "e6c697")
    text((Q(-34, 40)[0], Q(-34, 40)[1]), "TOWER 30", "e6c697")
    d.line([Q(9, 32)[0], Q(9, 32)[1], Q(0, 44)[0], Q(0, 44)[1]], fill=C("8e7f5e")[:3])
    text((Q(40, 50)[0] + 26, Q(40, 50)[1] - 12), "LOWEST TIER +34", "e6c697")
    text((Q(40, 50)[0] + 26, Q(40, 50)[1] - 2), "TOWER TOP +32", "e6c697")
    text((Q(40, 50)[0] + 26, Q(40, 50)[1] + 8), "CREST +12", "e6c697")
    text((Q(40, 50)[0] + 26, Q(40, 50)[1] + 18), "STREET 0, RIVER -8", "e6c697")
    text((Q(-36, -8)[0] - 8, Q(-36, -8)[1] - 9), "S", "e6c697")
    text((Q(72, -8)[0] + 3, Q(72, -8)[1] - 9), "N", "e6c697")
    save(im, "map")
    return im


def sheet(images, cols, scale, name):
    w = max(i.width for i in images) * scale
    h = max(i.height for i in images) * scale
    rows = (len(images) + cols - 1) // cols
    out = Image.new("RGB", (w * cols + 8 * (cols - 1), h * rows + 8 * (rows - 1)), (11, 14, 17))
    for k, im in enumerate(images):
        big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        out.paste(big, ((k % cols) * (w + 8), (k // cols) * (h + 8)))
    out.save(f"{HERE}/{name}.png")


if __name__ == "__main__":
    t = mock_title()
    v = mock_vista()
    h = mock_hold()
    r = mock_rise()
    m = mock_map()
    sheet([t, v, h, r], 2, 2, "_review_sheet")
    print("done")
