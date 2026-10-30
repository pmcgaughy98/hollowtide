Totals, final code: v2 off: WINDOW 6, RAN 3, RETIRED 4, PASS 112, SKIPPED 1 (FAIL 0, TIMEOUT 0, BROKEN 0), counting dungeon_pace_check's two lone reruns after its fix. v2 on (HT_HIGHBANK_V2=1): WINDOW 6, RAN 3, RETIRED 4, PASS 112, SKIPPED 1 (FAIL 0, TIMEOUT 0, BROKEN 0).

The "after" table for factory pass 9 (Claude, integrator, 2026-10-28, 05:23 to 06:13). The before table is
[before-pass9-checks.md](before-pass9-checks.md).

RAN means the check ran clean but its script judges nothing. Errors counts script errors and engine errors not on the
runner's noise list.

## How it was run

Exactly as the baseline, on the integrated tree:

    python tools/debug/run_checks.py --long --arena --fixed-fps 30 --jobs 1 --logs <scratch> --md <scratch>

- `--fixed-fps 30` is now accepted by the runner (only as 30; pass 9 integration) and changes nothing: the runner
  still adds `--fixed-fps 30` to every Godot call itself and gives every check its own empty APPDATA.
- Godot: the runner's default, `Godot_v4.7.2-stable_win64.exe` (GODOT not set), as in the baseline and pass 8.
- The outer APPDATA was a scratch folder, so no Godot run could reach Preston's folder.
- v2 off: `HT_HIGHBANK_V2` removed from the environment. 05:23:41 to 05:48:17 (24.6 min).
- v2 on: `HT_HIGHBANK_V2=1`. 05:48:40 to 06:10:23 (21.7 min).
- The switch really changed: area_data_check printed `Highbank v2 switch: false (HT_HIGHBANK_V2=, ...)` in the first
  run and `Highbank v2 switch: true (HT_HIGHBANK_V2=1, ...)` in the second.
- `pilot_chain_check` is in `--long`, so the suite rows are step 3's pilot runs: 59 s (v2 off) and 88 s (v2 on), both
  PASS. The v2 run printed the new D8 line: "Highbank v2: the Tower scene played on the first visit to Tower Rise
  (tower_seen true) -> ok".

## Against the baseline

- 121 rows then, 126 now. The 5 new rows are the lanes' new checks, all PASS in both modes: dungeon_rng (D3),
  dungeon_rt_recruit (D6), road_tower_view (W3), stick_edge (R4), tower_look (W4 to W7). No check was removed.
- dual_essence_check went from RAN to RETIRED on purpose (D10: it printed the old essence_chart.gd multipliers).
  So RAN is 3 (was 4) and RETIRED 4 (was 3).
- One new failure in the first full run, **dungeon_pace_check, v2 off only: "5 problems (pacing 0, pull-backs 5)"**.
  Cause, measured with two scratch probes: since D3 the run rolls on its own generator, and on seed 4242 the team now
  goes down on B1F. The floor is built again with `floor_n` still 1, so the check keeps watching. A nest then springs on
  the new floor and its five creatures drop in from 70 px above their tiles, unseen (alpha 0). The check remembered each
  creature's last distance by its place in `ents`, so places 5 to 9 still held the old floor's creatures (0 px) and the
  drop-ins read as five pull-backs. Not a game fault. Fix: the check keys each creature by its own sprite node. The v2
  run (which started after the fix) passed, and two lone reruns with v2 off passed (0 pull-backs, 13.6 and 14.8 s).
  The fix was not shown to still catch a planted real pull-back.
- No other row changed its result. No row differs between the two modes except dungeon_pace_check (fixed between them).
- Rows whose time moved 10 s or more: arena_aim 11 to 32 s and arena_anchor 36 to 49 s (v2 off), arena_abilities 4 to
  19 s and arena_aim 5 to 32 s (v2 on); dungeon_boss, dungeon_evolve and pilot_chain ran faster. No arena file changed
  in pass 9 except a comment in arena_prototype.gd (D9), so these read as load: another worker was writing mock
  images under `docs/design/vast-scale-2026-10-27/final/` during the v2-off run. Times are not verdicts.

Checked before the suite, both found by the previous integrator's quick runs and fixed here:

