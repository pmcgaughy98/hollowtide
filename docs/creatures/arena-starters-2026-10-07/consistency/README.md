# Arena sprite consistency, October 7, 2026

Installed colour corrections for all nine forms: 72 full facings, 15 existing walk sheets (120 source frames), and 264 rebuilt game PNGs. Every painted colour belongs to that form's approved base take. All 369 original PNGs are preserved, including the unchanged nine approved takes and nine rotation sheets. No paid generation, commit, or Godot code/scene change.

Preston's follow-up concerned Sparkwick, Kithflare stage II, facings **4/5: NE/N**. Their copper body now has the approved material's lighter midtones and stronger dark shading. The regional correction preserves the lanterns, existing contours, and the other six previously reviewed facing results byte-for-byte. Selected body brightness is **136.40 / 134.11** with contrast standard deviation **28.38 / 27.19**. [Detailed comparison](review/sparkwick_ne_n_contrast_comparison5x.png): original, earlier warm option, installed contrast option, approved base. [Installed game-size comparison](installed-proof/contacts/sparkwick-facings-before-after-game3x.png): before above, after below, ordered S/SE/E/NE/N/NW/W/SW.

| Form | Full brightness spread, before → after | Game-size spread, before → after |
| --- | --- | --- |
| Kithflare | 5.72 → 0.98 | 12.74 → 7.50 |
| Sparkwick | 26.88 → 4.13 | 20.26 → 12.25 |
| Stormwick | 15.17 → 1.13 | 17.12 → 5.93 |
| Tallowroot | 6.07 → 1.11 | 4.71 → 2.63 |
| Huskward | 5.98 → 2.53 | 7.29 → 4.18 |
| Rampartroot | 10.04 → 0.66 | 14.60 → 4.30 |
| Rimefin | 11.01 → 1.23 | 13.27 → 6.39 |
| Riftfin | 8.99 → 0.28 | 11.02 → 5.82 |
| Scourmaw | 9.51 → 1.02 | 11.40 → 3.68 |

All full-facing spreads meet the approximate <8 target. Sparkwick's game-size average still differs because NE/N contain proportionally more bright lantern/head pixels; dimming the rear body to force this number would reverse the requested material fix. Later forms retain their approved darker bronze, bark and gray-blue identities. Game walk brightness ranges improve but remain above 8 across all facings/poses: Kithflare 15.65 → 14.39, Tallowroot 16.21 → 10.64, Rimefin 21.39 → 12.74. Original RD anatomy/highlight-placement drift, including the taller Kithflare walk design and simpler Sparkwick rear heads, remains outside this colour-only pass.

[72-facing brightness/saturation/colour-count table](installed-proof/before-after-facings.md), [full and small spread tables](installed-proof/before-after-spreads.md), [120 source-walk measurements](installed-proof/before-after-walk-source-frames.csv), and [192 game-walk measurements](installed-proof/before-after-walk-game-frames.csv) report actual installed pixels. [Nine facing and fifteen walk contacts](installed-proof/contacts/) are game size at 3x; [walk previews](installed-proof/walk-previews/) use 140ms per frame for inspection, independent of game timing.

Structural checks passed: all full facings/whole walk sheets retain exact alpha and canvases; all 192 source-facing/frame measurements retain their silhouette, bounding box and foot row. No partial transparency or magenta remains. Tallowroot NE walk had 23 magenta pixels replaced in place using valid nearby material colours. Tiny intentional sparks, spikes and barbels stay. [Complete checks](installed-proof/consistency-check-summary.json).

The only existing Python tool change is `tools/arena/build_small.py`: five explicitly mirrored stills now flip **after** the unchanged one-third shrink. Right-edge truncation had broken Kithflare E, Rimefin E and Scourmaw SW symmetry. Their three derived small alpha masks change, documented individually; all game canvases and foot rows stay exact. All 82 required full/small/walk mirror checks pass. `downscale.py`, `slice_rotations.py`, `finish_back.py`, and the other 601 guarded existing code/tool files remain unchanged.

Godot 4.7.2 headless import and the requested `arena_stages.gd` run both exit 0 with **zero script errors**. All six fresh 1152×648 captures are [included here](native/runtime/stills/) and [summarized visually](installed-proof/arena-native-stills.png). Stormlantern leaves the target at 108/150 HP, matching 42 damage. This fixture covers four evolved-form matches plus the title/strike, not every facing or Stage-I walk. Original user captures were backed up before playback.

The logs are not completely clean: [import stderr](native/import/stderr.log) reports the previously documented default-audio-bus UID `blm6ps3r8bf7l` and empty-resource-save-path errors; [runtime stderr](native/runtime/stderr.log) reports 9 leaked ObjectDB instances and 3 resources still in use at shutdown. Audio/game code repairs were not part of this task. These did not prevent importing the sprites or saving fresh arena captures.

Added `tools/arena/normalize_arena_palette.py` and `report_consistency.py`, both with docstrings. To reproduce from preserved originals, run from the project root:

```text
python tools/arena/normalize_arena_palette.py --project . --source docs/creatures/arena-starters-2026-10-07/consistency/source-audit/originals --output docs/creatures/arena-starters-2026-10-07/consistency/rebuilt
```

This writes fixed versions alongside the originals for review. The installed game files were rebuilt with `python tools/arena/build_small.py`. To remeasure the active files:

```text
python tools/arena/report_consistency.py --project . --before-audit docs/creatures/arena-starters-2026-10-07/consistency/source-audit --output docs/creatures/arena-starters-2026-10-07/consistency/recheck
```

[Exact active-file changes and archive paths](changed-files.json), [installation receipt](installation-receipt.json), [normalization parameters](candidate-audit.json), and [preserved original sources](source-audit/originals/) provide the handoff. The shared guide has a dated entry for this installed arena work.
