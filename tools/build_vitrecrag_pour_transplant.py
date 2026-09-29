"""Build Vitrecrag's Molten Glass pour with Opal's drawn head poses.

Preston's direction (2026-09-28): use the poses Opal already drew, where the
head dips, tucks under the shell and comes back out, but keep the in-game body
and legs so nothing jumps when the attack starts or ends.

For each beat this takes the main pour frame (in-game sprite + shell glow),
removes its head and lava, lines the matching alt_old_sheet pose up with the
in-game sprite (Opal drew it a few pixels right and lower, by a different amount
each frame), and pastes only the pose's head/front region and its lava.

Writes .../vitrecrag_lava_pour/transplant/ and never edits the originals.
Run from the project root: python tools/build_vitrecrag_pour_transplant.py [--preview out.png]
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour"
OUT = SRC / "transplant"
OFFICIAL = ROOT / "assets/sprites/creatures/vitrecrag_official.png"
BEATS = ["01_load", "02_windup", "03_launch", "04_contact", "05_recovery"]
# Official head outline in 128x128 sprite coordinates.
HEAD_POLY = [(90, 72), (95, 69), (100, 71), (105, 73), (109, 77), (111, 84),
             (111, 93), (107, 97), (97, 97), (90, 93), (87, 82)]
GROW = 4          # how far past the official head the pose may replace pixels
SEARCH = 9        # alignment search range in pixels
SHADOW = 0.35     # vacated head pixels: share of the original colour kept


def is_lava(c):
    r, g, b, a = c
    return a > 0 and r > 190 and 70 < g < 200 and b < 110


FLOW_STEP = 2  # pixels the stream's colours travel per flow frame


def flow_frame(contact, step):
    """Scroll the stream's colours down by step pixels inside its own shape."""
    out = contact.copy()
    cp, o = contact.load(), out.load()
    W, H = contact.size
    for y in range(H):
        for x in range(100, W):
            if is_lava(cp[x, y]) and y - step >= 0 and is_lava(cp[x, y - step]):
                o[x, y] = cp[x, y - step]
            elif is_lava(cp[x, y]):
                # Top of a run: bring colour up from the far end so it loops.
                run_end = y
                while run_end + 1 < H and is_lava(cp[x, run_end + 1]):
                    run_end += 1
                src = run_end - ((run_end - y) % max(1, step))
                o[x, y] = cp[x, src]
    return out


def lava_components(img):
    """8-connected groups of lava pixels in front of the body (x >= 96)."""
    p = img.load()
    W, H = img.size
    seen, groups = set(), []
    for y in range(H):
        for x in range(96, W):
            if (x, y) in seen or not is_lava(p[x, y]):
                continue
            stack, group = [(x, y)], []
            seen.add((x, y))
            while stack:
                cx, cy = stack.pop()
                group.append((cx, cy))
                for ax in (cx - 1, cx, cx + 1):
                    for ay in (cy - 1, cy, cy + 1):
                        if 96 <= ax < W and 0 <= ay < H and (ax, ay) not in seen and is_lava(p[ax, ay]):
                            seen.add((ax, ay))
                            stack.append((ax, ay))
            groups.append(group)
    return groups


SPECK_MAX = 5  # lava groups this small are leftovers where two drawings met


def remove_specks(img, official):
    """Put back the in-game pixel (or clear air) under stray lava specks, and
    clear any tiny cluster of any colour floating in open air in front of the
    body, where Opal's splash left crumbs that touch nothing."""
    out = img.copy()
    o, op = out.load(), official.load()
    for group in lava_components(img):
        if len(group) <= SPECK_MAX:
            for x, y in group:
                o[x, y] = op[x, y]
    W, H = out.size
    seen = set()
    for y in range(H):
        for x in range(96, W):
            if (x, y) in seen or not o[x, y][3] or op[x, y][3]:
                continue
            stack, group, touches_body = [(x, y)], [], False
            seen.add((x, y))
            while stack:
                cx, cy = stack.pop()
                group.append((cx, cy))
                for ax in (cx - 1, cx, cx + 1):
                    for ay in (cy - 1, cy, cy + 1):
                        if not (0 <= ax < W and 0 <= ay < H) or not o[ax, ay][3]:
                            continue
                        if op[ax, ay][3]:
                            touches_body = True
                        elif (ax, ay) not in seen:
                            seen.add((ax, ay))
                            stack.append((ax, ay))
            if not touches_body and len(group) <= SPECK_MAX:
                for gx, gy in group:
                    o[gx, gy] = (0, 0, 0, 0)
    return out


def extend_stream(img):
    """Run the pour down in front of the foreleg until it meets its puddle.

    Opal's stream stops where the in-game leg starts, leaving the puddle on the
    ground with nothing feeding it. The gap is filled by repeating the stream's
    own bottom rows, so its colours and outline carry on and still flow.
    """
    out = img.copy()
    p = out.load()
    groups = sorted(lava_components(img), key=len, reverse=True)
    pool = [pt for g in groups for pt in g if pt[1] >= 112]
    stream = [pt for pt in groups[0] if pt[1] < 112] if groups else []
    if not pool or not stream:
        return out
    pool_top = min(y for _, y in pool)
    bottom = max(y for _, y in stream)
    span = sorted({x for x, y in stream if y >= bottom - 2})
    for y in range(bottom + 1, pool_top + 1):
        src_y = bottom - ((y - bottom - 1) % 4)  # tile the last four rows
        for x in span:
            c = p[x, src_y]
            if is_lava(c) or c[3]:
                p[x, y] = c
    return out


