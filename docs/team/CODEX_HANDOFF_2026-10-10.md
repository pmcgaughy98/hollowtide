# Codex: what changed on October 9, and your next jobs (written by Claude)

## October 10 jobs (written by Claude, in this order)

Preston, October 10: "need tasks for codex as well, also the wayline hall door needs widened to meet the path but so far the map rigging is working for codex." Your Highbank map rigging works; these build on it.

0. **First: the town buildings brief, `docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md`** (Preston, October 10). Your Hollowtide Sprite finish (the outline) on the buildings, buildings grounded in the world, doors that read as enterable, plus notes on how the games structure a map while you build the world. It includes job 1 (the hall door).
1. **Paint the Wayline Hall door two tiles wide.** The layout now gives the hall `door_tiles` `(23, 6)` and `(24, 6)`, matching its two-tile steps `Rect2i(23, 7, 2, 2)`; both tiles walk and answer E as the hall. `"door"` is still `(24, 6)`. In `scripts/town/highbank_ground_painter.gd` both door draws read `place["door"]` only; use `Layout.door_tiles(place)` so the opening spans both tiles and lines up with the steps. Checks: `tools/debug/hall_door_check.gd`, `tools/debug/hub_town_check.gd`, plus a native capture of the hall front.
2. **Re-run your pause-menu checks.** I added pages to your `scripts/ui/game_pause_menu.gd` (TEAM, BAG, FLOOR, MESSAGE LOG, from Explorers of Sky's dungeon menu and pokered's start menu). Your buttons, names, focus wrap, prefs and leave flow are unchanged; the new buttons sit between Resume and Options, which moves Options down the list. Your original is in `docs/ui/field-menu-2026-10-10/originals/`. My check: `tools/debug/field_menu_check.gd`.
3. **Give the field pages their look.** They are text only. Yours to design: each teammate's portrait (the front idle frames you already crop for the opening), a health bar, the evolve bar (level plus conditions, the same purple as the dungeon HUD), item icons in BAG. Keep the button names (`Team`, `Bag`, `Floor`, `Log`, `Use_<item>`) and the label text the check reads, or update the check with it.
4. **The Growth Shrine screen in town.** Its service is `growth`; it should show what TEAM shows (level, IQ, the evolve conditions, and the moves). Grok answered `docs/creatures/learnset-draft-2026-10-10.md`, and Claude wired `LEARN` and `WAITING` in `dungeon.gd`. Read those consts. Do not copy the numbers. The Springvault rows in that const are still Claude's draft.
5. **Settle the main scene.** `project.godot` has `run/main_scene` set to `scenes/hollow_floor.tscn` (uncommitted, not mine). The opening is yours; put F5 back where you and Preston want it.
6. **New, from Claude (same day):** `scripts/ui/ui_style.gd` holds one shared look taken from your pause menu, now used by the dungeon and town HUDs; headshots for every form are at `assets/sprites/arena/<form>/portrait.png` (cut by `tools/arena/build_portraits.py`), shown in the team panel and your TEAM page. For job 3 use the style module; for your portrait job, drawn emotion portraits can replace these crops one form at a time. Write-up: `docs/ui/ui-tour-2026-10-10/README.md`.
7. **Still open from October 9:** the hall as the dungeon guild (board, roster, dispatch, return) and the emotion portraits.
8. **Put the launch flow's boxes in the pixel frames** (Preston, October 10: the UI looked "so plain" and "doesn't blend with the game"). Claude replaced every panel, button and text box outside the launch flow with hand-placed pixel 9-slice frames at the world's 3x (moss weave, bevelled brass band, corner studs), from `tools/ui/build_frames.py` into `assets/sprites/ui/frame/`. Your screens still draw `StyleBoxFlat`: `scripts/main_menu.gd` (the panel, buttons, sliders and outline around lines 353, 477, 504, 609), `scripts/creature_opening.gd` (lines 135, 153, 190, 240, 250, 316), `scripts/creature_prologue.gd` (lines 65 and 128) and `scripts/first_partner_arrival.gd` (line 19). Swap them for `UI.frame("panel")` (normal), `UI.frame("panel_focus")` (chosen button) and `UI.frame("panel_dim")` (see-through), `.duplicate()` them before changing content margins, from `const UI := preload("res://scripts/ui/ui_style.gd")`. For the prologue's text box use `UI.dialogue(canvas, box, speaker, line, UI.dialogue_portrait(form), clock)`: portrait framed above the box, the name on a brass tab, the bobbing arrow. Portraits exist for `kithflare`, `tallowroot`, `rimefin` and `warden` (`assets/sprites/ui/dialogue/`, cut by `tools/ui/build_dialogue_portraits.py`); add more forms to that script's `SOURCES` the same way. Two limits: a framed box needs at least 48 px on each side (24 px borders) and its contents inset about 24 px, so 36 to 44 px buttons grow to about 52. Leave the title painting and the wordmark as they are; this is the boxes only. Stills of the new look: `docs/ui/dialogue-2026-10-10/` and `docs/ui/ui-tour-2026-10-10/`. Checks after: `tools/debug/soul_prologue_check.gd` (it walks into your creature prologue), `tools/debug/field_menu_check.gd`, plus a native capture of the main menu and the prologue box.
9. **The Job Board works now (Claude, same day).** E at the board opens four requests; taken jobs place a client or a lost item on their floor; the board pays on return. Code in `scripts/town/jobs.gd`, the board screen in `hub_town.gd` (`_draw_board`). Your `job_board_painter.gd` art is untouched. If the Wayline Hall becomes the guild desk (dispatch, reports), call `Jobs.rows`, `Jobs.toggle` and `Jobs.pay` rather than keeping a second job list. Write-up: `docs/design/job-board-2026-10-10/README.md`.
10. **Emotion portraits and the first dungeon's floor (Claude, same day).** Preston asked Claude for expression portraits: `tools/ui/rd_expressions.py` (a Kithflare pilot is in `assets/sprites/ui/dialogue/`; write-up `docs/ui/expressions-2026-10-10/README.md`), so your old emotion-portrait job (5) can wait unless Preston hands it back. The first dungeon now paints with `scripts/dungeon/riverbank_painter.gd` (clay, pebbles, grass, sediment banks) and the Hollow's stone with `ruin_painter.gd`; your atlas painter `hollow_bank_painter.gd` is untouched and still the default for any floor without a look.
11. **Sel-out pass (Preston, October 10: "codex needs sel-out task").** Selective outlines: an outline pixel takes a darker shade of the colour it borders (lighter on the lit top-left) instead of one flat dark ink, so shapes stay crisp but sit into Hollowtide's palettes. In this order: (a) **the town exteriors** (hall, home, shop, storage, scroll cellar, board, shrine, yard, gate): their outer edges against the new ground. Claude's `scripts/town/highbank_painter.gd` now paints the grass, street, terraces, cliffs and river around them and leaves your places' pixels alone (it only swaps your plain grass and earth tones); stills `docs/world/highbank-ground-2026-10-10/after.png` and `play_*.png`. (b) **a shared helper** `scripts/art/selout.gd` (`selout(img: Image, mask_or_rect) -> Image`) that the code painters can call on their wall lips, cliff tops, the Lookout's wall and the Dock's planks (`riverbank_painter.gd`, `ruin_painter.gd`, `valley_painter.gd`, `highbank_painter.gd`); write the helper and one before/after still, and Claude will wire it into the painters. (c) **creatures, A/B only:** a sel-out variant of `creature_finish.gdshader` beside the current near-black outline on three creatures, stills for Preston to choose; do not change Preston's creature art or the shipped outline until he picks. Run `hub_town_check.gd`, `town_walk_check.gd` and `dungeons_check.gd` after.
12. **The waking scene for the pilot (Preston, October 10: "Thats perfect").** Read `docs/design/pilot-story-2026-10-10.md` first: the pilot runs from the soul to the Warden, and Preston approved its story outline. Your `scripts/creature_prologue.gd` waking needs three changes, all text and staging in your scene: (a) the night is the **riverbank collapse that raised The Hollow** (it already says the bank gave way; add the river and the light of something rising); (b) the voice in the dark is a **Wayline trainee sent down to gather mail the river tore loose**, who says something told it to come down tonight; it is not another survivor; (c) the ending names the **rule that no one runs a route alone** and that the trainee keeps being turned away for having no partner, so the two set out for Highbank together. Keep the partner choice as it is. Do not write the Guildmaster's scene; Claude does that once Preston picks the town creatures. Lines are proposals; mark them so. Run `town_loop_check.gd` after.

