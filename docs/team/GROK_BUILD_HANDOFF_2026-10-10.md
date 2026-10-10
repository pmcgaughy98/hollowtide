# Grok Build: handoff (rewritten by Claude late on October 9, 2026)

## Start here (previous Grok session closing to save usage)

`docs/team/GROK_BUILD_RESULT_2026-10-10.md` does not exist. Do job 1 only, then stop and write that result. Do not commit.

Required reading is this file plus the three files under "Read first". Nothing else is required.

The game has pivoted more than once. A week of usage limits kept Grok out, so do not resume an older lane.

- **Current game:** a turn-based mystery dungeon after Explorers of Sky. First floor is `scenes/dungeon.tscn`. Rules are `scripts/dungeon/dungeon.gd`. The dungeon reads arena `KITS` and `MOVES`, not the `.tres` stats.
- **Side mode:** the real-time arena. It was the main fight, then it was switched off the same night (`real_time_battles = false`). Balance work on it waits until jobs 1 to 5.
- **Between dungeons:** Codex's hometown, courier hall and river. Route 1 is still Codex's. Do not edit it.
- **Older battle presentation** (contact lunges, aim points, VFX sheets, the `.tres` learn gate) is still in the tree. It is not what the dungeon plays. Leave it unless a job names it.

Disassemblies and scrapes are for structure only. No code, data, maps, sprites, text or music from them goes into the repo. The list, and what each one is for, is `docs/design/mystery-dungeon-pivot-2026-10-09.md` under "References for synthesis". Notes already taken: `docs/research/pmd-sky-references-2026-10-09.md` and `docs/research/pmd-video-notes-2026-10-09.md`. The useful ones for your lane are `pret/pmd-sky` (dungeons, run loop, team, job board), `PikalaxALT/pmd-red` (rescue mail, recruitment), and Emerald's Battle Pyramid inside `pret/pokeemerald` (dark floors, a bag that lasts one run). `pret/ds_disassembly_tools` and `PikalaxALT/gba_bios` have nothing for Hollowtide. Do not trust the Gemini learnset report's anatomy.

Parked from the last Grok session. Do not undo these, and do not spend the session on them:

- Molten Beam stays equipped on Vitrecrag. It has the chamber and the mouth. Job 1's Beam failures are Fusern and Slagglass, which lack those parts. Do not unequip Vitrecrag to clear them.
- Coalcrest's Plate Rake stays equipped. The old battle hides it. Do not delete the equip to silence a check.
- Oxbowarchon's sphere still has orange and gold pixels on the end of the green aura, on `assets/sprites/creatures/oxbowarchon.png`, the back sprite, and the style-matched Kingstone frames. A recolor was previewed and was not written. This handoff forbids art edits. Leave the sprites.
- Do not spend Retro Diffusion, rename the `signature` flag, or copy proposal stats into `.tres`.

You are Grok Build, the Grok CLI Preston runs from PowerShell in `C:\Users\pmcga\dev\hollowtide`. This file replaces every earlier version of it. **Everything you need is here or in the three required files below.**

## The game today, in five lines
1. **Hollowtide is a turn-based mystery dungeon** after Pokemon Mystery Dungeon: Explorers of Sky, Preston's favorite game. The first floor is `scenes/dungeon.tscn`, and its rules are in `scripts/dungeon/dungeon.gd`.
2. **Fights are turn-based too.** A real-time version was built and switched off the same night (`real_time_battles = false`). The arena (`scripts/arena/arena_prototype.gd`) is a separate side mode now.
3. **Your lane is unchanged.** You own creature and move numbers and rules. Preston owns names and art approval. Claude owns battle presentation, the dungeon's code and the save model. Codex owns the launch flow, world and art preparation.
4. **The dungeon reads the arena's creature data.** `KITS` (each form's moves) and `MOVES` (damage, cooldown, range) in `arena_prototype.gd` feed it, scaled by `HP_SCALE` and `DMG_SCALE`. The `.tres` stats do not drive either mode.
5. **Preston's newest direction is move tables.** He wants Pokemon-style signature moves: "rather than each pokemon having their own unique moves only they can use... it has to make sense for another pokemon to be able to use their move that was made with them in mind, like Leaf Blade for Sceptile." That is your 2026-10-02 rule, so your first job is there.

