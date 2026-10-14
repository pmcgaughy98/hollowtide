"""Kithflare built by hand as a 3D model and rendered to its eight sprite views (Claude, 2026-10-13; Preston: "How about
trying to build a hollowtide creature", after the GBA canine). The sprites-in-3D workshop's second option
(docs/design/sprite3d-workshop-2026-10-12.md): a model made to match the drawn sprite, for free, instead of a paid
generator that followed a guessed prompt.

The model is about 70 rounded shapes (ellipsoids) placed from the drawn views: an upright gecko, a big round head,
a gold eye high on each side, a smile line, a cream throat and belly, short bent legs with splayed toes, an ember
held in the right hand with a flame on it, and a striped tail curling into a spiral with a flame tip. The stripes,
the belly, the eye and the mouth are painted onto the 3D surface, so they sit in the same place from every angle.

Each view is ray cast (orthographic, 18 degrees from above, light from the upper left of the screen), 3x
supersampled, and each pixel takes the colour most of its subpixels show, so no colours are mixed. Shading only
ever picks from Kithflare's own colours (measured from assets/sprites/arena/kithflare/*.png). Then the drawn set's
pixel rules: a black 1-pixel outline, black lines where one part stands in front of another, no stray pixels.

Writes docs/design/sprite3d-workshop-2026-10-12/model_kithflare/: views_128/ and views_dungeon/ (the eight
directions at the two sizes the game uses), contact sheets with the drawn views underneath, and scores.json.
Nothing in assets/ is touched.
    python tools/art/kithflare_model.py
"""
import json
import math
import os
import sys
import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DRAWN = os.path.join(ROOT, "assets", "sprites", "arena", "kithflare")
OUT = os.path.join(ROOT, "docs", "design", "sprite3d-workshop-2026-10-12", "model_kithflare")
DIRS = ["e", "ne", "n", "nw", "w", "sw", "s", "se"]
# camera azimuth, measured from the direction the creature faces: "s" is straight in front of it
AZ = {"s": 0, "se": -45, "e": -90, "ne": -135, "n": 180, "nw": 135, "w": 90, "sw": 45}
ELEV = math.radians(18)


