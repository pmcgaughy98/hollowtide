# Evolution by conditions (Claude, 2026-10-09)

**Preston, 2026-10-09:** "For Digimon do (A)." That is: keep Hollowtide's one path per line (three stages, no branches, no second parent) and borrow the Digimon idea that a creature evolves when it meets **conditions**, instead of on any win.
- **Structure source:** clokken/digimon-dawn-dusk-data (Digimon World Dawn/Dusk). Every form lists evolution requirements (stat and battle thresholds), separate from its evolution paths. Branching (several paths), DNA (two parents) and armor (item) evolutions were left out, because Hollowtide's rule forbids them.
- **Grok's 2026-10-02 rule changes in one place.** Before: "a win evolves a creature". Now: conditions. Preston gave the say-so the rule requires.

## How it works (`scripts/dungeon/dungeon.gd`)
Every teammate's form keeps a growth record (`growth`, keyed line:stage):
- **knockouts:** foes it downed;
- **floors:** floors it went down with the team;
- **one "way":** what its line grows from, read off the dungeon's own systems:

| Way | Lines | Counts |
|---|---|---|
| flank | Kithflare (runner), Listener (controller), Dustkite (spotter) | hits from a pincer or on a sleeping foe |
| took | Tallowroot, Fusern, Preostmar, Punchybun, Canvaswing (tanks, wall, protector, shelter) | damage it took for the team |
| ambush | Rimefin (ambusher) | hits on a sleeping foe |
| slam | Cinderhide (bruiser) | foes it slammed into a wall or a body |

- **Drafts for Grok** (`EVO`): stage 1 to 2 needs 2 to 3 knockouts, 2 floors, and the way's number. Stage 2 to 3 needs about twice as much.
- **The growth bar:** a thin purple bar under each teammate's health fills toward the slowest condition. "READY!" pops, and the log says it will evolve on the next floor.
- **When it evolves:** as the next floor begins. That's down the stairs, after a cleared dungeon, or after a faint; a creature that got there before fainting still evolves.
  - A white flash, a "<NAME> EVOLVED!" banner.
  - The new form arrives with its own kit (Grok's rule: the old kit is not kept; taught scroll moves go with it).
  - A faint never undoes an evolution, and a final never evolves.

## Check (`tools/debug/dungeon_evolve_check.gd`)
| Case | Result |
|---|---|
| Counters from real play | a knocked-out sleeping Rimefin gave Kithflare a knockout, a flank hit and an ambush; Tallowroot taking 5 added 5 to "took" |
| Short one floor | stayed Kithflare |
| The next floor | evolved into Sparkwick with Sparkwick's kit, banner "KITHFLARE EVOLVED!" / "into Sparkwick" |
| After a faint | still Sparkwick |
| A final | 0 progress |
| Autopilot | one pair of runs evolved Tallowroot into Huskward and a recruited Canvaswing into Windcut; another, Kithflare into Sparkwick (before the faint fix, one Kithflare reached 150% and was missed) |

## Known
- **Every floor fully heals the team.** The stairs rebuild the team "fresh" (`_build_floor(floor_n != 1)`), so "health carries over" never shows. The Mystery Dungeon games carry health between floors. Grok's numbers assume the heal, so this is Preston's call.
- **Two of the same species share one growth record** (the key is line:stage).
- **The autopilot rarely flanks or ambushes,** so on autopilot the flank lines evolve slowly; a player who sets up pincers evolves them sooner.
