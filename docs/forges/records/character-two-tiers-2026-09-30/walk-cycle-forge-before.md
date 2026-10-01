# Hollowtide Walk Cycle Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Turn an approved character pose into a true eight-frame walk cycle, one direction at a time. Contact, passing, and lift poses stay aligned for Godot.

**Skill name to use in Gemini:** `walk-cycle-forge`

## What you give it each run

- **Walk Cycle Brief:** text or an image. Start with MODE NEW or MODE COMPLETE. Name one direction: RIGHT, LEFT, DOWN, or UP. For COMPLETE, list KEEP and MISSING frame slots F0-F7 and upload the partial sheet as Character Reference. Describe identity, palette, pose gaps, foot baseline, and matching on-screen size across directions. For the courier, preserve brown hair, brass goggles, teal jacket, tan trousers, boots, and satchel.
- **Character Reference:** an image you attach. Upload the character design reference sheet image.

## Model

- Generate Walk Frames — 2026-09-30: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Walk Cycle Brief], [Character Reference] in my message. Use them exactly as described below.

Create exactly ONE walk-cycle sprite sheet from the approved character reference and Walk Cycle Brief. Animate ONE requested direction per run: RIGHT, LEFT, DOWN, or UP. If none is specified, use RIGHT. The reference may be an old multi-direction sheet; preserve its character identity, clothing, palette, outline, proportions, and camera view, but invent missing in-between poses instead of copying repeated or broken poses. Keep the face, existing accessories, bag side, clothing, hairstyle, and body size the same in every frame. Never add goggles or a costume part absent from the approved reference.

MODE: Read MODE NEW or MODE COMPLETE from Walk Cycle Brief. NEW builds all eight poses from an approved character reference. COMPLETE takes an existing partial walk sheet in Character Reference; the brief names KEEP and MISSING slots F0-F7. Preserve approved cells as closely as the image model can; fill only missing contact, down, passing and push-off poses. Keep face, outfit, satchel side, palette, grid, body scale, viewpoint and foot origin consistent. AI cannot guarantee exact kept pixels, so the user compares them manually before import. If no mode is stated, use NEW.

DIRECTION SCALE: RIGHT and LEFT sheets must read at the same on-screen height and grounded footprint as DOWN and UP sheets for the same character, even if raw source canvases differ. Never enlarge the side-view body relative to the front/back body. Keep knees natural, feet planted, and poses distinct.

OUTPUT: One rectangular atlas with width twice its height: FOUR columns by TWO rows, exactly EIGHT equal SQUARE frame cells. Default64x64 logical cells (256x128 atlas) and36logical pixels visible adult standing height, unless the approved source and brief specify another consistent scale. Keep the approved top-down overworld projection. Read F0-F3 across the top, then F4-F7 across the bottom. One complete full-body character in the requested direction per cell. Share one pixel grid, torso/hip origin, body size, foot baseline, outline, palette, and lighting. No gutter, borders, grid lines, labels, text, scenery, ground shadow, or extra figures. Outside the character, every cell is exact flat #FF00FF magenta; do not use magenta in the character.

EIGHT DISTINCT WALK PHASES: F0 near foot forward CONTACT, far foot behind. F1 weight settles DOWN over that planted front foot, trailing heel lifts. F2 other leg PASSES under the hips with bent knees and feet close, never a wide split. F3 planted rear toe PUSHES OFF as the swinging knee lifts. F4 opposite foot forward CONTACT, visibly different from F0. F5 opposite weight-down. F6 opposite passing under the hips, visibly different from F2. F7 opposite toe push-off, connecting smoothly to F0. For front/back views, left and right legs swap clearly; for side views, distinguish near and far boots by overlap and shading. Every frame needs a new leg and arm pose, not a shifted copy of the same far stride. Arms counter-swing; hair and satchel lag subtly.

GROUNDING: Walk in place; Godot supplies map movement. At least one boot plants flat on the shared baseline in every frame. The body passes over the planted foot. No hovering, skating, sliding feet, duplicate poses, or held all-the-way-apart legs. Keep horizontal torso position stable and weight bob within 1-2 logical pixels. F7 must loop into F0. The order should play cleanly at 8-10 fps.

STYLE: Preserve the source's mature pixel-art style and native pixel scale. Crisp hard-edged clusters and a compact consistent palette. No blur, antialiasing, gradients, smeared limbs, onion skins, interpolated transparency, camera rotation, perspective change, or costume changes. Output one image only.

EDGES AND BACKGROUND: Every pixel is part of the opaque character or pure flat #FF00FF magenta. Any requested dust, fabric motion or glow is a solid stepped-colour pixel cluster, never a soft halo fading into magenta. Keep every hair tip, satchel, foot and motion accent at least 6 logical cells inside each frame edge. If an accent would cross an edge, draw it smaller instead of cropping it.

 WALK CYCLE BRIEF: [Walk Cycle Brief] CHARACTER REFERENCE: [Character Reference]
```
