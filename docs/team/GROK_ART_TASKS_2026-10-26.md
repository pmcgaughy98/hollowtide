# Grok art tasks, 2026-10-26 (written by tools/art/write_art_tasks.py; do not edit by hand)

**GATE (Wayline Tower, 2026-10-27): nothing in the tower batches is painted until Preston has walked the coded blockout and approved the key.** The key (cx-11) starts after his walk (Tower Rise with HT_HIGHBANK_V2=1, and scenes/debug/building_lineup.tscn); his yes on the key opens the parts, the title and Grok's small set. The far views and the Tower's sky (cx-10) no longer wait on the crown (cx-14): they were re-briefed for the vast-scale design and opened on 2026-10-28.

Placeholder factory, task-list lane (Claude). 10 batches, 38 slots, 46 images (a slot with several states takes one image per state): the plan's 8 batches, 30 slots and 27 images (00-BUILD-PLAN.md section 4), plus 1 road batch of 3 trail props that lane S added for Preston's canon change of 2026-10-26, plus the Wayline Tower's small set (gb-08, 5 slots, 12 images, 2026-10-27). Registry 19fe5c2bff04. This is the list promised at docs/team/GROK_TASKS_2026-10-26.md:78.

**Grok's spend is asked before anything runs.** The plan's 27 images x $0.06 to $0.13 = $1.62 to $3.51. With the 3 road props and the Tower's 12 images: 46 x $0.06 to $0.13 = $2.76 to $5.98. Ask Preston per batch, quoting its image count and range, before its first run. A redo costs another image.

