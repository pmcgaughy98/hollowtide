# Codex: Ironvent title card, skull-top touch-up (pixel work only)

From Preston via Claude, 2026-09-30. Preston wants the existing picture refined by hand, not regenerated. Do not use
image generation for this. Edit pixels in the installed file.

## The file
`assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/titlecard.png` (183 x 128, one drawn pixel per
PNG pixel). All coordinates below are in this file's pixels. Back it up first as
`docs/creatures/ironvent-titlecard-candidates/ironvent_titlecard_before_skull_touchup_2026-09-30.png`.

## Guides
- `skull_fix_guide_native_10x_2026-09-30.png`: the head at 10x with the four regions boxed and lettered.
- `skull_reference_front_and_roar_10x.png`: the approved front head (left) and the Furnace Roar side frame (right).
  These are the anatomy to match.

## What is already right: do not move or redraw
- The two horns. Both now rise from the crown behind the eye (near horn tip about x 129, y 0; far horn tip about
  x 148, y 3). Claude moved the far horn off the snout on 2026-09-30.
- The eye (about x 151, y 35), the nostril (about x 175, y 35), the jaw, teeth, mouth fire, the lower swept horn, the
  dorsal vents behind the head, and the whole body.

## The problem
Preston: the top of the head "doesn't look very skull-like". The top edge of the skull was closed with straight
machine-made lines when the horn was moved, so it reads as a flat lid, not bone and plate.

## The four touch-ups

**A. Snout bridge (x 154 to 179, y 25 to 32).** Now: one ruler-straight dark line from the brow to the nostril. Wanted:
the top of the snout built from three overlapping plates, like the front sprite's. Each plate's front edge drops one
pixel lower than the plate behind it, so the bridge steps down toward the nostril in three clear steps. One-pixel dark
outline along the top. Give each plate a one-pixel lighter top edge and a darker underside.

**B. Brow ledge (x 146 to 156, y 27 to 33).** Now: the skull top runs flat straight over the eye. Wanted: a thick,
blunt brow ridge that overhangs the eye by one pixel and is two to three pixels deep, the fused ram crest from the
front sprite. It is the highest point of the skull in front of the horns; the snout bridge (A) starts one pixel below
it.

**C. Cranium (x 135 to 147, y 25 to 32).** Now: a busy patch of lava cracks between the near horn's base and the
brow. Wanted: the curved top of the skull in two or three larger stone plates, with a highlight along the top edge
and at most one lava crack between plates. The near horn's base should sit on this, not float in front of it.

**D. Horn join (x 118 to 138, y 22 to 31).** Now: a flat, pale, three-band wedge that Claude painted to fuse the near
horn's base into the lower swept horn (in the original they are one structure). Keep the fusion; fix the painting.
Wanted: the near horn's base flaring down and back into the lower horn as one piece of stone, shaded in the horn's own
three tones following the horn's curve, its glowing crack carried on into the lower horn's glow. No hard diagonal
edge, no flat colour band. Do not cover the two dorsal vents to its left (about x 103 to 118, y 17 to 28).

## Rules
- Pixel edits only, inside the four boxes (a pixel or two outside is fine where an outline has to meet).
- Use only colours already in the picture: the stone tones from the horns and plates, the dark outline, the existing
  lava oranges.
- Whole pixels, no soft edges, no partial transparency. The silhouette keeps its dark outline everywhere.
- Same size, same position: the picture must stay 183 x 128 with nothing shifted, so it sits on the title card as now.

## Check and deliver
- View it in the engine: `scenes/ironvent_roar_preview.tscn`. The picture appears 3.6 s after the title card opens.
- Save a 10x before and after of the head in `docs/creatures/ironvent-titlecard-candidates/` and show Preston.
- Add a handoff line to `docs/AI_COLLABORATION.md`.
