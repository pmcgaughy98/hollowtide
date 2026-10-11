# Start here for the next Codex chat, 2026-10-11

Live project: **C:/Users/pmcga/dev/hollowtide**. Codex's writable workspace is **D:/dev**. The old Documents/Hollowtide/2026-10-08 handoff is historical; use this current live project.

Preston's latest completed request: task 6, current opening checks. Native 83/83 staging and installed live, with the old first-morning entry explicitly retired and inherited helpers preserved. Evidence: `docs/design/opening-checks-2026-10-11/README.md`. **Latest active request: finish Rootbank Warren dungeon presentation**, using current Claude wiring/layouts and preserving rules. The six-task master queue is complete except Claude's production task 2 idle swap.

## Read before work

1. Live `AGENTS.md`, `CLAUDE.md`, and the top/latest entries in `docs/AI_COLLABORATION.md`.
2. **Current master queue: `docs/team/CODEX_TASKS_2026-10-11.md`.** Read it, `docs/creatures/guild-crew-2026-10-11.md`, then `docs/pitch/pitch-kit.md`, in that order. It supersedes the five-creature queue, the Rinsepaw exclusion and the older portrait assignment. Read the Hall fixture handoff for current perspective/positions; the October10 main handoff is background, not the current task order.
3. `docs/ui/crew-portraits-2026-10-11/README.md`, `docs/world/hall-fixtures-finish-2026-10-11/README.md` and `docs/world/world-selout-2026-10-11/README.md` for current scope/evidence. Older Hall-floor snapshots predate Claude's corrected fixtures.

## Latest completed work

**Opening checks:** task 6 complete. New real campaign-flow check; retired human-courier first-morning run returns 2, helpers retained. Native 83/83 staging/live; old helper inheritors parse. `docs/design/opening-checks-2026-10-11/README.md`. Rootbank Warren presentation is now the user's active additional request.

**AI asset inventory:** task 5 complete. `docs/pitch/ai-asset-inventory.md` records all six player-facing groups/tools, current audio replacements, unknown older sources and a pitch/store disclosure draft. The dated evidence folder contains the 176-group static census, reference index and 70-link validation. Documentation only; final export inclusion and account/output rights remain to reconcile. Task 6 is next.

**Six crew dialogue portraits:** task 4 complete. New 40px normal headshots from current chosen fronts, matching existing recolour/crop/resample/black-outline rules. Exact native RGBA and 3x frame rendering; all six current Hall conversations resolve automatically, expressions fall back to normal. Native 49/49 staging/live. No game-script or prior portrait changes; Claude's concurrent soul music, roll-call staging and room landings preserved. `docs/ui/crew-portraits-2026-10-11/README.md`. Task 5 documentation is now complete; task 6 is next.

**Current Hall fixtures:** task 3 complete. Native pixel finish over Claude's corrected fixtures: edge-on doors/hatch, shortened back-wall cases, empty pegs, dark-down/lit-up arched stairs. One helper and three art/mask hooks, no PNG/layout/system changes. Native 36/36 art plus 13/13 route/interaction checks staging/live; 30,712 protected files exact; three concurrent Claude audio hooks preserved. Current screenshots, originals, diff and audit: `docs/world/hall-fixtures-finish-2026-10-11/README.md`. Task 4 is now complete; task 5 documentation is complete; task 6 is next.

**Six crew idle assets:** task 2 preparation complete; six `town/idle_s.png` files with current recolour rules, job objects, exact town canvases and south baselines. Native Godot 31/31 staging/live; original PNGs and scripts exact. `docs/art/crew-idles-2026-10-11/README.md`. Claude owns production idle wiring; tasks 3 and 4 are now complete; task 5 documentation is complete; task 6 is next for Codex.

**Eight-creature sel-out:** task 1 complete, including Rinsepaw and rebuilt Cairnshell/Crawdukes. 1,224 PNGs; all 1,024 walk frames inspected. Fresh originals, exact alpha/dimensions/interiors, native Godot 37/37 staging/live and all 1,216 runtime textures verified. No game code or shader changes. `docs/art/crew-selout-2026-10-11/README.md`. Task 2 assets are now complete; Claude owns their production swap.

**Growth Shrine information screen:** new `scripts/ui/shrine_info.gd` plus three small `hub_town` hooks. Browsable team portraits, level/IQ/next form/four condition bars, Growth and Moves pages, current/next LEARN, unavailable WAITING and queued next-run choices, using existing frames and creature finish. Pond-stone gate, stone installation, evolution and rules unchanged. Native26/26 staging; final live27/27, plus current town/evolution/field-menu checks. Full handoff/evidence: `docs/ui/shrine-info-2026-10-11/README.md`. Codex is out of hub_town; no generation or commit.

