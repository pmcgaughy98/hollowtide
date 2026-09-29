"""Recolor Ironvent's pale bone-colored head to match the Cinderhide line.

Preston (2026-09-29): Ironvent's head should be dark like Cinderhide's and
Clinkerhide's, not bone-colored. This is a recolor, not a redraw: each of the
head's bone shades is swapped for one of Clinkerhide's head charcoals, lightest
to lightest and darkest to darkest, so the head keeps its shading and detail.

Only pixels in the head area are touched (the right part of the art, where the
head faces, and not the lower body), so the belly and claws keep their browns.
Ironvent's attack frames are snapped to the in-game palette, so the same six
shades appear in them and the same swap works everywhere.

  python tools/recolor_ironvent_head.py --preview out.png      before/after of the in-game sprite
  python tools/recolor_ironvent_head.py --apply                 recolor every Ironvent image in place
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent

# Ironvent bone shade -> Clinkerhide head charcoal, lightest first.
SWAP = {
    (0xB4, 0xA4, 0x84): (0x6C, 0x6C, 0x6C),
    (0xA4, 0x94, 0x84): (0x5C, 0x5C, 0x5C),
    (0x9C, 0x8C, 0x74): (0x4C, 0x4C, 0x4C),
    (0x8C, 0x84, 0x6C): (0x4C, 0x4C, 0x4C),
    (0x84, 0x74, 0x64): (0x3C, 0x3C, 0x3C),
    (0x7C, 0x64, 0x54): (0x2C, 0x2C, 0x2C),
}
HEAD_FROM_X = 0.60   # the head area starts this far across the art (it faces right)
HEAD_TO_Y = 0.75     # and ends this far down the art, above the belly and feet

FILES = [
    "assets/sprites/creatures/ironvent.png",
    "assets/sprites/creatures/attacks/ironvent_furnace_roar/built/*.png",
]
# Sheets of frames side by side, with their frame width: each frame is its own
# creature, so the head area is found per frame (Cinder Claw's six-frame sheet).
SHEETS = {
    "assets/sprites/creatures/ironvent_claw_6.png": 100,
}


def recolor_sheet(img, frame_w):
    out = img.convert("RGBA").copy()
    total = 0
    for x in range(0, out.width, frame_w):
        frame, n = recolor(out.crop((x, 0, x + frame_w, out.height)))
        out.paste(frame, (x, 0))
        total += n
    return out, total


def recolor(img):
    a = np.asarray(img.convert("RGBA")).copy()
    ys, xs = np.where(a[..., 3] > 0)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    head_x = x0 + (x1 - x0) * HEAD_FROM_X
    head_y = y0 + (y1 - y0) * HEAD_TO_Y
    changed = 0
    for src, dst in SWAP.items():
        m = (a[..., 0] == src[0]) & (a[..., 1] == src[1]) & (a[..., 2] == src[2]) & (a[..., 3] > 0)
        m[:, :int(head_x)] = False
        m[int(head_y) + 1:, :] = False
        a[m, :3] = dst
        changed += int(m.sum())
    return Image.fromarray(a, "RGBA"), changed


def main():
    if "--preview" in sys.argv:
        dest = sys.argv[sys.argv.index("--preview") + 1]
        before = Image.open(ROOT / FILES[0]).convert("RGBA")
        after, n = recolor(before)
        tiles = []
        for im in (before, after):
            bg = Image.new("RGBA", im.size, (58, 74, 82, 255))
            bg.alpha_composite(im)
            tiles.append(bg.resize((im.width * 5, im.height * 5), Image.NEAREST))
        sheet = Image.new("RGBA", (tiles[0].width * 2 + 10, tiles[0].height), (0, 0, 0, 255))
        sheet.paste(tiles[0], (0, 0))
        sheet.paste(tiles[1], (tiles[0].width + 10, 0))
        sheet.save(dest)
        print("preview:", n, "pixels recolored")
    if "--apply-sheets" in sys.argv:
        for rel, frame_w in SHEETS.items():
            img, n = recolor_sheet(Image.open(ROOT / rel), frame_w)
            img.save(ROOT / rel)
            print(rel, n, "pixels")
    if "--apply" in sys.argv:
        for rel, frame_w in SHEETS.items():
            img, n = recolor_sheet(Image.open(ROOT / rel), frame_w)
            img.save(ROOT / rel)
            print(rel, n, "pixels")
        for pattern in FILES:
            for path in sorted(ROOT.glob(pattern)):
                img, n = recolor(Image.open(path))
                img.save(path)
                print(path.relative_to(ROOT), n, "pixels")


if __name__ == "__main__":
    main()
