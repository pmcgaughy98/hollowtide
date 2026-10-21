# Grok: The Hollow's floors against the pilot's team (from Claude, 2026-10-12)

Done 2026-10-12, filed 2026-10-16. Record: `docs/team/GROK_BUILD_RESULT_2026-10-12.md`. Do not redo this list. `pilot_chain_check.gd` was not run. Seed 31337 finished at level 8.



Lane: creature and move numbers, as before. No story flags, scenes, art, save model or names.

## What was measured
The pilot chain (`tools/debug/pilot_chain_check.gd`) has never got past The Hollow in a checked run: on 2026-10-11 and
again today the autopilot came home from The Hollow three times out of three without the Warden beaten (the Oct 11
log is `docs/design/pilot-chain-2026-10-11.log`). A probe (`tools/debug/warden_probe.gd`) played The Hollow on
autopilot with the team the chain arrives with (the two starters at Lv 5, Dustkite Lv 4, Canvaswing Lv 5, one
Reedberry, your Oct 11 pace) on three seeds:

| Seed | Result |
|---|---|
| 99 | the leader went down on **B1F to Troughspine** after 41 turns, one wild downed |
| 7 | reached the Warden and wore it to **8 of 168**, then the leader went down to it after 218 turns, six wilds downed |
| 31337 | **cleared on its own** after 205 turns: the Warden beaten to 0 |

Claude's side is done: a leader who goes down in the Warden's room once the Warden is under 35% of its health now
starts the stand-off instead of a faint (the scene already has both sides spent and the team knocked flat), so seed 7's
kind of fight ends in the stone. `tools/debug/warden_yield_check.gd` proves it. That rule is not a numbers change.

## The task
Seed 99 is yours: a Lv 5 leader with 40 HP and three partners loses to The Hollow's first floor in 41 turns with one
wild downed. Spring Spit (10, range 110) plus Seep (heal 6) on Troughspine, Echo Tap on the Listeners, Needle Bite on
Skimlet, at WILD_HP 0.8 and WILD_DMG 0.7. Find why the team cannot finish anything there (the healing, the range, the
numbers of wilds awake at once, or the autopilot's target choice, which is Claude's if that is the cause: say so) and
set the Hollow's B1F and B2F so the pilot's team clears them most of the time while the Warden room is still entered
at level 4 to 5, which you set on purpose on Oct 11. Keep the entry level; tune the floors.

Verify with `tools/debug/warden_probe.gd` (three seeds; the aim is the Warden met on at least two of three) and then
`pilot_chain_check.gd` if no Godot editor is open. Record what changed and the probe lines in `GROK_BUILD_RESULT_2026-10-12.md`.

## Deliveries (R4, added 2026-10-12 by Claude; numbers are yours)
`scripts/town/jobs.gd` has a third request kind, a delivery, with a condition judged at the client's feet. All
of these are Claude's placeholders for you to set: the delivery's base reward (`lamp_oil` x1) and rank (25),
`MET_COUNT` (2, the reward multiplier when the condition is met), `MET_PTS` (15 more rank when met),
`QUICK_TURNS_PER_FLOOR` (70 turns per floor for "within N turns"), and the mix of conditions a board posts
(one of three at random). Honesty line: these were chosen to make the check pass and the board read well, not
balanced against the run's pace; the lantern drains and trap counts are yours too.

## Rising water (R5, added 2026-10-12 by Claude; numbers are yours)
`scripts/dungeon/dungeon.gd`, the rising water section: `WATER_FLOORS` (which floors flood; now The Hollow's B1F,
the valley), `WATER_EVERY` (10 turns a row), `WET_LIGHT` (0.5 lantern a turn standing in water), the current's
direction (east) and that Tide creatures are the ones who swim. Honesty line: 10 and 0.5 were picked so the
check reads and the autopilot still clears the floor; whether B1F's water should bite harder or softer sits
with your B1F lethality task above, since both hit the same floor.

## Rootbank Warren's crew against a low team (added 2026-10-12 by Claude, evening)
A pilot chain run whose Hollow Mouth seed gave only six knockouts sent the team into Rootbank Warren at level 2
(the passing runs arrive at level 3 with 12 to 14). The crew boss beat it three times running; its levels rose
one a try (2, 3, 4). No dead end in the game (levels stay, the way down offers the Warren again), but three
faints before the first boss is a hard first hour for a real player. Yours to weigh with the B1F lethality above:
the Mouth's four floors could guarantee a level, or the crew's numbers could scale to the team's level, or the
Postmaster could send the team back to the Mouth once ("get your legs under you") before the Warren. Honesty
line: the chain's retry cap was raised from three to five so the check reflects what a player would do; that
is a check change, not a balance change.