Not yours, for context: levels and EXP were added October 9 (`levels` in the team record), and 45 ElevenLabs sounds now play in the dungeon and town (`docs/audio/sources.md`). No commit was made.


## Codex progress checked October 9, 2026

The original handoff below is retained as written by Claude. Current state supersedes its old main-scene statement: F5 opens the creature-village menu, then the awakening/identity/companion story; no starter choice on the title screen.

- Job 1 initial 24px terrain atlas/painter is installed, with the procedural fallback (`docs/design/creature-player-opening-2026-10-09/`). Secondary terrain remains inactive.
- Job 2 palette locks now installed for Dustkite, Waywhistle, Highsignal and current remade Riftfin/Scourmaw, in both arena and dungeon sets. Current models and cleaned silhouettes preserved.
- Job 3 relay check rerun: both appearances pass 25 real input/world/practice checks each against the rebuilt picker.
- Jobs 4 and 5 remain: creature guild/board/roster/dispatch/return with Claude, then emotion portraits. Old human-world courier content is retained; the creature guild loop and persistent identity are not claimed built.

Evidence and scope: `docs/creatures/handoff-palette-locks-2026-10-09/README.md`. No commit or gameplay/settings edits.


## The game now, in four lines
1. **Hollowtide is a mystery dungeon** after Explorers of Sky, Preston's favorite game. The courier takes jobs into generated dungeons called Hollows.
2. **Exploring is turn-based** on a grid: the team in a chain, sleeping wild creatures, items, traps, a lantern as the run's clock, and stairs.
3. **Fights are turn-based too.** A real-time version (the arena engine taking over the floor) was built and then turned off the same night. Preston: "we'll keep arena style for another mode, let's keep the dungeon combat turn-based." The arena stays a separate mode.
4. **Your launch flow, hometown, courier hall and first morning all stay.** The hall becomes the dungeon guild.

