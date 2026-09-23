# How the art actually gets made

Written 2026-09-10. Answers "how do I get art like Nexomon, Coromon, Lumentale."

Revised the same day after testing PixelLab directly. The first version of this document was
wrong and its central claim is corrected below.

Revised again after the concept pivot. Crystal Creatures is superseded by THE_CONCEPT.md: six
essences instead of eleven elements, 24 lines and 44 sprites as the finished target, six
single-stage creatures as the first roster. Sapphire Shark survives as Tide. Every art finding
below still holds. Only the counts changed, and the consistency strategy got easier, because a
shared palette family per essence is a smaller target than one look across everything.

Every number here has a source or was measured. Anything unverified is labelled unverified.

---

## Correction to the first version

The first draft of this document said, flatly, that no tool turns a written creature concept
into a finished 96x88 sprite at Coromon quality, and that AI gets you to sixty percent and
hands the rest to a pixel artist who does not exist on this project.

That was based on research, not on testing, and testing falsified it.

PixelLab produced a usable Sapphire Shark at exactly 96x88 in about forty seconds for one
generation. It is in the game. The conclusion changed when the evidence did.

What survived the correction: the licence trap, the copyright position, and the open question
of consistency across the roster. Those are still real and they are now the actual
constraints.

---

## What was measured

Generated with `create_image_pixflux`, one call, seed 20260910:

```
requested            96x88
delivered            96x88          exact
alpha channel        present
semi-transparent px  0              <- no anti-aliasing anywhere
unique colours       31
coverage             41% of canvas
cost                 1 generation   (40 -> 39 remaining)
wall time            ~40 seconds
```

Compare the hand-coded placeholder it replaced:

```
placeholder_creature.png   96x88   5 colours    37% coverage
sapphire_shark.png         96x88   31 colours   41% coverage
```

Zero anti-aliased pixels is the number that matters. The research said AI pixel art output
carries alpha-bleed edges, 100+ colours, and unreliable grid snapping. At this size, with this
tool, none of that was true. Thirty-one colours is inside normal pixel-art discipline, and
`reduce_colors` can tighten it further if an essence family needs to share one palette.

The sprite imported into Godot and picked up all four pixel-art settings automatically from
`importer_defaults`: lossless, no mipmaps, no alpha border processing, 3D detection disabled.
It renders crisp at 4x in the encounter screen. The full chain works.

---

## What PixelLab actually is

An 85-tool game art pipeline, not an image generator. The parts that matter here:

**Generation**
- `create_image_pixflux` freeform text to pixel art. Canvas 16 to 400px per side, so 96x88
  is directly supported. Transparent background, outline style, shading, detail, view angle,
  facing direction, seed. Accepts `color_image_url`, a PNG whose colours become a **forced
  palette**. 1 generation per call.
- `create_image_pro` returns a set of candidates per call rather than one image: 4 candidates
  at 96x88, 16 at 85px or under, 64 at 42px or under. Cost is per call, not per candidate, and
  is **20 generations, measured**. Accepts up to 4 labelled reference images and a
  `style_image_url` with `style_copy` selecting any of `color_palette`, `outline`, `detail`,
  `shading`.
- `create_character` rigged characters with 4 or 8 directional views, for overworld sprites.
  `size` max 128 in standard/pro, 256 in v3. Quadruped templates are limited to bear, cat,
  dog, horse and lion, which will cover very little of a monster roster, so most creatures would
  need pro or v3 mode. **Pro mode costs 20 to 40 generations per call.**

**Cleanup, which is the part the research said did not exist**
- `reduce_colors` quantises onto a tight shared palette, several frames together so they come
  back sharing one palette.
- `correct_pixelart` sharpens edges, drops stray pixels, tightens palette, keeps the existing
  grid and size.

**Consistency mechanisms** (`style_image` tested and working, see below)
- `create_character_state` makes a variant that "ALWAYS preserves the SAME individual's face
  and identity" across all rotations.
- `style_character_id` on `create_character`, and `style_image_url` plus `style_copy` on
  `create_image_pro`, make a new asset match an existing one's art direction.

Account status after the consistency test: `subscription: trial`, `generations_total: 40`,
**17 remaining**, `credits: $0.00`.

---

## The two things that are still genuinely hard

