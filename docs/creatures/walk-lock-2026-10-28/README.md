# Walk lock, 2026-10-28

Preston asked to fix every creature's walk and back views without spending money, one creature at a time. His examples:
- Tallowroot paddles forward as if it walks on its paddles.
- Some creatures move limbs they don't need to.
- The water skimmer (Skimlet) still has water around its legs.
- Sparkwick and others point northeast when going north, or the other way round.
- Some look like they float, and their shadow is wrong.

## Method (free, `tools/art/walk_lock.py`)

Two modes. **Lock** (the default) keeps Retro Diffusion's legs. **Step** (creatures listed in `STEP`) uses no Retro Diffusion pixels at all: the still's own outer feet take turns lifting. Step suits squat bodies, and any creature whose Retro Diffusion legs walk on the wrong limbs.

The Retro Diffusion walks redraw the whole creature every frame: about 60% of the body's pixels change colour between frames. The lock keeps each facing's still as the body and moves it as one piece. Only the legs come from the Retro Diffusion frames, recoloured to the still's own colours.

How it decides what moves:
- **Legs:** the narrow pieces at the bottom that stand under the torso. A tail lying on the ground stays part of the body.
- **Bob:** the body rises 1 px while the legs pass each other, twice a cycle.
- **Feet:** they never go below the still's own foot row (the game's rule: the lowest row with 4 or more pixels). So a creature no longer drops or rises when it starts walking.

The originals are kept in `before/<name>/<set>/`. The tool always reads from them, so running it again gives the same result.

## Audit (`tools/art/walk_audit.py`, results in AUDIT.md)

The audit gives one line per creature and does not judge anything for you. Its flags are leads to check by eye. The facing test in particular flags creatures that are lopsided by design, such as a tail curled to one side.

## Review videos

`python tools/art/review_videos.py [name ...]` records `scenes/debug/creature_review.tscn` (the dungeon's finish, shadow, foot rows and bob) with Godot's Movie Maker, one mp4 per creature, into the Hub's `06 Creative Projects/Hollowtide/Creature review videos 2026-10-28/`. Preston lists issues there by creature, part number and view. Re-record a creature after fixing it.

## Done

| creature | sets | shimmer before -> after (dungeon) | notes |
|---|---|---|---|
| kithflare | dungeon, town, small | 0.54-0.70 -> 0.14-0.23 | Back views read as backs; north still left as drawn. Feet on the still's line in all 24 facings. |

## Tried and reverted

Both are back on their original walks (the `before/` copies), and `walk_lock.py` now refuses them (`REVERTED`). Preston, 2026-10-28: "revert to originals we'll worry about them some other day they are just placeholder right now anyways but they would like require regeneration".

| creature | what was tried | why it was turned down |
|---|---|---|
| tallowroot | Step mode: only the two outer hind feet lift 1 px in turn, no Retro Diffusion pixels. | Preston, after Archroot's stride: "same with tallowroot". |
| archroot | S, N, NE and NW only (Preston said those four gallop). Step mode, then stride mode (the left and right halves of the bottom edge lift 2 px in turn). | "The limbs look still now", then "that doesn't work". Its dungeon shadow fix (FOOTPRINT_SHADOW) stays. |

What it showed: moving a still's own pixels a pixel or two cannot make a walk read as a walk on these two bodies. They need new walk art drawn from their stills.

## Next, in order

1. Skimlet: remove the water from its walk; its north still is flagged as turned.
2. Sparkwick: north points the wrong way; its limbs move 0.62.
3. The rest by flags: the biggest shimmer and limb movement first.

Shadows: dungeon.gd draws one 16 by 6 oval at the sprite's middle for every creature. It is not under the feet when they sit off-centre (by up to 13.5 px for Stormwick), and it is small under stage 3s. This is one change in dungeon.gd and is not done yet. Per creature so far: Archroot joined Troughspine in FOOTPRINT_SHADOW (a shadow fitted to the whole body in each pose; Preston, 2026-10-28). It stays after the walk revert.
