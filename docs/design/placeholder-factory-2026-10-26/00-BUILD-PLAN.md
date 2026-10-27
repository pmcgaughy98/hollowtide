# Placeholder factory: the build plan (Claude, 2026-10-26)

This plan covers the build phase after factory pass 8 lands. It turns parts 01 to 03 into lanes that never share a file. Every slot is in `slot-registry-draft.md`, and the counts there were computed by a script.

**The short version.** A contract goes first (registry, loader, placeholder painter, renderer, validator, cross-lane stubs). Six Claude lanes then run in parallel: town areas (A), buildings (B), ground and props (C), rooms (R), dungeon marks (D), UI, menus and story (U). A task-list lane writes the Codex and Grok lists; an integrator runs the gate. 151 slots: 75 new (Codex 31, Grok 26, Claude 18) and 76 finished Codex files kept. Highbank v2 sits behind a switch that stays off until Preston walks it; off, the town is pixel-identical to today. Full run 9 agents, about 3.2M tokens; lean run 5, about 2.2M.

## 0. Rules for every lane

The pass 1 to 8 rules apply:
- Edit only your own files. Make no git writes; the integrator commits only if Preston asks.
- Make no paid generation calls. Use no em-dashes.
- Leave these alone: creatures, Route 1, Grok's numbers, and Codex's launch files (`creature_opening.gd`, `opening_flow.gd`, `main_menu.gd`, `storm_open.gd`, `soul_prologue.gd`).
- New names are working labels.
- The Wayline Hall is now the Wayline Tower (Preston, 2026-10-26). Player-facing text says Tower; place and room ids (`hall`, `hall_low`), story flags, file and scene names keep `hall`. The area label Hall Rise is now Tower Rise.
- Parse-check with `--check-only`, then run `python tools/debug/run_checks.py <gate words> --jobs 1 --logs <temp>`.

Pass 8 owns many of these files (hub_town, town_layout, the Highbank painters, town_room, ui_style, party_screen, dungeon), so nothing starts until it lands, and the integrator first re-measures the line numbers below (taken at `dc37005af`).

## 1. The contract (one agent, lands first, then frozen)

**Registry.** `scripts/art/art_slots.gd` (`class_name ArtSlots`) is the loader. Rows live in seven `const SLOTS := {...}` files under `scripts/art/slots/`: `title`, `story`, `ui` (U), `town_buildings` (B), `town_street` (C), `town_rooms` (R), `dungeon` (D). GDScript, not JSON, because it is parse-checked, holds `Rect2i` and `Vector2i` directly, and exports with no filter rule. Seven files, so six lanes add slots at once. Python reads `slots.json`, stamped with the registry's SHA-256; a stale copy is refused. The contract writes all 76 keep rows (`legacy` = today's path) and fixes all 75 new ids, so a lane can place a slot before its owner draws it.

**Loader.**

```gdscript
class_name ArtSlots
static func spec(id: String) -> Dictionary
static func ids(owner := "", status := "") -> PackedStringArray
static func sheet_size(id: String) -> Vector2i      # size.x * max frames, size.y * state rows
static func texture(id: String) -> Texture2D         # cached for the session
static func image(id: String) -> Image
static func frame(id: String, state := "", i := 0) -> Texture2D
static func source(id: String) -> String             # "file", "legacy" or "placeholder"
static func forcing() -> bool                        # HT_FORCE_PLACEHOLDERS=1 or the debug toggle
static func registry_hash() -> String
```

`texture()` returns the first of these that applies:
1. The placeholder, if `forcing()` is on.
2. The slot's own file under `res://assets/slots/<area>/<kind>/`, if it is exactly `sheet_size`.
3. The `legacy` file, if it is its declared size.
4. The placeholder.

A wrong-size file prints one warning (except `legacy_misfit`: v1 buildings under v2). Nothing draws over real art. `install_slot.py` runs `godot --headless --import` after copying.

**Placeholder renderer.** `scripts/art/placeholder_painter.gd` (`class_name PlaceholderPainter`):

```gdscript
static func paint(id: String, spec: Dictionary) -> Image  # spec.placeholder "res://x.gd:method", else by kind
static func block(img: Image, r: Rect2i, base: Color) -> void   # lit top-left, shaded bottom-right, ink edge
static func shadow(img: Image, foot: Rect2i) -> void
static func bands(img: Image, ramp: Array[Color], rows: int) -> void
static func ramp(base: Color) -> Array[Color]
```

