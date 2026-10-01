"""Cut the Walk Cycle Forge results into the chibi courier's 272-pixel cells.

  python docs/art/characters/chibi-courier-preparation-2026-09-30/walk-forge-inputs/cut_walk_results.py

Each {direction}_result.png is a 2x2 sheet (F0 F1 / F2 F3) on noisy magenta. The Forge
redraws every cell, so Preston's original poses are never taken from it: only the
new cells are cut. Each new cell is sized by the result's own F0 against the original
F0 (one scale per sheet, so the steps keep their relative bob), put on the shared
boot line (y 260), lined up on the original's upper-body centre, and mapped to the
original atlas palette so the finish matches. Writes cut_cells/{direction}_f{n}.png
and review_sheet.png. Nothing in the game is changed by this script.
"""
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
ATLAS = ROOT / "assets/sprites/player/courier_chibi_prepared_2026_09_30/source_detail/source_pose_atlas_4x4.png"
CELL, FOOT = 272, 260
ROWS = {"down": 0, "left": 1, "right": 2, "up": 3}
INSET = 8  # skips the black grid lines some results draw between cells
INK = (26, 18, 20)


def magenta(rgb: np.ndarray) -> np.ndarray:
    r, g, b = (rgb[..., i].astype(int) for i in range(3))
    return (r > 130) & (b > 130) & (g < 0.62 * np.minimum(r, b))


def largest_parts(mask: np.ndarray) -> np.ndarray:
    """Keep the figure: the biggest connected blob plus any piece at least 3% of it."""
    h, w = mask.shape
    label = np.zeros(mask.shape, int)
    sizes = [0]
    for y, x in zip(*np.nonzero(mask)):
        if label[y, x]:
            continue
        n = len(sizes)
        label[y, x] = n
        q, count = deque([(y, x)]), 0
        while q:
            cy, cx = q.popleft()
            count += 1
            for ny, nx in ((cy + 1, cx), (cy - 1, cx), (cy, cx + 1), (cy, cx - 1)):
                if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not label[ny, nx]:
                    label[ny, nx] = n
                    q.append((ny, nx))
        sizes.append(count)
    big = max(sizes)
    keep = [i for i, s in enumerate(sizes) if i and s >= 0.03 * big]
    return np.isin(label, keep)


def bbox(mask: np.ndarray):
    ys, xs = np.nonzero(mask)
    return ys.min(), ys.max(), xs.min(), xs.max()


def upper_centre(mask: np.ndarray) -> float:
    top, bottom, _, _ = bbox(mask)
    band = mask[top: top + int(0.6 * (bottom - top))]
    return float(np.nonzero(band)[1].mean())


def result_cells(path: Path):
    img = np.array(Image.open(path).convert("RGB"))
    half = img.shape[0] // 2
    cells = []
    for r in range(2):
        for c in range(2):
            rgb = img[r * half + INSET:(r + 1) * half - INSET, c * half + INSET:(c + 1) * half - INSET]
            cells.append((rgb, largest_parts(~magenta(rgb))))
    return cells  # F0, F1, F2, F3


def place(rgb, mask, scale, centre_x, ref_centre):
    top, bottom, left, right = bbox(mask)
    rgb = rgb[top:bottom + 1, left:right + 1].copy()
    mask = mask[top:bottom + 1, left:right + 1]
    rgb[~mask] = INK  # edge samples darken toward ink, like the source outline
    w, h = mask.shape[1], mask.shape[0]
    size = (max(1, round(w * scale)), max(1, round(h * scale)))
    small_rgb = np.array(Image.fromarray(rgb).resize(size, Image.BOX))
    small_a = np.array(Image.fromarray((mask * 255).astype(np.uint8)).resize(size, Image.BOX)) >= 128
    out = np.zeros((CELL, CELL, 4), np.uint8)
    x0 = round(ref_centre - (centre_x - left) * scale)
    y0 = FOOT + 1 - size[1]
    out[y0:y0 + size[1], x0:x0 + size[0], :3] = small_rgb
    out[y0:y0 + size[1], x0:x0 + size[0], 3] = np.where(small_a, 255, 0)
    return out


