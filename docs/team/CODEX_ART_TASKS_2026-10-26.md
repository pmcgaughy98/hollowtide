# Codex art tasks, 2026-10-26 (written by tools/art/write_art_tasks.py; do not edit by hand)

Placeholder factory, task-list lane (Claude). 10 batches, 40 slots: the plan's 8 batches and 31 slots (00-BUILD-PLAN.md section 4), plus 2 road batches (9 slots) that lane S added for Preston's canon change of 2026-10-26 (the road back shows Highbank and the Wayline Tower far off). Registry cb33c871f11f.

**Why the old buildings read wrong.** The building rects were set on 2026-10-09 (the Home and Item Shop folders carry that date) and each PNG had to equal its solid footprint, 24 px a tile, with a one-tile door. On 2026-10-10, a day later, the creatures' town set was rebuilt at 1.5x. A stage 3 now stands 55 to 69 px, 2.3 to 2.9 tiles, beside a five-tile house with a 24 px door. Nothing in the old brief tied door or wall height to the creatures. The new canvases do: a single door is 22x48 (clears Sparkjab, a stage 2), the Tower's double door 48x64 (clears Galeshear, a stage 3), and every building and room task names the creature its door must clear (C11 measures it from the creature's own town sprite at check time).

**Nothing installs without Preston's yes.** Every batch ends in a review sheet (`python tools/art/review_sheet.py <batch>`): per slot the placeholder, the prepared candidate, an in-game capture and the check lines. Preston answers yes, redo (one line why) or keep the placeholder; Claude records it in the batch's review.json; `install_slot.py` refuses any slot without his yes.

**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees. Ids, files and flags keep `hall` (`town.building.hall`, rooms `hall` and `hall_low`). Tower Rise is the v2 area's working label. Highbank v2 stays behind its switch (HT_HIGHBANK_V2, off) until Preston walks it. All new names are working labels.

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
   `python tools/art/prepare_slot.py <slot_id> raw.png prepared.png` and `python tools/art/validate_slot.py <slot_id> prepared.png` (writes `prepared.png.check.json`; exit 0 means every scripted check passes).
4. `python tools/art/review_sheet.py <batch>` makes `review_sheet.png` for Preston. Do not install. Preston answers per slot; Claude records the answers in `review.json`.
5. Only after his yes: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/<batch>/<slot_id>/prepared.png --batch <batch>` (it refuses on a lock, a failed check or no yes; it backs up what it replaces and records the hash), then `python tools/debug/run_checks.py <the batch's check words> --jobs 1`.
6. Do not edit the registry (`scripts/art/slots/*.gd`) or another lane's files. List "source issues for Claude" in your result. Keep receipts short.

## Batches

| Batch | Slots | Area | Checks after install |
|---|---|---|---|
| `cx-01-buildings` | 5 | Highbank's buildings and the Wayline Tower | hall_door hub_town building_template art_slots |
| `cx-02-lots` | 3 | Lots before they open | hub_town building_template art_slots |
| `cx-03-shop-room` | 5 | The Item Shop's room (14x10 tiles) | town_room art_slots |
| `cx-04-cellar` | 5 | The Scroll Keeper's cellar (12x9 tiles) | town_room art_slots |
| `cx-05-room-fixes` | 4 | Four Tower room props drawn at a stretched size | town_room hall_floors art_slots |
| `cx-06-title` | 1 | The launch card's night | opening_launch opening_flow art_slots |
| `cx-07-story` | 2 | Story backdrops: the dawn bank and the river below | mouth_escape soul_prologue art_slots |
| `cx-08-stages` | 6 | TEAM page stages for the six essences without one | ui_fit field_menu art_slots |
| `cx-09-road` | 6 | The road back up to Highbank: the trail's layers | road mouth_escape art_slots |
| `cx-10-road-far` | 3 | Highbank and the Wayline Tower far off, and the Tower's sky | road tower_reveal art_slots |

## cx-01-buildings: Highbank's buildings and the Wayline Tower (5 slots)

The v2 canvases from the building template at BUILDING_SCALE 1.0 (Preston call 1's default). v1, today's town, keeps the old PNGs at rect x 24 and does not change; these show only with Highbank v2 on. The Tower is canon from 2026-10-26: the Hall's base footprint and doors, rising 24 tiles to a beacon mast.

### CX-town-1: town.building.hall (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall_card.png (style sample, placeholder, palette strip)
Brief: The Wayline Tower, the couriers' landmark: a tall river-stone tower on a wide base with a double door, rising more than two and a half screens to a signal lantern on a beacon mast, so the whole town can see it. Keep the placeholder's stages (BuildingTemplate.TOWER_STAGES): base with terrace roof, shaft, lamp gallery, lantern room, cap, mast with the beacon at (150, 8).
Notes: canon 2026-10-26: the Hall is the Wayline Tower (ids unchanged); base 12x3 and doors kept, at least 540 px tall (576 = 24 tiles); door 48 wide so Galeshear (63 px wide) passes C11; open frames come from door_px when absent; legacy_v1 is the v1 picture
Size:  exactly 300x576 world px (aspect 25:48), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=575: the art's lowest opaque row sits on it, centred on x=150
Door:  door_px x 126, y 510, 48x64: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears galeshear (62 px tall, 63 px wide, measured now from its town/s.png) (C11)
Keep:  these points where the code expects them: beacon (150, 8), door_mid (150, 542), lantern (150, 80)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-01-buildings/town.building.hall/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 9:16, pixel true, style_asset_ids = the uploaded house art), then prepare_slot crops 9:16 to 300:576. Weak: nothing else reaches 576 px (PixelLab stops at 400, RD Pro at 256) and 3 SpriteCook credits cover one try. Codex stays the route.

### CX-town-2: town.building.home (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.home.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.home.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.home_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.home_card.png (style sample, placeholder, palette strip)
Brief: The team's home: a low river-stone cottage with a moss roof, a framed door with warm lamplight inside and a step in front.
Notes: open frames come from door_px when absent; legacy_v1 is the v1 picture
Size:  exactly 132x144 world px (aspect 11:12), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=143: the art's lowest opaque row sits on it, centred on x=66
Door:  door_px x 55, y 94, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-01-buildings/town.building.home/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 132x144 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

### CX-town-3: town.building.shop (building)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.shop.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.shop.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.shop_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.shop_card.png (style sample, placeholder, palette strip)
Brief: The Item Shop: a plank-walled shopfront with a gable roof and an awning over the door, where berries, lamp oil and stones are sold.
Notes: open frames come from door_px when absent; legacy_v1 is the v1 picture
Size:  exactly 156x144 world px (aspect 13:12), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=143: the art's lowest opaque row sits on it, centred on x=78
Door:  door_px x 55, y 94, 22x48: an open doorway, dark against the wall and open to the path (C10)
Scale: the doorway clears sparkjab (45 px tall, 22 px wide, measured now from its town/s.png) (C11)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-01-buildings/town.building.shop/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: PixelLab create_map_object, style-matched: a 192x192 crop of a town capture around the lot as background_image with a rectangle mask over the footprint, view high top-down, selective outline. At 156x144 it fits the 192 px inpainting box, so it is painted in the town's own ground and light; then prepare_slot.

### CX-town-4: town.building.storage (building)

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

### CX-town-5: town.building.scrolls (building)

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

Review: `python tools/art/review_sheet.py cx-01-buildings`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hall_door hub_town building_template art_slots --jobs 1`.

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

## cx-06-title: The launch card's night (1 slots)

Codex's own launch files; Codex wires them (sites below).

### CX-title-1: title.backdrop.launch (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch.png (target), docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/title.backdrop.launch_card.png (style sample, placeholder, palette strip)
Brief: The launch card's night: the river valley before the title, dark greens and river blues in a few calm bands, with no text.
Notes: today a flat #161f1b fill (opening_flow.gd:21); placeholder: that fill in 3 stepped bands
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

- `scripts/opening_flow.gd:27` `ink.color = Color("#18172c")`, the launch card's flat fill: draw `ArtSlots.texture("title.backdrop.launch")` at 3x under the logo only when `ArtSlots.source(...) == "file"`, and keep the fill otherwise, so today's card is unchanged. Source issue: the registry note still says `#161f1b` at :21 (the dc37005af text), so its placeholder bands use the old colour.
- `scripts/creature_opening.gd:8` `const VILLAGE = preload(...)` and `:41` `town.texture=VILLAGE`: read `ArtSlots.texture("title.backdrop.village")` (a keep row; its legacy is today's file, so nothing changes). It stays at 4.5x (Preston call 8).
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
Brief: The wooded river trail: weeping willows with long hanging strands, their trunks down to the trail, flood debris caught in them (a snapped branch in a fork, driftwood at a root, a tangle of reeds). Gaps between the trees show the river and hills behind. Tiles left to right.
Notes: parallax 0.45, hazed 0.1; fades out near the rise (the trees open)
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

Added after the plan's counts (lane S). Canon 2026-10-26: on the road back, Highbank and the Tower show on the horizon, faded with distance (the scene adds the haze, so paint them clear); the Tower scene pans up against tower_sky.

### CX-far-1: road.backdrop.highbank_far (backdrop)

```
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far_grid.png (grid, foot row, door, scale block)
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.backdrop.highbank_far_card.png (style sample, placeholder, palette strip)
Brief: Highbank seen from miles down the river: a flat-topped bluff with a few rows of roofs on it, and the Wayline Tower rising over the town more than three times its height, a beacon mast and lantern at the very top (the beacon anchor). Silhouette-level detail only: no windows, no doors. The bluff runs off the bottom edge.
Notes: drawn at 0.82x growing to 1x as the party nears the rise, hazed by the scene (0.5 down to 0.3); the coded beacon glint sits on anchors.beacon
Size:  exactly 160x96 world px (aspect 5:3), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); no outline
Place: foot row y=95: the art's lowest opaque row sits on it, centred on x=80
Keep:  these points where the code expects them: beacon (92, 6)
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
Brief: The rise at first light: the willows open on both sides and Highbank lies below on its bluff, rows of roofs and chimneys, and over all of it the Wayline Tower, a tall river-stone tower with a beacon mast and lantern at the top (the beacon anchor). Grassy ground in the near left where the two stand (the party anchor is the leader's feet). Street lamps at the lamp anchors (paint them unlit: the game lights them and puts them out one by one) and chimney tops at the chimney anchors (the game draws the smoke).
Notes: held view at the rise; coded effects: lamps going out one by one, chimney smoke, the beacon glint
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 48 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Keep:  these points where the code expects them: beacon (268, 8), chimney_1 (202, 126), chimney_2 (308, 124), chimney_3 (355, 125), chimney_4 (248, 136), lamp_1 (154, 152), lamp_2 (211, 141), lamp_3 (286, 140), lamp_4 (313, 154), lamp_5 (250, 168), party (84, 148)
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
Brief: A clear morning sky over Highbank, deep blue at the top paling toward the bottom, two or three long thin clouds. Sky only. Seen behind the Wayline Tower while the camera pans up it; it does not scroll.
Notes: shown only during the Tower scene, behind the town's world, above the area's top edge
Size:  exactly 384x216 world px (aspect 16:9), drawn at 3x; colours <= 32 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/dawn.png`; light from the upper left
Edges: may touch every canvas side; fully opaque, no transparent pixel; no outline
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Deliver to docs/art/slot-candidates/cx-10-road-far/story.backdrop.tower_sky/ with raw, prompt, ledger, prepared and check.json.
Do not install. Lock the batch folder with CODEX_IN_PROGRESS while working.
List "source issues for Claude" in your result.
```

Alt: SpriteCook generate_game_art (aspect 16:9, pixel true, bg_mode include, style_asset_ids = uploaded house art such as waking_native.png); prepare_slot centre-crops and box-downscales. RD Pro tops out at 256x144 and PixelLab makes objects, not scenes.

Review: `python tools/art/review_sheet.py cx-10-road-far`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py road tower_reveal art_slots --jobs 1`.

## Not verified

- No generator was run for this list: the balances are read-only calls, and no route's per-call cost was measured except Retro Diffusion's free estimate ($0.18 for one 48x56 RD Pro prop).
- The Alt routes come from each tool's own description, not from a test in this project.
- The in-game capture column of the review sheet needs a capture made with the candidate swapped in; review_sheet.py shows where it is missing.
