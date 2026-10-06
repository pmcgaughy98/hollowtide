"""Route 1 meadow refinement (Claude, 2026-10-05).

Redraws the west meadow lane as one winding lane from the hometown entrance
to the River Road, using the exact 16 px soil tile from Codex's lane
(route1_meadow_approach.png), and lays out the meadow trees as groves and the
grass tufts along the lane. Prints the tree and tuft lists for
scripts/route1_approach.gd.

Run from the repo root:  python docs/art/world/route1-meadow-refine-2026-10-05/build_meadow.py
"""
import math
import random
import numpy as np
from PIL import Image

OLD = "assets/sprites/world/area_transitions_2026_10_03/route1_meadow_approach.png"
OUT = "assets/sprites/world/route1_meadow_refine_2026_10_05/meadow_lane.png"
ORIGIN_X = -768            # the lane image's left edge in the world
W, H = 792, 640            # 24 px past x 0, so the lane meets the River Road
HALF = 16.0                # half the lane width: rows 496-528 at the hometown edge
EDGE = 2.6                 # width of the worn, ragged border

# The lane's centre: a gentle S from the hometown entrance to the River Road.
P = [(0.0, 512.0), (250.0, 520.0), (500.0, 190.0), (792.0, 192.0)]


def bezier(t):
    u = 1.0 - t
    x = u**3 * P[0][0] + 3 * u * u * t * P[1][0] + 3 * u * t * t * P[2][0] + t**3 * P[3][0]
    y = u**3 * P[0][1] + 3 * u * u * t * P[1][1] + 3 * u * t * t * P[2][1] + t**3 * P[3][1]
    return x, y


CURVE = np.array([bezier(i / 3000.0) for i in range(3001)])


def lane_distance(x, y):
    """Distance from a lane-image pixel to the lane's centre."""
    return float(np.min(np.hypot(CURVE[:, 0] - x, CURVE[:, 1] - y)))


def build_lane():
    old = Image.open(OLD).convert("RGBA")
    tile = np.array(old.crop((400, 176, 416, 192)))          # one whole soil tile
    dist = np.full((H, W), 1e9)
    yy, xx = np.mgrid[0:H, 0:W]
    r = int(HALF + EDGE + 2)
    for cx, cy in CURVE[::2]:
        x0, x1 = max(0, int(cx) - r), min(W, int(cx) + r + 1)
        y0, y1 = max(0, int(cy) - r), min(H, int(cy) + r + 1)
        d = np.hypot(xx[y0:y1, x0:x1] - cx, yy[y0:y1, x0:x1] - cy)
        dist[y0:y1, x0:x1] = np.minimum(dist[y0:y1, x0:x1], d)
    out = np.zeros((H, W, 4), np.uint8)
    rng = np.random.default_rng(20261005)
    noise = rng.random((H, W))
    soil = tile[yy % 16, xx % 16]
    core = dist <= HALF
    out[core] = soil[core]
    # The border: darker, worn soil that frays into the grass.
    band = (dist > HALF) & (dist <= HALF + EDGE)
    keep = band & (noise < (HALF + EDGE - dist) / EDGE + 0.15)
    worn = soil.copy()
    worn[..., :3] = (worn[..., :3] * 0.84).astype(np.uint8)
    out[keep] = worn[keep]
    # Keep the edge columns exactly as wide as the old lane so the joins match.
    Image.fromarray(out).save(OUT)
    print("wrote", OUT)


def world_dist(wx, wy):
    return lane_distance(wx - ORIGIN_X, wy)


def layout():
    rnd = random.Random(20261005)
    groves = [  # centre, trees
        ((-660, 150), 4), ((-440, 96), 3), ((-560, 340), 3),
        ((-390, 610), 4), ((-150, 430), 3), ((-700, 628), 2), ((-250, 300), 1),
    ]
    trees = []
    for (gx, gy), n in groves:
        tries = 0
        placed = 0
        while placed < n and tries < 400:
            tries += 1
            x = round(gx + rnd.uniform(-70, 70))
            y = round(gy + rnd.uniform(-40, 40))
            if not (-752 <= x <= -24 and 72 <= y <= 632):
                continue
            if world_dist(x, y) < 40:
                continue                      # trunk and canopy stay off the lane
            if x < -700 and 440 < y < 560:
                continue                      # the hometown entrance stays open
            if any(math.hypot(x - tx, y - ty) < 62 for tx, ty, _, _ in trees):
                continue
            trees.append((x, y, len(trees) % 6, rnd.random() < 0.5))
            placed += 1
    tufts = []
    tries = 0
    while len(tufts) < 34 and tries < 5000:
        tries += 1
        x = round(rnd.uniform(-756, -12))
        y = round(rnd.uniform(40, 636))
        d = world_dist(x, y)
        near_lane = HALF + 6 <= d <= HALF + 22
        near_tree = any(math.hypot(x - tx, y - ty) < 40 and y >= ty - 4 for tx, ty, _, _ in trees)
        if not (near_lane or near_tree) or d < HALF + 6:
            continue
        if any(math.hypot(x - a, y - b) < 26 for a, b, _, _ in tufts):
            continue
        tufts.append((x, y, rnd.randrange(2), rnd.random() < 0.5))
    return trees, tufts


if __name__ == "__main__":
    build_lane()
    trees, tufts = layout()
    print("TREES (x, y, variant, flip):", len(trees))
    print("[" + ", ".join("[%d, %d, %d, %s]" % (x, y, v, "true" if f else "false") for x, y, v, f in trees) + "]")
    print("TUFTS (x, y, which, flip):", len(tufts))
    print("[" + ", ".join("[%d, %d, %d, %s]" % (x, y, v, "true" if f else "false") for x, y, v, f in tufts) + "]")
