# Production reality, and the canvas decision you have to make now

Written 2026-09-22. Multi-source research pass with adversarial verification.

---

## First, a correction to something I told you today

I said Outernauts was a large studio whose headcount did not buy survival. **That is wrong.**
Insomniac described it themselves as a "small team size" project that reached open beta in about
half the time of a console project. It died in January 2014 on Facebook and February 2016 on
mobile, and the cause was live-service and server economics, not team size or quality.

I labelled it unverified when I said it, which was right, but the claim should not have been made
at all. The real lesson from Outernauts is about distribution model, not headcount.

---

## What the comparable games actually cost

Verified from developer interviews, credits pages and Kickstarter records.

| Game | People | Time | Roster | Engine |
|---|---|---|---|---|
| **Monster Sanctuary** | **1** (Denis Sinner: code, pixel art, design, music) | 2015 to Dec 2020, ~5 yrs | 100+ | Unity |
| Cassette Beasts | 2 full time, 3 part time | ~4 yrs | 120 base | **Godot** |
| Coromon | 18 contributors, **3 on monster art alone** | ~2014 to 2022, ~8 yrs | 119 at launch | not confirmed |
| Beastieball | 4+ named on creature design | 2023 to 2027 target | in progress | GameMaker |
| Outernauts | "small team" (Insomniac) | ~half a console cycle | n/a | Flash |

**Monster Sanctuary is your proof of concept.** One person, no team, roughly 100 creatures, about
five years. It is the only entry on this list that a solo hobbyist can point at and say "that shape
is possible."

**Beastieball is the warning.** A single creature, Axolati, went through multi-stage design over
**several months** involving at least four people. That is what one creature costs at full
commercial polish.

Your 44-sprite target sits between those two poles, much closer to the achievable one.

### The number nobody publishes

No developer anywhere states hours per creature. A "4 hours per monster" figure circulates online;
it traces back to a student itch.io postmortem and is not usable. The closest credible description
is Insomniac's, listing one beast's asset set as front and back views, idle and walk animations,
and every ability animation, produced in sets of "two or three for a new beast and its evolutions,"
which they called "a huge amount of work."

**So the measurement in `what-actually-constrains-this.md` is still the only way to get this
number. Nobody will hand it to you.**

---

## The production trick you already wrote down and have not used

Cassette Beasts ships **14,000 visual fusion variants** off roughly 120 base monsters. They did not
draw 14,000 sprites. They built **modular parts and recombined them.**

`THE_CONCEPT.md` already says this, in your own document, unprompted:

> "Evolution reuses rigs. A stage-two inherits stage-one's skeleton with new parts and palette
> rather than being drawn from scratch."

The most directly comparable game on the list, same genre, same engine, two full-time people,
shipped on exactly that principle. Their programmer said outright that without Godot they could not
have built it themselves.

**You have the right idea written down and you are not building that way.** Right now each creature
is a whole separate sprite. The question that matters more than the essence count is whether stage
two is a new drawing or a recombination of stage one's parts.

---

## The decision that is actually in front of you: 64x64 or 96x88

This is live right now and it is cheap today and expensive later.

**Your project is 96x88.** Verified: `rimefin.png`, `cinderhide.png` and the placeholder are all
exactly 96 x 88. `THE_CONCEPT.md` says "96x88 canvas. Baked in, fine, keep it."

**The Cinderpelt prompt you used says 64x64.** So does Sprite Fusion's generator, which offers only
16x16, 32x32 and 64x64. There is no 96x88 option and there will not be one.

### What "baked in, fine, keep it" is actually worth

That is not a design argument. It is inertia, and it is the same shape as the essence count: an
early arbitrary choice that hardened into a constraint and then got rationalised after the fact.

96x88 is neither square nor a power of two. Almost every pixel art tool assumes one or the other.
It also does not downscale cleanly to anything: 96 to 64 is 1.5x, 88 to 64 is 1.375x, so the two
axes scale differently and any conversion degrades the art. **This will keep costing you.**

### The case for switching now

- Exactly **two** finished creature sprites exist. The switching cost will never be lower.
- 64x64 is a quarter fewer pixels than 96x88 (4,096 against 8,448). Cleanup time per sprite roughly
  halves, and cleanup time is your binding constraint.
- It unlocks Sprite Fusion's generator, its 8-direction rotation and its animation.
- PixelLab generates up to 200x200 on the free tier, so 64x64 does not lock you out of PixelLab
  either. Switching costs you nothing on that side.

### The case against

- Rimefin's art is good and `THE_CONCEPT.md` explicitly says it survives. Switching means redoing it.
- 96x88 carries more silhouette detail, and silhouette is the thing your art direction leans on hardest.

**This is your call, not mine.** But if you are going to switch, the honest answer is that today is
the cheapest day it will ever be, and every creature you add raises the price.

---

## Sprite Fusion against PixelLab: resolved

They are not competitors and you do not have to choose.

