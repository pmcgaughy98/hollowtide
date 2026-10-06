# Route 1 meadow refinement (Claude, 2026-10-05)

Preston asked Claude to refine Route 1 on top of Codex's work. This pass covers only the west meadow between the hometown and the River Road (`scripts/route1_approach.gd`, world x -768 to 0).

Problems found (`before_overview.png`): stepped lanes with right-angle corners, a diagonal lane ending in the open field, a 24 px grass gap between the meadow lane and the River Road at x 0, and twenty trees in near-grid rows.

Changes (`after_overview.png`):
- One winding lane from the hometown entrance (rows 496-528, unchanged) to the River Road (rows 176-208), drawn with Codex's exact 16 px soil tile and a darker, frayed border. The image is 792 px wide, so it runs 24 px past x 0 and closes the gap. New file `assets/sprites/world/route1_meadow_refine_2026_10_05/meadow_lane.png`; Codex's `route1_meadow_approach.png` is untouched and unused.
- Seventeen cottonwoods in seven groves that frame the lane, mixing all six variants and mirroring half; every trunk is at least 40 px from the lane centre and the hometown entrance is kept open. Trunk collision and canopy fade work as before.
- Thirty-four meadow tufts along the lane edges and at the groves' feet.
- `build_meadow.py` rebuilds the image and prints both layouts.

Checks: `tools/debug/route_walk.gd` steered the courier with the ordinary move actions from (-720, 504) to (19, 192) along the lane, zero stuck points (`walk_end_river_road.png`). `tools/debug/route_capture.gd` makes the overview and close views. No script errors. Not checked: the full quest trip, and the hometown-side return.
