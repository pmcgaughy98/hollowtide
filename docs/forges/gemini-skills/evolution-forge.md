# Hollowtide Evolution Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Grow approved Hollowtide creatures into distinct Stage II and III forms, then make true same-form rear sprites from their approved fronts.

**Skill name to use in Gemini:** `evolution-forge`

## What you give it each run

- **Evolution Brief:** text or an image. Paste one complete Stage II or Stage III brief. Begin with VIEW: FRONT for a new evolution, or VIEW: BACK for the approved same form's rear view. Generate only one view per run.
- **Previous Stage Front / Pose Guide:** an image you attach. For VIEW: FRONT, upload the approved front of the immediately previous stage. For VIEW: BACK, leave empty unless the brief explicitly labels this input POSE GUIDE; then upload a prior rear candidate for camera and body placement only. Species anatomy comes from Approved Evolved Front.
- **Approved Evolved Front:** an image you attach. For VIEW: BACK, upload the approved front of the exact same stage. Leave empty for VIEW: FRONT.
- **Style Anchor:** an image you attach. Optional: upload approved Cinderhide for pixel craft and material shading only. Do not borrow its anatomy, pose, or Ember colors.

## Model

- Render One Evolution View — 2026 production: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Evolution Brief], [Previous Stage Front / Pose Guide], [Approved Evolved Front], [Style Anchor] in my message. Use them exactly as described below.

Create exactly ONE image of ONE Hollowtide creature for the selected mode. Read Evolution Brief first; its first line must say VIEW: FRONT or VIEW: BACK. Use its stage name, anatomy, facing, temperament, palette and avoid-list. Never generate both views in one run.

VIEW: FRONT — Use Previous Stage Front as the immediately previous APPROVED form. Ignore Approved Evolved Front. Draw only the next Stage II or III front in the brief's requested three-quarter pose, with the face visible. Keep three lineage anchors: eye/face identity, one signature marking or structure, and the palette relationship. Rebuild head-to-body ratio, torso mass, limb structure, stance, and filled silhouette; the form must read as older and physically larger in the same frame. Move its weight into a new pose. Do not trace the predecessor, merely enlarge it, or attach armor, shoulder pads, heat sacs, props, extra spikes, or a glow to an unchanged body. For the Kithflare line keep four weight-bearing legs and narrow flush heat seams; no sacs or pads.

VIEW: BACK — Use Approved Evolved Front as this exact creature's identity, not its pose. The camera is behind the rear end and a little above; the creature walks away toward the upper right. Rear end and hind legs are nearest and largest. See the side only at a steep angle. Hide the head and face or show at most a thin far-side sliver. Never put the long body profile toward the viewer. Transfer each marking, plate and limb to its correct rear position; each visible limb keeps its own foot shape from the front. Match approved front scale, palette and baseline. Never mirror, evolve or redesign. If the brief explicitly labels Previous Stage Front a POSE GUIDE, copy only its camera angle, body placement and leg positions; all species anatomy and rendering still come from Approved Evolved Front and the brief.

RIG-READY — Keep the result one intact organism with readable head/neck, shoulder, hip, tail and limb roots; preserve near/far limb and layered shell overlaps. Do not draw artificial cut seams or detached rig parts. Hidden joint pixels must be authored after approval. For the Kithflare line, change gait, torso mass, limb leverage and tail counterweight between stages without becoming a dog or an armored parent. For the furnace-beetle line, preserve the small tucked head, six load-bearing legs, layered plates and correct-side orange-gold furnace. In BACK mode, do not invent a spike or flip a slab toward the head when its front reference points it rearward.

STYLE — Style Anchor is optional and controls only Cinderhide-quality craft: substantial dark contour, large coherent color clusters, stepped directional shading across material planes, restrained focal accents, and planted weight. Never copy Cinderhide anatomy, markings, or Ember palette into another species. Avoid pillow shading, parallel color bands, random single-pixel confetti, fuzzy edges, and floating contacts. Use a purposeful palette; no rigid color-count ceiling. Mature grounded folklore, never cute or toy-like.

HOUSE STYLE — Match the attached approved creature and Cinderhide's finish: a dark outline around the entire silhouette, about 20 to 36 colours, and shading in clean clustered shapes with very few lone single pixels. Match the approved creature's brightness; only its own glowing parts are brighter.

EDGES AND BACKGROUND — Every pixel is drawing or pure flat #FF00FF magenta. Glows, flashes, auras, sparks and smoke are solid opaque clusters of stepped colours. Never fade a glow, halo or soft edge into magenta. Keep every part, including tails and feet, at least 6 logical cells inside the canvas edge. If an effect would cross the edge, draw it smaller.

OUTPUT — Square 1:1 image on the approved same-form native logical grid. Default to 100x100 only when no approved reference or brief specifies another size; Vitrecrag and Oxbowarchon use 128x128; all other creatures use 100x100. One full-body creature, wholly in frame, contact feet on a stable baseline with at least three magenta cells below. Exact flat #FF00FF outside the creature; no magenta on it. No transparency, checkerboard, floor, baked shadow, frame, text, effects, second form, blur, gradients or subpixel detail. Output exactly one image and no text. If the required reference for the selected mode is missing, ask for it rather than inventing continuity.

previous_stage_front: [Previous Stage Front / Pose Guide]

approved_evolved_front: [Approved Evolved Front]

style_anchor: [Style Anchor]

evolution_brief: [Evolution Brief]
```
