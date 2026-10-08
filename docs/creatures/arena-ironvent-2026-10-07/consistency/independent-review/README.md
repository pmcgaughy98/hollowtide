# Independent Ironvent-line visual review, October 7, 2026

Reviewed the three approved base takes, 24 source facings, all 192 source walk frames, three candidate still contacts, three candidate walk contacts, and all 192 actual candidate small-walk frames at game size x3. The three all64 PNGs here read the saved candidate small files, rather than predicting a resize. No live assets, game code or paid service were touched by this review.

## Material decision

The current candidates pass visual review for integration. Charcoal bodies remain dark, the armor keeps its gray/brown stone ramp, and vent slots retain orange with pale approved hot highlights. There is no new yellow-vent substitution or orange body tint. Cinderhide south limbs and Clinkerhide south chest become clearer. Ironvent's gray armored head remains gray; it should not be forced black by historical front/back sprite discussion, because the approved arena base defines this task. Fine RD plate-grain noise remains in Ironvent walks, and original per-frame anatomy variations remain in all three. This correction does not redraw plate topology or claim all animation design drift vanished.

Low whole-frame saturation on south armor partly reflects hidden vent area. The normalization is acceptable in actual images, but brightness/saturation averages alone are not proof of correct material regions. The exact own-base palette and deterministic transform are useful safeguards alongside visual inspection.

## Clinkerhide curl cleanup

Source sheet is576x288, eight144x144 cells. Frames1/2/3 have the generated thin curl to the right/above the crest; frames5/6/7 have it to the left. Frames0/4 are control frames and remain literal. The staged manual mask removes270 positive-alpha pixels (43/50/27/55/52/43 respectively). It retains real crest peaks, all lower head/body/feet, canvas dimensions and foot rows. Every unmasked RGBA value stays exact.

The root reviewed the red mask and before/after preview and approved this artifact cleanup, then applied the proposal to the W candidate and rebuilt small sprites. My subsequent all64 Clinkerhide contact review shows the unwanted curl gone without visible real spike/body/foot loss. This is an explicit alpha/support change; never call the repaired sheet alpha-exact to the original. All removed local/sheet coordinates, original/input RGBA and unchanged controls are in `clinker-curl-review/proposal/curl-removal-proposal.json`. The tool requires explicit preserved source/input/output paths, so it can reproduce from originals without re-erasing a repaired live image.

## Native check boundary

This review did not launch Godot. The root must perform the requested import/runtime check and inspect actual captures before claiming verification. `arena_rocks_capture.gd` writes ten existing PNG names directly into `docs/creatures/arena-ironvent-2026-10-07/`; preserve them with hashes before running. Renderer-enabled execution is needed for images, in a hidden owned child with bounded wait. The debug script covers three stage matches and Furnace Roar/rocks/slams, not every facing or walk frame. Preserve `.gd`/`.tscn`/project config and all other creature art, and distinguish script errors from existing import/shutdown diagnostics.
