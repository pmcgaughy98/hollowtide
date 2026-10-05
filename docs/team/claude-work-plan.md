# Claude's Hollowtide work plan

**Started 2026-09-28 at Preston's request:** a standing queue so Claude always has a next task. It follows
`THE_CONCEPT.md` scope order, `docs/team/claude-next-shift-handoff.md`, and the role charter (Claude leads Godot
systems and battle architecture; Codex asset prep and wiring; Gemini research; Grok balance and
non-creature art; Opal the Forges; Preston approves art, lore, move feel and releases).

**2026-10-02.** Preston assigned Grok future creature and move rules. Read the top of `docs/AI_COLLABORATION.md` before this queue. The win trigger and the body gate are already in the scripts. HP between battles and saving are still open here. Do not rebuild evolution, and do not copy proposal stats or kit swaps into the creature files.

**How to use it:** take the first task that is not done and not waiting on Preston. One task per session,
ending in something he can press Play on. Mark it done here with the date and what was verified. If
Preston asks for something else, his request wins; slot it in and carry on after.

Status keys: **NOW** in progress · **NEXT** ready · **WAIT** needs a Preston decision first · **LATER** after its phase.

## Phase A: battle feel (current)

| # | Task | Status | Done when |
|---|---|---|---|
| A1 | **Molten Glass Forge art.** Run the Effect Forge in MODE ACTION for heavy molten-glass globs and an on-target splash; convert, swap in for the hand-made 2-4 px globs in `assets/sprites/effects/vitrecrag/`. **2026-09-28: built.** Preston generated the sheet; `tools/cut_molten_glass_effect.py` cuts eruption, three flight globs, splash and crust into `assets/sprites/effects/vitrecrag/forge_molten_glass/`, wired into the gush and lob scenes. Verified in a scripted battle. | Awaiting Preston's look | Pour preview shows Forge glass; Preston approves or keeps the hand-made globs. |
| A2 | **Battle framing for big foes.** The current visible-foot lines, player-side size cap, and HUD layout show Vitrecrag fully on both sides in Summer captures (2026-09-29). Keep this framing. Attack focus near the top still needs a separate shot review. | NEXT: attack shot review | Vitrecrag and an ordinary foe remain fully readable during their attacks. |
| A3 | **One action timeline for every move.** Fold the pieces built for Molten Glass (hit frame, brace, emitter, volley) into a documented per-move timeline. Put Molten Beam (connected, sustained) and Molten Cannon (one heavy launched mass, separate impact) on it. | NEXT | Vitrecrag's three ranged moves read as three different physical attacks. |
| A4 | **Contact tuning.** The generic travel calculation now uses a 2 px edge margin and an 80% centre-distance cap (2026-09-29). The cap can leave a larger visual gap. The player HP card still covers part of the attacker at contact; Shoulder Drive and other melee moves still need a review before wider CONTACT tagging. | NEXT: HUD and move review | Contact reads clearly without covering either creature or the HP card. |
| A5 | **Your-side attacks.** Drawn frames are skipped for back sprites. Decide per move whether the back view gets emitters, a volley, or its own frames. **2026-09-28: Molten Glass done** via `attack_back_frames` (glowing furnace frames from `tools/build_vitrecrag_back_pour.py`), `attack_back_emitter_offset`, and glass drawn behind the attacker; preview `scenes/vitrecrag_back_pour_preview.tscn`. Other moves still use the plain projectile from behind. | Molten Glass awaiting Preston's look |
| A7 | **Big creatures on your side.** The player-side foot line and size cap now keep Vitrecrag's rear body and feet above the message box in the current battle view. Verified in a Summer back-pour preview capture (2026-09-29). | DONE for idle framing | A 1.75x partner is fully readable from behind. |
| A6 | **Hit and guard reactions.** Defender body reaction on impact and a visible brace for Guard, using whole-sprite motion first. | LATER | A guarded and an unguarded hit look different. |

| A8 | **Vitrecrag Plate Lunge.** Built 2026-09-28 per the attack-sheet protocol: frame library, analysis, in-game body with transplanted lowered head and a sliding plate, contact charge with wind-up. **v2 after Preston's review:** whole Opal poses cut at their true grid so the body and legs move. See `assets/sprites/creatures/attacks/vitrecrag_plate_lunge/README.md`. | Awaiting Preston's look |
| A9 | **Molten Glass recheck against the research** (Preston): re-cut all four Molten Glass body sheets, look for the head-retraction hole with lava in it, and rebuild if better frames exist. **Analysis done 2026-09-28** (lava-pour README): v2 order proposed using sheet 4's glowing retraction hole, the shell flood, and three drawn pours. **v2 built 2026-09-28** with whole poses (sheet 2 backbone, sheet 4 lava hole, sheet 1 pour). Style match handed to Codex. | Awaiting Preston's look |