**Why the old buildings read wrong.** The building rects were set on 2026-10-09 (the Home and Item Shop folders carry that date) and each PNG had to equal its solid footprint, 24 px a tile, with a one-tile door. On 2026-10-10, a day later, the creatures' town set was rebuilt at 1.5x. A stage 3 now stands 55 to 69 px, 2.3 to 2.9 tiles, beside a five-tile house with a 24 px door. Nothing in the old brief tied door or wall height to the creatures. The new canvases do: a single door is 22x48 (clears Sparkjab, a stage 2), the Tower's double door 48x64 (clears Galeshear, a stage 3), and every building and room task names the creature its door must clear (C11 measures it from the creature's own town sprite at check time).
**Nothing installs without Preston's yes.** Every batch ends in a review sheet (`python tools/art/review_sheet.py <batch>`): per slot the placeholder, the prepared candidate, an in-game capture and the check lines. Preston answers yes, redo (one line why) or keep the placeholder; Claude records it in the batch's review.json; `install_slot.py` refuses any slot without his yes.

**Canon, 2026-10-26.** The Wayline Hall is the Wayline Tower in everything the player sees; ids keep `hall` (so `town.prop.sign_hall` is the Tower's sign). All new names are working labels.

**Wayline Tower approved, 2026-10-27** (Preston: "go with the defaults and build it"; docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md). A rooted river-stone tower 720 px (30 tiles) tall, built from 21 parts in one 432x720 frame, whose living root (the Reach) curls over the top like a crook to hold the Waiting Lamp above the door. The camera leans up 72 px at the doors. Today's game (v1) keeps the legacy 240x144 Hall until Preston walks v2. The title's town becomes Highbank with the Tower prominent (cx-15); the old title village is kept for a future town on another map. The Reach, the Waiting Lamp, the Route Board, the First Post and the dark lantern are working labels until Preston renames or cuts them.

## Generator balances (read only, 2026-10-27; nothing was generated)

- **AutoSprite** (get_account): 15 credits. Connected, no sign-in needed. generate_asset_preview costs 1 credit a call; an 8-direction character pack costs 15. The 2026-10-26 sprite tool test recorded that its generate step needed a paid plan; not retested, since no generation call was made.
- **PixelLab** (get_balance): $0.00 credits; trial plan with 0 plan generations left (51.2 used of 40); 16 daily bonus generations left today, refilled nightly (+5, up to 20).
- **SpriteCook** (get_credit_balance): 3 credits, free tier, one job at a time.
- **Retro Diffusion** (get_balance): $0.11 (the call also reports 50 credits; the free cost estimate reports 0 credits left). One RD Pro top-down prop at 48x56 is estimated at $0.18, so RD needs a top-up before any run.

Every credit spend waits for Preston's yes. Each task names one **Alt** route; Grok stays the owner the registry names.

<details><summary>What each alternative tool makes</summary>

- **AutoSprite** (connected): makes characters (8-direction packs, spritesheets, portraits, poses) and single assets through generate_asset_preview: weapon, item, character, prop, effect or texture, in pixel, painted, flat, anime, comic or isometric style, 1 credit a call; pixelArt true gives a 16-bit sprite on a crisp grid in 32 colours. No style reference and no size control, so prepare_slot does the sizing and the palette. Never for creatures here.
- **PixelLab**: create_map_object makes one object on a clear background, canvas 32 to 400 px (clear only up to 40,000 px of area); given a background_image (up to 192x192 for inpainting) it paints the object in that picture's style. create_building_kit makes matched floor, wall, doorway and stair pieces (square_topdown, tiles 16 to 96 px, walls 1 to 3 tiles, a colour cap). create_ui_asset makes 9-slice-style panels (192 to 688 px). The top-down tileset tools make two-terrain autotile sets (16 or 32 px tiles). pixelart_workbench is free: exact pixels placed by hand.
- **SpriteCook**: generate_game_art makes pixel or HD stills from text, with up to 14 uploaded style images (style_asset_ids), one reference or one picture to edit; aspect 1:1, 16:9 or 9:16; mode texture for seamless fills; the pixel-engine-image-v1 model draws at exactly the asked size from 16 to 128 px (sides up to 4:1) with the background removed, but takes no references. UI kits and tilesets too. Its 3 credits cover very little.
- **Retro Diffusion**: RD Pro styles take up to 9 reference images per run and draw from 12 px up to 256 px (a 16:9 scene is 256x144, which is not a whole-number step to 384x216). Needs a top-up first (see the balance).

</details>

## Rules for every Grok run

1. **The honesty line first**: "if a step fails, or you cannot see the attached image, say so plainly instead of guessing." `tools/grok_image.py make` puts it at the head of every prompt.
2. **One image per run**, through `tools/grok_image.py make <card> <raw.png> "<make line>" --aspect <a:b>`. It copies the card alone into a fresh temporary folder, a **sealed folder**: Grok never reads the repo, the Preston Hub or anything private. Never run Grok from the repo or the Hub.
3. Grok reads the card (a style sample of installed house art, the placeholder and the palette strip; no words on it) for style and colours.
4. Clean pixel art: flat colour areas, hard-edged clusters, no gradients or blur, light from the upper left.
5. **Nothing from any franchise**: nothing that reads as another game, show or brand.
6. **No text in images**: no words, letters or numbers anywhere. grok_image.py says it twice and every make line says it again, because Grok added labels when told once.
7. No creatures, animals or people. No AmFam material goes near any prompt.
8. Then `python tools/art/prepare_slot.py <slot_id> raw.png prepared.png` and `python tools/art/validate_slot.py <slot_id> prepared.png`, both inside `docs/art/slot-candidates/<batch>/<slot_id>/`. Report the check line, Grok's one-sentence reply and the cost (from `raw.png.grok.json`).
9. `python tools/art/review_sheet.py <batch>`; nothing installs before Preston's yes (`install_slot.py` refuses without it).

## Batches

| Batch | Slots | Images | Cost range | Area |
|---|---|---|---|---|
| `gb-01-street` | 8 | 9 | $0.54 to $1.17 | Street 1: lamp, well, waymark and street furniture |
| `gb-02-fences` | 4 | 4 | $0.24 to $0.52 | Street 2: fences and the road east barrier |
| `gb-03-parts` | 8 | 8 | $0.48 to $1.04 | Building parts: five signs and three shut overlays |
| `gb-04-furniture` | 4 | 4 | $0.24 to $0.52 | Shop and cellar furniture |
| `gb-05-menu` | 1 | 1 | $0.06 to $0.13 | The main menu's cursor |
| `gb-06-stairs` | 1 | 1 | $0.06 to $0.13 | Sealed stairs on the boss floor |
| `gb-07-road` | 3 | 3 | $0.18 to $0.39 | The road back: trail props |
| `gb-08-tower` | 5 | 12 | $0.72 to $1.56 | The Wayline Tower's small set: route lanterns, wayline posts, basket, cradle and parcel |
| `gb-09-forest` | 1 | 1 | $0.06 to $0.13 | The Great Tree Path: one forest trunk |
| `gb-10-dooryards` | 3 | 3 | $0.18 to $0.39 | Dooryards: what lies in front of a building |

## gb-01-street: Street 1: lamp, well, waymark and street furniture (8 slots, 9 images)

### GB-street-1: town.lamp.post

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post_grid.png (grid, foot row)
Sheet: 24x96, one 24x48 row per state, top to bottom: unlit, lit
Size:  exactly 24x48 world px (aspect 1:2), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/lantern.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=47: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (unlit): a Highbank street lamp: a dark timber post with an iron bracket and a glass lantern box. No glow beyond the glass and no ground shadow. This image: the unlit still, the lantern glass dark. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post_card.png docs/art/slot-candidates/gb-01-street/town.lamp.post/raw_unlit.png "a Highbank street lamp: a dark timber post with an iron bracket and a glass lantern box. No glow beyond the glass and no ground shadow. This image: the unlit still, the lantern glass dark. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Make (lit): a Highbank street lamp: a dark timber post with an iron bracket and a glass lantern box. No glow beyond the glass and no ground shadow. This image: the lit still, the same lamp with its lantern glass lit warm gold from inside. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.lamp.post_card.png docs/art/slot-candidates/gb-01-street/town.lamp.post/raw_lit.png "a Highbank street lamp: a dark timber post with an iron bracket and a glass lantern box. No glow beyond the glass and no ground shadow. This image: the lit still, the same lamp with its lantern glass lit warm gold from inside. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-01-street/town.lamp.post/raw.png docs/art/slot-candidates/gb-01-street/town.lamp.post/raw_unlit.png docs/art/slot-candidates/gb-01-street/town.lamp.post/raw_lit.png
Then:  python tools/art/prepare_slot.py town.lamp.post docs/art/slot-candidates/gb-01-street/town.lamp.post/raw.png docs/art/slot-candidates/gb-01-street/town.lamp.post/prepared.png
       python tools/art/validate_slot.py town.lamp.post docs/art/slot-candidates/gb-01-street/town.lamp.post/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 town capture (unlit), then the lit still from the unlit one with a custom mask over the lantern box only, so both rows share every other pixel; stack them with --stack.

### GB-street-2: town.prop.well

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.well_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.well.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.well.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.well_grid.png (grid, foot row)
Size:  exactly 48x56 world px (aspect 6:7), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=55: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  the Tower Rise well where the team waits: a round river-stone well with a small timber roof and a bucket. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.well_card.png docs/art/slot-candidates/gb-01-street/town.prop.well/raw.png "the Tower Rise well where the team waits: a round river-stone well with a small timber roof and a bucket. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Then:  python tools/art/prepare_slot.py town.prop.well docs/art/slot-candidates/gb-01-street/town.prop.well/raw.png docs/art/slot-candidates/gb-01-street/town.prop.well/prepared.png
       python tools/art/validate_slot.py town.prop.well docs/art/slot-candidates/gb-01-street/town.prop.well/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 48x56 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 48x56.

### GB-street-3: town.prop.waymark

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.waymark_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.waymark.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.waymark.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.waymark_grid.png (grid, foot row)
Size:  exactly 24x48 world px (aspect 1:2), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=47: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  the Crossroads waymark: a timber post with arrow boards pointing to every place, with no letters on them. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.waymark_card.png docs/art/slot-candidates/gb-01-street/town.prop.waymark/raw.png "the Crossroads waymark: a timber post with arrow boards pointing to every place, with no letters on them. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Then:  python tools/art/prepare_slot.py town.prop.waymark docs/art/slot-candidates/gb-01-street/town.prop.waymark/raw.png docs/art/slot-candidates/gb-01-street/town.prop.waymark/prepared.png
       python tools/art/validate_slot.py town.prop.waymark docs/art/slot-candidates/gb-01-street/town.prop.waymark/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x48 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x48.

### GB-street-4: town.prop.bench

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.bench_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.bench.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.bench.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.bench_grid.png (grid, foot row)
Size:  exactly 48x32 world px (aspect 3:2), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=31: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a plank street bench on two stone feet. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.bench_card.png docs/art/slot-candidates/gb-01-street/town.prop.bench/raw.png "a plank street bench on two stone feet. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:2
Then:  python tools/art/prepare_slot.py town.prop.bench docs/art/slot-candidates/gb-01-street/town.prop.bench/raw.png docs/art/slot-candidates/gb-01-street/town.prop.bench/prepared.png
       python tools/art/validate_slot.py town.prop.bench docs/art/slot-candidates/gb-01-street/town.prop.bench/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 48x32 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 48x32.

### GB-street-5: town.prop.crates

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.crates_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.crates.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.crates.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.crates_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small stack of two courier crates bound with rope. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.crates_card.png docs/art/slot-candidates/gb-01-street/town.prop.crates/raw.png "a small stack of two courier crates bound with rope. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.crates docs/art/slot-candidates/gb-01-street/town.prop.crates/raw.png docs/art/slot-candidates/gb-01-street/town.prop.crates/prepared.png
       python tools/art/validate_slot.py town.prop.crates docs/art/slot-candidates/gb-01-street/town.prop.crates/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: AutoSprite generate_asset_preview (category prop, pixelArt true, 1 credit of 15): a single object on a crisp pixel grid. No style reference, so prepare_slot snaps it to the slot palette. Cheaper than Grok.

### GB-street-6: town.prop.barrel

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.barrel_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.barrel.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.barrel.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.barrel_grid.png (grid, foot row)
Size:  exactly 24x28 world px (aspect 6:7), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=27: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a banded timber water barrel. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.barrel_card.png docs/art/slot-candidates/gb-01-street/town.prop.barrel/raw.png "a banded timber water barrel. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Then:  python tools/art/prepare_slot.py town.prop.barrel docs/art/slot-candidates/gb-01-street/town.prop.barrel/raw.png docs/art/slot-candidates/gb-01-street/town.prop.barrel/prepared.png
       python tools/art/validate_slot.py town.prop.barrel docs/art/slot-candidates/gb-01-street/town.prop.barrel/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: AutoSprite generate_asset_preview (category prop, pixelArt true, 1 credit of 15): a single object on a crisp pixel grid. No style reference, so prepare_slot snaps it to the slot palette. Cheaper than Grok.

### GB-street-7: town.prop.planter

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.planter_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.planter.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.planter.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.planter_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_stone.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a stone planter box with a low green shrub. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.planter_card.png docs/art/slot-candidates/gb-01-street/town.prop.planter/raw.png "a stone planter box with a low green shrub. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.planter docs/art/slot-candidates/gb-01-street/town.prop.planter/raw.png docs/art/slot-candidates/gb-01-street/town.prop.planter/prepared.png
       python tools/art/validate_slot.py town.prop.planter docs/art/slot-candidates/gb-01-street/town.prop.planter/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: AutoSprite generate_asset_preview (category prop, pixelArt true, 1 credit of 15): a single object on a crisp pixel grid. No style reference, so prepare_slot snaps it to the slot palette. Cheaper than Grok.

### GB-street-8: town.prop.mooring_post

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.mooring_post_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.mooring_post.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.mooring_post.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.mooring_post_grid.png (grid, foot row)
Size:  exactly 24x36 world px (aspect 2:3), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=35: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a thick timber mooring post at the Ferry Dock with a coil of rope around it. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.mooring_post_card.png docs/art/slot-candidates/gb-01-street/town.prop.mooring_post/raw.png "a thick timber mooring post at the Ferry Dock with a coil of rope around it. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 2:3
Then:  python tools/art/prepare_slot.py town.prop.mooring_post docs/art/slot-candidates/gb-01-street/town.prop.mooring_post/raw.png docs/art/slot-candidates/gb-01-street/town.prop.mooring_post/prepared.png
       python tools/art/validate_slot.py town.prop.mooring_post docs/art/slot-candidates/gb-01-street/town.prop.mooring_post/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x36 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x36.

Review: `python tools/art/review_sheet.py gb-01-street`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_props hub_town art_slots --jobs 1`.

## gb-02-fences: Street 2: fences and the road east barrier (4 slots, 4 images)

### GB-fence-1: town.prop.fence_h

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_h_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_h.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_h.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_h_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: left, right, bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Tile:  tiles left to right: the left and right edge columns must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  one span of low timber fence, its rails running left to right so it tiles with itself. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_h_card.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_h/raw.png "one span of low timber fence, its rails running left to right so it tiles with itself. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.fence_h docs/art/slot-candidates/gb-02-fences/town.prop.fence_h/raw.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_h/prepared.png
       python tools/art/validate_slot.py town.prop.fence_h docs/art/slot-candidates/gb-02-fences/town.prop.fence_h/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-fence-2: town.prop.fence_v

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_v_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_v.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_v.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_v_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: top, bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Tile:  tiles top to bottom: the top and bottom edge rows must meet (C6)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  one span of low timber fence running away from the camera, so it tiles top to bottom. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_v_card.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_v/raw.png "one span of low timber fence running away from the camera, so it tiles top to bottom. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.fence_v docs/art/slot-candidates/gb-02-fences/town.prop.fence_v/raw.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_v/prepared.png
       python tools/art/validate_slot.py town.prop.fence_v docs/art/slot-candidates/gb-02-fences/town.prop.fence_v/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-fence-3: town.prop.fence_corner

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_corner_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_corner.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_corner.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_corner_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: right, bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a timber fence corner post where a left-right span meets a front-back span. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.fence_corner_card.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_corner/raw.png "a timber fence corner post where a left-right span meets a front-back span. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.fence_corner docs/art/slot-candidates/gb-02-fences/town.prop.fence_corner/raw.png docs/art/slot-candidates/gb-02-fences/town.prop.fence_corner/prepared.png
       python tools/art/validate_slot.py town.prop.fence_corner docs/art/slot-candidates/gb-02-fences/town.prop.fence_corner/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-fence-4: town.prop.road_barrier

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.road_barrier_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.road_barrier.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.road_barrier.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.road_barrier_grid.png (grid, foot row)
Size:  exactly 24x60 world px (aspect 2:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=59: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a timber barrier across the road east: two posts and crossed planks that show the way is closed, with no words. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.road_barrier_card.png docs/art/slot-candidates/gb-02-fences/town.prop.road_barrier/raw.png "a timber barrier across the road east: two posts and crossed planks that show the way is closed, with no words. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Then:  python tools/art/prepare_slot.py town.prop.road_barrier docs/art/slot-candidates/gb-02-fences/town.prop.road_barrier/raw.png docs/art/slot-candidates/gb-02-fences/town.prop.road_barrier/prepared.png
       python tools/art/validate_slot.py town.prop.road_barrier docs/art/slot-candidates/gb-02-fences/town.prop.road_barrier/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x60 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x60.

Review: `python tools/art/review_sheet.py gb-02-fences`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_props hub_town art_slots --jobs 1`.

## gb-03-parts: Building parts: five signs and three shut overlays (8 slots, 8 images)

### GB-parts-1: town.prop.sign_hall

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_hall_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_hall.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_hall.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_hall_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small hanging plank sign with a carved pictogram of a waymark arrow, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_hall_card.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_hall/raw.png "a small hanging plank sign with a carved pictogram of a waymark arrow, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.sign_hall docs/art/slot-candidates/gb-03-parts/town.prop.sign_hall/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_hall/prepared.png
       python tools/art/validate_slot.py town.prop.sign_hall docs/art/slot-candidates/gb-03-parts/town.prop.sign_hall/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-parts-2: town.prop.sign_shop

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_shop_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_shop.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_shop.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_shop_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small hanging plank sign with a carved pictogram of a satchel bag, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_shop_card.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_shop/raw.png "a small hanging plank sign with a carved pictogram of a satchel bag, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.sign_shop docs/art/slot-candidates/gb-03-parts/town.prop.sign_shop/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_shop/prepared.png
       python tools/art/validate_slot.py town.prop.sign_shop docs/art/slot-candidates/gb-03-parts/town.prop.sign_shop/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-parts-3: town.prop.sign_storage

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_storage_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_storage.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_storage.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_storage_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small hanging plank sign with a carved pictogram of a crate, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_storage_card.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_storage/raw.png "a small hanging plank sign with a carved pictogram of a crate, no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.sign_storage docs/art/slot-candidates/gb-03-parts/town.prop.sign_storage/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_storage/prepared.png
       python tools/art/validate_slot.py town.prop.sign_storage docs/art/slot-candidates/gb-03-parts/town.prop.sign_storage/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-parts-4: town.prop.sign_scrolls

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_scrolls_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_scrolls.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_scrolls.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_scrolls_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small hanging plank sign with a carved pictogram of a rolled scroll (proposal), no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_scrolls_card.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_scrolls/raw.png "a small hanging plank sign with a carved pictogram of a rolled scroll (proposal), no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.sign_scrolls docs/art/slot-candidates/gb-03-parts/town.prop.sign_scrolls/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_scrolls/prepared.png
       python tools/art/validate_slot.py town.prop.sign_scrolls docs/art/slot-candidates/gb-03-parts/town.prop.sign_scrolls/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-parts-5: town.prop.sign_yard

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_yard_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_yard.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_yard.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_yard_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a small hanging plank sign with a carved pictogram of two crossed sparring staves (proposal), no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.sign_yard_card.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_yard/raw.png "a small hanging plank sign with a carved pictogram of two crossed sparring staves (proposal), no letters. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.sign_yard docs/art/slot-candidates/gb-03-parts/town.prop.sign_yard/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.sign_yard/prepared.png
       python tools/art/validate_slot.py town.prop.sign_yard docs/art/slot-candidates/gb-03-parts/town.prop.sign_yard/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): a 24x24 tiling span or a pictogram board is easier to place pixel by pixel than to generate, and C6 needs the span's edges to meet.

### GB-parts-6: town.prop.shut_boards

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_boards_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_boards.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_boards.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_boards_grid.png (grid, foot row)
Size:  exactly 26x50 world px (aspect 13:25), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=49: the art's lowest opaque row sits on it, centred on x=13
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  rough planks nailed across a shut doorway. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_boards_card.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_boards/raw.png "rough planks nailed across a shut doorway. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Then:  python tools/art/prepare_slot.py town.prop.shut_boards docs/art/slot-candidates/gb-03-parts/town.prop.shut_boards/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_boards/prepared.png
       python tools/art/validate_slot.py town.prop.shut_boards docs/art/slot-candidates/gb-03-parts/town.prop.shut_boards/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x50 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 26x50.

### GB-parts-7: town.prop.shut_chain

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_chain_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_chain.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_chain.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_chain_grid.png (grid, foot row)
Size:  exactly 28x36 world px (aspect 7:9), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=35: the art's lowest opaque row sits on it, centred on x=14
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  an iron chain and brass padlock hung across a shut door. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_chain_card.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_chain/raw.png "an iron chain and brass padlock hung across a shut door. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Then:  python tools/art/prepare_slot.py town.prop.shut_chain docs/art/slot-candidates/gb-03-parts/town.prop.shut_chain/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_chain/prepared.png
       python tools/art/validate_slot.py town.prop.shut_chain docs/art/slot-candidates/gb-03-parts/town.prop.shut_chain/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x36 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 28x36.

### GB-parts-8: town.prop.shut_rope

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_rope_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_rope.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_rope.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_rope_grid.png (grid, foot row)
Size:  exactly 30x20 world px (aspect 3:2), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: left, right, bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=19: the art's lowest opaque row sits on it, centred on x=15
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a hemp rope slung between two stakes across a closed gate. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.shut_rope_card.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_rope/raw.png "a hemp rope slung between two stakes across a closed gate. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:2
Then:  python tools/art/prepare_slot.py town.prop.shut_rope docs/art/slot-candidates/gb-03-parts/town.prop.shut_rope/raw.png docs/art/slot-candidates/gb-03-parts/town.prop.shut_rope/prepared.png
       python tools/art/validate_slot.py town.prop.shut_rope docs/art/slot-candidates/gb-03-parts/town.prop.shut_rope/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x32 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 30x20.

Review: `python tools/art/review_sheet.py gb-03-parts`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py hub_town building_template hall_door art_slots --jobs 1`.

## gb-04-furniture: Shop and cellar furniture (4 slots, 4 images)

### GB-furniture-1: town.prop.shop.counter

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.counter_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.counter.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.counter.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.counter_grid.png (grid, foot row)
Size:  exactly 96x48 world px (aspect 2:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=47: the art's lowest opaque row sits on it, centred on x=48
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  the Item Shop counter: a long timber counter with a brass scale and a few jars on it. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.counter_card.png docs/art/slot-candidates/gb-04-furniture/town.prop.shop.counter/raw.png "the Item Shop counter: a long timber counter with a brass scale and a few jars on it. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 2:1
Then:  python tools/art/prepare_slot.py town.prop.shop.counter docs/art/slot-candidates/gb-04-furniture/town.prop.shop.counter/raw.png docs/art/slot-candidates/gb-04-furniture/town.prop.shop.counter/prepared.png
       python tools/art/validate_slot.py town.prop.shop.counter docs/art/slot-candidates/gb-04-furniture/town.prop.shop.counter/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of the Home interior (the shop and cellar rooms are still placeholders), view high top-down; then prepare_slot.

### GB-furniture-2: town.prop.shop.shelf

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.shelf_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.shelf.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.shelf.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.shelf_grid.png (grid, foot row)
Size:  exactly 48x72 world px (aspect 2:3), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_shop.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=71: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a tall timber shop shelf stocked with jars, bundles and small sacks. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.shop.shelf_card.png docs/art/slot-candidates/gb-04-furniture/town.prop.shop.shelf/raw.png "a tall timber shop shelf stocked with jars, bundles and small sacks. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 2:3
Then:  python tools/art/prepare_slot.py town.prop.shop.shelf docs/art/slot-candidates/gb-04-furniture/town.prop.shop.shelf/raw.png docs/art/slot-candidates/gb-04-furniture/town.prop.shop.shelf/prepared.png
       python tools/art/validate_slot.py town.prop.shop.shelf docs/art/slot-candidates/gb-04-furniture/town.prop.shop.shelf/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of the Home interior (the shop and cellar rooms are still placeholders), view high top-down; then prepare_slot.

### GB-furniture-3: town.prop.scrolls_cellar.rack

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.rack_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.rack.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.rack.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.rack_grid.png (grid, foot row)
Size:  exactly 48x72 world px (aspect 2:3), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=71: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a tall cellar rack of rolled scrolls in pigeonholes. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.rack_card.png docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.rack/raw.png "a tall cellar rack of rolled scrolls in pigeonholes. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 2:3
Then:  python tools/art/prepare_slot.py town.prop.scrolls_cellar.rack docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.rack/raw.png docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.rack/prepared.png
       python tools/art/validate_slot.py town.prop.scrolls_cellar.rack docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.rack/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of the Home interior (the shop and cellar rooms are still placeholders), view high top-down; then prepare_slot.

### GB-furniture-4: town.prop.scrolls_cellar.table

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.table_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.table.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.table.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.table_grid.png (grid, foot row)
Size:  exactly 48x40 world px (aspect 6:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/room_scrolls_cellar.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=39: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a low reading table with an open scroll weighed down by two stones. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.scrolls_cellar.table_card.png docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.table/raw.png "a low reading table with an open scroll weighed down by two stones. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 4:3
Then:  python tools/art/prepare_slot.py town.prop.scrolls_cellar.table docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.table/raw.png docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.table/prepared.png
       python tools/art/validate_slot.py town.prop.scrolls_cellar.table docs/art/slot-candidates/gb-04-furniture/town.prop.scrolls_cellar.table/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of the Home interior (the shop and cellar rooms are still placeholders), view high top-down; then prepare_slot.

Review: `python tools/art/review_sheet.py gb-04-furniture`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_room art_slots --jobs 1`.

## gb-05-menu: The main menu's cursor (1 slot, 1 image)

Codex wires it into main_menu.gd (CX-title-1); the bounce stays coded.

### GB-menu-1: title.hud_piece.menu_cursor

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/title.hud_piece.menu_cursor_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/title.hud_piece.menu_cursor.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/title.hud_piece.menu_cursor.png (target), docs/design/placeholder-factory-2026-10-26/refs/title.hud_piece.menu_cursor_grid.png (grid, foot row)
Size:  exactly 8x9 world px (aspect 8:9), drawn at 3x; colours <= 16 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/brass_ui.png`; light from the upper left
Edges: touches no canvas side (keep a 1 px clear margin all round); alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: placed by its left middle (0, 4)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  the main menu's pointer: a small brass arrowhead pointing right, lit from the upper left. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/title.hud_piece.menu_cursor_card.png docs/art/slot-candidates/gb-05-menu/title.hud_piece.menu_cursor/raw.png "the main menu's pointer: a small brass arrowhead pointing right, lit from the upper left. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py title.hud_piece.menu_cursor docs/art/slot-candidates/gb-05-menu/title.hud_piece.menu_cursor/raw.png docs/art/slot-candidates/gb-05-menu/title.hud_piece.menu_cursor/prepared.png
       python tools/art/validate_slot.py title.hud_piece.menu_cursor docs/art/slot-candidates/gb-05-menu/title.hud_piece.menu_cursor/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free): 8x9 is under every generator's smallest canvas (PixelLab 32, SpriteCook 16, RD Pro 12); placed by hand like the UI frames. Fits better than Grok.

Review: `python tools/art/review_sheet.py gb-05-menu`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py opening_flow art_slots --jobs 1`.

## gb-06-stairs: Sealed stairs on the boss floor (1 slot, 1 image)

Replaces the red X drawn while the boss stands; the coded slab stands in until then.

### GB-dungeon-1: dungeon.prop.stairs_sealed

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/dungeon.prop.stairs_sealed_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/dungeon.prop.stairs_sealed.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/dungeon.prop.stairs_sealed.png (target), docs/design/placeholder-factory-2026-10-26/refs/dungeon.prop.stairs_sealed_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/ruin.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  sealed stairs in a ruin floor: a slate slab over the stair opening with a teal seal ring set into it. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/dungeon.prop.stairs_sealed_card.png docs/art/slot-candidates/gb-06-stairs/dungeon.prop.stairs_sealed/raw.png "sealed stairs in a ruin floor: a slate slab over the stair opening with a teal seal ring set into it. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py dungeon.prop.stairs_sealed docs/art/slot-candidates/gb-06-stairs/dungeon.prop.stairs_sealed/raw.png docs/art/slot-candidates/gb-06-stairs/dungeon.prop.stairs_sealed/prepared.png
       python tools/art/validate_slot.py dungeon.prop.stairs_sealed docs/art/slot-candidates/gb-06-stairs/dungeon.prop.stairs_sealed/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of a painted ruin floor, mask over one tile, prepared 32 to 24 px. (RD Pro with ruin captures as reference_images fits too, at $0.18, after a top-up.)

Review: `python tools/art/review_sheet.py gb-06-stairs`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py dungeon dungeon_boss art_slots --jobs 1`.

## gb-07-road: The road back: trail props (3 slots, 3 images)

Added after the plan's counts (lane S, Preston's canon change 4).

### GB-road-1: road.prop.ferry_sign

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.ferry_sign_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.ferry_sign.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.prop.ferry_sign.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.prop.ferry_sign_grid.png (grid, foot row)
Size:  exactly 40x48 world px (aspect 5:6), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=47: the art's lowest opaque row sits on it, centred on x=20
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a washed-out ferry sign by the trail: a leaning post with a plank sign, a boat painted on it (a picture, no letters), a flood line staining its lower half and a corner broken off. Mud at the foot. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/road.prop.ferry_sign_card.png docs/art/slot-candidates/gb-07-road/road.prop.ferry_sign/raw.png "a washed-out ferry sign by the trail: a leaning post with a plank sign, a boat painted on it (a picture, no letters), a flood line staining its lower half and a corner broken off. Mud at the foot. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Then:  python tools/art/prepare_slot.py road.prop.ferry_sign docs/art/slot-candidates/gb-07-road/road.prop.ferry_sign/raw.png docs/art/slot-candidates/gb-07-road/road.prop.ferry_sign/prepared.png
       python tools/art/validate_slot.py road.prop.ferry_sign docs/art/slot-candidates/gb-07-road/road.prop.ferry_sign/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 40x48 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 40x48.

### GB-road-2: road.prop.waymark

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.waymark_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.waymark.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.prop.waymark.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.prop.waymark_grid.png (grid, foot row)
Size:  exactly 24x56 world px (aspect 3:7), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=55: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a Wayline waymark post: a squared timber post with a brass cap, a carved arrow pointing up the trail (right), a teal courier band, and an arm holding an unlit trail lantern. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/road.prop.waymark_card.png docs/art/slot-candidates/gb-07-road/road.prop.waymark/raw.png "a Wayline waymark post: a squared timber post with a brass cap, a carved arrow pointing up the trail (right), a teal courier band, and an arm holding an unlit trail lantern. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Then:  python tools/art/prepare_slot.py road.prop.waymark docs/art/slot-candidates/gb-07-road/road.prop.waymark/raw.png docs/art/slot-candidates/gb-07-road/road.prop.waymark/prepared.png
       python tools/art/validate_slot.py road.prop.waymark docs/art/slot-candidates/gb-07-road/road.prop.waymark/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x56 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x56.

### GB-road-3: road.prop.lost_parcel

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.lost_parcel_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/road.prop.lost_parcel.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/road.prop.lost_parcel.png (target), docs/design/placeholder-factory-2026-10-26/refs/road.prop.lost_parcel_grid.png (grid, foot row)
Size:  exactly 32x20 world px (aspect 8:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=19: the art's lowest opaque row sits on it, centred on x=16
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a lost parcel half sunk in the mud at the trail's edge: a paper-wrapped box tipped on its corner, its twine dark with river water, the bottom third under mud with a wet sheen. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/road.prop.lost_parcel_card.png docs/art/slot-candidates/gb-07-road/road.prop.lost_parcel/raw.png "a lost parcel half sunk in the mud at the trail's edge: a paper-wrapped box tipped on its corner, its twine dark with river water, the bottom third under mud with a wet sheen. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:2
Then:  python tools/art/prepare_slot.py road.prop.lost_parcel docs/art/slot-candidates/gb-07-road/road.prop.lost_parcel/raw.png docs/art/slot-candidates/gb-07-road/road.prop.lost_parcel/prepared.png
       python tools/art/validate_slot.py road.prop.lost_parcel docs/art/slot-candidates/gb-07-road/road.prop.lost_parcel/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: AutoSprite generate_asset_preview (category prop, pixelArt true, 1 credit of 15): a single object on a crisp pixel grid. No style reference, so prepare_slot snaps it to the slot palette. Cheaper than Grok.

Review: `python tools/art/review_sheet.py gb-07-road`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py road art_slots --jobs 1`.

## gb-08-tower: The Wayline Tower's small set: route lanterns, wayline posts, basket, cradle and parcel (5 slots, 12 images)

**GATE: nothing here is made until Preston has walked the Tower's blockout and approved its key (Codex batch cx-11).**

Added 2026-10-27 for the approved Wayline Tower (TOWER_DESIGN.md section 5, rows 11 and 17 to 21). Small things hung on or carried by the tower; the game draws the cables, the rope, the glow and all motion. The quiet states are the route that went quiet: an absence, never a ghost. Check with HT_HIGHBANK_V2=1 set (the tower is a v2 building), then once more without it.

### GB-tower-1: town.building.hall.route_lantern

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern_grid.png (grid, foot row)
Sheet: 36x60, one 12x20 cell per frame, frames left to right; one row per state, top to bottom: lit (3 frames), dark (1 frame), quiet (1 frame)
Size:  exactly 12x20 world px (aspect 3:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch only: top; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Scale: the grid's grey block is sparkjab (45 px tall, 22 px wide, measured now from its town/s.png), a stage 2 for scale
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (lit): a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the lit still, the same lamp with its lantern glass lit warm gold from inside. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern_card.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_lit.png "a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the lit still, the same lamp with its lantern glass lit warm gold from inside. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 9:16
Make (dark): a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the dark still, the same lantern with its glass unlit. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern_card.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_dark.png "a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the dark still, the same lantern with its glass unlit. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 9:16
Make (quiet): a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the quiet still, the same object with dusty grey glass and no wick, for a route that went quiet (an absence, never a ghost). One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.building.hall.route_lantern_card.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_quiet.png "a route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost). This image: the quiet still, the same object with dusty grey glass and no wick, for a route that went quiet (an absence, never a ghost). One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 9:16
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_lit.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_dark.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw_quiet.png --frames 3,1,1
Frames: lit 3 frames. Grok makes one still per state and --frames copies it into each frame cell; then make the frames differ by hand in prepared.png as the brief says (PixelLab pixelart_workbench, free, exact pixels) and validate again. Identical frames are an allowed first pass.
Then:  python tools/art/prepare_slot.py town.building.hall.route_lantern docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/raw.png docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/prepared.png
       python tools/art/validate_slot.py town.building.hall.route_lantern docs/art/slot-candidates/gb-08-tower/town.building.hall.route_lantern/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): 12x20 is at or under the generators' smallest canvases (PixelLab 32, SpriteCook 16, RD Pro 12), and its states and frames must share every pixel but the part that changes. Fits better than Grok.

### GB-tower-2: town.prop.hall.wayline_post

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post_grid.png (grid, foot row)
Sheet: 24x192, one 24x64 row per state, top to bottom: strung, waiting, quiet
Size:  exactly 24x64 world px (aspect 3:8), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=63: the art's lowest opaque row sits on it, centred on x=12
Keep:  these points where the code expects them: pulley (12, 7)
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (strung): a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the strung still, the post's small lantern lit warm gold. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_strung.png "a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the strung still, the post's small lantern lit warm gold. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Make (waiting): a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the waiting still, the same post with its small lantern unlit. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_waiting.png "a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the waiting still, the same post with its small lantern unlit. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Make (quiet): a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the quiet still, the same object with dusty grey glass and no wick, for a route that went quiet (an absence, never a ghost). One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.wayline_post_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_quiet.png "a wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette. This image: the quiet still, the same object with dusty grey glass and no wick, for a route that went quiet (an absence, never a ghost). One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_strung.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_waiting.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw_quiet.png
Then:  python tools/art/prepare_slot.py town.prop.hall.wayline_post docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/prepared.png
       python tools/art/validate_slot.py town.prop.hall.wayline_post docs/art/slot-candidates/gb-08-tower/town.prop.hall.wayline_post/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object, style-matched against a 192x192 capture of Tower Rise round tile (2, 10), view high top-down, for the strung still; then the waiting and quiet stills from it with a mask over the lantern only, so all three rows share every other pixel; stack them with --stack.

### GB-tower-3: town.prop.hall.basket

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket_grid.png (grid, foot row)
Sheet: 16x32, one 16x16 row per state, top to bottom: full, empty
Size:  exactly 16x16 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch only: top; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (full): the hoist basket hung from its rope by the top middle: a wicker basket on two rope slings, carrying an oilcloth parcel when full. No outer outline (the game rims it). wayline_tower palette. This image: the full still, the basket carrying an oilcloth parcel. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw_full.png "the hoist basket hung from its rope by the top middle: a wicker basket on two rope slings, carrying an oilcloth parcel when full. No outer outline (the game rims it). wayline_tower palette. This image: the full still, the basket carrying an oilcloth parcel. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Make (empty): the hoist basket hung from its rope by the top middle: a wicker basket on two rope slings, carrying an oilcloth parcel when full. No outer outline (the game rims it). wayline_tower palette. This image: the empty still, the same object carrying nothing. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.basket_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw_empty.png "the hoist basket hung from its rope by the top middle: a wicker basket on two rope slings, carrying an oilcloth parcel when full. No outer outline (the game rims it). wayline_tower palette. This image: the empty still, the same object carrying nothing. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw_full.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw_empty.png
Then:  python tools/art/prepare_slot.py town.prop.hall.basket docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/prepared.png
       python tools/art/validate_slot.py town.prop.hall.basket docs/art/slot-candidates/gb-08-tower/town.prop.hall.basket/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): 16x16 is at or under the generators' smallest canvases (PixelLab 32, SpriteCook 16, RD Pro 12), and its states and frames must share every pixel but the part that changes. Fits better than Grok.

