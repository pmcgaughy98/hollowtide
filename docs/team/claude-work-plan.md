# Claude's Hollowtide work plan

**Started 2026-09-28 at Preston's request:** a standing queue so Claude always has a next task. It follows
`THE_CONCEPT.md` scope order, `docs/team/claude-next-shift-handoff.md`, and the role charter (Claude leads Godot
systems and battle architecture; Codex asset prep and wiring; Gemini research; Grok balance and
non-creature art; Opal the Forges; Preston approves art, lore, move feel and releases).

**2026-10-02.** Preston assigned Grok future creature and move rules. Read the top of `docs/AI_COLLABORATION.md` before this queue. The win trigger and the body gate are already in the scripts. HP between battles and saving are still open here. Do not rebuild evolution, and do not copy proposal stats or kit swaps into the creature files.

**How to use it:** take the first task that is not done and not waiting on Preston. One task per session,
ending in something he can press Play on. Mark it done here with the date and what was verified. If
Preston asks for something else, his request wins; slot it in and carry on after.

Status keys: **NOW** in progress · **NEXT** ready · **WAIT** needs a Preston decision first · **LATER** after its phase.

## Phase A: battle feel (current)

| # | Task | Status | Done when |
|---|---|---|---|
| A1 | **Molten Glass Forge art.** Run the Effect Forge in MODE ACTION for heavy molten-glass globs and an on-target splash; convert, swap in for the hand-made 2-4 px globs in `assets/sprites/effects/vitrecrag/`. **2026-09-28: built.** Preston generated the sheet; `tools/cut_molten_glass_effect.py` cuts eruption, three flight globs, splash and crust into `assets/sprites/effects/vitrecrag/forge_molten_glass/`, wired into the gush and lob scenes. Verified in a scripted battle. | Awaiting Preston's look | Pour preview shows Forge glass; Preston approves or keeps the hand-made globs. |
| A2 | **Battle framing for big foes.** The current visible-foot lines, player-side size cap, and HUD layout show Vitrecrag fully on both sides in Summer captures (2026-09-29). Keep this framing. Attack focus near the top still needs a separate shot review. | NEXT: attack shot review | Vitrecrag and an ordinary foe remain fully readable during their attacks. |
| A3 | **One action timeline for every move.** Fold the pieces built for Molten Glass (hit frame, brace, emitter, volley) into a documented per-move timeline. Put Molten Beam (connected, sustained) and Molten Cannon (one heavy launched mass, separate impact) on it. | NEXT | Vitrecrag's three ranged moves read as three different physical attacks. |
| A4 | **Contact tuning.** The generic travel calculation now uses a 2 px edge margin and an 80% centre-distance cap (2026-09-29). The cap can leave a larger visual gap. The player HP card still covers part of the attacker at contact; Shoulder Drive and other melee moves still need a review before wider CONTACT tagging. | NEXT: HUD and move review | Contact reads clearly without covering either creature or the HP card. |
| A5 | **Your-side attacks.** Drawn frames are skipped for back sprites. Decide per move whether the back view gets emitters, a volley, or its own frames. **2026-09-28: Molten Glass done** via `attack_back_frames` (glowing furnace frames from `tools/build_vitrecrag_back_pour.py`), `attack_back_emitter_offset`, and glass drawn behind the attacker; preview `scenes/vitrecrag_back_pour_preview.tscn`. Other moves still use the plain projectile from behind. | Molten Glass awaiting Preston's look |
| A7 | **Big creatures on your side.** The player-side foot line and size cap now keep Vitrecrag's rear body and feet above the message box in the current battle view. Verified in a Summer back-pour preview capture (2026-09-29). | DONE for idle framing | A 1.75x partner is fully readable from behind. |
| A6 | **Hit and guard reactions.** Defender body reaction on impact and a visible brace for Guard, using whole-sprite motion first. | LATER | A guarded and an unguarded hit look different. |

| A8 | **Vitrecrag Plate Lunge.** Built 2026-09-28 per the attack-sheet protocol: frame library, analysis, in-game body with transplanted lowered head and a sliding plate, contact charge with wind-up. **v2 after Preston's review:** whole Opal poses cut at their true grid so the body and legs move. See `assets/sprites/creatures/attacks/vitrecrag_plate_lunge/README.md`. | Awaiting Preston's look |
| A9 | **Molten Glass recheck against the research** (Preston): re-cut all four Molten Glass body sheets, look for the head-retraction hole with lava in it, and rebuild if better frames exist. **Analysis done 2026-09-28** (lava-pour README): v2 order proposed using sheet 4's glowing retraction hole, the shell flood, and three drawn pours. **v2 built 2026-09-28** with whole poses (sheet 2 backbone, sheet 4 lava hole, sheet 1 pour). Style match handed to Codex. | Awaiting Preston's look |

