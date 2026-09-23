# THE CONCEPT
Monster collector. Godot 4.x, GDScript. Pixel art.
Revised September 2026. Supersedes Crystal Creatures and the combination draft.

Inspired by Nexomon, Coromon, Lumentale, and Cassette Beasts, for art feel and general feel rather than mechanics.

---

## WHY CRYSTAL CREATURES WAS REPLACED

Naming the failure so this doesn't repeat it.

**The naming formula couldn't scale.** Gemstone plus animal with strict alliteration is a closed set. That is the real reason the old 100-monster list came back half duplicates. It wasn't sloppy generation, the concept ran dry around thirty and started repeating.

**The elements were assigned, not derived.** Why was Amethyst darkness? Why was Peridot poison? There was no answer, because the mapping was arbitrary. Design research is blunt about this failure mode: *"arbitrary or lore-incoherent matchups that players cannot reason about."*

**Eleven elements for eleven creatures is a dead end.** One creature per type means no type ever has a roster.

---

## THE STRUCTURE

**Classic three-tier evolution, applied unevenly.**

Not every line evolves the same amount. That is how Pokémon actually works, it produces variety instead of a formula, and it cuts the art load substantially.

| Stages | Lines | Sprites |
|---|---|---|
| Three-stage | 6 | 18 |
| Two-stage | 8 | 16 |
| Single-stage | 10 | 10 |
| **Total** | **24 lines** | **44 sprites** |

**Forty-four sprites, not seventy-two.** That difference is the project being finishable.

Design research on small teams: real-world shipping scale is 80 to 150 forms for a studio, and *"hand-authoring 300+ fully unique, fully animated monsters is rare outside large studios."* Twenty-four lines is a solo target that can actually be hit.

**Evolution reuses rigs.** A stage-two inherits stage-one's skeleton with new parts and palette rather than being drawn from scratch. PixelLab's skeleton rigging is built for this, and the research names it directly as the pattern that makes evolution trees affordable: *"expand via branching evolutions, regional forms, or redesigns that reuse the same animation skeleton with new parts or palettes."*

### Lines are one to one. No branching, no converging.

Added 2026-09-22, stated directly: what is good about Digimon is when the line makes sense, and what is bad is duplicates and several creatures that evolve into the same one.

So, as a rule:

- One creature evolves into **at most one** creature.
- One creature is the evolution of **at most one** creature.
- No loops, and no line longer than three stages.

This deliberately narrows the research quoted above, which recommends branching evolutions as a way to expand cheaply. Branching is cheap in art and expensive in coherence, and coherence is the thing being protected here.

These are enforced, not just written down. `CreatureRoster.validate_evolutions()` checks all four and the roster fails loudly rather than drifting. That is on purpose: the last roster went wrong quietly.

---

## THE SIX ESSENCES

Type count research: ten to eighteen is the workable range. Fewer is boring, twenty-five-plus becomes opaque. Six primaries with dual-typing on later stages lands inside that.

| Essence | Domain |
|---|---|
| **Ember** | heat, force, aggression |
| **Tide** | flow, adaptation, erosion |
| **Stone** | mass, endurance, structure |
| **Gale** | speed, dispersal, evasion |
| **Bloom** | growth, recovery, spread |
| **Hollow** | absence, decay, entropy |

**Four lines per essence.**

### The chart is a cycle, not a memorization test

- Ember burns **Bloom**
- Bloom breaks **Stone**
- Stone dams **Tide**
- Tide quenches **Ember**
- **Gale** scatters everything but commits to nothing: broad neutral coverage, few hard advantages
- **Hollow** consumes but cannot create: strong offensively, poor defensively

Every relationship is reasonable from the name alone. That is the test a good chart passes and an arbitrary one fails.

*Implemented in `scripts/essence_chart.gd`. Strong hits are 2.0, weak are 0.5. Gale is neutral everywhere; Hollow hits everything at 2.0 and takes 2.0 from everything, which is the glass cannon the description asks for.*

**Dual typing arrives through evolution.** A creature can gain a second essence at stage two or three, which makes evolution a strategic change rather than only a stat increase.

---

## TEMPERAMENT (the second axis)

Borrowed from Lumentale, which runs thirteen elements plus five emotion-based Attributes. It adds depth without adding type-chart complexity.

