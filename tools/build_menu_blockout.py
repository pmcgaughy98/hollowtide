"""Stand-in art for the main menu's Courier Lookout scene (Preston, 2026-09-30:
build Concept C from docs/Gemini DeepResearch(Hollowtide)/Hollowtide Animated
Title Menu Research.docx).

These are blockouts, drawn in code so the scene can be judged in the engine
before real art exists: the storm sky, the far bank, the river, the Old Ferry
Ward's roofs, fog, and the loess bluff with a route marker. Final art will come
from the World Asset Forge and replace these files one at a time; the scene
does not change.

Palette, 2026-09-30 (Preston: "more synthy, whimsical, chiptune" than the first
grey storm): a violet-to-rose dusk, clouds lit pink from below, the river
catching the sky, and dusk light on the loess. Same layout as before.

Everything is drawn on a 576 x 324 grid and shown at 2x, the same pixel size
as the characters, so art pixels match across the scene. Layers that scroll
(clouds, glints, fog) wrap left to right seamlessly.

  python tools/build_menu_blockout.py
Writes assets/sprites/menu/*.png.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/sprites/menu"
W, H = 576, 324
HORIZON = 150


def hexrgb(h: str) -> tuple:
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def canvas(w: int, h: int) -> np.ndarray:
    return np.zeros((h, w, 4), np.uint8)


def paint(img: np.ndarray, mask, colour: str, alpha: int = 255) -> None:
    """Fill a boolean mask, or a rectangle given as np.s_[rows, cols]."""
    if isinstance(mask, tuple):
        region = img[mask]  # a view, so writing to it writes the image
        region[..., :3] = hexrgb(colour)
        region[..., 3] = alpha
        return
    img[mask, :3] = hexrgb(colour)
    img[mask, 3] = alpha


def wave(x: np.ndarray, width: int, terms: list, seed: int) -> np.ndarray:
    """A bumpy line that wraps: a sum of sines with whole periods across the width."""
    rng = np.random.default_rng(seed)
    y = np.zeros_like(x, dtype=np.float64)
    for k, amp in terms:
        y += amp * np.sin(2 * np.pi * k * x / width + rng.uniform(0, 2 * np.pi))
    return y


def save(name: str, img: np.ndarray) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    Image.fromarray(img, "RGBA").save(OUT / f"{name}.png")
    print(f"{name}.png  {img.shape[1]}x{img.shape[0]}")


def sky() -> np.ndarray:
    """Static: a dusk sky in flat bands, deep indigo at the top to rose and a
    peach glow at the horizon."""
    img = canvas(W, H)
    bands = ["#1b1836", "#221d42", "#2c234d", "#3a2a58", "#4d325f", "#653b66", "#80476b", "#9c566e", "#b86c73", "#d88c7a"]
    edges = np.linspace(0, HORIZON + 10, len(bands) + 1).astype(int)
    for i, c in enumerate(bands):
        img[edges[i]:edges[i + 1], :, :3] = hexrgb(c)
    img[edges[-1]:, :, :3] = hexrgb(bands[-1])
    img[..., 3] = 255
    return img


def clouds() -> np.ndarray:
    """Scrolls: heavy storm clouds in three tones, wrapping left to right."""
    h = 130
    img = canvas(W, h)
    y, x = np.mgrid[0:h, 0:W]
    for layer, (base, terms, colour, rim, seed) in enumerate([
            (52, [(2, 12), (5, 6), (11, 3)], "#2b2450", "#4a3a70", 1),  # clear sky above it, for the stars
            (62, [(3, 12), (7, 6), (13, 3)], "#3d2f5e", "#7a5282", 2),
            (95, [(2, 10), (6, 6), (15, 2)], "#583f6c", "#c77a8c", 3)]):
        top = base + wave(x[0], W, terms, seed)
        body = (y >= top[None, :]) & (y < top[None, :] + 26 + wave(x[0], W, [(4, 6)], seed + 9)[None, :])
        paint(img, body, colour)
        lip = body & ~np.roll(body, -1, axis=0)  # the underside, lit by the low sun
        lip |= np.roll(lip, -1, axis=0)
        paint(img, lip, rim)
    return img


def far_bank() -> np.ndarray:
    """Static: the far bank's tree line and low fields, pale with distance."""
    h = 26
    img = canvas(W, h)
    y, x = np.mgrid[0:h, 0:W]
    trees = 8 + wave(x[0], W, [(9, 3), (23, 2), (41, 1)], 4)
    paint(img, y >= trees[None, :], "#3b3560")
    paint(img, (y >= trees[None, :]) & (y < trees[None, :] + 2), "#5a4a78")
    paint(img, y >= 20, "#453d68")
    paint(img, y >= 24, "#39345a")
    return img


