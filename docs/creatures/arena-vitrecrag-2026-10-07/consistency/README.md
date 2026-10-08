# Vitrecrag line: arena material consistency, October 7, 2026

Installed Fusern, Slagglass and Vitrecrag material cleanup. Fusern's pale-orange E/NE/N/NW shell views and walks now use its approved darker brick/mortar colours. This is arena art only, with no paid generation or commit.

Approved bases `forms/fusern.png`, `forms/slagglass.png` and `forms/vitrecrag.png` remain the authority. Their brick kiln, glass plates and crater materials stay distinct. Shapes, poses, outer silhouettes, canvases, foot rows and facing assignments remain fixed. Alpha is exact for Fusern, Slagglass, every full facing and Vitrecrag NE/N walks. The accepted exception restores exactly 2,886 transparent crater pixels in 11 fully enclosed original components across Vitrecrag S/SE/E walk sheets. Added pixels are hard alpha 255 and own-base crater colours. Original external background and transparent RGB outside those exact masks remain unchanged; this is explicitly an internal alpha restoration, not an all-alpha-exact pass.

| Form | Full brightness spread before -> after | Game-size spread before -> after |
| --- | ---: | ---: |
| Fusern | 35.53 -> 9.22 | 37.76 -> 8.68 |
| Slagglass | 13.53 -> 2.15 | 14.75 -> 5.94 |
| Vitrecrag | 3.73 -> 0.48 | 3.52 -> 2.08 |

Measured 24 full facings, 120 source walk frames, 24 game stills, 192 game walk frames and 3 bases: 363 records. Every painted output colour comes from its own approved base. No partial alpha or magenta; 72 derived walk mirrors and 216 exact unchanged-pipeline results pass. Derived game alpha changes in 19 saved walk frames are listed individually in final-verification.json and remain exact outputs of the unchanged shrink/mirror pipeline; small canvases, outer bounding boxes and feet remain fixed. Full and game spread flags are recorded independently in [installed proof](installed-proof/consistency-check-summary.json), including any remaining >8 value rather than hiding it.

## Fusern shell fidelity

Source/S/SE/W/SW are the dark-brick references. The shell treatment separates brick faces, dark joints and limited hot fissures; the gray lower band, legs and eyes keep their existing geometry. Whole-body brightness alone was insufficient, so these final values are measured from actual installed PNGs:

| Fusern facing | Dome mean before -> after | Bright-orange share% before -> after | Dark joint/shadow share% before -> after |
| --- | ---: | ---: | ---: |
| E | 136.33 -> 88.07 | 78.36 -> 0.00 | 6.14 -> 23.55 |
| NE | 120.35 -> 82.48 | 51.66 -> 0.00 | 8.40 -> 27.10 |
| N | 130.47 -> 86.58 | 61.97 -> 0.83 | 2.05 -> 20.51 |
| NW | 148.64 -> 87.81 | 84.13 -> 1.98 | 2.37 -> 19.83 |

This fixed diagnostic ROI is the upper 52% of the original painted bbox, excluding the external silhouette edge. It is a comparable upper dome, **not semantic segmentation of the whole shell**. Bright warm orange uses L>=130; dark pixels L<=60 include joints and shadows. The measures support colour/contrast fidelity and do not prove a complete anatomy redraw. [Actual installed shell CSV/JSON and good/pale-facing contacts](installed-shell-proof/). The accepted Fusern recipe retains its exact source-derived repair masks and RGB-role audit in [fusern-brick-audit.json](fusern-brick-audit.json). Any interior donor-brick detail is documented there; silhouettes and alpha remain exact. Accepted seam, warm-pit and enclosed-alpha stage audits/masks are retained in [accepted-vitrecrag-material](accepted-vitrecrag-material/); their historical proposal_only flags record staging, while selected-integration and actual installed hashes prove the accepted final bytes.

## Exact changes and preservation

Changed **255 active PNGs**: 24 full facings, 15 source walk sheets and 216 game PNGs. Exact paths/hashes and added tools are in [changed-files.json](changed-files.json) and [final-verification.json](final-verification.json). Preserved 264 original art PNGs and 8 initial captures under [source-audit/originals](source-audit/originals/). Approved bases, pads, rotation sheets and raw source inputs stay unchanged.

All 1020 current assets belonging to the previous 12 arena forms remain byte-identical to reviewed pre-install guards. Of 629 reviewed code/settings/tool guards, 628 remain byte-identical. The reporter alone was extended narrowly for typed `fill_enclosed_crater` coordinates, 0-to-255 transitions, independent enclosed-component checks and bbox/feet preservation; its installed hash matches the reviewed staged script. Its original version remains archived. Existing normalize/build/shrink/slice and finish_back tools remain unchanged. The reporter extension is described above; default audited-removal behavior is preserved. Added tools: tools/arena/repair_fusern_brick.py, tools/arena/repair_vitrecrag_seams.py, tools/arena/repair_vitrecrag_core.py, tools/arena/fill_vitrecrag_core_voids.py, tools/arena/audit_fusern_shell.py. Claude's 6 concurrent code updates were read and preserved before refreshing guards; prior hashes/manifests and external snapshots are retained. No `.gd`/`.tscn`, settings, rules, audio or control edits by this pass.

