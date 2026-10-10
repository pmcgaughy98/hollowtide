# Evolution and signatures

Preston, 2026-10-02. This is the mechanic. The part lists are the ones in `move-body-gate.md`. Proposed stats and the kit swaps in `legal-learnsets.md` are still not in the creature files.

## Evolution

A line is one creature, then one creature, then one creature. No branch, no second parent, no fourth stage. `CreatureRoster.validate_evolutions()` already rejects those.

Preston, 2026-10-09, chose Digimon option A. A win does not evolve anyone. There are no levels. A teammate evolves when its growth record meets three conditions in `EVO` (`scripts/dungeon/dungeon.gd`). The record is keyed by line and stage, so two of the same species share it.

The three conditions, all required:

- Knockouts: foes it downed.
- Floors: stairs it went down while it was still standing.
- One way, by line. Flank counts a hit from a pincer or on a sleeping foe (Kithflare, Listener, Dustkite). Took counts damage it took (Tallowroot, Fusern, Preostmar, Punchybun, Canvaswing). Ambush counts a hit on a sleeping foe (Rimefin). Slam counts a foe it shoved into a wall or another body (Cinderhide).

The first number of each pair is stage 1 to 2. The second is stage 2 to 3.

| Line | Way | Knockouts | Floors | Way count |
|---|---|---|---|---|
| Kithflare | flank | 3, then 6 | 2, then 4 | 4, then 8 |
| Tallowroot | took | 2, then 5 | 2, then 4 | 60, then 140 |
| Rimefin | ambush | 3, then 6 | 2, then 4 | 2, then 5 |
| Cinderhide | slam | 3, then 6 | 2, then 4 | 2, then 5 |
| Fusern | took | 2, then 5 | 2, then 4 | 60, then 140 |
| Preostmar | took | 3, then 6 | 2, then 4 | 50, then 120 |
| Punchybun | took | 2, then 5 | 2, then 4 | 50, then 120 |
| Listener | flank | 2, then 5 | 2, then 4 | 3, then 7 |
| Canvaswing | took | 2, then 5 | 2, then 4 | 50, then 120 |
| Dustkite | flank | 3, then 6 | 2, then 4 | 4, then 8 |

The bar fills toward the slowest of the three. When it is full, the creature evolves as the next floor begins: down the stairs, after a cleared dungeon, or on the floor after a faint. A faint does not undo an evolution. A final stage does not evolve.

Stage 1 can be ready on the third floor of the first dungeon, because that floor is the second set of stairs and the record asks for 2 floors. Stage 2 starts its own record at zero, and it asks for 4 floors, so a final form does not arrive in this three-floor dungeon.

Every floor rebuilds the team at full health. The evolution does not carry the old form's HP, and it does not heal by itself. The new form arrives with its own kit. Taught scroll moves stay. The old kit is not kept. An ultimate arrives only when that form's own list contains it.

## Signatures

A signature can be learned by another creature when `MoveGate.can_learn` passes. Every part on the move has to be on the body. Essence does not fill a gap.

The code flag `signature` is the ultimate. It takes the scene. It is not taught. Only the form whose move list already contains it may use it.

Four moves. `PlayerParty.try_learn` adds a fifth only by refusing. There is no teach screen yet. Evolution does not call `try_learn`. It installs the next form's kit.

Battle hides a move the body cannot learn. Coalcrest still equips Plate Rake in its file. The gate drops it from the buttons because that body has no shell. Molten Beam stays selectable. Vitrecrag has the chamber and the mouth. Unequipping it is a kit change, not this gate.

An empty part list on a move means the move is not gated yet. Strike is that kind of move.