def to_palette(cell: np.ndarray, palette: np.ndarray) -> np.ndarray:
    opaque = cell[..., 3] > 0
    px = cell[opaque][:, :3].astype(int)
    d = ((px[:, None, :] - palette[None, :, :]) ** 2).sum(-1)
    cell[opaque, :3] = palette[d.argmin(1)]
    return cell


def main():
    atlas = np.array(Image.open(ATLAS).convert("RGBA"))
    src_px = atlas[atlas[..., 3] > 0][:, :3]
    palette = np.array(Image.fromarray(src_px[None]).quantize(128, method=Image.MEDIANCUT).convert("RGB")).reshape(-1, 3)
    palette = np.unique(palette, axis=0).astype(int)
    out_dir = HERE / "cut_cells"
    out_dir.mkdir(exist_ok=True)
    rows = []
    for name, row in ROWS.items():
        src0 = atlas[row * CELL:(row + 1) * CELL, 0:CELL]
        src_mask = src0[..., 3] > 0
        s_top, s_bottom, _, _ = bbox(src_mask)
        ref_centre = upper_centre(src_mask)
        cells = result_cells(HERE / f"{name}_result.png")
        r_top, r_bottom, _, _ = bbox(cells[0][1])
        scale = (s_bottom - s_top + 1) / (r_bottom - r_top + 1)
        row_imgs = [src0, atlas[row * CELL:(row + 1) * CELL, CELL:2 * CELL]]
        for n, (rgb, mask) in enumerate(cells):
            cut = to_palette(place(rgb, mask, scale, upper_centre(mask), ref_centre), palette)
            Image.fromarray(cut).save(out_dir / f"{name}_f{n}.png")
            row_imgs.append(cut)
        print(f"{name}: scale {scale:.3f}, heights {[int(bbox(m)[1] - bbox(m)[0]) for _, m in cells]}")
        rows.append(row_imgs)
    sheet = Image.new("RGBA", (CELL * 6, CELL * 4), (60, 66, 70, 255))
    for r, imgs in enumerate(rows):
        for c, im in enumerate(imgs):
            sheet.alpha_composite(Image.fromarray(im), (c * CELL, r * CELL))
    sheet.save(HERE / "review_sheet.png")
    build_walk_atlas(atlas)


# Which drawing each walk beat uses, per direction, after measuring every cell's
# feet (2026-10-01). "src N" is Preston's original column N; "fN" is a new Forge cell.
# DOWN: F1 is the only level-feet passing pose; F2/F3 repeat the original steps.
# LEFT/RIGHT: F1 is a real passing pose; the rest repeat the original stride, and
#   LEFT's F2/F3 face the wrong way. The original stride serves as both contacts.
# UP: the two original cells are the same step; F3 is the true opposite step.
#   No passing pose came back, so UP keeps the one-pixel lift in player.gd.
WALK = {
    "down": ["src0", "f1", "src1", "f1"],
    "left": ["src0", "f1", "src0", "f1"],
    "right": ["src0", "f1", "src0", "f1"],
    "up": ["src0", "src0", "f3", "f3"],
}
WALK_ATLAS = ROOT / "assets/sprites/player/courier_chibi_walk_2026_10_01.png"


def build_walk_atlas(atlas):
    out = Image.new("RGBA", (CELL * 4, CELL * 4), (0, 0, 0, 0))
    for name, row in ROWS.items():
        for beat, pick in enumerate(WALK[name]):
            if pick.startswith("src"):
                c = int(pick[3:])
                cell = Image.fromarray(atlas[row * CELL:(row + 1) * CELL, c * CELL:(c + 1) * CELL])
            else:
                cell = Image.open(HERE / "cut_cells" / f"{name}_{pick}.png")
            out.alpha_composite(cell, (beat * CELL, row * CELL))
    out.save(WALK_ATLAS)
    print("wrote", WALK_ATLAS.relative_to(ROOT))


if __name__ == "__main__":
    main()
