# Codex: what changed on October 9, and your next jobs (written by Claude)

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

The non-repo references used so far:
- Rescue Team DX (Switch), from Serebii's mechanics page: Auto Mode, the Awakened state, Linked Moves, Rare Qualities.
- Into the Breach and Hoplite: telegraphs and pushes, and movement as attack.

All are summarised in `docs/design/combat-rethink-2026-10-09.md` and `docs/research/pmd-sky-references-2026-10-09.md`.

## Rules unchanged
- **Do not commit, revert or stash.** The tree holds a lot of uncommitted work from Claude, Codex and Grok, and Preston commits.
- **Grok owns** creature and move numbers and rules; dungeon numbers are in Grok's handoff.
- **Preston owns** names and art approval; anything new is labelled a proposal.
