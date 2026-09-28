# First route environment art pass

**Working art handoff for Grok, 26 September 2026.** The saved `first_route_prototype.tscn` was viewed in Summer's 2D editor and an offscreen scene preview. This brief describes visible composition, not a played camera review. Preston assigned Grok non-creature assets; creature sprites remain in Hollowtide Sprite Forge.

## What is already on screen

The route has a Wayline office at the dispatch end, a crooked three-dot marker on the high bend, a retaining wall, cottonwoods, a visible Cinderhide, the relay post, and a river-height marker. The sand path establishes a legible dispatch → marker → post → river direction. Most of the space between these landmarks is the same green ground with small repeated tufts. The editor's cyan circle around Cinderhide is an Area2D gizmo, not game art.

Keep the open walking space and each interactive landmark readable. Add evidence of people maintaining a river route and of water shaping the bank; do not fill every grass tile with decoration.

## Three focused art jobs

### 1. Old landing tie-off set

Make a small rope-wrapped timber bollard and one shorter worn companion post, viewed from the same top-down three-quarter angle as the route's current props. They belong near the final bend toward the relay post and river, suggesting where a ferry or workboat was once secured. Weathered wood, frayed rope, a damp lower edge, and a clear ground-contact shadow give it age without telling the player why the crossing changed. The rope-post candidate in `docs/HollowTide Sprites/Assets/Customer grok asset.png` is a reference for silhouette, not a ready-to-import sprite: it sits on a magenta gradient sheet and is much more detailed than the live route.

### 2. Cutbank edge and reed clusters

Make two short bank-edge pieces and two small reed/grass clumps that fit the live terrain grid and can be placed sparingly where the sand reaches the water. Show layered silt, roots or cut grass, and a few thin stems; leave negative space so the river remains visible. One edge piece can imply a lower, recently worn section without asserting a flood event. Avoid a continuous wall of vegetation, bright tropical foliage, and a repeated stamp pattern.

### 3. Return-mark detail

Make a small removable Wayline return-mark tab or inset slot detail for the existing relay post. The missing daily mark is the route's main observation, so the post must let players see that a mark *could* be there. The empty place should read at walking scale before dialogue explains it. Keep the existing relay-post silhouette unless a new prop is explicitly approved. Do not put a date or an explanation for the keeper's absence on the art.

## Fit and delivery

- Work from `scenes/first_route_prototype.tscn` and the current `assets/tilesets/river_bank_tileset.tres` scale. Favor crisp, consistent pixel clusters and a compact muted palette; compare at Godot's actual route zoom, not only on a large source image.
- Deliver each prop as its own lossless PNG with transparency, plus the editable source or original generation output. Include its pixel dimensions, palette notes, and usage rights/source. Preserve the existing creator/source history.
- Keep shadows and grass contact within each sprite's intended footprint so props can be placed without painting over the walking path.
- Hand off a simple contact sheet at route scale for review. No asset becomes final merely because this brief exists; Preston selects what to integrate.

## Placement intent for Codex or Claude after art review

The tie-off set belongs near the last path bend approaching the relay post at approximately (392, 240) in the current route scene. Put reeds and cutbank edges near the river approach around (432, 296), away from the height post's interaction space near (423, 205). The return-mark detail belongs on the existing relay post. These are placement leads, not final coordinates; keep collision and E-interaction reach clear and confirm in the edited scene before saving.

A successful pass makes the *work of using and maintaining this crossing* visible while preserving the route's quietness and the unresolved two-note call.

## Revised world style target (Preston feedback, 2026-09-26)

Preston finds the route too close to a Game Boy era monster game. The creature sprites and courier have finer shape, texture, and shading than the current terrain. The office, NPC concept, and trees are close enough to refine, not discard. This direction supersedes the earlier instruction above to make new pieces match the current low-detail terrain art; matching that texture would preserve the problem.

The current river_bank_tileset.tres uses assets/third_party/aroach_overworld/tilemap.png as a simple 16×16 base. Its even grass pattern, flat sand ribbon, hard straight water border, and repeated identical tufts make the world read older and cheaper than the player and Cinderhide. The office and cottonwoods have useful silhouettes, but their rendering and scale need a pass alongside the terrain. The player's head and costume detail should remain readable without the building looking like a small toy behind him.

### New art target for Grok

Create an original Hollowtide cutbank terrain set for this same route: grounded river town, humid late-summer light, silt and worn work materials. Aim for the visual density and nuanced clusters of the approved player/creature art, while keeping the path and interaction markers obvious. Use the game's existing top-down three-quarter view, firm dark outlines on props rather than around every ground tile, compact muted green/silt/tan/blue palettes, restrained highlights, and crisp unmixed pixels. The environment can have more texture and volume without becoming bright fantasy, painterly, or high-resolution illustration.

First small delivery: a contact sheet and separate source PNGs for (1) three grass variations, (2) three worn sand/path variations plus a grass transition, (3) two river surfaces plus a bank edge, and (4) one refined office/front door and one cottonwood at the live player's scale. Add the existing player and Cinderhide to the contact sheet for comparison, without editing either. A 16×16 tile may use detailed 1–2 pixel clusters; 32×32 overlays are fine for occasional larger roots, reeds, or silt marks. Keep the route's current tile geometry so Codex can replace terrain art without relocating gameplay objects. Supply seamless repeats and edge/corner pieces where required; a pretty collage is not yet a usable tileset.

Use docs/HollowTide Sprites/Assets/Cutbank tiles.png, Map Tile.jpg, and Customer grok asset.png as studies, not directly imported sheets. The cutbank sheet's soil layering and the Grok sheet's rope/stone material are closer to the desired detail. Check actual cell size, seams, magenta cleanup, and perspective before making any final sprites. The current tilemap.png is a layout reference only.

Review at game scale: the player must look native to the ground, the office must still read as a place one can enter, the cottonwood canopy must have depth without hiding the path, and the river must feel like a meaningful edge rather than a flat blue strip. Reject checkerboard grass, identical stamped tufts, thick outlines on every tile, neon water, rounded toy-like proportions, inconsistent pixel sizes, or a copied Pokémon map palette. Preserve the route's quiet space and the Wayline landmarks. After Preston chooses the contact sheet, replace one terrain family at a time and inspect the saved route before touching props or collision.
