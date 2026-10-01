# Hollowtide Back View: separate-app proposal (2026-09-26)

> This is a proposed fallback, not an installed app. The live [Hollowtide Sprite Forge](opal-sprite-forge-prompt-v4.md) currently includes a `VIEW: BACK` mode. That mode was preserved while its front and evolution prompt was repaired. Its output quality has not been reviewed with the new prompt. If back views still drift, use the separate-app plan below; do not assume it already exists in Opal.

**Why a separate app:** Sprite Forge's prompt treats the image input as a previous stage to evolve. The
v3 back-view add-on told the model the same image was the same creature to redraw. Two opposite
instructions about one image gave hit-or-miss backs (Cinderhide came out taller and more side-on).
One app per job removes the conflict.

## Setup (about 5 minutes)

1. **Sprite Forge:** if adopting this fallback, remove the VIEW RULE block from its live prompt so that app handles fronts and evolutions only. Its image input stays "Previous Stage Sprite (optional)".
2. **Make the back app:** duplicate/remix Sprite Forge and name it **Hollowtide Back View**.
   - Generate step model: **Nano Banana Pro**.
   - Input 1: image, required, named **Front Sprite**.
   - Input 2: text, optional, named **Notes** (anything specific to this creature).
   - Replace the prompt with the one below. Turn the two bracketed spots into input links: type `@`
     and pick the input.

## Prompt

```
Redraw the creature in the attached image from behind, as the player's own creature seen in a monster battle.

FRONT SPRITE: [@Front Sprite]
NOTES (optional): [@Notes]

THIS IS THE SAME CREATURE, NOT A NEW ONE. Copy it exactly: same anatomy, proportions, leg length, body height, stance, markings, spines, plates, outline weight and colours. Do not redesign it, evolve it, stand it up taller, slim it down, or add or remove any feature.

CAMERA: behind the creature and slightly above it, looking over its back. The creature faces away from the viewer toward the upper right, as if facing an opponent in the distance. The viewer sees its back, spine, tail and the back of its head. The face is hidden, except at most the edge of one cheek, horn or ear. This is a rear view, not a side view.

COLOUR: use exactly the colours in the attached image, lit the same way. Do not darken the back, the spines, or any glowing parts. Spines, vents, plates and tail keep the same colours they have in the attached image.

SIZE AND GRID: the same pixel grid and scale as the attached image. One centered creature filling about 80% of the image height, feet three grid cells above the bottom.

PIXEL ART: every grid cell is one flat colour. No gradients, blur, anti-aliasing or soft edges. Dark one-cell outline. No more than 16 colours.

BACKGROUND: flat solid magenta (#FF00FF). No shadow, ground, text, or extra creatures.
```

## Using it

- Attach the Forge **front** original from `docs/HollowTide Sprites/` (sharper than the converted PNG).
- Notes example for a redo: `Cinderhide. Keep the low crouch and short legs.`
- Facing left instead of right is fine: backs are mirrored to face right during conversion.
- Convert as usual; if a back's colours still drift, the palette-match fix from 2026-09-25 corrects it.
