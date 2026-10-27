# Slot registry draft (2026-10-26)

Every census visual from `01-asset-census.md`, plus the new slots the town rewire adds, in the spec format of `03-spec-format.md`. Generated from one data list by a script (`slot_draft.py` in the session scratchpad), so the counts below are computed. Read-only draft: nothing here is in the game yet. Slot ids follow `<area>.<kind>.<name>`; names may hold a dot for a room (`town.room.shop.floor`). Sizes are file pixels; Scale is file pixel to screen pixel.

**Status key.** placeholder: a new slot, drawn by a coded placeholder until a generator's art installs. keep: a finished file, registered with its current path as `legacy`, so the loader serves it and art_slots_check covers it. as_is: a finished file left exactly where it is, not registered this phase. code: stays GDScript, not a slot. uses: draws through another slot. dormant: fallback code that does not show today.

## Counts

| Owner | Placeholder slots (generator or Claude work) | Keep slots (registered, finished) | Total registered |
|---|---|---|---|
| codex | 31 | 76 | 107 |
| grok | 26 | 0 | 26 |
| claude | 18 | 0 | 18 |
| **all** | **75** | **76** | **151** |

Census reconciliation (176 visuals, each counted once by its statuses): as_is 11; code 65; dormant 5; keep 25; keep + placeholder 3; placeholder 24; uses 43.

By lane (placeholder / keep): B 16 / 8; C 12 / 6; R 18 / 53; D 14 / 0; U 12 / 8; codex-wire 3 / 1. Lanes as in `00-BUILD-PLAN.md`; codex-wire means the row is registered by lane U but its call site is in a Codex-owned launch file.

Palette column: `family/max colours`. Families are swatch strips the reference renderer cuts into `res://assets/slots/palettes/<family>.png`: town_stone, town_timber, lantern, brass_ui, night_bank, dawn, ruin, room_<id>, stage_<essence>, essence colour. Budgets are 03-spec-format.md 2.2's proposals (Preston call 12).

## T. Title and launch (Codex owns these files; rows are registered, Codex wires its own call sites)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| T01 | Launch card backdrop | title.backdrop.launch | codex | placeholder | res://assets/slots/title/backdrop/launch.png | 384x216 | 3 | top-left (0,0) | static | night_bank/48 | today a flat #161f1b fill (opening_flow.gd:21); placeholder: that fill in 3 stepped bands |
| T02 | Launch wordmark | - | - | code | - | - | - | - | - | - | reuses T08 |
| T03 | Launch captions | - | - | code | - | - | - | - | - | - | text |
| T04 | Village painting | title.backdrop.village | codex | keep | res://assets/sprites/menu/creature_village_2026_10_09.png | 256x144 | 4.5 | top-left (0,0) | static | as installed | not a whole scale (Preston call 8) |
| T05 | Canopy shade | - | - | code | - | - | - | - | - | - | flat band; left to Codex's title pass |
| T06 | Legibility wash | - | - | code | - | - | - | - | - | - |  |
| T07 | Fireflies | - | - | code | - | - | - | - | - | - |  |
| T08 | Wordmark | - | - | code | - | - | - | - | - | - | Codex's uncommitted logo pass pending |
| T09 | Main menu buttons | - | - | uses | - | - | - | - | - | - | K01 |
| T10 | Menu cursor | title.hud_piece.menu_cursor | grok | placeholder | res://assets/slots/title/hud_piece/menu_cursor.png | 8x9 | 3 | (0,4) left middle | static (bounce coded) | brass_ui/16 | Polygon2D today (main_menu.gd:366) |
| T11 | How to play panel | - | - | uses | - | - | - | - | - | - | K01 |
| T12 | Options page | - | - | uses | - | - | - | - | - | - | K01, Q07 |
| T13 | New Game confirmation | - | - | uses | - | - | - | - | - | - | K01 |
| T14 | Quit confirmation | - | - | uses | - | - | - | - | - | - | K01 |
| T15 | Title fade | - | - | code | - | - | - | - | - | - |  |

## S. Storm cold open

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| S01 | Waking riverbank painting | story.backdrop.waking_bank | codex | keep | res://assets/sprites/world/waking_bank_2026_10_10/waking_native.png | 384x216 | 3 | top-left (0,0) | graded by shader | as installed | code fallback ui/waking_bank.gd:75 becomes its placeholder |
| S02 | River cover | - | - | code | - | - | - | - | - | - |  |
| S03 | Rain and splashes | - | - | code | - | - | - | - | - | - |  |
| S04 | Lightning, grey drain | - | - | code | - | - | - | - | - | - |  |
| S05 | The soul falling | - | - | code | - | - | - | - | - | - |  |
| S06 | White-out | - | - | code | - | - | - | - | - | - |  |

## P. Soul prologue (soul_prologue.gd is in Codex's launch flow)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| P01 | The void | - | - | code | - | - | - | - | - | - |  |
| P02 | Drifting motes | - | - | code | - | - | - | - | - | - |  |
| P03 | Presence light | - | - | code | - | - | - | - | - | - |  |
| P04 | River far below | story.backdrop.river_below | codex | placeholder | res://assets/slots/story/backdrop/river_below.png | 384x40 | 3 | top-left (0,176) | static (shimmer coded) | night_bank/48 | 2x1 dashes today (soul_prologue.gd:267); tiling h |
| P05 | The soul | - | - | code | - | - | - | - | - | - | Preston call 10 |
| P06 | Starter cards | - | - | uses | - | - | - | - | - | - | K01 |
| P07 | Voice line box | - | - | uses | - | - | - | - | - | - | K01, K02, K04 |

