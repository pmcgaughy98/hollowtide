# Grok Build: handoff for October 10, 2026 (the dungeon first, then the arena)

## The game pivoted on October 9: read this part first
Preston: "We're pivoting to more mystery dungeon, we can keep arena mode for maybe some other usage but even the combat turns etc." Hollowtide is now a **turn-based mystery dungeon** after Explorers of Sky. The arena is a separate side mode. Your lane is unchanged, you own the creature and move numbers and rules, but where they matter has moved.

**Read first (required):**
1. `docs/design/mystery-dungeon-pivot-2026-10-09.md`
2. `docs/design/dungeon-slice-2026-10-09/README.md`

**The dungeon jobs, in order. These come before every arena job below.**
1. **A numbers pass on the dungeon.** In `scripts/dungeon/dungeon.gd`:
   - `HP_SCALE` 0.2 and `DMG_SCALE` 0.6: arena HP and damage to dungeon values.
   - `WILD_HP` 0.8 and `WILD_DMG` 0.7: early-floor wild creatures.
   - `SIGHT` 6 and `REGEN_EVERY` 4.
   - `RECIPE`: room density, extra halls, wild count 3, the spawn list.

   Target: an early floor where a stage 1 pair wins every fight but feels each one, about 3 to 5 hits to down a wild creature, and a floor cleared in 100 to 200 turns. Measure with `tools/debug/dungeon_check.gd`; it prints turns, faints and the log.
2. **How each move reaches on the grid.** `move_reach()` turns a move's arena telegraph and range into a reach: front tile, dash, line or burst, with a tile count. Review the mapping line by line and propose a reach for any move that reads wrong. Write the proposals as a table of move, current reach and proposed reach, with a reason for each.
3. **The non-damaging abilities on a grid (your design lane).** Marks, shields, dives, perches, terrain, Phase-like moves and signatures are not in the dungeon yet, so some creatures show fewer than four moves. Propose a turn-based rule for each, with turns, tiles and numbers. Do not change their names or the `signature` flag. Claude builds them after Preston approves.
4. **Floor recipes for the first dungeon:** three floors, with which wild creatures appear on each.
5. **The run loop's numbers** (added late on October 9 when it was built). In `scripts/dungeon/dungeon.gd`:
   - `LIGHT_DRAIN_EVERY` 3, `LIGHT_ON_KO` 12, and how the lantern sets `light_radius()`.
   - The `ITEMS` effects: Reedberry 15, Lamp Oil 40, River Stone 8.
   - The `TRAPS` effects: Snare 2 turns, Silt Pit 6 damage and 15 light.
   - `RECIPE` items 5, traps 4, monster_house 0.3, and `MONSTER_HOUSE_WILD` 4.

   Since the run loop went in, both autopilot checks faint once before reaching B2F; decide whether that is the right difficulty. Measure with `tools/debug/dungeon_run_check.gd`.

**Do not commit, revert or stash. Numbers and proposals only.** Write your results to `docs/team/GROK_BUILD_RESULT_2026-10-10.md`, dungeon first, and add two lines at the top of `docs/AI_COLLABORATION.md`.

---

> **Late on October 9:** a real-time fight version was built and then turned off the same night. Preston: "keep the dungeon combat turn-based"; the arena is its own mode. So your dungeon jobs come first, the grid reaches (job 2) matter fully, and the arena jobs below stay lower priority. Recruit rates (`RECRUIT_RATE`) are new drafts.

## The arena jobs (lower priority since the pivot; do them only after the dungeon jobs)

Written by Claude on October 9 for Grok Build, the Grok CLI Preston runs from PowerShell. Preston owns names and art; Claude owns presentation and the save model; **you own the creature and move numbers.** Today's work left a pile of numbers that were set to make things work, not to make them right. Every one of them is labelled a draft and waits for you.

## Read first (required, in this order, nothing else before you start)
1. `docs/creatures/arena-balance-2026-10-08.md`, only its last two sections ("After the AI dash fix" and "Next"). The clean ten-final duel table and what it says.
2. `docs/creatures/arena-combo-2026-10-09/README.md`. The follow-up rule you are tuning, and why the AI rarely lands one.
3. `docs/creatures/arena-dustkite-2026-10-09/README.md`, the "Spotter" section only. The newest line's kit.

Everything else you need is in this file.

**Preston's rekit comes first.** He said on October 9 that he will propose a rekit for every creature to balance the gameplay. If a file of his about it exists when you start (look in `docs/creatures/` for anything named rekit or kits dated October 9 or 10, and in the top of `docs/AI_COLLABORATION.md`), read it before the jobs below and work your numbers to his kits, not to the current ones. If it does not exist yet, do the jobs below as written and say in your result which numbers his rekit would change; expect some of your work to be redone when it lands. His kit decisions outrank anything in this file; your numbers serve them.

