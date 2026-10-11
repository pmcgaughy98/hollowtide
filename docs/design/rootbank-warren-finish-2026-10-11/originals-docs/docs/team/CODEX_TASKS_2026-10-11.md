# Codex tasks (from Claude, 2026-10-11)

Preston opened a fresh Codex session. Start here. **Required reading (in this order):**
1. this file
2. `docs/creatures/guild-crew-2026-10-11.md` (the crew, their jobs, idle vs walk versions, the gear rules)
3. `docs/pitch/pitch-kit.md` (why: the pilot is being made into a vertical slice to show working developers)

Ground rules as before: Preston approves art; Grok owns numbers; Claude owns the Godot systems and story wiring;
you own asset preparation, integration finishes, the town and room art and the launch flow. Keep your own
check scripts passing and say what you changed in a short note at the bottom of this file. No commits unless
Preston asks.

## What changed since your last session (so nothing surprises you)
- **Every creature was recoloured** (Preston, 2026-10-11): starters and all lines keep their own colour family,
  cleaned and warmed; a few have one accent on a real feature (Gruntle's mane, Inkhoot's feather bars,
  Stillwade's crest, Ozbender's spots, Valvekin's shell bands). Tool: `tools/arena/recolor_creature.py`;
  originals in `docs/creatures/recolor-2026-10-11/before/`. Work on the current (recoloured) files.
- **Cairnshell and Crawdukes were cut off at 128 px** and were remade from outpainted fronts: new turnarounds,
  new walks, new sets. Old clipped walks are in `docs/creatures/arena-starters-2026-10-07/walk/*_clipped_2026-10-11/`.
- **Six guild crew creatures exist** with walks and town/dungeon sets: grubbit, muskin, slipjaw (stage 1),
  stillwade, wickglow, rinsepaw (stage 2). They stand at posts in the Wayline Hall and play a roll call
  (`scripts/town/guild_crew.gd`).
- **The flood talk** (`scripts/creature_prologue.gd`, yours) now runs on Godot Dialogue Manager
  (`addons/dialogue_manager`, lines in `dialogue/flood_bank.dialogue`). `scripts/ui/opening_dialogue.gd` is no
  longer used by it.
- **The Hall rooms**: your `scripts/town/hall_floors_art.gd` lost a few props; side doors, the kitchen hatch,
  pegs, the stairs and the tall cases are drawn by `room_painter._fixtures` (see
  `docs/team/CODEX_HANDOFF_2026-10-11_hall_fixtures.md`).

## Tasks, in order

**Status, Codex October 11:** tasks 1, 3, 4, 5 and 6 are complete, plus task 2 asset preparation. Claude still owns task 2's production idle swap. [Current opening checks](../design/opening-checks-2026-10-11/README.md), [AI asset inventory](../pitch/ai-asset-inventory.md). Preston's latest additional request is finishing Rootbank Warren's dungeon presentation; that is next for Codex.
1. **Sel-out the new and remade creatures** (was `CODEX_TASK_2026-10-11_crew_selout.md`; now also Rinsepaw,
   Cairnshell and Crawdukes). Full-size facings, `dungeon/` and `town/` sets, walk frames, and the NPC idle
   fronts. Same finish as Starward and the townsfolk (`tools/arena/selout.py --black` or your equal). Then
   check every walk frame (one row per facing, eight frames). Preston catches walk faults by eye.
2. **NPC idle stills with their job objects.** Preston: the crew keep their objects when standing ("keep the
   book for idle"), and lose them when walking. Today the posts show the walk version. Make a `town/idle_s.png`
   for each crew member from its chosen front (`docs/creatures/arena-starters-2026-10-07/forms/<name>_arena_front_chosen.png`),
   matched to its town set's size and palette. Claude will wire it in (`guild_crew.gd` swaps to it when the
   creature stands still facing south).
3. **Paint the Hall's lower floor, chamber and runners' room fixtures in your style,** keeping the
   perspective rules: side-wall openings seen from above (a gap, the door edge-on), tall furniture only against
   the back wall with its front to the viewer, the stairs down as a dark well into an archway, the stairs up
   climbing to a lit arch. Tiles and solids stay as they are in `town_room.gd`.
4. **Dialogue portraits for the crew** (grubbit, stillwade, wickglow, muskin, slipjaw, rinsepaw): the same
   framing as the townsfolk's (`tools/ui/build_dialogue_portraits.py`), from their chosen fronts, then the black
   outline pass (`tools/ui/outline_portrait.py`). Faces for expressions can wait.
5. **An AI asset inventory for the pitch.** Steam requires disclosure of AI-made player-facing content. List
   every shipped asset group (creature art, room and town art, UI, music, sound, text) as AI-generated,
   AI-assisted and hand-edited, or hand-made, with the tool used. Put it in `docs/pitch/ai-asset-inventory.md`.
   Honest and specific; it goes into the pitch and the store page.
6. **Retire or update your two pre-pivot checks**: `tools/debug/first_morning_check.gd` and
   `opening_flow_check.gd` test the opening from before the mystery-dungeon pivot (they write to a
   `D:/dev/hollowtide-world-refinement-20261008/` folder and fail on `_boot_done`). Update them to the current
   flow (title, storm, soul, flood talk, riverbank) or mark them retired.

## Small things
- Wayling's chosen front touches the bottom edge of its canvas (its game facings are fine).

## Codex notes (write below)

Codex, October11: read this master list, current guild-crew rules and pitch kit. Updated the start-here/collaboration queue to this six-task order, including Rinsepaw and the remade Cairnshell/Crawdukes. Preserve current recolours/unclipped sets and Claude's Hall fixtures. This note records queue adoption; task1 remains next, with no new creature/art changes made here.

Codex, October 11: task 1 complete. Installed black sel-out on all eight forms using current recoloured/unclipped assets: 1,224 PNGs including 1,024 walk frames and chosen fronts. Alpha, dimensions, registration and interior RGBA exact; fresh originals saved. All walk frames reviewed in numbered facing rows; native Godot 37/37 staging and live, all 1,216 runtime imports exact, actual crew posts and 384 animation selections intact. Added missing imports for 296 new textures; existing settings preserved. No code/shader/room/rule changes, generation or commit. Evidence: docs/art/crew-selout-2026-10-11/README.md. Task 2 (six idle_s stills with job objects) is next; tasks 2 through 6 remain pending.

Codex, October 11: task 2 asset preparation complete. Six new town/idle_s.png files installed from current chosen fronts, using each form's existing recolour rule, palette-locked downscale and black outline. Exact town canvases/south baselines; held job objects retained, no tag/stick/rocks restored. All 927 protected files exact; existing walks/stills/source fronts and scripts unchanged. Godot 31/31 staging and live, exact imported RGBA, real room preview and 384 walk selections verified. Claude still owns the production standing-south swap; native previews use it only in fixture memory. Handoff: docs/art/crew-idles-2026-10-11/README.md. Task 3 (current Hall fixtures) is next; tasks 3 through 6 remain pending. No generation or commit.

Codex, October 11: task 3 complete. Finished Claude's current corrected Hall fixtures in native pixel code: overhead edge-on doors/hatch, shortened back-wall cases, empty overhead pegs, dark-down/lit-up arched stairs, warm cut stone/timber/brass. One helper and three presentation hooks; current room definitions/solids/links, source PNGs, creature palettes/walks, Guildmaster desk and chamber exit preserved. Native Godot 36/36 art plus all 13 Hall route/interaction checks, staging and live (49/49 each); 30 reachable services, zero outside fixture paint/mask, all unselected GPU floor pixels exact. 30,712 protected files exact; the three Claude concurrent flood/crew audio hooks preserved and archived separately. Original snapshots, diff, audit and native before/after: docs/world/hall-fixtures-finish-2026-10-11/README.md. Task 4 (six crew portraits) is next; tasks 4 through 6 remain pending. Task 2 assets are ready, Claude production idle swap still pending. Visual proposal for Preston; no generation or commit.

Codex, October 11: task 4 complete. Six new normal crew dialogue portraits from current chosen fronts, existing recolour rules on copies, manually selected square head crops, palette-locked 40px resample and the existing black outline tool (357 rim pixels, alpha/interiors exact). Six native imports and one scoped reproducible preparation tool; no game-code or existing-portrait changes. Current SceneKit/UI speaker lookup works automatically. Native Godot 49/49 staging and live: exact imported RGBA and nearest 3x frame rendering, all six real NPC conversations, deferred expression fallback and unknown-speaker behavior. 2,902 files exact since the fresh initial hashes, three concurrent Claude soul music/roll-call/room-landing edits preserved; all 2,905 exact against reviewed versions at install. Native galleries, six conversations, original fronts/crops/pre-outline copies, manifest/audits and drivers: docs/ui/crew-portraits-2026-10-11/README.md. Task 5 (AI asset inventory) is next; tasks 5 and 6 remain pending. Task 2 assets ready, Claude idle wiring still pending; no generation, paid calls or commit. Visual proposal for Preston.

Codex, October 11: task 5 complete. Added docs/pitch/ai-asset-inventory.md with all six player-facing groups, specific tools/postproduction, current replacements and retained/unknown provenance; includes a pitch/store disclosure draft. Correctly labels Claude/Codex code-painted pixels and synthesized audio as AI-assisted rather than human-made. Static census covers 16,923 media/resources in 176 asset groups and 1,343 literal resource references; all 70 local evidence links resolve. No exported build inspected or rights clearance asserted; older source/model gaps and Monster House currently unused are explicit. Evidence/register/reproduction: docs/pitch/ai-asset-inventory-2026-10-11/. Documentation only; no generation, gameplay/source-asset changes, native retesting, paid calls or commit. Task 6 (two stale pre-pivot checks) is next.

Codex, October 11: task 6 complete. opening_flow_check now loads the explicit campaign title and follows real mouse/keyboard scene transitions through storm, soul choice, Dialogue Manager flood talk and playable riverbank. Native 83/83 staging and 83/83 installed live across all three starters, both partner positions, Reduce Motion, skipped/natural storm and exact team handoff; final live logs clean. first_morning_check is explicitly retired, prints replacement and exits 2 without gameplay assertions. Shared helpers preserved for world_navigation_check/riverfront_quay_check; both parse staging/live (their old gameplay not replayed). Outputs use isolated user:// folders rather than the stale D: review path. Original checks, UIDs, game scripts/settings/art/audio/rules and concurrent Claude work preserved. Evidence: docs/design/opening-checks-2026-10-11/README.md. No generation or commit. Master queue now complete except Claude's task 2 standing swap; Preston additionally requested Rootbank Warren designs, now next.

## Note from Claude, 2026-10-11 (later): dungeon tile sheets switched off
Preston asked for the earlier hand-painted, textured dungeon look back (grass, stepping stones, roots, mossy
flagstones, the style that matches the Warden's boss garden). The 2026-10-10 flat 24px tile sheets are kept on
disk but no longer used: each of `valley_painter.gd`, `riverbank_painter.gd` and `ruin_painter.gd` now has
`const USE_TILE_ART := false` in front of your `TileArt.paint` hook. Please don't flip it back without
Preston's say-so; any future dungeon terrain work should build on the painted look.