### 1. Consistency across the roster. TESTED 2026-09-10. It works, with a recipe.

Three stages were run, each measured.

**Stage 1: matched parameters alone. FAILED.**
An Ember creature generated with byte-identical settings to Rimefin (same outline, shading,
detail, view, direction, guidance, seed) came out technically consistent and artistically
unrelated. Same canvas, zero anti-aliasing, same outline setting. Completely different material
language: Rimefin is translucent gem, the Ember one was opaque armoured mecha-beast.

It also arrived with a **baked-in grey ground shadow despite `no_background: true`**. Worth
knowing: transparent background does not mean no shadow.

```
Rimefin       31 colours   41% coverage
Ember (params) 44 colours  54% coverage
```

**Stage 2: `create_image_pro` with Rimefin as `style_image_base64`, `style_copy` set to
outline, detail and shading but NOT colour_palette. PARTIAL, and much better.**

Four candidates came back. The drop shadow was gone on all four. They picked up the crystal
shard spine motif, the outline weight and the detail level, and critically they were coherent
**with each other**. They still did not match Rimefin's translucency, and ran 44 to 46 colours
against its 31.

**Stage 3: `reduce_colors` across both together, 24 colours. THIS is what closes the gap.**

```
BEFORE   31 + 44 colours    shared colours = 0     union 75
AFTER    13 + 15 colours    shared colours = 4     union 24
```

Two sprites with nothing in common became two sprites drawing from one 24-colour palette. Both
flattened and posterised, which reads as pixel art rather than as an AI painting. Some fine
detail is lost, so 24 is aggressive for two creatures and should be tuned upward for a family.

**The recipe that works:**
1. Generate a whole essence family in ONE `create_image_pro` call with a style reference.
2. Run `reduce_colors` across that family together.
3. Pick the keeper by eye and fix what is left.

**Verified costs, measured from the balance, not from marketing:**

| Call | Cost | Notes |
|---|---|---|
| `create_image_pixflux` | 1 generation | one image |
| `create_image_pro` | **20 generations** | per call, NOT per candidate |
| `reduce_colors` | **0.1 generations** | effectively free |

`create_image_pro` returns more candidates on smaller canvases: 64 at 42px or under, 16 at 85px
or under, 4 at 170px or under, 1 above that. **96x88 sits just over the 85px line, which drops
you to 4 candidates for the same 20 generations.** Generating exploration passes at 85px or
smaller gives 16 candidates for the same price, then regenerate the winner at 96x88.

**Budget consequence.** At 20 generations per pro call, six essence families is 120 generations
before any iteration. The 40-generation trial cannot cover the roster. This is the thing that
forces a paid plan, and PixelLab's real pricing is still unverified.

### 2. Ownership

Neither PixelLab nor Retro Diffusion can grant you copyright. The US Copyright Office does not
register purely AI-generated output. PixelLab's terms of service grant use, verbatim: "You
retain ownership of any content you create using PixelLab. You are free to use, modify, and
distribute the outputs from our tools for any purpose, except for training other models
without our explicit permission." Source: https://www.pixellab.ai/termsofservice

That is permission to use, not an enforceable ownership interest. For creature designs
that are the identity of the game, decide deliberately whether that matters to you.

---

## The licence trap. Still true, now more important.

Human-made asset packs and AI-generated art are frequently mutually exclusive, and choosing
PixelLab closes the other door.

**Seliel the Shaper, Monster Battler Set.** $5.00 USD, 24 creatures, roughly 32x32, static,
explicitly "100% HUMAN-MADE" with "NO AI USED IN ANY WAY."
https://seliel-the-shaper.itch.io/monsterbattlerset

Its licence permits commercial games and editing, forbids print and redistribution, and states:

> "I do not consent for any of my art to be used in any machine learning datasets, nor used in
> a project alongside 'AI' generated imagery, writing, code, or anything else."

https://selieltheshaper.weebly.com/user-license.html

The clause covers code. The GDScript in this repository was AI-written. On a plain reading this
pack was already off the table before any AI art existed. Anti-AI clauses are now common among
human pixel artists and increasingly cover the whole project.

**Practical rule: screen every pack and every commission for AI clauses, with the AI-written
codebase in mind.** Having generated art with PixelLab, assume most human-made packs with such
clauses are now unusable here.

---

