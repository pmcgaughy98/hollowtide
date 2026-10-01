# Hollowtide Walk Cycle Forge: Gemini skill

Built from a downloaded Opal graph by `tools/export_opal_forges.py`. The raw graph remains in `../opal-export/`.

Includes the saved 2026-09-30 Generate prompt and input hints from [the verified revision](../records/character-two-tiers-2026-09-30/verified-prompt-record.json). Checked after reopening in Opal; no generation-quality claim. This is a merged instruction export, not a fresh live app backup.

**Skill name to use in Gemini:** `walk-cycle-forge`

## What you give it each run

- **Walk Cycle Brief:** text or an image. MODE NEW or COMPLETE; DIRECTION RIGHT, LEFT, DOWN or UP; KIND OVERWORLD (default 32x32 chibi cells, about 30-pixel height); FRAMES 4 (default 2x2 F0,F1 / F2,F3) or FRAMES 8 (4x2 F0-F7). COMPLETE must list KEEP and MISSING slots. Attach the approved exact-direction map sprite or partial walk sheet. Keep the reference's identity, outfit and measured size across directions; do not force the old teal/goggles courier. LEGACY ADULT only when explicitly preserving an approved older full-body sprite.
- **Character Reference:** an image you attach. Upload the approved overworld standing sprite for this direction, or the partial sheet for MODE COMPLETE. A 4-direction standing sheet is also usable with DIRECTION specified. Use the actual map sprite, not a waist-up dialogue portrait. Original KEEP cells will be retained during later asset assembly.

## Model

- Generate Walk - Four or Eight Frames v2: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Walk Cycle Brief], [Character Reference] in my message. Use them exactly as described below.

Create exactly ONE Hollowtide walk-cycle sheet from Character Reference and Walk Cycle Brief. Animate ONE direction per run: RIGHT, LEFT, DOWN or UP (default RIGHT). Use the approved exact-direction OVERWORLD standing sprite when available. A multi-direction reference supplies identity, but select the requested view rather than mixing views. Preserve face, hair, clothing colors, equipment, accessory sides, outline and camera. Never add goggles or a costume absent from the chosen identity. An adult dialogue bust is not a walk reference: derive and approve its small overworld standing sprite in Character Model Forge before this run.

SCALE: default KIND OVERWORLD, 32x32 logical square cells, chibi proportions about 2.5-3 head heights, approximately 30 logical pixels standing height, matching the approved small map identity. Use the same measured head size, body height and hip origin for DOWN, UP, LEFT and RIGHT; never enlarge side views. Hips stay around x=16; boot bottoms share y=30; leave at least one logical pixel above hair and below boots and keep all equipment inside each cell. The brief may explicitly request LEGACY ADULT and provide its approved full-body reference; then preserve that source's established adult scale (default 64x64 cells, 36-pixel visible height, six-pixel margins). Do not silently rescale or replace an existing game sprite.

MODE AND FRAME COUNT: MODE NEW creates all requested poses. MODE COMPLETE fills an existing incomplete sheet, using KEEP and MISSING slots stated in the brief. FRAMES 4 is the default, and FRAMES 8 is optional; keep one count and one layout for the whole run. Preserve kept cells as closely as the model can and draw missing poses to match them. AI does not guarantee identical kept pixels, so extraction later retains original approved cells and reviews the additions. If the sheet needs more missing poses than fit in this run, produce one clearly specified continuation sheet; do not cram extra poses into the cells or duplicate contacts as filler.

FOUR-FRAME DEFAULT: 2 columns x 2 rows, four equal square cells, logical atlas 64x64 for 32x32 cells. Read F0, F1 / F2, F3. F0 near foot forward CONTACT and far foot behind. F1 other foot PASSES under hips with a naturally bent knee and feet close together. F2 opposite foot forward CONTACT, visibly different from F0. F3 opposite PASSING pose, visibly different from F1, connecting back to F0. Arms counter-swing. In DOWN/UP, left and right legs alternate clearly; in side views, near and far boots differ by overlap and shading. Both contacts and both passing poses are required. No four copies of the same wide stride.

OPTIONAL EIGHT-FRAME: FRAMES 8 gives 4 columns x 2 rows of equal square cells. Logical atlas 128x64 for 32x32 cells, with total width twice height. Opal fixes this workflow to a square exported image: place the rectangular 128x64 logical atlas as a centered band in a 128x128 logical canvas, starting at y=32, with exact flat magenta above and below. Do not stretch the square cells to fill the canvas height. Later extraction crops only the rectangular band. Read F0-F3 top then F4-F7 bottom. F0 near-foot CONTACT; F1 weight settles DOWN over planted foot with trailing heel lifting; F2 opposite leg PASSES under hips; F3 rear toe PUSHES OFF while swinging knee lifts; F4 opposite CONTACT; F5 opposite DOWN; F6 opposite PASSING; F7 opposite PUSH-OFF returning into F0. Eight distinct anatomically valid poses, not contact-only floating or shifted copies.

GROUNDING: walk in place; Godot supplies travel. At least one boot plants on the shared baseline in every frame. Stable torso/hip origin, natural knee bends, body bob at most one logical pixel for chibi (at most two for explicit legacy adult). No hovering, sliding feet, broken knees, repeated peak strides, direction changes or perspective/height changes. At full size the last pose must loop to F0. Four-frame starting playback about 6-8 fps; eight-frame about 8-10 fps, adjusted later for map speed. Hair and satchel follow subtly without changing their design.

STYLE AND CELLS: one consistent logical pixel grid and compact reference palette; crisp dark outline and deliberate clusters. No blur, smooth gradients, antialiasing, smeared limbs, onion skins or interpolated transparency. Exact flat #FF00FF outside each opaque character; never magenta inside the character. No gutters, borders, grid lines, labels, lettering, scenery, shadow or extra figures. Respect the chosen cell margins; do not crop any hair, bag or boot. Return ONE image only after checking requested direction, frame count, gait phases, identity, equal scale and foot baseline. Logical size is a target, not a guarantee of native pixels, transparency or automatic game import.

 WALK CYCLE BRIEF: [Walk Cycle Brief] CHARACTER REFERENCE: [Character Reference]
```
