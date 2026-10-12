# The sprites-in-3D workshop (Claude, 2026-10-12)

Preston: the mech session builds its machine in 3D and renders it down to pixel views, so every angle agrees;
could a Hollowtide creature get the same treatment? This is the synthesis run on that question: stock-take,
measure the reference, build, look, score. Everything here is in `docs/design/sprite3d-workshop-2026-10-12/`.

**Correction first.** Earlier in the day I described the mech work as 2D sprites standing in a 3D room
(billboards). Its files say the opposite: `art/machines/ape_l/views/` holds eight pixel views rendered from the
3D ape, feet-anchored, palette-limited. The 3D model is the source of consistency; the output is 2D. That is the
2026-10-06 rule (3D only as render-to-pixel), and it is what this workshop tests.

## 1. Stock-take (what each tool gave)

| Tool | What it gave | Cost |
|---|---|---|
| Retro Diffusion Low-Poly, Detailed Lite | a textured low-poly Kithflare in three minutes from a prompt and four of its own views; exports a Blender GLB, a turntable, and (after an animate job) a walk rig | $0.10 generate, $0.08 animate; balance $0.29 before, $0.11 after |
| The generation server's Meshy 7 image-to-3D | priced, not run: a mesh that "reproduces only what is in the source image", so it would follow the real sprite instead of a prompt | 38 credits of the 84 on the plan (preflight only) |
| Blender 5.2, headless | `tools/blender/render_creature_views.py`: eight orthographic views at a 30° pitch from one camera ring, flat Workbench colour, transparent, with a facing argument and an animation-frames mode. Its compass was wrong on the first try and was proved right by numbers on the mech ape (eyes right of centre in "e", left in "w") | free |
| Our own scripts | `tools/art/measure_views.py` (height, width, feet row, colours, mirror IoU per view) and `tools/art/pixelize_views.py` (crop, one scale for all eight, snap to the creature's own palette, feet on one row, contact sheet beside the game's views) | free |
| The mech session's method | the structure of `render_sprite_views.py`, `import_views.py` and `score_ape_vs_sprite.py`: one framing, feet anchor, palette, a numeric score against the drawn sprite | free |

## 2. The reference, measured

Kithflare's eight views as the game has them (Retro Diffusion rotations, fixed by hand):

| set | height spread across the eight | mirror IoU e/w | ne/nw | se/sw | colours per view |
|---|---|---|---|---|---|
| 128 px (`assets/sprites/arena/kithflare`) | 4 px | 1.000 (a literal flip) | 0.605 | 0.659 | 18 to 24 |
| dungeon (`.../kithflare/dungeon`) | 2 px | 1.000 | 0.599 | 0.683 | 13 to 16 |

So the drawn set is tall-consistent and its sides are mirrors; its diagonals are the weak pairs (the tail and
the lantern hand sit on one side).

## 3. The build, and the numbers

The $0.10 model rendered to eight views, scaled to the dungeon's 23 px and to the 128 set's 79 px, snapped to
the creature's own palette (`pixel_dungeon/contact.png`, `pixel_128/contact.png`, top row the model, bottom row
the game's views):

| set | height spread | mirror IoU e/w | ne/nw | se/sw |
|---|---|---|---|---|
| model at 23 px | 7 px | 0.664 | 0.432 | 0.506 |
| model at 79 px | 20 px | 0.742 | 0.414 | 0.497 |

## 4. What the look says

- **The pipeline works end to end.** Model in, eight angle-true views out, in the game's palette, feet on one
  row, in about four minutes of machine time. The views agree with each other the way only one object can: the
  crest, the belly and the legs land where the turn says they should.
- **The model is the wrong creature, and that is my error.** Kithflare is an upright lizard holding a lantern
  with a curled flame tail. I wrote the prompt from a guess ("four-legged salamander") before looking at the
  sprite, and the Lite model followed the prompt over the four reference views. Measure the reference first
  means the design too, not only the pixels.
- **A pitched camera trades one consistency for another.** At 30° the back views show the tail and the rump
  from above, so the rendered heights vary (7 px at dungeon size against the drawn set's 2 px), and a lumpy,
  asymmetric model mirrors worse than a drawn set that is literally flipped. The numbers favour the drawn set
  on every row in section 3; they would not if the model were symmetric and posed, as the mech ape is after 24
  passes.
- **Animation.** The walk rig is the point of 3D: one rig, eight directions, every frame agreeing. The animate
  job is run and the renderer takes `FRAMES`; see section 6 for what came back.

## 5. Verdict and the next step (yours)

The method holds; the cheap model does not. Three ways forward, in order of cost:
1. **Meshy image-to-3D from the real sprite, 38 credits.** Reproduces what is in the image, so the upright
   lizard with the lantern, which answers the real question: does a faithful model give views that beat the
   drawn set's numbers. One job, then the same pipeline. Not run without your word; it is almost half the plan's
   monthly credits.
2. **A hand-built Blender model**, the ape's way (primitives, passes, a score against the sprite). Days, not
   minutes, and the mech session's lane.
3. **Keep the drawn set** and use 3D only for what it is best at here: the walk and action cycles of creatures
   whose rotations we already trust, from a model built to match them.

A fourth, honest option: the drawn views are already more consistent than a cheap model, so the pitch does not
need this. It is a tool for later creatures and for animation, not a fix for the ones we have.

## 6. The walk

The $0.08 animate job rigged the model and gave a 22-frame walk (Retro's own sheet: `rd_lite_walk_sheet.png`).
The renderer's `FRAMES` mode rendered six frames of it for all eight views in one pass (48 renders, about a
minute), and `pixel_walk/contact.png` shows south and east at the dungeon's size above the game's own walk
frames.

| | model (6 frames, rendered) | game (8 frames, Retro walk + hand fixes) |
|---|---|---|
| south: feet row drift across frames | 0 px | 1 px |
| east: feet row drift across frames | 0 px | 1 px |
| pixels changing between frames (256 px renders) | 750 to 3,900, so the legs do move | not measured |
| directions that share one motion | 8, by construction | 8 sheets made separately |

This is the part 3D is for. One rig gives the same step in every direction with the feet nailed to one row,
which the drawn walks only reach after the foot-row fixes in `dungeon.gd` (`FOOT_FIX`, the median rule). The
motion itself is small and stiff at Lite quality, and it is still the wrong creature, so it proves the pipe,
not the art.

## 7. Cost and balance

Spent $0.18 of Retro Diffusion's $0.29 ($0.10 model, $0.08 walk); $0.11 left. Nothing spent on the generation
server (Meshy preflight only, 38 credits of 84).