## Phase B: creatures that persist (scope step 7)

| # | Task | Status | Done when |
|---|---|---|---|
| B1 | **Individual creature state.** `PartyMember` carries its own HP, move uses and placeholder level/XP; battle entry, exit, capture, fainting and switching update one individual. `CreatureData` stays species data. | NEXT (after A2 or A3) | HP carries from one encounter to the next. |
| B2 | **Save and load.** Versioned save file with defaults for missing fields. | LATER | Quit, relaunch, same party and HP. |
| B4 | **2v2 battles with an ally (campaign partner).** Replace the fixed one-player/one-foe fields in `battle_screen.gd` with battle slots (creature, sprite, home, facing, HP card, chosen action), then turn order across all slots, a target choice, ally AI, and two HP cards per side. The attack code is already slot-ready: every effect is placed from the attacker's and target's sprites (`_emitter_point`, mirroring, zoom), and the back view serves both you and an ally. Needs B1 first; slot positions need a Preston layout pass. | LATER (after B1) | A 2v2 preview where you and an ally each attack, from the back view, at two foes. |
| B3 | **Evolution play review.** The win trigger is already the rule for any form with `evolves_into` (`docs/creatures/evolution-and-signatures.md`, 2026-10-02). It was checked headless, not in a played battle. A normal battle still needs to show the change. Do not replace the trigger, and do not add levels. | NEXT after B1 | One normal battle shows the evolution and carries the owned creature's state. |

## Phase C: the first courier route (scope step 8)

| # | Task | Status | Done when |
|---|---|---|---|
| C1 | **Play review of `scenes/first_route_prototype.tscn`** end to end; list what breaks. | NEXT (can run any session) | A written list of issues with file paths. |
| C2 | **Route in the real game flow.** Keep `main.tscn` as the intended normal start after the active battle-preview session finishes (decision 2026-09-29); another Summer editor currently keeps `vitrecrag_pour_preview.tscn` in `project.godot`. The first route stays on F6 until its opening camera and complete journey are reviewed. | NEXT after C1 | Press Play, walk the reviewed route, battle, return. |
| C3 | **Habitat encounter pools** per route; no late evolutions in early grass. | LATER | Each route area draws from its own pool. |
| C4 | **Overworld layering and occlusion plan** for three-quarter trees and buildings (Grok makes the art, Codex imports). | LATER | Courier walks behind and in front of props correctly. |

## Phase D: keeping the project healthy (slot in whenever)

- **D1 Reusable battle review harness.** Turn this session's scripted driver (start a preview, fire a move, log frames, HP and screenshots) into `tools/` or `tests/` so every move change is checked the same way.
- **D2 Smoke test refresh.** `tests/field_encounter_smoke.gd` was last updated for an older cast; bring it in line and run it.
- **D3 Project hygiene check.** A small script that flags missing `res://` paths and any `class_name` defined twice. Two duplicate class names broke every battle until 2026-09-28.
- **D4 Ember move kits.** Once Preston approves names from `docs/creatures/ember-creature-physiology-and-action-brief-2026-09-27.md`, put each form's four moves on the A3 timeline.

## Waiting on Preston (short list)

1. **Decided for the current prototype on 2026-09-29:** keep the HUD-safe foot lines and size cap for big creatures; use a 2-pixel calculation margin and an 80% contact travel cap; return normal Play to `main.tscn` after the active preview session. The Cinderhide-only evolution limit in this item was superseded on 2026-10-02. Any form with a link evolves on a win. Details are at the top of `docs/AI_COLLABORATION.md`.
2. Still to review in play: contact crossing the player HP card, attack focus near the top edge, and the complete first-route loop before promoting it to normal Play.
3. Names and lore for new forms and moves stay Preston's; Claude drafts proposals only when asked.

## Not Claude's lead

New creature sprites and effect art candidates (Opal via Preston or Claude on request), non-creature
environment art (Grok), exact asset import and resource wiring (Codex), balance numbers (Grok), historical
research (Gemini). Claude reviews and integrates when asked.

## Log

- 2026-09-28: fixed duplicate class names breaking battles; reviewed Cinder Claw contact both sides;
  built Molten Glass head-retract pour with brace, gush, eruption, surges and a volley that reaches the
  target. Details in `docs/AI_COLLABORATION.md`.
