# Factory pass result (Claude, integrator, 2026-10-22, finished 2026-10-23)

Plan: [FACTORY_PLAN_2026-10-22.md](FACTORY_PLAN_2026-10-22.md). Full check table: [after-factory-checks.md](after-factory-checks.md). Nothing is committed; Preston commits.

## The short version

All 108 checks (`run_checks.py --long --arena`): **68 PASS, 1 FAIL, 0 TIMEOUT**, 32 RAN, 6 WINDOW, 1 RETIRED, 1 SKIPPED. Baseline before the pass: 66 PASS, 0 FAIL, 0 TIMEOUT of 106. The one FAIL is ui_fit's new measurement of the title's Options and How to play panels, which are Codex's queued fix (task 3, LP-01/LP-02), not a lane regression.

- Ten lanes plus the contract landed. Every lane item is in except the ones listed as skipped below, each with its reason.
- 20 of 27 cross-lane requests applied (18 edits; three lanes sent the same UI.tick fix); the other 7 were already covered, held for Preston, or left alone on purpose (list below).
- The integrator fixed three things the lanes could not reach: the Rootbank Warren painter (same picture, 3.7x faster), the pilot chain's replay retry, and three tester-note lines the merge made stale.
- Windowed smoke test: not run. Your call 14 (a yes to a windowed smoke test) is still unanswered and its default is to leave it; your standing rule is no screenshots unless you ask; and New Game in the real build writes over your own save. Say yes and it is one short session.

## Suite, before and after

| Run | PASS | FAIL | TIMEOUT | RAN | WINDOW | Other |
|---|---|---|---|---|---|---|
| Baseline (after-refine-checks.md, 106 checks) | 66 | 0 | 0 | 33 | 6 | RETIRED 1, SKIPPED 1 |
| First full run after merge (108 checks) | 66 | 3 | 0 | 32 | 6 | RETIRED 1, SKIPPED 1 |
| Final full run (108 checks) | 68 | 1 | 0 | 32 | 6 | RETIRED 1, SKIPPED 1 | |

The two new checks are timing_check (judged) and lv1_run_check (a table for Grok, judges nothing). dungeon_pace_check and music_check now judge (they were RAN); both PASS.

First run's three failures and what happened to each:

1. **pilot_chain_check**: the post-pilot Warren replay went down on try 1 (a level 9 team, random seed) and the retry pressed E on a closed way-down picker, so tries 2 to 5 never left town. A check bug that only shows when a replay faints. Fixed in the check: a retry reopens the picker first, and every try that does not clear now prints what the faint screen said (dungeon, floor, turns, what the leader fell to). Rerun alone: PASS, 160 s.
2. **timing_check**: Rootbank Warren floors 3.0 to 7.3 s, over the 3.5 s line. The cost was riverbank_painter.gd hashing four noise corners per pixel. The integrator lays each noise out once per floor and reads it from a grid; the floor is byte-identical on 5 seeds (probe below) and paints in 312 to 736 ms instead of 1.3 to 2.4 s. Rerun alone: PASS, slowest floor 2.70 s, Warren mean 1.27 s.
3. **ui_fit_check**: the title's Options and How to play panels end at 659 and 669, past 636. Not fixed here, on purpose: those panels live in Codex's title files and are already Codex's task 3 plus LP-01/LP-02 in the factory queue. Lane 8's new points measure them correctly; they turn green when Codex lands that edit.

