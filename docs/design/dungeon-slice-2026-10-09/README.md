# The first turn-based dungeon floor (Claude, 2026-10-09)

The first slice of the mystery-dungeon pivot (`docs/design/mystery-dungeon-pivot-2026-10-09.md`).

## Play it
Run the arena scene to open the matchup picker, fill your side (the first slot leads), press **DUNGEON**. Or F6 on `scenes/dungeon.tscn` for Kithflare leading Tallowroot.
- **WASD or the arrows:** step one tile. Press two keys together for a diagonal. Holding a key keeps walking.
- **Shift with a direction:** turn without moving (free).
- **Bump:** walking into an enemy attacks it with your basic.
- **J, Space or left click:** the basic. **1 to 3:** your moves. A move turns itself toward the one enemy it can reach; with nobody in reach it is refused and costs no turn.
- **Z:** rest a turn. **E:** take the stairs while standing on them. **Tab:** autopilot.

## What it is (`scripts/dungeon/dungeon.gd`, `scripts/dungeon/floor_painter.gd`)
- **The floor:** the Hollow generator with one-tile hallways and 4 by 3 cells of 14 by 10 tiles, so 56 by 30 tiles of 24 px. Painted from the arena grass and the silted-bank walls. Three floors to a dungeon.
- **Turns:** when the leader acts, every other creature acts once. Steps happen together, attacks one after another. Cooldowns count down in turns, and your team recovers 1 HP every 4 turns.
- **Moves on the grid:** each damaging move's arena telegraph gives its reach. Melee hits the front tile, a charge dashes down a line, a shot travels a line, a lob bursts on a target in sight and the tiles around it. Up to four damaging moves per creature, the basic first.
- **The team:** partners follow the one ahead of them in a chain, and fight anything near the leader. Walking into a partner swaps places.
- **Wild creatures:** asleep (a "z" floats over them) until something of yours comes into sight within 5 tiles. Then they come at the nearest of your team.
- **The screen:** your team's health top left, the floor number, the leader's four moves with their reach and turns left, a message log, and a minimap of what you've explored. The stairs show once seen; wild creatures show only while in sight.
- **Numbers (drafts for Grok):** dungeon HP is the arena's times 0.2 (a stage 1 starter has 36), damage times 0.6. Early wild creatures have 0.8 of their health and deal 0.7 of their damage. Three per floor. Sight 6 tiles.

## Check (`tools/debug/dungeon_check.gd`)
- The floor is 56 by 30 with 8 rooms. The leader is on the start, with two partners and three sleeping wild creatures.
- A step is one turn.
- A diagonal past a wall corner is refused.
- Bumping a Dustkite attacked it (the partner joined in on its turn).
- Ember Feint with nobody in reach was refused and no turn was spent. In reach, it hit and cooled down 4 turns.
- Autopilot cleared B1F and took the stairs in 120 turns, with no faints. No two creatures ever shared a tile, and none stood in a wall.
- The team kept its health to B2F, which had three new sleeping wild creatures.
- Stills: `start.png`, `bump.png`, `fight.png`, `b2f.png`.

## Known
- Non-damaging abilities are not on the grid yet, so some creatures have fewer than four moves.
- No items, traps, run clock, recruiting, levels or jobs yet; the pivot doc orders them.
- Sprites are the arena's size, so big creatures overlap the tiles around them in hallways.
- Enemy warnings (the telegraph as a turn) are planned, not built.
- The first-morning fight on the levee still uses the arena. Moving it into the dungeon is part of slice 6.
