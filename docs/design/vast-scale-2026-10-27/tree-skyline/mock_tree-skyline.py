# Great tree, reading 1 "the trunk on the skyline", at the vast scale (2026-10-27).
# Design mocks only (proposal). Pixel art: hard edges, repo palettes, flat tones, nearest-neighbour 3x.
# Run: python -W ignore mock_tree-skyline.py   (writes PNGs and mock_report.txt next to this file)
import math, random, os
from PIL import Image, ImageDraw, ImageFont

R = r"C:/Users/pmcga/dev/hollowtide"
OUT = R + "/docs/design/vast-scale-2026-10-27/tree-skyline"
PALDIR = R + "/docs/design/placeholder-factory-2026-10-26/refs/palettes"
CAND = R + "/docs/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/prepared.png"
CAP = R + "/docs/design/wayline-tower-2026-10-27/build/round2"
SPR = R + "/assets/sprites/creatures"
FONTF = R + "/assets/fonts/Silkscreen-Regular.ttf"
os.makedirs(OUT, exist_ok=True)
REPORT = []


def log(*a):
    s = " ".join(str(x) for x in a)
    REPORT.append(s)
    print(s)


# ---------------------------------------------------------------- helpers
def hx(s):
    s = s.lstrip('#')
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def oramp(*hexes):
    return [hx(h) for h in hexes]


B4 = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def bay(x, y):
    return (B4[y & 3][x & 3] + 0.5) / 16.0


def pick(rmp, v, x, y, amt=0.3):
    n = len(rmp)
    f = v * (n - 1) + (bay(x, y) - 0.5) * amt
    i = int(round(f))
    return rmp[max(0, min(n - 1, i))]


def save2(img, name):
    img.save(f"{OUT}/{name}_1x.png")
    img.resize((img.width * 3, img.height * 3), Image.NEAREST).save(f"{OUT}/{name}_3x.png")


def load_pal(fn):
    im = Image.open(PALDIR + '/' + fn).convert('RGB')
    seen = []
    for y in range(im.height):
        for x in range(im.width):
            c = im.getpixel((x, y))
            if c not in seen:
                seen.append(c)
    return seen


