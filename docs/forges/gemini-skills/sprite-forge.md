# Hollowtide Sprite Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Create original Hollowtide creature fronts, evolutions, redraws, and backs from roster briefs. Use a lineage image for anatomy and the optional Cinderhide image for pixel-art quality.

**Skill name to use in Gemini:** `sprite-forge`

## What you give it each run

- **Creature Brief:** text you type. Paste one complete copy-ready brief from the Hollowtide creature roster. Include: creature and evolution stage; essence and folklore inspiration; body plan, silhouette, and signature anatomy; face, pose, and facing; temperament; palette and palette limits; details that must stay recognizable from the prior stage; and a clear avoid-list. Give each stage its own distinct silhouette while preserving the line’s identity. For a standalone creature or Stage I, say that no prior-stage image is needed. For Stage II or III, attach only the immediately previous stage from this same creature line in the optional image input.
- **Previous Stage Sprite (optional):** an image you attach. Optional image reference. For a new Stage I, leave blank. For Stage II, upload that line's Stage I PNG; for Stage III, upload that line's Stage II PNG. Use only the same creature line. For Cinderhide or Rimefin redraws, upload the current sprite. This image preserves face, signature anatomy, and palette while the written brief directs the new silhouette and form.
- **Style Anchor (optional):** an image you attach. Optional approved Cinderhide front. Use only as the rendering-quality reference: dark pixel outline, dense but readable material clusters, layered shading, controlled ember accents, and grounded weight. Never copy its reptile anatomy into another species.

## Model

- Render Hollowtide Creature — 2026 production: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Creature Brief], [Previous Stage Sprite (optional)], [Style Anchor (optional)] in my message. Use them exactly as described below.

Create exactly ONE Hollowtide creature sprite from the Creature Brief. The brief determines species anatomy, pose, facing, palette and evolution changes. Draw only that creature: no props, effects, extra anatomy or labels.

REFERENCE IMAGE MODES: For a new Stage I front, leave Previous Stage Sprite empty and draw from the brief. If the brief starts TASK: REDRAW, Previous Stage Sprite is this exact form: retain its recognizable body plan, face and markings while improving the specified pose and rendering; do not evolve it. For a Stage II or III front without TASK: REDRAW, Previous Stage Sprite is the immediately prior stage of the same line. Preserve face and eye identity, palette relationships and one or two signature motifs, then transform proportions, stance, limbs, head-to-body ratio and filled silhouette according to the new brief. Draw a new stage from scratch; do not merely enlarge or bolt parts onto the old one.

VIEW: When VIEW: BACK, Previous Stage Sprite is this exact form's approved front, supplying its identity but not its pose. The camera is behind the rear end and a little above; the creature walks away toward the upper right. Hindquarters and hind legs are nearest and largest. Show the side only at a steep angle; hide the face or show at most a thin sliver at the far upper right. Place each marking, plate and limb on its correct anatomical side, and use each visible limb's proper foot shape. Match the approved front's scale, palette and baseline. Never mirror, evolve or redesign the front. Otherwise draw the front from the brief, defaulting to three-quarter right-facing.

CINDERHIDE QUALITY STANDARD: Match the approved Cinderhide front for pixel craft and finish: substantial dark outline, strong chunky silhouette, stepped shadow/midtone/highlight clusters that describe real volume, specific material texture inside major forms, restrained luminous accents and planted weight. Use the optional Style Anchor image for these rendering qualities only. Never copy Cinderhide's reptile anatomy, markings or coal palette into an unrelated species. A giant or evolved form must gain material structure and readable mass, not just larger dimensions. Mature grounded folklore; never cute, chibi or toy-like.

HOUSE STYLE: Match the attached approved creature and Cinderhide's finish: a dark outline around the entire silhouette, about 20 to 36 colours, and shading in clean clustered shapes with very few lone single pixels. Match the approved creature's brightness; only its own glowing parts are brighter. Native grid: 128x128 for Vitrecrag and Oxbowarchon, 100x100 for every other creature.

EDGES AND BACKGROUND: Every pixel is either part of the drawing or pure flat #FF00FF magenta. Glows, flashes, auras, sparks and smoke are solid opaque clusters of stepped colours. Never let a glow, halo or soft edge fade into magenta. Keep every part, including sparks, tails and feet, at least 6 logical cells inside the canvas edge. If an effect would cross an edge, draw it smaller rather than cutting it off.

PIXEL ART: Match the approved same-form reference’s native logical grid in one square image. Default to 100x100 only when no reference or brief specifies another size; Vitrecrag and Oxbowarchon use their approved 128x128 grids. Every logical cell is one flat color. Hard pixel edges and a purposeful palette without a fixed color cap. No gradients, blur, antialiasing, noise, subpixel details or soft edges.

RIG-READY DESIGN: Keep the finished sprite as one intact organism, but make the head/neck, shoulder, hip, tail and limb roots visually legible. Show which limbs and shell plates overlap in front or behind. Keep feet load-bearing and asymmetrical furnaces, seams and markings on their correct anatomical sides. Do not expose artificial cut seams or output detached body-part stickers. A flattened image still needs human-authored hidden joint pixels and exact rest-pose reconstruction before it can become a full cutout rig. Never add armor, sacs or spikes solely to make a joint visible.

BACKGROUND: One exact flat pure magenta #FF00FF outside the creature. No magenta inside the creature. No transparency, checkerboard, floor, shadow, border, guides or text.

ASSET ALIGNMENT: Exactly one complete creature on a stable native-grid origin. Keep every body part in frame and the lowest foot or body contact point on a consistent baseline with at least three clear magenta cells below. Same-form redraws and backs retain the reference form's apparent size and footprint. Evolutions may gain mass and alter silhouette while staying planted. If the brief gives no size, fill about 80% of image height. Output one image only.

CREATURE BRIEF: [Creature Brief]

LINEAGE OR SAME-FORM REFERENCE IMAGE (optional): [Previous Stage Sprite (optional)]

STYLE ANCHOR IMAGE (optional; rendering only, never species anatomy): [Style Anchor (optional)]
```
