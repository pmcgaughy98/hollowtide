# Hollowtide character generation: portrait, map sprite, then walks

Updated 2026-09-30 from `../art/characters/character-art-two-tiers-2026-09-30.md`.
Both live Forges are configured and their prompts/reference links survived reopening. No new output is approved.

- [Character Model Forge](https://opal.google/app/1n9s7JHBcc7O3FJx-TdohZZ71HJbYcsd2): 32x32 chibi map sprites or 96x96 adult waist-up dialogue portraits.
- [Walk Cycle Forge](https://opal.google/app/1hJoFcTzUTBVT-EqX8eA2eTQaUEiLEhQy): one direction, four frames by default; eight frames optional; missing-frame completion supported.

## 1. Establish the portrait identity

Attach the person you want as **Identity Reference** and approved Cinderhide art as **Style Reference**. The identity image controls outfit colors and equipment; Cinderhide supplies finish only. Preston chose the **original chibi teal/goggles courier**, found in `OneDrive/Documents/HollowTide Sprites/Character/Male.jpg`. Use the clearly named `Main Courier - Chibi Identity - Four Views.png` beside it. The olive-jacket model is not the selected courier, and the taller recent walk atlases are not the body-proportion reference.

```text
MODE REDRAW; KIND PORTRAIT; OUTPUT SINGLE; DIRECTION RIGHT.
The original chibi teal-and-goggles courier is the identity reference. Keep his tousled brown hair, brass goggles above his forehead, teal jacket over a dark shirt, tan trousers, brown boots and cross-body satchel. Translate him into an adult waist-up dialogue bust without replacing his face or costume. Calm, capable, neutral expression. The small reference has chibi map proportions; the portrait has natural adult proportions.
```

For an entirely new person use MODE NEW and Identity Reference NONE. Approve the neutral portrait before continuing.

## 2. Expressions

Attach the approved neutral portrait as Identity Reference.

```text
MODE REDRAW; KIND PORTRAIT; OUTPUT EXPRESSIONS; DIRECTION RIGHT.
Same approved adult courier. Four waist-up portraits, NEUTRAL, HAPPY / SURPRISED, WORRIED. Keep body pose, head position, outfit, framing and lighting identical. Change only eyebrows, eyes and mouth. A restrained, readable expression range.
```

## 3. Map turnaround

Attach the approved portrait as Identity Reference. Chibi proportions describe drawing scale, not a younger person.

```text
MODE REDRAW; KIND OVERWORLD; OUTPUT TURNAROUND.
The original approved chibi teal/goggles courier, preserving his large head and short body, about 2.5-3 heads tall. Use the original four-view chibi image as the anatomy reference; do not inherit the taller recent walking model's proportions. Four standing views DOWN, UP / LEFT, RIGHT. 32x32 logical cells, approximately 30-pixel standing height, identical head/body scale in all directions, hips centered x=16 and boots on y=30. Preserve the strongest outfit colors and equipment on the correct side. Top-down three-quarter map projection, both feet planted.
```

## 4. Walks: one direction per run

Use the Walk Forge and attach the approved exact-direction map standing sprite as Character Reference. Repeat for DOWN, UP, LEFT and RIGHT; use the same cell scale in every run.

```text
MODE NEW; KIND OVERWORLD; DIRECTION RIGHT; FRAMES 4.
32x32 logical cells, around 30-pixel standing height, boots on y=30. Preserve the attached approved courier's exact identity, outfit, palette and map projection. Four distinct poses F0 contact, F1 passing, F2 opposite contact, F3 opposite passing. Natural knees, feet close under the hips in passing poses, subtle arm counter-swing, no floating held stride. 2x2 sheet in that order. Side view must match the up/down sprite's measured height.
```

## 5. Repair an incomplete walk

Attach the partial sheet. This example keeps the two contacts and asks for the missing passing poses; change KEEP/MISSING to match the actual sheet.

```text
MODE COMPLETE; KIND OVERWORLD; DIRECTION RIGHT; FRAMES 4.
KEEP F0, F2. MISSING F1, F3.
Keep the two contact poses and the same reference identity, 32x32 cells, scale, palette and boot baseline. Add the two different passing poses: swinging boot moves under the hips, knee bends naturally, arms counter-swing. Avoid another peak stride. F3 must connect smoothly to F0.
```

AI may redraw KEEP cells. Asset assembly retains original approved cells and uses reviewed new poses only.

## Optional eight-frame or legacy walk

`FRAMES 8` adds down/push-off phases. Opal's image setting is fixed at 1:1: draw the 4x2 rectangular atlas in a centered band with blank magenta above/below; do not stretch cells to fill the square. Later extraction crops the band. Four-frame mode fills the square normally.

`KIND LEGACY ADULT` only preserves an explicitly supplied approved older full-body map sprite: 64x64 cells and its established roughly 36-pixel visible height. It is not a dialogue-portrait walk mode.

## Game handoff

This update changes generation tools and instructions only. Current player art and movement remain as installed. Portrait dialogue UI (speaker art, expression per line, background dim/blur) is a separate Claude systems task after Preston approves one portrait. Logical dimensions are drawing targets; actual outputs need grid inspection, conservative magenta removal and Godot preparation.

Current portable instructions: `gemini-skills/character-model-forge.md` and `gemini-skills/walk-cycle-forge.md`. Saved exact prompts and browser proof: `records/character-two-tiers-2026-09-30/`. Earlier single-scale instructions are archived there.