- **dungeon_rt_recruit_check** (D6's new check, never run by its lane) failed 3 of 3: it called `_start_battle()`
  directly, but `in_battle` is set by the walk before it defers that call (dungeon.gd, end of the leader's step), so it
  read "battle false" with the arena running. The check now sets `in_battle` first. Then: guard in, "all ok"; guard
  taken out for one run (dungeon.gd edited, then copied back, SHA-256 fe1ca242... before and after), "2 FAILED" on the
  minion and the boss. So it tests what it says.
- **ui_fit_check** failed its shrine rows point: "widest count 166 of 122 px". Since T3 a met count reads
  "140 / 140   done", and the shrine's count column grows to the widest count while the gauge gives way, so the fixed
  122 px bound no longer described the layout. The point now bounds the row instead: the 180 px name, the count, the
  6 px gap and at least 160 px of gauge in the detail column (1056 px panel less its 24 px frame each side, the 258 px
  list, the 18 px gap and the 15 px scrollbar = 717 px). Now: "widest count 166 of 359 px (a 717 px detail column
  keeps a gauge of 353 px)".

## Did the runs change any files

Manifests of every repo file (size and modified time, 83,365 files) and hashes of every dirty file were taken before
the first suite, after it and after the timing runs (scratch `p9base\s5_suite_start` to `s8_after_timing`).

- The only repo file the checks touched: `docs/world/hollow-slice-2026-10-09/layouts.png`, rewritten by hollow_check
  in each suite with the same bytes, as in the baseline (git still calls it unchanged).
- `move_table_check` wrote its table to the log folder with the same bytes as the baseline's (af79fd38...); the
  committed `docs/creatures/move-table-2026-10-09.md` (3d2eeb95...) was not rewritten. So the dungeon lane's changes
  moved no move, power or learnset.
- My own edit to `tools/debug/dungeon_pace_check.gd` (the fix above) falls between the first two snapshots.
- Other changes in the window, none by these runs: another worker's mock images and `final_mocks.py` under
  `docs/design/vast-scale-2026-10-27/final/` (19 files added during the v2-off run, rewritten during the v2 run).

## Preston's files (`%APPDATA%/Godot/app_userdata/Hollowtide/`), SHA-256

| File | Before (the baseline, all four lanes, and this integration's first snapshot, 05:22) | After (06:22, after the last Godot run) |
|---|---|---|
| team.save | 74da42927c22d816dddbf9a6ead63226278dedd0888f14e0bddc6fb7adc1770b, 1556 bytes | same, same modified time |
| team.save.bak | 74da42927c22d816dddbf9a6ead63226278dedd0888f14e0bddc6fb7adc1770b, 1556 bytes | same, same modified time |
| menu_preferences.cfg | 59fa1b889c1ad37fbc0c2f0e92c7a9dc9bd31bc2f85af8b1a0f8993de63d3afa, 28 bytes | same, same modified time |
| game_prefs.cfg | absent | absent |

summer_engine_settings.cfg was not opened. One thing not explained: Godot's own `logs` folder in Preston's
Hollowtide folder holds five 73-byte logs (the engine banner and nothing else) written 05:15:51 to 05:16:21 on
2026-10-28, before this integration's first Godot run (05:21:31). Every Godot run of this integration had APPDATA
pointed at a scratch folder. The resume note says the previous integrator's edits were parse-checked with
`--check-only` before this run; a run like that without a scratch APPDATA would leave logs like these, but that was
not confirmed. Nothing in that folder is newer than 05:16:21, and his save and prefs did not change.

## The table

| Check | v2 off | Secs | v2 on | Secs | Exit | Fail lines | Errors | First problem or note |
|---|---|---|---|---|---|---|---|---|
| dungeon_pace_check | FAIL | 12 | PASS | 13 | 1 / 0 | 1 / 0 | 0 | off: RESULT: 5 problems (pacing 0, pull-backs 5); on:  |
| galeshear_wings_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: sw.png clear borders: true |
| listener_palette_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: [godot_ai game_helper] registered mcp capture (debugger active=false, logger=true) |
| opening_launch_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: [godot_ai game_helper] registered mcp capture (debugger active=false, logger=true) |
| relay_yard_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Walk riverfront east lane: PASS |
| riverfront_quay_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Board introduces optional round without changing main objective: PASS |
| world_navigation_check | WINDOW | 60 | WINDOW | 60 | 124 | 0 | 0 | needs a window; last line: Distant pin starts with adjacent riverfront: PASS |
| arena_sizes_check | RAN | 3 | RAN | 3 | 0 | 0 | 0 | prints values but judges nothing |
| arena_vfx_check | RAN | 3 | RAN | 3 | 0 | 0 | 0 | prints values but judges nothing |
| arena_vfx_pass_check | RAN | 3 | RAN | 3 | 0 | 0 | 0 | prints values but judges nothing; 8 screenshots skipped headless |
| arena_scourmaw_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| arena_stormwick_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| dual_essence_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| first_morning_check | RETIRED | 1 | RETIRED | 1 | 2 | 0 | 0 | retired on purpose |
| area_data_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| arena_abilities_check | PASS | 19 | PASS | 3 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_aim_check | PASS | 32 | PASS | 4 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_ambusher_check | PASS | 9 | PASS | 5 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_anchor_check | PASS | 49 | PASS | 11 | 0 | 0 | 0 |  |
| arena_backline_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_canvaswing_check | PASS | 9 | PASS | 8 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_chain_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 |  |
| arena_charms_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 |  |
| arena_combat_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_combo_check | PASS | 4 | PASS | 3 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_epic_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 8 screenshots skipped headless |
| arena_feedback_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_feel_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_frames_check | PASS | 4 | PASS | 3 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_hitbox_check | PASS | 5 | PASS | 3 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_ironvent_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_kitsense_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_listener_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_motion_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_objective_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_oxbowarchon_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 | 14 screenshots skipped headless |
| arena_picker_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 |  |
| arena_press_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_protector_check | PASS | 12 | PASS | 11 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_rampart_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 7 screenshots skipped headless |
| arena_reach_check | PASS | 3 | PASS | 3 | 0 | 0 | 0 | 5 screenshots skipped headless |
| arena_spotter_check | PASS | 10 | PASS | 9 | 0 | 0 | 0 | 9 screenshots skipped headless |
| arena_stage_kits_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 3 screenshots skipped headless |
| arena_tackle_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_tank_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 5 screenshots skipped headless |
| arena_terrain_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 2 screenshots skipped headless |
| arena_verbs_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 | 6 screenshots skipped headless |
| arena_vfx2_check | PASS | 4 | PASS | 3 | 0 | 0 | 0 | 4 screenshots skipped headless |
| arena_vitrecrag_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 8 screenshots skipped headless |
| art_slots_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 |  |
| board_scene_check | PASS | 8 | PASS | 5 | 0 | 0 | 0 |  |
| building_template_check | PASS | 2 | PASS | 1 | 0 | 0 | 0 |  |
| dungeon_action_check | PASS | 9 | PASS | 7 | 0 | 0 | 0 |  |
| dungeon_aim_check | PASS | 5 | PASS | 4 | 0 | 0 | 0 |  |
| dungeon_battle_check | PASS | 8 | PASS | 7 | 0 | 0 | 0 |  |
| dungeon_boss_check | PASS | 40 | PASS | 28 | 0 | 0 | 0 |  |
| dungeon_chain_check | PASS | 38 | PASS | 37 | 0 | 0 | 0 |  |
| dungeon_check | PASS | 19 | PASS | 19 | 0 | 0 | 0 | 4 screenshots skipped headless |
| dungeon_evolve_check | PASS | 34 | PASS | 35 | 0 | 0 | 0 |  |
| dungeon_iq_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_learn_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_level_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| dungeon_position_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 1 screenshots skipped headless |
| dungeon_recruit_check | PASS | 11 | PASS | 11 | 0 | 0 | 0 | 2 screenshots skipped headless |
| dungeon_rng_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 |  |
| dungeon_rt_recruit_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 |  |
| dungeon_run_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 | 4 screenshots skipped headless |
| dungeon_sfx_check | PASS | 10 | PASS | 9 | 0 | 0 | 0 |  |
| dungeon_tactics_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_teamsense_check | PASS | 10 | PASS | 7 | 0 | 0 | 0 |  |
| dungeon_trap_check | PASS | 37 | PASS | 35 | 0 | 0 | 0 |  |
| dungeon_vfx_check | PASS | 4 | PASS | 5 | 0 | 0 | 0 |  |
| dungeon_warn_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 | 2 screenshots skipped headless |
| dungeons_check | PASS | 20 | PASS | 11 | 0 | 0 | 0 |  |
| evolution_check | PASS | 11 | PASS | 7 | 0 | 0 | 0 |  |
| face_crop_check | PASS | 2 | PASS | 1 | 0 | 0 | 0 |  |
| faint_check | PASS | 11 | PASS | 9 | 0 | 0 | 0 |  |
| field_menu_check | PASS | 9 | PASS | 7 | 0 | 0 | 0 |  |
| first_fight_check | PASS | 6 | PASS | 5 | 0 | 0 | 0 |  |
| flood_opening_check | PASS | 6 | PASS | 6 | 0 | 0 | 0 |  |
| flood_talk_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| guild_scene_check | PASS | 6 | PASS | 4 | 0 | 0 | 0 |  |
| hall_door_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| hall_floors_check | PASS | 10 | PASS | 5 | 0 | 0 | 0 |  |
| hollow_approach_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| hollow_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 | 3 screenshots skipped headless |
| hollow_wilds_check | PASS | 18 | PASS | 13 | 0 | 0 | 0 |  |
| hub_town_check | PASS | 13 | PASS | 7 | 0 | 0 | 0 |  |
| input_map_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| job_board_check | PASS | 11 | PASS | 9 | 0 | 0 | 0 |  |
| lv1_run_check | PASS | 65 | PASS | 64 | 0 | 0 | 0 |  |
| matchup_picker_check | PASS | 8 | PASS | 8 | 0 | 0 | 0 |  |
| mouth_escape_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| move_table_check | PASS | 24 | PASS | 24 | 0 | 0 | 0 |  |
| music_check | PASS | 16 | PASS | 14 | 0 | 0 | 0 |  |
| opening_flow_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| pad_play_check | PASS | 11 | PASS | 10 | 0 | 0 | 0 |  |
| pilot_chain_check | PASS | 59 | PASS | 88 | 0 | 0 | 0 |  |
| rebind_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| road_check | PASS | 9 | PASS | 6 | 0 | 0 | 0 |  |
| road_tower_view_check | PASS | 7 | PASS | 7 | 0 | 0 | 0 |  |
| roll_call_check | PASS | 6 | PASS | 7 | 0 | 0 | 0 |  |
| roster_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| run_stop_check | PASS | 5 | PASS | 6 | 0 | 0 | 0 |  |
| save_check | PASS | 12 | PASS | 10 | 0 | 0 | 0 |  |
| soul_prologue_check | PASS | 4 | PASS | 4 | 0 | 0 | 0 |  |
| springvault_check | PASS | 7 | PASS | 11 | 0 | 0 | 0 |  |
| stick_edge_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| stone_check | PASS | 14 | PASS | 11 | 0 | 0 | 0 |  |
| storage_check | PASS | 10 | PASS | 6 | 0 | 0 | 0 |  |
| storm_open_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| story_gate_check | PASS | 7 | PASS | 4 | 0 | 0 | 0 |  |
| timing_check | PASS | 26 | PASS | 21 | 0 | 0 | 0 |  |
| tower_lean_check | PASS | 7 | PASS | 5 | 0 | 0 | 0 |  |
| tower_look_check | PASS | 1 | PASS | 1 | 0 | 0 | 0 |  |
| tower_parts_check | PASS | 2 | PASS | 2 | 0 | 0 | 0 |  |
| tower_reveal_check | PASS | 8 | PASS | 5 | 0 | 0 | 0 |  |
| town_loop_check | PASS | 12 | PASS | 10 | 0 | 0 | 0 |  |
| town_props_check | PASS | 10 | PASS | 4 | 0 | 0 | 0 |  |
| town_room_check | PASS | 18 | PASS | 16 | 0 | 0 | 0 |  |
| town_walk_check | PASS | 6 | PASS | 4 | 0 | 0 | 0 |  |
| ui_fit_check | PASS | 12 | PASS | 10 | 0 | 0 | 0 |  |
| warden_yield_check | PASS | 8 | PASS | 9 | 0 | 0 | 0 |  |
| water_check | PASS | 5 | PASS | 5 | 0 | 0 | 0 |  |
| way_down_check | PASS | 6 | PASS | 4 | 0 | 0 | 0 |  |
| back_idle_check | SKIPPED |  | SKIPPED |  |  |  |  | a tool that needs an argument |

Rerun after the pace fix, v2 off, alone: `python tools/debug/run_checks.py dungeon_pace --fixed-fps 30 --jobs 1`, twice:
PASS 13.6 s and PASS 14.8 s, both "sprite pull-backs while idle: 0", "RESULT: no pacing and no pull-backs".

## Timing

Measured the way the baseline and pass 8 did: timing_check alone after the suites, through the runner
(`python tools/debug/run_checks.py timing --jobs 1 --logs <scratch>`), three runs with v2 off (06:10, 06:11, 06:11) and
two with v2 on (06:12). All five said TIMING: PASS.

Machine: not idle. Another worker was writing mock images during the suites, and CPU load read 56% right after the
timing runs (the baseline read 22 to 23% before its runs). So the numbers below are, if anything, measured under more
load than the baseline's.

| Measure | Pass 8 | Before pass 9, v2 off (runs 1, 2, 3) | After pass 9, v2 off (runs 1, 2, 3) | Before, v2 on (1, 2) | After, v2 on (1, 2) |
|---|---|---|---|---|---|
| Slowest floor build (20 floors) | 1.40 s (1.42) | 1.63, 1.58, 1.60 s | 1.30, 1.19, 1.37 s | 2.23, 1.70 s | 1.34, 1.44 s |
| Mean floor build | 0.74 s (0.73) | 0.85, 0.84, 0.84 s | 0.71, 0.68, 0.75 s | 0.94, 0.86 s | 0.73, 0.77 s |
| Ruin floors, mean | 0.53 s (0.52) | 0.62, 0.61, 0.61 s | 0.55, 0.53, 0.59 s | 0.65, 0.63 s | 0.55, 0.58 s |
| Riverbank floors (Warren), mean | 1.02 s (1.01) | 1.16, 1.16, 1.17 s | 1.01, 0.96, 1.02 s | 1.32, 1.16 s | 1.07, 1.13 s |
| Valley floors (The Hollow B1F), mean | 1.13 s (1.13) | 1.28, 1.26, 1.27 s | 0.76, 0.77, 0.87 s | 1.58, 1.33 s | 0.82, 0.82 s |
| Dungeon scene ready with its first floor | 1554 ms (1554) | 1854, 1781, 1728 ms | 1685, 1744, 1613 ms | 1886, 1780 ms | 1677, 1572 ms |
| Highbank first arrival, painted (headless, one call) | 4268 ms (4323) | 4706, 4447, 4494 ms | 4313, 4144, 4028 ms | 1284, 1304 ms | 1240, 1252 ms |
| Highbank warm arrival | 60 ms (59) | 57, 64, 60 ms | 50, 60, 50 ms | 15, 14 ms | 10, 10 ms |
| `TownRoom.prepare('hall')` / Hall arrival after it | 274 / 160 ms | 271 / 216, 304 / 211, 273 / 184 ms | 281 / 169, 240 / 167, 239 / 167 ms | 287 / 184, 267 / 183 ms | 246 / 163, 233 / 160 ms |
| `prepare('hall_low')` / arrival | 801 / 2 ms | 837 / 2, 860 / 3, 766 / 3 ms | 745 / 2, 688 / 3, 693 / 2 ms | 799 / 3, 798 / 4 ms | 799 / 2, 692 / 2 ms |
| `prepare('home')` / arrival | 102 / 3 ms | 117 / 3, 157 / 3, 124 / 3 ms | 108 / 3, 109 / 3, 106 / 3 ms | 116 / 3, 116 / 3 ms | 107 / 3, 102 / 3 ms |
| Static memory over 20 floors | +14.6 MB | +14.6 MB (94.4 to 109.0) each run | +14.5 MB (94.4 to 109.0) each run | +14.6 MB each run | +14.5 MB each run |
| Static memory at the end | 145.6 MB | 156.4 MB each run | 156.9 MB each run | 138.7 MB each run | 139.1 MB each run |

(The warm arrival is printed to two decimals of a second, so 0.05 s reads 50 ms.)

What the numbers say, and what they do not:

- Every floor row is better than the baseline and the valley floors (The Hollow B1F) dropped the most, 1.26 to 1.28 s
  down to 0.76 to 0.87 s, below pass 8's 1.13 s. That fits D2: the dungeon's art cache now keeps the sets it already
  has and moves a hit to the back, so building The Hollow no longer pushes the team's sets out and reads them again.
  The other floor rows are back near pass 8's numbers.
- Highbank's first arrival is 4028 to 4313 ms, back near pass 8's 4268 ms. T7's cache key change does not show in this
  number: each timing run starts with an empty APPDATA, so every first arrival paints the street.
- The rooms' prepare times are a little lower (R2 moved painting onto a worker in a window only; headless it is off),
  and the Hall's arrival is 167 ms against the baseline's 184 to 216 ms.
- Static memory at the end is 0.5 MB above the baseline in both modes (156.9 against 156.4 MB; 139.1 against
  138.7 MB) and the floors' own growth is unchanged. The 10.8 MB the baseline found above pass 8 is still there and is
  still not traced.
- The windowed live-stall numbers are in PASS9_RESULT (the re-shoot's hitch logs), not here.

## Logs

All in this session's scratch folder, `...\scratchpad\integ9\`: `v1_logs\` and `v2_logs\` (one log per check), `v1.md`
and `v2.md` (the runner's own tables), `merged.md`, `t1v1`, `t2v1`, `t3v1`, `t1v2`, `t2v2` (timing), `pace_v1_1`,
`pace_v1_2` (the pace reruns), `q2` and `q3_noguard` (the D6 and ui_fit checks before the suite, and the guard-out run),
`pace_probe.txt` and `pace_probe2.txt` (the pace diagnosis), and `..\p9base\s5_suite_start` to `s8_after_timing` (file
manifests).
