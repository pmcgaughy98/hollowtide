# Highbank, the whole map: what we measured and what we build, 2026-10-28

Preston: "Go ahead wire up not just the buildings but the whole map. the area around the buildings etc. Like mystery dungeon, but obviously use the synthesis to upgrade and be original from mystery dungeon and enhance the concept and idea." Earlier the same day: the buildings are "to small and shack like" and "something doesnt feel right with the perspective of the builgins".

Explorers of Sky's town is read for **structure only**. Nothing is copied: not a shape, not a layout, not a palette.

## What the reference measures (Treasure Town, native pixels)

Sources: the stitched town background (1152x504) and an in-game shop screenshot (256x192), both from Bulbapedia. Measured by eye at native size, so these are ranges.

| | Treasure Town |
|---|---|
| A character | about 22 to 26 px tall |
| A shop | about 90 to 120 px wide, 110 to 120 px tall: 4 to 5 characters wide, about 5 tall |
| A house (tent) | about 70 x 75 px: 3 characters each way |
| **Roof against wall** | **roof or crest 60 to 75% of the height; walls 25 to 35%**, a short band at the foot |
| The door | a coloured mat on the ground in front, wider than the door, on the road's edge |
| Around each building | its own clearing: a ring of rocks, bushes or fence bits; the keeper's goods on tables seen from above; a signpost by the road |
| Spacing | a building every 85 to 170 px along the road, with yard and grass between |
| The road | one dirt road across the whole town, about 30 to 35 px wide (1.5 characters), branches to buildings set back from it |
| The edges | landscape, not walls: tree canopy along the top, cliffs and a waterfall along the bottom, gate markers where the road leaves |
| Scatter | rocks, flowers, stumps, pots, log piles, always in clusters of 3 to 5, never one alone |

## Why ours feels wrong

1. **Inverted perspective.** Our building classes give the walls 60 px and the roof 36 px (`scripts/town/building_template.gd`): walls are about 62% of the height. The reference is the reverse. Tall walls with a thin roof read as a front elevation, a flat cutout, instead of a building seen from above at three-quarters. This is most of the "something doesn't feel right".
2. **Shallow footprints.** Bases are 2 tiles deep, so nothing sits on the ground in front: no mat, no stock, no step.
3. **Packed in a row.** Buildings stand shoulder to shoulder along the street, so the street reads as a wall of boxes. The reference gives each building its own clearing.

## What we build (the synthesis: their structure, our town)

Highbank keeps its own shape: the bluff, the river and the ferry, the forest to the west, Wayline Tower on its rise. These rules replace the boxes:

1. **Roof first.** Every class: roof 60 to 70% of the canvas height, walls 30 to 40%, and the roof's top surface shows (we look down on it). A rule in the template, checked by `building_template_check`.
2. **Bigger, by the character.** Measure our town characters first, then size shops at about 4 to 5 characters wide and 5 tall, houses about 3 by 3. (Not measured yet: our town character height.)
3. **Every building gets a yard.** A new place part, `yard`: the ground in front and around (packed earth, stones or boards by trade), its edge (rocks, hedge, fence bits), the door mat or step, and the keeper's goods laid out on the ground, seen from above. The yard says what the building does before the sign does.
4. **Ours, not theirs: shaped by the keeper's trade.** Treasure Town shapes each shop like its keeper's head. Ours are shaped by what the keeper does and owns: the Item Shop is a lean-to grown out of its own stock heap, Storage a boathouse on the landing, Home dug into the bluff. Keep that.
5. **One road, worn paths.** A main way through each area, narrowing to footpaths that end at each door. The wear shows where people walk.
6. **Edges are landscape.** The bluff, the river, the forest and the cliff close each area, with a marker where a way leaves (the ferry post, the Tower steps, the forest arch).
7. **Clusters.** Scatter in clusters of 3 to 5 with one big piece, never alone. A placeholder rule in the props painter.
8. **Beyond the reference:** depth sorting so characters walk behind roofs and in front of yards, and each yard changes with the story (the Item Shop's stock thins after the parcel theft, the Shrine's clearing lights when the stone is set).

## Slices (one at a time, each checked)

1. **The perspective rule and a bigger Item Shop in its yard.** Measure our characters; change the class geometry to roof first; rebuild `lean_to` at the new size; add the `yard` part and the Item Shop's yard on the street; update the slot and Codex's cx-16 brief.
2. **The street around it:** the main way, footpaths to each door, edges and clusters; Home dug into the bluff.
3. **The Ferry Ward:** the Storage boathouse and the landing yard.
4. **Tower Rise and the forest edge.**
5. **The town map render and a walk-through check.**

## Tools used for this (synthesis ledger)

| Tool | What it gave |
|---|---|
| Firecrawl search | Nothing: the account is out of credits. |
| Built-in browser | The Spriters Resource page sits behind a bot check (not bypassed). Bulbapedia's Treasure Town page gave the two image links. |
| curl and PIL | The two reference images, sizes confirmed (1152x504, 256x192). |
| Claude, looking at native size | The measurements above. |
| Our code | The current class numbers (walls 60, roof 36, bases 2 deep). |
| Not used | Gemini (its numbers have been wrong before), the paid image tools (no generation without Preston's yes). |

## Corrections (Claude, 2026-10-28, later the same day)

Two statements above are wrong, and the plan changed in one place:

1. **"Walls are about 62%" is wrong.** That came from the class numbers (wall 60, roof 36), not from the painting. Measured on the painted shop: the roof is about 56% of the height and the wall about 43%. The real finding still holds: our roofs are a smaller share than Explorers of Sky's (60-75%).
2. **"The door is twice a character's height" is wrong.** I measured the dungeon-size sprites. The town set is 1.5x. Measured town body heights: Punchybun 29, Kithflare 32, Tallowroot 34, Sparkjab 46, Starward 55 px. The 48 px door is about one Sparkjab, which is right. The buildings were too small: the old 144 px shop was about 3 Sparkjabs tall, against about 5 characters for an Explorers of Sky shop.
3. **Rule 3's new "yard" place part is dropped.** "yard" is already the Training Yard's id. Dooryards are built from paths plus props, with no schema change.

## Built: slice 1 (2026-10-28)

- `trading_post` class replaces `lean_to`: base 8x3, canvas 204x192, the roof the top 128 px (67%), the front a 64 px band ("eave"), the door 48 px (25%). building_template_check asserts roof at least 60%, door at most 26%.
- The street grew from 16 to 19 rows. Buildings moved down 2, the lane down 3, so a two-row dooryard sits between each front and the road.
- The Item Shop's dooryard: a trodden forecourt, goods tables either side, crate stacks against the walls, rock clusters closing the ends. Three new Grok prop slots in batch gb-10-dooryards (goods_table, crate_stack, rock_cluster). A door mat was tried and dropped: the town rule keeps the step in front of every door clear.
- Checks passing with HT_HIGHBANK_V2=1: building_template, art_slots, area_data, hub_town, town_props, tower_lean, town_loop, town_room, board_scene, job_board, music, tower_reveal. Not yet run: storage, evolution, stone, the v1 subset. Not yet seen in a game window.
