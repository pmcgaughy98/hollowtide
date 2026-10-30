"""Walk lock: steady creature walks made from each facing's own still (Claude, 2026-10-28; Preston: "fix the
animations especially the walking for all creatures ... without having to use money ... do each one individually").

The walks came from Retro Diffusion's walking animation, which redraws the whole creature every frame. About two
thirds of the body's pixels change colour from one frame to the next (the body boils), and tails, crests and
held things change shape. A pixel artist animates a small walk the other way round: one good drawing of the body
per facing, moved as one piece, and only the legs redrawn. This does that at each set's own size, with no new
colours and no paid step:

  1. Per facing, the still is the body. Its legs are the pieces of its bottom band that reach the ground,
     widened a little for the stride (the leg zone).
  2. Per frame, find how far Retro Diffusion's body moved: the shift that best fits the still's upper body onto
     the frame. That is the bob; it is held to whole pixels and a small range.
  3. Draw the frame: the still moved by the bob everywhere except the leg zone, where Retro Diffusion's legs are
     kept, recoloured to the still's own leg colours. Lone pixels are cleared.

The Retro Diffusion frames are kept once under docs/creatures/walk-lock-2026-10-28/before/<name>/<set>/ and are
always the input, so running it again gives the same result. After build_dungeon_set.py or build_small.py rebuilds
a creature, delete its before folder and run this again.

  python tools/art/walk_lock.py kithflare [--sets=dungeon,town,small] [--preview=DIR] [--dry]
"""
import json
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ART = Path("assets/sprites/arena")
BEFORE = Path("docs/creatures/walk-lock-2026-10-28/before")
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
BAND = 0.30      # the bottom share of the body that holds the legs
REACH = 2        # rows above the foot a piece must reach to count as a leg
WIDEN = 2        # how far a stride may step outside the still's legs (px, at the set's size)
SHIFT = 3        # the largest bob looked for (px)
# Creatures whose walk is stepped from the still alone, with no Retro Diffusion pixels: the outer two feet take turns
# lifting 1 px (and stepping 1 px forward in the side views) while the body bobs. For squat bodies whose legs barely
# show, and wherever Retro Diffusion's legs walk on the wrong limbs.
STEP = {}
# Creatures whose walk is strided from the still alone: everything along the bottom edge (legs, and roots or tendrils
# that hang like legs) is split into a left and a right half, which take turns lifting 2 px (more in the bigger sets)
# and swinging forward in the side views, while the body bobs. A bigger step than STEP, still with no new pixels.
STRIDE = {}
# Creatures where only some facings are rewritten; the rest stay as Retro Diffusion drew them.
ONLY = {}
# Creatures put back to their original walks after a free fix was tried and turned down. The tool refuses them, so a
# rerun can't undo the revert; they wait for regenerated art instead.
REVERTED = {
    "tallowroot": "Preston, 2026-10-28: step mode tried, then 'revert to originals ... would like require regeneration'",
    "archroot": "Preston, 2026-10-28: step then stride mode on S, N, NE, NW ('the limbs look still'), then 'that "
                "doesn't work', reverted; its FOOTPRINT_SHADOW in dungeon.gd stays",
}
FORWARD = {"e": 1, "se": 1, "ne": 1, "w": -1, "sw": -1, "nw": -1, "s": 0, "n": 0}
FOOT_SHARE = 0.35  # a run in the bottom rows wider than this share of the body is not a foot
UNDER = 0.22       # of a wider run, only the part this close to the torso's middle walks (share of the body's width)


def load(p):
    return np.array(Image.open(p).convert("RGBA"))


def frames_for(name, s, fc):
    """The Retro Diffusion frames of one facing, backed up once and read from the backup from then on."""
    src = ART / name / s
    keep = BEFORE / name / s
    out = []
    for i in range(8):
        k = keep / f"walk_{fc}_f{i}.png"
        if not k.exists():
            keep.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src / f"walk_{fc}_f{i}.png", k)
        out.append(load(k))
    return out


def shifted(img, dx, dy):
    """The image moved by whole pixels, with transparent fill."""
    out = np.zeros_like(img)
    h, w = img.shape[:2]
    ys, yd = (slice(0, h - dy), slice(dy, h)) if dy >= 0 else (slice(-dy, h), slice(0, h + dy))
    xs, xd = (slice(0, w - dx), slice(dx, w)) if dx >= 0 else (slice(-dx, w), slice(0, w + dx))
    out[yd, xd] = img[ys, xs]
    return out


