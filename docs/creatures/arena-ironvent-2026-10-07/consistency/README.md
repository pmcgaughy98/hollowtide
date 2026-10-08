# Cinderhide line: arena consistency, October 7, 2026

Installed Cinderhide, Clinkerhide and Ironvent color/outline cleanup and removed Clinkerhide's generated curl above the crest. This is arena art only. No generation or Retro Diffusion charge. No commit.

The approved bases in `docs/creatures/arena-starters-2026-10-07/forms/` were read unchanged: `cinderhide.png`, `clinkerhide.png`, `ironvent.png`. Their charcoal bodies, gray/tan stone armor and orange vents are the material authority. Ironvent's approved gray armored head remains gray. Kithflare is the clarity bar, rather than a brightness target for these deliberately dark creatures.

| Form | Full brightness spread before -> after | Game-size spread before -> after |
| --- | --- | --- |
| Cinderhide | 5.80 -> 1.66 | 6.95 -> 3.09 |
| Clinkerhide | 4.26 -> 0.98 | 6.51 -> 1.45 |
| Ironvent | 8.15 -> 1.08 | 6.70 -> 2.79 |

Measured all 24 full facings, 120 source walk frames, 24 game stills and 192 game walk frames, plus the three bases: 363 records. Every installed painted pixel uses its form's exact base palette. No partial alpha or magenta. All 72 derived walk-frame mirror checks pass. All 216 game PNGs match the unchanged named-form shrink pipeline exactly. Largest within-cycle game brightness ranges remain below 5. Cinderhide rear saturation varies because the rear hides orange vent area; forcing equal saturation would recolor its gray armor.

## Exact changes and preservation

- Changed 255 active PNGs: 24 full facings under `assets/sprites/arena/{cinderhide,clinkerhide,ironvent}/`, 15 source walk sheets under `docs/creatures/arena-starters-2026-10-07/walk/`, and 216 PNGs in the three `small/` folders. The exact filenames are in [changed-files.json](changed-files.json).
- Added `tools/arena/repair_clinker_curl.py`; extended `tools/arena/report_consistency.py` with explicit form selection, exact pipeline proof, other-form guards, and pixel-specific geometry exceptions. The original nine-form default remains. Existing normalizer, builder, slicer, shrink, finish_back, all .gd/.tscn and game settings remain unchanged by this task.
- Preserved 265 original PNGs and 11 initial native captures under [source-audit/originals](source-audit/originals/). Native proof also retains all 11 captures as they stood immediately before our runtime. Approved bases, raw take/pads and rotation sheets are byte-identical. All 765 current assets belonging to the old nine arena forms are byte-identical.
- Claude updated arena_prototype.gd and arena_rocks_capture.gd for larger faceted boulders during review. The first install guard stopped with zero writes. Both updated files were read and saved as external changes, then preserved; current 615 protected code/tool checks pass with only the explicitly authorized report-tool change. Initial and refreshed guard manifests remain in source-audit.

Clinkerhide's south sheet has one explicit silhouette exception: 270 positive-alpha pixels forming a generated thin external curl were removed from frames 1, 2, 3, 5, 6, 7. Frames 0/4, true crest tips, body and feet were preserved; all unmasked RGBA stays exact relative to the palette candidate. Foot rows and canvases stay exact for every source and game frame. The six affected game masks naturally lose the curl through the existing shrink. Exact-alpha fields correctly report false; the separate geometry-valid fields prove that ONLY the audited source pixels changed alpha. [Mask, coordinates and comparisons](clinker-curl-review/proposal/) and [geometry repair audit](geometry-repairs.json).

## Native verification and practical limits

Godot 4.7.2: headless import then renderer-enabled fixed-fps 30 `res://tools/debug/arena_rocks_capture.gd`, each in a bounded hidden owned process. Both exit 0, zero script errors. Eleven fresh 1152x648 stills cover all three forms, Furnace Roar, wall/rock slams, cracked boulder and rubble. The current runtime reports enemy Roar HP 150->146,212->201,128->96; wall slam 150->132, rock HP 44/60, then 2 rocks and 16 rubble bits. [Logs, receipts, stills and original captures](native-proof/).

Import retains the existing unknown audio UID and empty-save-path errors. Runtime retains 13 ObjectDB leaks and 6 resources in use at exit. These do not become 'clean stderr' or a claim that the unrelated engine issues are repaired. Capture timestamps are verified, including captures whose pixels match the original. The native stills are runtime evidence; the all-frame sheets and palette/pipeline proof provide the exhaustive art checks.

This improves palette, outline stability and the documented curl artifact. Original RD anatomy differences and fine-grain armor noise remain visible, especially Ironvent's walks; no topology redraw, resize or paid regeneration was performed. There is no approval blocker for the installed pass.

## Evidence and reproduction

[24-facing brightness, saturation and color-count table](installed-proof/before-after-facings.md), [CSV](installed-proof/before-after-facings.csv), [per-form spreads](installed-proof/before-after-spreads.md), [120 source walk measurements](installed-proof/before-after-walk-source-frames.csv), [192 game walk measurements](installed-proof/before-after-walk-game-frames.csv), [3 facing and 15 walk comparison sheets](installed-proof/contacts/), [15 animated walk comparisons](installed-proof/walk-previews/), [independent visual review](independent-review/README.md), [installed invariant proof](installed-proof/consistency-check-summary.json).

Use the preserved originals as input to the unchanged normalizer, ALWAYS naming these three forms:

```text
python tools/arena/normalize_arena_palette.py --project . --forms cinderhide clinkerhide ironvent --source docs/creatures/arena-ironvent-2026-10-07/consistency/source-audit/originals --output <separate-candidate-folder>
```

Run repair_clinker_curl.py with `--source` pointing to the preserved original south sheet, `--input` to the palette-fixed candidate south sheet, `--project` to this project, and `--output` to a separate review folder. It saves a proposed PNG and exact mask audit, and does not edit live art. Copy the reviewed PNG into the candidate south-sheet location. Rebuild only these names with the unchanged build_small.py from the candidate root. Do not run the slicer or builder bare, because that overwrites other corrected forms.

Installed verification:

```text
python tools/arena/report_consistency.py --project . --forms cinderhide clinkerhide ironvent --before-audit docs/creatures/arena-ironvent-2026-10-07/consistency/source-audit --geometry-repairs docs/creatures/arena-ironvent-2026-10-07/consistency/geometry-repairs.json --output <separate-proof-folder>
```

The scripts folder preserves the exact normalizer/builder/shrink and new repair/report tools used here. Run proof against installed assets to verify colors, alpha exceptions, feet, palettes, mirrors, untouched old-nine assets and exact shrink results. Original data and previous handoffs are retained.
