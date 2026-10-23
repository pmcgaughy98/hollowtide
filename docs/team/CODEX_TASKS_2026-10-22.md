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
| after | GS-01, GS-03 | Title Options rows for screen mode (UI.apply_screen_mode) and text speed, same prefs keys; apply both at launch |
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
