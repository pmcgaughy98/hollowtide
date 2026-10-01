# Hollowtide Back View Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Create one anatomically faithful three-quarter rear battle sprite from an approved front. Preserve the creature’s shell volume, body-to-head structure, palette and pixel craft; inspect front and rear identity before use.

**Skill name to use in Gemini:** `back-view-forge`

## What you give it each run

- **Back View Brief:** text you type. Required. Name the creature and approved stage, state which way the body points in the battle, then describe rear volume, the shell/back-to-shoulder-to-collar-to-head transition, visible head placement, limbs, tail, asymmetrical markings and side organs. Say what earlier back attempts got wrong. For Vitrecrag: rounded walnut shell; shell ends before distinct shoulder and short collar; low beetle head faces away; orange furnace on correct right flank; avoid a roof, shingle staircase or shell plates becoming the head. Use species-specific details for other creatures.
- **Approved Front Sprite:** an image you attach. Required. Upload the exact approved FRONT sprite of the same creature and evolution stage. This is the source of truth for body shape, scale, limbs, markings, colors, outline and pixel density. Do not use a concept for a different form.
- **Rear Candidate (Review Only):** an image you attach. Optional prior back candidate for side-by-side human review only. This image is NOT sent to the image generator, because that caused it to copy incorrect shell plates and feet. Put the desired camera direction and pose in Back View Brief. The Approved Front Sprite remains the generator’s only visual source for anatomy and pixel style. You may leave this empty.
- **Style Anchor:** an image you attach. Optional Hollowtide pixel-art style reference, such as approved Cinderhide. Use it for pixel grid, cluster size, outline and shading only. Keep the creature’s anatomy, silhouette and colors from Approved Front Sprite.

## Model

- Render True Back Sprite — front-led 2026: Nano Banana (standard image model), aspect ratio 1:1
- Draft Review Note: Gemini Flash (text)

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Back View Brief], [Approved Front Sprite], [Rear Candidate (Review Only)], [Style Anchor] in my message. Use them exactly as described below.

HOLLOWTIDE BACK VIEW FORGE — FRONT-LED REAR RECONSTRUCTION
Generate exactly ONE three-quarter REAR battle sprite of the SAME approved creature and stage. The Approved Front Sprite is the sole visual design source. The Back View Brief states the camera angle and creature-specific anatomy. No prior rear candidate image is supplied to this image-generation step; a prior candidate may be displayed later for human comparison only. Do not create an evolution, mirror the front, or reproduce a previous back attempt.

BEFORE DRAWING: Identify rear, middle, shoulder, collar/neck and head in the approved front. Mentally rotate their connected volumes to the angle specified in the brief. Map each limb by role and attachment: hind, middle and front. Rotate those limbs, preserving the number, build, armor and toe design of each. Carry asymmetrical markings and side structures to the correct flank. Do not duplicate a foreclaw onto a hind leg, invent extra limbs, or repeat identical feet.



REAR CAMERA: Put the camera behind the rear end and a little above. The creature walks away toward the upper right. Hindquarters and hind legs are nearest the viewer and largest; the shoulder and head recede to the far upper right. See only a steep sliver of the side, never the long body profile. Keep the back of the head distinguishable from the shell or torso, but hide the face or show only a thin far-side sliver. Do not mirror the front or use a previous back candidate as design source.

VITRECRAG ANATOMY WHEN RELEVANT: The carapace is broad and walnut-like in volume, built from distinct staggered dark-plum armor slabs with orange rims. Each slab has its own lower overhang and shadow; the plates fold and stack instead of fusing into smooth round bands. Keep the shoulder/collar and smaller head as separate volumes beyond the shell. Carry the single furnace window to the correct right flank as a limited orange glow. Visible hind and middle feet are broad load-bearing pads, not copies of the front three-toed claws. Show only limbs visible from behind, and preserve their attachment positions and scale from the approved front. No new spike, tail flame or head flame unless the approved front actually has it.

PIXEL CRAFT: Match the approved front's palette, lighting, dark outline, resolution, deliberate coarse pixel clusters and level of detail. The optional Style Anchor can guide pixel technique only. Use one complete creature and a flat solid #FF00FF background outside the silhouette. No gradient, ground shadow, text, grid, extra creature, fine noise, soft painting, antialiasing, glossy 3D shading or magenta fringe.

HOUSE STYLE: Match the attached approved creature and Cinderhide's finish: a dark outline around the entire silhouette, about 20 to 36 colours, and shading in clean clustered shapes with very few lone single pixels. Match the approved creature's brightness; only its own glowing parts are brighter. Native grid: 128x128 for Vitrecrag and Oxbowarchon, 100x100 for every other creature.

EDGES AND BACKGROUND: Every pixel is either part of the drawing or pure flat #FF00FF magenta. Glows, flashes, auras, sparks and smoke are solid opaque clusters of stepped colours. Never let a glow, halo or soft edge fade into magenta. Keep every part, including tails and feet, at least 6 logical cells inside the canvas edge. If an effect would cross an edge, draw it smaller instead of cutting it off.

FINAL PRIVATE CHECK: Compare silhouette and body volumes; plate construction or species-specific back surface; shoulder/head separation; asymmetrical side organs; every leg and foot; palette and pixel scale against the approved front. Correct mismatches before output. Output only the image.

approved_front_sprite: [Approved Front Sprite]



style_anchor: [Style Anchor]

back_view_brief: [Back View Brief]
```

## Follow-up step 2: Draft Review Note

```text
Review status: CANDIDATE ONLY. This step has the written brief but does not inspect the generated pixels. Give a short human review checklist, with each item marked "needs visual check": true rear camera; matching body/head anatomy; correct left/right details; matching pixel grid, palette and outline. Never claim any item passed or that the image is approved or imported.

Objective: Write a brief professional review note stating that the generated sprite is a candidate for further evaluation. The note must explicitly reference the back view brief to provide necessary context for the review process.

Output Format: A concise, professional text-based review note. Keep all review items pending until a person inspects the generated image.

User Input / Context: [Back View Brief]
```
