# Pokémon Mystery Dungeon: Explorers of Sky, read as structure (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Ok this is my favorite game and one I want to synthesize into Hollowtide. Has a lot of similarities in terms of pixel size and walking animations etc. I really like the dungeon aspect too, can we take from this though and synthesize it to the game to enhance it?" He linked `pret/pmd-sky`.

**What `pret/pmd-sky` is:** a work-in-progress decompilation of the Nintendo DS game, built to match the original ROM byte for byte. It is Nintendo, Chunsoft and The Pokémon Company's game. The same rule as every reference applies: read for structure, never copy its code, data, maps, sprites, text or music into Hollowtide. Its recent commits were made by Claude under human direction, which is a sign it can be read well, not a licence to reuse it.

Sources read through Firecrawl: the pmd-sky README; the SkyTemple wiki's "Dungeon Floor" page (the floor editor's parameters, which expose the generator's structure); the Mystery Dungeon Franchise Wiki's "Floor Layouts" page. Items marked *(general knowledge)* are from how the game plays and were not re-verified today.

## 1. The dungeon floor generator (read)
Each floor is generated from a small parameter set; the same generator makes every dungeon feel different by changing the numbers:
- **Structure type:** Small, Small Medium, Medium, Medium Large (the most random), and fixed-shape types: Ring, Crossroads, Line, Cross, Beetle, Outer Rooms, Two Rooms with a Monster House, Single Monster House.
- **The cell grid:** the floor is a grid of cells; each cell holds a room or a hallway junction. *Floor connectivity* sets how many cells are joined; *extra hallway density* adds loops, extra links and dead ends; *room density* sets the room count (never fewer than two); *dead ends* on or off; *imperfect rooms* notches room corners.
- **Secondary terrain:** water, lava or void outside rooms (and in a set number of rooms), at a density.
- **Per-floor contents:** item density (16 at most), buried items in walls, trap density, money size, initial enemy density (14 at most, more arrive over time), a spawn list per floor (14 species drawn at random if longer), darkness level in hallways, weather, a shop keeper's chance, hidden stairs leading to a secret room or a secret shop, and fixed rooms (hand-built floors for bosses and story beats).
- **The floor is a recipe:** tileset, music, spawns, items, traps per floor, so a dungeon is a list of floor recipes.

## 2. The run loop *(general knowledge)*
Floors stack; stairs lead down; the run ends at the last floor (or a boss), by escaping, or by fainting, which costs money and items. A belly (hunger) drains with every step and is the run's clock; food refills it. Monster Houses are rooms that fill with enemies when entered. Traps are hidden until stepped on or revealed.

## 3. The team *(general knowledge)*
A leader the player controls and partners who follow in a chain and fight with their own AI, set by tactics ("go after foes", "stay close", "avoid trouble"). IQ skills unlock behaviours as creatures grow. Recruitment happens in the dungeon: a beaten wild creature sometimes asks to join.

## 4. The hub and the jobs *(general knowledge; the Missions and Explorer Rank pages exist on the wiki)*
A town with services (bank, storage, shop, a training dojo) and a guild with a job board: rescue, deliver an item, escort a client, catch an outlaw. Jobs name a dungeon and a floor; finishing them raises Explorer Rank, which opens harder jobs and rewards. Wonder Mail codes share jobs between players.

## 5. Sprites and faces *(general knowledge)*
Small creature sprites (about 24 to 48 pixels) in eight directions with walk, attack, hurt and sleep cycles; a large emotion portrait set per creature (happy, pained, determined, surprised, and so on) beside dialogue. Hollowtide already has eight-direction walks at a similar size and front-idle portraits from Codex; emotion portraits are the missing piece.

## What already lines up in Hollowtide
- **The courier is a delivery job by definition.** PMD's job board is the courier hall's dispatch board. Deliver, escort and rescue are the jobs a river courier would take.
- **A partner who follows you** is the first morning's partner.
- **Hollow is absence.** Scour holes, eaten banks and sunken places are mystery-dungeon ground: places that rearrange themselves because the river keeps eating them. That gives the generator a reason to exist in the fiction, which PMD itself explains with "mystery".
- **The arena engine** already has eight-direction movement, momentum, dashes, AI with modes and called targets, hitboxes, rocks and terrain. A dungeon floor is that engine on a generated map.

## Synthesis proposal (for Preston; nothing here is canon)
**The Hollows** (working name): generated multi-floor places along the river, reached from the world map, entered for a dispatch job.
1. **Combat stays real-time.** The arena's fighting happens on the dungeon floor itself: you steer your creature, your partners follow and fight with Kit Sense, wild creatures in rooms use the same AI. PMD's grid turns would be a third combat system to maintain. The option exists if Preston wants the tactical step-for-step feel instead.
2. **The floor generator from section 1**, cut to our size: a cell grid of rooms and hallways, the stairs, secondary terrain (water for Tide floors, silt for Hollow), a spawn list per floor, a Monster House chance, fixed rooms for bosses. Built as a recipe file per Hollow, so Grok can tune spawns and density without touching code.
3. **The job board** in the courier hall: deliver a parcel to a floor, find a missing courier, escort a client, drive off a named troublemaker. Courier Rank instead of Explorer Rank.
4. **The run clock:** the courier's satchel light or the river rising, not hunger, so it is ours. Fainting costs the parcel, not the creature.
5. **Recruitment in the Hollow:** a beaten wild creature can follow you out, which is also where the roster comes from.
6. **Emotion portraits** for partners in dialogue, after Codex's front-idle portraits.

## The first slice (one session, verifiable)
One generated Hollow floor, playable: the cell-grid generator makes rooms and hallways from a seed; the courier's partner is steered with today's arena controls through it; two or three wild creatures wait in rooms and fight with the arena AI; stairs lead to a second floor; the camera follows. Floors and walls drawn from the arena's existing ground and rock art, no paid generation. A check generates 200 seeds and proves every room and the stairs are reachable from the start, then plays one floor with the AI driving. Everything after it (jobs, recruitment, recipes, the clock) builds on that floor.

**Built the same night** (Preston: "do the slice"): see `docs/world/hollow-slice-2026-10-09/README.md`. The generator passes 200 seeds; an autopilot floor downs all three wild creatures and takes the stairs; the picker has a HOLLOW button.
