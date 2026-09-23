# What actually constrains this project

Written 2026-09-22, answering "why the limitation on essences, really."

---

## The short answer

**The essence limit is an art budget wearing a game design costume.**

Player cognition is the argument that got written down. It is not the argument that is doing
the work.

---

## The real derivation, in order

Read the documents backward and the chain is this:

1. `THE_CONCEPT.md`: "Forty-four sprites, not seventy-two. That difference is the project being
   finishable." **This is the root.** Everything else is downstream of it.
2. 44 sprites came from staging 24 lines unevenly: 6 three-stage, 8 two-stage, 10 single-stage.
3. 24 lines came from 6 essences times 4 lines each.
4. So 6 essences is the **output** of an art budget, not an input to it.

The type-count research in `THE_CONCEPT.md` says the workable range is ten to eighteen. Six is
below that range. The document handles this by saying dual typing "lands inside that." That is a
rationalisation written after the number was already chosen, not a derivation.

Then `docs/reshape-proposal.md` did the arithmetic honestly. Going all-three-stage removes the
uneven-staging lever, so sprites become lines times three with no exceptions:

- Art budget of roughly 48 sprites, divided by 3 stages, buys about **15 lines**
- Floor of **2 lines per essence**, because one line per essence was the stated failure of the old
  eleven-element system
- 15 divided by 2 rounds to **8 essences**

**That is the whole limit.** Eight because 8 x 2 x 3 = 48, and 48 is close to 44.

---

## What the research actually said, which is nearly the opposite

The evidence gathered in `reshape-proposal.md` argues the count barely matters:

- Temtem has 12 types and players find it harder than Pokemon's 18. Fewer types, harder chart.
- Coromon shipped **7 defensive types** plus move-only types that cost zero sprites, and said out
  loud that this was to add depth without adding creatures.
- The "6 to 9 types is the human memorisation ceiling" figure is flagged in that same document as
  "a rule of thumb from one discussion, not a verified figure."

What predicts whether players enjoy a chart is **inferability**, not count. `THE_CONCEPT.md`
already states the correct test: "Every relationship is reasonable from the name alone."

So the cognitive ceiling is real but it is not binding at 6, 8, or 10. The sprite count is binding.

---

## The number nobody has measured

The art budget rests on one unmeasured quantity: **how long one finished creature takes Preston.**

Never timed. Not in any document. Every scope decision in this project, including the essence
count, is derived from a guess about throughput that nobody has checked.

Stated availability as of 2026-09-22: roughly 7:00 to 10:00am and 6:45 to 10:00pm on work days.
Call it five to six hours a day if he wants them. That is a large budget by hobby-project
standards and it was not what the 44-sprite figure assumed.

**Until sprite rate is measured, the essence question cannot be answered, only argued about.**

### The measurement

Take one of the four undesigned essences. Take one creature from concept to in-game: design,
generate, clean up, drop the PNG in, point a `.tres` at it, see it in a battle. Write down the
wall-clock hours.

That single number converts the whole argument into arithmetic:

- `sprites_affordable = hours_per_week x weeks_you_stay_interested / hours_per_sprite`
- then `essences = sprites_affordable / (lines_per_essence x stages)`

One measurement, and the essence count stops being a matter of opinion.

---

## Money is not the constraint either

Verified from the vendor page on 2026-09-22: PixelLab's entry tier, Pixel Apprentice, is
**$12.00 per month** for 2,000 images. A free tier exists at 40 fast generations, then 5 per day.

Against a stated budget of $50 to $150, the honest ranking of what to actually buy:

1. **Sound, roughly $10 to $30.** There is none in the game. `docs/game-feel.md` records that
   developers put audio at about half the weight of an impact. Largest perceived-quality gap
   currently open, and the cheapest to close.
2. **A pixel font.** `game-feel.md` calls Godot's default UI font "the loudest remaining tell" and
   notes it is a single line to change once a font exists. PixelLab has a `create_font` tool.
3. **PixelLab at $12 a month**, which is already the verified pipeline.
4. Aseprite is unnecessary. Pixelorama is free and already in the pipeline.

Total needed is under $50. **The remaining $100 buys nothing this project needs.** Money is not
the lever here and spending more will not move the date.

---

## Version control

The project is not under git, and it sits inside OneDrive.

Those two facts interact badly. A `.git` directory inside a cloud-synced folder is a known
corruption risk, because the sync client copies and locks git's internal files while git is
writing them. Fixing the missing git without also moving the folder trades one problem for
another.

Recommended order:

1. Move the project out of OneDrive, for example to `C:\Users\pmcga\dev\hollowtide`
2. `git init` there
3. Push to a free private GitHub repository as the offsite copy

What this buys, in plain terms: an undo button for the entire project, and the ability to try
something structurally risky, like the eight-essence reshape, without risking the version that
already works. Cost is zero. Git LFS is not needed; 96x88 PNGs are far too small to require it.

---

## The open authorship decision, and a candidate

`docs/game-feel.md` ends by asking one question and refusing to answer it: **what shape is this
game?** It is explicit that an AI inventing that motif produces exactly the generic result the
project is trying to avoid.

Three days after that file was written, `Preston Hub\06 Creative Projects\Design\The_Turbo_Green.md`
was created. It documents a colour he has been unable to name for 28 years, measured at hue 167.5,
sitting in the gap between green and cyan that almost no manufactured colour occupies. Mid tone
**#42776B**, a near-exact match for Hooker's green. The file notes the colour is genuinely rare and
that the attachment has never been satisfied because nothing commercial matches it.

`THE_CONCEPT.md` already calls for a "shared palette family per essence."

**These are two halves of the same thing and the connection has not been made anywhere in the
project.** An authored colour identity that is provably his, attached to a game that needs one.

This document does not make that decision. Per `game-feel.md`, it is not Claude's to make. It is
recorded here as a candidate because nothing else in the project points at it.

---

## What would change these conclusions

One timed creature. If a finished creature takes 90 minutes, the art budget is far too
conservative and the essence debate was never real. If it takes 12 hours, 44 sprites is already
optimistic and the count should come down rather than up.
