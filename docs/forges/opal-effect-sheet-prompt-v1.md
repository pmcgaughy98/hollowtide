# Hollowtide Effect Sheet Generator (live v3, 2026-09-26)

**Historical prompt snapshot:** The live Forge now has MODE MODULES and MODE ACTION, material-specific eight-frame effects, and Nature wording. It was verified after reload on 2026-09-27; no output was generated. See [verified live modes](forge-live-status-2026-09-27.md).

[Open the live Effect Sheet Generator](https://opal.google/edit/1G34GLZ7O1UEBX3pX6NIXNd8LjQjKUyBt). The Create Sprites step uses Nano Banana Pro. Its revised prompt and two linked input chips remained saved after a reload. No new effect image was generated in this update.

## Inputs

- **Creature Brief:** Describe one move, or paste a creature roster brief and let the Forge invent its signature effect.
- **Creature Reference (optional):** Upload the approved front sprite of the creature using the move. This is the same creature, not a previous evolution stage.

## Live prompt

The two bracketed input markers below stand for Opal's linked chips. They are wired in the live app. If rebuilding it, type @ and select the matching input rather than pasting the marker as plain text.

```text
Create exactly ONE square Hollowtide pixel-art battle effect sheet for one move. The text input may describe a move or may be a creature roster brief. If a creature reference image is supplied, it is the creature that uses the move, not a previous evolution stage. Draw only effect pieces, never the creature.

DESIGN: Study the creature's anatomy, markings, palette, essence, and temperament. Make the main shape echo one signature feature. Make three small particles as recognizable motifs from that same design, never generic dots or squares. Make the impact burst echo the main shape. If the text is only a creature brief, invent one move that fits it. Ember means heat/fire; Tide water/erosion; Stone rock/grit; Gale wind/dust; Nature growth; Hollow absence/cracks/fading. Do not substitute lightning for Ember or Gale.

LAYOUT: One square image with five distinct pieces on a single flat magenta #FF00FF background. Upper left: main projectile or primary shape, about 20-24 logical cells wide. Upper right: impact burst, about 32-40 cells wide. Lower half: three different 3-6-cell particles, spaced apart. Keep all pieces entirely inside their own areas, with at least four clear magenta cells between them and the canvas edge. No overlap, frames, dividers, guides, or labels.

PIXEL ART: Use one consistent enlarged logical pixel grid for the entire sheet. Every logical cell is one flat color; hard edges, dark one-cell outlines, and 4-6 colors total drawn from the creature or brief. No gradients, glow, blur, antialiasing, smoke, noise, lighting halos, motion blur, or transparency. Never use magenta inside an effect piece. Keep the mature grounded folklore look. No text, UI, characters, scenery, floor, ground shadows, or extra images. Output exactly one sheet image.

CREATURE BRIEF: [linked Creature Brief chip]

CREATURE REFERENCE (optional): [linked Creature Reference (optional) chip]
```

## Use in Godot

Save the original Opal output, review the hard pixel grid, palette, and spacing, then convert magenta to transparent PNG with the existing Forge converter. Cut the five reviewed pieces from the sheet as needed and import them as move effects. The Forge generates art only; it does not assign move timings or animate a battle. See [Forge production standard](forge-production-standard.md) and the move briefs for creature-specific jobs.
