# Hollowtide overworld perspective brief

**2026-09-27.** Preston's two references in Downloads (`images.jfif` and `images (1).jfif`) show overworld exploration. Preston clarified that the requested view is the **overworld route**, not the battle screen. The existing battle camera and HUD are outside this change.

## What the references show

Both views use a top-down three-quarter *art projection*: the ground reads from above, but buildings show roof and front/side faces; trees have raised canopies, trunk height and cast shadows; characters can pass behind props. Paths, crops, shrubs, fences and raised edges form layered depth. This angle is drawn into each sprite and tile. Rotating a Godot Camera2D cannot reveal an unseen building wall or the back of a tree.

## Current Hollowtide comparison

- `scenes/main.tscn` has a large uniform grass field, simple straight paths, sparse props and little height/occlusion. A live view on 2026-09-27 showed the courier and Cinderhide readable but surrounded by broad empty ground.
- `scenes/first_route_prototype.tscn` already has a wayline office, cottonwoods, a retaining wall, route marker and river edge. Its terrain covers 40×24 cells at 16 pixels each (640×384 world pixels). Its building and tree props begin to show the desired angle, but the ground materials, prop density and shadows are still provisional.
- The approved creature finish is closer to Cinderhide and the current player than the small, flat environment assets. Environment redraws should match their clustered shading and material detail, without merely enlarging low-resolution retro tiles.

## Camera adjustment made now

`scenes/player.tscn` keeps its existing 3× pixel-clean zoom. Camera2D offset is now (0, -16) world pixels, placing the courier slightly below the viewport center and showing more of the route ahead. This is a framing adjustment; it does not change the projection of the art.

## Art and scene targets

1. Use a consistent three-quarter projection for one route slice: ground plane from above, roof and wall faces visible, door/window height scaled to the courier's roughly 35-world-pixel figure. Draw assets for the final 3× view, not a much lower-detail handheld style.
2. Replace broad plain grass with restrained material variation: soil, short/long grass, floodplain reeds, stones, wheel ruts and damp ground clusters. Keep traversable ground visually clear.
3. Give the wayline office readable roof thickness, front/side wall, entrance depth and a grounded shadow. Make its silhouette distinct from a generic small house.
4. Make cottonwoods tall enough to overlap a walking courier; separate trunk, canopy and shadow. Use Y-based ordering or explicit foreground layers where the player passes behind canopy/structures. Keep collisions at the trunk/footprint, not the full canopy.
5. Shape the river edge as a bank with elevation: exposed mud/silt, retaining structures, wet marks, reeds and a height marker. The river should feel consequential to the route and flood story rather than like a flat blue rectangle.
6. Add a few authored landmarks and route cues before increasing decoration everywhere: a wayline sign, delivery post, repair point, levee/river sight line and a path turn. Place these to guide movement and exploration.
7. Compare every new environment asset at native gameplay size beside the current courier and Cinderhide. Match value grouping and pixel cluster finish; preserve the creature palette rather than tinting the entire world Turbo Green.

## Implementation order

Grok can make a small, cohesive environment art pack for the first route from this brief; creature sprites remain under the established creature-art workflow. Claude can plan the TileMapLayer/prop layering, Y ordering, occlusion and collisions. Codex can import the approved pack, wire layers and keep camera and route behavior consistent. Judge the first route in the actual viewport before extending the art system across the main scene.

**Do not interpret the references as a request to rotate or skew the entire rendered scene.** That would deform the courier, creature sprites, HUD and pixel clusters without adding the missing three-quarter building/tree artwork.
