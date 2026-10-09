# Listener line palette refinement, October 8, 2026

Installed palette consistency pass for **Cutbank Listener, Bend Caller and Quietwater Warden**, following Preston's request to finish the line's pending sprite refinement. Keeps the approved squat kit, lanky adolescent and ridged frog guardian. This is the established deterministic asset integration pass; no generated redesign, new anatomy, lore, creature rules or paid generation.

## Installed changes

- 255 active PNGs: 24 full facings, 24 game facings, 192 game walking frames and 15 source walk sheets.
- Each form uses its own approved `*_arena_front_take1.png` palette: Listener 29 colors, Caller 28, Warden 30. The existing bounded palette normalizer repairs brightness/saturation drift and dark outline consistency. The Caller keeps its pale throat and mouth colors; the Warden keeps its dark teal body and pale plate edges.
- Every active PNG retains its exact original alpha channel and canvas size. Full-source poses, silhouettes, feet and cell placement are unchanged. The unchanged named-only builder retains scales 0.95 / 1.0 / 1.1.
- The approved bases and raw rotation sheets remain untouched as source evidence. **Do not reslice these raw rotation sheets over the installed color-corrected stills.** Reproduce with the scoped helper below instead. Do not run the all-form builder.
- 261 source/game originals are retained here, including the six unchanged palette/rotation references. Rejected takes and raw generation receipts remain untouched in their original folders.

## Verification

Native Godot 4.7.2 Compatibility: **436 assertions, zero failures**, covering exact alpha/size for all 216 game PNGs, all 24 runtime still selections, all 192 runtime walking selections, the three actual stage names, and Hush playing with Warden art. Reviewed before/after captures, Caller walking poses and all three stages in the arena. The test's paused HUD was explicitly redrawn before capture. `native/` contains fresh engine captures and `checks.json`.

Independent asset audit: all 255 PNGs retain alpha/size and use only their own base colors; **216 exact current-pipeline comparisons** cover stills, authored walks and mirrored walks. Each of the five authored cycles still has eight distinct game frames. `asset-audit.json` includes per-image changes. The reproducible helper's output is compared byte-for-byte against the installed candidates.

Walking brightness ranges at game size (different facings and poses combined; lower spread is not by itself visual approval):

| Form | Before | After |
| --- | --- | --- |
| Cutbank Listener | 64.85–74.54 | 69.32–73.06 |
| Bend Caller | 51.98–68.05 | 56.71–71.15 |
| Quietwater Warden | 63.96–71.00 | 65.50–68.39 |

Caller still has visible pose-dependent changes in its pale throat and thin limbs. Those are original artwork and majority-downscale differences, not missing frames. This pass does not promise identical brightness across poses or eliminate the existing three mirrored walking directions. Final visual approval remains Preston's.

## Reproduce safely

From the project, with Python/Pillow/NumPy available:

```powershell
python tools/arena/refine_listener_palette.py --project . --originals docs/creatures/listener-palette-refinement-2026-10-08/originals --output D:/dev/listener-new-candidate
```

The output must be a new directory. The helper copies and uses the current `normalize_arena_palette.py`, `downscale.py`, and `build_small.py`. Their tested versions are retained in `pipeline/`. It never installs automatically. Source identities, normalization parameters and candidate hashes are in `original-manifest.json` and `candidate-audit.json`.

Native check:

```powershell
Godot --path . --rendering-method gl_compatibility --fixed-fps 60 --script res://tools/debug/listener_palette_check.gd
```

Default repeat captures go to `rerun/`, preserving the installed evidence. Optional two arguments after `--` override the output directory and original `assets/sprites/arena` root. Testing used an isolated project/profile with MCP disabled there only.

## Preservation and limits

Installation guards retain all 620 protected seven-form image hashes, 622 original/palette archive entries (including dark-jade Oxbowarchon), and all 86 Galeshear repaired PNG/source paths. No gameplay, data, scene, audio, launch setting, existing builder/slicer or world/menu file is installed by this pass. Claude's concurrent movement/camera and matchup-picker changes were copied into the isolated test project and left intact in the live project. `tested-code.json` records the precise tested snapshot; `installation.json` records any later concurrent differences rather than overwriting them.

The final native run has no script errors or shutdown resource warnings; it retains the Windows root-certificate diagnostic. Import also recorded the pre-existing audio UID/empty-resource-path diagnostics. Earlier captures/logs are kept separately. This is art and resource verification, not a new balance simulation, full movement regression or campaign recruitment integration. No commit.
