# Vitrecrag-line original arena audit (October 7, 2026)

Current forms are **Fusern → Slagglass → Vitrecrag**. All three arena takes are in `docs/creatures/arena-starters-2026-10-07/forms/<form>.png`. Their full-size facings are `assets/sprites/arena/<form>/<s|se|e|ne|n|nw|w|sw>.png`. Each rotation uses TALLOW in the current slicer, and each form has five source walk directions(s,se,e,ne,n); the other three game walks are mirrors.

This audit writes only the task evidence folder. No live project changes, paid generation, engine launches, or commits.

## Original preservation and current guards

-264 original PNGs retained under `originals/` with project-relative paths:3 bases,3 padded inputs,3 rotation sheets,24 full facings,15 walk sheets and216 game PNGs.
-8 current native captures preserved separately as `capture_originals`, allowing root's native checks to refresh those paths without losing originals.
-`before-manifest.json` uses the existing `files` / `protected_code_and_tools` / `protected_assets` schema. Fresh guards cover1020 other-form active PNGs (the previous12 forms, including60 current walk sheets) and624 current code/tool files. The reporting-tool extension is recorded explicitly as an authorized intended exception; all game `.gd`/`.tscn` code remains protected.
-`before-metrics.json`/CSV has363 records for the new line. `before-summary.json` gives grouped statistics; `palette-drift-and-magenta.json` records exact palette overlap; `canvas-and-source-outline-summary.json` gives geometry/outline diagnostics.
-20 main contact PNGs: nine original game-facing/source-facing/walk sheets, six full2x or game3x contacts with exact labeled facings and approved-base references, and five Fusern full2x source-walk contacts.

## Whole-image brightness before

Mean luminance is .299R+.587G+.114B over painted pixels; saturation is mean HSV percent.

| Form | Base luminance | Base saturation% | Full-facing spread | Game-facing spread | Source-walk spread | Game-walk spread |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Fusern |71.86|56.01|35.53|37.76|26.79|31.92|
| Slagglass |46.46|32.09|13.53|14.75|18.23|25.08|
| Vitrecrag |54.37|51.72|3.73|3.52|31.67|33.30|

Vitrecrag's still means look consistent while its walks do not; evaluating only the8 stills would miss the large motion fade. Fusern's appearance drift is localized strongly in the shell, and a whole-body average would conceal material-role mistakes.

Outside-base exact RGB share: Fusern55–74%, Slagglass6–15%, Vitrecrag34–39%. No magenta case, half-transparent pixel, or full/walk source-canvas edge contact was found. Canvases remain128,144,160 pixels for full facings/source walk frames, and42,48,53 pixels for game sprites.

## Fusern dark-brick source versus pale-orange facings

The approved source and s/se/w/sw facings are the useful dark-brick references. **SE** is the closest source reference: its dome geometry has the same1839 diagnostic pixels as the base, and matching brick colour proportions with minor one-channel RGB drift. **S** is the best front-facing reference. **W/SW** keep clear dark joints and source-like brick material with natural lighting differences.

The generated **E/NE/N/NW** views change the shell into broad light-orange plates with pale joints. NW is the strongest failure and has missing/suppressed portions of internal seam detail. Many join coordinates remain in the other pale views, so local RGB role correction can restore dark-mortar contrast without changing the silhouette. A global brightness/palette pass does not by itself prove brick-material restoration.

`fusern-shell-before-metrics.json`/CSV and49 source diagnostic masks quantify this separately. The fixed ROI is the upper52% of the original painted bbox, excluding the external silhouette edge. It is a **comparable upper-dome diagnostic, not semantic segmentation of the whole shell or every brick**. It excludes eyes/legs and most gray lower armor. Dark L<=60 pixels are a joint-or-shadow measure, not a claim to count exact mortar topology.

| View | Dome mean | Bright warm-orange L>=130% | Pale warm-orange L>=165% | Dark joint/shadow L<=60% |
| --- | ---: | ---: | ---: | ---: |
| Approved base |88.49|7.61|1.58|19.25|
| S |89.85|9.68|1.12|19.63|
| SE |88.23|7.61|1.58|19.25|
| E |136.33|78.36|25.29|6.14|
| NE |120.35|51.66|22.82|8.40|
| N |130.47|61.97|26.33|2.05|
| NW |148.64|84.13|43.31|2.37|
| W |79.96|0.27|0.00|21.58|
| SW |84.46|2.26|0.00|20.84|

NW's one light-orange colour [252,161,82] covers43.31% of this dome versus the base's most-common brick [191,96,53] covering15.99%. The original hot cracks are narrow; the pale version turns hot colour into most of the dome. Protect the lower gray rim, face/eyes and legs during shell-role work, and preserve the true small hot cracks rather than darkening an entire pale-colour class blindly.

## Reusable read-only shell evaluator

Staged tool: `../candidate-tools/audit_fusern_shell.py`.

```text
python audit_fusern_shell.py --before-audit <this source-audit folder> --image-root <candidate project tree or live project> --output <explicit review folder>
```

It compares actual saved candidate/installed PNGs against fixed original ROIs, checks original-source alpha/canvases, and writes CSV/JSON/README plus separate dark-original S/SE/W/SW and pale-original E/NE/N/NW comparisons, full base+8 grids, and five source-walk comparisons. It never edits source art or calls generation/the engine. It evaluates121 Fusern records:49 full source/base records plus72 game records. Original-to-original validation passed; its outputs are under `shell-evaluator-original-validation/` and are **tool validation, not candidate or installed after proof**.

## Other visible cautions

Slagglass south walk f2 has a detached3-pixel full-source component bbox[81,28,83,30]; it is near an upper crest/plate tip and needs visual judgment before any alpha-cleanup exception. Some small Slagglass leg/tip islands come from shrinking thin existing geometry, so do not delete all tiny components.

All base/rotation/source art is retained. Use named forms when rebuilding; bare slicer/builder runs overwrite other repaired arena art. Palette correctness and mean spreads cannot prove anatomy consistency or replace missing brick geometry. Preserve source shapes and report any specifically authorized exception rather than silently making a broad redraw.
