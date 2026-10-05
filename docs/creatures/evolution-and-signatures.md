# Evolution and signatures

Preston, 2026-10-02. This is the mechanic. The part lists are the ones in `move-body-gate.md`. Proposed stats and the kit swaps in `legal-learnsets.md` are still not in the creature files.

## Evolution

A line is one creature, then one creature, then one creature. No branch, no second parent, no fourth stage. `CreatureRoster.validate_evolutions()` already rejects those.

The creature that won the battle evolves, and only that one. One stage. It stops when `evolves_into` is empty. There are no levels. A different trigger needs Preston's say-so before it replaces the win.

HP carries over and is clamped to the new form. The win is not a heal.

The new form arrives with its own legal moves. The old kit is not kept. An ultimate arrives only when that form's own list contains it.

## Signatures

A signature can be learned by another creature when `MoveGate.can_learn` passes. Every part on the move has to be on the body. Essence does not fill a gap.

The code flag `signature` is the ultimate. It takes the scene. It is not taught. Only the form whose move list already contains it may use it.

Four moves. `PlayerParty.try_learn` adds a fifth only by refusing. There is no teach screen yet. Evolution does not call `try_learn`. It installs the next form's kit.

Battle hides a move the body cannot learn. Coalcrest still equips Plate Rake in its file. The gate drops it from the buttons because that body has no shell. Molten Beam stays selectable. Vitrecrag has the chamber and the mouth. Unequipping it is a kit change, not this gate.

An empty part list on a move means the move is not gated yet. Strike is that kind of move.
