# Hollowtide Attack Animation Forge

[Open the live Opal app](https://opal.google/edit/1mcPSsql5N9rj53Nbg0FFqFEh-e39c_f-). This is the duplicate of the Idle Sprite Forge that Preston renamed. It now asks for an attack brief, an approved still sprite, and an optional partial action sheet.

## Output contract

One 3-column × 2-row sheet with six equal square **creature body** cells: F0 ready, F1 anticipation, F2 coil, F3 launch, **F4 contact**, F5 recovery. The current Godot battle code triggers damage and the separate target effect on the penultimate frame, so F4 aligns with that code. All cells retain the source view, species, grid, palette, outline, scale and baseline. The body sheet must not contain the free-floating slash or impact art.

## Ironvent Cinder Claw, first test

**Attack Motion Brief**:

> Ironvent; Cinder Claw; FRONT, facing right; MODE NEW. Use the approved 100×100 Ironvent front. A heavy, grounded claw rake from the near forelimb. Keep the rear foot planted as the torso twists and the shoulder loads. F0 matches the source ready pose. F1 draws the near claw back. F2 lowers the center of mass and flexes shoulder, elbow and wrist. F3 pushes from the hindquarters and sweeps the claw toward the foe. F4 is a distinct, widest claw contact pose; the separate slash and impact appear on the target here. F5 recoils toward the original stance. Preserve the face, ram crest, dorsal vent pattern, iron and coal palette, right-facing camera, four-limb anatomy and foot baseline. A small vent pulse can follow the exertion. No added armor, duplicate limbs, whole-body slide, static peak repeated across cells or baked slash effects.

**Approved Source Sprite**: upload `C:\Users\pmcga\dev\hollowtide\assets\sprites\creatures\ironvent.png`.

**Existing Attack Sheet**: enter `NONE`.

For **MODE COMPLETE**, upload an original partial sheet instead and state its layout and explicit KEEP and MISSING F0–F5 poses in the brief. Preserve approved cells as anchors, then add missing in-betweens. AI cannot guarantee pixel-exact copies of KEEP frames, so compare them against the input before accepting.

## Review gate

Download the original generated image, not a screenshot of Opal's review page. Flip through F0–F5 at nearest-neighbor zoom and at actual battle size. Reject changed viewpoint or anatomy, jumps in shoulder/wrist position, extra limbs, identical peak frames, moving cell origins, magenta fringe, or contact before F4. The existing `tools/convert_idle_sheet.py` is for 2×2 idle sheets and must not be used for this 3×2 action output. No attack sheet from the revised Forge has yet been generated or imported.

[Gemini's deep research task](C:/Users/pmcga/dev/hollowtide/docs/gemini-attack-animation-research-task.md) asks whether single-call sheets, per-pose edits, or artist-assisted in-betweens should become the long-term production method.
