# Preston's personal Stone line — design proposal

> **Superseded in part, 2026-10-08 (Preston):** this is no longer his personal line. Oxbowarchon is one of the **Gemstone Kings**, one pseudo-legendary per essence, each with Stone as its second essence. Oxbowarchon is the **Bloom** king (Bloom/Stone); its emerald is the Bloom king stone and Kingstone Rail is its power. The art direction and move directions below still stand. Arena kit and signature: `arena-oxbowarchon-2026-10-08/README.md`.

**2026-09-29, Preston:** this line moves to **Stone** and replaces the former Stone starter (Marlward line) as
Line 9. The essence formerly called Nature is **Bloom** again, and Bloom's original starter (Tallowroot) returns
at Line 17.

## Direction v2.1: bound-stone jade titan with an emerald Kingstone (Preston, 2026-09-29) — supersedes all prompts below

**Why:** v1 came out "too eco-friendly". Preston wants an SSS-tier Stone creature inspired by Torterra (the model to
surpass, never copied), the Green King of Accel World (faceted green armor, gold-amber inset gems, absolute
defense), a Zoids siege tortoise and a railgun cannon turtle, and now **Dauntless's Skarn** (armor that is not
grown but bound to a lean reptile body by glowing energy; matte stone against bright green light). Its lore
needs a green gem.

**Core idea (proposal):** the creature's life is a single living emerald, the **Kingstone**. Its green pull binds
stone and jade to a stocky, invented, neckless body: the armor is a formation, not bone, so it can
move, break apart and re-form. Emerald is brilliant but brittle, so the pull gathers the toughest stone it can hold
around it: river stone when young, dense jade when mature, the rarest jade and gem shards at its peak. Thin
emerald-mint light pulses in every seam between the bound slabs. On its back the pull holds two floating jade
rails: a living railgun that fires jade slugs with the Kingstone's power. Where Torterra carries a tree, this titan
carries its own heart and the weapon that heart powers. The energy's in-world name is Preston's to choose (Dauntless
calls it aether; Hollowtide will not).

**Detachable slabs:** jade spikes float bound at its hips like holstered weapons. In battle they break free and
pierce toward the target, then new ones are pulled into place. They are **separate art**
(`Effect Sheets/Proestmar Effect/`), never drawn into the body sprite, so the prompts keep the hips clear.

