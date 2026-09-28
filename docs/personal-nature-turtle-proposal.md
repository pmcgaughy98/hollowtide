# Preston's river-island turtle line — design proposal

**Generation status:** the first Stage I turtle run, before the current names were chosen, was submitted in the main Sprite Forge with approved Cinderhide as the separate style anchor, but Opal returned its image-generation quota error. No image was produced or imported. Retry after Preston's stated reset and review it before evolving.

**Status:** Preston chose this as the Nature starter replacing the old seed-burrower line at roster Line 17. The roster remains 20 lines / 60 forms. The names below are working creature names, and no new game data or sprites exist yet. Nature is the current essence name; it replaces the old Bloom label in the same gameplay slot. This line does not borrow an existing species' anatomy.

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
