# Grok Build: handoff (rewritten by Claude late on October 9, 2026)

## Start here (Grok, 2026-10-10, after Claude's same-day updates)

Jobs 1 to 6 are done. The record is `docs/team/GROK_BUILD_RESULT_2026-10-10.md`. Do not redo them. Do not commit.

The learnset answer is `docs/creatures/learnset-draft-2026-10-10.md`. Claude copied `LEARN` and `WAITING` into `scripts/dungeon/dungeon.gd` and reported `dungeon_learn_check.gd` passing. The "starts with the whole kit" tables inside the result file are the earlier proposal. The wired consts replace them.

### Open now

As of 2026-10-16 there is no Grok task file newer than `docs/team/GROK_TASKS_2026-10-12.md`. That job is done. The record is `docs/team/GROK_BUILD_RESULT_2026-10-12.md`. Do not redo it, and do not start the October 10 or October 11 lists.

Troughspine no longer learns Seep. Archroot learns it on evolving. Heal 6 and the 3 turns were not changed. `pilot_chain_check.gd` was not run after the floor change. Seed 31337 finished The Hollow at level 8, so a house-heavy floor may enter the Warden above level 5. That moment was not printed. The essence chart and the health-carry re-measure are still parked.

### Claude changed, and it is not a numbers job unless Preston asks

Evolution is confirmed at the Growth Shrine in town. The campaign opens on the soul prologue. The pause menu has TEAM, BAG, FLOOR, and LOG. Codex's town art (Hall, shrine, Scroll Keeper, Yard, job board) is presentation. Leave it.

Required reading is this file plus the three files under "Read first". Nothing else is required.

The game has pivoted more than once. A week of usage limits kept Grok out, so do not resume an older lane.

- **Current game:** a turn-based mystery dungeon after Explorers of Sky. First floor is `scenes/dungeon.tscn`. Rules are `scripts/dungeon/dungeon.gd`. The dungeon reads arena `KITS` and `MOVES`, not the `.tres` stats.
- **Side mode:** the real-time arena. It was the main fight, then it was switched off the same night (`real_time_battles = false`). Arena balance is parked. The open tasks are the healer line, the new essence chart, and a re-measure now that health carries.
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
5. **Move tables are in.** The 2026-10-02 rule is live in `move_body.gd`. The open work is the Tasks section above the old October 9 notes.

## Read first (required, in this order)
1. The Tasks section in this file.
2. `docs/creatures/arena-springvault-2026-10-10/README.md`: the healer line Claude built, every number still a draft.
3. `docs/creatures/essence-expansion-proposal-2026-10-10.md`: the four new essences and the chart sketch.
4. `docs/creatures/learnset-draft-2026-10-10.md`: decided and wired. Do not redo it.
5. `docs/creatures/DESIGN_RULES.md`: still the authority on parts and ultimates.

The October 9 move-table files are the finished job. Read them only if a task names them.

**Background, only if a job needs it:**
- `docs/design/dungeon-position-2026-10-09/README.md`: ambush, pincer, shove and slam.
- `docs/design/dungeon-tactics-2026-10-09/README.md`: team orders and stage sizes.
- `docs/design/mystery-dungeon-pivot-2026-10-09.md`: the pivot.