## Read first (required, in order)
1. `docs/design/mystery-dungeon-pivot-2026-10-09.md`: what carries over, the slice order, and the full reference list.
2. `docs/design/combat-rethink-2026-10-09.md`: the combat ideas (read its top note: fights stayed turn-based).
3. The top entries of `docs/AI_COLLABORATION.md` from October 9.

Background, read only if a job needs it:
- `docs/design/dungeon-slice-2026-10-09/README.md` (the floor);
- `dungeon-run-loop-2026-10-09/` (items, traps, lantern, Monster Houses);
- `dungeon-warnings-2026-10-09/`;
- `dungeon-recruiting-2026-10-09/`;
- `dungeon-hybrid-2026-10-09/` (the real-time fight switch).

## How to play what exists
Run the arena scene (F6 on `scenes/arena_prototype.tscn`) to open the matchup picker, fill your side, and press **DUNGEON**. Or F6 on `scenes/dungeon.tscn`.
- WASD steps, Shift turns, J attacks, 1 to 3 are moves.
- I is the bag, Z rests, E takes the stairs, Tab is autopilot.
- Y and N answer a creature asking to join.

## What changed in files you own or use
- **`scripts/relay_yard_practice.gd`**: my picker rewrite broke it. It overrode a `_grid()` the picker no longer has, so it failed to parse. I removed the override and it compiles again. **Please re-run your relay check**; it hasn't been run since.
- **`scripts/world_journey.gd`**: three lines. A `first_fight` var, its creation beside `partner_story`, and an `enter_area` call. The levee Cinderhide is fought in the arena through `scripts/first_fight.gd`. With the pivot that fight belongs on a short first dungeon floor (job 4).
- **`project.godot`**: the main scene is `scenes/opening_flow.tscn` again.
- **`scripts/move_preview.gd`** (the matchup picker): rebuilt as one screen, with DUNGEON and HOLLOW buttons beside FIGHT.
- **`scripts/hollow/hollow_floor.gd`**:
  - now plays the dungeon's real-time fights through a battle mode;
  - `Gen.TILE` became a `tile` variable (16 by default, 24 in a dungeon fight).
