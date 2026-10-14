# Ballastak, eight directions (proposal art, Claude, 2026-10-13)

Preston: "First skill up using the synthesis, then lets try to make a new hollowtide creature." Ballastak is the Stone
digger line's stage 1, already named in the roster with its job ("slow, high attack, shovel and claws"; DESIGN_RULES.md)
and a brief in `docs/creatures/creature-roster-draft.md`; no new species and no new name. It had no art.

**Status: proposal.** DESIGN_RULES.md puts art after the line's numbers (Grok) and Preston's approval, so nothing here
is in `assets/`. Approving it means: Preston likes the look, Grok writes the numbers, then the dungeon set and walks.

**How it was made** (the pipeline in `docs/design/sprite-generator-skillup-2026-10-13.md`):
1. Master, southeast view: Nano Banana 2.1 through SpriteCook (12 credits), the brief as the prompt, five in-game
   sprites as the house-style guide (Preostmar, Troughspine, Tallowroot and two Kithflare views), at the game's scale.
2. Eight directions in one 3x3 grid (12 credits), the master as the reference, so every view is the same creature.
   The model laid the cells out facing the centre, the way rotate sheets do; directions were assigned by what each
   cell shows. The sheet was sliced by connected shapes, with merged neighbours cut at their emptiest columns.
3. Preston, the same day: "the raw from banana was better." The views are the raw Nano Banana pixels, untouched:
   `tools/art/slice_grid.py` only cuts the sheet and places each view on the game's 128 canvas, feet on row 104.
   (A version through `tools/art/finish_sprite.py` at 24 colours lost the face line work, and he preferred the raw.)
   He also ruled out Preostmar as a style reference ("one of the worst ones"); the next generation uses Tallowroot.

| | Ballastak set | drawn Kithflare set |
|---|---|---|
| height spread across eight views | 2 px | 4 px |
| mirror match e/w, ne/nw, se/sw | 0.94, 0.94, 0.99 | 1.00, 0.61, 0.66 |
| colours per view | about 1,800 to 2,100 (raw shading) | 18 to 24 |
| grid se against the master se | 0.84 shape match | |

Files: `views_128/<dir>.png` (the eight views), `ballastak_se.png` (the finished master), `contact_128.png`,
`look_se.png` (beside Tallowroot and Kithflare), the raw generations, and `_sheet_finished.png` (the rejected finished sheet).
SpriteCook asset IDs are in `docs/art/spritecook-assets.json`. 24 credits spent, 7 left.

## East and west, fixed (Preston: "Just needs the east and west fixed")
The grid's middle-row cells were three-quarter views turned toward the camera, near duplicates of se and sw. East is
now a true side profile: an edit of the old east cell with GPT-Image-2 at low quality (2 credits), then a second edit
for the pointed spade snout and a more compact body (2 credits), placed at native pixels with no stretching. West is
its mirror, as in the drawn sets. The replaced cells are kept in `_three_quarter_e_w/`. In profile Ballastak stands
56 pixels tall against about 71 for the other views: a long, low digger. If the shoulders should stand higher there,
one more edit costs 2 credits.