## D. Waking riverbank

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| D01 | Ruin rising | - | - | code | - | - | - | - | - | - |  |
| D02 | Hollow entrance close-up | story.backdrop.hollow_entrance | codex | keep | res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png | 384x216 | 3 | top-left (0,0) | static | as installed | E05 stand-in becomes its placeholder |
| D03 | Place card | - | - | code | - | - | - | - | - | - |  |
| D04 | Key strip | - | - | uses | - | - | - | - | - | - | K01 |
| D05 | Dialogue box | - | - | uses | - | - | - | - | - | - | K01-K04; face backgrounds code |
| D06 | Answer list | - | - | uses | - | - | - | - | - | - | K01 |
| D07 | Back to title prompt | - | - | uses | - | - | - | - | - | - | K01 |
| D08 | Ground shadows | - | - | code | - | - | - | - | - | - |  |
| D09 | Scene fades | - | - | code | - | - | - | - | - | - |  |

## E. Hollow approach

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E01 | Node glow | - | - | code | - | - | - | - | - | - |  |
| E02 | Light column | - | - | code | - | - | - | - | - | - |  |
| E03 | Door light swell | - | - | code | - | - | - | - | - | - |  |
| E04 | Walkway prompt | - | - | uses | - | - | - | - | - | - | K01 |
| E05 | Entrance stand-in | - | - | dormant | - | - | - | - | - | - | becomes the placeholder of story.backdrop.hollow_entrance |

## F. Out of the Mouth at dawn

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| F01 | Dawn grade | story.backdrop.dawn_bank | codex | placeholder | res://assets/slots/story/backdrop/dawn_bank.png | 384x216 | 3 | top-left (0,0) | static | dawn/48 | placeholder is today's DAWN_SHADER grade over S01, so the screen is unchanged until art installs; opaque |
| F02 | River mist | - | - | code | - | - | - | - | - | - |  |

## H. Highbank ground (stays code-painted; lane C)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| H01 | Blockout key | - | - | dormant | - | - | - | - | - | - |  |
| H02 | Ground clusters | - | - | code | - | - | - | - | - | - |  |
| H03 | Turf pass | - | - | code | - | - | - | - | - | - |  |
| H04 | World tile grass | town.ground.grass | codex | keep | res://assets/sprites/world/world_tiles_2026_10_10/ (grass) | 192x192 | 3 | tiled | static | as installed | file name as world_tile_art.gd:23-60 |
| H04 | World tile earth | town.ground.earth | codex | keep | res://assets/sprites/world/world_tiles_2026_10_10/ (earth) | 192x192 | 3 | tiled | static | as installed | file name as world_tile_art.gd:23-60 |
| H04 | World tile lane | town.ground.lane | codex | keep | res://assets/sprites/world/world_tiles_2026_10_10/ (lane) | 192x192 | 3 | tiled | static | as installed | file name as world_tile_art.gd:23-60 |
| H04 | World tile cliff | town.ground.cliff | codex | keep | res://assets/sprites/world/world_tiles_2026_10_10/ (cliff) | 192x24 | 3 | tiled | static | as installed | file name as world_tile_art.gd:23-60 |
| H04 | World tile cliff_b | town.ground.cliff_b | codex | keep | res://assets/sprites/world/world_tiles_2026_10_10/ (cliff_b) | 192x24 | 3 | tiled | static | as installed | file name as world_tile_art.gd:23-60 |
| H05 | Cliff bands, crossings | - | - | code | - | - | - | - | - | - |  |
| H06 | River | town.ground.river | codex | keep | res://assets/sprites/world/town_detail_2026_10_10/river_native.png | 384x72 | 3 | tiled h | static | as installed | 27,648 of 27,648 pixels partial alpha; kept |
| H07 | Reeds | - | - | code | - | - | - | - | - | - |  |
| H08 | Tufts, stones, flowers | - | - | code | - | - | - | - | - | - |  |
| H09 | Ink finish | - | - | code | - | - | - | - | - | - |  |
| H10 | Road east | town.prop.road_barrier | grok | placeholder | res://assets/slots/town/prop/road_barrier.png | 24x60 | 3 | (12,59) | static | town_timber/24 | closes the road east exit (1x2 tiles, solid) |

