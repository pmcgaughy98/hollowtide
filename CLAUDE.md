# How to work on this project

> **Preston's role order, 2026-09-27:** Read `docs/team/agent-role-charter-2026-09-27.md` and the latest `docs/AI_COLLABORATION.md` before choosing work. Preston directs Claude to lead complex Godot systems and battle animation architecture, while Codex leads precise asset preparation and integration, Gemini research, Grok balance and non-creature concepts, and Opal the scoped art Forges. This is a default assignment; Preston's later direct request overrides it.

> **Attack sheets protocol, 2026-09-28:** When Preston brings Opal sheets for an attack, follow `docs/battle/attack-sheet-protocol.md` step by step (research, Summer MCP check, cut every frame, analyze each frame, order, re-analyze, then build).

> **Current-state pointer, 2026-09-26:** The snapshot under WHERE THINGS STAND below was checked on 2026-09-22 and is now historical. Read `docs/AI_COLLABORATION.md` for the latest asset, battle, evolution, and first-route handoffs. `THE_CONCEPT.md` now reflects Preston's 20-line, all-three-stage roster direction; `docs/world/world-bible.md` tracks the provisional first route. The new `scenes/first_route_prototype.tscn` is separate from the project start scene and has not been played end to end.

A 2D pixel-art monster-collecting RPG. Godot 4.x, GDScript.

**This file is about how to work with Preston. It is not the design document.**

The design lives in `THE_CONCEPT.md` and that file is the authority on the game itself: the six
essences, the roster structure, naming rules, art direction, and scope order. If this file and
that one ever disagree about the game, `THE_CONCEPT.md` wins.

`docs/art/art-direction.md` records the current art path, prior tool research, and licensing constraints.
The Godot import defaults are verified; the current Forge converter has been used on approved Ember sprites, while the newly installed v4 Opal prompt has not yet had a generation review.

> **Superseded September 2026.** This file used to contain the Crystal Creatures concept: eleven
> legendary gemstone Guardians, the strict alliteration naming rule, eleven elements, and the
> Heart of Eternity lore. All of that is replaced. `THE_CONCEPT.md` explains why the old naming
> formula could not scale and why the elements were arbitrary. Do not rebuild any of it.

---

## WHERE THINGS STAND

Checked against the files on 2026-09-22, not recalled.

- **Next unbuilt step is 7, evolution.** Steps 1 through 6 are marked done in `THE_CONCEPT.md`.
- **Three creature resources exist:** Rimefin (Tide), Cinderhide (Ember), and Cinderpelt (Ember).
  Cinderpelt is an unlinked experiment, not an approved evolution. Draft briefs for the larger
  roster are in `docs/creatures/creature-roster-draft.md`; the four additional first-six starters are still
  proposals, and no Opal-generated sprite art has been validated yet.
- **`docs/creatures/reshape-proposal.md` is unsigned and it gates roster work.** It proposes eight essences,
  two lines each, all three stages, plus move-only essences on skills. `THE_CONCEPT.md` still says
  six essences and 24 lines, so the two disagree by design. Until he picks which two essences join
  the six, do not add creatures beyond the current six-essence plan. Evolution does not need that
  decision, so step 7 is not blocked.
- **This folder is a Git repository.** Inspect its current branch and dirty files before editing;
  do not assume the branch is clean, and do not commit unless Preston asks.
- **The Hub copies are stale.** `Preston Hub\06 Creative Projects\Hollowtide\` holds older versions
  of the concept and art direction; `game-feel.md` there still matches. This folder is the source of
  truth. The folder name `crystal-creatures-concept` is leftover from the superseded version; the
  working title is Hollowtide.

---

## WHO YOU ARE WORKING WITH

Preston is the designer and director of this project, not a programmer. He has no formal coding background.

**This means:**
- Explain what code does in plain language before or after writing it. Not line-by-line, but what the piece is for and how it fits.
- When you make an architectural decision, say why, and say what the alternative was.
- Never write something you can't explain simply.
- If he asks "why did you do it that way," that's a real question, not a challenge.

**He has ADHD and chronic pain that makes long reading sessions expensive.** Keep explanations short and structural. Favor showing a working thing over describing a plan.

---

## THE HARD RULE: ONE COMPLETION PER SESSION

**This is the most important instruction in this file.**

Preston finishes things that have a visible endpoint and stalls on open-ended accumulation. That pattern is consistent across his whole life and it is not a discipline problem, it is how his reward system works.

**So every session must end with something that runs.** Not scaffolding. Not a plan. Something he can press play on and see.

- **Do not** scaffold the whole game architecture up front.
- **Do not** generate large amounts of code across many files in one pass.
- **Do not** build systems for features that don't exist yet.
- **Do** pick one small thing, build it, verify it runs, and stop.

If a request would take more than one session, say so and propose the first slice.

This applies to art as much as code. "Make the whole roster" is open-ended accumulation and it is
the shape of work that stalls. One creature, finished, in the game.

---

## TECHNICAL DIRECTION

- **Engine:** Godot 4.x. GDScript, not C#.
- **2D only.** This is a pixel-art game.
- Keep the project structure simple and readable. Preston needs to be able to find things.
- Use Godot conventions rather than clever abstractions.
- Comment code where the intent isn't obvious from the name.

**When something breaks, explain what broke and why before fixing it.** Debugging is where he'll learn the engine.

**Verify before claiming.** Run it. A test that passes can still be testing nothing, and that has
already happened twice on this project. Measure the thing itself rather than reasoning about it.

---

## SCOPE REALITY

Preston works full time, is managing a substance quit starting September 3 2026, and is saving toward moving out. This project is a creative outlet, not a deadline.

**Do not create urgency.** Do not suggest he work faster or longer. If he goes weeks without a session, pick up where things left off without commentary about the gap.

Scope order lives in `THE_CONCEPT.md`. Do not skip ahead. Do not build step four before step two works.

---

## WHAT NOT TO DO

- No emoji, no hype, no "let's crush this."
- No fabricated progress claims. If something doesn't work, say so.
- No presenting untested code as finished. If you haven't verified it runs, say that plainly.
- No em-dashes in anything written for him.
- Don't generate large volumes of content because more feels better. One working thing beats ten scaffolded ones.
- Don't invent creature names, designs, lore or stat values. That is his authorship. Generated
  creature data is how the previous roster broke.


## Working with Codex and shared design notes

Read docs/AI_COLLABORATION.md before working alongside Codex. It defines the source of truth, Git safety, research standards, and a short handoff format for both assistants. Preston has explicitly asked the assistants to help draft and synthesize the Hollowtide world and creatures. This supersedes the earlier blanket instruction not to invent names, designs, or lore only for proposal drafting. Label new ideas as proposals and do not silently promote them to canon. In particular, preserve Cinderhide and do not restore the removed Cinderpelt evolution link by inference.
