"""Measure a creature sprite's art properties (Claude, 2026-10-06), so a back view can
be held to the front view's numbers.
  python tools/unity_port/sprite_study.py <png> [<png> ...]
Per image: canvas, painted size, colour count, outline (how much of the silhouette edge
is a dark line, and its colour), light direction (top-left vs bottom-right brightness),
pixel noise (share of lone pixels that match none of their 4 neighbours), and alpha."""
import sys
import numpy as np
from PIL import Image


def lum(rgb):
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


def study(path):
    a = np.array(Image.open(path).convert("RGBA")).astype(int)
    alpha = a[..., 3]
    on = alpha > 0
    ys, xs = np.nonzero(on)
    rgb = a[..., :3]
    cols = {tuple(c) for c in rgb[on]}
    partial = ((alpha > 0) & (alpha < 255)).sum()
    # silhouette edge: painted pixels with an empty 4-neighbour
    pad = np.pad(on, 1)
    edge = on & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    L = lum(rgb)
    inner_mean = L[on & ~edge].mean()
    dark_edge = (L[edge] < inner_mean * 0.55).mean()
    edge_cols = rgb[edge][L[edge] < inner_mean * 0.55]
    outline = tuple(np.median(edge_cols, axis=0).astype(int)) if len(edge_cols) else None
    # light: mean brightness of the top-left vs bottom-right half of the body (diagonal split)
    cx, cy = xs.mean(), ys.mean()
    yy, xx = np.mgrid[: a.shape[0], : a.shape[1]]
    tl = on & ((xx - cx) + (yy - cy) < 0)
    br = on & ((xx - cx) + (yy - cy) > 0)
    # noise: interior pixels whose colour matches none of the 4 neighbours
    c = rgb[..., 0] * 65536 + rgb[..., 1] * 256 + rgb[..., 2]
    cp = np.pad(c, 1, constant_values=-1)
    lone = on & ~edge & (cp[:-2, 1:-1] != c) & (cp[2:, 1:-1] != c) & (cp[1:-1, :-2] != c) & (cp[1:-1, 2:] != c)
    w, h = xs.max() - xs.min() + 1, ys.max() - ys.min() + 1
    return {
        "canvas": a.shape[1], "painted": f"{w}x{h}", "colours": len(cols), "soft_alpha_px": int(partial),
        "outline_share": round(float(dark_edge), 2), "outline_rgb": outline,
        "light_tl_minus_br": round(float(L[tl].mean() - L[br].mean()), 1),
        "lone_px_%": round(100 * lone.sum() / max(1, (on & ~edge).sum()), 1),
        "mean_lum": round(float(L[on].mean()), 1),
    }


if __name__ == "__main__":
    for p in sys.argv[1:]:
        print(p.split("/")[-1], study(p))