## B. Highbank buildings and places (lane B; v2 canvases from 02-town-rewire-design.md 4.2)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B01 | hall | town.building.hall | codex | placeholder | res://assets/slots/town/building/hall.png | 300x192 | 3 | (150,191) | closed 1; open 3 at 12 fps (optional, template cuts from door_px) | town_stone/32 | door_px (127,126,46,64); pass galeshear 62; legacy (v1 only) wayline_hall_2026_10_10/wayline_hall_native.png 240x144; canon 2026-10-26: the Wayline Tower, 300x576, door_px (126,510,48,64) in `slots/town_buildings.gd` |
| B02 | home | town.building.home | codex | placeholder | res://assets/slots/town/building/home.png | 132x144 | 3 | (66,143) | closed 1; open 3 at 12 fps (optional, template cuts from door_px) | town_stone/32 | door_px (55,94,22,48); pass sparkjab 45; legacy (v1 only) home_2026_10_09/home_native.png 120x120 |
| B03 | shop | town.building.shop | codex | placeholder | res://assets/slots/town/building/shop.png | 156x144 | 3 | (78,143) | closed 1; open 3 at 12 fps (optional, template cuts from door_px) | town_stone/32 | door_px (55,94,22,48); pass sparkjab 45; legacy (v1 only) item_shop_2026_10_09/item_shop_native.png 144x120 |
| B04 | storage | town.building.storage | codex | placeholder | res://assets/slots/town/building/storage.png | 156x144 | 3 | (78,143) | closed 1; open 3 at 12 fps (optional, template cuts from door_px) | town_stone/32 | door_px (55,94,22,48); pass sparkjab 45; legacy (v1 only) storage_2026_10_10/storage_native.png 144x120 |
| B05 | scrolls | town.building.scrolls | codex | placeholder | res://assets/slots/town/building/scrolls.png | 156x144 | 3 | (78,143) | closed 1; open 3 at 12 fps (optional, template cuts from door_px) | town_stone/32 | door_px (55,94,22,48), south door; pass sparkjab 45; legacy (v1 only) scroll_cellar_2026_10_10/scroll_native.png 144x120 |
| B06 | yard | town.landmark.yard | codex | keep | res://assets/sprites/world/training_yard_2026_10_10/yard_native.png | 168x120 | 3 | rect top-left | static | as installed | rope overlay town.prop.shut_rope |
| B07 | shrine | town.landmark.shrine | codex | keep | res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png | 144x120 | 3 | rect top-left | static | as installed | anchor socket (72,64) |
| B08 | Shrine socket, pond stone | - | - | code | - | - | - | - | - | - |  |
| B09 | board | town.landmark.board | codex | keep | res://assets/sprites/world/job_board_selout_2026_10_10/board_native.png | 96x48 | visual_scale (job_board_painter.gd:72) | rect top-left | new-request marker coded | as installed | 48x24 source copy stays |
| B10 | Crossroads plaza floor | town.ground.plaza | codex | keep | res://assets/sprites/world/town_detail_2026_10_10/floor_native.png | 160x96 | 3 | tiled | static | as installed | stepped edge coded |
| B11 | Waymark post | town.prop.waymark | grok | placeholder | res://assets/slots/town/prop/waymark.png | 24x48 | 3 | (12,47) | static | town_timber/24 | placeholder is today's coded post (crossroads_painter.gd:77) |
| B12 | lookout | town.landmark.lookout | codex | keep | res://assets/sprites/world/town_detail_2026_10_10/lookout_native.png | 144x96 | 3 | rect top-left | static | as installed | fits v2 unchanged |
| B13 | landing | town.landmark.landing | codex | keep | res://assets/sprites/world/town_detail_2026_10_10/landing_native.png | 288x108 | 3 | rect top-left | static | as installed | fits v2 unchanged |
| B14 | mouth | town.landmark.mouth | codex | keep | res://assets/sprites/world/hollow_mouth_2026_10_10/mouth_native.png | 48x48 | 3 | rect top-left | static | as installed | fits v2 unchanged |
| B15 | dock | town.landmark.dock | codex | keep | res://assets/sprites/world/town_detail_2026_10_10/dock_native.png | 144x72 | 3 | rect top-left | static | as installed | fits v2 unchanged |
| B16 | Door animation | - | - | code | - | - | - | - | - | - | template makes 3 frames from door_px (no flood fill) |
| B17 | Sign hall | town.prop.sign_hall | grok | placeholder | res://assets/slots/town/prop/sign_hall.png | 24x24 | 3 | (12,23) | static | town_timber/24 | placeholder: coded pictogram (waymark, building_exteriors.gd:333-365); foundations and mats stay template code |
| B17 | Sign shop | town.prop.sign_shop | grok | placeholder | res://assets/slots/town/prop/sign_shop.png | 24x24 | 3 | (12,23) | static | town_timber/24 | placeholder: coded pictogram (bag, building_exteriors.gd:333-365); foundations and mats stay template code |
| B17 | Sign storage | town.prop.sign_storage | grok | placeholder | res://assets/slots/town/prop/sign_storage.png | 24x24 | 3 | (12,23) | static | town_timber/24 | placeholder: coded pictogram (crate, building_exteriors.gd:333-365); foundations and mats stay template code |
| B17 | Sign scrolls | town.prop.sign_scrolls | grok | placeholder | res://assets/slots/town/prop/sign_scrolls.png | 24x24 | 3 | (12,23) | static | town_timber/24 | placeholder: coded pictogram (new, building_exteriors.gd:333-365); foundations and mats stay template code |
| B17 | Sign yard | town.prop.sign_yard | grok | placeholder | res://assets/slots/town/prop/sign_yard.png | 24x24 | 3 | (12,23) | static | town_timber/24 | placeholder: coded pictogram (new, building_exteriors.gd:333-365); foundations and mats stay template code |
| B18 | shut_boards | town.prop.shut_boards | grok | placeholder | res://assets/slots/town/prop/shut_boards.png | 26x50 | 3 | (13,49) | static | town_timber/24 | placeholder: today's code (building_exteriors.gd:235) |
| B18 | shut_chain | town.prop.shut_chain | grok | placeholder | res://assets/slots/town/prop/shut_chain.png | 28x36 | 3 | (14,35) | static | town_timber/24 | placeholder: today's code (building_exteriors.gd:264) |
| B18 | shut_rope | town.prop.shut_rope | grok | placeholder | res://assets/slots/town/prop/shut_rope.png | 30x20 | 3 | (15,19) | static | town_timber/24 | placeholder: today's code (building_exteriors.gd:281) |
| B19 | Place plaques | - | - | dormant | - | - | - | - | - | - |  |

