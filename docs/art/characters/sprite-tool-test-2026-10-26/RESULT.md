# PixelLab courier walk test, 2026-10-26

**Verdict: keep the RD walk.** PixelLab drew clean pixel art in all 8 directions, but the courier loses his satchel, goggles and dark eyes when he turns, his body never bobs, and his head drops up to 4 px on a turn. Fixing that means hand repair on about 30 frames, which defeats the point of a pipeline.

| Review lens (score out of 10) | PixelLab | RD (in game now) |
|---|---|---|
| Looks like our courier | 4.5 | 7.5 |
| Walk motion | 3.5 | 6.5 |
| Ready for the game | 5 | 7 |

## Better than RD
- Draws all 8 directions. RD's right and up-right rows are mirror copies of left and up-left (0 pixels differ, re-checked), so RD's bag jumps hips on those turns.
- Side walks have an even two-step rhythm. RD's left and right have a slight limp (a 5-frame step, then a 3-frame step).
- Loops close cleanly in 7 of 8 rows. RD pops at the loop seam in 5 rows.
- Clean output: no half-transparent pixels, nothing clipped, full dark outline. The south standing frame is almost a pixel copy of the reference.

## Worse than RD
- **Back view has no satchel** in any of its 8 frames (see compare_frame0_8x.png). The three back views disagree about the bag.
- **South walk is a shuffle**: feet separate by 2 px at most, and the bag is fully drawn in only 2 of 8 frames.
- **Eyes turn blue** in left, right and down-right (1 to 4 px a frame, re-measured). Front views keep dark eyes.
- **Side goggles fade** to a pale glint (left) or a grey lens (right).
- **No body bob**: the head top stays on one row in 6 of 8 directions (re-measured). RD bobs 2 to 3 px.
- **Head drops when he turns**: head top in the standing frame is 7, 7, 10, 8, 8, 7, 11, 10 against RD's 7, 7, 8, 8, 8, 8, 8, 9 (re-measured). That is about 5.6 screen px outdoors.
- North walk is two poses held for 4 frames each, so it reads as a stomp.
- Side views are 2 to 3 px shorter and visibly thinner at game size.
- Heads redraw 45 to 58% of their pixels every frame, which shows as shimmer. Two reviewers measured it. I did not see it by eye, because still images cannot show it.
- More colours (46 to 58 a frame against 26 to 40), drift in 3 rows, and a maroon far leg in right frames 5 and 6.

## Checking the reviews
- Dropped "pale debris": those pixels are eye whites and goggle glints, not loose specks.
- Correction: down-left also has 1 to 2 bluish eye pixels in 4 of 8 frames, not zero.
- The north flip holds: the left foot sits at 66 to 67 for frames 0 to 3, then at 72. My own split could not confirm the reviewer's right-foot numbers.
- Nobody checked these: the walk has not run in Godot; each direction got only one roll, and a re-roll could differ; nobody tried PixelLab's free fix tools or a palette clamp; the 8 rotations were not scored; one job in the queue (46dec11f) was not started by this run, and no charge from it was seen.

## Cost
- 9 generations spent: 1 to create the character, then 1 for each of the 8 walk directions.
- 11 of the daily bonus are left today. The plan has no other generations and $0 credits.
- PixelLab's help says the bonus adds 5 a day, up to 20. This trial plan runs one job at a time.

## How to view it
- `compare/compare_walk_all.gif`: both walks side by side at 8 fps. This is the only file that shows the shimmer.
- `compare/compare_rows_4x.png`: every frame, with RD above PixelLab.
- `compare/compare_frame0_8x.png`: a close-up of each standing frame. `compare/compare_ingame.png` shows real game size.
- In Godot: open `scenes/debug/sprite_tool_test.tscn` and press F6. Space pauses, and Left/Right steps one frame.
- **Load check not done.** Godot was open the whole time (three copies were still running at the end), so the scene has never been parsed. The PixelLab row will say "Missing or not imported yet" until Godot imports the new PNG. Focusing the editor once does that.

## Next options
1. **Keep RD for the courier.** Costs 0. This is my recommendation.
2. **Give PixelLab our own RD views and let it animate them.** Importing the 8 views costs 0.25, and the walk costs 1 per direction, so 8.25 in total, which fits the 11 left today. This would keep our art. It probably would not fix the missing bob or the head shimmer, which showed up in every direction, so a bob script would still be needed.
3. **Use PixelLab only to turn new NPCs.** One generation gives 8 views from one front, and the generate step saw the outfit hold in all 8. RD or hand work would then make the walk. The rotations have not been scored yet.

Files: `pixellab_courier_walk_native80.png` (atlas), `measurements.json`, `raw/`, `reference/`. All new, all untracked, nothing committed.

## Fix pass (2026-10-26)

**Verdict: generate-then-fix works as a salvage step, not as a replacement for RD.** Fixing each fault after generation lifted the PixelLab walk from 3.7 to 5.8 out of 10 (RD 7.7). Every fault moved, but about eight small hand touch-ups remain, and two of the biggest repairs (the north and south legs, the back bag) borrowed pixels from our RD walk. Keep RD for the courier.

Six free scripts ran in a chain on the raw atlas: head lock, height, legs, satchel, bob, colour. No paid or PixelLab generation calls. Result: `fix/pixellab_courier_walk_fixed_native80.png`.

