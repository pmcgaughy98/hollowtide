# Hollowtide World Asset Forge

Preston requested a dedicated environment Forge on 2026-09-30. It supplies original terrain and props for the river route. The existing route geometry remains 16 pixels per tile; this contract does not silently migrate it to a larger grid.

Forge: https://opal.google/app/1gkKkSpg8Pakg7888e05tKqAhps9wFl19

**Installed and saved:** Nano Banana Pro image step with all three linked inputs, plus an output page that displays the original image without filters or invented exports. Generate and output prompts survived reopening on 2026-09-30. No world-asset image was run in this pass; seamlessness and visual quality require review of the first result.

## Inputs and reference roles

1. **Asset Brief:** mode, asset, native grid, footprint and any layout or seams.
2. **Style Anchor:** approved Cinderhide or a newly approved world asset. Transfers outline, cluster craft and shading quality only. Never transfer reptile anatomy or the Ember palette to buildings and plants.
3. **World Perspective Reference:** saved overworld study. Transfers top-down projection, roof/wall depth and relative human scale. Do not copy its actual graphics or map.

The most useful local references are the farm and dark overworld studies in `C:/Users/pmcga/Documents/Codex/Hollowtide/Reference Images/Overworld/`. The reviewed Game-Ideas files show battle and item interfaces, not the route angle.

## Modes

| Mode | Output | Native target |
|---|---|---|
| PROP | One full object on flat magenta | Specify canvas in brief; default 128x128, footprint in 16-pixel tiles |
| TILESET | One 4x4 terrain atlas | Default 16x16 cells for the current route, 64x64 logical sheet |
| WATER | Four chronological seamless surface tiles in a 2x2 | Same native tile size and phase-compatible borders |
| PROP SET | Explicitly requested small set in stated equal cells | One whole object in each cell, shared projection and scale |

A 32-pixel terrain option is allowed only when requested. Preserve that native output as a candidate for a planned grid change; do not shrink it automatically into the current 16-pixel map.

TILESET order, row-major: center A, center B, center C, north edge; east edge, south edge, west edge, northwest outer corner; northeast outer corner, southeast outer corner, southwest outer corner, northwest inner corner; northeast inner corner, southeast inner corner, southwest inner corner, center A repeat. Every slot is a full square material tile with the named transition drawn within it. The brief identifies the neighboring material and which side of each border it occupies.

**Tile exception:** terrain cells go all the way to their edges. No six-pixel empty margin, magenta gutter, ground outline or fake floating tile. Magenta is only for explicitly transparent overlays. Neighboring boundaries must match in color and pattern; no bevels or grid borders. This is a generation request, not a guarantee of a correct Godot atlas or seamless output.

## Shared world finish

Use the depth of the saved exploration references: ground from above, visible roof tops and front/side walls, raised tree canopies and believable door height beside the selected chibi courier (32x32 map cell, roughly 30 logical pixels standing height). The character is an adult drawn with a large head and short map body. The 96x96 adult dialogue portrait is a separate tier and does not set environment scale. Keep an original inland river identity with loess-yellow soil, dark silty banks, cottonwood and oak, weathered timber, rust-red brick and muted river blue-green. Paths and interactable landmarks remain legible.

Use crisp consistent pixel clusters, grouped values, restrained highlights and local material ramps. Dark silhouette outlines belong on props, not around every ground tile. No toy houses, checkerboard grass, repeated stamped tufts, painterly texture or extremely coarse handheld graphics. Turbo Green stays a UI accent; it is not the whole world palette. The color report's local-ramp/shared-anchor idea is useful; its old Nature turtle and universal-grid examples are superseded by current project decisions. Bloom is the current growth essence.

Props keep their entire object six logical pixels inside the canvas on pure #FF00FF. Shadows are omitted or requested as a separate shadow layer, never blended into magenta. Trees and buildings remain flattened candidates; separated canopies, roof occlusion, collision footprints and Y ordering are engine work after approval.

## First route generation order

Use `world-asset-forge-prompts-2026-09-30.md`, beginning with grass, packed dirt and river bank. Approve one family before widening it. Then request the dispatch hall, cottonwood and relay-post landmarks. Keep originals and inspect a contact sheet beside the courier and Cinderhide before changing the live route.

Example Asset Brief:

```text
MODE: TILESET; TILE: 16x16 logical pixels; LAYOUT: 4x4 standard terrain order. Bluff-top short olive grass with restrained clover and seed-head clusters. Neighbor material is loess-yellow packed dirt. In each edge tile grass occupies the interior side and dirt the named outer side; corners follow the same rule. Full square tiles with no margin or gutters, no dark border around each tile. Natural quiet ground, with enough value variation to belong beside our detailed courier and creatures. Upper-left daylight. Seamless repeats and transitions.
```

Do not force all world sprites into one exact palette. Approve material ramps and shared shadow/light anchors, then preserve each asset's intended material colors during preparation.
