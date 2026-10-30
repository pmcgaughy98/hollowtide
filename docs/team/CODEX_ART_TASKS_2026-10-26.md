# Codex art tasks, 2026-10-26 (written by tools/art/write_art_tasks.py; do not edit by hand)

**GATE (Wayline Tower, 2026-10-27): nothing in the tower batches is painted until Preston has walked the coded blockout and approved the key.** The key (cx-11) starts after his walk (Tower Rise with HT_HIGHBANK_V2=1, and scenes/debug/building_lineup.tscn); his yes on the key opens the parts, the title and Grok's small set. The far views and the Tower's sky (cx-10) no longer wait on the crown (cx-14): they were re-briefed for the vast-scale design and opened on 2026-10-28.

Placeholder factory, task-list lane (Claude). 17 batches, 57 slots: the plan's 10 batches and 30 slots (00-BUILD-PLAN.md section 4; the Tower's old one-picture slot left cx-01 on 2026-10-27), plus 2 road batches (9 slots) that lane S added for Preston's canon change of 2026-10-26 (the road back shows Highbank and the Wayline Tower far off), plus 5 batches (18 slots) for the approved Wayline Tower and the Highbank title (2026-10-27, TOWER_DESIGN.md section 11). Registry 19fe5c2bff04.

**Why the old buildings read wrong.** The building rects were set on 2026-10-09 (the Home and Item Shop folders carry that date) and each PNG had to equal its solid footprint, 24 px a tile, with a one-tile door. On 2026-10-10, a day later, the creatures' town set was rebuilt at 1.5x. A stage 3 now stands 55 to 69 px, 2.3 to 2.9 tiles, beside a five-tile house with a 24 px door. Nothing in the old brief tied door or wall height to the creatures. The new canvases do: a single door is 22x48 (clears Sparkjab, a stage 2), the Tower's double door 48x64 (clears Galeshear, a stage 3), and every building and room task names the creature its door must clear (C11 measures it from the creature's own town sprite at check time).

**Nothing installs without Preston's yes.** Every batch ends in a review sheet (`python tools/art/review_sheet.py <batch>`): per slot the placeholder, the prepared candidate, an in-game capture and the check lines. Preston answers yes, redo (one line why) or keep the placeholder; Claude records it in the batch's review.json; `install_slot.py` refuses any slot without his yes.

**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees. Ids, files and flags keep `hall` (`town.building.hall`, rooms `hall` and `hall_low`). Tower Rise is the v2 area's working label. Highbank v2 stays behind its switch (HT_HIGHBANK_V2, off) until Preston walks it. All new names are working labels.

**Wayline Tower approved, 2026-10-27** (Preston: "go with the defaults and build it"; docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md). A rooted river-stone tower 720 px (30 tiles) tall, built from 21 parts in one 432x720 frame, whose living root (the Reach) curls over the top like a crook to hold the Waiting Lamp above the door. The camera leans up 72 px at the doors. Today's game (v1) keeps the legacy 240x144 Hall until Preston walks v2. The title's town becomes Highbank with the Tower prominent (cx-15); the old title village is kept for a future town on another map. The Reach, the Waiting Lamp, the Route Board, the First Post and the dark lantern are working labels until Preston renames or cuts them.

## Generator balances (read only, 2026-10-27; nothing was generated)

- **AutoSprite** (get_account): 15 credits. Connected, no sign-in needed. generate_asset_preview costs 1 credit a call; an 8-direction character pack costs 15. The 2026-10-26 sprite tool test recorded that its generate step needed a paid plan; not retested, since no generation call was made.
- **PixelLab** (get_balance): $0.00 credits; trial plan with 0 plan generations left (51.2 used of 40); 16 daily bonus generations left today, refilled nightly (+5, up to 20).
- **SpriteCook** (get_credit_balance): 3 credits, free tier, one job at a time.
- **Retro Diffusion** (get_balance): $0.11 (the call also reports 50 credits; the free cost estimate reports 0 credits left). One RD Pro top-down prop at 48x56 is estimated at $0.18, so RD needs a top-up before any run.

Every credit spend waits for Preston's yes. Each task names one **Alt** route for when Codex's route is not the best fit; Codex stays the owner the registry names.

<details><summary>What each alternative tool makes</summary>

- **AutoSprite** (connected): makes characters (8-direction packs, spritesheets, portraits, poses) and single assets through generate_asset_preview: weapon, item, character, prop, effect or texture, in pixel, painted, flat, anime, comic or isometric style, 1 credit a call; pixelArt true gives a 16-bit sprite on a crisp grid in 32 colours. No style reference and no size control, so prepare_slot does the sizing and the palette. Never for creatures here.
- **PixelLab**: create_map_object makes one object on a clear background, canvas 32 to 400 px (clear only up to 40,000 px of area); given a background_image (up to 192x192 for inpainting) it paints the object in that picture's style. create_building_kit makes matched floor, wall, doorway and stair pieces (square_topdown, tiles 16 to 96 px, walls 1 to 3 tiles, a colour cap). create_ui_asset makes 9-slice-style panels (192 to 688 px). The top-down tileset tools make two-terrain autotile sets (16 or 32 px tiles). pixelart_workbench is free: exact pixels placed by hand.
- **SpriteCook**: generate_game_art makes pixel or HD stills from text, with up to 14 uploaded style images (style_asset_ids), one reference or one picture to edit; aspect 1:1, 16:9 or 9:16; mode texture for seamless fills; the pixel-engine-image-v1 model draws at exactly the asked size from 16 to 128 px (sides up to 4:1) with the background removed, but takes no references. UI kits and tilesets too. Its 3 credits cover very little.
- **Retro Diffusion**: RD Pro styles take up to 9 reference images per run and draw from 12 px up to 256 px (a 16:9 scene is 256x144, which is not a whole-number step to 384x216). Needs a top-up first (see the balance).

</details>

## How Codex delivers and installs

1. Read the task's spec JSON, the target (the placeholder at its exact size), the grid (pixel and tile lines, the foot row in cyan, the door box in yellow, the scale creature as a grey block) and the card. Paint to the exact size; never resize the canvas.
2. Lock the batch folder while working: `docs/art/slot-candidates/<batch>/CODEX_IN_PROGRESS`. Remove it when the batch is delivered.
3. Per slot, into `docs/art/slot-candidates/<batch>/<slot_id>/`: `raw.png` (untouched output), `prompt.txt`, `ledger.json` (tool, references, cost, date), then
   `python tools/art/prepare_slot.py <slot_id> raw.png prepared.png` and `python tools/art/validate_slot.py <slot_id> prepared.png` (writes `prepared.png.check.json`; exit 0 means every scripted check passes). A raw painted at exactly the slot's size keeps every pixel where it is: prepare_slot only keys the background, hardens alpha and snaps colours to the strip.
4. `python tools/art/review_sheet.py <batch>` makes `review_sheet.png` for Preston. Do not install. Preston answers per slot; Claude records the answers in `review.json`.
5. Only after his yes: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/<batch>/<slot_id>/prepared.png --batch <batch>` (it refuses on a lock, a failed check or no yes; it backs up what it replaces and records the hash), then `python tools/debug/run_checks.py <the batch's check words> --jobs 1`.
6. Do not edit the registry (`scripts/art/slots/*.gd`) or another lane's files. List "source issues for Claude" in your result. Keep receipts short.

## Batches

| Batch | Slots | Area | Checks after install |
|---|---|---|---|
| `cx-01-buildings` | 2 | Highbank's buildings | hub_town building_template art_slots |
| `cx-02-lots` | 3 | Lots before they open | hub_town building_template art_slots |
| `cx-03-shop-room` | 5 | The Item Shop's room (14x10 tiles) | town_room art_slots |
| `cx-04-cellar` | 5 | The Scroll Keeper's cellar (12x9 tiles) | town_room art_slots |
| `cx-05-room-fixes` | 4 | Four Tower room props drawn at a stretched size | town_room hall_floors art_slots |
| `cx-06-title` | 1 | The launch card's night | opening_launch opening_flow art_slots |
| `cx-07-story` | 2 | Story backdrops: the dawn bank and the river below | mouth_escape soul_prologue art_slots |
| `cx-08-stages` | 6 | TEAM page stages for the six essences without one | ui_fit field_menu art_slots |
| `cx-09-road` | 6 | The road back up to Highbank: the trail's layers | road mouth_escape art_slots |
| `cx-10-road-far` | 3 | Highbank and the Wayline Tower far off, and the Tower's sky | road tower_reveal art_slots |
| `cx-11-tower-key` | 1 | The Wayline Tower's style key (refs only) | tower_parts art_slots |
| `cx-12-tower-foot` | 5 | The Wayline Tower's foot: depot, Route Board gable, root, yard and rise stair (seen every day) | hall_door building_template tower_parts tower_lean hub_town art_slots |
| `cx-13-tower-body` | 5 | The Wayline Tower's body: Sorting Drum, hoist, chute, root vein and Galleries | building_template tower_parts tower_reveal art_slots |
| `cx-14-tower-crown` | 6 | The Wayline Tower's crown: the Reel Deck, the Reach, the Waiting Lamp, the vane and the bell | tower_parts tower_reveal building_template art_slots |
| `cx-15-title-highbank` | 1 | The title screen: Highbank with the Wayline Tower as the hero | opening_launch opening_flow ui_fit art_slots |
| `cx-16-item-shop` | 1 | The Item Shop: the first building shaped by its keeper | hub_town building_template art_slots |
| `cx-17-home-burrow` | 1 | Home, dug into the bluff | hub_town building_template art_slots |

## cx-01-buildings: Highbank's buildings (2 slots)

The v2 canvases from the building template at BUILDING_SCALE 1.0 (Preston call 1's default). v1, today's town, keeps the old PNGs at rect x 24 and does not change; these show only with Highbank v2 on. **The Wayline Tower left this batch on 2026-10-27** (Preston's default): its one-picture slot, the 300x576 tower, is superseded by the parts plan (cx-11 to cx-14 and gb-08), and `town.building.hall` is now the tower's 300x192 depot in cx-12. The old candidate in `docs/art/slot-candidates/cx-01-buildings/town.building.hall/` stays where it is, on HOLD, as a record: do not deliver, review or install it.

### CX-town-1: town.building.storage (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.storage.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.storage.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.storage_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.storage_card.png (style sample, placeholder, palette strip)
Brief: Storage: a sturdy stone-and-timber store house with a heavy door, where a team keeps items between runs.
Notes: open frames come from door_px when absent; legacy_v1 is the v1 picture
Size:  exactly 156x144 world px (aspect 13:12), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=143: the art's lowest opaque row sits on it, centred on x=78
Door:  door_px x 55, y 94, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-01-buildings/town.building.storage/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 156x144 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

### CX-town-2: town.building.scrolls (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.scrolls.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.scrolls.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.scrolls_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.scrolls_card.png (style sample, placeholder, palette strip)
Brief: The Scroll Keeper's house: a quiet timber house with a south door that leads down to a cellar of move scrolls.
Notes: south door down to a cellar; open frames come from door_px when absent; legacy_v1 is the v1 picture
Size:  exactly 156x144 world px (aspect 13:12), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=143: the art's lowest opaque row sits on it, centred on x=78
Door:  door_px x 55, y 94, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-01-buildings/town.building.scrolls/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 156x144 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

Review: `python tools/art/review_sheet.py cx-01-buildings`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1`.

## cx-02-lots: Lots before they open (3 slots)

Lots A and B on Highbank Street, and C, D and E in the East Quarter (working label; empty and closed, only the debug scene reaches it). No beat opens a lot yet.

### CX-lots-1: town.building.lot_before_stall (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_stall.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_stall.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_stall_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_stall_card.png (style sample, placeholder, palette strip)
Brief: An unopened stall lot: a canvas tarp tied over a bare timber counter frame.
Notes: lots A and D before they open
Size:  exactly 108x120 world px (aspect 9:10), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=119: the art's lowest opaque row sits on it, centred on x=54
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-02-lots/town.building.lot_before_stall/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 108x120 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

### CX-lots-2: town.building.lot_before_shop (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_shop.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_shop.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_shop_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.lot_before_shop_card.png (style sample, placeholder, palette strip)
Brief: An unopened shopfront lot: a shop-class building with its door and windows shuttered with plain boards.
Notes: lot C before it opens
Size:  exactly 156x144 world px (aspect 13:12), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=143: the art's lowest opaque row sits on it, centred on x=78
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-02-lots/town.building.lot_before_shop/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 156x144 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

### CX-lots-3: town.landmark.lot_before_plot (landmark)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.landmark.lot_before_plot.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.landmark.lot_before_plot.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.landmark.lot_before_plot_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.landmark.lot_before_plot_card.png (style sample, placeholder, palette strip)
Brief: An empty open-air plot: trampled earth inside a low timber fence, a few stakes marking where something will stand.
Notes: lots B and E before they open
Size:  exactly 144x96 world px (aspect 3:2), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-02-lots/town.landmark.lot_before_plot/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 144x96 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

Review: `python tools/art/review_sheet.py cx-02-lots`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1`.

## cx-03-shop-room: The Item Shop's room (14x10 tiles) (5 slots)

Its door in Highbank stays shut (Preston call 5); the room is reached only by the debug scene and checks.

### CX-shop-1: town.room.shop.floor (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.floor.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.floor.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.floor_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.floor_card.png (style sample, placeholder, palette strip)
Brief: The floor strip of the Item Shop's room: warm plank floor, shelved timber walls.
Notes: 14x10 tiles, 336x240; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS shop; the door in Highbank stays shut (Preston call 5)
Size:  exactly 288x168 world px (aspect 12:7), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-03-shop-room/town.room.shop.floor/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "warm plank floor", walls "shelved timber walls"): one kit gives the Item Shop's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-shop-2: town.room.shop.north (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.north.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.north.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.north_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.north_card.png (style sample, placeholder, palette strip)
Brief: The north strip of the Item Shop's room: warm plank floor, shelved timber walls.
Notes: 14x10 tiles, 336x240; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS shop; the door in Highbank stays shut (Preston call 5)
Size:  exactly 336x48 world px (aspect 7:1), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-03-shop-room/town.room.shop.north/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "warm plank floor", walls "shelved timber walls"): one kit gives the Item Shop's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-shop-3: town.room.shop.south (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.south.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.south.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.south_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.south_card.png (style sample, placeholder, palette strip)
Brief: The south strip of the Item Shop's room: warm plank floor, shelved timber walls.
Notes: 14x10 tiles, 336x240; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS shop; the door in Highbank stays shut (Preston call 5)
Size:  exactly 336x24 world px (aspect 14:1), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-03-shop-room/town.room.shop.south/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "warm plank floor", walls "shelved timber walls"): one kit gives the Item Shop's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-shop-4: town.room.shop.west (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.west.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.west.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.west_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.west_card.png (style sample, placeholder, palette strip)
Brief: The west strip of the Item Shop's room: warm plank floor, shelved timber walls.
Notes: 14x10 tiles, 336x240; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS shop; the door in Highbank stays shut (Preston call 5)
Size:  exactly 24x168 world px (aspect 1:7), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-03-shop-room/town.room.shop.west/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "warm plank floor", walls "shelved timber walls"): one kit gives the Item Shop's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-shop-5: town.room.shop.east (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.east.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.east.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.east_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.shop.east_card.png (style sample, placeholder, palette strip)
Brief: The east strip of the Item Shop's room: warm plank floor, shelved timber walls.
Notes: 14x10 tiles, 336x240; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS shop; the door in Highbank stays shut (Preston call 5)
Size:  exactly 24x168 world px (aspect 1:7), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-03-shop-room/town.room.shop.east/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "warm plank floor", walls "shelved timber walls"): one kit gives the Item Shop's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

