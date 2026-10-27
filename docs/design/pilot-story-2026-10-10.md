# The pilot's story (proposal, approved in outline by Preston, 2026-10-10)

The first build to show a developer runs from the soul's arrival to the Warden, with the Warden as the
climax and the stone from the pond as the payoff: it wakes the Growth Shrine, and evolution begins.
Preston approved this outline ("Thats perfect"). Names, lines and the stone's identity are still his to
set; everything below is the agreed shape, with open points marked.

## Borrow the shape, not the beats
A human soul becoming a creature, a partner, a guild and a first mission is Explorers of Sky's skeleton,
and the genre's. What we do not copy: waking on a beach at sunset with no memory, a partner who just walks
by, the guild's entry gimmicks. Every beat here has a Hollowtide reason.

## The arc (superseded)
Superseded the same day by "The opening, revised" below, which is the order the game plays and the order
`tools/debug/pilot_chain_check.gd` runs. Kept because the reasons behind each beat still hold (marked 2026-10-22).
1. **The night it starts.** The soul arrives (the presence speaks, the soul picks its creature;
   `scenes/soul_prologue.tscn`). The same night the riverbank collapses and **The Hollow rises out of
   the river**. These are one event: the presence is tied to what lies in the Warden's pond.
2. **The partner finds you.** Wayline trainees are sent down after a collapse to gather mail the river
   tears loose. Your partner finds you in the clay. "Something told me to come down here tonight": a
   quiet hint of the presence.
3. **Why you join.** The Wayline rule: **no one runs a route alone**; the river and the Hollow take
   lone travellers. Your partner keeps being turned away for having no one to run with. You need them to
   understand this world; they need you to get in.
4. **Highbank and the Guildmaster.** **Starward** (Punchybuns' final form, Preston's call) is the
   Guildmaster. The collapse washed out routes and every senior runner is out checking them, so the Tower
   is short. The partner pleads; Starward agrees to **one parcel, a short run, as the entry trial**:
   deliver it and you are both runners. The walk there meets the shop, the scroll keeper, storage, and
   the Growth Shrine, **dark, a socket at its heart empty**.
5. **The theft.** The Shortcut Crew (Mirekit and Whinet) snatch the parcel. Failing means no guild, so
   the team chases them through **Rootbank Warren** and wins it back (built:
   `scripts/dungeon/crew_scene.gd`).
6. **The first mission.** Accepted, the team is sent to **The Hollow**, new and thought safe for
   rookies (built: the valley and ruin floors).
7. **The climax.** The Quietwater Warden in its pond garden (built: `scripts/dungeon/boss_intro.gd`).
8. **The stone.** When the Warden and its Listeners fall, the pond lights and **a stone rises out of
   it**. The presence's voice, once: it was waiting.
9. **The shrine wakes.** Back in Highbank the stone is set in the Growth Shrine's empty socket; the
   shrine wakes, and the first evolution can happen there. **End of the pilot.**

## Decided since (Preston, 2026-10-10, same day)
- **The player keeps a little memory** of being human (not Sky's blank amnesia).
- **Town and guild roles are stage 3 creatures made for those roles**, from new lines. In the pilot their
  lines are not met in dungeons; only the role holder exists. **Starward (Punchybuns' line) is the
  Guildmaster, and the Punchybun line is not met in dungeons either.**
- **Each dungeon's wild creatures are chosen for it**, the way Explorers of Sky stocks a place: mostly
  the place's own essence, plus creatures that would live there (a water dungeon also holds the stone,
  bog and reed creatures of a riverbank). **Troughspine belongs in the Warden's dungeon**, so The Hollow
  leans Tide. New creatures will be made for the dungeons to fill what is missing.
- **The Shortcut Crew has a boss**: a stage 1 that looks fat, bulky and like a bully.

## Who lives where (Preston, 2026-10-10: starters are not recruited yet)
Recruitable in the pilot: Preostmar, Cinderhide, Fusern, Listener, Canvaswing, Dustkite, Troughspine and
the three new Hollow lines. Starters, the crew and the townsfolk are not met as wilds. Stocked the Explorers
of Sky way, by what would live in each place:

| Dungeon | Floor | Wild creatures |
|---|---|---|
| Rootbank Warren (dry clay riverbank) | B1F | Dustkite, Canvaswing (Gale nesters in the sunny burrows) |
| | B2F | Dustkite, Canvaswing, Cinderhide (the burrowing Ember lizard) |
| | B3F | Cinderhide, Fusern, Preostmar (kiln-hard clay, buried river stone) |
| | Boss | Mirekit and Whinet |
| The Hollow (the risen river structure) | B1F valley | Listener, Skimlet |
| | B2F ruin | Ozbender, Valvekin, Troughspine |
| | Boss | the Quietwater Warden and its Listeners |

Skimlet, Ozbender and Valvekin are on these floors. Preston picked the takes in
`docs/creatures/hollow-wilds-2026-10-10.md`.

Grok, 2026-10-12: B1F is Listener and Skimlet. Troughspine is off B1F because Spring Spit is a long Tide
line, about 6 into the Ember leader's 40 HP on that day, and Seep was healing that hit back. Seed 99 went
down there with one wild downed. B2F is Ozbender, Valvekin and Troughspine, without Listener, so the floor
before the Warden is not two Tide shots at once. The code matches: `DUNGEONS["hollow"]["spawns"]` is
`{1: [[7, 0], [103, 0]], 2: [[104, 0], [105, 0], [10, 0]]}`. The Mouth is not in this table. Its stock is
`DUNGEONS["mouth"]`. The Rootbank Warren rows were not part of this pass.

## Still Preston's to decide
- Which creature is the partner, and does it get its own name?
- The town role creatures' designs (Claude proposes stage 3s for the shop, scroll keeper, storage,
  shrine and training yard, and guild members; Preston approves).
