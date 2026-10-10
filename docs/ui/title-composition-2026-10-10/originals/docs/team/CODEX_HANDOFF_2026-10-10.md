# Codex: what changed on October 9, and your next jobs (written by Claude)

## October 10 jobs (written by Claude, in this order)

Preston, October 10: "need tasks for codex as well, also the wayline hall door needs widened to meet the path but so far the map rigging is working for codex." Your Highbank map rigging works; these build on it.

1. **Paint the Wayline Hall door two tiles wide.** The layout now gives the hall `door_tiles` `(23, 6)` and `(24, 6)`, matching its two-tile steps `Rect2i(23, 7, 2, 2)`; both tiles walk and answer E as the hall. `"door"` is still `(24, 6)`. In `scripts/town/highbank_ground_painter.gd` both door draws read `place["door"]` only; use `Layout.door_tiles(place)` so the opening spans both tiles and lines up with the steps. Checks: `tools/debug/hall_door_check.gd`, `tools/debug/hub_town_check.gd`, plus a native capture of the hall front.
2. **Re-run your pause-menu checks.** I added pages to your `scripts/ui/game_pause_menu.gd` (TEAM, BAG, FLOOR, MESSAGE LOG, from Explorers of Sky's dungeon menu and pokered's start menu). Your buttons, names, focus wrap, prefs and leave flow are unchanged; the new buttons sit between Resume and Options, which moves Options down the list. Your original is in `docs/ui/field-menu-2026-10-10/originals/`. My check: `tools/debug/field_menu_check.gd`.
3. **Give the field pages their look.** They are text only. Yours to design: each teammate's portrait (the front idle frames you already crop for the opening), a health bar, the evolve bar (level plus conditions, the same purple as the dungeon HUD), item icons in BAG. Keep the button names (`Team`, `Bag`, `Floor`, `Log`, `Use_<item>`) and the label text the check reads, or update the check with it.
4. **The Growth Shrine screen in town.** Its service is `growth`; it should show what TEAM shows (level, IQ, the evolve conditions) with room for the learnset once Grok answers `docs/creatures/learnset-draft-2026-10-10.md`. The numbers come from `dungeon.gd` (`EVO`, `EVO_LEVEL`, `levels`); read them, do not copy them.
5. **Settle the main scene.** `project.godot` has `run/main_scene` set to `scenes/hollow_floor.tscn` (uncommitted, not mine). The opening is yours; put F5 back where you and Preston want it.
6. **Still open from October 9:** the hall as the dungeon guild (board, roster, dispatch, return) and the emotion portraits.

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