### GB-tower-4: town.prop.hall.cradle

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle_grid.png (grid, foot row)
Sheet: 24x28, one 12x14 cell per frame, frames left to right; one row per state, top to bottom: loaded (2 frames), empty (2 frames)
Size:  exactly 12x14 world px (aspect 6:7), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch only: top; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: placed by its top-left corner
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (loaded): a cradle riding a wayline: a brass trolley wheel on the cable (its middle is the hang point), a twine sling and an oilcloth parcel (none when empty). The sling sways 1 px over 2 frames. No outer outline (the game rims it). wayline_tower palette. This image: the loaded still, the cradle carrying an oilcloth parcel. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw_loaded.png "a cradle riding a wayline: a brass trolley wheel on the cable (its middle is the hang point), a twine sling and an oilcloth parcel (none when empty). The sling sways 1 px over 2 frames. No outer outline (the game rims it). wayline_tower palette. This image: the loaded still, the cradle carrying an oilcloth parcel. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Make (empty): a cradle riding a wayline: a brass trolley wheel on the cable (its middle is the hang point), a twine sling and an oilcloth parcel (none when empty). The sling sways 1 px over 2 frames. No outer outline (the game rims it). wayline_tower palette. This image: the empty still, the same object carrying nothing. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.cradle_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw_empty.png "a cradle riding a wayline: a brass trolley wheel on the cable (its middle is the hang point), a twine sling and an oilcloth parcel (none when empty). The sling sways 1 px over 2 frames. No outer outline (the game rims it). wayline_tower palette. This image: the empty still, the same object carrying nothing. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 3:4
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw_loaded.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw_empty.png --frames 2,2
Frames: loaded 2, empty 2 frames. Grok makes one still per state and --frames copies it into each frame cell; then make the frames differ by hand in prepared.png as the brief says (PixelLab pixelart_workbench, free, exact pixels) and validate again. Identical frames are an allowed first pass.
Then:  python tools/art/prepare_slot.py town.prop.hall.cradle docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/prepared.png
       python tools/art/validate_slot.py town.prop.hall.cradle docs/art/slot-candidates/gb-08-tower/town.prop.hall.cradle/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): 12x14 is at or under the generators' smallest canvases (PixelLab 32, SpriteCook 16, RD Pro 12), and its states and frames must share every pixel but the part that changes. Fits better than Grok.

