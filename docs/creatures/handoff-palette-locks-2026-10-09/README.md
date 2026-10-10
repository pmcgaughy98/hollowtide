# October 10 handoff: five current models, palette locks and relay verification

Preston asked to resume `docs/team/CODEX_HANDOFF_2026-10-10.md`. Read its required design/pivot notes and current collaboration log, inspected existing art and dirty tree first. Job 1's initial native 24px tileset/painter and the creature launch already exist; the obsolete human-main-scene statement in the original handoff is historical. This slice finishes the outstanding palette pass for Dustkite, Waywhistle, Highsignal and the approved remade Riftfin/Scourmaw, and reruns the relay check requested in job 3.

## Installed art

The same existing exact-reference palette normalizer is used without changing its algorithm. Each form's currently approved `*_arena_front_take1.png` supplies all allowed colors. The original eight facings are treated independently; the old Riftfin/Scourmaw mirror assignments are not imposed on their new rotation art. Five cleaned source walk sheets per form are normalized frame by frame. The unchanged named-only arena and dungeon builders then recreate both sprite sizes. No new art/model generation, geometry change or kit/stat change.

65 source PNGs and 720 derived PNGs verified; 784 have changed RGB. All **785** retain exact canvas, alpha bytes and transparent RGBA. Every painted output color belongs to its form's approved reference. Sizes, source foot rows, cleaned Dustkite silhouettes, native frame order and existing mirrored walking assignments remain. Original approved base/rotation sheets, old serpent/blade-fin variants, every earlier palette refinement, Oxbowarchon's dark jade, Listener finish, Galeshear wings and all backups are untouched. The shared Hollowtide Sprite renderer remains active.

| Form | Full-facing brightness spread before | After |
| --- | ---: | ---: |
| Dustkite | 9.84 | 1.59 |
| Waywhistle | 13.42 | 4.78 |
| Highsignal | 11.60 | 0.67 |
| Riftfin | 8.25 | 0.52 |
| Scourmaw | 13.91 | 0.83 |

Whole-sprite averages measure palette drift, not anatomy. Different poses expose different proportions of ivory, sail membrane and dark body. Waywhistle retains an arena-facing spread of 13.40 after the size conversion (dungeon-facing spread 7.35), and walking spreads of 13.28 / 11.01 for arena / dungeon, reduced from 24.54 / 19.65. Exact per-facing and walking values for both sizes are in the report JSONs. The pass keeps that material detail instead of flattening it to force a statistic. Original generator pose differences are not redrawn.

## Verification

`structural-and-palette-checks.json` records all 785 palette/geometry comparisons. `candidate-audit.json` includes the exact per-frame transformations and allowed palettes. `game-size-before-after.png` shows every arena facing; `prepared-walk-review.gif` shows the SE cycle for both sizes. Native Godot `palette_native_check.gd` uses the actual arena and dungeon constructors/loaders and shared finish, swaps all **720** derived textures through their real anchor methods and captures `native-palette-view.png` / `native-walk.gif`. This is a controlled native art view, not an AI composite or a dungeon-clear test.

The existing `relay_yard_check.gd` is rerun with both courier appearances against Claude's current picker/relay fix: 25 real walking/input/transition checks per appearance, including opening a Cinderhide/Fusern practice fight, returning through the picker to the exact cached yard, preserving party/route state and returning through the gate. Logs and fresh captures are retained. Final native logs have no script/resource errors; the existing Windows certificate-store diagnostic remains. Any shutdown diagnostics are recorded rather than hidden.

## Preservation and reproduction

`originals/` preserves every current pre-pass source/derived PNG and approved reference. `candidate/` preserves the complete prepared set and the unchanged builder/normalizer code used. `.gdignore` excludes this archival project/art from Godot imports. `baseline.json`, `installed-files.json`, `installation.json` and `preserved-sha256.json` record exact scope and hashes. Only the listed art paths and collaboration/handoff notes are written; Claude/Grok runtime, rules, source references, project settings, menu and wordmark remain intact. Concurrent protected changes, if observed, are recorded and retained.

Reproduction helpers are in `reproduction/`. To rerun the preparation from this archive, copy `originals/`, `candidate/` and those helpers together into a new empty work directory, then run `normalize.py` followed by `report.py` and `walk_review.py`. Do not run the installer for a second copy; its exact live-source guards are specific to this installation. No commit, reset, revert, stash, paid call or generation.

The next unbuilt handoff slice is the creature guild/job-board dispatch and return loop; persistent player identity and dungeon/save contracts remain Claude's responsibility. Emotion portraits remain a later job.
