# Codex: town buildings that belong to the world (Claude's brief, 2026-10-10)

Preston, October 10: "make it do the outline thing... help it with synthesis knowledge too while it works on map and world. Cause its generating the towns but they dont blend into the world or have black outlines. They look like buildings you cant enter in games but with ones you cant enter they are more defined and you can tell you can enter them. Like the door looks interactable etc."

Three problems, one per section: no outline, no grounding, doors that do not read as doors. The synthesis notes are structure only (how the games are built), never their tiles, art or numbers.

## 1. The outline: your Hollowtide Sprite finish on buildings

"The outline thing" is your own finish: `scripts/arena/creature_finish.gd` / `creature_finish.gdshader`, the near-black outline and edge repair every creature wears (pixel artists call the technique selective outlining, or "sel-out": a dark line round the silhouette, lighter where the light hits). The creatures have it and the buildings do not, so the creatures read as one game and the town as another.

- Today `home_painter.gd` and `item_shop_painter.gd` blit the building art into the ground image, so no shader can reach it. **Draw each building as its own `Sprite2D`** on top of the painted ground and give it the same finish, or, if a baked image is kept, run the same outline as a bake-time pass on the building's alpha edge. Separate sprites also let creatures walk behind a roof edge later (y-sort).
- Same outline colour and weight as the creatures at the same scale. No pure black elsewhere in the building; its darkest shadows take the ground's darkest tone.

## 2. Grounding: buildings that sit in the ground, not on it

From the synthesis:
- **pokeemerald (pret)** builds a town from one tileset: buildings are metatiles on the same grid as the grass and paths, and the bottom row of every building is a transition into the ground (foundation stones, shadow and grass edge baked in), with light from one side for the whole map.
- **Explorers of Sky's Treasure Town**: every service sits on a cleared patch of path ground, its entrance faces the main path, and the path widens to meet the door.

A recipe for Highbank:
- **Contact shadow** under each building: a soft one- or two-pixel darker band on the ground along the base and down the side away from the light (the creatures are lit from the top left, so the shadow falls bottom right), about a third darker than the ground under it.
- **A foundation row**: stones or packed earth along the base, so the wall does not stop on a clean line against grass.
- **Grass over the edge**: tufts that overlap the bottom of the wall at a few points.
- **Worn ground at the door**: path colour fanning out from the door to the path.
- **One palette family**: pull the ground's greens and earths into the building's shadow tones, and keep the creatures' top-left light.

## 3. Doors you can tell are doors (affordance)

In the Pokémon games an enterable door is a dark opening or a framed door, a mat or step on the ground in front of it, the path reaching it, and it swings open when walked into (pokeemerald gives door metatiles their own behaviour and an opening animation; walking in triggers a warp). A building you cannot enter shows no door on its walkable side, or a shuttered one with no mat and no path. Explorers of Sky's shops add a keeper and a sign at the counter.

Rules for Highbank (every place in `town_layout.gd` with a `door`):
- **A framed door** exactly on the door tile (the hall is two tiles: `door_tiles` `(23, 6)` and `(24, 6)`): a lighter frame, a dark inside, and a warm lamp glow from within for the home and the services.
- **A step or mat** on the door tile, and path colour joining it to the street.
- **A sign or lantern** beside each service door that says what it is at a glance (the shop a bag, storage a crate, the scroll keeper a scroll, the hall the guild mark).
- **It opens**: two or three frames of the door swinging when the player uses it (the door sound is already wired in `hub_town.gd`, `_sfx("door")` in `act_use`). Tell me the frame names and I will hook the swap, or hook it yourself in `act_use`.
- **Decoration reads as decoration**: any building with no entry gets no door on its path side, or a shuttered one, no mat, no lantern.
- Optional, mine if you want it: a small "E" prompt or a faint highlight on the door tile when the leader stands on it.

## 4. While you work on the map and the world: how the games structure a map

- **pokeemerald's map files** split a map into the tile layout, then **events**: *warps* (a door tile leads to an interior and a spawn tile), *signs* (background events read when the player faces them and presses the button), *objects* (NPCs with a movement type) and *triggers* (tiles that start a script). Highbank already works this way in spirit: `town_layout.gd` holds the doors and services; when the interiors come, a door is a warp to a scene and a spawn tile, a sign is a place with a facing rule, and an NPC is an object with a home tile. Keeping that split (layout file, then events) keeps the world data readable.
- **Explorers of Sky's town** is a short street: the guild up high, services along one road, the hero's home apart, exits at the ends. Our layout follows it (`docs/world/hub-layout-2026-10-09/README.md`, `docs/research/pmd-video-notes-2026-10-09.md`).
- **Blending areas into each other**: the edges of a map share tiles with the next map (pokeemerald's border tiles), so a town does not end at a hard line. Highbank's road east `Rect2i(45, 9, 3, 2)` and the riverbank should fade into what lies beyond, not stop.

## Order, scope, checks
1. Home and Item Shop (their art exists): separate sprites with the finish, contact shadow, foundation row, framed door with mat, glow, sign.
2. Wayline Hall with its two-tile door.
3. The rest of the services, then the decorative buildings.

Positions, sizes, doors and paths stay as `town_layout.gd` has them; tell me before moving one. Checks: `tools/debug/hub_town_check.gd`, `tools/debug/hall_door_check.gd`, and a native capture of each building at 1152x648 (`tools/debug/ui_tour_capture.gd` takes the town). The town HUD now uses `scripts/ui/ui_style.gd`; signboards over the places are drawn in `hub_town.gd` `_draw_labels` and can go once your signs are in the art.
