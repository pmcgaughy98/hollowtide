"""Gemini image API for sprites, plus a snapper back to the pixel grid (Claude, 2026-10-14).

Same route that made Ballastak through SpriteCook (Nano Banana with our own sprites as references), called directly.
The raw API returns soft, enlarged "pixel art" on a background, so `snap` finds the real art-pixel size from where
colour edges line up, takes each block's median colour, and removes the background by filling in from the border.

    gen   --prompt "..." --ref a.png [--ref b.png] [--ref-scale 8] [--model gemini-3.1-flash-image] [--size 1K] --out raw.png
    snap  raw.png out.png [--place]        --place puts a single creature bottom-centred on the 128 canvas, feet on row 104

The key is read from the Gemini MCP entry in ~/.claude.json and is never printed.
"""
import argparse
import base64
import io
import json
import os
import urllib.request
from collections import deque
import numpy as np
from PIL import Image

API = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent"


def key():
    cfg = json.load(open(os.path.expanduser("~/.claude.json"), encoding="utf-8"))
    return cfg["mcpServers"]["gemini"]["env"]["GEMINI_API_KEY"]


def ref_png(path, scale):
    """A reference sprite cropped to the creature, on white, enlarged by a whole number (nearest), as PNG bytes."""
    im = Image.open(path).convert("RGBA")
    box = im.getchannel("A").point(lambda a: 255 if a > 64 else 0).getbbox()
    im = im.crop(box)
    pad = 6
    bg = Image.new("RGBA", (im.width + 2 * pad, im.height + 2 * pad), (255, 255, 255, 255))
    bg.alpha_composite(im, (pad, pad))
    bg = bg.convert("RGB").resize((bg.width * scale, bg.height * scale), Image.NEAREST)
    buf = io.BytesIO()
    bg.save(buf, "PNG")
    return buf.getvalue()


def gen(a):
    parts = [{"text": a.prompt}]
    for r in a.ref or []:
        parts.append({"inline_data": {"mime_type": "image/png", "data": base64.b64encode(ref_png(r, a.ref_scale)).decode()}})
    body = {"contents": [{"role": "user", "parts": parts}],
            "generationConfig": {"responseModalities": ["IMAGE"], "imageConfig": {"aspectRatio": "1:1", "imageSize": a.size}}}
    req = urllib.request.Request(API % a.model, data=json.dumps(body).encode(), method="POST",
                                 headers={"Content-Type": "application/json", "x-goog-api-key": key()})
    try:
        res = json.load(urllib.request.urlopen(req, timeout=300))
    except urllib.error.HTTPError as e:
        raise SystemExit("API error %d: %s" % (e.code, e.read().decode()[:400]))
    for c in res.get("candidates", []):
        for p in c.get("content", {}).get("parts", []):
            d = p.get("inlineData") or p.get("inline_data")
            if d:
                os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
                Image.open(io.BytesIO(base64.b64decode(d["data"]))).save(a.out)
                print("saved", a.out, Image.open(a.out).size, "| usage", res.get("usageMetadata", {}).get("totalTokenCount"))
                return
    raise SystemExit("no image returned: %s" % json.dumps(res)[:400])


def grid_scale(rgb, lo=3, hi=24):
    """Art-pixel size and phase. Colour edges pile up on block boundaries; for each candidate size, the share of
    edge strength on the best phase, times the size, is its lift over chance. Multiples of the true size tie with it
    and divisors score about half, so the smallest size near the top lift is the answer."""
    a = rgb.astype(np.int32)
    out = []
    for axis in (1, 0):
        d = np.abs(np.diff(a, axis=axis)).sum(-1)
        prof = d.sum(axis=1 - axis).astype(float)
        tot = prof.sum()
        lifts = {}
        for s in range(lo, hi + 1):
            sh = [prof[p::s].sum() / tot for p in range(s)]
            p = int(np.argmax(sh))
            lifts[s] = (sh[p] * s, (p + 1) % s)
        top = max(v[0] for v in lifts.values())
        s = min(k for k, v in lifts.items() if v[0] >= 0.85 * top)
        out.append((s, lifts[s][1], round(lifts[s][0], 2)))
    return out  # [(sx, phase_x, lift), (sy, phase_y, lift)]


