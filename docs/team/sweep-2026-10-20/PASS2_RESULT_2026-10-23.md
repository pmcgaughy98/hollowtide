# Factory pass 2 result: controller and rebinding (Claude, integrator, 2026-10-23)

Audit items: FEEL-01 (a pad can play the whole game), FEEL-02 (one confirm rule), GS-04 (rebinding), UI-05 (one face pixel size), LP-29 (furniture in front of creatures). Full check table: [after-pass2-checks.md](after-pass2-checks.md). Nothing is committed; Preston commits.

## The short version

**Checks: 70 PASS, 1 FAIL, 0 TIMEOUT** (all 110, `run_checks.py --long --arena`), against 68 PASS, 1 FAIL, 0 TIMEOUT before this pass. The two extra PASS are the new input_map and pad_play checks. The one FAIL is unchanged: ui_fit's three title-panel points (Codex's title files).

- A controller now plays the whole campaign: walk, attack, moves, bag, stairs, talk, the Job Board, storage, the shrine, the faint screen, the pause menu and the end card. The new pad_play check plays the loop on pad events alone (19 steps, all ok).
- On a keyboard every default key is the same as before. The few small differences are listed under "Keyboard differences" below.
- Every key and button can be changed: pause menu, Options, Controls.
- One "next line" rule everywhere: J, Enter, Space or E on a keyboard; A or X on a pad.
- The team row, party cards and Job Board faces now use a cut of the dialogue face at the dialogue's pixel size (UI-05). Pillars and other tall furniture now draw over a creature standing behind them (LP-29).
- `git push`: your request said "push it then go". master already matched origin/master (the factory pass commit 40ba5fcb2 was on GitHub), so there was nothing to push. This pass is not committed, so it is not pushed either.

## Pad mapping (read from the engine after the merge)

Keys are read by key position (physical), as the dungeon always did. Pad names are the Xbox layout. Every row can be changed on the rebinding page.

| Action | Keyboard | Pad |
|---|---|---|
| Walk up / down / left / right | Up or W / Down or S / Left or A / Right or D | D-pad or left stick |
| Attack | J, Space | A |
| Move 1 / 2 / 3 | 1 / 2 / 3 | hold RB + A / X / Y |
| Hold for moves | none (keyboard uses 1, 2, 3) | RB |
| Rest | Z, Period | hold RB + B |
| Bag | I | Y |
| Use / stairs | E | X |
| Team orders | T | LB |
| Messages | L | R3 (press the right stick) |
| Autopilot | Tab | Back |
| Run (held with a direction) | Ctrl | RT |
| Turn (held) | Shift | LT |
| Choose (lists) | J, Enter | A |
| Back | Esc | B |
| Yes / No | Y or Enter / N or Esc | A / B |
| Take out (storage) | R | Y |
| Scroll up / down (shrine) | Page Up / Page Down | right stick up / down |
| Pause | P | Start |
| Full screen | F11 | none |
| Menu choose / back (title, pause menu, party screen) | Enter, Space / Esc | A / B |
| Dex (debug) | F1 | none |

The chord rule: while RB is held, A, X, Y and B mean moves 1 to 3 and rest, and nothing else. That is the same idea as Explorers of Sky's L + button for moves.

## What each lane did