**Highbank world:** new `scripts/town/world_finish.gd`; one return hook in highbank_painter and one map-material hook in hub_town. Shared CPU material rim + existing masked shader0.55 on joined road borders, cliff lips/faces and switchback treads. All13 landmarks and their foundations/shadow/approach margins, river/water/glints, quiet grass/clay/stone interiors and grid preserved. No source PNG edits or generation. Native21/21 comparisons pass; hub services/routes, walking and both Hall doors pass. Exact images, originals, diff, protected hashes and test logs in the world archive.

**Wayline Hall:** lower Hall720x432, Starward chamber408x264, runners336x240, upper stairwell48x48 on tiles14,10..15,11. Rooted timber/limestone/teal/brass sprites; shared sel-out + masked0.75 detail. Reused original Hall pillars/ferns; empty runners' pegs match text. Built-in imagegen5 calls, original outputs and exact prompts archived.39 versioned PNGs in `assets/sprites/world/hall_floors_2026_10_11/`; new hall_floors_art helper and two presentation lines each in room_painter/town_room. Preserved Claude's concurrent chamber17x11 resize, centered tile8, rug216x120, window96x32, east shelf tile15 and three-tile exit. Art hook runs AFTER _guild_desk to preserve its cleared counter mask. Native art24/24 staging,23/23 live;13 Hall-floor assertions and existing Home/Hall/guild story checks pass. Archives contain source snapshots before and after concurrent changes.

**Previously finished:** Bag field page with existing icons/focused list/details (29/29 plus field menu); quiet native24px dungeon atlases and opaque darkness (26/26); detailed Guildmaster desk192x52 at168,70 depth116, blockersrows3/4 and row2 open; detailed world tiles and river/bench/dock props; title/launch pixel frames; Home and earlier Hall interior art; finished town exteriors/Job Board. See AI_COLLABORATION for links. Do not recreate these.

## Claude's current changes to preserve

Claude is actively editing. Inspect Git dirty state and current files before making changes; never reset/stash/revert/commit without Preston's instruction. Code snapshots can become stale even during generation.

