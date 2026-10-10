# Monster Houses, the floor plan and the boss floor (Claude, 2026-10-09)

**Preston, 2026-10-09:**
- "Do the monster house and boss floor next."
- Then, correcting the first try: "The boss is always at the top highest level dungeon floor and sometimes there's a rest and save floor after like 60 or so floors, then like 10-20 floors before the boss floor... it would solely be boss. With usually a dialogue cutscene beforehand."

## Sources (structure only, nothing copied)
- **SkyTemple wiki** (Explorers of Sky's editing tools): "Boss battles take place in fixed rooms (aka fixed floors)." Fixed rooms are hand-made layouts that can be the whole floor, also used for treasure rooms and puzzle floors.
- **Rescue Team DX, part 4, 36:18 to 38:26 (Zapdos):**
  - a prep stop at the peak;
  - an open arena with the boss at the far side and helpers around it;
  - each move's name in a bubble, and the boss's passive tilting the fight;
  - a white flash and a cry when it falls, then a cutscene.
- **Explorers of Sky, part 1, about 82:50 (Drowzee at the peak):** its own small fixed area, a dialogue scene first.
- **The first try was wrong.** It put the boss in one of two generated rooms on the last floor. That is the mistake Preston caught, and the research above would have caught it first.

## The floor plan (`scripts/dungeon/dungeon.gd`)
- **Normal floors:** `FLOORS` generated floors, B1F to B3F.
- **The boss floor:** `FLOORS + 1` (B4F) is a fixed floor that is only the boss.
  - One hand-set arena, `BOSS_ARENA` 15 by 11, with no hallways, items, traps or other wild creatures.
  - The team arrives at the bottom. The boss waits at the top with its two helpers, before the sealed stairs.
- **Rest floors:** `rest_floor` can put a quiet fixed floor partway through a long dungeon, `REST_ROOM` 9 by 7. It heals the team, refills the lantern and shows REST, with the stairs onward. The first dungeon is short, so it has none (0).
- **The boss floor, step by step:**
  1. A dialogue scene plays before the fight while the boss sleeps. J moves to the next line, and the log hides while lines show. The lines are placeholders: Preston writes the real scene.
  2. When the scene ends, the boss and its helpers wake, its name shows as a banner, and its health bar appears.
  3. The boss doesn't budge. A charge doesn't shove or stagger it, but a charge while it gathers still breaks the move. That is the counterplay the enemy warnings already teach.
  4. It never asks to join.
  5. When it falls: a white flash and VICTORY!, then the dungeon is cleared and the team goes home (the first floor, until the courier hall exists).
- **The boss** is a placeholder pick from the existing roster: Scourmaw, the Hollow river walker, with two Rimefin. Preston chooses the boss.

## The Monster House
- **Bait:** `MONSTER_HOUSE_ITEMS` 3 items lie in the room before it springs.
- **Size:** bigger rooms drop in more, between `MONSTER_HOUSE_WILD` 4 and `MONSTER_HOUSE_MAX` 7 (one more per `MONSTER_HOUSE_PER_TILES` 12 floor tiles).
- **Arrival:** they drop in from above, one after another, under a MONSTER HOUSE! banner.
- **Reward:** clearing it shows CLEARED! and gives the lantern `MONSTER_HOUSE_LIGHT` 30.

## Numbers (drafts for Grok)
`BOSS_HP` 3.0 (149 HP against a plain wild Scourmaw's 50), `BOSS_DMG` 0.9, `BOSS_MINIONS`, and the Monster House numbers above.

## Bugs found and fixed on the way
- **A recruit could make a fifth teammate:** the full-team count skipped fainted partners.
- **Two creatures could end up on one tile.**
  - A beaten creature asking to join could be hit again; it fainted, its tile emptied, another creature stepped in, and the yes revived it underneath.
  - Now a creature that is asking can't be targeted.
  - `dungeon_check.gd` now names the first overlap it sees.

## Check (`tools/debug/dungeon_boss_check.gd`)
**Monster House:** 3 bait items lay in the room. 4 creatures dropped in, each starting above its tile and landing on it, under the MONSTER HOUSE! banner. Clearing it took the lantern from 50 to 80 and showed CLEARED!.

**Rest floor:** a fixed floor with one room, no wild creatures, items or traps. The leader went from 5 HP to full, under a REST banner.

**Boss floor:**
| Case | Result |
|---|---|
| Layout | B4F is one room with only Scourmaw (149 HP) and 2 helpers |
| The scene | 3 lines; the boss slept through it |
| After the scene | the SCOURMAW / BOSS banner; the boss and both helpers woke |
| The stairs while it stands | sealed |
| A charge while it gathers | the move broke; it didn't move or stagger |
| A charge otherwise | it didn't move |
| Its fall | VICTORY!, no request to join, the dungeon cleared |

**Autopilot:** with the team-cap fix, both runs cleared the whole dungeon and beat the boss in about 9 to 10 s of fighting, with a team of four. Before that fix, 2 of 3 runs fainted on the way to the peak.

**Stills:** `monster_house_drop.png`, `boss_met.png`, `boss_beaten.png`. `boss_scene.png` can be captured a frame early; the scene itself was checked directly.
