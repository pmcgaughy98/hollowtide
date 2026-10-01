# Hollowtide Effect Sheet Generator: Gemini skill

Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. Generate separate Hollowtide move effects: five isolated modules or an eight-frame material sequence. Match the creature’s approved pixel finish and physiology; keep body actions, projectiles and impacts separate for review before Godot import.

**Skill name to use in Gemini:** `effect-sheet-generator`

## What you give it each run

- **Configure Creature:** text or an image. Start with MODE MODULES for five separate move parts or MODE ACTION for an eight-frame material sequence. Name the creature, one move, source anatomy, material, direction, target, charge, contact and aftermath. For Vitrecrag, request its orange-gold molten-glass beam or heavy cannon shot as distinct effects.
- **Creature Reference (optional):** an image you attach. Optional: upload the approved front sprite of the creature using this move.

## Model

- Create Effect Sheet — 2026-09-30: Nano Banana Pro (Gemini's best image model), aspect ratio 1:1

The Opal review page (it only displayed the result) is not part of the skill.

## Skill instructions (paste this into the skill)

```text
Each time this skill runs, I will give you [Configure Creature], [Creature Reference (optional)] in my message. Use them exactly as described below.

Create exactly ONE Hollowtide pixel-art battle effect sheet for one move. The text input may describe a move or may be a creature roster brief. If a creature reference image is supplied, it is the creature that uses the move, not a previous evolution stage. Draw only effect pieces, never the creature.

DESIGN: Study the creature's anatomy, markings, palette, essence, and temperament. Make the main shape echo one signature feature. For MODULES, make three small motif particles rather than generic dots/squares and an impact echoing the main shape. For ACTION, follow only the requested chronological material effect; do not add unrelated modules. If the text is only a creature brief, invent one move that fits it. Ember means heat, fire and molten material; Tide water and erosion; Stone rock, grit and bound gemstone; Gale wind and dust; Bloom growth; Hollow absence, cracks and fading. Do not substitute lightning for Ember or Gale, or for Stone's gem energy.

MODE AND LAYOUT: Read MODE MODULES or MODE ACTION from Creature Brief; default MODULES. MODULES uses one square canvas and makes the existing five distinct pieces: upper-left main shape, upper-right impact, and three lower motifs, each separated by at least four flat-magenta logical cells. ACTION uses a rectangular atlas twice as wide as tall: 4 columns by2 rows of eight equal SQUARE chronological cells, default100x100 logical cells or128x128 for Vitrecrag/Oxbowarchon unless brief specifies an approved other size; eight chronological frames of ONE emitted material effect: F0 charge/first emission, F1-F2 growth, F3-F5 travel or sustained connection, F6 contact, F7 decay or cooling. Keep the same origin, pixel grid, direction and palette in every cell. No dividers, labels or text. For Vitrecrag, make the molten orange-gold glass CANNON one heavy launched mass with a distinct impact and cooling sequence. Its material comes from the furnace visible in its approved body. Do not turn it into a generic fireball, tiny dot or beam; the Molten Beam move was dropped. The creature body action, contact timing, camera and sound belong to Godot, not this sheet.

PIXEL ART: Match the approved source finish and density with one coherent logical pixel grid across all cells; the drawing target is not a guarantee of export dimensions. Every logical cell is one flat color with hard stepped edges and coherent material planes. Use a purposeful palette from the creature and move, without a fixed color ceiling. Give a molten-glass mass a dark cooled rim, orange-gold hot core, weight and changing viscosity; any sustained stream requested for another creature must have connected material volume, not a thin 8-bit streak. Keep luminous accents within the drawn material, not a soft halo. No gradients, blur, antialiasing, random noise, motion blur, smeared smoke, or transparency. Never put magenta within effect pieces. Mature grounded folklore; no UI, creatures, scenery, floor, shadows, extra images or text. Output exactly one sheet image.

EDGES AND BACKGROUND: Every pixel is part of an opaque drawing cluster or pure flat #FF00FF magenta. Glows, flashes, auras, sparks and smoke use solid stepped colours; never let a glow, halo or soft edge fade into magenta. Keep every part of every effect at least 6 logical cells inside its canvas or cell edge. If an effect would cross an edge, draw it smaller instead of cropping it.

 CREATURE BRIEF: [Configure Creature]

CREATURE REFERENCE (optional): [Creature Reference (optional)]
```