## R. Street props and lamps (lane C draws them from each area's props list)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| R01 | Street lamp | town.lamp.post | grok | placeholder | res://assets/slots/town/lamp/post.png | 24x48 cell, sheet 24x96 | 3 | (12,47) | unlit 1, lit 1 (rows) | lantern/24 | light anchor (12,8); glow and flicker coded |
| R02 | well | town.prop.well | grok | placeholder | res://assets/slots/town/prop/well.png | 48x56 | 3 | (24,55) | static | town_stone/24 | 2x2 solid; Tower Rise waiting spot |
| R02 | bench | town.prop.bench | grok | placeholder | res://assets/slots/town/prop/bench.png | 48x32 | 3 | (24,31) | static | town_timber/24 | 2x1 |
| R02 | crates | town.prop.crates | grok | placeholder | res://assets/slots/town/prop/crates.png | 24x24 | 3 | (12,23) | static | town_timber/24 |  |
| R02 | barrel | town.prop.barrel | grok | placeholder | res://assets/slots/town/prop/barrel.png | 24x28 | 3 | (12,27) | static | town_timber/24 |  |
| R02 | planter | town.prop.planter | grok | placeholder | res://assets/slots/town/prop/planter.png | 24x24 | 3 | (12,23) | static | town_stone/24 |  |
| R02 | fence_h | town.prop.fence_h | grok | placeholder | res://assets/slots/town/prop/fence_h.png | 24x24 | 3 | (12,23) | static | town_timber/24 | tiling h |
| R02 | fence_v | town.prop.fence_v | grok | placeholder | res://assets/slots/town/prop/fence_v.png | 24x24 | 3 | (12,23) | static | town_timber/24 | tiling v |
| R02 | fence_corner | town.prop.fence_corner | grok | placeholder | res://assets/slots/town/prop/fence_corner.png | 24x24 | 3 | (12,23) | static | town_timber/24 |  |
| R02 | mooring_post | town.prop.mooring_post | grok | placeholder | res://assets/slots/town/prop/mooring_post.png | 24x36 | 3 | (12,35) | static | town_timber/24 | Ferry Dock |
| R03 | Speech bubble, emotes | - | - | code | - | - | - | - | - | - |  |
| R04 | Parcel prop | - | - | code | - | - | - | - | - | - |  |
| R05 | Board scene marks | - | - | code | - | - | - | - | - | - |  |

## U. Highbank HUD and panels

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| U01 | Arrival card lantern | - | - | code | - | - | - | - | - | - |  |
| U02 | Place panel | - | - | uses | - | - | - | - | - | - | K01 |
| U03 | Next objective | - | - | uses | - | - | - | - | - | - | K01 |
| U04 | Key strip | - | - | uses | - | - | - | - | - | - | K01 |
| U05 | Sign panel | - | - | uses | - | - | - | - | - | - | K01, K02 |
| U06 | Job Board panel | - | - | uses | - | - | - | - | - | - | K01, K02, K08, K09, ui.frame9.focus_row, ui.frame9.headshot |
| U07 | Way-down list | - | - | uses | - | - | - | - | - | - | K01, K02, ui.frame9.headshot |
| U08 | Storage list | - | - | uses | - | - | - | - | - | - | K01 |
| U09 | Menu corner button | - | - | uses | - | - | - | - | - | - | K01 |
| U10 | Toast | - | - | uses | - | - | - | - | - | - | K01 |

