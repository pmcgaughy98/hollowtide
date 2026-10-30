"""What moves between window stills (pass 9 rooms lane, R5 / H9-33; Claude, 2026-10-27).
python -I motion.py out.png still1.png still2.png ...
Each pair of stills in order is compared on an 8 px grid: a cell moves when more than 10% of its pixels changed by more
than 24 in any channel. A pair whose moving cells cover more than 15% of the frame is a camera move and is skipped.
The rest are joined into boxes (cells touching), and each box is printed with the pairs it moved in. out.png is a
contact sheet: 12 of the still pairs that moved, spread over the run, each later still with its moving boxes drawn in red. Reads the stills only."""
import sys
from PIL import Image, ImageChops, ImageDraw

CELL = 8


def moving_cells(a, b):
    d = ImageChops.difference(a, b).convert("L").point(lambda v: 255 if v > 24 else 0)
    w, h = d.size
    cells = set()
    px = d.load()
    for cy in range(0, h, CELL):
        for cx in range(0, w, CELL):
            n = 0
            for y in range(cy, min(cy + CELL, h)):
                for x in range(cx, min(cx + CELL, w), 2):
                    if px[x, y]:
                        n += 1
            if n > CELL * CELL * 0.1 / 2:
                cells.add((cx // CELL, cy // CELL))
    return cells, (w // CELL) * (h // CELL)


def boxes(cells):
    left = set(cells)
    out = []
    while left:
        stack = [left.pop()]
        group = []
        while stack:
            c = stack.pop()
            group.append(c)
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    n = (c[0] + dx, c[1] + dy)
                    if n in left:
                        left.remove(n)
                        stack.append(n)
        xs = [g[0] for g in group]
        ys = [g[1] for g in group]
        out.append((min(xs) * CELL, min(ys) * CELL, (max(xs) + 1) * CELL, (max(ys) + 1) * CELL, len(group)))
    return sorted(out, key=lambda b: -b[4])


def main():
    out_path = sys.argv[1]
    paths = sys.argv[2:]
    ims = [Image.open(p).convert("RGB") for p in paths]
    still_pairs = []
    camera = 0
    for i in range(1, len(ims)):
        cells, total = moving_cells(ims[i - 1], ims[i])
        if len(cells) > total * 0.15:
            camera += 1
            continue
        bx = [b for b in boxes(cells) if b[4] >= 2]
        still_pairs.append((i, bx))
        name = paths[i].replace("\\", "/").split("/")[-1]
        print("%s: %d moving cells, boxes %s" % (name, len(cells), ", ".join("(%d,%d)-(%d,%d)x%d" % b for b in bx[:6])))
    print("%d pairs, %d camera moves skipped, %d compared" % (len(ims) - 1, camera, len(still_pairs)))
    moved = [p for p in still_pairs if p[1]]
    pick = [moved[int(k * len(moved) / 12)] for k in range(min(12, len(moved)))]   # spread over the whole run
    if not pick:
        return
    tw, th = 384, 216
    sheet = Image.new("RGB", (tw * 3, th * ((len(pick) + 2) // 3)), (16, 16, 16))
    for k, (i, bx) in enumerate(pick):
        im = ims[i].copy()
        dr = ImageDraw.Draw(im)
        for b in bx[:8]:
            dr.rectangle(b[:4], outline=(255, 40, 40), width=3)
        sheet.paste(im.resize((tw, th)), ((k % 3) * tw, (k // 3) * th))
    sheet.save(out_path)
    print("sheet " + out_path)


main()
