# Flintram, eight views from the Opal Sprite Forge v5 (2026-10-14, Claude)

Preston, 2026-10-14: "The 8 page flintram is our new flintram." This sheet is Flintram; the Forge's first single
front is not. Proposal art. Flintram is roster line 10, Stage I (Stone, "nimble cliff quadruped, flint wedge brow, narrow limbs,
two loose back plates ... avoid sheep horns, turtle shell, boulder body, rounded face"). Not in `assets/`: it needs
Grok's numbers and Preston's approval first.

- `flintram_8dir_raw.jpg`: the Forge's VIEW: EIGHT sheet, untouched (1024 px JPEG, 118,158 bytes, sha12 ebbcb67fd4f1).
  Made free in Opal with the Forge's first Flintram front as the reference and Tallowroot as the style anchor.
  Preston chose to save this sheet only, not the front.
- `flintram_8dir_snapped.png`: back on its own pixel grid. Gemini drew on a 200x200 grid (5.12 image pixels per art
  pixel, found by `tools/art/gemini_sprite.py snap --fractional`), JPEG noise folded into 40 shared colours
  (`--colours 40`), magenta removed.
- `views_128/`: the eight views cut by `tools/art/slice_grid.py`, feet on row 104 of the 128 canvas.
- `contact_views.png`: the eight in game order at 3x.

Measured: heights 46 to 54 (spread 8), mirror pairs e/w 0.935, ne/nw 0.923, se/sw 0.920.

Against the brief and the game:
- **Scale is half the game's.** Stage I arena views stand 76 to 82 pixels; these stand 46 to 54. Doubling them
  would double every pixel and look chunkier than the rest of the cast.
- **The plates became a shell.** The front showed a stack of stones; the sheet merged them into a domed, segmented
  back that reads as a turtle shell, which the brief rules out. The single front did not do this.
- What works: one design held across all eight directions, clean outline, house shading, the line's palette.
