# What "the synthesis" means, and how Imagine may use it (2026-10-16)

The file is `docs/design/genre-synthesis-2026-10-12.md`. Preston's line at the top is the definition: keep Hollowtide's foundation, and build on the dungeon-crawl genre far enough that the game is its own expression.

Use the structure. Do not copy the screens.

- A grid, turns, stairs, a bag, a hub, companions, and a run that ends with carried things lost and growth kept are genre-wide. They are free.
- Another game's art, tiles, music, names, and UI are not. Look and feel is protected. A screen that reads as Explorers of Sky with the names filed off is the failure mode the synthesis names.
- Hollowtide's own picture is the river, the lantern as the clock, the Wayline's parcels, the Growth Shrine, moss, worn brass, parchment, and river teal. Player-facing words are Sense, a nest, Second Wind, growth, and "went down."

## Imagine

Imagine can paint a mood: a desk, a lantern, a parcel, a frame study. It cannot set menu type, and it cannot replace the pixel 9-slice frames.

Three studies are in this folder (`frame-study.jpg`, `icon-study.jpg`, `desk-study.jpg`). The frame has about 17,000 colors and the icon sheet about 60,000, in JPEG. They are not pixel frames. They were not installed over `assets/sprites/ui/frame/`. Those frames stay Codex's 9-slices. That is the defence the synthesis already states.

Prompts for the next study: chunky pixels, moss, brass, parchment, lantern amber, river teal, silt. No letters, no numbers, no creatures unless the ask is a creature, and never a blue window, a ball, or a copied menu layout. Generate the set as one sheet. Key a flat background before any PNG is cut. If the result is not a small palette on a pixel grid, it stays a study.

## Wired this session

- Main menu title, labels, and buttons use `UI.font` (`display`, `title`, `body`, `button`) instead of Alegreya.
- Pause menu buttons no longer preload Alegreya. `UI.style_button` sets the button face.
- The battle screen's creature names use the button face and the HP numbers use the number face, with smoothing off.
- The dungeon HUD draws a small brass lantern in code and drops the word "Lantern" beside the light bar.

The opening, the first route, and the world atlas still have their own Alegreya labels. They were not restyled in this pass.
