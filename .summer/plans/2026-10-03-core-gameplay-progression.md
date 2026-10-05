# Core Gameplay & Progression Implementation Plan

> **For agentic workers:** implement this plan task-by-task, in order, checking off each step as it lands. Steps use checkbox (`- [ ]`) syntax for tracking. Dispatch a fresh subagent per task where tasks are independent, otherwise execute inline with a review checkpoint after each task.

**Goal:** Implement the complete core progression for Hollowtide — establish GameSoul memory, apply creature stat differentiation & move balancing from the verified design rules, build an intentional level & EXP progression system, and implement full save/load persistence for the party and player state (excluding route/world content owned by Codex).

**Architecture:** 
- GameSoul captured in `.summer/GameSoul.md` as durable memory for all agents.
- Base stats applied directly to `CreatureData` resources with validation via `CreatureRoster` and verification via `balance_sim.gd`.
- Progression added through decoupled formulas in `BattleRules`, state tracking in `PartyMember`, and victory rewards in `BattleScreen`.
- Persistence handled through a dedicated `SaveManager` interacting with `PlayerParty` and overworld state via standard Godot JSON serialization.

**Tech Stack:** Godot 4.7 (Summer Engine), GDScript, Resource serialization (`.tres`), headless CLI execution.

---

### Task 1: Lock Down GameSoul Memory
**Files:**
- Create: `.summer/GameSoul.md`

- [ ] **Step 1: Write `.summer/GameSoul.md`**
Capture all established design pillars from `THE_CONCEPT.md`, `world-bible.md`, and `DESIGN_RULES.md`:
- Genre: 2D pixel art monster-collecting RPG, courier for the Wayline Compact in the Siltward Reach.
- Pillars: No grinding. No items in battle. Evolution changes identity, not just numbers. Every route connects people.
- Essence Cycle: Ember > Bloom > Stone > Tide > Ember (Gale neutral; Hollow 2x glass cannon; Electric & Ice pending).
- Rules: Strictly 3-stage linear evolutions (no branching/converging), unique job per creature line, ultimates vs signatures.
- Reserved forms: Punchybuns line (Electric guardian) reserved for Adrianna.

- [ ] **Step 2: Verify Summer Engine reads project context cleanly**
Call `summer_get_project_context` to confirm `projectMemory.canonical.gameSoul` is detected and valid.

---

### Task 2: Apply Stat Differentiation & Move Rebalancing
**Files:**
- Modify: `data/creatures/001_rimefin.tres`
- Modify: `data/creatures/002_cinderhide.tres`
- Modify: `data/creatures/101_clinkerhide.tres`
- Modify: `data/creatures/102_ironvent.tres`
- Modify: `data/creatures/103_kithflare.tres`
- Modify: `data/creatures/104_wayburn.tres`
- Modify: `data/creatures/105_coalcrest.tres`
- Modify: `data/creatures/106_fusern.tres`
- Modify: `data/creatures/107_slagglass.tres`
- Modify: `data/creatures/108_vitrecrag.tres`
- Modify: `data/creatures/903_oxbowarchon.tres`
- Modify: `data/moves/oxbowarchon_kingstone_rail.tres`
- Modify: `data/moves/vitrecrag_molten_glass.tres`
- Test: `tools/balance_sim.gd`

- [ ] **Step 1: Run balance simulator with overrides to verify expected outcome**
Execute `Summer.exe --headless --path . --script res://tools/balance_sim.gd -- --overrides docs/team/grok-pack-2026-10-01/RESULT_task1_overrides.json --out docs/battle/balance/sim-report-test.md`
Verify that duels match the expected 4–12 turn range.

- [ ] **Step 2: Write script or update the 11 creature resources and 2 move resources**
Apply exact values from `RESULT_task1_overrides.json`:
- Rimefin: HP 96, Atk 54, Def 66, Spd 58
- Cinderhide: HP 90, Atk 64, Def 64, Spd 54
- Clinkerhide: HP 104, Atk 70, Def 86, Spd 46
- Ironvent: HP 112, Atk 84, Def 76, Spd 38
- Kithflare: HP 78, Atk 64, Def 56, Spd 74
- Wayburn: HP 92, Atk 68, Def 64, Spd 70
- Coalcrest: HP 108, Atk 72, Def 74, Spd 62
- Fusern: HP 90, Atk 62, Def 56, Spd 66
- Slagglass: HP 100, Atk 74, Def 80, Spd 50
- Vitrecrag: HP 116, Atk 92, Def 72, Spd 34
- Oxbowarchon: HP 100, Atk 82, Def 96, Spd 42
- Kingstone Rail: power 54, max_uses 2
- Molten Glass: power 62, max_uses 2