### GB-tower-5: town.prop.hall.parcel

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel_grid.png (grid, foot row)
Sheet: 10x16, one 10x8 row per state, top to bottom: oilcloth, paper
Size:  exactly 10x8 world px (aspect 5:4), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/wayline_tower.png` (locked: only these colours); light from the upper left
Edges: may touch every canvas side; alpha 0 or 255 only (no soft edges); no outer outline (the game's finish shader draws the rim); inner detail lines in #0b0e11 only
Place: foot row y=7: the art's lowest opaque row sits on it, centred on x=5
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make (oilcloth): a parcel sliding down the tower's chute: oilcloth with a moss-green top, or brown paper, tied with twine. No outer outline (the game rims it). wayline_tower palette. This image: the oilcloth still, a parcel in oilcloth with a moss-green top, tied with twine. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw_oilcloth.png "a parcel sliding down the tower's chute: oilcloth with a moss-green top, or brown paper, tied with twine. No outer outline (the game rims it). wayline_tower palette. This image: the oilcloth still, a parcel in oilcloth with a moss-green top, tied with twine. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 4:3
Make (paper): a parcel sliding down the tower's chute: oilcloth with a moss-green top, or brown paper, tied with twine. No outer outline (the game rims it). wayline_tower palette. This image: the paper still, the same parcel in brown paper, tied with twine. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.hall.parcel_card.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw_paper.png "a parcel sliding down the tower's chute: oilcloth with a moss-green top, or brown paper, tied with twine. No outer outline (the game rims it). wayline_tower palette. This image: the paper still, the same parcel in brown paper, tied with twine. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 4:3
Stack: python tools/art/write_art_tasks.py --stack docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw_oilcloth.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw_paper.png
Then:  python tools/art/prepare_slot.py town.prop.hall.parcel docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/raw.png docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/prepared.png
       python tools/art/validate_slot.py town.prop.hall.parcel docs/art/slot-candidates/gb-08-tower/town.prop.hall.parcel/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab pixelart_workbench (free, exact pixels by hand): 10x8 is at or under the generators' smallest canvases (PixelLab 32, SpriteCook 16, RD Pro 12), and its states and frames must share every pixel but the part that changes. Fits better than Grok.

Review: `python tools/art/review_sheet.py gb-08-tower`, then Preston's yes per slot. Install per slot: `python tools/art/install_slot.py <slot_id> docs/art/slot-candidates/gb-08-tower/<slot_id>/prepared.png --batch gb-08-tower`. A part shows only with Highbank v2 on and in the debug lineup, and only at its exact sheet size, so parts can land one at a time while the coded blockout stands in for the rest. Then `python tools/debug/run_checks.py tower_parts town_props hub_town art_slots --jobs 1` with HT_HIGHBANK_V2=1 set, and once more without it (v1 must not change).

## gb-09-forest: The Great Tree Path: one forest trunk (1 slot, 1 image)

### GB-forest-1: town.prop.forest_trunk

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.forest_trunk_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.forest_trunk.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.forest_trunk.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.forest_trunk_grid.png (grid, foot row)
Size:  exactly 48x96 world px (aspect 1:2), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=95: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  one trunk of the old forest round the great tree, on the Great Tree Path: thick dark bark with deep furrows, moss on its lit left side, a foot of flared roots gripping the ground two tiles wide, and the dark underside of the canopy closing over the top of the sheet. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.forest_trunk_card.png docs/art/slot-candidates/gb-09-forest/town.prop.forest_trunk/raw.png "one trunk of the old forest round the great tree, on the Great Tree Path: thick dark bark with deep furrows, moss on its lit left side, a foot of flared roots gripping the ground two tiles wide, and the dark underside of the canopy closing over the top of the sheet. No ground shadow. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:2
Then:  python tools/art/prepare_slot.py town.prop.forest_trunk docs/art/slot-candidates/gb-09-forest/town.prop.forest_trunk/raw.png docs/art/slot-candidates/gb-09-forest/town.prop.forest_trunk/prepared.png
       python tools/art/validate_slot.py town.prop.forest_trunk docs/art/slot-candidates/gb-09-forest/town.prop.forest_trunk/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 48x96 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 48x96.

Review: `python tools/art/review_sheet.py gb-09-forest`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_props hub_town art_slots --jobs 1`.

