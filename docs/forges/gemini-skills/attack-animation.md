# Hollowtide Attack Animation: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Generate six-frame creature body-action sheets or ONE signature title card with ACTION CLASS CUT-IN. Use approved source anatomy and pixel finish. Complete partial sheets with explicit KEEP/MISSING slots; travelling effects stay separate. Every frame is reviewed before Godot integration.

**Skill name to use in Gemini:** `attack-animation`

## What you give it each run

- **Attack Motion Brief / Cut-In:** text you type. Name creature, move and exact FRONT/BACK view. ACTION CLASS CUT-IN or TITLE CARD makes ONE full-body signature picture: state peak pose, framing and heat state. Approved Source Sprite is identity; Existing Attack Sheet can be a pose-only guide or NONE. Other classes MELEE, RANGED, BEAM, GUARD, INTERRUPT or HIT make six square cells in 3x2. MODE NEW builds them; MODE COMPLETE needs explicit KEEP/MISSING F0-F5 and an original partial sheet. Name F4 release/contact and separate target-hit timing when needed. Preserve source finish, anatomy and viewpoint. Travelling effects come from the Effect Forge. Four-sheet projects are cut into individual frames, inspected, ordered and inspected again before engine integration.
- **Approved Source Sprite:** an image you attach. Upload the approved creature sprite in the exact view named in Attack Motion Brief. Use the original Forge image or its transparent Godot PNG, not a preview screenshot. This is the authority for species identity, anatomy, material, palette, outline weight, logical pixel grid, and facing. The action may articulate limbs and shift weight, but must not redesign, evolve, mirror, rescale, or switch front/back view.
- **Existing Attack Sheet:** text or an image. MODE NEW: type NONE. MODE COMPLETE: upload the original partial action sheet for this same creature and view, not a screenshot. It may be a 3×2 sheet with blank/duplicate placeholders or a numbered 1×N horizontal strip. In Attack Motion Brief name the layout and exact KEEP and MISSING frames F0–F5. Preserve approved existing poses; request only missing poses or specific in-between action. Never treat a deliberate repeated hold as a missing frame.

## Model

- Generate Combat Sheet / Cut-In — 2026-09-30: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Attack Motion Brief / Cut-In], [Approved Source Sprite], [Existing Attack Sheet] in my message. Use them exactly as described below.

OUTPUT ROUTER — apply before all sheet rules below: If Attack Motion Brief names ACTION CLASS: CUT-IN or TITLE CARD, generate exactly ONE complete signature title-card creature picture. Do not generate an animation sheet, panels, repeated poses, text, borders or labels. Use Approved Source Sprite as the anatomy authority. In CUT-IN mode, Existing Attack Sheet is optional pose/heat guidance only: it never replaces the approved creature's skull, horns, limbs, plates or proportions. Follow the brief's one dramatic peak-action pose, full body, facing direction, heat state and composition. Increase deliberate clustered pixel detail for the close-up while keeping the approved dark outline, material and palette; do not smooth or paint it. Keep every horn tip, foot and tail fully visible with at least six logical pixels of pure #FF00FF margin. Draw all light as opaque stepped colour clusters, never a halo fading into magenta. The final prepared game picture should fit within 130 native pixels tall; this is a visual target, not a claim the exported image has that resolution. Ignore every six-cell, F0–F5, NEW/COMPLETE-sheet and registration instruction below for CUT-IN. For every other action class, execute the existing six-frame workflow below unchanged.

 Create one Hollowtide creature BODY attack animation from the approved source sprite. This is a combat action, not an idle breath or an evolution. Preserve the same species, anatomy, silhouette landmarks, material, palette, dark pixel outline, logical pixel grid, and exact FRONT or BACK view. Keep the character grounded and recognizable at native battle size. Never mirror, change view, redesign, add armor, or render a smooth painted illustration.

ACTION CLASS: Read MELEE, RANGED, BEAM, GUARD, INTERRUPT, or HIT from Attack Motion Brief; default MELEE. Output exactly SIX equal square cells in a 3-column × 2-row sheet, row-major F0–F5, with one complete creature at one shared origin and baseline per cell. F0 ready/source pose. F1 readable anticipation. F2 load or brace. F3 action begins. F4 named event: MELEE contact, RANGED shot release, BEAM emission/held channel, GUARD full brace, INTERRUPT deflection, or HIT peak recoil. F5 recovery toward F0. Make adjacent silhouettes visibly different with coherent anatomy and planted support. Do not fake action with whole-image sliding, glow-only changes, or six near-identical poses. Godot now supports separate emission and hit frames, a strain loop for sustained actions, camera shots and sound cues. Name those events in the motion brief; F4 is the body action's main release or contact pose, not automatically the target-hit frame.