Temperament governs behaviour, not damage: how a creature acts in battle, what it responds to, how easily it is caught, and how it evolves. Two creatures of the same essence with different temperaments play differently.

This keeps team building about more than type coverage.

---

## WHAT CARRIES OVER

- **The Godot project and verified import pipeline.** Nearest-neighbour filtering, no mipmaps, correct compression. Finished since session one.
- ~~**96×88 canvas.** Baked in, fine, keep it.~~ **Changed to 64×64 on 2026-09-22.** See the
  canvas note under ART DIRECTION.
- **The data layer**, which references sprites by filename. Swapping art is changing one field.
- **The shark sprite**, now named **Rimefin**. The art is good and it survives. **Tide essence, single-stage.** It is already a finished creature. The old name was gemstone plus animal with alliteration, which is the exact formula the naming rules below ban, so the sprite carried over and the name did not.
- **Everything in CLAUDE.md about how Preston works.** One completion per session, explain the code, no scaffolding, no urgency. That was never about the concept.

**Replaced:** the eleven legendaries, the gem-alliteration rule, the eleven-element system, and the Heart of Eternity lore.

---

## NAMING RULES

**No formula.** The alliteration rule is what broke the last roster. Names should sound like creatures, not like a spreadsheet.

Look at what the reference games do. Coromon and Nexomon use coined, evocative names that suggest the creature without a rigid pattern. Nothing requires the essence to appear in the name.

**Only rule: a name must be pronounceable and must not collide with an existing Pokémon, Coromon, Nexomon, Temtem, or Cassette Beasts name.** Check before committing.

---

## ART DIRECTION

Reference feel: Nexomon and Coromon for creature readability, Lumentale for environment and presentation.

- **64×64**, transparent background

  Changed from 96×88 on 2026-09-22. Preston asked me to make this call, so it is mine, and the
  reasoning is short: 96×88 was never a design choice, it was inertia. It is neither square nor a
  power of two, and every tool assumes one or the other. Sprite Fusion's generator stops at 64.
  PixelLab's text animation is hard locked to exactly 64×64, and its skeleton animation is
  documented as degrading at any size other than 16, 32 or 64. At 64×64 every tool works and the
  two can be combined. At 96×88 only plain image generation works.
  64×64 is also a quarter fewer pixels to clean up by hand, and hand cleanup is the real budget.

  **Rimefin and Cinderhide stay at 96×88 until they are regenerated.** They are not being
  downscaled: 96 to 64 is 1.5× and 88 to 64 is 1.375×, so the two axes do not scale together and
  any conversion would wreck the art. They are legacy at the old size, and new creatures are 64×64.
  Full evidence in `docs/sprite-generation.md`.
- **Strong silhouettes.** The outline carries the identity, interiors stay lower detail. This is the single most repeated rule in beginner pixel art guidance and it is exactly what the old placeholder failed.
- **Angular over round.** Cubic volumes read better in pixels than curves.
- **Tight palettes.** Limited ramps per creature, shared palette family per essence so a Tide creature is recognisably Tide at a glance.
- **Crisp edges, no anti-aliasing.**

**Pipeline, verified working:** PixelLab for generation and skeleton rotation, cleanup in Pixelorama (free, built in Godot), drop the PNG in the art folder, point the data resource at it.

**The spec is a target to grow into, not a gate on the first sprite.** A simpler style executed cleanly beats an ambitious one executed badly, and consistency across the roster matters more than rendering sophistication on any single creature.

---

## SCOPE ORDER

Do not skip ahead. Do not build step four before step two works.

1. One sprite rendering in a scene *(done)*
2. Player movement on a tilemap *(done)*
3. One creature data resource, then the first few *(done, 2 of the first 6)*
4. An encounter that can start and end *(done)*
5. Turn-based combat, one move each *(done)*
6. Capture *(done)*
7. Evolution *(next)*
8. Everything else

**Twenty-four lines is the finished target, not the starting target.** Build the systems with three creatures. Add the rest once the systems work.

---

## THE FIRST ROSTER DECISION

Six lines, one per essence, to build and test systems against. Not twenty-four.

Rimefin is Tide and Cinderhide is Ember. Two down. Four more designs, one each for Stone, Gale, Bloom and Hollow, single-stage to start. Evolution comes after combat works.
