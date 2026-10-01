# Hollowtide Sprite Forge prompt v3 (historical, 2026-09-26)

> Superseded by [the live v4 prompt and mode guide](opal-sprite-forge-prompt-v4.md). V3 did not distinguish a same-form redraw from an evolution and did not include the back-view rule.

Supersedes the v2 prompt text. Setup is unchanged (Nano Banana Pro, Creature Brief text input,
Previous Stage Sprite (optional) image input). Not yet tested.

**Why v3:** evolutions from a reference image sometimes kept the old pose and body and bolted new
parts on. v2 told the model mostly what to preserve, said "invent no extra anatomy", and image models
copy an attached image's pose by default. v3 names the few things to keep and makes pose, proportions
and silhouette mandatory changes. The canvas line now says 100x100, which is what the Forge actually
draws (THE_CONCEPT.md, 2026-09-25).

Install: select all in the Generate step's prompt, paste, then turn the two bracketed spots into input
links (type `@`, pick the input).

```text
Create exactly one creature sprite for Hollowtide from the Creature Brief at the end of this prompt.

IF NO IMAGE IS ATTACHED: draw the creature from the brief alone. Draw only the features it asks for; add no props, effects or markings.

IF A PREVIOUS STAGE SPRITE IS ATTACHED: it is this creature's previous stage. Draw the NEXT stage: the same animal grown up and changed, not the old sprite with parts added.
KEEP, and only these: the face and eye shape, the palette, and the one or two signature features the brief names.
CHANGE, all four:
1. POSE: use the pose in the brief. Do not copy the attached image's pose, stance, leg positions or head angle.
2. PROPORTIONS: a new body plan as the brief describes: different leg length, neck, torso depth and head-to-body ratio.
3. SILHOUETTE: filled solid black, the new outline must look clearly different from the attached image's.
4. TRANSFORM, DON'T ADD: old features grow, fuse, split or reshape into the new ones (horns into a crest, vents into a ridge, fins into limbs). Never bolt new parts onto the old body. Absorb or drop old details that no longer fit.
Before drawing, check: if this result could be made by editing the attached image (adding spikes, armour or size), it is wrong. Draw the new stage from scratch.

PIXEL ART: depict a true 100x100 pixel grid enlarged into a square image. Every grid cell is one flat color. No gradients, blur, anti-aliasing, noise, or soft edges. Details thinner than one grid cell are omitted.

BACKGROUND: solid pure magenta #FF00FF, one exact flat color, outside the creature. No transparency, checkerboard, shadow, floor, border, or text. Never use magenta on the creature.

STYLE: mature, grounded folklore creature art; not cute, chibi, or toy-like. Exactly one full-body creature, using the pose, facing, anatomy, and palette in the brief. If missing, use a three-quarter side view facing right. Center it and fill about 80% of the image height, feet three grid cells above the bottom. Dark one-cell outline, strong chunky silhouette, low interior detail, no more than 16 colors.

Output exactly one image.

Creature brief:
[insert @Creature Brief]

Previous-stage image reference (optional):
[insert @Previous Stage Sprite (optional)]
```

## If evolutions still bolt parts on after a few runs

Add a text step before the image step: **Plan Evolution** (Gemini 3.1 Pro), taking both inputs, prompt:
"Look at the attached previous stage and the brief. In under 80 words, describe the next stage: what
stays (face, eyes, palette, signature feature), the new pose, the new proportions, and exactly which old
feature turns into which new one. Do not describe the old sprite." Then add `@Plan Evolution` to the
image prompt under the brief. Image models follow a written description of a new pose far better than
an instruction to depart from a picture.
