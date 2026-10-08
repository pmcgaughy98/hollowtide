# Hollowtide next-session handoff, October 8, 2026

## Start here

Project: `C:/Users/pmcga/dev/hollowtide`. This is the active Godot arena-fighter project, not the stale OneDrive copy. Earlier menu-only, creature-paused and Vitrecrag-shelved notes have been superseded by Preston's later requests.

Read, in order:
1. This handoff.
2. Project `AGENTS.md`, `CLAUDE.md`, and the latest top entries of `docs/AI_COLLABORATION.md`.
3. `docs/creatures/arena-material-consistency-2026-10-08/README.md` and `final-state-check.json`.
4. `docs/creatures/arena-oxbowarchon-2026-10-08/README.md`, `docs/creatures/arena-starward-2026-10-08/README.md`, `docs/creatures/slagglass-redo-2026-10-08/README.md`, and current `tools/arena/build_small.py`.

Newest direct user decisions and live shared work take precedence over outdated handoffs. Inspect current Git status before writing. Do not commit, reset, discard, or overwrite Claude's concurrent changes.

## User requests completed

Preston asked to refine the new Slagglass and Preostmar/Oathfen/Oxbowarchon line, especially Oxbowarchon's overly pale green, closer to its original look and signature card. Then: include the newly added Punchybuns line. All seven forms are installed: Slagglass, Preostmar, Oathfen, Oxbowarchon, Punchybun, Sparkjab, Starward.

- 595 active PNG changes: 56 full facings, 35 five-direction source walk sheets, 504 game PNGs.
- Source alpha bytes, canvases, poses, feet and facing assignments are exact. Current per-form game sizes remain intact.
- Slagglass retains the newly approved beetle-growing-a-kiln design; orange mortar replaces yellow mid-dome walk flashes. Do not restore the old clawed form.
- Preostmar/Oathfen walks use darker approved jade instead of white/mint flashes.
- Punchybun/Sparkjab/Starward keep each approved cream-fur/pink palette.
- Oxbowarchon keeps retake A's approved silhouette and pose, but pale jade is mapped to eight exact darker jade colors from its original front. Charcoal body, gold and saturated rails stay distinct.
- No paid generation, game-code edit, setting change or commit by Codex.

## Essential palette and pipeline protection

Oxbowarchon's raw arena base at `docs/creatures/arena-starters-2026-10-07/forms/oxbowarchon.png` remains the PALE raw take. It is not the current color authority. Its explicit corrected reference is:
`docs/creatures/arena-material-consistency-2026-10-08/palette-reference/oxbowarchon-dark-jade.png`
with selection recorded in `palette-reference/references.json`.

Original reference: `assets/sprites/creatures/oxbowarchon.png`.
Signature card, unchanged: `assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/style_matched/titlecard.png`.

Do not reslice raw rotation sheets over corrected full facings. Do not run bare `build_small.py`, which rebuilds all forms. Named-form rebuilds are safe from corrected full facings/source walks. The current builder uses per-form SCALE and `resample` for many forms, rather than always shrinking by exactly three. Do not use the older reporter's hardcoded one-third pipeline to validate current sizes.

Current files:
- Full facings: `assets/sprites/arena/<form>/{s,se,e,ne,n,nw,w,sw}.png`.
- Five 4x2 source walk sheets: `docs/creatures/arena-starters-2026-10-07/walk/<form>_<s|se|e|ne|n>_sheet.png`.
- Game loads `assets/sprites/arena/<form>/small/`; NW/W/SW walks are exact derived mirrors.
- New deterministic helpers: `tools/arena/refine_arena_materials_20261008.py`, `tools/arena/report_arena_materials.py`.
- Existing builder/downscale/normalizer/reporter behavior was not edited.