Current controls remain Claude's newer model: AI footwork, player targeting, abilities on 1-4 with 4 as ultimate and SPACE team switching. Creature selection is through the matchup picker; historical line-selection key 5 is superseded.

## Native verification and limits

Godot 4.7.2 headless import and renderer-enabled fixed-fps 30 `res://tools/debug/arena_vitrecrag_check.gd` both exited 0 without script errors in bounded hidden owned processes. All 8 fresh 1152x648 captures match receipt hashes and were written within the owned runtime interval. [Receipts, original captures, logs and stills](native-proof/); [timestamp/hash validation](final-verification.json).

Import stderr is empty. Runtime stderr is empty. This art pass does not claim unrelated audio/import/shutdown issues fixed. Native stills show the current runtime; exhaustive contact/palette/geometry/pipeline checks cover all saved frames. Original AI anatomy and motion-detail drift can remain; installed and reviewed is not a claim that the full arena or every creature is final.

## Evidence and reproduction

[24-facing brightness/saturation/colour table](installed-proof/before-after-facings.md), [CSV](installed-proof/before-after-facings.csv), [full/game spreads](installed-proof/before-after-spreads.md), [120 source-walk measurements](installed-proof/before-after-walk-source-frames.csv), [192 game-walk measurements](installed-proof/before-after-walk-game-frames.csv), [selected-form facing/walk contacts](installed-proof/contacts/), [15 walk GIF comparisons](installed-proof/walk-previews/), [original source/full2x contacts](source-audit/contacts/), [installed shell-material proof](installed-shell-proof/), [accepted masks and palette baseline](recipe-inputs/), [accepted Vitrecrag material/fill stages](accepted-vitrecrag-material/), [reviewed candidate material contacts](reviewed-candidate-contacts/), [clearly labelled intermediate proposals](intermediate-proposals/), [independent diagnostics](independent-review/).

Use preserved originals with the unchanged normalizer, always naming only these forms:

```text
python tools/arena/normalize_arena_palette.py --project . --forms fusern slagglass vitrecrag --source docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals --output <separate-candidate-folder>
```

The accepted Fusern repair uses the archived seven-file palette baseline and explicit NW interior donor option:

```text
python tools/arena/repair_fusern_brick.py --project . --source docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals --candidate <separate-candidate-folder> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/palette-baseline --restore-nw-donor
```

Do not run whole-image normalization again after this material repair: it would whiten the restored mortar. The accepted Vitrecrag recipe runs three bounded stages into separate output roots:

```text
python tools/arena/repair_vitrecrag_seams.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --output <separate-seams-output>
python tools/arena/repair_vitrecrag_core.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --seams <separate-seams-output> --output <separate-core-output>
python tools/arena/fill_vitrecrag_core_voids.py --project . --source <preserved-originals> --baseline docs/creatures/arena-vitrecrag-2026-10-07/consistency/recipe-inputs/vitrecrag-palette-baseline --input <separate-core-output> --output <separate-enclosed-core-output>
```

Here `<preserved-originals>` is `docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit/originals`. Compare the five outputs with the archived accepted-stage hashes/masks, then copy only their five Vitrecrag walk sheets into the candidate's same relative paths. The source/acceptance proofs distinguish the exact 0-to-255 fill exception from palette edits. From the candidate root, run the unchanged builder with only the three explicit names:

```text
python tools/arena/build_small.py fusern slagglass vitrecrag
```

Never run the slicer/builder bare. Then report actual installed PNGs:

```text
python tools/arena/report_consistency.py --project . --forms fusern slagglass vitrecrag --before-audit docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit --geometry-repairs docs/creatures/arena-vitrecrag-2026-10-07/consistency/accepted-vitrecrag-material/enclosed-core/vitrecrag-crater-repairs.json --output <separate-proof-folder>
python tools/arena/audit_fusern_shell.py --before-audit docs/creatures/arena-vitrecrag-2026-10-07/consistency/source-audit --image-root . --output <separate-shell-proof-folder>
```

Exact scripts, originals, accepted recipe audits, clearly tagged intermediate proposals, current metrics and native proof remain archived. Finalization does not update the shared AI guide; root handles that separately, preserving newer decisions.

## Concurrent project history

Claude committed project work while this pass was running. The observed VFX commit was `5c9a42e` (October 7, 2026, 21:30:23 CDT); its code was already present before the owned runtime launch and was read and preserved. Codex did not stage, commit or reset the project. The reviewed guard histories retain the successive external revisions.
