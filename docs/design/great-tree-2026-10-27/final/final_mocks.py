"""Final mocks for the great tree (working label; the name is Preston's). Proposal only, nothing installed.

Base: concept C (horizon, the root road), with grafts:
  - closer than C (about 4,400 tiles, not 6,600), so it reads massive on screen, not only in the math
  - clumped shelves with gaps and hanging root curtains (not flat plates), limbs showing between shelves
  - crook-shaped buttress roots at its foot (from A), so the Reach reads as one of its roots, not a cane
  - existing cloud strips pass in front of it (title, vista, road) and a cloud crosses its trunk in the hold
  - haze rule: never lit; each part is one ramp step darker than the sky right behind it, so it stays the
    lowest-contrast thing in the view; its foot is as light as, or lighter than, the land at its foot
  - the root shows in every far view as raised bark humps with moss crests, a faint seam where it runs under
    the ground, and the pale trail that keeps beside it (the root road)
  - on Tower Rise the root arrives at full girth from past the west edge and bends up into the climb

Size math (one lens, from C): a thing H tiles tall at d tiles shows H * 24 * 40 / d px at 1x; the reveal camera
(scale 1.0) sits 40 tiles from the Tower. Tree 480 tiles tall, crown 720 wide, 4,400 tiles N 7 deg E of the Tower:
  reveal top hold (d 4,400): 105 px tall, crown 157 px
  title (viewer 178 tiles south, d ~4,580): 101 px, crown 151 (lower third hidden by the far hills)
  vista (viewer 164 tiles south, d ~4,560): 101 px, crown 151 (base hidden by the far hills)
  road far layer (viewer 411 tiles south, d ~4,810): 96 px, crown 144 (lower part hidden by the far hills)
The Tower swings from 70 px to 720 px across those views; the tree stays about 100 px. That is the far-and-huge read.

Run:  python final_mocks.py   (writes final_*_1x.png and final_*_3x.png next to this file, review sheets to scratch)
Pixel rules: hard edges, no anti-aliasing, nearest-neighbour 3x only. Title and vista use only colours already in them.
Reads (never writes) Codex's cx-12 root_foot candidate for the before/after.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
GT = ROOT + '/docs/design/great-tree-2026-10-27'
OUT = GT + '/final'
BUILD = ROOT + '/docs/design/wayline-tower-2026-10-27/build'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
C12 = ROOT + '/docs/art/slot-candidates/cx-12-tower-foot/town.building.hall.root_foot/prepared.png'
SCRATCH = 'C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad'
REPORT = {}


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
    # in-game shots are exact 3x of a 384x216 frame, so NEAREST picks one pixel of each 3x3 block
    im = Image.open(path).convert('RGB')
    return im.resize((im.width // 3, im.height // 3), Image.NEAREST)


def colours(img, mask=None):
    px = img.load()
    s = set()
    for y in range(img.height):
        for x in range(img.width):
            if mask is None or mask(x, y):
                s.add(px[x, y])
    return s


def mean_lum(img, pts):
    px = img.load()
    pts = list(pts)
    return round(sum(lum(px[x, y]) for x, y in pts) / max(1, len(pts)))


class Ramp:
    """A sky ramp, dark to light. Tree pixels step off the sky band behind them along this ramp."""

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
# Shape (proposal): a braided trunk on crook-shaped buttress roots, big limbs, and five shelves of crown made of
# clumps, widest in the middle, with gaps between shelves and root curtains hanging under each one. The shelves
# are the dungeon's later floors. Not an oak dome, not flat plates, no faces, never lit.
TIERS = [  # (centre height as a fraction of H, half width, clump radius, clump count), drawn top first
    (0.970, 0.12, 0.058, 2),
    (0.895, 0.31, 0.070, 5),
    (0.800, 0.52, 0.080, 8),
    (0.690, 0.66, 0.088, 10),
    (0.575, 0.56, 0.082, 9),
]


def tree_roles(cx, base_y, Ht, light=1, seed=3):
    """Pixel -> (role, (y0, y1)): the rows of sky whose darkest band sets that pixel's tone. Shelves look at the
    sky along their own top edge; trunk, limbs and buttress roots look at their own row, so they fade toward the
    horizon like everything far away."""
    rnd = random.Random(seed)
    R = {}

    def Y(h):
        return base_y - h * Ht

    def setp(x, y, role, ref=None):
        k = (int(math.floor(x + 0.5)), int(math.floor(y + 0.5)))
        R[k] = (role, ref or (k[1], k[1]))

    def disc(x, y, r, role_fn, ref=None):
        for yy in range(int(y - r) - 1, int(y + r) + 2):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if (xx - x) ** 2 + (yy - y) ** 2 <= r * r + 0.25:
                    setp(xx, yy, role_fn(xx - x, yy - y), ref)

    # 1. crook-shaped buttress roots: out from the trunk, then hooking down into the ground, like the Reach
    for side, h0, a, ph in ((-1, 0.085, 0.16, 0), (1, 0.09, 0.17, 1), (-1, 0.05, 0.10, 2), (1, 0.05, 0.11, 3)):
        xs = cx + side * 0.07 * Ht
        n = int(Ht * 0.6) + 8
        for k in range(n + 1):
            th = (k / n) * (math.pi / 2)
            x = xs + side * a * Ht * math.sin(th)
            y = Y(h0) + h0 * Ht * (1 - math.cos(th))
            r = max(0.6, (0.048 - 0.030 * k / n) * Ht)
            disc(x, y, r, lambda dx, dy: 'trunk_shade' if dy > 0.2 or dx * light < -0.4 else 'trunk')
    # 2. the trunk, braided: two strands twist round each other up its length
    for y in range(int(Y(0.86)), int(base_y) + 1):
        t = (base_y - y) / Ht
        xc = cx + 0.02 * Ht * math.sin(t * math.pi * 1.3)
        hw = (0.078 - 0.03 * t) * Ht
        if t < 0.12:
            hw += 0.10 * Ht * ((0.12 - t) / 0.12) ** 2
        for x in range(int(math.floor(xc - hw)), int(math.ceil(xc + hw)) + 1):
            u = (x - xc) / max(hw, 0.5)
            if abs(u) > 1.0:
                continue
            role = 'trunk'
            if u * light < -0.3:
                role = 'trunk_shade'
            for b in (0.5 * math.sin(t * 11.0), -0.5 * math.sin(t * 11.0 + 0.9)):
                if abs(u - b) < 0.5 / max(hw, 1) + 0.04 and hw > 2.5:
                    role = 'trunk_shade'
            setp(x, y, role)
    # 3. limbs out to the shelves
    for (h0, h1, u1, w) in ((0.42, 0.56, -0.42, 0.024), (0.45, 0.57, 0.40, 0.024), (0.53, 0.68, -0.50, 0.022),
                            (0.55, 0.69, 0.52, 0.022), (0.64, 0.80, -0.33, 0.018), (0.66, 0.80, 0.36, 0.018),
                            (0.76, 0.89, 0.20, 0.014)):
        x0, y0 = cx, Y(h0)
        x1, y1 = cx + u1 * Ht, Y(h1)
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for k in range(n + 1):
            a = k / n
            bow = -0.04 * Ht * math.sin(math.pi * a)  # a slight upward bow, like a real limb
            disc(x0 + (x1 - x0) * a, y0 + (y1 - y0) * a + bow, max(0.6, w * Ht * (1 - 0.5 * a)),
                 lambda dx, dy: 'limb')
    # 4. shelves, top first, each: its curtains, then its clumps (a lower shelf covers the curtains above it)
    for (h, hw, cr, n) in TIERS:
        yc = Y(h)
        ref = (int(yc - 1.0 * cr * Ht), int(yc))
        clumps = []
        for i in range(n):
            s = -1 + 2 * (i + 0.5) / n + rnd.uniform(-0.25, 0.25) / n
            rx = cr * Ht * rnd.uniform(1.05, 1.55)
            ry = cr * Ht * rnd.uniform(0.62, 0.86)
            x = cx + s * hw * Ht
            y = yc + 0.045 * Ht * s * s + rnd.uniform(-0.25, 0.15) * ry
            clumps.append((x, y, rx, ry))
        trunk_hw = (0.078 - 0.03 * h) * Ht + 2
        for (x, y, rx, ry) in clumps:  # curtains: hanging aerial roots, thin and broken, clear of the trunk
            for xx in range(int(x - 0.8 * rx), int(x + 0.8 * rx) + 1):
                if rnd.random() < 0.6 or abs(xx - cx) < trunk_hw:
                    continue
                L = int(rnd.uniform(0.015, 0.05 if h > 0.6 else 0.09) * Ht)
                for k in range(1, L + 1):
                    setp(xx, y + 0.42 * ry + k, 'curtain', ref)
        for (x, y, rx, ry) in clumps:
            for yy in range(int(y - ry) - 1, int(y + ry) + 2):
                for xx in range(int(x - rx) - 1, int(x + rx) + 2):
                    q = ((xx - x) / rx) ** 2 + ((yy - y) / ry) ** 2
                    if q > 1.0 or yy > y + 0.48 * ry:  # flat underside: a shelf
                        continue
                    setp(xx, yy, 'shade' if yy >= y + 0.12 * ry else 'body', ref)
    # a few sky holes through the bigger shelves, so they read as leaves, not slabs
    for (h, hw, cr, n) in TIERS[2:]:
        for _ in range(3):
            x = cx + rnd.uniform(-0.8, 0.8) * hw * Ht
            y = Y(h) - rnd.uniform(0.0, 0.3) * cr * Ht
            for (dx, dy) in ((0, 0), (1, 0)) if Ht > 80 else ((0, 0),):
                R.pop((int(x) + dx, int(y) + dy), None)
    return R


# one step off the sky for the crown; the trunk and its braided strands one more, so it reads solid, not as a ghost
HAZE = {'body': -1, 'shade': -2, 'curtain': -2, 'trunk': -2, 'trunk_shade': -3, 'limb': -2}


def paint_tree(img, roles, ramp, allowed, ref_sky, shift=HAZE, floor=0):
    px = img.load()
    W, H = img.size
    box = [999, 999, -1, -1]
    n, tl, bl = 0, 0.0, 0.0
    for (x, y), (role, (y0, y1)) in roles.items():
        if not (0 <= x < W and 0 <= y < H) or not allowed(x, y):
            continue
        refs = [ref_sky[max(0, min(H - 1, yy))] for yy in range(y0, y1 + 1)]
        refs = [r for r in refs if r is not None]
        if not refs:
            continue
        i = min(ramp.idx(r) for r in refs)
        before = px[x, y]
        c = ramp.get(max(floor, i + shift[role]))
        px[x, y] = c
        tl += lum(c)
        bl += lum(before)
        box = [min(box[0], x), min(box[1], y), max(box[2], x), max(box[3], y)]
        n += 1
    return box, n, dict(tree_lum=round(tl / max(1, n)), sky_behind_lum=round(bl / max(1, n)))


def paint_flat(img, roles, cmap):
    px = img.load()
    for (x, y), (role, _) in roles.items():
        if 0 <= x < img.width and 0 <= y < img.height:
            px[x, y] = hx(cmap[role])


def row_sky(img, sky, x0, x1):
    """The most common sky colour in each row, carried down past the skyline."""
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


def cloud_mask(img, sky, dom):
    """Sky pixels that belong to a cloud strip: runs of 4+ pixels lighter than the row's main band. Band dither is
    single pixels, so it is not caught. The tree is painted behind these, so the strips cross in front of it."""
    px = img.load()
    W, H = img.size
    m = set()
    for y in range(H):
        d = dom[y]
        if d is None:
            continue
        run = []
        for x in range(W + 1):
            c = px[x, y] if x < W else None
            if c is not None and c in sky and c != d and lum(c) > lum(d) + 6:
                run.append(x)
            else:
                if len(run) >= 4:
                    m.update((xx, y) for xx in run)
                run = []
    return m


def skyline_of(img, sky, start):
    px = img.load()
    out = []
    for x in range(img.width):
        y = start
        while y < img.height and px[x, y] in sky:
            y += 1
        out.append(y)
    return out


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


def frame_of(S):
    N = len(S)
    T, along = [], [0.0]
    for i in range(N):
        a, b = S[max(0, i - 1)], S[min(N - 1, i + 1)]
        tx, ty = b[0] - a[0], b[1] - a[1]
        m = math.hypot(tx, ty) or 1.0
        T.append((tx / m, ty / m))
        if i:
            along.append(along[-1] + math.hypot(S[i][0] - S[i - 1][0], S[i][1] - S[i - 1][1]))
    return T, along


def root_road(img, pts, humps, width, cols, allowed, seam=None, per=60):
    """The root seen from far off: long raised humps where it surfaces (a moss crest, a lit bark flank on the east
    side, a dark bark flank and a contact shadow on the west), a faint darker seam in the turf where it runs under the
    ground, and the pale trail that keeps beside it on the east side the whole way. humps are fractions of the path."""
    px = img.load()
    W, H = img.size
    S = catmull([(x, y, 0) for x, y in pts], per)
    N = len(S)
    T, along = frame_of(S)

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H and allowed(x, y):
            px[x, y] = hx(c) if isinstance(c, str) else c

    def east_normal(i):
        nx, ny = -T[i][1], T[i][0]
        return (nx, ny) if nx >= 0 else (-nx, -ny)

    E = []
    L = along[-1]
    for i, (x, y, _) in enumerate(S):
        f = i / (N - 1)
        r = width(x, y)
        e = 0.0
        for (a, b) in humps:
            if a <= f <= b:
                # a ridge breaks out of the turf and dives back in: nearly full girth along its length, short
                # rounded ends (not a pod or a lens)
                d_end = min(f - a, b - f) * L
                e = r * max(0.45, min(1.0, d_end / (1.0 + 0.8 * r)) ** 0.5)
                break
        E.append((r, e))
    # 1. the seam where the root runs under the turf, and the trail: on the root's line between ridges, beside them
    # (east) where the root is up. Dotted, so it reads as a worn way and not a painted road.
    for i, (x, y, _) in enumerate(S):
        r, e = E[i]
        nx, ny = east_normal(i)
        X, Y = int(math.floor(x + 0.5)), int(math.floor(y + 0.5))
        if e <= 0 and seam is not None and 0 <= X < W and 0 <= Y < H and allowed(X, Y):
            put(X, Y, seam(px[X, Y]))
        off = (r + 1.6) if e > 0 else (0.9 + 0.4 * r)
        if int(along[i]) % 3 != 2:
            put(int(math.floor(x + nx * off + 0.5)), int(math.floor(y + ny * off + 0.5)), cols['trail'])
    # 2. the humps
    best = {}
    for i, (x, y, _) in enumerate(S):
        r, e = E[i]
        if e <= 0:
            continue
        nx, ny = east_normal(i)
        Rr = int(math.ceil(e)) + 3
        for yy in range(int(y) - Rr, int(y) + Rr + 2):
            for xx in range(int(x) - Rr, int(x) + Rr + 2):
                dx, dy = xx - x, yy - y
                q = math.hypot(dx, dy) / e
                if q > 1 + 1.3 / e:
                    continue
                cur = best.get((xx, yy))
                if cur is None or q < cur[0]:
                    best[(xx, yy)] = (q, (dx * nx + dy * ny) / e, e, along[i])
    # rootlets: short thin branches leaving the ridges at an angle and diving into the turf. A root branches; a rope or
    # a snake does not, so these are what make the line read as root.
    rnd = random.Random(int(pts[0][0] * 7 + pts[0][1]))
    for (a, b) in humps:
        for side in (1, -1):
            if rnd.random() < 0.35:
                continue
            f = a + (b - a) * rnd.uniform(0.25, 0.75)
            i = int(f * (N - 1))
            x, y, _ = S[i]
            r, e = E[i]
            if e < 1.0:
                continue
            nx, ny = east_normal(i)
            tx, ty = T[i]
            back = -1 if rnd.random() < 0.5 else 1
            dx, dy = side * nx + back * 0.8 * tx, side * ny + back * 0.8 * ty
            m = math.hypot(dx, dy)
            dx, dy = dx / m, dy / m
            ln = e * rnd.uniform(1.8, 2.8) + 1
            k = 0.0
            while k <= ln:
                X = int(math.floor(x + dx * (e * 0.6 + k) + 0.5))
                Y = int(math.floor(y + dy * (e * 0.6 + k) + 0.5))
                put(X, Y, cols['dark'] if side < 0 else cols['bark'])
                if k < ln * 0.4 and e >= 2.5:
                    put(X + (1 if side > 0 else 0), Y + (0 if side > 0 else 1), cols['lit'] if side > 0 else cols['contact'])
                k += 0.5
    for (xx, yy), (q, u, e, s) in best.items():
        if q > 1.0:
            if u < -0.35:
                put(xx, yy, cols['contact'])  # the shadow it casts on its west side only
            continue
        if e < 1.3:
            c = cols['crest'] if u > -0.2 else cols['dark']
        elif u > 0.38:
            c = cols['lit']  # bark flank catching the morning light
        elif u < -0.38:
            c = cols['dark']
        else:  # the crest: moss with bark plates showing through
            c = cols['crest'] if noise(int(s // 2.5), int(u * 3 + 5), 3) > 0.42 else cols['bark']
            if c == cols['crest'] and u > 0.1 and noise(int(s // 2), 9, 4) > 0.6:
                c = cols['crest_lit']
        put(xx, yy, c)
    return S


# ---------------------------------------------------------------------------------------------- 1. title
def mock_title():
    img = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    # 303e37 (the ridge woods' own top colour) sits between the two darkest bands: the tree never goes darker
    ramp = Ramp(['1e302e', '263d3a', '303e37', '33524e', '43665a', '61785c', '9f946d', 'dca562'])
    sky = {hx(c) for c in ('1e302e', '263d3a', '33524e', '43665a', '61785c', '9f946d', 'dca562', '192726')}
    skyline = skyline_of(src, sky, 95)
    dom = row_sky(src, sky, 110, 270)
    clouds = cloud_mask(src, sky, dom)

    def allowed(x, y):
        # sky only, under the wordmark band, never inside the menu box, never on the Tower's side
        return orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and y >= 55 and 70 <= x < 280

    roles = tree_roles(cx=188, base_y=153, Ht=96, light=-1, seed=7)
    box, n, haze = paint_tree(img, roles, ramp, allowed, dom, floor=2)
    # the root's line through the ridge woods, from the tree's dip toward the Tower's west foot: a low seam with
    # three surfaced humps, one step lighter than the woods (hazed), ending where the Tower's own root strokes begin
    woods = {hx('303e37'), hx('1d2925')}
    root_road(img, [(200, 120), (216, 127), (232, 135), (248, 143), (262, 151), (272, 157), (279, 162)],
              [(0.10, 0.24), (0.40, 0.56), (0.74, 0.92)], lambda x, y: 1.2 + 0.03 * (y - 120),
              dict(crest='43665a', crest_lit='61785c', bark='33524e', lit='61785c', dark='263d3a', contact='1e302e',
                   trail='33524e'),
              lambda x, y: orig[x, y] in woods and x < 280 and y > 118,
              seam=lambda c: hx('303e37') if c == hx('1d2925') else c)
    save(img, 'final_title')
    a, b = src.load(), img.load()
    changed = [(x, y) for y in range(H) for x in range(W) if a[x, y] != b[x, y]]
    tree_px = [(x, y) for (x, y) in roles if 0 <= x < W and 0 <= y < H and allowed(x, y)]
    REPORT['title'] = dict(box=box, painted=n, changed=len(changed), **haze,
                           woods_in_front_lum=mean_lum(src, [(x, y) for x in range(150, 280) for y in range(118, 160)
                                                             if orig[x, y] in woods]),
                           in_wordmark=sum(1 for x, y in changed if 90 <= x <= 295 and y <= 52),
                           in_menu=sum(1 for x, y in changed if 21 <= x <= 128 and 108 <= y <= 199),
                           right_of_280=sum(1 for x, y in changed if x >= 280),
                           colours_before=len(colours(src)), colours_after=len(colours(img)),
                           new_colours=len(colours(img) - colours(src)), tree_px=len(tree_px))


# ---------------------------------------------------------------------------------------------- 2. vista
def mock_vista():
    img = load_3x(f'{BUILD}/round2/13_road_vista.png')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    sky = {orig[x, y] for x in range(60, 220) for y in range(0, 117)} - {hx('a3b0ae'), hx('b8c2bc')}  # hills out
    ramp = Ramp(['56708e', '6a84a0', '879db0', 'a9b5ba', 'cdc6b4', 'e4cba6', 'f0d59f', 'f7e3b5'])
    skyline = skyline_of(src, sky, 50)
    dom = row_sky(src, sky, 60, 220)
    clouds = cloud_mask(src, sky, dom)

    def allowed(x, y):
        return orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and x < 236

    # base at y 137, 20 px behind the far hills: the trunk runs down to the hill line and the hills cover it
    roles = tree_roles(cx=136, base_y=137, Ht=100, light=1, seed=7)
    box, n, haze = paint_tree(img, roles, ramp, allowed, dom)
    land = {hx(c) for c in ('6f8455', 'a3b0ae', '7f9467', '93a77a', 'b8c2bc', '6a8848', '4b6634', '3e5629')}
    darker = {'a3b0ae': '7f9467', 'b8c2bc': 'a3b0ae', '7f9467': '6f8455', '93a77a': '7f9467', '6f8455': '4b6634',
              '6a8848': '4b6634', '4b6634': '3e5629', '3e5629': '3e5629'}
    # the root road: over the far hills' crest from the tree's foot, down the open slope left of the houses, to the
    # Tower's west foot behind them
    root_road(img, [(146, 117), (150, 127), (154, 139), (158, 152), (166, 165), (180, 177), (198, 186), (218, 190),
                    (236, 186)],
              [(0.02, 0.09), (0.15, 0.24), (0.30, 0.40), (0.47, 0.56), (0.62, 0.72), (0.78, 0.86), (0.91, 1.0)],
              lambda x, y: 0.8 + 0.042 * (y - 117),
              dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23', contact='3e5629',
                   trail='ccb290'),
              lambda x, y: orig[x, y] in land,
              seam=lambda c: hx(darker.get('%02x%02x%02x' % c, '%02x%02x%02x' % c)))
    save(img, 'final_vista')
    REPORT['vista'] = dict(box=box, painted=n, **haze,
                           far_hill_lum=mean_lum(src, [(x, y) for x in range(60, 230) for y in range(119, 125)
                                                        if orig[x, y] == hx('a3b0ae')]),
                           slope_lum=mean_lum(src, [(x, y) for x in range(140, 215) for y in range(124, 200)
                                                    if orig[x, y] in land]),
                           trunk_bottom_y=max(y for (x, y) in roles if 0 <= x < W and 0 <= y < H and allowed(x, y)
                                              and abs(x - 136) < 8),
                           hill_top_y=skyline[136],
                           colours_before=len(colours(src)), colours_after=len(colours(img)),
                           new_colours=sorted('%02x%02x%02x' % c for c in colours(img) - colours(src)),
                           cloud_px=len(clouds))


# ---------------------------------------------------------------------------------------------- 3. reveal backdrop
HZ = 120  # the horizon at eye level, just above the lamp
# sky bands packed so the brightest sits at eye level and the crown's height is mid-blue, not night
SKY_BANDS = [(0, '2e3b52'), (10, '3a4a60'), (22, '4a5e73'), (36, '566c80'), (52, '62788a'), (68, '7f939a'),
             (86, 'a3a891'), (100, 'c2b58f'), (111, 'd9bf94')]
LAND_BANDS = [(120, 'c2b58f'), (122, 'a3a891'), (126, '979683'), (131, '878b7c'), (138, '838e87'),
              (146, '748471'), (156, '6f8455'), (170, '59753c'), (188, '4b6731')]
LAND_EXT = [c for _, c in LAND_BANDS] + ['3d542b', '2d3729']
PLACEHOLDER_SKY = ['2e3b52', '3a4a60', '4a5e73', '566c80', '62788a', '7f939a', 'a3a891', 'c2b58f', 'd9bf94', '8d95a6',
                   'e2c0a4']  # the bands, and the old placeholder's two thin clouds with their light edge
GLOW = ['97a8a6', '92a2a2', '7a8d96', 'afbdb2', '6e818c', 'b6c1b5', 'd3dcc5', '869698']


def band_at(bands, x, y):
    i = 0
    for k, (y0, _) in enumerate(bands):
        if y >= y0:
            i = k
    if i + 1 < len(bands) and y == bands[i + 1][0] - 1 and (x + y) % 2 == 0:
        i += 1
    return i


def build_backdrop():
    """story.backdrop.tower_sky as proposed: one fixed 384x216 picture behind the whole climb."""
    W, H = 384, 216
    img = Image.new('RGB', (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            px[x, y] = hx(SKY_BANDS[band_at(SKY_BANDS, x, y)][1]) if y < HZ else hx(LAND_EXT[band_at(LAND_BANDS, x, y)])
    rnd = random.Random(11)

    def blob(cx, cy, rx, ry, col, hi=None):
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if 0 <= xx < W and HZ + 1 <= yy < H and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1:
                    px[xx, yy] = hx(col)
                    if hi and ((xx - cx - 0.35 * rx) / rx) ** 2 + ((yy - cy + 0.5 * ry) / ry) ** 2 <= 0.25:
                        px[xx, yy] = hx(hi)

    def depth_y():  # ground d tiles out shows at y = HZ + 28800 / d
        d = math.exp(rnd.uniform(math.log(300), math.log(7000)))
        return HZ + 28800 / d

    for _ in range(26):  # grass openings
        y = depth_y()
        if y < H:
            s = y - HZ
            i = band_at(LAND_BANDS, 0, int(y))
            blob(rnd.uniform(0, W), y, max(1.5, rnd.uniform(0.6, 1.4) * s * 0.5), max(0.6, 0.25 * s * 0.5),
                 LAND_EXT[max(0, i - 1)])
    for _ in range(90):  # woods: ordinary trees, tiny next to the great tree on the same horizon
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
    for _ in range(16):  # upland springs
        y = depth_y()
        if y < H:
            x = rnd.uniform(0, W)
            for j in range(max(1, int((y - HZ) * 0.06))):
                xx, yy = int(x) + j, int(y)
                if xx < W:
                    px[xx, yy] = hx('c2d4df' if j else 'deded0')

    # the root road: from the bottom of the frame (300 tiles out, right of the Reach's shaft) to the tree's foot.
    # Its width follows the same lens: about 1.6 tiles near the Tower, 4 tiles at the tree.
    def seam(c):
        i = LAND_EXT.index('%02x%02x%02x' % c) if '%02x%02x%02x' % c in LAND_EXT else 4
        return hx(LAND_EXT[min(len(LAND_EXT) - 1, i + 1)])

    root_road(img, [(232, 216), (248, 199), (270, 185), (281, 170), (299, 158), (304, 146), (315, 138), (318, 131),
                    (321, 127)],
              [(0.0, 0.14), (0.19, 0.33), (0.38, 0.50), (0.56, 0.66), (0.72, 0.80), (0.86, 0.92), (0.96, 1.0)],
              lambda x, y: max(0.5, 0.045 * (y - HZ) + 0.4),
              dict(crest='6f8455', crest_lit='908940', bark='8c6545', lit='b06b3d', dark='5d4b34', contact='2d3729',
                   trail='c9b38e'),
              lambda x, y: y > HZ, seam=seam)
    # low mist under the eye, two birds below us
    for (y, x0, x1) in ((151, 140, 230), (152, 132, 250), (153, 0, 96), (154, 6, 120), (171, 330, 384),
                        (172, 320, 384)):
        for x in range(x0, x1):
            if (x * 7 + y) % 23 != 0:
                px[x, y] = hx('c2d4df' if y in (151, 153, 171) else 'a0adb0')
    for (bx, by) in ((262, 196), (272, 190)):
        for (dx, dy) in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            px[bx + dx, by + dy] = hx('2d3729')
    # the great tree on the horizon, right of the crook: still far above eye level after a 30-tile climb
    ramp = Ramp([c for _, c in SKY_BANDS])
    ref = [hx(SKY_BANDS[band_at(SKY_BANDS, 1, y)][1]) if y < HZ else hx(LAND_EXT[min(1, y - HZ)]) for y in range(H)]
    roles = tree_roles(cx=322, base_y=126, Ht=104, light=1, seed=7)
    src = img.copy()
    box, n, haze = paint_tree(img, roles, ramp, lambda x, y: True, ref_sky=ref)
    # a cloud strip crossing in front of the trunk, below the crown: the tree stands taller than weather
    for (y, x0, x1) in ((92, 270, 384), (93, 262, 376), (94, 286, 352)):
        for x in range(x0, x1):
            if (x * 5 + y) % 17 != 0:
                px[x, y] = hx('c2b58f' if y != 94 else 'a3a891')
    for (y, x0, x1) in ((27, 0, 64), (28, 14, 84)):  # one high streak on the empty side
        for x in range(x0, x1):
            px[x, y] = hx('566c80')
    tree_px = [(x, y) for (x, y) in roles if 0 <= x < W and 0 <= y < H]
    stats = dict(box=box, painted=n, **haze,
                 land_at_foot_lum=mean_lum(src, [(x, y) for x in range(280, 384) for y in range(120, 132)
                                                 if (x, y) not in roles]),
                 near_land_lum=mean_lum(src, [(x, y) for x in range(0, 384) for y in range(190, 216)]),
                 lamp_side_tree_px=sum(1 for (x, y) in tree_px if 150 <= x < 232 and y < HZ))
    return img, stats


def composite(frame_path, bd, glow=False):
    img = load_3x(frame_path)
    src = img.copy().load()
    px = img.load()
    bg_cols = {hx(c) for c in PLACEHOLDER_SKY}
    glow_cols = {hx(c) for c in GLOW}
    bp = bd.load()
    bg = [[src[x, y] in bg_cols or (glow and src[x, y] in glow_cols) for y in range(img.height)]
          for x in range(img.width)]
    for x in range(img.width):
        for y in range(img.height):
            if bg[x][y]:
                px[x, y] = bp[x, y]
    if glow:  # the lamp's glow, rebuilt over the new sky and land
        ramp = Ramp([c for _, c in SKY_BANDS])
        for x in range(img.width):
            for y in range(img.height):
                c = src[x, y]
                if c in glow_cols:
                    strong = lum(c) > 165
                    if y < HZ:
                        px[x, y] = ramp.get(ramp.idx(px[x, y]) + (2 if strong else 1))
                    else:
                        i = band_at(LAND_BANDS, x, y)
                        px[x, y] = hx(LAND_EXT[max(0, i - (3 if strong else 2))])
    n_bg = sum(1 for x in range(img.width) for y in range(img.height) if bg[x][y])
    return img, dict(backdrop_colours=len(colours(img, lambda x, y: bg[x][y])), backdrop_px=n_bg)


def mock_reveal():
    bd, stats = build_backdrop()
    save(bd, 'final_backdrop')
    hold, h = composite(f'{BUILD}/round2/11_reveal_hold_top.png', bd, glow=True)
    save(hold, 'final_hold')
    climb, c = composite(f'{BUILD}/round2/09_reveal_mid_climb.png', bd)
    save(climb, 'final_climb')
    REPORT['hold'] = dict(**stats, **h, slot_colours=len(colours(bd)))
    REPORT['climb'] = c


# ---------------------------------------------------------------------------------------------- 4. road far
def mock_road_far():
    img = load_3x(f'{BUILD}/round2/12_road_far_3.png')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    willow = {hx(c) for c in ('627755', '52634b', '6b825a', '768b61', '575245', '49463b')}
    hills = {hx('a4afb2'), hx('aeb9bb')}
    sky = {orig[x, y] for x in range(36, 170) for y in range(0, 107)} - willow - hills  # cloud strips stay in
    ramp = Ramp(['4d6582', '5f7894', '7a90a6', '8696a8', '9aa9b4', 'a9b0b4', 'afbabe', 'bdc7ca'])
    skyline = skyline_of(src, sky, 40)
    dom = row_sky(src, sky, 36, 170)
    clouds = cloud_mask(src, sky, dom)

    def allowed(x, y):
        return orig[x, y] in sky and y < skyline[x] and (x, y) not in clouds and x < 232

    roles = tree_roles(cx=104, base_y=141, Ht=96, light=1, seed=7)
    box, n, haze = paint_tree(img, roles, ramp, allowed, dom)
    save(img, 'final_road_far')
    REPORT['road_far'] = dict(box=box, painted=n, **haze, colours_before=len(colours(src)),
                              colours_after=len(colours(img)), new_colours=len(colours(img) - colours(src)),
                              far_hill_lum=mean_lum(src, [(x, y) for x in range(36, 170) for y in range(110, 134)
                                                          if orig[x, y] == hx('a4afb2')]))


# ---------------------------------------------------------------------------------------------- 5. Tower Rise
def rise_ridge(img, pts, allowed, worn_x=None, seed=5):
    """The root on the ground, close up, in the climbing root's own style: dark outline, a warm bark body with grain
    running along it, a lit upper edge, moss in loose patches, and its near (lower) side half buried under a turf
    lip, so it reads as one root lying in the ground and not a log on the grass."""
    px = img.load()
    W, H = img.size
    S = catmull(pts, 40)
    T, along = frame_of(S)
    rnd = random.Random(seed)
    L = along[-1]
    blobs = []
    s = 10.0
    while s < L:
        blobs.append((s + rnd.uniform(-5, 5), rnd.uniform(0.15, 0.55), rnd.uniform(5, 11), rnd.uniform(0.18, 0.34)))
        s += rnd.uniform(16, 30)
    knots = [rnd.uniform(0.15, 0.9) * L for _ in range(3)]
    best = {}
    for i, (x, y, r) in enumerate(S):
        nx, ny = -T[i][1], T[i][0]
        if ny > 0:
            nx, ny = -nx, -ny  # u > 0 is the upper (north, far) side
        Rr = int(r) + 4
        for yy in range(int(y) - Rr, int(y) + Rr + 1):
            for xx in range(int(x) - Rr, int(x) + Rr + 1):
                dx, dy = xx - x, yy - y
                q = math.hypot(dx, dy) / r
                if q > 1 + 2.0 / r:
                    continue
                cur = best.get((xx, yy))
                if cur is None or q < cur[0]:
                    best[(xx, yy)] = (q, (dx * nx + dy * ny) / r, along[i] + dx * T[i][0] + dy * T[i][1], r)

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H and allowed(x, y):
            px[x, y] = hx(c)

    for (xx, yy), (q, u, s, r) in best.items():
        bury = -0.45 - 0.25 * noise(int(s // 4), 3, 7)
        if q > 1.0:
            if u > 0 and q <= 1 + 1.2 / r:
                put(xx, yy, '101006')  # contact shadow along the far edge
            continue
        if u < bury:  # the near side is under the turf
            if u > bury - 0.10:
                c = '908940' if noise(xx, yy, 2) > 0.5 else '7b8643'
            else:
                c = ('667032', '727c3d', '656f33', '646e33')[int(noise(xx, yy, 4) * 3.99)]
        elif q > 1 - 1.0 / r and u > 0:
            c = '181412'
        elif u > 0.66:
            c = 'c49b69'
        else:
            c = 'b06b3d'
            g = noise(int(s // 8), int((u + 1) * 5), 3)
            if g > 0.70:
                c = 'ad693c'
            elif g < 0.22:
                c = '663f23'
            if u < bury + 0.16:
                c = '663f23'  # shadow just above the turf line
            for (sc, uc, rs, ru) in blobs:
                if ((s - sc) / rs) ** 2 + ((u - uc) / ru) ** 2 < 0.85 + 0.35 * noise(int(s), int(u * 9), 6):
                    c = '908940' if u > uc + 0.08 else '6b6f1d'
            for kc in knots:
                dk = math.hypot((s - kc) / 1.0, (u - 0.1) * r)
                if dk < 1.3:
                    c = 'ad693c'
                elif dk < 2.4:
                    c = '663f23'
            if worn_x and worn_x[0] <= xx <= worn_x[1] and -0.2 < u < 0.5 and noise(int(s // 2), int(u * 5), 8) > 0.2:
                c = 'c7a378'  # worn smooth where runners step over it
        put(xx, yy, c)


def mock_rise():
    path3 = f'{BUILD}/round2/05c_rise_side_west_col2_row3.png'
    big = Image.open(path3).convert('RGB')
    img = load_3x(path3)
    orig = img.copy().load()
    px = img.load()
    W, H = img.size
    keep = {hx(c) for c in ('b06b3d', '181412', '663f23', '0b0e11', '8e7f5e', '908940', '241b16', '9c8c68',
                            '2a1a0f', 'ad693c', 'c49b69', '3f2716', '23180e', '101006', '0f0905', '44421a')}
    line = {hx('f2d27a'), hx('ddca86')}
    # 1. the blockout's olive base pad under the climbing root's legs goes: the root no longer has its own base
    pad = {hx(c) for c in ('44421a', '19180a', '101006', '180f08', '0f0905')}
    for y in range(194, H):
        for x in range(104, 198):
            if orig[x, y] in pad:
                c = None
                for yy in range(y + 1, H):  # paving or grass below it
                    if orig[x, yy] not in pad and orig[x, yy] not in keep:
                        c = orig[x, yy]
                        break
                if c is None:
                    for xx in range(x + 1, W):
                        if orig[xx, y] not in pad and orig[xx, y] not in keep:
                            c = orig[xx, y]
                            break
                if c is not None:
                    px[x, y] = c

    def allowed(x, y):
        if y < 37:  # the dialogue box
            return False
        if orig[x, y] in line:  # waylines stay in front
            return False
        if x >= 128 and orig[x, y] in keep - pad:  # above the bend, the existing climbing root stays as it is
            return False
        return True

    # Screen = world here: the side lane is x 0..96, the root meets the ground at world (100, 214). It comes in from
    # past the west edge at full girth, half buried, runs low across the lane (walkable, worn smooth at col 2), bends
    # at the foot and rears up into the climb. Its girth at the ground is the biggest anywhere on the Tower.
    rise_ridge(img, [(-22, 124, 15.0), (8, 132, 15.5), (34, 148, 16.0), (58, 168, 16.5), (80, 189, 16.5),
                     (98, 201, 16.0), (113, 201, 15.0), (125, 189, 13.5), (135, 171, 11.5), (142, 156, 10.0)],
               allowed, worn_x=(48, 72))
    # 2. the UI: at 1x the in-game text cannot sit on the 1x grid, so each UI pixel takes its 3x3 block's most common
    # colour (the text drops out); the 3x puts the original crisp UI back
    bp = big.load()
    ui = [(0, 0, 204, 37), (300, 174, 384, 216)]
    for (x0, y0, x1, y1) in ui:
        for y in range(y0, y1):
            for x in range(x0, x1):
                cnt = {}
                for j in range(3):
                    for i in range(3):
                        c = bp[3 * x + i, 3 * y + j]
                        cnt[c] = cnt.get(c, 0) + 1
                px[x, y] = max(cnt, key=cnt.get)
    img.save(f'{OUT}/final_rise_root_1x.png')
    out3 = img.resize((W * 3, H * 3), Image.NEAREST)
    o3 = out3.load()
    for (x0, y0, x1, y1) in ui:
        for y in range(3 * y0, 3 * y1):
            for x in range(3 * x0, 3 * x1):
                o3[x, y] = bp[x, y]
    out3.save(f'{OUT}/final_rise_root_3x.png')


# ---------------------------------------------------------------------------------------------- 6. cx-12 change
WEST = 48  # context drawn west of the cell, where the new ridge prop carries the root on toward the tree


def root_foot_after():
    """A rough paint-over of Codex's cx-12 root_foot (read only) showing the one change: the flared base and the
    footing stone go, and the root leaves the cell's west edge at full girth, half buried. Its texture is cloned
    from the candidate's own root body. Codex paints the real one."""
    cell = Image.open(C12).convert('RGBA')
    cp = cell.load()
    CW, CH = cell.size
    # the main root's centre line, fitted on its upper body (left-most opaque run of each row)
    ys, xs, ws = [], [], []
    for y in range(16, 80):
        run = [x for x in range(CW) if cp[x, y][3]]
        if not run:
            continue
        x0 = run[0]
        x1 = x0
        while x1 + 1 < CW and cp[x1 + 1, y][3]:
            x1 += 1
        ys.append(y)
        xs.append((x0 + x1) / 2)
        ws.append(x1 - x0 + 1)
    n = len(ys)
    my, mx = sum(ys) / n, sum(xs) / n
    b = sum((ys[i] - my) * (xs[i] - mx) for i in range(n)) / sum((y - my) ** 2 for y in ys)
    a = mx - b * my
    dl = math.hypot(b, 1)
    d1 = (-b / dl, -1 / dl)  # up the root
    n1 = (d1[1], -d1[0])     # its upper-left (lit, mossy) side
    hw1 = (sum(ws) / n) / 2 / dl
    apex = (a + b * 106, 106.0)
    d2 = (-0.79, -0.61)      # the ground arm, heading west-north-west to the ridge
    n2 = (0.61, -0.79)       # its upper (north) side
    out = Image.new('RGBA', (WEST + CW, CH), (0, 0, 0, 0))
    op = out.load()

    def main_u(x, y):
        return (x - apex[0]) * n1[0] + (y - apex[1]) * n1[1], (x - apex[0]) * d1[0] + (y - apex[1]) * d1[1]

    # 1. keep the candidate except the flared base, rootlets and stone at the bottom left
    for y in range(CH):
        for x in range(CW):
            c = cp[x, y]
            if not c[3]:
                continue
            u, s = main_u(x, y)
            flare = y > 84 and x < apex[0] + 26 and (abs(u) > hw1 + 1.0 or s < -2)
            if flare:
                continue
            op[WEST + x, y] = c
    # 2. the ground arm, cloned from the root body above, thickening toward the west
    for y in range(CH):
        for X in range(WEST + CW):
            x = X - WEST
            s2 = (x - apex[0]) * d2[0] + (y - apex[1]) * d2[1]
            u2 = (x - apex[0]) * n2[0] + (y - apex[1]) * n2[1]
            if s2 < -4:
                continue
            hw2 = min(17.0, hw1 + 0.12 * (s2 + 4) + 2.0) * (1 + 0.07 * math.sin(s2 / 6.0))
            if abs(u2) > hw2:
                continue
            k = u2 / hw2
            bury = -0.40 - 0.22 * noise(int(s2 // 4), 2, 9)
            if k < bury:
                if k > bury - 0.12:
                    col = (0x90, 0x89, 0x40, 255) if noise(X, y, 3) > 0.5 else (0x6b, 0x6f, 0x1d, 255)
                else:
                    col = (0x6b, 0x6f, 0x1d, 255) if noise(X, y, 5) > 0.45 else (0x44, 0x42, 0x1a, 255)
                if op[X, y][3] == 0 or x < apex[0]:
                    op[X, y] = col
                continue
            if abs(u2) > hw2 - 1.0 and u2 > 0 and noise(int(s2), 1, 2) > 0.35:
                col = (0x3f, 0x27, 0x16, 255)
            else:
                sx = apex[0] + (s2 + 30) * d1[0] + k * hw1 * n1[0]
                sy = apex[1] + (s2 + 30) * d1[1] + k * hw1 * n1[1]
                sx, sy = int(round(sx)), int(round(sy))
                col = cp[sx, sy] if 0 <= sx < CW and 0 <= sy < CH and cp[sx, sy][3] else (0xb0, 0x6b, 0x3d, 255)
            if op[X, y][3] == 0 or x < apex[0] + 2:
                op[X, y] = col
    # 3. a rounded elbow where the two arms meet, so it bends like one root instead of meeting in a V
    ex, ey = apex[0] + 1.0, apex[1] - 5.0
    for y in range(int(ey) - 14, min(CH, int(ey) + 14)):
        for x in range(int(ex) - 14, int(ex) + 14):
            X = x + WEST
            if not (0 <= X < WEST + CW) or op[X, y][3]:
                continue
            if math.hypot(x - ex, y - ey) <= hw1 + 1.5:
                sx, sy = int(round(x + 30 * d1[0])), int(round(y + 30 * d1[1]))
                op[X, y] = cp[sx, sy] if 0 <= sx < CW and 0 <= sy < CH and cp[sx, sy][3] else (0xb0, 0x6b, 0x3d, 255)
    return cell, out


def mock_root_foot_change():
    cell, after = root_foot_after()
    bg = hx('e6c697')
    W, H = 2 * (WEST + 96) + 40, 166
    img = Image.new('RGB', (W, H), bg)
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    ink, faint = hx('3f2716'), hx('a37a32')
    before = Image.new('RGBA', (WEST + 96, 120), (0, 0, 0, 0))
    before.paste(cell, (WEST, 0))
    xs = (12, 12 + WEST + 96 + 16)
    for x0, im in zip(xs, (before, after)):
        d.rectangle((x0, 140, x0 + WEST + 96, 141), fill=hx('908940'))  # ground line
        img.paste(im, (x0, 22), im)
        for y in range(18, 146, 4):  # the cell's west edge (frame x 0, world x 96, tile col 4)
            img.putpixel((x0 + WEST, y), faint)
            img.putpixel((x0 + WEST, y + 1), faint)
    d.text((xs[0], 4), 'TODAY: CX-12 CANDIDATE', font=f, fill=ink)
    d.text((xs[1], 4), 'PROPOSED (ROUGH PAINT-OVER)', font=f, fill=ink)
    d.text((xs[0], 146), 'OWN BASE, FOOTING STONE', font=f, fill=ink)
    d.text((xs[0], 155), 'DASHED = CELL WEST EDGE', font=f, fill=faint)
    d.text((xs[1], 146), 'LEAVES THE WEST EDGE AT FULL', font=f, fill=ink)
    d.text((xs[1], 155), 'GIRTH, HALF BURIED, TO THE TREE', font=f, fill=ink)
    save(img, 'final_root_foot_change')
    a = after.load()
    REPORT['root_foot'] = dict(
        today_west_edge_rows=[y for y in range(120) if cell.load()[0, y][3]][:1] + [y for y in range(120) if cell.load()[0, y][3]][-1:],
        proposed_west_edge_rows=[y for y in range(120) if a[WEST, y][3]][:1] + [y for y in range(120) if a[WEST, y][3]][-1:])
    return after


def mock_tower(after):
    """The whole Tower (assembled blockout, 432x720) with the proposed root_foot in place: the root arrives from past
    the frame's west edge at full girth. root_vein and the Reach are as built; see the doc for root_vein."""
    tw = Image.open(f'{BUILD}/assembled_blockout.png').convert('RGBA')
    tp = tw.load()
    rootc = {hx(c) for c in ('c49b69', 'b06b3d', '663f23', '3f2716', '23180e')}
    cell = after.crop((WEST, 0, WEST + 96, 120))
    cpx = cell.load()
    for y in range(120):  # the blockout's own foot goes where the new root does not cover it (lower left only)
        for x in range(96):
            p = tp[x, 600 + y]
            if p[3] and p[:3] in rootc and not cpx[x, y][3] and (y > 40 and x < 60):
                tp[x, 600 + y] = (0, 0, 0, 0)
    tw.alpha_composite(cell, (0, 600))
    bg = Image.new('RGBA', tw.size, hx('a9b5ba') + (255,))
    bg.alpha_composite(tw)
    save(bg.convert('RGB'), 'final_tower_root')


# ---------------------------------------------------------------------------------------------- 7. map
def mock_map():
    W, H = 384, 292
    img = Image.new('RGB', (W, H), hx('e6c697'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    ink, faint, rootc, water, panel = hx('3f2716'), hx('a37a32'), hx('7c4a26'), hx('07515c'), hx('f5d9a8')

    def text(x, y, s, c=ink, knock=True):
        if knock:  # clear the panel under the label so nothing touches it
            w = d.textlength(s, font=f)
            d.rectangle((x - 1, y, x + w, y + 8), fill=panel)
        d.text((x, y), s, font=f, fill=c)

    def dashed(pts, c, on=2, off=2):
        S = catmull([(x, y, 0) for x, y in pts], 30)
        for i, (x, y, _) in enumerate(S):
            if i % (on + off) < on:
                img.putpixel((int(x + 0.5), int(y + 0.5)), c)

    # --- region panel: 1 px = 40 tiles
    d.rectangle((3, 11, 199, 212), fill=panel, outline=faint)
    text(4, 1, 'REGION, 1 PX = 40 TILES', knock=False)
    rnd = random.Random(4)
    tree = (131, 76)   # 4,400 tiles = 110 px north of the Tower, N 7 deg E
    tower = (117, 186)
    for _ in range(60):  # grass openings and springs, kept off the tree and the root line
        x, y = rnd.uniform(8, 194), rnd.uniform(30, 182)
        if math.hypot(x - tree[0], y - tree[1]) < 14 or abs(x - (tree[0] + (tower[0] - tree[0]) * (y - tree[1]) / (tower[1] - tree[1]))) < 9:
            continue
        d.rectangle((int(x), int(y), int(x) + 2, int(y) + 1), fill=hx('908940'))
    for _ in range(14):
        x, y = rnd.uniform(30, 185), rnd.uniform(96, 170)
        if abs(x - 124) < 12:
            continue
        d.rectangle((int(x), int(y), int(x) + 1, int(y)), fill=hx('2d9e9f'))
    river = [(4, 194), (40, 197), (80, 195), (118, 197), (160, 200), (198, 198)]
    for (x, y, _) in catmull([(x, y, 0) for x, y in river], 40):
        for k in range(3):
            img.putpixel((int(x + 0.5), int(y + 0.5) + k), hx('2d9e9f') if k < 2 else hx('12837f'))
    # the view from the far bank (title and vista), a thin cone
    eye = (113, 207)
    for end in ((98, 80), (158, 80)):
        S = catmull([(eye[0], eye[1], 0), (end[0], end[1], 0)], 160)
        for i, (x, y, _) in enumerate(S):
            if i % 6 < 4:
                img.putpixel((int(x + 0.5), int(y + 0.5)), hx('d4b483'))
    d.rectangle((eye[0] - 1, eye[1] - 1, eye[0] + 1, eye[1] + 1), fill=water)
    # the tree: crown 720 tiles across = 18 px
    d.ellipse((tree[0] - 9, tree[1] - 9, tree[0] + 9, tree[1] + 9), fill=hx('6b6d45'), outline=hx('44421a'))
    d.ellipse((tree[0] - 5, tree[1] - 5, tree[0] + 5, tree[1] + 5), outline=hx('908940'))
    d.rectangle((tree[0] - 1, tree[1] - 1, tree[0] + 1, tree[1] + 1), fill=hx('3f2716'))
    rpts = [(131, 85), (127, 98), (133, 111), (124, 126), (129, 140), (119, 154), (123, 166), (116, 176), (117, 184)]
    S = catmull([(x, y, 0) for x, y in rpts], 30)
    N = len(S)
    surf = [(0.0, 0.09), (0.21, 0.31), (0.43, 0.52), (0.64, 0.73), (0.86, 1.0)]
    for i, (x, y, _) in enumerate(S):
        X, Y = int(x + 0.5), int(y + 0.5)
        if any(a <= i / (N - 1) <= b for a, b in surf):
            d.rectangle((X - 1, Y - 1, X + 1, Y + 1), fill=hx('b06b3d'))
        elif i % 4 < 2:
            img.putpixel((X, Y), hx('663f23'))
    # Highbank at true size (about 86 x 40 tiles: 2 x 1 px), the Tower's lamp as one lit dot
    d.rectangle((tower[0] - 2, tower[1], tower[0] + 1, tower[1] + 1), fill=ink)
    img.putpixel((tower[0], tower[1] - 1), hx('f2d27a'))
    # distance bracket
    d.line(((188, 76), (188, 186)), fill=faint)
    d.line(((185, 76), (191, 76)), fill=faint)
    d.line(((185, 186), (191, 186)), fill=faint)
    d.polygon([(186, 16), (183, 24), (189, 24)], fill=ink)
    text(183, 26, 'N')
    text(146, 52, 'GREAT TREE')
    text(146, 61, '(WORKING)')
    text(155, 120, '4,400', faint)
    text(155, 129, 'TILES', faint)
    text(8, 36, 'UPLAND SPRINGS AND')
    text(8, 45, 'GRASS OPENINGS')
    text(8, 74, 'FAR-BANK VIEW')
    text(8, 83, '(TITLE, VISTA)')
    text(146, 150, 'ROOT', rootc)
    text(146, 159, 'ROAD', rootc)
    d.line(((144, 155), (130, 148)), fill=rootc)
    text(8, 176, 'HIGHBANK, TO SCALE')
    d.line(((100, 180), (114, 186)), fill=ink)
    text(8, 202, 'RIVER', water)
    text(130, 202, 'FAR BANK', water)
    d.rectangle((8, 112, 18, 114), fill=hx('b06b3d'))
    text(22, 109, 'ROOT, SURFACED')
    for x in range(8, 19, 4):
        img.putpixel((x, 124), hx('663f23'))
        img.putpixel((x + 1, 124), hx('663f23'))
    text(22, 120, 'UNDERGROUND')
    d.line(((8, 140), (33, 140)), fill=ink)
    d.line(((8, 137), (8, 143)), fill=ink)
    d.line(((33, 137), (33, 143)), fill=ink)
    text(38, 136, '1000 TILES')

    # --- Highbank inset: 2 px = 1 tile
    d.rectangle((204, 11, 381, 212), fill=panel, outline=faint)
    text(206, 1, 'HIGHBANK, 2 PX = 1 TILE', knock=False)
    rx0, ry0 = 300, 70
    sx0, sy0 = 232, ry0 + 28

    def R(c, r):
        return (int(rx0 + 2 * c), int(ry0 + 2 * r))

    d.rectangle((rx0, ry0, rx0 + 52, ry0 + 28), fill=hx('ccb290'), outline=ink)
    d.rectangle((rx0 + 1, ry0 + 1, rx0 + 51, ry0 + 2), fill=hx('6b6d45'))
    d.rectangle((*R(7, 6), *R(19, 9)), fill=panel, outline=ink)
    d.rectangle((*R(4, 1), *R(7, 9)), fill=hx('e0c08a'), outline=faint)   # solid west wing (existing)
    d.rectangle((*R(4, 7), *R(5, 9)), fill=hx('b06b3d'))                  # the root foot, rearing up at (4,8)
    for k in range(10):                                                     # the ridge, walkable, cols 0-3
        x, y = R(4 - k * 0.45, 8 - k * 0.26)
        d.rectangle((x - 1, y, x + 1, y + 2), fill=hx('b06b3d'))
        img.putpixel((x, y), hx('6b6f1d'))
    d.rectangle((*R(2, 10), R(2, 10)[0] + 1, R(2, 10)[1] + 1), fill=ink)
    img.putpixel(R(12, 7), hx('f2d27a'))
    d.rectangle((sx0, sy0, sx0 + 112, sy0 + 32), fill=hx('e6c697'), outline=ink)
    for (c, r) in ((3, 5), (12, 5), (20, 5), (28, 5), (12, 11), (21, 11)):
        d.rectangle((sx0 + 2 * c - 2, sy0 + 2 * r - 2, sx0 + 2 * c + 3, sy0 + 2 * r + 2), fill=hx('c7a378'),
                    outline=faint)
    d.rectangle((sx0, sy0 + 34, sx0 + 146, sy0 + 37), fill=hx('2d9e9f'))
    dashed([R(-0.5, 5.4), (292, 76), (288, 60), (288, 42), (290, 28)], hx('663f23'))
    d.polygon([(290, 21), (287, 26), (293, 26)], fill=hx('663f23'))
    text(206, 16, 'TO THE TREE,', rootc)
    text(206, 25, 'UNDERGROUND', rootc)
    text(334, 58, 'RISE')
    text(238, 110, 'STREET')
    text(238, 136, 'RIVER', water)
    text(206, 46, 'RIDGE (NEW)', rootc)
    d.line(((250, 55), (298, 82)), fill=rootc)
    text(318, 108, 'POST 2,10', faint)
    d.line(((316, 112), (306, 91)), fill=faint)
    d.line(((234, 152), (254, 152)), fill=ink)
    d.line(((234, 149), (234, 155)), fill=ink)
    d.line(((254, 149), (254, 155)), fill=ink)
    text(258, 148, '10 TILES')
    for i, s in enumerate(['TREE N 7 DEG E OF THE', 'TOWER, 4,400 TILES OUT', 'ROOT ABOUT 4 TILES WIDE',
                           'AT THE TREE, 1.5 AT', 'THE TOWER']):
        text(208, 166 + 9 * i, s)

    # --- side view strip: 1 px = 8 tiles, the distance between them is not to scale
    d.rectangle((3, 216, 381, 289), fill=panel, outline=faint)
    gy = 283
    d.line(((6, gy), (190, gy)), fill=ink)
    d.line(((206, gy), (378, gy)), fill=ink)
    for x0 in (191, 199):  # the break in the ground line
        d.line(((x0, gy + 3), (x0 + 5, gy - 3)), fill=ink)
    roles = tree_roles(cx=96, base_y=gy - 1, Ht=60, light=-1, seed=7)
    paint_flat(img, roles, dict(body='6b6d45', shade='44421a', curtain='44421a', trunk='663f23',
                                trunk_shade='3f2716', limb='663f23'))
    xs = [x for (x, y) in roles]
    ys = [y for (x, y) in roles]
    tx = 352
    d.rectangle((tx - 1, gy - 4, tx + 1, gy - 1), fill=hx('b06b3d'))
    img.putpixel((tx + 1, gy - 5), hx('f2d27a'))
    text(218, 220, 'SIDE VIEW, 1 PX = 8 TILES')
    text(218, 229, 'THE GAP IS NOT TO SCALE', faint)
    text(178, 252, 'GREAT TREE: 480 TALL,')
    text(178, 261, 'CROWN ABOUT 720 ACROSS')
    text(318, 266, 'TOWER 30')
    text(214, 272, '4,400 TILES', faint)
    REPORT['map_profile'] = dict(tree_w_px=max(xs) - min(xs) + 1, tree_h_px=max(ys) - min(ys) + 1,
                                 tree_w_tiles=(max(xs) - min(xs) + 1) * 8, tree_h_tiles=(max(ys) - min(ys) + 1) * 8)
    save(img, 'final_map')


# ---------------------------------------------------------------------------------------------- 8. size A/B
def mock_size_ab():
    rows = [('TITLE', 'final_title', 'concept_b-bluff/title_tree'), ('VISTA', 'final_vista', 'concept_b-bluff/vista_tree'),
            ('REVEAL HOLD', 'final_hold', 'concept_b-bluff/hold_tree')]
    W, H = 768 + 6, 3 * 216 + 3 * 11 + 14
    img = Image.new('RGB', (W, H), hx('1a1410'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    d.text((4, 2), 'PICKED: FAR, ABOUT 100 PX, HAZED', font=f, fill=hx('f0d696'))
    d.text((392, 2), 'ALTERNATIVE (B): CLOSE, CROWN OVERHEAD', font=f, fill=hx('f0d696'))
    y = 14
    for (label, a, b) in rows:
        d.text((4, y), label, font=f, fill=hx('be9c62'))
        y += 11
        img.paste(Image.open(f'{OUT}/{a}_1x.png').convert('RGB'), (0, y))
        img.paste(Image.open(f'{GT}/{b}_1x.png').convert('RGB'), (390, y))
        y += 216
    save(img, 'final_size_ab')


def review():
    names = ['final_title', 'final_vista', 'final_hold', 'final_climb', 'final_road_far', 'final_rise_root']
    ims = [Image.open(f'{OUT}/{n}_1x.png').convert('RGB') for n in names]
    sheet = Image.new('RGB', (768, 648), (0, 0, 0))
    for i, im in enumerate(ims):
        sheet.paste(im, ((i % 2) * 384, (i // 2) * 216))
    sheet.resize((1536, 1296), Image.NEAREST).save(f'{SCRATCH}/final_sheet.png')
    m = Image.open(f'{OUT}/final_map_1x.png').convert('RGB')
    r = Image.open(f'{OUT}/final_root_foot_change_1x.png').convert('RGB')
    t = Image.open(f'{OUT}/final_tower_root_1x.png').convert('RGB').crop((0, 300, 432, 720))
    s2 = Image.new('RGB', (384 + 432 + 4, 420 + 170), (0, 0, 0))
    s2.paste(m, (0, 0))
    s2.paste(r, (0, 296))
    s2.paste(t, (388, 0))
    s2.resize((s2.width * 2, s2.height * 2), Image.NEAREST).save(f'{SCRATCH}/final_sheet2.png')
    crops = [('final_title', (180, 96, 300, 176)), ('final_vista', (60, 30, 250, 200)),
             ('final_hold', (220, 10, 384, 216)), ('final_rise_root', (0, 100, 200, 216)),
             ('final_road_far', (40, 30, 240, 140)), ('final_root_foot_change', (150, 15, 330, 150))]
    z = Image.new('RGB', (190 * 3, 216 * 2), (0, 0, 0))
    for i, (n, box) in enumerate(crops):
        z.paste(Image.open(f'{OUT}/{n}_1x.png').convert('RGB').crop(box), ((i % 3) * 190, (i // 3) * 216))
    z.resize((z.width * 3, z.height * 3), Image.NEAREST).save(f'{SCRATCH}/final_zoom.png')


if __name__ == '__main__':
    mock_title()
    mock_vista()
    mock_reveal()
    mock_road_far()
    mock_rise()
    after = mock_root_foot_change()
    mock_tower(after)
    mock_map()
    mock_size_ab()
    review()
    for k, v in REPORT.items():
        print(k, v)
