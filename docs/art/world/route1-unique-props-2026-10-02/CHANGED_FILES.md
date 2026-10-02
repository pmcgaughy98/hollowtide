# Exact project changes for this pass

October 2, 2026. This reports only the complete-roof, individual-prop and regional-synthesis pass. It is distinct from the full dirty checkout and earlier walking/creature/terrain work.

## Existing runtime and shared documents

| File | Action | Change |
| --- | --- | --- |
| `scenes/first_route_prototype.tscn` | Modified | New prop texture references; complete hall offset; two ferry tie-offs and their small foot collisions. All terrain cells and existing quest sites preserved. |
| `scripts/first_route_prototype.gd` | Modified | Only camera offset changes from (0,-48) to (0,-84) to frame the complete roof. |
| `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md` | Modified | Current implementation, geography decisions, verification and remaining work. |
| `docs/AI_COLLABORATION.md` | Modified | Latest current-state paragraph; prior history preserved. |
| `docs/world/route1-regional-synthesis-2026-10-02.md` | Added | Existing Hollowtide design and St. Joseph research combined with supplied maps and native-tree reference. |

## New runtime images

All files below are under `assets/sprites/world/route1_rd_2026_10_02/`. Each PNG also has a new Godot `.png.import` sidecar. The 27 images match the archived prepared copies and hashes.

- `bank_reeds_1.png` and `bank_reeds_1.png.import`
- `bank_reeds_2.png` and `bank_reeds_2.png.import`
- `bank_reeds_3.png` and `bank_reeds_3.png.import`
- `bank_reeds_4.png` and `bank_reeds_4.png.import`
- `bank_reeds_5.png` and `bank_reeds_5.png.import`
- `bank_reeds_6.png` and `bank_reeds_6.png.import`
- `bank_shrub_1.png` and `bank_shrub_1.png.import`
- `bank_shrub_2.png` and `bank_shrub_2.png.import`
- `bank_shrub_3.png` and `bank_shrub_3.png.import`
- `bank_shrub_4.png` and `bank_shrub_4.png.import`
- `bank_shrub_5.png` and `bank_shrub_5.png.import`
- `bank_shrub_6.png` and `bank_shrub_6.png.import`
- `bank_shrub_7.png` and `bank_shrub_7.png.import`
- `bank_shrub_8.png` and `bank_shrub_8.png.import`
- `cottonwood_bank_bend.png` and `cottonwood_bank_bend.png.import`
- `cottonwood_east.png` and `cottonwood_east.png.import`
- `cottonwood_north.png` and `cottonwood_north.png.import`
- `cottonwood_office_grove.png` and `cottonwood_office_grove.png.import`
- `cottonwood_ridge.png` and `cottonwood_ridge.png.import`
- `cottonwood_south.png` and `cottonwood_south.png.import`
- `cottonwood_west.png` and `cottonwood_west.png.import`
- `dispatch_hall_complete.png` and `dispatch_hall_complete.png.import`
- `ferry_tieoff_full.png` and `ferry_tieoff_full.png.import`
- `ferry_tieoff_short.png` and `ferry_tieoff_short.png.import`
- `relay_post_empty_slot.png` and `relay_post_empty_slot.png.import`
- `retaining_wall_east.png` and `retaining_wall_east.png.import`
- `retaining_wall_west.png` and `retaining_wall_west.png.import`

## New review archive

All files below are under `docs/art/world/route1-unique-props-2026-10-02/`. Original inputs, rejected raw generations, exact preparation, prompts/receipts, map references, source hashes, before/after snapshots and final runtime evidence are retained.

- `prepared/bank_reeds_1.png`
- `prepared/bank_reeds_2.png`
- `prepared/bank_reeds_3.png`
- `prepared/bank_reeds_4.png`
- `prepared/bank_reeds_5.png`
- `prepared/bank_reeds_6.png`
- `prepared/bank_shrub_1.png`
- `prepared/bank_shrub_2.png`
- `prepared/bank_shrub_3.png`
- `prepared/bank_shrub_4.png`
- `prepared/bank_shrub_5.png`
- `prepared/bank_shrub_6.png`
- `prepared/bank_shrub_7.png`
- `prepared/bank_shrub_8.png`
- `prepared/cottonwood_bank_bend.png`
- `prepared/cottonwood_east.png`
- `prepared/cottonwood_north.png`
- `prepared/cottonwood_office_grove.png`
- `prepared/cottonwood_ridge.png`
- `prepared/cottonwood_south.png`
- `prepared/cottonwood_west.png`
- `prepared/dispatch_hall_complete.png`
- `prepared/ferry_tieoff_full.png`
- `prepared/ferry_tieoff_short.png`
- `prepared/relay_post_empty_slot.png`
- `prepared/retaining_wall_east.png`
- `prepared/retaining_wall_west.png`
- `raw/reeds_raw.png`
- `raw/roof_raw.png`
- `raw/shrub_raw.png`
- `raw/tree_left_raw.png`
- `raw/tree_tall_raw.png`
- `raw/wall_raw.png`
- `README.md`
- `reference/Screenshot_160.png`
- `reference/Screenshot_161.png`
- `reference/Screenshot_162.png`
- `reference/Screenshot_163.png`
- `reference/Screenshot_164.png`
- `reference/Screenshot_165.png`
- `reference/Screenshot_166.png`
- `reference/Screenshot_167.png`
- `review/bank.jpg`
- `review/bank_capture.json`
- `review/diagnostics.json`
- `review/door.jpg`
- `review/door_capture.json`
- `review/final_complete_rendered.jpg`
- `review/final_complete_rendered_capture.json`
- `review/final_diagnostics.json`
- `review/final_playtest.json`
- `review/final_post_details.jpg`
- `review/final_post_details_capture.json`
- `review/final_report_choices_visible.jpg`
- `review/final_report_choices_visible_capture.json`
- `review/final_river_approach.jpg`
- `review/final_river_approach_capture.json`
- `review/final_start.jpg`
- `review/final_start_capture.json`
- `review/historical_import_diagnostics.json`
- `review/interaction.jpg`
- `review/interaction_capture.json`
- `review/landing_details.png`
- `review/preservation_checks.json`
- `review/roof_complete_review.png`
- `review/start.jpg`
- `review/start_capture.json`
- `review/targeted_playtest.json`
- `review/unique_prop_review.png`
- `source/asset_manifest.json`
- `source/download_receipts.json`
- `source/edit_requests_and_receipts.json`
- `source/grok_rope_post_original.png`
- `source/landing_detail_manifest.json`
- `source/landing_preparation.py.txt`
- `source/map_reference_manifest.json`
- `source/native_preparation.py.txt`
- `source/reeds_original.png`
- `source/reference_notes.md`
- `source/research_ledger.json`
- `source/roof_original.png`
- `source/roof_receipt.json`
- `source/roof_request.json`
- `source/route_script_before.txt`
- `source/route_script_final.txt`
- `source/scene_before.txt`
- `source/scene_final.txt`
- `source/shrub_original.png`
- `source/St._Joseph_Creaturedex_Design.txt`
- `source/St._Joseph_History_And_Lore.txt`
- `source/tree_mask.png`
- `source/tree_original.png`
- `source/wall_original.png`
- `CHANGED_FILES.md`
- `owned_file_manifest.json`

No staging, commit, deletion, creature/menu edit, Gemini research or launch-setting change was made in this pass. Owned hidden review instances were stopped. Route 1 remains in progress; current terrain work is described in the regional synthesis.

Temporary preparation files are in the Codex task workspace `work/route_unique/`; the preparation used for runtime art is copied into this archive.
