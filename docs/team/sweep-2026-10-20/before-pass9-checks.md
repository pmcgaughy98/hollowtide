Totals: v2 off: WINDOW 6, RAN 4, RETIRED 3, PASS 107, SKIPPED 1 (FAIL 0, TIMEOUT 0, BROKEN 0). v2 on (HT_HIGHBANK_V2=1): WINDOW 6, RAN 4, RETIRED 3, PASS 107, SKIPPED 1 (FAIL 0, TIMEOUT 0, BROKEN 0).

The "before" baseline for factory pass 9 (Claude, 2026-10-27, 17:21 to 18:16). Nothing was edited for it; the only
repo file it wrote is this one.

RAN means the check ran clean but its script judges nothing. Errors counts script errors and engine errors not on the
runner's noise list.

## How it was run

The same command pass 8 and passes 3 to 7 used for the full suite, with `--jobs 1` as pass 9 asks:

    python tools/debug/run_checks.py --long --arena --jobs 1 --logs <scratch> --md <scratch>

- The runner adds `--fixed-fps 30` to every Godot call itself and gives every check its own empty APPDATA
  (run_checks.py lines 213 to 215). It has no `--fixed-fps` flag of its own, so the flag is not typed.
- Godot: the runner's default, `Godot_v4.7.2-stable_win64.exe` (GODOT was not set), as in pass 8.
- The outer APPDATA was a scratch folder as well, so no Godot run could reach Preston's folder.
- v2 off: `HT_HIGHBANK_V2` removed from the environment. 17:21:54 to 17:48:25 (26.5 min).
- v2 on: `HT_HIGHBANK_V2=1`. 17:49:17 to 18:12:53 (23.6 min).
- The switch really changed: area_data_check printed `Highbank v2 switch: false (HT_HIGHBANK_V2=, ...)` in the first
  run and `Highbank v2 switch: true (HT_HIGHBANK_V2=1, ...)` in the second, and the town checks walked different maps
  (hub_town_check: the ferry at (28, 27) against (22, 10)).
- Passes 3 to 6 recorded `--jobs 3`; pass 8 did not record its jobs count. Verdicts do not depend on it, the Secs
  column does.

## Against pass 8

- 99 PASS then, 107 PASS now in both modes. The 8 extra PASS are checks added since pass 8, all passing in both
  modes: area_data, art_slots, building_template, road, tower_lean, tower_parts, tower_reveal, town_props. No check
  was removed. tower_lean_check and tower_parts_check are untracked files (the Wayline Tower build);
  building_template_check, road_check and tower_reveal_check have uncommitted edits.
- The WINDOW 6, RAN 4, RETIRED 3 and SKIPPED 1 are the same checks as pass 8.
- Nothing failed, so nothing was rerun. No row differs between the two modes in result, exit, fail lines or errors.
- pilot_chain passed in 76 s (v2 off) and 80 s (v2 on); pass 8's three runs took 66, 95 and 73 s. Its random runs
  differ each time, so the time is not a verdict.

## Did the runs change any files

A manifest of every repo file (size and modified time, 82,825 files outside .git and .godot) was taken before the
first run, after each suite and after the timing runs, with a SHA-256 of every file git calls changed or untracked.

- The only repo file the checks touched: `docs/world/hollow-slice-2026-10-09/layouts.png`, rewritten by
  hollow_check in each suite with the same bytes (its time changed, git still calls it unchanged).
  `docs/creatures/move-table-2026-10-09.md` was not rewritten.
- Other files changed during the window, none by these runs: Codex's `docs/art/slot-candidates/cx-14-tower-crown/`
  delivery (its CODEX_IN_PROGRESS marker went away and DELIVERY.md, review and preview files arrived), mock images
  and scripts under `docs/design/great-tree-2026-10-27/` (v2_boughs, v2_skyline, final_v2), and the planner's
  PASS9_PLAN_2026-10-27.md. So the machine was not idle during the suites.
- The window checks write to `D:/dev/hollowtide-*` as before (outside the repo).

## Preston's files (`%APPDATA%/Godot/app_userdata/Hollowtide/`), SHA-256

| File | Before (17:21) | After (18:16) |
|---|---|---|
| team.save | 74da42927c22d816dddbf9a6ead63226278dedd0888f14e0bddc6fb7adc1770b, 1556 bytes | same |
| team.save.bak | 74da42927c22d816dddbf9a6ead63226278dedd0888f14e0bddc6fb7adc1770b, 1556 bytes | same |
| menu_preferences.cfg | 59fa1b889c1ad37fbc0c2f0e92c7a9dc9bd31bc2f85af8b1a0f8993de63d3afa, 28 bytes | same |
| game_prefs.cfg | absent | absent |