| Lane | Done | Skipped (why) |
|---|---|---|
| Contract (project.godot, ui_style.gd, new input_prefs.gd) | 23 new Input Map actions with the exact old keys plus pad inputs; ui_accept and ui_cancel gain pad A and B; the shared helpers (UI.tapped, held, pressed, dir8, binding_text, binding_clashes) and the clash table; InputPrefs autoload saves rebinds to the [input] section of menu_preferences.cfg with the crash-safe write; UI.portrait_3x for UI-05 | LP-29 and the screens (other lanes' files); arena and old route prototypes (outside the campaign) |
| D, the dungeon (dungeon.gd) | All 24 raw key sites now read actions, including the run stop, the press buffer (pad presses buffer too), recruit, skip-ask, teach and bag lists, and free roam; hints follow the last device; the team row uses portrait_3x | Controls page text (lane U's file); a light-up of the move chips while RB is held (new UI, left as an idea) |
| T, town and rooms (hub_town, town_room, storage_panel, hollow_approach, pilot_end, scene_kit) | Walking, use, close, lists, take out, lines and the end card read actions; every hint follows the device; Job Board faces use portrait_3x; LP-29 lifts tall furniture over creatures behind it | board_scene, guild_scene, objective, town_layout (no key reads in them) |
| U, menus (pause menu, faint, party, shrine, bag page, evolution, controls text, new rebind_page.gd) | Every screen reads actions; hints follow the device; the new rebinding page; the Controls page builds its lines live; party cards use portrait_3x | Changing a row's second key (for example attack's Space): one button per row kept the page simple; Reset restores everything |
| S, story scenes (creature_prologue, mouth_escape, riverbank_journey) | Lines, choices, the Esc title prompt and riverbank walking read actions; the riverbank hints follow the device; boss, stone and crew scenes needed nothing (their lines go through dungeon.gd) | The riverbank's H shortcut to Highbank (no action for it; a pad uses the south trail prompt) |
| C, checks (new input_map_check, pad_play_check) | input_map judges the whole map: both devices bound, the exact defaults, no clash in any context, every action a script reads exists. pad_play plays Highbank and the Warren on pad events alone | none |

Integrator: applied 4 of the 6 cross-lane requests as written (ui_fit_check now measures the pad key strips and the rebinding page; the title help's "J / click" is now "J / Space"; "Field movement uses the keyboard." is now "A controller works everywhere."). The contract's two pause-menu requests no longer matched because lane U had already made the same change its own way (pause and cancel through UI.pressed, the chord rule kept, the release wait includes Start and the rebound pause key). No lane missed a raw key read in a campaign file; the leftovers are below. The resumed integrator run (after the first one was cut off when the session ended) found no seams left to fix: every touched script parses, the grep of scripts/ found no raw key read the lanes missed in a campaign file, and input_map and pad_play pass on their own.

## The rebinding page

Pause menu, Options, Controls opens CHANGE CONTROLS: 26 actions in three groups with a Keyboard and a Controller column; choose a row and press the new key or button, and it saves at once. A key another action already uses in the same place is refused and the page names that action (it never swaps), and Reset to defaults puts everything back after a second press.

## Raw reads left, and why

- `scripts/ui/ui_style.gd` UI._down: the one place that asks the devices, for whatever the Input Map holds. It never names a key, so rebinding still works.
- `scripts/ui/rebind_page.gd`: Esc and pad B always stop listening (on purpose, so a player can back out even after rebinding Back); it reads the sticks once when listening starts so a stick already pushed is not taken as the answer; it reads the map's own key codes to pick which slot to replace.
- `scripts/riverbank_journey.gd:259` H, the Highbank shortcut on the post-Mouth riverbank. Keyboard only; the pad hint leaves it out and a pad player uses the south trail prompt.
- Engine menu actions kept on purpose: the pause menu's release wait and its open-menu Back, the party screen's choose and back, and the evolution scene's ui_accept. These are the menus context, and they now have pad A and B.
- Codex's title files (left as the task asked): `soul_prologue.gd:212-216` reads A, D, J, Space and E beside ui_left, ui_right and ui_accept. A pad works there through the D-pad and A; the left stick is ignored because the event filter on line 210 takes buttons only. `creature_opening.gd:271` is device detection. `main_menu.gd:101` adds pad A and B at run time, which project.godot now already has (harmless).
- Outside the campaign: arena_prototype.gd, first_route_prototype.gd, world_atlas.gd, world_journey.gd, relay_yard_practice.gd, move_preview.gd (Esc), debug/rd_material_review.gd, field_creature.gd and courier_partner_story.gd.

## Suite, before and after

| | Before (after-factory-checks.md) | After (after-pass2-checks.md) |
|---|---|---|
| PASS | 68 | 70 (adds input_map, pad_play) |
| FAIL | 1 (ui_fit: title Options, How to play x2) | 1 (the same three points, same numbers) |
| TIMEOUT | 0 | 0 (see below) |
| RAN (prints, judges nothing) | 32 | 32 |
| WINDOW (needs a window) | 6 | 6 |
| RETIRED / SKIPPED | 1 / 1 | 1 / 1 |

Every check keeps the class it had in the baseline; no check changed except the two new ones, and no row has a script error. The computer slept from about 13:23 to 14:45 during the run, while story_gate, timing and town_loop were running, so the runner's wall clock timed those three out (timing measured one floor at 4925 s). Rerun alone on the same tree: story_gate PASS, timing PASS (slowest floor 2.57 s), town_loop RAN with its usual log. The note at the top of after-pass2-checks.md records this. pilot_chain_check passed in 103 s.

## Keyboard differences a player could notice

All small, all from the shared contract:

- Period now also stops a run and dismisses the faint screen, because Period is part of rest (Z always did both).
- Town, shrine and Shift/Ctrl keys are read by key position like the dungeon's. No change on a US keyboard; only on layouts such as AZERTY.
- A key held down through a scene change no longer counts as a fresh press in the next scene (the dungeon still starts each floor with a clean slate).
- Hints name only the device in use. The bag now reads "Arrows  browse  Enter  use  Esc  back" on a keyboard instead of naming both.
- J now also works on the riverbank. The left stick now pages the Team screen. In town, RB + A does nothing (the chord rule).

## New player-facing lines (all proposals, yours to change)

<details><summary>The full list</summary>

- Pad key strip in a Hollow: "A attack   RB+A/X/Y moves", "Y bag   LB orders   RB+B rest", "X stairs   Back autopilot", "RT run   R3 messages", "A join   B leave".
- Hollow lists on a pad: "D-pad choose   A use   Y close", "D-pad choose   A pick   B close", "Let <move> go unlearned? A/B", "Stairs. Press X to go down.", and the B1F lesson "If it comes at us, A swings, or RB+A/X/Y for our moves."
- Town on a pad: "Stick walk   A use", "D-pad  choose     A  put one in     Y  take one out     B  close", "[A] ... [B]" at the Hollow's mouth, "A  Keep running routes" on the end card.
- Riverbank on a pad: "D-pad / Left stick  walk", "A  try the south trail", "B  return to riverbank".
- Action names: "Use / stairs", "Hold for moves", "Team orders", "Messages", "Autopilot", "Take out", "Scroll up", "Scroll down".
- Rebinding page: Options row "Controls"; heading "CHANGE CONTROLS"; groups WALKING, IN A HOLLOW, MENUS AND QUESTIONS; columns KEYBOARD and CONTROLLER; "Choose a row, then press the new key or button."; "<Action>: press the new key or button."; "<Key> is already <Action>. Choose another, or change <Action> first."; "<Action> now uses <Key>."; "Left as it was."; "Hold for moves is a controller button: press one on the controller."; "Reset to defaults? Press again"; "Every key and button goes back to the start. Press again to do it."; "Every key and button is back to the start."; hints "Enter  change     Esc  back" and "Esc / B  stop listening".
- Controls page notes: "Showing the keyboard. A controller works everywhere too. Change any key under Options, Controls." and "Showing the controller. The keyboard works everywhere too. Change any button under Options, Controls."
- Title help (Codex's file, changed by the integrator): "J / Space: attack" and "A controller works everywhere."

</details>

## Notes for Preston

1. **The faces (UI-05) need your eye.** The 16 x 16 cut you specified mostly shows one eye; Cairnshell, Crawdukes, Riftfin, Troughspine, the Warden, Vitrecrag and Rampartroot do not read as creatures at that size. A 24 x 24 cut (a 72 px box) reads as the creature for nearly all 49. It is one number (`UI.portrait_3x(form, span)`), and 16 stays until you choose. The face centres were picked by eye. Contact sheets: `C:/Users/pmcga/AppData/Local/Temp/claude/C--Users-pmcga-dev-hollowtide/a9e8a4f0-7051-47b8-8115-f9a36b2774b8/scratchpad/crops.png` (16) and `crops24.png` (24), in the same folder.
2. **Two pages share a name.** The main pause page has a read-only "Controls" page, and Options now has a "Controls" row that opens the rebinding page. If that reads as confusing, rename one.
3. **The pad layout is a proposal.** A attack and choose, B back, X stairs and use, Y bag, RB + A/X/Y moves, RB + B rest, LT turn, RT run, LB team orders, R3 messages, Back autopilot, Start pause.
4. **Nobody has looked at this in a window.** All checks ran headless. Pillars over creatures (LP-29) were measured pixel by pixel in one small window by lane T (a creature behind a Hall pillar drew over 108 of its pixels before, 0 now).
5. Riverbank walking on a pad is now 8-way at full speed, the same as Highbank. The stick used to be analog there. One line goes back if you prefer the analog feel.
6. If you ever change a default key on purpose, update the `_defaults()` table in `tools/debug/input_map_check.gd` too, or that check fails by design. Saved rebinds never affect the checks.
7. The pass was cut off once when the session ended, mid-suite; its 46 "no output" failures were killed runs, not real ones. The resumed run reran the whole suite (results above). If your computer sleeps during a suite, the checks running at that moment time out falsely; rerun those by name.

## For Codex (title files)

1. **The title's help Controls topic is still fixed text.** It now tells the truth (the integrator changed the two false lines), but it always shows keyboard keys. Build those lines from `ControlsText.groups(UI.last_device())` and `ControlsText.note(...)` so a pad player sees pad buttons and a rebind shows.
2. **soul_prologue.gd** can read `UI.pressed(event, "move_left")`, `"move_right"` and the `UI.INPUT_ADVANCE` actions instead of KEY_A, KEY_D, KEY_J, KEY_SPACE and KEY_E. That lets the left stick and rebinds work there. Keep line 210's filter, but let it pass InputEventJoypadMotion.
3. **main_menu.gd `_ensure_menu_inputs()`** is no longer needed (project.godot gives ui_accept and ui_cancel pad A and B). It does no harm, but it can go.
4. A title Options row for rebinding would need the pause menu's host methods (`rebind_page.gd` calls `menu._button`, `menu._tick` and appends to `menu.controls`). Optional.
5. The title Options and How to play panel heights (ui_fit, LP-01/LP-02) are still the last red check, unchanged by this pass.
