# Dungeon combat: position is power (Claude, 2026-10-09)

**Preston, 2026-10-09:** "We should have enough game scrapes from other games to synthesize and create the best combat system for our dungeon mode right? Go ahead." Dungeon fights stay turn-based; the arena is its own mode.

## The system, synthesized (structure only, nothing copied)
Explorers of Sky gives the base: a grid, turns, a team in a chain, sleeping rooms. What makes a turn-based grid fight deep in the other references is **where you stand**, not bigger numbers:
- **Into the Breach:** enemies show their plan first, and pushing them into walls or each other is the game.
- **Hoplite:** how you approach is how you attack.
- **Rescue Team DX:** team tactics, linked moves, the Awakened power-up.
- **Smite and the arena:** crowd control that interrupts, and follow-ups.

Five pillars, one slice each:
1. **Position is power** (built here): ambush, pincer, shove and slam.
2. **Read the enemy** (built earlier): wild creatures mark their strong moves a turn ahead. A slam now breaks the move it was gathering.
3. **Team tactics** (next): partners walk to pincer tiles on their own, and one key switches them between follow, go after, and guard.
4. **Links and Awakened:** two of your team hitting the same foe in one turn makes a LINK; a full lantern or an item makes a creature Awakened for a floor.
5. **Terrain:** water and silt tiles that a shove can push a creature into.

## What is built (`scripts/dungeon/dungeon.gd`)
- **AMBUSH:** a hit on a sleeping wild creature does x1.5.
- **PINCER:** a hit on a foe with one of the attacker's team on the tile right behind it does x1.5. Wild creatures pincer you too.
- **Shove:** a charge (a dash move such as Ember Feint) pushes the creature it hits one tile further.
- **SLAM:** if a wall or another creature is in the way, the creature loses 15% of its max HP and its next turn, and any move it was gathering is broken. A creature it slams into takes the same knock.
- **The leader can be slammed too:** the next key press only spends the turn ("still reeling").
- The numbers (`AMBUSH`, `PINCER`, `SLAM_SHARE`, `SLAM_STAGGER`) are drafts for Grok.

## The hallway back-and-forth, fixed
Preston: "its doing the walk back and forth glitch again... its when I walk in hallways."
- **Cause:** when the leader's path was blocked by a partner, it swapped with whichever partner came first in its list, sometimes the one behind it. In a one-tile hallway the two then traded tiles every turn.
- **Fix:** `_step_toward(i, goal, through_team)` treats a teammate's tile as open, so the leader only swaps with a partner who is on its way.
- **Measured:** pacing went from about 2,200 cases to 6 over four runs (`tools/debug/dungeon_pace_check.gd`). A hand-walked hallway shows zero sprite reversals.

## Check (`tools/debug/dungeon_position_check.gd`)
| Case | Result |
|---|---|
| Ambush | x1.65 against the awake average |
| Pincer | x1.55 |
| Shove into open floor | moved one tile |
| Slam into a wall | stayed put, SLAM shown, wind-up broken, the next turn skipped (the leader took 0) |
| Slam into a body | both hurt |
| Reeling leader | the press did not move it; the next press did |

The still is `slam_wall.png`. The four earlier dungeon checks pass, and every autopilot run reaches B2F.
