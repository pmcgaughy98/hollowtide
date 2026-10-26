# Codex tasks, 2026-10-22 (from Claude's refine pass)

Found by measuring in the upgrade sweep's refine pass, each confirmed by a second agent that tried to refute it.
Full findings: [refine-2026-10-22.md](sweep-2026-10-20/refine-2026-10-22.md). Please list any "source issues for Claude" in your result, as usual.

## 1. Canvaswing's diagonal walk is mostly broken (art)
`docs/creatures/arena-starters-2026-10-07/walk/canvaswing_se_sheet.png` has only three real frames (f0 to f2). The rest:
- f3: a flat pale slab (525 px of one colour, 233,207,179) cut by the cell edge, the "pale block in a take" debris pattern.
- f4 and f6: outline-only ghosts (121 and 87 px, 6 colours, against about 265 px and 20 colours for real frames).
- f5: a solid tan square filling the whole frame (all four edges touched) in the dungeon, small and town sets.
- f7: a ghost plus a 423 px single-colour block (110,73,50) at the right edge.
SW is a mirror of SE, so both diagonals are affected. The dungeon picks `int(progress*4 + turn*4) % 8`, so every odd diagonal step plays only broken frames.
A wild Canvaswing walks the Rootbank Warren (floors 1 and 2), and a recruited one walks the town.
**Task:** redo frames f3 to f7 of the SE sheet as real walk poses (a re-take or a repaint matching f0 to f2), then rebuild
canvaswing's dungeon, town and small sets with the same builders and arguments as the current sets. Copying f1 over f5
alone would fix one of five bad frames, so it is not a stand-in. Check: no frame touches its edges, colour counts near 20.

## 2. Portraits for Skimlet, Ozbender and Valvekin (art, Preston looks at the crops)
They can be recruited (stage 1 wilds) but have no `portrait.png`. Until now the team panel showed an empty box. Claude
added a stand-in on 2026-10-22: the panel shows the creature's dungeon still instead. Real portraits: run
`tools/arena/build_portraits.py` for the three forms, check the 48 px crop shows the face, install
`assets/sprites/arena/<form>/portrait.png`. Gruntle, Mirekit and Whinet also lack one, but they never join (Preston, 2026-10-21).

## 3. Title Options box runs 11 px past the bottom of a 16:9 screen (your menu)
The panel ends at y 659 on a 648 px screen, cutting its bottom frame edge. All content stays visible. Measured fix,
checked by a second agent: tighter row separation in `scripts/creature_opening.gd`.

`scripts/creature_opening.gd`: Seven gaps x 2 px brings the bottom to 645 without moving the box toward the wordmark (LF file)

```
	_options_panel.get_node("Choices").add_theme_constant_override("separation",12)
```
becomes
```
	_options_panel.get_node("Choices").add_theme_constant_override("separation",10)
```

## 4. `menu_preferences.cfg` is written in place (your menu)
ConfigFile.save truncates the file when it opens it. A crash mid-write keeps only the keys before the cut. For example,
a player who picked the female courier gets the male one back, and the pause menu's `_save()` then writes the partial
file back for good. Claude made the team save crash-safe on 2026-10-22 (write to `.tmp`, keep a `.bak`, then rename).
The same change for the settings file, checked by a second agent:

`scripts/main_menu.gd`: The title's settings save writes the whole file to a .tmp first, then renames it over the old one. The existing error branch still reports a failure.

```
	var error := config.save(PREFERENCES)
	if error == OK:

```
becomes
```
	var error := config.save(PREFERENCES + ".tmp")   # whole file first, then renamed over the old one (2026-10-22)
	if error == OK:
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(PREFERENCES + ".tmp"), ProjectSettings.globalize_path(PREFERENCES))
	if error == OK:

```

`scripts/ui/game_pause_menu.gd`: The same change for the field menu's settings save. The status line still says 'could not be saved' on failure.

```
    var err = c.save(PREFS)

```
becomes
```
    var err = c.save(PREFS + ".tmp")   # whole file first, then renamed over the old one (2026-10-22)
    if err == OK: err = DirAccess.rename_absolute(ProjectSettings.globalize_path(PREFS + ".tmp"), ProjectSettings.globalize_path(PREFS))

```


## Codex result, October22: task1

Task1 COMPLETE/INSTALLED: Canvaswing SE source frames f3-f7 replaced with five complete poses matching the intact f0-f2; SW rebuilt as exact mirrors. Original source f0-f2 RGBA and every unselected runtime sprite remain exact. Rebuilt dungeon/town/small with the current named builders (town --set=town --scale=1.5; small scale0.95), retaining installed palette colours on the30 changed frames. All repaired runtime frames have clear edges, opaque body mass comparable to the intact frames and18-23 colours. Native64/64 candidate plus64/64 installed live:48 diagonal textures and16 actual Rootbank animation selections across even/odd steps. Originals, one built-in imagegen raw/prompt, source/PNG hashes, builders, native logs/captures and slowed before/after GIF: docs/art/canvaswing-diagonal-walk-2026-10-22/README.md. 2152 other protected files exact; 11 concurrent script edits preserved and archived, including title/settings edits made by another session. No game code, rules, save, paid external call or commit by this pass. Task2, Skimlet/Ozbender/Valvekin portraits, is next; tasks3/4 have concurrent source edits and are not claimed checked or completed here.

