"""Split Vitrecrag's idle mouth flame into its own animated layer.

Preston (2026-09-28): make the flame at Vitrecrag's mouth move like a flame
blown in and out like a tongue. The approved in-game sprite is left untouched;
this writes, into assets/sprites/creatures/idle/vitrecrag_flame/:
  body.png          the in-game sprite without the flame
  grow_1..3, full   reforming out of the mouth, base first, curl last
  fade_1..4         going back in: the tip breaks up and throws rising sparks
                    while the rest shortens toward the mouth
  ember             a small glow at the mouth between loops
  flick_*.png       full-length flicker variants: tip up, tip down, longer
All are 128x128 overlays anchored at the lips.
The battle lays the flame over the body and runs the loop out, flicker, back in.

Run from the project root: python tools/build_vitrecrag_mouth_flame.py [--preview out.png]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"
OUT = ROOT / "assets/sprites/creatures/idle/vitrecrag_flame"
LIP_X = 107      # flame pixels left of this are inside the mouth
TRAVEL = 15      # pixels the flame slides between fully in and fully out
TIP_X = 113      # the curl, which flickers on its own


def main():
    img = np.asarray(Image.open(OFFICIAL).convert("RGBA")).copy()
    r, g, b, a = (img[..., i].astype(int) for i in range(4))
    ys, xs = np.mgrid[0:128, 0:128]
    flame = (a > 0) & (xs >= LIP_X) & (ys >= 79) & (ys <= 93) & (r > 150) & (r > b + 80)
    body = img.copy()
    body[flame] = 0
    piece = np.zeros_like(img)
    piece[flame] = img[flame]
    OUT.mkdir(parents=True, exist_ok=True)
    Image.fromarray(body, "RGBA").save(OUT / "body.png")

    def slid(share):
        """The flame pulled back into the mouth: only what is past the lips shows."""
        back = int(round((1.0 - share) * TRAVEL))
        out = np.zeros_like(img)
        fy, fx = np.where(piece[..., 3] > 0)
        for y, x in zip(fy, fx):
            nx = x - back
            if nx >= LIP_X:
                out[y, nx] = piece[y, x]
        return out

    def tip_moved(dy):
        out = np.zeros_like(img)
        fy, fx = np.where(piece[..., 3] > 0)
        for y, x in zip(fy, fx):
            ny = y + (dy if x >= TIP_X else 0)
            if 0 <= ny < 128:
                out[ny, x] = piece[y, x]
        return out

    def longer():
        """One pixel longer: everything from the curl on moves out a column."""
        out = np.zeros_like(img)
        fy, fx = np.where(piece[..., 3] > 0)
        for y, x in zip(fy, fx):
            out[y, x + (1 if x >= TIP_X else 0)] = piece[y, x]
            if x == TIP_X:
                out[y, x] = piece[y, x]  # fill the gap the shift opens
        return out

    fy_all, fx_all = np.where(piece[..., 3] > 0)
    reach = max(1, fx_all.max() - LIP_X)

    def curled(length, rise):
        """The flame stays anchored at the lips and changes shape like a real
        flame: length squeezes it toward the mouth (1.0 is the full tongue) and
        rise bends it upward, more the further from the mouth, as heat does.
        Each column moves as a whole, and a gap between neighbouring columns is
        filled so the outline stays joined."""
        out = np.zeros_like(img)
        lift_of = {}
        for y, x in zip(fy_all, fx_all):
            d = x - LIP_X
            nx = LIP_X + int(round(d * length))
            lift = int(round(rise * (d / reach) ** 1.6 * 7))
            lift_of[nx] = max(lift_of.get(nx, 0), lift)
            ny = y - lift
            if 0 <= ny < 128 and (out[ny, nx, 3] == 0 or piece[y, x, :3].sum() > out[ny, nx, :3].sum()):
                out[ny, nx] = piece[y, x]
        # Close vertical tears where the lift jumps between neighbouring columns.
        cols = sorted(lift_of)
        for a, b in zip(cols, cols[1:]):
            if lift_of[b] - lift_of[a] >= 2:
                ys = np.where(out[:, a, 3] > 0)[0]
                if len(ys):
                    top = ys.min()
                    for yy in range(top - (lift_of[b] - lift_of[a]) + 1, top):
                        out[yy, a] = out[top, a]
        return out

    def wisp():
        """The tip breaks off and rises, like a lick of flame detaching."""
        out = curled(0.9, 0.3)
        tip = out.copy()
        tip[:, :TIP_X + 4] = 0
        out[:, TIP_X + 4:] = 0
        ty, tx = np.where(tip[..., 3] > 0)
        for y, x in zip(ty, tx):
            if y - 3 >= 0 and x + 1 < 128:
                out[y - 3, x + 1] = tip[y, x]
        return out

    # Distance along the flame from the lips, following its own curve (the curl
    # bends back over itself, so left-to-right distance would get the tip wrong).
    dist = np.full((128, 128), -1, int)
    queue = [(y, x) for y, x in zip(fy_all, fx_all) if x <= LIP_X + 1]
    for y, x in queue:
        dist[y, x] = 0
    head = 0
    while head < len(queue):
        y, x = queue[head]
        head += 1
        for ny in (y - 1, y, y + 1):
            for nx in (x - 1, x, x + 1):
                if 0 <= ny < 128 and 0 <= nx < 128 and piece[ny, nx, 3] > 0 and dist[ny, nx] < 0:
                    dist[ny, nx] = dist[y, x] + 1
                    queue.append((ny, nx))
    tip = dist.max()
    hot = np.array([252, 200, 112, 255], np.uint8)   # the glass's pale-gold hot core
    bright = np.array([252, 156, 76, 255], np.uint8)

    def grown(share):
        """Reforming out of the mouth: solid, base first, the curl forming last."""
        out = np.zeros_like(img)
        keep = (dist >= 0) & (dist <= share * tip)
        out[keep] = piece[keep]
        return out

    def faded(share, step):
        """Going back in: the body shortens to share of its length while the part
        beyond breaks up (every other pixel, drifting up) and throws a few sparks
        that rise off the tip."""
        out = np.zeros_like(img)
        solid = (dist >= 0) & (dist <= share * tip)
        out[solid] = piece[solid]
        cut = share * tip
        yy, xx = np.where(dist > cut)
        for y, x in zip(yy, xx):
            beyond = dist[y, x] - cut
            if beyond <= 5:
                if (x + y + step) % 2 == 0 and y - 1 >= 0:
                    out[y - 1, x] = piece[y, x]  # thinning, drifting up
            elif (x * 3 + y * 5 + step) % 7 == 0:
                ny = y - 2 - step
                if 0 <= ny < 128:
                    out[ny, x] = hot if (x + step) % 2 else bright  # a rising spark
        return out

    edge_c = np.array([220, 92, 36, 255], np.uint8)

    def billows(ember):
        """Small flames licking up out of the closed mouth: each frame adds one
        lick rising from the ember, with its own height and lean, some with a
        spark above. Cycled quickly, they make the ember burn and billow."""
        ey, ex = np.where(ember[..., 3] > 0)
        # Anchor on the ember's front edge, where it sits at the lips; a stray
        # high pixel elsewhere must not lift the licks off the flame.
        right = ex.max()
        top = ey[ex >= right - 2].min()
        # (height, lean per two rows, column offset, spark)
        shapes = [(2, 0, 0, False), (4, 1, 0, False), (5, 1, -1, True), (3, -1, 1, False), (4, 0, -1, True)]
        out = {}
        for n, (h, lean, dx, spark) in enumerate(shapes, start=1):
            f = ember.copy()
            x0 = right - 1 + dx
            for k in range(1, h + 1):
                y = top - k
                x = x0 + (lean * (k // 2))
                if y < 0 or not (0 <= x < 127):
                    continue
                f[y, x] = hot if k >= h - 1 else bright
                if k <= h - 2:  # wider, cooler base
                    f[y, x + 1] = edge_c
            if spark and top - h - 2 >= 0:
                f[top - h - 2, x0 + lean * (h // 2) + 1] = hot
            out[f"billow_{n}"] = f
        return out

    # One loop, not a mirror: reform out of the mouth, hold and flicker at full
    # length, then dissipate from the tip while the rest goes back in, down to an
    # ember at the mouth.
    frames = {
        "grow_1": grown(0.3), "grow_2": grown(0.55), "grow_3": grown(0.8), "full": piece.copy(),
        "fade_1": faded(0.8, 0), "fade_2": faded(0.6, 1), "fade_3": faded(0.4, 2), "fade_4": faded(0.2, 3),
        "ember": grown(0.2),
        **billows(grown(0.2)),
        "flick_up": tip_moved(-1), "flick_down": tip_moved(1), "flick_long": longer(),
    }
    for old in OUT.glob("flame_*.png"):
        old.unlink()
    for old in ("flick_wisp", "flick_rise"):
        (OUT / f"{old}.png").unlink(missing_ok=True)
    for name, arr in frames.items():
        Image.fromarray(arr, "RGBA").save(OUT / f"{name}.png")
    print("flame pixels", int(flame.sum()), "->", ", ".join(frames))

    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z = 8
        tiles = []
        base = Image.fromarray(body, "RGBA")
        for arr in [np.zeros_like(img)] + list(frames.values()):
            t = Image.new("RGBA", (128, 128), (40, 60, 70, 255))
            t.alpha_composite(base)
            t.alpha_composite(Image.fromarray(arr, "RGBA"))
            tiles.append(t.crop((92, 74, 128, 98)).resize((36 * Z, 24 * Z), Image.NEAREST))
        sheet = Image.new("RGBA", (sum(p.width + 6 for p in tiles), tiles[0].height), (0, 0, 0, 255))
        x = 0
        for p in tiles:
            sheet.paste(p, (x, 0))
            x += p.width + 6
        sheet.save(dest)


if __name__ == "__main__":
    main()