Modified times are unchanged too. Godot's own log folder there has nothing newer than 15:33, before these runs.
summer_engine_settings.cfg was not opened.

## The table

| Check | v2 off | Secs | v2 on | Secs | Exit | Fail lines | Errors | First problem or note |
|---|---|---|---|---|---|---|---|---|
| galeshear_wings_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: sw.png clear borders: true |
| listener_palette_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: [godot_ai game_helper] registered mcp capture (debugger active=false, logger=true) |
| opening_launch_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: [godot_ai game_helper] registered mcp capture (debugger active=false, logger=true) |
| relay_yard_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Walk riverfront east lane: PASS |
| riverfront_quay_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Board introduces optional round without changing main objective: PASS |
| world_navigation_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Distant pin starts with adjacent riverfront: PASS |
| arena_sizes_check | RAN | 3 | RAN | 4 | 0 | 0 | 0 | prints values but judges nothing |
| arena_vfx_check | RAN | 3 | RAN | 3 | 0 | 0 | 0 | prints values but judges nothing |
| arena_vfx_pass_check | RAN | 3 | RAN | 4 | 0 | 0 | 0 | prints values but judges nothing; 8 screenshots skipped headless |
| dual_essence_check | RAN | 1 | RAN | 1 | 0 | 0 | 0 | prints values but judges nothing |
| arena_scourmaw_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| arena_stormwick_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| first_morning_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| area_data_check | PASS | 3 | PASS | 1 | 0 | 0 | 0 |  |
| arena_abilities_check | PASS | 20 | PASS | 4 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_aim_check | PASS | 11 | PASS | 5 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_ambusher_check | PASS | 8 | PASS | 6 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_anchor_check | PASS | 36 | PASS | 13 | 0 | 0 | 0 |  |
| arena_backline_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_canvaswing_check | PASS | 10 | PASS | 10 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_chain_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 |  |
| arena_charms_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| arena_combat_check | PASS | 4 | PASS | 3 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_combo_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_epic_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 | 8 screenshots skipped headless |
| arena_feedback_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_feel_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_frames_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_hitbox_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_ironvent_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_kitsense_check | PASS | 8 | PASS | 9 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_listener_check | PASS | 10 | PASS | 10 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_motion_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_objective_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_oxbowarchon_check | PASS | 8 | PASS | 7 | 0 | 0 | 0 | 14 screenshots skipped headless |
| arena_picker_check | PASS | 10 | PASS | 9 | 0 | 0 | 0 |  |
| arena_press_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_protector_check | PASS | 13 | PASS | 14 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_rampart_check | PASS | 5 | PASS | 6 | 0 | 0 | 0 | 7 screenshots skipped headless |
| arena_reach_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 5 screenshots skipped headless |
| arena_spotter_check | PASS | 10 | PASS | 11 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_stage_kits_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_tackle_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_tank_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 5 screenshots skipped headless |
| arena_terrain_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_verbs_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_vfx2_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_vitrecrag_check | PASS | 6 | PASS | 7 | 0 | 0 | 0 | 8 screenshots skipped headless |
| art_slots_check | PASS | 6 | PASS | 5 | 0 | 0 | 0 |  |
| board_scene_check | PASS | 14 | PASS | 7 | 0 | 0 | 0 |  |
| building_template_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| dungeon_action_check | PASS | 18 | PASS | 9 | 0 | 0 | 0 |  |
| dungeon_aim_check | PASS | 5 | PASS | 6 | 0 | 0 | 0 |  |
| dungeon_battle_check | PASS | 11 | PASS | 10 | 0 | 0 | 0 |  |
| dungeon_boss_check | PASS | 57 | PASS | 39 | 0 | 0 | 0 |  |
| dungeon_chain_check | PASS | 43 | PASS | 45 | 0 | 0 | 0 |  |
| dungeon_check | PASS | 23 | PASS | 22 | 0 | 0 | 0 | 4 screenshots skipped headless |
| dungeon_evolve_check | PASS | 55 | PASS | 49 | 0 | 0 | 0 |  |
| dungeon_iq_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 |  |
| dungeon_learn_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 |  |
| dungeon_level_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_pace_check | PASS | 14 | PASS | 14 | 0 | 0 | 0 |  |
| dungeon_position_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 1 screenshots skipped headless |
| dungeon_recruit_check | PASS | 13 | PASS | 13 | 0 | 0 | 0 | 2 screenshots skipped headless |
| dungeon_run_check | PASS | 9 | PASS | 9 | 0 | 0 | 0 | 4 screenshots skipped headless |
| dungeon_sfx_check | PASS | 12 | PASS | 10 | 0 | 0 | 0 |  |
| dungeon_tactics_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_teamsense_check | PASS | 13 | PASS | 10 | 0 | 0 | 0 |  |
| dungeon_trap_check | PASS | 41 | PASS | 42 | 0 | 0 | 0 |  |
| dungeon_vfx_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_warn_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 | 2 screenshots skipped headless |
| dungeons_check | PASS | 25 | PASS | 13 | 0 | 0 | 0 |  |
| evolution_check | PASS | 13 | PASS | 8 | 0 | 0 | 0 |  |
| face_crop_check | PASS | 2 | PASS | 1 | 0 | 0 | 0 |  |
| faint_check | PASS | 13 | PASS | 10 | 0 | 0 | 0 |  |
| field_menu_check | PASS | 11 | PASS | 8 | 0 | 0 | 0 |  |
| first_fight_check | PASS | 6 | PASS | 5 | 0 | 0 | 0 |  |
| flood_opening_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 |  |
| flood_talk_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 |  |
| guild_scene_check | PASS | 7 | PASS | 4 | 0 | 0 | 0 |  |
| hall_door_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| hall_floors_check | PASS | 10 | PASS | 5 | 0 | 0 | 0 |  |
| hollow_approach_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| hollow_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 | 3 screenshots skipped headless |
| hollow_wilds_check | PASS | 20 | PASS | 14 | 0 | 0 | 0 |  |
| hub_town_check | PASS | 15 | PASS | 8 | 0 | 0 | 0 |  |
| input_map_check | PASS | 1 | PASS | 2 | 0 | 0 | 0 |  |
| job_board_check | PASS | 13 | PASS | 10 | 0 | 0 | 0 |  |
| lv1_run_check | PASS | 65 | PASS | 67 | 0 | 0 | 0 |  |
| matchup_picker_check | PASS | 8 | PASS | 9 | 0 | 0 | 0 |  |
| mouth_escape_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| move_table_check | PASS | 28 | PASS | 28 | 0 | 0 | 0 |  |
| music_check | PASS | 20 | PASS | 19 | 0 | 0 | 0 |  |
| opening_flow_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 |  |
| pad_play_check | PASS | 12 | PASS | 11 | 0 | 0 | 0 |  |
| pilot_chain_check | PASS | 76 | PASS | 80 | 0 | 0 | 0 |  |
| rebind_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| road_check | PASS | 10 | PASS | 7 | 0 | 0 | 0 |  |
| roll_call_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 |  |
| roster_check | PASS | 1 | PASS | 2 | 0 | 0 | 0 |  |
| run_stop_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 |  |
| save_check | PASS | 13 | PASS | 10 | 0 | 0 | 0 |  |
| soul_prologue_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| springvault_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 |  |
| stone_check | PASS | 17 | PASS | 14 | 0 | 0 | 0 |  |
| storage_check | PASS | 10 | PASS | 7 | 0 | 0 | 0 |  |
| storm_open_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| story_gate_check | PASS | 8 | PASS | 4 | 0 | 0 | 0 |  |
| timing_check | PASS | 28 | PASS | 25 | 0 | 0 | 0 |  |
| tower_lean_check | PASS | 7 | PASS | 6 | 0 | 0 | 0 |  |
| tower_parts_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| tower_reveal_check | PASS | 8 | PASS | 5 | 0 | 0 | 0 |  |
| town_loop_check | PASS | 14 | PASS | 12 | 0 | 0 | 0 |  |
| town_props_check | PASS | 12 | PASS | 5 | 0 | 0 | 0 |  |
| town_room_check | PASS | 17 | PASS | 12 | 0 | 0 | 0 |  |
| town_walk_check | PASS | 8 | PASS | 5 | 0 | 0 | 0 |  |
| ui_fit_check | PASS | 14 | PASS | 11 | 0 | 0 | 0 |  |
| warden_yield_check | PASS | 10 | PASS | 10 | 0 | 0 | 0 |  |
| water_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 |  |
| way_down_check | PASS | 7 | PASS | 4 | 0 | 0 | 0 |  |
| back_idle_check | SKIPPED |  | SKIPPED |  |  |  |  | a tool that needs an argument |