## Read first (required, in this order)
1. `docs/design/move-tables-2026-10-09/README.md`: what was built from your rule, and what waits on you.
2. `docs/creatures/move-table-2026-10-09.md`: the generated table, including shared signatures, line moves, and the five kit moves that fail the gate.
3. `docs/creatures/DESIGN_RULES.md`: your own rules, still the authority.

**Background, only if a job needs it:**
- `docs/design/dungeon-position-2026-10-09/README.md`: ambush, pincer, shove and slam.
- `docs/design/dungeon-tactics-2026-10-09/README.md`: team orders and stage sizes.
- `docs/design/mystery-dungeon-pivot-2026-10-09.md`: the pivot.

A Gemini deep-research report, "Hollowtide Move Learnset Research" (Preston's Google Drive), proposed the same split. **Do not trust its creature-by-creature claims.** It invented anatomy (Tallowroot "burrowing claws", Kithflare "predatory muzzle") and misnumbered lines. Parts come from the approved art only.

## What changed on October 9 (so nothing surprises you)
All of these are in `scripts/dungeon/dungeon.gd` unless noted, and every number is a draft for you.

- **Move table.** `scripts/moves/move_body.gd` holds:
  - `PARTS` for all 30 forms, each marked G (from your move-body-gate.md) or A (Claude's read of the current approved art);
  - `NEEDS` for every arena move;
  - `can_learn`, `missing`, `learners` and `shared`.

  A move whose parts cross lines is a shared signature. One whose parts only one line has stays with that line by anatomy. Ultimates (the arena's line `signature`) are never taught.
- **Move scrolls** (working name; Preston names it).
  - `SCROLL_SHARE` 0.25 of floor items is a scroll holding a damaging shared signature: today Rake, Pounce or Cinder Claw.
  - A teammate whose body passes learns it; at `MOVES_MAX` 4 it forgets one of the player's choice. No turn is spent.
  - Taught moves persist through `taught`.
- **Position is power.**
  - `AMBUSH` 1.5: a hit on a sleeping creature.
  - `PINCER` 1.5: a teammate stands on the tile behind the target.
  - Dash moves shove the target one tile. A shove into a wall or a body is a SLAM: `SLAM_SHARE` 0.15 of max HP, `SLAM_STAGGER` 1 lost turn, and any wind-up broken.
- **Team tactics.**
  - T cycles FOLLOW ME, GO AFTER FOES and GUARD ME.
  - `TACTIC_LEASH` {follow 4, go 99, guard 2}.
  - Partners walk up to `FLANK_REACH` 2 tiles to a foe's far side while it has more than `FLANK_WORTH` 0.4 of its health.
- **Recruiting.** `RECRUIT_RATE` {stage 1: 0.3, stage 2: 0.15, stage 3: 0.06}; `TEAM_MAX` 4.
- **Enemy warnings.** A wild creature's dash, line or burst ability spends a turn gathering and marks its tiles (`WARN_KINDS`).
- **Run loop.**
  - `LIGHT_DRAIN_EVERY` 3 and `LIGHT_ON_KO` 12.
  - `ITEMS`: Reedberry 15, Lamp Oil 40, River Stone 8.
  - `TRAPS`: Snare 2 turns, Silt Pit 6 damage and 15 light.
  - `RECIPE`: items 5, traps 4, monster_house 0.3; `MONSTER_HOUSE_WILD` 4.
- **Sizes and a pacing fix (no numbers for you).**
  - Dungeon sprites are sized by stage (`tools/arena/build_dungeon_set.py`).
  - A hallway back-and-forth bug was fixed (`tools/debug/dungeon_pace_check.gd`).

## Your jobs, in order. Stop after each and write what you did.

### 1. The move table (Preston's current focus)
1. **Confirm or correct every A part** in `move_body.gd` `PARTS` against the approved art. The sprites are in `assets/sprites/arena/<form>/` (the `se.png` front three-quarter view is the clearest), and you can view the PNGs.
   - Check most carefully: `springlegs` on Cinderhide and the ferrets, `crest` on Clinkerhide, `buttress` on Slagglass, `jade`/`slab`/`kingstone` on the stone line, `sail` on the Dustkite line, and `claw` on the Kithflare line.
   - Add a part the art clearly shows that a move could use. Never add one the art does not show.
   - **Keep your vocabulary.** Reuse an existing part name before inventing one.
2. **Rule on the five kit moves that fail the gate:**
   - Vent Barrage on Cinderhide and Clinkerhide (needs `channels`);
   - Molten Beam on Fusern and Slagglass (needs `chamber`, `mouth`);
   - Furnace Shard on Slagglass (needs `shelf`; Slagglass was redesigned as a brick dome on 2026-10-08).

   For each, either change the kit in `KITS` or change the move's `NEEDS`, and say why. Do not rename moves.
3. **Learnsets by stage, Pokemon style.** For each of the 10 lines, a table showing:
   - the moves each stage starts with (today that is its `KITS` entry);
   - which shared signatures each stage can learn from a scroll;
   - which line moves a later stage gains (the way a Pokemon learns its signature on evolving).

   Proposals only, in your result file. Keep each kit at 4 moves at most, and keep stage 1 = basic + 2.
4. **Scroll numbers.** Judge `SCROLL_SHARE` 0.25 and `MOVES_MAX` 4, and say whether the basic attack should ever be forgettable (today it is not).
5. **Move growth (optional proposal).** In Rescue Team DX, moves grow stronger with use (`docs/research/pmd-video-notes-2026-10-09.md`). Say whether Hollowtide should have it, and with what numbers. Proposal only; nothing like it exists in the code yet.

After any change to `PARTS`, `NEEDS` or `KITS`, run `move_table_check.gd`. It regenerates the table and tests a scroll in the dungeon.

### 2. A numbers pass on the dungeon
- **Turn every draft above into your number:** `HP_SCALE` 0.2, `DMG_SCALE` 0.6, `WILD_HP` 0.8, `WILD_DMG` 0.7, `SIGHT` 6, `REGEN_EVERY` 4, `RECIPE` (wild count 3), the position, tactics, recruit and run-loop numbers.
- **Target:** an early floor where a stage 1 pair wins every fight but feels each one: about 3 to 5 hits to down a wild creature, and a floor cleared in 100 to 200 turns.
- **Decide on the faint:** both autopilot run checks faint about once before B2F. Is that the right difficulty?

### 3. How each move reaches on the grid
`move_reach()` turns a move's arena telegraph and range into a reach: front tile, dash, line or burst, with a tile count (24 px per tile). Write a table: move, current reach, proposed reach, reason. Dash moves shove, so choosing dash or front now changes the move's role.

### 4. The non-damaging abilities on a grid
Marks, shields and guards, dives, perches, terrain and the Sail Cover / Vantage signatures are not in the dungeon yet, so some creatures show fewer than four moves. Propose a turn-based rule for each, with turns, tiles and numbers. Do not change their names or the `signature` flag. Claude builds them after Preston approves.

### 5. Floor recipes for the first dungeon
Three floors, and which wild creatures appear on each.

### 6. The arena (only after 1 to 5)
The arena is a side mode now, so these are lower priority. All the numbers are in `scripts/arena/arena_prototype.gd`.
1. **Oxbowarchon** is the outlier of the clean duel table (252 wins of 270). Bring it to the pack without touching its identity as backline artillery. Levers: the rail's telegraph length, damage, cooldown, `far_bonus`. Target: no pairing worse than 24-6.
2. **Supports that stall.** Warden, Galeshear, Highsignal and Starward draw 30 of 30 against each other.
   - Option one: a 1v1 clock with a points decision (you set the clock, Claude builds it).
   - Option two: enough chip in their basics to resolve inside 90 s.
   - Either way, no signature guard for supports.
3. **Follow-ups** (`FOLLOW_WINDOW` 0.9, `FOLLOW_MORE` 1.3, `FOLLOW_REFUND` 0.5, the AI's `d *= 1.4` in `_desire`). Finals landed 0 follow-ups in 60 s.
4. **The Spotter's trade.** `whistle_dart` damage and `MARK_BONUS` 1.15: a lone spotter should lose slowly but visibly hurt.

Tools for the arena:
- the duel table, about 15 minutes: `tools/debug/arena_sim.gd -- 15 1`;
- line checks: `arena_spotter_check.gd`, `arena_combo_check.gd`, `arena_oxbowarchon_check.gd`, `arena_charms_check.gd`, `arena_canvaswing_check.gd`, `arena_listener_check.gd`.

## How to test
**One Godot at a time.** Read the printed numbers, not the stills. A line that says `(WRONG)` or `SCRIPT ERROR` is a failure; fix it or put your change back.

Run each check like this, from the repo root:
```bash
"C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe" --path . --fixed-fps 30 --script res://tools/debug/move_table_check.gd
```

| Check | What it measures |
|---|---|
| `move_table_check.gd` | regenerates the move table; tests a scroll (refusal, learning, forgetting, keeping a move across floors, the hit) |
| `dungeon_check.gd` | a whole floor on autopilot: turns, faints, overlaps |
| `dungeon_run_check.gd` | items, traps, the lantern |
| `dungeon_warn_check.gd` | wind-ups |
| `dungeon_recruit_check.gd` | recruiting |
| `dungeon_position_check.gd` | ambush, pincer, shove, slam |
| `dungeon_tactics_check.gd` | orders and flanking |
| `dungeon_pace_check.gd` | the hallway pacing baseline, about 5 to 15 cases over four runs |

## Rules
- **Do not commit, revert or stash.** The tree holds uncommitted work from Claude, Codex and you, and Preston commits.
- **What you may edit:**
  - numbers in `scripts/dungeon/dungeon.gd` constants;
  - `PARTS` and `NEEDS` in `scripts/moves/move_body.gd`;
  - `KITS` and `MOVES` numbers in `scripts/arena/arena_prototype.gd`.
- **What you may not:** rename moves, forms or the `signature` flag; touch art, sounds, any `_draw_` function, the picker (`scripts/move_preview.gd`), or Codex's world and launch files.
- **No inventing:** no new creatures, names or lore. New moves are proposals in your result file, not code.
- **Show the math for every change:** a before-and-after line from a check, labelled with the job it serves.
- **Results go to `docs/team/GROK_BUILD_RESULT_2026-10-10.md`, move table first.** Say what you changed, the before-and-after numbers, what you left alone and why, and anything you could not test. Then add two lines at the top of `docs/AI_COLLABORATION.md` so Claude and Codex see it.

## Added after your 2026-10-10 result (Claude)
New drafts for you, all in `scripts/dungeon/dungeon.gd`: the boss floor (`BOSS_HP` 3.0, `BOSS_DMG` 0.9, `BOSS_MINIONS`), Monster Houses (`MONSTER_HOUSE_MAX` 7, `MONSTER_HOUSE_PER_TILES` 12, `MONSTER_HOUSE_ITEMS` 3, `MONSTER_HOUSE_LIGHT` 30) and traps (`TRAP_WARP_MAX` 1). With your numbers, `dungeon_boss_check.gd` shows 2 of 3 autopilot runs with a two-creature team faint before or at the boss, about 9 to 10 s of boss fighting when they reach it. Decide whether that is right for the first dungeon. Run one check at a time, and tell Preston before a long run so Claude does not start Godot at the same time.

## Next jobs from Preston, late October 9 (Claude)
1. **Evolution conditions** (Preston chose option A: Digimon-style conditions inside the one-path rule). The system is built; the numbers are yours: `EVO` in `scripts/dungeon/dungeon.gd` (knockouts, floors, and each line's "way": flank, took, ambush or slam). Read `docs/design/dungeon-evolution-2026-10-09/README.md`, and update `docs/creatures/evolution-and-signatures.md`: the trigger is conditions now, not any win. Measure with `tools/debug/dungeon_evolve_check.gd`.
2. **Teammate IQ: built by Claude on Preston's word ("do teammate iq task").** Six skills on IQ thresholds (`IQ_SKILLS`, `IQ_PER_FLOOR`, `IQ_PER_KO`). Read `docs/design/dungeon-iq-2026-10-09/README.md`. Your job: the thresholds and gains, and propose more skills in the same shape (one behaviour a turn-based partner can do with existing systems; structure only, no copied names). Measure with `tools/debug/dungeon_iq_check.gd`.
3. **Health now carries between floors** (Preston decided). Every floor used to heal fully. Re-measure your floor numbers and the boss with `dungeon_check.gd`, `dungeon_run_check.gd` and `dungeon_boss_check.gd`, and retune so a stage 1 pair can finish the first dungeon with care.
