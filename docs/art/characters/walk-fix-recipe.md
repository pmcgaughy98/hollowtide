# Walk fix recipe: generate, then repair like a pixel artist

Learned on the PixelLab courier walk, 2026-10-26 (`sprite-tool-test-2026-10-26/RESULT.md`, "Fix pass").
It took that walk from 3.7 to 5.8 out of 10 against RD's 7.7. Use it to salvage a generated walk, not to skip art direction.

**Input:** one 640x640 atlas, 8 rows by 8 frames of 80 px cells, rows in the order down, down_left, left, up_left, up, up_right, right, down_right, feet on y=72, alpha only 0 or 255.
**Rules for every step:** whole pixels only, no blur or resizing, alpha stays 0/255, feet stay on 72, measure before and after, and look at the result at 4x and at game size (1.40625).

## 0. Measure the raw walk first
`python tools/art/walk_fix/measure_walk.py RAW.png raw.json`. Measure the walk you compare against too (RD for the courier). Write down each fault as a number before fixing it.

## The chain (this order; scripts in `tools/art/walk_fix/`, each runs as `python SCRIPT IN.png OUT.png`)
1. **fix_headlock.py**: head shimmer, wrong-colour eyes, faces that change per frame. Pastes one master head per direction and moves it with the body.
   Measure: head redraw per frame under 0.03; wrong eye pixels 0. Look at the chosen heads at 8x: the master can be a different drawing (new brow, mouth, glint).
   Needs: a collar colour to cut the head at (teal here) and, if you have them, the generator's rotation images.
2. **fix_height.py**: head drops when the character turns. Duplicates whole body rows in short directions only.
   Measure: head-top spread across the 8 directions 2 px or less, feet still on 72. Reads alpha only.
3. **fix_legs.py**: shuffling south walk, stomping north walk. Moves a donor walk's legs (RD here) onto the generated body in the down and up rows and re-times the arms.
   Measure: `measure_legs.py RAW FIXED OUT_DIR`; foot poses per row (8 is ideal), leg shape change never near 0.
4. **fix_satchel.py**: a prop that is missing or pops in and out. Cuts the best-drawn prop from the same row (or a donor back view) and pastes it in every frame.
   Measure: share of the prop drawn per frame (`satchel_report.py`); dark outline share must not fall.
5. **fix_bob.py**: no body bob. Removes or duplicates one hip row so the head is 1 px low on contact frames.
   Measure: head-top range per row matches the reference (1 to 3 px). Skip rows step 3 already bobbed.
6. **fix_colour.py**: too many colours, drift, wrong-colour eyes, lenses or limbs. Locks every pixel to a 40-colour palette (reference frame plus a few donor colours) and repairs eyes, side lenses and off-colour legs.
   Measure: colours per frame at or under the reference; palette distance near 0; then check skin colours have not leaked onto clothes.
7. **Hand touch-up**: holes, stray glints, leftover pieces. Find them with the enclosed-hole count in `measure_walk.py` and by eye at 8x.
8. **Look:** `build_fixed_compare.py FIXED.png` writes the 4x rows sheet, the game-size sheet and a GIF (into the courier's `fix/compare/` folder, so change its output path first for another character). Watch the GIF, then the walk in Godot (`scenes/debug/sprite_tool_test.tscn`, F6).

`compose_walk.py` runs steps 1 to 6 and measures each one, but it is hard-wired to the courier's raw atlas. For another walk, run the scripts one by one or copy it and change the input path.

## Before using it on a new character
- headlock, satchel, legs and colour read courier files (rotation images, the raw PixelLab atlas, the RD atlas, the reference frame). Point them at the new character's own files first; each script's docstring lists them.
- Steps 3 and 4 need a donor: an existing good walk or prop drawing. Without one, those faults need hand drawing or a re-roll.
- Only bob and height were tested on a second atlas. Treat the rest as unproven on other art.

## Warnings learned here
- Order matters. Satchel before legs erased the new back bag. Colour first made the head lock pick worse heads. Height before head lock overshot by 1 to 2 px.
- A fix can expose a fault the noise was hiding: locked heads revealed 1 px sideways head hops.
- A fix can create one: the bag hid a hand, a re-timed body carried a leftover pouch, the palette lock put skin colour on trousers, pasted heads left pinholes at the neck.
- Heavy finishing flattens shading (the colour lock lost 3.3% of light and shadow steps). Check ramps by eye.
- Bob phase from a period-4 stride is wrong on rows with only one real step per loop.
- A paid re-roll undoes the chain. If you re-roll a direction, run the whole chain again.
- Still images cannot show shimmer or bob. Do not call it done until someone has watched it move.
