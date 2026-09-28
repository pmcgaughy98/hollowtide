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
| A1 | **Molten Glass Forge art.** Run the Effect Forge in MODE ACTION for heavy molten-glass globs and an on-target splash; convert, swap in for the hand-made 2-4 px globs in `assets/sprites/effects/vitrecrag/`. | NOW | Pour preview shows Forge glass; Preston approves or keeps the hand-made globs. |
| A2 | **Battle framing for big foes.** Design note, then smallest refactor: place each sprite by visible bounds and foot line, keep HUD-safe rectangles, keep the size difference. Vitrecrag's pour and legs sit under the player HP panel today. | WAIT: Preston picks shrink, reposition, or reserve space. | Vitrecrag and an ordinary foe both fully visible, both sides, including the pour. |
| A3 | **One action timeline for every move.** Fold the pieces built for Molten Glass (hit frame, brace, emitter, volley) into a documented per-move timeline. Put Molten Beam (connected, sustained) and Molten Cannon (one heavy launched mass, separate impact) on it. | NEXT | Vitrecrag's three ranged moves read as three different physical attacks. |
| A4 | **Contact tuning.** Cinder Claw stops ~90-100 px short and crosses the player HP panel; watch Shoulder Drive; then tag the other melee moves CONTACT. | WAIT: Preston watches the claw and says how close. | Preston approves contact feel; melee moves use it. |
| A5 | **Your-side attacks.** Drawn frames are skipped for back sprites. Decide per move whether the back view gets emitters, a volley, or its own frames. | LATER (after A3) | Vitrecrag's Molten Glass reads from both sides. |
| A6 | **Hit and guard reactions.** Defender body reaction on impact and a visible brace for Guard, using whole-sprite motion first. | LATER | A guarded and an unguarded hit look different. |

## Phase B: creatures that persist (scope step 7)

| # | Task | Status | Done when |
|---|---|---|---|
| B1 | **Individual creature state.** `PartyMember` carries its own HP, move uses and placeholder level/XP; battle entry, exit, capture, fainting and switching update one individual. `CreatureData` stays species data. | NEXT (after A2 or A3) | HP carries from one encounter to the next. |
| B2 | **Save and load.** Versioned save file with defaults for missing fields. | LATER | Quit, relaunch, same party and HP. |
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