## gb-10-dooryards: Dooryards: what lies in front of a building (3 slots, 3 images)

Preston, 2026-10-28: wire the whole map, the area around the buildings too. Each building gets a dooryard (docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md), the Item Shop's first: its stock on goods tables, crates against its walls, rocks closing the yard. Seen from above like the town. Check with HT_HIGHBANK_V2=1 set.

### GB-dooryards-1: town.prop.goods_table

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.goods_table_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.goods_table.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.goods_table.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.goods_table_grid.png (grid, foot row)
Size:  exactly 48x40 world px (aspect 6:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=39: the art's lowest opaque row sits on it, centred on x=24
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  a trestle table of the Item Shop's stock, two tiles wide, seen from above so its top shows deep: a basket of red berries, three jars of lamp oil, a heap of pale stones. Legs to the ground, lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.goods_table_card.png docs/art/slot-candidates/gb-10-dooryards/town.prop.goods_table/raw.png "a trestle table of the Item Shop's stock, two tiles wide, seen from above so its top shows deep: a basket of red berries, three jars of lamp oil, a heap of pale stones. Legs to the ground, lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 4:3
Then:  python tools/art/prepare_slot.py town.prop.goods_table docs/art/slot-candidates/gb-10-dooryards/town.prop.goods_table/raw.png docs/art/slot-candidates/gb-10-dooryards/town.prop.goods_table/prepared.png
       python tools/art/validate_slot.py town.prop.goods_table docs/art/slot-candidates/gb-10-dooryards/town.prop.goods_table/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 48x40 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 48x40.

### GB-dooryards-2: town.prop.crate_stack

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.crate_stack_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.crate_stack.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.crate_stack.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.crate_stack_grid.png (grid, foot row)
Size:  exactly 24x40 world px (aspect 3:5), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=39: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  Two wooden crates stacked against a wall with a tied sack on top, one tile, the top crate set back so the stack reads from above. Lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.crate_stack_card.png docs/art/slot-candidates/gb-10-dooryards/town.prop.crate_stack/raw.png "Two wooden crates stacked against a wall with a tied sack on top, one tile, the top crate set back so the stack reads from above. Lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 9:16
Then:  python tools/art/prepare_slot.py town.prop.crate_stack docs/art/slot-candidates/gb-10-dooryards/town.prop.crate_stack/raw.png docs/art/slot-candidates/gb-10-dooryards/town.prop.crate_stack/prepared.png
       python tools/art/validate_slot.py town.prop.crate_stack docs/art/slot-candidates/gb-10-dooryards/town.prop.crate_stack/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x40 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x40.

### GB-dooryards-3: town.prop.rock_cluster

```
Card:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.rock_cluster_card.png
Spec:  docs/design/placeholder-factory-2026-10-26/refs/town.prop.rock_cluster.json
Ref:   docs/design/placeholder-factory-2026-10-26/refs/town.prop.rock_cluster.png (target), docs/design/placeholder-factory-2026-10-26/refs/town.prop.rock_cluster_grid.png (grid, foot row)
Size:  exactly 24x24 world px (aspect 1:1), drawn at 3x; colours <= 24 from `docs/design/placeholder-factory-2026-10-26/refs/palettes/town_timber.png`; light from the upper left
Edges: may touch only: bottom; alpha 0 or 255 only (no soft edges); a 1 px outline in the object's own darkest tone
Place: foot row y=23: the art's lowest opaque row sits on it, centred on x=12
Never: text, creature, franchise (no letters or numbers anywhere; nothing that reads as another game)
Make:  Three rocks in a cluster, one big and two small, closing the end of a dooryard: weathered river stone, moss in the cracks of the big one. Lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere.
Run:   python tools/grok_image.py make docs/design/placeholder-factory-2026-10-26/refs/town.prop.rock_cluster_card.png docs/art/slot-candidates/gb-10-dooryards/town.prop.rock_cluster/raw.png "Three rocks in a cluster, one big and two small, closing the end of a dooryard: weathered river stone, moss in the cracks of the big one. Lit from the upper left, 1 px dark outline. One object only, filling the box, in the game's three-quarter top-down view, on a flat pure magenta (#FF00FF) background. No creatures, animals or people. No text, words or letters anywhere." --aspect 1:1
Then:  python tools/art/prepare_slot.py town.prop.rock_cluster docs/art/slot-candidates/gb-10-dooryards/town.prop.rock_cluster/raw.png docs/art/slot-candidates/gb-10-dooryards/town.prop.rock_cluster/prepared.png
       python tools/art/validate_slot.py town.prop.rock_cluster docs/art/slot-candidates/gb-10-dooryards/town.prop.rock_cluster/prepared.png
Report: the check line, Grok's one-sentence reply, the cost.
```

Alt: PixelLab create_map_object (basic, 32x32 canvas, view high top-down, single colour outline), then prepare_slot box-downscales to 24x24.

Review: `python tools/art/review_sheet.py gb-10-dooryards`, then Preston's yes per slot, then install and `python tools/debug/run_checks.py town_props hub_town art_slots --jobs 1`.

## Not verified

- No generator was run for this list: the balances are read-only calls, and no route's per-call cost was measured except Retro Diffusion's free estimate ($0.18 for one 48x56 RD Pro prop).
- The Alt routes come from each tool's own description, not from a test in this project.
- The in-game capture column of the review sheet needs a capture made with the candidate swapped in; review_sheet.py shows where it is missing.
- The Wayline Tower's references (the assembled blockout, each part's band, the exact palette strips) come from the coded blockout. No painted part has been seen against its neighbours or under the game's rim yet, and nothing checks a seam between two painted parts except Preston's eye in review.
