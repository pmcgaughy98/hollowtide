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