def leg_zone(still):
    a = still[..., 3] > 0
    rows = np.where(a.any(1))[0]
    top, foot = rows.min(), rows.max()
    hip = foot - int(round(BAND * (foot - top + 1)))
    band = a.copy()
    band[:hip] = False
    # Feet are the narrow runs of solid pixels in the bottom rows; a wide run there is a tail or a belly lying on
    # the ground, which stays part of the body (Kithflare's tail curl in its back views, 2026-10-28).
    cols = a[foot - REACH: foot + 1].any(0)
    width = np.ptp(np.where(a.any(0))[0]) + 1
    feet = np.zeros_like(cols)
    lab, n = ndimage.label(cols)
    # The torso's middle: legs stand under it, a tail on the ground lies off to one side.
    mid = np.nonzero(a[:hip])[1].mean() if a[:hip].any() else a.shape[1] / 2
    under = np.abs(np.arange(a.shape[1]) - mid) <= UNDER * width
    for k in range(1, n + 1):
        run = lab == k
        feet |= run if run.sum() <= FOOT_SHARE * width else run & under
    if not feet.any():   # nothing under the torso (a slug or a fish on its belly): the whole bottom run walks
        feet = cols
    near = ndimage.binary_dilation(feet, iterations=WIDEN)
    zone = band & near[None, :]
    zone = ndimage.binary_dilation(zone, structure=np.ones((3, 2 * WIDEN + 1))) & near[None, :]
    zone[:hip] = False
    return zone, hip, foot


def best_shift(still, frame, hip):
    """The whole-pixel move that best fits the still's upper body onto the frame."""
    up = still.copy()
    up[hip:] = 0
    fa = frame[..., 3] > 0
    best = None
    for dy in range(-SHIFT, SHIFT + 1):
        for dx in range(-SHIFT, SHIFT + 1):
            m = shifted(up, dx, dy)
            ma = m[..., 3] > 0
            region = np.zeros_like(fa)
            region[: hip + dy] = True
            miss = ((ma ^ fa) & region).sum()
            both = ma & fa & region
            col = np.abs(m[..., :3].astype(int) - frame[..., :3]).sum(-1)[both].mean() if both.any() else 0
            cost = miss + 0.01 * col * both.sum() / 50 + 0.5 * (abs(dx) + abs(dy))
            if best is None or cost < best[0]:
                best = (cost, dx, dy)
    return best[1], best[2]


def game_foot(img):
    """The row the game stands a sprite on (dungeon.gd _count_foot_row: the lowest row with 4 or more solid pixels)."""
    n = (img[..., 3] > 25).sum(1)
    rows = np.where(n >= 4)[0]
    return int(rows.max()) if len(rows) else img.shape[0] - 1


def recolour(px, palette):
    d = ((px[:, None, :3].astype(int) - palette[None, :, :3].astype(int)) ** 2).sum(-1)
    return palette[d.argmin(1)]


def lock_facing(still, frames):
    zone, hip, foot = leg_zone(still)
    a = still[..., 3] > 0
    legs_pal = np.unique(still[zone & a].reshape(-1, 4), axis=0)
    if len(legs_pal) < 4:
        legs_pal = np.unique(still[a].reshape(-1, 4), axis=0)
    # The bob follows the legs, not Retro Diffusion's body, which jitters: the body rises 1 px while the legs pass
    # each other (their spread at the feet is narrow) and sits on the still's height while they are apart.
    spread = []
    for f in frames:
        fa = (f[..., 3] > 0) & zone
        xs = np.where(fa[max(0, foot - 3): foot + 1].any(0))[0]
        spread.append(np.ptp(xs) if len(xs) else 0)
    # Eight frames hold two steps, so the bob repeats every four frames; its phase is the one that best lines the
    # widest stride (the foot coming down) up with the low point.
    sp = np.array(spread, float) - np.mean(spread)
    phase = max(range(4), key=lambda p: sum(sp[i] * (1, 0, -1, 0)[(i - p) % 4] for i in range(len(sp))))
    moves = [(0, -1 if (i - phase) % 4 in (2, 3) else 0) for i in range(len(frames))]
    body = still.copy()
    body[zone] = 0
    out = []
    for f, (dx, dy) in zip(frames, moves):
        o = shifted(body, dx, dy)
        z = zone | (shifted(zone[..., None].astype(np.uint8), dx, dy)[..., 0] > 0)
        z[: hip + min(dy, 0)] = False
        take = z & (f[..., 3] > 0)
        # Above the hip line the moved body wins; below it the legs do.
        take &= ~((o[..., 3] > 0) & (np.arange(o.shape[0])[:, None] < hip + dy))
        if take.any():
            legs = np.zeros_like(o)
            legs[take] = recolour(f[take], legs_pal)
            legs[take, 3] = 255
            # Feet below the still's own would lift the whole creature off its shadow when it starts walking: the
            # game stands every frame on its lowest row with four or more solid pixels, so the legs keep to the still's.
            trial = o.copy()
            trial[legs[..., 3] > 0] = legs[legs[..., 3] > 0]
            low = game_foot(trial) - game_foot(still)
            if low > 0:
                legs = shifted(legs, 0, -low)
            put = legs[..., 3] > 0
            o[put] = legs[put]
        al = o[..., 3] > 0
        nb = ndimage.convolve(al.astype(int), np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]]), mode="constant")
        o[al & (nb == 0)] = 0
        out.append(o)
    return out, moves, hip, int(zone.sum())


