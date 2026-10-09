# Terrain in motion (Claude, 2026-10-08 night, item 5)

The last item of Preston's "more dynamic like the 2D arena video" list. The video's terrain moves: Onix tunnels and leaves a trench, Lapras surfs on a path it freezes, platforms float. The arena had terrain that stays put (glass pools, lava seams, shards, star fields, still water). Now two kinds move or are made by moving.

## Trenches
Every burrowing move (Tallowroot's Burrow, Rimefin's Dive, Scourmaw's Sinkhole) leaves a **trench** along the tunnel when its user surfaces: a dark torn line with broken edges on the floor layer, water-dark for the Tide line and earth-dark for the rest, 9 px either side, for 8 s. Enemies crossing it move at 0.6 and **cannot dash across it** (dashes, dodges and Space are refused on broken ground); the burrower's own team crosses free. A burrow is now a way to cut the pitch in two for eight seconds.

## Whirlpools that hunt
A Riptide no longer sits where it was cast: it **drifts** toward the nearest enemy within 90 px at 18 px a second, so a kiter has to keep moving away from it and a pressed creature finds the water following it. Everything else about it is unchanged (the drag to its centre, the slow, no movement abilities inside, the Conduct and Overgrow combos read it).

Not taken from the video: floating platforms (no water arena yet) and an ice path (no Ice creature yet). Both are the same verb as the trench with a different owner rule, when the lines exist.

## Check (`tools/debug/arena_terrain_check.gd`)
- After Tallowroot's burrow a 120 px trench was laid; an enemy standing on it moved at 0.60 and its dash was refused; the ally beside it moved at 1.00.
- In one second a riptide drifted 18 px toward the enemy 60 px away.
- A trench at the end of its life was gone after its 8 s.
- Stills here: `trench.png`, `riptide_drift.png`.

## Known
- A trench is drawn as a straight line between where the burrower went under and where it came up; the tunnel itself is not animated.
- **Grok:** the width, the slow, the 8 s and the drift speed are drafts.
