"""Turn eight creature renders into sprites at the dungeon's size (Claude, 2026-10-12, the sprites-in-3D workshop).

For each view: crop to the opaque pixels, scale so the tallest view is `height` px (one scale for all eight, so
the views keep their relative sizes), snap colours to the creature's own palette (every colour in its existing
sprite set, so the result sits in the game's palette), stand it on a common feet row in a square canvas, and
write <dir>.png. Then a contact sheet beside the existing sprites (top row the renders, bottom row the game's
own views, both at 4x) and the measurement table from measure_views.py.

    python tools/art/pixelize_views.py <renders_dir> <out_dir> --height 37 --palette assets/sprites/arena/kithflare/dungeon --compare assets/sprites/arena/kithflare/dungeon
"""
import os, sys
import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(__file__))
from measure_views import DIRS, measure

MARGIN = 2


def arg(name, default):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def palette_of(folder):
    cols = set()
    for d in DIRS:
        p = os.path.join(folder, d + ".png")
        if os.path.exists(p):
            im = np.asarray(Image.open(p).convert("RGBA"))
            cols |= {tuple(c) for c in im[im[:, :, 3] > 64][:, :3].tolist()}
    return np.array(sorted(cols), dtype=np.float32)


def snap(rgb, pal):
    flat = rgb.reshape(-1, 3).astype(np.float32)
    out = np.empty_like(flat)
    for i in range(0, len(flat), 4096):
        chunk = flat[i:i + 4096]
        d = ((chunk[:, None, :] - pal[None, :, :]) ** 2).sum(2)
        out[i:i + 4096] = pal[d.argmin(1)]
    return out.reshape(rgb.shape).astype(np.uint8)


def main():
    src, out = sys.argv[1], sys.argv[2]
    height = int(arg("--height", 37))
    pal_dir = arg("--palette", None)
    cmp_dir = arg("--compare", None)
    os.makedirs(out, exist_ok=True)
    crops = {}
    for d in DIRS:
        p = os.path.join(src, d + ".png")
        if not os.path.exists(p):
            continue
        im = Image.open(p).convert("RGBA")
        a = np.asarray(im)[:, :, 3] > 64
        ys, xs = np.where(a)
        crops[d] = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    tallest = max(c.size[1] for c in crops.values())
    scale = height / float(tallest)
    pal = palette_of(pal_dir) if pal_dir else None
    sprites = {}
    for d, c in crops.items():
        w = max(1, int(round(c.size[0] * scale)))
        h = max(1, int(round(c.size[1] * scale)))
        small = c.resize((w, h), Image.BOX)
        arr = np.asarray(small).copy()
        alpha = arr[:, :, 3] > 100
        arr[:, :, 3] = np.where(alpha, 255, 0)
        if pal is not None and len(pal):
            arr[:, :, :3] = np.where(alpha[:, :, None], snap(arr[:, :, :3], pal), 0)
        sprites[d] = Image.fromarray(arr)
    canvas = height + MARGIN * 2
    cw = max(canvas, max(s.size[0] for s in sprites.values()) + MARGIN * 2)
    for d, s in sprites.items():
        img = Image.new("RGBA", (cw, canvas), (0, 0, 0, 0))
        img.paste(s, ((cw - s.size[0]) // 2, canvas - MARGIN - s.size[1]))
        img.save(os.path.join(out, d + ".png"))
    # The contact sheet: renders above, the game's own views below, 4x.
    z = 4
    rows = 2 if cmp_dir else 1
    sheet = Image.new("RGBA", (len(DIRS) * (cw * z + 8) + 8, rows * (canvas * z + 20) + 8), (40, 40, 44, 255))
    draw = ImageDraw.Draw(sheet)
    for i, d in enumerate(DIRS):
        x = 8 + i * (cw * z + 8)
        if d in sprites:
            img = Image.open(os.path.join(out, d + ".png")).resize((cw * z, canvas * z), Image.NEAREST)
            sheet.paste(img, (x, 20), img)
        draw.text((x, 4), d, fill=(230, 230, 230, 255))
        if cmp_dir:
            p = os.path.join(cmp_dir, d + ".png")
            if os.path.exists(p):
                g = Image.open(p).convert("RGBA")
                gz = g.resize((g.size[0] * z, g.size[1] * z), Image.NEAREST)
                sheet.paste(gz, (x, 20 + canvas * z + 20), gz)
    sheet.save(os.path.join(out, "contact.png"))
    m = measure(out)
    print("pixelized %d views to %d px tall (scale %.3f), canvas %dx%d, palette %s colours" % (len(sprites), height, scale, cw, canvas, len(pal) if pal is not None else "free"))
    print("  dir   h    w   feet  foot_x  area  colours")
    for d in DIRS:
        v = m["views"].get(d)
        if v:
            print("  %-3s %4d %4d  %4d  %5d  %5d  %5d" % (d, v["h"], v["w"], v["feet_row"], v["foot_x"], v["area"], v["colours"]))
    print("  height spread %d px; mirror IoU %s" % (m["height_spread"], m["mirror_iou"]))


if __name__ == "__main__":
    main()
