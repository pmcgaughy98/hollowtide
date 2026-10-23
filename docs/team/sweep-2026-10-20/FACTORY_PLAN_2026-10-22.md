# Factory plan: the mass upgrade pass (Claude, 2026-10-22)

Preston: "a mass factory hollowtide wiring that we refine into a finished product rather than add one part of the game individually." This plan turns the seven audit strands (live play, genre, words, wiring, art and UI, feel, critic) into lanes that run as parallel agents, each in its own git worktree, each owning files no other lane touches. One integrator merges in the order in section 8 and runs all 106 checks.

Rules for every lane: edit only the files in your row; a change you need in another lane's file goes in your result as "for lane X: file:line, change" and the integrator applies it; never commit, push, stash or checkout; no paid calls; no em-dashes; the house words stay (Sense, nest, Second Wind, went down, Postmaster, Hollow; never "Mystery Dungeon"); always `python tools/debug/run_checks.py <names> --jobs 1 --logs <your temp>` (it adds `--fixed-fps 30` itself). Each item ends with its check run and the log path in the result.

## 1. What was dropped or merged

Dropped as unmeasured or corrected by the critic: LP-11's "ten seconds" (replaced by CR-01's measured 2.3 to 5.7 s), GS-13 (the Runners' Room does open; only its text is stale, CR-02), GS-06 (a strength), W28 (not player-facing), FEEL-16's pace number (Preston's call, no change). Deferred to a second pass because they touch every lane's files at once: GS-04 and FEEL-01 (input actions and controller), UI-05 (portrait density), LP-29 (furniture depth). Merged groups keep the first id: LP-15 (+GS-10, W04, W05, FLOW-03, FLOW-04), LP-16 (+W01), LP-17 (+W09), LP-03 (+FLOW-20, W13, GS-22), GS-08 (+FEEL-15), GS-09 (+W29), GS-12 (+FLOW-02, W06), GS-15 (+W21, FLOW-05), GS-16 (+FLOW-01), GS-21 (+FEEL-06, FEEL-07), LP-04 (+LP-05, UI-02), W08 (+FLOW-19), LP-10 (+FLOW-07), LP-26 (+FEEL-19, CR-03), GS-19 (+W26). Known collision: GS-02's title slider would grow a panel Codex is already shrinking (task 3), so the title slider waits and only the caption changes.

## 2. Shared contract (the UI lane lands this first; every other lane codes against it)

| Helper | Lives in | Signature and behaviour |
|---|---|---|
| UI.tick | scripts/ui/ui_style.gd | `static func tick(kind: String)`; kinds cursor, confirm, cancel, open, close; plays assets/audio/sfx/ui or dungeon/menu_open and menu_close on bus "UI" at -8 dB |
| UI.toast | ui_style.gd | `static func toast(tree, text: String, secs := 1.5)`; a label-role UI.panel strip, top right |
| UI.fade_out / fade_in | ui_style.gd | `static func fade_out(tree, secs := 0.2) -> Signal`, `fade_in(tree, secs := 0.2)`; black ColorRect on a CanvasLayer; halved when UI.reduce_motion() |
| UI.reduce_motion | ui_style.gd | reads user://menu_preferences.cfg menu/reduce_motion once |
| UI.apply_screen_mode | ui_style.gd | `static func apply_screen_mode(full: bool)`; pref key display/fullscreen; DisplayServer.window_set_mode |
| UI.text_speed | ui_style.gd | pref menu/text_speed in 1, 2, 0 (instant); typed() multiplies TYPE_CPS |
| ControlsText | new scripts/ui/controls_text.gd | consts TOWN, HOLLOW, MENUS (the three headed groups from creature_opening.gd:336-342 plus Ctrl run and L messages) |
| Buses | default_bus_layout.tres (audio lane) | "SFX" for world and scene sounds, "UI" for clicks and blips, "Music"; every AudioStreamPlayer sets one |
| last_run | TeamState.data | dungeon.gd writes `data["last_run"] = DUNGEONS[dungeon]["name"]` before _go_to_town; readers use `.get("last_run", "the Hollow")` |
| ruin variant | scripts/dungeon/ruin_painter.gd | optional `variant := "hollow"` argument; dungeon.gd passes "mouth" for the Mouth |

## 3. Claude's lanes

Sizes: S under an hour, M a sitting, L more. "Probe" means a new check or a step added to the named check.

### Lane 1: dungeon.gd (1 agent, two sittings; the file cannot be split)
Owns: scripts/dungeon/dungeon.gd only.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| LP-17 | Strings: 'wait at the Wayline Hall' (2204), 'Lv %d' (2959), 'into the Hollow' (2191), Sense-skill line "%s's Sense grew. %s." (2708-2710), log line 'Hollow Mouth, B1F.' on floor 1 (769), recruit hint 'Y join   N leave' on the hint row not in the message (2143) | dungeon_recruit, dungeon_iq; grep 'courier hall\|Lv\. \|into the hollow' = 0 | S |
| LP-14 | Exclude 'parcel' from the random pool in _stock_floor (786) | dungeon (lane 8 adds the assertion) | S |
| FEEL-10 | Floor card every floor: _banner_show(name, 'B%dF') at 736; hold black 0.45 s before fade-in (2010); draw the card on the fade layer before _build_floor; cache painted floor images by (dungeon, floor, seed) in a static Dictionary (CR-01) | dungeon_sfx stairs step reads _banner text; lane 7's timing_check | M |
| GS-08 | _banner_show('A NEST!', "they're all awake") at 3470 | grep 'MONSTER HOUSE' scripts = 0 | S |
| LP-21 | hud_name_tag tight step shows 'Lv 1  S0' instead of dropping Sense (4301-4310) | ui_fit point 1 | S |
| FEEL-11 | Feedback: snare ring plus SNARED pop, silt dust burst plus 1.5 shake, warp fade (3445); pickup pop and rise (3431); rest '...' pop (1974); autopilot toggle plays open/close (3790) (FEEL-12, FEEL-18) | dungeon_trap: _fade alpha > 0 after warp; dungeon_sfx: _pops holds the item name | S |
| FEEL-05 | Input: 150 ms press buffer consumed in _poll when not busy; delete the click-attack (3793-3797, FEEL-03); E advances a talk line (3686, 3705, FEEL-02); read UI.reduce_motion() and clamp _shake at 1528, 1533, 1645, 2021 and skip the white rect at 4089 (FEEL-04) | probe: tap J mid-step, a swing follows; run_stop still passes | M |
| GS-21 | UI.tick('cursor') at 3710, 3712, 3729, 3731; 'cancel' at 3719, 3736; 'open' when teach_kind is set; Escape over a 'learn:' offer asks 'Let %s go unlearned? Y/N' before act_teach(-2) (FEEL-22) | dungeon_learn: pending_learn unchanged until Y | S |
| FEEL-21 | Pause tw2 during the hit-stop (1419) and resume after; guard _slide when the node is already on its tile (1762); a wild with an adjacent blocked target waits instead of pacing (2370-2395) (FEEL-17) | dungeon_battle; dungeon_pace with lane 8's judging | M |
| GS-07 | Three partner lines on Mouth B1F fired once by story flags taught_wild, taught_item, taught_lantern, through the talk box: first wild in view (J, 1-3), first floor item (I), lantern under half (Z). Proposed words stand unless Preston rewrites them | flood_opening extended: each fires once on a fresh record, never on replay | M |
| FX-02 | Self-effect branch in use_move for zero-damage moves; MOVE_FX rows sail_cover, still_water, star_guard (star_shield), stone_cocoon (cocoon_stone), signal_mark (mark_glyph), root_rampart (root_burst area), kingstone_lift and rail_recoil (jade_burst); the rest get the essence ring | probe: every learnset move has a MOVE_FX row, particle call or self-effect; dungeon_vfx, dungeon_learn | M |
| CR-07 | Small: _play returns on a null stream (4328); write data["last_run"]; HUD key hints on a label-role UI.panel strip (4198); pass variant "mouth" to the ruin painter; every _play on bus "SFX" | dungeon_sfx; grep 'Master' in dungeon.gd _play = 0 | S |

### Lane 2: painters and dungeon scenes (1 agent)
Owns: scripts/dungeon/stone_scene.gd, boss_intro.gd, crew_scene.gd, ruin_painter.gd, valley_painter.gd, riverbank_painter.gd; scripts/town/highbank_ground_painter.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| UI-07 | Warden breathes by whole pixels (offset 0 or 1 px on a 0.6 s cycle), scale stays Vector2.ONE (stone_scene.gd:409) | stone; probe reads wn.scale over 10 frames | S |
| WORLD-01 | `variant` argument on ruin_painter: shifted STONE and MOSS ramp plus one mouth-only detail (silt lines) | dungeons, stone, hollow; equal-height stills by the integrator | M |
| WORLD-02 | One grass ramp const read by the three painters (town GRASS, valley MEADOW, riverbank GRASS) | grep the three hex sets: one source; dungeons | S |
| FEEL-08 | pond_ambience player on bus "SFX" (boss_intro.gd:139) | music; probe walks the tree after _ready, no player on Master | S |

### Lane 3: Highbank street (1 agent)
Owns: scripts/town/hub_town.gd, jobs.gd, hollow_approach.gd, building_exteriors.gd, scene_kit.gd, new scripts/town/pilot_end.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| GS-15 | Return panels name the place from last_run and drop '(Cleared %d.)' (110, 119) | town_loop prints the new text; grep '(Cleared' = 0 | S |
| GS-12 | Shop, Scroll Keeper, Yard: no door sound; a shut sign in the voice (303); shutters drawn by building_exteriors.gd. If Preston says yes to the Yard, service "arena" opens scenes/move_preview.tscn with Esc back | hub_town walks to the three doors and prints each panel; no 'mode', 'arena', 'real-time' | M |
| GS-16 | End card after the first growth (580): fade, title-face 'The first stretch of Hollowtide', three lines of what comes next, 'Thanks for running it.', 'E  Keep running routes'; new pilot_end.gd on scene_kit; story flag pilot_end_seen | pilot extended by one step (lane 7); a still by the integrator | M |
| LP-12 | Build board rows, titles, descriptors and reward names once when the panel opens (store in panel['rows']); draw from the cache (794-840) | probe: two probes 5 s apart with the board open, frames_drawn delta >= 0.9 x physics delta; job_board | M |
| LP-18 | Followers take the tile the one ahead just left on every leader step (232-236) | town_walk assertion (lane 8) | S |
| LP-23 | Skip the place and 'Next:' panels while any panel is open (759-762) | job_board, storage | S |
| LP-24 | Descriptor column always 'body' role (823) | a still of a delivery plus a rescue posted | S |
| GS-14 | _npc_idle: one or two steps toward a random tile within 2 of home every 4 to 8 s; face the leader within 2 tiles; never a door tile | town_walk: after 20 s one NPC moved, none in a door | S |
| GS-11 | UI.toast 'Highbank remembers.' at the autosaves (123, 342) and 'The run is kept.' at 601; UI.fade_out before enter_room (586-591) and the Hollow exit (623-625), UI.fade_in in _ready (FEEL-13); Music.play 'hollow_flute' in hollow_approach._ready (FEEL-14); arrive_at "gate" on Esc from the approach (hollow_approach.gd:207, FLOW-08) | town_loop asserts the toast node; hollow_approach back lands on (33,29); music gains the approach row | M |
| GS-21 | UI.tick('cursor') at 698, 'cancel' at 704; the three existing clicks through the same helper; HUD hints on a panel strip (759-760); _play null guard; players on bus "SFX", clicks on "UI" | hub_town; grep 'AudioStreamPlayer.new' sites all set a bus | S |
| W16 | Gate lines 475-479 lead with a reaction and an object (shape only; Preston's words). Default if he does not answer: leave | read in Highbank before the Hall | S |

### Lane 4: rooms, layout and objectives (1 agent)
Owns: scripts/town/town_room.gd, town_layout.gd, objective.gd, storage_panel.gd, board_scene.gd, guild_scene.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| LP-15 | Bed text without the parenthesis (town_room 38, 84); counter line to its first sentence (45); Lookout 'On a clear day you can see the next bend.' (town_layout 51); Dock 'No ferry has run since the flood.' (71); shrine 'Where a creature that is ready grows into its next form.' (63); Hall 'The Wayline's hall: jobs, the roster, reports.' (47) | grep 'Later:\|Saving comes\|Preston, 20\|Wayline Compact' scripts/town = 0; town_room, hub_town | S |
| GS-10 | The bed rests the team: UI.fade_out, full HP, TeamState.autosave(), one line 'Morning. Highbank remembers.' (394-397) | town_room; save_check step (lane 7) | S |
| LP-16 | 'Kept between runs. Going down loses the bag, never this.' (storage_panel 30); 'lost when the team goes down; storage is not' (town_layout 57) | grep '"[^"]*faint' scripts/town = 0; storage | S |
| CR-02 | Runners' Room 'what' keyed on story.runner: 'Runners only. The door is locked.' before, 'Your bunks now. Rest here or go on.' after (72) | town_room on a record with runner set and unset | S |
| W25 | Objectives give directions once, then name the place; Starward 'is at the counter inside' after the theft (22, FLOW-18); 'run a Hollow again' (35-36, W07); last line after pilot_end_seen: "That's the first stretch. Run the Hollows again or rest at home." | each direction phrase at most once in objective.gd; field_menu Objective page | S |
| LP-18 | Arrival places members on distinct open tiles behind the door, never on a solid rect (176-195) | town_room: no two members share a pos after arrival | S |
| LP-13 | Layout.grid marks every 'spot' rect solid except its door tiles (town_layout 84-88) | town_walk, job_board: walking up from (26,9) stops on (26,8) and E opens the board | S |
| FLOW-22 | Delete the unreachable HAND_OVER trial branch (guild_scene 170-187) or mark it retired in one line | guild_scene, hall_door, hall_floors | S |
| GS-21 | town_room: 'cancel' through UI.tick at 507; HUD hints on a panel strip (528-529); _play null guard; bus "SFX" and "UI" (553) | town_room | S |
| W12 | Column-row key hints only in the room and board panels (the grow question at hub_town 464 is lane 3's) | ui_fit | S |

### Lane 5: UI scripts (1 agent; lands the contract commit first, then the rest)
Owns: scripts/ui/ui_style.gd, game_pause_menu.gd, faint_screen.gd, party_screen.gd, shrine_info.gd, bag_page.gd, evolution_scene.gd, new scripts/ui/controls_text.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| CONTRACT | The helpers in section 2, plus text speed in typed() (ui_style 338-359) | ui_fit, field_menu; every check still loads | M |
| LP-19 | Widow rule in UI.dialogue: a last page under 12 characters rebalances the rows (320-324) | faint; a still of the faint line | S |
| GS-21 | Pause menu sounds through UI.tick: open, close, cursor on focus, confirm, cancel; slider tick on its own bus; focus ring to UI.frame('panel_focus') (141); portrait frame to UI.frame (336) (UI-06) | field_menu records the three names; grep StyleBoxFlat scripts/ui = scrollbars only | S |
| GS-01 | Pause Options rows: 'Screen: Windowed / Full screen' (UI.apply_screen_mode, F11 anywhere), 'Text: Normal / Fast / Instant' (GS-03), caption 'Sound effects volume' (GS-02), label 'Reduce motion' (FEEL-04) | field_menu; quit and relaunch keeps the mode | S |
| LP-03 | Controls page draws ControlsText; honest line 'Keyboard. A controller works in the menus only for now.' (GS-05); no arena sentence (W06); 'Fights in a Hollow are turn-based' (W07) | ui_fit pause-controls point | S |
| LP-28 | Objective page: short goal in the 'title' role at 30 (245) | field_menu | S |
| LP-22 | Faint screen: heading via UI.say 'title', PANEL height to content (17, 76-85); 'BACK TO THE TOP' when the next scene is B1F (63, 77, FLOW-06); kept-list ends at 'your partners.' (100, W30); KEY_J and ui_accept confirm (37, FEEL-02); water_rain bed at -18 dB on SFX (FEEL-14) | faint, plus lane 7's not-to-town step | S |
| W23 | Shrine: 'Nobody in Highbank has seen this line grow.' (256, 282); hide or reword the 'unavailable' rows (289-290); 'To grow' heading (188, W24); UI.tick cursor on W/S and tabs, cancel on close; condition bars to UI.bar (273) | shrine with a Skimlet in the team: no 'defined' or 'unavailable'; evolution | S |
| LP-08 | Party: Moves list sized to rows x 60 + 24, body-part line under the description; UI.HEAD at 388 to UI.say 'body'; integer scale floorf(k) min 1 (246, 253-264, UI-04) | field_menu; probe prints k per form as whole numbers | M |
| UI-04 | Evolution: floorf(k) min 1 (63-65); CreatureFinish.apply on both sprites (ART-07); null fallback to the dungeon still (62, CR-07); hint row 'E  yes   Esc  not now' (141, W12) | evolution; probe builds the scene for a made-up form with no script error | S |
| FLOW-09 | leave() autosaves from any room host: host.has_method("_record") replaces the storage test (431) | save_check step (lane 7) | S |
| W12 | Bag page hint row in the column style (127); party cursor on bus "UI" (64) | field_menu | S |

### Lane 6: riverbank and prologue scenes (1 agent)
Owns: scripts/riverbank_journey.gd, creature_prologue.gd, mouth_escape.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| LP-09 | The rise line and both refusals through UI.dialogue with the partner's name and portrait (88-90, 177-181); status label for narration only | flood_opening; a still after the ruin rises | S |
| LP-10 | Hint during the flood: 'The road to Highbank is under water. The stone walkway is the way.' with no H (140); delete the dead branches 170-175 and 181-183 or comment why they stay | flood_opening; H during the flood does nothing | S |
| LP-04 | _label uses UI.font('body' / 'title') as game_pause_menu._label does (93) | grep UI.HEAD riverbank_journey.gd = 0; hollow_approach | S |
| W14 | Straight apostrophe at 171; the gate line leads with a reaction (W15, proposed: 'Nope. Highbank first.'); the error at 189 ends 'Try the arch again.' | flood_opening | S |
| LP-18 | Partner stands one tile behind the leader at the arch, not on it (63) | hollow_approach still | S |
| FLOW-15 | Esc in creature_prologue (any line) and on the riverbank opens 'Back to the title?' with Resume and Return | flood_talk; pressing Esc then Return lands on the title | S |
| FEEL-08 | Scene player on bus "SFX" (creature_prologue 167) | music | S |

### Lane 7: save, chain and probes (1 agent)
Owns: scripts/town/team_state.gd, tools/debug/save_check.gd, pilot_chain_check.gd, faint_check.gd, new timing_check.gd, new lv1_run_check.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| FLOW-21 | Chain pass 2 behind a flag: force one faint in the Warren, read the faint panel, suspend in the Hollow, resume through Continue; one more step for the end card (GS-16) | run_checks pilot --long: new ok lines | M |
| FLOW-09 | save_check steps: quit from the Hall after the trial keeps guild_trial; the bed autosaves (GS-10) | save | S |
| FLOW-06 | faint_check covers the Mouth-before-the-road path: panel words match the next scene | faint | S |
| CR-01 | timing_check.gd from the scratchpad probe (critic_timing.gd): floor build per look, Highbank arrival, rooms, static memory; judges build <= 3.5 s and memory growth <= 20 MB over 20 floors | a PASS line; rerun after lane 1's cache | S |
| LP-25 | lv1_run_check.gd: the Mouth on seeds 1 to 10 with the chain's scripted fight policy and no autopilot; prints faints, turns and the floor reached per seed, judges nothing; the table goes to Grok | RAN with a table | M |

### Lane 8: project, tools and preview (1 agent)
Owns: project.godot, scripts/move_preview.gd, tools/debug/run_checks.py, ui_fit_check.gd, dungeon_pace_check.gd, dungeon_check.gd, town_walk_check.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| CR-05 | window/stretch/aspect "keep", window/size viewport 1152 x 648 | ui_fit gains a point asserting the layout size; a 1280 x 1024 window by the integrator | S |
| CR-08 | rendering_method gl_compatibility (and mobile) | pilot, ui_fit headless; the integrator's windowed look at Kithflare on B1F (the canvas shaders must compile under GL); if it fails, revert | S |
| UI-08 | ui_fit points: the 760 x 128 town panel at 2 and 3 lines, the party description box, shrine rows for every growing line, the dialogue box with the longest line, Options and How-to-play bottoms <= 636 (LP-01, LP-02) | run_checks ui_fit > 29 ok lines, 0 failed | M |
| FEEL-17 | dungeon_pace_check judges: FAIL on any idle pull-back or three-turn A-B-A pacing | PASS after lane 1 | S |
| LP-14 | dungeon_check: 20 seeded floors with jobs empty, no floor item of kind parcel | dungeon | S |
| LP-18 | town_walk_check: no two team members share a pos after 10 steps | town_walk | S |
| GS-09 | Tooltip 'The turn-based Hollow with your side as the team (the first one leads)' (move_preview 71) | grep -i 'mystery dungeon' scripts minus comments = 0 | S |
| T0 | run_checks.py prints a PASS / RAN / FAIL table and exits 1 on any FAIL, for the integrator | a planted failure exits 1 | S |

### Lane 9: audio (1 agent)
Owns: default_bus_layout.tres, scripts/audio/music.gd, scripts/area_music.gd, scripts/effects/storm_rain.gd, tools/audio/*, assets/audio/* (no new generation), docs/audio/sources.md, tools/debug/music_check.gd, dungeon_sfx_check.gd.

| ID | Change (where) | Verify | Size |
|---|---|---|---|
| FEEL-08 | Add bus "UI" (send Master); write the bus contract into docs/audio/sources.md; the SFX slider also scales UI (one line for lane 5 and Codex, named in the result) | music; a tree walk after each scene's _ready: no player on Master | S |
| FEEL-09 | The duck is off by Preston's 2026-10-22 answer: fix area_music.gd:7, note the state in sources.md | grep 'ducks under' = 0 | S |
| FEEL-20 | build_dungeon_sfx.py skips stairs, pickup, faint, menu_open, menu_close unless --force (the chiptune set on disk stands); list cheer and fall_whoosh as unused in sources.md; delete nothing | both tools run in either order leave the files unchanged; dungeon_sfx | S |
| LP-26 | Note the two step takes as parked in sources.md (Preston decides later) | sources.md names them | S |
| FEEL-14 | music_check rows: the approach plays hollow_flute; the faint screen beds water_rain | music | S |
| FEEL-08b | storm_rain.gd:30 on bus "SFX" | storm_open | S |

### Lane 10: docs (1 agent, or the integrator)
Owns: docs/design/pilot-story-2026-10-10.md, docs/AI_COLLABORATION.md (top entry), new docs/team/GROK_TASKS_2026-10-22.md, docs/team/CODEX_TASKS_2026-10-22.md (append section 4 below), new docs/team/TESTER_NOTES.md.

| ID | Change | Verify | Size |
|---|---|---|---|
| FLOW-16 | Remove the three 'not built yet' markers, fix the Mouth's floor count (four), mark the old arc superseded | read against the edge map in the wiring strand | S |
| FLOW-17 | The Grok task line for the spawn table rows (not the data) | GROK_TASKS exists | S |
| CR-09 | AI_COLLABORATION entry: the factory pass, lanes, what merged, what waits on Preston | top entry dated 2026-10-22 | S |
| GS-18 | TESTER_NOTES.md: where the content ends (section 9), keyboard only, Tab plays the game itself, what is not in this build, where to send findings once Preston names it | file exists | S |
| CODEX | Append section 4 to CODEX_TASKS as the queue | file updated | S |

## 4. Codex queue (precise lines; after the lanes merge unless marked "now")

| Order | Item | Task |
|---|---|---|
| now | Task 2 (ART-10) | Portraits for Skimlet, Ozbender, Valvekin via build_portraits.py; Preston looks at the crops |
| now | FX-01 | Re-cut sail_slash f04, f08, f12 and mark_glyph f00, f12, f13 so no frame is empty; dungeon_vfx passes |
| now | ART-08 | Snap muskin/n.png to muskin/s.png's palette; rebuild its dungeon and town sets; colours <= 30 |
| now | ART-09 | build_dungeon_set.py starward and build_small.py listener; starward dungeon mass 25.5 +/- 0.3 |
| now | ART-03 | Re-cut creature_village_2026_10_09.png to 384 x 216 so creature_opening.gd:44 scales by 3 |
| now | ART-01 | Reduce the pilot-path world PNGs (waking bank, hall_native, lower_floor, home_native) to 32 to 48 colours by box-downscale and median-cut, originals in docs/art/world_pre_reduce_2026-10-22/; then the rest of the 82 |
| now | ART-02 | The five town tile sheets to 32 colours or fewer |
| now | ART-05 | Re-cut the 14 flagged walk sheets with the foot row pinned and bob <= 2 px; rebuild both sets |
| now | ART-04 | build_actions.py for warden, sparkwick, huskward, riftfin, sparkjab first, then the Hollow wilds |
| now | LP-31 | Paint the Wayline mark and a parcel glyph on the two blank title sign boards |
| after | Tasks 3 and 4 | Already queued: Options separation 10, settings file .tmp then rename |
| after | LP-01, LP-02 | Title Options at y 120 (or heading at 30) and How to play at y 120 so both bottoms end above 636; ui_fit's new point passes |
| after | UI-01 | Title buttons through UI.style_button and UI.frame('panel_focus'); delete MENU_FACE and COPY_FACE |
| after | LP-03 | Title Controls tab draws ControlsText |
| after | GS-01, GS-03 | Title Options rows for screen mode (UI.apply_screen_mode) and text speed, same prefs keys; apply both at launch |
| after | GS-17 | Credits row and one-page panel: Preston McGaughy Jr, design and direction; collaborators as he lists them; Silkscreen, Pixelify Sans, Jersey, Dialogue Manager, ElevenLabs, Godot |
| after | FLOW-10 | New Game confirm when a save exists |
| after | CR-06 | 'Enter  skip' label-role hint on the storm from 2 s and on the soul prologue |
| after | LP-04, LP-06, LP-07, LP-08 | Soul prologue: lines through UI.dialogue; the soul stays over the chosen card in 'after'; the top strip becomes a gradient; cards sized to the sprite plus 24 px |
| after | W14, W19, W20 | '1-3: moves'; title copy in the house voice (Preston's words; default leave); step 02 matches the real order |
| after | FEEL-08 | storm_open 224, soul_prologue 93, main_menu 643 on their buses |
| after | CR-04 | Hollowtide icon.png and boot_splash bg_color #161f1b, show_image false |
| after | FLOW-13, FLOW-12 | export_presets.cfg Windows Desktop, excludes tools/*, docs/*, addons/godot_ai/*, scenes/_lab/*; the autoload line out of the release branch |
| after | FLOW-14 | git mv the 17 zero-reference and 9 retired-route scenes to scenes/_lab/; default checks pass |

## 5. Grok queue

| Item | Task |
|---|---|
| LP-25 | Read lane 7's lv1_run_check table; decide Mouth spawns and the autopilot rest threshold; numbers are yours |
| FX-02 | Say which of the 13 status moves belong in the dungeon at all; the rest come out of the learnsets |
| W27 | Delete data/moves/fire_move.tres or give it a real name |
| GS-20 | Name Lantern Tackle, Verdant Roar, Ember Feint before the Yard opens |
| FLOW-17 | Update the pilot story's two Hollow spawn rows to DUNGEONS["hollow"]["spawns"] with the 2026-10-12 reason |
| W28 | Later: one in-world line per creature description before any entry screen ships |

## 6. Preston's calls (default if unanswered: leave as is, except where noted)

1. One name for the first entrance: "Hollow Mouth" everywhere? (W08)
2. The growth stat's noun: "Downs" for KOs and Knockouts? (W02)
3. "Lamp Oil" or "Lantern Oil"? (W11)
4. Footsteps: wire the two paid step takes, or delete them? (LP-26)
5. Tab autopilot: a feature with a name, or debug-only? (FLOW-11)
6. Names: the three two-word creatures, the stone, the Mouth, the traps and six skills (GS-19)
7. The end card's one line from the presence, and the feedback address (GS-16, GS-18). Default: the card ships without both lines.
8. The three B1F tutorial lines and the six gate rewrites: approve the proposals or write yours (GS-07, W16, W18). Default: GS-07's proposals ship (new lines, not rewrites); W16 and W18 stay.
9. Three doors: shut signs now, or wire the Yard to the picker? (GS-12) Default: shut signs.
10. Outline rule, canon facing per flagged creature, stage height bands, the Team screen stage (ART-07, ART-06, ART-11, LP-30). Default: the evolution-scene ink still lands; the rest waits.
11. One walk pace for town and dungeon (FEEL-16)
12. The five UI sounds: chiptune (on disk) or ElevenLabs (FEEL-20). Default: chiptune stays, the rerun is guarded.
13. One player reply in each of the eight scripted scenes? (W17) Default: no.
14. Yes to a windowed smoke test by the integrator (needed for CR-08 and the stills).

## 7. Strengths to protect (no lane changes these)

The storm, soul prologue and flood talk pacing; the one dialogue system (portrait, nameplate, typed blips, paging, choices) and the St. Joseph lines in the two .dialogue files; the dungeon HUD layout and its combat log prose; the layered hit feedback (three hit tiers, essence impact, pops, burst, ring, shake, flash, hit-stop); the faint flow (partner first, defeat report, Try again keeps levels); the crash-safe save with .bak and the SaveNote; the music table and 1.2 s crossfade; the painted dungeon look (USE_TILE_ART false); the pixel 9-slice frames and TYPE roles; the per-stage sprite mass rule; the trap placement; the Job Board loop (job_board PASS); the house words everywhere they already hold; 0 print calls in the campaign scripts.

## 8. Integration order and gates

Baseline: `python tools/debug/run_checks.py --long --arena` must match after-refine-checks.md (66 PASS, 0 FAIL) before the first merge.

| Step | Merge | Gate (all PASS) |
|---|---|---|
| 1 | Lane 5 contract commit | every check loads; ui_fit, field_menu |
| 2 | Lane 9 audio | music, dungeon_sfx |
| 3 | Lane 5 rest | ui_fit, field_menu, faint, evolution |
| 4 | Lane 1 dungeon.gd | dungeon, dungeon_battle, dungeon_learn, dungeon_recruit, dungeon_trap, dungeon_vfx, dungeon_sfx, run_stop, water, warden_yield, stone |
| 5 | Lane 2 painters | dungeons, stone, hollow, music |
| 6 | Lanes 3 and 4 town | hub_town, town_room, town_walk, town_loop, job_board, storage, hall_door, hall_floors, guild_scene, board_scene, hollow_approach, story_gate, way_down |
| 7 | Lane 6 riverbank | flood_opening, flood_talk, mouth_escape, hollow_approach |
| 8 | Lane 7 save and chain | save, faint, timing, pilot (long) |
| 9 | Lane 8 project and tools | the full run: --long --arena, 0 FAIL, more ok lines than the baseline |
| 10 | Lane 10 docs | none |
| 11 | Windowed smoke (Preston's yes): title, New Game to B2F, a faint, Continue, Highbank, board, Storage, end card on the post-pilot save; stills saved beside the logs | the integrator's eyes; CR-08 reverts if the outline shader fails under GL |
| 12 | Codex "after" queue, then pass 2 (one agent: GS-04 and FEEL-01 input actions and controller) | opening_launch, soul_prologue, storm_open; input_map probe |

Commits only when Preston says. Lane results are read before any commit (the mech synthesis rule).

## 9. The alpha stopping point

The build ends after the first growth at the Growth Shrine. The player sees the end card (lane 3): fade, 'The first stretch of Hollowtide', three lines of what comes next (the deeper Hollow, more routes, the crew), 'Thanks for running it.', 'E  Keep running routes', then Highbank with every Hollow open and the objective line "That's the first stretch. Run the Hollows again or rest at home." (lane 4). TESTER_NOTES.md (lane 10) says the same, plus: keyboard only, no Item Shop or Scroll Keeper or Yard yet, and where to send findings once Preston picks the address.

## 10. Agents and cost

Ten lane agents plus one integrator. Lane 1 is the long one (two sittings in series); lanes 2, 6, 9 and 10 are short. Preston's cost rule: three agents cost about 360k tokens, so this pass is roughly 1.2 to 1.5 million. If that is too much at once, run in two waves: wave 1 lanes 5, 9, 1, 2, 10; wave 2 lanes 3, 4, 6, 7, 8. Nothing in wave 2 depends on wave 1 beyond the contract commit.
