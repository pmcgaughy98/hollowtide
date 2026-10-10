# Teammate IQ, and health between floors (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Our system should have the teammate IQ system right?", then "carry health between floors, also do teammate iq task."

## Teammate IQ (`scripts/dungeon/dungeon.gd`)
- **The structure** comes from Explorers of Sky: a partner's IQ grows, and behaviour skills switch on at thresholds. Nothing is copied: the skills are built from Hollowtide's own systems, and the names are working names Preston replaces.
- **How IQ grows:** +1 (`IQ_PER_FLOOR`) for each floor a partner goes down with the team, and +1 (`IQ_PER_KO`) for each foe it downs.
  - IQ belongs to the creature's line (`iq`), so it carries through evolution.
  - The leader is the player and has none.
  - The team panel shows each partner's IQ, and a new skill pops "IQ: <name>!" with a line in the log.

| IQ | Skill (working name) | What the partner does |
|---|---|---|
| 3 | Step Aside | steps off a tile a wind-up has marked, before it lands |
| 6 | Finisher | goes for the weakest foe it can see, and favours a hit that downs it |
| 10 | Quiet Steps | its presence no longer wakes sleeping creatures |
| 15 | Ambusher | strikes a sleeping foe right beside it (with the ambush bonus) |
| 20 | Berry Sense | eats a Reedberry from the bag below 30% health |
| 25 | Fall Back | below 25% health with no berry, stops fighting and stays by the leader |

The thresholds and gains are drafts for Grok. Every skill once unlocked is always on. A switch to turn skills off, as Explorers of Sky has, is a later step.

## Health between floors
- **The old behaviour was a bug:** the stairs called `_build_floor(floor_n != 1)`, which read backwards, so every floor fully healed the team.
- **Now** health carries down the stairs, as in the Mystery Dungeon games. A new run starts fresh, and so does the team after a faint or a cleared dungeon.
- **A partner that faints stays down** for the rest of the run.
- **Ways to heal on the way:** natural recovery (`REGEN_EVERY`), Reedberries, Berry Sense, and rest floors.

## Check (`tools/debug/dungeon_iq_check.gd`)
**Gaining IQ:** at 3 IQ, Step Aside switched on, and the log said "Tallowroot learned an IQ skill: Step Aside".

| Skill | Without it | With it |
|---|---|---|
| Step Aside | attacked from the marked tile | moved to an unmarked tile |
| Finisher | went for the nearest foe (30 HP) | went for the wounded one (4 HP) |
| Quiet Steps | the sleeper woke | it stayed asleep |
| Ambusher | no target | the sleeper beside it, and an attack |
| Berry Sense | attacked | ate a berry: 8 to 23 HP, berry used |
| Fall Back | attacked | moved back toward the leader |

**Health:** a leader at 10/36 arrived on the next floor at 10/36. The partner's IQ was kept.
