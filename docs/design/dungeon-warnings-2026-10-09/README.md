# Enemy warnings (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Keep upgrading, synthesizing and refining." Slice 4 of the mystery-dungeon pivot: the arena's telegraphs turned into a turn rule. It's the "newer and improved" idea against Explorers of Sky, where a wild creature's strong move just lands.

## The rule (`scripts/dungeon/dungeon.gd`)
- A wild creature's **ability that reaches past the next tile** (a dash, a shot down a line, or a burst) doesn't land at once. It spends its turn gathering itself:
  - the log says "Rimefin is gathering itself for Lunge!" and a telegraph sound plays;
  - the tiles it will cover glow red on the floor.
- On its **next turn it lands on those tiles:**
  - a dash runs down them until something is in the way;
  - a shot takes the first enemy on them;
  - a burst takes every enemy on them.
  - Whoever stepped out is missed ("It missed: nobody was where it struck.").
- **Instant, no warning:** basic attacks and moves that hit only the next tile, and every move your own team makes.
- A wild creature that is snared or downed while gathering loses the move. The move's cooldown starts when it begins gathering.
- **Hallways matter now.** A dash or shot down a one-tile hallway marks the whole hallway, so there is nowhere to step. Fight in rooms.
- **The autopilot** steps out of a marked tile before doing anything else, when a free tile exists.

Wild creatures that warn today: Rimefin (Lunge) and Cinderhide (Vent Barrage, Pounce). Dustkite and the Cutbank Listener's abilities do no damage, so they aren't in the dungeon yet (Grok's job 3).

## Check (`tools/debug/dungeon_warn_check.gd`)
- A rest with a Rimefin three tiles off: it gathered its Lunge, marked four tiles including the leader's, and did no damage that turn.
- The leader stepped aside: the Lunge ran down the empty tiles and missed, and the leader took 0.
- The leader stood still: the Lunge gathered, then hit for 5.
- With the Rimefin adjacent, its basic was instant: no wind-up, 7 damage the same turn.
- The autopilot still clears a floor with no faints.
- A probe over four floors: with a free tile beside it, the autopilot stepped out and the move missed 5 times out of 6. Both hits came in one-tile hallways with no safe step.
- Stills: `warning.png`, `hit.png`.

## Known
- A wind-up can't be interrupted by hitting the creature; the arena's counter-hit could become that later.
- Partners don't step out of marked tiles yet; only the leader (or the autopilot) does.