- 2026-10-12: the crew's standing-south job-object stills (Codex task 2) were already wired in scene_kit.spawn on
  2026-10-11; added the roll-call check assertion that proves it, which caught Rinsepaw placed at her post one step
  early on a walk frame. SceneKit.walk_all now waits until every walker has settled. Roll call, guild scene and
  board scene checks pass. The phase tables above are the September battle-feel plan and are stale since the
  mystery-dungeon pivot; the live state is the top of docs/AI_COLLABORATION.md and docs/design/pilot-story-2026-10-10.md.
- 2026-10-12, later: the faint flow and the defeat screen (Preston: a wipe must bring the team home like Mystery
  Dungeon, with a defeat information screen). scenes/faint_screen.tscn: the partner's word, then the panel (where,
  what beat you, turns, downed, lost, kept), E home to Highbank or back to the bank in the Mouth. Checks:
  faint_check (both routes), town_loop_check and pilot_chain_check press through it. Verified headless and windowed.
- 2026-10-12, later still: the genre synthesis (docs/design/genre-synthesis-2026-10-12.md) and R1, the words: Sense,
  a nest, Second Wind, went down, carried back, Postmaster (a title proposal). Player-facing strings only; ids,
  story flags and item keys unchanged. Checks pass: faint, IQ, roll call, guild scene, board scene, mouth escape,
  dungeon run. Next from the plan: R2 Orders in a courier's words.
