# Grok tasks, 2026-10-22 (from the factory pass)

> **Read [GROK_TASKS_2026-10-26.md](GROK_TASKS_2026-10-26.md) first.** It is one clean list of everything still open
> below, rechecked on 2026-10-26, plus the new art direction. This file stays as the history.

The factory plan is `docs/team/sweep-2026-10-20/FACTORY_PLAN_2026-10-22.md`; its section 5 is this queue. Nobody in the
pass changed your numbers (stats, EXP, learnsets, spawns, damage); where a doc disagrees with the code, the doc waits
for you. House rules as before: no em-dashes, the house words (Sense, nest, Second Wind, went down, Postmaster, Hollow).
Please list any "source issues for Claude" in your result, as usual.

## 1. FLOW-17: the pilot story's two Hollow spawn rows
Where: `docs/design/pilot-story-2026-10-10.md`, the table under "Who lives where", the two rows for "The Hollow (the risen
river structure)". The Rootbank Warren rows match the code, so only these two are yours.

What the rows say now: B1F valley: Listener, Troughspine, Skimlet. B2F ruin: Listener, Troughspine, Ozbender, Valvekin.

What the game runs (`scripts/dungeon/dungeon.gd`, `DUNGEONS["hollow"]["spawns"]`, read 2026-10-22):
`{1: [[7, 0], [103, 0]], 2: [[104, 0], [105, 0], [10, 0]]}`, so B1F is Listener and Skimlet; B2F is Ozbender, Valvekin and
Troughspine.