The sheet prioritizes the creature's BODY poses. A small species-native charge, sphere, flash or vent glow may stay attached to its anatomy if the brief requires it and every pixel remains inside its cell. The separate Effect Forge supplies travelling projectiles, slash paths, debris and target impact. Do not bake large arcs, explosions, ground, props, text, frame numbers, timing marks, borders, shadows or extra creatures into these cells.

REGISTRATION: All cells have identical dimensions, viewpoint, scale, ground line and pixel origin. Hold anchored anatomy stable; a supporting foot can pivot or step only when the brief calls for it. Give active claws, limbs, furnace apertures, tail counterweights or guard structures a continuous path with no duplicated part or impossible joint jump. Pixel clusters must be crisp, no blur, gradients, antialiasing, subpixel drift, recentering, cropping, or auto-scaling. Use one flat #FF00FF background outside the creature in every cell, with no magenta inside the creature. The first frame should closely match the approved sprite. Mature grounded folklore tone, not cute or chibi.

HOUSE STYLE: Match the approved source creature and Cinderhide's finish: dark outline around the full silhouette, about 20 to 36 colours, clean clustered shading with few lone pixels, and source-matched brightness. Only that creature's own glow may be brighter. Native cell grid: 128x128 for Vitrecrag and Oxbowarchon, 100x100 for every other creature.

FRAMES: All six cells show the same creature at the same scale, feet on the same baseline. The whole creature, including its tail, fits within each cell with margin. Make six DISTINCT sequential body poses; for MODE COMPLETE preserve only explicit KEEP poses, even if a held pose is repeated there, and create distinct missing in-betweens.

EDGES AND BACKGROUND: Each pixel belongs to an opaque drawing cluster or pure flat #FF00FF magenta. Sparks, flashes, smoke and glows use stepped opaque colours; no fading into magenta. Keep every visible part, including energy and tail, at least 6 logical cells inside its cell edge. Reduce an effect's size if needed rather than crop it.

Attack motion brief: [Attack Motion Brief / Cut-In]




Approved source sprite: [Approved Source Sprite]



Use the approved source and its exact view as the anchor, including the head visibility actually present there. Never turn a rear into a front. Author physical intermediate poses with a clear path into the named F4 event. Godot handles travel, hitstop, damage and target effects separately. An intact-sprite approach and separate contact effect is an approved alternative for simple strikes; do not invent a six-pose sheet to replace an already approved intact animation. For a sustained BEAM show a held emitter posture; for a CANNON show charge, recoil and release. Vitrecrag Molten Glass uses its golden-orange molten-glass cannon, not the retired Molten Beam. Kithflare-line moves use the approved flush heat/light markings and the named move brief; locomotion is not a mandatory power theme. No sacs, pads, generic flames or armor unless already present in the approved form. 

MODE NEW: If Existing Attack Sheet is NONE, create all six body frames using the brief above. MODE COMPLETE: If an original partial action sheet is supplied, use its approved poses as anchors. Read KEEP and MISSING F0–F5 and the uploaded layout from Attack Motion Brief. Copy KEEP cells as faithfully as possible into their row-major positions; draw only missing cells, especially the in-between poses needed to make the motion read. A 3×2 with blank or duplicated placeholders or a 1×N strip can be completed. Preserve native cell size, palette, outline, view, pixel origin, feet baseline and anatomical continuity. Do not assume a held repeated frame is missing unless the brief labels it MISSING. If the brief omits KEEP/MISSING, preserve the uploaded art rather than guessing.

Before finalizing, inspect the six silhouettes in order: the creature should visibly load, perform its named F4 event, then recover. Reject a static peak pose repeated across cells, wandering face or markings, duplicated limbs, perspective flip, cell misalignment, magenta fringe, and contact before F4. Return only one clean 3×2 sheet; do not draw explanatory text onto the pixels.

Existing attack sheet (NONE for NEW, original image for COMPLETE): [Existing Attack Sheet]
```
