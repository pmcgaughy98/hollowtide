# Courier Lookout menu: added life (Claude, 2026-10-05)

Preston: "it looks really good right now, just add what you can to spice it up." No new art and no paid generation. All additions are in `scripts/main_menu_art_preview.gd`, read their positions from the flat painting itself, step 12 times a second like the rest of the menu, and stop with Reduce Motion.

- River glints: about two dozen short white dashes (1 to 3 art px) that sparkle and move, only on pixels where the sunset already lights the open river (2,022 candidate pixels), plus warm ones on the town's lamp reflections below the quay.
- Window lamps: lit window pixels are grouped into lamps; each breathes and occasionally gutters, drawn with additive light.
- A flock of five birds crosses the sky right to left every 28 to 45 s (first at 6 s), two wing frames each.
- A shooting star every 20 to 34 s (first at 11 s).
- Wordmark (Preston: make the title cool, unique, top centre): HOLLOWTIDE is now pixel art, top centre. The menu font is drawn at the painting's pixel size with smoothing off in a small canvas, shown at 2x. Four dark depth layers and a rim sit under it. The face is sunset gold to coral in flat bands above a rolling tide line (foam with glints), and teal water with drifting ripples below it. A pale band sweeps across every 7 to 10 s, and a small mint wave with three gold diamonds sits underneath. The old title label stays as a hidden fallback.

Kept as they were: rain, stars, embers, title bob, cursor, the courier and Cinderhide walk-in and idles, the panels and music.

Checked with `tools/debug/menu_capture.gd` (new; usage in its header): no script errors. `menu_wordmark.png` and `menu_8s_flock.png` are full frames (the flock one predates the wordmark). Not checked: the Reduce Motion toggle with the new layers, and a resized window.
