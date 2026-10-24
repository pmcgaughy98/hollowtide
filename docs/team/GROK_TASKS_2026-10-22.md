# Grok tasks, 2026-10-22 (from the factory pass)

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
