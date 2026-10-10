# The mystery-dungeon pivot (2026-10-09)

**Preston, 2026-10-09:** "We're pivoting to more mystery dungeon. We can keep arena mode for maybe some other usage, but even the combat turns etc. We can take and synthesize what we've made and learned already onto and make a newer and improved mystery dungeon like game." Explorers of Sky is his favorite game (`docs/research/pmd-sky-references-2026-10-09.md`).

This supersedes the 2026-10-07 arena pivot as the game's main shape. The arena stays in the project as a separate mode. `THE_CONCEPT.md` still owns the creatures, essences, naming and art direction; this file records the change in how the game plays. Everything below the first section is a proposal until Preston says otherwise.

## What the game is now
A turn-based mystery dungeon. You lead a small team through generated floors of rooms and one-tile hallways. Every creature acts once when the leader acts. Floors have stairs, and a dungeon is a stack of floors. Between dungeons is the world Codex built: the hometown, the courier hall and the river. The courier takes dispatch jobs that lead into the dungeons.

## What carries over from the arena, and how
- **Creatures, lines and art.** The same 30 forms, their eight facings and walk cycles. The arena's floating and anchoring lessons carry over: walk cycles stand on a planted row.
- **Kits become moves on a grid.** Each damaging move keeps its name, damage and essence. Its arena telegraph becomes its reach: a melee move hits the front tile, a charge dashes down a line, a shot travels a line, a lob bursts on a target and the tiles around it. Cooldowns become turns, and the basic attack is always free. Non-damaging abilities (marks, shields, dives, perches, terrain) are not on the grid yet; they are the next big piece.
- **The essence chart** (`ARENA_CHART`) is unchanged, with "super effective" in the log.
- **Kit Sense** becomes move choice: each AI creature scores the moves that can reach, and leans to an ability over the basic.
- **The feel lessons from the five-item plan:** attack on press became bump-to-attack. Cast feedback became a refusal that costs no turn. Mouse aim became auto-aim to the one enemy a move can reach. Reach on the floor became the move panel naming each move's reach. Follow-ups are a candidate for a combo turn later.
- **The floor generator** (`scripts/hollow/hollow_gen.gd`), with one-tile hallways for the turn-based floors.
- **The world and the first morning** (Codex): the courier hall becomes the dungeon's guild, with the job board.
- **Hollow as absence** is the reason the dungeons exist: the river eats the banks and leaves scour hollows that rearrange.

## Newer and improved, against Explorers of Sky (proposals)
- Bumping into an enemy attacks it (built).
- A move with nobody in reach is refused and costs nothing (built).
- A move aims itself at the one enemy it can reach (built).
- Enemy strong moves show a warning the turn before (built).
- The run clock is ours, the courier's satchel light or the river rising, not hunger (planned).
- Recruiting, jobs and a Courier Rank in place of Explorer Rank (planned).

## The order, one slice each
1. **Turn-based floor (built today):** `scenes/dungeon.tscn`.
2. **The run loop (built 2026-10-09, `docs/design/dungeon-run-loop-2026-10-09/README.md`):** items and a run bag, hidden traps, the lantern as the run clock (it relights on knockouts, after the Battle Pyramid), dark hallways, Monster Houses. Secondary terrain (water, silt) is still to come.
3. **Non-damaging moves on the grid:** marks, shields, dives, perches, terrain. Each line's kit made whole again.
4. **Enemy warnings (built 2026-10-09, `docs/design/dungeon-warnings-2026-10-09/README.md`):** a wild creature's dash, line or burst gathers for a turn and marks its tiles; step out and it misses. Combo turns (the arena's follow-ups) are still to come.
5. **Recruiting (built 2026-10-09, `docs/design/dungeon-recruiting-2026-10-09/README.md`):** a beaten wild creature asks to join; a team of up to four.