**Sprite Fusion** (https://www.spritefusion.com)
- Tilemap editor: **free forever**, web, no login, native Godot 4 export. Desktop edition $14.99
  one time, which only adds offline use and unlimited export size.
- AI Pixel Art Generator, separately priced: Starter **$9/mo for 450 credits**, Creator $19/mo for
  1,050, Pro $49/mo for 3,000. Credits reset monthly and do not roll over. Top-ups $5 per 150.
- **Every AI action costs 15 credits.** Starter is therefore about 30 actions a month. A still
  generation returns 12 images, an 8-direction rotation returns 8 sprites, an edit costs 2 actions.
- Output locked to 16x16, 32x32, 64x64. Confirmed twice: their docs, and the live editor UI.
- **No skeleton or rig.** Nothing in their site or docs mentions skeletons, bones, or reusing an
  animation across sprites. 8-direction rotation exists but is click-and-generate with no stated
  mechanism.

**PixelLab** (https://www.pixellab.ai)
- $12/mo entry tier, 2,000 images. Free tier of 40 fast generations then 5 a day.
- Explicitly advertises **"Animate with skeleton"** plus 4- and 8-direction rotation.

**Conclusion.** Sprite Fusion cannot replace PixelLab for creatures, because the rig is the thing
your evolution design depends on and Sprite Fusion does not have one. Sprite Fusion's free tilemap
editor is straightforwardly better than anything you currently have for the overworld, and you
already have `assets/tilesets/overworld_tiles.png` sitting there with no editor behind it.

Licensing on both is clean for commercial use. Both only ask that you not train models on outputs.

**Running both generators is $21/mo, which burns your $150 ceiling in seven months.** Pick one
generator. Take the free tilemap editor regardless.

### Not checked

Retro Diffusion is the one genuine third option named by non-marketing sources; its site would not
render and there is no price here. Firsthand quality comparisons could not be obtained at all:
Reddit blocks automated access and the rest of the search results are affiliate SEO from sites
selling competing tools. **Your own eyes on the Cinderpelt sprite are better evidence than anything
published, and you liked it.**

---

## Your Grok setup is running two different games

This needs saying plainly.

**`Video Game Developer` project, chat "Crystal Creatures: Gemstone Elemental Beasts": dead
concept, still live.** It contains the eleven gem-alliterated Guardians, the eleven-element system,
Crystalia, the Heart of Eternity. All superseded in September 2026 and explicitly marked do not
rebuild.

**It also contains direct proof of the failure `THE_CONCEPT.md` diagnosed.** The 100-monster Dex is
in that chat, and entries 051 to 100 are overwhelmingly repeats of 012 to 050. Tourmaline Tiger
appears at 012 and 093. Ruby Ram at 035 and 074. Emerald Elk at 046 and 085. Moonstone Mole at 043
and 082. At least 25 exact duplicate names. You wrote that the concept "ran dry around thirty and
started repeating." The artifact confirms it almost exactly.

**The Python script in that chat does not work.** `generate_crystal_guardian_sprite()` is handed an
`aurelion_map` of 11 rows multiplied by 2, for a 96x88 canvas. The comment in the code says "I
truncated 38 middle rows for brevity" and "placeholder duplication for demo," while the prose above
it claims the script is "fully runnable right now (no missing pixel_map)." Those two statements
contradict each other inside a single message. It would output a small malformed blob. It also
claims the full map is "ready in my editor," which does not exist.

**`MasterPlan(Info Node)` project is the good one.** The Cinderpelt prompt there is genuinely well
built and derived from your current art direction, not the dead lore:

```
pixel art monster sprite, 64x64, transparent background, side-3q view facing right,
squat ember grub with blocky cubic body, short legs, coal-lump belly, two small angular
ear tufts, single bright ember core in chest, thick 1px dark outline, no anti-aliasing,
limited palette: charcoal, rust, ember orange, pale ash highlight, readable silhouette,
Nexomon / Coromon creature readability, game-ready, no text, no background
```

Every clause maps to something in `THE_CONCEPT.md`: blocky cubic body to "angular over round,"
thick outline and no anti-aliasing to "crisp edges," the limited palette to "tight palettes,
shared palette family per essence," readable silhouette to "strong silhouettes." **Keep this
prompt. It is a template, and it is the first thing in this project that is reusable per creature.**

Note that Cinderpelt is described there as the base form of the Ember line, which would make
Cinderhide a later stage. Your data file currently has Cinderhide as a standalone with placeholder
stats of 60 across the board and an empty description.

**Recommendation: delete or archive the Crystal Creatures chat, or at minimum stop using that
project.** It is the live version of the thing your memory files warn about, and it is one
convenient paste away from re-entering the project.

---

## Still uncertain

- Hours per creature for you specifically. Unmeasured, and nobody publishes a comparable figure.
- Retro Diffusion's pricing and quality.
- Whether Sprite Fusion's 8-direction rotation preserves identity well enough for a roster, since
  no independent account of its output quality could be found.
- Nexomon's team size and timeline. No credible source exists.
- Whether you already have a Sprite Fusion account, which would change the pricing answer.

## What would change all of this

One timed creature at 64x64, using the Cinderpelt prompt as the template. That single number
settles the canvas question, the essence count, and whether 44 sprites is conservative or
optimistic. Everything above is arithmetic waiting on it.