Reproduce CANDIDATES only, from preserved sources, without reinstalling active art:
```text
python tools/arena/refine_arena_materials_20261008.py --workspace docs/creatures/arena-material-consistency-2026-10-08
```
Optional `--forms` limits the selection. Output is inside the ignored review archive's `source-audit/candidate-project/`. It does not install into the live arena. Inspect candidates before any install.

## Evidence and remaining visual limits

Archive: `docs/creatures/arena-material-consistency-2026-10-08/`.
- `installed-files.json`: every changed active path and new helper/capture/documentation paths.
- `source-audit/originals/`: 620 original art PNGs. Reference copies and earlier native captures are also preserved.
- `review/contacts/`: before/after game-size facing and source-walk contacts.
- `review/walk-previews/`: animated before/after previews.
- `review/before-after-facings.md`: brightness, saturation and color count per facing.
- `review/before-after-spreads.json`: full, game and walking spreads.
- `review/consistency-check-summary.json`: 847 records; 168 exact mirrors; 504 exact current-pipeline game PNG checks; all 1190 other-fourteen arena assets unchanged at verification.
- `native-verification.json`, `native/`: actual logs, process exits, timestamps, screenshots and prior-capture backups.
- `evidence-manifest.json`: archive hashes.

All full/game STANDING facing brightness spreads are under 8. Game WALK spreads remain: Slagglass 8.12, Preostmar 9.84, Oathfen 9.26, Oxbowarchon 5.14, Punchybun 5.96, Sparkjab 10.71, Starward 4.87. Do not claim every walk is under 8 or that original generated pose/material-pattern variations have been eliminated. This was deterministic material refinement, not an anatomy redraw. Further refinements should target visible defects rather than flatten every shade to equal averages.

Slagglass' chosen raw turn-based front is `assets/sprites/creatures/slagglass_redo_2026_10_08/slagglass_front.png`. Its turn-based resource still intentionally uses the OLD matched front/back because a new matching battle back was not made. Do not switch only its front during arena work.

## Verification boundary and concurrent code

Final Godot 4.7.2 import exited 0, clean. Native `arena_backline_check.gd`, `arena_protector_check.gd` and `arena_vitrecrag_check.gd` exited 0, zero script errors, with 23 fresh verified 1152x648 stills. Backline/protector logs were clean. Vitrecrag-line check logged a shutdown ObjectDB/resource leak. Initial import diagnostics were retained separately.

After those checks, `scripts/arena/arena_prototype.gd` changed externally. Codex read and preserved it without editing. At the final recorded check, all verified art and other arena assets were still exact; the other 653 existing code/tool/settings guards were unchanged. Evidence applies to the earlier verified script hash, NOT the later revision:
- Tested/reported hash: `859fa4b33cc85929fbbed7b565f45e6b78afaaa5522b74f842ccb7f7df435d38`.
- Later recorded hash: `9e965f302560c03833c258ff177f485edeba00a5533ba63eab39ccec5c3121b4`.
- Details: `final-state-check.json`; latest recorded bytes and Git-HEAD diff in `concurrent-code/`.

Those hashes are historical, not an assumption about the next session's live code. The later diff includes stage-specific kit/control work and comments calling Oxbowarchon Electric rather than older Bloom notes. Do not resolve essence/kit authority in an art pass or silently restore older rules; read the latest live data and Claude handoff first.

## Next justified actions

The requested seven-form installation is complete. First sync with the live project and latest Claude work, inspect the installed contacts/GIFs, and rerun current Godot import/relevant arena checks if validating the newer code revision. Preserve prior capture files before checks overwrite their output names. Follow Preston's next specific target; do not restart the completed palette pass, expand into world/menu work, or spend Retro Diffusion credits automatically.

Engine: `C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe`.
Python used: `C:/Users/pmcga/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Old work/reproduction staging: `C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/arena-oxbowarchon-slagglass-consistency-2026-10-08/`.

No credentials belong in a handoff. Paid uploads/generation require Preston's explicit approval for the specific work. Existing authorization for reversible local sprite refinement does not require repeated confirmation.
