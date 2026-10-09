# Explore in turns, fight in real time (Claude, 2026-10-09)

> **Reversed the same night (Preston, 2026-10-09):** "We'll keep arena style for another mode, let's keep the dungeon combat turn-based." `real_time_battles` now defaults to false in `scripts/dungeon/dungeon.gd`; the switch and `hollow_floor.gd` battle mode are kept but off. The arena is its own mode.

**Preston, 2026-10-09:** "Keep the movement turns for encounters, then when the battle starts it's kind of arena style." The why and the next steps are in `docs/design/combat-rethink-2026-10-09.md`.

## How it works
- **`scripts/dungeon/dungeon.gd`** runs the switch.
  - At the end of a turn, a wild creature that is awake, within 5 tiles and in sight starts a battle.
  - `_start_battle` gathers your team and the wild creatures awake within 8 tiles of the leader or asleep in its room. Each one carries its tile position (in pixels), its share of health and its facing.
  - It hides the dungeon's screen and hands everything to the battle scene.
  - `_end_battle` takes back each creature's health share and snaps it to the nearest open floor tile, never two on one.
  - The turn count advances one per second of fighting and the lantern drains to match. Each knockout relights the lantern.
  - A beaten creature may ask to join.
  - `_watch_battle` ends the fight as an escape if the leader stays about 9 tiles from every foe for 1.5 s.
- **`scripts/hollow/hollow_floor.gd`** plays the fight. It already ran the arena on a generated floor, and now has a battle mode:
  - it uses the dungeon's floor data, painted picture and 24 px tiles instead of making its own;
  - it places the given creatures with their health;
  - it shows a BATTLE! banner;
  - it ends when your leader or every wild creature is down;
  - it skips its own stairs and floor changes.

  Every arena system carries over: aimed basics, abilities, dashes, telegraphs, carries and wall slams, signatures, charms, Kit Sense.
- **`real_time_battles = false`** keeps the old turn-for-turn fights (bump attacks, enemy warnings). The four earlier dungeon checks use it.

## Check (`tools/debug/dungeon_battle_check.gd`)
- **The start:** a rest with an awake Rimefin four tiles off started a battle. Sparkwick, Huskward and the Rimefin each began exactly at its tile with its health share, and the dungeon screen was hidden.
- **The fight:** won in about 9 seconds with the Rimefin down. The team came back with its health (Sparkwick 31 of 45), everyone on open floor, no two on a tile, and the turn count went from 0 to 10.
- **Running away:** with the leader carried far from a second Rimefin, the battle ended after 1.5 s with "You got away" and the Rimefin still standing.
- **A whole floor on autopilot:** reached B2F in 74 s through 3 battles with no faints, and recruited a Dustkite along the way.
- **Stills:** `battle_start.png`, `battle_mid.png`, `battle_after.png`.

## Known
- The rest of the floor waits during a fight; nothing wanders in.
- Items and traps aren't used inside a fight.
- In the check, the arena's AI plays your side. In play you steer.
