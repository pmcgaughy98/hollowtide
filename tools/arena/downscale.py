"""Shrink pixel art by a whole factor, keeping it crisp (Claude, 2026-10-07).
Each block of factor x factor art pixels becomes one pixel: transparent if most of the
block is empty, otherwise the block's most common colour (ties go to the darker one, so
outlines survive). This keeps hard edges and the palette, unlike smooth resizing.
  from downscale import shrink;  shrink(image, 3)"""
from collections import Counter
import numpy as np
from PIL import Image


def shrink(im: Image.Image, f: int) -> Image.Image:
    a = np.array(im.convert("RGBA"))
    h, w = a.shape[0] // f, a.shape[1] // f
    out = np.zeros((h, w, 4), np.uint8)
    for y in range(h):
        for x in range(w):
            block = a[y * f:(y + 1) * f, x * f:(x + 1) * f].reshape(-1, 4)
            solid = block[block[:, 3] > 0]
            if len(solid) * 2 < len(block):
                continue
            counts = Counter(map(tuple, solid))
            top = max(counts.values())
            best = min((c for c, n in counts.items() if n == top), key=lambda c: int(c[0]) + int(c[1]) + int(c[2]))
            out[y, x] = best
    return Image.fromarray(out)


def resample(im: Image.Image, f: float) -> Image.Image:
    """Shrink by any factor (Claude, 2026-10-08, for Preston's size fix): a smooth resize to
    the target size, then every pixel is snapped back to the nearest colour the source
    already uses and the alpha is hardened, so the palette and the hard edges survive."""
    im = im.convert("RGBA")
    src = np.array(im)
    solid = src[src[:, :, 3] > 0][:, :3]
    palette = np.unique(solid, axis=0).astype(int)
    tw, th = max(1, round(im.width / f)), max(1, round(im.height / f))
    small = np.array(im.resize((tw, th), Image.LANCZOS)).astype(int)
    out = np.zeros((th, tw, 4), np.uint8)
    mask = small[:, :, 3] >= 128
    rgb = small[:, :, :3][mask]
    if len(rgb):
        # nearest palette colour, weighted a little toward red (the "redmean" distance)
        d = ((rgb[:, None, :] - palette[None, :, :]) ** 2)
        d = d[:, :, 0] * 2 + d[:, :, 1] * 4 + d[:, :, 2] * 3
        out[mask, :3] = palette[d.argmin(axis=1)]
        out[mask, 3] = 255
    return Image.fromarray(out)

