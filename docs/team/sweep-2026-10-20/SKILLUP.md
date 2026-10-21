# Skill-up and sweep plan (2026-10-21)

Preston asked for a complete wiring and upgrade sweep of Hollowtide, with a skill-up first. This is the skill-up report and the plan. Nothing in the game was changed to make it.

> **Correction, 2026-10-21 (Claude, after the diagnosis pass).** The baseline below ran every check without
> `--fixed-fps 30`, the flag each check's header asks for. Headless Godot then draws about 145 frames a second,
> so every frame-counted wait ended four or five times early. None of the 13 "real failures" is a bug a player
> would see. Six were this timing mistake (flood talk, opening, first fight, hall floors, town walk, stone and
> town loop). The rest were checks left behind by deliberate changes: Grok's EXP curve and Troughspine
> learnset, the guaranteed first growth once the stone is set, the picker rebuild, the switched-off real-time
> battles, and typed dialogue needing two presses per line. So plan items W1 to W4, G1 to G4 and the walk part
> of A1 are void. What replaced them: `tools/debug/run_checks.py` (always `--fixed-fps 30`, a fresh APPDATA per
> check, results read from what each check prints), eight stale checks updated, and one missing guard added in
> `stone_scene.gd`. Details per check: [diagnosis.md](diagnosis.md). New results: [after-checks.md](after-checks.md).

## 1. What the skill-up found

- **Engine skills (10 read).** Code review, testing, debugging, advanced GDScript, optimization, scene checks, verification, headless scripting, scene layout and export. export-and-ship is not installed, so export-pipeline stood in. They gave 25 checks. Top finds: 82 of 107 checks exit 0 even on a failure. run_long_checks.ps1 throws away stderr, where SCRIPT ERROR lines go. dungeon.gd has 40 awaits and 4 is_instance_valid calls. There is no export preset. The godot_ai helper autoload would ship in a build.
- **Gameplay and UI skills (13 read, none missing).** HUD, UI, screen sizes, input, save, state machines, Dialogue Manager, tweens, game feel, playtesting, audio and camera. They gave 22 checks. Top finds: the dungeon reads raw keys, so there is no gamepad. 9 awaited timers run while paused. Dungeon sounds skip the SFX bus. Saves are written in place, and other save versions are dropped. Shake uses the global RNG every frame.
- **GitHub research (Firecrawl).** Structure to study, never code: statico/godot-roguelike-example and gdquest-demos/godot-open-rpg (both MIT). For CI: gdUnit4 and chickensoft-games/setup-godot. For the mech game: ramaureirac/godot-tactical-rpg and a Blender 8-view render pattern. No Zoids-like Godot repo exists.
- **Tool probes.** Godot 4.7.2 headless works and is the main verifier. ElevenLabs and Firecrawl work. Paid art is nearly empty: Retro Diffusion $0.11, PixelLab $0 plus a 20-a-day bonus, SpriteCook 3 credits, Higgsfield 0. RD's edit tools and PixelLab's workbenches are free. Down: Blender, Claude in Chrome, gemini, godot-ai, summer-engine.
- **Check baseline.** 67 headless checks, each with an empty APPDATA, so no real save was touched.
- **Docs.** Codex's 2026-10-17 note settles the main scene: creature_opening.tscn is the campaign entry and opening_flow.tscn is legacy. Grok's 2026-10-16 note says Troughspine no longer learns Seep. The genre synthesis plan (R1 to R8) stays the design queue.

## 2. Baseline

| Result | Count |
|---|---|
| Pass | 33 |
| Window-only | 16 |
| Fail | 10 |
| Timeout | 7 |
| Retired | 1 |

- 6 of the passes only print numbers and assert nothing.
- **Fail:** flood_talk, hall_floors, stone, opening_flow, dungeon_level, dungeon_teamsense, evolution, springvault, town_walk, dungeon_battle. Seven exited 0 anyway.
- **Timeouts:** first_fight, town_loop and matchup_picker hit a real error first. back_idle needs an argument. Three long autopilot runs needed more than 240 s.
- **Window-only:** 10 die on a null screenshot, and 6 wait for a frame that never draws headless.
- Not run: pilot_chain_check and the arena checks.
- move_table_check rewrote docs/creatures/move-table-2026-10-09.md. It is uncommitted.