- **Dialogue Manager4.1.0**, `addons/dialogue_manager`, `DialogueManager` autoload and plugin, `dialogue/flood_bank.dialogue`. Creature prologue now uses it: narration without portrait/name, partner expression tags, choices over shared room-style box. Older Back/confirm/header/opening_dialogue presentation is unused. Do not restore the old prologue. New checks: `tools/debug/flood_talk_check.gd`, updated `town_loop_check.gd` (30 presses).
- Revised Warden boss staging and `boss_intro.gd` / dungeon changes are his current work. Inspect current source and test before taking those files. Current isolated `dungeons_check` passed5/5 assertions during this world pass, including both rival moves, floor styles, Warden/pond staging and town dungeon selection.
- New creature/guild-crew art is being generated and new files may appear. Preserve current art, original takes/backups, all source PNGs, installed seven-form refinements, darker jade Oxbowarchon, Starward all sprites/portraits/fringe, Sparkwick brown correction, Skimlet leg-dot correction and Gruntle portrait clipping/outline.
- **New Hall fixture perspective corrections:** Claude removed the former face-on side doors/hatch, stairs-down and side-wall tall cases from `hall_floors_art.gd`; `room_painter._fixtures` now draws side openings edge-on, stairs as a dark well, and shortened cases against the back wall. Solids/spots moved with them; chamber lamps moved to55/343. Preserve these current changes, not the older finished-room snapshots. Read `docs/team/CODEX_HANDOFF_2026-10-11_hall_fixtures.md`.
- **Latest creature sources:** every creature has been recoloured; preserve the current colours and `docs/creatures/recolor-2026-10-11/before/` originals. Cairnshell/Crawdukes were remade from outpainted fronts with new turnarounds/walks/sets; do not use their older clipped walks. All six crew including Rinsepaw now have sets and posts/roll call in `guild_crew.gd`. The master task list supersedes the earlier Rinsepaw wait and five-creature scope.
- Original town layout, collision, services, story gates (including runners' `runner` flag), team/state/save and Grok's creature/move rules are Claude/Grok scope. Codex leads visual preparation/integration by default.

## Completed master queue and current request

Follow **`docs/team/CODEX_TASKS_2026-10-11.md`**, Claude's current master queue, in this order. Re-read it before each slice because Claude is still working.

1. **DONE: Sel-out eight new/remade creatures:** Grubbit, Muskin, Slipjaw, Stillwade, Wickglow, Rinsepaw, Cairnshell and Crawdukes. Cover full-size facings, town/dungeon stills and every walk frame, plus chosen NPC idle fronts. Work on current recoloured files and new unclipped sets. Preserve current palette/silhouette, job gear and original backups; inspect numbered eight-frame rows for every facing.
2. **ASSETS DONE, CLAUDE WIRING PENDING: NPC idle stills with job objects:** prepare `town/idle_s.png` for each of the six crew from its current chosen front, matching town size/palette. Standing keeps the job objects; walking follows the approved held-object removal rules. Claude wires the idle swap in `guild_crew.gd`.
3. **DONE: Finish current Hall fixtures:** lower floor, chamber and runners' room, preserving `town_room.gd` tiles/solids and Claude's installed perspective correction. Side openings are edge-on; tall furniture belongs on the back wall; down stairs form a dark well/arch, up stairs climb to a lit arch. Read `CODEX_HANDOFF_2026-10-11_hall_fixtures.md`.
4. **DONE: Six crew dialogue portraits:** Grubbit, Stillwade, Wickglow, Muskin, Slipjaw and Rinsepaw, using the townsfolk framing and current chosen fronts, then black outline. Expression faces can wait. This direct assignment supersedes the older Claude-only portrait note.
5. **DONE: AI asset inventory for the pitch:** `docs/pitch/ai-asset-inventory.md`, with evidence-backed shipped asset groups, tools and AI-generated/AI-assisted/hand-edited/hand-made provenance. Do not invent unknown provenance or describe generated art as hand-drawn.
6. **DONE: Update or retire pre-pivot checks:** `first_morning_check.gd` and `opening_flow_check.gd`, following the current title/storm/soul/flood-talk/riverbank flow. Do not restore obsolete `_boot_done` flow to make old tests pass.

Small follow-up from the master list: Wayling's chosen front touches its bottom canvas edge; game facings are fine. Preserve those facings.

Finished before this queue: Growth Shrine information/exterior/evolution, Bag, world/terrain/sel-out, the earlier Hall art and launch frames. Claude's `party_screen.gd` already handles TEAM presentation. The newly requested fixture work refines Claude's current corrected layout, rather than reinstalling the earlier Hall snapshot. Older guild-roster/F5 requests are background; the master list sets current priority. F5 remains Claude's current dungeon development scene unless Preston directs a change.

The user wants polished handmade-looking art, consistent purpose-building black internal detail and material sel-out, quiet walking floors, proper raised wall tiles, top-left light and locked dungeon palettes. Source art and backup preservation are standing requirements. New art is a proposal until Preston approves.

## Safe workflow and tools

- Work staging: `D:/dev/hollowtide-world-refinement-20261008/project`. Sync **current live** dependencies before tests; never blanket-copy staging back into live. Hash-guard only owned files and rebase tiny hooks if Claude changes them. Preserve originals in a versioned docs archive.
- Current portrait work: `D:/dev/hollowtide-crew-portraits-20261011`, `python run.py verify --live`. New builder: `tools/ui/build_crew_dialogue_portraits.py`, using fresh output/evidence directories. Existing dialogue portraits, chosen sources and old builder outputs must be preserved. Native import and six Hall conversations are verified.
- Current Hall fixture work: `D:/dev/hollowtide-hall-fixtures-20261011`; `python run.py check --live` and `python run.py hall_floors --live`, with isolated APPDATA profiles and hidden native Godot processes. Older `hollowtide-hall-floors-finish-20261011/art_check.gd` predates Claude's fixture corrections; its snapshots are historical. World work: `D:/dev/hollowtide-world-selout-20261011`, `python run.py verify --live`. Native OpenGL rendering is required for shader proof; headless is for parsing/logic only. Private teardown frees persistent Music to avoid misleading ObjectDB leaks.
- Python: `C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
- Godot: `C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe`.
- Live C: installs/native runs require scoped `require_escalated`; automatic review has approved task-authorized edits. No need to ask Preston again. Never stop a live editor/Claude process; only exact owned test command lines if a fixture hangs.
- Read imagegen SKILL before future generation. Use built-in imagegen, inspect refs first, real alpha for props, sibling versioned assets, native crop/nearest prep only; archive exact prompts and unmodified sources. Never paid Retro calls without explicit authorization. Firecrawl is available if new research is needed; synthesize reference structures, never copy another game's art/code/data.
- No proactive subagents permitted unless Preston or applicable instructions request them. Do not send messages to Claude/other chats without user authorization. Do not create a new chat automatically; Preston asked for this handoff, not dispatch to another chat.
- Communicate concise progress and finish one visible runnable slice with native checks and a handoff. No permission loop for routine authorized work.

Suggested new-chat prompt: **Continue Hollowtide from C:/Users/pmcga/dev/hollowtide/docs/team/CODEX_START_HERE_2026-10-11.md. Read it first, then project instructions and latest collaboration/handoff notes. Inspect current work and preserve Claude's concurrent changes, installed art/palettes and originals.**