def river() -> np.ndarray:
    """Static: the broad river, deep blue-green in bands, lighter toward the far bank."""
    h = 100
    img = canvas(W, h)
    for y0, c in [(0, "#b0707a"), (4, "#7c5a78"), (9, "#4f6a80"), (18, "#3f7079"), (35, "#356570"), (60, "#2d5663"), (82, "#274856")]:
        img[y0:, :, :3] = hexrgb(c)
    img[..., 3] = 255
    return img


def glints() -> np.ndarray:
    """Scrolls: long low ripples catching the light, wrapping left to right."""
    h = 100
    img = canvas(W, h)
    rng = np.random.default_rng(6)
    for _ in range(70):
        yy = int(rng.integers(2, h - 2))
        length = int(rng.integers(4, 18)) if yy > 30 else int(rng.integers(3, 9))
        xx = int(rng.integers(0, W))
        cols = np.arange(xx, xx + length) % W
        img[yy, cols, :3] = hexrgb("#f0a8a0" if yy < 12 else ("#8fd6d0" if yy < 45 else "#5fb0b2"))
        img[yy, cols, 3] = 200
    return img


WINDOWS: list = []  # filled by ward(): where each lit window is, for window_glow()


def ward() -> np.ndarray:
    """Static: the Old Ferry Ward on the low ground below the bluff: slate gable
    roofs along the shore path, a few lit windows, and the ground below it."""
    h = 100
    img = canvas(W, h)
    shore = 34
    paint(img, np.s_[shore:h, 240:W], "#3a3148")
    paint(img, np.s_[shore:shore + 2, 240:W], "#5a4a62")
    paint(img, np.s_[shore + 30:h, 240:W], "#2f283d")
    rng = np.random.default_rng(8)
    x = 300
    while x < W - 12:
        w = int(rng.integers(20, 32))
        roof_h = int(rng.integers(8, 11))
        wall_h = int(rng.integers(9, 13))
        wall_top = shore - wall_h
        top = wall_top - roof_h
        for row in range(top, wall_top):
            inset = round((wall_top - row) * (w / 2) / (roof_h + 1))
            if inset * 2 >= w:
                continue
            paint(img, np.s_[row, x + inset:x + w - inset], "#3b3458")
            paint(img, np.s_[row, x + inset:x + w // 2], "#5a4b78")
        paint(img, np.s_[wall_top:shore, x + 2:x + w - 2], "#6a4e5a")
        paint(img, np.s_[wall_top:shore, x + 2:x + 3], "#553e4c")
        if rng.random() < 0.65:
            wx = x + int(rng.integers(5, max(6, w - 7)))
            paint(img, np.s_[wall_top + 3:wall_top + 6, wx:wx + 3], "#ffd27a")
            WINDOWS.append((wx + 1, 224 + wall_top + 4))  # stage position, for the glow
        x += w + int(rng.integers(4, 14))
    return img


def fog() -> np.ndarray:
    """Scrolls: a low band of river fog, see-through, wrapping left to right."""
    h = 44
    img = canvas(W, h)
    y, x = np.mgrid[0:h, 0:W]
    top = 14 + wave(x[0], W, [(3, 5), (8, 3), (17, 1.5)], 12)
    bottom = 32 + wave(x[0], W, [(4, 4), (11, 2)], 13)
    body = (y >= top[None, :]) & (y < bottom[None, :])
    core = (y >= top[None, :] + 4) & (y < bottom[None, :] - 4)
    paint(img, body, "#b8a3c8", 60)
    paint(img, core, "#c9b6d6", 95)
    return img


def bluff() -> np.ndarray:
    """Static: the loess bluff the courier stands on, its switchback road, grass
    along the lip, and a Wayline route marker with its three-dot mark."""
    img = canvas(W, H)
    y, x = np.mgrid[0:H, 0:W]
    lip = 238 + wave(x[0], W, [(3, 3), (9, 1.5)], 21) + np.clip((x[0] - 300) * 0.9, 0, None)
    ground = y >= lip[None, :]
    paint(img, ground, "#c09070")
    face = ground & (y >= lip[None, :] + 6)
    paint(img, face, "#9c7068")
    # Vertical flutes in the loess face.
    flutes = face & ((x + (y // 7)) % 11 < 2)
    paint(img, flutes, "#7e5a60")
    paint(img, ground & (y >= 300), "#6a4c5c")
    # The switchback road: a pale band across the top of the bluff.
    road = ground & (y >= lip[None, :] + 1) & (y < lip[None, :] + 5) & (x < 280)
    paint(img, road, "#e0b48a")
    # Grass along the lip.
    tufts = ground & (y < lip[None, :] + 2) & ((x * 7 + y * 3) % 5 < 3)
    paint(img, tufts, "#4f8a6e")
    paint(img, ground & (y < lip[None, :] + 1), "#3f6e5e")
    # The route marker: a post with a flat head and three dots, near the edge.
    mx, my = 268, int(lip[268])
    paint(img, np.s_[my - 22:my, mx:mx + 4], "#6a5238")
    paint(img, np.s_[my - 22:my, mx:mx + 1], "#4f3d2a")
    paint(img, np.s_[my - 26:my - 20, mx - 3:mx + 7], "#7a6044")
    for dx in (-2, 2, 6):
        paint(img, np.s_[my - 24:my - 22, mx + dx - 0:mx + dx + 1], "#e1d2a8")
    # A dark outline along the top of the bluff, like the creatures'.
    top_edge = ground & ~np.roll(ground, 1, axis=0)
    paint(img, top_edge, "#2a2038")
    return img


def courier() -> np.ndarray:
    """The courier seen from behind, from the approved walk sheet (bottom row,
    first frame), reduced to the menu's pixel size: about 130 art pixels tall."""
    sheet = Image.open(ROOT / "assets/sprites/player/male_vertical_walk_4x2_2026_09_27.png").convert("RGBA")
    cell = sheet.crop((0, 512, 256, 1024))
    cell = cell.crop(cell.getbbox())
    scale = 130 / cell.height
    small = cell.resize((round(cell.width * scale), 130), Image.BOX)
    a = np.asarray(small).copy()
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    return a


def window_glow() -> np.ndarray:
    """A soft two-step glow around each lit window, as its own layer so the
    game can make the windows flicker. Run after ward()."""
    img = canvas(W, H)
    for wx, wy in WINDOWS:
        for r, a in ((6, 40), (3, 80)):
            y0, y1, x0, x1 = max(0, wy - r), min(H, wy + r + 1), max(0, wx - r), min(W, wx + r + 2)
            yy, xx = np.mgrid[y0:y1, x0:x1]
            ring = (np.abs(yy - wy) + np.abs(xx - wx)) <= r
            region = img[y0:y1, x0:x1]
            region[ring, :3] = hexrgb("#ffc070")
            region[ring, 3] = np.maximum(region[ring, 3], a)
    return img


if __name__ == "__main__":
    for name, make in (("sky", sky), ("clouds", clouds), ("far_bank", far_bank), ("river", river),
                       ("glints", glints), ("ward", ward), ("window_glow", window_glow), ("fog", fog), ("bluff", bluff),
                       ("courier_back", courier)):
        save(name, make())
