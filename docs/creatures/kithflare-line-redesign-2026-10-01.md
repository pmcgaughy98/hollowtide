# Kithflare line redesign (PROPOSAL, 2026-10-01)

Preston: the line "feels dull and evolves into the same thing just a bigger version," like Rattata to Raticate. Everything here is a proposal until he approves it. Names stay Kithflare, Wayburn and Coalcrest unless he changes them.

## What went wrong

All three current fronts are the same animal: a grey four-legged lizard with an orange zigzag, standing in nearly the same pose, drawn 68, 82 and 94 cells wide. The old brief asked for changes in "mass, height and stance" but kept the body plan, so the output was a resize. It also shares Cinderhide's charcoal-and-lava palette, so the Ember roster reads as one grey reptile family.

## The new idea: carry the flame, run the route, become the light

The line keeps its existing lore hook (heat-light signals along a living marking, read by couriers), which ties it to the player being a courier. What changes is that each stage has a **different job, body plan and silhouette**:

| | Kithflare (I) | Wayburn (II) | Coalcrest (III) |
|---|---|---|---|
| **Job** | Carries a spark | Runs signals between towns | Is the beacon couriers steer by |
| **Body plan** | Small, upright, hops on big hind feet | Long, low, striding runner | Tall, upright, planted sentinel |
| **Silhouette** | Compact and round, tail curled over its back | Long horizontal line, neck frill fanned | Vertical tower, huge crest |
| **Signal organ** | A glowing ember bulb at the tail tip, like a coal carried in a lantern | A throat-and-neck frill that flashes patterns as it runs | The frill grown into a tall crest that blazes like a signal fire |
| **Temperament** | Curious, darting, always checking its spark | Restless, purposeful, never stays put | Patient, still, watches the river from the bluffs |

Lineage threads that stay in all three, so they read as one family: the cream angular throat mark, the zigzag marking (now amber light, not lava orange), the side-set slit eye, and three-toed feet.

**Palette, distinct from Cinderhide:** loess ochre, sandstone tan and warm umber hide, soot-brown shading, cream throat, with **lantern amber-gold** light (not lava orange). It matches the menu's bluffs and river towns, and no other Ember creature uses it.

**Readable from behind:** each stage has one big feature that shows from the back: the curled tail bulb, the fanned frill and the tall crest. That should make battle back views easier than Vitrecrag's shell, where the front and back silhouettes had nothing in common.

## Stage briefs

**Kithflare (Stage I).** A small, upright, gecko-like lizard that sits back on large hind feet, with short forelimbs held near the chest and a big head (about a third of its height). Its long tail curls up over its back and ends in a round ember bulb that glows amber, like a coal carried in a lantern. Cream angular throat mark; amber zigzag faint along the flank. Hide is sandstone tan with umber stripes. Pose: three-quarter facing right, perched mid-hop, glancing back at its tail light. About 50 to 60% of Wayburn's height. Avoid: dog, cat, cute baby proportions, wings, fur, open flames on the body.

**Wayburn (Stage II).** The body stretches into a lean, long-legged runner, low and horizontal, built like a basilisk lizard at full sprint. The tail bulb is gone, absorbed into the body: the amber zigzag now runs the whole length as a bright signal line. A new folded frill around the throat and neck (like a frilled lizard's) flares open as it runs, with the cream throat mark at its centre. Ochre hide, umber back. Pose: mid-stride to the right, frill half-open, tail straight out behind for balance. Avoid: the Stage I hop pose, horse or dog anatomy, armour plates, saddle, a resized Kithflare.

**Coalcrest (Stage III).** The runner stops running. It stands tall and upright on thick hind legs braced with its tail like a tripod, chest high, forelimbs folded, the tallest Ember silhouette. The frill has grown into a huge fixed crest behind its head, ribbed like a sail or a lantern's reflector, with the amber zigzag climbing into it and blazing at the top. Hide darkens to deep umber with sandstone bands; the cream throat mark sits at the crest's base. Pose: three-quarter right, head raised, looking out over a distance. Avoid: dragon wings, a mane, horns, armour, machinery, a bigger Wayburn.

## Moves (proposal; live move resources are not changed)

The existing names already fit this story. Suggested readings:
- Kithflare: **Signal Spark** (flicks its tail bulb), **Tail Brake** (tail swipe), **Shoulder Kindle**, **Handoff Dash** (rushes in and passes the spark on contact).
- Wayburn: **Relay Arc** (the signal runs the zigzag and leaps off the frill), **Shoulder Drive**, **Tail Shutter**, **Wayflare** (sprinting frill flash).
- Coalcrest: **Crest Signal**, **Furnace Bolt** (from the crest, not a chest furnace), **Plate Rake** (consider renaming to Crest Rake), **Longfire Burst** (signature candidate: the crest lights like a beacon and fires one long sustained beam).

## Making it

- Sprites now come from Retro Diffusion (8-direction). Make **Kithflare first**, alone. Approve it before Wayburn, and Wayburn before Coalcrest, using each approved stage as the reference for the next.
- Check each stage against the one before it at actual battle size: if the silhouettes could be swapped with a resize, reject it.
- Retro Diffusion is prepaid: estimate the cost before each run.

## Also recorded 2026-10-01

Preston scrapped **Vitrecrag and Slagglass for now**: their back views proved too hard to make. Their files and game data are preserved, not deleted. Fusern's line has no Stage II or III until he decides.

## First Retro Diffusion candidates (2026-10-01, not approved, not in the game)

Folder: `docs/creatures/kithflare-line-rd-2026-10-01/`. Made with RD Pro (128px front, each stage using the previous one as reference), then RD Rotate for 8 directions (each sheet is 3x3 cells of 160px; the centre cell is empty).

- **Kithflare:** clean and on-brief (upright gecko, tail lantern bulb). Finish is smoother and cuter than Cinderhide's gritty clusters. Rotation holds well, including the back.
- **Wayburn:** second take used; the first ran off both edges (kept as `wayburn_front_rejected_cropped.png`). Frill, zigzag and runner body read clearly; the tail tip grazes the left edge.
- **Coalcrest:** strongest design: tall, upright sail-crest sentinel. Its straight-from-behind view is weak (the crest flattens to a slab); its back three-quarter views are usable.
- Rotation outputs are smaller and coarser than the fronts (RD Fast model). Battle back views would come from the back three-quarter cells.
- Cost: $1.34 of a $2.33 balance (4 fronts at $0.18, 3 rotations at $0.10; about $0.32 more was deducted than the listed prices, unexplained). $0.99 left.