A Gemini deep-research report, "Hollowtide Move Learnset Research" (Preston's Google Drive), proposed the same split. **Do not trust its creature-by-creature claims.** It invented anatomy (Tallowroot "burrowing claws", Kithflare "predatory muzzle") and misnumbered lines. Parts come from the approved art only.

## What changed on October 9 (so nothing surprises you)
History. The Tasks section is the work. Several numbers below were changed in the result (`SCROLL_SHARE` is 0.10, `RECRUIT_RATE` is 0.12 / 0.08 / 0.04, the floor is 3 by 2). Do not put the old drafts back.

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

## Tasks (2026-10-10). Superseded by GROK_TASKS_2026-10-11.md. Do not do this list.

The October 9 jobs under "Done" are finished. Do not redo them.

### 1. Springvault, the healer (code index 10)
Claude built the line. The numbers and the body gate are not ruled. Read the art in `assets/sprites/arena/troughspine/`, `archroot/`, and `springvault/` (`se.png` first) before keeping a part.

- Reuse a part name that already exists. `roots` is Tallowroot's. Listener's frills are `gillplate`. `muzzle`, `gills`, and `arches` are new. Keep a new name only when no old name is the same part.
- Seep is gated on `gills`. The written mechanic is planting roots, and stage 1 has no roots. Decide which is true. If the heal is the plant, Troughspine does not learn Seep. Archroot does, on evolving.
- Drafts already in code, to keep or change with the math: Spring Spit damage 10, cooldown 1.0, range 110. Seep heal 6, cooldown 9, `SEEP_TURNS` 3. `EVO[10]` way `healed`, need 40 then 100, KOs 2 then 5, floors 2 then 4. B2F spawn `[10, 0]`.
- `LEARN` may change only to match that gate. Mineral Brace, Vault Arch, and Headspring are not moves. Do not invent the ids.
- The roster draft called this line 12. Edit index 10.
- After a parts or needs change, run `springvault_check.gd`, then `move_table_check.gd`.

### 2. Chart numbers for Sinew, Loam, Murk, and Blight
They are in the essence list and neutral in `ARENA_CHART`. The sketch (two strengths and two weaknesses each) is the essence proposal. Set the cells, or say why a cell is wrong. Use the chart's existing steps: main 1.5 and 0.75, second 1.25 and 0.9. Do not rename an essence. Punchybun is Sinew. Sparkjab and Starward are Sinew/Electric. Tallowroot is Bloom/Loam. Rimefin and Scourmaw are Tide/Murk. The Warden stays Tide/Hollow.

Show one hit before and after for a matchup the new cells change. One Godot at a time.

### 3. Re-measure the first dungeon now that health carries
`_build_floor(floor_n == 1)` is the only full heal. Job 2's 100-to-200-turn clocks were taken when every floor healed. Run `dungeon_check.gd`, `dungeon_run_check.gd`, and `dungeon_boss_check.gd`. The boss is the Quietwater Warden. A stage 1 pair should still finish the first dungeon with care. Retune only if they cannot. Tell Preston before a long run.

### Parked
Written already. Not the next session unless Preston asks.

- Grid reaches (old job 3). `move_reach()` was not changed.
- Non-damage moves on the grid (old job 4). They sit in `WAITING`. Claude builds them after Preston approves.
- Arena pack target. Oxbowarchon did not reach 24-6. The arena is the side mode.
- Move growth. Not for this game yet. The proposal is +1 at 10 uses and +1 at 25, cap +2, if it is ever wanted.

## Done (do not redo)

Record: `docs/team/GROK_BUILD_RESULT_2026-10-10.md`.

- Jobs 1 to 6: move table (0 kit failures), dungeon numbers (`SCROLL_SHARE` 0.10, `RECRUIT_RATE` 0.12 / 0.08 / 0.04, floor 3x2), reach proposals, non-damage proposals, floor spawns, arena tunes.
- Learnsets, wired by Claude from `learnset-draft-2026-10-10.md`.
- Evolution conditions kept. IQ gains stay 1. Thresholds stay 3, 6, 10, 15, 20, 25.
- Boss, Monster House, and warp cap kept. Health carry is what task 3 measures. It was not retuned.

The old job text is not repeated here. It is the result file.

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
| `dungeon_learn_check.gd` | level-up and evolve learns |
| `dungeon_boss_check.gd` | the Warden floor |
| `springvault_check.gd` | the healer line |
| `dungeon_evolve_check.gd` | evolution conditions |
| `dungeon_iq_check.gd` | IQ thresholds |

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

## Closed notes (Claude, late October 9)

These were the follow-up jobs. Evolution conditions and the IQ thresholds were kept. The boss, Monster House, and warp numbers were kept. Health between floors is task 3 in the list above, not a separate job. One Godot at a time. Tell Preston before a long run.
