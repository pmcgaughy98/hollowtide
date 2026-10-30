"""Reading 2, "under its reach" (proposal). The great tree is the working label; the name is Preston's.

Preston, 2026-10-27: "like not too far from the town. Like the tree of life kind of like its so great and vasts its
at the center of the forest but its just so big its influence is everywhere around the town."

The proposal drawn here:
  - the great tree stands about 115 tiles from the Tower, N 17 deg W, at the heart of the forest that rings Highbank
  - 150 tiles tall (5 Towers), trunk 24 tiles across, crown about 175 by 210 tiles, fullest on its south and west side
  - its south rim reaches the Rise's north-west corner, so the town lives at the edge of its canopy; the Tower itself
    stands about 6 tiles outside the rim, in open sky
  - the Tower stays the landmark: the tree is never whole in a town view (the frame always crops it), it is cool,
    flat and hazed, it always sits west (left) of the Tower, and nothing of it comes near the crook or the lamp

Size math, one lens for every view: something w tiles wide at d tiles shows w * f / d px at 1x (f = 961 for the title
and vista, from the Tower's own height in them; 960 for the reveal camera). The script prints every number it uses.

Mocks (each saved at 1x and 3x, nearest neighbour):
  boughs_title, boughs_vista, boughs_hold, boughs_influence, boughs_map
Run:  python mock_boughs.py
Reads (never writes) the round2 captures and the title render; borrows helpers from ../final/final_mocks.py.
"""
import math
import random
import sys
from PIL import Image, ImageDraw, ImageFont

ROOT = 'C:/Users/pmcga/dev/hollowtide'
GT = ROOT + '/docs/design/great-tree-2026-10-27'
OUT = GT + '/v2_boughs'
BUILD = ROOT + '/docs/design/wayline-tower-2026-10-27/build'
FONT = ROOT + '/assets/fonts/Silkscreen-Regular.ttf'
SCRATCH = ('C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/'
           '3708decc-a9ed-4fb1-9ffb-c06cd75193c6/scratchpad')
sys.path.insert(0, GT + '/final')
import final_mocks as fm  # noqa: E402  (helpers only; its __main__ guard stops it re-rendering)

hx, lum, noise, catmull, frame_of = fm.hx, fm.lum, fm.noise, fm.catmull, fm.frame_of
REPORT = {}


def save(img, name):
    img.save(f'{OUT}/{name}_1x.png')
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f'{OUT}/{name}_3x.png')


def hexs(c):
    return '%02x%02x%02x' % c[:3]


def vnoise(x, y, scale, seed):
    """Smooth value noise in 0..1 (hard-thresholded later, so edges stay pixel-hard)."""
    gx, gy = x / scale, y / scale
    x0, y0 = int(math.floor(gx)), int(math.floor(gy))
    fx, fy = gx - x0, gy - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = noise(x0, y0, seed), noise(x0 + 1, y0, seed)
    c, d = noise(x0, y0 + 1, seed), noise(x0 + 1, y0 + 1, seed)
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy


def nearest_lum(cols, target):
    return min(cols, key=lambda c: abs(lum(c) - target))


class tone_map(dict):
    """colour -> the colour in the same image that is lo..hi luminance darker (or lighter) and closest in hue. Used for
    dapple and heave, so the mocks only use colours the shot already has. Lazy, and it only searches the image's 200
    most common colours (the in-game captures carry thousands)."""

    def __init__(self, cols, lo, hi, darker=True):
        super().__init__()
        self.cands = [(d, lum(d), sum(d) or 1) for d in cols]
        self.lo, self.hi, self.darker = lo, hi, darker

    def __missing__(self, c):
        L = lum(c)
        sc = sum(c) or 1
        best, bs = c, 1e9
        for d, Ld, sd in self.cands:
            dl = (L - Ld) if self.darker else (Ld - L)
            if self.lo <= dl <= self.hi:
                hd = sum(abs(c[i] / sc - d[i] / sd) for i in range(3))
                s = hd * 100 + abs(dl - (self.lo + self.hi) / 2) * 0.2
                if s < bs:
                    best, bs = d, s
        self[c] = best
        return best


def common_colours(img, n=200):
    cnt = {}
    for c in img.getdata():
        cnt[c] = cnt.get(c, 0) + 1
    return [c for c, _ in sorted(cnt.items(), key=lambda kv: -kv[1])[:n]]


# ================================================================================================ geometry (proposal)
TREE_E, TREE_N = -33.0, 110.0           # trunk centre, tiles from the Tower's centre (east, north)
HEIGHT, TRUNK_W, BOUGH_ALT = 150, 24, 40
# crown radius by bearing from the trunk (degrees clockwise from north): fullest toward the open south and west
CROWN_R = [(0, 95), (45, 70), (90, 60), (135, 85), (155, 100), (165, 110), (180, 115), (210, 118), (250, 115),
           (290, 108), (330, 100), (360, 95)]
VIEWS = {  # viewer (east, north) in tiles from the Tower centre, focal length in px
    'title': (-26.0, -178.0, 961.0),   # far bank; Tower 162 px tall, 141 px right of centre
    'vista': (-13.0, -164.0, 961.0),   # road home's last rise; Tower 176 px tall at cx 268
    'hold': (0.0, -40.0, 960.0),       # reveal camera, lamp at x 192
}
# places around town, tiles from the Tower centre (Tower centre = Rise col 12.5 row 7; Street row 0 = 7 rows south)
PLACES = {
    'Tower centre (lamp above it)': (0.0, 0.0),
    'Rise north-west corner': (-12.5, 7.0),
    'Rise north edge above the Tower': (0.0, 7.0),
    'root foot (Rise col 5 row 4)': (-7.5, 3.0),
    'west lane post (Rise 2,10)': (-10.5, -3.0),
    'Street north-west corner': (-46.5, -7.0),
    'Home (Street 3,5)': (-43.5, -12.0),
    'Growth Shrine (Street 12,11)': (-34.5, -18.0),
    'Crossroads waymark (Street 48,11)': (1.5, -18.0),
    'Mouth of the Hollow (Ferry 25,9)': (18.5, -32.0),
    'East Quarter middle': (24.0, -14.0),
}


def crown_r(b):
    b %= 360
    for (b0, r0), (b1, r1) in zip(CROWN_R, CROWN_R[1:]):
        if b0 <= b <= b1:
            return r0 + (r1 - r0) * (b - b0) / (b1 - b0)
    return CROWN_R[0][1]


def bearing(dE, dN):
    return math.degrees(math.atan2(dE, dN)) % 360


def geometry_report():
    g = {}
    d = math.hypot(TREE_E, TREE_N)
    g['tree'] = dict(distance_tiles=round(d, 1), bearing='N %.0f W' % (360 - bearing(TREE_E, TREE_N)),
                     height_tiles=HEIGHT, height_in_towers=round(HEIGHT / 30, 1), trunk_tiles=TRUNK_W,
                     crown_w_e=round(crown_r(90) + crown_r(270)), crown_n_s=round(crown_r(0) + crown_r(180)))
    for k, (vx, vy, f) in VIEWS.items():
        dep = TREE_N - vy
        cx = 192 + (TREE_E - vx) * f / dep
        w = TRUNK_W * f / dep
        g[k] = dict(depth=round(dep), trunk_cx=round(cx, 1), trunk_w=round(w, 1), trunk_x=(round(cx - w / 2),
                    round(cx + w / 2)), whole_tree_px=round(HEIGHT * f / dep), tower_px=round(30 * f / (0 - vy)))
    rim = {}
    for name, (E, N) in PLACES.items():
        dE, dN = E - TREE_E, N - TREE_N
        dist = math.hypot(dE, dN)
        r = crown_r(bearing(dE, dN))
        rim[name] = dict(from_trunk=round(dist, 1), rim=round(r, 1), under_canopy=round(r - dist, 1))
    g['rim'] = rim
    REPORT['geometry'] = g
    return g