## M. Rooms (lane R; modular shells: floor plus four wall strips)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| M01 | Home room | town.room.home | codex | keep | res://assets/sprites/world/home_interior_2026_10_10/home_native.png | 336x240 | 3 | room origin | static | as installed |  |
| M02 | Hearth light | - | - | code | - | - | - | - | - | - |  |
| M03 | Tower work floor | town.room.hall | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/hall_native.png | 528x336 | 3 | room origin | static | as installed |  |
| M04 | pillar | town.prop.hall.pillar | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/pillar.png | 22x46 | 3 | feet | static | as installed | also placed on the lower floor |
| M04 | fern | town.prop.hall.fern | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/fern.png | 24x32 | 3 | feet | static | as installed | also placed on the lower floor |
| M04 | bench | town.prop.hall.bench | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/bench.png | 20x70 | 3 | feet | static | as installed |  |
| M04 | chart | town.prop.hall.chart | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/chart.png | 48x42 | 3 | feet | static | as installed |  |
| M04 | reports | town.prop.hall.reports | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/reports.png | 48x42 | 3 | feet | static | as installed |  |
| M04 | parcels | town.prop.hall.parcels | codex | keep | res://assets/sprites/world/hall_interior_2026_10_10/parcels.png | 44x26 | 3 | feet | static | as installed |  |
| M05 | Dispatch desk | town.prop.hall.desk | codex | keep | res://assets/sprites/world/guild_desk/desk_detail_2026_10_10.png | 192x52 | 3 | feet | static | as installed | Claude's desk.png (tools/art/guild_desk.py) sits beside it |
| M06 | stairs_down | town.prop.hall_low.stairs_down | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/stairs_down.png | 48x48 | 3 | (24,47) | static | as installed | unreferenced today; wired (Preston call 8); today's code opening (room_painter.gd:412) is the placeholder |
| M06 | stairs_up | town.prop.hall_low.stairs_up | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/stairs_up.png | 48x48 | 3 | (24,47) | static | as installed | unreferenced today; wired (Preston call 8); today's code opening (room_painter.gd:412) is the placeholder |
| M07 | lower floor | town.room.hall_low.floor | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lower_floor.png | 672x360 | 3 | strip origin | static | as installed |  |
| M07 | lower north | town.room.hall_low.north | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lower_north.png | 720x48 | 3 | strip origin | static | as installed |  |
| M07 | lower south | town.room.hall_low.south | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lower_south.png | 720x24 | 3 | strip origin | static | as installed |  |
| M07 | lower west | town.room.hall_low.west | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lower_west.png | 24x360 | 3 | strip origin | static | as installed |  |
| M07 | lower east | town.room.hall_low.east | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lower_east.png | 24x360 | 3 | strip origin | static | as installed |  |
| M08 | runner | town.prop.hall_low.runner | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runner.png | 36x128 | 3 | feet | static | as installed |  |
| M08 | rollcall | town.prop.hall_low.rollcall | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/rollcall.png | 153x93 | 3 | feet | static | as installed |  |
| M08 | north_door | town.prop.hall_low.north_door | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/north_door.png | 60x46 | 3 | feet | static | as installed |  |
| M08 | window | town.prop.hall_low.window | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/window.png | 44x32 | 3 | feet | static | as installed |  |
| M08 | banner | town.prop.hall_low.banner | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/banner.png | 16x38 | 3 | feet | static | as installed |  |
| M08 | duty | town.prop.hall_low.duty | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/duty.png | 52x28 | 3 | feet | static | as installed |  |
| M08 | lamp | town.prop.hall_low.lamp | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/lamp.png | 10x18 | 3 | feet | static | as installed | lamp also used in chamber and runners |
| M08 | mess | town.prop.hall_low.mess | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/mess.png | 144x50 | 3 | feet | static | as installed |  |
| M09 | side_door | town.prop.hall_low.side_door | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/side_door.png | 18x52 | 3 | feet | static | as installed | unreferenced today; wired; code (room_painter.gd:745, :762) is the placeholder |
| M09 | kitchen | town.prop.hall_low.kitchen | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/kitchen.png | 24x48 | 3 | feet | static | as installed | unreferenced today; wired; code (room_painter.gd:745, :762) is the placeholder |
| M10 | supply | town.prop.hall_low.supply | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/supply.png | 20x82 | 3 | feet | static | as installed | cut to top shelves and base |
| M10 | keepsakes | town.prop.hall_low.keepsakes | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/keepsakes.png | 20x82 | 3 | feet | static | as installed | cut to top shelves and base |
| M10 | ledgers | town.prop.hall_low.ledgers | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/ledgers.png | 20x82 | 3 | feet | static | as installed | cut to top shelves and base |
| M11 | chamber floor | town.room.chamber.floor | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chamber_floor.png | 360x192 | 3 | strip origin | static | as installed |  |
| M11 | chamber north | town.room.chamber.north | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chamber_north.png | 408x48 | 3 | strip origin | static | as installed |  |
| M11 | chamber south | town.room.chamber.south | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chamber_south.png | 408x24 | 3 | strip origin | static | as installed |  |
| M11 | chamber west | town.room.chamber.west | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chamber_west.png | 24x192 | 3 | strip origin | static | as installed |  |
| M11 | chamber east | town.room.chamber.east | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chamber_east.png | 24x192 | 3 | strip origin | static | as installed |  |
| M12 | dais | town.prop.chamber.dais | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/dais.png | 72x52 | 3 | feet | static | as installed |  |
| M12 | chamber river map | town.prop.chamber.river_map | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/river_map.png | 96x32 | 3 | feet | static | as installed |  |
| M12 | teal rug | town.prop.chamber.rug | codex | placeholder | res://assets/slots/town/prop/chamber/rug.png | 216x120 | 3 | top-left | static | room_chamber/24 | drawn 216 wide today from a 192 file; placeholder is that resize, as on screen now |
| M12 | wide window | town.prop.chamber.window_wide | codex | placeholder | res://assets/slots/town/prop/chamber/window_wide.png | 96x32 | 3 | feet | static | room_chamber/24 | from 68x32 at 1.41x today |
| M13 | runners floor | town.room.runners.floor | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runners_floor.png | 288x168 | 3 | strip origin | static | as installed |  |
| M13 | runners north | town.room.runners.north | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runners_north.png | 336x48 | 3 | strip origin | static | as installed |  |
| M13 | runners south | town.room.runners.south | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runners_south.png | 336x24 | 3 | strip origin | static | as installed |  |
| M13 | runners west | town.room.runners.west | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runners_west.png | 24x168 | 3 | strip origin | static | as installed |  |
| M13 | runners east | town.room.runners.east | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/runners_east.png | 24x168 | 3 | strip origin | static | as installed |  |
| M14 | rust_rug | town.prop.runners.rust_rug | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/rust_rug.png | 96x48 | 3 | feet | static | as installed |  |
| M14 | bunk_ochre | town.prop.runners.bunk_ochre | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/bunk_ochre.png | 48x52 | 3 | feet | static | as installed |  |
| M14 | bunk_slate | town.prop.runners.bunk_slate | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/bunk_slate.png | 48x52 | 3 | feet | static | as installed |  |
| M14 | chest | town.prop.runners.chest | codex | keep | res://assets/sprites/world/hall_floors_2026_10_11/chest.png | 48x22 | 3 | feet | static | as installed |  |
| M14 | runners window | town.prop.runners.window | codex | placeholder | res://assets/slots/town/prop/runners/window.png | 36x32 | 3 | feet | static | room_runners/24 | from 44x32 at 0.82x today |
| M14 | runners river map | town.prop.runners.river_map | codex | placeholder | res://assets/slots/town/prop/runners/river_map.png | 48x28 | 3 | feet | static | room_runners/24 | from 96x32 at 0.5 x 0.875 today |
| M15 | storage shell | town.room.storage.shell | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/shell.png | 408x312 | 3 | room origin | static | as installed |  |
| M15 | storage shell mask | town.room.storage.shell_mask | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/shell-mask.png | 408x312 | 3 | room origin | static | as installed | mask |
| M15 | cabinet_left | town.prop.storage.cabinet_left | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/cabinet_left.png | 72x96 | 3 | feet | static | as installed |  |
| M15 | cabinet_right | town.prop.storage.cabinet_right | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/cabinet_right.png | 72x96 | 3 | feet | static | as installed |  |
| M15 | counter | town.prop.storage.counter | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/counter.png | 144x60 | 3 | feet | static | as installed |  |
| M15 | crates | town.prop.storage.crates | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/crates.png | 48x48 | 3 | feet | static | as installed |  |
| M15 | basket | town.prop.storage.basket | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/basket.png | 48x40 | 3 | feet | static | as installed |  |
| M15 | lamp | town.prop.storage.lamp | codex | keep | res://assets/sprites/world/storage_interior_2026_10_14/props/lamp.png | 16x32 | 3 | feet | static | as installed |  |
| M16 | Room doors | - | - | code | - | - | - | - | - | - |  |
| M17 | Furniture cut-outs | - | - | code | - | - | - | - | - | - |  |
| M18 | Room HUD | - | - | uses | - | - | - | - | - | - | K01 |
| M19 | shop floor | town.room.shop.floor | codex | placeholder | res://assets/slots/town/room/shop/floor.png | 288x168 | 3 | strip origin | static | room_shop/48 | 14x10 tiles, 336x240; placeholder: room_painter.gd blocks |
| M19 | shop north | town.room.shop.north | codex | placeholder | res://assets/slots/town/room/shop/north.png | 336x48 | 3 | strip origin | static | room_shop/48 | 14x10 tiles, 336x240; placeholder: room_painter.gd blocks |
| M19 | shop south | town.room.shop.south | codex | placeholder | res://assets/slots/town/room/shop/south.png | 336x24 | 3 | strip origin | static | room_shop/48 | 14x10 tiles, 336x240; placeholder: room_painter.gd blocks |
| M19 | shop west | town.room.shop.west | codex | placeholder | res://assets/slots/town/room/shop/west.png | 24x168 | 3 | strip origin | static | room_shop/48 | 14x10 tiles, 336x240; placeholder: room_painter.gd blocks |
| M19 | shop east | town.room.shop.east | codex | placeholder | res://assets/slots/town/room/shop/east.png | 24x168 | 3 | strip origin | static | room_shop/48 | 14x10 tiles, 336x240; placeholder: room_painter.gd blocks |
| M20 | scrolls_cellar floor | town.room.scrolls_cellar.floor | codex | placeholder | res://assets/slots/town/room/scrolls_cellar/floor.png | 240x144 | 3 | strip origin | static | room_scrolls_cellar/48 | 12x9 tiles, 288x216; placeholder: room_painter.gd blocks |
| M20 | scrolls_cellar north | town.room.scrolls_cellar.north | codex | placeholder | res://assets/slots/town/room/scrolls_cellar/north.png | 288x48 | 3 | strip origin | static | room_scrolls_cellar/48 | 12x9 tiles, 288x216; placeholder: room_painter.gd blocks |
| M20 | scrolls_cellar south | town.room.scrolls_cellar.south | codex | placeholder | res://assets/slots/town/room/scrolls_cellar/south.png | 288x24 | 3 | strip origin | static | room_scrolls_cellar/48 | 12x9 tiles, 288x216; placeholder: room_painter.gd blocks |
| M20 | scrolls_cellar west | town.room.scrolls_cellar.west | codex | placeholder | res://assets/slots/town/room/scrolls_cellar/west.png | 24x144 | 3 | strip origin | static | room_scrolls_cellar/48 | 12x9 tiles, 288x216; placeholder: room_painter.gd blocks |
| M20 | scrolls_cellar east | town.room.scrolls_cellar.east | codex | placeholder | res://assets/slots/town/room/scrolls_cellar/east.png | 24x144 | 3 | strip origin | static | room_scrolls_cellar/48 | 12x9 tiles, 288x216; placeholder: room_painter.gd blocks |
| M19 | shop counter | town.prop.shop.counter | grok | placeholder | res://assets/slots/town/prop/shop/counter.png | 96x48 | 3 | feet | static | room_shop/24 | solid furniture |
| M19 | shop shelf | town.prop.shop.shelf | grok | placeholder | res://assets/slots/town/prop/shop/shelf.png | 48x72 | 3 | feet | static | room_shop/24 | solid furniture |
| M20 | scrolls_cellar rack | town.prop.scrolls_cellar.rack | grok | placeholder | res://assets/slots/town/prop/scrolls_cellar/rack.png | 48x72 | 3 | feet | static | room_scrolls_cellar/24 | solid furniture |
| M20 | scrolls_cellar table | town.prop.scrolls_cellar.table | grok | placeholder | res://assets/slots/town/prop/scrolls_cellar/table.png | 48x40 | 3 | feet | static | room_scrolls_cellar/24 | solid furniture |
| M21 | Room code painter | - | - | dormant | - | - | - | - | - | - | becomes the placeholder painter of every room slot |

