# Hollowtide World Asset Forge: Gemini skill

Built from a downloaded Opal graph by `tools/export_opal_forges.py`. The raw graph remains in `../opal-export/`.

Includes the saved 2026-09-30 Generate prompt and input hints from [the verified revision](../records/world-chibi-scale-2026-09-30/verified-prompt-record.json). Checked after reopening in Opal; no generation-quality claim. This is a merged instruction export, not a fresh live app backup.

**Skill name to use in Gemini:** `world-asset-forge`

## What you give it each run

- **Asset Brief:** text or an image. Enter a descriptive brief for your asset.
- **Style Anchor:** an image you attach. Upload an image defining the desired art style.
- **World Perspective Reference:** an image you attach. Upload a reference image for world perspective.

## Model

- Generate World Asset - Chibi Scale v2: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Asset Brief], [Style Anchor], [World Perspective Reference] in my message. Use them exactly as described below.

Create ONE original Hollowtide WORLD ASSET candidate from Asset Brief and linked images. Interpret MODE explicitly. Default MODE PROP. Do not generate a game, mockup, map screenshot or character.
REFERENCE ROLES: Style Anchor governs crisp outlines, pixel clusters and material shading ONLY. If it is a creature, do not transfer creature anatomy, fire motifs or its whole palette. World Perspective Reference governs the top-down three-quarter camera, roof/front-wall depth and scale ONLY; never copy another game's assets, symbols or map. Use modest visible top surfaces and clear front faces, scaled beside the approved chibi map courier: a 32x32 logical character cell and roughly 30 logical pixels of standing height, with a large head and short body. The courier is an adult drawn in chibi map proportions. Doors, paths and props fit this map figure. The 96x96 adult waist-up dialogue portrait is a separate art tier and does not set map scale. Keep the current 16x16 map grid.
MODE PROP: one complete requested object on a 128x128 logical-pixel canvas by default. Asset Brief states footprint in the current 16x16 world tiles. Keep at least 6 logical pixels of clean margin around the entire prop, including leaves, roots and roof tips. Flat #FF00FF outside. No cast shadow on the background; separate shadows can be prepared later.
MODE TILESET: default native tile 16x16, exactly sixteen equal cells in a 4x4 atlas (64x64 logical pixels total), no gutters or margin between cells. Brief names both surface and neighboring material. Row-major cell order: center A, center B, center C, north edge / east edge, south edge, west edge, northwest outer corner / northeast outer, southeast outer, southwest outer, northwest inner corner / northeast inner, southeast inner, southwest inner, repeat center A. Fill every tile to its edges; no magenta unless brief explicitly requests a transparent overlay. Seamless edges with stated neighbor. No dark outline boxing each terrain tile. A 32x32 native tile is allowed ONLY when brief explicitly requests a future grid migration; do not change the current 16x16 game grid automatically.
MODE WATER: four chronological looping surface tiles in 2x2, default16x16 cells, border continuity and shared surface phase. No background gutters; no whitewater unless requested.
MODE PROP SET: only the explicitly named small set in stated equal-size cells. Shared scale, projection and finish; no extra props.
WORLD: mature grounded river frontier folklore. Loess and silt banks, cottonwood and oak, weathered timber, rust-red brick, muted blue-green water, practical courier infrastructure when requested. Original Hollowtide architecture; no borrowed game signs or recognizable characters. Local material ramps, restrained cool shadows, warm upper-left daylight. Quiet ground contrast leaves room for creatures and people. Paths and interactables remain readable. Turbo Green is a selective UI accent, not the global world palette.
FINISH: Cinderhide-quality crisp dark silhouettes on props, selective internal lines, large readable pixel clusters and 4-6 tones per material. Ground tiles use softer contrast without outlines around every cell. Neither sparse old handheld graphics nor painterly detail/noise. No smooth gradients, antialiasing, blur, dithering, random checkerboard grass, repeated stamped tufts, decorative text or frame labels. Use one coherent logical pixel scale; enlarged display may repeat square pixels.
DELIVERY: only the requested image. This is a candidate, not a guaranteed native-size export, transparent PNG, working TileSet, rig or automatic Godot import. Preserve original result for approval and later engine preparation.

 asset_brief: [Asset Brief]

style_anchor: [Style Anchor]

world_perspective_reference: [World Perspective Reference]
```