## Where the numbers live
All in `scripts/arena/arena_prototype.gd`, which is one big file. Search for the name; each is a `const` or a dictionary entry near the top.
- `KITS`: per form, `hp`, `speed`, `far_bonus`, and which moves it carries. `MOVES`: per move, `damage`, `cooldown`, `range`.
- Follow-ups: `FOLLOW_WINDOW` (0.9), `FOLLOW_MORE` (1.3), `FOLLOW_REFUND` (0.5), and the AI's preference `d *= 1.4` inside `_desire` (search "a follow-up").
- The Spotter line: `MARK_BONUS` (1.15), `SPOTTER_RANGE` (120), `SPOTTER_AGAIN` (10), `SIGNAL_DOUBLE` (2.0), `VANTAGE_REACH` (90), `PERCH_SECONDS` (6), `PERCH_WORTH` (160), and the `whistle_dart`, `signal_mark`, `decoy_call`, `vantage` entries in `MOVES`.
- Charms: `THORNS_BACK` (0.4), `BLINK_DISTANCE` (90). Dodge step: the chance is a line inside `_ai_dodge` (`var chance: float = 0.8 ... 0.3 ... 0.55`, listeners, bruisers, everyone else) and `DODGE_COOLDOWN` (4.0).
- Kingstone Rail and Oxbowarchon: `TELEGRAPH["rail_shot"]` and the rail entries in `MOVES`.

## Your jobs, in order. Stop after each and write what you did.
1. **Oxbowarchon** is the outlier of the clean table: 252 wins of 270, 30-0 over Scourmaw and Vitrecrag. Only Ironvent closes on it (14-16). Bring it to the pack without touching its identity (backline artillery). Levers: the rail's telegraph length, its damage, its cooldown, `far_bonus`. Target: no pairing worse than 24-6 either way.
2. **Supports that stall.** The Warden, Galeshear, Highsignal and Starward draw 30 of 30 against each other and 24 to 28 against Vitrecrag. They are supports and should lose duels, but a draw is nothing. Decide one of: a 1v1 clock with a points decision (then say so; Claude builds it, you set the clock), or enough chip in their basics that two supports resolve inside 90 s. Do not give supports a signature guard; DESIGN_RULES keeps that for the Protector.
3. **Follow-ups.** Two finals that dodge and kite opened 5 windows and landed 0 follow-ups in 60 s; stage 1 forms landed 2 in 20 s. If the rhythm should matter for the AI, lengthen `FOLLOW_WINDOW` or raise the AI's preference, and say what the player's version should be. Keep the basic's follow-up bonus at or under 1.3 unless the table says otherwise.
4. **The Spotter's trade.** Highsignal dealt 15 in a 37 s duel: the perch and the kite profile keep it alive without scoring. Set `whistle_dart` damage and `MARK_BONUS` so a spotter alone loses slowly but visibly hurts, and so a marked enemy in a 3v3 feels the mark.
5. Only if 1 to 4 are done: Thorns at 0.4 was proposed for a cut on the tainted table and then the clean table said it was fine. Leave it unless job 1 or 2 moves it.

## How to test anything you change
One Godot at a time. Each run writes its own file; read the numbers, not the stills.
```bash
"C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe" --headless --path . --fixed-fps 30 --script res://tools/debug/arena_sim.gd -- 15 1 > docs/creatures/arena-sim-2026-10-10-grok.log 2>&1
```
That is the duel table, 30 matches a pairing, ten finals, about 15 minutes. The lines read `A vs B: A wins - B wins (draws)`. For one line's kit after a change, run its check and read the printed lines (every check ends with an AI fight):
```bash
"C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe" --path . --fixed-fps 30 --script res://tools/debug/arena_spotter_check.gd
```
Other checks: `arena_combo_check.gd`, `arena_oxbowarchon_check.gd`, `arena_charms_check.gd`, `arena_canvaswing_check.gd`, `arena_listener_check.gd`. A check that prints `(WRONG)` is a failure; fix or revert.

## Rules for the day
- **Do not commit, do not revert, do not stash.** The tree holds about 410 uncommitted files from Claude, Codex and you; Preston commits.
- Change numbers and `KITS` entries only. Do not rename moves, forms or the `signature` flag; do not touch art, sounds, the picker (`scripts/move_preview.gd`), or any `_draw_` function.
- The arena is a 2D arena fighter now, not the turn-based battle. Stats in `data/creatures/*.tres` do not drive the arena; `KITS` and `MOVES` do.
- Show the math for every change (a before-and-after line from the sim or a check) and label each number with the job it serves.
- Write your results to `docs/team/GROK_BUILD_RESULT_2026-10-10.md`: what you changed, the before-and-after numbers, what you left alone and why, and anything you could not test. Add two lines at the top of `docs/AI_COLLABORATION.md` under "Working Together on Hollowtide" so Claude and Codex see it.

## What Claude did today, so nothing surprises you
The Dustkite line (line 9, the Spotter); a fix for an AI bug that froze every AI creature on its first dash, which is why the October 8 table was wrong; left click as a basic attack; and five feel items for the steered creature (attack on press with a buffer, cast feedback, mouse aim with right-click lock, a reach ring and telegraph ghosts, follow-ups). None of it changed a creature's numbers on purpose; where a number was needed it was set as a draft and listed above.
