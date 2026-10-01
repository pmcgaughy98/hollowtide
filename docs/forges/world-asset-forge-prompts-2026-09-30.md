# Route 1 world assets: Opal prompt list

Preston, 2026-09-30: the 8-bit placeholder tiles and the map in Route 1 do not fit the creatures' finish. Codex has installed the World Asset and Character Model Forges. This list supplies subjects; use the mode and layout rules below with each subject.

**Status:** proposals. Nothing here is generated or approved. Place and job names are the world bible's working names
(`docs/world/world-bible.md`, sections 4 to 6); no new names, lore or characters are invented here.

**Installed contract, 2026-09-30:** [World Asset Forge](https://opal.google/app/1gkKkSpg8Pakg7888e05tKqAhps9wFl19), [Character Model Forge](https://opal.google/app/1n9s7JHBcc7O3FJx-TdohZZ71HJbYcsd2).
- Use the current top-down three-quarter projection, 16x16 native terrain cells and a selected chibi courier (32x32 cell, about 30 pixels standing height). Preserve route geometry.
- Begin each run with an explicit mode. Terrain: `MODE: TILESET; TILE: 16x16; LAYOUT: standard 4x4 terrain atlas`. Props: `MODE: PROP; CANVAS: 128x128; FOOTPRINT: [number] current 16-pixel tiles`. Water: `MODE: WATER; TILE: 16x16; LAYOUT: 2x2 chronological surface tiles`.
- Terrain fills cells to their edges without gutters or a dark box around each tile. Full props have six logical pixels of clean magenta margin. These are different layout rules.
- Cinderhide supplies pixel finish only; the saved overworld references supply projection and scale. Local material colors remain distinct. See `world-asset-forge-spec-2026-09-30.md`.
- Wall segments, cliffs and overlay sets below require an explicit custom cell layout in the brief; they are not the default sixteen surface-transition tiles. Start with the ordinary grass/dirt/bank families before these custom layouts.

## How to use it
Paste the **style block** once per run (or have Codex build it into the Forge), then one **asset line**. Run one asset
at a time and approve it before the next, in the batch order below. Batch 1 alone is enough to restyle the route.

## Style block (every world asset)

```text
HOLLOWTIDE WORLD STYLE: Cinderhide-quality dark prop outlines, deliberate pixel clusters and readable material planes; do not copy its anatomy or coal/fire palette. Terrain has quieter contrast without a dark box around every cell. Three-quarter top-down view, modest visible roof tops and front walls, consistent scale beside the approved chibi courier: a 32x32 map cell and about 30 pixels standing height, large head and short body. This is an adult character in chibi map proportions; the adult dialogue portrait does not set world scale. Loess-yellow bluff soil, oak and cottonwood greens, weathered timber, rust-red brick and muted river blue-green. Use individual 4-6-tone material ramps and restrained upper-left daylight. Practical lived-in river frontier. No text or extra characters, smooth painting, checkerboard grass or repeated stamped tufts. PROP: whole object with six logical pixels of flat #FF00FF margin, no baked floor shadow. TILESET/WATER: fill each cell to its edges, no margin or magenta gutter except an explicitly transparent overlay.
```

## Batch 1: the ground (Route 1 cannot change look without these)

For ordinary surface families use the installed **sixteen-cell 4x4 atlas**: center A/B/C, north edge / east/south/west edges, NW outer / NE/SE/SW outer, NW inner / NE/SE/SW inner, repeated center A. Specify the neighboring material. Walls and cliffs need a separate explicit layout. Generate animated water surfaces and shoreline transitions in separate runs.

1. **Bluff-top grass.** `TILESET: short dry-green bluff grass with scattered clover and a few pale seed heads; edges and corners where it meets packed dirt.`
2. **Packed dirt lane.** `TILESET: a worn packed-earth footpath, loess yellow-tan, with faint cart ruts and small stones; edges and corners where it meets grass.`
3. **Switchback sand road.** `MODE: TILESET; TILE: 16x16; LAYOUT: standard 4x4 terrain atlas. Pale sandy road cut into a hillside, loose at the edges, firmer in the middle, with a few exposed roots. Neighbor: grass; edges and corners follow the standard order.` Generate the wooden step-log separately as a transparent PROP overlay; do not replace a transition slot with it.
4. **Loess bluff face.** `TILESET: a steep loess bluff seen from the front: crumbly pale yellow-tan soil in vertical flutes, grass overhanging the top lip, roots showing; top edge, face, base, and left and right end pieces. The face is two tiles tall.`
5. **Floodplain bank.** Two separate runs, each `MODE: TILESET; TILE: 16x16; LAYOUT: standard 4x4 terrain atlas`: dark silty mud with flattened river grass and quiet driftwood flecks. Run A neighbor: bluff grass. Run B neighbor: approved river water. One neighbor per atlas; match the approved surface references.
6. **River water.** `MODE: WATER; TILE: 16x16; LAYOUT: 2x2 chronological surface tiles. Slow broad river water, muted blue-green with brown silt and long low ripples. Four looping phases of the same seamless surface; matching borders, no shoreline pieces, gutters or labels.` Shoreline transitions are the separate mud/water run in entry 5.
7. **Tall prairie grass.** `TILESET: waist-high dry prairie grass in tan and olive, moving slightly; a full tile, and a front-edge tile that can draw over a character's legs. This is where wild creatures are met.`

## Batch 2: the landmarks (each replaces a placeholder now in the route)

One object per image, whole object in frame.

8. **Dispatch hall.** `PROP, LARGE: the Wayline dispatch hall, a plain two-storey brick and timber building on a bluff-top street: a covered porch, a wide door, a route board on the wall beside it, one lit window, a small water trough for creature partners. Practical, a working post office for runners, not grand. About six tiles wide.`
9. **Route marker, upright.** `PROP, SMALL: a waist-high wooden route marker post with a flat head carved with three dots in a row, weathered, set in a small ring of stones. One tile.`
10. **Route marker, turned.** `PROP, SMALL: the same route marker post knocked crooked and twisted sideways so its three-dot face points the wrong way, soil disturbed at its base. One tile.`
11. **Relay post.** `PROP, LARGE: an abandoned riverside relay post: a small timber shelter with a shingle roof under a big cottonwood, a dry message slot in its front wall standing empty, a blank board where the day's mark should be, an unlit lantern on a hook. Damp, quiet, recently used. About three tiles wide.`
12. **Flood-mark wall.** `PROP, MEDIUM: a short old stone and brick river wall with several horizontal high-water lines cut into it at different heights, stained darker below each line, moss at the base. No numbers or letters. About three tiles wide.`
13. **River-height post.** `PROP, SMALL: a tall timber gauge post at the water's edge with evenly spaced notches up its side and a darker waterline stain. No numbers. One tile wide, three tall.`
14. **Old ferry landing.** `PROP, LARGE: an old wooden ferry landing: a plank ramp running into the water, two heavy mooring posts with worn rope, a rusted winch, some planks missing. Unused for years. About five tiles wide.`
15. **Retaining wall.** `TILESET: a bluff retaining wall of stacked rust-red brick and grey stone, a little bowed, weeds in the joints; left end, middle, right end, and a version with a stair cut through it.`

## Batch 3: what grows and what stands around

16. **Cottonwood.** `PROP, LARGE, 2 VARIANTS: a tall bluff cottonwood tree with a thick furrowed trunk and a broad rounded crown of pale green heart-shaped leaves; one full tree and one leaning over water. Trunk base one tile, crown about four tiles.`
17. **Oak and hickory.** `PROP, LARGE, 2 VARIANTS: a bluff woodland oak and a shagbark hickory, darker and denser than the cottonwood, for the upper route.`
18. **Undergrowth.** `PROP SHEET: six small plants on one sheet, each under one tile: a shrub, a clump of prairie grass, a large beardtongue in pale flower, a scarlet gaura, a fern, a fallen branch.`
19. **Service shed.** `PROP, MEDIUM: a small river service shed of grey boards with a tin roof, a padlocked door, coiled rope and a boat hook on the wall. About two tiles wide.`
20. **Street pieces.** `PROP SHEET: six small street objects on one sheet: a lantern post, a bench, a water trough, a stack of crates, a hand cart, a section of split-rail fence that tiles left to right.`
21. **Station kit.** `PROP SHEET: five Wayline station objects on one sheet: a map board on legs, a first-aid box, a sealed route pouch, a message hook with a paper tag, a small brass bell.`

## Batch 4: people (the new character Forge)

Use the Character Model Forge for people. New NPC: `KIND: OVERWORLD; MODE: NEW; OUTPUT: SINGLE; DIRECTION: DOWN; CELL: 32x32; VISIBLE HEIGHT: about 30 pixels`, Identity Reference `NONE`, Style Reference approved Cinderhide for finish only. Keep chibi map proportions while preserving each person's age. Then `KIND: OVERWORLD; MODE: REDRAW; OUTPUT: TURNAROUND`, with the approved exact identity, 2x2 DOWN, UP / LEFT, RIGHT and equal scale. Walks come afterward, four distinct poses by default, one direction per run. Optional dialogue portraits use `KIND: PORTRAIT; CELL: 96x96`, adult waist-up proportions of the same identity. Preston's existing main courier is already selected; do not redesign him as a NEW person. See `new-courier-character-forge-prompt-2026-09-30.md`.

22. **The courier (player).** `KIND: OVERWORLD; MODE: REDRAW; OUTPUT: TURNAROUND; CELL: 32x32; VISIBLE HEIGHT: about 30 pixels. The approved original chibi courier: brown hair, brass forehead goggles, teal jacket, tan trousers, brown boots and cross-body satchel. Preserve the attached identity and large-head/short-body map anatomy. 2x2 DOWN, UP / LEFT, RIGHT, same scale and foot baseline.` Identity Reference: `Character/Main Courier - Chibi Identity - Four Views.png`. Claude owns integration of the prepared original cuts; the incomplete old side strides still need contact/passing additions.
23. **The dispatcher.** `CHARACTER, 4 DIRECTIONS, STANDING: a Wayline dispatcher, middle-aged, shirtsleeves and a work apron with pockets, ink on the fingers, a pencil behind one ear. Calm and busy.`
24. **A ferry ward resident.** `CHARACTER, 4 DIRECTIONS, STANDING: an older river-district resident in a patched coat and rubber boots, a net bag over one shoulder. Watchful, has seen floods.`
25. **Cinderhide in the field.** Use the creature Sprite Forge, not the human Character Forge. `TASK: REDRAW; PURPOSE: OVERWORLD; VIEW: [one direction]. Cinderhide, exactly the approved reference, at a stated small field scale. Keep its charcoal body, wedge snout, horn plates and ember vents; no new anatomy. One standing view per run.` A dedicated small field sheet remains a review candidate.

## Batch 5: later, not needed for the Route 1 slice
A bluff-road battle backdrop, Highbank street buildings beyond the dispatch hall, interior tiles, the far bank.

## After each asset arrives
Codex cuts it, keys the magenta, preserves its approved local material ramps and shared lighting anchors, and
places it in `scenes/first_route_prototype.tscn` beside the placeholder it replaces, so Preston can compare in the game
before the placeholder is removed.

## Main menu art (Concept C, the Courier Lookout), added 2026-09-30

`scenes/main_menu.tscn` runs now with stand-in art from `tools/build_menu_blockout.py`. Each file below replaces one
stand-in in `assets/sprites/menu/` with no code change. Every layer is drawn at 576 art pixels wide and shown at 2x;
the moving layers must wrap left edge to right edge seamlessly. These are wide scenery layers, not PROP or TILESET
runs, so each brief needs a custom layout line (confirm with Codex how the World Asset Forge takes that).

1. **Storm sky** (`sky.png`, 576x324, still): slate-grey sky in flat bands, darkest at the top, lightest at the horizon line 150 pixels down.
2. **Storm clouds** (`clouds.png`, 576x130, wraps): heavy, bruised storm clouds in three tones, transparent between them.
3. **Far bank** (`far_bank.png`, 576x26, still): the far bank's low tree line and fields, pale and blue-grey with distance.
4. **River** (`river.png`, 576x100, still): the broad river, deep muted blue-green (#42776B family), lighter toward the far bank.
5. **Old Ferry Ward** (`ward.png`, 576x100, still, transparent above the roofs): slate gable roofs and timber walls along a shore path at the right half, a few warm lit windows, dark ground below.
6. **River fog** (`fog.png`, 576x44, wraps): a low, see-through band of fog.
7. **The bluff** (`bluff.png`, 576x324, still, transparent above the ground): the loess bluff filling the lower left, its top a switchback road at about 238 pixels down, fluted yellow-tan face dropping away to the right, grass on the lip, and a Wayline route marker with its three-dot mark near the edge.
8. **Courier, from behind, standing** (Character Model Forge): the adult courier standing still at a lookout, seen from behind, the route pouch on its strap, coat moving slightly in the wind (4 frames for the research's coat flutter).
9. **Cinderhide, from behind, sitting** (Sprite or Back View Forge): Cinderhide's approved back view, sitting on its haunches, looking out.

**Palette change, same day (Preston: "more synthy, whimsical, chiptune"):** the menu is now a violet-to-rose dusk,
not a grey storm. Ask for: a dusk sky from deep indigo to rose with a peach glow at the horizon; violet clouds lit pink
from underneath; the river teal with the rose sky reflected near the far bank; violet-slate roofs with warm windows;
lavender fog; loess under dusk light with lavender shadows and teal-green grass. The stand-ins show the colours.

### Main menu, three more pieces (2026-09-30)
10. **Title logo** (`logo.png`, about 240x60, transparent): the word HOLLOWTIDE as a hand-made pixel-art logo, not a typed font: chunky rounded letters in warm cream with a deep indigo outline and a rose drop shadow, a small wave or ripple worked into the letters, and a faint ember glint. Legible at a glance. (The current title is the Alegreya Sans font.)
11. **Menu frame** (`panel_frame.png`, 48x48, transparent centre, for 9-slice): the menu panel's border as pixel art: an indigo panel edge with a lavender inner line and small rounded corners, so it scales to any size without stretching the corners.
12. **Menu cursor** (`cursor.png`, 16x16, 2 frames): a small pixel pointer in mint, frame 2 nudged one pixel forward, for the bounce.