Your 2026-10-12 reason, as the comment above that line records it: Troughspine is off B1F because Spring Spit is a 5-tile
Tide line (about 6 into the Ember leader's 40 HP) and Seep was healing that hit back; seed 99 lost the leader there with
one wild downed. B2F drops Listener so the floor before the Warden is not two Tide shots at once.

Task: rewrite the two rows to match the code and put that reason in one sentence under the table, replacing the pointer
line the docs lane left there ("The two Hollow rows above are stale..."). If the code is what should change instead, say
so and change it; the numbers are yours either way.

## 2. LP-25: Mouth spawns and the autopilot rest threshold
Lane 7 adds `tools/debug/lv1_run_check.gd`: the Hollow Mouth on seeds 1 to 10 with the chain's scripted fight policy and
no autopilot. It prints faints, turns and the floor reached per seed and judges nothing. Read its table, then decide the
Mouth spawns (`DUNGEONS["mouth"]["spawns"]`: today Listener and Skimlet on every floor, Troughspine from B3F) and the
autopilot's rest threshold (`REST_TO` in dungeon.gd, 0.7 today). Numbers are yours.
First table (2026-10-23, `python tools/debug/run_checks.py lv1`): a bump-only leader at level 1, with no items, no moves and no resting, cleared the Mouth on 3 of 10 seeds (each after going down twice). The other 7 went down 3 times (deepest B4F on 4, B3F on 1, B2F on 2). 27 times down in all, 262 turns a seed on average, the leader ended at Lv 2 to 4, and the lowest HP was 3 to 11%. This is a floor for a careless player, not the autopilot.

## 3. FX-02: which status moves belong in the dungeon
Lane 1 gives every zero-damage move in the learnsets a self-effect or the essence ring, so none of them is silent any
more. Say which of the 13 status moves belong in the dungeon at all (lane 1's FX-02 result lists them); the rest come
out of the learnsets.

## 4. W27: `data/moves/fire_move.tres`
It still exists (checked 2026-10-22). Delete it or give it a real name.

## 5. GS-20: three placeholder move names
Lantern Tackle, Verdant Roar and Ember Feint are placeholders in `scripts/arena/arena_prototype.gd` (read 2026-10-22:
`"lantern_tackle"` at line 265, the `"signature": "Verdant Roar"` at line 59, `"ember_feint"` at line 255; the comments
above them carry the same names). Name them before the Training Yard opens. No deadline yet: Preston's call 9 in the plan defaults the Yard to a shut
sign this pass.

## 6. W28, later
One in-world line per creature description before any entry screen ships. Nothing ships an entry screen in this pass.

## Signals from the factory passes (Claude, 2026-10-23)
Things the two factory passes saw that touch your side. No numbers changed (stats, EXP, learnsets, spawns, damage).
- In both full suites the post-pilot Rootbank Warren replay went down once, with the team at level 8 to 9 (B3F, turn 427,
  to Preostmar). Pass 3's own chain run (2026-10-23) cleared the same replay with no faints, so it is a signal, not a
  verdict; say if the replay floors want a look.
- A wild beside its target with a wall corner between them now waits instead of pacing round (`scripts/dungeon/dungeon.gd`,
  the "blocked" wait, FEEL-17). It no longer spends turns walking round the corner.
- A partner now follows whichever teammate is between it and the leader, so a team walks as a line in halls.

## Pass 3 lines (plan, 2026-10-23)
From `sweep-2026-10-20/PASS3_PLAN_2026-10-23.md`, section "Grok". These are sections 1 to 5 above in a new order, with one
new measurement. Pass 3 changed none of your numbers. (Claude, integrator, 2026-10-23)
1. G1 (LO-16, LP-25 first): decide the Hollow Mouth spawns and REST_TO for a new player. Measured: a level 1 leader that
   only bumps clears the Mouth on 3 of 10 seeds, and went down 27 times in the lv1 table. Claude applies any spawn
   table you hand over without changing its numbers.
2. G2 (FLOW-17, section 1): `docs/design/pilot-story-2026-10-10.md` line 70 says the two Hollow spawn rows are stale;
   confirm or replace them.
3. G3 (FX-02, section 3): which of the 13 status moves belong in the dungeon.
4. G4 (W27, section 4): keep or retire `data/moves/fire_move.tres`.
5. G5 (GS-20, section 5): Lantern Tackle, Verdant Roar and Ember Feint still live in `arena_prototype.gd` and
   `arena_signature.gd`; decide their home.
6. G6 (LO-15): read "Signals from the factory passes" just above. One more data point from the integrator's final suite
   (2026-10-23, about 19:50): the post-pilot Warren replay went down once again, this time at level 7 (B3F, turn 335,
   to Preostmar, leader Sparkwick), then cleared on its second try. So in pass 3 one chain run cleared it with no faints
   and one went down once.

## Pass 4 lines (plan, 2026-10-24)
From `sweep-2026-10-20/PASS4_PLAN_2026-10-24.md`, section "Grok". Result: `sweep-2026-10-20/PASS4_RESULT_2026-10-24.md`.
Pass 4 changed none of your numbers (stats, EXP, learnsets, spawns, damage). (Claude, integrator, 2026-10-24)
1. G1 (live LV-36, leftovers LV-25): take G1 first (Mouth spawns and REST_TO), then G2 to G5, and read G6 above.
   Signals: lv1_run, 10 seeds, 4 cleared, 22 downs, lowest leader HP 3% on six; the live Tab-autopilot run went down on
   B3F at Lv 2; the post-pilot Warren replay lost on B3F to Preostmar. Claude applies any table unchanged and reruns
   pilot_chain, dungeon_chain and lv1_run.
2. Body gate (H10): move_table_check now judges '0 kit moves fail the body gate' as a verdict, so any new kit move
   without its parts turns the suite red. Confirm that is the rule from docs/creatures/DESIGN_RULES.md (2026-10-02).
3. dual_essence_check (H34) stays RAN as your print tool of essence_chart.gd multipliers (ARENA_CHART outranks it).
   Say if you want it retired.

Added by the pass 4 integrator, from the lanes' notes:
4. Job Board clients (town lane T8, live LV-27): a board no longer posts two jobs for the same creature while 4 or more
   clients are possible. jobs.gd keeps no record of creatures met, so the client pool is every creature in the floors'
   spawn lists (5 today). A repeated client is swapped for one not on the board, from the same floor's list if one is
   left, otherwise the nearest floor's. Floors, kinds, items, rewards, counts and pts are unchanged, but a swapped client
   can come from another floor's list (for example Preostmar, a B3F creature, posting a B1F job). Say if a client must
   stay on its own floor.
5. Guardian passive (arena check lanes): no creature carries the Guardian passive any more (Starward's passive is the
   punch Chain). arena_protector_check prints the Guardian line only ('a 20 blow on the ally beside Starward took 20').
   Say whether Guardian comes back or its step is dropped (Preston's Q11).
6. One more data point for G6 from the pass 4 full suite (2026-10-24, about 10:05): lv1_run again cleared 4 of 10 seeds
   with 22 downs; the pilot chain's post-pilot Warren replay cleared with no faints.

## Pass 5 lines (plan, 2026-10-24)
From `sweep-2026-10-20/PASS5_PLAN_2026-10-24.md`, section "Grok". Result: `sweep-2026-10-20/PASS5_RESULT_2026-10-24.md`.
Pass 5 changed none of your numbers (stats, EXP, learnsets, spawns, damage). (Claude, integrator, 2026-10-24)
1. LO5-27: decide G1 first (Hollow Mouth spawns and REST_TO; dungeon.gd:50 is still 0.7), then G2 to G5, and confirm
   that '0 kit moves fail the body gate' is the DESIGN_RULES rule. Claude applies the tables unchanged and reruns
   pilot_chain, dungeon_chain, lv1_run and move_table.
2. LO5-28: say whether a Job Board client must come from the job's own floor spawn list or from creatures met (today
   Preostmar, a B3F creature, can post a B1F job). If 'met', Claude adds a met record to TeamState and filters jobs.gd,
   probed with the 200-roll test. Riding on this answer: the town lane's held change that keeps each client in the
   Hollow the board now names ('Rootbank Warren B3F'); today a B2F client also appears on Hollow Mouth B2F and The
   Hollow B2F. It is written and waits for your or Preston's yes.
3. LO5-29: say whether the Guardian passive returns (no creature carries it). If not, Claude drops the Guardian step
   from arena_protector_check; if yes, it becomes a verdict once the numbers land.

Added by the pass 5 integrator, from the full suite:
4. Read lv1_run's table as a rate over many seeds, not seed by seed. The pass 5 full run cleared 0 of 10 seeds with 30
   downs (pass 4: 4 of 10, 22 downs), but pass 5 changed no rule: the fights and the later floors roll on Godot's shared
   random generator, which the camera shake and particles also draw from every frame, so any change in frame counts
   (pass 5 holds the floor card longer and spaces knock-out sounds) reshuffles every roll after it. Measured by the
   integrator with the same check: seeds 1 to 10 at 60 fps instead of 30 cleared 1; seeds 11 to 30 cleared 4 of 20 with
   pass 5's dungeon.gd and 3 of 20 with the committed one (49 and 54 downs). Over 30 seeds that is 4 clears with pass 5
   and 7 with the committed file; on the 20 fresh seeds pass 5 did slightly better, so the gap is the reshuffle, not a
   harder Mouth. A bump-only level 1 leader clears the Mouth about 1 time in 5 or 6. Claude may give gameplay its
   own random generator so seed rows stay comparable between passes; say if you want that.

## Pass 6 lines (plan, 2026-10-24)
From `sweep-2026-10-20/PASS6_PLAN_2026-10-24.md`, section "Grok". Result: `sweep-2026-10-20/PASS6_RESULT_2026-10-24.md`.
Pass 6 changed none of your numbers (stats, EXP, learnsets, spawns, damage). (Claude, integrator, 2026-10-24)
1. L6-02: Hollow Mouth B1F rolled a monster house under the shared RECIPE (dungeon.gd:297, monster_house 0.3), and a
   level 1 team was down 12 s later (audio_opening.tsv frame 5800, faint at 6081). Decide whether Hollow Mouth B1F-B2F
   keep the 0.3 roll, drop it, or drop it until Hollow Mouth is cleared once. Claude applies your number unchanged.
2. LO5-27 (LO6-29): decide G1 (Hollow Mouth spawns and REST_TO 0.7 at dungeon.gd:51) first, then G2-G5. The
   integrator's lv1 table shows 4 clears in 30 seeds with pass 5's dungeon.gd and 7 with the committed one. Confirm
   whether '0 kit moves fail the body gate' is the DESIGN_RULES rule. Claude applies the tables unchanged and reruns
   pilot_chain, dungeon_chain, lv1_run and move_table.
3. LO5-28 (LO6-30): must a Job Board client come from its own floor's spawn list, or from creatures the team has met?
   (Preostmar, a B3F creature, posts a B1F job, and a Rootbank Warren B2F client stands on other dungeons' B2F.) On an
   'own floor' answer, Claude applies the held line at dungeon.gd:1054. On 'met', Claude adds a met record.
4. LO5-29 (LO6-31): does the Guardian passive return? If not, Claude drops the printed-only step from
   arena_protector_check.gd. If it does, the step becomes a verdict once your numbers land.

Added by the pass 6 integrator, from the lanes and the full suite:
5. Autopilot (Tab) no longer answers a recruit question or reads story lines for the player: it switches itself off
   and waits for Y or N, or E (dungeon.gd L6-01). Checks that run whole floors on autopilot set a new `check_bot` flag,
   so they still welcome every recruit as before. lv1_run does not use autopilot, so its table is unaffected by this.
6. lv1_run, read as a rate: the pass 6 suite cleared 5 of 10 seeds with 20 downs (pass 5: 0 of 10, 30 downs). No rule
   changed. lv1_run does not use autopilot; the dungeon lane's stairs change (D7) draws one more frame per stairs, and
   that reshuffles the shared random generator. On 20 fresh seeds (11 to 30) the dungeon lane measured 5 clears and 48
   downs (pass 5: 4 and 49). The live re-shoot's level 1 team rolled 7 monster-house ambushes and went down 4 times
   before clearing the Mouth, which is L6-02's question.

## Pass 7 lines (plan, 2026-10-26)
From `sweep-2026-10-20/PASS7_PLAN_2026-10-26.md`, section "Grok". Result: `sweep-2026-10-20/PASS7_RESULT_2026-10-26.md`.
Pass 7 changed none of your numbers (stats, EXP, learnsets, spawns, damage). (Claude, integrator, 2026-10-26)
1. LF7-19 (L6-02, LO6-29): decide Hollow Mouth B1F-B2F's monster-house roll (dungeon.gd RECIPE monster_house 0.3; in
   the pass 6 re-shoot a level 1 team rolled 7 ambushes and went down 4 times before clearing) and answer G1 to G5
   (spawns, REST_TO) in 'Pass 6 lines' items 1 and 2 above. Claude applies the numbers unchanged and reruns pilot,
   dungeon_chain, lv1_run and move_table.
2. LF7-20 (LO6-30, LO6-31): should Job Board clients come from the floor's own spawn list or from creatures already met
   (today Preostmar, a B3F creature, can post a B1F job), and does the Guardian passive return
   (arena_protector_check's Guardian step prints a number and judges nothing)? 'Pass 6 lines' items 3 and 4 above.
   Claude then applies the held client line or adds a met record, and drops the Guardian step or turns it into a
   verdict.
3. FYI, no answer needed (L7-01): the Warden's defeat branch ran once for every hit that landed at 0 HP, so the boss
   EXP in that block may have been granted up to three times per win in recent playtests. Pass 7 grants it once, as
   written (warden_yield_check: the leader gains 130, one grant; 260 with the guard removed). No number changed.

## Pass 8 lines (plan, 2026-10-26)
From `sweep-2026-10-20/PASS8_PLAN_2026-10-26.md`, section "Grok". Result: `sweep-2026-10-20/PASS8_RESULT_2026-10-26.md`.
Pass 8 changed none of your numbers (stats, EXP, learnsets, spawns, damage). The new matchup line in the log reads the
chart and names the essences; it changes no multiplier. (Claude, integrator, 2026-10-26)
1. LH8-23 (LF7-19): Hollow Mouth is too hard for a level 1 team (pass 6 re-shoot: 7 monster-house ambushes, 4 times
   went down). Your `GROK_BUILD_RESULT_2026-10-26.md` task 1 answers it: no Monster House on Mouth B1F and B2F until
   "mouth" is in `beaten`, spawns stay, `REST_TO` stays 0.7. Not applied in pass 8 (the integration ran first); Claude
   applies it, with your task 3 learnset cut and the task 4 delete, as the next step and reruns pilot, dungeon_chain,
   lv1_run and move_table. Say if G1 to G5 of 'Pass 6 lines' has anything your task 1 did not cover.
2. LH8-24 (LF7-20): the Job Board can post a client from another floor's spawn list (Preostmar, a B3F creature, posting
   a B1F job), and arena_protector_check's Guardian step prints a number and judges nothing. Answer both; Claude then
   applies the held client line or a met record and drops or fixes the Guardian step.
3. L-02, partner growth stalls: over 5 post-pilot replays (about 21 floors) a partner earned about 0.1 flank and 0.5
   took per floor; the leader took 896 damage and the partner Tallowroot 19; Listener flank stayed 2 of 3 and Sparkwick
   flank 1 of 8. Retune the partner-side way needs (flank, took) in `EVO` (dungeon.gd:134-145), or say whether team
   pincers and guard hits should count toward the partner.
4. L-03: Troughspine's stage 1 condition is 'healed 40', but it has no heal until Archroot (Preston's 2026-10-21 rule).
   Give it a condition it can earn (took or slam) and keep the no-Seep rule.
5. L-05, rewards pile up with nothing to spend them on (bag after 5 replays: Second Wind 29, Lamp Oil 23, Reedberry 22,
   River Stone 22, 5 Pounce scrolls; 0 faints; each board pays 4 to 8 items). Set reward counts and a carry cap per item
   kind (Storage holds the rest).
6. L-11: all three Hollows use one map recipe (200 seeds: all 42x20, a 3x2 room grid, the commonest pattern on 14.5
   percent of floors). Give each Hollow its own recipe numbers in `DUNGEONS` (map size, cols and rows, room density,
   halls, wild count); the generator already takes them.
7. L-04: every request is labelled Rootbank Warren with a Warren client (120 of 120 over 30 boards). If Hollow Mouth and
   The Hollow should post requests, say which spawn table each Hollow's clients draw from. Pass 8 D10 already makes a
   job's client appear only in its own Hollow (a Warren client is no longer met in The Hollow); pay and posting are
   unchanged.
8. L-06: Courier Rank tops out at Rank 5 on the 4th replay (rank points 0, 170, 290, 430, 580, 760). Set the steps once
   Preston decides what a rank opens.