def hexc(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


# ---- colours: all from Kithflare's own sprites ---------------------------------------------------------------------
OUTLINE = "#080000"
RAMPS = {   # dark to light
    "body": ["#4f2a14", "#7b3f14", "#914f21", "#ae642c", "#c68131", "#d9984a", "#ea9549", "#f9b34e"],
    "stripe": ["#381e0a", "#4f2a14", "#5b3317", "#7b3f14", "#914f21", "#a24f12", "#ae642c", "#c68131"],
    "belly": ["#ae642c", "#c68131", "#d9984a", "#f0a54b", "#f6c38d", "#f6c38d", "#f7d7a9", "#f7d7a9"],
    "iris": ["#7b3f14", "#a24f12", "#c8530c", "#d86912", "#de6e12", "#f0a54b", "#f9b34e", "#f9b34e"],
    "ember": ["#190700", "#190700", "#381e0a", "#381e0a", "#452108", "#452108", "#4f2a14", "#5b3317"],
    "flame": ["#d05911", "#d86912", "#de6e12", "#f0a54b", "#f9b34e", "#fddd45", "#fddd45", "#fddd45"],
}
EYE_WHITE = "#f7ebe8"
PAL = [None, OUTLINE, EYE_WHITE]
for ramp in RAMPS.values():
    for c in ramp:
        if c not in PAL:
            PAL.append(c)
IDX = {c: i for i, c in enumerate(PAL) if c}


# ---- shapes ---------------------------------------------------------------------------------------------------------
def frame_along(axis):
    a = np.asarray(axis, float)
    a /= np.linalg.norm(a)
    ref = np.array([0.0, 0.0, 1.0]) if abs(a[2]) < 0.9 else np.array([1.0, 0.0, 0.0])
    b = np.cross(ref, a)
    b /= np.linalg.norm(b)
    return np.stack([a, b, np.cross(a, b)], axis=1)   # columns: local x (along the axis), y, z


prims = []


def blob(c, r, mat="body", R=None, **tag):
    prims.append({"c": np.array(c, float), "r": np.array(r, float), "R": np.eye(3) if R is None else R,
                  "mat": mat, **tag})


def limb(a, b, r, mat="body", **tag):
    a, b = np.array(a, float), np.array(b, float)
    half = np.linalg.norm(b - a) / 2
    blob((a + b) / 2, (half + 0.45 * r, r, r), mat, frame_along(b - a), **tag)


EYE_AXES = {}


def build():
    """Model units are pixels of the 128 set before the fit; x forward, y the creature's left, z up, feet on z = 0."""
    # body: a pear leaning slightly forward, a neck, a big round head with a blunt snout
    blob((-1, 0, 19), (10.5, 12, 12.5), belly=True, stripes="torso")
    blob((3, 0, 28.5), (9.5, 10.5, 10), belly=True, stripes="torso")
    blob((6.5, 0, 36.5), (7.5, 8.5, 7.5), belly=True, stripes="torso")
    blob((5, 0, 20), (6, 9, 12), "belly")              # pass 2: the cream strip as shapes, not a rule
    blob((8.5, 0, 29), (5.5, 8, 8), "belly")
    blob((11, 0, 37.5), (5, 7, 5.5), "belly")
    blob((11, 0, 48), (14.5, 13.5, 10.5), head=True, stripes="head", belly=True)    # pass 3: one long oval head
    blob((23.5, 0, 46), (8.5, 9.5, 6.8), head=True, belly=True)                     # pass 3: a snout narrower than the skull
    for s in (1, -1):    # pass 3: eyes high and forward, inside the head's outline from the front
        axis = np.array([0.62, 0.72 * s, 0.32])
        axis /= np.linalg.norm(axis)
        blob((16.5, 8.2 * s, 54.5), (5.8, 5.8, 5.8), "eye", eye=s)
        EYE_AXES[s] = axis
    # legs: short, bent, toes splayed forward
    for s in (1, -1):
        hip, knee, ankle = (-1, 8 * s, 13), (5, 10 * s, 7.5), (0, 9 * s, 2.8)
        limb(hip, knee, 4.6, stripes="leg")
        limb(knee, ankle, 3.0, stripes="leg")
        blob((4, 9.5 * s, 1.5), (5.5, 3.2, 1.6), R=frame_along((1, 0.25 * s, 0)))
        for k in (-1, 0, 1):
            blob((9.5, 9.5 * s + 2.6 * k, 0.9), (2.3, 0.9, 0.9), R=frame_along((1, 0.35 * k + 0.2 * s, 0)))
    # arms: the right hand (y < 0) holds the ember forward at chest height, the left hangs
    limb((6, -10, 30), (8, -14.5, 23.5), 2.8)
    limb((8, -14.5, 23.5), (16, -11.5, 25.5), 2.4)
    blob((16.5, -11, 25.5), (2.6, 2.6, 2.6))
    limb((6, 10, 30), (8, 14, 23), 2.8)
    limb((8, 14, 23), (12.5, 13, 18.5), 2.4)
    blob((13, 12.5, 18), (2.5, 2.5, 2.5))
    blob((19.5, -10.5, 27.5), (4.2, 4.2, 4.0), "ember")
    blob((19.5, -10.5, 32.8), (3.8, 3.8, 4.4), "flame", emissive=True)      # pass 2: a teardrop, not a bar
    blob((19.7, -10.5, 38.0), (2.0, 2.0, 2.8), "flame", emissive=True, tip=True)
    # tail: a sweep low behind, then a spiral standing a little off to the left, a flame at the tip
    alpha = math.radians(25)
    h = np.array([math.cos(alpha), -math.sin(alpha), 0.0])       # in-plane horizontal, pointing forward
    C = -31 * h + np.array([0, 0, 27.0])
    R0, turns = 16.0, 420.0
    start = C + R0 * np.array([0, 0, -1.0])
    pts = []
    base, ctrl = np.array([-9, 0, 13.5]), np.array([-22, 4, 5.0])
    for i in range(10):
        t = i / 10
        pts.append((1 - t) ** 2 * base + 2 * (1 - t) * t * ctrl + t * t * start)
    for i in range(36):
        f = i / 35
        th = math.radians(-90 - turns * f)
        r = R0 + (3.5 - R0) * f
        pts.append(C + r * (math.cos(th) * h + math.sin(th) * np.array([0, 0, 1.0])))
    pts = np.array(pts)
    seglen = np.linalg.norm(np.diff(pts, axis=0), axis=1)
    along = np.concatenate([[0], np.cumsum(seglen)])
    for i, p in enumerate(pts):
        f = along[i] / along[-1]
        blob(p, (6.2 - 4.4 * f,) * 3, stripes="tail", along=along[i])
    tip = pts[-1] + 0.6 * (pts[-1] - pts[-2])
    blob(tip, (2.4, 2.4, 3.6), "flame", emissive=True)


# ---- the camera and the ray cast ------------------------------------------------------------------------------------
def camera(view):
    az = math.radians(AZ[view])
    to_cam = np.array([math.cos(ELEV) * math.cos(az), math.cos(ELEV) * math.sin(az), math.sin(ELEV)])
    d = -to_cam
    r = np.cross(d, [0, 0, 1.0])
    r /= np.linalg.norm(r)
    u = np.cross(r, d)
    return d, r, u


def cast(view, size, scale, origin, ss):
    """Returns per-subpixel palette index (0 empty) and depth, at size*ss."""
    W, H = size
    d, r, u = camera(view)
    L = -0.5 * r + 0.75 * u - 0.45 * d
    L /= np.linalg.norm(L)
    Hh = L - d
    Hh /= np.linalg.norm(Hh)
    ys, xs = np.mgrid[0:H * ss, 0:W * ss]
    sx = ((xs + 0.5) / ss - origin[0]) / scale
    sy = (origin[1] - (ys + 0.5) / ss) / scale
    O = sx[..., None] * r + sy[..., None] * u - 400 * d
    O = O.reshape(-1, 3)
    P = len(O)
    tbest = np.full(P, np.inf)
    who = np.full(P, -1)
    for k, pr in enumerate(prims):
        Rm, c, rad = pr["R"], pr["c"], pr["r"]
        qo = ((O - c) @ Rm) / rad
        qd = (d @ Rm) / rad
        a = qd @ qd
        b = 2 * (qo @ qd)
        cc = (qo * qo).sum(1) - 1
        disc = b * b - 4 * a * cc
        ok = disc >= 0
        t = np.full(P, np.inf)
        t[ok] = (-b[ok] - np.sqrt(disc[ok])) / (2 * a)
        better = t < tbest
        tbest[better] = t[better]
        who[better] = k
    out = np.zeros(P, int)
    hit = who >= 0
    Pw = O + tbest[:, None] * d
    for k in np.unique(who[hit]):
        m = who == k
        pr = prims[k]
        p = Pw[m]
        loc = (p - pr["c"]) @ pr["R"]
        n = (loc / pr["r"] ** 2) @ pr["R"].T
        n /= np.linalg.norm(n, axis=1, keepdims=True)
        lam = np.clip(n @ L, 0, 1)
        spec = n @ Hh
        level = np.clip(np.round((0.42 + 0.5 * lam) * 7), 0, 6).astype(int)   # pass 2: two shades lighter, like the drawn body
        level[spec > 0.97] = 7
        mat = np.full(len(p), pr["mat"], object)
        if pr.get("belly"):
            front = np.zeros(len(p), bool)
            if pr.get("head"):
                front = (n[:, 2] < -0.05) & (p[:, 2] < 46.5)                # the cream under the jaw
            mat[front] = "belly"
        st = pr.get("stripes")
        if st == "torso":
            band = (n[:, 0] < 0.1) & (((p[:, 2] + 2) / 8.0) % 1.0 < 0.22)
            mat[band & (mat == "body")] = "stripe"
        elif st == "head":
            band = (n[:, 2] > 0.5) & (((p[:, 0] + 3) / 7.0) % 1.0 < 0.25)
            mat[band & (mat == "body")] = "stripe"
        elif st == "leg":
            mat[((p[:, 2] / 7.0) % 1.0 < 0.2) & (mat == "body")] = "stripe"
        elif st == "tail" and (pr["along"] / 11.0) % 1.0 < 0.25:
            mat[mat == "body"] = "stripe"
        idx = np.zeros(len(p), int)
        for name in ("body", "stripe", "belly", "ember"):
            sel = mat == name
            ramp = RAMPS[name]
            idx[sel] = [IDX[ramp[v]] for v in level[sel]]
        if pr["mat"] == "flame":
            toward = np.clip(n @ (-d), 0, 1)
            lv = np.clip(np.round(1 + 5 * toward ** 2), 0, 7).astype(int)   # yellow only in the core
            if pr.get("tip"):
                lv = np.minimum(lv, 3)
            idx[:] = [IDX[RAMPS["flame"][v]] for v in lv]
        if pr["mat"] == "eye":
            ax = EYE_AXES[pr["eye"]]
            cosang = n @ ax
            iris = [IDX[RAMPS["iris"][v]] for v in level]
            idx[:] = [IDX[RAMPS["body"][v]] for v in level]          # the lid
            zone = cosang > 0.62
            idx[zone] = IDX[OUTLINE]                                   # the dark ring
            zone2 = cosang > 0.72
            idx[zone2] = np.array(iris)[zone2]
            idx[cosang > 0.95] = IDX[OUTLINE]                          # the pupil
            idx[(spec > 0.975) & zone2] = IDX[EYE_WHITE]               # the glint
        if pr.get("head"):                                             # the smile, painted on the head's sides
            zm = 43.5 + 0.15 * (32 - p[:, 0])
            line = (np.abs(p[:, 1]) > 3) & (p[:, 0] > 11) & (p[:, 0] < 32.5) & (np.abs(p[:, 2] - zm) < 0.8)
            idx[line] = IDX[OUTLINE]
        out[m] = idx
    return out.reshape(H * ss, W * ss), np.where(hit, tbest, np.inf).reshape(H * ss, W * ss)


def down(sub, depth, size, ss, keep=0.5):
    W, H = size
    s = sub.reshape(H, ss, W, ss).transpose(0, 2, 1, 3).reshape(H, W, ss * ss)
    z = depth.reshape(H, ss, W, ss).transpose(0, 2, 1, 3).reshape(H, W, ss * ss)
    img = np.zeros((H, W), int)
    dep = np.full((H, W), np.inf)
    for y in range(H):
        for x in range(W):
            v = s[y, x]
            on = v > 0
            if on.mean() < keep:
                continue
            ids, cnt = np.unique(v[on], return_counts=True)
            img[y, x] = ids[cnt.argmax()]
            dep[y, x] = z[y, x][on].mean()
    return img, dep


SHADE_OF = {}
for _ramp in RAMPS.values():
    for _k, _c in enumerate(_ramp):
        SHADE_OF.setdefault(IDX[_c], (_ramp, _k))


def selout(img):
    """Hollowtide's rule for the shrunk sets (tools/arena/selout.py): at dungeon size a black line eats the sprite, so
    each edge pixel takes a dark shade of its own colour instead."""
    H, W = img.shape
    out = img.copy()
    for y in range(H):
        for x in range(W):
            v = img[y, x]
            if v == 0 or v not in SHADE_OF:
                continue
            if any(not (0 <= yy < H and 0 <= xx < W) or img[yy, xx] == 0 for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))):
                ramp, k = SHADE_OF[v]
                out[y, x] = IDX[ramp[max(0, k - 4)]]
    return out