def canvas_official():
    off = Image.open(OFFICIAL).convert("RGBA")
    c = Image.new("RGBA", (140, 128), (0, 0, 0, 0))
    c.alpha_composite(off, (6, 0))
    return c


def best_shift(pose, official):
    """Shift that makes the pose's front end overlap the official's most."""
    pp, op = pose.load(), official.load()
    best = (-1.0, 0, 0)
    for dx in range(-SEARCH, SEARCH + 1):
        for dy in range(-SEARCH, SEARCH + 1):
            inter = union = 0
            # Front end only, left of where the pour column hangs.
            for y in range(40, 100):
                for x in range(84, 126):
                    sx, sy = x - dx, y - dy
                    a = 0 <= sx < 140 and 0 <= sy < 128 and pp[sx, sy][3] > 0
                    b = op[x, y][3] > 0
                    inter += a and b
                    union += a or b
            score = inter / max(union, 1)
            if score > best[0]:
                best = (score, dx, dy)
    return best


def build(name, official, head_mask, region_mask):
    frame = Image.open(SRC / f"{name}.png").convert("RGBA")
    pose = Image.open(SRC / "alt_old_sheet" / f"{name}.png").convert("RGBA")
    score, dx, dy = best_shift(pose, official)
    shifted = Image.new("RGBA", pose.size, (0, 0, 0, 0))
    shifted.paste(pose.crop((max(0, -dx), max(0, -dy), 140, 128)), (max(0, dx), max(0, dy)))
    out = frame.copy()
    o, fp, op, sp = out.load(), frame.load(), official.load(), shifted.load()
    hm, rm = head_mask.load(), region_mask.load()
    W, H = out.size
    # 1. Remove the main frame's head and its lava (the pose brings its own).
    for y in range(H):
        for x in range(W):
            if hm[x, y]:
                o[x, y] = (0, 0, 0, 0)
            elif x > 100 and is_lava(fp[x, y]) and (op[x, y][3] == 0 or fp[x, y] != op[x, y]):
                o[x, y] = (0, 0, 0, 0)
            elif x > 100 and op[x, y][3] == 0 and fp[x, y][3]:
                o[x, y] = (0, 0, 0, 0)  # lava the main frame added
            elif x > 114 and 74 <= y < 100 and not rm[x, y] and fp[x, y][0] > 150 and fp[x, y][0] > fp[x, y][2] + 80:
                o[x, y] = (0, 0, 0, 0)  # the idle mouth flame (part of the in-game sprite)
    # 2. Paste the pose's head/front region, and its lava wherever it falls.
    for y in range(H):
        for x in range(W):
            c = sp[x, y]
            if not c[3]:
                continue
            # Lava only where it falls outside the in-game body, so Opal's
            # glowing shell plates never land on the in-game shell.
            if rm[x, y] or (x > 100 and is_lava(c) and op[x, y][3] == 0):
                o[x, y] = c
    # 3. Any old head pixels the pose does not cover become shadowed opening,
    #    so the legs behind the head are never left bare.
    for y in range(H):
        for x in range(W):
            if hm[x, y] and o[x, y][3] == 0:
                c = op[x, y]
                o[x, y] = (int(c[0] * SHADOW), int(c[1] * SHADOW), int(c[2] * SHADOW), c[3])
    # 4. Lone specks left where two drawings meet.
    for y in range(H):
        for x in range(90, W):
            if o[x, y][3]:
                n = sum(1 for ax, ay in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1))
                        if 0 <= ax < W and 0 <= ay < H and o[ax, ay][3])
                if n == 0:
                    o[x, y] = (0, 0, 0, 0)
    return out, (round(score, 3), dx, dy)


def main():
    official = canvas_official()
    head = Image.new("L", (140, 128), 0)
    ImageDraw.Draw(head).polygon([(x + 6, y) for x, y in HEAD_POLY], fill=255)
    op, hp = official.load(), head.load()
    for y in range(128):
        for x in range(140):
            if op[x, y][3] == 0:
                hp[x, y] = 0
    region = head.filter(ImageFilter.MaxFilter(GROW * 2 + 1))
    OUT.mkdir(exist_ok=True)
    frames = []
    for name in BEATS:
        img, fit = build(name, official, head, region)
        img = remove_specks(img, official)
        if name == "04_contact":
            img = extend_stream(img)
        img.save(OUT / f"{name}.png")
        frames.append(img)
        print(name, "fit IoU/shift", fit)
    # Flowing stream: two extra contact frames whose glass colours scroll down
    # the stream, so a held pour moves instead of freezing.
    contact = frames[BEATS.index("04_contact")]
    for suffix, step in (("b", FLOW_STEP), ("c", FLOW_STEP * 2)):
        flow_frame(contact, step).save(OUT / f"04_contact_{suffix}.png")
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        Z, x0, y0, x1, y1 = 4, 40, 20, 140, 128
        panels = []
        for img in [official] + frames:
            bg = Image.new("RGBA", img.size, (40, 60, 70, 255))
            bg.alpha_composite(img)
            panels.append(bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * Z, (y1 - y0) * Z), Image.NEAREST))
        sheet = Image.new("RGBA", (sum(p.width + 6 for p in panels), panels[0].height), (0, 0, 0, 255))
        x = 0
        for p in panels:
            sheet.paste(p, (x, 0))
            x += p.width + 6
        sheet.save(dest)


if __name__ == "__main__":
    main()