Review: `python tools/art/review_sheet.py cx-03-shop-room`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_room art_slots --jobs 1`.

## cx-04-cellar: The Scroll Keeper's cellar (12x9 tiles) (5 slots)

Down the Scroll Keeper's south door (Preston call 4); the door stays shut for now (call 5).

### CX-cellar-1: town.room.scrolls_cellar.floor (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.floor.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.floor.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.floor_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.floor_card.png (style sample, placeholder, palette strip)
Brief: The floor strip of the Scroll Keeper's cellar: cool flagstone floor, stone walls lined with scroll racks.
Notes: 12x9 tiles, 288x216; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS scrolls_cellar; the door in Highbank stays shut (Preston call 5)
Size:  exactly 240x144 world px (aspect 5:3), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-04-cellar/town.room.scrolls_cellar.floor/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "cool flagstone floor", walls "stone walls lined with scroll racks"): one kit gives the Scroll Keeper cellar's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-cellar-2: town.room.scrolls_cellar.north (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.north.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.north.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.north_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.north_card.png (style sample, placeholder, palette strip)
Brief: The north strip of the Scroll Keeper's cellar: cool flagstone floor, stone walls lined with scroll racks.
Notes: 12x9 tiles, 288x216; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS scrolls_cellar; the door in Highbank stays shut (Preston call 5)
Size:  exactly 288x48 world px (aspect 6:1), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-04-cellar/town.room.scrolls_cellar.north/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "cool flagstone floor", walls "stone walls lined with scroll racks"): one kit gives the Scroll Keeper cellar's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-cellar-3: town.room.scrolls_cellar.south (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.south.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.south.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.south_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.south_card.png (style sample, placeholder, palette strip)
Brief: The south strip of the Scroll Keeper's cellar: cool flagstone floor, stone walls lined with scroll racks.
Notes: 12x9 tiles, 288x216; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS scrolls_cellar; the door in Highbank stays shut (Preston call 5)
Size:  exactly 288x24 world px (aspect 12:1), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-04-cellar/town.room.scrolls_cellar.south/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "cool flagstone floor", walls "stone walls lined with scroll racks"): one kit gives the Scroll Keeper cellar's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-cellar-4: town.room.scrolls_cellar.west (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.west.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.west.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.west_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.west_card.png (style sample, placeholder, palette strip)
Brief: The west strip of the Scroll Keeper's cellar: cool flagstone floor, stone walls lined with scroll racks.
Notes: 12x9 tiles, 288x216; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS scrolls_cellar; the door in Highbank stays shut (Preston call 5)
Size:  exactly 24x144 world px (aspect 1:6), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-04-cellar/town.room.scrolls_cellar.west/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "cool flagstone floor", walls "stone walls lined with scroll racks"): one kit gives the Scroll Keeper cellar's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

### CX-cellar-5: town.room.scrolls_cellar.east (room)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.east.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.east.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.east_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.room.scrolls_cellar.east_card.png (style sample, placeholder, palette strip)
Brief: The east strip of the Scroll Keeper's cellar: cool flagstone floor, stone walls lined with scroll racks.
Notes: 12x9 tiles, 288x216; placeholder: its crop of room_painter.gd _plain (lane R); town_room.gd ROOMS scrolls_cellar; the door in Highbank stays shut (Preston call 5)
Size:  exactly 24x144 world px (aspect 1:6), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-04-cellar/town.room.scrolls_cellar.east/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_building_kit (tile_type square_topdown, tile_size 24, wall_tiles 2, max_colors 48, floor "cool flagstone floor", walls "stone walls lined with scroll racks"): one kit gives the Scroll Keeper cellar's matched floor, wall and doorway pieces for all five strips, and Codex assembles them to each strip's exact size. One kit per room.

Review: `python tools/art/review_sheet.py cx-04-cellar`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_room art_slots --jobs 1`.

