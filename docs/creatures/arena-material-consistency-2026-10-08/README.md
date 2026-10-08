# Arena material consistency installed, October 8, 2026

Scope: the new Slagglass, Preostmar/Oathfen/Oxbowarchon, and Punchybun/Sparkjab/Starward.

## Result

595 active PNGs changed: 56 full facings, 35 source walk sheets and 504 rebuilt game PNGs. [Every changed path](installed-files.json). Repainted existing pixels only; source alpha bytes, canvas, poses, feet and facing assignments remain exact. Current approved per-form sizes are preserved through the unchanged builder. No game code, settings, creature rules, title-card image, approved raw base, paid call or commit was changed/performed.

Oxbowarchon retains the approved new A pose and silhouette, with the pale desaturated jade recolored using eight exact muted emerald/jade colors sampled from its original front. Saturated rail greens, dark body and gold retain their own roles. This is an explicit Preston-authorized color override, not an assertion that the unchanged pale arena take is the palette authority. See [the corrected reference](palette-reference/oxbowarchon-dark-jade.png), [palette selection](palette-reference/references.json), [references](references.png) and [reference hash checks](reference-checks.json). The signature card itself stays unchanged.

Slagglass keeps the chosen new kiln-beetle design, dark bricks and orange seams, reducing yellow seam flashes in mid-dome walk pixels while preserving the crater. Preostmar/Oathfen walking jade no longer projects to white/mint highlights. Punchybun's line retains cream fur and pink accents from each approved base; it is deliberately much lighter than the stone lines.

## Proof and practical limits

All full/game facing spreads are below 8. These averages measure actual saved pixels; they do not prove identical anatomy. Walking poses expose different material proportions, and sparse-palette downsampling changes proportions further. Residual game-walk spreads above 8 are retained and disclosed instead of forcing white fur or glowing material into flat colors. Source-generated motion/pose differences remain; this pass did not redraw shapes.

| Form | Full facing spread | Game facing spread | Game walk spread |
| --- | --- | --- | --- |
| slagglass | 0.72 | 0.61 | 8.12 |
| preostmar | 0.36 | 3.82 | 9.84 |
| oathfen | 2.31 | 2.87 | 9.26 |
| oxbowarchon | 2.09 | 2.17 | 5.14 |
| punchybun | 3.88 | 3.06 | 5.96 |
| sparkjab | 4.97 | 5.08 | 10.71 |
| starward | 1.28 | 3.00 | 4.87 |

See [every facing's brightness/saturation/color count](review/before-after-facings.md), [spread tables](review/before-after-spreads.md), source/game walking CSVs in review/, [structural and palette proof](review/consistency-check-summary.json), [candidate parameters and pixel counts](candidate-audit.json), [contacts](review/contacts/) and [walk GIFs](review/walk-previews/).

Checks: 847 metric records; 620 unchanged original snapshots; 168 exact walk mirrors; 504 RGBA-exact comparisons against the current builder, including its per-form resample scales; all 1190 other-fourteen arena PNGs unchanged; 654 existing code/tool/settings guards unchanged. No source geometry exemption was needed. All painted output colors belong to the selected reference palette, with the single explicit Oxbowarchon override. Original files live in source-audit/originals/ and source-audit/references/.

## Native verification

Final headless Godot 4.7.2 import exits 0, no errors. Current arena_backline_check.gd and arena_protector_check.gd exit 0 with no errors/warnings. arena_vitrecrag_check.gd shows the new Slagglass and exits 0 with no script errors, but logs a shutdown ObjectDB/resource leak; that code issue is not repaired by this art pass. Initial import diagnostics are separately preserved. All 23 captured stills are new, checked against timestamps/hashes and 1152x648 dimensions. [Native evidence](native-verification.json); screenshots, logs, receipts and backups of the earlier stills are under native/<line>/.

## Reproduce without overwriting active art

From the project root, run:

```text
python tools/arena/refine_arena_materials_20261008.py --workspace docs/creatures/arena-material-consistency-2026-10-08
```

This reads preserved originals and writes candidates under the archive's source-audit/candidate-project/, then builds ONLY these seven forms using the copied unchanged pipeline. The archive has .gdignore. It does not install candidates into the live game. The optional --forms limits a repeat to named forms. The new report_arena_materials.py accepts --project, --before-audit, --output, --forms and --palette-reference; it parses the current SCALE constants without executing the builder.

Do not reslice raw rotation sheets over the fixed facings, restore the old Slagglass, or use the pale Oxbowarchon take as current color authority. Named build_small.py calls are safe after the fixed full facings and source walks are installed. Local reproduction/ helpers retain the actual preparation, guarded installation and native-run workflow; original materials and game settings are untouched.

## Concurrent code after verification

The final check found one later external update to scripts/arena/arena_prototype.gd, containing arena kit/control changes. It was read and preserved without edits by Codex. All 620 snapshotted image paths still match the installed proof, all 1190 other arena assets remain unchanged, and the other 653 existing code/tool/settings guards remain unchanged. The original report and 23 native captures describe the previously verified script hash; they do not certify the later concurrent code revision. [Final state and both script hashes](final-state-check.json); the latest script bytes and its diff against Git HEAD are preserved in concurrent-code/. The Git diff includes earlier shared work and is not claimed to isolate only the last edit. No art blocker remains.
