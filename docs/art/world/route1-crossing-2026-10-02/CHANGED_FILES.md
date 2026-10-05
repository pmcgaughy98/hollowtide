# Exact files for the October 2 river crossing

## Latest bridge-peg and river-current refinement

- Modified `scripts/route1_crossing.gd`: repaired sibling bridge preload; masked water surface, scene-driven texture current and moving highlights.
- Added `assets/sprites/world/route1_crossing_2026_10_02/river_bridge_peg_fixed.png`, `river_water_native32.png` and `river_flow.gdshader`, with two PNG import files and shader UID.
- Updated `docs/AI_COLLABORATION.md`, `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`, and this archive's `README.md`, `CHANGED_FILES.md`, `manifest.json` and `source_checks.json`.
- Added `peg-and-river-flow/` with the original and installed bridge, exact source snapshots, prompt/input/mask/result/receipts, shader/water source, actual river animation captures and GIF, walk/pixel/hash checks and archive manifest. [Full record](peg-and-river-flow/README.md).

## Latest bridge-support and city-landing refinement

- Modified `scripts/route1_crossing.gd`: sibling bridge preload and the city landing's native soil/turf surface, taper and small corner rounding.
- Added `assets/sprites/world/route1_crossing_2026_10_02/river_bridge_refined.png` and its Godot `.import` metadata.
- Updated `docs/AI_COLLABORATION.md`, `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`, this archive's `README.md`, `CHANGED_FILES.md`, `manifest.json` and `source_checks.json`.
- Added `bridge-abutment-refine/` with before/installed sources, original/prepared/accepted/rejected art, exact prompts, estimates and task receipts, frame captures, pixel checks, verification and archive hash manifest. [Full record](bridge-abutment-refine/README.md).

## Latest completed-corner and road-junction correction

- Modified `scripts/route1_crossing.gd`: complete bridge image and foreground registration; 48px entrance tapering to 26px; native pixel union with the existing lane, exact soil texture phase and border colors.
- Added `assets/sprites/world/route1_crossing_2026_10_02/river_bridge_complete.png` (288x112).
- Added `assets/sprites/world/route1_crossing_2026_10_02/path_soil_native32.png` (approved unchanged 32px source copy).

Updated `docs/AI_COLLABORATION.md`, `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`, and this archive's `README.md`, `CHANGED_FILES.md`, `manifest.json`, `source_checks.json`. Added `complete-bridge-junction/` containing sources, prompts, task/estimate receipts, final and rejected images, frame captures and verification. [Exact revision and file manifest](complete-bridge-junction/README.md).

## Latest bridge/road correction

Only `scripts/route1_crossing.gd` changed in the game: centered bridge/rail, connected and rounded crest road, matching soil/edging, attached grass shoulders and removal of the western dirt fragment. No raster asset was altered.

Coordination records updated: `docs/AI_COLLABORATION.md`, `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`, this archive's `README.md`, `CHANGED_FILES.md`, `manifest.json`, and `source_checks.json`. Added `bank-road-fix/` with exact before/installed helper source, manifests, verification, capture receipt and four JPGs. [Complete correction file list](bank-road-fix/README.md).

## Initial crossing files


## Runtime

- Modified `scenes/first_route_prototype.tscn`: added the RiverCrossing child/script; original authored terrain and existing nodes retained.
- Modified `scripts/first_route_prototype.gd`: expanded camera limits and regional framing, region readout, three interactions and field-note discoveries; updated two outdated dispatch directions.
- Added `scripts/route1_crossing.gd`: surrounding terrain, grassy levee, bridge rendering/rail depth, river/world boundaries, entrance and city-arrival props.
- Added `assets/sprites/world/route1_crossing_2026_10_02/river_bridge.png`: prepared transparent bridge still.
- Godot may create the normal import metadata and script UID beside the new assets/scripts.

## Coordination documents

- Modified `docs/AI_COLLABORATION.md`: new completion entry above the retained history.
- Modified `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`: completed crossing and current remaining work.
- Added this archive under `docs/art/world/route1-crossing-2026-10-02/`:
  - `README.md`, `CHANGED_FILES.md`, `manifest.json`, `source_checks.json`.
  - `bridge_prompt.txt`, `bridge_receipt.json`, `bridge_rd_original.png`.
  - `first_route_prototype.before.gd.txt`, `first_route_prototype.before.tscn.txt`.
  - `first_route_prototype.gd.installed.txt`, `first_route_prototype.tscn.installed.txt`, `route1_crossing.gd.installed.txt`.
  - `review/verification.json`, `review/capture_archive_receipt.json`.
  - Seven review captures: `verified_levee.jpg`, `verified_bridge.jpg`, `verified_city.jpg`, `verified_board.jpg`, `verified_return_landing.jpg`, `verified_report_choices.jpg`, `verified_full_report.jpg`.

This list describes this implementation pass, not the checkout's other existing changes.
