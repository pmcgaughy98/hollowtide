# Hollowtide Character Model Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Craft custom pixel art RPG character models from your unique vision.

**Skill name to use in Gemini:** `character-model-forge`

## What you give it each run

- **Character Brief:** text or an image. Provide a detailed description of your character.
- **Identity Reference (NONE for new):** text or an image. MODE NEW: type NONE. MODE REDRAW: upload the approved exact character image. This reference governs identity and costume, not the world style.
- **Style Reference:** an image you attach. Upload an image defining the visual style.

## Model

- Generate Standing Character v1: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Character Brief], [Identity Reference (NONE for new)], [Style Reference] in my message. Use them exactly as described below.

Create one Hollowtide overworld CHARACTER candidate from Character Brief. Follow these rules and the linked inputs below. MODE NEW makes an original person; MODE REDRAW preserves the supplied exact character identity. OUTPUT SINGLE gives one full-body neutral standing pose in DIRECTION (default DOWN). OUTPUT TURNAROUND gives four standing views in one 2x2 sheet ordered DOWN, UP / LEFT, RIGHT. Do not generate walking frames.

REFERENCE ROLES: Identity Reference is optional for NEW; NONE means no prior identity. For REDRAW it governs face, hair, clothing, equipment, silhouette and side-specific details. Style Reference governs pixel finish and projection only. A creature anchor must never transfer animal anatomy, armor or Ember colors to the person. A world screenshot is composition/projection reference, never art to copy.

SCALE: default64x64 logical cells and36logical pixels visible standing height, matching the current courier at gameplay scale. For TURNAROUND hold exactly the same height, head size, foot baseline and shared cell origin across all views. Side views must not grow. Adult anatomy, approximately5.5-6head heights, capable grounded posture and readable face; no oversized child head or chibi. Use consistent top-down three-quarter overworld projection with modest head/shoulder tops visible, not an isometric diamond or a flat battle portrait. Both feet naturally planted, arms relaxed, hands clear of torso, no lifted knee. Keep outfit and satchel on their real anatomical side, do not mirror asymmetric designs.

FINISH: original inland river folklore RPG, practical courier/work clothes; Cinderhide-quality crisp dark silhouette outline, selective interior outlines, grouped planes, deliberate clustered shading, compact local palette about20-36colors, warm upper-left daylight and restrained cool shadows. Use individual material ramps, not one global palette or all Turbo Green. Never render smooth painted/vector shading, blur, noisy dithering or mixed pixel sizes.

BACKGROUND: pure flat #FF00FF everywhere outside the person; opaque pixels and stepped color clusters only. Keep entire hair, hands, bag and boots at least6logical pixels from cell edges. No floor shadow, scenery, UI, lettering, frame labels or second character in a cell. Check identity, directional costume consistency, even height/baseline and readable joints before returning ONE image. Logical size is a drawing target; do not claim exported pixels, transparent PNG, rig layers or automatic Godot import.

 character_brief: [Character Brief]

identity_reference: [Identity Reference (NONE for new)]

style_reference: [Style Reference]
```