**How the detachable slabs will work (build plan, after Preostmar's sprite exists):** the art is cut into
`assets/sprites/effects/preostmar/` (slab.png is the big spike; dart_1-3 the in-flight spikes; burst_a/b the
emerald shatter). Two slabs float at the hips, one per side (the far one partly behind the body), a pixel or two off
the flank with a faint emerald seam of light binding them, bobbing gently with the breath. A Jade Lance style move
lifts them, points them at the target and fires them one after another: in flight they are the darts, which point
straight ahead (the big slab is drawn on a diagonal, and rotating pixel art breaks its pixels). Each shatters in an
emerald burst on the target, then new slabs are pulled back into place. It reuses systems already built (aim
points, volley, impact sequences), about one session of work. **Size note:** the big slab is drawn roughly as large
as a whole Stage I creature, so hip-sized slabs will need either a smaller Forge version generated to match the
approved sprite or a careful reduced copy.

**Weakness (battle hook for later):** rearing up exposes a soft, unarmored underbelly.

**Not an Earth animal (Preston, 2026-09-29):** the first v2.1 Forge result had exactly the right jade armor but a
real snapping turtle underneath (beak, turtle legs, neck), because the prompt said "snapping-turtle-like". The body
is now invented: a neckless anvil-shaped stone skull with emerald eye-points and a three-part stone jaw, cracked
stone hide with light in the cracks, pillar legs with three stone talons, a stone-wedge tail. Skarn is the model:
turtle-ish in stance only.

**Preostmar looks like its own spike (Preston, 2026-09-29):** its bound armor is the same material as the jade
spike it fires (the big spike on the Proestmar effect sheet): overlapping faceted jade slabs with cracked facets
over rough brown earth-stone, gathered into a forward-pointing arrowhead mass on its back, with the emerald
glowing at the centre like the spike's core. The creature and its weapon read as one thing.

**The gem across the line:** the Kingstone always sits at the centre of the back formation and grows with each
stage: a small emerald core in Preostmar, a larger one blazing through the seams of Oathfen's dome, the full
Kingstone at the base of Oxbowarchon's railgun with emerald light running up the rails.

**Palette anchors (draft):** skin from the v1 colours Preston liked: peat charcoal #27312E, bark brown #473D34,
sedge olive #64745A, silt ochre #A0916D, river slate #526B70, amber eye #C49A58. Bound stone: slate #4E5A5E,
charcoal #2A2E30, obsidian #16181B. Jade slabs, sampled from Preston's spike: deep jade #206349 / #406F55, jade #53986E, light jade #6DC183, pale mint
highlight #AFE8B8, dark slate outline #31353D, rough brown earth-stone under the slabs. Emerald energy
and Kingstone, the only vivid colours: deep emerald #0B6B3F, emerald #12B76A, mint glow #7CF5B8. Gold-amber gems
#E0A82E. Dark outline, clean clustered shading, strong contrast between matte stone and glowing seams.

**Move directions (proposals; names and numbers are Preston's):** Jade Lance (the hip spikes detach and pierce),
Stone Cocoon (slabs pull tight, then burst outward as shrapnel), Slab Vortex (it rears and spins its plates), Ground
Spikes (jade erupts under the target), and for Oxbowarchon a railgun signature.

**Railgun charge (Preston, 2026-09-29):** for the signature, Oxbowarchon swings its two rails up to point at the sky.
A sphere of power builds between them, the way a lightning railgun charges between its rails, but with the
Kingstone's own green binding pull instead of lightning. It braces harder as the power builds around the sphere,
then releases it. The jade-slug sheets are kept for now. Prompts:
`docs/forges/preostmar-line-attack-forge-prompts-2026-09-29.md`.

### Stage I, Preostmar front (v2.1)

```text
VIEW: FRONT
NAME: Preostmar
ESSENCE: Stone
Original fantasy creature, first stage of a three-stage titan line, invented for this world. A stocky, barrel-chested quadruped with no neck: a broad, flat, anvil-shaped stone skull sits low between its shoulders, a heavy brow shading two small glowing emerald eye-points, and its lower jaw is split into three short stone mandibles. Charcoal-brown hide cracked like dried stone, with thin emerald-mint light glowing through the cracks. Four thick pillar legs with elbows turned outward, each ending in three blunt stone talons; a short thick tail ending in a flat stone wedge. On its back, bound to the body by that green light, a formation of overlapping faceted jade slabs rises from the shoulders along the spine into a sharp arrowhead-shaped mass pointing forward and up like a spearhead: pale green jade plates with bevelled, cracked facets and bright edge highlights, rough brown earth-stone showing at the base of the slabs, and at the centre of the mass a glowing faceted emerald core with thin emerald seams of light between the slabs. The front-left slab is visibly cracked. Leave its hips and flanks clear of slabs. Confident, wary, battle-ready, never cute. Three-quarter side view facing right, head low and forward, one foreleg planted. Peat charcoal and bark brown hide; jade #53986E, deep jade #406F55, light jade #6DC183 and pale mint #AFE8B8 slabs; brown earth-stone; the emerald core, eyes and seams the only vivid colour; dark slate outline and clean clustered pixel shading. About 60-65% of the usable 100x100 logical-pixel height. Exactly one creature on solid #FF00FF magenta, no floor, shadow, text or other characters. Not a turtle, tortoise, lizard, crocodile, rhino, beetle or any other real animal: no beak, no neck, no turtle shell, scutes, flippers or turtle legs. Not a robot, no guns, no tree, no chibi eyes, no loose floating pieces.
```

### Stage II, Oathfen front (v2.1)

```text
VIEW: FRONT
NAME: Oathfen
ESSENCE: Stone
Evolve the attached approved Preostmar into a genuinely new, heavier adult body of the same invented species. Keep the anvil-shaped neckless skull, the glowing emerald eye-points, the three-part stone jaw, the cracked stone hide with light in its cracks, the cracked front-left slab, the faceted jade-over-brown-stone armor and the palette. Its pull is stronger now: a much taller domed formation of dense, sharp-edged jade slabs is bound over its back and shoulders, each slab separated by thin glowing emerald-mint seams, and the emerald core at the centre has grown larger and blazes through the seams, the brightest thing on the creature. Massive shoulders armored in bound jade slabs with a gold-amber gem in each, thicker pillar legs with jade plates on the forelegs and bigger stone talons, a heavier tail ending in a broad stone wedge. Leave its hips and flanks clear of slabs. Imposing, disciplined, powerful. Three-quarter side view facing right, braced stance. About 70-75% of the usable height on the same baseline. Rebuild the whole body; do not keep Preostmar's pose and add parts. Same palette and pixel craft, matte stone against glowing seams. Exactly one creature, 100x100 logical pixels, flat #FF00FF magenta background, no floor, text or extra creature. Not a turtle, tortoise, lizard, crocodile, rhino, beetle or any other real animal: no beak, no neck, no turtle shell, scutes, flippers or turtle legs. Not a robot, no guns, no tree.
```

### Stage III, Oxbowarchon front (v2.1, SSS tier)

```text
VIEW: FRONT
NAME: Oxbowarchon
ESSENCE: Stone
Evolve the attached approved Oathfen into a legendary SSS-tier titan of the same invented species: an ancient beast holding a fortress of stone around itself by the power of the gem at its heart, the strongest creature in the world. Preserve the anvil-shaped neckless skull (now crowned with a ridge of jade horns), the glowing emerald eye-points, the three-part stone jaw, the cracked stone hide with light in its cracks, the cracked front-left slab and the palette. A colossal mountain-like formation of the rarest jade slabs and obsidian plates is bound over its back, cut sharp like gems, every seam blazing with emerald-mint light, gold-amber gems set along its ridge. Above the formation float two long parallel rails of jade, held in the air by the same green light: a living railgun angled forward, emerald energy arcing between the rails. At the rails' base sits the Kingstone, a single huge faceted emerald, the brightest and most vivid thing in the image. Massive pillar legs in bound jade armor with huge stone talons, deep armored shoulders with gold gems, a long heavy tail ending in a stone wedge. Leave its hips and flanks clear of slabs. Low, planted, menacing battle stance, head lowered toward the viewer, three-quarter side view facing right. Peat charcoal and bark brown hide, slate, charcoal and obsidian stone, deep jade and pale jade slabs, vivid emerald Kingstone, eyes and seams, gold-amber gems, dark outline and clean clustered pixel shading, strong contrast between matte stone and glowing light. Fills about 85-90% of the usable height and nearly the full width, entirely in frame on the same foot baseline. Exactly one full-body creature on pure #FF00FF magenta, 100x100 logical pixel grid, no shadow, floor, labels, effects or extra forms. Not a turtle, tortoise, lizard, crocodile, rhino, beetle or any other real animal: no beak, no neck, no turtle shell, scutes, flippers or turtle legs. Original design: not Torterra, not Dauntless's Skarn, not a machine or robot, no metal, rivets, bolts, antennas or numbers, no rider, house, tree or scenery on its back.
```

---

*The v1 material below is kept for history.*

**Generation status:** the first Stage I turtle run, before the current names were chosen, was submitted in the main Sprite Forge with approved Cinderhide as the separate style anchor, but Opal returned its image-generation quota error. No image was produced or imported. Retry after Preston's stated reset and review it before evolving.

**Status (superseded 2026-09-29, now Stone Line 9):** Preston chose this as the Nature starter replacing the old seed-burrower line at roster Line 17. The roster remains 20 lines / 60 forms. The names below are working creature names, and no new game data or sprites exist yet. Nature is the current essence name; it replaces the old Bloom label in the same gameplay slot. This line does not borrow an existing species' anatomy.

**Name origin:** Preston comes from Old English *prēost* + *tūn*, usually glossed as “priest's farmstead or settlement” ([Brent Council local history](https://www.brent.gov.uk/libraries-arts-and-heritage/brent-museum-and-archives/your-local-area/history-of-preston-and-uxendon)). **Preostmar** adapts the older *prēost* root and the floodplain setting. **Oathfen** and **Oxbowarchon** express the creature's invented Hollowtide duty: provide refuge when the river rises. That protective duty is creative lore, not a historical meaning of the name Preston.

## Core idea

**Preostmar → Oathfen → Oxbowarchon.** A floodplain turtle carries a living piece of high ground on a shell formed as a shallow basin with a raised, oxbow-shaped rim. Reeds and roots grow from silt trapped between its living scutes. During floods it shelters small wild creatures and seed stores until water recedes. It is a refuge, never a passive walking island or a building. Residents know it from the ring of reeds that seems to move against the river current.

The shell is part of the body: layered keratin scutes and thick growth seams hold silt and water. Plants are symbionts and seasonal; the turtle remains recognizable if every reed is cut back. Its own anatomy does the visual work: hooked beak, dark inset eyes, four broad clawed limbs, exposed neck, and heavy tail. A distinctive **broken left front scute** and a short **three-reed crown** recur through the line. Stage changes alter anatomy, mass, shell profile, and stance; they are not armor attached to an unchanged turtle.

**Ecology and region:** It inhabits sheltered river bends and old flood channels near the significant riverside area. A young Preostmar begins in a muddy side pool. Oathfen stabilizes small patches of raised bank. An Oxbowarchon is exceptionally old and can carry a temporary refuge through high water; it cannot stop or reverse a regional flood. People may mistake a sleeping elder for a planted island, but the story is local folklore, not a claim about the real Elwood flood. A Pony Express-inspired field guild could ask the player to identify a moving refuge during a route closure.

## Silhouette ladder

| Stage | Physical identity | Battle sprite read |
|---|---|---|
| **Preostmar** | Juvenile but not cute: long neck, large hooked beak, four visible feet, low angular shell with one raised muddy rim and three short reeds. | Low narrow wedge; head and neck project far forward. 60–65% of the usable frame height. |
| **Oathfen** | Mature riverbank forager: deeper chest, thicker neck, broad splayed front claws, shell rim splits into two terraced arcs, a small dark pool recessed between them. | Taller at the shell shoulders, longer body, head turned sideways as it braces against current. 70–75% height. |
| **Oxbowarchon** | Ancient refuge bearer: massive planted limbs, weathered beak and brow, oxbow rim around a clear recessed marsh basin, root mats trailing into the shell seams. | Wide low mass with a high rim, planted asymmetrical forefeet, neck drawn in and head turned toward the viewer. 85–90% height. It should imply real-world scale through a large, quiet body, not through a tiny character or house on its back. |

The final form's likely field size is **a design range, not canon**: roughly as long as a small boat and broad enough for a few small creatures to shelter. Battle art compresses this into the 100×100 logical grid. Relative scale should come from age, limbs, neck, and shell construction, not from an invented fixed meter count.

## Color and material

This creature deliberately does not inherit Turbo Green. Use peat charcoal (#27312E), dark bark brown (#473D34), muted sedge olive (#64745A), dry silt ochre (#A0916D), cool river slate (#526B70), and a tiny amber eye (#C49A58) as **draft anchors**, not mandatory exact values. Keep dark outline and Cinderhide-level clustered material shading. Nature can include roots, waterlogged wood, seeds, fungus, prairie grasses, and floodplain plants; it is broader than bright green leaves.

## Battle role and four-move direction

A slow protective Nature partner with guard and interruption, consistent with the current battle resolver. Proposed signature direction for its eventual four-move kit:

1. **Mudjaw** — direct Nature strike; reads from the hooked beak and body weight.
2. **Sedge Brace** — guard; lowers the next incoming hit while feet anchor in place.
3. **Root Catch** — interrupt; catches an explicitly telegraphed foe action if Oxbowarchon acts before impact.
4. **Refuge Rise** — support or protective signature move for later battle-system design. Do not implement until multi-creature or field-support rules exist.

Move names, costs, and numbers need balance review. The current four-move kit can use a temporary ordinary strike in the fourth slot until support behavior exists.

## Copy-ready Sprite Forge prompts

Generate **one front at a time**. Use [Hollowtide Sprite Forge](https://opal.google/edit/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY) for Preostmar with no lineage image. Use [Hollowtide Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV) for Oathfen and Oxbowarchon. Attach the approved prior-stage **front** for the next-stage **front**, and the approved same-form **front** for its **back**. Use approved Cinderhide only in the separate style-anchor input. Review each stage before producing the next.

### Stage I — Preostmar front

```text
VIEW: FRONT
NAME: Preostmar
ESSENCE: Nature
One grounded floodplain turtle, first stage of a three-stage river-island line. Long projecting neck, angular hooked beak, dark inset eyes, four visible broad clawed legs, low slanted living shell. The front-left shell scute has a distinctive natural break. A narrow raised rim of shell holds damp silt and exactly three short sedge reeds. The reeds grow from the shell seams; they are not a tree, backpack, helmet, or scenery. Strong low wedge silhouette, three-quarter side view facing right, head reaching forward and one front claw planted in mud. Mature wary expression, never baby-cute. Peat charcoal and bark brown body, muted olive reeds, silt ochre shell highlights, cool river-slate shadow, tiny amber eye. Cinderhide-level dark outline and clustered material shading, with no Ember anatomy or orange glow. Occupy about 60–65% of the usable 100x100 logical-pixel height. Exactly one creature on solid #FF00FF magenta, no floor, shadow, text, or other characters. Avoid Torterra's single tree, Fortoise's fortress, bright Turbo Green, chibi eyes, smooth armor, building, floating island, and leaf cloak.
```

### Stage II — Oathfen front

```text
VIEW: FRONT
NAME: Oathfen
ESSENCE: Nature
Evolve the attached approved Preostmar into a genuinely new adult body. Keep the hooked beak, dark inset eyes, broken left-front scute, three-reed motif, and peat/ochre/sedge palette as lineage anchors. Change anatomy and silhouette: broader splayed front claws, much deeper chest, thicker exposed neck, longer flatter tail, and shell rim grown into two staggered living terraces around a small recessed dark pool. Turn the head sideways while all four feet brace against current. It should be substantially longer and taller at the shell shoulder than Preostmar, occupying about 70–75% of the usable height on the same baseline. Rebuild the turtle's torso and shell; do not keep Preostmar's pose and add reeds, armor, rock plates, or accessories. The pool is contained within scutes, not a blue sticker or lake floating above the shell. Three-quarter side view facing right. Cinderhide-level crisp pixel craft, no Cinderhide anatomy or Ember colors. Exactly one creature, 100x100 logical pixels, flat #FF00FF magenta background, no floor, text, tree, structure, or extra creature.
```

### Stage III — Oxbowarchon front

```text
VIEW: FRONT
NAME: Oxbowarchon
ESSENCE: Nature
Evolve the attached approved Oathfen into an ancient, giant floodplain refuge bearer. Preserve its hooked beak and eye identity, broken left-front scute, three-reed motif, two-tone peat/silt palette, and the living recessed shell basin. Transform its anatomy: enormous planted forelimbs with broad mud claws, deep load-bearing shoulders, heavy neck drawn partway in, longer counterweight tail, shell grown into a wide oxbow-shaped raised rim enclosing a low marsh basin with restrained sedges and root mats. Pose as a broad, asymmetrical four-footed brace, head turned slightly toward the viewer; different stance and silhouette from Oathfen. Its body should fill about 85–90% of usable height and nearly the full usable width while remaining entirely in frame on the same foot baseline. Make its age and size read through material planes and mass, never by placing a tiny human, house, mountain, or full tree on its back. The shell is grown anatomy, not detachable armor or a diorama. Quiet protective expression, mature grounded folklore. Use approved Cinderhide for dark outline and material-shading quality only. Exactly one full-body creature on pure #FF00FF magenta, 100x100 logical pixel grid, no shadow, floor, labels, effects, or extra forms. Avoid Torterra's tree silhouette, Fortoise's fortress, bright Turbo Green, island floating above the shell, pasted-on landscape, and same-sized predecessor with extra parts.
```

### Back view for any approved stage

In the Evolution Forge, set `VIEW: BACK`, attach **the approved front of the exact same stage** as Approved Evolved Front, and use its stage brief above. Show a true three-quarter rear turtle looking toward the upper right: shell basin and rim, back of head, rear limbs, tail, broken left-front scute visible where anatomy allows. Match its front's body mass, palette, and stage-specific shell construction. Never mirror the front or evolve again.