**Combat changed on 2026-10-09 (Preston's call):** exploring stays turn-based; a fight is played in real time with the arena engine on the same floor, then everyone snaps back to the grid. See `docs/design/combat-rethink-2026-10-09.md` and `docs/design/dungeon-hybrid-2026-10-09/README.md`. The turn-for-turn fighting (bump attacks, enemy warnings) is kept as an option.
6. **The courier hall's job board (board built 2026-10-10, `docs/design/job-board-2026-10-10/README.md`):** world to dungeon and back; Courier Rank; rewards. The Wayline Hall as the guild is Codex's.
7. **Growth:** levels or the win-trigger evolution in the dungeon.
8. **Bosses and fixed rooms; dialogue with emotion portraits.**

## The arena's future (a proposal)
A training ring and exhibition mode: the relay yard practice Codex built, a place to test a team, and later play against a friend. The arena code is kept; its balance work for Grok drops below the dungeon's numbers.

## References for synthesis ("the synthesis", Preston's name for the whole collection)
Preston is dropping Pokémon disassemblies one at a time for synthesis. Each is read for structure only. No code, data, maps, sprites, text or music goes into the repo.
- `pret/pokered`: Pokémon Red and Blue (Game Boy). Read on 2026-10-09 through a video about a Claude-built remake.
- `pret/pmd-sky`: Explorers of Sky (DS). The main reference: dungeons, the run loop, the team, the job board.
- `pret/ds_disassembly_tools`: scripts for unpacking DS ROMs. Nothing in it for Hollowtide.
- `pret/pokeplatinum`: Pokémon Platinum (DS). Not read yet. Likely useful later for menus, the bag, the summary screens and the overworld town.
- `pret/pokestadium`: Pokémon Stadium (N64). Not read yet. It fits the arena's new role as a side mode: an exhibition ring with rental teams, cups and stadium presentation.
- `pret/pokestadiumgs`: Pokémon Stadium 2 (N64, US and JP). Not read yet. It pairs with Stadium for the arena side mode, and its mini-games are a possible source for hub-town activities in the courier's town.
- `pret/colosseum-mb`: the small Game Boy Advance program that Pokémon Colosseum sends over the link cable, which moves Pokémon between the GameCube game and the GBA games. Not the Colosseum game itself. Little for Hollowtide beyond the idea of moving a team between modes, for example from the dungeon into the arena side mode.
- `pret/pokeemerald`: Pokémon Emerald (GBA), the most complete and best documented of the set. Not read yet. The most useful parts for Hollowtide:
  - **The Battle Pyramid** in the Battle Frontier: a floor-by-floor run with darkness that shrinks your view, items found on the floor, trainers and wild encounters, and a bag that only lasts the run. It is the closest thing in the main series to a mystery dungeon.
  - **The Battle Frontier's other facilities** as rule sets for the arena side mode.
  - **The overworld and menus:** bag, party and summary screens, and the save structure, for the courier's town.
  - **Secret Bases** as a possible home for the courier.
- `PikalaxALT/pmd-red`: Pokémon Mystery Dungeon: Red Rescue Team (GBA), a fork of pret/pmd-red. Not read in depth yet. The first Mystery Dungeon game, and the closest reference after pmd-sky: the rescue-team loop of mail jobs, the team base, recruitment and the original dungeon rules. Its rescue mail fits the courier's dispatch board directly. Read it beside pmd-sky when the job board (slice 6) and recruiting (slice 5) start.
- `PikalaxALT/gba_bios`: the Game Boy Advance's start-up firmware, disassembled. Nothing for Hollowtide.
- `pret/pokerevo`: Pokémon Battle Revolution (Wii, European release). Not read yet. A battle-only game: colosseums with their own rules, battle presentation and camera work, rental and player passes. It belongs with the two Stadiums as reference for the arena side mode and for how a fight is staged on screen.
- `clokken/digimon-dawn-dusk-data`: Digimon World Dawn and Dusk (DS) data tables, not a disassembly. Its evolution requirements (stat and battle thresholds per form) shaped Hollowtide's evolution by conditions; branching, DNA and armor evolution were left out by Preston's one-path rule (`docs/design/dungeon-evolution-2026-10-09/README.md`).
- `jmacato/ZoidsLegacyDecomp`: Zoids Legacy (USA, GBA), a matched decompilation (C code only; no game data, art or text; the author calls the code rough). Read the README only so far. Possibly useful later: the battle's "Deck Command" (a deck of commands in battle), parts-based customization (the inverse of Hollowtide's body-part gate, a model if equipment ever arrives), and how its battle menus and quote windows are laid out. Read its battle code before borrowing any of it.
- `WolfEye939/spectrobesSFM`: **not usable.** Ripped 3D models and textures from Spectrobes: Origins (Wii), made for Source Filmmaker; the author says the textures came straight from the game data. No code or data, only the game's art, so nothing from it goes in Hollowtide, not even as a sprite reference. The game's ideas (from memory, unverified; check videos or a wiki first): three forms per creature, evolution by feeding minerals that raise stats (an item-based evolution condition), and digging creatures up as fossils (a possible dig or scan activity on a dungeon floor).
- `Pokemon-Tectonic-Team/Pokemon-Tectonic`: an open-source fan game (Pokemon Essentials, Ruby; archived January 2026). Not read in depth yet. The most useful of the October 9 late batch: a rebalanced roster, hundreds of new moves and abilities, a custom battle AI with distinct trainer personalities, and team-building tools. Structure for Grok's balance and move work and for the AI (Kit Sense, IQ); never copy its code, data or text.
- `monhacks/opendpr` (a fork of TeamLumi/opendpr): a Unity recreation of Brilliant Diamond and Shining Pearl (Switch); the user supplies their own dumped game for the assets. Structure only: how a modern (2021) Pokemon game is organised. None of its assets.
- `Pokemon-3D-api/assets`: **not usable.** 1,300+ 3D Pokemon models; Pokemon's art.
- `Pokemon-3D-api/api-server` and `Pokemon-3D-api/Showcase`: a web server and a React viewer for those models. Nothing for Hollowtide.
