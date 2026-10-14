"""Finish a generated sprite to the game's pixel discipline and check it (Claude, 2026-10-13; the sprite-generator
skill-up, docs/design/sprite-generator-skillup-2026-10-13.md).

The exam showed that a pixel-art model repainting a view with our own sprites as style references reaches the
game's level, and that what it lacks is discipline: soft edges, thousands of colours, noise. This does the finish
and then lints the result with PixelLab's pixel-art rules (pixelart_workbench `describe lint_rules`), measured here:

  1. alpha to 0 or 255 at a cutoff (no partial alpha)
  2. optional scale to a target height (box filter, then everything below re-quantizes)
  3. palette: snap to a creature's own colours (--palette DIR or PNG), or pick the image's own (median cut)
  4. colour budget: merge the least-used colour into its nearest neighbour until --budget remain
  5. noise: remove orphan pixels, recolour 1-2 pixel same-colour clusters to their neighbours (glints kept)
  6. outline: silhouette edge pixels to the darkest colour (--outline auto), or sel-out for small sets
  7. place bottom-centred on the game's canvas (--canvas 128x128 --feet 102)
Then it prints the gates: colours, off-palette, partial alpha, orphan pixels, orphan clusters, outline gaps,
doubles, border contact, cluster size, stray share, and shape match to a --compare sprite.

    python tools/art/finish_sprite.py raw.png out.png --palette assets/sprites/arena/kithflare --budget 20 \
        --height 78 --canvas 128x128 --feet 102 --compare assets/sprites/arena/kithflare/se.png
"""
import argparse
import glob
import os
from collections import deque
import numpy as np
from PIL import Image


def load_palette(src):
    """The creature's colours, and the colour its own sprites put on their silhouette edges (its outline)."""
    files = glob.glob(os.path.join(src, "*.png")) if os.path.isdir(src) else [src]
    cols, edge = {}, {}
    for f in files:
        a = np.array(Image.open(f).convert("RGBA"))
        m = a[..., 3] > 64
        for c in a[m][:, :3].tolist():
            cols[tuple(c)] = cols.get(tuple(c), 0) + 1
        idx = np.where(m, 0, -1)
        for c in a[edge_mask(idx)][:, :3].tolist():
            edge[tuple(c)] = edge.get(tuple(c), 0) + 1
    pal = np.array(sorted(cols), float)
    line = max(edge, key=edge.get) if edge else None
    return pal, line


def components(idx, same_colour=True):
    """4-connected regions: same colour (same_colour) or any opaque. Returns a label grid and sizes."""
    H, W = idx.shape
    lab = np.full((H, W), -1, int)
    sizes = []
    for y in range(H):
        for x in range(W):
            if idx[y, x] < 0 or lab[y, x] >= 0:
                continue
            k = len(sizes)
            q = deque([(y, x)])
            lab[y, x] = k
            n = 0
            while q:
                cy, cx = q.popleft()
                n += 1
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < H and 0 <= nx < W and lab[ny, nx] < 0 and idx[ny, nx] >= 0 and (not same_colour or idx[ny, nx] == idx[cy, cx]):
                        lab[ny, nx] = k
                        q.append((ny, nx))
            sizes.append(n)
    return lab, sizes


def edge_mask(idx):
    solid = idx >= 0
    pad = np.pad(solid, 1)
    inner = pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
    return solid & ~inner