- **Your sprite finish** (`scripts/arena/creature_finish.gd`) is now applied in the dungeon too. Standing rule: any screen that draws a creature applies it.
- **New:**
  - `scenes/dungeon.tscn`;
  - `scripts/dungeon/dungeon.gd`;
  - `scripts/dungeon/floor_painter.gd`;
  - `scripts/hollow/hollow_gen.gd` (the floor generator).

## Your jobs, in order (proposals; Preston's word overrides)
1. **A Hollow dungeon tileset at 24 px.** Today `floor_painter.gd` paints floors from the arena's grass and a procedural silted bank.
   - Make a real tileset at the Cinderhide-level finish:
     - floor variants (silt, grass, cut-bank clay);
     - wall top, lip and cliff-face pieces;
     - inner and outer corners;
     - water and silt for secondary terrain;
     - the stairs.
   - Wire the painter to use it when present, and keep the procedural painter as the fallback.
   - This one floor picture carries the whole game's look. Preston approves it.
   - Structure to read: how Explorers of Sky and Red Rescue Team pick a wall piece from its eight neighbours (see the references below).
2. **Palette locks** for Dustkite, Waywhistle, Highsignal (approved October 9) and the remade Riftfin and Scourmaw. Old sheets are kept with `_serpent` and `_bladefin` suffixes.
3. **Re-run your relay check** (see above) and say in the log whether it passes.
4. **The courier hall as the dungeon guild** (pivot slice 6, with Claude):
   - a job board in the hall;
   - a dispatch that opens a Hollow with the party;
   - the return to the hall;
   - a roster to choose who comes (recruits wait there);
   - the first-morning levee fight moved onto a short first floor.

   **You own** the hall, the board's presentation, the roster screen and the world side. **Claude owns** the dungeon's rules, the fight switch and the save/state model.

   Structure to read: Red Rescue Team's rescue mail and the Explorers of Sky job board (see the references).
5. **Dialogue portraits with emotions** for partners (a later job): happy, hurt, determined, surprised, built from your front-idle portrait work. Explorers of Sky shows one beside every line of dialogue.

## The disassemblies Preston linked, and what each is for you
Preston is dropping Pokémon disassemblies one at a time "for synthesis". **The rule for all of them:** read for structure only. How a screen is ordered, what a system tracks, how tiles are chosen. Never copy code, data, maps, sprites, text, music or numbers into the repo. Claude read the starred ones through Firecrawl (web pages about them); the rest are unread, and you can read their public repos with your own web access.

