# Hollowtide Idle Sprite Forge: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Upload an approved Hollowtide creature sprite and generate a four-frame, subtle idle-breath sprite sheet for Godot. The source art, palette, pose, and pixel grid stay consistent.

**Skill name to use in Gemini:** `idle-sprite-forge`

## What you give it each run

- **Idle Motion Brief:** text you type. State the creature and exact view (front or back). Choose MODE NEW for a fresh 2×2 idle sheet, or MODE COMPLETE to finish an uploaded partial sheet. For COMPLETE, explicitly list KEEP and MISSING slots F0 neutral, F1 early inhale, F2 inhale peak, F3 return. Say whether the old sheet is 2×2, 1×2, or 1×3. Name at most one subtle secondary motion; feet stay fixed. Example: Cinderhide front; MODE COMPLETE; 1×2 sheet; KEEP F0,F1; MISSING F2,F3; gentle chest breath with delayed vent pulse.
- **Source Sprite:** an image you attach. Upload the approved front or back creature sprite you want to animate. Use the original Forge image or its transparent Godot PNG. Keep its identity, pose, palette, silhouette, outline, and pixel grid unchanged across every frame.
- **Existing Idle Sheet:** text or an image. MODE NEW: type NONE and submit this step. MODE COMPLETE: attach your earlier idle sheet for the same creature and view. A partial 2×2 sheet or a 1×2/1×3 strip is supported; include its blank or repeated placeholders. Use the original image, not a screenshot. In Idle Motion Brief identify KEEP and MISSING F0-F3 slots explicitly.

## Model

- Generate Idle Frames — 2026 production: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Idle Motion Brief], [Source Sprite], [Existing Idle Sheet] in my message. Use them exactly as described below.

Animate the uploaded approved Hollowtide creature sprite as one subtle, seamless idle-breath loop. The Source Sprite is the authority for identity, front/back viewpoint, pose, anatomy, silhouette, markings, palette, dark one-cell outline, and native pixel grid. Never redesign or evolve it. Never flip its facing. Match the source image's logical pixel size; do not resample it to 64×64.

OUTPUT: Exactly one square 2×2 sprite sheet containing FOUR equal, square frames. Reading order: top-left F0 neutral; top-right F1 beginning inhale; bottom-left F2 peak inhale; bottom-right F3 exhale, almost neutral. Each frame shows exactly one complete creature, placed at the same coordinates. The sheet must have no gutter, spacing, borders, labels, guides, numbers, shadows, ground, props, attack effects, or extra creatures.

MOTION: Keep feet and ground contact fixed in every frame. Change chest, shoulders or body volume by only 1–2 logical pixels across the cycle. Preserve mass and outline weight. A vent, fin, ear, tail tip, leaf, or similar secondary element may lag by one frame if the motion brief asks for it. No full-body bobbing, translation, scale jump, rotation, blinking unless requested, smear, blur, anti-aliasing, gradients, or added details. F3 must transition cleanly back to F0. Make the movement readable but restrained, like polished monster-collector battle idle art.

BACKGROUND: In all four frames, use one exact solid chroma-key color #FF00FF outside the creature. No transparency or checkerboard. Do not use magenta inside the creature. Use hard-edged pixel clusters only; do not introduce new palette colors. Keep the original mature, grounded folklore tone, never cute or chibi.

HOUSE STYLE: Match the approved source creature and Cinderhide's finish: a dark outline around the entire silhouette, clean clustered shading with very few lone pixels, and source-matched brightness. Aim for about 20 to 36 colours when creating a new sheet; in COMPLETE mode keep the source palette exactly. Only the creature's own glowing parts may be brighter. Native cell grid: 128x128 for Vitrecrag and Oxbowarchon, 100x100 for every other creature unless the approved source has an explicitly different native grid.

EDGES AND BACKGROUND: Every pixel is drawing or pure flat #FF00FF magenta. Glows, flashes, sparks and smoke, if the brief requires them, are solid opaque stepped-colour clusters. Never fade a glow, halo or soft edge into magenta. Keep every part, including tails, fins and feet, at least 6 logical cells inside each cell edge. Reduce a motion accent rather than crop it.

If the source image already has a transparent background, replace only the empty outside area with #FF00FF. The first frame should closely reproduce the supplied sprite at its original pose and proportions.

Motion brief: [Idle Motion Brief]


Reference sprite: [Source Sprite]



Preserve the supplied view exactly. Do not convert a front view into a back view or vice versa. If a consistent four-frame sheet cannot be produced, keep the source sprite intact and use the smallest motion possible.

SHEET REGISTRATION: Treat F0 as a faithful pixel copy of the approved source. Build F1-F3 by editing only small breathing and requested secondary-motion clusters of that same sprite, never by redrawing or repositioning the whole body. All four quadrants have identical square cell dimensions and one shared pixel origin. Keep the same feet/contact pixels and stable silhouette landmarks at the same coordinates; do not crop, scale, auto-center, or shift any frame independently. F2 is the soft inhale peak; F3 settles naturally toward F0 without snapping. Keep motion restrained and readable at battle size. Do not draw timing or frame labels; assign playback holds after conversion for Godot. 

TWO MODES. NEW: When Existing Idle Sheet is NONE or no image, make a new four-frame sheet using the rules above. COMPLETE: When an earlier idle sheet is supplied, finish that sheet. The earlier sheet may be a 2×2 with blank or duplicated placeholder cells, or a horizontal strip of 2 or 3 frames. Treat every existing approved frame as locked artwork. Follow the Motion Brief’s explicit KEEP and MISSING frame list. Map a horizontal strip in reading order from F0; preserve its frame pixels and cell dimensions when placing them into the final 2×2. For a partial 2×2, preserve the approved cells in their exact quadrants. Draw only the missing frames. Do not assume a deliberate repeated hold is missing unless the brief marks it MISSING. The finished output still contains F0 neutral, F1 early inhale, F2 soft peak, and F3 return in one seamless 2×2 sheet. Keep the same pixel origin, baseline, palette, outline, anatomy, view, and contact pixels as the supplied frames; interpolate 1–2 logical pixels of breathing and only the requested secondary motion. Never shrink, crop, recenter, flip, or remake a kept frame. No blank cells, labels, gutters, or extra poses. If the brief does not identify what is missing, preserve the existing sheet instead of inventing a replacement.

Existing sheet (image for COMPLETE, text NONE for NEW): [Existing Idle Sheet]
```