It uses the house constants already in building_exteriors and ui_style (ink `#0b0e11`, wood `#80694a`, stone `#8f805e`, lantern `#f2c14e`). Every painter returns exactly `sheet_size`.

**Cross-lane stubs.** The contract writes each signature. The owning lane writes the body.

| Call | Owner |
|---|---|
| `TownLayout.v2()`, `area_id()`, `area(id)`, `area_of(place_id)`, `anchor(name, area)` (stubs return today's consts) | A |
| `town.enter_area(id: String, at: String)` | A |
| `AreaSchema.validate(area) -> PackedStringArray` (fields from 02 sections 3.2-3.3) | contract |
| `BuildingTemplate.canvas()`, `door_px()`, `paint_slot(id, spec) -> Image`, `place(b, parent)` | B |
| `highbank_painter.gd paint_area(area) -> Image` (stub wraps today's painter), `TownProps.build(area, parent)` | C |
| `UI.focus_row(ci, r)`, `UI.headshot_well(ci, r)`, `UI.banner(ci, r)` (stubs draw today's flat rects) | U |

**Tools.**

```
godot --headless --path . --script res://tools/art/render_slot_refs.gd -- [--id <slot>] [--area <a>] [--owner codex|grok]
python tools/art/prepare_slot.py <slot_id> <raw.png> <out.png>
python tools/art/validate_slot.py <slot_id> <candidate.png>
python tools/art/install_slot.py <slot_id> <candidate.png> --batch <batch_id>
```

As 03 sections 2.3 and 3.3-3.5: the renderer writes the target, a grid image (tiles, foot row, door box, pass creature as a grey block), Grok's text-free card, the spec JSON and palettes into `refs/`; the validator runs C1-C13 (exit 0 = pass); the installer refuses on a `CODEX_IN_PROGRESS` lock, a failed check, or no yes in `review.json`.

**Contract gate:** `art_slots_check` passes with all 76 keep rows on legacy, and the full gate is unchanged.

## 2. Town rewire lanes

### 2.1 Lane A: town areas

**Owns:** `town_layout.gd`, `hub_town.gd`, `scripts/world/areas/` (index, highbank_v1, street, hall_rise, ferry_ward, east_quarter), `scenes/debug/highbank_v2.tscn`, a new `area_data_check.gd`, and the checks in the table below except the last two.

**Order:**
1. **Today's map, tile for tile.** It goes into `highbank_v1.gd`. `PLACES`, `door_tiles()`, `place_at()` and `grid()` keep their signatures. Every check must pass unchanged before step 2.
2. **v2** (02 section 6). Highbank Street 56x16, Tower Rise 26x14 and Old Ferry Ward 34x16, joined by exits that use the room fade.
   - `RETURN_SPOT` becomes the `return` anchor at Tower Rise (12,9).
   - `SPAWN` becomes the street's `spawn` anchor at (5,7).
   - Music, the cached picture and the camera clamp go per area.
   - `SOFT_TILES` becomes a ground rect.
3. **The switch.** `TownLayout.v2()` is true when `HT_HIGHBANK_V2=1` is set or the const `HIGHBANK_V2` is true (it starts false). `run_checks.py:213` copies `os.environ`, so the gate runs both ways without editing a file. Preston walks v2 by opening `scenes/debug/highbank_v2.tscn` and pressing F6.
4. **Lots.** Lot A (stall) and lot B (plot) sit on the street in their `before` state. The open-on-flag code is in, but no beat opens a lot yet.
5. **First expansion area: East Quarter** (working label), 30x14 behind the road east: lots C (shop), D (stall), E (plot), lamps, fences; no services, townsfolk or story. Its exit needs a flag nothing sets, so only the debug scene and checks reach it.

**Saves.** Saves are safe: no town tile is saved, and an old `arrive_at` place id resolves through `area_of`.

**Story beats.** The board scene and theft play on Tower Rise relative to the board door (`board_scene.gd:51-56` unchanged); the stone installs at the shrine's `socket`; Storage opens after Rootbank Warren; runs end at `return` and start from the Ferry Ward's Mouth; area changes are a 0.2 s fade with no card.

**Checks that read town positions** (found by grep). Each anchor gets the same tile in `highbank_v1.gd`, so every rewritten check still passes with v2 off.

| Check (lines) | Needs |
|---|---|
| hub_town :13 FERRY (28,27), :108 (32,28), :38-63 grid and size | `ferry_landing`, `mouth_approach`, the area's grid, `enter_area` |
| town_walk :78-79 walks from (24,9) and (5,9), :105 (41,12), :112 (41,11) | `lane_walk`, `home_walk`, `yard_gate`, `yard_gate_front` |
| town_loop :86, :116 (32,28), :111 RETURN_SPOT | `mouth_approach`, `return` |
| music :96 (24,9), :101 (26,27) | `music_street`, `music_ferry` |
| board_scene :48-49 board door + (0,6), (0,7) | `board_start`: on Tower Rise, door (16,10) + (0,6) is row 16 of 14 |
| storage :47, job_board :40, pad_play :113 :158 :174, stone :54, evolution :51, way_down :35, dungeon_sfx :203, ui_fit :172 :335, pilot_chain :168 :302 :349, all by place id | `enter_area(area_of(id), id)` first |
| tools town_view_capture :24, ui_tour_capture :46 | `view_street`, `view_terrace`, `view_landing` |
| hall_door :8-14 (lane B) | same API; Tower doors at (12,8), (13,8) |
| town_room :167, :202, :210 (lane R) | `area_of` for `arrive_at`; room tiles unchanged |

Room tiles in `pilot_chain_check` and `save_check` stay valid. `area_data_check` runs 02 section 7.3: two-way exits, every door and exit reachable, a walkable tile before each door, no prop on a door approach, anchors walkable, all 13 place ids present once.

**Gate**, run with v2 off and then on: hub_town, town, music, board_scene, storage, job_board, pad_play, stone, evolution, way_down, dungeon_sfx, story_gate, ui_fit, area_data, pilot.

### 2.2 Lane B: building template and exteriors

**Owns:**
- the new `building_template.gd`
- `building_exteriors.gd`
- the nine place painters (home, item_shop, storage, landmark_exteriors, crossroads, job_board, training_yard, growth_shrine, hollow_mouth)
- `slots/town_buildings.gd`
- `scenes/debug/building_lineup.tscn`
- `hall_door_check.gd` and a new `building_template_check.gd`

**Builds:**
1. **The template** (02 section 4): cottage 132x144, shop 156x144, stall 108x120, Tower 300x576 (canon 2026-10-26, as in `slots/town_buildings.gd`; was Hall 300x192); single door 22x48 (clears Sparkjab, 45 px), double door 46x64 (clears Galeshear, 62 px); `BUILDING_SCALE` 1.0; doors from `door_px`, no flood fill.
2. **The lineup scene, first:** each class from data beside Codex's current PNG, a stage 1, 2 and 3 creature at the door, at 1.0 and 1.25. The first thing Preston can press play on.
3. In v2 every building draws through `ArtSlots.texture("town.building.<id>")`; v1 keeps the rect x 24 rule (`:39`) and does not change.
4. 5 signs and 3 shut overlays become slots, today's code as placeholders. Open-air places read rects from the area and art from the keep rows. Lots get their `before` states (stall, shopfront, plot).

16 new slots, 8 keep. **Gate:** hall_door, hub_town, building_template, art_slots, story_gate, timing.

### 2.3 Lane C: ground and street props

**Owns:** the five ground painters (highbank_painter, highbank_ground_painter, world_tile_art, town_detail_art, world_finish), a new `town_props.gd`, `placeholders/street_props.gd`, `town_props_check.gd`, and `slots/town_street.gd`.

**Builds:**
- `paint_area(area)` paints any outdoor area in today's coded style. There is no ground slot.
- `TownProps` draws the lamp post (its glow stays in code) and 11 props.
- The waymark keeps its coded post as its placeholder.

12 new slots, 6 keep. **Gate:** hub_town, town, town_props, art_slots, timing. Paint time per screen must stay within 10% of today's.

## 3. Placeholder lanes

**How placeholders look:** flat shapes at the exact slot size in house colours, lit upper left, with a contact shadow and a 1 px ink edge. Buildings use the template's layers, props stacked blocks, lamps a post and lantern box, room strips `room_painter.gd`'s blocks, backdrops three to five bands. Slot ids show only in the reference render and the `forcing()` overlay, never in play. Claude's own slots are final pixel art.

| Lane | Owns | Wires | Gate |
|---|---|---|---|
| **R rooms** | town_room, room_painter, hall_floors_art, hall_fixtures_art, hall_room_art, home_room_art, storage_room_art, `slots/town_rooms.gd`, town_room_check | **53 keep**, including the 4 unused Tower PNGs (stairs 48x48 x2, side door 18x52, kitchen 24x48).<br>**4 distorted props** get slots at their drawn size: chamber rug 216x120, wide window 96x32, runners' window 36x32 and map 48x28. Today's resize is their placeholder, so nothing changes on screen.<br>**New shop (14x10) and cellar (12x9)**: 10 Codex strips and 4 Grok furniture pieces. Their doors stay shut. | town_room, hall_door, hall_floors, storage, guild_scene, art_slots, timing, pilot |
| **D dungeon marks** | dungeon.gd, `slots/dungeon.gd`, `placeholders/dungeon_marks.gd` | **Sealed stairs** (Grok, 24x24): a slate slab with a teal seal replaces the red X (:4859).<br>**Sleep mark** (Claude): a hand-placed 7x8 pixel z, 3 frames, replaces the font letter (:5077).<br>**12 essence shots** (Claude, 6x6, 3 frames) replace the dot (:5086).<br>**Calls switch** to `UI.focus_row` (:5476, :5504), `UI.headshot_well` (:5359) and `UI.banner` (:5328). | dungeon_check, dungeon_boss, dungeon_trap, dungeon_vfx, dungeon_run, warden_yield, art_slots, ui_fit, timing |
| **U UI, menus, story** | ui_style, `tools/ui/build_frames.py` and its PNGs, party_screen, mouth_escape, waking_bank, riverbank_journey, hollow_approach, `slots/ui.gd`, `story.gd`, `title.gd` | **9-slice frames** for the bar well and fill, focus row, headshot well and banner.<br>**TEAM-page stages**: 6 keep (GALE now points at a real file), plus 6 Codex 448x252 for blight, hollow, ice, loam, murk and sinew. `party_screen.gd:36-38` maps only 6 of the 12 essences.<br>**Dawn bank** (Codex): today's shader grade is its placeholder.<br>**Waking bank and Hollow entrance** are registered, with their code fallbacks as placeholders.<br>**Title rows** are registered only; Codex wires them. | ui_fit, field_menu, rebind, evolution, mouth_escape, flood_talk, hollow_approach, storm_open, art_slots |

Effects stay coded and Claude's.

## 4. The task-list lane

**Owns:** `tools/art/write_art_tasks.py`, `review_sheet.py`, `docs/team/CODEX_ART_TASKS_<date>.md`, `GROK_ART_TASKS_<date>.md`, and the generated `refs/` and `slots.json`.

It writes its tools while the lanes work; once they land, it renders the 57 Codex and Grok references and runs `write_art_tasks.py --date <date>`. Each task is a 03 block (4.3 Grok, 4.4 Codex) with its spec path, target, grid and card images, size, colour budget, edges, door box and pass creature. Fixes go into the registry and the lists are rewritten.

**Codex: 8 batches, 31 slots.**
- Buildings: 5
- Lots: 3
- Shop room: 5
- Cellar: 5
- Room fixes: 4
- Title: 1, plus wiring `opening_flow.gd:21`, `creature_opening.gd:39` and `main_menu.gd:366`
- Story: 2, plus wiring `soul_prologue.gd:267`
- Stages: 6

**Grok: 6 batches, 26 slots, 27 images** (the lamp has two states).
- Street 1: lamp, well, waymark, bench, crates, barrel, planter, mooring post (8)
- Street 2: three fences and the road barrier (4)
- Building parts: 5 signs and 3 shut overlays (8)
- Furniture: 4
- Menu cursor: 1
- Sealed stairs: 1

## 5. Gates and checks

**`art_slots_check`**, per slot: unique well-formed id, known owner and kind; complete spec (anchor in the cell, door box in the wall); doors clear `pass_creature` measured from `town/s.png` at check time (C11); palette within budget; `forbid` holds text, creature, franchise; placeholder exactly `sheet_size`, binary alpha, nothing on forbidden edges (C1, C3, C4); an unshared file under `res://assets/slots/`; legacy present at its size; installed hashes match; nothing in a creature folder. It prints "installed X of Y" by area and owner, plus the hard-coded art paths left in `scripts/` (114 at the start). At landing it should show 151 slots: 75 on placeholder and 76 on legacy.

**Lane checks.**
- `area_data_check` (A).
- `building_template_check` (B): canvases, doors and anchors per class; v1 still drawn at rect x 24.
- `town_props_check` (C): every prop resolves, nothing sits on a door approach, lamps have both states.

**Integrator.** The pass 7 baseline was 113 rows: PASS 99, WINDOW 6, RAN 4, RETIRED 3, SKIPPED 1. Re-baseline after pass 8, then run:
1. `python tools/debug/run_checks.py --long --arena`: 0 FAIL with v1, the default.
2. `HT_HIGHBANK_V2=1 python tools/debug/run_checks.py hub_town town music board storage job_board pad_play stone evolution way_down dungeon_sfx story_gate ui_fit area_data art_slots pilot --long`: 0 FAIL.
3. `HT_FORCE_PLACEHOLDERS=1 python tools/debug/run_checks.py ui_fit art_slots hub_town town_room`: 0 FAIL.

Expect four new PASS rows. If run 2 fails, v2 stays off and the failures are listed.

**Review before install** (03 section 4.5): one sheet per batch; Preston answers yes, redo or keep placeholder; nothing installs without his yes.

## 6. What stays exactly as it is

- **Creatures:** every set, the 109 dialogue faces, the idles, the village actors, the crew, the clients, and the Shortcut Crew.
- **Painted dungeon terrain** (G01-G03, G06, G07, G10, G12), with `USE_TILE_ART` still false. Codex's tile sheets (G04) and atlas (G05) stay on disk, unregistered.
- **Town ground** stays code-painted (H02, H03, H05, H07-H09).
- **75 of the 80 finished census visuals.**
  - Title, story and town: T04, T09, T11-T14, S01, P06, P07, D02, D04-D07, E04, H04, H06, B06, B07, B09, B10, B12-B15, U02-U10.
  - Rooms: M01, M03-M05, M07, M08, M10, M11, M13, M15, M18.
  - Dungeon and HUD: G09, G11, A11, X01, X03-X05, X07, X08, X10-X13.
  - Effects, menus and kit: V01, Z01, Z03, Z04, Q01-Q04, Q06-Q08, K01-K04, K08-K10.

  The K items, V01 and G11 are not even registered this phase.
- **The planned exception: B01-B05, the building PNGs.** Their v2 canvases change, so v2 shows placeholders until Codex repaints; v1 still shows them, and they stay on disk.
- **Code that reads finished:** all 65 code rows, except the flat UI pieces (K05-K07, X14) and the marks (G08, X17, V03).
- Codex's launch files, Route 1, Grok's numbers, the 97 courier-era paths.

## 7. Preston's design calls (the default stands if he does not answer)

| # | Call | Default |
|---|---|---|
| 1 | Building scale | 1.0 after walking the lineup; 1.25 resizes every canvas before the lists go out |
| 2 | Town shape | Three areas behind the switch, off until he walks v2 (else one map, buildings resized) |
| 3 | Home | On the street |
| 4 | Scroll Keeper | A south door down to a cellar room |
| 5 | Shut shop and cellar | Placeholder rooms; the doors stay shut, and so does the Yard |
| 6 | East Quarter | Empty and closed; only the debug scene reaches it |
| 7 | Tower Rise well | A prop only, with no party switch |
| 8 | Existing art | Keep all 75. Wire the 4 unused Tower PNGs. The title stays at 4.5x. GALE uses take1 |
| 9 | Review | Nothing installs without his yes |
| 10 | Grok "character sprites" | Non-creature only, none this phase; job-gear overlays need his yes |
| 11 | UI frames | Stay Claude's hand-placed 9-slices |
| 12 | Colour budgets | Building 32, room 48, backdrop 48, prop and lamp 24, HUD 16, icon 8, frame 16 |
| 13 | Ground and terrain | Both stay painted in code |
| 14 | Names | Working labels |
| 15 | Grok spend | 27 images x $0.06-0.13 = $1.62-3.51, asked before running |

## 8. Agents and cost

| Plan | Agents | Tokens |
|---|---|---|
| Full | 9: contract, A, B, C, R, D, U, task list, integrator | 9 x 350k = 3.15M (range 2.7M-3.6M) |
| Lean | 5: contract, A+C, B+R, D+U, integrator also writing the lists | 350k + 3 x 500k + 350k = 2.2M (2.0M-2.5M); bigger contexts, longer wall time |

## Not verified

- Pass 8's plan appeared mid-writing; its lane table was read, not its results.
- `PLACES` as a static var against the 20 scripts that preload town_layout is untested; the contract tests it first.
- Tower Rise offsets come from 02's map. New slot sizes are proposals; kept sizes were read from file headers. Nothing was run.
