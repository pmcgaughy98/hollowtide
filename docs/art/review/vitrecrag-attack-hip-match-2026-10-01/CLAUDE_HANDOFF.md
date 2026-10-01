# Vitrecrag attack hip-material finish

Preston requested middle/rear limbs rooted in a solid grey stone torso, like a rhino or elephant. This pass carries that installed idle correction through the existing Plate Lunge and Molten Glass poses. It preserves the beetle identity and each approved whole-pose animation.

## Every used image inspected individually

This is a texture pass on already-cut source poses. Original four-sheet sources, unused cuts and their selection remain as documented in the attack READMEs and builder tools. The current move resources are authoritative for playback order.

| Image | Source lineage | Individual pose/material observation | Native size | Pixel changes | Colors before/after |
|---|---|---|---|---|---|
| plate/load | sheet4_f01 | Early forward load; shell high, head down a little, existing wide legs planted. | 128x128 | 211 | 23/23 |
| plate/brace | sheet4_f02 | Head tucks down; body remains on the planted feet during the code draw-back/brace. | 128x128 | 195 | 20/21 |
| plate/launch | sheet4_f03 | Plate begins extending; body leans and roots follow that lean. | 128x128 | 201 | 21/22 |
| plate/contact | sheet4_f04 | Fully extended plate reaches low; shell tips forward and the rear loads upward. | 128x128 | 182 | 22/23 |
| plate/recover | sheet4_f05 | Plate retracts and torso rises; roots stay buried as it returns to idle. | 128x128 | 185 | 22/23 |
| glass/load | sheet2_f01 | Head lowers; loaded furnace remains inside the shell; legs stay planted. | 140x128 | 193 | 22/23 |
| glass/hole | sheet4_f01 | Head recessed, glowing front opening low; torso and hip roots descend with this pose. | 140x128 | 189 | 21/22 |
| glass/flood | sheet2_f02 | Raised shell glows orange during brace/strain; copper and furnace light are intentional. | 140x128 | 234 | 23/23 |
| glass/overload | overload.png | Pressure peak, mouth-glass bulge and hanging droplets; whole original overload pose preserved. | 140x128 | 234 | 25/25 |
| glass/overload_pour_a | overload.png + sheet2_f04 stream | Same pressure body; thick pouring strand and foot-level pool in phase A. | 140x128 | 234 | 25/25 |
| glass/overload_pour_b | overload.png + sheet1_f04 stream | Same pressure body; alternate flowing strand and pool in phase B. | 140x128 | 234 | 25/25 |
| glass/breakout | sheet2_f03 | Head/front opens with the first material stream; body settles out of the pressure peak. | 140x128 | 174 | 23/23 |
| glass/recover | sheet2_f05 | Head returns with cooling material at the mouth; torso returns toward the neutral stance. | 140x128 | 203 | 23/23 |
| glass/titlecard | exact visible overload crop at +9,+29 | pressure title-card close-up; same body and drip pose as overload | 120x93 | 234 | 25/25 |

All fourteen images face screen-right in the existing front three-quarter view. Decision for each: retain the original whole pose; correct only the recessed body and hip-root material. Near-middle hip uses the front's upper-left stone face, while deeper roots use its darker stone ramp. Carapace pixels, hot liquid, droplets, exterior outlines and alpha stay unchanged.

## Ordered sequence inspected again

Plate Lunge: 0: load (0.25s) -> 1: brace (1.3s) -> 2: launch (0.06s) -> 3: contact (0.32s) -> 4: recover (0.38s).

Molten Glass: 0: load (0.1s) -> 1: hole (0.35s) -> 2: flood (0.9s) -> 3: flood (1.1s) -> 4: overload (0.08s) -> 5: overload_pour_a (0.14s) -> 6: overload_pour_b (0.14s) -> 7: overload_pour_a (0.14s) -> 8: overload_pour_b (0.14s) -> 9: overload_pour_a (0.14s) -> 10: overload_pour_b (0.14s) -> 11: overload_pour_a (0.14s) -> 12: breakout (0.12s) -> 13: recover (0.25s).

The title card is outside these body-frame arrays. Its visible pixels match the overload crop at x+9/y+29, so it receives the same correction by exact pixel correspondence. Its 120x93 dimensions remain unchanged. Plate body frames stay128x128; Glass body frames stay140x128.

Re-analysis: the grey roots follow each frame's existing lean or lowered body; the shared overload body is consistent across the two pouring phases and title card. Original feet, head, furnace, plate extension and molten stream locations are untouched. Existing pose changes and intentional hot-shell brightness remain. This pass does not remove the underlying differences between the Opal poses and idle drawing, or claim to add missing motion.

## Saved files and repeatable preparation

Existing live style_matched PNG paths are updated, so no move-resource, scene, shader, timing, sound or camera edit is needed. Exact pre-edit PNGs are in before/plate and before/glass. manifest.json records the hashes, per-pose root coordinates and material regions. after_frames_4x.png shows every result; the two ordered strips show current frame order and authored holds. idle_entry_comparison_4x.png compares both entry poses with the updated idle.

To rebuild from the preserved originals into a separate review folder:

```text
python match_attack_hips.py --project C:/Users/pmcga/dev/hollowtide --sources before --output rebuilt
```

Do not run an older builder or finish pass straight over these textures: it would restore the old hip shading. If new source geometry or registration arrives, inspect each new pose and update its root coordinates before applying this recipe. For new Forge runs, use the current official front/back PNGs as material references; the untouched older OneDrive JFIFs predate this correction.

The per-pose and ordered static images were inspected and the production writer checks alpha, contour and protected carapace/heat pixels. No gameplay test or new image generation was run. Preston's visual review in battle remains pending.
