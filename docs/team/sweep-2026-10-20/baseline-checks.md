# Baseline checks before the upgrade sweep (2026-10-21)

Claude ran Hollowtide's own headless checks to get a starting point. Nothing in the game was changed.

## Result

| Class | Count |
|---|---|
| PASS | 33 |
| WINDOW-ONLY | 16 |
| FAIL (real) | 10 |
| TIMEOUT | 7 |
| BROKEN | 0 |
| RETIRED | 1 |

67 checks in all. 10 fail for real. No check failed to parse or compile.

## How it was run

- The repo was at commit 810696e4b ("Baseline before the upgrade sweep"), branch master.
- Godot 4.7.2: `C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe`.
- Every `tools/debug/*_check.gd` ran, except the `arena_` ones and `pilot_chain_check.gd`.
- Each check got a fresh, empty APPDATA folder in the session scratch folder. No real save was touched.
- Command: `<godot> --headless --path C:/Users/pmcga/dev/hollowtide --script res://tools/debug/<name>.gd`.
- The checks ran one at a time, with a 240 second timeout each. Logs went to the scratch folder, not the repo.
- Ran 2026-10-21, 07:28 to 08:53. About 84 minutes of check time.
- A partial run from the night before (2026-10-20, 22:20 to 22:41) was set aside. The baseline commit landed in the middle of it, at 22:35, so all 67 were run again.

## How each check was classed

- **PASS**: exit 0, no failing lines and no real script errors. Some only print a report and assert nothing. The notes say which.
- **WINDOW-ONLY**: the only errors are screenshot ones (`save_png` or `get_size` on a null image). Or the check waits for a rendered frame, which never comes headless. These need a window to judge.
- **FAIL (real)**: a failing line, a WRONG line, a "problems" result, or a script error in game code.
- **TIMEOUT**: still running at 240 seconds, for a reason other than a screenshot.
- **BROKEN**: a parse or compile error. None found.
- **RETIRED**: `first_morning_check` exits 2 on purpose and runs no assertions.

The FAIL pattern from the task looks for lines starting FAIL, or with "-> FAIL" or "FAILED". It misses checks that print "-> WRONG" and "RESULT: N problems". So the table has a WRONG column too.

Every log also has engine noise that is not counted: `custom_samplers` shader warnings, and ObjectDB leak warnings at exit.

## Real failures

1. **flood_talk_check** (exit 1). "The talk ends on the riverbank with Tallowroot and Rimefin (creature_prologue.tscn, []) -> FAIL". The team list is empty.
2. **hall_floors_check** (exit 1, 6 failed). First: "Work floor: the stairs lead down (nowhere) -> FAIL". The stairs and doors between hall floors lead nowhere.
3. **stone_check** (exit 0, 4 failed). First: "The Warden beaten: the stone is ; the Hollow beaten false -> FAIL". It also has a script error: `'intro'` on a freed object at `scripts/dungeon/stone_scene.gd:389`.
4. **opening_flow_check** (exit 1). "Explicit campaign title reveals: FAIL". The title never reached its main page. This may be headless timing. Check it once with a window.
5. **dungeon_level_check** (exit 0, 3 problems). First: "100 EXP from Lv 1: Lv 2 with 60 left, health 36 -> 37, sound ["level_up"] -> WRONG".
6. **dungeon_teamsense_check** (exit 0, 2 problems). First: "To the hurt: plan { "kind": "move", "d": (0, 1) }, closer false -> WRONG".
7. **evolution_check** (exit 0, 1 problem). "No one else: 'Tallowroot is ready to grow. Let it grow here? ...' -> WRONG". A second creature is offered growth when it should not be.
8. **springvault_check** (exit 0, 7 problems). First: "Troughspine: Troughspine knows ["spring_spit"], art true -> WRONG". Seep healing, rooting and the partner AI all report WRONG.
9. **town_walk_check** (exit 0, 2 problems). First: "kithflare: 3 different pictures while walking, standing again true -> WRONG". Tallowroot shows the same problem.
10. **dungeon_battle_check** (exit 0). It has no failing line but 5 game script errors. First: "SCRIPT ERROR: Out of bounds get index '7' (on base: 'Array[Dictionary]')" at `scripts/dungeon/dungeon.gd:1580` (position_tags). The others are at lines 1336, 1346, 1483 and 2232.

## Timeouts that hide a real error

These hung, but the log shows why. They are classed TIMEOUT, not FAIL.

- **first_fight_check**: "On the levee (hometown): the Cinderhide's battle screen is the arena bridge: false", then `'creature'` on null at check line 39.
- **town_loop_check**: `'team'` not found on `dungeon.gd` at check line 61. The check looks out of date.
- **matchup_picker_check**: `'_team_size'` not found on `move_preview.gd` at check line 19. The check looks out of date.
- **back_idle_check**: needs a command line argument. With none it errors at line 8 and never quits. It works more like a tool than a check.
- **dungeon_boss_check, dungeon_chain_check, dungeon_evolve_check**: no errors. These are long autopilot runs that were still going at 240 seconds.

