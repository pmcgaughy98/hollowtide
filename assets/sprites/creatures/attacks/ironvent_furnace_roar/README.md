# Ironvent Furnace Roar (attack-sheet protocol, 2026-09-28)

Ember essence. Preston's three Opal sheets in
`OneDrive/Documents/HollowTide Sprites/Effect Sheets/IronVent Effect/` (originals untouched):
`Furance roar sheet 1.jfif`, `Furnace roar sheet  2.jfif`, `Furnace roar 3.jfif`.

Direction: the Ember physiology brief (`ember-creature-physiology-and-action-brief-2026-09-27.md`, OneDrive docs)
reads Ironvent's line as living heat regulation and Furnace Roar as "a broad pressure release from the head/vent
system"; the move set calls it "a full warning vent becomes a crushing blast". So heat fills the ridge, the head
rears, and the roar releases a pressure wave rather than a projectile.

Research and MCP: same session as Molten Cannon (animation pipeline research read; Summer editor debugger in use).

## Cutting

`tools/cut_ironvent_furnace_roar_sheets.py`, one block per sheet row (every frame in a row is drawn at one scale;
matching each frame's height on its own shrank the rearing poses). The in-game sprite is 96x81 on 100x100.
`tools/build_ironvent_furnace_roar.py` snaps to the in-game colours, clears crumbs and registers on the in-game
foot line and tail edge.

## Every frame

| Frame | What it shows | Beat | Decision |
|---|---|---|---|
| roar1_f00 | Idle | rest | **keep: rest** |
| roar1_f01 | Heat rising in the ridge | anticipation | **keep: warm** |
| roar1_f02 | Ridge full and bright | anticipation | **keep: pressure** (brace, tremble) |
| roar1_f03 | Head rears, glow in the mouth | wind-up | **keep: rear** |
| roar1_f04 | Jaws opening wider | wind-up | **keep: open** (cut-in plays here) |
| roar1_f05 | Near idle, ridge warm | rest | reference |
| roar1_f06 | Head up, jaws closing | follow-through | **keep: settle** |
| roar1_f07 | Jaws wide, head high | release | **keep: roar** |
| roar1_f08 | Back down, ridge warm | recovery | **keep: cool** |
| roar2_f00 to f02 | Three idles, one with the ridge blazing; drawn wider than sheet 1 | rest | reference |
| closeup (sheet 2) | Big close-up of the roar, full body | release | **keep: cut-in** (`built/cutin.png`, shown at 3x) |
| roar3_f00 to f02 | Idles | rest | reference (duplicates sheet 1's rest) |
| roar3_f03 | Lunging, fire bursting from the jaws | release | reject: legs hidden behind the strip below |
| roar3_f04 | Bigger burst with glow | release | reject: legs hidden |
| roar3_f05 | Jaws closing, crest up | follow-through | reject: legs hidden |
| sheet 3 bottom strip | Lower body only (tail, belly, legs) | none | not cut: no head or torso, and a different scale from the close-up, so it cannot complete anything |

Preston asked whether the cut-off frames could be completed. They could only borrow legs from sheet 1's upright
frames, which would sit wrong under a low lunging body, so the burst they show is drawn in code instead.

## Final timeline

| # | Frame | Hold | Code |
|---|---|---|---|
| 0 | rest | 0.08 | overheat starts climbing on the ridge |
| 1 | warm | 0.25 | |
| 2 | pressure | 0.60 | brace tremble |
| 3 | rear | 0.20 | |
| 4 | open | 0.70 | cut-in: dark band, close-up slides in from Ironvent's side, holds 0.4 s |
| 5 | roar | 0.60 | RELEASE: `ironvent_roar_blast.tscn` at the mouth (27, -26): five pressure arcs aimed at the target plus a flame burst; shake 30; heat flare |
| 6 | roar | 0.25 | HIT (the old `ironvent_furnace_roar.tscn` impact art) |
| 7 | settle | 0.25 | |
| 8 | cool | 0.30 | back to idle |

## Open

- Frames are a little darker than the in-game sprite and keep a faint magenta edge (Codex style-match pass).
- Awaiting Preston's review in play (`scenes/ironvent_roar_preview.tscn`).
