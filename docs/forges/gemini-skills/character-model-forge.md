# Hollowtide Character Model Forge: Gemini skill

Built from a downloaded Opal graph by `tools/export_opal_forges.py`. The raw graph remains in `../opal-export/`.

Includes the saved 2026-09-30 Generate prompt and input hints from [the verified revision](../records/character-two-tiers-2026-09-30/verified-prompt-record.json). Checked after reopening in Opal; no generation-quality claim. This is a merged instruction export, not a fresh live app backup.

**Skill name to use in Gemini:** `character-model-forge`

## What you give it each run

- **Character Brief:** text or an image. Choose KIND PORTRAIT or KIND OVERWORLD, MODE NEW or REDRAW, and OUTPUT. PORTRAIT: SINGLE neutral waist-up adult bust, or EXPRESSIONS 2x2 NEUTRAL, HAPPY / SURPRISED, WORRIED. OVERWORLD: 32x32 chibi standing sprite, SINGLE with DIRECTION or TURNAROUND 2x2 DOWN, UP / LEFT, RIGHT. Establish a portrait identity first, then derive its map sprite. Describe the person without prescribing a different costume from the identity image.
- **Identity Reference (NONE for new):** text or an image. Upload the chosen person's identity image for PORTRAIT or OVERWORLD redraws. It governs face, hair, age, outfit colors, equipment and the real side of the satchel. For a wholly new identity, type NONE. To derive map sprites, upload the approved portrait. To make expressions, upload the approved neutral portrait.
- **Style Reference:** an image you attach. Upload approved Hollowtide pixel art such as Cinderhide to guide crisp outlines, clustered shading and material contrast only. Do not transfer creature anatomy or Ember colors onto the person. The character identity supplies the outfit palette.

## Model

- Generate Character - Overworld / Portrait v2: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Character Brief], [Identity Reference (NONE for new)], [Style Reference] in my message. Use them exactly as described below.

Create ONE Hollowtide character-art candidate. Read MODE, KIND and OUTPUT in Character Brief before drawing. MODE NEW designs an original person when Identity Reference is NONE; MODE REDRAW preserves the attached person's identity. If an identity image is attached, it governs identity even if the brief says NEW. KIND OVERWORLD and KIND PORTRAIT are separate output types; never combine them in the same image. Default KIND OVERWORLD, OUTPUT SINGLE. Do not generate walk poses in this Forge.

REFERENCE ROLES: Identity Reference governs the exact face, hair, age, skin tone, clothing, equipment, garment colors and anatomical side of accessories. A portrait can establish identity for its small map sprite; simplify it without changing who the person is. Style Reference governs pixel finish only. Cinderhide is a finish anchor, never a source of animal anatomy, horns, Ember colors or armor for a person. An exploration screenshot may guide map projection; do not copy its characters or artwork. Never force teal clothing, brass goggles or any other accessory absent from the chosen identity.

KIND OVERWORLD: small chibi map sprite, about 2.5-3 head heights with a large readable head and short torso and legs. Simplify the adult identity into clear outfit shapes; chibi proportion does not change their age. One 32x32 logical cell per standing view, visible height about 30 logical pixels and body width usually about 24; leave at least one logical pixel above hair and below boots, and keep every accessory inside the cell. Center the hips at x=16 and put the bottoms of the boots on y=30, using the same origin, head size, standing height and footprint in every direction. Top-down three-quarter map projection with modest head/shoulder tops visible. No flat battle view or isometric diamond. Feet planted, arms relaxed, no lifted knee. OUTPUT SINGLE gives DIRECTION DOWN, UP, LEFT or RIGHT (default DOWN). OUTPUT TURNAROUND gives exactly four equal square cells in a 2x2 sheet: DOWN, UP / LEFT, RIGHT; logical atlas 64x64. Front/back views must not shrink and side views must not grow. Preserve the real anatomical side of satchel and equipment; do not mirror asymmetric clothing. Use a compact local palette around 12-24 colors, crisp dark outline and flat clustered shading.

KIND PORTRAIT: adult waist-up dialogue bust on a 96x96 logical cell. Normal adult head/shoulder proportions, suggesting a body about six head heights tall; do not try to fit a full body on the portrait canvas. Three-quarter view turned toward the right by default, or the explicit DIRECTION in the brief. Face unobstructed and expressive; waist and lower torso end inside the canvas, with at least four logical pixels clear around the silhouette. Hair, collar, jacket, straps and equipment must match the identity. Full Cinderhide-level crisp pixel finish with deliberate material planes, selective interior outlines and a compact local palette about 24-40 colors. OUTPUT SINGLE gives one neutral bust. OUTPUT EXPRESSIONS gives exactly four equal 96x96 cells in a 2x2 sheet, logical atlas 192x192: NEUTRAL, HAPPY / SURPRISED, WORRIED. All four share identical body pose, camera, head position, framing, costume, palette and lighting. Change only eyebrows, eyes and mouth; no head tilt, arm pose or outfit change. No full-body or chibi figures in portrait mode.

HOUSE FINISH: original inland river folklore RPG; practical clothing and readable materials. Hard-edged whole-pixel clusters, dark stepped contour, warm upper-left daylight and restrained cool shadows. Keep the chosen person's local color ramps. Turbo Green is an HP/UI accent, not a mandatory character palette. No smooth painted/vector shading, blur, antialiasing, noisy dithering, semi-transparent edges or mixed pixel sizes. All cells use one consistent logical pixel grid, including faces and small accessories.

BACKGROUND AND SHEET: exact flat #FF00FF everywhere outside the character. No magenta in clothing or shadows. For a sheet, cells touch edge-to-edge with no gutters, borders, labels or grid lines; one person per cell. No floor shadow, scenery, UI, text or spare accessories. Output ONE image only. Check KIND, identity, view order, equal scale/baseline or portrait framing, and correct accessory sides before returning. Logical dimensions are drawing targets; do not claim native exported size, transparency, separated layers, rigging or automatic Godot import. New output remains a candidate until reviewed.

 character_brief: [Character Brief]

identity_reference: [Identity Reference (NONE for new)]

style_reference: [Style Reference]
```