## Phase B: creatures that persist (scope step 7)

| # | Task | Status | Done when |
|---|---|---|---|
| B1 | **Individual creature state.** `PartyMember` carries its own HP, move uses and placeholder level/XP; battle entry, exit, capture, fainting and switching update one individual. `CreatureData` stays species data. | NEXT (after A2 or A3) | HP carries from one encounter to the next. |
| B2 | **Save and load.** Versioned save file with defaults for missing fields. | LATER | Quit, relaunch, same party and HP. |
| B4 | **2v2 battles with an ally (campaign partner).** Replace the fixed one-player/one-foe fields in `battle_screen.gd` with battle slots (creature, sprite, home, facing, HP card, chosen action), then turn order across all slots, a target choice, ally AI, and two HP cards per side. The attack code is already slot-ready: every effect is placed from the attacker's and target's sprites (`_emitter_point`, mirroring, zoom), and the back view serves both you and an ally. Needs B1 first; slot positions need a Preston layout pass. | LATER (after B1) | A 2v2 preview where you and an ally each attack, from the back view, at two foes. |
| B3 | **Evolution play review.** The win trigger is already the rule for any form with `evolves_into` (`docs/creatures/evolution-and-signatures.md`, 2026-10-02). It was checked headless, not in a played battle. A normal battle still needs to show the change. Do not replace the trigger, and do not add levels. | NEXT after B1 | One normal battle shows the evolution and carries the owned creature's state. |

## Phase C: the first courier route (scope step 8)

| # | Task | Status | Done when |
|---|---|---|---|
| C1 | **Play review of `scenes/first_route_prototype.tscn`** end to end; list what breaks. | NEXT (can run any session) | A written list of issues with file paths. |
| C2 | **Route in the real game flow.** Keep `main.tscn` as the intended normal start after the active battle-preview session finishes (decision 2026-09-29); another Summer editor currently keeps `vitrecrag_pour_preview.tscn` in `project.godot`. The first route stays on F6 until its opening camera and complete journey are reviewed. | NEXT after C1 | Press Play, walk the reviewed route, battle, return. |
| C3 | **Habitat encounter pools** per route; no late evolutions in early grass. | LATER | Each route area draws from its own pool. |
| C4 | **Overworld layering and occlusion plan** for three-quarter trees and buildings (Grok makes the art, Codex imports). | LATER | Courier walks behind and in front of props correctly. |

## Phase D: keeping the project healthy (slot in whenever)

- **D1 Reusable battle review harness.** Turn this session's scripted driver (start a preview, fire a move, log frames, HP and screenshots) into `tools/` or `tests/` so every move change is checked the same way.
- **D2 Smoke test refresh.** `tests/field_encounter_smoke.gd` was last updated for an older cast; bring it in line and run it.
- **D3 Project hygiene check.** A small script that flags missing `res://` paths and any `class_name` defined twice. Two duplicate class names broke every battle until 2026-09-28.
- **D4 Ember move kits.** Once Preston approves names from `docs/creatures/ember-creature-physiology-and-action-brief-2026-09-27.md`, put each form's four moves on the A3 timeline.

## Waiting on Preston (short list)

1. **Decided for the current prototype on 2026-09-29:** keep the HUD-safe foot lines and size cap for big creatures; use a 2-pixel calculation margin and an 80% contact travel cap; return normal Play to `main.tscn` after the active preview session. The Cinderhide-only evolution limit in this item was superseded on 2026-10-02. Any form with a link evolves on a win. Details are at the top of `docs/AI_COLLABORATION.md`.
2. Still to review in play: contact crossing the player HP card, attack focus near the top edge, and the complete first-route loop before promoting it to normal Play.
3. Names and lore for new forms and moves stay Preston's; Claude drafts proposals only when asked.

## Not Claude's lead

New creature sprites and effect art candidates (Opal via Preston or Claude on request), non-creature
environment art (Grok), exact asset import and resource wiring (Codex), balance numbers (Grok), historical
research (Gemini). Claude reviews and integrates when asked.

## Log

- 2026-09-28: fixed duplicate class names breaking battles; reviewed Cinder Claw contact both sides;
  built Molten Glass head-retract pour with brace, gush, eruption, surges and a volley that reaches the
  target. Details in `docs/AI_COLLABORATION.md`.