- The starter list: stay at three with the partner from the two not picked, add partner-only
  creatures, or something else (Claude's recommendation in chat, 2026-10-10).
- **The stone's name and look.** In the game it is called "the pond stone" as a working label
  (`STONE_NAME` in `scripts/dungeon/stone_scene.gd`), drawn in code as a smooth dark river stone with a
  glowing seam.

## Who builds what
- **Claude:** steps 8 and 9 and the shrine lock (evolution waits for the stone), the town introduction
  scene once the town creatures are picked.
- **Codex:** steps 1 to 3 live in the launch flow and waking scene (`scripts/creature_prologue.gd`);
  job 12 in `docs/team/CODEX_HANDOFF_2026-10-10.md`.
- **Grok:** nothing new; the evolution rules are unchanged, only when the shrine opens.

## The opening, revised (Preston approved, 2026-10-10 late)
Preston: reincarnate during the flood, the partner is there, it is dire so the two retreat into the Hollow; that is the first dungeon, with no boss; the partner then shows the parcel, it is stolen, and the second dungeon is the first boss, the rival crew. Claude's lean on the open choices was approved with it:
1. The soul arrives (unchanged).
2. Waking on the riverbank mid-flood (Codex's walkable riverbank, `scripts/riverbank_journey.gd`). The first time, the ruin and its stone path rise out of the river (`scripts/ui/hollow_rise.gd`): the team are the first to set foot in it. The road to Highbank is under water.
3. Dungeon 1, the Hollow Mouth (working name; `dungeon.gd` "mouth"): the outer Hollow, four floors (Preston, 2026-10-11; `DUNGEONS["mouth"]["floors"]`), no boss, a tutorial. Its last stairs clear it. On the way out a rumble and a presence below foreshadow the Warden (built: `dungeon.gd` `_mouth_exit`).
4. Out the far side, the partner shows the one parcel saved, still dry (built: the last lines of `_mouth_exit`, then the dawn walk to Highbank in `scripts/mouth_escape.gd` with `dialogue/road_to_highbank.dialogue`).
5. Highbank, the Job Board: the theft. Gruntle shoves the partner and the crew takes the parcel (built: `scripts/town/board_scene.gd`; story `parcel` goes from "saved" to "stolen").
6. The guild: Starward turned the trainee away for having no partner; now there are two, and the trial is to bring back what was stolen (built: `scripts/town/guild_scene.gd`, the stolen-parcel line sets; story `guild_trial`).
7. Dungeon 2, Rootbank Warren: the first boss, the rival crew; the parcel comes back, the two become runners.
8. Later, The Hollow again by teleport from town (`scripts/town/hollow_approach.gd` "teleport"), deeper: the Warden twist, the pond stone, the Growth Shrine.
Checks: `tools/debug/flood_opening_check.gd` (steps 2 and 3, the rise, the road, the no-boss clear).

## The Wayline Tower on two floors (2026-10-10 late; the Hall became the Tower on 2026-10-26)
Preston chose two floors, like Sky's guild. Upstairs is the work floor, where the guild scenes still play. Stairs lead down to the lower floor: the roll-call floor, the crew room (a door you read, not enter) and the runners' room (its door opens once the team are runners: the `town_room.gd` link needs "runner"), the mess hall, and the door to Starward's chamber. Once the trial is set, Starward waits in the chamber and speaks by story state. Claude's drafts for Preston: the room names and lines. Done since: the morning mail call (the roll call in this plan) plays on the lower floor once before each run after the Wayline has taken the team on (`scripts/town/guild_crew.gd`), and the two are named runners when the parcel comes back (`guild_scene.gd`, story `runner`).

## Where the alpha stops (factory plan, 2026-10-22)
The build ends after the first growth at the Growth Shrine: the end card (fade, 'The first stretch of Hollowtide', three lines of what comes next, 'Thanks for running it.', 'E  Keep running routes'), then Highbank with every Hollow open and the objective line "That's the first stretch. Run the Hollows again or rest at home." Section 9 of `docs/team/sweep-2026-10-20/FACTORY_PLAN_2026-10-22.md` is the authority; `docs/team/TESTER_NOTES.md` says the same for testers.