### Fault by fault

| Fault | Fix used | Status | Evidence (raw to fixed) |
|---|---|---|---|
| 1. Back views have no satchel | satchel: RD back bag cut out, 2 px strap from the right shoulder | Fixed | Bag drawn 100% in all 24 back frames (raw mean 7 to 15%). All three back views agree. The bag is one rigid stamp, brown instead of RD's olive. |
| 2. No body bob | bob (six rows), legs (down, up) | Mostly fixed | Bob range 3,2,2,2,1,2,2,2, the same as RD (raw 0 in 6 rows). In down_left and up_right the bob dips on a legs-together frame (f2). |
| 3. Head drops on turns | head lock, then height (duplicated body rows) | Fixed, with a new problem | Standing head tops 7,6,7,7,8,6,7,7 (raw 7,7,10,8,8,7,11,10). Biggest turn step 2 px, same as RD. Side heads are now 26 to 27 px wide on 12 to 13 px torsos (RD 25 on 14), so the side views read top-heavy. |
| 4. Blue eyes, faded side goggles | head lock, colour | Fixed | Blue eye pixels 0 in all 64 frames. Teal lens in all 16 side frames. New: 2 white pixels on the down_left goggle edge in every frame. |
| 5. South shuffle, north stomp | legs (RD stride moved onto PixelLab's body) | Partly | South foot poses 4 to 8, north 3 to 6, feet match RD. South arms still barely swing, the new bag hides the hand in f0, f1 and f3, and up f3 has a leftover brown pouch (45 px). |
| 6. Head shimmer | head lock (one master head per direction) | Fixed | Head redraw 0.006 to 0.022 per frame (raw 0.26 to 0.58). With the shimmer gone, 1 px sideways head hops now show in a few frames. |
| 7. Colours, drift, maroon leg | colour (40-colour palette lock) | Mostly fixed | 39 colours in the set, 30 to 35 per row (RD 26 to 41). Maroon 0. New: peach skin colour on down_left trouser highlights (14 to 33 px a frame), RD's orange glove colour on back hands (up, up_right), skin shadow a little more orange. |

### Scores (out of 10, three judges, one lens each)

| Lens | RD | Raw | Fixed |
|---|---|---|---|
| Looks like our courier | 8 | 4 | 6 |
| Walk motion | 7 | 3 | 5.5 |
| Ready for the game | 8 | 4 | 6 |

All three judges: "usable with small fixes". These are a different panel from the first test above, so compare within this table only.

### Checking the judges (I re-measured the key claims)
- Confirmed: peach trouser pixels in down_left (raw and RD have 0), the up f3 pouch (it comes from raw frame 5 through the legs step's 2-frame re-time), the down_left goggle pixels, three new 1 px pinholes (down_left f4, right f1, down_right f0), the bob dip on legs-together frames, and down_left's feet floating 3 px in f5 to f7.
- Corrected: the south bag hides the hand in 3 frames (f0, f1, f3), not 5. In f2 and f7 the hand was already hidden before the bag step. The orange back hands are in up and up_right only, not up_left.
- Dropped: "side heads are still small and narrow." After the head lock they are 1 to 2 px wider than RD's, so the problem is now the opposite.
- Nobody checked: the walk in motion (GIF or a Godot window), the 0.9375 indoor scale, the scripts on any other character's walk (only the bob ran on RD's atlas), or how long the touch-ups take.

### What still needs work, cheapest first (all free)
1. Paint out the up f3 pouch (45 px) and fill the three pinholes with outline.
2. Put the down_left goggle edge pixels (2 px a frame) back to outline.
3. Recolour the down_left trouser highlights from peach to trouser tan, and the back-view hands from orange to skin.
4. Put the south hand back in front of the bag in f0, f1 and f3 (the satchel script's hand rule, 14 skin px, is too strict).
5. Move the down_left and up_right bob dip off f2 so it lands only on real steps, and drop down_left's feet 3 px in f5 to f7.
6. Your call: the side heads look big on thin bodies. Options are a frame head with its eyes repainted instead of PixelLab's rotation head, or 1 px more torso width.

Items 1 to 5 are small pixel edits or script settings. A paid PixelLab re-roll (animate_character, 1 to 2 generations per direction; 11 bonus generations were left on 10-26) would redraw heads and props and bring the shimmer back, so the whole chain would have to run again. Not recommended.

### How to view it
- `fix/compare/compare_walk_all.gif`: RD, raw and fixed walking together, 8 frames, about 7.7 fps. The only file that shows bob and shimmer.
- `fix/compare/compare_rows_4x.png`: every frame of every direction, RD over raw over fixed.
- `fix/compare/compare_frame0_8x.png` (close-ups) and `fix/compare/compare_ingame.png` (game size).
- Godot: open `scenes/debug/sprite_tool_test.tscn` and press F6. Three rows step together: RD, raw, fixed. Space pauses, Left and Right step one frame.
- **Load check: passed headless only** (2026-10-27: import exit 0, scene loads, 24 sprites all textured, no "Missing" labels). Not yet run in a window, so nobody has watched it move. The import also rewrote the tracked `project.godot.bak`.

Scripts: `tools/art/walk_fix/` (recipe in `docs/art/characters/walk-fix-recipe.md`). Every step's output and numbers: `fix/chain/` and `fix/chain/step_metrics.json`. Nothing committed.
