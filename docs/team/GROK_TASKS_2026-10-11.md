# Grok tasks (from Claude, 2026-10-11)

Preston is turning the pilot (the soul's arrival to the first evolution) into a vertical slice to show working
developers (`docs/pitch/pitch-kit.md`). Your lane is unchanged: creature and move numbers, balance, the
evolution rules. Names, lore and art approval stay Preston's. Read the top of `docs/AI_COLLABORATION.md`,
then this file. Write a short result note in `docs/team/GROK_BUILD_RESULT_2026-10-11.md`.

## 1. The first evolution has to be reachable in the pilot (most important)
The pilot's payoff is evolving at the Growth Shrine after the Warden. The run is three dungeons:
Hollow Mouth (2 floors, no boss, a tutorial), Rootbank Warren (3 floors + the crew boss), The Hollow
(2 floors + the Warden). Claude's `tools/debug/pilot_chain_check.gd` plays it on autopilot and prints the
team's levels and growth at the shrine (log: `docs/design/pilot-chain-2026-10-11.log`, and the console).
Evolving needs `EVO_LEVEL` (stage 1 to 2 at level 5) AND the line's `EVO` conditions (kos, floors, and its
way: flank, took, ambush...). Numbers in `scripts/dungeon/dungeon.gd`: `EVO`, `EVO_LEVEL`, `EXP_PER_KO` 12,
`EXP_PER_STAGE` 6, `EXP_BOSS` 60, `LEVEL_HP`, and the level curve.
**Task:** tune so a normal player's leader (and ideally the partner) is ready to evolve by the end of The
Hollow, not before the Warden. Say what you changed and why, with the numbers before and after.

## 2. The two bosses at pilot pace
- The crew boss in Rootbank Warren (Mirekit and Whinet; Gruntle is the crew's boss in the story).
- The Quietwater Warden (`BOSS_HP` 3.0x) and its Listeners. Its room grew to 25x18 tiles today and the
  Listeners now stand right at its flanks; check the fight still feels fair for the team's level then.

## 3. Numbers for creatures that became meetable
Preston, 2026-10-11: the townsfolk and guild crew can now be met in dungeons as plain versions (their job gear
removed). They need kits and stats if they become wilds or recruits: Grubbit, Muskin, Slipjaw (stage 1);
Stillwade, Wickglow, Rinsepaw, Swaphoard, Pouchbill (stage 2); Inkhoot, Cairnshell, Crawdukes (stage 3);
Wayling (stage 1). Their other stages are not designed yet. Draft stats, essences (proposals) and a move kit
that fits each body (`docs/creatures/DESIGN_RULES.md`, the body gate in `move_body.gd`). Mark everything as
proposals for Preston.

## 4. Still waiting on you from earlier
- The five dungeon kit conflicts noted in `docs/creatures/` (move tables, shared signatures, 2026-10-09).
- Springvault's healer numbers (Claude's draft in `EVO` line 10 and its kit, 2026-10-10).

Do not change: story flags, scenes, art, the save/state model, or names.

## Data from the pilot chain run (Claude, 2026-10-11, autopilot, no faints, about 2 minutes)
Every story handoff works. At the Growth Shrine with the stone set: **0 ready to evolve.** Team at the end:
| Creature | Level | kos | floors | its way | needed |
|---|---|---|---|---|---|
| Kithflare (leader) | 6 | 10 | 7 | flank 1 | flank 4 |
| Tallowroot (partner) | 6 | 15 | 7 | took 9 | took 60 (the leader took 415 at the front) |
| Listener (recruit) | 6 | 4 | 6 | flank 2 | flank 3 |
| Skimlet (recruit) | 6 | 1 | 5 | n/a | (no evolution yet) |
Levels pass (EVO_LEVEL 5); the line's "way" condition is what blocks it. The autopilot does not play for those
conditions, so a human may do better, but the pilot needs a reliable first evolution. Preston is deciding
whether the first evolution is guaranteed at the shrine. Propose numbers either way.
Run it yourself: `Godot --headless --path . --fixed-fps 30 --script res://tools/debug/pilot_chain_check.gd`.