## 3. References

**Hollowtide:**
1. 21 of 39 data creatures have no dungeon attack, hurt or sleep frames. Starward lacks hurt and sleep.
2. 6 have no portrait and 4 have no small set (gruntle, ozbender, skimlet, valvekin miss both).
3. Proposal lines have 8 views only. They wait on Grok's numbers and Preston's approval.
4. Clutter: 27 orphan legacy files, 6 unwired effect folders, 15,539 recolor backups, and a GeminiSetup.exe in the OneDrive Opal folder for Preston to judge.

**Mech game:**
1. Only the gorilla has a game model. Five machines are .blend only, with no exchange format.
2. Every animation clip faces east only.
3. 4.5 GB of git-ignored render rounds sit on one spinning disk, including AI concepts that cannot be remade.

## 4. GitHub

**Hollowtide now.** origin is github.com/pmcgaughy98/hollowtide, master pushed at 810696e4b. This folder has no c-drive remote. History is 1.38 GiB. 46 MP4s are tracked; the largest is 62.9 MB, over GitHub's 50 MB warning. No LFS, no .github, no export_presets.cfg. docs/ has a .gdignore, so CI will not import the design PNGs.

**Mech game now.** origin is github.com/pmcgaughy98/mech-zoids, with main and cloud/model-pass-2026-10-16 pushed. The old remote stays as c-drive. History is 22 MiB. It has no .gitattributes and no .github. Its .git folder is about 1.9 GB, mostly loose leftovers. Its uncommitted state was not rechecked after the move.

**Left to do:**
- .gitignore in both: /build/, /exports/, **/*.avi, **/_work/, *.blend1, *.blend2, pycache, Thumbs.db. Keep .import files tracked.
- .gitattributes: LFS for mp4, mov, blend, psd and kra; the mech game also glb, fbx and wav. Keep PNGs out of LFS. One CI pull of 0.84 GB would use the 10 GiB free bandwidth in about 12 runs.
- Old MP4s: run `git lfs migrate info --everything --include="*.mp4"` first. Rewrite history only if they are over about a quarter of it.
- CI: item T3. Ubuntu only. 2,000 free minutes is about 130 to 400 runs a month. Run time is not measured.
- git gc in both. An off-disk copy of the mech concept folders.

**Claude can do:** the .gitignore, .gitattributes and workflow files, the LFS measure, git gc, and the check runner. All local; commits only when Preston says.

**Needs Preston:** approve each commit and push. Decide the history rewrite, which needs a force-push and fresh clones for Codex and Grok Build. Say whether Actions may spend minutes. Pick where the 4.5 GB backup lives. Install the Godot export templates.

## 5. The sweep plan

Wiring first. "Sitting" means Claude can finish it in one sitting.