# ================================================================================================ tree parts as roles
def trunk_roles(cx, y_top, y_bot, hw_top, hw_bot, light=1, seed=1, flare=0.0, R=None, lit_u=0.8):
    """A braided trunk: three strands twist round each other as it climbs (dark seams, a lit lip beside each), bark
    grain, moss on the lit side, two or three hollows. Pixel -> role."""
    R = {} if R is None else R
    rnd = random.Random(seed)
    span = max(1.0, y_bot - y_top)
    knots = [(rnd.uniform(-0.45, 0.45), rnd.uniform(0.2, 0.75), rnd.uniform(1.4, 2.6)) for _ in range(3)]
    for y in range(int(y_top), int(y_bot) + 1):
        t = (y - y_top) / span
        hw = hw_top + (hw_bot - hw_top) * t + flare * hw_bot * max(0.0, (t - 0.82) / 0.18) ** 2
        for x in range(int(math.floor(cx - hw)), int(math.ceil(cx + hw)) + 1):
            u = (x - cx) / hw
            if abs(u) > 1.0:
                continue
            role = 'body'
            if u * light < -0.6:
                role = 'shade'
            elif u * light > lit_u:
                role = 'lit'
            for k, base in enumerate((-0.5, 0.02, 0.52)):
                seam = base + 0.17 * math.sin(y / (0.8 * hw_bot) * 2.0 + k * 2.1)
                du = (u - seam) * hw
                if abs(du) < 0.75:
                    role = 'braid'
                elif 0.75 <= du * light < 1.75 and role == 'body':
                    role = 'lit'
            if role == 'body' and noise(x, y // 5, seed) > 0.9:
                role = 'braid'
            if role in ('body', 'lit') and u * light > -0.1 and vnoise(x, y, 4.5, seed + 7) > 0.8:
                role = 'moss'
            for (ku, kt, kr) in knots:
                kx, ky = cx + ku * hw_bot, y_top + kt * span
                q = ((x - kx) / kr) ** 2 + ((y - ky) / (kr * 1.6)) ** 2
                if q <= 1.0:
                    role = 'knot'
                elif q <= 1.9 and (x - kx) * light > 0:
                    role = 'lit'
            R[(x, y)] = role
    return R


def limb_roles(R, pts, w0, w1):
    """A limb as a tube; its lower side is in shade (we see the canopy from beneath)."""
    S = catmull([(x, y, 0) for x, y in pts], 30)
    T, along = frame_of(S)
    L = along[-1] or 1.0
    for i, (x, y, _) in enumerate(S):
        r = w0 + (w1 - w0) * along[i] / L
        nx, ny = -T[i][1], T[i][0]
        if ny < 0:
            nx, ny = -nx, -ny  # normal pointing down
        for yy in range(int(y - r) - 1, int(y + r) + 2):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                dx, dy = xx - x, yy - y
                if dx * dx + dy * dy <= r * r + 0.25:
                    u = (dx * nx + dy * ny) / max(r, 0.5)
                    R[(xx, yy)] = 'limb_shade' if u > 0.25 else 'limb'
    return R


def hem_roles(x0, x1, edge, rnd, size=lambda x: 1.0, curtain=lambda x: (4, 14), density=lambda x: 0.3):
    """The canopy's hanging edge: leaf clumps along the edge line, a ragged lower lip, and curtain roots (thin aerial
    roots, the tree-of-life read) hanging under it, with a node every few pixels and a leaf tuft at some tips."""
    R = {}
    clumps = []
    x = float(x0)
    while x <= x1:
        s = size(x)
        rx, ry = rnd.uniform(5, 10) * s, rnd.uniform(2.4, 4.8) * s
        e = edge(int(x))
        if e is not None:
            clumps.append((x, e + rnd.uniform(-0.5, 1.2), rx, ry))
        x += rx * rnd.uniform(1.0, 1.45)
    bottom = {}
    for (cx, cy, rx, ry) in clumps:
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if x0 <= xx <= x1 and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1.0:
                    R[(xx, yy)] = 'clump'
                    bottom[xx] = max(bottom.get(xx, -99), yy)
    for xx, by in bottom.items():
        e = edge(xx)
        if e is not None:
            for yy in range(int(e) - 3, by):
                if (xx, yy) not in R:
                    R[(xx, yy)] = 'clump'
        R[(xx, by)] = 'clump_edge'
        if noise(xx, by, 31) > 0.62:
            R[(xx, by + 1)] = 'tip'
    last = -9
    for xx in sorted(bottom):
        if xx - last < 3 or rnd.random() > density(xx):
            continue
        last = xx
        lo, hi = curtain(xx)
        if hi <= 0:
            continue
        L = rnd.randint(lo, hi)
        y = bottom[xx] + 1
        cx = xx
        for k in range(L):
            R[(cx, y + k)] = 'node' if k % 5 == 4 else 'curtain'
            if rnd.random() < 0.07:
                cx += rnd.choice((-1, 1))
        if rnd.random() < 0.45:
            for (dx, dy) in ((0, 0), (-1, 0), (0, 1)):
                R[(cx + dx, y + L + dy)] = 'tuft'
    return R


def paint_roles(img, R, colour, allowed):
    px = img.load()
    W, H = img.size
    painted = []
    for (x, y), role in R.items():
        if 0 <= x < W and 0 <= y < H and allowed(x, y):
            c = colour(role, x, y)
            if c is not None:
                px[x, y] = c
                painted.append((x, y))
    return painted


LEAF_SHAPES = [[(0, 0, 'b'), (1, 0, 'b'), (1, 1, 'd')], [(0, 0, 'd'), (1, 0, 'b'), (2, -1, 'b')],
               [(0, 0, 'b'), (0, 1, 'd'), (1, 0, 'b')], [(0, 0, 'b'), (1, -1, 'b'), (1, 0, 'd')]]


def leaves(img, spots, body, dark, allowed=lambda x, y: True, shadow=None):
    """Drifting leaves (and fallen ones). With shadow set, a 1 px shadow sits a few rows under the leaf: in the air."""
    px = img.load()
    W, H = img.size
    n = 0
    for i, (x, y) in enumerate(spots):
        for (dx, dy, k) in LEAF_SHAPES[i % 4]:
            X, Y = x + dx, y + dy
            if 0 <= X < W and 0 <= Y < H and allowed(X, Y):
                px[X, Y] = hx(body) if k == 'b' else hx(dark)
                n += 1
        if shadow is not None:
            X, Y = x, y + 5
            if 0 <= X < W and 0 <= Y < H and allowed(X, Y):
                px[X, Y] = shadow(px[X, Y])
    return n


# ================================================================================================ 1. title
def mock_title(g):
    img = Image.open(f'{BUILD}/title_highbank_1x.png').convert('RGB')
    src = img.copy()
    orig = src.load()
    px = img.load()
    W, H = img.size
    ramp = fm.Ramp(['1e302e', '263d3a', '33524e', '43665a', '61785c', '9f946d', 'dca562'])
    sky = {hx(c) for c in ('1e302e', '263d3a', '33524e', '43665a', '61785c', '9f946d', 'dca562', '192726')}
    skyline = fm.skyline_of(src, sky, 95)
    dom = fm.row_sky(src, sky, 110, 270)
    band_dark = {hx('263d3a'), hx('1e302e')}
    WINDOW_X = 282  # nothing of the tree right of here: the crook and lamp keep their own dark field

    def in_wordmark(x, y):
        return 90 <= x <= 295 and y <= 52

    def allowed(x, y):
        if x >= WINDOW_X or (21 <= x <= 128 and 108 <= y <= 199):
            return False
        return orig[x, y] in sky and y < skyline[x]

    far_hill = hx('4f6858')
    woods_top = fm.skyline_of(src, sky | {far_hill}, 95)  # the ridge woods (the forest's south edge) hide its foot

    def allowed_trunk(x, y):
        if x >= WINDOW_X or (21 <= x <= 128 and 108 <= y <= 199):
            return False
        return (orig[x, y] in sky or orig[x, y] == far_hill) and y < woods_top[x]

    # the trunk: lens says centre x ~169, 80 px wide. It stands in front of the far hills, rises into the canopy band,
    # and its foot is hidden by its own forest (the ridge woods). Its colours follow the haze in a few clamped steps, so
    # it reads as one solid hazed thing and not as glass showing the sky bands through it.
    cx = g['title']['trunk_cx']
    hw = g['title']['trunk_w'] / 2
    R = trunk_roles(cx, 55, 130, hw - 7, hw, light=-1, seed=7, flare=0.28)
    limb_roles(R, [(cx - 18, 80), (cx - 30, 66), (cx - 44, 55), (cx - 52, 49)], 6, 3)
    limb_roles(R, [(cx + 20, 78), (cx + 32, 65), (cx + 46, 55), (cx + 56, 48)], 6, 3)
    limb_roles(R, [(cx - 30, 92), (cx - 52, 74), (cx - 70, 60), (cx - 82, 52)], 4, 2)
    limb_roles(R, [(cx + 6, 66), (cx + 10, 56), (cx + 12, 49)], 6, 4)
    clamp = {'body': (-2, 1, 2), 'lit': (-1, 1, 3), 'shade': (-3, 0, 2), 'braid': (-3, 0, 2), 'knot': (-3, 0, 1),
             'limb': (-2, 1, 2), 'limb_shade': (-3, 0, 2)}

    def tcol(role, x, y):
        # where the sky changes band, checker one row of the step so the bark has no hard horizontal stripe
        i = ramp.idx(dom[y - 1] if (y > 0 and (x + y) % 2 == 0) else dom[y])
        if role == 'moss':
            return hx('303e37') if i <= 4 else hx('4f6858')
        s, lo, hi = clamp[role]
        c = ramp.get(max(lo, min(hi, i + s)))
        if in_wordmark(x, y) and c not in band_dark:
            return None
        return c

    tree_px = paint_roles(img, R, tcol, allowed_trunk)

    # the hem of the canopy under the existing dark band (read as the underside of its boughs): clumps and curtains.
    # Under the wordmark only the band's own two darks, short and sparse; longer at the left and round the trunk.
    rnd = random.Random(21)
    near_trunk = lambda x: abs(x - cx) < hw + 30
    hem = hem_roles(30, WINDOW_X - 4, lambda x: 50, rnd,
                    size=lambda x: 1.25 if x < 90 or near_trunk(x) else (0.7 if x > 255 else 0.95),
                    curtain=lambda x: (10, 34) if x < 90 else ((6, 20) if near_trunk(x) else
                                                                ((2, 6) if x > 255 else (3, 11))),
                    density=lambda x: 0.55 if x < 90 or near_trunk(x) else 0.3)
    hcol = {'clump': '263d3a', 'clump_edge': '1e302e', 'tip': '263d3a', 'curtain': '263d3a', 'node': '1e302e',
            'tuft': '303e37'}

    def hem_col(role, x, y):
        c = hx(hcol[role])
        if in_wordmark(x, y) and (y < 48 or c not in band_dark):
            return None
        if role == 'clump' and y >= 53 and noise(x, y, 5) > 0.86:
            return hx('33524e')  # a leaf edge catching sky light, outside the wordmark only
        return c

    hem_px = paint_roles(img, hem, hem_col, lambda x, y: allowed(x, y) and y >= 46)

    # leaves drifting over town (never on the Tower, never in the menu)
    spots = [(214, 89), (241, 103), (262, 73), (150, 128), (198, 141), (230, 158), (268, 131), (176, 99)]
    nleaf = leaves(img, spots, '908940', '6b6f1d', lambda x, y: x < WINDOW_X and not (21 <= x <= 128 and
                                                                                    108 <= y <= 199))
    # roots holding the bluff: two great-tree roots come out from under the walkway, cross the bluff face and drink
    # at the river. Same bark as the Tower's root, kept in shadow.
    rcols = dict(out='3f2716', body='8c6545', lit='c49b69', mid='b06b3d', dark='663f23', moss='908940')

    def bank_root(pts, r0, r1):
        """A root seen side-on on the bluff face: it bulges out from under the walkway lip, curves down the wall and
        thins into the river. Lit from the left like the Tower's root."""
        S = catmull([(x, y, 0) for x, y in pts], 24)
        T, along = frame_of(S)
        L = along[-1] or 1.0
        best = {}
        for i, (x, y, _) in enumerate(S):
            r = r0 + (r1 - r0) * along[i] / L
            for yy in range(int(y - r) - 1, int(y + r) + 2):
                for xx in range(int(x - r) - 1, int(x + r) + 2):
                    dd = math.hypot(xx - x, yy - y)
                    if dd <= r + 0.35 and (best.get((xx, yy), (9,))[0] > dd / r):
                        nx, ny = -T[i][1], T[i][0]
                        if nx > 0:
                            nx, ny = -nx, -ny  # u > 0 faces left, toward the light
                        best[(xx, yy)] = (dd / r, ((xx - x) * nx + (yy - y) * ny) / r, along[i])
        for (xx, yy), (q, u, s) in best.items():
            if not (0 <= xx < W and 0 <= yy < H):
                continue
            if yy >= 202:  # below the water line it is only a dark shape
                px[xx, yy] = hx('00313a')
                continue
            # thin roots in the bluff's shadow: a dark rim, one lit pixel line on the left, no moss
            if q > 0.8 and u < 0.3:
                c = rcols['out']
            elif u > 0.35:
                c = rcols['body']
            elif u > -0.35:
                c = rcols['dark']
            else:
                c = rcols['out']
            px[xx, yy] = hx(c)

    def root_cluster(knob, tips, r0=1.6, r1=0.6):
        """Where a great-tree root breaks out under the walkway lip: a dark knob, then thin fingers splaying down the
        bluff face into the river, the way real bank roots hang (not one fat tube)."""
        kx, ky = knob
        for yy in range(ky - 2, ky + 3):
            for xx in range(kx - 3, kx + 4):
                q = ((xx - kx) / 3.2) ** 2 + ((yy - ky) / 2.2) ** 2
                if q <= 1.0:
                    px[xx, yy] = hx(rcols['out'] if q > 0.6 or yy > ky else
                                    (rcols['body'] if xx < kx else rcols['dark']))
        for (tx, ty) in tips:
            mx = kx + (tx - kx) * 0.45 + (1 if tx >= kx else -1)
            bank_root([(kx, ky + 1), (mx, ky + (ty - ky) * 0.4), (tx + (0.5 if tx < kx else -0.5), ty - 4), (tx, ty)],
                      r0, r1)
        for (tx, ty) in tips:  # a broken ripple where each finger meets the water
            for dx in (-2, 2):
                if 0 <= tx + dx < W:
                    px[tx + dx, 202] = hx('2d9e9f')

    rcols['body'], rcols['dark'], rcols['out'] = '8c6545', '663f23', '3f2716'
    root_cluster((205, 189), [(200, 203), (207, 203), (214, 202)])
    root_cluster((247, 189), [(243, 203), (250, 203)], 1.4, 0.6)
    save(img, 'boughs_title')
    a, b = src.load(), img.load()
    changed = [(x, y) for y in range(H) for x in range(W) if a[x, y] != b[x, y]]
    tl = [lum(b[x, y]) for (x, y) in tree_px if b[x, y] != a[x, y]]
    sl = [lum(a[x, y]) for (x, y) in tree_px if b[x, y] != a[x, y]]
    REPORT['title'] = dict(
        trunk_cx=round(cx, 1), trunk_w=round(2 * hw, 1), changed=len(changed), trunk_px=len(tl), hem_px=len(hem_px),
        trunk_lum=round(sum(tl) / max(1, len(tl))), sky_behind_lum=round(sum(sl) / max(1, len(sl))),
        in_wordmark=sum(1 for x, y in changed if in_wordmark(x, y)),
        in_wordmark_rows=sorted({y for x, y in changed if in_wordmark(x, y)}),
        in_wordmark_colours=sorted({hexs(b[x, y]) for x, y in changed if in_wordmark(x, y)}),
        in_menu=sum(1 for x, y in changed if 21 <= x <= 128 and 108 <= y <= 199),
        right_of_window=sum(1 for x, y in changed if x >= WINDOW_X),
        colours_before=len(fm.colours(src)), colours_after=len(fm.colours(img)),
        new_colours=sorted(hexs(c) for c in fm.colours(img) - fm.colours(src)), leaf_px=nleaf)
    return img


# ================================================================================================ 2. vista
VISTA_RAMP = [hx(c) for c in ('2d3729', '45502d', '596d6f', '66899d', '7a95a5', 'a0adb0')]
VISTA_MOSS = [hx(c) for c in ('45502d', '4b6731', '59753c', '6f8455')]
VISTA_D = {'body': 48, 'shade': 66, 'braid': 66, 'lit': 28, 'knot': 72, 'under': 62, 'clump': 54, 'clump_edge': 70,
           'tip': 44, 'curtain': 52, 'node': 64, 'tuft': 46, 'limb': 60, 'limb_shade': 72, 'bough': 74}


def mock_vista(g):
    img = fm.load_3x(f'{BUILD}/round2/13_road_vista.png')
    src = img.copy()
    orig = src.load()
    W, H = img.size
    hills = {hx('a3b0ae'), hx('b8c2bc')}
    sky = {orig[x, y] for x in range(60, 220) for y in range(0, 117)} - hills
    dom = fm.row_sky(src, sky, 60, 220)
    WINDOW_X = 238
    CREST = 128  # the near slope's crest: the trunk's foot is behind it

    def edge(x):  # the canopy's lower edge: deepest under the trunk, lifting to the top before the crook
        if x > 236:
            return None
        e = 18 + 12 * math.exp(-((x - 122) / 48.0) ** 2)
        if x > 176:
            e *= ((236 - x) / 60.0) ** 0.45  # a rounded crown outline, not a straight diagonal
        return e

    def allowed(x, y):
        if x >= WINDOW_X and y < 118:
            return False
        return orig[x, y] in sky or (orig[x, y] in hills and y < CREST)

    # fixed hazed colours, two zones down the trunk (break at y 84, between the sky's own band edges), so it reads
    # as one solid thing in the dawn haze and never as glass showing the sky bands through it
    # one set of hazed colours for the whole tree (the dawn haze flattens it), so it reads as one solid thing and
    # never as glass showing the sky bands through it
    bark = dict(body='596d6f', lit='66899d', shade='45502d', braid='45502d', knot='2d3729', moss='4b6731',
                limb='596d6f', limb_shade='45502d')
    canopy = dict(c_body='596d6f', c_shade='45502d', c_rim='66899d', c_fleck='4b6731', clump='596d6f',
                  clump_edge='45502d', tip='66899d', curtain='596d6f', node='45502d', tuft='4b6731')

    def vcol(role, x, y):
        if role == 'shade' and (x + y) % 2 == 0:
            return hx('596d6f')  # the shade side is a checker, so its olive dark never reads as a separate material
        return hx(canopy[role] if role in canopy else bark[role])

    cx = g['vista']['trunk_cx']
    hw = g['vista']['trunk_w'] / 2
    R = {}
    # 1. the trunk climbs into the crown; its foot flares into buttresses behind the slope crest
    trunk_roles(cx, 20, CREST + 2, hw - 8, hw, light=1, seed=9, flare=0.35, R=R)
    # 2. limbs that curve up and thin out, disappearing into the crown
    limb_roles(R, [(cx - 18, 66), (cx - 36, 52), (cx - 60, 38), (cx - 84, 24), (cx - 98, 12)], 7, 2)
    limb_roles(R, [(cx + 18, 62), (cx + 34, 48), (cx + 50, 36), (cx + 62, 24), (cx + 70, 12)], 7, 2)
    limb_roles(R, [(cx - 10, 50), (cx - 18, 36), (cx - 34, 24), (cx - 46, 14)], 5, 2)
    # 3. the crown's underside: a solid mass above the edge, with big leaf lobes hanging along its lower edge (laid
    # top first, so each lower lobe overlaps the one above). Dark bellies under each lobe, a lit rim only where the
    # crown meets the sky, so it reads as foliage seen from below and not as a cap or a tiled roof.
    crnd = random.Random(23)
    crown = {}
    for x in range(0, 237):
        bound = edge(x) - 3
        if x > 166:  # the receding right edge is a row of round leaf masses, not a straight diagonal
            P = 16.0
            t = (x - (166 + P * (math.floor((x - 166) / P) + 0.5))) / (P / 2)
            bound = edge(x) - 9 + 9 * math.sqrt(max(0.0, 1 - t * t))
        for y in range(0, int(bound)):
            crown[(x, y)] = 'c_body'
    lobes = []
    x = crnd.uniform(-6, 2)
    while x < 236:
        e = edge(int(max(0, min(236, x))))
        rx = crnd.uniform(11, 18) * (0.55 if x > 170 else 1.0)  # the receding edge breaks into rounder, deeper lobes
        ry = crnd.uniform(6, 9.5) * (1.1 if x > 170 else 1.0)
        rx = min(rx, 236 - x)
        if rx >= 4:
            lobes.append((x, e - ry * 0.35 + crnd.uniform(-1.5, 4.5), rx, ry))
            if crnd.random() < 0.55:  # a second, higher lobe behind it, showing as a step in the underside
                lobes.append((x + crnd.uniform(-9, 9), e - ry * 1.3, rx * 0.8, ry * 0.8))
        x += rx * crnd.uniform(1.1, 1.5)
    lobes.sort(key=lambda c: c[1])
    for (kx, ky, rx, ry) in lobes:
        for yy in range(int(ky - ry) - 1, int(ky + ry) + 2):
            for xx in range(int(kx - rx) - 1, int(kx + rx) + 2):
                dx, dy = (xx - kx) / rx, (yy - ky) / ry
                q = dx * dx + dy * dy
                if q > 1.0 or not (0 <= xx <= 236) or yy < 0:
                    continue
                crown[(xx, yy)] = 'c_shade' if (dy > 0.45 or (q > 0.82 and dy > 0.15)) else 'c_body'
    for (xx, yy), role in list(crown.items()):
        if role == 'c_body' and noise(xx // 2, yy, 29) > 0.93:
            crown[(xx, yy)] = 'c_shade'  # a few leaf-cluster marks
        if (xx + 1, yy) not in crown and (xx, yy + 1) not in crown and yy > 0:
            crown[(xx, yy)] = 'c_shade'  # the lower right outline
        elif ((xx - 1, yy) not in crown and xx > 0) or ((xx, yy - 1) not in crown and yy > 0):
            if role == 'c_body':
                crown[(xx, yy)] = 'c_rim'  # the crown's upper-left edge against the sky catches light
    R.update(crown)
    # 4. the hem: a few more clumps and the curtain roots along the edge
    lowest = {}
    for (xx, yy) in crown:
        lowest[xx] = max(lowest.get(xx, -1), yy)
    hem = hem_roles(0, 232, lambda x: lowest.get(x, edge(x)) - 1, random.Random(17),
                    size=lambda x: 0.45,
                    curtain=lambda x: (10, 28) if abs(x - cx) < hw + 20 else ((0, 0) if x > 200 else (3, 9)),
                    density=lambda x: 0.45 if abs(x - cx) < hw + 20 else 0.14)
    for k, v in hem.items():
        if v in ('curtain', 'node', 'tuft') and k not in crown:
            R[k] = v
    tree_px = paint_roles(img, R, vcol, allowed)
    px = img.load()
    # 4. the Tower's root: from the trunk's foot over the crest and down the open slope to the Tower's west foot
    land = {hx(c) for c in ('6f8455', 'a3b0ae', '7f9467', '93a77a', 'b8c2bc', '6a8848', '4b6634', '3e5629')}
    darker = {'a3b0ae': '7f9467', 'b8c2bc': 'a3b0ae', '7f9467': '6f8455', '93a77a': '7f9467', '6f8455': '4b6634',
              '6a8848': '4b6634', '4b6634': '3e5629', '3e5629': '3e5629'}
    fm.root_road(img, [(cx + 18, CREST + 1), (cx + 26, 139), (cx + 36, 151), (cx + 50, 163), (cx + 66, 173),
                       (cx + 84, 181), (cx + 102, 187), (238, 187)],
                 [(0.0, 0.10), (0.16, 0.26), (0.32, 0.42), (0.49, 0.58), (0.64, 0.74), (0.80, 0.88), (0.93, 1.0)],
                 lambda x, y: 1.0 + 0.045 * (y - 117),
                 dict(crest='6a8848', crest_lit='93a77a', bark='8c6545', lit='c49b69', dark='663f23', contact='3e5629',
                      trail='ccb290'),
                 lambda x, y: orig[x, y] in land, seam=lambda c: hx(darker.get(hexs(c), hexs(c))))
    nleaf = leaves(img, [(206, 64), (226, 92), (180, 108), (300, 128), (206, 140), (330, 164), (160, 196)],
                   '6f8455', '4b6634', lambda x, y: not (240 <= x <= 300 and y < 118))
    save(img, 'boughs_vista')
    a, b = src.load(), img.load()
    changed = [(x, y) for y in range(H) for x in range(W) if a[x, y] != b[x, y]]
    tl = [lum(b[x, y]) for (x, y) in tree_px if b[x, y] != a[x, y]]
    sl = [lum(a[x, y]) for (x, y) in tree_px if b[x, y] != a[x, y]]
    REPORT['vista'] = dict(
        trunk_cx=round(cx, 1), trunk_w=round(2 * hw, 1), changed=len(changed), tree_px=len(tl),
        tree_lum=round(sum(tl) / max(1, len(tl))), sky_behind_lum=round(sum(sl) / max(1, len(sl))),
        tree_px_in_window=sum(1 for (x, y) in tree_px if x >= WINDOW_X and y < 118),
        colours_before=len(fm.colours(src)), colours_after=len(fm.colours(img)),
        new_colours=sorted(hexs(c) for c in fm.colours(img) - fm.colours(src)), leaf_px=nleaf)
    return img


# ================================================================================================ 3. reveal top hold
HZ = 120
HOLD_SKY = [c for _, c in fm.SKY_BANDS]  # nine bands, packed to a horizon at y 120 (as in the earlier final)
UPLAND = [(120, 'c2b58f'), (122, 'a3a891'), (127, '979683'), (134, '878b7c'), (143, '838e87'), (155, '748471'),
          (168, '6f8455'), (178, '59753c')]
FOREST = ['59753c', '4b6731', '3d542b', '2d3729']
HOLD_TRUNK = [hx(c) for c in ('2d3729', '45502d', '565b40', '73734d', '979683')]
HOLD_MOSS = [hx(c) for c in ('3d542b', '4b6731', '59753c')]
HOLD_D = {'body': 42, 'shade': 58, 'braid': 58, 'lit': 20, 'knot': 64, 'limb': 46, 'limb_shade': 60}


def build_hold_backdrop(g):
    W, H = 384, 216
    img = Image.new('RGB', (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            if y < HZ:
                px[x, y] = hx(fm.SKY_BANDS[fm.band_at(fm.SKY_BANDS, x, y)][1])
            else:
                px[x, y] = hx(UPLAND[fm.band_at(UPLAND, x, y)][1])
    rnd = random.Random(13)

    def blob(cx, cy, rx, ry, col, hi=None, lo=None):
        for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if 0 <= xx < W and HZ + 1 <= yy < H and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1:
                    px[xx, yy] = hx(col)
                    if hi and ((xx - cx + 0.35 * rx) / rx) ** 2 + ((yy - cy + 0.5 * ry) / ry) ** 2 <= 0.22:
                        px[xx, yy] = hx(hi)
                    if lo and yy >= cy + 0.55 * ry:
                        px[xx, yy] = hx(lo)

    # uplands beyond the forest: grass openings, small woods, upland springs (the region atlas's "behind town")
    for _ in range(30):
        y = rnd.uniform(HZ + 2, 176)
        s = (y - HZ) / 56.0
        i = fm.band_at(UPLAND, 0, int(y))
        blob(rnd.uniform(0, W), y, max(1.5, rnd.uniform(4, 14) * s), max(0.6, rnd.uniform(0.6, 1.6) * s),
             UPLAND[max(0, i - 1)][1])
    for _ in range(46):
        y = rnd.uniform(HZ + 3, 178)
        s = (y - HZ) / 56.0
        i = fm.band_at(UPLAND, 0, int(y))
        x = rnd.uniform(0, W)
        col = UPLAND[min(len(UPLAND) - 1, i + 2)][1]
        for _k in range(rnd.randint(2, 4)):
            r = max(0.8, rnd.uniform(1.0, 3.2) * s)
            blob(x + rnd.uniform(-2, 2) * r, y, r, max(0.6, r * 0.45), col)
    for _ in range(9):
        y = int(rnd.uniform(HZ + 4, 170))
        x = int(rnd.uniform(140, W - 10))
        for j in range(max(1, int((y - HZ) * 0.08))):
            px[x + j, y] = hx('c2d4df' if j else 'deded0')
    # the forest's far side: rows of crowns, nearer rows bigger, its top edge bumpy at y ~182 (the forest runs about
    # 300 tiles past the great tree, so from up here its far edge sits this close to the horizon)
    y = 181.0
    while y < H + 6:
        s = 1.6 + (y - 181) * 0.16
        x = rnd.uniform(-6, 0)
        while x < W + 6:
            blob(x, y, s * rnd.uniform(1.0, 1.5), s * rnd.uniform(0.7, 0.95), FOREST[2], FOREST[1], FOREST[3])
            x += s * rnd.uniform(1.6, 2.4)
        y += max(2.0, s * 0.8)
    for (yy, x0, x1, c) in ((171, 150, 384, 'c2d4df'), (172, 168, 384, 'a0adb0'), (194, 0, 120, 'a0adb0'),
                            (195, 10, 150, 'c2d4df'), (205, 250, 384, 'a0adb0')):
        for x in range(x0, x1):
            if (x * 7 + yy) % 19 != 0 and (x // 9 + yy) % 5 != 0:
                px[x, yy] = hx(c)
    for (bx, by) in ((302, 150), (314, 146)):  # two birds below us
        for (dx, dy) in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            px[bx + dx, by + dy] = hx('2d3729')
    bg = img.copy()
    bgp = bg.load()

    # the great tree: its trunk is a wall at the left edge (lens: 154 px wide, centre x -19), its foot below the frame
    # and its crown above it. A bough leaves the trunk at the top and climbs out of frame toward the town.
    cx = g['hold']['trunk_cx']
    hw = g['hold']['trunk_w'] / 2
    R = trunk_roles(cx, 0, H - 1, hw - 3, hw, light=1, seed=4, lit_u=0.93)
    limb_roles(R, [(cx + hw - 8, 34), (cx + hw + 10, 20), (cx + hw + 26, 6), (cx + hw + 34, -8)], 9, 6)

    # fixed bark colours, darker in the top 56 rows where the dawn sky is still dark: a solid wall, never glass
    top = dict(body='45502d', lit='565b40', shade='2d3729', braid='2d3729', knot='2d3729', moss='3d542b',
               limb='45502d', limb_shade='2d3729')
    mid = dict(body='565b40', lit='73734d', shade='45502d', braid='45502d', knot='2d3729', moss='4b6731',
               limb='565b40', limb_shade='45502d')

    def tcol(role, x, y):
        zone = mid if (y > 57 or (y >= 55 and (x + y) % 2 == 0)) else top
        return hx(zone[role])

    trunk_px = paint_roles(img, R, tcol, lambda x, y: True)
    # curtain roots: from the bough over the trunk's shoulder, and from the rim's drooping tips at the top right.
    # Highbank keeps them trimmed back from the Tower, so nothing hangs between x 95 and 245 (the lamp's window).
    rnd2 = random.Random(8)
    hem_l = hem_roles(46, 92, lambda x: 14 - (x - 46) * 0.32, rnd2, size=lambda x: 0.75,
                      curtain=lambda x: (12, 40), density=lambda x: 0.6)
    hem_r = hem_roles(250, 383, lambda x: 1 + 3 * math.sin(x / 23.0), rnd2, size=lambda x: 1.0,
                      curtain=lambda x: (8, 30) if x > 280 else (4, 12), density=lambda x: 0.55)
    hcol = {'clump': '2d3729', 'clump_edge': '45502d', 'tip': '45502d', 'curtain': '45502d', 'node': '2d3729',
            'tuft': '4b6731'}

    def hem_ok(x, y):
        return not (95 <= x <= 245) and (x, y) not in R

    hem_px = paint_roles(img, hem_l, lambda r, x, y: hx(hcol[r]), hem_ok)
    hem_px += paint_roles(img, hem_r, lambda r, x, y: hx(hcol[r]), hem_ok)
    nleaf = leaves(img, [(262, 66), (318, 104), (356, 141), (72, 150), (292, 176), (252, 196), (80, 92)],
                   '6f8455', '4b6731', lambda x, y: not (95 <= x <= 245))
    stats = dict(trunk_cx=round(cx, 1), trunk_w=round(2 * hw, 1), trunk_visible_x=(0, int(cx + hw)),
                 trunk_px=len(trunk_px), hem_px=len(hem_px), leaf_px=nleaf,
                 window_px=sum(1 for (x, y) in trunk_px + hem_px if 95 <= x <= 245),
                 trunk_lum=round(sum(lum(img.getpixel(p)) for p in trunk_px) / max(1, len(trunk_px))),
                 behind_lum=round(sum(lum(bgp[x, y]) for (x, y) in trunk_px) / max(1, len(trunk_px))))
    return img, stats


def composite_hold(frame_path, bd):
    img = fm.load_3x(frame_path)
    src = img.copy().load()
    px = img.load()
    bp = bd.load()
    bg_cols = {hx(c) for c in fm.PLACEHOLDER_SKY}
    glow_cols = {hx(c) for c in fm.GLOW}
    # the lamp's glow, rebuilt over the new sky and land by stepping up a luminance ramp of the backdrop's own colours
    sky_ramp = sorted({hx(c) for c in HOLD_SKY}, key=lum)
    land_ramp = sorted({hx(c) for _, c in UPLAND} | {hx('d9bf94')}, key=lum)
    n = 0
    for y in range(img.height):
        for x in range(img.width):
            c = src[x, y]
            if c in bg_cols:
                px[x, y] = bp[x, y]
                n += 1
            elif c in glow_cols:
                b = bp[x, y]
                ramp = sky_ramp if y < HZ else land_ramp
                i = min(range(len(ramp)), key=lambda k: abs(lum(ramp[k]) - lum(b)))
                px[x, y] = ramp[min(len(ramp) - 1, i + (2 if lum(c) > 165 else 1))]
                n += 1
    return img, n


def mock_hold(g):
    bd, stats = build_hold_backdrop(g)
    hold, n = composite_hold(f'{BUILD}/round2/11_reveal_hold_top.png', bd)
    save(hold, 'boughs_hold')
    stats.update(backdrop_colours=len(fm.colours(bd)), replaced_px=n)
    REPORT['hold'] = stats
    return hold


# ================================================================================================ 4. influence sheet
ROOT_COL = dict(out='181412', body='b06b3d', mid='8c6545', grain='ad693c', dark='663f23', lit='c49b69',
                moss='908940', moss_dk='6b6f1d')


def surface_root(img, pts, r0, r1, allowed, base_kind, seed=3, bury=True):
    """A great-tree root lying in the ground, seen from above in the Tower root's own bark colours: dark outline, lit
    upper-left edge, grain along it, moss on top. On turf its lower side is half buried; on paving the stones round it
    are heaved (a dark gap on the shadow side, a lifted light edge on the lit side); in water it is a dark shape.
    base_kind(x, y) -> 'turf' | 'stone' | 'water'."""
    px = img.load()
    W, H = img.size
    orig = img.copy().load()
    cols = common_colours(img)
    dk = tone_map(cols, 14, 40, True)
    lt = tone_map(cols, 10, 34, False)
    S = catmull(pts, 40)
    T, along = frame_of(S)
    L = along[-1] or 1.0
    best = {}
    for i, (x, y, _) in enumerate(S):
        f = along[i] / L
        r = r0 + (r1 - r0) * f
        r *= min(1.0, 0.35 + min(f, 1 - f) * 5.0)  # it dives into the ground at both ends
        nx, ny = -T[i][1], T[i][0]
        if nx + ny > 0:
            nx, ny = -nx, -ny  # u > 0 faces up-left, toward the light
        Rr = int(r) + 4
        for yy in range(int(y) - Rr, int(y) + Rr + 1):
            for xx in range(int(x) - Rr, int(x) + Rr + 1):
                dx, dy = xx - x, yy - y
                q = math.hypot(dx, dy) / max(r, 0.6)
                if q > 1 + 2.6 / max(r, 0.6):
                    continue
                cur = best.get((xx, yy))
                if cur is None or q < cur[0]:
                    best[(xx, yy)] = (q, (dx * nx + dy * ny) / max(r, 0.6), along[i], r)
    for (xx, yy), (q, u, s, r) in best.items():
        if not (0 <= xx < W and 0 <= yy < H) or not allowed(xx, yy):
            continue
        k = base_kind(xx, yy)
        o = orig[xx, yy]
        if q > 1.0:
            if k == 'stone':
                if u < -0.2 and q <= 1 + 1.6 / r:
                    px[xx, yy] = dk[dk[o]]  # the gap where the stones lift on the shadow side
                elif u > 0.2 and q <= 1 + 1.4 / r:
                    px[xx, yy] = lt[o]      # lifted stone edge catching light
            elif k == 'turf' and u < -0.3 and q <= 1 + 1.2 / r:
                px[xx, yy] = dk[o]          # contact shadow
            continue
        if k == 'water':
            px[xx, yy] = dk[dk[o]]
            continue
        if bury and k == 'turf' and u < -0.5 - 0.25 * noise(int(s // 4), 3, seed):
            continue  # the near side stays under the turf: the original grass shows
        # a round root lit from the upper left: light lip, warm top, a mid band, the shadow side, a dark rim
        if q > 1 - 1.0 / max(r, 1.0):
            c = ROOT_COL['out'] if u < 0.4 else ROOT_COL['dark']
        elif u > 0.62:
            c = ROOT_COL['lit']
        elif u > 0.05:
            c = ROOT_COL['body']
        elif u > -0.5:
            c = ROOT_COL['mid']
        else:
            c = ROOT_COL['dark']
        if c in (ROOT_COL['body'], ROOT_COL['mid']):
            # grain: two broken lines running along the root
            for g0 in (0.32, -0.22):
                if abs(u - g0 - 0.06 * math.sin(s / 7.0)) * r < 0.6 and noise(int(s // 3), int(g0 * 10), seed) > 0.3:
                    c = ROOT_COL['grain'] if u > 0 else ROOT_COL['dark']
            if vnoise(s, u * 6, 5, seed + 3) > 0.7 and u > 0.0:
                c = ROOT_COL['moss'] if u > 0.3 else ROOT_COL['moss_dk']
        px[xx, yy] = hx(c)


def dapple(img, box, seed, strength_fn, allowed):
    """Leaf shade from the canopy above: hard-edged blots one step darker, with sun flecks one step lighter inside
    them. strength_fn(x, y) in 0..1 (stronger toward the north, under the rim)."""
    px = img.load()
    cols = common_colours(img)
    dk = tone_map(cols, 18, 42, True)
    lt = tone_map(cols, 14, 40, False)
    x0, y0, x1, y1 = box
    n = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            if not allowed(x, y):
                continue
            s = strength_fn(x, y)
            v = 0.6 * vnoise(x, y * 1.4, 9, seed) + 0.4 * vnoise(x, y * 1.4, 4, seed + 1)
            if v < 0.72 - 0.36 * s:
                continue
            c = px[x, y]
            fleck = vnoise(x, y, 3.0, seed + 5) > 0.77
            px[x, y] = lt[c] if fleck else dk[c]
            n += 1
    return n


FALLEN = [[(1, 0, 'b'), (2, 0, 'b'), (0, 1, 'b'), (1, 1, 'h'), (2, 1, 'd'), (0, 2, 's')],
          [(0, 0, 'b'), (1, 0, 'b'), (1, 1, 'h'), (2, 1, 'b'), (2, 2, 'd'), (3, 2, 's')],
          [(1, 0, 'b'), (0, 1, 'b'), (1, 1, 'b'), (2, 1, 'h'), (1, 2, 'd'), (2, 2, 'd'), (3, 3, 's')]]


def fallen_leaves(img, spots, allowed=lambda x, y: True):
    """The great tree's leaves on the ground: bigger than a drifting speck, olive with a lit vein and a stalk."""
    px = img.load()
    cmap = {'b': '908940', 'h': 'c6bb2a', 'd': '6b6f1d', 's': '44421a'}
    for i, (x, y) in enumerate(spots):
        for (dx, dy, k) in FALLEN[i % 3]:
            X, Y = x + dx, y + dy
            if 0 <= X < img.width and 0 <= Y < img.height and allowed(X, Y):
                px[X, Y] = hx(cmap[k])


def vignette_street():
    img = fm.load_3x(f'{BUILD}/round2/06_street_wayline.png')
    o = img.copy().load()

    def kind(x, y):
        c = o[x, y]
        return 'turf' if c[1] > c[0] + 8 and c[1] > c[2] + 8 else 'stone'

    keep = lambda x, y: not (300 <= x and 174 <= y) and y >= 37
    # a root heaves up through the cobbles, below the wayline post, from the grass on the west side
    surface_root(img, [(26, 186, 0), (64, 178, 0), (104, 172, 0), (146, 167, 0), (190, 160, 0), (236, 152, 0),
                       (262, 148, 0)], 8.5, 9.5, keep, kind, seed=6)
    surface_root(img, [(118, 170, 0), (128, 182, 0), (134, 192, 0)], 3.2, 1.6, keep, kind, seed=7)  # a rootlet
    # leaves blown down from the rim: on the cobbles and the grass, and two in the air (with a shadow under them)
    cols = common_colours(img)
    dk = tone_map(cols, 14, 40, True)
    fallen_leaves(img, [(122, 108), (196, 130), (92, 128), (214, 176), (150, 146), (70, 160), (176, 186)], keep)
    leaves(img, [(178, 112), (110, 96), (220, 100)], 'c6bb2a', '908940', keep, shadow=lambda c: dk[c])
    return img.crop((40, 80, 232, 188))


def vignette_rise():
    img = fm.load_3x(f'{BUILD}/round2/05c_rise_side_west_col2_row3.png')
    o = img.copy().load()
    line = {hx('f2d27a'), hx('ddca86')}

    def ground(x, y):
        c = o[x, y]
        if c in line or y < 37:
            return False
        if c[0] > c[1] + 25 and c[0] > 120:  # the creature, the Tower's root and walls keep their light
            return False
        return True

    dapple(img, (0, 37, 200, 145), 41, lambda x, y: max(0.0, min(1.0, 1.25 - (y - 37) / 110.0)), ground)
    cols = common_colours(img)
    dk = tone_map(cols, 14, 40, True)
    fallen_leaves(img, [(30, 128), (88, 104), (126, 132), (12, 90), (58, 140), (150, 116)], ground)
    leaves(img, [(70, 64), (140, 86), (36, 110)], 'c6bb2a', '908940', lambda x, y: y >= 37,
           shadow=lambda c: dk[c])
    return img.crop((0, 37, 192, 145))


def vignette_ferry():
    img = fm.load_3x(f'{BUILD}/round2/07_ferry_ward_quiet_wayline.png')
    o = img.copy().load()

    def kind(x, y):
        c = o[x, y]
        if c[2] > c[0] + 10 and y > 140:
            return 'water'
        return 'turf' if c[1] > c[0] + 8 and c[1] > c[2] + 8 else 'stone'

    mouth = (192, 72, 27)  # the Mouth's ring, 1x; the roots keep clear of it (Hollow is absence)
    keep = lambda x, y: math.hypot(x - mouth[0], y - mouth[1]) > mouth[2] and y >= 37 and not (x >= 300 and y >= 174)
    # one root down from the cliff, bending away from the Mouth, between two mooring posts and into the river
    surface_root(img, [(150, 30, 0), (146, 56, 0), (130, 82, 0), (118, 106, 0), (124, 128, 0), (138, 148, 0),
                       (144, 168, 0)], 9.0, 4.0, keep, kind, seed=9, bury=False)
    # rootlets: one reaches west and grips the landing; one turned toward the Mouth and stopped short of it
    surface_root(img, [(124, 100, 0), (106, 104, 0), (94, 112, 0), (88, 120, 0)], 3.0, 1.2, keep, kind, seed=12,
                 bury=False)
    surface_root(img, [(138, 72, 0), (150, 76, 0), (158, 78, 0)], 2.6, 1.0, keep, kind, seed=10, bury=False)
    # a second, thinner root to the water further west
    surface_root(img, [(70, 30, 0), (76, 64, 0), (70, 96, 0), (78, 124, 0), (86, 150, 0), (90, 166, 0)], 5.5, 2.6,
                 keep, kind, seed=11, bury=False)
    fallen_leaves(img, [(104, 152), (168, 156), (58, 148), (200, 150), (100, 66)], lambda x, y: True)
    return img.crop((40, 56, 232, 164))


def mock_influence(title_img):
    cells = [('STREET: A ROOT LIFTS THE COBBLES', vignette_street()),
             ('RISE: DAPPLE UNDER THE RIM', vignette_rise()),
             ('FERRY WARD: ROOTS DRINK', vignette_ferry()),
             ('BLUFF: ROOTS HOLD THE BANK', title_img.crop((150, 108, 342, 216)))]
    W, H = 2 * 192 + 4, 12 + 2 * (108 + 12) + 2
    sheet = Image.new('RGB', (W, H), hx('1a1410'))
    d = ImageDraw.Draw(sheet)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    d.text((2, 1), 'THE GREAT TREE AROUND TOWN (PROPOSAL)', font=f, fill=hx('f0d696'))
    for i, (label, im) in enumerate(cells):
        x = (i % 2) * 196
        y = 12 + (i // 2) * 120
        d.text((x + 2, y + 1), label, font=f, fill=hx('be9c62'))
        sheet.paste(im, (x, y + 12))
        REPORT.setdefault('influence', {})[label] = dict(text_w=round(d.textlength(label, font=f)))
    save(sheet, 'boughs_influence')
    return sheet


# ================================================================================================ 5. map
def mock_map(g):
    W, H = 384, 262
    img = Image.new('RGB', (W, H), hx('e6c697'))
    d = ImageDraw.Draw(img)
    d.fontmode = '1'
    f = ImageFont.truetype(FONT, 8)
    ink, faint, panel = hx('3f2716'), hx('a37a32'), hx('f5d9a8')
    forest, forest_dk = hx('908940'), hx('6b6f1d')
    hatch, rimc = hx('43665a'), hx('1e302e')
    water, bank = hx('2d9e9f'), hx('12837f')
    rootc, rootlit, towroot = hx('7c4a26'), hx('92724b'), hx('b06b3d')
    lamp = hx('fbd490')

    def text(x, y, s, c=ink, knock=True):
        if knock:
            w = d.textlength(s, font=f)
            d.rectangle((x - 1, y, x + w, y + 8), fill=panel)
        d.text((x, y), s, font=f, fill=c)

    # world tiles: x east, y south, origin at the Street's top-left (Street 0,0). Tower centre (46.5, -7).
    TX, TY = 46.5, -7.0
    TRX, TRY = TX + TREE_E, TY - TREE_N  # trunk

    def crown_pt(b, scale=1.0):
        r = crown_r(b) * scale
        return TRX + r * math.sin(math.radians(b)), TRY - r * math.cos(math.radians(b))

    # the forest: about 280 tiles round the trunk on the north, west and east; on the south it runs to the river and
    # crosses it as the south bank's willow woods (the road home's woods and the title's frame tree). Highbank is a
    # clearing on the bluff at its south rim.
    def forest_r(b):
        return 280 * (0.86 + 0.14 * vnoise(b, 0, 40, 3))

    def river_y(x):  # river centreline, tiles; the Ferry Ward's water rows sit on its north bank at y ~29 to 31
        return 52 + 10 * math.sin((x - 40) / 95.0) + 4 * math.sin(x / 31.0)

    def in_forest(x, y):
        dx, dy = x - TRX, y - TRY
        if math.hypot(dx, dy) > forest_r(bearing(dx, -dy)) and y < river_y(x) - 20:
            return False
        if abs(y - river_y(x)) < 20:
            return False
        if y > river_y(x) + 20 and (y > river_y(x) + 95 or abs(x - TRX) > 260):
            return False
        if -16 <= x <= 92 and -28 <= y <= 36:  # Highbank's clearing
            return False
        return True

    def under_crown(x, y):
        dx, dy = x - TRX, y - TRY
        return math.hypot(dx, dy) <= crown_r(bearing(dx, -dy))

    # ---- panel A: the region, 1 px = 3 tiles
    A = (2, 12, 196, 230)
    AX, AY = 96.0, 152.0

    def A_px(x, y):
        return AX + x / 3.0, AY + y / 3.0

    def A_w(px_, py_):
        return (px_ - AX) * 3.0, (py_ - AY) * 3.0

    d.rectangle(A, fill=panel, outline=faint)
    text(3, 2, 'REGION, 1 PX = 3 TILES', knock=False)
    for py_ in range(A[1] + 1, A[3]):
        for px_ in range(A[0] + 1, A[2]):
            x, y = A_w(px_, py_)
            if abs(y - river_y(x)) < 20 - 1.5:
                img.putpixel((px_, py_), water)
            elif abs(y - river_y(x)) < 20 + 1.5:
                img.putpixel((px_, py_), bank)
            elif under_crown(x, y) and (px_ + py_) % 3 == 0:
                img.putpixel((px_, py_), hatch)
            elif in_forest(x, y):
                v = noise(px_, py_, 7)
                if v > 0.55:
                    img.putpixel((px_, py_), forest if v < 0.85 else forest_dk)
    # crown rim
    prev = None
    for k in range(0, 361, 2):
        p = A_px(*crown_pt(k))
        if prev is not None:
            d.line([prev, p], fill=rimc)
        prev = p
    # roots radiating from the trunk; the forest stands on them. Tapering, a few forked.
    rnd = random.Random(12)

    def root_line(pts, w0, w1, col, per=12):
        S = catmull([(x, y, 0) for x, y in pts], per)
        for i, (x, y, _) in enumerate(S):
            w = w0 + (w1 - w0) * i / max(1, len(S) - 1)
            cx_, cy_ = A_px(x, y)
            r = max(0.0, w / 2.0)
            for yy in range(int(cy_ - r - 1), int(cy_ + r + 2)):
                for xx in range(int(cx_ - r - 1), int(cx_ + r + 2)):
                    if (xx + 0.5 - cx_) ** 2 + (yy + 0.5 - cy_) ** 2 <= max(0.3, r * r) and \
                            A[0] < xx < A[2] and A[1] < yy < A[3]:
                        img.putpixel((xx, yy), col)

    for b in (20, 62, 100, 205, 240, 275, 310, 345):
        L = forest_r(b) * rnd.uniform(0.75, 0.95)
        pts = []
        for k in range(6):
            t = k / 5.0
            bb = b + 14 * math.sin(t * 3 + b)
            pts.append((TRX + L * t * math.sin(math.radians(bb)), TRY - L * t * math.cos(math.radians(bb))))
        root_line(pts, 3.0, 0.6, rootc)
        fk = pts[2]
        b2 = b + rnd.choice((-1, 1)) * 30
        root_line([fk, (fk[0] + 60 * math.sin(math.radians(b2)), fk[1] - 60 * math.cos(math.radians(b2)))],
                  1.4, 0.4, rootc)
    # roots to the river: one west of town (riverbank roots; where Rootbank Warren could be, place not fixed), one
    # under the Ferry Ward
    root_line([(TRX - 10, TRY + 12), (-20, -60), (-46, 0), (-58, 30)], 2.4, 1.0, rootc)
    root_line([(TRX + 8, TRY + 12), (30, -50), (36, -10), (44, 20), (50, 30)], 1.8, 0.8, rootc)
    # the Tower's root: south from the trunk's south buttress, past the Rise's west edge, hooking east into the root
    # foot (the crook's shape, lying down). The root road keeps beside it: a later route, proposal.
    tower_root = [(TRX + 4, TRY + 10), (14, -90), (20, -60), (25, -34), (27, -16), (30, -8), (34, -6.5), (38, -6)]
    root_line(tower_root, 3.4, 1.6, towroot)
    S = catmull([(x, y, 0) for x, y in tower_root], 14)
    for i, (x, y, _) in enumerate(S):
        if i % 3 == 0 and 4 < i < len(S) - 4:
            p = A_px(x + 7, y)
            img.putpixel((int(p[0]), int(p[1])), faint)
    # trunk
    tx, ty = A_px(TRX, TRY)
    d.ellipse((tx - 4, ty - 4, tx + 4, ty + 4), fill=ink, outline=towroot)
    # Highbank: the four areas as blocks, the Tower and its lamp
    for (x0, y0, x1, y1) in ((0, 0, 56, 16), (34, -14, 60, 0), (40, 16, 74, 30), (56, 1, 86, 15)):
        p0, p1 = A_px(x0, y0), A_px(x1, y1)
        d.rectangle((p0[0], p0[1], p1[0], p1[1]), fill=hx('ccb290'), outline=ink)
    p = A_px(TX, TY)
    d.rectangle((p[0] - 1, p[1] - 3, p[0] + 1, p[1]), fill=ink)
    img.putpixel((int(p[0]), int(p[1] - 4)), lamp)
    # inset frame on A
    p0, p1 = A_px(-8, -30), A_px(83, 39)
    d.rectangle((p0[0], p0[1], p1[0], p1[1]), outline=hx('b8793e'))
    # labels
    text(tx - 30, ty - 44, 'THE GREAT TREE')
    text(A[0] + 4, A[1] + 5, 'FOREST', c=forest_dk)
    q = A_px(-150, -60)
    text(q[0], q[1], 'CANOPY')
    q = A_px(-130, 60)
    text(q[0], q[1], 'RIVER', c=hx('07515c'))
    q = A_px(60, 10)
    text(q[0] + 4, q[1] + 6, 'HIGHBANK')
    q = A_px(-88, 120)
    text(q[0], q[1], 'SOUTH BANK WOODS', c=forest_dk)
    # scale bar and north
    sx, sy = A[0] + 6, A[3] - 9
    d.line([(sx, sy), (sx + 100 / 3.0, sy)], fill=ink)
    d.line([(sx + 100 / 3.0, sy), (sx + 200 / 3.0, sy)], fill=faint)
    for k in (0, 1, 2):
        d.line([(sx + k * 100 / 3.0, sy - 2), (sx + k * 100 / 3.0, sy + 1)], fill=ink)
    text(sx + 70, sy - 4, '200 TILES', knock=False)
    nx_, ny_ = A[2] - 10, A[1] + 6
    d.line([(nx_, ny_ + 10), (nx_, ny_ + 2)], fill=ink)
    d.polygon([(nx_ - 2, ny_ + 4), (nx_, ny_), (nx_ + 2, ny_ + 4)], fill=ink)
    text(nx_ - 2, ny_ + 11, 'N', knock=False)

    # ---- panel B: the town at the canopy's rim, 2 px = 1 tile
    B = (200, 12, 382, 152)
    BX, BY = 216.0, 72.0

    def B_px(x, y):
        return BX + 2 * x, BY + 2 * y

    def B_w(px_, py_):
        return (px_ - BX) / 2.0, (py_ - BY) / 2.0

    d.rectangle(B, fill=panel, outline=faint)
    text(201, 2, 'TOWN AT THE RIM, 2 PX = 1 TILE', knock=False)
    for py_ in range(B[1] + 1, B[3]):
        for px_ in range(B[0] + 1, B[2]):
            x, y = B_w(px_ + 0.5, py_ + 0.5)
            if y >= 29 + 2 * math.sin(x / 9.0) and not (40 <= x < 74 and y < 29):
                img.putpixel((px_, py_), water)
            elif under_crown(x, y) and (px_ + py_) % 4 == 0:
                img.putpixel((px_, py_), hatch)
            elif in_forest(x, y) and noise(px_, py_, 9) > 0.6:
                img.putpixel((px_, py_), forest)
    for (x0, y0, x1, y1, c) in ((0, 0, 56, 16, 'e6c697'), (34, -14, 60, 0, 'ccb290'), (40, 16, 74, 29, 'c7a378'),
                                (56, 1, 86, 15, 'dca562')):
        p0, p1 = B_px(x0, y0), B_px(x1, y1)
        d.rectangle((p0[0], p0[1], min(B[2] - 1, p1[0] - 1), p1[1] - 1), fill=hx(c), outline=faint)
    # the canopy's shade lies over the areas too: the Rise's north-west corner sits under the rim
    for py_ in range(B[1] + 1, B[3]):
        for px_ in range(B[0] + 1, B[2]):
            x, y = B_w(px_ + 0.5, py_ + 0.5)
            if under_crown(x, y) and (px_ + py_) % 4 == 0:
                img.putpixel((px_, py_), hatch)
    # buildings on the Street's north side, the Tower base, the lamp
    for (bx, by) in ((3, 5), (12, 5), (20, 5), (28, 5)):
        p0 = B_px(bx - 2, by - 3)
        d.rectangle((p0[0], p0[1], p0[0] + 9, p0[1] + 5), fill=hx('8e7f5e'), outline=ink)
    p0, p1 = B_px(41, -8), B_px(53, -5)
    d.rectangle((p0[0], p0[1], p1[0] - 1, p1[1] - 1), fill=hx('5f5e57'), outline=ink)
    lp = B_px(TX, TY)
    d.rectangle((lp[0] - 1, lp[1] - 1, lp[0] + 1, lp[1] + 1), fill=lamp, outline=ink)
    # the canopy rim, dashed
    pts = []
    for k10 in range(1400, 2400):
        b = k10 / 10.0
        x, y = crown_pt(b)
        p = B_px(x, y)
        if B[0] < p[0] < B[2] and B[1] < p[1] < B[3]:
            pts.append((int(p[0]), int(p[1])))
    for i, p in enumerate(pts):
        if (i // 3) % 2 == 0:
            img.putpixel(p, rimc)

    def broot(path, w0, w1, col):
        S = catmull([(x, y, 0) for x, y in path], 48)
        for i, (x, y, _) in enumerate(S):
            w = w0 + (w1 - w0) * i / max(1, len(S) - 1)
            cx_, cy_ = B_px(x, y)
            r = w / 2.0
            for yy in range(int(cy_ - r - 1), int(cy_ + r + 2)):
                for xx in range(int(cx_ - r - 1), int(cx_ + r + 2)):
                    if (xx + 0.5 - cx_) ** 2 + (yy + 0.5 - cy_) ** 2 <= max(0.4, r * r) and \
                            B[0] < xx < B[2] and B[1] < yy < B[3]:
                        img.putpixel((xx, yy), col)

    broot([(25, -40), (27, -16), (30, -8), (34, -6.5), (38, -6), (40, -8), (42, -11)], 4.5, 3.4, towroot)
    broot([(16, -40), (22, -14), (30, -2), (32, 5), (31, 9)], 3.0, 2.0, rootc)        # the Street heave
    broot([(36, -40), (38, -16), (41, 16), (45, 24), (49, 31)], 3.0, 1.8, rootc)      # down the Ferry cliffs
    broot([(-8, -18), (-2, 4), (-1, 20), (-4, 31)], 3.0, 1.6, rootc)                  # west bluff to the river
    broot([(45, 22), (52, 20), (58, 21)], 1.8, 0.8, rootc)                            # stops short of the Mouth
    mp = B_px(65, 25)
    d.ellipse((mp[0] - 4, mp[1] - 4, mp[0] + 4, mp[1] + 4), fill=hx('0b0e11'))
    sp = B_px(12, 11)
    for (dx, dy, c) in ((0, 0, '6b6f1d'), (1, -1, 'c6bb2a'), (-1, -1, '908940'), (0, -2, 'c6bb2a')):
        img.putpixel((int(sp[0] + dx), int(sp[1] + dy)), hx(c))
    ep = B_px(70, 6)
    for (dx, dy, c) in ((0, 0, '6b6f1d'), (1, -1, '908940'), (-1, -1, '908940')):
        img.putpixel((int(ep[0] + dx), int(ep[1] + dy)), hx(c))
    for (x, y) in ((8, 3), (22, 9), (40, 4), (30, 12), (50, 10), (16, 14), (44, -3)):  # leaves on the Street
        p = B_px(x, y)
        img.putpixel((int(p[0]), int(p[1])), hx('6b6f1d'))
    # labels (knocked out)
    for (x, y, s) in ((36, -12.5, 'RISE'), (2, 13, 'STREET'), (52, 26.5, 'FERRY'), (66, 9, 'EAST Q')):
        p = B_px(x, y)
        text(p[0], p[1], s)
    p = B_px(-6, -27)
    text(p[0], p[1], 'UNDER THE CANOPY', c=hx('263d3a'))
    p = B_px(52, -20)
    text(p[0], p[1], 'OPEN SKY')
    p = B_px(-6, 32)
    text(p[0], p[1], 'RIVER', c=hx('07515c'))
    # scale bar: 10 tiles
    sx, sy = B[2] - 70, B[3] - 5
    d.line([(sx, sy), (sx + 20, sy)], fill=ink)
    d.line([(sx, sy - 2), (sx, sy + 1)], fill=ink)
    d.line([(sx + 20, sy - 2), (sx + 20, sy + 1)], fill=ink)
    text(sx + 24, sy - 4, '10 TILES')

    # ---- legend
    L0 = 158
    d.rectangle((200, L0 - 2, 382, 258), fill=panel, outline=faint)
    gt = g['tree']
    lines = [('THE GREAT TREE (PROPOSAL)', ink),
             ('%d TILES N %d W OF THE TOWER' % (round(gt['distance_tiles']), round(360 - bearing(TREE_E, TREE_N))),
              ink),
             ('%d TALL, CROWN ~%d X %d' % (HEIGHT, gt['crown_w_e'], gt['crown_n_s']), ink),
             ('FOREST ABOUT 560 ACROSS', ink)]
    for i, (s, c) in enumerate(lines):
        d.text((203, L0 + i * 10), s, font=f, fill=c)
    ky = L0 + 44
    d.line([(204, ky + 4), (216, ky + 4)], fill=towroot, width=3)
    d.text((222, ky), "THE TOWER'S ROOT", font=f, fill=ink)
    d.line([(204, ky + 14), (216, ky + 14)], fill=rootc, width=2)
    d.text((222, ky + 10), 'OTHER ROOTS', font=f, fill=ink)
    for k in range(204, 217, 3):
        img.putpixel((k, ky + 24), faint)
    d.text((222, ky + 20), 'ROOT ROAD (LATER)', font=f, fill=ink)
    for yy in range(ky + 30, ky + 38):
        for xx in range(204, 217):
            if (xx + yy) % 3 == 0:
                img.putpixel((xx, yy), hatch)
    d.text((222, ky + 30), 'UNDER THE CANOPY', font=f, fill=ink)
    d.rectangle((209, ky + 41, 211, ky + 43), fill=lamp, outline=ink)
    d.text((222, ky + 40), 'THE LAMP', font=f, fill=ink)
    save(img, 'boughs_map')


# ================================================================================================ review
def review():
    names = ['boughs_title', 'boughs_vista', 'boughs_hold']
    ims = [Image.open(f'{OUT}/{n}_1x.png').convert('RGB') for n in names]
    sheet = Image.new('RGB', (768, 432), (0, 0, 0))
    for i, im in enumerate(ims):
        sheet.paste(im, ((i % 2) * 384, (i // 2) * 216))
    sheet.paste(Image.open(f'{OUT}/boughs_map_1x.png').convert('RGB').crop((0, 0, 384, 216)), (384, 216))
    sheet.resize((1536, 864), Image.NEAREST).save(f'{SCRATCH}/boughs_sheet.png')


if __name__ == '__main__':
    g = geometry_report()
    title = mock_title(g)
    mock_vista(g)
    mock_hold(g)
    mock_influence(title)
    mock_map(g)
    review()
    for k, v in REPORT.items():
        if k == 'geometry':
            for kk, vv in v.items():
                print('geometry', kk, vv)
        else:
            print(k, v)