def passes(img, dep, jump, sel=False):
    H, W = img.shape
    if sel:
        return selout(img)
    out = img.copy()
    solid = img > 0
    for y in range(H):
        for x in range(W):
            if not solid[y, x]:
                continue
            for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if not (0 <= yy < H and 0 <= xx < W) or not solid[yy, xx]:
                    out[y, x] = IDX[OUTLINE]                       # the silhouette's 1-pixel black line
                    break
                if dep[yy, xx] < dep[y, x] - jump:
                    out[y, x] = IDX[OUTLINE]                       # something stands in front: a contour line
                    break
    clean = out.copy()
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            v = out[y, x]
            if v == 0 or v == IDX[OUTLINE] or v == IDX[EYE_WHITE]:
                continue
            nb = [out[y - 1, x], out[y + 1, x], out[y, x - 1], out[y, x + 1]]
            if v in nb:
                continue
            solid_nb = [c for c in nb if c not in (0, IDX[OUTLINE])]
            if len(solid_nb) >= 2:
                vals, cnt = np.unique(solid_nb, return_counts=True)
                if cnt.max() >= 2:
                    clean[y, x] = vals[cnt.argmax()]
    return clean


def to_png(img, path):
    rgba = np.zeros(img.shape + (4,), np.uint8)
    for i, c in enumerate(PAL):
        if c:
            rgba[img == i] = hexc(c) + (255,)
    Image.fromarray(rgba, "RGBA").save(path)