## Timing

Measured the way pass 8 did: timing_check alone, after the suites, through the runner
(`python tools/debug/run_checks.py timing --jobs 1 --logs <scratch>`, so `--fixed-fps 30` and an empty APPDATA). It
builds 20 normal floors (slowest and mean `_build_floor`, mean by look), times the dungeon scene up to its first floor
(Hollow Mouth B1F, seed 1), times Highbank's `hub_town._ready` on the first arrival (paints the street, headless, one
call) and again warm, times `TownRoom.prepare` and each room's arrival, and reads `OS.get_static_memory_usage()` before
and after the 20 floors and at the end. Three runs with v2 off (18:13, 18:14, 18:16) and two with v2 on (18:15). All
five said TIMING: PASS.

Machine: CPU load read 23% and 22% just before the runs, with the Summer app, Chrome, the League client and the Codex
and Grok sessions open, and the great-tree mock script still writing files. Pass 8 called its run a quiet machine.

| Measure | Pass 8 | Before pass 9, v2 off (runs 1, 2, 3) | Before pass 9, v2 on (runs 1, 2) |
|---|---|---|---|
| Slowest floor build (20 floors) | 1.40 s (1.42) | 1.63, 1.58, 1.60 s | 2.23, 1.70 s |
| Mean floor build | 0.74 s (0.73) | 0.85, 0.84, 0.84 s | 0.94, 0.86 s |
| Ruin floors, mean | 0.53 s (0.52) | 0.62, 0.61, 0.61 s | 0.65, 0.63 s |
| Riverbank floors (Warren), mean | 1.02 s (1.01) | 1.16, 1.16, 1.17 s | 1.32, 1.16 s |
| Valley floors, mean | 1.13 s (1.13) | 1.28, 1.26, 1.27 s | 1.58, 1.33 s |
| Dungeon scene ready with its first floor | 1554 ms (1554) | 1854, 1781, 1728 ms | 1886, 1780 ms |
| Highbank first arrival, painted (headless, one call) | 4268 ms (4323) | 4706, 4447, 4494 ms | 1284, 1304 ms |
| Highbank warm arrival | 60 ms (59) | 57, 64, 60 ms | 15, 14 ms |
| `TownRoom.prepare('hall')` / Hall arrival after it | 274 / 160 ms | 271 / 216, 304 / 211, 273 / 184 ms | 287 / 184, 267 / 183 ms |
| `prepare('hall_low')` / arrival | 801 / 2 ms | 837 / 2, 860 / 3, 766 / 3 ms | 799 / 3, 798 / 4 ms |
| `prepare('home')` / arrival | 102 / 3 ms | 117 / 3, 157 / 3, 124 / 3 ms | 116 / 3, 116 / 3 ms |
| Static memory over 20 floors | +14.6 MB | +14.6 MB (94.4 to 109.0) each run | +14.6 MB (94.4 to 109.0) each run |
| Static memory at the end | 145.6 MB | 156.4 MB each run | 138.7 MB each run |

