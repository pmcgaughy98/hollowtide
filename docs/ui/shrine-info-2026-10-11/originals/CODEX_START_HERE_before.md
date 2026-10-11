# Start here for the next Codex chat, 2026-10-11

Live project: **C:/Users/pmcga/dev/hollowtide**. Codex's writable workspace is **D:/dev**. The old Documents/Hollowtide/2026-10-08 handoff is historical; use this current live project.

Preston's latest requests: finish sel-out on the world, then prepare a new-chat handoff to save usage. The preceding request was detail/sel-out on Claude's rebuilt Wayline Hall wiring. Both visible slices are installed. Do not redo finished work or overwrite Claude's concurrent code.

## Read before work

1. Live `AGENTS.md`, `CLAUDE.md`, and the top/latest entries in `docs/AI_COLLABORATION.md`.
2. Re-read **current** `docs/team/CODEX_HANDOFF_2026-10-10.md`; Claude keeps appending tasks. Its old progress and scene statements may be superseded. In particular, its chamber16x11 note is stale: live chamber is17x11.
3. `docs/world/world-selout-2026-10-11/README.md` and `docs/world/hall-floors-finish-2026-10-11/README.md` for latest installed scope/evidence.

## Latest completed work

**Highbank world:** new `scripts/town/world_finish.gd`; one return hook in highbank_painter and one map-material hook in hub_town. Shared CPU material rim + existing masked shader0.55 on joined road borders, cliff lips/faces and switchback treads. All13 landmarks and their foundations/shadow/approach margins, river/water/glints, quiet grass/clay/stone interiors and grid preserved. No source PNG edits or generation. Native21/21 comparisons pass; hub services/routes, walking and both Hall doors pass. Exact images, originals, diff, protected hashes and test logs in the world archive.

**Wayline Hall:** lower Hall720x432, Starward chamber408x264, runners336x240, upper stairwell48x48 on tiles14,10..15,11. Rooted timber/limestone/teal/brass sprites; shared sel-out + masked0.75 detail. Reused original Hall pillars/ferns; empty runners' pegs match text. Built-in imagegen5 calls, original outputs and exact prompts archived.39 versioned PNGs in `assets/sprites/world/hall_floors_2026_10_11/`; new hall_floors_art helper and two presentation lines each in room_painter/town_room. Preserved Claude's concurrent chamber17x11 resize, centered tile8, rug216x120, window96x32, east shelf tile15 and three-tile exit. Art hook runs AFTER _guild_desk to preserve its cleared counter mask. Native art24/24 staging,23/23 live;13 Hall-floor assertions and existing Home/Hall/guild story checks pass. Archives contain source snapshots before and after concurrent changes.

**Previously finished:** Bag field page with existing icons/focused list/details (29/29 plus field menu); quiet native24px dungeon atlases and opaque darkness (26/26); detailed Guildmaster desk192x52 at168,70 depth116, blockersrows3/4 and row2 open; detailed world tiles and river/bench/dock props; title/launch pixel frames; Home and earlier Hall interior art; finished town exteriors/Job Board. See AI_COLLABORATION for links. Do not recreate these.

## Claude's current changes to preserve

Claude is actively editing. Inspect Git dirty state and current files before making changes; never reset/stash/revert/commit without Preston's instruction. Code snapshots can become stale even during generation.

- **Dialogue Manager4.1.0**, `addons/dialogue_manager`, `DialogueManager` autoload and plugin, `dialogue/flood_bank.dialogue`. Creature prologue now uses it: narration without portrait/name, partner expression tags, choices over shared room-style box. Older Back/confirm/header/opening_dialogue presentation is unused. Do not restore the old prologue. New checks: `tools/debug/flood_talk_check.gd`, updated `town_loop_check.gd` (30 presses).
- Revised Warden boss staging and `boss_intro.gd` / dungeon changes are his current work. Inspect current source and test before taking those files. Current isolated `dungeons_check` passed5/5 assertions during this world pass, including both rival moves, floor styles, Warden/pond staging and town dungeon selection.
- New creature/guild-crew art is being generated and new files may appear. Preserve current art, original takes/backups, all source PNGs, installed seven-form refinements, darker jade Oxbowarchon, Starward all sprites/portraits/fringe, Sparkwick brown correction, Skimlet leg-dot correction and Gruntle portrait clipping/outline.
- Original town layout, collision, services, story gates (including runners' `runner` flag), team/state/save and Grok's creature/move rules are Claude/Grok scope. Codex leads visual preparation/integration by default.

## Next when Preston says “next”

Inspect the newest handoff first. **Growth Shrine's detailed information screen (handoff job4)** remains the next known pending visual task, showing existing level/IQ/evolution conditions/moves. Its exterior and existing evolution presentation ARE already installed and checked: `docs/world/growth-shrine-finish-2026-10-10/README.md`. The older folder `D:/dev/hollowtide-shrine-finish-20261010` belongs to that completed exterior/evolution slice, not an uninstalled screen candidate. Do not install its stale scripts or regenerate the Shrine exterior. Read the live `_shrine_panel`, evolution/UI/LEARN/WAITING code and current pond-stone gate; reuse pixel frames/portraits/condition data. First verify whether Claude has already added the information screen. Do not copy or invent rule numbers. A later explicit request from Preston takes priority.

The user wants polished handmade-looking art, consistent purpose-building black internal detail and material sel-out, quiet walking floors, proper raised wall tiles, top-left light and locked dungeon palettes. Source art and backup preservation are standing requirements. New art is a proposal until Preston approves.

## Safe workflow and tools

- Work staging: `D:/dev/hollowtide-world-refinement-20261008/project`. Sync **current live** dependencies before tests; never blanket-copy staging back into live. Hash-guard only owned files and rebase tiny hooks if Claude changes them. Preserve originals in a versioned docs archive.
- Latest fixture work: `D:/dev/hollowtide-world-selout-20261011`; Hall fixtures: `D:/dev/hollowtide-hall-floors-finish-20261011`. Both run.py scripts use isolated APPDATA profiles and hidden native Godot processes; `python run.py verify --live` for world; Hall `art_check` and `hall_floors` modes. Native OpenGL rendering is required for shader proof; headless is for parsing/logic only. Private teardown frees persistent Music to avoid misleading ObjectDB leaks.
- Python: `C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
- Godot: `C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe`.
- Live C: installs/native runs require scoped `require_escalated`; automatic review has approved task-authorized edits. No need to ask Preston again. Never stop a live editor/Claude process; only exact owned test command lines if a fixture hangs.
- Read imagegen SKILL before future generation. Use built-in imagegen, inspect refs first, real alpha for props, sibling versioned assets, native crop/nearest prep only; archive exact prompts and unmodified sources. Never paid Retro calls without explicit authorization. Firecrawl is available if new research is needed; synthesize reference structures, never copy another game's art/code/data.
- No proactive subagents permitted unless Preston or applicable instructions request them. Do not send messages to Claude/other chats without user authorization. Do not create a new chat automatically; Preston asked for this handoff, not dispatch to another chat.
- Communicate concise progress and finish one visible runnable slice with native checks and a handoff. No permission loop for routine authorized work.

Suggested new-chat prompt: **Continue Hollowtide from C:/Users/pmcga/dev/hollowtide/docs/team/CODEX_START_HERE_2026-10-11.md. Read it first, then project instructions and latest collaboration/handoff notes. Inspect current work and preserve Claude's concurrent changes, installed art/palettes and originals.**