| Repo | Game | What to take, for your jobs |
|---|---|---|
| `pret/pmd-sky` * | Explorers of Sky (DS) | The main reference: dungeon tilesets and wall autotiling (job 1), the guild and job board (job 4), emotion portraits (job 5). The SkyTemple wiki documents its dungeon data. |
| `PikalaxALT/pmd-red` | Red Rescue Team (GBA) | The first Mystery Dungeon. Rescue mail and the rescue team base: the closest match to the courier's board (job 4). Its smaller tilesets are a good scale reference (job 1). |
| `pret/pokeemerald` | Emerald (GBA) | The best documented of the set. Menus, the bag, party and summary screens, the town, Secret Bases (a possible courier home); the Battle Pyramid (already used for the lantern). |
| `pret/pokeplatinum` | Platinum (DS) | Menus, the bag, summary screens and the town at DS scale, close to ours. |
| `pret/pokered` * | Red and Blue (Game Boy) | How maps, connections between areas, and trainer and encounter tables are laid out. Useful for the world map you built. |
| `pret/pokestadium`, `pret/pokestadiumgs` | Stadium 1 and 2 (N64) | The arena side mode: rental teams, cups, presentation. Stadium 2's mini-games could be hometown activities. |
| `pret/pokerevo` | Battle Revolution (Wii) | The arena side mode, and how a fight is staged on screen. |
| `pret/colosseum-mb` * | Colosseum's link-cable program (GBA) | Only the idea of carrying a team between modes. |
| `pret/ds_disassembly_tools` *, `PikalaxALT/gba_bios` * | Tools, firmware | Nothing for Hollowtide. |

Gameplay videos Preston linked (October 9): Explorers of Sky and Rescue Team DX no-commentary playthroughs. Notes on HUD, map, portraits and the town are in `docs/research/pmd-video-notes-2026-10-09.md`; useful for your hall and portrait jobs.

The non-repo references used so far:
- Rescue Team DX (Switch), from Serebii's mechanics page: Auto Mode, the Awakened state, Linked Moves, Rare Qualities.
- Into the Breach and Hoplite: telegraphs and pushes, and movement as attack.

All are summarised in `docs/design/combat-rethink-2026-10-09.md` and `docs/research/pmd-sky-references-2026-10-09.md`.

## Rules unchanged
- **Do not commit, revert or stash.** The tree holds a lot of uncommitted work from Claude, Codex and Grok, and Preston commits.
- **Grok owns** creature and move numbers and rules; dungeon numbers are in Grok's handoff.
- **Preston owns** names and art approval; anything new is labelled a proposal.

## New, late October 9: the hub town layout is ready to fill (Claude)
Preston asked Claude to lay out the world with the synthesis so you can fill it in, as with the dungeon. **Read `docs/world/hub-layout-2026-10-09/README.md` first.** Every position, size, door and path is decided in `scripts/town/town_layout.gd`. Your job is the art to those rects, in the order the README gives, plus later the service screens. Do not move a door or path tile without telling Claude. Run `scenes/hub_town.tscn` (F6) and `tools/debug/hub_town_check.gd`.

**Also (Claude, later October 9):** your `scripts/creature_prologue.gd` now ends by opening the hub town (`scenes/hub_town.tscn`) instead of the dungeon, with the team record `scripts/town/team_state.gd` carrying the choice. Three lines, marked with a comment. The loop prologue → town → Hollow → town is checked by `tools/debug/town_loop_check.gd`.

## Claude, 2026-10-10 20:33: the Hollow entrance, Preston's latest direction (read before editing `scripts/town/hollow_approach.gd`)
- Claude wrote `scripts/town/hollow_approach.gd` + `scenes/hollow_approach.tscn` (check: `tools/debug/hollow_approach_check.gd`, passing) and `hub_town.gd` `enter_hollow` now opens it when The Hollow is the next dungeon. You have since wired your entrance art into it (`ENTRANCE`, `EntranceFinish`). Claude has stopped editing it so your changes are not overwritten.
- **Preston changed the plan after it was built:** the riverbank with the structure in the distance is **only the waking scene**. The entrance painting is used, but the team gets there by **a teleport from town, Mystery Dungeon style**, not by walking from the riverbank.
  So the approach drops its riverbank stop (`QuietBank`, `NODE_AT`, `_run_bank`): the team arrives in a light column at the foot of the walkway, an "Enter? / Back to Highbank" prompt, then the walk up to the door, the glow, and `_enter_dungeon()`.
  Claude will make that change once you say you are out of the file; or make it yourself and say so here.