## G. Dungeon terrain and floor objects (terrain stays painted)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| G01 | Ruin floors | - | - | code | - | - | - | - | - | - | painted terrain, unchanged |
| G02 | Riverbank floors | - | - | code | - | - | - | - | - | - | painted terrain, unchanged |
| G03 | Valley floor | - | - | code | - | - | - | - | - | - | painted terrain, unchanged |
| G04 | Codex tile sheets (12) | - | - | as_is | - | - | - | - | - | - | USE_TILE_ART false; stay on disk, not registered |
| G05 | Default painter atlas | - | - | as_is | - | - | - | - | - | - | dormant; not registered |
| G06 | Wall and stairs ink | - | - | code | - | - | - | - | - | - |  |
| G07 | Stairs | - | - | code | - | - | - | - | - | - |  |
| G08 | Sealed stairs | dungeon.prop.stairs_sealed | grok | placeholder | res://assets/slots/dungeon/prop/stairs_sealed.png | 24x24 | 3 | (12,23) | static | ruin/24 | red X today (dungeon.gd:4859); placeholder: slate slab with a teal seal ring |
| G09 | Items on the floor | - | - | uses | - | - | - | - | - | - | K09 |
| G10 | Traps | - | - | code | - | - | - | - | - | - |  |
| G11 | Rising water | - | - | as_is | - | - | - | - | - | - | shoreline 192x32, ripples 192x96; rising_water_art.gd not in a lane |
| G12 | Fog and sight | - | - | code | - | - | - | - | - | - |  |
| G13 | Floor card | - | - | code | - | - | - | - | - | - |  |