Source issues for Claude: rebuilding current recoloured sheets/stills does not reproduce the installed palette pixel choices (216 set PNGs differ), and rebuilding from the preserved pre-recolour inputs plus the old colour transform still differs. This pass keeps all unselected installed bytes and locks only the30 changed rebuild outputs to installed f0-f2 palette colours. Please document/unify the complete finishing order before a bulk rebuild; do not replace the approved sets with a bare builder run. Generated walk jobs also need per-frame body/edge/colour checks before being accepted: the original job was nominally eight frames but five were damaged. The headless editor import also reports Dialogue Manager theme_values.gd:51 Nil-to-int errors and an unresolved default-audio-bus UID (uid://blm6ps3r8bf7l); process exit0 and reimport completes, but that import log is not clean. Final native live resources match all48 candidate PNGs pixel-for-pixel and the runtime64/64 log is clean. No game-source fix was made for these editor-only diagnostics.

## 5. The factory queue (plan section 4, 2026-10-22)

Appended by the docs lane of the factory pass (`sweep-2026-10-20/FACTORY_PLAN_2026-10-22.md`, section 4). The rows marked
"now" are art and asset files no lane touches, so they can start while the lanes run. The rows marked "after" wait for the
integrator's merge: they call helpers the UI lane lands and the ui_fit points lane 8 adds. Sections 1 to 4 above stand;
tasks 3 and 4 appear again below under "after" as the plan lists them.

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
| after | Tasks 3 and 4 | Already queued above: Options separation 10, settings file .tmp then rename |
| after | LP-01, LP-02 | Title Options at y 120 (or heading at 30) and How to play at y 120 so both bottoms end above 636; ui_fit's new point passes |
| after | UI-01 | Title buttons through UI.style_button and UI.frame('panel_focus'); delete MENU_FACE and COPY_FACE |
| after | LP-03 | Title Controls tab draws ControlsText |
| after | GS-01, GS-03 | Title Options rows for screen mode (UI.apply_screen_mode) and text speed, same prefs keys; ~~apply both at launch~~ |
| after | GS-17 | Credits row and one-page panel: Preston McGaughy Jr, design and direction; collaborators as he lists them; Silkscreen, Pixelify Sans, Jersey, Dialogue Manager, ElevenLabs, Godot |
| after | FLOW-10 | New Game confirm when a save exists |
| after | CR-06 | 'Enter  skip' label-role hint on the storm from 2 s and on the soul prologue |
| after | LP-04, LP-06, LP-07, LP-08 | Soul prologue: lines through UI.dialogue; the soul stays over the chosen card in 'after'; the top strip becomes a gradient; cards sized to the sprite plus 24 px |
| after | W14, W19, W20 | '1-3: moves'; title copy in the house voice (Preston's words; default leave); step 02 matches the real order |
| done | FEEL-08 | storm_open 224, soul_prologue 93, main_menu 643 on their buses (the integrator applied lane 9's three one-line bus fixes on 2026-10-22: main_menu clicks on UI, the soul prologue blip on UI, storm_open sounds on SFX; nothing left here) |
| after | CR-04 | Hollowtide icon.png and boot_splash bg_color #161f1b, show_image false |
| after | FLOW-13, FLOW-12 | export_presets.cfg Windows Desktop, excludes tools/*, docs/*, addons/godot_ai/*, scenes/_lab/*; the autoload line out of the release branch |
| after | FLOW-14 | git mv the 17 zero-reference and 9 retired-route scenes to scenes/_lab/; default checks pass |

### The contract, as landed in `scripts/ui/ui_style.gd` (all static; `const UI := preload("res://scripts/ui/ui_style.gd")`)
- `UI.tick(kind: String) -> void`: kinds "cursor", "confirm", "cancel", "open", "close"; unknown kinds do nothing; bus "UI" at -8 dB.
- `UI.toast(tree: SceneTree, text: String, secs := 1.5) -> void`: pass `get_tree()`.
- `UI.fade_out(tree: SceneTree, secs := 0.2) -> Signal` then change the scene; `UI.fade_in(tree: SceneTree, secs := 0.2) -> Signal` clears the layer (with no layer up it starts black).
- `UI.reduce_motion() -> bool` (menu/reduce_motion); `UI.text_speed() -> int` (menu/text_speed: 1 normal, 2 fast, 0 instant); `UI.screen_full() -> bool` (display/fullscreen) for whoever applies it at launch; `UI.apply_screen_mode(full: bool) -> void` sets the window mode and saves display/fullscreen, keeping the other keys.
- `UI.reload_prefs() -> void`: call after any menu saves a pref, or the cached read stays stale this session. `UI.motion_secs(secs: float) -> float`: half under reduce motion.
- `const ControlsText := preload("res://scripts/ui/controls_text.gd")`: `ControlsText.TOWN`, `.HOLLOW`, `.MENUS` are each `{"head": String, "lines": Array of String}`; `ControlsText.GROUPS = [TOWN, HOLLOW, MENUS]`. No class_name on purpose (the checks run headless without the class cache).
- Buses: "UI" is bus 3 in `default_bus_layout.tres` (send Master, 0 dB); SFX stays 1 and Music 2, so the SFX slider's index is unchanged. Every AudioStreamPlayer sets one: "SFX" for world and scene sounds, "UI" for clicks and blips, "Music".

## 6. Pass 3 lines (plan, 2026-10-23)

From `sweep-2026-10-20/PASS3_PLAN_2026-10-23.md`, section "Codex". GS-01/GS-03's "apply both at launch" is struck above:
pass 3's U2 has `InputPrefs._ready` restore full screen at launch, so the title only writes the keys. (Claude, 2026-10-23)

1. LO-01: `config.load(PREFERENCES)` right after `ConfigFile.new()` in main_menu.gd _save_preferences, then task 4's temp-then-rename write.
2. LO-17: title Options and both How to play panels start at y 120 and end above 636.
3. L10, LO-18 (UI-01): title on UI.TYPE roles and UI.frame buttons; delete MENU_FACE and COPY_FACE; fix "NewGame".
4. L12, LO-22 (LP-03): Controls topic from ControlsText for the current device.
5. L13: hide and zero captions[] and LaunchPrelude on menu open; skip the prelude on return.
6. L11, LO-25: title Options match the game's, filled sliders, credits, New Game confirm, skip hint.
7. LO-23 (LP-04): soul prologue on UI.pressed, stick and UI.dialogue; UI.HEAD replaced; delete _ensure_menu_inputs.
8. L15: starter cards with the showcase idle at 3x.
9. L16: shafts fade by vertex alpha; dithered top glow.
10. LO-19 (CR-04): icon and boot splash colour, after pass 3 merges.
11. LO-20: Windows export preset with excludes; one test export.
12. LO-21: drop the unused world_journey.tscn boot load; retired scenes to scenes/_lab.
13. LO-24: "now" art rows FX-01, ART-08, ART-03, ART-10.
14. L24: painted signboards as PNGs; Claude wires them next pass.
15. L22: dual-grid transition tiles for grass, dirt, cobble and flagstone in the Highbank palette, only if Preston picks it in P8.

Added by the pass 3 integrator (Claude, 2026-10-23), from the lanes' notes:

16. C10 can go now: pass 3 set `rendering/environment/defaults/default_clear_color` to pure black, `Color(0, 0, 0, 1)` (not near black), the same black as the UI fade.
17. Art, when there is room: Punchybun and Sparkjab have no 40 x 40 dialogue face yet, so every 24 x 24 portrait of them falls back to `portrait.png`; a face each, then Claude adds their FACE_AT rows.
18. Art, when there is room: the waking riverbank picture has the rain painted into it. The dawn walk (`mouth_escape.gd`) removes the streaks while the game runs and leaves the PNG alone; a real dawn painting of that bank would replace the runtime fix.

## 7. Pass 4 lines (plan, 2026-10-24)

From `sweep-2026-10-20/PASS4_PLAN_2026-10-24.md`, section "Codex", in the plan's order. Result: `sweep-2026-10-20/PASS4_RESULT_2026-10-24.md`.
Words in C6, C19 and C20 are proposals: build the layout and hold the words until Preston answers. (Claude, integrator, 2026-10-24)

1. C2 (live LV-01, leftovers LV-10): creature_opening.gd:232-236 and main_menu.gd: start Options and both How to play panels at y 120 (or size them to content) so they end above 636; pull the Quit panel inside 1152 with a 16 px margin so its right frame, corners and 'Leave Hollowtide?' are on screen. ui_fit's 3 title points go green. They are the only ui_fit failures left.
2. C3 (live LV-03, leftovers LV-11): title menu, title panels and soul prologue text on UI.TYPE roles, buttons through UI.style_button and UI.frame; delete MENU_FACE and COPY_FACE (creature_opening.gd:10-11), fix the 'NewGame' comment at :179; the carved wordmark stays.
3. C4 (live LV-05, LV-09; leftovers LV-12): title Options gets the pause menu's rows and prefs keys (Master, Music, Sound effects, Screen, Text speed, Reduce Motion, Rebind keys page) with framed, filled sliders matching Claude's M1; How to play > Controls built from ControlsText.groups(UI.last_device()).
4. C6 (live LV-06, leftovers LV-12): when TeamState.has_save(), New Game asks before the storm (proposed: 'Start over? Your saved journey will be replaced when you reach Highbank.' / Keep my save / Start over); one line under Continue (place, leader level); credits; skip hint. Build the prompt, hold the wording for Preston.
5. C5 (leftovers LV-13): opening_flow.gd and main_menu.gd: hide captions[] and LaunchPrelude and zero their alpha when the menu opens; skip the prelude on a return visit.
6. C7 (leftovers LV-14): soul_prologue.gd reads UI.pressed for move_left/move_right and UI.INPUT_ADVANCE, lets joypad motion through, draws lines through UI.dialogue; delete _ensure_menu_inputs (main_menu.gd:98-110). Tell Claude, who then deletes UI.HEAD.
7. C8 (live LV-08, leftovers LV-15): starter cards show the showcase front idle at 3x scaled to a shared bounding height on an essence-tinted backdrop, name in the title role; the controls hint (soul_prologue.gd:309) at full label contrast via UI.binding_text.
8. C9 (live LV-02, leftovers LV-16): soul_prologue.gd:257-264: remove the full-width 9 px top strip (rows 0-8 at 54,52,55) or make it a pulse on the light; draw the shafts with draw_polygon and per-vertex alpha fading to 0 so there is no edge at y=450.
9. C19 (live LV-07): the title quit confirm's cancel button stops reading 'Back to title' (proposal 'Stay'; Preston picks the word).
10. C20 (live LV-35): storm_open.gd: after about 4 s add one beat (a faint advance prompt via UI.binding_text, or narration once Preston approves words); draw the soul light as a pixel cluster like the soul prologue's.
11. C10 (leftovers LV-17): Hollowtide icon.png as config/icon; application/boot_splash bg_color to the clear colour, show_image false.
12. C11 (leftovers LV-18): export_presets.cfg Windows Desktop preset excluding tools/*, addons/godot_ai/*, scenes/_lab/*, with the godot_ai autoload out of the release; keep docs/ until C22; one test export, and confirm Highbank and one room show painted art (proves Claude's A4 and T11).
13. C22 (leftovers LV-19): move the arena front art that board_scene.gd:96 reads from res://docs/creatures/arena-starters-2026-10-07/forms/ into assets/ and give Claude the new path.
14. C21 (live LV-31): a Team page backdrop drawn at the sprite's pixel scale and palette (or a simple essence frame) to replace the painterly canyon; Claude wires it into creature_detail_canvas.gd.
15. C12 (leftovers LV-22): confirm opening_flow never instantiates _route_scene, drop the world_journey.tscn preload at main_menu.gd:36, move retired scenes to scenes/_lab (Preston commits); Route 1 files stay untouched.
16. C1 (leftovers LV-23): main_menu.gd:808-822: config.load(PREFERENCES) after ConfigFile.new(), then save through a temp file renamed over the original (ui_style.gd:699-702 pattern).
17. C13 (leftovers LV-20): FX-01, ART-08, ART-03, ART-10 in queue order; tell Claude after FX-01 (rerun dungeon_vfx) and ART-08 (rebuild both sets with build_dungeon_set.py); Preston looks at the ART-10 crops.
18. C14, C17, C18 (leftovers LV-21, LV-24): painted signboard PNGs per service for Claude to wire into building_exteriors.gd; 40 x 40 faces for Punchybun and Sparkjab; a dawn painting of the waking bank without rain.

Added by the pass 4 integrator (Claude, 2026-10-24), from the lanes' notes:

19. For C4, the pause menu's slider look is one static call: `_slider_look(slider: HSlider)` in scripts/ui/game_pause_menu.gd (about line 267). It gives the framed track, the gold fill and the brass knob, drawn in code from UI colours at 3x, the same for every state. Calling it on the title's sliders makes the two Options screens match; the title today still uses panel_dim and panel_focus.
20. For C11, what to look at in the test export: Highbank's painted street, the Home desk (town_room.gd), the Job Board stand and a Hollow floor. Pass 4 moved every res:// picture read to the imported texture first (`UI.res_image`, ui_style.gd about line 639; town_room.gd and board_scene.gd use their own `_art_image`), so none of them should fall back to stand-in art. If one does, name the file.
21. For C22, board_scene.gd's stand-in reads that docs/ folder through `_art_image`, which already copes with a missing file (it draws an empty 66 x 66 stand-in instead of crashing). Send the new path and Claude points it there.

## 8. Pass 5 lines (plan, 2026-10-24)

From `sweep-2026-10-20/PASS5_PLAN_2026-10-24.md`, section "Codex", in the plan's order. Result: `sweep-2026-10-20/PASS5_RESULT_2026-10-24.md`. Many repeat pass 4's lines with the pass 5 live audit's evidence added; the title files are yours, and Route 1 stays untouched. Words in C6 are proposals: build the prompt and keep it off until Preston picks them. (Claude, integrator, 2026-10-24)

1. C11 (LO5-01): add export_presets.cfg with a Windows Desktop preset that leaves out tools/*, addons/godot_ai/* and scenes/_lab/*, keeps the godot_ai autoload out of the release, and keeps docs/ until C22; make one test export and check that Highbank's street, the Home desk, the Job Board stand and one Hollow floor show painted art, not stand-ins.
2. C2 (LO5-02, live LV-21, LV-22): in creature_opening.gd and main_menu.gd start the title Options and both How to play panels so they end by y 636 (start at 120 or size to content); pull the Quit panel inside 1152 with a 16 px margin. ui_fit's three title points should then go green.
3. C3 (LO5-03, LV-23): move the title menu, its panels and the soul prologue text onto UI.TYPE roles with UI.style_button and UI.frame; delete MENU_FACE and COPY_FACE (creature_opening.gd:10-11) and fix the 'NewGame' comment at :179. The carved wordmark stays.
4. C4 (LO5-04, LV-21): title Options gets the pause menu's rows and prefs keys (Sound effects, Screen, Text speed, Rebind keys) and calls game_pause_menu.gd `_slider_look` on its sliders; How to play > Controls is built from `ControlsText.groups(UI.last_device())`.
5. C6 (LO5-05): when `TeamState.has_save()` is true, New Game asks before the storm. Build the prompt but keep it off until Preston picks the words; one line under Continue with the place and the leader's level.
6. C5 (LO5-06): when the menu opens, hide captions[] and LaunchPrelude (alpha 0); skip the prelude on a return visit.
7. C7 (LO5-07): soul_prologue.gd reads UI.pressed for move_left and move_right and UI.INPUT_ADVANCE, lets joypad motion through, and draws lines through UI.dialogue; delete main_menu.gd `_ensure_menu_inputs`. Then tell Claude, so UI.HEAD can be deleted.
8. C8 (LO5-08, LV-26): starter cards show the showcase front idle at 3x on an essence-tinted backdrop with the name in the title role; moving between cards plays the UI cursor tick and picking plays confirm (not text.wav); the hint at full label contrast through UI.binding_text.
9. C9 (LO5-09, LV-25): remove the 3 px full-width strip at soul_prologue.gd:264 (or make it a pulse on the light); draw each shaft with per-vertex alpha fading to 0 so no edge shows at y 450; size the backdrop to the expanded viewport.
10. C10 (LO5-10): set the Hollowtide icon.png as config/icon; boot_splash bg_color to the clear colour and show_image false.
11. C12 (LO5-11): confirm opening_flow never instantiates _route_scene, drop the world_journey preload at main_menu.gd:36, and move retired scenes to scenes/_lab (Preston commits). Route 1 files stay untouched.
12. C1 (LO5-12): main_menu.gd:811-817 loads PREFERENCES before saving and writes through a temp file and rename (the ui_style.gd:699-702 pattern).
13. C20 (LO5-13): storm_open.gd shows a faint advance prompt through UI.binding_text after about 4 s; draw the soul light as a pixel cluster, not four draw_circle calls.
14. LV-24: the splash either waits for the key it names or drops 'ENTER TO CONTINUE'; fade the splash wordmark fully out before the title wordmark appears; no dim 55-frame hold on the return to title; silence the focus-grab cursor tick at title load and the doubled confirm and cursor when Options opens.
15. LV-27: creature_prologue.gd and opening_dialogue.gd use one dialogue face (the Pixelify prose role) and draw response choices at the dialogue's pixel scale.
16. LV-13: redraw the Scroll Keeper exterior (scroll_keeper_painter.gd, landmark_exteriors.gd) at the Item Shop's scale and outline weight, or as an object set built from existing pieces.
17. C13 (LO5-14): FX-01, ART-08, ART-03, ART-10 in queue order. After FX-01 Claude reruns dungeon_vfx; after ART-08 Claude rebuilds both sets with build_dungeon_set.py; Preston looks at the ART-10 crops.
18. C14, C17, C18 (LO5-15, LV-14): paint a hanging wooden signboard PNG per service in the building palette, 40 x 40 faces for Punchybun and Sparkjab, and a dawn waking-bank painting without rain; send Claude the paths for wiring.
19. C21 (LO5-16): a Team page backdrop at the sprite's pixel scale and palette (or a simple essence frame); send Claude the path for party_screen.gd:43.
20. C22 (LO5-17): move the arena-starters front images read at board_scene.gd:97 from docs/ into assets/ and send Claude the path (board_scene now reads them through `UI.res_image`, which copes with a missing file).
21. PERF-08: build_dungeon_set.py writes each frame's foot row into a small data file beside the sets, so `_read_art` can skip its GPU readbacks (138 to 169 ms on a session's first floor); Claude then switches `_read_art` to read it.

Added by the pass 5 integrator (Claude, 2026-10-24), from the lanes' notes:

22. From the town lane (T2): the growth scene draws both stages from one art family. Rimefin to Riftfin falls back to the small arena stills, because Riftfin's stills are long and low (75 to 78 px). A taller Riftfin front idle, like the other lines' showcase idles, would let that pair use the big 2x family.
23. For C11, one more thing to look at in the test export: Highbank's painted street is now saved once to user://street/highbank_<key>.png and read back in later sessions (hub_town.gd STREET_VERSION and STREET_SOURCES). In the export, a second launch should reach Highbank in about 1 s with the same picture.


## 9. Pass 6 lines (plan, 2026-10-24)

From `sweep-2026-10-20/PASS6_PLAN_2026-10-24.md`, section "Codex", in the plan's order. Result: `sweep-2026-10-20/PASS6_RESULT_2026-10-24.md`. The pass 6 live audit (findings L6-01 to L6-33) adds evidence to many pass 5 lines. The title files are yours, and Route 1 stays untouched. Words in C6 and W14 are proposals: build the prompt and keep it off until Preston picks the words. (Claude, integrator, 2026-10-24)

1. C2 (L6-05, LO6-08): in creature_opening.gd and main_menu.gd, start the title Options and both How to play panels at y 120, or size them to content, so they end by 636 with their own framed bottom edge. Pull the Quit panel 16 px inside 1152. Verify: ui_fit's 3 title points go green.
2. C3 (L6-04, LO6-09): set the title menu, its panels and the soul prologue text in UI.TYPE roles (Silkscreen buttons, Pixelify prose, Jersey headings) at whole-pixel sizes with UI.style_button and UI.frame. Delete MENU_FACE and COPY_FACE (creature_opening.gd:10-11) and fix the :179 comment. Keep the carved wordmark.
3. C4 (L6-03, L6-06, LO6-10, W14 key lines): the title Options opens the pause menu's options and rebind pages, or copies their rows, prefs keys and game_pause_menu.gd `_slider_look` sliders (Sound effects, Screen, Text speed, Rebind keys). Build How to play > Controls from `ControlsText.groups(UI.last_device())` and `note()`, so rebinds, Ctrl run and L messages show. Mark the open tab with panel_focus.
4. C6 (L6-08, LO6-11): when `TeamState.has_save()` is true, New Game and How to play's Start New Game ask a framed Yes/No before the storm, behind a flag that stays off until Preston picks the words (proposal: 'Start a new journey? Your current save is replaced when the new team reaches Highbank.'). Add one line under Continue with the place and the leader's level.
5. Storm (L6-07, C20/LO6-27) in storm_open.gd: accept UI.INPUT_ADVANCE (E, J, Enter, A). Skipping is a 1 s hold with a small fill ring, or a second press after a prompt. After about 4 s, show a faint advance prompt through UI.binding_text. Draw the soul light (:194-197) as a pixel cluster like the soul prologue's.
6. White-outs (L6-09) in storm_open.gd and soul_prologue.gd: hold the white 2-3 frames, then fade into the next scene over 8-12 frames (UI.fade_in), with no single black frame. Verify with a frame luminance log (live_opening.log frames 874-877 and 1719-1742 were the faults).
7. C9 (L6-10, LO6-12): remove the soul_prologue.gd:264 top bar (Rect2(0,0,LOW.x,3)) and move the speaking cue into the text box (pulse the arrow or the name tab). Draw each shaft with per-vertex alpha fading to 0, so no hard edge shows at y 450. Size the backdrop to the expanded viewport.
8. C8 (L6-11, LO6-13): starter cards show the showcase front idle at 3x on an essence-tinted backdrop with the name in the title role. Card moves play UI.tick('cursor'), and the pick plays UI.tick('confirm') plus presence_swell.wav. The hint is drawn at full label contrast through UI.binding_text.
9. C7 (LO6-14): soul_prologue.gd reads UI.pressed on move_left/move_right and UI.INPUT_ADVANCE with joypad motion, and draws lines through UI.dialogue. Delete main_menu.gd `_ensure_menu_inputs`. Tell Claude when done, so Claude can delete ui_style.gd HEAD and the party_screen.gd:429 comment.
10. L6-16: on Continue, start the fade and the confirm sound first, then load Highbank with ResourceLoader.load_threaded_request under the black (live_town.log frame 106 froze for 857 ms before the fade).
11. LV-24 (LO6-16): the splash either waits for the key it names or drops the prompt. Fade the splash wordmark fully out before the title wordmark appears. Skip the dim hold on return to title. Silence the focus-grab tick at title load and the doubled confirm and cursor when Options opens. C5 (LO6-17): hide captions[] and LaunchPrelude at alpha 0 when the menu opens, and skip the prelude on a return visit.
12. C1 (LO6-26): main_menu.gd `_save_preferences` loads menu_preferences.cfg first, then saves to a temp file and renames it over, the ui_style.gd save_pref pattern.
13. C10 (LO6-18): project.godot config/icon uses the Hollowtide icon.png. boot_splash bg_color is the clear colour, with show_image false.
14. C11 (LO6-07): add a Windows Desktop export preset that leaves out tools/*, addons/godot_ai/* and scenes/_lab/*, with the godot_ai autoload out of the release. Keep docs/ until C22 lands. Make one test export, and check Highbank's street, the Home desk, the Job Board stand and one Hollow floor for painted art, and a cached street on a second launch (first arrival under 1 s).
15. C12 (LO6-25): confirm opening_flow never instantiates _route_scene, then drop the world_journey.tscn threaded load in main_menu.gd:36/:833/:857. Route 1 files stay untouched.
16. L6-12: hand-pixel 'THE HOLLOW' on the entrance lintel (assets/sprites/world/waking_bank_2026_10_10/entrance_native.png) as clean 1-px glyphs in the stone's two tones, or paint the lettering out.
17. LV-13 (LO6-19): redraw the Scroll Keeper exterior (scroll_keeper_painter.gd, landmark_exteriors.gd) at the Item Shop's scale and outline weight, or build it from existing object pieces.
18. C13 (LO6-20): FX-01 (empty frames in sail_slash and mark_glyph), ART-08 (Muskin back view), ART-03 (Skimlet, Ozbender and Valvekin portraits) and ART-10 (title village at a whole-number scale), in queue order. Tell Claude after FX-01 (dungeon_vfx rerun) and ART-08 (build_dungeon_set.py rebuild).
19. C14, C17 and C18 (LO6-21): hanging wooden signboard PNGs per service, 40x40 faces for Punchybun and Sparkjab, and a dawn waking-bank painting without rain. Send the paths. Claude wires building_exteriors.gd, FACE_AT and waking_bank.gd:7.
20. C21 (LO6-22): a Team page backdrop at the sprite's pixel scale and palette, replacing assets/backgrounds/signature_stages. Send the path for party_screen.gd:43.
21. LO6-23: a taller Riftfin front idle (at least Rimefin's opaque height), so evolution_scene.gd `_pick` chooses the idles. Claude reruns evolution.
22. C22 (LO6-24): move the arena front images board_scene.gd:99 reads from docs/ into assets/, and send the path.
23. PERF-08 (LO6-28): build_dungeon_set.py writes each frame's foot row to a small data file beside the sets. Claude then fills `_foot_rows` from it.
24. W14 words in creature_opening.gd and opening_flow.gd: replace 'dungeon' with 'a Hollow', 'village' and 'hometown' with 'Highbank', 'party' with 'team', and the page head 'The journey' (proposal 'How it goes'). Error line proposal: 'Highbank didn't load. Your team is still here.'. The 'BEGIN YOUR JOURNEY' caption waits for Preston.
25. LV-27 (flood talk response choices in creature_prologue.gd and ui/opening_dialogue.gd) was taken by Claude's story lane (S4) this pass. Skip it.

Added by the pass 6 integrator (Claude, 2026-10-24), from the lanes' notes:

26. Your native tile check `docs/design/dungeon-tiles-2026-10-10/tile_checks.gd` now expects the fog's unseen colour to be `Color.BLACK`, not `#080b0e`. The paint lane changed the fog canvas (dungeon_visibility_canvas.gd FOG) so it matches the painters' black and the project's clear colour, and the integrator applied the one-line change to your check. The check's intent (exact opaque dark over world effects) still holds.
27. For C3 and LV-27: the dialogue's real face is the `story` role in ui_style.gd TYPE, which is Jersey 10 today. Pixelify is on disk but no role uses it. Name roles (`UI.say(..., "story")`), not font files, so the title and the flood talk stay in one face whatever the role points at.
28. `scripts/ui/opening_dialogue.gd` has no live caller: only archived copies under docs/ preload it, and it reads `source.phase` and `source.prose`, which creature_prologue no longer has. The story lane left it untouched. Retire it with the other leftovers if you agree.
29. For L6-09 (white-outs): the flood talk now leaves through `UI.fade_out` and the riverbank lifts the black itself two frames after its build (`riverbank_journey.gd _lift_black`). The soul prologue's hand-over to the flood talk is yours; ending it on UI's shared black would let the same fade carry through.

## Codex result, October 26: task 2 and current queue reconciliation

Task 2 COMPLETE/INSTALLED as fallback art: Skimlet, Ozbender and Valvekin each have a 48px arena portrait, cropped from current southwest stills through build_portraits.py, with three reproducible HEAD entries. The default crop missed Ozbender's face and Valvekin's mantle; corrected crops inspected by Codex, Preston approval pending. Native 32/32, clean runtime: imported RGBA exact, existing dialogue-first Team/dungeon headshots preserved, and new portraits selected exactly when the dialogue face is unavailable in a private-process fixture. Existing face_crop_check 5/5 across 49 faces. All 48 other builder outputs exact; 3483 protected files exact before documentation, only the builder changed among existing production files. Claude's dirty source work preserved. No new generation, paid call, real save, game-rule change or commit. Evidence: [portrait review and checks](../ui/recruit-portraits-2026-10-26/README.md). [Handoff](CODEX_HANDOFF_2026-10-26_recruit_portraits.md).

Source issues for Claude: task 2's empty-box diagnosis predates the current dialogue-first UI; these files are fallbacks, with the existing dialogue portraits retained. Section 9 item 18 swaps ART-03/ART-10 descriptions relative to section 5. Headless import still reports the previously recorded Dialogue Manager theme_values.gd:51 Nil-to-int editor errors; import exits 0 and final native pixels/runtime checks pass independently. The first fixture failed 10/19 because it expected obsolete portrait priority; archived, corrected final fixture 32/32, no game-source workaround.

New work confirmed in sections 5-9 through October 24; their repeated rows refine earlier items. Next slice: original task 3 / latest pass 6 C2, title Options/How to play/Quit bounds and ui_fit's three title failures. Settings task 4/C1 still needs current inspection and checking. Canvaswing task 1 remains complete. LV-27 flood dialogue choices were taken by Claude; skip them. Other factory/pass tasks remain pending, and proposed wording retains its specified flags.

## Codex result, October 26: task 3 / pass 6 C2 title bounds

COMPLETE/INSTALLED: Options y120-599, both How to play topics y120-621 (all above y636), Quit x635-1136 with 16px right margin based on its actual 501px minimum width. Shared base Options y120 also fixes the legacy opening (bottom558). Only four panel placements in scripts/creature_opening.gd and scripts/main_menu.gd changed; text/fonts/spacing/settings/art untouched. Native campaign 12/12 and full native ui_fit 48/48, clean runtime logs; all four campaign captures inspected. Official unmodified run_checks.py ui_fit: PASS, exit0, including the three formerly failing title points. Legacy geometry/focus/cancel 6/6 with separately recorded ObjectDB exit warnings. No claim that the whole suite was rerun. Fresh protected-file receipt: 1369/1373 existing files exact after source/docs publication, only the two owned source files and two handoff documents changed; Claude's modified ui_fit and other source work preserved. Private profiles/saves only, no generation/asset/rule change or commit. [Evidence and before/after](../ui/title-panel-bounds-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_bounds.md).

Source issues for Claude: the first combined fixture freed the legacy title while its unused world_journey background load was running; waiting removed the cascading shutdown errors. Legacy-only exits still show 100-101 ObjectDB instances across baseline/installed fixtures; unused route load removal remains C12. The official unmodified ui_fit leaves 7 instances/3 resources, accepted by the current runner's noise list; the private native copy's music teardown exits cleanly. Original task3's separation10 suggestion would not meet the newer y636 target, so current spacing12 is retained and latest C2 placement used. Next original-queue slice: task4 / C1, preference preservation and crash-safe saving against today's split preference contract. C3/C4 and remaining factory requests remain pending; proposed wording flags unchanged.

## Codex result, October 26: C1 / task 4 title save

TITLE PORTION COMPLETE/INSTALLED: main_menu.gd loads current preferences before updating its five title keys, writes the complete .tmp then renames over the final file. Errors retain the dirty/retry flag and show the existing error; a successful retry clears it. Success refreshes shared preference caches. Native28/28 (save/integration16, fresh process4, failure/retry8); normal/restart logs clean, failure injections emit only the expected two warnings. Official rebind regression PASS,26 assertions, exit0 (its existing14-instance/5-resource exit noise retained). Real title controls preserve unknown keys, female courier and audio values; separate game prefs are byte-exact at the title-save boundary; later migration/rebinds/text speed survive. Earlier title bounds retained. Only the owned main_menu save method changed; Claude's concurrent files were preserved and recorded. Private profiles/settings/saves only; no art/rules/generation/paid call/commit. [Evidence and source diff](../ui/settings-save-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_settings_save.md).

Original task4 is NOT claimed fully closed across all writers. Source issue for Claude's active pass7 UI lane: shared UI.write_prefs moves the final file to .bak before installing .tmp, but its readers do not read .bak. A private diagnostic reproduces an interruption state with valid backup settings yet default values returned. ui_style.gd/game_pause_menu.gd remain untouched as active Claude files. A concrete candidate-only fix is staged in the evidence folder's proposal/shared-pause-save.diff (copy prior final to backup, propagate backup-copy errors, then replace final). Candidate8/8 tests pass interruption-after-backup, existing-reader recovery, successful replacement and failed-backup preservation; NOT INSTALLED. Please rebase/integrate the small diff in the active UI lane. Title's direct rename avoids this separate gap. No cross-chat message sent. Next independent Codex factory slice C3 (type roles/shared button styles); C4 and remaining requests still pending, proposed words retain flags.

## Codex result, October 26: C3 title and soul type roles

COMPLETE/INSTALLED: title/menu/panel text uses shared UI.TYPE roles, buttons UI.style_button plus UI.frame normal/focus, with creature MENU_FACE/COPY_FACE/direct hint-font overrides removed. Carved wordmark exact RGBA. Soul lines now use UI.dialogue/story with readable two-row pages and page-aware advance; card names/body/hints use roles, duplicate prose typing blip removed. All original story words, input/choice/flight methods, card geometry/creature scale and previous title preference-save methods exact. Current roles are Jersey prose/headings/names and Silkscreen buttons/labels, per the real UI.TYPE contract, not an older Pixelify description. Only three owned title/soul scripts changed; concurrent Claude files preserved/archived. Native45/45 title/story, full native ui_fit48/48, both clean logs; official opening_flow21-check, soul_prologue and ui_fit all PASS, exit0 (known raw exit warnings retained). Main ends590/596 without/with Continue, Options586, Help602, Quit right1108; all fit. Native captures inspected, private saves/profiles only, no art/generation/paid call/rules/new words/commit. [Before/after and evidence](../ui/title-type-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_type.md).

Source issues for Claude: C7's shared-dialogue/font portion landed as necessary for the story role's readable page size; its input-action migration and main_menu _ensure_menu_inputs removal remain pending. No runtime UI.HEAD users remain in soul; only party_screen's historical comment remains elsewhere; shared HEAD stays untouched in the active UI lane, remove when ready. Baseline actual Continue menu bottom616 is now measured596 after shared type metrics. Previous task4 shared pause-save gap remains OPEN with its8/8 candidate-only diff under settings-save-2026-10-26/proposal, not installed. No cross-chat message sent. Next independent Codex slice C4 full title Options parity/shared filled sliders and live ControlsText help; C7 remainder, C8 cards, C9 light and other opening/export/art requests remain pending. Proposed words/flags unchanged.
