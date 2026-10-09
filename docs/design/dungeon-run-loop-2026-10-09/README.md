# The run loop (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Upgrade." This is slice 2 of the mystery-dungeon pivot. The structure comes from Explorers of Sky and from Emerald's Battle Pyramid, read on Bulbapedia through Firecrawl: its floors are dark and only light up as you beat opponents, and the run's bag carries over only if you clear it. Item and trap names are working labels; every number is a draft for Grok.

## What you'll find on a floor (`scripts/dungeon/dungeon.gd`)
- **The lantern** is the run's clock, our own in place of hunger.
  - It burns from 100 and loses a point every 3 turns.
  - Downing a wild creature relights it by 12; that's the Pyramid's rule.
  - Its light is how far the leader sees down a hallway: 6 tiles at full, 2 when nearly out. Rooms stay lit while it burns.
  - Everything beyond its reach is dark, and wild creatures in the dark aren't drawn.
- **Items** lie in the rooms (five a floor) and go in the bag when the leader steps on them. Each use is a turn.
  - Reedberry heals 15.
  - Lamp Oil gives 40 light back.
  - River Stone is thrown down a line for 8, and is refused for free with nobody in line.
  - Rally Seed gets the leader up once when it faints, by itself.
- **The bag** holds ten kinds (the Pyramid's ten slots). It is kept when the dungeon is cleared and lost when the leader faints, as in Explorers of Sky. A fresh run starts with one Reedberry. Press I to open it, W and S to choose, J to use.
- **Traps** are hidden (four a floor) and spring when your team steps on them, then stay visible.
  - Snare holds for 2 turns.
  - Silt Pit does 6 to everyone of yours around it and costs 15 light.
  - Warp Eddy carries you to another room.
- **Monster House:** on 30% of floors, one room fills with four awake wild creatures when the leader walks in.
- **The screen:** a lantern bar and the bag count under the team, a bag panel, items and seen traps on the floor and the minimap.

## Fixed on the way
A creature moved by the game rather than by a step, such as a warp or a Monster House check, could be pulled back a tile. The last frame of its previous step's slide ran after it was placed. Every sprite movement now goes through one slide that stops the one before it.

Preston also reported "the creature is going back and forth." A probe of every creature's tile over 290 autopilot turns found no creature flipping between two tiles, and a held walk had no backward frames. So that report is not reproduced yet; see Known.

## Check (`tools/debug/dungeon_run_check.gd`)
- **Stock:** five items and four hidden traps, all on open floor; the bag starts with one Reedberry.
- **Items:**
  - Stepping on a River Stone put it in the bag.
  - A Reedberry took the leader from 16 to 31 and spent a turn.
  - The stone with nobody in line was refused for free; thrown at a Rimefin 2 tiles off, it hit, with the partner joining in on its turn.
- **Lantern:** 30 rests took it from 100 to 90. Its reach is 6 tiles at full light and 2 at 10, and downing a Rimefin relit it from 10 to 22.
- **Snare:** sprung and shown, holding for 2 turns; a step while held kept the leader in place.
- **Monster House:** walking in set four awake wild creatures in the room, with the leader's sprite in the room.
- **Rally Seed:** the leader got back up with 18 HP. With no seed it fainted, and the bag was reset.
- **Autopilot:** reached B2F with the lantern at 55 and a bag of 2 Reedberries and 2 River Stones.
- The first dungeon check still passes; its autopilot fainted once on the way, the run being harder now.
- Stills: `start.png`, `dark.png`, `monster_house.png`, `b2f.png`.

## Known
- The back-and-forth Preston saw is not reproduced on the turn-based floor. It may be the attack lunge, the real-time Hollow floor, or the arena; it needs his word on where.
- Items don't stack beyond the bag's kinds rule, there's no shop, and no item has a use on a partner yet.
- Wild creatures ignore the dark; it only limits what you see.
- Secondary terrain (water, silt) is not in yet.