What the numbers say, and what they do not:

- Floor builds read about 0.1 s slower on the mean (0.74 to 0.84 s) and the dungeon scene 170 to 300 ms slower than
  pass 8. The same floor code swung from 1.70 to 2.23 s slowest within two minutes (v2 on, runs 1 and 2; v2 is a town
  switch), so load on this machine moves these numbers by that much. They are not shown to be a code
  regression. A rerun on a quiet machine would settle it.
- Highbank's first arrival with v2 off reads 4447 to 4706 ms against pass 8's 4268 and 4323 ms: 120 to 440 ms
  more, the same caveat applies.
- Static memory at the end does not move with load (156.4 MB in all three runs) and is 10.8 MB above pass 8's
  145.6 MB. The floors' own growth is unchanged (+14.6 MB). Pass 8 did not record the floor phase's start, so this
  baseline cannot say which phase grew; it was not traced. With v2 on the end reads 138.7 MB, 17.7 MB under v2 off,
  and v2's first arrival is 1.3 s against 4.4 to 4.7 s.
- The live stalls (windowed wall-clock probe) were not taken for this baseline.

## Logs

All in the scratch folder of this session, `...\scratchpad\p9base\`: `v1_logs\` and `v2_logs\` (one log per check),
`v1.md` and `v2.md` (the runner's own tables), `t1v1`, `t2v1`, `t3v1`, `t1v2`, `t2v2` (timing), `s0_before` to
`s3_after_timing` (file manifests, git status, dirty-file hashes and a copy of every dirty file taken before the
first run).