def finish(args):
    img = Image.open(args.raw).convert("RGBA")
    a = np.array(img)
    m = a[..., 3] >= args.alpha
    ys, xs = np.where(m)
    img = img.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    if args.height:
        w = max(1, round(img.width * args.height / img.height))
        rgb = img.convert("RGB").resize((w, args.height), Image.BOX)
        al = img.getchannel("A").resize((w, args.height), Image.BOX)
        img = Image.merge("RGBA", (*rgb.split(), al))
    a = np.array(img).astype(float)
    m = a[..., 3] >= args.alpha
    line_rgb = None
    if args.palette:
        pal, line_rgb = load_palette(args.palette)
    else:
        q = Image.fromarray(a[..., :3].astype(np.uint8)).quantize(colors=max(args.budget * 2, 16), method=Image.Quantize.MEDIANCUT)
        p = np.array(q.getpalette()[: 3 * max(args.budget * 2, 16)], float).reshape(-1, 3)
        # pass 7: picking colours by area loses the few-pixel accents (an eye glint, rust on a claw tip); the
        # image's brightest colour and its three most saturated ones always join the palette
        px = a[m][:, :3]
        satp = px.max(1) - px.min(1)          # chroma: a ratio would rank near-blacks as the most saturated
        extra = [px[px.sum(1).argmax()]] + [px[i] for i in np.argsort(-satp)[:3]]
        pal = np.vstack([p, np.array(extra, float)])
    d = ((a[..., None, :3] - pal[None, None]) ** 2).sum(-1)
    idx = np.where(m, d.argmin(-1), -1)
    # the colour budget: fold the least-used colour into its nearest remaining neighbour
    # pass 5: the accents a pixel artist would keep (the darkest, the brightest, the three most saturated) are never
    # folded away, even though they are the least used: they are the eye, the glints and the claw tips
    used0 = np.unique(idx[idx >= 0])
    sat = pal.max(1) - pal.min(1)              # chroma, as above
    keep = {int(used0[pal[used0].sum(1).argmin()]), int(used0[pal[used0].sum(1).argmax()])}
    keep |= {int(u) for u in used0[np.argsort(-sat[used0])[:3]]}
    while args.budget:
        used, counts = np.unique(idx[idx >= 0], return_counts=True)
        if len(used) <= args.budget:
            break
        order = [u for u in used[np.argsort(counts)] if int(u) not in keep] or list(used[np.argsort(counts)])
        least = order[0]
        rest = used[used != least]
        near = rest[((pal[rest] - pal[least]) ** 2).sum(1).argmin()]
        idx[idx == least] = near
    lum = pal.sum(1)
    used = np.unique(idx[idx >= 0])
    glint = used[lum[used].argmax()]
    darkest = used[lum[used].argmin()]
    if line_rgb is not None:                       # pass 2: the outline the creature's own sprites use
        darkest = int(((pal - np.array(line_rgb, float)) ** 2).sum(1).argmin())
    H, W = idx.shape
    # pass 3: the outline goes on first, then the noise is cleaned around it
    if args.outline == "auto":
        idx[edge_mask(idx)] = darkest
    elif args.outline == "selout":
        e = edge_mask(idx)
        for y, x in zip(*np.where(e)):
            c = pal[idx[y, x]]
            darker = [u for u in used if lum[u] < lum[idx[y, x]] - 60]
            if darker:
                idx[y, x] = min(darker, key=lambda u: ((pal[u] - c * 0.55) ** 2).sum())
    edge0 = edge_mask(idx)
    for _ in range(6):                             # pass 2: until nothing changes, not a fixed two
        before = idx.copy()
        # orphan pixels: nothing opaque beside them
        solid = idx >= 0
        for y in range(H):
            for x in range(W):
                if solid[y, x] and not any(0 <= yy < H and 0 <= xx < W and solid[yy, xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))):
                    idx[y, x] = -1
        # 1-2 pixel clusters inside the sprite take their neighbours' colour (a glint stays)
        lab, sizes = components(idx)
        for y in range(H):
            for x in range(W):
                if idx[y, x] < 0 or sizes[lab[y, x]] > 2 or idx[y, x] == glint:
                    continue
                if idx[y, x] == darkest and edge0[y, x]:   # the outline itself stays
                    continue
                nb = [idx[yy, xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)) if 0 <= yy < H and 0 <= xx < W and idx[yy, xx] >= 0 and idx[yy, xx] != idx[y, x] and idx[yy, xx] != darkest]
                if nb:   # pass 4: the neighbour closest in colour keeps the form; the most common one flattens it
                    best = min(set(nb), key=lambda u: ((pal[u] - pal[idx[y, x]]) ** 2).sum())
                    # pass 6: speckle is a patch nearly the colour of its neighbours; a line, a glint or a claw tip
                    # stands out from them, so a patch that contrasts is detail and stays
                    if np.sqrt(((pal[best] - pal[idx[y, x]]) ** 2).sum()) <= args.speckle:
                        idx[y, x] = best
        if (idx == before).all():
            break
    out = np.zeros((H, W, 4), np.uint8)
    on = idx >= 0
    out[on, :3] = pal[idx[on]].astype(np.uint8)
    out[on, 3] = 255
    sprite = Image.fromarray(out, "RGBA")
    if args.canvas:
        cw, ch = (int(v) for v in args.canvas.lower().split("x"))
        canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        feet = args.feet if args.feet else ch - 2
        canvas.alpha_composite(sprite, (int(round(cw / 2 - W / 2)), int(feet + 1 - H)))
        sprite = canvas
    sprite.save(args.out)
    report = gates(np.array(sprite), pal if args.palette else None, args.compare, darkest_rgb=tuple(pal[darkest].astype(int)))
    print("finished %s: %dx%d" % (args.out, sprite.width, sprite.height))
    for k, v in report.items():
        print("  %-16s %s" % (k, v))
    return report


