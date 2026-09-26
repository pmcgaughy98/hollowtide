# Hollowtide Sprite Forge: prompt v2

Updated 2026-09-25 by Codex from Claude's v2 prompt. This file now documents the current Opal editor setup. The earlier prompt is preserved in `opal-sprite-forge-prompt-v1-backup.md`.

## Current Opal setup

- The generator is set to **Nano Banana Pro**, not Agent.
- **Creature Brief** is a required Text input.
- **Previous Stage Sprite (optional)** is an optional Image input. It is connected to the generator prompt.
- The generator prompt also references both inputs. The showcase step receives the generated image and the full brief.
- The app has not been run for an image generation. The input wiring is visible in the editor; continuity and image quality still need a real output review. No sprite was generated while preparing this handoff.

## Use the roster

1. Paste one complete creature brief into **Creature Brief**.
2. For Stage I, leave **Previous Stage Sprite (optional)** empty. For Stage II or III, upload only that line's immediately previous-stage sprite. For a Cinderhide or Rimefin redraw, you may upload its current sprite.
3. Leave the generator at **Nano Banana Pro** and aspect ratio **1:1**.
4. After generation, review the result. The prompt requests a square image depicting a 64-by-64 grid over a solid magenta background. It does not request transparency or a native 64x64 image. Convert the generated square image with tools/opal-sprite-converter.html to create a transparent 64x64 PNG. Review its preview against the raw image before import; the tool has not yet been checked on a real Opal output. Do not import the raw generated image into Godot as a finished sprite.

Opal currently displays a daily generation limit notice. The first generated roster form should be treated as the test of the whole pipeline, including whether the image input preserves identity.

## Prompt text

The live prompt contains Opal output-reference chips at the two bracketed positions below. When installing the text manually, type `@` at each position and select the named step in Opal's picker; do not leave the bracketed directions in the prompt.

```text
Create exactly one creature sprite for Hollowtide from the Creature Brief at the end of this prompt. Draw only its requested features; invent no extra anatomy, effects, props, or markings. If the optional Previous Stage Sprite image is attached, it is the same creature at its prior stage. Preserve its recognizable face, signature anatomy, and palette while changing proportions and silhouette as the brief directs. If no image is attached, follow the text brief alone.

PIXEL ART: depict a true 64×64 pixel grid enlarged into a square image. Every grid cell is one flat color. No gradients, blur, anti-aliasing, noise, or soft edges. Details thinner than one grid cell are omitted.

BACKGROUND: solid pure magenta #FF00FF, one exact flat color, outside the creature. No transparency, checkerboard, shadow, floor, border, or text. Never use magenta on the creature.

STYLE: mature, grounded folklore creature art; not cute, chibi, or toy-like. Exactly one full-body creature, using the pose, facing, anatomy, and palette specified in the brief. If missing, use a three-quarter side view facing right. Center it and fill about 80% of the image height, feet three grid cells above the bottom. Use a dark one-cell outline, strong chunky silhouette, low interior detail, and no more than 16 colors.

Output exactly one image.

Creature brief:
[insert @Creature Brief]

Previous-stage image reference (optional):
[insert @Previous Stage Sprite (optional)]
```

## Why the background is magenta

The generated image is intended as a grid-accurate source that can be cut out and downsampled. It is not a transparent sprite yet. The local converter is tools/opal-sprite-converter.html; it still needs review against the first real output before any art is treated as Godot-ready.