## Files in the repo that changed during the run

Git status before the run:

```
?? docs/art/reference-index-2026-10-20.md
```

Git status after the run:

```
 M docs/creatures/move-table-2026-10-09.md
?? docs/art/reference-index-2026-10-20.md
```

- `move_table_check` rewrote `docs/creatures/move-table-2026-10-09.md` at 08:25. It writes that file by design. The change adds Mirekit to the Rake and Cinder Claw rows (8 lines in, 2 out). Nothing was restored.

## All checks

Columns: exit code, seconds, FAIL lines (the pattern from the task), WRONG lines, SCRIPT ERROR lines, how many of those are save_png on null, and whether the check hit the 240 second timeout.

| Check | Class | Exit | Secs | FAIL | WRONG | SCRIPT ERROR | save_png | Timeout | Note |
|---|---|---|---|---|---|---|---|---|---|
| back_idle_check | TIMEOUT | 124 | 240.4 | 0 | 0 | 1 | 0 | yes | Needs a user argument. Index 0 out of bounds at line 8, then never quits. |
| board_scene_check | PASS | 0 | 39.2 | 0 | 0 | 0 | 0 | no |  |
| dual_essence_check | PASS | 0 | 4.5 | 0 | 0 | 0 | 0 | no | Report only. Prints numbers, asserts nothing. |
| dungeon_action_check | WINDOW-ONLY | 124 | 240.3 | 0 | 0 | 1 | 1 | yes | A save_png error at line 62 stopped the run before quit(), so it hung. |
| dungeon_aim_check | PASS | 0 | 7.4 | 0 | 0 | 0 | 0 | no |  |
| dungeon_battle_check | FAIL (real) | 0 | 39.5 | 0 | 0 | 7 | 2 | no | Exit 0 and no FAIL lines, but 5 game script errors in scripts/dungeon/dungeon.gd. |
| dungeon_boss_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Long autopilot run, no errors. Still going at 240 s. |
| dungeon_chain_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Long autopilot run, no errors. Still going at 240 s. |
| dungeon_check | WINDOW-ONLY | 0 | 27.3 | 0 | 0 | 4 | 4 | no | Only save_png errors from screenshots. Report only. |
| dungeon_evolve_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Long autopilot run, no errors. Still going at 240 s. |
| dungeon_iq_check | PASS | 0 | 9.5 | 0 | 0 | 0 | 0 | no | Report only. Prints numbers, asserts nothing. |
| dungeon_learn_check | PASS | 0 | 10.4 | 0 | 0 | 0 | 0 | no |  |
| dungeon_level_check | FAIL (real) | 0 | 8.5 | 0 | 3 | 0 | 0 | no |  |
| dungeon_pace_check | PASS | 0 | 85.7 | 0 | 0 | 0 | 0 | no | Report only. Prints numbers, asserts nothing. |
| dungeon_position_check | WINDOW-ONLY | 0 | 9.8 | 0 | 0 | 1 | 1 | no | Only save_png errors from screenshots. Report only. |
| dungeon_recruit_check | WINDOW-ONLY | 0 | 21.7 | 0 | 0 | 2 | 2 | no | Only save_png errors from screenshots. Report only. |
| dungeon_run_check | WINDOW-ONLY | 0 | 37.8 | 0 | 0 | 4 | 4 | no | Only save_png errors from screenshots. Report only. |
| dungeon_sfx_check | PASS | 0 | 17.3 | 0 | 0 | 0 | 0 | no |  |
| dungeon_tactics_check | WINDOW-ONLY | 0 | 8.4 | 0 | 0 | 1 | 1 | no | Only save_png errors from screenshots. Report only. |
| dungeon_teamsense_check | FAIL (real) | 0 | 36.5 | 0 | 2 | 0 | 0 | no |  |
| dungeon_trap_check | PASS | 0 | 202.0 | 0 | 0 | 0 | 0 | no | Report only. Prints numbers, asserts nothing. |
| dungeon_vfx_check | WINDOW-ONLY | 0 | 6.9 | 0 | 0 | 9 | 0 | no | 9 get_size on null in its _save screenshot helper (line 25). Same capture limit. |
| dungeon_warn_check | WINDOW-ONLY | 0 | 39.9 | 0 | 0 | 2 | 2 | no | Only save_png errors from screenshots. Report only. |
| dungeons_check | PASS | 0 | 46.3 | 0 | 0 | 0 | 0 | no |  |
| evolution_check | FAIL (real) | 0 | 31.1 | 0 | 1 | 0 | 0 | no |  |
| faint_check | PASS | 0 | 24.2 | 0 | 0 | 0 | 0 | no |  |
| field_menu_check | PASS | 0 | 12.3 | 0 | 0 | 0 | 0 | no |  |
| first_fight_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 1 | 0 | yes | Real error: 'creature' on null at check line 39, right after 'the battle screen is the arena bridge: false'. |
| first_morning_check | RETIRED | 2 | 0.8 | 0 | 0 | 0 | 0 | no | Exits 2 by design. Prints RETIRED, no assertions ran. |
| flood_opening_check | PASS | 0 | 17.6 | 0 | 0 | 0 | 0 | no |  |
| flood_talk_check | FAIL (real) | 1 | 2.4 | 2 | 0 | 0 | 0 | no |  |
| galeshear_wings_check | WINDOW-ONLY | 124 | 240.4 | 0 | 0 | 0 | 0 | yes | Capture check. Waits on frame_post_draw, which never fires headless. |
| guild_scene_check | PASS | 0 | 33.2 | 0 | 0 | 0 | 0 | no |  |
| hall_door_check | PASS | 0 | 0.8 | 0 | 0 | 0 | 0 | no |  |
| hall_floors_check | FAIL (real) | 1 | 10.4 | 7 | 0 | 0 | 0 | no |  |
| hollow_approach_check | PASS | 0 | 11.5 | 0 | 0 | 0 | 0 | no |  |
| hollow_check | WINDOW-ONLY | 0 | 45.9 | 0 | 0 | 3 | 3 | no | Only save_png errors from screenshots. Report only. |
| hollow_wilds_check | PASS | 0 | 46.1 | 0 | 0 | 0 | 0 | no |  |
| hub_town_check | WINDOW-ONLY | 124 | 240.3 | 0 | 0 | 1 | 1 | yes | A save_png error at line 71 stopped the run before quit(), so it hung. |
| job_board_check | PASS | 0 | 46.8 | 0 | 0 | 0 | 0 | no |  |
| listener_palette_check | WINDOW-ONLY | 124 | 240.2 | 0 | 0 | 0 | 0 | yes | Capture check. Waits on frame_post_draw, which never fires headless. |
| matchup_picker_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 3 | 2 | yes | Real error: '_team_size' not found on move_preview.gd at check line 19. Also 2 save_png errors. |
| mouth_escape_check | PASS | 0 | 9.8 | 0 | 0 | 0 | 0 | no |  |
| move_table_check | PASS | 0 | 95.5 | 0 | 0 | 0 | 0 | no | Report only. Rewrote docs/creatures/move-table-2026-10-09.md. |
| music_check | PASS | 0 | 37.6 | 0 | 0 | 0 | 0 | no | Report only. Prints numbers, asserts nothing. |
| opening_flow_check | FAIL (real) | 1 | 2.8 | 0 | 0 | 0 | 0 | no | Title never reached its main page. Could be headless timing. Confirm with a window. |
| opening_launch_check | WINDOW-ONLY | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Capture check. Waits on frame_post_draw, which never fires headless. |
| relay_yard_check | WINDOW-ONLY | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Capture check. Waits on frame_post_draw, which never fires headless. |
| riverfront_quay_check | WINDOW-ONLY | 124 | 240.1 | 0 | 0 | 0 | 0 | yes | Capture check. Waits on frame_post_draw, which never fires headless. |
| roll_call_check | PASS | 0 | 37.9 | 0 | 0 | 0 | 0 | no |  |
| roster_check | PASS | 0 | 1.5 | 0 | 0 | 0 | 0 | no |  |
| run_stop_check | PASS | 0 | 15.7 | 0 | 0 | 0 | 0 | no |  |
| save_check | PASS | 0 | 26.7 | 0 | 0 | 0 | 0 | no |  |
| soul_prologue_check | PASS | 0 | 22.6 | 0 | 0 | 0 | 0 | no |  |
| springvault_check | FAIL (real) | 0 | 24.2 | 0 | 7 | 0 | 0 | no |  |
| stone_check | FAIL (real) | 0 | 69.4 | 5 | 0 | 1 | 0 | no | Also 1 script error in scripts/dungeon/stone_scene.gd:389 ('intro' on a freed object). |
| storage_check | PASS | 0 | 11.6 | 0 | 0 | 0 | 0 | no |  |
| storm_open_check | PASS | 0 | 18.8 | 0 | 0 | 0 | 0 | no |  |
| story_gate_check | PASS | 0 | 30.7 | 0 | 0 | 0 | 0 | no |  |
| town_loop_check | TIMEOUT | 124 | 240.1 | 0 | 0 | 1 | 0 | yes | Real error: 'team' not found on dungeon.gd at check line 61. The check is out of date. |
| town_room_check | PASS | 0 | 11.5 | 0 | 0 | 0 | 0 | no |  |
| town_walk_check | FAIL (real) | 0 | 6.9 | 0 | 2 | 0 | 0 | no |  |
| ui_fit_check | PASS | 0 | 7.7 | 0 | 0 | 0 | 0 | no |  |
| warden_yield_check | PASS | 0 | 40.0 | 0 | 0 | 0 | 0 | no |  |
| water_check | PASS | 0 | 7.4 | 0 | 0 | 0 | 0 | no |  |
| way_down_check | PASS | 0 | 6.7 | 0 | 0 | 0 | 0 | no |  |
| world_navigation_check | WINDOW-ONLY | 124 | 240.2 | 0 | 0 | 0 | 0 | yes | All 18 asserts PASS, then it hung at capture() on line 39. |
