"""Remove magenta spill from converted Forge art.

Preston (2026-09-29): Opal draws on a flat magenta background, and converted
frames keep some of it: outline pixels tinted magenta, like (20,4,20) or
(28,4,28), where the dark edge blended with the background, and pale pink or
lilac halos where a glow was drawn over it.

A pixel counts as spill only if it has the background's signature:
  - magenta cast: red and blue about equal and green far below both, or
  - pink tint: red and blue both well above green (a glow blended with magenta).
Real purples are not spill: Vitrecrag's plum shell, like (76,44,60) or
(124,84,100), keeps plenty of green and fails both tests.

Each spill pixel has the magenta taken out (red and blue brought down toward
green by the same amount), then is snapped to the nearest colour the image
uses that is not spill. A spill pixel on the outer edge that is still light
after that is a halo fringe and is removed instead, so the outline stays and
the pink rim goes.

  python tools/clean_spill.py --check <png or folder>...   report only
  python tools/clean_spill.py --apply <png or folder>...   clean in place
"""
import sys
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image

CAST_RB_MATCH = 24     # red and blue within this of each other
CAST_GREEN = 0.45      # and green at most this fraction of the smaller one
CAST_FLOOR = 12        # ignore near-black pixels below this
TINT_RED, TINT_BLUE = 25, 30  # pink tint: red and blue this far above green
FRINGE_LIGHT = 70      # edge spill brighter than this (after despill) is removed


def spill_mask(a):
    r, g, b = (a[..., i].astype(int) for i in range(3))
    lo = np.minimum(r, b)
    cast = (np.abs(r - b) <= CAST_RB_MATCH) & (g <= CAST_GREEN * lo) & (lo >= CAST_FLOOR)
    tint = (r > g + TINT_RED) & (b > g + TINT_BLUE)
    return (cast | tint) & (a[..., 3] > 0)


def edge_mask(a):
    clear = np.pad(a[..., 3] == 0, 1, constant_values=True)
    return (a[..., 3] > 0) & (clear[:-2, 1:-1] | clear[2:, 1:-1] | clear[1:-1, :-2] | clear[1:-1, 2:])


def clean(a):
    """Returns the cleaned RGBA array and how many pixels were recoloured and removed."""
    a = a.copy()
    spill = spill_mask(a)
    if not spill.any():
        return a, 0, 0
    keep = (a[..., 3] > 0) & ~spill
    palette = np.unique(a[keep][:, :3], axis=0).astype(int) if keep.any() else None
    px = a[spill][:, :3].astype(int)
    m = np.clip(np.minimum(px[:, 0], px[:, 2]) - px[:, 1], 0, None)
    px[:, 0] -= m
    px[:, 2] -= m
    fringe = edge_mask(a)[spill] & (px.max(1) > FRINGE_LIGHT)
    if palette is not None:
        px = palette[((px[:, None, :] - palette[None]) ** 2).sum(-1).argmin(1)]
    ys, xs = np.where(spill)
    a[ys, xs, :3] = px
    a[ys[fringe], xs[fringe]] = 0
    return a, int((~fringe).sum()), int(fringe.sum())


def files(args):
    for arg in args:
        p = Path(arg)
        yield from (sorted(p.rglob("*.png")) if p.is_dir() else [p])


def main():
    apply = "--apply" in sys.argv
    for path in files([x for x in sys.argv[1:] if not x.startswith("--")]):
        a = np.asarray(Image.open(path).convert("RGBA"))
        spill = spill_mask(a)
        if not spill.any():
            continue
        top = Counter(tuple(int(v) for v in p) for p in a[spill][:, :3]).most_common(4)
        if apply:
            out, recoloured, removed = clean(a)
            Image.fromarray(out, "RGBA").save(path)
            print(f"{path}: {recoloured} recoloured, {removed} removed")
        else:
            print(f"{path}: {int(spill.sum())} spill px, e.g. {top}")


if __name__ == "__main__":
    main()