- 2026-10-12, evening: growth wording (Preston: "so and so has grown into") in every player-facing line, and R2,
  Orders in a runner's words (STAY CLOSE, PUSH ON, HOLD; ids follow/go/guard unchanged). Checks pass: evolution
  (the new wording), field menu, tactics. Pre-existing failures found by comparing against the last commit, not
  caused today: evolution_check "No one else" (Tallowroot is also ready in that setup since the Oct 11 growth
  pace) and stone_check headless (the stone scene's line reader touches a freed dungeon). Next: R3, mail call.
- 2026-10-12, night: the full-pass stock-take (pitch kit, creature art matrix: every pilot creature has facings,
  walks, actions and a dialogue portrait). Spent the Retro balance on the six Hall crew's expression faces, two
  each (tools/ui/rd_crew_expressions.py, $2.16, $0.29 left), all within the silhouette and debris limits, wired
  into their lines and the roll call. Roll call and rooms checks pass. Next toward the pitch: the save system
  (the pitch kit's biggest hole), R3 mail call, the two-minute capture.
- 2026-10-12, late: found that the pilot chain had never passed The Hollow (Oct 11's log fails there too). Probe:
  one seed dies on B1F to Troughspine, one wears the Warden to 8 of 168 and loses the leader, one clears. Built the
  Warden yield rule (a fallen leader against a Warden under 35% starts the stand-off, not a faint) with its check;
  the B1F lethality is handed to Grok (GROK_TASKS_2026-10-12.md). The pilot chain is being re-run.
- 2026-10-12, end of day: PILOT CHAIN all ok in 720 s, the first pass ever (the check's growth wait lengthened to
  cover the whole scene). Two faints along the way, both retried. Grok has the B1F numbers task. Next for the
  pitch: the save system, R3 mail call, the two-minute capture, and posting the build for outside feedback.
- 2026-10-12, last: Preston: "make the climax unlosable". STANDOFF_AT is 1.0: once the Warden is awake, a fallen
  leader always starts the stand-off; before it wakes, a faint as anywhere. warden_yield_check covers all three.
- 2026-10-12, after that: the save. scripts/town/team_state.gd writes the team record to user://team.save
  (store_var, so int keys and Vector2i survive) when Highbank is reached, left for a run, or quit from; the
  title lists Continue first when a save exists (main_menu.gd, Codex's file, the smallest change: entries by
  name, Help placed by the last button's index). A check never writes or sees the real save unless it names
  its own file. tools/debug/save_check.gd all ok (round trip, arrival save, Continue to Highbank, no save no
  Continue); Codex's opening_flow_check 21/21 after the menu change; a real headless run wrote the real file,
  then deleted it. Next: the suspend save for a quit mid-run, R3 mail call, the two-minute capture.
- 2026-10-12, then the suspend save: a quit mid-run (pause menu, Return to title or Quit Game) writes the record as
  the run stands plus the run itself (dungeon.suspend_record: dungeon, floor, seed, lantern, turn, the team's HP,
  the run's start team); Continue opens the dungeon at the top of that floor with the same seed, once, then the
  record drops the run and saves again (no replaying a run from the file). The pause menu's leave text says what
  is kept. save_check 14 steps all ok; faint, Warden yield and field menu checks ok. Next: R3 mail call, the
  two-minute capture, and the sprites-in-3D test if Preston calls it.
- 2026-10-12, R3 mail call: the lower-floor morning scene is parcel sorting now (guild_crew.gd). Wayling calls
  routes, not names (the bend, levee row, Highbank windows, the grocer's slip, the ford), the crew claim them,
  Muskin is late and gets the Warren road, the runners' route comes from the Postmaster's morning note, and there
  is no cheer: the crew peel off to work. Ids unchanged (rollcall_runs, the room id). The place is the Sorting
  Floor. roll_call_check (its file keeps its name) now also asserts every crew member claims a route.
- 2026-10-12, R4 deliveries: a third Job Board kind, "Deliver to X" (jobs.gd). Taking one puts a Parcel in the
  bag (dungeon.gd ITEMS; it cannot be used); the client waits on its floor; the condition is judged at the
  client's feet (lit: lantern > 0; quick: turn <= N; careful: no trap sprung, a new traps_sprung counter) and the
  board pays by it (met: reward x2, +15 rank; missed: plain). A faint loses the bag and its parcels, those
  deliveries drop, and the faint screen names them. The board rows show the ask and the result. job_board_check
  has eight delivery steps; faint, field menu, board scene, save checks pass. Numbers to Grok (GROK_TASKS).
- 2026-10-12, R5 rising water: The Hollow's valley floor (B1F) floods a row at a time from the lowest floor row
  every WATER_EVERY turns (10), capped below the stairs and the start so the floor is never cut off; each rise is
  the current: creatures standing in the water and items lying in it go a tile downstream (east), Tide creatures
  swim; the leader's wet feet cost WET_LIGHT (0.5) a turn; a banner and lines at the first rise; a translucent
  band with a water line drawn in _draw_floor_fx; the Floor page says how high it is. The push comes only on a
  rise, so the autopilot can always walk out of it. water_check all ok headless and windowed; faint, Warden, save,
  field menu checks pass; pilot chain re-run. Numbers to Grok.
- 2026-10-12, R6 the Storage: a route's reward, not a purchase. Shut with a note until "first" (Rootbank Warren)
  is in beaten; then a panel at its door (E puts one in, R takes one out, W/S choose) over the record's new
  "stored" dict beside "bag". Parcels refused; the bag's kinds cap honoured on the way out; the faint screen's
  Kept row names the Storage; the save carries it (no KEYS change: the dungeon never touches it). The return
  from the Warren says the road is clear. storage_check all ok headless and windowed; job board, faint, save
  checks pass; pilot chain re-run.
- 2026-10-12, the sprites-in-3D workshop (Preston: do with a Hollowtide creature what the mech session does with
  its machine). Corrected my earlier reading: the mech work is render-to-pixel (3D model, eight pixel views), not
  billboards. Built tools/blender/render_creature_views.py (eight views, facing argument, FRAMES mode; compass
  proved by numbers on the mech ape), tools/art/measure_views.py and tools/art/pixelize_views.py. Spent $0.18
  of Retro's $0.29 on a Detailed Lite model and its walk. Findings in docs/design/sprite3d-workshop-2026-10-12.md:
  the pipeline works; the $0.10 model is the wrong creature (my prompt, not the references); a pitched camera and
  a lumpy model measure less consistent than the drawn set (height spread 7 vs 2 px; mirror IoU 0.43 vs 0.60 on
  the diagonals). Next is Preston's call: Meshy image-to-3D from the real sprite at 38 credits, a hand-built
  model, or keep the drawn set and use 3D for animation only.
- 2026-10-12, R7 the dialogue frame: UI.dialogue draws the portrait set into the box's left end (its frame
  straddling the top edge), the name tab beside it and the line to its right, with the wrap width reduced by
  the inset so paging and line_done agree with the drawing. Every dialogue box goes through that one function.
  Mail call windowed all ok; stills in docs/design/dialogue-frame-2026-10-12/; pilot chain re-run. R8 (a
  lawyer's read) is Preston's to arrange; Claude can draft the questions.
- 2026-10-12, R8 the lawyer's brief: docs/pitch/lawyer-brief-2026-10-12.md, nine questions in order (title,
  genre label and comps, names, the recruit rule and patents, look and feel as a sum, AI-made content, AI-written
  code, licences, business basics) with attachments: every name in the game's data, the mechanics one line each
  for a patent scan, the tools and licences, the store text drafts. Preston sends it; the plan R1 to R8 is now
  all in his hands or done.
