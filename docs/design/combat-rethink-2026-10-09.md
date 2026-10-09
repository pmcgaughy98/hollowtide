# Rethinking the combat (2026-10-09)

> **Reversed the same night (Preston, 2026-10-09):** "We'll keep arena style for another mode, let's keep the dungeon combat turn-based." `real_time_battles` now defaults to false in `scripts/dungeon/dungeon.gd`; the switch and `hollow_floor.gd` battle mode are kept but off. The arena is its own mode.

The ideas below that make turn fights richer (approach, rooms, Awakened, team tactics, linked moves) still apply on the grid.

**Preston, 2026-10-09:**
- "Let's really rethink the combat and movement system. It kind of feels like we'll be removing a lot of dynamic combat because it will be turn-based and just regular mystery dungeon combat."
- Then: "In my head I was thinking we could keep the movement turns for encounters, then when the battle starts it's kind of arena style. I just want there to be more mechanics and dynamic combat, like the mystery dungeon they made for Switch."

Everything here past "built" is a proposal.

## The shape: explore in turns, fight in real time (built)
- **Exploring** stays Explorers of Sky: a grid, one step at a time, the team in a chain, sleeping wild creatures, items, traps, the lantern, stairs.
- **A fight** starts when an awake wild creature comes within 5 tiles in sight. At that moment the arena engine takes over the same floor:
  - the same painted picture;
  - every creature from the tile it stood on, with its share of health;
  - your whole team, and every wild creature awake within 8 tiles or asleep in your room.
- **During the fight** you have the arena's controls: steering, dash, aimed basic, abilities 1 to 3, signature, charm. Partners fight with Kit Sense. Walls are the dungeon's walls.
- **When it ends**, everyone snaps back to the nearest open tile with what they kept. The turn count and the lantern move on by the fight's length. A beaten wild creature may ask to join.
  - Your leader going down ends it (a mystery dungeon rule).
  - Running about 9 tiles from every foe for 1.5 seconds ends it as an escape.
- Write-up: `docs/design/dungeon-hybrid-2026-10-09/README.md`. The old turn-for-turn fighting stays as an option (`real_time_battles = false`), with bump attacks and enemy warnings.

## What the references add, as structure
- **Rescue Team DX (Switch; Serebii's mechanics page):**
  - Auto Mode explores until a creature is near: our Tab autopilot already does this.
  - The Awakened state powers a creature up, and its Linked Moves always land critical: our signature meter and the arena's follow-ups.
  - Rare Qualities are team-wide passives: our charms and passives.
- **Into the Breach:** enemies show their plan one turn ahead; pushing them into walls, each other or each other's attacks is the game. The arena has telegraphs, carries and wall slams; a dungeon room has real walls, so they matter more here than on the open pitch.
- **Hoplite:** how you move is how you attack: moving between two tiles beside an enemy stabs it, moving straight at one lunges. Here that becomes the approach: how you walk up to a fight decides how it starts.

## Proposed next mechanics, one slice each
1. **The approach matters.** This is the bridge between the two halves.
   - Walk up on a sleeping creature and the fight starts with it still asleep for a moment: free hits, Hoplite's lunge.
   - A creature that saw you first gets the first move.
   - Your partners start where they stood in the chain, so formation in the hallway is a choice.
   - Dungeon terrain (water, silt) carries into the fight.
2. **Rooms as arenas.** Floor recipes put the arena's rocks and crates in rooms: breakable, throwable, with shards. Wall slams and carries are already in. Monster Houses become proper arena brawls.
3. **Awakened (DX).** An item, or the run's lantern at full, fills the signature meter and powers a creature up for one fight. Finals already have signatures.
4. **Team tactics mid-fight (DX).** A key cycles partners between go after foes, stay close, and guard the leader. Kit Sense already has these modes.
5. **Linked moves on screen.** The arena's follow-ups (an ability, then the basic inside the window) shown as "LINK!", stronger while Awakened.
6. **Fights that grow.** A wild creature that wakes or wanders within reach during a fight joins it. Today the rest of the floor waits.

## Open questions for Preston
- Should fleeing cost something, like lantern light?
- How far should a fight reach? Today it's 8 tiles from the leader, and the rest of the floor waits.
- Should the turn-based fighting stay as an option (an easy mode, or for players who prefer it), or be removed?