## What you are comparing yourself to

**Coromon, TRAGsoft.** Eighteen people. Monster art specifically: Daniel Reis and Marcus
Dewdney as monster designer and animator, Manon Dreijer as monster polisher. So three people
whose job was creature sprites. https://coromon.wiki.gg/wiki/TRAGsoft

**Nexomon, VEWO Interactive.** The lead creature designer on Extinction states over three
hundred creature designs for the sequel, 2019 to 2020.
https://www.artofmello.ca/nexomonextinction Total team size unverified.

You were holding the output of a three-person monster art team as the bar for your first
sprite while working alone with no art background. That comparison is now less relevant than
it was this morning, but it is worth keeping in view when judging results.

---

## Tools, verified

- **PixelLab.** Connected and working. Trial: 40 generations, 1 used. Pricing beyond the trial
  is **unverified** and every figure in circulation traces to aggregator sites citing each
  other. Read the checkout page before subscribing.
- **Retro Diffusion.** Aseprite extension $65 full, $20 Lite, one-time, local, commercial use
  allowed. https://astropulse.itch.io/retrodiffusion
  **Disqualified for this project by its own developer**, asked whether it can redraw the same
  character in another pose: "It creates something new, this model doesnt have the consistency
  to make the same characters in different poses." https://itch.io/post/11931421
  For a monster collector, consistency is the requirement.
  Also note the extension uses different models than the website: "DO NOT buy the extension if
  you are trying to get the same results as the website, it is not possible!"
- **Aseprite, $19.99** on Steam and aseprite.org. Compiling from source is free and permitted
  for personal use including commercial art. https://www.aseprite.org/faq/
- **Pixelorama.** Free, MIT, actively developed, built in Godot. Strongest free editor option.
- **saint11 tutorials**, free: https://lospec.com/pixel-art-tutorials/author/pedro-medeiros

---

## Alpix

A live shared 256x256 pixel canvas. An r/place for AI models. Three tools: open the canvas,
stamp pixels onto it, fetch a leaderboard ranking models by pixels placed.

No export, nothing returns a file. The board is public and shared. It does not generate:
`stamp-grid` takes an ASCII grid typed character by character against a fixed 32-colour
palette, which is the same process that produced the original placeholder blob.

Fun toy. Not part of this pipeline. Worth recording in the connector-routing skill so it does
not get reached for again.

---

## Recommendation

**PixelLab is the route.** Generate, then finish by hand where it needs it.

The pixel art skill still has value, but its role changed. It is no longer "learn to draw
a whole roster from scratch." It is "learn enough to judge and fix output," which is a far
smaller ask and can be picked up alongside the work rather than before it. Aseprite or
Pixelorama plus saint11's tutorials still earn their place, because `correct_pixelart` and
`reduce_colors` are blunt instruments and someone has to decide when a sprite is right.

### Sequence

1. **Test consistency next.** One more creature, generated with the shark as a style reference
   copying outline, detail and shading but not palette. If two creatures read as one set, the
   approach scales. If they do not, that is the real blocker and it is better to find
   it at creature two than at creature nine.
2. Lock a house style once from a creature you are happy with, and use it as the style
   reference for the rest.
3. Do the first six battle sprites, one per essence, before touching overworld sprites,
   evolution stages or animation. Twenty-four lines is the finished target, not the start.
4. Run `reduce_colors` across each essence family together so a Tide creature reads as Tide at
   a glance. That will do more for coherence than any single sprite's quality. That is what will
   make them look like one world more than any single sprite's quality.

### Budget note

39 trial generations remain. The first six creatures with iteration might fit. The full 44
sprites, plus overworld rotations, will not. Before subscribing, read PixelLab's actual checkout page, because no price found
in research was verifiable.

---

## What is already done and not part of the problem

The import pipeline is verified correct and it handled a real generated sprite with no
intervention: nearest neighbour filtering, lossless, no mipmaps, no alpha border processing,
3D detection disabled. A checkerboard of alternating single pixels renders as hard-edged blocks
in exactly two colours.

The data layer references sprites by file. Swapping art is one field. `003_sapphire_shark.tres`
now points at `sapphire_shark.png` and the encounter screen shows it crisp at 4x. Roster
validation still passes, zero problems.

That half has been finished since session one and none of it needed to change.