- **The waking scene's creature sprites:** Preston says they can be "nonnormal, meaning make it look best for the scene" (not tied to the `small` set size). That is your `creature_prologue.gd` `set_form`; yours to tune, or tell Claude to.

## Claude, 2026-10-10 21:30: refine the dungeon floor so it reads as a real map (Preston asked what you should do)
Reference shot: `docs/ui/type-2026-10-10/dungeon_hud.png` (Rootbank Warren B1F, seed 4242). This is your job 1 (the 24 px tileset), made concrete. Structure from Explorers of Sky's tilesets; copy nothing.
1. **Calm the floor.** The even speckle of dirt noise, the grey pebbles sprinkled at a constant density, and the pale diagonal streaks read as procedural texture. Make floor tiles low contrast (3 variants plus 1 or 2 rare accent tiles), so creatures and items pop. Put detail in clusters with a reason: pebbles and roots along wall bases and in room corners, not everywhere.
2. **Grass as tiles, not blobs.** The flat green shapes with dithered edges and white sparkles have no edge or shading. Make a grass-on-clay transition set (edges, inner and outer corners) chosen from the 8 neighbours, like the walls.
3. **Walls with height.** Only the top band reads as wall; the sides fade to a soft dark blur. Each wall needs a lit top surface, a lip, and a face one tile tall where it meets the floor, autotiled from its 8 neighbours (the 47-piece blob set, or 16 plus corners). That is what makes rooms and one-tile hallways read at a glance.
4. **One light direction and one outline.** Light from the top left on every piece. Wall-top edges and props get the same sel-out edge the creatures now have (`tools/arena/selout.py` shows the colour rule: a dark shade of the fill mixed with the line's outline colour).
5. **A palette per dungeon, locked.** About 16 to 24 colours for each tileset. Rootbank Warren: clay, root brown, moss. The Hollow: river slate, teal, wet stone (match your entrance painting). No colours outside the lock.
6. **Crisp darkness.** Unseen tiles should be solid dark per tile, not a soft green vignette, so the explored shape of the floor is readable.
7. **A visible tile rhythm.** A real tiled map shows its 24 px grid faintly (slight seams, repeated stones). The current floor reads as one painted image.
Claude will update the minimap to draw explored rooms and hallways as lines, with the team, items and the stairs as dots, once your tiles land. Verify with before/after captures on the same seed (4242) and the existing dungeon checks.

## Claude, 2026-10-10 late: the flood opening is wired into your riverbank (read before editing `scripts/riverbank_journey.gd`)
Preston approved a new opening (full order in `docs/design/pilot-story-2026-10-10.md`, "The opening, revised"). Three small, commented hooks are in your `riverbank_journey.gd`:
- `_rise()`: on the first visit, before the Hollow Mouth is cleared, the ruin and stone path rise out of the river (`scripts/ui/hollow_rise.gd`, drawn over your `waking_native.png` with your finish material; the painting is untouched).
- `_enter_arch()`: until "mouth" is beaten, the arch starts the Hollow Mouth (`dungeon.gd` "mouth", two floors, no boss). Your Rootbank-then-Hollow rule follows unchanged.
- `_town()`: during the flood the road to Highbank is under water.
`hollow_approach.gd` now has two modes ("flood", "teleport"); the town's way down uses "teleport" (a column of light at the walkway's foot, Enter or Back). Your entrance art and finish are kept exactly as you wired them. If you would rather the teleport land in your walkable `hollow_entrance.tscn`, say so and Claude will point the town there.
Your waking text should now speak of the flood still rising (the trainee's lines and the agreement), since Highbank comes after the Hollow Mouth.
- Claude, same night: Preston asked to remove the parcels on the ground, so the three sealed envelopes are painted out of `assets/sprites/world/waking_bank_2026_10_10/waking_native.png` (filled from the clay beside each; your original is in `docs/design/flood-opening-2026-10-10/before/`). Your waking text that mentions loose letters leading to the trainee may want a new line. The partner's saved parcel now appears at the Hollow Mouth's exit and is stolen at the Job Board.

## Wayline Hall, two floors (Claude, 2026-10-10 late; Preston: "need more space, should be like the guild hall in Sky", chose two floors)
Taken from Sky's guild as structure only: public work upstairs, the Guildmaster's chamber, the morning roll call, crew rooms and the mess hall below. Built and walkable now, painted in code as a stand-in (`scripts/town/room_painter.gd` `_lower`, `_chamber`, `_stairs`). Your art replaces it the same way `hall_room_art.gd` replaces the Hall's: same pixel size, furniture on the same tiles (the tiles are in `scripts/town/town_room.gd` ROOMS).
- **Work floor (`hall`, your art, unchanged):** new stairs down at tiles (14,10) to (15,11), drawn over your picture by `_stairs`. Please paint them into the Hall art in its palette; keep the tiles.
- **Lower floor (`hall_low`, 30x18 tiles, 720x432 px):** tall double doors to the chamber at the back centre (14,1)-(15,1) with a teal runner down to the roll-call floor (a brass-ringed teal oval with the Wayline mark, centre (15,9)); banners and ferns either side of the door; a duty board (9,1); river windows (3,1) and (25,1); four pillars (9,5) (20,5) (9,12) (20,12); side-wall doors to the crew room (west, rows 5-6) and the runners' room (east, rows 5-6); kitchen hatch in the west wall (rows 8-9); mess table with benches (3,12)-(8,13); supply shelf (27,9)-(27,11); stairs up (25,13)-(26,14).
- **Guildmaster's chamber (`chamber`, 16x11 tiles, 384x264 px):** plank floor, a wide teal rug, Starward's dais with a cushion at (7,3)-(9,4), the whole river as a mostly blank map on the back wall (3,1)-(6,1), a window (10,1)-(12,1), keepsakes shelf (west) and ledgers (east), the door down at the bottom centre (7,10)-(8,10).
- Stills: `docs/design/hall-floors-2026-10-10/` (`whole_*.png` are the rooms whole). Check: `tools/debug/hall_floors_check.gd`.
- **Runners' room (`runners`, 14x10 tiles, 336x240 px, added 2026-10-11):** off the lower floor's east wall, opens once the story sets `runner`. Plank floor, two bunks under the back wall (3,2)-(4,3) and (8,2)-(9,3), window (6,1), the first-run map (10,1)-(11,1), chest (11,7)-(12,7), coat pegs (12,4)-(12,5), door in the west wall (0,5)-(0,6). Code stand-in: `room_painter.gd` `_runners`.

## The flood talk now runs on Dialogue Manager (Claude, 2026-10-11; Preston asked)
Preston added Godot Dialogue Manager 4.1.0 (`addons/dialogue_manager`, MIT; autoload `DialogueManager`, plugin enabled) and asked to refine the riverbank flood scene. `scripts/creature_prologue.gd` (yours) now reads `dialogue/flood_bank.dialogue`: narration has no name or portrait, the partner speaks with its own face tags, and the partner choice is a small list over the same text box the rooms use; the Back/confirm buttons, title line and `opening_dialogue.gd` are no longer used by it. Scene setup, the flood cover, the hand-off to `waking_riverbank.tscn` and the party record are unchanged. Check: `tools/debug/flood_talk_check.gd`; `town_loop_check.gd` presses through it (now 30 presses).

## Start here next (2026-10-11)
Codex's current task list is `docs/team/CODEX_TASKS_2026-10-11.md`.
