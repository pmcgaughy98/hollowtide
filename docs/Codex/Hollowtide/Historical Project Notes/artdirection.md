# Crystal Creatures: How the art actually gets made

Written 2026-09-10. Answers the question "how do I get art like Nexomon, Coromon, Lumentale."

Every number here has a source. Anything unverified is labelled unverified.

---

## The short version

There is no tool, AI or otherwise, that turns a written creature concept into a finished
96x88 sprite at Coromon quality. Not Alpix, not Retro Diffusion, not PixelLab, not a
generator built from scratch.

What the good tools do is get you from a blank canvas to roughly sixty percent, and hand
you something a person who understands pixel art then finishes. That person has to exist.
Right now, on this project, nobody is that person.

That is the whole finding. Everything below is detail and options.

---

## What you are comparing yourself to

This matters because the comparison has been running unfairly.

**Coromon, by TRAGsoft.** Eighteen people. Monster art specifically was handled by Daniel
Reis and Marcus Dewdney as monster designer and animator, plus Manon Dreijer as monster
polisher. So roughly three people whose job was creature sprites, inside an
eighteen-person studio.
Source: https://coromon.wiki.gg/wiki/TRAGsoft

**Nexomon, by VEWO Interactive.** The lead creature designer on Extinction states over
three hundred creature designs for the sequel, across 2019 to 2020, in a role credited as
Lead Creature Designer, Character Designer, Concept Artist and Illustrator.
Source: https://www.artofmello.ca/nexomonextinction

Total VEWO team size is unverified. No primary source states it.

You are one person, with no art background, holding the output of a three-person monster
art team as the bar for your first sprite. That is not a reason to lower your ambition. It
is a reason to stop reading the gap as a personal failure or a tooling failure.

---

## What Alpix actually is

Alpix is a live shared 256x256 pixel canvas. An r/place for AI models. Its entire tool
surface is three calls: open the canvas, stamp a grid of pixels onto it, and fetch a
leaderboard ranking AI models by total pixels placed.

- There is no export. Nothing returns a file.
- The board is public and shared. Other people can draw over anything placed there.
- It does not generate. `stamp-grid` takes an ASCII grid typed out character by character,
  with a legend mapping letters to 32 fixed colour names.

That last point is the important one. Drawing on Alpix means an AI hand-specifying every
pixel as text. That is the same process that produced the placeholder blob. Same input,
same output, different destination.

Alpix is a fun toy. It is not part of this project's art pipeline.

---

## Why the placeholder failed, measured

```
placeholder_creature.png   96x88   5 unique colours   37% canvas coverage
player_placeholder.png     16x24   6 unique colours   55% canvas coverage
```

Five flat fills arranged in a hexagon. Three body tones, one outline, four white pixels.

Pedro Medeiros (saint11), whose free tutorials at
https://lospec.com/pixel-art-tutorials/author/pedro-medeiros are the standard beginner
reference, gives two rules the placeholder breaks:

1. The silhouette carries the identity. Keep interiors low detail and let the outline say
   what the thing is.
2. Avoid round and cylindrical forms. Cubic volumes read better in pixels.

The placeholder is a rounded hexagon with a flat interior. Its silhouette says nothing.
That is a drawing problem, not a rendering problem, and no amount of better generator code
fixes it, because what is missing is the decision about what a Topaz Tyranno looks like.

---

## The tools, verified

### Retro Diffusion

Built by a working pixel artist (Astropulse), trained on their own and licensed work,
specifically to output grid-aligned limited-palette art rather than pixel-art-styled
illustration.

- **Aseprite extension: $65 one-time full, $20 one-time Lite.** Runs locally and offline.
  No subscription, no credits for local generation. Commercial use permitted: the vendor
  states outputs "are owned by whoever creates them (you) and are able to be used
  commercially."
  Sources: https://astropulse.itch.io/retrodiffusion , https://astropulse.itch.io/retrodiffusionlite
- **Trap:** the extension uses different models than the website. Vendor's own words: "DO
  NOT buy the extension if you are trying to get the same results as the website, it is
  not possible!" Any demo you see of the web app does not transfer to the $65 extension.
- Web app: roughly $0.01 per image, prepaid credits that do not expire, commercial use
  allowed. Source: https://www.retrodiffusion.ai/llms.txt
- The "50 free credits" and "276x276" figures are secondary-sourced. The often-repeated
  "newer models cost 40 credits" figure is **unverified**. Do not plan around it.

**Disqualifying limitation for this project.** The developer, asked directly whether it
can recreate the same character in another pose, answered: "It creates something new, this
model doesnt have the consistency to make the same characters in different poses."
Source: https://itch.io/post/11931421

A monster collector needs each creature to survive across a battle sprite, an overworld
sprite, and later animation frames. Character consistency is the core requirement, and
this is the vendor conceding it is the core weakness.

### PixelLab

End-to-end game art pipeline rather than a single image model. Skeleton-based rotation
across four or eight directions, sprite sheet export, tilesets, and an official Aseprite
extension. On paper this is the better fit for a game.

**Pricing is unverified and should be treated as unknown.** The pricing page renders
nothing server-side. Every figure in circulation (a roughly $12/month entry tier, 200x200
free, 320x320 paid) traces back to aggregator sites citing each other, and at least one
contradicts the others. Log in and read the checkout page before believing any number.

What is primary: the terms of service grant ownership. Verbatim: "You retain ownership of
any content you create using PixelLab. You are free to use, modify, and distribute the
outputs from our tools for any purpose, except for training other models without our
explicit permission." Source: https://www.pixellab.ai/termsofservice

### The copyright caveat that applies to both

