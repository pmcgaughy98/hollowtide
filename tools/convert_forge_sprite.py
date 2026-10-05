"""Turn a Hollowtide Sprite Forge image into a transparent game sprite, 1:1.

Usage:
    python tools/convert_forge_sprite.py <input image> <output .png> [--compare <sheet.png>]

The Forge draws pixel art on a 100 by 100 block grid, enlarged to 1024x1024, on
a flat magenta background. This reads that grid back one pixel per block, so the
sprite is the Forge's art exactly, minus the magenta. Nothing is resized.

An earlier version shrank everything to 64x64. That cannot work: a creature
drawn 88 blocks wide has 88 pixels of detail, and squeezing it into 64 destroys
some of it no matter how the squeeze is done. So the output is 100x100.

--compare writes a side-by-side image, original on the left and the sprite on
the right at the same size, so the result can be judged against the source
instead of against itself.
"""
import sys
from collections import Counter

import numpy as np
from PIL import Image

FLOOR_GAP = 3  # empty rows under the feet
# Colours closer than this (straight-line RGB distance) count as one colour when
# the palette is built. Big enough to merge JPEG noise, small enough that a glow
# never merges into the rock around it.
MERGE_DISTANCE = 18


def grid_period(signal):
	"""Block size along one axis, from where colour edges repeat."""
	best = (0.0, 10.24)
	idx = np.arange(1, len(signal) + 1)
	# 8 to 16px per block covers a 64 to 128 block grid. Searching wider finds
	# false matches: at 6px the JPEG noise alone scores higher than the real grid.
	for period in np.arange(8.0, 16.001, 0.005):
		bins = np.floor(np.mod(idx, period) / period * 40).astype(int)
		energy = np.bincount(bins, weights=signal, minlength=40)
		score = energy.max() / energy.mean()
		if score > best[0]:
			best = (score, period)
	return best


def period_score(signal, period):
	idx = np.arange(1, len(signal) + 1)
	bins = np.floor(np.mod(idx, period) / period * 40).astype(int)
	energy = np.bincount(bins, weights=signal, minlength=40)
	return energy.max() / energy.mean()


def is_magenta(rgb):
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	return (r > 170) & (b > 170) & (g < 110) & (np.abs(r - b) < 70)


def background(a):
	"""Pure magenta, plus whatever colour actually fills the image's border.

    The Forge does not always hit exact #FF00FF: Wayburn came back on a darker
    magenta that the fixed test missed, so its whole background survived. The
    border is always background, so its colour is the reliable one to key out.
	"""
	border = np.concatenate([a[:4].reshape(-1, 3), a[-4:].reshape(-1, 3),
							 a[:, :4].reshape(-1, 3), a[:, -4:].reshape(-1, 3)])
	key = np.median(border, axis=0)
	near_key = np.sqrt(((a - key) ** 2).sum(-1)) < 60
	return is_magenta(a) | near_key


