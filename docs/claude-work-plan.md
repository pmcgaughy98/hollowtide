# Claude's Hollowtide work plan

**Started 2026-09-28 at Preston's request:** a standing queue so Claude always has a next task. It follows
`THE_CONCEPT.md` scope order, `docs/claude-next-shift-handoff.md`, and the role charter (Claude leads Godot
systems and battle architecture; Codex asset prep and wiring; Gemini research; Grok balance and
non-creature art; Opal the Forges; Preston approves art, lore, move feel and releases).

**How to use it:** take the first task that is not done and not waiting on Preston. One task per session,
ending in something he can press Play on. Mark it done here with the date and what was verified. If
Preston asks for something else, his request wins; slot it in and carry on after.

Status keys: **NOW** in progress · **NEXT** ready · **WAIT** needs a Preston decision first · **LATER** after its phase.

## Phase A: battle feel (current)

| # | Task | Status | Done when |
|---|---|---|---|
| A1 | **Molten Glass Forge art.** Run the Effect Forge in MODE ACTION for heavy molten-glass globs and an on-target splash; convert, swap in for the hand-made 2-4 px globs in `assets/sprites/effects/vitrecrag/`. **2026-09-28: built.** Preston generated the sheet; `tools/cut_molten_glass_effect.py` cuts eruption, three flight globs, splash and crust into `assets/sprites/effects/vitrecrag/forge_molten_glass/`, wired into the gush and lob scenes. Verified in a scripted battle. | Awaiting Preston's look | Pour preview shows Forge glass; Preston approves or keeps the hand-made globs. |
| A2 | **Battle framing for big foes.** Design note, then smallest refactor: place each sprite by visible bounds and foot line, keep HUD-safe rectangles, keep the size difference. Vitrecrag's pour and legs sat under the player HP panel. **2026-09-28 first slice done** (Preston asked to fix the HUD): merged each HP header and bar into one card, moved the player card to bottom right above the commands, and stand every foe on a shared foot line (`FOE_FOOT_Y`) by its lowest visible pixel. Verified with Vitrecrag and Cinderhide as foes. Still open: player-side foot line, attack focus zoom near the screen top. | Awaiting Preston's look | Vitrecrag and an ordinary foe both fully visible, both sides, including the pour. |
| A3 | **One action timeline for every move.** Fold the pieces built for Molten Glass (hit frame, brace, emitter, volley) into a documented per-move timeline. Put Molten Beam (connected, sustained) and Molten Cannon (one heavy launched mass, separate impact) on it. | NEXT | Vitrecrag's three ranged moves read as three different physical attacks. |
| A4 | **Contact tuning.** Cinder Claw stops ~90-100 px short and crosses the player HP panel; watch Shoulder Drive; then tag the other melee moves CONTACT. | WAIT: Preston watches the claw and says how close. | Preston approves contact feel; melee moves use it. |
| A5 | **Your-side attacks.** Drawn frames are skipped for back sprites. Decide per move whether the back view gets emitters, a volley, or its own frames. **2026-09-28: Molten Glass done** via `attack_back_frames` (glowing furnace frames from `tools/build_vitrecrag_back_pour.py`), `attack_back_emitter_offset`, and glass drawn behind the attacker; preview `scenes/vitrecrag_back_pour_preview.tscn`. Other moves still use the plain projectile from behind. | Molten Glass awaiting Preston's look |
| A7 | **Big creatures on your side.** Vitrecrag's back view draws at 4x (512 px) and its lower half sits behind the message box. Player-side foot line and size cap, same idea as the foe's. | NEXT | A 1.75x partner is fully readable from behind. |
| A6 | **Hit and guard reactions.** Defender body reaction on impact and a visible brace for Guard, using whole-sprite motion first. | LATER | A guarded and an unguarded hit look different. |