## A. Boss arenas and dungeon scenes

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A01 | Crew den | - | - | code | - | - | - | - | - | - |  |
| A02 | Stink wisps | - | - | code | - | - | - | - | - | - |  |
| A03 | Pond garden | - | - | code | - | - | - | - | - | - |  |
| A04 | Pond life | - | - | code | - | - | - | - | - | - |  |
| A05 | Fireflies, daze stars | - | - | code | - | - | - | - | - | - |  |
| A06 | Pond light, stone | - | - | code | - | - | - | - | - | - |  |
| A07 | Standoff | - | - | code | - | - | - | - | - | - |  |
| A08 | Cutscene bars | - | - | code | - | - | - | - | - | - |  |
| A09 | Boss wipe | - | - | code | - | - | - | - | - | - |  |
| A10 | Hit flash | - | - | code | - | - | - | - | - | - |  |
| A11 | Boss health panel | - | - | uses | - | - | - | - | - | - | K01, ui.frame9.bar_well, ui.frame9.bar_fill |

## X. Dungeon HUD

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| X01 | Floor and lantern panel | - | - | uses | - | - | - | - | - | - | K01, K09, bar |
| X02 | Lantern drawing | - | - | dormant | - | - | - | - | - | - |  |
| X03 | Team panel | - | - | uses | - | - | - | - | - | - | K01, ui.frame9.headshot, bar |
| X04 | Orders flash | - | - | uses | - | - | - | - | - | - | K01 |
| X05 | Move cards | - | - | uses | - | - | - | - | - | - | K01, K08 |
| X06 | Keycaps | - | - | code | - | - | - | - | - | - |  |
| X07 | Message log | - | - | uses | - | - | - | - | - | - | K01 |
| X08 | Key strip | - | - | uses | - | - | - | - | - | - | K01 |
| X09 | Minimap | - | - | code | - | - | - | - | - | - |  |
| X10 | Partner lines | - | - | uses | - | - | - | - | - | - | K01 |
| X11 | Join question | - | - | uses | - | - | - | - | - | - | K01 |
| X12 | Bag in a run | - | - | uses | - | - | - | - | - | - | K01, K09, ui.frame9.focus_row |
| X13 | Learn a move panel | - | - | uses | - | - | - | - | - | - | K01, ui.frame9.focus_row |
| X14 | Banner band | ui.frame9.banner | claude | placeholder | res://assets/sprites/ui/frame/banner.png | 24x36 | 1 (drawn at 3x inside) | 9-slice, margins t12 b12 | static | brass_ui/16 | tiling h across 1152x100; replaces the flat band (dungeon.gd:5328) |
| X15 | Damage numbers | - | - | code | - | - | - | - | - | - |  |
| X16 | Aim marks | - | - | code | - | - | - | - | - | - |  |
| X17 | Sleeping z | dungeon.hud_piece.sleep_mark | claude | placeholder | res://assets/slots/dungeon/hud_piece/sleep_mark.png | 7x8 cell, sheet 21x8 | 3 | (3,7) | bob 3 at 6 fps | brass_ui/16 | hand-placed pixel z, not a font letter |
| X18 | Blight bubbles | - | - | code | - | - | - | - | - | - |  |

## V. Move effects

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| V01 | Move effect sheets (35) | - | - | as_is | - | - | - | - | - | - | RD, 16 frames each; not migrated |
| V02 | Code particles | - | - | code | - | - | - | - | - | - |  |
| V03 | Shot dot | dungeon.effect.shot_<essence> (12) | claude | placeholder | res://assets/slots/dungeon/effect/shot_<essence>.png | 6x6 cell, sheet 18x6 | 3 | (3,3) centre | fly 3 at 12 fps | essence colour/12 | one per essence; coded |

## Z. Town story screens

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Z01 | Growth Shrine info | - | - | uses | - | - | - | - | - | - | K01, K03 |
| Z02 | Evolution scene | - | - | code | - | - | - | - | - | - |  |
| Z03 | End card | - | - | uses | - | - | - | - | - | - | K01 |
| Z04 | Faint screen | - | - | uses | - | - | - | - | - | - | K01 |

