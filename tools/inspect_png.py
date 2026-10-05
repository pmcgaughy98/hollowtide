"""Print a PNG's structure as text.

An assistant that cannot view images still needs to know where the pieces sit
inside a source sheet before slicing it. This reads the file read-only and
prints the size, the palette, and a coarse character preview so the layout can
be read as text.

Usage:
    python tools/inspect_png.py IMAGE [COLUMNS]
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

RAMP = " .:-=+*#%"


def _bands(img: Image.Image, by_row: bool) -> list[tuple[int, int, str]]:
	"""Condense each line into clear / magenta / content runs."""
	MAGENTA = (255, 0, 255)
	width, height = img.size
	px = img.load()
	labels: list[str] = []
	limit = height if by_row else width
	span = width if by_row else height
	for i in range(limit):
		t = m = o = 0
		for j in range(span):
			p = px[j, i] if by_row else px[i, j]
			if p[3] <= 40:
				t += 1
			elif p[:3] == MAGENTA:
				m += 1
			else:
				o += 1
		if o >= 20:
			labels.append("content")
		elif m > t:
			labels.append("magenta")
		elif t > 0:
			labels.append("clear")
		else:
			labels.append("thin")
	out: list[tuple[int, int, str]] = []
	start = 0
	for i in range(1, limit + 1):
		if i == limit or labels[i] != labels[start]:
			if i - start >= 2:
				out.append((start, i, labels[start]))
			start = i
	return out


def main() -> int:
	if len(sys.argv) < 2:
		print("usage: inspect_png.py IMAGE [COLUMNS|profile]")
		return 2

	path = Path(sys.argv[1])
	mode = sys.argv[2] if len(sys.argv) > 2 else "96"
	cols = int(mode) if mode.isdigit() else 96
	if not path.exists():
		print("missing:", path)
		return 2

	img = Image.open(path).convert("RGBA")
	width, height = img.size
	print("path:", path)
	print("size:", width, "x", height)
	print("opaque bbox:", img.getchannel("A").getbbox())

	pixels = img.load()

	if mode == "profile":
		for label, by_row in (("row", True), ("column", False)):
			print("%s bands (clear / magenta / content):" % label)
			for a, b, kind in _bands(img, by_row):
				print("  %ss %4d-%4d  %s" % (label, a, b, kind))
		return 0
	counts: dict[tuple[int, int, int, int], int] = {}
	for y in range(height):
		for x in range(width):
			px = pixels[x, y]
			counts[px] = counts.get(px, 0) + 1

	print("unique colours:", len(counts))
	for px, n in sorted(counts.items(), key=lambda kv: -kv[1])[:16]:
		print("  rgba%-24s %6d" % (str(px), n))

	rows = max(1, int(cols * height / max(1, width) * 0.5))
	print("preview %dx%d:" % (cols, rows))
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
					p = pixels[xx, yy]
					r += p[0]
					g += p[1]
					b += p[2]
					a += p[3]
					n += 1
			if n == 0:
				line.append(" ")
				continue
			r //= n
			g //= n
			b //= n
			a //= n
			if a < 40:
				line.append(" ")
			elif r > 200 and g > 200 and b > 200:
				line.append("@")
			elif r > 150 and g < 120 and b < 120:
				line.append("R")
			elif r > 150 and g > 110 and b < 110:
				line.append("Y")
			elif b > 140 and b > r + 30:
				line.append("B")
			else:
				lum = (r * 299 + g * 587 + b * 114) // 1000
				line.append(RAMP[min(len(RAMP) - 1, lum // 32)])
		print("".join(line))

	return 0


if __name__ == "__main__":
	raise SystemExit(main())