def convert(src, dst, compare=None, block=None):
	"""block: force the drawn block size in pixels when detection locks onto a
    multiple of the real grid (Opal sheets with several frames can read as 8
	when the art is drawn on 4)."""
	a = np.asarray(Image.open(src).convert("RGB")).astype(int)
	h, w, _ = a.shape

	# Blocks are square, so one block size must fit both directions. Measuring
	# each axis on its own once read Kithflare as 100 wide by 128 tall, which
	# stretches the sprite. Try both axes' best guesses and keep the one that
    # scores best across columns and rows together.
    col_signal = np.abs(np.diff(a, axis=1)).sum(axis=(0, 2))
    row_signal = np.abs(np.diff(a, axis=0)).sum(axis=(1, 2))
    _, px = grid_period(col_signal)
    _, py = grid_period(row_signal)
    px = max((px, py), key=lambda p: period_score(col_signal, p) + period_score(row_signal, p))
    if block:
        px = float(block)
    col_strength, row_strength = period_score(col_signal, px), period_score(row_signal, px)
    nx, ny = round(w / px), round(h / px)
    xs = np.linspace(0, w, nx + 1)
    ys = np.linspace(0, h, ny + 1)

    bg = background(a)
    cells = np.zeros((ny, nx, 4), np.uint8)
    for j in range(ny):
        for i in range(nx):
            # Inner 60% of the block, clear of the JPEG smear at its edges.
            y0, y1, x0, x1 = ys[j], ys[j + 1], xs[i], xs[i + 1]
            my, mx = (y1 - y0) * 0.2, (x1 - x0) * 0.2
            sl = (slice(int(round(y0 + my)), max(int(round(y0 + my)) + 1, int(round(y1 - my)))),
                  slice(int(round(x0 + mx)), max(int(round(x0 + mx)) + 1, int(round(x1 - mx)))))
            fg = ~bg[sl]
            if fg.mean() < 0.5:
                continue
            cells[j, i, :3] = np.median(a[sl][fg], axis=0)
            cells[j, i, 3] = 255

    opaque = cells[..., 3] == 255
    if not opaque.any():
        raise SystemExit("No creature found: is the background magenta?")

    # JPEG blends magenta into the outline, leaving pink blocks on the rim.
	# Only rim blocks are checked, so a creature's own pinks and purples survive.
	c = cells[..., :3].astype(int)
	# Two passes, because on detailed art (Vitrecrag) the bleed runs two blocks deep.
	pink = (c[..., 0] > 120) & (c[..., 2] > 100) & (c[..., 1] < c[..., 0] - 50) & (c[..., 1] < c[..., 2] - 50)
	for _ in range(2):
		padded = np.pad(opaque, 1)
		interior = padded[:-2, 1:-1] & padded[2:, 1:-1] & padded[1:-1, :-2] & padded[1:-1, 2:]
		cells[opaque & ~interior & pink, 3] = 0
		opaque = cells[..., 3] == 255
	# The Forge prompt forbids magenta on creatures, so a hot magenta block anywhere
	# is background showing through a gap. Slagglass had one inside its shell.
	hot = (c[..., 0] > 180) & (c[..., 2] > 130) & (c[..., 1] < 90)
	cells[opaque & hot, 3] = 0
	opaque = cells[..., 3] == 255

	# JPEG makes one real colour into many near-copies. Snap each block to the
	# nearest colour that appears in at least two blocks, which keeps small
	# features like eyes while merging the noise.
	#
	# The palette is built from colours that are actually different, most common
	# first, skipping near-copies of one already chosen. A plain top-48 list lost
	# rare but distinct colours: Ironvent's orange vents and Vitrecrag's glowing
	# windows were outvoted by dozens of near-identical browns and purples, then
	# snapped to them, so the glow vanished.
	rounded = (cells[..., :3].astype(int) // 8) * 8 + 4
	counts = Counter(map(tuple, rounded[opaque]))
	# Near-copies are grouped first and counted together, so an orange scattered
	# across many one-block shades still adds up to one strong orange.
	groups = []  # [colour, blocks]
	for col, n in counts.most_common():
		for g in groups:
			if sum((x - y) ** 2 for x, y in zip(col, g[0])) <= MERGE_DISTANCE ** 2:
				g[1] += n
				break
		else:
			groups.append([col, n])
	palette = np.array([g[0] for g in groups if g[1] >= 3] or [g[0] for g in groups[:8]])
	flat = cells[..., :3].reshape(-1, 3).astype(int)
	nearest = palette[np.argmin(((flat[:, None, :] - palette[None]) ** 2).sum(-1), axis=1)]
	cells[..., :3] = nearest.reshape(cells.shape[:2] + (3,)).astype(np.uint8)
	cells[~opaque] = 0

	# Same canvas size as the grid. Centre left to right, stand on a common floor,
	# so every creature lines up the same way in battle. Moving it loses nothing.
	rows = np.where(opaque.any(axis=1))[0]
	cols = np.where(opaque.any(axis=0))[0]
	crop = cells[rows[0]:rows[-1] + 1, cols[0]:cols[-1] + 1]
	ch, cw = crop.shape[:2]
	canvas = np.zeros((ny, nx, 4), np.uint8)
	top = max(0, ny - FLOOR_GAP - ch)
	left = (nx - cw) // 2
	canvas[top:top + ch, left:left + cw] = crop
	Image.fromarray(canvas, "RGBA").save(dst)

	# Fidelity: enlarge the sprite back onto the original grid and measure how far
	# its colours sit from the original, over the creature only.
	back = np.zeros_like(a)
	for j in range(ny):
		for i in range(nx):
			back[int(ys[j]):int(ys[j + 1]), int(xs[i]):int(xs[i + 1])] = cells[j, i, :3]
	creature = ~bg
	err = np.abs(back - a)[creature].mean()
	colours = len({tuple(p) for p in cells[..., :3][opaque]})

	print(src)
	print(f"  grid {nx} x {ny} blocks ({px:.3f}px each, edge strength {col_strength:.1f}/{row_strength:.1f})")
	print(f"  creature {cw} x {ch} blocks, {colours} colours, nothing resized")
	print(f"  average colour difference from the original: {err:.1f} of 255")
	print(f"  -> {dst}")

	if compare:
		dark = np.array([40, 40, 48])
		orig = a.copy()
		orig[bg] = dark
		left_img = Image.fromarray(orig.astype(np.uint8)).resize((nx * 5, ny * 5), Image.LANCZOS)
		spr = Image.fromarray(canvas, "RGBA").resize((nx * 5, ny * 5), Image.NEAREST)
		right_img = Image.new("RGB", spr.size, tuple(dark))
		right_img.paste(spr, (0, 0), spr)
		sheet = Image.new("RGB", (nx * 10 + 20, ny * 5), tuple(dark))
		sheet.paste(left_img, (0, 0))
		sheet.paste(right_img, (nx * 5 + 20, 0))
		sheet.save(compare)


if __name__ == "__main__":
	args = sys.argv[1:]
	cmp = None
	if "--compare" in args:
		k = args.index("--compare")
		cmp = args[k + 1]
		del args[k:k + 2]
	if len(args) != 2:
		raise SystemExit(__doc__)
	convert(args[0], args[1], cmp)