## Q. Menus and UI pages

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Q01 | Pause panel | - | - | uses | - | - | - | - | - | - | K01-K03 |
| Q02 | Main page buttons | - | - | uses | - | - | - | - | - | - | K01-K03 |
| Q03 | Text pages | - | - | uses | - | - | - | - | - | - | K01-K03 |
| Q04 | TEAM page | - | - | uses | - | - | - | - | - | - | K01-K03 |
| Q05 | Stage ember | ui.backdrop.stage_ember | codex | keep | res://assets/backgrounds/signature_stages/furnace_roar.png | 448x256 | as party_screen.gd draws it | top-left | static | as installed |  |
| Q05 | Stage tide | ui.backdrop.stage_tide | codex | keep | res://assets/backgrounds/signature_stages/undertow.png | 448x252 | as party_screen.gd draws it | top-left | static | as installed |  |
| Q05 | Stage bloom | ui.backdrop.stage_bloom | codex | keep | res://assets/backgrounds/signature_stages/root_rampart.png | 448x252 | as party_screen.gd draws it | top-left | static | as installed |  |
| Q05 | Stage electric | ui.backdrop.stage_electric | codex | keep | res://assets/backgrounds/signature_stages/stormlantern.png | 448x252 | as party_screen.gd draws it | top-left | static | as installed |  |
| Q05 | Stage stone | ui.backdrop.stage_stone | codex | keep | res://assets/backgrounds/signature_stages/kingstone_rail.png | 448x256 | as party_screen.gd draws it | top-left | static | as installed |  |
| Q05 | Stage gale | ui.backdrop.stage_gale | codex | keep | res://assets/backgrounds/signature_stages/gale_bluff_take1.png | 448x256 | as party_screen.gd draws it | top-left | static | as installed | fixes the missing gale_bluff.png path; take1 or take2 is Preston call 8 |
| Q05 | Stage blight | ui.backdrop.stage_blight | codex | placeholder | res://assets/slots/ui/backdrop/stage_blight.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_blight/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q05 | Stage hollow | ui.backdrop.stage_hollow | codex | placeholder | res://assets/slots/ui/backdrop/stage_hollow.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_hollow/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q05 | Stage ice | ui.backdrop.stage_ice | codex | placeholder | res://assets/slots/ui/backdrop/stage_ice.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_ice/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q05 | Stage loam | ui.backdrop.stage_loam | codex | placeholder | res://assets/slots/ui/backdrop/stage_loam.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_loam/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q05 | Stage murk | ui.backdrop.stage_murk | codex | placeholder | res://assets/slots/ui/backdrop/stage_murk.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_murk/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q05 | Stage sinew | ui.backdrop.stage_sinew | codex | placeholder | res://assets/slots/ui/backdrop/stage_sinew.png | 448x252 | as party_screen.gd draws it | top-left | static | stage_sinew/48 | no stage today (plain parchment, party_screen.gd:36-38); placeholder: parchment with 3 essence-colour bands |
| Q06 | BAG page | - | - | uses | - | - | - | - | - | - | K01, K09 |
| Q07 | OPTIONS sliders | - | - | code | - | - | - | - | - | - |  |
| Q08 | REBIND KEYS page | - | - | uses | - | - | - | - | - | - | K01, K10 |

## K. Shared UI kit and icons (Claude's pixel tools; frames stay hand-placed)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| K01 | Panel frame (3 files) | - | - | as_is | - | - | - | - | - | - | panel, panel_dim, panel_focus 84x84, margin 24 |
| K02 | Name tab | - | - | as_is | - | - | - | - | - | - | 42x36, margin 12 |
| K03 | Portrait frame | - | - | as_is | - | - | - | - | - | - | 60x60, margin 21 |
| K04 | Next arrow | - | - | as_is | - | - | - | - | - | - | 21x15 |
| K05 | Bar well | ui.frame9.bar_well | claude | placeholder | res://assets/sprites/ui/frame/bar_well.png | 18x9 | 1 (drawn at 3x inside) | 9-slice, margins l6 t3 r6 b3 | static | brass_ui/16 | replaces the flat well (ui_style.gd:631) |
| K05 | Bar fill | ui.frame9.bar_fill | claude | placeholder | res://assets/sprites/ui/frame/bar_fill.png | 3x3 | 1 (drawn at 3x inside) | tiling h | static | brass_ui/16 | tinted by health colour at runtime |
| K06 | Focus row | ui.frame9.focus_row | claude | placeholder | res://assets/sprites/ui/frame/focus_row.png | 24x24 | 1 (drawn at 3x inside) | 9-slice, margins 6 | static | brass_ui/16 | UI.focus_row replaces flat rects (dungeon.gd:5476, :5504; hub_town.gd:2051) |
| K07 | Headshot well | ui.frame9.headshot | claude | placeholder | res://assets/sprites/ui/frame/headshot.png | 18x18 | 1 (drawn at 3x inside) | 9-slice, margins 6, rim inside 48x48 | static | brass_ui/16 | UI.headshot_well (dungeon.gd:5359; hub_town.gd:1971, :2054) |
| K08 | Essence icons (12) | - | - | as_is | - | - | - | - | - | - | 32x32 |
| K09 | Item icons (6) | - | - | as_is | - | - | - | - | - | - | 32x32 |
| K10 | Pixel scrollbar | - | - | as_is | - | - | - | - | - | - |  |

## N. New slots from the town rewire (not in the census)

| Census | Visual | Slot id | Owner | Status | File | Size | Scale | Anchor | States | Palette | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| new | Lot before: stall | town.building.lot_before_stall | codex | placeholder | res://assets/slots/town/building/lot_before_stall.png | 108x120 | 3 | (54,119) | static | town_timber/32 | tarp over a counter frame; lots A and D |
| new | Lot before: shopfront | town.building.lot_before_shop | codex | placeholder | res://assets/slots/town/building/lot_before_shop.png | 156x144 | 3 | (78,143) | static | town_timber/32 | shuttered shop class; lot C |
| new | Lot before: plot | town.landmark.lot_before_plot | codex | placeholder | res://assets/slots/town/landmark/lot_before_plot.png | 144x96 | 3 | rect top-left | static | town_stone/32 | fenced empty open-air plot; lots B and E |

## Not verified

- H04's exact file names were not read (the folder and sizes come from the census). The 6 new stage backdrops take 448x252 (16:9, the size of 3 of the 8 installed stage files; the other 5 are 448x256).
- New slot sizes (signs, overlays, props, lamps, frames, the sleep mark, shots, the cursor) are proposals from 02-town-rewire-design.md 5.2 and the measured neighbours; Preston can move any of them before the task lists are written.
- `pegs.png` (16x48) sits in hall_floors_2026_10_11 but is not in the census; whether a script uses it was not checked.