## cx-05-room-fixes: Four Tower room props drawn at a stretched size (4 slots)

Today each shows a nearest resize of an older file (its style_ref). A file at the drawn size ends the stretch. The rooms keep their ids: the chamber and the runners' room inside the Wayline Tower.

### CX-rooms-1: town.prop.chamber.rug (prop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.rug.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.rug.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.rug_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.rug_card.png (style sample, placeholder, palette strip)
Brief: The chamber's teal rug: a woven river-teal rug with a brass border, lying flat on the floor.
Notes: on screen until a file is installed: today's nearest resize of teal_rug.png (192x120 to 216x120, room_slots.gd DRAWN), so nothing changes; the registered placeholder is the kind's flat block (C2-C4), seen only when forcing; style_ref is that old file
Size:  exactly 216x120 world px (aspect 9:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_chamber.png`; light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-05-room-fixes/town.prop.chamber.rug/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object (basic, 216x120 canvas, view high top-down, flat shading): 25,920 px keeps a clear background and it draws at the slot's size.

### CX-rooms-2: town.prop.chamber.window_wide (prop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.window_wide.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.window_wide.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.window_wide_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.chamber.window_wide_card.png (style sample, placeholder, palette strip)
Brief: A wide chamber window: three timber-framed panes with river light behind them.
Notes: on screen until a file is installed: today's nearest resize of window_wide.png (68x32 to 96x32, room_slots.gd DRAWN), so nothing changes; the registered placeholder is the kind's flat block (C2-C4), seen only when forcing; style_ref is that old file
Size:  exactly 96x32 world px (aspect 3:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_chamber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=31: the art's lowest opaque row sits on it, centred on x=48
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-05-room-fixes/town.prop.chamber.window_wide/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with the pixel-engine-image-v1 model at exactly 96x32 (16 to 128 px, sides up to 4:1, background removed): fits better than a resize, prepare_slot only snaps colours. No references on that model.

### CX-rooms-3: town.prop.runners.window (prop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.window.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.window.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.window_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.window_card.png (style sample, placeholder, palette strip)
Brief: A small runners' room window: two timber-framed panes with river light behind them.
Notes: on screen until a file is installed: today's nearest resize of window.png (44x32 to 36x32, room_slots.gd DRAWN), so nothing changes; the registered placeholder is the kind's flat block (C2-C4), seen only when forcing; style_ref is that old file
Size:  exactly 36x32 world px (aspect 9:8), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_runners.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=31: the art's lowest opaque row sits on it, centred on x=18
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-05-room-fixes/town.prop.runners.window/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with the pixel-engine-image-v1 model at exactly 36x32 (16 to 128 px, sides up to 4:1, background removed): fits better than a resize, prepare_slot only snaps colours. No references on that model.

### CX-rooms-4: town.prop.runners.river_map (prop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.river_map.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.river_map.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.river_map_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.runners.river_map_card.png (style sample, placeholder, palette strip)
Brief: A small pinned river map on parchment, the river drawn as one blue line with a few marked bends.
Notes: on screen until a file is installed: today's nearest resize of river_map.png (96x32 to 48x28, room_slots.gd DRAWN), so nothing changes; the registered placeholder is the kind's flat block (C2-C4), seen only when forcing; style_ref is that old file
Size:  exactly 48x28 world px (aspect 12:7), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_runners.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=27: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-05-room-fixes/town.prop.runners.river_map/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with the pixel-engine-image-v1 model at exactly 48x28 (16 to 128 px, sides up to 4:1, background removed): fits better than a resize, prepare_slot only snaps colours. No references on that model.

Review: `python tools/art/review_sheet.py cx-05-room-fixes`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_room hall_floors art_slots --jobs 1`.

## cx-06-title: The launch card's night (1 slot)

Codex's own launch files; Codex wires them (sites below).

### CX-title-1: title.backdrop.launch (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch.png (target), docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch_card.png (style sample, placeholder, palette strip)
Brief: The launch card's night: the river valley before the title, dark greens and river blues in a few calm bands, with no text.
Notes: today a flat #18172c fill (opening_flow.gd:27); placeholder: that fill in 3 stepped bands
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/night_bank.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-06-title/title.backdrop.launch/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

**Wiring (Codex's launch files; sites re-measured by text on 2026-10-27, after factory pass 8):**

- `scripts/opening_flow.gd:27` `ink.color = Color("#18172c")`, the launch card's flat fill: draw `ArtSlots.texture("title.backdrop.launch")` at 3x under the logo only when `ArtSlots.source(...) == "file"`, and keep the fill otherwise, so today's card is unchanged. The registry's tint and note name that same `#18172c` since pass 9 (they said `#161f1b` at :21, the dc37005af text, until then).
- **Done by Claude, 2026-10-27; nothing to wire here.** Preston: the title's town must be a real place in the game, so the title backdrop is now Highbank with the Wayline Tower prominent. `scripts/creature_opening.gd:10` `const BACKDROP := "title.backdrop.highbank"` and `:43` `town.texture=Slots.texture(BACKDROP)` draw it at 3x (its art is batch cx-15). The village is retired from the title: `title.backdrop.village` stays a keep row and today's file (`assets/sprites/menu/creature_village_2026_10_09.png`) is kept untouched as the reference for a future town on another map. Do not paint over or replace it.
- `scripts/main_menu.gd:357` `_cursor = Polygon2D.new()`: a Sprite2D of `ArtSlots.texture("title.hud_piece.menu_cursor")` when its source is "file", the Polygon2D otherwise; the bounce stays coded. The cursor's art is Grok's (GB-menu-1).

Review: `python tools/art/review_sheet.py cx-06-title`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py opening_launch opening_flow art_slots --jobs 1`.

## cx-07-story: Story backdrops: the dawn bank and the river below (2 slots)

The dawn bank is already wired (mouth_escape.gd asks waking_bank.gd dawn_image(); until a file is installed the night painting under today's dawn grade is its placeholder, so the screen is unchanged).

### CX-story-1: story.backdrop.dawn_bank (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.dawn_bank.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.dawn_bank.png (target), docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.dawn_bank_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.dawn_bank_card.png (style sample, placeholder, palette strip)
Brief: The waking riverbank at first light after the storm: the same bank as the night painting, washed in pale gold and rose, mist lifting off the river.
Notes: in the game the placeholder is today's DAWN_SHADER grade over S01 (mouth_escape.gd, lane S), so the screen is unchanged until art installs; waking_bank.gd dawn_image() hands mouth_escape the installed file; dawn_placeholder is that grade worked on the CPU and stepped to 48 colours, for the reference render; opaque
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-07-story/story.backdrop.dawn_bank/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with edit_asset_id = the uploaded night painting (waking_native.png), aspect 16:9: the same bank at dawn, which is what the brief asks; prepare_slot crops and steps it to 48 colours. Fits better than painting from text.

### CX-story-2: story.backdrop.river_below (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.river_below.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.river_below.png (target), docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.river_below_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.river_below_card.png (style sample, placeholder, palette strip)
Brief: The river seen from high above while the soul falls: a dark strip of water with faint pale glints, tiling left to right.
Notes: 2x1 dashes today (soul_prologue.gd:267); shimmer stays coded
Size:  exactly 384x40 world px (aspect 48:5), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/night_bank.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-07-story/story.backdrop.river_below/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art, mode texture (seamless), aspect 16:9, style_asset_ids = uploaded house art; prepare_slot crops a 384x40 band and C6 checks the seam.

**Wiring (Codex's launch files; sites re-measured by text on 2026-10-27, after factory pass 8):**

- `scripts/soul_prologue.gd:399` `c.draw_rect(Rect2(x, y, 2, 1), ...)`, the river's 2x1 dashes (line 267 at dc37005af): tile `ArtSlots.texture("story.backdrop.river_below")` when its source is "file", the dashes otherwise; the shimmer stays coded.

Review: `python tools/art/review_sheet.py cx-07-story`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py mouth_escape soul_prologue art_slots --jobs 1`.

## cx-08-stages: TEAM page stages for the six essences without one (6 slots)

party_screen.gd keeps the plain parchment until a file is installed. 448x252, drawn at 1x.

### CX-stages-1: ui.backdrop.stage_blight (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_blight.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_blight.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_blight_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_blight_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the blight essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_blight.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_blight/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-stages-2: ui.backdrop.stage_hollow (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_hollow.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_hollow.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_hollow_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_hollow_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the hollow essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_hollow.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_hollow/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-stages-3: ui.backdrop.stage_ice (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_ice.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_ice.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_ice_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_ice_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the ice essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_ice.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_ice/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-stages-4: ui.backdrop.stage_loam (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_loam.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_loam.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_loam_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_loam_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the loam essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_loam.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_loam/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-stages-5: ui.backdrop.stage_murk (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_murk.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_murk.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_murk_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_murk_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the murk essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_murk.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_murk/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-stages-6: ui.backdrop.stage_sinew (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_sinew.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_sinew.png (target), docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_sinew_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/ui.backdrop.stage_sinew_card.png (style sample, placeholder, palette strip)
Brief: A wide, quiet stage backdrop for the TEAM page in the sinew essence's colours: ground, sky and one landmark shape, with open ground in the middle where a creature stands. No creatures, no text.
Notes: no stage today: party_screen.gd _stage_tex keeps the plain parchment until this file is installed, and shows the placeholder (parchment with 3 essence-colour bands) only when placeholders are forced
Size:  exactly 448x252 world px (aspect 16:9), drawn at 1x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/stage_sinew.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-08-stages/ui.backdrop.stage_sinew/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

Review: `python tools/art/review_sheet.py cx-08-stages`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py ui_fit field_menu art_slots --jobs 1`.

## cx-09-road: The road back up to Highbank: the trail's layers (6 slots)

Added after the plan's counts (lane S, Preston's canon change 4, 2026-10-26). The walkable road scene draws these as parallax layers; each layer's note gives its scroll rate and haze.

### CX-road-1: road.backdrop.sky (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.sky.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.sky.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.sky_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.sky_card.png (style sample, placeholder, palette strip)
Brief: The dawn sky over the river valley the morning after the storm: cool slate blue at the top, warming through pale grey and rose to gold at the horizon (row 140), a few torn cloud bands lit gold underneath. Sky only, no ground, no sun disc. It does not scroll.
Notes: parallax 0; everything below row 150 is covered by the trail
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.backdrop.sky/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-road-2: road.backdrop.far (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.far.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.far.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.far_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.far_card.png (style sample, placeholder, palette strip)
Brief: Far wooded hills along the river valley, two low ridges, the farther one paler, their tops broken by tree crowns. Few tones and little detail: these are miles off. Tiles left to right; transparent above the hill line.
Notes: parallax 0.12, hazed 0.45 by the scene
Size:  exactly 384x88 world px (aspect 48:11), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch only: left, right, bottom; alpha 0 or 255 only (no soft edges); no outline
Place: placed edge to edge as a repeating strip
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.backdrop.far/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a strip that tiles left to right with clear sky above needs hand assembly. (SpriteCook texture mode tiles, but has no clear top; RD Pro stops at 256 px.)

### CX-road-3: road.backdrop.river (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.river.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.river.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.river_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.river_card.png (style sample, placeholder, palette strip)
Brief: The river glimpsed between the willows: a band of slow brown-green water still high from the flood, pale streaks of current and a few glints of morning sky, a thin dark far bank along its top. Tiles left to right.
Notes: parallax 0.3; the scene lowers it 18 px and fades it out over the first half of the trail (the river dropping back)
Size:  exactly 384x24 world px (aspect 16:1), drawn at 3x; colours <= 16 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch only: left, right; alpha 0 or 255 only (no soft edges); no outline
Place: placed edge to edge as a repeating strip
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.backdrop.river/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a strip that tiles left to right with clear sky above needs hand assembly. (SpriteCook texture mode tiles, but has no clear top; RD Pro stops at 256 px.)

### CX-road-4: road.backdrop.mid (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.mid.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.mid.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.mid_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.mid_card.png (style sample, placeholder, palette strip)
Brief: The wooded river trail: weeping willows with long hanging strands, their trunks down to the trail, flood debris caught in them (a snapped branch in a fork, driftwood at a root, a tangle of reeds). Gaps between the trees show the river and hills behind. Keep a gap where the far Tower stands: both willows between x 60 and 226, and from x 228 round to x 58 nothing above row 52 (low reeds and debris are fine), so the far Tower shows clear at each trail talk. Tiles left to right.
Notes: parallax 0.45, hazed 0.1; fades out near the rise (the trees open). Pass 9 (W3): the far Tower falls on columns 229 to 370 of this picture, rows 0 to 51, at the four trail talks; tools/debug/road_tower_view_check.gd measures it.
Size:  exactly 384x112 world px (aspect 24:7), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch only: left, right, bottom; alpha 0 or 255 only (no soft edges); no outline
Place: placed edge to edge as a repeating strip
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.backdrop.mid/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a strip that tiles left to right with clear sky above needs hand assembly. (SpriteCook texture mode tiles, but has no clear top; RD Pro stops at 256 px.)

### CX-road-5: road.backdrop.near (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.near.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.near.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.near_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.near_card.png (style sample, placeholder, palette strip)
Brief: Near foliage in front of the trail: dark ferns and reeds with seed heads, close to the camera, darkest of all the layers. Nothing above row 12. Tiles left to right; transparent above the plants.
Notes: parallax 1.35, drawn in front of the party
Size:  exactly 384x56 world px (aspect 48:7), drawn at 3x; colours <= 16 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch only: left, right, bottom; alpha 0 or 255 only (no soft edges); no outline
Place: placed edge to edge as a repeating strip
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.backdrop.near/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a strip that tiles left to right with clear sky above needs hand assembly. (SpriteCook texture mode tiles, but has no clear top; RD Pro stops at 256 px.)

### CX-road-6: road.ground.path (ground)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.ground.path.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.ground.path.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.ground.path_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.ground.path_card.png (style sample, placeholder, palette strip)
Brief: The trail seen from the side: a grass verge at the back, a band of churned mud (rows 4 to 21) with cart ruts and rain puddles holding the sky, then a grassy slope down to the bottom. The party's feet stand on row 10. Tiles left to right.
Notes: parallax 1 (moves with the party and the props)
Size:  exactly 192x80 world px (aspect 12:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed edge to edge as a repeating strip
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-09-road/road.ground.path/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art, mode texture (seamless), aspect 16:9, style_asset_ids = uploaded house art; prepare_slot crops a 192x80 band and C6 checks the seam.

Review: `python tools/art/review_sheet.py cx-09-road`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py road mouth_escape art_slots --jobs 1`.

## cx-10-road-far: Highbank and the Wayline Tower far off, and the Tower's sky (3 slots)

**GATE: road.backdrop.vista, road.backdrop.highbank_far and story.backdrop.tower_sky are open now (Preston, 2026-10-28: fix the cliff tree and tower 'so codex can go ham').**

Added after the plan's counts (lane S). Canon 2026-10-26: on the road back, Highbank and the Tower show on the horizon, faded with distance (the scene adds the haze, so paint them clear); the Tower scene pans up against tower_sky. **Re-briefed 2026-10-27 for the approved Tower, now superseded for all three by the 2026-10-28 re-brief that follows** (TOWER_DESIGN.md section 9): the briefs and anchors were then new (highbank_far's beacon at (92, 14) with a cable from wayline_top to wayline_end; the vista's beacon at (268, 36) with the Tower about 176 px tall; tower_sky is sky only, no tower). Each far Tower is painted for its own size, not shrunk from the big one. The refs were rendered again from the new coded far views (TowerParts.paint_far); anything drawn to the 2026-10-26 one-picture tower is superseded. **Re-briefed 2026-10-28 for the vast-scale design** (docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md): road.backdrop.vista now shows the whole 480-tile Wayline Tower standing alone (no other buildings by it), the great tree as the title paints it (crown centred on its trunk, leaf clusters, morning colours) and Highbank's roofs set back in a clearing west of the Tower. Paint to its placeholder, which is the vast-scale mock (final/slot_vista.png); its beacon is now (286, 11) and its five house lamps moved, so the 176 px tower and the beacon at (268, 36) above are superseded for the vista. road.backdrop.highbank_far is re-briefed the same way: from 3,000 tiles down the river, the great tree as the title paints it and the whole Tower (70 px, vane row 5, foot row 75) standing alone over a forest band on valley mist, Highbank's roofs in a clearing west of it, one wayline from the Low Reel down to them. Paint to its placeholder, the vast-scale mock (final/slot_highbank_far.png); its foot anchor (the picture's bottom row under the Tower's axis) is now (104, 95), its beacon (105, 7) and its wayline (101, 70) to (84, 73), so the earlier flat-topped bluff of roofs and the beacon at (92, 14) above are superseded. story.backdrop.tower_sky is re-briefed to the vast-scale hold: the sky behind the Tower's top at first light, a flat sea of cloud under the Waiting Lamp (horizon y 146) and the great tree's crown cap breaking it on the left, the title's tree in the morning's greens. Paint to its placeholder, the vast-scale mock (final/slot_tower_sky.png); its beacon anchor (192, 127) is where the scene's lamp stands at the hold, cool blue sky round it. The banded dawn with the top two thirds empty is superseded. Still sky only: the scene draws the Tower, and the climb runs up today's 30-tile tower until the town's Tower is redesigned. Light: all three take the low dawn sun from the east, on the right, as their briefs say. None of the three waits on the town's Tower batches (cx-11 to cx-14) or on their far_70 and far_170 reads: if Preston's walk of the Tower changes its look, the far Towers get a touch-up pass then. Delivery (later on 2026-10-28): prepare_slot.py keeps a picture painted at exactly the slot's size pixel for pixel, so the anchors hold; each of the three has its own palette strip, every colour its target uses (vast_far, vast_vista, vast_sky), and the far view and the vista allow more lone pixels (C9) than the usual 1%, as their targets have. Each target passes validate_slot.py as it stands.

### CX-far-1: road.backdrop.highbank_far (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far_card.png (style sample, placeholder, palette strip)
Tower: docs/design/vast-scale-2026-10-27/final/road_far_slot_3x.png (the vast-scale mock of this view at 3x: the Tower, the great tree and Highbank at this size; not the earlier coded far Tower or cx-14's crown)
Brief: Highbank and the two giants from about 3,000 tiles down the river, as docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md lays out the far view (the target is this slot's placeholder, the vast-scale mock final/road_far_slot_1x.png there; final/slot_highbank_far.png is the picture itself). Both giants stand over a dark forest band. On the right the whole Wayline Tower, all 480 tiles in 70 px from its vane (row 5) to its foot (row 75, axis x 104): a slender pale Stack with brass rings, the dark wet collar in a flat cloud layer (280 to 360 tiles up), the narrow neck, and at the top a root's crook holding the Waiting Lamp, one amber px (the beacon anchor). A thin root climbs its west side. It stands alone in open ground: no other building by the Tower (Preston, 2026-10-28). Left of it and farther off, the great tree, the same tree as the title's (scripts/art/placeholders/title_giants.gd): its crown one even dome centred on its trunk (Preston, 2026-10-28), about 60 px across, leaf clusters each with a lit top arc, lit from the east in the morning's greens, the trunk about 14 px wide flaring into the forest. Highbank's roofs, 1 or 2 px each, sit in a pale clearing west of the Tower on rows 73 and 74, between it and the tree, well clear of its foot. One broken 1 px wayline runs from the Low Reel (5 px up the Tower's west side) down to a roof in the middle of the town, from wayline_top to wayline_end, sagging 3 px at its middle (the scene's glint runs along that curve). Keep the forest band, the town, the wayline and the Tower's foot above row 76: the scene stands the bottom row (the foot anchor) at y 108, behind its far hills, which can hide anything below row 76, but where they dip the land shows down to about row 90. So under the band the land thins into valley mist the colour of the hazed hills and runs off the bottom edge, and toward both sides its top rounds down into the mist: only the bottom edge may be touched. Sky transparent. Paint in full colour, unhazed: the scene hazes the layer. No text.
Notes: drawn at 0.82x growing to 1x as the party nears the rise (the foot anchor at x 300 to 236, y 108), hazed by the scene (0.5 down to 0.3); the game draws the Waiting Lamp unhazed on anchors.beacon (it breathes) and a slow glint of light running down the wayline from anchors.wayline_top to anchors.wayline_end; road_check and road_tower_view_check measure the Tower's body in RouteScene.FAR_BODY (x 100 to 107, rows 5 to 70), so a repaint keeps the Tower there; the placeholder is the vast-scale mock (final_mocks.py mock_road_far, exported to assets/placeholders/road_highbank_far.png); names are working labels
Size:  exactly 160x96 world px (aspect 5:3), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/vast_far.png` (every colour the target uses); light from the right
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outline
Specks: lone pixels up to 10% of the opaque ones (C9), as the target has; the usual limit is 1%
Place: the scene stands the picture by (104, 95), a point on its bottom row, not the middle of its content: keep the target's layout where it is (prepare_slot moves nothing painted at the exact size)
Keep:  these points where the code expects them: beacon (105, 7), wayline_end (84, 73), wayline_top (101, 70)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-10-road-far/road.backdrop.highbank_far/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object (basic, 160x96 canvas, view side, lineless, flat shading): a silhouette on a clear background at the slot's size (15,360 px).

### CX-far-2: road.backdrop.vista (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.vista.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.vista.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.vista_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.vista_card.png (style sample, placeholder, palette strip)
Tower: docs/design/vast-scale-2026-10-27/final/vista_3x.png (the vast-scale mock of this view at 3x: the Tower, the great tree and Highbank at this size; not the earlier coded far Tower or cx-14's crown)
Brief: The rise at first light, the last hill of the road home, as docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md lays it out (the target is this slot's placeholder, the vast-scale mock final/slot_vista.png there). The willows open on both sides. On the right the whole Wayline Tower, all 480 tiles from its foot (y 200, axis x 285) to its vane (y 8): a slender round Stack about 14 to 1, banded with brass rings, a flat cloud layer level with its collar (280 to 360 tiles), the Waiting Lamp lit near the top (the beacon anchor is the lamp's middle) and one wayline sagging away west, down to Highbank's roofs (both waylines run west to the town; VAST_SCALE_DESIGN, 2026-10-28). It stands alone on open ground: no other building by the Tower (Preston, 2026-10-28). Left of it and 340 tiles further off, the great tree in its forest, the same tree as the title's (scripts/art/placeholders/title_giants.gd): its crown one even dome centred on its trunk (Preston, 2026-10-28), leaf clusters each with a lit top arc, lit from the east in the morning's greens and hazed a third toward the sky, the trunk flaring to the ground. Highbank's roofs, 2 or 3 px each, sit in a clearing west of the Tower and beyond it, well clear of its foot, with house lamps at the lamp anchors (paint them unlit: the game lights them and puts them out one by one). The party's hill dark in the near left (the party anchor is the leader's feet). No text.
Notes: held view at the rise; coded effects: the house lamps going out one by one while the Waiting Lamp stays lit and breathes; the placeholder is the vast-scale mock (final_mocks.py mock_vista, exported to assets/placeholders/road_vista.png); names are working labels
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 64 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/vast_vista.png` (every colour the target uses); light from the right
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Specks: lone pixels up to 2% of the opaque ones (C9), as the target has; the usual limit is 1%
Place: placed by its top-left corner
Keep:  these points where the code expects them: beacon (286, 11), lamp_1 (224, 191), lamp_2 (233, 194), lamp_3 (236, 189), lamp_4 (240, 192), lamp_5 (246, 193), party (84, 148)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-10-road-far/road.backdrop.vista/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

### CX-far-3: story.backdrop.tower_sky (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.tower_sky.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.tower_sky.png (target), docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.tower_sky_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/story.backdrop.tower_sky_card.png (style sample, placeholder, palette strip)
Brief: The sky behind the Wayline Tower's top while the Tower scene's camera holds there, as docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md lays it out (the target is this slot's placeholder, the vast-scale mock final/slot_tower_sky.png there; final/hold_1x.png shows it with Codex's crown and the lamp's glow over it). First light, seen from the Waiting Lamp 475 tiles up. Flat dawn bands from a deep blue at the top through slate to a pale grey-blue haze at the horizon (y 146). The Waiting Lamp's glass hangs at the beacon anchor: keep the sky in a 17 px box round it a calm cool blue, no cloud or leaf in it, so the amber stands out. Below the horizon a flat sea of cloud fills the bottom: the cloud layer's top (360 tiles), lit warm cream from the east by the low sun, its lumps growing toward the bottom edge. On the left the great tree's crown cap breaks the sea, the same tree as the title's (scripts/art/placeholders/title_giants.gd): one even dome centred on its trunk at x 100, its top at y 156, about 180 px wide where it meets the cloud at y 188, leaf clusters each with a lit top arc, in the morning's greens, lit from the east (the right), hazed a little toward the sky; cloud laps round its foot. No building and no town: the town is under the clouds and nothing stands by the Tower. Sky only, no tower or lamp painted in: the scene draws the Tower, the lamp and its glow over it. It does not scroll.
Notes: shown only during the Tower scene, behind the town's world, above the area's top edge (the whole view from the second leg of the climb to the hold); the placeholder is the vast-scale mock (final_mocks.py hold_backdrop, exported to assets/placeholders/tower_sky.png); the climb still runs up TowerParts' 30-tile tower, so the cloud sea shows behind its drum and Reel Deck until the town's Tower is redesigned and the reveal retimed; names are working labels
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/vast_sky.png` (every colour the target uses); light from the right
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Keep:  these points where the code expects them: beacon (192, 127)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-10-road-far/story.backdrop.tower_sky/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

Review: `python tools/art/review_sheet.py cx-10-road-far`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py road tower_reveal art_slots --jobs 1`.

## cx-11-tower-key: The Wayline Tower's style key (refs only) (1 slot)

**GATE: paint after Preston has walked the coded blockout (Tower Rise with HT_HIGHBANK_V2=1, and scenes/debug/building_lineup.tscn) and judged its 25% flat fill (TOWER_DESIGN.md section 11, step 1). His yes on this key opens cx-12 to cx-15 and gb-08.**

One low-detail pass over the assembled blockout at half size (432x720 shown as 216x360). Preston approves the palette, the light and the eras here once; every part is then painted to it. The key is never installed and never placed. slots.json carries this slot from 2026-10-27, so prepare_slot.py and validate_slot.py accept it; a draft made before that export still goes through both and the review.

### CX-key-1: town.building.hall.key (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key_card.png (style sample, placeholder, palette strip)
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout at 1:1: paint it at half size, same layout), docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/parts_sheet.png (every part), docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/far_70.png and docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/far_170.png (the far reads the key must keep)
Brief: The whole Wayline Tower at half size (432 x 720 shown as 216 x 360): the style key every part is painted to. A rooted river-stone tower built in eras round a living root, the Reach, that climbs the left face and curls over the top to hold the Waiting Lamp on its chain right above the double door. Match the blockout's layout and silhouette exactly; settle materials, light and the shading columns here once.
Notes: refs only: never installed and never placed; the parts are painted to it (batch cx-11)
Size:  exactly 216x360 world px (aspect 3:5), drawn at 3x; colours <= 41 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=359: the art's lowest opaque row sits on it, centred on x=108
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with edit_asset_id = the uploaded assembled blockout (aspect 9:16), 3 credits for one try; RD Pro stops at 256 px and PixelLab keeps a clear background only up to 40,000 px (this is 77,760). Codex stays the route: the key must keep the blockout's layout exactly.

Review: `python tools/art/review_sheet.py cx-11-tower-key`, then Preston's yes per slot. Install: do not install: the key is refs only. After Preston's yes, `docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png` is the approved key that every later tower batch carries.

## cx-12-tower-foot: The Wayline Tower's foot: depot, Route Board gable, root, yard and rise stair (seen every day) (5 slots)

**GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).**

What the player sees every day at the doors. The depot keeps the old Hall's id, door box and foot, so the doors and their checks do not change. Paint each part to the approved key, against its band (the neighbours it meets), at exactly its size. ROOT CHANGE (Preston, 2026-10-27, yes): the Tower's root is one root of a separate, massive great tree, so it must read as arriving from off-frame, thickest at the ground. Redo root_foot once before install: no flared base or footing stone; run it out through the west edge at full girth (34 to 40 px), half buried under a turf lip. Full note and paint-over: docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md. The other four slots here are unchanged.

### CX-foot-1: town.building.hall (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall_card.png (style sample, placeholder, palette strip)
Frame: top-left at (66, 528) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: The Wayline Tower's depot, the door part (read TOWER_DESIGN.md and the key, town.building.hall.key, first): the wide ground storey the tower stands on. Its roof deck seen from above (mostly under the drum) with a skylight, crates, an oilcloth stack and the mess chimney; a parapet lip; a limestone and loess-brick front on a boulder footing; the runners' porch on the left under a moss awning (satchel hooks, one empty, a bench, a round window); the First Post, an old relay stone worn pale by partners' hands, in the left jamb; the grand arch with its three-route fan-light and the 48 x 64 double door; and on the right the loading bay under its canopy, a chute bin, a burrow hatch and high-water cuts. Lit from the upper left, wayline_tower palette, no outer outline.
Notes: 2026-10-27 approved tower (Reach and Waiting Lamp, defaults): this row is now the 300 x 192 depot at frame (66, 528) of the 432 x 720 tower; the other parts are scripts/art/slots/town_tower.gd. The 300 x 576 single-picture tower and Codex's cx-01 hall candidate (and the old 240 x 144 Hall) are superseded. beacon and apex are in the depot's px, above its top (negative y), so the reveal finds the lamp. Base 12x3 and doors kept; door 48 wide so Galeshear (63 px wide) passes C11; open frames come from door_px; legacy_v1 is still the v1 picture.
Size:  exactly 300x192 world px (aspect 25:16), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=191: the art's lowest opaque row sits on it, centred on x=150
Door:  door_px x 126, y 126, 48x64: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears galeshear (62 px tall, 63 px wide, measured now from its town/s.png) (C11)
Keep:  these points where the code expects them: door_mid (150, 158)
Code:  points outside this picture that the code reads (paint nothing for them): apex (117, -527), beacon (150, -410)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-12-tower-foot/town.building.hall/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-foot-2: town.building.hall.gable (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.gable.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.gable.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.gable_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.gable_card.png (style sample, placeholder, palette strip)
Frame: top-left at (164, 560) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.gable_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Route Board gable over the arch: an arched stone gable with a moss lip and brick ends, holding a brass board with three waymark arms meeting at a knot and 8 dark peg sockets (two and three along the arms, one at the knot). Paint the sockets dark: the game lights the pegs.
Notes: order 7; peg sockets at TowerParts.route_pegs() (batch cx-12)
Size:  exactly 104x53 world px (aspect 104:53), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-12-tower-foot/town.building.hall.gable/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-foot-3: town.building.hall.root_foot (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_foot.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_foot.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_foot_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_foot_card.png (style sample, placeholder, palette strip)
Frame: top-left at (0, 600) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_foot_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Great Root buttress, the tower's left ground wing: the root arching out of the turf onto the depot's left corner where the Climb starts, rootlets into the turf, treads, knots, moss and a stone at its foot.
Notes: order 15; ground layer, sorts one step in front of the body (batch cx-12)
Size:  exactly 96x120 world px (aspect 4:5), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=119: the art's lowest opaque row sits on it, centred on x=48
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-12-tower-foot/town.building.hall.root_foot/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-foot-4: town.building.hall.yard (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.yard.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.yard.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.yard_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.yard_card.png (style sample, placeholder, palette strip)
Frame: top-left at (360, 616) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.yard_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The hoist yard, the tower's right ground wing: a timber dock on legs with the capstan winch (its handle swings over 2 frames while the rope runs), parcels, a crate, a barrow wheel and a barrel with a teal lid.
Notes: order 16; ground layer (batch cx-12)
Sheet: 144x104, one 72x104 cell per frame, frames left to right; one row per state, top to bottom: winch (2 frames)
Size:  exactly 72x104 world px (aspect 9:13), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=103: the art's lowest opaque row sits on it, centred on x=36
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-12-tower-foot/town.building.hall.yard/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-foot-5: town.prop.hall.rise_stair (prop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.rise_stair.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.rise_stair.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.rise_stair_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.rise_stair_card.png (style sample, placeholder, palette strip)
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: The painted stair up Tower Rise's south cliff, two tiles wide and four tall: eight worn stone steps, roots through two risers and the three-route mark inlaid in the top step as a shape. Replaces the coded steps at tile (12, 9). wayline_tower palette.
Notes: order 18 (batch cx-12). Outline: drawn, the prop default, kept in pass 9 (W8): Codex's cx-12 candidate draws its own 1 px ink sides, and the town's prop builder puts no runtime rim on props.
Size:  exactly 48x96 world px (aspect 1:2), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=95: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-12-tower-foot/town.prop.hall.rise_stair/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 capture of Tower Rise round tile (12, 9) as background_image with a mask over the 2 x 4 tile stair, view high top-down; then prepare_slot.

Review: `python tools/art/review_sheet.py cx-12-tower-foot`, then Preston's yes per slot. Install per slot: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/cx-12-tower-foot/<slot_id>/prepared.png --batch cx-12-tower-foot`. A part shows only with Highbank v2 on and in the debug lineup, and only at its exact sheet size, so parts can land one at a time while the coded blockout stands in for the rest. Then `python tools/debug/run_checks.py hall_door building_template tower_parts tower_lean hub_town art_slots --jobs 1` with HT_HIGHBANK_V2=1 set, and once more without it (v1 must not change).

## cx-13-tower-body: The Wayline Tower's body: Sorting Drum, hoist, chute, root vein and Galleries (5 slots)

**GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).**

The middle of the climb the Tower scene rides. The chute and the root vein are overlays that hide the drum's seams, so paint the drum and the galleries first and the overlays over them. ROOT CHANGE (Preston, 2026-10-27, yes): redo root_vein once before install. Same rect and path, but paint it half sunk into the masonry, with mortar lips along both edges and the drum lips stepping over it, so the 17 to 9 px strip reads as the back of a root about 34 px thick. The other four slots here are unchanged. Note: docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md.

### CX-body-1: town.building.hall.drum (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.drum.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.drum.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.drum_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.drum_card.png (style sample, placeholder, palette strip)
Frame: top-left at (104, 368) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.drum_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Sorting Drum: the cream river-stone cylinder on the depot's deck, its own contact shadow on that deck, a root-beam ring, three round lit windows, the 6 x 3 sorting-cubby wall (two dark and empty), the hoist door on its right flank, moss on the lower courses, and its round deck seen from above with a working landing (rail, crate, parcel) on the right.
Notes: order 2; overlaps the depot's roof deck and owns that seam (batch cx-13)
Size:  exactly 225x236 world px (aspect 225:236), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-13-tower-body/town.building.hall.drum/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-body-2: town.building.hall.hoist (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.hoist.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.hoist.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.hoist_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.hoist_card.png (style sample, placeholder, palette strip)
Frame: top-left at (304, 460) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.hoist_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The hoist jib out of the drum's right flank: a root-wood stub, a timber arm with iron straps, a diagonal brace and the brass pulley block at its end. Two frames turn the pulley's sheave while the rope runs (the rope and basket are coded).
Notes: order 3; the rope hangs from TowerParts.PULLEY (batch cx-13)
Sheet: 176x56, one 88x56 cell per frame, frames left to right; one row per state, top to bottom: turn (2 frames)
Size:  exactly 88x56 world px (aspect 11:7), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-13-tower-body/town.building.hall.hoist/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-body-3: town.building.hall.chute (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.chute.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.chute.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.chute_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.chute_card.png (style sample, placeholder, palette strip)
Frame: top-left at (244, 336) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.chute_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The parcel chute: a timber trough with brass edges and iron brackets running from the galleries' walkway down the drum's front right to a bin on the depot's deck, with a parcel waiting at the spout. An overlay that hides the right-hand seams.
Notes: order 6; the sliding parcel is coded (batch cx-13)
Size:  exactly 88x290 world px (aspect 44:145), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-13-tower-body/town.building.hall.chute/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-body-4: town.building.hall.root_vein (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_vein.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_vein.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_vein_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_vein_card.png (style sample, placeholder, palette strip)
Frame: top-left at (80, 326) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.root_vein_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Climb: the living root running up the tower's left face in three runs, with worn treads every few px, rootlets gripping the stone, two knots, ink lips where it dives into the stone, and moss. An overlay that hides the depot to drum and drum to galleries seams on the left.
Notes: order 5 (batch cx-13)
Size:  exactly 60x296 world px (aspect 15:74), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-13-tower-body/town.building.hall.root_vein/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-body-5: town.building.hall.galleries (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.galleries.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.galleries.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.galleries_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.galleries_card.png (style sample, placeholder, palette strip)
Frame: top-left at (88, 252) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.galleries_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Galleries: a timber-and-plaster drum set left of the stone drum, stone under the plaster, timber bands and posts, five round shuttered lit windows in a 2-1-2 pattern, the timber walkway wrapping the front right where the parcel chute starts, two empty flyer landing boards and a brass ring perch on the left face, and its deck.
Notes: order 4; owns its seam on the drum's deck (batch cx-13)
Size:  exactly 217x206 world px (aspect 217:206), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-13-tower-body/town.building.hall.galleries/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

Review: `python tools/art/review_sheet.py cx-13-tower-body`, then Preston's yes per slot. Install per slot: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/cx-13-tower-body/<slot_id>/prepared.png --batch cx-13-tower-body`. A part shows only with Highbank v2 on and in the debug lineup, and only at its exact sheet size, so parts can land one at a time while the coded blockout stands in for the rest. Then `python tools/debug/run_checks.py building_template tower_parts tower_reveal art_slots --jobs 1` with HT_HIGHBANK_V2=1 set, and once more without it (v1 must not change).

## cx-14-tower-crown: The Wayline Tower's crown: the Reel Deck, the Reach, the Waiting Lamp, the vane and the bell (6 slots)

**GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11).**

The top of the Tower scene's climb and the shape the far views must keep: a hooked column with one lit dot. Keep the Reach thick, banded and tended: no canopy, no face, no creature shape, and never a cane, gallows or question mark (TOWER_DESIGN.md section 13). cx-10 no longer waits on this batch (opened 2026-10-28 for the vast-scale design). ROOT CHANGE (Preston, 2026-10-27): the Reach's silhouette is unchanged. Optional, can wait: two or three thin rootlets trailing west off the crook's back (docs/design/great-tree-2026-10-27/CODEX_ROOT_NOTE.md).

### CX-crown-1: town.building.hall.reel_back (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reel_back.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reel_back.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reel_back_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reel_back_card.png (style sample, placeholder, palette strip)
Frame: top-left at (88, 198) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reel_back_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Reel Deck ring's back half (planks, radial joints, the back rail) and the dispatcher's loft standing in its middle: timber and brass, one big round lit window with three spokes, under a moss dome.
Notes: order 8 (batch cx-14)
Size:  exactly 225x93 world px (aspect 75:31), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.reel_back/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-crown-2: town.building.hall.ring_front (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.ring_front.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.ring_front.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.ring_front_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.ring_front_card.png (style sample, placeholder, palette strip)
Frame: top-left at (84, 286) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.ring_front_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Reel Deck ring's front half: planks, the rim face with its brass band, the front rail at creature hip height, the 7 brass sheaves where the waylines tie off (TowerParts.sheave), and the moss collar where the Reach rises. Leave the loft's footprint clear.
Notes: order 10 (batch cx-14)
Size:  exactly 232x60 world px (aspect 58:15), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.ring_front/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-crown-3: town.building.hall.reach (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reach.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reach.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reach_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reach_card.png (style sample, placeholder, palette strip)
Frame: top-left at (128, 24) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.reach_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Reach: the living root rising through the deck's moss collar with a gentle S and a flared foot, then curling over to the right like a shepherd's crook to hold the lamp's chain on the door axis (the hook at frame 216, 96). Rootlets binding the loft, three knots, moss on the lit side and along the top of the curl, three worn brass bands, two small leaf tufts and the chain hook. The curl tapers as it turns down to the hook (about 24 px thick leaving the shaft, 13 at the hook) and carries two worn brass lashings square across it and two knots, so it reads as the same tended root and never as a bent pipe.
Notes: order 9 (batch cx-14)
Size:  exactly 104x300 world px (aspect 26:75), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.reach/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-crown-4: town.building.hall.lamp (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.lamp.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.lamp.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.lamp_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.lamp_card.png (style sample, placeholder, palette strip)
Frame: top-left at (200, 92) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.lamp_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The Waiting Lamp on its short chain from the Reach's hook: the bail, a vented brass cap, amber panes with a centre bar, and the drip pan. The glass centre is the beacon (frame 216, 118). Lit flickers over 4 frames (the hot pane changes shape); dark is cold glass with one glint. The glow and the sway are coded.
Notes: order 13; TowerParts.BEACON (batch cx-14)
Sheet: 128x84, one 32x42 cell per frame, frames left to right; one row per state, top to bottom: lit (4 frames), dark (1 frame)
Size:  exactly 32x42 world px (aspect 16:21), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.lamp/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-crown-5: town.building.hall.vane (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.vane.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.vane.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.vane_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.vane_card.png (style sample, placeholder, palette strip)
Frame: top-left at (164, 0) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.vane_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). The three-arm route vane at the apex (its tip is the tower's top, frame 183, 1) with a teal courier pennant and its fold, which lifts and drops 1 px over 4 frames.
Notes: order 14; TowerParts.APEX (batch cx-14)
Sheet: 192x44, one 48x44 cell per frame, frames left to right; one row per state, top to bottom: flutter (4 frames)
Size:  exactly 48x44 world px (aspect 12:11), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.vane/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

### CX-crown-6: town.building.hall.bell (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.bell.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.bell.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.bell_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.bell_card.png (style sample, placeholder, palette strip)
Frame: top-left at (40, 232) in the tower's 432x720 frame; where two parts overlap the upper one owns the seam and carries its 3 px contact shadow
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.bell_band.png (this part dimmed in its place, with a 24 px band of the neighbours it meets)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). Stillwade's flood bell off the deck's left end: a timber gallows with a moss-topped hood, the bronze bell on an iron yoke, and its rope hanging down. Swing moves the bell and rope 2 px each way over 4 frames.
Notes: order 12 (batch cx-14)
Sheet: 224x180, one 56x90 cell per frame, frames left to right; one row per state, top to bottom: rest (1 frame), swing (4 frames)
Size:  exactly 56x90 world px (aspect 28:45), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-14-tower-crown/town.building.hall.bell/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: none fits better: a tower part must meet its neighbours' seams and the approved key pixel for pixel, which no generator here does. If a small part stalls, PixelLab pixelart_workbench (free, exact pixels by hand) over its blockout cell.

Review: `python tools/art/review_sheet.py cx-14-tower-crown`, then Preston's yes per slot. Install per slot: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/cx-14-tower-crown/<slot_id>/prepared.png --batch cx-14-tower-crown`. A part shows only with Highbank v2 on and in the debug lineup, and only at its exact sheet size, so parts can land one at a time while the coded blockout stands in for the rest. Then `python tools/debug/run_checks.py tower_parts tower_reveal building_template art_slots --jobs 1` with HT_HIGHBANK_V2=1 set, and once more without it (v1 must not change).

## cx-15-title-highbank: The title screen: Highbank with the Wayline Tower as the hero (1 slot)

**GATE: nothing here is painted until Preston has walked the blockout and approved the key (cx-11), so the title's Tower matches it.**

Preston, 2026-10-27: the town on the title screen has to be a real town in the game. Highbank from across the river, painted for its own 384x216 size (drawn at 3x), with the Wayline Tower the largest, brightest and only tall shape. The wordmark, the menu, the canopy shade and the legibility wash are the game's; keep their areas calm as the brief says. The old title village is not repainted: it is kept for a future town on another map. Optional wiring: the six coded fireflies (`scripts/creature_opening.gd` `_draw_stars`) were placed for the village banks and now float over the Street and the Rise; they were not retuned. REDO, LAYOUT A (Preston, 2026-10-28): he chose layout A of the cloud-high Tower design, then said 'Remove the older tower from Title A too, its covering the new tower you made behind it that looks better'. Keep your houses, river and left tree as painted; take out the painted depot and drum tower and paint the 480-tile Tower in its place: the round Stack running off the top, down to the ground on its wide stepped plinth with the doors at street level, the Low Reel and waylines, the great tree's root on its west face (pre-darken about x0.62 under the canopy shade, x 0 to 311 above y 50, so the band shows no seam). Behind the town paint the great tree with its full crown of leaves and branch tops (his words: it needs 'the leaves and branch top'), painted only over sky and far hills. Keep the menu box (21,108 to 129,200) untouched and the wordmark area calm. The Tower stays slender and the tree stays 340 tiles away (both his yes). Target picture: docs/design/vast-scale-2026-10-27/final/title_a_game_3x.png for the layout (its crown and root are out of date, see the update below); numbers: docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md. The slot's lamp anchor (333,33) and 'about 162 px tall' brief lines are stale in layout A (no lamp in frame). UPDATE (Preston, 2026-10-28, after seeing Title A in the game): centre the great tree's crown on its trunk (the left side reached much farther out than the right, so the trunk looked off to one side), with the limbs under it spreading both ways; and bring the Tower root's lower end up out of the ground at the first plinth step's west corner, with short roots gripping the Rise either side, then up the steps and the west face (it used to come in from behind the gardens and looked cut off and floating). The placeholder now shows both: match docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.highbank.png for these two.

### CX-highbank-1: title.backdrop.highbank (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.highbank.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.highbank.png (target), docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.highbank_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.highbank_card.png (style sample, placeholder, palette strip)
Tower: docs/design/placeholder-factory-2026-10-26/refs/wayline_tower/assembled_blockout.png (the whole blockout)
Key:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.key.png until cx-11 is approved, then docs/art/slot-candidates/cx-11-tower-key/town.building.hall.key/prepared.png
Brief: Highbank seen from across the river at the golden hour, the old title village's time of day and mood. Layout A of docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md (the target is this slot's placeholder; the mock final/title_1x.png there still has the older off-centre crown and floating root). The Wayline Tower is the hero at its full 480 tiles, so only its foot fits: the round Stack (2.6 px a tile, west face at x 313) runs off the top and the right edge and comes down to Tower Rise on its two plinth steps (x 289 and 302 to the edge, foot on row 167), with brass rails on the ledges, the doors at the top of the Rise stair (x 327 to 339), the Low Reel deck at y 80 where the waylines leave, and the great tree's root coming up out of the Rise at the first step's west corner, short roots gripping the ground either side, then up the steps and the Stack's west face off the top; no lamp in frame. Behind the town the great tree with its whole crown, one even dome centred on its trunk (x 130 to 288, top y 6), a short stretch of trunk and four limbs under it spreading both ways, painted only over sky and far hills, lit low from the west. Below, small and in street order from the west: Home, the Item Shop, Storage and the Scroll Keeper along the bluff, the Crossroads and the Rise stair under the Tower's doors, waylines from the reel down to posts on their roofs (one slack, the quiet route), the bluff face with the switchbacks and the ferry dock, and the river in front. Keep the sky calm behind the wordmark (x 90 to 295, y 0 to 52; the crown there is only its dark body and a 1 px rim) and keep the Stack right of x 312, where the title's canopy shade stops; paint everything right of x 312 above row 50 already shaded (the sky one band darker, the Stack and root about x0.62) so it meets the shaded sky with no edge; the lower left (x 0 to 140, y 100 down) sits under the menu and its dark wash, so keep it quiet. No text.
Notes: Placeholder (layout A, Preston 2026-10-28): the giant Tower's foot and the great tree painted in code by title_giants.gd from the vast-scale mock's numbers; the house slot pictures shrunk to 0.225 and placed from the Street's area data; sky, hills, bluff and river painted in code (45 colours, PALETTE in the painter). The old shrunken tower blockout is no longer drawn here. The tower names are working labels.
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/highbank_title.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Keep:  these points where the code expects them: door (333, 160), shade_end (312, 50)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art with edit_asset_id = the uploaded placeholder (aspect 16:9): a repaint that keeps the layout and anchors; prepare_slot steps it to 48 colours. RD Pro tops out at 256x144. Codex stays the route: the Tower in it must match the approved key.

Review: `python tools/art/review_sheet.py cx-15-title-highbank`, then Preston's yes per slot. Install: `python tools/art/install_slot.py title.backdrop.highbank docs/art/slot-candidates/cx-15-title-highbank/title.backdrop.highbank/prepared.png --batch cx-15-title-highbank`, then `python tools/debug/run_checks.py opening_flow ui_fit art_slots --jobs 1` and `python tools/debug/run_checks.py opening_launch --jobs 1 --window` (its screenshot needs a window). The title is the same with Highbank v2 on or off.

## cx-16-item-shop: The Item Shop: the first building shaped by its keeper (1 slot)

Preston, 2026-10-28: the buildings were all the same box, and then "to small and shack like" with a perspective that felt wrong. Measured against Explorers of Sky's town (structure only; docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md): roof first. The Item Shop is now the trading_post class, 204x192 on an 8x3 base, the roof the top 128 px, the front the bottom 64, the door on base column 3. The placeholder painted in code (building_template.gd _trading_post) shows the layout to keep. The stock out front is Grok's dooryard props (gb-10), not part of this picture. Your cx-01 candidate for town.building.shop and the lean_to of the same morning are superseded: do not install either.

### CX-item-shop-1: town.building.shop (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.shop.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.shop.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.shop_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.shop_card.png (style sample, placeholder, palette strip)
Brief: Swaphoard's Item Shop, a hoarder's trading post, seen from above at three quarters the way the whole town is: ROOF FIRST. A clay-tile hip roof takes the top two thirds (128 of 192 px), its back plane past the ridge lit and narrowing away, a loft dormer in the front plane with a hoist beam and a crate hanging over the tiles, a tied sack on the ridge for the trade, a chimney on the back plane. Under a deep eave shadow, a short plank front (the bottom 64 px) on a stone sill: a shuttered window left, the door on base column 3 exactly at door_px, and an open counter right under a striped awning with stock on its sill. No goods heaps in the picture: the tables and crates out front are separate dooryard props. Lit from the upper left, 1 px dark outline.
Notes: Claude, 2026-10-28: the trading_post class (8x3 base, 204x192, door Rect2i(79, 142, 22, 48)), roof first after measuring Explorers of Sky's town (docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md); it replaced the lean_to of the same morning. The cx-01 box and the lean_to are both superseded.
Size:  exactly 204x192 world px (aspect 17:16), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=191: the art's lowest opaque row sits on it, centred on x=102
Door:  door_px x 79, y 142, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-16-item-shop/town.building.shop/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 204x192 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

Review: `python tools/art/review_sheet.py cx-16-item-shop`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1`.

## cx-17-home-burrow: Home, dug into the bluff (1 slot)

Preston, 2026-10-28: yes to Home dug into the bluff, the next keeper-shaped building after the Item Shop (docs/design/town-map-2026-10-28/TOWN_MAP.md). Claude wired it on 2026-10-29 as the burrow class: 132x192 on a 5x3 base, the grass bank the roof (about 70%), the stone face the bottom 56 px, the door on base column 2 at Rect2i(55, 142, 22, 48). The placeholder painted in code (building_template.gd _burrow) shows the layout to keep. Your cx-01 candidate for town.building.home is the old 132x144 cottage and is superseded: do not install it. Storage (Pouchbill's boathouse) follows in its own batch.

### CX-home-1: town.building.home (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.home.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.home.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.home_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.home_card.png (style sample, placeholder, palette strip)
Brief: The team's home, dug into the river bluff: a broad grass bank is the roof (the top two thirds of the picture), lit on its crown, a stovepipe standing out of the turf right of centre. Under the turf's hanging lip, a short face of river stone between the bank's grassy flanks: a round lit window either side, the arched doorway under a thick stone ring that cuts up into the turf, a lantern hung by the door, a tied parcel waiting under the right window (a courier team lives here), a flat stone step. Seen from above and in front like the trading post; no cottage walls, no tiled roof.
Notes: Claude, 2026-10-29: the burrow class (5x3 base, 132x192, door Rect2i(55, 142, 22, 48)), Home dug into the bluff per docs/design/town-map-2026-10-28/TOWN_MAP.md; it replaces the cottage brief (132x144), so Codex's cx-01 home candidate is superseded. The doorway stays dark inside door_px (the game draws the leaves); open frames come from door_px when absent; legacy_v1 is the v1 picture.
Size:  exactly 132x192 world px (aspect 11:16), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=191: the art's lowest opaque row sits on it, centred on x=66
Door:  door_px x 55, y 142, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-17-home-burrow/town.building.home/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 132x192 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

Review: `python tools/art/review_sheet.py cx-17-home-burrow`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1`.

## Not verified

- No generator was run for this list: the balances are read-only calls, and no route's per-call cost was measured except Retro Diffusion's free estimate ($0.18 for one 48x56 RD Pro prop).
- The Alt routes come from each tool's own description, not from a test in this project.
- The in-game capture column of the review sheet needs a capture made with the candidate swapped in; review_sheet.py shows where it is missing.
- The Wayline Tower's references (the assembled blockout, each part's band, the exact palette strips) come from the coded blockout. No painted part has been seen against its neighbours or under the game's rim yet, and nothing checks a seam between two painted parts except Preston's eye in review.
