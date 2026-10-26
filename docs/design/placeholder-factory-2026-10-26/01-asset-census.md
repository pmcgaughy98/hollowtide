# Asset census: every non-creature visual (2026-10-26)

Placeholder factory, step 1 of the 2026-10-26 plan. Read-only survey of the game at commit dc37005af (branch master, with Codex's uncommitted title-logo work beside it, not counted). Preston's ask: placeholder art everywhere except creatures, wired in code first so Codex (maps, rooms, buildings, tiles) and Grok (HUD, lamps, UI, character sprites, props) can each work from a named slot with an exact size.

How it was measured: every script on the live path was indexed for its drawing calls (draw_*, Image painters, texture loads, UI kit calls); every PNG size was read from its file header; scene flow was traced from the main scene, scenes/creature_opening.tscn (project.godot:14). Nothing was run and no screenshots were taken, so the last column is a judgment from the code, explained in the key below.

## Counts

**176 non-creature visuals** on the live path, in 18 groups.

By current source:

| Source | Visuals | What it means |
|---|---|---|
| Codex PNG | 32 | a PNG Codex made, installed under assets/ |
| RD PNG | 3 | a Retro Diffusion PNG (title painting, move effects, stage backdrops) |
| Tool PNG | 50 | a PNG drawn by Claude's own pixel tools (tools/ui/build_frames.py, build_icons.py): the frames and icons |
| Code | 86 | drawn at runtime by GDScript (draw calls, Image painters, shaders) |
| Missing | 5 | nothing is drawn where the layout or story implies something |
| Opal sheet | 0 | Opal art in the game is creature art only |
| Grok generation | 0 | no Grok-made image is installed |

By how it reads today:

| Reads as | Visuals | Rule used |
|---|---|---|
| Finished | 80 | a dedicated art file at its exact slot size, through the house finish |
| Reads finished | 69 | code drawing with deliberate pixel detail (palettes, shading, stepped light) |
| Placeholder | 14 | flat fills, vector shapes, debug-like marks, plain letters or stretched art |
| Dormant | 7 | code or art that only shows when something else is missing; not seen today |
| Missing | 6 | a slot the layout or story implies, with nothing in it |

By group and source:

| Group | Codex PNG | RD PNG | Tool PNG | Code | Missing | Total | Placeholder or missing |
|---|---|---|---|---|---|---|---|
| T: Title and launch | 0 | 1 | 5 | 9 | 0 | 15 | 3 |
| S: Storm cold open | 1 | 0 | 0 | 5 | 0 | 6 | 0 |
| P: Soul prologue | 0 | 0 | 2 | 5 | 0 | 7 | 1 |
| D: Waking riverbank: flood talk, the walk and the rise | 1 | 0 | 4 | 4 | 0 | 9 | 0 |
| E: Hollow approach and the Hollow's gate | 0 | 0 | 1 | 4 | 0 | 5 | 0 |
| F: Out of the Mouth at dawn | 0 | 0 | 0 | 2 | 0 | 2 | 1 |
| H: Highbank: ground, paths and water | 2 | 0 | 0 | 7 | 1 | 10 | 1 |
| B: Highbank: buildings and places | 13 | 0 | 0 | 6 | 0 | 19 | 0 |
| R: Highbank: street props and scene marks | 0 | 0 | 0 | 3 | 2 | 5 | 2 |
| U: Highbank HUD and panels | 0 | 0 | 9 | 1 | 0 | 10 | 0 |
| M: Rooms | 12 | 0 | 1 | 6 | 2 | 21 | 4 |
| G: Dungeon terrain and floor objects | 3 | 0 | 1 | 9 | 0 | 13 | 1 |
| A: Boss arenas and dungeon scenes | 0 | 0 | 1 | 10 | 0 | 11 | 0 |
| X: Dungeon HUD | 0 | 0 | 10 | 8 | 0 | 18 | 2 |
| V: Move effects and particles | 0 | 1 | 0 | 2 | 0 | 3 | 1 |
| Z: Town story screens | 0 | 0 | 3 | 1 | 0 | 4 | 0 |
| Q: Menus and UI pages | 0 | 1 | 6 | 1 | 0 | 8 | 1 |
| K: Shared UI kit and icons | 0 | 0 | 7 | 3 | 0 | 10 | 3 |
| **All** | **32** | **3** | **50** | **86** | **5** | **176** | **20** |

## What matters for the factory

1. **Building art is locked to the footprint.** A building only shows when its PNG is exactly its rect in town_layout.gd times 24 (building_exteriors.gd:39). Hall 240x144 (10x6 tiles), Home 120x120 (5x5), Shop, Storage and Scroll Keeper 144x120 (6x5). Codex cannot hand in a bigger building without the layout contract changing first, so the rewire has to start in town_layout.gd.
2. **Creatures outgrow the doors.** Town sprites are 1.5x the dungeon set (hub_town.gd:707). Measured opaque height of the south view: stage 1 Kithflare 33 px, Tallowroot 34, Rimefin 31; stage 2 Sparkwick 50; stage 3 Stormwick 69, Starward 56, Warden 61. A door's art starts 36 px above its door tile (48 for the Hall; building_exteriors.gd:153) and the whole Home is 120 px tall, so a stage-3 creature stands nearly twice a door's height while a stage-1 creature fits it.
3. **The town is one screen-sized idea stretched.** 48x32 tiles (1152x768 px) is 3 screens wide and 3.6 tall. Every service sits on one map; the road east (Rect2i(45,9,3,2)) leads nowhere and nothing marks it closed. There is no second area, no interior for the Item Shop or the Scroll Keeper, and the Training Yard's arena is shut.
4. **The street has no props of its own.** No lamps, benches, fences, barrels, signposts or trees are drawn on Highbank's street; everything of that kind lives inside a building's PNG. This is the clearest Grok slot list.
5. **Four room props are stretched or squeezed** by nearest-neighbour resize (hall_floors_art.gd:69): the chamber's teal rug and wide window, the runners' window and river map.
6. **Dormant art and unused files.** Codex's 12 dungeon tile sheets are switched off (USE_TILE_ART false), and four Hall PNGs have no reference anywhere in scripts/: kitchen.png, side_door.png, stairs_down.png, stairs_up.png.
7. **The UI kit is finished, its bars are not.** Every panel, tab, portrait frame and icon is a pixel PNG. The bars, focus rows and HUD headshot boxes are flat rects (K05 to K07), the main place the hand-placed 9-slice rule is not met (with the banner band X14 and the title's canopy shade T05).
8. **No non-creature characters exist in the live game.** The soul (S05, P05) and the presence's light (P03) are code. Human courier sprites remain from the courier era but no live screen loads them (see Not reached).
9. **The title painting sits at 4.5x.** 256x144 to 1152x648 is not a whole scale, so its art pixels are 4 or 5 screen pixels wide.

## Key

- **Code** column: file:line of the drawing (paths under scripts/ unless they start with assets/ or docs/).
- **Source**: Codex PNG, RD PNG, Tool PNG, Code or Missing, as in the counts. Details give the file and its pixel size; a bare folder name is under assets/sprites/world/, frame/, essence/ and item/ are under assets/sprites/ui/, and fuller paths are written out.
- **On screen**: world things are in the 384x216 low-res view, shown 3x (one art pixel is 3x3 screen pixels); UI is on the 1152x648 canvas. Tile positions are (column,row) from the top left.
- Creature sprites, portraits, idles and the creatures standing in town and rooms are left out on purpose.

## T. Title and launch (scenes/creature_opening.tscn, the project's main scene)

Drawn on the full 1152x648 canvas, not the 384x216 low-res view. Script chain: creature_opening.gd extends opening_flow.gd extends main_menu_art_preview.gd extends main_menu.gd; creature_opening.gd overrides the scenery and empties the old courier characters (creature_opening.gd:377).

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| T01 | Launch card backdrop | opening_flow.gd:21, colour creature_opening.gd:113 | Code | flat ColorRect #161f1b | 1152x648 at (0,0) | until Enter | Placeholder: flat fill |
| T02 | Launch wordmark | opening_flow.gd:26 | Code | reuses T08's texture | 768x168, centred, y 216 | static | Reads finished |
| T03 | Launch captions | opening_flow.gd:34, :40; text set creature_opening.gd:119 | Code | font labels | full width at y 392, hint below | hint follows the input device | Reads finished |
| T04 | Village painting | creature_opening.gd:39 | RD PNG | assets/sprites/menu/creature_village_2026_10_09.png, 256x144 | scaled 4.5x to 1152x648 at (0,0) | static | Reads finished: header calls the architecture a proposal; 4.5 is not a whole scale, so art pixels land 4 or 5 screen px wide |
| T05 | Canopy shade | creature_opening.gd:47 | Code | ColorRect rgba(0.07,0.10,0.10,0.38) | 1152x150 at (0,0) | static | Placeholder: flat band |
| T06 | Legibility wash | creature_opening.gd:53 | Code | scripts/ui/title_legibility.gdshader | 1152x648 | static | Reads finished |
| T07 | Fireflies | creature_opening.gd:68 | Code | six 3x3 squares | fixed homes between y 426 and 550 | pulse, drift 5 px | Reads finished |
| T08 | Wordmark HOLLOWTIDE | creature_opening.gd:84, ui/hollowtide_wordmark.gd:89 | Code | font letters through a 3-band gradient shader, roots, burrow arch and leaves set pixel by pixel | 384x84 canvas at 2x = 768x168 at (192,0) | static | Reads finished: Codex has an uncommitted logo pass in docs/ui/title-logo-2026-10-26/ (not counted) |
| T09 | Main menu buttons | creature_opening.gd:145, main_menu.gd:729, ui_style.gd:127 | Tool PNG | frame/panel.png and panel_focus.png, 84x84, 9-slice margin 24 | column 320 wide at (64, 324 or higher) | normal, focus | Finished |
| T10 | Menu cursor | main_menu.gd:366 | Code | Polygon2D | beside the focused button | bounces 12 steps a second | Placeholder: a vector triangle, not pixel art |
| T11 | How to play panel | creature_opening.gd:238 | Tool PNG | frame/panel.png | 678 wide at (430,120), scrolls | topics | Finished |
| T12 | Options page on the title | ui/title_settings.gd, ui/game_pause_menu.gd:201, :259 | Tool PNG | frame + slider parts drawn from letter rows at 3x | pause-panel layout | sliders, toggles, rebind | Finished |
| T13 | New Game confirmation | main_menu.gd:499 | Tool PNG | frame/panel.png | 560 wide at (296,216) | yes/no | Finished |
| T14 | Quit confirmation | main_menu.gd:643 | Tool PNG | frame/panel.png | 390 wide at (720,330) | yes/no | Finished |
| T15 | Title fade | main_menu.gd:376 | Code | black ColorRect | 1152x648 | 0.6 s (0.2 under Reduce motion) | Reads finished |

## S. Storm cold open (scenes/storm_open.tscn)

Low-res 384x216 view at 3x. Everything except the painting is code.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| S01 | Waking riverbank painting (used again by D, E and F) | ui/waking_bank.gd:7; code fallback :75; finish ui/waking_bank_finish.gd:42 | Codex PNG | assets/sprites/world/waking_bank_2026_10_10/waking_native.png, 384x216 | full screen, 1152x648 | night, grey drain, lightning via shader uniforms storm_open.gd:59-60 | Finished |
| S02 | River cover hiding the ruin | ui/hollow_rise.gd:37 | Code | copies of the painting's own river and treeline, shifted 90 px | over STRUCT 90x50 and WALK 76x38 (low-res) | until the rise | Reads finished |
| S03 | Rain and splashes | storm_open.gd:179; effects/storm_rain.gd:54 | Code | 1 px slanted lines, 3x1 splashes | full screen | wind, then frozen when time stops | Reads finished |
| S04 | Lightning and the grey drain | storm_open.gd:59-60 (shader) | Code | shader uniforms grey and flash | full screen | 0 to 1 | Reads finished |
| S05 | The soul falling | storm_open.gd:188 | Code | 4 circles, radius 2, 4, 7, 12 (grow by up to 14) | at soul_at, bobs 3 px | glow, brighten to white | Reads finished |
| S06 | White-out | storm_open.gd:198 | Code | 384x216 rect | full screen | alpha | Reads finished |

## P. Soul prologue (scenes/soul_prologue.tscn)

Low-res 384x216 at 3x; the UI layer is full 1152x648.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| P01 | The void | soul_prologue.gd:246 | Code | one rect per row, indigo gradient | 384x216 | static | Reads finished |
| P02 | Drifting motes | soul_prologue.gd:252 | Code | 1x1 px | random | drift up | Reads finished |
| P03 | The presence's light (it never appears) | soul_prologue.gd:259 | Code | 5 polygons and a 3 px band at the top edge | top edge down to y 150 | brightens while it speaks | Reads finished |
| P04 | The river far below | soul_prologue.gd:267 | Code | 2x1 dashes on rows 176 to 216 | bottom 40 rows | shimmer | Placeholder: abstract dashes stand in for a view of the world |
| P05 | The soul (ball of light) | soul_prologue.gd:275 | Code | circles radius 26, 16, 9, 5 and 6 sparks; a ? label | at _soul, bobs 3 px | wobble, question, fly | Reads finished |
| P06 | Starter cards (3) | soul_prologue.gd:328, rect :225 | Tool PNG | UI.panel frame; the creature idles inside are creature art | 324x312 each at x 66, 414, 762, y 176 (picked lifts 12) | pick, dimmed 0.35 | Finished |
| P07 | Voice line box | soul_prologue.gd:297 | Tool PNG | UI.dialogue, ??? name tab, no portrait | 872x122 at (140,498) | typing, arrow | Finished |

## D. Waking riverbank: flood talk, the walk and the rise (creature_prologue.tscn, riverbank_journey.gd)

The painting is S01. Low-res 384x216 at 3x, UI at 1152x648.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| D01 | Ruin and walkway rising from the river | ui/hollow_rise.gd:154 | Code | the ruin climbs behind the waterline, foam, spray, stones break the surface | STRUCT 90x50, WALK 76x38 (low-res) | 4 steps, plays once | Reads finished |
| D02 | Hollow entrance close-up | riverbank_journey.gd:16, town/hollow_approach.gd:26; finish ui/hollow_entrance_finish.gd:15 | Codex PNG | assets/sprites/world/waking_bank_2026_10_10/entrance_native.png, 384x216 | full screen | static | Finished |
| D03 | Place card RIVERBANK / THE HOLLOW | riverbank_journey.gd:150 | Code | dark band in 3 steps, title face in gold | y 300 (the arch's card y 96) | 2.5 s, fades | Reads finished |
| D04 | Key strip | riverbank_journey.gd:268 | Tool PNG | frame/panel.png | bottom right, foot at y 600 | device keys | Finished |
| D05 | Dialogue box with portrait | ui_style.gd:365; creature_prologue.gd:199 | Tool PNG | panel, portrait 60x60, nameplate 42x36, arrow 21x15; face backgrounds code ui_style.gd:294 | 760x116 at (196,452); portrait 120x120 at box +(42,-34) | 9 faces, typing, 2-row pages | Finished |
| D06 | Answer list | creature_prologue.gd:216; mouth_escape.gd:286 | Tool PNG | frame/panel.png | over the box's right end | cursor | Finished |
| D07 | Back to the title? prompt | creature_prologue.gd:231 | Tool PNG | frame/panel.png | 360x176 at (396,236) | Resume / Return | Finished |
| D08 | Ground shadows under actors | ui/waking_bank.gd:197; ui/journey_shadows.gd:5 | Code | ellipses | under each creature | follow | Reads finished |
| D09 | Scene fades (shared by every screen) | ui_style.gd:946, :970 | Code | black ColorRect on layer 110 | 1152x648 | 0.2 s | Reads finished |

## E. Hollow approach and the Hollow's gate (scenes/hollow_approach.tscn)

Uses S01 and D02.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| E01 | Walkway node glow | town/hollow_approach.gd:388 | Code | glow at NODE_AT (244,79) | low-res, about 1 tile | pulse | Reads finished |
| E02 | Teleport light column | town/hollow_approach.gd:388 | Code | column of light | on the walkway at y 192 | appears, team fades in | Reads finished |
| E03 | Door light swell | town/hollow_approach.gd:388 | Code | light at DOOR_AT (192,110) | doorway | swells, run starts | Reads finished |
| E04 | Walkway prompt | town/hollow_approach.gd:173 | Tool PNG | frame + label | near the node | device keys | Finished |
| E05 | Entrance stand-in | town/hollow_approach.gd:141 | Code | dark water, walkway, lit doorway | full screen | only if entrance_native.png is missing | Dormant |

## F. Out of the Mouth at dawn (scenes/mouth_escape.tscn)

Uses S01 and the dialogue pieces D05 and D06.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| F01 | Dawn grade | mouth_escape.gd:34 (DAWN_SHADER) | Code | shader over the night painting S01 | full screen | static | Placeholder: there is no dawn painting; the storm night is regraded |
| F02 | River mist | mouth_escape.gd:404 | Code | Image in 3 see-through steps, water only | the painting's river | static | Reads finished |

## H. Highbank: ground, paths and water (scenes/hub_town.tscn)

One street picture of 48x32 tiles at 24 px = 1152x768, painted once and cached to user:// (hub_town.gd:69), seen through a 384x216 view at 3x (16x9 tiles a screen). The layout contract is scripts/town/town_layout.gd.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| H01 | Blockout key | hub_town.gd:654 | Code | flat BLOCK colours per band, path, building, roof | 1152x768 | read by the painters as a key | Dormant: never seen when the painters run |
| H02 | Ground pixel clusters | town/highbank_ground_painter.gd:29 | Code | seeded clusters (Codex's code) | whole map | static | Reads finished |
| H03 | Turf pass: grass, cobbled lanes, packed earth, patches | town/highbank_painter.gd:40, :150, :177, :360 | Code | Claude's painter over the tile PNGs | whole map | static | Reads finished |
| H04 | World tile materials | town/world_tile_art.gd:23, :50, :60 | Codex PNG | world_tiles_2026_10_10: grass, earth, lane 192x192; cliff, cliff_b 192x24 | tiled | static | Finished |
| H05 | Two cliff bands and the switchback crossings | highbank_painter.gd:195, :910; world_tile_art.gd:50 | Code | banded cliffs, turf, roots, steps | rows 18 and 24, 1152x24 each | static | Reads finished |
| H06 | River | highbank_painter.gd:221; town_detail_art.gd:26 | Codex PNG | town_detail_2026_10_10/river_native.png 384x72, laid 3 times at y 696 | 1152x72 (rows 29 to 31) | static | Finished |
| H07 | Reeds | highbank_painter.gd:245 | Code | 2 greens | water's edge | static | Reads finished |
| H08 | Tufts, stones, flowers | highbank_painter.gd:504, :513, :523 | Code | meadow palette | scattered on the bluff | static | Reads finished |
| H09 | Ink finish on ledges | town/world_finish.gd:20, :56; hub_town.gd:610 | Code | mask and shader | cliffs and stair crossings | static | Reads finished |
| H10 | Road east | town_layout.gd:37 Rect2i(45,9,3,2) | Missing | a plain lane runs off the map edge | 3x2 tiles at the east edge | closed | Missing: no gate, barrier or sign says it is closed |

## B. Highbank: buildings and places

Positions in tiles from town_layout.gd:42-72. World px = tiles x 24; screen px = world px x 3. A building's PNG must be exactly its footprint size or it is not shown at all (building_exteriors.gd:39).

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| B01 | Wayline Hall | building_exteriors.gd:117; town_layout.gd:46 | Codex PNG | wayline_hall_2026_10_10/wayline_hall_native.png 240x144 | 10x6 tiles at (19,1); 720x432 on screen | door 3 frames; door 2 tiles wide, art starts 48 px above the door tile | Finished |
| B02 | Home | building_exteriors.gd:117; home_painter.gd:6 | Codex PNG | home_2026_10_09/home_native.png 120x120 | 5x5 at (3,3); 360x360 | door 3 frames, mat | Finished: door art starts 36 px above the door tile |
| B03 | Item Shop | building_exteriors.gd:117; item_shop_painter.gd:6 | Codex PNG | item_shop_2026_10_09/item_shop_native.png 144x120 | 6x5 at (31,3); 432x360 | shut: boards over the door (:235) | Finished: shut, and no interior exists (M19) |
| B04 | Storage | building_exteriors.gd:117; storage_painter.gd | Codex PNG | storage_2026_10_10/storage_native.png 144x120 | 6x5 at (38,3) | crate sign; opens after Rootbank Warren | Finished |
| B05 | Scroll Keeper | building_exteriors.gd:198, :212, :427, :444 | Codex PNG | scroll_cellar_2026_10_10/scroll_native.png 144x120; porch cut out and lifted 12 px | 6x5 at (31,12), door on the north row | shut: chain over the cellar lid (:264) | Finished: shut, no interior (M20) |
| B06 | Training Yard | training_yard_painter.gd:13, sign :60; rope building_exteriors.gd:281 | Codex PNG | training_yard_2026_10_10/yard_native.png 168x120 | 7x5 at (38,12) | shut: rope across the gate | Finished: shut; the arena mode behind it is not reachable in the pilot |
| B07 | Growth Shrine clearing | growth_shrine_painter.gd:13, inlay :58 | Codex PNG | growth_shrine_2026_10_10/shrine_native.png 144x120 | 6x5 at (4,12) | static | Finished |
| B08 | Shrine socket and the pond stone | hub_town.gd:1453; dungeon/stone_scene.gd:168 | Code | socket: ellipse r 6 and 4 at half height; stone: slate egg with a pulsing teal seam, motes, rings | at the shrine's socket | empty, carried, installed, waking | Reads finished |
| B09 | Job Board | job_board_painter.gd:15, marker :94 | Codex PNG | job_board_2026_10_10/board_native.png 48x24 and job_board_selout_2026_10_10/board_native.png 96x48 | 2x1 at (26,7); 144x72 | new-request marker | Finished |
| B10 | Crossroads plaza | crossroads_painter.gd:26 | Codex PNG | town_detail_2026_10_10/floor_native.png 160x96 tiled, stepped edge in code | 12x6 at (18,11); 288x144 world | static | Finished |
| B11 | Waymark post | crossroads_painter.gd:77 | Code | posts and arms set in pixels | plaza centre, tile (24,14) | static | Reads finished |
| B12 | Bluff Lookout | landmark_exteriors.gd:98 | Codex PNG | town_detail_2026_10_10/lookout_native.png 144x96, contact shadow | 6x4 at (10,2) | static | Finished |
| B13 | Old Ferry Landing | landmark_exteriors.gd:98 | Codex PNG | town_detail_2026_10_10/landing_native.png 288x108 | 12x4 at (26,26); art 12 px taller than its rect | static | Finished |
| B14 | Mouth of the Hollow (the run's gate in town) | hollow_mouth_painter.gd:13 | Codex PNG | hollow_mouth_2026_10_10/mouth_native.png 48x48 | 2x2 at (33,27); 144x144 on screen | static | Finished: the way into every dungeon is a 2-tile spot |
| B15 | Ferry Dock | landmark_exteriors.gd:98 | Codex PNG | town_detail_2026_10_10/dock_native.png 144x72 | 6x2 at (38,28); art one tile taller | static | Finished |
| B16 | Door animation | building_exteriors.gd:368, :403 | Code | frames cut from each building's art, 28x56 | per door | 3 frames | Reads finished |
| B17 | Foundations, grass seams, doorstep mats, pictogram signs | building_exteriors.gd:311 | Code | bag (shop), crate (storage), waymark (hall) signs | per building | static | Reads finished |
| B18 | Shut boards, chain, rope | building_exteriors.gd:235, :264, :281 | Code | pixel art over the doors and gate | shop, scrolls, yard | static | Reads finished |
| B19 | Place plaques | hub_town.gd:1859 | Code | dark plaque, 1 px brass rim, Silkscreen 8 px | 13 px tall, mid-left of a place | drawn only for a place with no installed exterior: 0 of 13 today (by code reading) | Dormant |

## R. Highbank: street props and scene marks

Searched highbank_painter.gd, building_exteriors.gd, highbank_ground_painter.gd, landmark_exteriors.gd, crossroads_painter.gd and town_detail_art.gd for lamps, benches, fences, barrels, crates, wells, signposts and trees.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| R01 | Street lamps | none | Missing | no lamp is drawn on the street |  |  | Missing |
| R02 | Street furniture: benches, fences, barrels, crates, planters, signposts, trees | none | Missing | only what is painted inside a building's own PNG |  |  | Missing |
| R03 | Speech bubble and emote marks | town/scene_kit.gd:353, :427 | Code | 11x13 bubble with an ink rim and a mark | over a head; 33x39 on screen | !, ? and others | Reads finished |
| R04 | Wayline parcel prop | town/scene_kit.gd:451; dungeon/crew_scene.gd:270 | Code | kraft box, twine, teal seal at 1x | world | handed over, hops, jolts | Reads finished |
| R05 | Board scene marks: torn paper, dust | town/board_scene.gd:590 | Code | scraps and puffs | at the board | 700 ms | Reads finished |

## U. Highbank HUD and panels

CanvasLayer at 1152x648.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| U01 | Arrival place card with lantern | hub_town.gd:378, :428 | Code | black, HIGHBANK in the title face at y 292, lantern 11x15 art px at 3x (33x45) at (560,330), glow 33x33 at 3x | full screen | 3 flame frames on a 10-step flicker | Reads finished |
| U02 | Place panel | hub_town.gd:1898 | Tool PNG | frame/panel.png | 330x54 at (6,6) | place underfoot | Finished |
| U03 | Next objective panel | hub_town.gd:1905 | Tool PNG | frame/panel_dim.png | 600x34 at (6,64) | text | Finished |
| U04 | Key strip | hub_town.gd:2012 | Tool PNG | frame/panel.png over a PANEL fill | bottom right, foot at y 578 | 1 or 2 lines | Finished |
| U05 | Sign panel | hub_town.gd:1936 | Tool PNG | frame + name tab | 760x128 at (196,452) | 2 lines | Finished |
| U06 | Job Board panel | hub_town.gd:2029 | Tool PNG | frame, name tab, 48x48 face boxes, cargo and reward icons, Taken tab | 960 x (132 + 70 a row) at (96,64) | focus row, Taken | Finished: its focus row and face boxes are flat rects (K06, K07) |
| U07 | Way-down list | hub_town.gd:1923, :1957 | Tool PNG | frame, name tab, 48x48 face boxes | 760 wide at (196,64) | choose | Finished |
| U08 | Storage list (town fallback and room) | town/storage_panel.gd:114, :130 | Tool PNG | frame made opaque | panel | scroll rows | Finished |
| U09 | Menu corner button | ui/game_pause_menu.gd:52 | Tool PNG | frame/panel.png | 160x52 at (984,586) | device key | Finished |
| U10 | Toast (Highbank remembers.) | ui_style.gd:901 | Tool PNG | frame/panel.png | top right, 24 px in | 1.5 s, then fades | Finished |

## M. Rooms (scenes/town_room.tscn)

24 px tiles, 384x216 at 3x, the same town-size creatures. room_painter.gd paints every room in code first; Codex's art layers go over it when every file is present at its exact size (hall_floors_art.gd:49).

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| M01 | Home | room_painter.gd:170; home_room_art.gd:12 | Codex PNG | home_interior_2026_10_10/home_native.png 336x240 | 14x10 tiles | static | Finished |
| M02 | Hearth light | town_room.gd:682, :691 | Code | stepped flicker | hearth, tile (9,2) | flicker | Reads finished |
| M03 | Wayline Hall work floor | room_painter.gd:288; hall_room_art.gd:26 | Codex PNG | hall_interior_2026_10_10/hall_native.png 528x336 | 22x14 | static | Finished |
| M04 | Work floor props (12 placements) | hall_room_art.gd:8-13 | Codex PNG | pillar 22x46 x4, fern 24x32 x2, bench 20x70 x2, chart 48x42, reports 48x42, parcels 44x26 x2 | as placed | static | Finished |
| M05 | Dispatch desk | town_room.gd:511, :530 | Codex PNG | guild_desk/desk_detail_2026_10_10.png 192x52 | counter, 8x2 tiles at (7,3) | static | Finished |
| M06 | Stairs down and up | room_painter.gd:412; hall_fixtures_art.gd:144 | Code | dark opening; Codex's stairs_down.png and stairs_up.png (48x48) are not referenced | 2x2 tiles at (14,10) and (25,13) | static | Reads finished |
| M07 | Hall lower floor shell | hall_floors_art.gd:44, :72 | Codex PNG | lower_floor 672x360, lower_north 720x48, lower_south 720x24, lower_west and lower_east 24x360 | 30x18 (720x432) | static | Finished |
| M08 | Lower floor props (17 placements) | hall_floors_art.gd:12-21 | Codex PNG | runner 36x128, rollcall 153x93, north_door 60x46, window 44x32 x2, banner 16x38 x2, duty 52x28, lamp 10x18 x2, fern x2, pillar x4, mess 144x50 | as placed | static | Finished |
| M09 | Side doors and kitchen hatch, edge-on | room_painter.gd:745, :762 | Code | Codex's side_door.png 18x52 and kitchen.png 24x48 are not referenced | west and east walls | static | Reads finished |
| M10 | Tall cases: supply, keepsakes, ledgers | room_painter.gd:62; hall_fixtures_art.gd:28-29 | Codex PNG | 20x82 each, cut to the top two shelves and base | back walls | static | Finished |
| M11 | Postmaster's Chamber shell | hall_floors_art.gd:44 | Codex PNG | chamber_floor 360x192, chamber_north 408x48, chamber_south 408x24, west and east 24x192 | 17x11 (408x264) | static | Finished |
| M12 | Chamber props | hall_floors_art.gd:23-26, resize :69 | Codex PNG | teal_rug 192x120 drawn 216x120; window_wide 68x32 drawn 96x32; dais 72x52; river_map 96x32; lamp 10x18 x2 | as placed | static | Placeholder: two props are stretched by nearest-neighbour resize at 1.125x and 1.41x |
| M13 | Runners' Room shell | hall_floors_art.gd:44 | Codex PNG | runners_floor 288x168, runners_north 336x48, runners_south 336x24, west and east 24x168 | 14x10 (336x240) | static | Finished |
| M14 | Runners' Room props | hall_floors_art.gd:27-30, resize :69 | Codex PNG | rust_rug 96x48, bunk_ochre and bunk_slate 48x52, chest 48x22, lamp 10x18; window 44x32 drawn 36x32; river_map 96x32 drawn 48x28 | as placed | static | Placeholder: two props squeezed to 0.82x and 0.5x by 0.875x |
| M15 | Storage room | storage_room_art.gd:3-11 | Codex PNG | storage_interior_2026_10_14/shell.png 408x312 (+ shell-mask); props cabinet_left and cabinet_right 72x96, counter 144x60, crates 48x48, basket 48x40, lamp 16x32 x2 | 17x13 (408x312) | props sorted by their feet | Finished |
| M16 | Room doors and thresholds | room_painter.gd:142 | Code | door in the bottom wall | door tiles | static | Reads finished |
| M17 | Furniture drawn over creatures | town_room.gd:569, :605 | Code | cut-outs of each solid piece | per piece | static | Reads finished |
| M18 | Room HUD: name, Next, key hints, signs | town_room.gd:988, :999, :1070 | Tool PNG | frame/panel.png | 330x54 at (6,6) and the town's panel spots | text | Finished |
| M19 | Item Shop interior | none (hub_town.gd:1141 SHUT) | Missing | no room in town_room.gd ROOMS |  |  | Missing |
| M20 | Scroll Keeper interior | none (hub_town.gd:1141 SHUT) | Missing | no room in town_room.gd ROOMS |  |  | Missing |
| M21 | Room code painter for every room | room_painter.gd:13 | Code | blocks with a lit top-left, shaded bottom-right, ink outline | full room | seen only where art is missing | Dormant |

## G. Dungeon terrain and floor objects (scenes/dungeon.tscn)

24 px tiles, 384x216 at 3x. Looks per floor from dungeon.gd:320-345: Hollow Mouth B1F-B4F ruin; Rootbank Warren B1F-B3F riverbank; The Hollow B1F valley, B2F ruin, B3F boss. Floor pictures are painted once and cached (dungeon.gd:932).

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| G01 | Ruin floors | dungeon/ruin_painter.gd:147, :69, :282, :320, :510, :622, :721, :761 | Code | hand-painted textured stone (the house look) | whole floor | static | Reads finished |
| G02 | Riverbank floors and roots | riverbank_painter.gd:35, :63, :201, :227, :342; rootbank_detail.gd:75, :107 | Code | clay, pools, grass lip, pebbles, roots on wall faces | whole floor | static | Reads finished |
| G03 | Valley floor | valley_painter.gd:32, :73, :133, :163, :316, :342 | Code | meadow, path, hills, trees, rocks | whole floor | static | Reads finished |
| G04 | Codex's 24 px tile sheets | dungeon_tile_art.gd:144 | Codex PNG | tilesets/dungeon_tiles_2026_10_10: 12 sheets (floor and decor 96x24, grass and wall 384x384, for 3 looks) |  | off: USE_TILE_ART false (ruin_painter.gd:5, riverbank_painter.gd:6, valley_painter.gd:5) | Dormant |
| G05 | Default painter and bank atlas | floor_painter.gd:15, :19; hollow_bank_painter.gd:13 | Codex PNG | tilesets/hollow_bank_2026_10_09/terrain_24.png 96x96 |  | only for a look with no painter (none today) | Dormant |
| G06 | Wall and stairs ink finish | dungeon_finish.gd:11 | Code | mask and shader | exposed wall faces, stairs | static | Reads finished |
| G07 | Stairs | ruin_painter.gd:190 (one drawing in 3 palettes) | Code | a way down cut into the floor, rubble chips | 22x20 inside a 24 tile; 66x60 on screen | static | Reads finished |
| G08 | Sealed stairs while a boss stands | dungeon.gd:4859 | Code | dark slab and a red X, 2 px lines | 24x24 tile | static | Placeholder: reads as a debug mark |
| G09 | Items on the floor | dungeon.gd:5062 | Tool PNG | item icons 32x32 drawn 16x16 in the world, 3-row pixel shadow; a ball if an icon is missing | tile centre; 48x48 on screen | static | Finished |
| G10 | Traps: Silt Pit, Snare, Warp Eddy | dungeon.gd:4886, inks :4958 | Code | pixel marks in the floor's own palette with a 1 px deep rim | about 19x13, 17x10, 17x11 | hidden until seen | Reads finished |
| G11 | Rising water (The Hollow B1F) | rising_water_art.gd:29; fallback dungeon.gd:714 | Codex PNG | rising_water_2026_10_14/shoreline.png 192x32, ripples.png 192x96, with code depth bands | from water_base up | 4 phases, 400 ms | Finished |
| G12 | Fog and sight | dungeon_visibility_canvas.gd:20 | Code | darkness outside sight | whole floor | follows the leader | Reads finished |
| G13 | Floor card | dungeon.gd:995 | Code | dungeon name in gold and B#F in the title face | centred at y 304 | fades | Reads finished |

## A. Boss arenas and dungeon scenes

World parts at 24 px tiles and 3x; full-screen parts at 1152x648.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| A01 | The crew's den (Rootbank Warren boss floor) | rootbank_detail.gd:40, :135 | Code | one 13x10 room, a rooted arch | 312x240 world | static | Reads finished |
| A02 | Stink wisps while Mirekit plays dead | crew_scene.gd:295 | Code | 3 green wisps | over Mirekit | curl up | Reads finished |
| A03 | The Warden's pond garden | boss_intro.gd:476 (meadow), :597 (pond) | Code | grass patches, clumps, flower beds, bushes, stones, stepping stones; pond with reeds, cattails, lily pads | 25x18 tiles (600x432 world) | static | Reads finished |
| A04 | Pond life: fish, ripples, the rising shadow, the ground shadow | boss_intro.gd:672 | Code |  | pond and floor | animated | Reads finished |
| A05 | Fireflies and daze stars | boss_intro.gd:738 | Code |  | garden; over the dazed team | until the Warden bursts out | Reads finished |
| A06 | Pond light and the stone rising | stone_scene.gd:150, :168 | Code | slate egg, pulsing teal seam, halo | pond centre, then to the leader | rises, travels | Reads finished |
| A07 | Standoff: breath puffs, gathering strike, light streak | stone_scene.gd:404 | Code |  | over the creatures | sequence | Reads finished |
| A08 | Cutscene bars and dim | dungeon.gd:5306 | Code | black bars | 1152x54 top and bottom | while a scene plays | Reads finished |
| A09 | Wipe into a boss fight | dungeon.gd:5312 | Code | 34 streaks up to 360 px, then white | full screen | 700 ms; none under Reduce motion | Reads finished |
| A10 | Hit flash | dungeon.gd:5298 | Code | white | full screen | strong hits; none under Reduce motion | Reads finished |
| A11 | Boss health panel | dungeon.gd:5378 | Tool PNG | frame; name in the foe colour; flat bar (K05) | 360x46 at (396,10) | drains | Finished |

## X. Dungeon HUD

CanvasLayer at 1152x648, laid out in dungeon.gd:5290-5512.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| X01 | Floor and lantern panel | dungeon.gd:5336 | Tool PNG | frame; B#F; Lamp Oil icon 32x32 at (92,24); light bar 146x9 (K05) | 346x54 at (6,6) | icon dims to half when the light is out | Finished |
| X02 | Lantern drawing | dungeon.gd:5282 | Code | 5 rects | 10x15 | only if lamp_oil.png is missing | Dormant |
| X03 | Team panel | dungeon.gd:5352 | Tool PNG | frame; a row each: 48x48 headshot box (K07), name tag, HP bar 170x9 (K05), numbers, evolve sliver 170x3 | 346 x (56 + 50 a member) at (6,62) | leader edge, downed dim | Finished |
| X04 | Orders flash | dungeon.gd:4025 | Tool PNG | frame | under the team panel | 1 s after T | Finished |
| X05 | Move cards (4) | dungeon.gd:5387, rects :5653 | Tool PNG | frame; keycap (X06); essence icon 32x32 | 200x54 at (8 + 206 a slot, 580) | ready, cooling (dark overlay, 0.7 alpha) | Finished |
| X06 | Keycaps | dungeon.gd:5669 | Code | ink face, 1 px light top, shadow, brass rim | 38x22 | lit, unlit | Reads finished |
| X07 | Message log | dungeon.gd:5414, LOG_BOX :5662 | Tool PNG | frame; names in colour | 818 wide, 21 px rows, up to 4, foot at y 574 | fades when quiet | Finished |
| X08 | Key strip | dungeon.gd:5434, :5660 | Tool PNG | frame | right, above the Menu button | hidden during lines | Finished |
| X09 | Minimap | dungeon.gd:5580 | Code | panel_dim frame; explored tiles 3 to 5 px with 1 px edges, item dots, gold stairs square, team and foe dots | top right, at most 232x170 | fills as explored | Reads finished |
| X10 | Partner lines and warnings | dungeon.gd:5443 | Tool PNG | UI.dialogue in the log box | 818x108 at (8,466) | typing | Finished |
| X11 | Join question | dungeon.gd:5447, :5543 | Tool PNG | frame | 480x88, the side away from the asker | yes/no | Finished |
| X12 | Bag in a run | dungeon.gd:5452 | Tool PNG | frame; item icons 32x32; flat focus row (K06) | 560 wide, side away from the leader | choose | Finished |
| X13 | Learn a move panel | dungeon.gd:5487 | Tool PNG | frame; flat focus row (K06) | 480 wide | choose, forget, skip | Finished |
| X14 | Banner: Monster House, boss, win | dungeon.gd:5328, :3400 | Code | PANEL colour band at 0.78 and the title face | 1152x100 at y 226 | 2 s | Placeholder: a flat band, not the pixel frame |
| X15 | Damage numbers and pickup pops | dungeon.gd:5120, :5160, :4244 | Code | outlined numbers that overshoot and settle | over targets | fade | Reads finished |
| X16 | Aim brackets, warning tiles, wind-up glow, facing chevron, turn arrows | dungeon.gd:4978, :5005, :4868, :5082, :5023 | Code | pixel marks and arcs | on tiles | per turn | Reads finished |
| X17 | Sleeping z | dungeon.gd:5077 | Code | Silkscreen letter z at 8 px | over sleepers | bobs | Placeholder: a plain letter |
| X18 | Blight bubbles | dungeon.gd:5047 | Code | 3x3, 2x2, 1x1 squares | over a blighted creature | rise | Reads finished |

## V. Move effects and particles

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| V01 | Move effect sheets (35) | dungeon.gd:2043, :2054 | RD PNG | assets/sprites/arena/vfx/<name>/f00-f15.png, cut by tools/arena/slice_vfx.py from Retro Diffusion sheets (receipts in docs/creatures/arena-starters-2026-10-07/vfx); 27 at 32x32, 8 at 48x48 | centred on the target, world 1x | 16 frames over 0.45 s | Finished |
| V02 | Code particles: bursts, rings, rising motes, after-images | dungeon.gd:5255, :5263, :5268, :5091, :5104, :5107 | Code | squares and arcs in the move's colour | world | short lives | Reads finished |
| V03 | Shot dot for a move with no projectile art | dungeon.gd:5086 | Code | a circle radius 3 that flies | world | 0.15 s | Placeholder: a moving dot stands in for missing projectile art |

## Z. Town story screens

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| Z01 | Growth Shrine info | ui/shrine_info.gd:118, :283 | Tool PNG | frames, 72x72 portrait wells, buttons, pixel scrollbar; creature idles inside | browsable panel | lists, detail | Finished |
| Z02 | Evolution scene | ui/evolution_scene.gd:258, :274 | Code | dark, column of light, turning rays, glow, motes on a 384x216 layer at 3x; frame panel | centre (576,300) | sequence | Reads finished |
| Z03 | End card | town/pilot_end.gd:257, :264 | Tool PNG | black, frame panel 900x588 at (126,22), display-face title; team idles | full screen | lines fade in one by one | Finished |
| Z04 | Faint screen | ui/faint_screen.gd:120 | Tool PNG | the last floor frame at 25 percent, dialogue 760x116 at (196,412), defeat panel 740 wide at x 206 | full screen | line, then panel | Finished |

## Q. Menus and UI pages (scripts/ui/game_pause_menu.gd and pages)

Layer 80, pauses the tree.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| Q01 | Pause shade and panel | game_pause_menu.gd:65, :71 | Tool PNG | shade rgba(0.04,0.07,0.05,0.72); frame with 34 px margin | 520 wide or more at (316,58) | pages | Finished |
| Q02 | Main page buttons | game_pause_menu.gd:108 | Tool PNG | frame panel and panel_focus via UI.style_button | in the panel | focus | Finished |
| Q03 | OBJECTIVE, FLOOR, MESSAGE LOG, CONTROLS pages | game_pause_menu.gd:143, :607; controls_text.gd | Tool PNG | frame and text; log names in colour | in the panel; Floor text 532 wide | scroll | Finished |
| Q04 | TEAM page | ui/party_screen.gd:230, :266, :346, :398; wells game_pause_menu.gd:538 | Tool PNG | frames, portrait frame round a 48x48 well, move details; creature idle inside | left 360x504 at (64,92), right 648x420 at (440,128) | Status, Moves | Finished |
| Q05 | Stage behind the creature on the TEAM page | party_screen.gd:36-43 | RD PNG | backgrounds/signature_stages: furnace_roar 448x256, undertow 448x252, root_rampart 448x252, stormlantern 448x252, kingstone_rail 448x256 | behind the creature in the left column | by first essence | Missing: 5 of 12 essences have one; GALE points at gale_bluff.png, which is missing (only gale_bluff_take1 and take2 exist); 6 others have none and show plain parchment |
| Q06 | BAG page | ui/bag_page.gd:31, :115 | Tool PNG | frames, item icons, 96x96 portrait, list 446x336 | in the panel | choose, use | Finished |
| Q07 | OPTIONS sliders | game_pause_menu.gd:201, :259-300 | Code | track 6x8, fill and 6x10 knob set from letter rows at 3x | volume rows | focus shows on the row frame | Finished |
| Q08 | REBIND KEYS page | ui/rebind_page.gd:62 | Tool PNG | frames, 40 px rows, pixel scrollbar 15 wide | in the panel | listen, clash | Finished |

## K. Shared UI kit and icons

Made by Claude's pixel tools (tools/ui/build_frames.py, tools/ui/build_icons.py) and saved as PNGs; every panel above draws through these.

| ID | Visual | Code | Source | Details | On screen | States | Reads as |
|---|---|---|---|---|---|---|---|
| K01 | Panel frame: moss weave, brass bevel, corner studs | ui_style.gd:169, :185 | Tool PNG | ui/frame/panel.png, panel_dim.png, panel_focus.png, 84x84, 9-slice margin 24, tiled | any size | normal, see-through, focus | Finished |
| K02 | Name tab | ui_style.gd:243 | Tool PNG | ui/frame/nameplate.png 42x36, margin 12 | at least 96x36 |  | Finished |
| K03 | Portrait frame and face backgrounds | ui_style.gd:255, :294, :327 | Tool PNG | ui/frame/portrait.png 60x60, margin 21; backgrounds in 5 code bands per face | 120x120, frame 15 px outside | 9 faces | Finished |
| K04 | Next arrow | ui_style.gd:352 | Tool PNG | ui/frame/arrow.png 21x15 | box's bottom right | bobs 3 px each 0.5 s | Finished |
| K05 | Bars: health, light, EXP, boss | ui_style.gd:631 | Code | black well at 0.55, flat fill, 1 px brass edge at 0.55 | for example 170x9 | colour by health | Placeholder: flat rectangles, not a pixel 9-slice |
| K06 | Focus row highlight | dungeon.gd:5476, :5504; hub_town.gd:2051 | Code | flat UI.FOCUS rect and a 1 px edge | row size |  | Placeholder: flat box |
| K07 | Headshot boxes in the HUD and on the board | dungeon.gd:5359; hub_town.gd:1971, :2054 | Code | flat PORTRAIT_BG and a 1 px edge | 48x48 |  | Placeholder: the TEAM page already uses the portrait frame for the same job |
| K08 | Essence icons (12) | ui_style.gd:682 | Tool PNG | ui/essence/*.png 32x32: blight, bloom, electric, ember, gale, hollow, ice, loam, murk, sinew, stone, tide | 32x32 | dim when cooling | Finished |
| K09 | Item icons (6) | ui_style.gd:686 | Tool PNG | ui/item/*.png 32x32 (drawn 16 px, saved at 2x): lamp_oil, parcel, rally_seed, reedberry, river_stone, scroll | 32x32 in panels, 16x16 world on the floor |  | Finished |
| K10 | Pixel scrollbar | ui_style.gd:202 | Tool PNG | cut from the frame pieces | 15 px wide | thumb | Finished |

## Characters that are not creatures

| Who | Where | How it is drawn |
|---|---|---|
| The soul, a ball of light | storm_open.gd:188 (S05), soul_prologue.gd:275 (P05) | code circles and sparks |
| The presence (never seen) | soul_prologue.gd:259 (P03) | light shafts from the top edge |
| Humans, couriers, townsfolk | none on the live path | Highbank's townsfolk and the guild crew are creatures (excluded) |

## Not reached from the title

Courier-era scenes (world_journey, first_route_prototype, hometown, historic_street, city_relay_yard, city_riverfront, courier_hall, courtyard_home, hometown_courtyard and the route1 set) and the old Courier Lookout menu layers are still in the project but no live screen opens them. Their scripts reference 97 non-creature asset paths (PNGs, tilesets, shaders and folders), among them 1024x1024 and 640x640 courier walk sheets (scripts/player.gd:19-29), 8 cottonwood trees and 14 bank shrub or reed sprites (route1_rd_2026_10_01 and _02), brick and ledger house linework (world_linework_2026_10_04) and 1024x768 street paintings. The arena side mode (arena_grass.png and arena_stone.png, 384x216) is behind the shut Training Yard. None of these are counted above; some could be studied as structure for the new town areas.

## Excluded as creature visuals

Creature sprites in every set (dungeon, town, small, portrait), the 109 dialogue faces at 40x40 in assets/sprites/ui/dialogue/, the front idles on the starter cards, TEAM page, shrine, evolution scene and end card, the title's village actors (village_actors_2026_10_09), the guild crew, job clients and the Shortcut Crew.

## Not verified

- Nothing was run, so the Reads as column is judged from the code and file sizes, not from a render.
- The plaque count (B19, 0 of 13) and the stand-ins marked Dormant were read from the code paths, not watched in a session.
- The provenance of world PNGs is taken from the painters' headers and commit messages (Codex for the town, rooms, waking bank and tile sheets; Retro Diffusion for the title painting, stage backdrops and effect receipts).
- Codex's uncommitted title-logo work (docs/ui/title-logo-2026-10-26/, docs/team/CODEX_HANDOFF_2026-10-26_title_logo.md) was not read.