def step_facing(still, fc):
    """A walk stepped from the still alone: returns (frames, moves, hip, feet px)."""
    a = still[..., 3] > 0
    gf = game_foot(still)
    rows = np.where(a.any(1))[0]
    tall = gf - rows.min() + 1
    fh = max(2, int(round(0.08 * tall)))             # how many rows of each foot lift
    width = np.ptp(np.where(a.any(0))[0]) + 1
    mid = np.nonzero(a[: gf - fh + 1])[1].mean()

    def foot_runs(y):
        lab, n = ndimage.label(a[y])
        runs = [np.nonzero(lab == k)[0] for k in range(1, n + 1)]
        runs = [xs for xs in runs if abs(xs.mean() - mid) <= 0.35 * width]
        if len(runs) == 1 and len(runs[0]) >= 4:   # one wide run: the feet touch, so split it at its middle
            xs = runs[0]
            runs = [xs[: len(xs) // 2], xs[len(xs) // 2:]]
        return runs

    # Each foot is a run of solid pixels on the foot row (feet often touch higher up, through the belly), taken up
    # through the lifting rows in its own columns. Things hanging wide of the body (Archroot's roots in the back view)
    # can be the game's foot row; then the feet are the lowest row a little higher that has them.
    fr = gf
    for y in range(gf, gf - max(3, int(0.2 * tall)), -1):
        if len(foot_runs(y)) >= 2:
            fr = y
            break
    runs = foot_runs(fr)
    low = np.zeros_like(a)
    low[fr - fh + 1: fr + 1] = a[fr - fh + 1: fr + 1]
    if fr == gf:
        low[gf + 1:] = a[gf + 1:]                     # stray toe pixels under the foot row go with the feet
    pieces = []
    for xs in runs:
        cols = np.zeros(a.shape[1], bool)
        cols[xs.min(): xs.max() + 1] = True
        pieces.append((xs.mean(), low & cols[None, :]))
    pieces.sort(key=lambda t: t[0])
    if len(pieces) < 2:
        feet = [p for _, p in pieces] + [np.zeros_like(a)]
    else:
        feet = [pieces[0][1], pieces[-1][1]]          # the outer two step; anything between stays planted
    body = still.copy()
    for f in feet:
        body[f] = 0
    # Frame by frame: which foot is up, and the bob (the body rises while a foot is up).
    plan = [(None, 0), (0, -1), (0, -1), (None, 0), (None, 0), (1, -1), (1, -1), (None, 0)]
    out, moves = [], []
    above = fr - fh   # the body's lowest row over the feet, stretched down 1 px when the body rises
    def frame(up, dy):
        o = shifted(body, 0, dy)
        if dy < 0:
            for f in feet:
                cols = f.any(0)
                gap = (a[above] & cols) & (o[above, :, 3] == 0)
                o[above][gap] = still[above][gap]
        for k, f in enumerate(feet):
            piece = still.copy()
            piece[~f] = 0
            if k == up:
                piece = shifted(piece, FORWARD[fc], -1)
            put = piece[..., 3] > 0
            o[put] = piece[put]
        return o

    for up, dy in plan:
        o = frame(up, dy)
        # The game stands the frame on its lowest row of four or more pixels; when the planted foot is too thin to
        # count, the whole creature would rise 2 px. Then the body stays down for that frame.
        if dy < 0 and game_foot(still) - game_foot(o) > 1:
            dy = 0
            o = frame(up, dy)
        out.append(o)
        moves.append((0, dy))
    return out, moves, above, int(sum(f.sum() for f in feet))


def stride_facing(still, fc):
    """A walk strided from the still alone: returns (frames, moves, top of the limb band, limb px)."""
    a = still[..., 3] > 0
    gf = game_foot(still)
    rows = np.where(a.any(1))[0]
    tall = gf - rows.min() + 1
    band = max(3, int(round(0.14 * tall)))           # the bottom rows that hold the limbs
    top = gf - band + 1
    lift = max(2, int(round(band * 0.5)))            # how high a limb rises at the top of its step
    limbs = a.copy()
    limbs[:top] = False
    lab, n = ndimage.label(limbs, structure=np.ones((3, 3)))
    mid = np.nonzero(limbs)[1].mean()
    # Each piece of the band goes with the half of the body it hangs from; the two halves take turns.
    sides = [[], []]
    for k in range(1, n + 1):
        m = lab == k
        sides[0 if np.nonzero(m)[1].mean() < mid else 1].append(m)
    side = [np.any(g, 0) if g else np.zeros_like(a) for g in sides]
    body = still.copy()
    body[limbs] = 0
    # Frame by frame: each half's rise and swing, and the bob (down when a foot lands, up while one is in the air).
    rise = [0, lift // 2 or 1, lift, lift // 2 or 1, 0, 0, 0, 0]
    swing = [0, 1, 1, 0, 0, 0, -1, 0]
    bob = [0, -1, -1, -1, 0, -1, -1, -1]
    out, moves = [], []
    for i in range(8):
        o = np.zeros_like(still)
        for h in (0, 1):
            j = (i + 4 * h) % 8
            piece = still.copy()
            piece[~side[h]] = 0
            piece = shifted(piece, FORWARD[fc] * swing[j], -rise[j])
            put = piece[..., 3] > 0
            o[put] = piece[put]
        dy = bob[i]
        b = shifted(body, 0, dy)
        put = b[..., 3] > 0
        o[put] = b[put]
        if dy < 0:
            # The body's lowest row stretches down 1 px over the limbs that stay planted.
            gap = a[top - 1] & (o[top - 1, :, 3] == 0)
            o[top - 1][gap] = still[top - 1][gap]
        out.append(o)
        moves.append((0, dy))
    return out, moves, top, int(limbs.sum())


def boil(frames):
    """Share of the body's pixels that change colour from one frame to the next (the shimmer). The locked frames are
    measured with their bob taken out, so only drawing that changes counts."""
    r = []
    for i, a in enumerate(frames):
        b = frames[(i + 1) % len(frames)]
        both = (a[..., 3] > 0) & (b[..., 3] > 0)
        diff = (np.abs(a[..., :3].astype(int) - b[..., :3]).sum(-1) > 30) & both
        r.append(diff.sum() / max(1, both.sum()))
    return float(np.mean(r))


def main():
    opts = dict(a[2:].split("=", 1) if "=" in a else (a[2:], "1") for a in sys.argv[1:] if a.startswith("--"))
    names = [a for a in sys.argv[1:] if not a.startswith("--")]
    sets = opts.get("sets", "dungeon,town,small").split(",")
    report = {}
    for name in names:
        if name in REVERTED:
            print(f"{name}: skipped, reverted to its original walk ({REVERTED[name]})")
            continue
        for s in sets:
            if not (ART / name / s / "walk_s_f0.png").exists():
                continue
            rep = report.setdefault(name, {}).setdefault(s, {})
            for fc in FACINGS:
                if name in ONLY and fc not in ONLY[name]:
                    continue
                still = load(ART / name / s / f"{fc}.png")
                frames = frames_for(name, s, fc)
                if still.shape != frames[0].shape:
                    rep[fc] = "skipped: the still and the walk differ in size"
                    continue
                if name in STRIDE:
                    new, moves, hip, zone = stride_facing(still, fc)
                elif name in STEP:
                    new, moves, hip, zone = step_facing(still, fc)
                else:
                    new, moves, hip, zone = lock_facing(still, frames)
                still_body = [shifted(o, 0, -dy) for o, (dx, dy) in zip(new, moves)]
                rep[fc] = {"boil_before": round(boil(frames), 2), "boil_after": round(boil(still_body), 2),
                           "bob": [m[1] for m in moves], "hip_row": int(hip), "leg_zone_px": zone}
                if "dry" not in opts:
                    for i, o in enumerate(new):
                        Image.fromarray(o).save(ART / name / s / f"walk_{fc}_f{i}.png")
                if "preview" in opts:
                    Path(opts["preview"]).mkdir(parents=True, exist_ok=True)
                    np.save(Path(opts["preview"]) / f"{name}_{s}_{fc}.npy", np.stack(frames + new))
                    np.save(Path(opts["preview"]) / f"{name}_{s}_{fc}_zone.npy",
                            np.any([n[..., 3] != still[..., 3] for n in new], 0) if name in STEP or name in STRIDE else leg_zone(still)[0])
    print(json.dumps(report, indent=1))


if __name__ == "__main__":
    main()
