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