Neither vendor can grant you copyright. The US Copyright Office does not register purely
AI-generated output. What these licences give is the vendor's permission to use the
output, not an enforceable ownership interest in it. If ownership of your creature designs
matters to you, and for eleven named Guardians that are the identity of the game it
probably does, that is a real consideration.

### Can these produce a finished asset with no human cleanup?

No.

A developer using exactly this stack describes the real workflow: a mix of Gemini,
PixelLab and Retro Diffusion, aligned against handmade art, run through custom
post-processing for palette and outlines, then "manually cleaning up for release." Raw
output carries 100+ colours needing reduction, alpha-bleed edges, and unreliable pixel
grid snapping.

Note that 96x88 sits under every free tier resolution cap. **Resolution is not your
constraint.** Palette discipline and grid alignment are, and those are precisely what the
models do not deliver.

---

## The licence trap, and it is serious

Human-made asset packs are the obvious cheap option. One that looked ideal:

**Seliel the Shaper, Pixel Art Creature Sprites, Monster Battler Set.** $5.00 USD minimum,
24 unique creatures, roughly 32x32 with variation, all under 64x64, static, and explicitly
"100% HUMAN-MADE" with "NO AI USED IN ANY WAY."
Source: https://seliel-the-shaper.itch.io/monsterbattlerset

The licence permits commercial digital games and permits editing. It forbids printed
products and redistribution. And it contains this, verbatim:

> "I do not consent for any of my art to be used in any machine learning datasets, nor
> used in a project alongside 'AI' generated imagery, writing, code, or anything else."

Source: https://selieltheshaper.weebly.com/user-license.html

Read that clause against this project. **The GDScript in this repository was written by an
AI.** Not just the art. The clause covers code. On a plain reading, this pack cannot be
used in Crystal Creatures as the project currently exists, regardless of whether any AI art
is involved.

This generalises. Anti-AI clauses are now common among human pixel artists, and they
increasingly cover the whole project rather than just the art. **Any pack or commission
must be licence-screened for AI clauses specifically, with the AI-written codebase in
mind.** This is not a hypothetical risk, it is the first pack that came up.

It also means the two obvious cheap routes, human-made packs and AI generation, are
frequently mutually exclusive. You will have to pick a lane.

---

## Tools for drawing it yourself

- **Aseprite, $19.99** on Steam and on aseprite.org. No discount currently.
  Sources: https://store.steampowered.com/app/431730/Aseprite/ , https://www.aseprite.org/faq/
- **Free and legal:** Aseprite's own FAQ permits compiling from source for personal use,
  including commercial art made with it. You cannot redistribute the build. There is no
  trial version.
- **Pixelorama.** Free, MIT licensed, actively developed, and built in Godot. Given this
  project is already Godot, this is the strongest free option.
- LibreSprite is a stalled fork missing tilemaps, slices and reference images. Piskel is
  browser-based with no layers. GraphicsGale is free but unmaintained.

Learning material: saint11's tutorials on Lospec are free and are the standard
recommendation. https://lospec.com/pixel-art-tutorials/author/pedro-medeiros

---

## The four routes, honestly

**1. Learn to draw them.** Cost: $0 to $19.99. Time: months to competence. This is the only
route where the eleven Guardians end up being genuinely yours, and it is the only route
that does not depend on a licence you do not control.

**2. AI-assisted, you finish.** Cost: $20 to $65 one-time, plus route 1 anyway, because
cleanup requires knowing what correct looks like. Reported time saving around sixty
percent, unverified. Rules out human-made packs with anti-AI clauses. Ownership is
legally thin.

**3. Commission an artist.** Cost is the honest blocker. Commission data found was weak and
mostly dated, so no figure here is reliable enough to plan against. What is safe to say is
that eleven detailed original 96x88 creatures from a competent pixel artist is a real
expense that would compete with the move-out fund, and it should not be entered without
getting actual quotes first.

**4. Buy a human-made pack.** Cheapest and fastest to something presentable. But the
creatures will not be your creatures, the sizes will not match your spec, and the licence
screening problem above applies immediately.

---

## Recommendation

Route 1, with route 2 available later, decomposed the way everything else in this project
has been decomposed.

The reason is structural, not artistic. "Make eleven Coromon-quality sprites" is
open-ended accumulation with no visible endpoint. CLAUDE.md says plainly that this is the
shape of work that stalls. It is worth noticing that the art has been stuck since before
session one, across a much longer stretch than the four sessions in which the game went
from nothing to a walkable world with data and encounters. The code moved because it was
cut into pieces with endpoints. The art has never been cut that way.

So: **one creature. Not eleven. Start to finish. In the game.**

### Start with Sapphire Shark, 003

Not Topaz Tyranno. A dinosaur is a hard first silhouette.

A shark is one of the most readable silhouettes that exists, it is built from angular
forms which suit pixels far better than curves, and its palette is a tight blue-to-white
ramp, which is the easiest kind of ramp to build. It is the lowest-difficulty creature on
the roster that still looks like something when it works.

### On the spec

The 96x88 canvas is fine and is already baked into the pipeline, so keep it. But
"volumetric shading, metallic sheen, four spark pixels" is a description of the output of a
three-person monster art team. Treat it as the target to grow into, not as a gate on the
first sprite. A simpler, cleanly executed style beats an ambitious badly executed one, and
consistency across eleven creatures matters more to the finished game than rendering
sophistication on any one of them.

### What is already done and not part of the problem

The import pipeline is verified correct: nearest neighbour filtering, lossless compression,
no mipmaps, no alpha border processing, 3D detection disabled. A checkerboard of alternating
single pixels renders as hard-edged blocks with exactly two colours and no blending.

The data layer references sprites by file. Swapping placeholder art for real art is
changing one field.

When a real 96x88 sprite exists, it drops in and comes out crisp. That half is finished and
has been since session one.