- [ ] **Step 3: Run balance simulator on live data (without overrides)**
Verify that running `balance_sim.gd` without `--overrides` produces the exact same report, confirming live resources are updated.

- [ ] **Step 4: Verify roster validation**
Run `CreatureRoster.validate()` and `validate_evolutions()` to confirm zero errors or regressions.

---

### Task 3: Experience, Growth & Leveling System
**Files:**
- Modify: `scripts/battle_rules.gd`
- Modify: `scripts/party_member.gd`
- Modify: `scripts/battle_screen.gd`
- Test: `tests/test_leveling.gd`

- [ ] **Step 1: Write unit test for leveling formulas**
Create `tests/test_leveling.gd` verifying:
- Exp required curve: `exp_for_level(lvl)` (smooth curve, e.g. cubic or moderate quadratic up to level 50).
- Stat scaling calculation: `calculate_stat(base_stat, level)` giving predictable progression without power inflation.
- Exp yield from defeated opponent based on opponent species and level.

- [ ] **Step 2: Add growth formulas to `BattleRules`**
Add:
- `static func exp_required(level: int) -> int`
- `static func exp_yield(defeated: CreatureData, defeated_level: int) -> int`
- `static func stat_at_level(base_stat: int, level: int) -> int`

- [ ] **Step 3: Upgrade `PartyMember` to track level, current EXP, and effective stats**
- Add `var level: int = 1`
- Add `var current_exp: int = 0`
- Add methods: `gain_exp(amount: int) -> Array[int]` (returns levels gained, if any), `get_max_hp()`, `get_attack()`, `get_defense()`, `get_speed()`.

- [ ] **Step 4: Update `BattleScreen` to award EXP on victory**
- In battle victory sequence, calculate exp gained and award to active party member.
- Display level up fanfare/message if active creature leveled up.
- Pass level into combat calculations if wild creatures have level parameters.

- [ ] **Step 5: Run tests and verify clean execution**
Run `tests/test_leveling.gd` headlessly to confirm all formulas work as specified.

---

### Task 4: Persistent Save & Load System
**Files:**
- Create: `scripts/save_manager.gd`
- Modify: `scripts/player_party.gd`
- Test: `tests/test_save_load.gd`

- [ ] **Step 1: Write save/load round-trip test**
Create `tests/test_save_load.gd` testing:
- Populating party with 2 members, custom moves, specific level/exp.
- Saving to test path `user://test_save.json`.
- Restoring into a fresh party instance.
- Verifying species, level, exp, known moves, and active slot match 100%.

- [ ] **Step 2: Implement `SaveManager`**
- Serialization methods: `serialize_party() -> Dictionary`, `deserialize_party(data: Dictionary) -> bool`.
- File I/O: `save_game(slot: int = 0) -> bool`, `load_game(slot: int = 0) -> bool`, `has_save(slot: int = 0) -> bool`.
- Support saving player overworld position if available.

- [ ] **Step 3: Integrate with `PlayerParty` and game lifecycle**
- Add auto-save hooks upon winning a battle or catching a creature.
- Add `PlayerParty.load_saved_party()` on game startup if save exists.

- [ ] **Step 4: Run test to verify save/load pass**
Execute `tests/test_save_load.gd` headlessly and verify success.

---

### Task 5: End-to-End Verification & Health Check
**Files:**
- Test: `tests/field_encounter_smoke.gd`

- [ ] **Step 1: Run full diagnostics & smoke test**
Run `field_encounter_smoke.gd` and `balance_sim.gd` to confirm the entire project runs cleanly with no script errors or broken references.
- [ ] **Step 2: Take editor screenshot and check console logs**
Verify no lingering debugger warnings or scene errors in the live editor session.