| A8 | **Vitrecrag Plate Lunge.** Built 2026-09-28 per the attack-sheet protocol: frame library, analysis, in-game body with transplanted lowered head and a sliding plate, contact charge with wind-up. **v2 after Preston's review:** whole Opal poses cut at their true grid so the body and legs move. See `assets/sprites/creatures/attacks/vitrecrag_plate_lunge/README.md`. | Awaiting Preston's look |
| A9 | **Molten Glass recheck against the research** (Preston): re-cut all four Molten Glass body sheets, look for the head-retraction hole with lava in it, and rebuild if better frames exist. **Analysis done 2026-09-28** (lava-pour README): v2 order proposed using sheet 4's glowing retraction hole, the shell flood, and three drawn pours. **v2 built 2026-09-28** with whole poses (sheet 2 backbone, sheet 4 lava hole, sheet 1 pour). Style match handed to Codex. | Awaiting Preston's look |

## Phase B: creatures that persist (scope step 7)

| # | Task | Status | Done when |
|---|---|---|---|
| B1 | **Individual creature state.** `PartyMember` carries its own HP, move uses and placeholder level/XP; battle entry, exit, capture, fainting and switching update one individual. `CreatureData` stays species data. | NEXT (after A2 or A3) | HP carries from one encounter to the next. |
| B2 | **Save and load.** Versioned save file with defaults for missing fields. | LATER | Quit, relaunch, same party and HP. |
| B4 | **2v2 battles with an ally (campaign partner).** Replace the fixed one-player/one-foe fields in `battle_screen.gd` with battle slots (creature, sprite, home, facing, HP card, chosen action), then turn order across all slots, a target choice, ally AI, and two HP cards per side. The attack code is already slot-ready: every effect is placed from the attacker's and target's sprites (`_emitter_point`, mirroring, zoom), and the back view serves both you and an ally. Needs B1 first; slot positions need a Preston layout pass. | LATER (after B1) | A 2v2 preview where you and an ally each attack, from the back view, at two foes. |
| B3 | **Evolution play review.** Cinderhide to Clinkerhide win trigger, played with individual state; carry HP and moves correctly. The trigger is still a prototype. | WAIT: Preston approves the trigger after watching. | Preston watches it evolve in a normal battle. |

## Phase C: the first courier route (scope step 8)

| # | Task | Status | Done when |
|---|---|---|---|
| C1 | **Play review of `scenes/first_route_prototype.tscn`** end to end; list what breaks. | NEXT (can run any session) | A written list of issues with file paths. |
| C2 | **Route in the real game flow.** Which scene starts the game is Preston's call. | WAIT | Press Play, walk the route, battle, return. |
| C3 | **Habitat encounter pools** per route; no late evolutions in early grass. | LATER | Each route area draws from its own pool. |
| C4 | **Overworld layering and occlusion plan** for three-quarter trees and buildings (Grok makes the art, Codex imports). | LATER | Courier walks behind and in front of props correctly. |

## Phase D: keeping the project healthy (slot in whenever)

- **D1 Reusable battle review harness.** Turn this session's scripted driver (start a preview, fire a move, log frames, HP and screenshots) into `tools/` or `tests/` so every move change is checked the same way.
- **D2 Smoke test refresh.** `tests/field_encounter_smoke.gd` was last updated for an older cast; bring it in line and run it.
- **D3 Project hygiene check.** A small script that flags missing `res://` paths and any `class_name` defined twice. Two duplicate class names broke every battle until 2026-09-28.
- **D4 Ember move kits.** Once Preston approves names from `docs/ember-creature-physiology-and-action-brief-2026-09-27.md`, put each form's four moves on the A3 timeline.

## Waiting on Preston (short list)

1. A2 framing choice for big foes.
2. A4 how close a contact strike should end.
3. B3 whether winning a battle stays the evolution trigger.
4. C2 which scene the game starts in.
5. Names and lore for new forms and moves stay his; Claude drafts proposals only when asked.

## Not Claude's lead

New creature sprites and effect art candidates (Opal via Preston or Claude on request), non-creature
environment art (Grok), exact asset import and resource wiring (Codex), balance numbers (Grok), historical
research (Gemini). Claude reviews and integrates when asked.

## Log

- 2026-09-28: fixed duplicate class names breaking battles; reviewed Cinder Claw contact both sides;
  built Molten Glass head-retract pour with brace, gush, eruption, surges and a volley that reaches the
  target. Details in `docs/AI_COLLABORATION.md`.
