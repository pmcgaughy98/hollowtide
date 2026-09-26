# Hollowtide Creature Roster and Sprite Forge Briefs

**Draft, not canon.** Preston selected the River Listener line as the first evolution prototype. Its stage names and exact designs remain proposals. New names below have not been collision-checked against Pokémon, Coromon, Nexomon, Temtem, or Cassette Beasts.

## Roster target

This follows THE_CONCEPT.md: 24 one-to-one lines, 44 sprite forms: six three-stage lines, eight two-stage lines, ten single-stage forms. Each essence has four lines. The first six species remain single-stage starters: Cinderhide, Rimefin, Marlward, Skirr, Tallowroot, Hushmire.

| Essence | Single | Two-stage | Three-stage | Total lines |
|---|---:|---:|---:|---:|
| Ember | 2 | 1 | 1 | 4 |
| Tide | 2 | 1 | 1 | 4 |
| Stone | 1 | 2 | 1 | 4 |
| Gale | 2 | 1 | 1 | 4 |
| Bloom | 1 | 2 | 1 | 4 |
| Hollow | 2 | 1 | 1 | 4 |
| **Total** | **10** | **8** | **6** | **24** |

## Use one brief at a time

Paste one form's brief into the required Creature Brief text field in Hollowtide Sprite Forge. For a new Stage I, leave Previous Stage Sprite (optional) empty; for a Cinderhide or Rimefin redraw, you may attach the current sprite. For Stage II or III, attach only the immediately previous sprite from that same line in Previous Stage Sprite (optional). The optional Image field is wired to the sprite prompt, but evolution continuity has not been confirmed by an image-generation run.

