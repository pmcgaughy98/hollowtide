# How to work on this project

A 2D pixel-art monster-collecting RPG. Godot 4.x, GDScript.

**This file is about how to work with Preston. It is not the design document.**

The design lives in `THE_CONCEPT.md` and that file is the authority on the game itself: the six
essences, the roster structure, naming rules, art direction, and scope order. If this file and
that one ever disagree about the game, `THE_CONCEPT.md` wins.

`docs/art-direction.md` holds the verified art pipeline and the licensing constraints.

> **Superseded September 2026.** This file used to contain the Crystal Creatures concept: eleven
> legendary gemstone Guardians, the strict alliteration naming rule, eleven elements, and the
> Heart of Eternity lore. All of that is replaced. `THE_CONCEPT.md` explains why the old naming
> formula could not scale and why the elements were arbitrary. Do not rebuild any of it.

---

## WHERE THINGS STAND

Checked against the files on 2026-09-22, not recalled.

- **Next unbuilt step is 7, evolution.** Steps 1 through 6 are marked done in `THE_CONCEPT.md`.
- **Two creatures exist:** Rimefin (Tide) and Cinderhide (Ember), in `data/creatures/`. Four of the
  first six are still undesigned, and those designs are his authorship, not generated.
- **`docs/reshape-proposal.md` is unsigned and it gates roster work.** It proposes eight essences,
  two lines each, all three stages, plus move-only essences on skills. `THE_CONCEPT.md` still says
  six essences and 24 lines, so the two disagree by design. Until he picks which two essences join
  the six, do not add creatures beyond the current six-essence plan. Evolution does not need that
  decision, so step 7 is not blocked.
- **This folder is not a git repository**, despite the `.gitignore` and `.gitattributes`. No history,
  no undo except OneDrive file versions.
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