| ID | Area | What is wrong (evidence) | Fix | Verify | Size | Owner | Sitting |
|---|---|---|---|---|---|---|---|
| W1 | wiring | The riverbank talk ends with an empty team (flood_talk_check). | Find where the starter drops before creature_prologue. | flood_talk_check | M | Claude finds; Codex if launch flow | Yes |
| W2 | wiring | Hall floor stairs lead nowhere, 6 fails (hall_floors_check:70). | Restore the floor links. | hall_floors_check | S | Claude | Yes |
| W3 | wiring | After the Warden: no stone, Hollow not beaten (stone_check). stone_scene.gd:389 writes to a freed dungeon after an await. | Guard each await. Find why the stone is empty. | stone_check, pilot_chain_check | M | Claude | Yes |
| W4 | wiring | 4 s after a boss clear the check still finds the dungeon (town_loop_check:61). | Find whether the return or the check broke. Add orphan counts. | town_loop_check | M | Claude | Yes |
| W5 | wiring | first_fight and opening_flow checks test the legacy opening. | Retire or repoint them. | both checks | S | Codex | No |
| G1 | gameplay | ents index errors after a removal: dungeon.gd:1580, 1336, 1346, 1483, 2232 (dungeon_battle_check). | Re-find indexes after awaits. Skip removed entities. | dungeon_battle_check, 0 SCRIPT ERROR | M | Claude | Yes |
| G2 | gameplay | A second creature is offered growth (evolution_check). | Offer only to the one that qualified. | evolution_check | S | Claude | Yes |
| G3 | gameplay | Partner AI does not close on a hurt teammate (dungeon_teamsense_check). | Fix the distance test. | dungeon_teamsense_check | S | Claude | Yes |
| G4 | gameplay | Checks disagree with newer data: dungeon_level, springvault, matchup_picker. | Grok confirms numbers; Claude updates checks. | the three checks | S | Grok, then Claude | After Grok |
| T1 | tests/CI | 82 of 107 checks exit 0 on failure. 16 die or hang on captures headless. | quit(1 if fails else 0). Skip captures headless. | a planted failure exits 1 | M | Claude | Yes |
| T2 | tests/CI | No single runner. run_long_checks.ps1:9 drops stderr. | run_all_checks.ps1 with timeouts and a pass table. | two runs match | M | Claude | Yes |
| T3 | tests/CI | No CI. | check.yml: Ubuntu, Godot 4.7.2, cached import, 2 or 3 fast checks. | a green GitHub run | M | Claude; Preston approves push | Yes |
| S1 | save | Checks can hit the real save (hub_town.gd:600 autosaves). Writes in place (team_state.gd:49). Other versions dropped (team_state.gd:125). | Back up team.save. Test save paths. Write .tmp then rename. Migrate step. | save_check with a version 0 record | M | Claude | Yes |
| F1 | feel | 9 awaited timers in dungeon.gd run during pause. | process_always false. | pause mid-turn probe | S | Claude | Yes |
| F2 | feel | Dungeon sounds ignore the SFX slider (dungeon.gd:4296). | SFX bus, cached streams. | dungeon_sfx_check | S | Claude | Yes |
| F3 | feel | Shake uses the global RNG every frame (dungeon.gd:3658). | Own RNG; rolls from floor_seed. | same seed, same end state | M | Claude | No |
| U1 | UI | Raw keys in the dungeon (dungeon.gd:3720, 3781). No gamepad. Esc has two owners. | Input Map actions, one Esc owner, key guard above the busy return. | run_stop_check | L | Claude; Codex for pause menu | No |
| U2 | UI | StyleBoxFlat in bag_page, game_pause_menu, shrine_info, creature_opening. | UI.frame or UI.panel. | ui_fit_check in a window | S | Codex | No |
| A1 | art | Kithflare and Tallowroot show 3 walk pictures (town_walk_check). 6 portraits, 4 small sets missing. | Fix frames; free tools first. | town_walk_check | M | Codex | No |
| E1 | tests/CI | No export preset, no version, MCP helper ships (project.godot:26). | Windows preset, exclude addons/godot_ai, 0.1.0-pilot. | an .exe boots to the title | M | Preston (templates), then Claude | No |

**First sitting:** T1, then W2, W3 and G1. It ends with stone, hall_floors and dungeon_battle checks clean and a pilot chain run.

## 6. What was skipped and why

- pilot_chain_check and the arena checks were not in the baseline. The pilot chain needs about 900 s.
- The 16 window-only checks were not judged. A window needs Preston's yes.
- No paid generation. Credits are near zero.
- No live editor, Blender or Gemini work. Those servers were down.
- Claude in Chrome was down, so claude.ai recents were not checked.
- Not measured: the MP4 share of history, CI run time, gdUnit4 on 4.7.2, and image quality.
- The full baseline table was not saved; the harness blocked it. Logs: C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\base_logs\
- Profiling dungeon.gd waits until something points at it.
- The memory note codex-launch-flow still names opening_flow.tscn as the main scene. It is out of date.
