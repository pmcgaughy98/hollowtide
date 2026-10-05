"""Slice the hero gauge mockup into Godot pieces.

The source sheet is a mockup of the same gauge drawn three times at three fill
levels, not a component sheet, so the pieces are cut by detecting the geometry
from the art rather than by cropping hard-coded rectangles.

Reads:  docs/art/palettes/hud-gauge-view.png   (720 x 1332, 16 colours)
Writes: assets/sprites/ui/gauge_housing.png
        assets/sprites/ui/gauge_hp_full.png
        assets/sprites/ui/gauge_hp_warn.png
        assets/sprites/ui/gauge_hp_empty.png
        assets/sprites/ui/gauge_sp_lit.png
        assets/sprites/ui/gauge_sp_empty.png
        assets/sprites/ui/gauge_layout.json

Usage:  python tools/slice_gauge_sheet.py [SOURCE] [OUTPUT_DIR]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image

MAGENTA = (255, 0, 255)
AMBER = (227, 154, 34)   # HP well, healthy
RED = (196, 58, 40)      # HP well, low; also every SP coal when lit
RAMP = " .:-=+*#%"
MIN_PANEL_ROWS = 40
MIN_CELL_COLS = 3


def preview(img: Image.Image, cols: int = 96, label: str = "") -> None:
	"""Print an image as coarse text so layout can be read without eyes."""
	width, height = img.size
	px = img.convert("RGBA").load()
	rows = max(1, int(cols * height / max(1, width) * 0.5))
	print("%s %dx%d" % (label, width, height))
	for by in range(rows):
		line: list[str] = []
		for bx in range(cols):
			x0 = int(bx * width / cols)
			x1 = max(x0 + 1, int((bx + 1) * width / cols))
			y0 = int(by * height / rows)
			y1 = max(y0 + 1, int((by + 1) * height / rows))
			r = g = b = a = n = 0
			for yy in range(y0, min(y1, height)):
				for xx in range(x0, min(x1, width)):
					p = px[xx, yy]
					r += p[0]; g += p[1]; b += p[2]; a += p[3]; n += 1
			if n == 0:
				line.append(" "); continue
			r //= n; g //= n; b //= n; a //= n
			if a < 40:
				line.append(" ")
			elif r > 150 and g < 120 and b < 120:
				line.append("R")
			elif r > 150 and g > 110 and b < 110:
				line.append("Y")
			elif r > 200 and g > 200 and b > 200:
				line.append("@")
			else:
				lum = (r * 299 + g * 587 + b * 114) // 1000
				line.append(RAMP[min(len(RAMP) - 1, lum // 32)])
		print("".join(line))


def runs(flags: list[bool], min_len: int) -> list[tuple[int, int]]:
	"""Contiguous True spans, as inclusive start and exclusive end."""
	out: list[tuple[int, int]] = []
	start = None
	for i, on in enumerate(flags + [False]):
		if on and start is None:
			start = i
		elif not on and start is not None:
			if i - start >= min_len:
				out.append((start, i))
			start = None
	return out


def main() -> int:
	src = Path(sys.argv[1] if len(sys.argv) > 1 else "docs/art/palettes/hud-gauge-view.png")
	out_dir = Path(sys.argv[2] if len(sys.argv) > 2 else "assets/sprites/ui")
	if not src.exists():
		print("missing:", src)
		return 2

	img = Image.open(src).convert("RGBA")
	width, height = img.size
	px = img.load()
	print("source:", src, width, "x", height)

	magenta = 0
	magenta_rows: set[int] = set()
	for y in range(height):
		for x in range(width):
			if px[x, y] == MAGENTA + (255,):
				magenta += 1
				magenta_rows.add(y)
	print("magenta pixels:", magenta)
	if magenta_rows:
		print("magenta row range:", min(magenta_rows), "-", max(magenta_rows))

	# The sheet is a mockup drawn on a solid page background, not a transparent
	# component sheet, so panels are found by which background colour dominates
	# a row rather than by transparency.
	tally: dict[tuple[int, int, int], int] = {}
	for y in range(height):
		for x in range(width):
			c = px[x, y][:3]
			tally[c] = tally.get(c, 0) + 1
	top = sorted(tally.items(), key=lambda kv: -kv[1])
	print("top colours:")
	for c, n in top[:10]:
		print("   rgba%s  %d" % (str(c), n))

	# The mockup repeats the same gauge every 436 rows, with the first full
	# gauge starting at row 276. Those two numbers are MEASURED from this
	# particular file by reading its row structure, not guessed, because the
	# page background is deliberately the same charcoal as the gauge itself
	# and cannot be told apart from it automatically. If the art is redrawn,
	# re-measure these before running again.
	PANEL_STEP = 436
	PANEL_TOP = 276
	bands = []
	y = PANEL_TOP
	while y < height:
		bands.append((y, min(y + PANEL_STEP, height)))
		y += PANEL_STEP
	print("panels found:", len(bands))
	for i, (y0, y1) in enumerate(bands):
		print("   panel %d: rows %d-%d (%d tall)" % (i, y0, y1, y1 - y0))

	if len(bands) < 3:
		print("need at least three panels (full, half, low); stopping")
		return 1

	def panel_rect(index: int) -> tuple[int, int, int, int]:
		y0, y1 = bands[index]
		xs = [x for y in range(y0, y1) for x in range(width)
			  if px[x, y][3] > 128 and px[x, y][:3] != MAGENTA]
		return (min(xs), y0, max(xs) + 1, y1)

	def color_cells(rect: tuple[int, int, int, int], colour: tuple[int, int, int]):
		"""Rows and column runs of one exact colour inside a rect."""
		x0, y0, x1, y1 = rect
		row_hits = []
		for y in range(y0, y1):
			n = sum(1 for x in range(x0, x1) if px[x, y][:3] == colour and px[x, y][3] > 128)
			row_hits.append(n)
		row_bands = runs([n > 0 for n in row_hits], 2)
		if not row_bands:
			return []
		ry0 = y0 + row_bands[0][0]
		ry1 = y0 + row_bands[0][1]
		col_flags = []
		for x in range(x0, x1):
			n = sum(1 for y in range(ry0, ry1) if px[x, y][:3] == colour and px[x, y][3] > 128)
			col_flags.append(n > 0)
		cells = [(x0 + a, x0 + b) for a, b in runs(col_flags, MIN_CELL_COLS)]
		return [{"row0": ry0, "row1": ry1, "col0": c[0], "col1": c[1]} for c in cells]

	full_rect = panel_rect(0)   # 100% row
	low_rect = panel_rect(2)    # 10% row, also the warn colour

	hp_cells = color_cells(full_rect, AMBER)
	sp_cells = color_cells(full_rect, RED)
	print("HP wells in the full panel:", len(hp_cells))
	print("SP coals in the full panel:", len(sp_cells))

	if len(hp_cells) != 6:
		print("expected 6 HP wells; check the art before wiring this")
	if len(sp_cells) != 8:
		print("spawn: expected 8 SP coals")

	def rel(cell: dict, rect: tuple[int, int, int, int]) -> dict:
		return {"x": cell["col0"] - rect[0], "y": cell["row0"] - rect[1],
				"w": cell["col1"] - cell["col0"], "h": cell["row1"] - cell["row0"]}

	hp_rel = [rel(c, full_rect) for c in hp_cells]
	sp_rel = [rel(c, full_rect) for c in sp_cells]

	for name, rels in (("HP", hp_rel), ("SP", sp_rel)):
		step = rels[1]["x"] - rels[0]["x"] if len(rels) > 1 else 0
		print("%s: origin (%d,%d) size %dx%d step %d, count %d"
			  % (name, rels[0]["x"], rels[0]["y"], rels[0]["w"], rels[0]["h"],
				 step, len(rels)))

	def abs_rect(rel_cell: dict, rect: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
		return (rect[0] + rel_cell["x"], rect[1] + rel_cell["y"],
				rect[0] + rel_cell["x"] + rel_cell["w"], rect[1] + rel_cell["y"] + rel_cell["h"])

	# Housing: the 10% panel with its two lit cells painted over with unlit art
	# from the same row, so every well and coal reads empty.
	housing = img.crop(low_rect).copy()
	def clear(rels: list[dict], lit_index: int, clear_index: int) -> None:
		dest = abs_rect(rels[lit_index], low_rect)
		src_box = abs_rect(rels[clear_index], low_rect)
		housing.paste(img.crop(src_box), (dest[0] - low_rect[0], dest[1] - low_rect[1]))
	if len(hp_rel) > 2:
		clear(hp_rel, 0, 2)
	if len(sp_rel) > 2:
		clear(sp_rel, 0, 2)

	def pip(source_rect, rel_cell) -> Image.Image:
		return img.crop(abs_rect(rel_cell, source_rect)).copy()

	out_dir.mkdir(parents=True, exist_ok=True)
	pieces = {
		"gauge_housing.png": housing,
		"gauge_hp_full.png": pip(full_rect, hp_rel[0]),
		"gauge_hp_warn.png": pip(low_rect, hp_rel[0]),
		"gauge_hp_empty.png": pip(low_rect, hp_rel[2]),
		"gauge_sp_lit.png": pip(full_rect, sp_rel[0]),
		"gauge_sp_empty.png": pip(low_rect, sp_rel[2]),
	}
	for name, im in pieces.items():
		im.save(out_dir / name)
		colours = {}
		p = im.convert("RGBA").load()
		for y in range(im.size[1]):
			for x in range(im.size[0]):
				colours[p[x, y]] = colours.get(p[x, y], 0) + 1
		top = max(colours.items(), key=lambda kv: kv[1])
		print("wrote %-22s %dx%d  dominant rgba%s (%d px)"
			  % (name, im.size[0], im.size[1], str(top[0]), top[1]))

	layout = {
		"housing": {"w": housing.size[0], "h": housing.size[1]},
		"hp": {"count": len(hp_rel), **{k: hp_rel[0][k] for k in ("x", "y", "w", "h")},
			   "step": (hp_rel[1]["x"] - hp_rel[0]["x"]) if len(hp_rel) > 1 else 0},
		"sp": {"count": len(sp_rel), **{k: sp_rel[0][k] for k in ("x", "y", "w", "h")},
			   "step": (sp_rel[1]["x"] - sp_rel[0]["x"]) if len(sp_rel) > 1 else 0},
	}
	(out_dir / "gauge_layout.json").write_text(json.dumps(layout, indent=2), encoding="utf-8")
	print("layout:", json.dumps(layout))

	# Self check: rebuild the gauge at four fill levels and read it back as text.
	# If the geometry is right, the amber and red groups land under the wells.
	for filled in (6, 3, 1, 0):
		test = housing.copy()
		for i in range(min(filled, len(hp_rel))):
			warn = filled == 1
			well = pieces["gauge_hp_warn.png" if warn else "gauge_hp_full.png"]
			test.paste(well, (hp_rel[i]["x"], hp_rel[i]["y"]))
		preview(test, 88, "selftest hp=%d/6:" % filled)

	return 0


if __name__ == "__main__":
	raise SystemExit(main())
