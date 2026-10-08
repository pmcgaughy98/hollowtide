"""Lock a generated back view to its front view's art rules (Claude, 2026-10-06).

  python tools/unity_port/finish_back.py <front.png> <back.png> <out.png>

The AI only gives the back its shape. This makes the rest match the front exactly:
  1. brightness: the back's overall brightness is scaled to the front's;
  2. colours: every pixel is replaced by the nearest of the front's own colours,
     so the back cannot use a colour the front does not have;
  3. outline: every pixel on the silhouette edge becomes the front's outline colour;
  4. canvas: the back is placed on the front's canvas, feet on the front's foot row,
     with no resizing (resizing pixel art blurs or breaks it).
Prints the before and after numbers from sprite_study.py.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from sprite_study import lum, study  # noqa: E402


def edge_of(on):
    pad = np.pad(on, 1)
    return on & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])


def nearest(rgb, palette):
    """Nearest palette colour by 'redmean' distance, a cheap perceptual weighting."""
    p = palette.astype(float)[None, :, :]
    c = rgb.astype(float)[:, None, :]
    rmean = (c[..., 0] + p[..., 0]) / 2
    d = (2 + rmean / 256) * (c[..., 0] - p[..., 0]) ** 2 + 4 * (c[..., 1] - p[..., 1]) ** 2 \
        + (2 + (255 - rmean) / 256) * (c[..., 2] - p[..., 2]) ** 2
    return palette[d.argmin(axis=1)]


def main():
    front_p, back_p, out_p = sys.argv[1], sys.argv[2], sys.argv[3]
    front = np.array(Image.open(front_p).convert("RGBA")).astype(int)
    back = np.array(Image.open(back_p).convert("RGBA")).astype(int)
    f_on, b_on = front[..., 3] > 0, back[..., 3] > 0

    rgb = back[..., :3].astype(float)
    rgb[b_on] *= lum(front[..., :3][f_on]).mean() / max(1.0, lum(back[..., :3][b_on]).mean())
    rgb = np.clip(rgb, 0, 255)

    f_edge = edge_of(f_on)
    outline = np.median(front[..., :3][f_edge & (lum(front[..., :3]) < 40)], axis=0).astype(int)
    palette = np.unique(front[..., :3][f_on], axis=0)
    out = np.zeros_like(back)
    out[b_on, :3] = nearest(rgb[b_on].astype(int), palette)
    out[b_on, 3] = 255
    out[edge_of(b_on), :3] = outline

    ys, xs = np.nonzero(b_on)
    body = out[ys.min(): ys.max() + 1, xs.min(): xs.max() + 1]
    fy = np.nonzero(f_on)[0].max()
    canvas = np.zeros_like(front)
    top = fy - body.shape[0] + 1
    left = (front.shape[1] - body.shape[1]) // 2
    canvas[top: top + body.shape[0], left: left + body.shape[1]] = body
    Image.fromarray(canvas.astype(np.uint8)).save(out_p)
    for name, p in (("front", front_p), ("back before", back_p), ("back after", out_p)):
        print(f"{name:12s}", study(p))


if __name__ == "__main__":
    main()