# ---- scoring against the drawn set ----------------------------------------------------------------------------------
def mask_of(path):
    a = np.array(Image.open(path).convert("RGBA"))
    return a[..., 3] > 64


def shape_iou(a, b):
    """Both silhouettes cropped, scaled to the same height, bottoms and centres aligned: how alike the shapes are."""
    def norm(m, h=96):
        ys, xs = np.where(m)
        crop = m[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        w = max(1, int(round(crop.shape[1] * h / crop.shape[0])))
        return np.array(Image.fromarray(crop.astype(np.uint8) * 255).resize((w, h), Image.NEAREST)) > 127
    A, B = norm(a), norm(b)
    W = max(A.shape[1], B.shape[1]) + 4
    ca = np.zeros((96, W), bool)
    cb = np.zeros((96, W), bool)
    ca[:, (W - A.shape[1]) // 2:(W - A.shape[1]) // 2 + A.shape[1]] = A
    cb[:, (W - B.shape[1]) // 2:(W - B.shape[1]) // 2 + B.shape[1]] = B
    return float((ca & cb).sum()) / float((ca | cb).sum())


def main():
    build()
    os.makedirs(OUT, exist_ok=True)
    zmax = max(p["c"][2] + p["r"].max() for p in prims)
    scores = {}
    sys.path.insert(0, os.path.join(ROOT, "tools", "art"))
    from measure_views import measure
    for name, size, height, feet, ss, jump, keep, sel, drawn_dir in (
            ("128", (128, 128), 75.0, 102.0, 3, 3.0, 0.5, False, DRAWN),
            ("dungeon", Image.open(os.path.join(DRAWN, "dungeon", "s.png")).size, 21.5, 29.5, 6, 6.0, 0.36, True, os.path.join(DRAWN, "dungeon"))):
        out_dir = os.path.join(OUT, "views_" + name)
        os.makedirs(out_dir, exist_ok=True)
        scale = height / zmax
        origin = (size[0] / 2.0, feet)
        ious = {}
        for v in DIRS:
            sub, dep = cast(v, size, scale, origin, ss)
            img, d2 = down(sub, dep, size, ss, keep)
            img = passes(img, d2, jump, sel)
            path = os.path.join(out_dir, v + ".png")
            to_png(img, path)
            ious[v] = round(shape_iou(img > 0, mask_of(os.path.join(drawn_dir, v + ".png"))), 3)
        mine, theirs = measure(out_dir), measure(drawn_dir)
        scores[name] = {"shape_iou_vs_drawn": ious, "mean_shape_iou": round(sum(ious.values()) / 8, 3),
                        "height_spread": [mine["height_spread"], theirs["height_spread"]],
                        "mirror_iou": [mine["mirror_iou"], theirs["mirror_iou"]],
                        "colours_per_view": [[v["colours"] for v in mine["views"].values()], [v["colours"] for v in theirs["views"].values()]]}
        # contact sheet: the model above, the drawn views below
        z = 2 if name == "128" else 5
        cw, ch = size[0] * z, size[1] * z
        sheet = Image.new("RGBA", (8 * (cw + 6) + 6, 2 * (ch + 18) + 6), (46, 46, 52, 255))
        dr = ImageDraw.Draw(sheet)
        for i, v in enumerate(DIRS):
            x = 6 + i * (cw + 6)
            for row, src in enumerate((os.path.join(out_dir, v + ".png"), os.path.join(drawn_dir, v + ".png"))):
                im = Image.open(src).convert("RGBA").resize((cw, ch), Image.NEAREST)
                sheet.alpha_composite(im, (x, 18 + row * (ch + 18)))
            dr.text((x, 3), "%s  model / drawn  shape %.2f" % (v, ious[v]), fill=(235, 235, 235, 255))
        sheet.save(os.path.join(OUT, "contact_%s.png" % name))
    with open(os.path.join(OUT, "scores.json"), "w") as f:
        json.dump(scores, f, indent=1)
    for name, sc in scores.items():
        print("%s: mean shape IoU %.3f %s" % (name, sc["mean_shape_iou"], sc["shape_iou_vs_drawn"]))
        print("   height spread model/drawn %s, mirror IoU model %s drawn %s" % (sc["height_spread"], sc["mirror_iou"][0], sc["mirror_iou"][1]))


if __name__ == "__main__":
    main()