def capture1x(fn):
    im = Image.open(CAP + '/' + fn).convert('RGB')
    return im.resize((im.width // 3, im.height // 3), Image.NEAREST)


def hash2(ix, iy, seed):
    h = (ix * 374761393 + iy * 668265263 + seed * 982451653) & 0xffffffff
    h = ((h ^ (h >> 13)) * 1274126177) & 0xffffffff
    return ((h ^ (h >> 16)) & 0xffff) / 65535.0


def vnoise(x, y, seed=0):
    ix, iy = math.floor(x), math.floor(y)
    fx, fy = x - ix, y - iy
    sx, sy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = hash2(ix, iy, seed), hash2(ix + 1, iy, seed)
    c, d = hash2(ix, iy + 1, seed), hash2(ix + 1, iy + 1, seed)
    top = a + (b - a) * sx
    bot = c + (d - c) * sx
    return top + (bot - top) * sy


def fbm(x, y, seed=0, octv=3):
    s, amp, f, tot = 0.0, 0.5, 1.0, 0.0
    for o in range(octv):
        s += amp * vnoise(x * f, y * f, seed + o * 17)
        tot += amp
        amp *= 0.5
        f *= 2
    return s / tot


def nearest(c, pal):
    best, bd = pal[0], 1e18
    for p in pal:
        d = (p[0] - c[0]) ** 2 * 0.3 + (p[1] - c[1]) ** 2 * 0.59 + (p[2] - c[2]) ** 2 * 0.11
        if d < bd:
            bd, best = d, p
    return best


FONT8 = ImageFont.truetype(FONTF, 8)
FONT16 = ImageFont.truetype(FONTF, 16)


def text1(img, xy, s, col, font=FONT8, shadow=None):
    w = int(font.getlength(s)) + 4
    h = font.size + 6
    m = Image.new('1', (w, h), 0)
    d = ImageDraw.Draw(m)
    d.fontmode = '1'
    d.text((0, 0), s, fill=1, font=font)
    if shadow is not None:
        img.paste(Image.new('RGB', (w, h), shadow), (xy[0] + 1, xy[1] + 1), m)
    img.paste(Image.new('RGB', (w, h), col), xy, m)


def edges(img, box):
    px = img.load()
    x0, y0, x1, y1 = box
    n = 0
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if x < x1 and px[x, y] != px[x + 1, y]:
                n += 1
            if y < y1 and px[x, y] != px[x, y + 1]:
                n += 1
    return n


def changed(a, b, box):
    pa, pb = a.load(), b.load()
    x0, y0, x1, y1 = box
    return sum(1 for y in range(y0, y1 + 1) for x in range(x0, x1 + 1) if pa[x, y] != pb[x, y])


def blob(px, W, H, x, cy, rr, rmp, seed, clip=None, aspect=1.0):
    """Lumpy tree crown, lit from the upper left. rmp = [shadow, mid, lit, highlight]."""
    for yy in range(int(cy - rr * aspect) - 1, int(cy + rr * aspect) + 2):
        for xx in range(int(x - rr) - 1, int(x + rr) + 2):
            if not (0 <= xx < W and 0 <= yy < H):
                continue
            if clip is not None and not clip(xx, yy):
                continue
            dx, dy = (xx + 0.5 - x) / rr, (yy + 0.5 - cy) / (rr * aspect)
            th = math.atan2(dy, dx)
            r2 = 1 + 0.14 * math.sin(6 * th + seed) + 0.06 * math.sin(13 * th + seed * 2)
            if dx * dx + dy * dy > r2 * r2:
                continue
            l = -0.7 * dx - 0.7 * dy + (vnoise(xx / 2.5, yy / 2.5, int(seed * 7) % 997) - 0.5) * 0.6
            t = 3 if l > 0.75 else 2 if l > 0.15 else 1 if l > -0.5 else 0
            px[xx, yy] = rmp[t]


def canopy_tone(x, y, cell=3.0, seed=0):
    """Far forest texture: jittered cells, each a little crown lit from its upper left (0 shadow..2 lit)."""
    gx, gy = math.floor(x / cell), math.floor(y / cell)
    best, bdx, bdy = 1e9, 0.0, 0.0
    for oy in (-1, 0, 1):
        for ox in (-1, 0, 1):
            ccx = (gx + ox + 0.2 + 0.6 * hash2(gx + ox, gy + oy, seed)) * cell
            ccy = (gy + oy + 0.2 + 0.6 * hash2(gx + ox, gy + oy, seed + 1)) * cell
            dx, dy = x + 0.5 - ccx, y + 0.5 - ccy
            dd = dx * dx + dy * dy
            if dd < best:
                best, bdx, bdy = dd, dx, dy
    sd = (bdx + bdy) / cell
    return 2 if sd < -0.35 else (1 if sd < 0.3 else 0)


# ---------------------------------------------------------------- the tree (proposal numbers, tiles)
TREE_D = 340.0          # Tower to trunk centre
TREE_BEAR = -35.0       # degrees from north, negative = west (north-west)
TREE = (TREE_D * math.sin(math.radians(TREE_BEAR)), -TREE_D * math.cos(math.radians(TREE_BEAR)))
T_H = 360               # ground to crown top
T_TRUNK = 100           # trunk width above the flare
T_FLARE = 260           # flare across the buttresses at the ground
T_CROWN = 440           # crown spread
T_CROWN_OFF = -65       # crown centre sits this far west of the trunk (lopsided, away from town)
T_UNDER = 165           # crown underside height at its centre
T_RIM = 133             # crown rim height (it droops)


def t_hw(h):
    return 50 + 80 * math.exp(-h / 16.0) + 2.5 * math.sin(h / 9.0) + 1.5 * math.sin(h / 4.3 + 1) - 0.03 * max(0, h - 40)


def t_uc(h):
    return 4 * math.sin(h / 37.0) - 0.02 * h


def lens(cam, axis_deg, f, pt):
    dx = pt[0] - cam[0]
    dn = cam[1] - pt[1]
    bear = math.degrees(math.atan2(dx, dn))
    phi = math.radians(bear - axis_deg)
    dist = math.hypot(dx, dn)
    z = dist * math.cos(phi)
    return 192 + f * math.tan(phi), f / z, dist, bear


LIMBS = [  # (h0, angle from vertical deg, bend deg, length, w0, w1); negative angle = west/left
    (120, -58, -8, 80, 22, 12),
    (132, -30, -10, 70, 20, 11),
    (146, -6, -4, 50, 18, 11),
    (138, 22, 10, 60, 18, 10),
    (124, 50, 10, 60, 19, 10),
]

# material codes
M_TRUNK, M_SPUR, M_LIMB, M_CROWN, M_STRAND, M_FOREST, M_BAND, M_MOSS = 1, 2, 3, 4, 5, 6, 7, 8


def far_tree(W, H, sx, s, base_y, L, max_x, seed, calm_y=-1):
    """Material and tone maps for a far view. L = -1 sun from the left, +1 from the right.
    Tones: trunk 0..4 (shadow, mid, lit, strong, rim); crown 0..5; forest 0..3.
    Rows above calm_y get no furrows, moss or strands (keeps the title wordmark area quiet)."""
    rnd = random.Random(seed)
    mirror = (lambda x: x) if L < 0 else (lambda x: -x)
    mat = [[0] * W for _ in range(H)]
    ton = [[0] * W for _ in range(H)]
    # trunk with flare
    for y in range(H):
        h = (base_y - y) / s
        if h < -1 or h > 178:
            continue
        hc = max(h, 0.0)
        hwt = t_hw(hc)
        hw = hwt * s
        uc = sx + t_uc(hc) * s
        for x in range(max(0, int(uc - hw) - 1), min(W, int(uc + hw) + 2)):
            if x > max_x:
                continue
            nx = (x + 0.5 - uc) / hw
            if abs(nx) > 1:
                continue
            q = nx * L
            t = 4 if q > 0.9 else 3 if q > 0.45 else 2 if q > 0.0 else 1 if q > -0.6 else 0
            arc = math.asin(max(-1.0, min(1.0, nx))) * hwt
            wob = 3.0 * math.sin(hc / 21.0 + arc / 30.0) + 1.5 * math.sin(hc / 8.0 + arc / 13.0)
            k = math.floor((arc + wob) / 14.0)
            ph = ((arc + wob) / 14.0) % 1.0
            calm = y < calm_y
            if not calm and ph < 0.11 and 1 <= t <= 3 and vnoise(k * 1.7, hc / 26.0, seed) > 0.32:
                t -= 1
            if hc > 100:
                t -= 1
            if hc > 128:
                t -= 1
            if calm:
                t = {0: 0, 1: 0, 2: 2, 3: 2, 4: 4}[max(0, t)]
            m = M_TRUNK
            if not calm and t >= 2 and vnoise(arc / 5.0, hc / 40.0, seed + 3) > 0.76:
                m = M_MOSS
            if hc < 14 + 8 * vnoise(x / 4.0, 0, seed + 4):
                m = M_FOREST
                t = canopy_tone(mirror(x), y, 3.0, seed + 9) + (1 if nx * L > 0.3 else 0)
            mat[y][x] = m
            ton[y][x] = max(0, t)
    # buttress spurs: hill-like ridges (shoulder, slope, toe) with forest growing on them
    spurs = [(-1, 62, 205), (-1, 30, 118), (1, 52, 168)]
    for si, (side, jh, end_u) in enumerate(spurs):
        ju = t_uc(jh) + side * t_hw(jh) * 0.85
        for x in range(W):
            if x > max_x:
                continue
            u = (x + 0.5 - sx) / s
            t = (u - ju) / (side * end_u - ju)
            if t < 0 or t > 1:
                continue
            sm = t * t * (3 - 2 * t)
            rh = jh * (1 - sm) * (1 + 0.07 * math.sin(t * 9 + si))
            yt = int(round(base_y - rh * s))
            for y in range(max(0, yt), min(H, int(base_y) + 1)):
                d = y - yt
                if d == 0 and vnoise(x / 2.0, si, seed + 2) > 0.3:
                    mat[y][x], ton[y][x] = M_SPUR, (3 if side * L > 0 else 2)
                else:
                    tt = canopy_tone(mirror(x), y, 3.0, seed + 11 + si)
                    if side * L > 0 and tt == 2 and hash2(x, y, seed) < 0.35:
                        tt = 3
                    mat[y][x], ton[y][x] = M_FOREST, tt
            if rh * s > 1.5 and hash2(x, 3 + si, seed) < 0.45:
                bh = 1 + int(hash2(x, 7 + si, seed) * 2.2)
                for kk in range(1, bh + 1):
                    yy = yt - kk
                    if 0 <= yy < H:
                        mat[yy][x], ton[yy][x] = M_FOREST, (2 if kk == bh else 1)
    # limbs, short forks into the crown
    for (h0, a0, bend, length, w0, w1) in LIMBS:
        u = t_uc(h0) + math.sin(math.radians(a0)) * t_hw(h0) * 0.4
        h = float(h0)
        steps = 160
        dl = length / steps
        for i in range(steps):
            tt = i / steps
            a = math.radians(a0 + bend * tt)
            u += math.sin(a) * dl
            h += math.cos(a) * dl
            r = (w0 + (w1 - w0) * tt) * 0.5 * s
            cx, cy = sx + u * s, base_y - h * s
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if 0 <= xx < W and 0 <= yy < H and xx <= max_x:
                        dx, dy = xx + 0.5 - cx, yy + 0.5 - cy
                        if dx * dx + dy * dy <= r * r:
                            mat[yy][xx] = M_LIMB
                            ton[yy][xx] = 1 if dx * L > r * 0.3 else 0
    # crown: a flat mass above two rows of lobes along its drooping underside
    cu, Rr = T_CROWN_OFF, T_CROWN / 2.0
    row1 = []
    u = cu - Rr + 18
    while u < cu + Rr - 10:
        q = (u - cu) / Rr
        low = T_UNDER - (T_UNDER - T_RIM) * q * q
        cr = rnd.uniform(28, 42)
        row1.append((u + rnd.uniform(-4, 4), low + cr * 0.42 + rnd.uniform(-3, 3), cr))
        u += cr * 1.15
    row2 = [(u0 + cr0 * 0.55, h0 + cr0 * 1.05, cr0 * rnd.uniform(0.9, 1.2)) for (u0, h0, cr0) in row1]
    kept1 = [l for l in row1 if sx + (l[0] + l[2] * 1.15) * s <= max_x]
    kept2 = [l for l in row2 if sx + (l[0] + l[2] * 1.15) * s <= max_x]
    if kept1:
        xl = min(sx + (l[0] - l[2]) * s for l in kept1)
        xr = max(sx + (l[0] + l[2]) * s for l in kept1)
        for x in range(max(0, int(xl)), min(W, int(xr) + 1)):
            u = (x + 0.5 - sx) / s
            q = (u - cu) / Rr
            if abs(q) > 1:
                continue
            hl = T_UNDER - (T_UNDER - T_RIM) * q * q + 26
            ht = T_H - 140 * q * q
            for y in range(max(0, int(base_y - ht * s)), min(H, int(base_y - hl * s) + 1)):
                mat[y][x], ton[y][x] = M_CROWN, 0
    for lobes in (kept2, kept1):
        for (u, h, cr) in lobes:
            cx, cy, r = sx + u * s, base_y - h * s, cr * s
            ph1, ph2 = rnd.uniform(0, 6.28), rnd.uniform(0, 6.28)
            rimk = max(0.0, ((u - cu) / Rr) * L)
            for yy in range(int(cy - r) - 2, int(cy + r) + 3):
                for xx in range(int(cx - r * 1.2) - 2, int(cx + r * 1.2) + 3):
                    if not (0 <= xx < W and 0 <= yy < H) or xx > max_x:
                        continue
                    dx, dy = (xx + 0.5 - cx) / r, (yy + 0.5 - cy) / (r * 0.7)
                    th = math.atan2(dy, dx)
                    rr = 1 + 0.12 * math.sin(5 * th + ph1) + 0.07 * math.sin(11 * th + ph2)
                    dd = math.sqrt(dx * dx + dy * dy)
                    if dd > rr:
                        continue
                    t = 1
                    if dd > rr - 0.16 and dy > 0.15:
                        t = 0
                    if dx * L > 0.4 and dy > -0.25 and rimk > 0.2 and dd > rr - 0.32 and cx + r < max_x - 10:
                        t = 3 if rimk < 0.45 else (4 if dd < rr - 0.12 else 5)
                    mat[yy][xx], ton[yy][xx] = M_CROWN, t
    # a few hanging strands under the crown
    for x in range(W):
        if x > max_x:
            continue
        if calm_y > 0 and 90 <= x <= 295:
            continue
        yb = -1
        for y in range(H):
            if mat[y][x] == M_CROWN:
                yb = y
        if yb >= 0 and hash2(x, yb, seed + 5) < 0.07:
            ln = 2 + int(hash2(x, 1, seed + 9) * 4)
            for k in range(1, ln + 1):
                if yb + k < H and mat[yb + k][x] in (0,):
                    mat[yb + k][x], ton[yb + k][x] = M_STRAND, 0
    return mat, ton


def composite_far(img, mat, ton, mask, ramps, zone_of):
    px = img.load()
    n = 0
    for y in range(img.height):
        for x in range(img.width):
            m = mat[y][x]
            if m == 0 or not mask(x, y):
                continue
            z = zone_of(x, y)
            t = ton[y][x]
            if m in (M_TRUNK, M_SPUR, M_LIMB):
                rmp = ramps['trunk_' + z]
            elif m == M_MOSS:
                rmp = ramps['moss_' + z]
            elif m == M_CROWN:
                rmp = ramps['crown']
            elif m == M_STRAND:
                rmp = ramps['crown']
            elif m == M_BAND:
                rmp = ramps['band']
            else:
                rmp = ramps['forest']
            px[x, y] = rmp[max(0, min(len(rmp) - 1, t))]
            n += 1
    return n


def row_modes(img, x0, x1):
    px = img.load()
    modes = []
    for y in range(img.height):
        cnt = {}
        for x in range(x0, x1):
            c = px[x, y]
            cnt[c] = cnt.get(c, 0) + 1
        modes.append(max(cnt.items(), key=lambda kv: kv[1])[0])
    return modes


def zoner(b1, b2):
    def zone(x, y):
        yy = y + (bay(x, y) - 0.5) * 3
        return 'high' if yy < b1 else ('mid' if yy < b2 else 'low')
    return zone


# ---------------------------------------------------------------- 1. title on Codex's candidate
def build_title():
    base = Image.open(CAND).convert('RGB')
    img = base.copy()
    W, H = img.size
    px0 = base.load()
    cam, f = (0.0, 50.0), 270.0
    axis = -math.degrees(math.atan((333 - 192) / f))
    sx, s, dist, bear = lens(cam, axis, f, TREE)
    sx_t, s_t, dist_t, _ = lens(cam, axis, f, (0.0, 0.0))
    log(f"TITLE lens: f {f:.0f} px, camera 50 tiles S of the Tower looking {abs(axis):.1f} deg west of north; tree at screen x {sx:.0f}, {s:.3f} px per tile, {dist:.0f} tiles away; Tower {s_t:.2f} px per tile")
    base_y = 124
    modes = row_modes(base, 100, 200)
    HILLS = {hx('#43665a'), hx('#4f6858'), hx('#61785c')}
    WOODS = {hx(c) for c in ('#303e37', '#1d2925', '#44421a', '#263d3a', '#1e302e', '#192726')}
    ridge = []
    for x in range(W):
        rt = base_y
        for y in range(104, 140):
            if px0[x, y] in WOODS and px0[x, min(H - 1, y + 1)] in WOODS:
                rt = y
                break
        ridge.append(rt)

    def allowed(y):
        a = {modes[yy] for yy in range(max(0, y - 3), min(H, y + 4))}
        if y >= 100:
            a |= HILLS
        return a
    ALLOW = [allowed(y) for y in range(H)]
    canopy_r = []
    for y in range(H):
        run, start = 0, W
        for x in range(W):
            if px0[x, y] in ALLOW[y]:
                run += 1
                if run >= 12:
                    start = x - 11
                    break
            else:
                run = 0
        canopy_r.append(start)
    MAXX = 288

    def mask(x, y):
        if x > MAXX or y >= ridge[x]:
            return False
        if 21 <= x <= 128 and 108 <= y <= 199:
            return False
        if x < canopy_r[y]:
            return False
        return px0[x, y] in ALLOW[y]
    mat, ton = far_tree(W, H, sx, s, base_y, -1, MAXX, 11, calm_y=53)
    ramps = {
        'trunk_high': oramp('#1d2925', '#1d2925', '#33524e', '#33524e', '#4f6858'),
        'trunk_mid': oramp('#263d3a', '#303e37', '#4f6858', '#61785c', '#8e7f5e'),
        'trunk_low': oramp('#303e37', '#43665a', '#4f6858', '#61785c', '#9c8c68'),
        'moss_high': oramp('#263d3a', '#263d3a', '#263d3a', '#303e37', '#303e37'),
        'moss_mid': oramp('#303e37', '#303e37', '#44421a', '#6b6d45', '#6b6d45'),
        'moss_low': oramp('#303e37', '#303e37', '#44421a', '#6b6d45', '#6b6d45'),
        'crown': oramp('#192726', '#1d2925', '#263d3a', '#44421a', '#6b6d45', '#908940'),
        'forest': oramp('#263d3a', '#303e37', '#43665a', '#61785c'),
        'band': oramp('#303e37', '#43665a', '#61785c'),
    }
    n = composite_far(img, mat, ton, mask, ramps, zoner(52, 86))
    pxi = img.load()
    for (bx, by) in [(160, 70), (168, 74), (176, 68), (171, 79)]:
        for (dx, dy) in [(0, 0), (1, 1), (2, 0)]:
            pxi[bx + dx, by + dy] = hx('#1d2925')
    save2(img, 'title')
    pal = set(load_pal('highbank_title.png'))
    cols = set(img.getdata())
    log(f"TITLE colours {len(cols)} (before {len(set(base.getdata()))}); outside the highbank_title palette: {len(cols - pal)}")
    log(f"TITLE tree px {n}; changed in the menu box {changed(base, img, (21, 108, 128, 199))}; changed right of x 288 (room for the taller Tower) {changed(base, img, (289, 0, 383, 215))}")
    log(f"TITLE wordmark box (x 90-295, y 0-52) colour edges before {edges(base, (90, 0, 295, 52))} after {edges(img, (90, 0, 295, 52))}")
    trunk_w = 2 * t_hw(60) * s
    log(f"TITLE trunk {trunk_w:.0f} px wide (x {sx - trunk_w / 2:.0f} to {sx + trunk_w / 2:.0f}); full tree would be {T_H * s:.0f} px tall (runs off the top); crown underside y {base_y - T_UNDER * s:.0f} at centre, rim y {base_y - T_RIM * s:.0f}; flare {T_FLARE * s:.0f} px across at the ground")
    g = img.resize((W * 3, H * 3), Image.NEAREST)
    d = ImageDraw.Draw(g)

    def dash_rect(b, col):
        x0, y0, x1, y1 = [v * 3 for v in b]
        for x in range(x0, x1, 12):
            d.line([(x, y0), (min(x + 6, x1), y0)], fill=col, width=3)
            d.line([(x, y1), (min(x + 6, x1), y1)], fill=col, width=3)
        for y in range(y0, y1, 12):
            d.line([(x0, y), (x0, min(y + 6, y1))], fill=col, width=3)
            d.line([(x1, y), (x1, min(y + 6, y1))], fill=col, width=3)
    dash_rect((90, 0, 295, 52), (245, 245, 245))
    dash_rect((21, 108, 128, 199), (245, 245, 245))
    dash_rect((289, 0, 383, 170), hx('#fbd490'))
    text1(g, (96 * 3, 42 * 3), 'WORDMARK AREA', (245, 245, 245), FONT16, (0, 0, 0))
    text1(g, (24 * 3, 186 * 3), 'MENU, 0 PX CHANGED', (245, 245, 245), FONT16, (0, 0, 0))
    text1(g, (292 * 3, 4 * 3), 'ROOM FOR THE', hx('#fbd490'), FONT16, (0, 0, 0))
    text1(g, (292 * 3, 11 * 3), 'TALLER TOWER', hx('#fbd490'), FONT16, (0, 0, 0))
    text1(g, (292 * 3, 18 * 3), '(OLD 30-TILE', hx('#fbd490'), FONT16, (0, 0, 0))
    text1(g, (292 * 3, 25 * 3), 'TOWER SHOWN)', hx('#fbd490'), FONT16, (0, 0, 0))
    g.save(f"{OUT}/title_guides_3x.png")


# ---------------------------------------------------------------- 2. vista on the in-game capture
def build_vista():
    base = capture1x('13_road_vista.png')
    img = base.copy()
    W, H = img.size
    px0 = base.load()
    cam, f = (0.0, 46.0), 270.0
    axis = -math.degrees(math.atan((268 - 192) / f))
    sx, s, dist, bear = lens(cam, axis, f, TREE)
    log(f"VISTA lens: f {f:.0f} px, camera 46 tiles S of the Tower looking {abs(axis):.1f} deg west of north; tree at screen x {sx:.0f}, {s:.3f} px per tile, {dist:.0f} tiles away")
    base_y = 126
    modes = row_modes(base, 60, 200)
    HILLS = {hx('#a3b0ae'), hx('#b8c2bc')}

    def allowed(y):
        a = {modes[yy] for yy in range(max(0, y - 3), min(H, y + 4)) if yy < 124}
        if y >= 108:
            a |= HILLS
        return a
    ALLOW = [allowed(y) for y in range(H)]
    MAXX = 226

    def mask(x, y):
        if x > MAXX or y > base_y:
            return False
        return px0[x, y] in ALLOW[y]
    mat, ton = far_tree(W, H, sx, s, base_y, 1, MAXX, 23)
    # the great forest band across the tree's foot
    for x in range(0, MAXX + 1):
        top = 110 + 3.0 * math.sin(x / 23.0) + 4.0 * fbm(x / 9.0, 0, 4)
        yt = int(top - 2.0 * abs(math.sin(x * 0.85 + hash2(x // 4, 0, 2) * 3)))
        for y in range(max(0, yt), base_y + 1):
            if mat[y][x] in (M_CROWN, M_LIMB):
                continue
            d = y - yt
            mat[y][x] = M_BAND
            ton[y][x] = 3 if (d == 0 and hash2(x, 0, 4) < 0.6) else canopy_tone(-x, y, 3.0, 41) + (1 if d < 3 else 0)
    ramps = {  # current dawn palette (55 colours since factory pass 9, 19:00)
        'trunk_high': oramp('#2f372a', '#3c4d56', '#4b5350', '#7a8d81', '#9b8c68'),
        'trunk_mid': oramp('#3c4d56', '#4b5350', '#5e6f63', '#8a856c', '#b59e7c'),
        'trunk_low': oramp('#4b5350', '#5e6f63', '#7f9394', '#999683', '#c8b190'),
        'moss_high': oramp('#2f372a', '#2f372a', '#2f372a', '#4c4a40', '#4c4a40'),
        'moss_mid': oramp('#4c4a40', '#4c4a40', '#73754e', '#73754e', '#73754e'),
        'moss_low': oramp('#5e6f63', '#5e6f63', '#8a856c', '#8a856c', '#8a856c'),
        'crown': oramp('#2a3426', '#2f372a', '#3c532b', '#5c6a3b', '#73754e', '#8a856c'),
        'forest': oramp('#3c4d56', '#5e6f63', '#7a8d81', '#8b9284'),
        'band': oramp('#4b5350', '#5e6f63', '#7f9394', '#9cabb1'),
    }
    n = composite_far(img, mat, ton, mask, ramps, zoner(40, 80))
    px = img.load()
    for (bx, by) in [(104, 66), (112, 70), (119, 64)]:
        for (dx, dy) in [(0, 0), (1, 1), (2, 0)]:
            if mask(bx + dx, by + dy):
                px[bx + dx, by + dy] = hx('#2f372a')
    save2(img, 'vista')
    pal = set(load_pal('dawn.png'))
    cap = set(base.getdata())
    cols = set(img.getdata())
    new = cols - cap
    log(f"VISTA colours {len(cols)} (capture {len(cap)}); colours added {len(new)}, all from the dawn palette: {new <= pal}; not in dawn: {sorted('#%02x%02x%02x' % c for c in (new - pal))}")
    log(f"VISTA tree px {n}; changed right of x 226 (room for the taller Tower) {changed(base, img, (227, 0, 383, 215))}")
    log(f"VISTA trunk {2 * t_hw(60) * s:.0f} px wide; crown underside y {base_y - T_UNDER * s:.0f} at centre, rim y {base_y - T_RIM * s:.0f}; crown would reach x {sx + (T_CROWN_OFF - T_CROWN / 2) * s:.0f} to {sx + (T_CROWN_OFF + T_CROWN / 2) * s:.0f}")


# ---------------------------------------------------------------- 3. base: arriving at the tree, from scratch
def majority_down(im, th):
    bb = im.getbbox()
    im = im.crop(bb)
    w, h = im.size
    tw = max(1, round(w * th / h))
    out = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    src, dst = im.load(), out.load()
    for ty in range(th):
        y0 = int(ty * h / th)
        y1 = max(y0 + 1, int((ty + 1) * h / th))
        for tx in range(tw):
            x0 = int(tx * w / tw)
            x1 = max(x0 + 1, int((tx + 1) * w / tw))
            cnt, n, tr = {}, 0, 0
            for yy in range(y0, y1):
                for xx in range(x0, x1):
                    p = src[xx, yy]
                    n += 1
                    if p[3] < 128:
                        tr += 1
                    else:
                        cnt[p[:3]] = cnt.get(p[:3], 0) + 1
            if tr * 2 > n or not cnt:
                continue
            dark = [kv for kv in cnt.items() if lum(kv[0]) < 55 and kv[1] * 4 >= n]
            c = dark[0][0] if dark else max(cnt.items(), key=lambda kv: kv[1])[0]
            dst[tx, ty] = c + (255,)
    return out


def build_base():
    W, H = 384, 216
    img = Image.new('RGB', (W, H))
    px = img.load()
    SKY = oramp('#8da2aa', '#9cabb1', '#bdbdb5', '#e2c59b', '#f5e4bd')
    BARK = oramp('#1d2925', '#3f2716', '#663f23', '#8c6545', '#b06b3d', '#c49b69', '#e6c697')
    BFAR = oramp('#4b5350', '#796145', '#8a856c', '#a3a891', '#bfb28e', '#bdbdb5')
    MOSS = oramp('#2f372a', '#44421a', '#6b6f1d', '#908940', '#c6bb2a')
    FNEAR = oramp('#1d2925', '#3c532b', '#4a6530', '#75895d')
    FMID = oramp('#2f372a', '#3e5629', '#5c7149', '#75895d')
    FFAR = oramp('#4b5350', '#5e6f63', '#7a8d81', '#8b9284')
    FHAZE = oramp('#7f9394', '#8da2aa', '#9cabb1', '#bdbdb5')
    MIST = oramp('#c4b48f', '#e2c59b', '#f5e4bd')
    # sky, flat bands with a 2-row checker between them
    for y in range(H):
        for x in range(W):
            t = (y + (bay(x, y) - 0.5) * 3) / 34.0
            px[x, y] = SKY[max(0, min(len(SKY) - 1, int(t)))]
    # far forest at the sides
    for x in range(W):
        y1 = int(132 + 5 * vnoise(x / 9.0, 1, 3) + 3 * math.sin(x / 13.0) - 2 * abs(math.sin(x * 0.7)))
        for y in range(y1, H):
            px[x, y] = FHAZE[2] if y < y1 + 1 else FHAZE[1]

    def tcx(y):
        return 196 + 3 * math.sin(y / 40.0)

    def thw(y):
        if y <= 100:
            return 150 + 0.10 * y
        return 160 + ((y - 100) / 72.0) ** 2 * 260
    # trunk
    for y in range(0, 176):
        cx, hw = tcx(y), thw(y)
        for x in range(max(0, int(cx - hw)), min(W, int(cx + hw) + 1)):
            nx = (x + 0.5 - cx) / hw
            if abs(nx) > 1:
                continue
            lit = 0.6 - 0.42 * nx - 0.22 * max(0.0, nx - 0.55) / 0.45
            arc = math.asin(max(-1.0, min(1.0, nx))) * 70.0
            wob = 2.4 * math.sin(y / 19.0 + arc * 0.21) + 1.3 * math.sin(y / 7.3 + arc * 0.5)
            ph = ((arc + wob) / 6.5) % 1.0
            k = math.floor((arc + wob) / 6.5)
            if ph < 0.15:
                lit -= 0.42
            elif ph < 0.25:
                lit += 0.1
            elif (y + int(hash2(k, 0, 5) * 40)) % 37 == 0 and ph < 0.85:
                lit -= 0.3
            if nx < -0.96:
                lit = 0.9
            if nx > 0.98:
                lit = 0.0
            lit = max(0.0, min(1.0, lit))
            if fbm(arc / 9.0, y / 22.0, 3) > 0.6 and nx < 0.45 and ph > 0.22:
                px[x, y] = pick(MOSS, lit * 0.95, x, y)
            else:
                px[x, y] = pick(BARK, lit, x, y)
    # two banks of low cloud drifting across the trunk (vastness cue): lumpy tops, flat shaded bases
    rndw = random.Random(11)
    for (bx0, bx1, by) in [(118, 228, 68), (250, 334, 61)]:
        cover = {}
        x = bx0
        while x < bx1:
            s = math.sin(math.pi * (x - bx0) / float(bx1 - bx0))
            r = max(1.6, rndw.uniform(2.5, 8.0) * (0.3 + 0.7 * s))
            ly = by + 2 * math.sin(x / 23.0) - r * 0.2
            base = by + 2 + int(2 * s)
            for yy in range(int(ly - r), int(base) + 1):
                for xx in range(int(x - r * 1.35), int(x + r * 1.35) + 1):
                    dx = (xx - x) / (r * 1.35)
                    dy = (yy - ly) / r
                    if dx * dx + dy * dy <= 1.0 or (yy >= ly and abs(dx) <= 0.7):
                        if 0 <= xx < W and 0 <= yy < H and yy <= base:
                            cover[(xx, yy)] = min(cover.get((xx, yy), 9.0), dy)
            x += rndw.randint(5, 9)
        # trailing streaks off both ends, one or two rows thick
        for (sx0, sx1, sy) in [(bx0 - 22, bx0 + 4, by + 2), (bx1 - 4, bx1 + 26, by + 1)]:
            for xx in range(sx0, sx1):
                if 0 <= xx < W and (xx * 7 + sy) % 11 != 0:
                    cover.setdefault((xx, sy), 0.5)
                    if bx0 - 12 < xx < bx1 + 14:
                        cover.setdefault((xx, sy - 1), -0.5)
        for (xx, yy), dy in cover.items():
            below = (xx, yy + 1) in cover
            if (xx, yy - 1) not in cover or dy < -0.55:
                px[xx, yy] = MIST[2]
            elif not below:
                px[xx, yy] = MIST[0]
            else:
                px[xx, yy] = MIST[1] if dy > -0.1 else MIST[2]
    # vines from above
    for i, (vx, ln) in enumerate([(70, 40), (98, 70), (121, 30), (150, 56), (183, 84), (214, 44), (247, 66), (276, 36), (310, 74), (334, 30)]):
        for y in range(0, ln):
            x = int(vx + 2 * math.sin(y / 9.0 + i))
            px[x, y] = hx('#2f372a')
            if y % 5 == i % 5:
                px[x - 1, y] = hx('#908940')
                px[x + 1, y] = hx('#6b6f1d')
    # moss curtains hanging into the top corners from limbs far above
    for i, (vx, ln) in enumerate([(6, 44), (15, 26), (24, 60), (36, 34), (350, 52), (360, 30), (372, 64), (380, 40)]):
        for y in range(0, ln):
            x = int(vx + 1.5 * math.sin(y / 8.0 + i))
            px[x, y] = hx('#5c6a3b')
            if y % 4 == i % 4:
                px[x + 1, y] = hx('#73754e')
                px[x - 1, y] = hx('#3c532b')

    # buttress roots, far to near
    def draw_buttress(jx, jy, ex, ey, far, seed):
        rnd = random.Random(seed)
        lo, hi = (jx, ex) if jx < ex else (ex, jx)
        ridge = {}
        # inner side face: the wedge where the buttress leaves the trunk, with a crease against the bark
        out = -1 if ex < jx else 1
        # the flank in shadow, flaring in a curve (not a straight wedge) so the root grows out of the bark
        # the root starts as a fold in the bark well above where it leaves the trunk, so there is no apex
        for y in range(int(jy) - 30, int(jy)):
            f = (y - (jy - 30)) / 30.0
            fx = jx - out * 2.0 * (1 - f)
            wf = int(1 + 3 * f)
            for k in range(-wf, wf + 1):
                x = int(fx + k)
                if 0 <= x < W:
                    side = k * (-out)
                    if side > 0:
                        px[x, y] = pick(BARK, 0.18 + 0.08 * f, x, y)
                    elif side < 0:
                        px[x, y] = pick(BARK, 0.74 + 0.1 * f, x, y)
                    else:
                        px[x, y] = BARK[0]
        for y in range(int(jy), H):
            wdt = (2.4 if far else 3.0) * math.sqrt(max(0.0, y - jy))
            for k in range(int(wdt) + 1):
                x = int(jx - out * k)
                if not (0 <= x < W):
                    continue
                if k >= int(wdt) - 1:
                    px[x, y] = BARK[0]
                else:
                    v = (0.4 if out > 0 else 0.24) - 0.12 * (k / max(1.0, wdt))
                    g = ((y - jy + 2 * math.sin(k / 3.0)) / 6.0) % 1.0
                    if g < 0.15:
                        v -= 0.16
                    px[x, y] = pick(BARK, max(0.0, v), x, y)
        for x in range(max(0, int(lo)), min(W, int(hi) + 1)):
            t = (x - jx) / (ex - jx)
            if t < 0 or t > 1:
                continue
            yt = jy + (ey - jy) * (1 - (1 - t) ** 2) + 2.0 * math.sin(x / 11.0 + seed)
            ridge[x] = yt
            # far roots lose contrast toward their far end (no palette switch, so no seam)
            hazy = False
            for y in range(max(0, int(yt)), H):
                d = y - yt
                lit = 0.95 if d < 1.5 else (0.72 if d < 6 else 0.55 - min(0.32, (d - 6) / 60.0))
                if ex > jx:
                    lit -= 0.12
                g = ((d + 3 * math.sin(x / 9.0 + seed)) / 7.0) % 1.0
                if d > 6 and g < 0.16:
                    lit -= 0.25
                if far:
                    lit = lit * (1 - 0.4 * t) + 0.62 * 0.4 * t
                lit = max(0.0, min(1.0, lit))
                if not hazy and d < 5 and fbm(x / 8.0, y / 5.0, seed) > 0.52:
                    px[x, y] = pick(MOSS, lit, x, y)
                else:
                    px[x, y] = pick(BFAR if hazy else BARK, lit, x, y)
        # trees standing on the ridge, small as shrubs against the trunk
        x = int(lo) + rnd.randint(2, 6)
        while x < hi - 3:
            if x in ridge and rnd.random() < 0.85:
                yt = ridge[x]
                prox = 1 - abs(x - jx) / max(1, abs(ex - jx))
                rr = (rnd.uniform(2.6, 4.2) if far else rnd.uniform(4.0, 7.0)) * (0.55 + 0.6 * (1 - prox))
                ccy = yt - rr * 0.8
                tpal = (FFAR if prox < 0.5 else FMID) if far else FNEAR
                for yy in range(int(ccy), int(yt) + 2):
                    if 0 <= x < W and 0 <= yy < H:
                        px[x, yy] = tpal[0]
                blob(px, W, H, x, ccy, rr, tpal, x * 0.37 + seed)
            x += rnd.randint(4, 9) if far else rnd.randint(6, 12)
        # forest climbing the lower face
        x = int(lo)
        while x < hi:
            if x in ridge:
                depth = 26 if not far else 16
                ybase = min(H - 1, ridge[x] + depth + 6 * vnoise(x / 9.0, seed, 3))
                rr = rnd.uniform(3.0, 5.0) if far else rnd.uniform(5.0, 8.5)
                blob(px, W, H, x, ybase, rr, FFAR if far else FMID, x * 0.53 + seed)
            x += rnd.randint(4, 8)
    draw_buttress(80, 96, -24, 152, True, 2)
    draw_buttress(312, 94, 408, 148, True, 4)
    draw_buttress(118, 128, -34, 186, False, 3)
    draw_buttress(276, 132, 414, 182, False, 6)
    draw_buttress(160, 154, 112, 178, False, 8)
    draw_buttress(234, 156, 278, 180, False, 9)
    # the dark way in at the trunk base (proposal: unlit)
    for y in range(148, 178):
        t = (y - 148) / 30.0
        half = 7 + 8 * math.sqrt(t)
        for x in range(int(196 - half), int(196 + half) + 1):
            px[x, y] = hx('#0b0e11') if abs(x - 196) < half - 1.5 else hx('#23180e')
    # mist band over the root feet
    for x in range(W):
        if vnoise(x / 14.0, 3, 9) < 0.3:
            continue
        y0 = int(171 + 3 * math.sin(x / 17.0) + 2 * vnoise(x / 6.0, 4, 9))
        th = 2 + int(4 * vnoise(x / 10.0, 5, 9))
        for y in range(y0, y0 + th):
            px[x, y] = MIST[2] if y - y0 < th - 1 else MIST[1]
    # forest canopy below, back to front
    rows = [(182, 3.6, FFAR), (190, 5.0, FMID), (201, 6.5, FMID), (214, 8.5, FNEAR)]
    rnd = random.Random(21)
    for (ry, rr0, rmp) in rows:
        x = -6 + rnd.uniform(0, 6)
        while x < W + 8:
            rr = rr0 * rnd.uniform(0.8, 1.25)
            blob(px, W, H, x, ry + rnd.uniform(-2, 2), rr, rmp, x * 0.71 + ry)
            for yy in range(int(ry + rr * 0.6), H):
                for xx in range(int(x - rr * 0.8), int(x + rr * 0.8) + 1):
                    if 0 <= xx < W and 0 <= yy < H and yy > ry + rr * 0.8:
                        px[xx, yy] = rmp[0]
            x += rr * rnd.uniform(1.15, 1.5)
    # root road in front, from the bottom left to the way in
    pts = [(-40, 236, 92), (60, 212, 66), (130, 194, 38), (172, 182, 16), (196, 176, 6)]
    samples = []
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        for k in range(80):
            t = k / 80.0
            tt = t * t * (3 - 2 * t)
            samples.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * tt, a[2] + (b[2] - a[2]) * t))
    cols = {}
    for (cx, cy, th) in samples:
        x = int(round(cx))
        top, bot = cy - th * 0.55, cy + th * 0.45
        if x in cols:
            t0, b0, th0 = cols[x]
            cols[x] = (min(t0, top), max(b0, bot), max(th0, th))
        else:
            cols[x] = (top, bot, th)
    road_top = {}
    for x, (top, bot, th) in cols.items():
        if not (0 <= x < W):
            continue
        road_top[x] = top
        surf = th * 0.42
        for y in range(max(0, int(top)), min(H, int(bot) + 1)):
            d = y - top
            if d < 1:
                px[x, y] = hx('#c6bb2a') if hash2(x, 1, 2) < 0.5 else hx('#908940')
            elif d < surf:
                v = 0.78 - 0.4 * d / surf
                if fbm(x / 18.0, y / 7.0, 12) > 0.38:
                    px[x, y] = MOSS[3] if v > 0.62 else MOSS[2]
                else:
                    px[x, y] = BARK[5] if v > 0.62 else BARK[4]
            elif d < surf + 1:
                px[x, y] = BARK[1]
            else:
                dd = (y - top - surf) / max(1.0, (bot - top - surf))
                v = 0.5 - 0.42 * dd
                g = ((y - top + 2 * math.sin(x / 13.0)) / 5.0) % 1.0
                if g < 0.2:
                    v -= 0.16
                px[x, y] = pick(BARK, max(0.0, v), x, y)
    # two starters for scale (game sprites, back views, majority downscale to stage 1 size)
    for (bx, by) in [(232, 34), (241, 38), (251, 32), (246, 45), (260, 40)]:
        for (dx, dy) in [(0, 0), (1, 1), (2, 0)]:
            px[bx + dx, by + dy] = hx('#23180e')
    painted = set(img.getdata())   # measured before the sprites go in
    sprite_cols = set()
    for fn, th, fx in [('kithflare_back.png', 36, 70), ('cinderhide_back.png', 32, 108)]:
        sp = majority_down(Image.open(SPR + '/' + fn).convert('RGBA'), th)
        sprite_cols |= {c[:3] for c in sp.getdata() if c[3] > 0}
        sw, sh = sp.size
        fy = int(road_top[fx] + (cols[fx][2] * 0.42) * 0.6)
        for xx in range(fx - sw // 2 + 2, fx + sw // 2 - 1):
            for yy in (fy, fy + 1):
                px[xx, yy] = hx('#2f372a')
        img.paste(sp, (fx - sw // 2, fy - sh + 1), sp)
        log(f"BASE starter {fn}: {sw}x{sh} px, feet at y {fy}")
    save2(img, 'base')
    pal = set(load_pal('highbank_title.png')) | set(load_pal('dawn.png'))
    allc = set(img.getdata())
    off = painted - pal
    log(f"BASE colours {len(allc)}; painted {len(painted)}, of which outside highbank_title+dawn: {len(off)} {sorted('#%02x%02x%02x' % c for c in off)}; "
        f"{len(allc - painted)} colours added by the two game sprites (sprite colours {len(sprite_cols)})")
    log(f"BASE trunk {2 * thw(0):.0f} px wide at the top edge of a 384 px frame (about 3 px per tile, so 100 tiles); trees on the roots 5 to 14 px")


# ---------------------------------------------------------------- 4. influence sheet
ROOTC = oramp('#23180e', '#3f2716', '#663f23', '#b06b3d', '#c49b69')
MOSSC = oramp('#44421a', '#6b6f1d', '#908940', '#c6bb2a')


def root_band(img, pts, th0, th1, buried=True, seed=1, round_top=False):
    px = img.load()
    W, H = img.size
    snap = img.copy().load()
    samples = []
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        for k in range(50):
            t = k / 50.0
            samples.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t))
    n = len(samples)
    if round_top:
        # broken paving and bare soil where the root dives back under, at both ends
        rs = random.Random(seed * 7)
        (ax, ay), (bx, by) = samples[0], samples[-1]
        ln = max(1.0, math.hypot(bx - ax, by - ay))
        ux, uy = (bx - ax) / ln, (by - ay) / ln
        for (ex, ey) in ((ax - ux * 4, ay - uy * 4), (bx + ux * 4, by + uy * 4)):
            for yy in range(int(ey - 6), int(ey + 7)):
                for xx in range(int(ex - 11), int(ex + 12)):
                    dx, dy = (xx - ex) / 10.0, (yy - ey) / 5.0
                    rr = dx * dx + dy * dy
                    if rr <= 1.0 + 0.25 * (hash2(xx, yy, seed) - 0.5) and 0 <= xx < W and 0 <= yy < H:
                        px[xx, yy] = hx('#3f2716') if rr > 0.55 or hash2(xx, yy, 3) < 0.3 else hx('#663f23')
            for _ in range(4):
                sx, sy = ex + rs.uniform(-12, 12), ey + rs.uniform(-6, 6)
                for yy in range(int(sy) - 1, int(sy) + 2):
                    for xx in range(int(sx) - 2, int(sx) + 3):
                        if 0 <= xx < W and 0 <= yy < H:
                            px[xx, yy] = hx('#c49b69') if yy == int(sy) - 1 else hx('#8c6545')
    cols = {}
    for i, (cx, cy) in enumerate(samples):
        th = th0 + (th1 - th0) * i / max(1, n - 1)
        if round_top:
            th = th * math.sin(math.pi * (0.04 + 0.92 * i / max(1, n - 1))) ** 0.6
        for x in range(int(cx - 1), int(cx + 2)):
            top, bot = cy - th * 0.5, cy + th * 0.5
            if x in cols:
                cols[x] = (min(cols[x][0], top), max(cols[x][1], bot))
            else:
                cols[x] = (top, bot)
    for x, (top, bot) in cols.items():
        if not (0 <= x < W) or bot - top < 1:
            continue
        lip = 2 + int(3 * vnoise(x / 4.0, 0, seed)) if buried else 0
        for y in range(max(0, int(top)), min(H, int(bot) + 1)):
            if buried and y > bot - lip:
                continue
            d = (y - top) / max(1.0, bot - top)
            if y - top < 1:
                c = ROOTC[4]
            elif d < 0.38:
                v = 0.85 - d
                c = pick(MOSSC, v, x, y) if fbm(x / 7.0, y / 3.0, seed) > 0.5 else pick(ROOTC, v, x, y)
            else:
                v = 0.55 - 0.5 * d
                if ((y - top + 2 * math.sin(x / 9.0)) / 4.0) % 1.0 < 0.2:
                    v -= 0.15
                c = pick(ROOTC, max(0.0, v), x, y)
            px[x, y] = c
        if buried:
            yb = int(bot) - lip + 1
            if 0 <= yb < H:
                px[x, yb] = hx('#3f2716') if hash2(x, 2, seed) < 0.6 else snap[x, yb]
        else:
            for yb in (int(top) - 1, int(bot) + 1):
                if 0 <= yb < H:
                    px[x, yb] = hx('#3f2716')
            yb = int(top) - 2
            if 0 <= yb < H and hash2(x, 5, seed) < 0.5:
                px[x, yb] = hx('#e6c697')
            if round_top:
                # cast shadow on the paving south of the hump, two rows, the second broken
                for k in (2, 3):
                    yb = int(bot) + k
                    if 0 <= yb < H and (k == 2 or (x + yb) % 2 == 0):
                        px[x, yb] = hx('#3f2716')
    if round_top:
        # cracks run out of the paving at both ends of each hump, where the root pushed the stones up
        rnd = random.Random(seed * 13)
        for (ex, ey) in (samples[0], samples[-1]):
            for _ in range(3):
                ang = rnd.uniform(0, 2 * math.pi)
                ln = rnd.randint(5, 10)
                cx, cy = ex, ey
                for s in range(ln):
                    ang += rnd.uniform(-0.5, 0.5)
                    cx += math.cos(ang)
                    cy += math.sin(ang) * 0.6
                    if 0 <= int(cx) < W and 0 <= int(cy) < H:
                        px[int(cx), int(cy)] = hx('#3f2716')


def leaf(px, x, y, kind=0):
    body = [hx('#b8793e'), hx('#dca562'), hx('#8c6545')][kind % 3]
    for (dx, dy) in [(1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1), (3, 1), (4, 1), (1, 2), (2, 2), (3, 2)]:
        px[x + dx, y + dy] = body
    px[x + 1, y + 1] = hx('#7c4a26')
    px[x + 2, y + 1] = hx('#7c4a26')
    px[x + 5, y + 2] = hx('#7c4a26')


def tuft(px, x, y):
    for (dx, dy) in [(0, 0), (1, -1), (-1, -1), (0, -2), (1, 1)]:
        px[x + dx, y + dy] = hx('#f5d9a8')
    px[x, y - 1] = hx('#e6c697')


def build_influence():
    VW, VH = 256, 144
    # 1 Tower Rise west lane: the Tower's root comes in from the west at full girth
    a = capture1x('05c_rise_side_west_col2_row3.png')
    root_band(a, [(-6, 168), (30, 170), (62, 178), (92, 192), (108, 206), (116, 218)], 38, 30, True, 3)
    pa = a.load()
    leaf(pa, 40, 126, 0)
    leaf(pa, 150, 150, 1)
    leaf(pa, 70, 140, 2)
    leaf(pa, 22, 104, 1)
    for dx in range(4):
        pa[24 + dx, 112] = hx('#4f6858')
    tuft(pa, 130, 120)
    tuft(pa, 58, 96)
    A = a.crop((0, 72, 256, 216))
    # 2 Street Crossroads: a root heaves the paving, surfacing twice
    b = capture1x('06_street_wayline.png')
    for seg in ([(112, 172), (140, 158), (168, 150), (196, 146)], [(222, 132), (248, 120), (276, 114), (304, 110)]):
        root_band(b, seg, 18, 16, False, 5, round_top=True)
    pb = b.load()
    leaf(pb, 150, 112, 0)
    leaf(pb, 238, 150, 2)
    leaf(pb, 96, 92, 1)
    tuft(pb, 270, 140)
    tuft(pb, 205, 160)
    B = b.crop((52, 36, 308, 180))
    # 3 Ferry Ward: roots come down the wall and drink; one rootlet stopped short of the Mouth
    c = capture1x('07_ferry_ward_quiet_wayline.png')
    pc = c.load()
    for (xs, wob, th0) in [(30, 0.0, 7), (236, 2.1, 6)]:
        for y in range(36, 152):
            t = (y - 36) / 116.0
            th = max(2, int(th0 * (1 - 0.6 * t)))
            x = int(xs + 5 * math.sin(y / 15.0 + wob))
            for dx in range(th):
                pc[x + dx, y] = ROOTC[4] if dx == 0 else (ROOTC[3] if dx < th // 2 else (ROOTC[2] if dx < th - 1 else ROOTC[1]))
            pc[x + th, y] = hx('#3f2716')
            if y % 17 == int(wob * 5) % 17:
                for k in range(1, 7):
                    pc[x - k, y + k // 2] = ROOTC[2]
                    pc[x + th + k, y + k // 2] = ROOTC[2]
        xe = int(xs + 5 * math.sin(152 / 15.0 + wob))
        for fx in (-4, 0, 4):
            for y in range(150, 160):
                pc[int(xe + fx * (y - 148) * 0.25 + 1), y] = ROOTC[1]
            pc[int(xe + fx * 3 + 1) - 1, 161] = hx('#6fb5a6')
            pc[int(xe + fx * 3 + 1) + 1, 161] = hx('#6fb5a6')
    # the rootlet toward the Mouth (ring centre about 191,72, outer radius about 22)
    for i in range(100):
        t = i / 99.0
        x = int(112 + 52 * t)
        y = int(40 + 26 * t - 8 * math.sin(t * math.pi))
        th = 4 if t < 0.35 else (3 if t < 0.65 else (2 if t < 0.85 else 1))
        col = ROOTC[3] if t < 0.8 else hx('#9f946d')
        for dy in range(th):
            pc[x, y + dy] = col if dy < th - 1 or th == 1 else ROOTC[1]
    C = c.crop((0, 36, 256, 180))
    # 4 summer evening: the tree's shade reaches town before sunset
    dimg = capture1x('04_rise_side_east_col23.png')
    pal = list(set(dimg.getdata()))
    cache = {}
    pd = dimg.load()

    def shade(x, y):
        edge = 205 - 0.3 * y
        sc = 14 * abs(math.sin((y + 6) / 13.0)) + 6 * vnoise(y / 4.0, 2, 4)
        inside = x < edge + sc
        if inside and x > edge + sc - 26:
            # leaf gaps let light through near the edge
            if vnoise(x / 3.0, y / 3.0, 77) > 0.74:
                return False
        return inside
    for y in range(dimg.height):
        for x in range(dimg.width):
            c0 = pd[x, y]
            key = ('s' if shade(x, y) else 'w', c0)
            if key not in cache:
                if key[0] == 's':
                    cache[key] = nearest((int(c0[0] * 0.52), int(c0[1] * 0.6), int(c0[2] * 0.8)), pal)
                else:
                    cache[key] = nearest((min(255, int(c0[0] * 1.06 + 10)), int(c0[1] * 0.98), int(c0[2] * 0.84)), pal)
            pd[x, y] = cache[key]
    D = dimg.crop((52, 36, 308, 180))
    G, CAPH = 6, 22
    SW = G * 3 + VW * 2
    SH = 16 + G * 3 + (VH + CAPH) * 2
    sheet = Image.new('RGB', (SW, SH), hx('#1d2925'))
    text1(sheet, (G, 4), 'THE GREAT TREE IN TOWN (PROPOSALS, PAINTED OVER GAME CAPTURES)', hx('#f5d9a8'))
    caps = [
        (A, "1 TOWER RISE: THE TOWER'S ROOT", 'COMES IN FROM THE WEST, FULL GIRTH'),
        (B, '2 CROSSROADS: A ROOT HEAVES THE', 'PAVING. LEAVES AND SEED TUFTS DRIFT'),
        (C, '3 FERRY WARD: ROOTS DRINK THE RIVER.', 'ONE STOPPED SHORT OF THE MOUTH'),
        (D, "4 SUMMER EVENINGS: THE TREE'S SHADE", 'REACHES TOWN BEFORE SUNSET'),
    ]
    for i, (im, l1, l2) in enumerate(caps):
        cx = G + (i % 2) * (VW + G)
        cy = 16 + G + (i // 2) * (VH + CAPH + G)
        sheet.paste(im, (cx, cy))
        text1(sheet, (cx, cy + VH + 3), l1, hx('#e6c697'))
        text1(sheet, (cx, cy + VH + 12), l2, hx('#c7a378'))
    save2(sheet, 'influence')


# ---------------------------------------------------------------- 5. top-down map
def build_map():
    W, H = 500, 300
    img = Image.new('RGB', (W, H), hx('#1d2925'))
    px = img.load()
    X0, Y0, K = -600.0, -660.0, 0.36
    MX0, MY0, MW, MH = 4, 16, 296, 272

    def M(x, y):
        return (MX0 + (x - X0) * K, MY0 + (y - Y0) * K)

    def river_c(x):
        return 42 + 9 * math.sin(x / 130.0) + 4 * math.sin(x / 47.0)

    def south_edge(x):
        if x < -130:
            return 32
        if x < -50:
            return 32 + (x + 130) / 80.0 * (4 - 32)
        if x < -12:
            return 4
        if x < 16:
            return -9
        if x < 45:
            return -9 + (x - 16) / 29.0 * (-22 + 9)
        if x < 140:
            return -22 + (x - 45) / 95.0 * (-70 + 22)
        return -70 + (x - 140) / 120.0 * (-50)

    def forest(x, y):
        e = ((x + 210) / 600.0) ** 2 + ((y + 300) / 420.0) ** 2
        if e > 1 + 0.25 * (fbm(x / 80.0, y / 80.0, 7) - 0.5):
            return False
        return y < south_edge(x) + 6 * (vnoise(x / 30.0, 0, 8) - 0.5)
    ccx = TREE[0] + T_CROWN_OFF * math.cos(math.radians(27.6))
    ccy = TREE[1] - T_CROWN_OFF * math.sin(math.radians(27.6))
    for j in range(MH):
        for i in range(MW):
            x = X0 + i / K
            y = Y0 + j / K
            rc = river_c(x)
            if abs(y - rc) < 7:
                c = hx('#2d9e9f') if abs(y - rc) < 5.5 else hx('#12837f')
            elif forest(x, y):
                h = hash2(i, j, 1)
                if math.hypot(x - ccx, y - ccy) < 220 + 10 * (vnoise(i / 6.0, j / 6.0, 3) - 0.5):
                    c = hx('#33524e') if h < 0.22 else hx('#43665a')
                else:
                    c = hx('#43665a') if h < 0.22 else hx('#61785c')
            else:
                c = hx('#ccb290') if hash2(i, j, 2) < 0.08 else hx('#e6c697')
            px[MX0 + i, MY0 + j] = c
    d = ImageDraw.Draw(img)
    for a in range(0, 360 * 4):
        th = math.radians(a / 4.0)
        X, Y = M(ccx + 220 * math.cos(th), ccy + 220 * math.sin(th))
        if a % 8 < 4 and MX0 <= X < MX0 + MW and MY0 <= Y < MY0 + MH:
            px[int(X), int(Y)] = hx('#c7a378')
    tx, ty = M(*TREE)
    # trunk with its buttress roots (spokes)
    for j in range(-50, 51):
        for i in range(-50, 51):
            r = math.hypot(i, j)
            a = math.atan2(j, i)
            spoke = abs(math.cos(4 * a + 0.3)) ** 10
            if 50 * K < r <= 130 * K * (0.4 + 0.6 * spoke) and spoke > 0.25:
                px[int(tx + i), int(ty + j)] = hx('#8c6545')
            elif r <= 50 * K:
                px[int(tx + i), int(ty + j)] = hx('#663f23') if r < 50 * K - 1.2 else hx('#3f2716')

    def path(points, surf_from=None, width=2, col='#7c4a26', dash='#a37a32'):
        segs = []
        for i in range(len(points) - 1):
            a, b = points[i], points[i + 1]
            n = int(math.hypot(b[0] - a[0], b[1] - a[1]) / 2) + 1
            for k in range(n):
                t = k / n
                segs.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t))
        for idx, (x, y) in enumerate(segs):
            X, Y = M(x, y)
            surf = surf_from is not None and idx >= surf_from * len(segs)
            if surf:
                for dx in range(width):
                    for dy in range(width):
                        px[int(X) + dx, int(Y) + dy] = hx(col)
            elif (idx // 3) % 2 == 0:
                px[int(X), int(Y)] = hx(dash)
    path([TREE, (-175, -190), (-150, -100), (-110, -40), (-62, -6), (-30, -1), (-12, 1), (-3, 0)], 0.82, 2)
    path([(-110, -40), (-70, 6), (-34, 18), (-5, 16), (8, 22), (12, 34), (14, 40)], 0.45, 1)
    path([TREE, (-110, -260), (-20, -120), (40, -40), (30, 6), (25, 21)], 0.9, 1)
    path([TREE, (-260, -150), (-310, -40), (-330, 34)], 0.88, 1)
    path([TREE, (-380, -300), (-560, -330)], None, 1)
    path([TREE, (-260, -460), (-300, -640)], None, 1)
    path([TREE, (-150, -480), (-110, -650)], None, 1)
    path([TREE, (-20, -360), (160, -420)], None, 1)
    path([TREE, (-420, -150), (-590, -60)], None, 1)
    path([TREE, (60, -230), (200, -160)], None, 1)
    for (x0, y0, x1, y1) in [(-12, -7, 14, 7), (-46, 7, 10, 23), (10, 8, 40, 22), (-6, 23, 28, 36)]:
        a0, b0 = M(x0, y0)
        a1, b1 = M(x1, y1)
        d.rectangle([a0, b0, a1, b1], fill=hx('#f5d9a8'), outline=hx('#663f23'))
    Tx, Ty = M(0, 0)
    d.rectangle([Tx - 1, Ty - 1, Tx + 1, Ty + 1], fill=hx('#7c4a26'))
    px[int(Tx), int(Ty) - 2] = hx('#fbd490')
    for (cam, axis, col) in [((0, 50), -27.6, '#fbd490'), ((0, 46), -15.7, '#f5d9a8')]:
        for side in (-35.4, 35.4):
            a = math.radians(axis + side)
            for k in range(6, 420, 3):
                X, Y = M(cam[0] + k * math.sin(a), cam[1] - k * math.cos(a))
                if MX0 <= X < MX0 + MW and MY0 <= Y < MY0 + MH and (k // 3) % 4 == 0:
                    px[int(X), int(Y)] = hx(col)
    cxm, cym = M(0, 50)
    d.rectangle([cxm - 1, cym - 1, cxm + 1, cym + 1], fill=hx('#fbd490'))
    for k in range(0, 100):
        t = k / 100.0
        X, Y = M(TREE[0] * t, TREE[1] * t)
        if k % 4 < 2 and t > 0.18:
            px[int(X) + 1, int(Y)] = hx('#f5d9a8')
    text1(img, (4, 3), 'THE GREAT TREE AND HIGHBANK, TOP DOWN (PROPOSAL). NORTH IS UP.', hx('#f5d9a8'))
    text1(img, (int(tx) - 30, int(ty) - 58), 'THE GREAT TREE', hx('#f5d9a8'), FONT8, hx('#1d2925'))
    text1(img, (int(M(-470, -40)[0]), int(M(-470, -40)[1])), 'CROWN EDGE, 440 ACROSS', hx('#f5d9a8'), FONT8, hx('#1d2925'))
    lx0, ly0 = M(TREE[0] * 0.45, TREE[1] * 0.45)
    text1(img, (int(lx0) + 4, int(ly0) - 4), '340 TILES', hx('#f5d9a8'), FONT8, hx('#1d2925'))
    text1(img, (int(Tx) + 6, int(Ty) + 22), 'HIGHBANK', hx('#3f2716'))
    rx, ry = M(-330, 34)
    d.rectangle([rx - 1, ry - 1, rx + 1, ry + 1], fill=hx('#3f2716'))
    text1(img, (int(rx) - 20, int(ry) - 12), 'ROOTBANK WARREN?', hx('#3f2716'))
    text1(img, (int(M(-590, 62)[0]), int(M(-590, 62)[1])), 'RIVER', hx('#3f2716'))
    text1(img, (int(M(-470, -560)[0]), int(M(-470, -560)[1])), 'ITS FOREST', hx('#e6c697'), FONT8, hx('#1d2925'))
    cyl = int(M(0, -250)[1])
    for i, s in enumerate(['TITLE AND VISTA', 'CAMERAS (DOTTED)', 'LOOK NORTH']):
        text1(img, (MX0 + MW - 92, cyl + i * 9), s, hx('#f5d9a8'), FONT8, hx('#1d2925'))
    sbx, sby = MX0 + 8, MY0 + 10
    d.rectangle([sbx, sby, sbx + 100 * K, sby + 2], fill=hx('#f5d9a8'))
    d.rectangle([sbx + 100 * K, sby, sbx + 200 * K, sby + 2], fill=hx('#3f2716'))
    for t in (0, 100, 200):
        d.line([(sbx + t * K, sby - 2), (sbx + t * K, sby + 4)], fill=hx('#3f2716'))
    text1(img, (sbx, sby + 5), '0    100   200 TILES', hx('#3f2716'))
    lx = MX0 + MW + 6
    text1(img, (lx, 16), 'SOLID ROOT: ABOVE GROUND', hx('#c49b69'))
    text1(img, (lx, 25), 'DOTTED ROOT: UNDER IT', hx('#a37a32'))
    IX0, IY0, IK = lx, 40, 1.65
    XA, YA, XB, YB = -56, -14, 54, 50

    def N(x, y):
        return (IX0 + (x - XA) * IK, IY0 + (y - YA) * IK)
    for j in range(int((YB - YA) * IK)):
        for i in range(int((XB - XA) * IK)):
            x, y = XA + i / IK, YA + j / IK
            if abs(y - river_c(x)) < 7:
                c = hx('#2d9e9f') if abs(y - river_c(x)) < 5.5 else hx('#12837f')
            elif forest(x, y):
                c = hx('#43665a') if hash2(i, j, 5) < 0.25 else hx('#61785c')
            else:
                c = hx('#e6c697')
            px[IX0 + i, IY0 + j] = c
    for (x0, y0, x1, y1, name, lxo) in [(-12, -7, 14, 7, 'RISE', 8), (-46, 7, 10, 23, 'STREET', 2), (10, 8, 40, 22, 'EAST Q', 2), (-6, 23, 28, 36, 'FERRY', 2)]:
        a0, b0 = N(x0, y0)
        a1, b1 = N(x1, y1)
        d.rectangle([a0, b0, a1, b1], fill=hx('#f5d9a8'), outline=hx('#663f23'))
        text1(img, (int(a1) - int(FONT8.getlength(name)) - 3, int(b0) + 2), name, hx('#8c6545'))
    d.line([N(-56, -4), N(-34, -2), N(-12, 0), N(-2, 0)], fill=hx('#7c4a26'), width=3)
    text1(img, (int(N(-55, -12)[0]), int(N(-55, -12)[1])), 'FROM THE TREE', hx('#3f2716'))
    Tx2, Ty2 = N(0, 0)
    d.rectangle([Tx2 - 2, Ty2 - 2, Tx2 + 2, Ty2 + 2], fill=hx('#7c4a26'))
    px[int(Tx2), int(Ty2) - 4] = hx('#fbd490')
    d.line([N(-6, 14), N(5, 19)], fill=hx('#7c4a26'), width=2)
    for xx in range(-40, -18, 4):
        d.line([N(xx, 22), N(xx + 1, 24)], fill=hx('#7c4a26'), width=1)
    d.line([N(14, 21), N(36, 21)], fill=hx('#7c4a26'), width=2)
    d.line([N(4, 30), N(4, 37)], fill=hx('#7c4a26'), width=1)
    d.line([N(24, 30), N(24, 37)], fill=hx('#7c4a26'), width=1)
    d.line([N(12, 28), N(15, 30)], fill=hx('#9f946d'), width=1)
    mx, my = N(19, 32)
    d.ellipse([mx - 2, my - 2, mx + 2, my + 2], fill=hx('#0b0e11'))
    sx2, sy2 = N(-34, 18)
    d.ellipse([sx2 - 2, sy2 - 2, sx2 + 2, sy2 + 2], outline=hx('#7c4a26'))
    marks = [(1, (-24, -1)), (2, (-34, 18)), (3, (-2, 16)), (4, (-26, 24)), (5, (8, 32)), (6, (26, 21))]
    for (nn, (x, y)) in marks:
        X, Y = N(x, y)
        text1(img, (int(X) + 2, int(Y) - 9), str(nn), hx('#ffffff'), FONT8, hx('#0b0e11'))
    ly = IY0 + int((YB - YA) * IK) + 4
    items = ["1 TOWER'S ROOT, RISE WEST LANE", '2 SHRINE ON A ROOT KNUCKLE', '3 CROSSROADS ROOT HUMP',
             '4 BLUFF FINGER ROOTS', '5 FERRY WARD ROOTS; ONE ROOTLET', '  STOPS SHORT OF THE MOUTH', '6 EAST QUARTER FENCE ROOT',
             '', 'INSET: HIGHBANK, 4.6X LARGER', 'RIVER WIDTH IS A PROPOSAL']
    for i, s in enumerate(items):
        text1(img, (lx, ly + i * 9), s, hx('#e6c697'))
    save2(img, 'map')


if __name__ == '__main__':
    import sys
    only = sys.argv[1:]   # e.g. "base" to rebuild one mock while iterating; the report is only written on a full run
    if only:
        for name in only:
            globals()['build_' + name]()
        print("\n".join(REPORT))
    else:
        build_title()
        build_vista()
        build_base()
        build_influence()
        build_map()
        with open(OUT + '/mock_report.txt', 'w') as fh:
            fh.write("\n".join(REPORT) + "\n")