Pilot chain, both full runs: the post-pilot Warren replay went down once at level 8 to 9 before clearing on the retry (the final run's faint screen: Rootbank Warren B3F, turn 427, fell to Preostmar, leader Sparkwick). Lane 7's run cleared it first try at level 7. It is a balance signal for Grok, not a failure.

Final run: timing slowest 3.12 s (The Hollow B1F, valley look), Warren mean 1.45 s, Highbank arrival 6.1 s (printed, not judged); dungeon_pace set aside 4 swap echoes, 2 pickup detours and 2 knock-backs and found 0 pacing.

Note on timing: Civilization VI and Roblox were running on this machine during the first runs. The same floor took 3.0 s in one run and 7.3 s in another before the fix, so the old numbers were partly load. The fix holds either way: the painter itself is 3.7x faster.

## Per lane: done and skipped

| Lane | Done | Skipped (why) |
|---|---|---|
| Contract | CONTRACT (UI.tick, toast, fade_out/fade_in, reduce_motion, text_speed, apply_screen_mode, reload_prefs, motion_secs; controls_text.gd; UI bus) | none |
| 1 dungeon.gd | LP-17, LP-14, FEEL-10, GS-08, LP-21, FEEL-11, FEEL-05, GS-21, FEEL-21 (with the FEEL-17 partner fix), GS-07, FX-02, CR-07 | none |
| 2 painters | UI-07, WORLD-01, WORLD-02, FEEL-08 (pond ambience on SFX) | none |
| 3 Highbank street | GS-15, GS-12, GS-16, LP-12, LP-18, LP-23, LP-24, GS-14, GS-11, GS-21 | W16 (call 8 default: gate lines stay) |
| 4 rooms, layout, objectives | LP-15, GS-10, LP-16, CR-02, W25, LP-18, LP-13, FLOW-22 (marked retired, not deleted), GS-21, W12 | W12 board part (sent to lane 3, applied here); GS-10's save_check step (lane 7 wrote it as FLOW-09 step 2) |
| 5 UI scripts | CONTRACT, LP-19, GS-21, GS-01, LP-03, LP-28, LP-22, W23, LP-08, UI-04, FLOW-09, W12 | UI-04 hint text: 'E  yes   Esc  not now' would ask a question after it is answered, so the row reads 'E  continue' |
| 6 riverbank and prologue | LP-09, LP-10, LP-04, W14, LP-18, FLOW-15, FEEL-08 | none |
| 7 save, chain, probes | FLOW-21, FLOW-09, FLOW-06, CR-01 (the check), LP-25 | none (team_state.gd needed no change) |
| 8 project and tools | GS-09, LP-14 (probe), FEEL-17 (judging), LP-18 (probe), UI-08, T0 | CR-05 and CR-08 (held for Preston: window shape and renderer) |
| 9 audio | FEEL-08, FEEL-09, FEEL-20, LP-26 (parked note), FEEL-14, storm rain on SFX | FEEL-08 slider part (conflicts with Preston's 2026-10-22 call; see decisions) |
| 10 docs | FLOW-16, FLOW-17, GS-18, CODEX (section 5 appended) | CR-09 (this integrator writes it) |

## Cross-lane requests

Applied (old text matched, line endings kept):

| From -> to | File | Change |
|---|---|---|
| 1, 3, 4 -> 5 | scripts/ui/ui_style.gd | UI.tick no longer connects `ready` twice when one kind ticks twice in a frame (the job_board and storage FAIL tags) |
| 1 -> 8 | tools/debug/dungeon_pace_check.gd | pickup detour reads the snapshot after the return step |
| 1 -> 8 | tools/debug/dungeon_pace_check.gd | a knock-back walked back from is not pacing; the integrator added a printed count of these so the exemption stays visible |
| 2 -> integrator | scripts/town/highbank_painter.gd | TURF reads V.MEADOW (same three colours, one source) |
| 3 -> 9 | tools/debug/dungeon_sfx_check.gd | comment, and the town pairs: board rustles, Storage door creaks, the shut shop is quiet |
| 4 -> 3 | scripts/town/hub_town.gd | Job Board hint in column style 'W/S  choose     E  take or put back     Esc  close' |
| 4 -> 8 | tools/debug/ui_fit_check.gd | measures the room hint actually drawn ('WASD  walk     E  use') |
| 5 -> 8 | tools/debug/ui_fit_check.gd | point 9 asks the Team screen for its own move box (LP-08 layout) |
| 5 -> integrator | tools/debug/field_menu_check.gd | one cursor move, then the menu sounds step (open, cursor, close on the UI bus) |
| 6 -> integrator | tools/debug/flood_opening_check.gd | reads the partner's refusal from the talk box, where LP-09 moved it |
| 7 -> 8 | tools/debug/run_checks.py | lv1_run_check gets the 600 s long-check limit |
| 7 -> 10 | docs/team/GROK_TASKS_2026-10-22.md | the first lv1 table beside Grok's LP-25 task |
| 9 -> Codex queue | scripts/main_menu.gd | title clicks on the UI bus |
| 9 -> Codex queue | scripts/soul_prologue.gd | the typed blip on the UI bus |
| 9 -> Codex queue | scripts/storm_open.gd | storm sounds on the SFX bus |
| 9 -> 10 | docs/audio/music-prompts.md | the ducking line says the duck is off |

The three Codex-queue bus lines were one-line fixes that music_check's new source scan needs; the queue row FEEL-08 in CODEX_TASKS_2026-10-22.md is marked done.

Not applied:

| From -> to | File | Why |
|---|---|---|
| 9 -> 1 | dungeon.gd `_play` default Master to UI | superseded: lane 1 already defaults `_play` to SFX and sends its clicks through `_tick` on UI; music_check passes |
| 9 -> 1 | dungeon.gd comment beside `p.bus` | superseded with the line above (the old comment is gone) |
| 9 -> 5 | game_pause_menu.gd: the SFX slider also scales UI | held: on 2026-10-22 Preston put the clicks off the effects slider (ui_style.gd says so at the blip and the tick players). Preston's call |
| 9 -> Codex | main_menu.gd `_apply_volume` scales UI with SFX | held, same reason |
| 9 -> integrator | scripts/battle_screen.gd, three 'ducks under' comments | held: battle_screen.gd is the old Route 1 battle and the project rule says do not edit Route 1; comments only, so nothing breaks |

## Integrator changes beyond the requests

- scripts/dungeon/riverbank_painter.gd: `_layer` (new) lays a noise out once per floor; `_ground` and `_walls` read it. Probe: 5 seeds (102, 104, 203, 4242, 7) byte-identical to the file as the lanes left it; 9.5 s down to 2.6 s for the five. One dead branch (a turf blade root that could never draw) is noted in a comment; removing it changes no pixel.
- tools/debug/pilot_chain_check.gd: the replay retry reopens the way-down picker; a try that does not clear prints the faint screen's facts.
- tools/debug/dungeon_pace_check.gd: prints how many knock-backs it set aside.
- scripts/town/hollow_approach.gd: a code comment used the borrowed genre label and said 'two floors'; now it uses neither (house words; the Mouth has four floors).
- docs/team/TESTER_NOTES.md: left click no longer attacks (FEEL-05 removed it), the bed at home saves (GS-10), and every floor opens on a name and floor card (FEEL-10).
- docs/team/CODEX_TASKS_2026-10-22.md: FEEL-08 row marked done.

## Every new player-facing line (proposals, for Preston to keep, change or cut)

None of these are canon until Preston says so.

**Dungeon (lane 1)**
- Log: "%s's Sense grew. %s: %s." / "Hollow Mouth, B1F." (the dungeon's name and floor on arrival) / "The team is full. %s will wait at the Wayline Hall." / "%s goes back into the Hollow." / "%s grew to Lv %d!"
- Recruit hint strip: "Y join   N leave"
- Nest banner: "A NEST!" with "they're all awake"
- Team tag when tight: "Lv 1  S0"
- Pops: "SNARED", "...", and the picked-up item's name
- Unlearn prompt: "Let %s go unlearned? Y/N", footer "Y let it go   N keep it"
- HUD move label: "Self"
- Partner on the Mouth's B1F (ships per call 8's default): "Whoa, heads up, there's one of 'em over there. If it comes at us, J swings, or 1, 2 and 3 for our moves." / "Ooh, somebody dropped this. It's ours now. Press I whenever you want to dig through the bag." / "Lantern's burning down, huh. It flares back up when we beat something. Z rests us, but it keeps burning while we sit."

**Highbank street (lane 3)**
- Return panels: "%s is cleared. The bag and the new partners came home." / "...%s's still there when you are."
- Item Shop: "Boards across the door. A card's tucked behind them: "Out restocking. Back when the boats run again.""
- Scroll Keeper: "The cellar lid's chained shut. A note on the chain says the Keeper is sorting scrolls and not taking callers yet."
- Training Yard: "There's a rope across the gate, and a board hung off it: "Yard's closed till the ground dries out.""
- End card: "The first stretch of Hollowtide" (plan), then "The Hollow goes deeper than the Warden's pond." / "More routes are coming, up and down the river." / "And the Wayline crew has a lot more to say." / "Thanks for running it." / "E  Keep running routes" (plan)
- Toasts: "Highbank remembers." / "The run is kept." (plan)

**Rooms and objectives (lane 4)**
- Bed: "Morning. Highbank remembers." (plan)
- Storage: "Kept between runs. Going down loses the bag, never this." / "Keeps items between runs. A run's bag is lost when the team goes down; storage is not."
- Runners' Room: "Runners only. The door is locked." then "Your bunks now. Rest here or go on."
- Places (plan lines): Lookout "Where the river looks close. On a clear day you can see the next bend." / Dock "Planks over the water. No ferry has run since the flood." / Shrine "Where a creature that is ready grows into its next form." / Hall "The Wayline's hall: jobs, the roster, reports."
- Objectives: "The Shortcut Crew took the parcel. Starward, the Postmaster, is at the counter inside the Wayline Hall." / "The parcel is back. Take it to Starward at the counter in the Wayline Hall." / "You're runners now. The Hollow is the next way down, through the Mouth of the Hollow." / short "Grow at the Growth Shrine, or run a Hollow again", long "The shrine is awake. A creature that is ready grows there. The Mouth of the Hollow takes you back into any Hollow to grow the rest of the team." / after the end card "That's the first stretch. Run the Hollows again or rest at home." (plan) with the long line "The shrine is there for whoever is ready next."

**Menus and screens (lane 5)**
- Faint screen: heading "BACK TO THE TOP"; partner "%s! Hey... okay, you're still here. I've got you. Let's head back up top and go again."; kept row "Kept: levels, moves and your partners."
- Shrine: "Nobody in Highbank has seen this line grow." and the heading "To grow"
- Evolution hint: "E  continue"
- Bag hints: "Enter / A  use", "Enter / A  learn the move"
- Controls page opener: "Keyboard. A controller works in the menus only for now." and "Fights in a Hollow are turn-based."
- Controls list (contract): "Ctrl + direction: run. L: messages." and "1-3: moves." with a plain hyphen

**Riverbank (lane 6)**
- Gate (W15): "Nope. Highbank first. Let's tell them what we found. We can come back together."
- Hint near the trail during the flood: "E / Enter  try the south trail"; flood hint (plan) "The road to Highbank is under water. The stone walkway is the way."
- Route errors: "The route could not open. Try the arch again." / "...Try the walkway again." / "...Try the trail again." / "...Try again."
- Title prompt: "Back to the title?" with "Resume" and "Return" (plan); fallback "The title could not open. Your team is still here."

**Tools and docs (lanes 8 and 10)**
- Move-preview tooltip (dev screen): "The turn-based Hollow with your side as the team (the first one leads)"
- docs/team/TESTER_NOTES.md as a whole (tester-facing prose)

## Notes for Preston (merged)

**What you will notice when you play**
- Every Hollow floor opens on its name and floor over the black, a short hold, then the banner. Traps, pickups and rests show what happened. A J tapped mid-step now goes through. Clicking no longer attacks. E pages through talk. Escape on a new-move offer asks before throwing the move away.
- Floors build faster: creature art is kept once read, the painted floor is cached by seed, and the Warren's painter is 3.7x faster (same picture).
- The Hollow Mouth has its own floor look: paler, warmer silt-washed stone, yellower moss, faint old high-water lines. The riverbank grass is now the valley's green; the town already showed it.
- The Warden's spent breath moves one whole pixel instead of stretching.
- Highbank: the Item Shop is boarded, the Scroll Keeper's lid is chained, the Yard has a rope (you can still walk in past the rope; blocking it needs the town grid). The crew at the board shuffle a step and back and look at you up close; they snap to their marks when the board scene starts. You can no longer walk onto the Job Board or the Mouth's stones.
- Sleeping in a bed fades to black, saves, and says "Morning. Highbank remembers."
- After the first growth the end card plays once per save, then the objective line takes over.
- The faint screen says "BACK TO THE TOP" when E really takes you back to the Mouth's first floor.
- The Team screen draws every creature at exact 1x (crisper, smaller). If too small, the fix is a taller stage at 2x, not a fractional scale.
- The shrine hides moves the Hollow cannot teach yet; the data is untouched.
- Pause menu: Screen (windowed or full), Text speed (Normal, Fast, Instant) and Reduce motion; F11 toggles full screen. Restoring full screen at launch is still on Codex's list, so a relaunch opens windowed until then.
- On the riverbank the partner's lines are in the talk box with a face, and Esc asks "Back to the title?".

**Behaviour changes for Grok (no numbers changed)**
- A move with 0 damage and no heal (Sail Cover, Still Water, Star Guard, Signal Mark, Glass Guard) plays on its user and hits nobody; before, a rounding floor let it deal 1. Basic attacks are excluded.
- A wild beside its target with a wall corner between them waits instead of pacing.
- A partner follows whichever teammate is between it and the leader; partners no longer trade tiles.
- The lv1 table (a bump-only level 1 leader on the Mouth): cleared 3 of 10 seeds, 27 times down; it is in GROK_TASKS_2026-10-22.md.

**Decisions waiting on you**
- Clicks and the effects slider: on 2026-10-22 you put clicks off the SFX slider (Master only); the plan said the SFX slider should scale them. The current build follows your call. Either way is one line in each menu.
- "Back to the title?" (riverbank, new) or "Return to the title?" (pause menu): pick one.
- The Warden's pond garden keeps its own four greens (a fourth grass), to protect the approved entrance. Say if it should take the shared green.
- The shrine's grow question in hub_town still has "E  yes      Esc  not now" inside its sentence (W12's last piece).
- Your section 6 calls are all still at their defaults: 1 (Hollow Mouth vs Mouth of the Hollow; both still appear), 2, 3, 4 (two paid footstep takes parked, named in docs/audio/sources.md), 5, 6, 7 (end card ships without the presence's line and the feedback address), 8 (B1F lines ship), 9 (shut signs), 10 to 13 unchanged, 14 (smoke test, below).
- "courier hall" still appears in player text in scripts/first_fight.gd:41 and scripts/first_route_prototype.gd:224, 228, 233 (old route files no lane owned).

**Sound**
- Clicks have their own UI bus; the music no longer dips under hits; the five menu sounds stay chiptune and rerunning the sound tools cannot overwrite them (checked byte for byte on a copy).
- Correction to the plan: fall_whoosh.wav is in use (the Warden coming down). Only cheer.wav is unused. Nothing was deleted.

**Housekeeping**
- The editor will write scripts/ui/controls_text.gd.uid the next time the project opens; it belongs with the script.
- Every headless log carries shader 'custom_samplers' lines, 'resources still in use at exit' and null screenshot errors. All were there before and none is judged.
- Not seen by eye in headless runs: the bed fade, the hint strips, the board planks, chain and rope, the LP-24 board still. The smoke test below covers what it could.

## Windowed smoke test

Not run, for three reasons: plan call 14 (your yes to a windowed smoke test) is unanswered and section 6 says an unanswered call stays as is; your CLAUDE.md says no screenshots unless you ask; and a New Game in the real build would overwrite your own save in %APPDATA%\Godot\app_userdata\Hollowtide (it would need backing up and restoring around the test). Summer Engine is connected to this project, so the test is ready when you say yes: title, New Game to B2F, a faint, Continue, Highbank, the board, Storage and the end card, with one still each, plus the stills the lanes could not take headless (the bed fade, the room hint strip, the board planks, chain and rope, the LP-24 board, the ruin rise on the riverbank).

## The Codex and Grok queues now

- **Codex** (docs/team/CODEX_TASKS_2026-10-22.md): tasks 2 to 4 from before, then section 5, the factory queue. "Now" rows: ART-10 portraits, FX-01 empty VFX frames, ART-08 muskin palette, ART-09 starward and listener rebuilds, ART-03 title village re-cut, ART-01 and ART-02 colour reduction, ART-05 walk sheets, ART-04 action sheets, LP-31 sign boards. "After" rows: tasks 3 and 4, LP-01/LP-02 (the ui_fit title panels, the one red check left), UI-01 title buttons, LP-03 title Controls tab, GS-01/GS-03 title screen and text rows applied at launch, GS-17 credits, FLOW-10 New Game confirm, CR-06 skip hints, the soul prologue rows, W14/W19/W20, CR-04 icon and splash, FLOW-13/FLOW-12 export preset, FLOW-14 lab scenes. FEEL-08 is done.
- **Grok** (docs/team/GROK_TASKS_2026-10-22.md): FLOW-17 spawn rows in the pilot story; LP-25 Mouth spawns and REST_TO with the first lv1 table beside it; FX-02 which status moves belong in the dungeon; W27 fire_move.tres; GS-20 names for Lantern Tackle, Verdant Roar, Ember Feint; W28 later.

## Left for pass 2

- Plan section 8 step 12: input actions and controller (GS-04, FEEL-01), one agent, after Codex's "after" queue; gates opening_launch, soul_prologue, storm_open and an input_map probe.
- CR-05 (window aspect) and CR-08 (renderer) held for Preston.
- Also deferred by the plan: UI-05 portrait density, LP-29 furniture depth.
