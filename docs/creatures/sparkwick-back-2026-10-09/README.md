# Sparkwick's back views: colour fixed (Claude, 2026-10-09)

**Preston, 2026-10-09:** the back animations "still don't look right", "some are darker with light stripes and vice versa", and "are you able to just fix the color, that's the only issue."

## What was wrong
- **The front and sides:** a warm tan body, (215,156,76) on stills and (202,152,89) on walks, with brown stripes (156,103,58) and (143,92,54).
- **The back still `n` and the back walk `n`:** a dull grey-tan body, (180,139,91) and (166,137,105), with light (216,181,115) and bright orange (217,128,37) stripes. That is the flipped pattern.
- **Both back views:** cream (254,240,168) and (247,226,157) on the tail.
- **The back still `nw` and the back walk `nw`:** mostly right, apart from the cream tail.

## The fix (no generation)
`tools/arena/fix_stripe_flip.py` makes an exact colour swap, read off the palettes:
- the dull body becomes the front's body tan;
- the light and orange stripes become the front's stripe browns;
- cream outside the lantern becomes body tan (seen from behind there is no belly, so that cream is the tail).

The lantern (a disc round its bright core) and the outline are never touched.

**Files fixed:** `assets/sprites/arena/sparkwick/n.png`, `nw.png`, and the walk sheets `sparkwick_n_sheet.png` and `sparkwick_nw_sheet.png`. The small and dungeon sets were rebuilt from them. The originals are in `original/`. The comparison is `fixed_compare.png`.

## Not used
- **Four paid back-view edits** (`sparkwick_*_edit*.png`, $0.72) were made first. Preston judged that they drifted from the original design, so they are kept for the record only.
- **The facing order of the back views** (`n` looks like a rear three-quarter, `ne` like a side) was left as it was, because Preston said colour is the only issue.