The live Opal workflow uses Nano Banana Pro (not Agent) and the prompt recorded in docs/opal-sprite-forge-prompt-v2.md. It asks for a 64-by-64 pixel grid drawn in a larger square image over exact flat magenta (#FF00FF); do not ask Opal for transparency or native 64x64 output. After generation, remove the magenta and sample the pixel grid down to a transparent 64x64 PNG. The local browser converter is tools/opal-sprite-converter.html; verify its output against a real Opal result before import. Do not import outputs into Godot before conversion and review.

The v2 Forge prompt supplies the common rules: 64-by-64 pixel grid, solid magenta background, one centered creature, crisp angular pixels, strong silhouette, palette limited to 16 colors, no text, shadow, or extra forms. Aim for mature grounded folklore; avoid cute, round, chibi, or toy-like proportions. Transparency is made after generation by removing magenta. The briefs below specify name, essence, anatomy, silhouette, temperament, pose/facing, palette, and avoid-list.

## Ember

**Line 1 — Cinderhide (single; existing starter, optional redraw).** Name Cinderhide; Essence Ember; anatomy compact charcoal reptile, blunt wedge snout, two short horn plates, ember vents, sturdy foreclaws; silhouette low braced body with broken sawtooth spine; temperament proud and wary; pose three-quarter facing right, foreclaw forward; palette coal, iron gray, restrained ember red/orange; avoid cute dragon, round belly, wings, flame mane, changing its recognizable design.

**Line 2 — Kithflare -> Wayburn -> Coalcrest (three-stage relay runner).**

- **Stage I Kithflare:** Ember; lean four-limbed runner, narrow muzzle, paired shoulder heat sacs, short forked tail; forward wedge with long rear legs; impatient but attentive to handoff signals; three-quarter right-facing sprint-brake; soot, rust, muted orange, tiny cream heat points; avoid horse, dog, rider, saddle, cute proportions. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Wayburn:** Ember; attach Kithflare PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; same runner with longer forelimbs, layered shoulder chambers, tail ember shutter; taller stable silhouette, forward-leading shoulder; disciplined and protective; right-facing, glancing back toward partner; preserve soot/rust/orange palette; avoid simple enlargement, horse tack, flames everywhere.
- **Stage III Coalcrest:** Ember; attach Wayburn PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; long-distance runner, shielded chest furnace, plated haunches, split signal crest; low aerodynamic torso, high crest, balancing tail; steady and discerning; right-facing guard-run stance, head high; same soot/rust with iron plates and ember core; avoid mounted armor, lantern, fire wings, generic dragon.

**Line 3 — Fusern -> Slagglass (two-stage kiln arthropod).**

- **Stage I Fusern:** Ember; squat arthropod, faceted shell, narrow furnace seam, three pairs of jointed legs; broad hexagonal back over thin legs; patient and heat-seeking; right-facing three-quarter brace, head tucked; charcoal, brick, oxidized copper, one orange seam; avoid pottery, tools, glowing full body, mascot beetle.
- **Stage II Slagglass:** Ember; attach Fusern PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; opened shell of angular glassy plates around protected heat chamber, longer load-bearing legs; raised asymmetric shield and chest negative space; deliberate and hard to dislodge; right-facing, one plate angled toward viewer; preserve charcoal/brick, add dark plum glass and tiny orange fractures; avoid smooth crystal, mirror shine, simple enlargement.

**Line 4 — Wickthorn (single).** Ember; thorn-backed burrower, narrow mask, hooked shoulder spines, tail holding one coal; compact crouch broken by one crooked spine; secretive and easily startled; right-facing crouch, tail curled beside body; black-brown, rust, muted ember, bone eye-glint; avoid candle, matchstick, cute hedgehog, all-over flames.

## Tide

**Line 5 — Rimefin (single; existing starter, optional redraw).** Tide; small sharp-bodied river shark, swept pectoral fins, notched dorsal, blunt tail fork, watchful eyes; clean wedge head and angular fins; curious and cool-headed; three-quarter battle pose facing right; deep river blue, slate, cold cyan, pale highlights; avoid round cartoon fish, bubbles, water effects, extra fins, changing recognizable design.

**Line 6 — Cutbank Listener -> Bend Caller -> Quietwater Warden (three-stage River Listener prototype).**

- **Stage I Cutbank Listener:** Tide; low cutbank amphibian, compressed body, split shovel-like brow paddles, short bracing fins, three narrow gill fans; near-ground silhouette with open space under brow; wary but curious, taps stones to map space; right-facing crouch, one paddle raised; deep teal, river blue, muted silver; avoid shark, catfish, turtle, armored lizard, smooth curves, broad smile. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Bend Caller:** Tide; attach Cutbank Listener PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; lengthened trunk, three widened backward-swept gill plates, second brow ridge forming resonance chamber; broader deliberate silhouette, retain split brow and negative space; confident in familiar water, unsure about echoes; right-facing call stance, gills flared; preserve teal/blue/silver, deepen gill shadows; avoid simple enlargement, whiskers, shell, generic fish.
- **Stage III Quietwater Warden:** Tide, proposed Hollow secondary; attach Bend Caller PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; long river guardian, layered dorsal ridges, dark glass gill chambers, broad asymmetric sensory vanes; grounded sweep, vanes visibly descended from split paddles; composed and protective, recognizes lifeless echoes; right-facing guard stance; same river teal/blue, near-black chambers, cold silver; avoid ghost costume, crown, generic shark, hostile expression.

**Line 7 — Siltcrank -> Millcurrent (two-stage channel swimmer).**

- **Stage I Siltcrank:** Tide; narrow bottom-feeder, ringed throat, four paddle feet, short circular dorsal fin; low horizontal body crossed by that fin; methodical and nosy; right-facing walk, one foot raised; mud teal, river blue, silt brown, pale foam; avoid machinery, human mill imagery, paddlefish brow, cute eyes.
- **Stage II Millcurrent:** Tide; attach Siltcrank PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; longer body, current-cutting fins, broad living tail fan; strong horizontal sweep, retain transformed circular motif; steady and protective of pools; right-facing turn, tail fan open; same teal/blue with pale water lines; avoid gears, literal waterwheel, metal, simple enlargement.

**Line 8 — Backeddy (single).** Tide; small ambush swimmer, flattened head, folded side fins, curled silt-trapping fin fringe; triangular head and crescent tail framing negative space; cautious and observant; right-facing hover, one fin open; dark blue-green, muddy slate, muted turquoise; avoid River Listener paddles, whiskers, bubbles, rounded body.

## Stone

**Line 9 — Marlward (single-stage Stone starter).** Stone; compact bluff-dweller, sloping limestone brow, layered shoulder plates, split stone toes; low four-legged wedge with uneven back ridge; steady and gentle with smaller creatures; right-facing brace, head low; limestone, slate, dry ochre, sparse moss cracks; avoid turtle shell, face-boulder, metal armor, round mascot.

**Line 10 — Flintram -> Mortarback -> Cutbank Bastion (three-stage bank guardian).**

- **Stage I Flintram:** Stone; nimble cliff quadruped, flint wedge brow, narrow limbs, two loose back plates; sloped head, high shoulder, visible leg gaps; stubborn and alert; right-facing step, testing foreleg; flint gray, limestone tan, iron, tiny moss; avoid sheep horns, turtle shell, boulder body, rounded face. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Mortarback:** Stone; attach Flintram PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; heavier forequarters, interlocking shoulder plates, earth-holding central groove; broad front, low rear, preserve brow angle; patient and protective of paths; right-facing shield stance; preserve flint/limestone, add soil brown; avoid literal wall, bricks, straps, simple enlargement.
- **Stage III Cutbank Bastion:** Stone; attach Mortarback PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; powerful low guardian, stepped ridge, root-like stone braces, debris-shedding plates; long stable wedge, high shoulder, visible feet; calm and protective; right-facing anchor stance; flint, pale limestone, soil, lichen; avoid building with eyes, castle turrets, literal levee, humanoid armor.

**Line 11 — Ballastak -> Switchhold (two-stage rail-bed burrower).**

- **Stage I Ballastak:** Stone; compact burrower, shovel snout, heavy claws, loose pebble plates; low wedge, oversized digging shoulders; private and industrious; right-facing dig stance, claw lifted; rail-slate, iron gray, dusty tan, tiny rust; avoid train, tracks, tools, round-nosed mole.
- **Stage II Switchhold:** Stone; attach Ballastak PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; broader digging shoulders, interlocking flanges, reinforced tunnel-bracing tail; widened shoulder shield over narrow body; reliable and careful around unstable ground; right-facing brace; preserve slate/tan/iron, small rust seams; avoid locomotive parts, literal switch, simple enlargement.

**Line 12 — Troughspine -> Archroot (two-stage spring crawler).**

- **Stage I Troughspine:** Stone; spring-side crawler, flat stone muzzle, paired side gills, three arched back ribs; low arch with visible openings; quiet and attached to seep-water; right-facing crawl, head lifted; wet slate, pale limestone, mineral green; avoid turtle, bridge, pipe, smooth shell.
- **Stage II Archroot:** Stone; attach Troughspine PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; taller rib arches with root-like mineral braces, widened gill flanges; keep open arch cavities; enduring and protective of springs; right-facing guard stance; preserve wet slate/pale stone, add root brown and lichen; avoid literal bridge, tree trunk, closed shell.

## Gale

**Line 13 — Skirr (single-stage Gale starter).** Gale; bluff-running reptile, wedge skull, long hind legs, short forelimbs, folded rib membranes; low sprint line, notched sail edge, balancing tail; skittish and sharp-eyed; right-facing spring crouch; storm blue-gray, smoke slate, pale dust, cream eye; avoid bird beak, feather wings, cute gecko, wind effects.

**Line 14 — Dustkite -> Waywhistle -> Highsignal (three-stage bluff signal glider).**

- **Stage I Dustkite:** Gale; light glider, four hooked feet, folded side membranes, narrow whistle-throat; small diamond torso; watchful and noise-shy; right-facing perch-crouch, membranes parting; storm gray, faded blue, dust tan, ivory throat; avoid bird, paper kite, string, cute bat, sound graphics. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Waywhistle:** Gale; attach Dustkite PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; longer throat chamber, extended forelimbs, ribbed membranes with split trailing edges; broader but light, diamond chest retained; communicative and exacting; right-facing landing, one membrane raised; preserve storm blue-gray and dust tan; avoid feathers, clothing, simple enlargement.
- **Stage III Highsignal:** Gale; attach Waywhistle PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; bluff sentinel, reinforced membrane ribs, resonant throat, forked tail vane; tall wing arc over narrow body; vigilant and loyal to routes; right-facing landing guard pose; deep storm blue, mineral gray, tan, ivory signal mark; avoid angel wings, feathers, halo, literal flag.

**Line 15 — Canvaswing -> Windcut (two-stage floodplain glider).**

- **Stage I Canvaswing:** Gale; broad membrane glider, narrow body, hooked toes, branching wing veins; low body framed by angular folded sails; calm and fond of high perches; right-facing cling, one sail open; faded slate blue, brown-gray, bone, rust vein; avoid cloth, sewing, bat face, feather fan, cute expression.
- **Stage II Windcut:** Gale; attach Canvaswing PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; longer torso, reinforced shoulder spars, notched membranes that split gusts; strong diagonal from high sail to tapering tail; decisive and protective in rough weather; right-facing dive-brake; same slate/bone with storm edge and little rust; avoid blades, paper, feathers, simple enlargement.

**Line 16 — Switchgust (single).** Gale; scree runner, spring ankles, split brow fin, dust-trapping flank vanes; angular zigzag, high rear legs, visible gaps; bold and changeable; right-facing sidestep, one leg tucked; dusty blue-gray, limestone, charcoal, sand; avoid tornado body, feathers, puppy shape, motion blur.

## Bloom

**Line 17 — Tallowroot (single-stage Bloom starter).** Bloom; sturdy seed-burrower, tapered snout, rootlike foreclaws, husked shoulder pod; low body broken by angular husk points and visible legs; patient and protective; right-facing brace, claw touching earth; moss, seed ochre, soil, cream sprout; avoid flower crown, cute vegetable, bean body, gardening tools.

**Line 18 — Cotterseed -> Canopyvein -> Floodcrown (three-stage floodplain shade line).**

- **Stage I Cotterseed:** Bloom; floating seed creature, dark kernel, two stiff cottonwood-like vanes, fine rootlets; narrow kernel framed by asymmetrical vanes; curious and migratory; right-facing hover, one vane lowered; seed brown, muted leaf green, river-gray tufts; avoid fluffy ball, cotton candy, cute face, literal tree. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Canopyvein:** Bloom; attach Cotterseed PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; lengthened kernel, veined leaf membranes, stronger rooting tendrils; wider canopy with gaps between panels; communal and resilient; right-facing hover-brace, tendril reaching down; preserve seed/gray-white, deepen green, add bark; avoid fairy wings, petals, cloud, simple enlargement.
- **Stage III Floodcrown:** Bloom, proposed Stone secondary; attach Canopyvein PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; floodplain guardian, layered leaf plates, deep root cradle, sparse wind-bent branches; high asymmetric canopy over grounded roots, open space beneath; protective and enduring; right-facing rooted guard stance; dark bark, river moss, ochre, pale flood mark; avoid tree-person, flower overload, jewelry crown, cute proportions.

**Line 19 — Milletusk -> Threshback (two-stage grainfield grazer).**

- **Stage I Milletusk:** Bloom; compact grazer, short shovel muzzle, seed-sheath tusks, dry-husk back; low torso with angular tusks and narrow legs; wary and social; right-facing three-quarter stance, head slightly turned; straw ochre, muted green, soil, cream seeds; avoid barnyard pig, branded grain, round snout, farmer props.
- **Stage II Threshback:** Bloom; attach Milletusk PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; deeper chest, longer sheath tusks, layered seed pods that scatter when startled; heavy shoulder and lifted bristled back, same muzzle; steadfast and communal; right-facing brace, foot scraping soil; retain straw/moss, darken husks; avoid tractor, machine, literal grain bundle, simple enlargement.

**Line 20 — Masonsward -> Thimblecomb (two-stage pollinator-builder).**

- **Stage I Masonsward:** Bloom; angular solitary pollinator, narrow mask, six jointed legs, pollen brushes, mud-plug abdomen; tapered thorax, square abdomen, folded wings; cautious and industrious; right-facing, one foreleg raised; dark leaf green, muted amber, clay, cream pollen; avoid round bee, bright stripes, honey pot, cute wings.
- **Stage II Thimblecomb:** Bloom; attach Masonsward PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; broader abdomen with layered hexagonal mud chambers, reinforced legs, pollen mantle; low angular body with readable planes, not sphere; communal and precise; right-facing guard pose, wings folded; preserve green/clay, muted amber, sparse cream; avoid cartoon honeycomb, crown, queen bee, simple enlargement.

## Hollow

**Line 21 — Hushmire (single-stage Hollow starter).** Hollow; marsh lurker, narrow skull, hollow flank cavities, long jointed legs, broken-ring tail; thin limbs around deliberate empty spaces; cautious and attentive to pauses; right-facing crouch, head tilted; ink charcoal, desaturated plum, wet gray, silver eye; avoid ghost sheet, skull, corpse, smoke, villain grin.

**Line 22 — Echolarva -> Stillshade -> Nullchorus (three-stage silence line).**

- **Stage I Echolarva:** Hollow; small segmented marsh creature, two empty shell cups, narrow feelers, dark abdomen; curled comma with visible hollows; timid and curious; right-facing curl, feeler extended; charcoal, plum-gray, dull silver, blue-black; avoid skull, ghost sheet, aura, cute caterpillar. For Stage I, leave Previous Stage Sprite (optional) empty.
- **Stage II Stillshade:** Hollow; attach Echolarva PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; longer body, cups fused into split resonator, four stabilizing limbs; low arch with open center; wary and attentive, repeats calls imperfectly; right-facing listening stance; same charcoal/plum, deeper voids, silver; avoid sound graphics, ghost effects, skulls, simple enlargement.
- **Stage III Nullchorus:** Hollow; attach Stillshade PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; long sentinel, stepped resonator spine, deep chambers, narrow balancing legs; rear arc over low forebody, open gaps; solemn and protective, recognizes echoes without living callers; right-facing guard; ink black, muted plum, wet silver, cold-blue seam; avoid death imagery, robes, instruments, glowing eyes, demon.

**Line 23 — Mutecho -> Unanswered (two-stage message mimic).**

- **Stage I Mutecho:** Hollow; compact wall-clinger, flat mask, deep throat aperture, short stone-gripping hooks; vertical flattened body, open throat, no mouth-line; observant and imitative; right-facing cling, head turned toward viewer; charcoal, indigo-plum, damp gray, silver; avoid speaking mask, human face, sound marks, horror teeth.
- **Stage II Unanswered:** Hollow; attach Mutecho PNG in Previous Stage Sprite (optional); preserve this line's face, signature anatomy, and palette while making the new silhouette specified here; taller body, ribbed throat chamber, two offset gripping arms, split back plate; narrow vertical profile with throat negative space; patient and protective of quiet places; right-facing brace; retain charcoal/indigo, deepen void, silver rim; avoid robes, text, human hands, scream mouth, simple enlargement.

**Line 24 — Glassquiet (single).** Hollow; low marsh quadruped, wedge face, opaque dark flank plates, one missing plate leaving an empty window; thin feet beneath broken diamond back; gentle and distant; right-facing stand, head lowered; charcoal, smoky violet, cold gray, desaturated teal glint; avoid photoreal glass, crystal shards, ghost sheet, gore, cute gem animal.

## Design and implementation guardrails

- Rimefin and Cinderhide remain single-stage starters. Do not infer an evolution for Cinderpelt.
- The River Listener prototype is user-selected; its labels, final forms, art, and trigger still need review.
- Do not create or link creature resources from this proposal alone. Secondary essence support and the player starter/party ownership path are incomplete; see docs/world-bible.md Phase 3.
- The prior hand-drawn River Listener study is not production art and must not be used as an evolution reference. Use only a generated, reviewed sprite from the same line.