def grid_scale_fractional(rgb, lo=3.0, hi=16.0, step=0.01):
    """Art-pixel size when it is not a whole number of image pixels (Opal's Nano Banana Pro sheets come back at
    about 4.5). Each colour edge is a point on a circle of circumference s; at the true size they all land
    together, so the resultant length R of their angles peaks. Halves of the true size tie with it and doubles
    fall away, so the largest size near the top R is the answer."""
    a = rgb.astype(np.int32)
    out = []
    for axis in (1, 0):
        prof = np.abs(np.diff(a, axis=axis)).sum(-1).sum(axis=1 - axis).astype(float)
        pos = np.arange(1, len(prof) + 1, dtype=float)       # the boundary after pixel i sits at i + 1
        sizes = np.arange(lo, hi, step)
        R, ph = [], []
        for s in sizes:
            z = (prof * np.exp(2j * np.pi * pos / s)).sum() / prof.sum()
            R.append(abs(z))
            ph.append((np.angle(z) / (2 * np.pi)) % 1 * s)
        R = np.array(R)
        best = max(i for i in range(len(sizes)) if R[i] >= 0.9 * R.max())
        out.append((float(sizes[best]), float(ph[best]), round(float(R[best]), 3)))
    return out


def snap(a):
    rgb = np.array(Image.open(a.raw).convert("RGB"))
    if a.scale:
        # No real grid (a finely drawn sheet): shrink by a chosen amount. Fold the image into a shared palette first,
        # then each output pixel takes the most common palette colour in its source area, so edges and outlines stay
        # crisp instead of averaging into mud.
        s = px = py = a.scale
        px = py = 0.0
        # the palette is built from the creature alone (background left out), so small accents such as moss, soil
        # and dark shot keep their own colours instead of being merged into the background's slots
        edge = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
        bg_full = np.median(edge, axis=0)
        is_bg = np.abs(rgb.astype(int) - bg_full).max(-1) <= a.tol
        fg = rgb[~is_bg]
        n = a.colours or 64
        q = Image.fromarray(fg[None, :, :]).quantize(colors=n, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
        pal = np.array(q.getpalette()[:3 * n], np.uint8).reshape(-1, 3)
        idx = np.full(rgb.shape[:2], n, np.int64)                  # n = background
        idx[~is_bg] = np.array(q)[0]
        H, W = int(rgb.shape[0] // s), int(rgb.shape[1] // s)
        small = np.zeros((H, W, 3), np.uint8)
        for y in range(H):
            y0, y1 = int(y * s), max(int(y * s) + 1, int((y + 1) * s))
            for x in range(W):
                x0, x1 = int(x * s), max(int(x * s) + 1, int((x + 1) * s))
                k = np.bincount(idx[y0:y1, x0:x1].ravel(), minlength=n + 1)
                if k[n] * 2 > k.sum():
                    small[y, x] = bg_full
                else:
                    small[y, x] = pal[k[:n].argmax()]
        if a.outline:
            # the 1-pixel dark outline the house style needs, in the creature's own darkest colour
            m = np.abs(small.astype(int) - bg_full).max(-1) > a.tol
            pad = np.pad(m, 1)
            rim = m & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
            dark = pal[np.argmin(pal.astype(int).sum(1))]
            small[rim] = dark
        a.colours = 0                                               # already folded above
        sx = sy = s
        lx = ly = 0.0
    elif a.fractional:
        (sx, px, lx), (sy, py, ly) = grid_scale_fractional(rgb)
        s = (sx + sy) / 2
        H, W = int((rgb.shape[0] - py) // s), int((rgb.shape[1] - px) // s)
        small = np.zeros((H, W, 3), np.uint8)
        for y in range(H):
            y0, y1 = int(py + (y + 0.25) * s), max(int(py + (y + 0.25) * s) + 1, int(py + (y + 0.75) * s))
            for x in range(W):
                x0, x1 = int(px + (x + 0.25) * s), max(int(px + (x + 0.25) * s) + 1, int(px + (x + 0.75) * s))
                small[y, x] = np.median(rgb[y0:y1, x0:x1].reshape(-1, 3), axis=0)
    else:
        (sx, px, lx), (sy, py, ly) = grid_scale(rgb)
        s = round((sx + sy) / 2)
        H, W = (rgb.shape[0] - py) // s, (rgb.shape[1] - px) // s
        blk = rgb[py:py + H * s, px:px + W * s].reshape(H, s, W, s, 3).transpose(0, 2, 1, 3, 4)
        m = 1 if s >= 5 else 0
        small = np.median(blk[:, :, m:s - m, m:s - m].reshape(H, W, -1, 3), axis=2).astype(np.uint8)
    # background: the border's colour, filled in from the edges until the outline stops it
    border = np.concatenate([small[0], small[-1], small[:, 0], small[:, -1]])
    bgc = np.median(border, axis=0)
    near = np.abs(small.astype(int) - bgc).max(-1) <= a.tol
    bg = np.zeros((H, W), bool)
    q = deque([(y, x) for y in range(H) for x in (0, W - 1)] + [(y, x) for x in range(W) for y in (0, H - 1)])
    while q:
        y, x = q.popleft()
        if 0 <= y < H and 0 <= x < W and not bg[y, x] and near[y, x]:
            bg[y, x] = True
            q.extend(((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)))
    if a.pockets:
        # background trapped between legs or under a tail never touches the border; the Forge forbids magenta on the
        # creature, so any pixel near the background colour is background wherever it sits
        bg |= np.abs(small.astype(int) - bgc).max(-1) <= a.tol
    if a.colours:
        # JPEG output (Opal) adds thousands of near-duplicate colours; fold them into one shared palette, no dither
        fg_idx = np.where(~bg)
        strip = Image.fromarray(small[fg_idx][None, :, :])
        q = strip.quantize(colors=a.colours, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
        small = small.copy()
        small[fg_idx] = np.array(q)[0]
    out = np.dstack([small, np.where(bg, 0, 255).astype(np.uint8)])
    img = Image.fromarray(out)
    if a.place:
        ys, xs = np.where(~bg)
        spr = img.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        c = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
        c.alpha_composite(spr, (int(round(64 - spr.width / 2)), 105 - spr.height))
        img = c
    img.save(a.out)
    fg = out[..., 3] > 0
    print("art pixel %s (x %s score %.2f, y %s score %.2f), grid %dx%d, creature px %d, colours %d -> %s" % (
        s, sx, lx, sy, ly, W, H, int(fg.sum()), len({tuple(c) for c in small[fg].tolist()}), a.out))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    g = sub.add_parser("gen")
    g.add_argument("--prompt", required=True)
    g.add_argument("--ref", action="append")
    g.add_argument("--ref-scale", type=int, default=8)
    g.add_argument("--model", default="gemini-3.1-flash-image")
    g.add_argument("--size", default="1K")
    g.add_argument("--out", required=True)
    s = sub.add_parser("snap")
    s.add_argument("raw")
    s.add_argument("out")
    s.add_argument("--place", action="store_true")
    s.add_argument("--tol", type=int, default=36)
    s.add_argument("--fractional", action="store_true", help="art pixel is not a whole number of image pixels (Opal sheets)")
    s.add_argument("--colours", type=int, default=0, help="fold JPEG noise into this many shared colours (0 keeps all)")
    s.add_argument("--scale", type=float, default=0, help="no real grid: shrink by this many image pixels per art pixel")
    s.add_argument("--pockets", action="store_true", help="also clear background-coloured pockets enclosed by the creature")
    s.add_argument("--outline", action="store_true", help="with --scale: redraw a 1-pixel dark outline in the creature's darkest colour")
    a = ap.parse_args()
    gen(a) if a.cmd == "gen" else snap(a)


if __name__ == "__main__":
    main()
