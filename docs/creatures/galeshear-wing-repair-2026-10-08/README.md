# Galeshear wing repair — October 8, 2026

Preston reported cut-off wing parts. Inspection found the cuts inside the source silhouettes, inherited by the eight facing stills and five authored walking sheets, rather than an arena viewport crop.

## Result

Reconstructed complete wing sails, forked spars and tail tips through the built-in **imagegen** edit tool. Imported into padded **192 × 192** cells, with the creature about 128 source pixels high and a common foot baseline at 176. The existing **1.1** Galeshear scale and unchanged named-form builder produce **70 × 70** game textures. The extra canvas is transparent space for the repaired silhouette; all source and game frames have clear borders.

Eight still-facing assignments remain in the original 3×3 layout. Five authored eight-frame walking sheets remain in 4×2 layout, and the existing pipeline produces the other three directions by mirroring. Forty distinct authored frames and twenty-four exact derived mirrors are retained. The rebuilt rotation sheet is the current source for a named Galeshear reslice. The old clipped bases, raw takes and original active files are backed up; do not use those clipped bases as the repair authority.

Generated candidates were registered by alpha-connected sprite bounds before conversion, rather than assuming that the image-generation output aligned perfectly to equal cells. Each sheet contains eight complete separated silhouettes. Godot conversion snaps all opaque pixels back to the **23 colors in Galeshear's original installed palette** and hardens alpha. Native size conversion uses the unchanged `build_small.py galeshear` path only.

This is an AI reconstruction of missing silhouettes, not an exact preservation of all interior pixels or poses. Minor generated anatomy/step variation remains. The three mirrored walk directions retain the existing pipeline's limitation; no new authored reverse-side cycles or attack sheets were invented. Creature identity, slate wings/taupe body, palette, arena scale, abilities and balance are retained.

## Validation and evidence

- Eight full stills and seventy-two game PNGs audited for hard alpha, original palette membership and transparent borders.
- Eight exact still and forty exact authored-walk comparisons against the existing resampler; twenty-four exact mirrored-walk comparisons; eight distinct steps in each authored direction.
- 138 native assertions: 72 game-frame borders, current arena loading Galeshear, all 64 runtime walking-frame selections, and Gale Shear running with repaired art.
- `native/stills.png`: before/after at 2×; `native/walk-frame-0..7.png`: every animation frame; `native/arena-*.png`: all eight current arena views; `native/gale-shear.png`: signature.
- `originals.json` records all 86 previous active/source files. `asset-audit.json`, `import-report.json` and `installation.json` record the outputs and preservation checks.

## Generation and reproduction

Built-in imagegen, not the CLI: one rotation edit and five walking-sheet edits, using the original corresponding images and the repaired rotation as a supporting silhouette reference. Prompt constraints: preserve creature identity, slate-blue/taupe palette, original facing/step order, complete the chopped sails/spars/tail tips, transparent padding in each cell, no labels or background. Exact requests are in `prompts.json`; generated originals are in `generated/`.

The archived importer, source inspection and audit scripts reproduce the conversion from those saved outputs. Their explicit D:/dev review paths are recorded and must be adjusted when moving the review workspace. Active outputs are all installed in the project; no runtime asset depends on the default generated-image folder.

Claude's current VFX, chain/CC changes, Listener line, Canvaswing/Windcut art, arena scripts, creature data and builders are preserved. The seven earlier form refinements, original backup manifests and Oxbowarchon's dark-jade reference remain exact. Native verification uses the combat hash in the installation record. No combat-code edits, creature-rule changes, all-form rebuild, or commit.
