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

**Every creature line has three stages.**

Preston changed the roster direction on 2026-09-25: no single-stage or two-stage lines. The current draft is 20 one-to-one lines across the six essences, for 60 forms. The six starter lines, including Cinderhide and Rimefin, also receive complete evolutions. Stage names and exact designs in the roster draft are proposals until reviewed.

| Stages | Lines | Forms |
|---|---:|---:|
| Three-stage | 20 | 60 |
| **Total** | **20 lines** | **60 forms** |

This is the current production roster target, not the first implementation batch. Preston's [personal Stone line](docs/creatures/personal-stone-line-proposal.md), Preostmar → Oathfen → Oxbowarchon, is the Stone starter at Line 9, replacing the former Marlward line (Preston, 2026-09-29). Bloom's original starter, the seed-burrower Tallowroot, returns at Line 17. It is included in the 20-line / 60-form count. Build and review one line at a time so art continuity and battle roles stay coherent. The [roster and Forge briefs](docs/creatures/creature-roster-draft.md) track the 20 draft lines.

**Evolution preserves a line's visual skeleton.** Later stages should retain recognizable anatomy and palette anchors while changing silhouette, role, and field behavior. PixelLab skeleton animation was part of an earlier tool evaluation; it is an optional future animation path, not the current still-sprite pipeline. Preston chose Hollowtide Sprite Forge in Opal for new creature art. Approved Cinderhide is the in-game creature finish benchmark: substantial dark outline, readable material shading, restrained accents and grounded weight. A separate Forge style-anchor image may transfer those rendering qualities to other species without transferring Cinderhide's reptile anatomy or Ember palette. Physical world scale and compressed battle display scale are separate; Vitrecrag's giant stature needs to read through anatomy and composition as well as its battle zoom. Image-to-image continuity still needs a real output review.

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

**Three or four lines per essence in the current 20-line draft.** Ember, Tide, Gale, and Hollow have three each; Stone and Bloom have four each.

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
- **The shark sprite**, now named **Rimefin**. The art is good and it survives. **Tide essence, stage I of a planned three-stage starter line.** Its original art exists; Preston plans to redo the sprite in the Forge. The old name was gemstone plus animal with alliteration, which is the exact formula the naming rules below ban, so the sprite carried over and the name did not.
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

**Overworld visual target (Preston, 2026-09-26):** The first route should carry the same visual weight as the approved courier and creature art. The current flat 16×16 grass, sand, and water study feels too close to a Game Boy era monster game; it is a layout foundation, not the finished world style. Refine the promising office, NPC, and tree concepts while rebuilding terrain with more natural silt, vegetation, river-edge texture, and shaded materials. Keep crisp pixels, grounded muted color, readable paths, and consistent top-down three-quarter perspective. See docs/world/first-route-art-pass-brief.md for the first small asset delivery and review criteria.

- **100×100 is the usual creature grid**, with transparency in the finished Godot asset and one logical pixel per approved source block. Approved large forms may keep a larger native grid; Vitrecrag's official front and rear are 128×128.

  Changed from 64×64 on 2026-09-25, after measuring real Sprite Forge output. The Forge draws on a
  100 by 100 block grid (10.25px per block across all three first images: Cinderhide, Kithflare,
  Wayburn), and the creatures themselves run 72 to 98 blocks. Squeezing that into 64×64 destroys
  detail no matter how it is done, and Preston rejected the shrunk results. Read 1:1, the sprites
  match the originals: average colour difference 6 to 10 out of 255, which is JPEG noise.

  The 64×64 target came from PixelLab and Sprite Fusion size limits. Neither is the art pipeline now.

  The player's battle sprite uses a whole-number zoom; the opponent receives an adjustable
  distance scale, rounded to half steps when needed. Mixed canvas sizes are fine in battle, and
  the source pixels remain under nearest filtering.

  Convert with `python tools/convert_forge_sprite.py <in> <out.png> --compare <sheet.png>`. The
  compare sheet puts the original beside the result; check it before importing.
  **`tools/opal-sprite-converter.html` targets 64×64 and shrinks; do not use it for Forge art.**

  **Rimefin stays at 96×88 until it is regenerated.** Never downscale existing art: 96 to 64 and 88
  to 64 are different ratios, so the two axes do not scale together and any conversion wrecks it.
- **Strong silhouettes.** The outline carries the identity, interiors stay lower detail. This is the single most repeated rule in beginner pixel art guidance and it is exactly what the old placeholder failed.
- **Angular over round.** Cubic volumes read better in pixels than curves.
- **Tight palettes.** Limited ramps per creature, shared palette family per essence so a Tide creature is recognisably Tide at a glance.
- **Crisp edges, no anti-aliasing.**

**Current still-sprite path:** generate one form at a time in Hollowtide Sprite Forge (Google Opal, Nano Banana Pro), using the roster brief and optional immediately previous-stage image. Review the magenta-background image, then run `tools/convert_forge_sprite.py` with `--compare` to make a transparent 100×100 PNG and check it against the original before importing. Conversion was reviewed on Cinderhide, Kithflare, and Wayburn on 2026-09-25; each later asset still needs visual review. The current main Forge and Evolution Forge roles are documented in `docs/forges/forge-production-standard.md`, with their saved prompts in `docs/forges/opal-sprite-forge-prompt-v6.md` and `docs/forges/opal-evolution-forge-prompt-v1.md`. Review and record each image at its actual logical grid before it becomes game art.

**Pixelorama is no longer in the chosen workflow.** Preston explicitly stopped using it on 2026-09-25. PixelLab remains historical tool research and may be reconsidered for animation later; it is not the current source for new still sprites.

**The spec is a target to grow into, not a gate on the first sprite.** A simpler style executed cleanly beats an ambitious one executed badly, and consistency across the roster matters more than rendering sophistication on any single creature.

---

## SCOPE ORDER

Do not skip ahead. Do not build step four before step two works.

1. One sprite rendering in a scene *(done)*
2. Player movement on a tilemap *(done)*
3. Creature data resources, beginning with Cinderhide and Rimefin *(in use; more forms are provisional)*
4. A visible encounter that can start and end *(done)*
5. Turn-based combat with the current impact animation and four-move Ember prototype *(in use)*
6. Capture *(done)*
7. Evolution *(Cinderhide-to-Clinkerhide win-trigger prototype exists; play review pending)*
8. First courier route *(separate scene built; full play review pending)*
9. Expand only after those loops are reviewed

**Twenty lines and sixty forms are the current finished roster target, not the starting batch.** Add lines one at a time once their art and game roles work.

---

## THE FIRST ROSTER DECISION

Six starter lines, one per essence, are the first design set. Each is planned as a three-stage line. Rimefin (Tide) and Cinderhide (Ember) are the existing stage-I anchors; the Stone, Gale, Bloom, and Hollow starters remain proposals until their sprites and roles are reviewed. The current Cinderhide to Clinkerhide link is a provisional evolution prototype, not final canon.