def gates(a, pal, compare, darkest_rgb):
    m = a[..., 3] > 0
    key = np.where(m, a[..., 0].astype(int) * 65536 + a[..., 1].astype(int) * 256 + a[..., 2], -1)
    ids = {k: i for i, k in enumerate(np.unique(key[m]))}
    idx = np.where(m, np.vectorize(lambda k: ids.get(k, -1))(key), -1)
    lab, sizes = components(idx)
    H, W = idx.shape
    e = edge_mask(idx)
    dk = darkest_rgb[0] * 65536 + darkest_rgb[1] * 256 + darkest_rgb[2]
    orphans = sum(1 for y, x in zip(*np.where(m)) if not any(0 <= yy < H and 0 <= xx < W and m[yy, xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))))
    small = sum(1 for s in sizes if s <= 2)
    stray = sum(1 for y, x in zip(*np.where(m)) if all(not (0 <= yy < H and 0 <= xx < W) or idx[yy, xx] != idx[y, x] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))))
    out_line = (key == dk) & e
    doubles = 0
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            if out_line[y, x] and ((out_line[y, x - 1] and out_line[y - 1, x] and not out_line[y - 1, x - 1]) or (out_line[y, x + 1] and out_line[y - 1, x] and not out_line[y - 1, x + 1])):
                doubles += 1
    rep = {
        "colours": len(ids),
        "off_palette": (sum(1 for k in ids if pal is None or not ((pal - np.array([k >> 16, (k >> 8) & 255, k & 255])) ** 2).sum(1).min() == 0)) if pal is not None else "n/a",
        "partial_alpha": int(((a[..., 3] > 0) & (a[..., 3] < 255)).sum()),
        "orphan_pixels": orphans,
        "orphan_clusters": small,
        "outline_gaps": "%d of %d edge pixels" % (int((e & (key != dk)).sum()), int(e.sum())),
        "doubles": doubles,
        "border_contact": int(m[0].sum() + m[-1].sum() + m[:, 0].sum() + m[:, -1].sum()),
        "cluster_mean": round(float(np.mean(sizes)), 1),
        "stray_share": "%d%%" % round(100 * stray / max(1, m.sum())),
    }
    if compare:
        import sys
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        from kithflare_model import shape_iou
        rep["shape_vs_compare"] = round(shape_iou(m, np.array(Image.open(compare).convert("RGBA"))[..., 3] > 64), 3)
    return rep


def main():
    p = argparse.ArgumentParser()
    p.add_argument("raw")
    p.add_argument("out")
    p.add_argument("--palette")
    p.add_argument("--budget", type=int, default=0)
    p.add_argument("--alpha", type=int, default=128)
    p.add_argument("--height", type=int, default=0)
    p.add_argument("--outline", default="auto", choices=["auto", "selout", "none"])
    p.add_argument("--canvas")
    p.add_argument("--feet", type=int, default=0)
    p.add_argument("--compare")
    p.add_argument("--speckle", type=float, default=45.0, help="a 1-2 pixel patch closer than this to its neighbours is noise")
    finish(p.parse_args())


if __name__ == "__main__":
    main()
