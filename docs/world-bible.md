# Hollowtide: Living Game Bible
## Draft 0.6 | 26 September 2026

This is a working design document for Preston to shape. It distinguishes established project decisions from new proposals. Names marked **working** are not locked canon.

## 1. The game in one sentence

A moody, character-led monster-collecting RPG about carrying people and creatures through a river region where routes, memories, and stories can all go quiet.

## 2. What already belongs to Hollowtide

These points come from the current project and are treated as the foundation:

- Godot 4, GDScript, 2D pixel art.
- Cinderhide remains part of the game and its visual identity should be preserved.
- The existing battle presentation has deliberate impact animation: wind-up, lunge, hit stop, flash, squash, shake, floating damage, and continuously sliding HP bars. The bars use Turbo Green viridian at full health, yellow to orange at medium health, and red when low. Preston selected the Main HUD artwork for their frames and controls; the live HP fill still tracks exact remaining health. A river-landing background study now sits behind the battle stage. New mechanics should keep that physical feel.
- Creature art favors readable angular silhouettes, crisp pixels, transparent backgrounds, and compact palettes. The current Forge conversion preserves the observed 100x100 logical pixel grid in finished transparent Godot sprites; original Forge outputs and converted assets are kept separately.
- The current essence concepts are Ember, Tide, Stone, Gale, Bloom, and Hollow. Their matchups should be understandable from the idea of each essence.
- Preston chose three stages for every creature line. The current draft has 20 one-to-one lines and 60 forms across the six essences, including proposed full chains for the Cinderhide and Rimefin starter lines. Most forms exist only as briefs; names and exact roles remain proposals until reviewed.
- Rimefin is an existing Tide creature and Cinderhide is an existing Ember creature. The older Cinderpelt experiment was removed from the project after its art went missing; it is not linked to Cinderhide. The currently linked next stage is the provisional Clinkerhide.
- Preston selected his personal jade titan (an invented creature, not an Earth animal) as the Stone starter (Line 9, 2026-09-29); Bloom's original seed-burrower starter, Tallowroot, is restored at Line 17. Working names: Preostmar → Oathfen → Oxbowarchon. Its [full design and Forge briefs](personal-stone-line-proposal.md) are ready; no approved sprite or Godot resource exists yet.
- Creature temperament is a possible second design axis. It should be taught clearly and early if retained.

Earlier 96x88 and 64x64 canvas notes are historical. Real Sprite Forge output led to the current 100x100 conversion target in THE_CONCEPT.md. Each generated asset still needs visual review before import.

## 3. Design pillars

### Every route connects people

Exploration should feel like crossing a lived-in place, not moving through filler corridors. A route has a reason to exist: a delivery, a habitat, a blocked crossing, a local dispute, or a story someone has kept.

### Creatures belong somewhere

Wild creatures are visible in their environments. Their behavior, silhouette, and battle role should suggest how they live. Capture should feel like a relationship and a field discovery, not harvesting interchangeable drops.

### Growth changes identity

Evolution should change silhouette, role, and how a partner relates to the world. A new stage may gain a second essence or a field skill, but it should not be only a larger body and higher numbers.

### The past is contested

A famous story may be incomplete, romanticized, or used for someone else's benefit. Hollowtide can explore the gap between a legend and the ordinary people who lived around it without copying real people or celebrating violence.

### Finish a small journey before expanding

The first target is one compact route, one complete delivery, one meaningful battle, and a return to a changed town. Larger guild ranks, towns to rebuild, deep dungeons, and dozens of creatures wait until that loop is enjoyable.

## 4. World proposal

The [region atlas draft](region-atlas-draft.md) connects the proposed areas, story progression, character roles, and habitats for all 20 three-stage lines. The [far-bank slice draft](far-bank-slice-draft.md) turns the next proposed route into a small work assignment. Both are production proposals, not approved canon.

### Region: The Siltward Reach (working name)

A fictional inland river region inspired by St. Joseph's mix of bluff-top streets, steep descents, an old ferry crossing, rail and market history, and a broad river edge. It is not a map of St. Joseph and does not use real residents or historical figures as characters.

### Nearby ecology references (research-grounded, not creature canon)

Missouri Department of Conservation describes Bluffwoods, about nine miles south of St. Joseph, as part of the Missouri River loess hills, with steep valley bluffs, oak-hickory forest, old fields, grass openings, and springs. Its regional prairie guide notes species such as large beardtongue, scarlet gaura, swift tiger beetle, and plains hognose snake. These details support a compact route that moves from bluff woodland through exposed dry prairie toward floodplain habitats. Creature designs should be original abstractions; these species are reference material, not approved roster additions.

### Main settlement: Highbank (working name)

A layered town built up the bluff and down toward the water. The upper streets hold homes, shops, and the dispatch hall. Switchback lanes descend through retaining walls, gardens, and older buildings to the ferry district. From the high streets, the river looks close; on foot, reaching it takes time.

### The Old Ferry Ward (working name)

The first significant exploration area. It includes the old landing, a walkable river trail, a flood-mark wall, cottonwood islands, service sheds, and an abandoned relay post. Ferries once made this stretch a threshold between an overland route and the far bank. In the game, the ferry site is where messages, people, and creature migrations meet.

The Old Ferry Ward matters to the story because the first local reports of Hollowtide came from this crossing. During certain still evenings, familiar calls seem to arrive from the wrong direction. Some messages reach the landing with a sentence missing. River creatures gather there even when the banks are quiet.

### Hollowtide

Hollowtide is the local name for a recurring hush in the watershed. It is not a literal ocean tide. During a Hollowtide, sounds carry strangely, creatures leave familiar paths, and people disagree about what they heard. Its cause is unknown at the beginning.

Keep the phenomenon observable but debatable. A player should be able to collect evidence from routes and witnesses before the game gives a confident explanation. Hollowtide is not automatically evil; it may be a natural cycle, a creature response, or a human-made disturbance.

### Flood memory and the far bank (working story seed)

The 1993 Great Flood and the destruction of Elwood, Kansas, across the Missouri River from St. Joseph, are major real-world inspirations for the region's relationship with water. Preston remembers the event as a decision between flooding St. Joseph or Elwood, and remembers the levee being deliberately broken to spare St. Joseph. Keep that firsthand memory intact as a memory; distinguish it from what public records currently establish.

For Hollowtide, this can become a contested local story about who gets protected, who bears the cost, and how a community lives with the version of events it was told. A possible fictional counterpart might preserve eyewitness testimony, official reports, and family retellings that disagree. Whether the fictional levee was intentionally opened is not decided here. Do not present the real Elwood levee as intentionally breached as a verified historical fact.

A second environmental seed is a “ghost channel” that reappears during Hollowtide. Keep its real inspirations distinct: the Corps documents a new Missouri River channel and oxbow formation after the 1952 flood; the 1993 event caused an overtopping breach at the Elwood-side levee. A fictional river memory may combine those ideas, but the real 1993 flood should not be described as the channel change.

**Recommended story treatment (not locked canon):** early scenes should preserve the conflict between memory, records, and rumor without confirming an intentional breach. Show what flood danger cost people and how they helped each other. If the fictional region later has an intentional opening, make it a fully invented event with its own evidence and motives; do not use it to declare what happened at Elwood.

## 5. The courier and stewardship order

### The Wayline Compact (working name)

A regional relay service that grew into a public guild. Its members carry letters and supplies, mark safe routes, report creature behavior, assist travelers, and help settle disputes between communities and habitats.

It fills three roles without needing three separate organizations:

- **Courier network:** messages and goods move between small settlements.
- **Field stewardship:** members report migration changes, injuries, and unsafe crossings.
- **Guild:** trainees earn trust by completing useful work, not by collecting abstract ranks.

Its stations are practical places: a dry room, a map board, water for partners, a first-aid kit, and a place to leave a message for the next runner. The emblem could be a simple route mark with three dots, subject to art direction.

The order is inspired by relay couriers and ranger-like work, not a direct copy of the Pony Express. In real history, the Pony Express operated for only about 18 months before the transcontinental telegraph replaced it. Hollowtide's Wayline should have a distinct origin and ongoing purpose.

The Pony Express's financial troubles are useful context, but the service ended when telegraph coverage made it obsolete. A creature inspired by relays might express the idea through handoffs, urgent bursts, and recovery costs; “burns itself out” is only one fictional mechanic, not a direct historical conclusion. ([National Park Service](https://www.nps.gov/poex/learn/historyculture/index.htm), [National Park Service on the mochila and service period](https://www.nps.gov/articles/000/commemoration-of-the-pony-express.htm))

### The player's role

The player is a new Wayline field runner who travels with a creature partner. The first assignment is ordinary on purpose: carry a sealed reply to the Old Ferry Ward, find out why the receiving post stopped answering, and return with a report. The missing answer opens the larger mystery.

## 6. First playable route

**Highbank Dispatch Hall -> Switchback Road -> Old Ferry Ward -> river trail -> return to Highbank**

The route should take a few minutes to cross and contain:

1. One short conversation that shows what the Compact does.
2. One visible wild creature that can be approached or avoided.
3. One readable battle using the existing battle presentation.
4. One environmental clue related to sound, water, or a missing message.
5. One delivery choice or observation that changes what an NPC says on return.
6. A clear end point. No town-building or multi-floor dungeon is needed for this slice.

Use the same spaces for exploration and creature sightings where practical. Keep the current battle scene until a small prototype proves that a different battle flow is better. Do not rebuild the proven battle foundation to chase a reference.

### First assignment beat sheet (proposal)

This is a small, implementable version of the opening route, not locked story canon. Keep all names as place or job labels until Preston approves the region names.

1. **Dispatch Hall:** a dispatcher gives the new runner a sealed route pouch for the Old Ferry Ward relay post. The instruction is to deliver it and report whether the post is operating; do not open the pouch.
2. **Switchback Road:** one route marker is turned sideways. The player can read its three-dot relay mark and set it straight, teaching that route care is part of the job rather than a battle reward.
3. **Old Ferry Ward:** the pouch is delivered to the post's dry slot. No keeper answers, and the day's return mark is missing. The delivery still counts.
4. **River trail:** a familiar two-note creature call seems to come from the far bank. A second, weaker copy answers from beside the post. No character can prove whether this is an animal, an echo, or a route signal carried by the water. An optional visible Cinderhide encounter can use the existing battle screen and can be avoided.
5. **Return to Highbank:** the player chooses whether to report only that the post was empty or to include the two calls. The dispatcher's response and one mark on the route board change; neither report confirms what caused the signal.

The first slice should end with the pouch delivered, the route marker restored, and the report recorded. This gives the player a complete outward-and-return loop without deciding the Hollowtide mystery or making a claim about the real 1993 Elwood flood. The far bank and flood-history conflict belong in a later chapter, after the player has met people on both sides of the river.

**Prototype status (2026-09-26):** `scenes/first_route_prototype.tscn` now contains the delivery, marker, empty post, optional two-call river clue, and report choice. It reuses the existing player, visible Cinderhide encounter, and BattleScreen, with a muted CC0 terrain study. The original `main.tscn` remains the project start scene. Godot opened the new scene and parsed its script; the assignment has not yet been played end to end. Props and place labels are prototype placeholders, not approved canon.

## 7. First new creature-line seed

This is a provisional concept, not a locked species or approved name.

**Working label: the River Listener line**  
**Essence path: Tide, then Tide/Hollow at the final stage**

- **Stage I:** A low, quick cutbank amphibian with a shovel-shaped brow, narrow body, and small split gill fans. It taps river stones to map nearby spaces.
- **Stage II:** The gill fans widen into hard, angular plates. It can send a short call around bends and recognizes familiar voices, but it cannot tell a true message from an echo.
- **Stage III:** A long, powerful river guardian with a stepped dorsal ridge and dark, glassy gill chambers. It can distinguish a living call from an old echo and guide creatures away from dangerous channels.

The visual evolution moves from close-to-ground and alert, to broad and resonant, to long and authoritative. Avoid making it a generic shark, catfish, turtle, or armored lizard. Its defining shape is the split gill fan and the negative space under its head. Preston chose guards and interruptions for this line's eventual four-move kits. Its gameplay role is a defensive scout that protects and disrupts rather than a high-damage attacker; the [defensive move rules](defensive-move-rules-draft.md) are a proposal for how those actions could work in the current battle system.

A later field ability might let this line reveal a safe crossing or identify which sound is an echo. Keep that out of the first battle prototype unless it proves useful in the route.

Preston selected River Listener as the first new nonstarter three-stage line to develop. Its labels and details remain proposals, and no resource link has been created. Cinderhide-to-Clinkerhide is the current playable starter evolution prototype. The 20-line/60-form roster draft and copy-ready Sprite Forge briefs are in [docs/creature-roster-draft.md](creature-roster-draft.md); the earlier silhouette study is not production art.

### Preston's Stone starter: the jade titan

**Selected concept, updated 2026-09-29; working names:** Preostmar → Oathfen → Oxbowarchon is now the **Stone**
starter at roster Line 9, replacing the former Marlward line. Its life is a single living emerald, the Kingstone;
because emerald is brittle, the line grows layered jade armor, among the toughest stones there is, to protect it,
ending in an SSS-tier jade fortress whose petrified siege spire fires the Kingstone's power. Inspired by Torterra
and the Green King of Accel World, copying neither. The earlier floodplain-refuge lore (the moving ring of reeds)
is superseded; whether its protector role survives in the new lore is open. See the
[stage briefs and v2 prompts](personal-stone-line-proposal.md). No front, back, idle art, live creature resource
or assigned moves exist yet.

## 8. Reference synthesis

Use each reference for a design lesson, not as a feature checklist:

- **Nexomon:** a clear, welcoming monster-collector journey and a bestiary that supports a sense of discovery.
- **Coromon:** readable creature identities and a compact defensive type chart with room for move variety.
- **Monster Sanctuary:** creatures can have distinct tactical jobs and, eventually, meaningful uses in exploration.
- **Cassette Beasts:** strong identity between creature concept and presentation. Do not assume its fusion system belongs in Hollowtide.
- **Miscrits:** use as a prompt to investigate what made creature discovery, habitats, and collecting feel inviting to its players; do not copy its systems without research.
- **Outernauts:** visible creatures and discrete named places suggest a world that can be read and explored directly. Prototype this as a small route before changing the whole overworld.
- **Digimon:** evolution can carry emotional and thematic meaning. Keep each creature line coherent and one-to-one; avoid duplicate forms, branching, or converging evolution unless Preston changes that rule.

The shared target is a world where the player leaves a place with people in it, crosses a distinct route, meets a creature that belongs there, makes a meaningful choice or discovery, and returns to a changed conversation.

## 9. Story guardrails for St. Joseph inspiration

Verified historical anchors are research material, not in-game canon:

- St. Joseph was platted as a town in 1843 around a river landing and trading post.
- The river landing served ferries and riverboats for passengers crossing between Missouri and Kansas; Pony Express riders used this crossing in 1860-61.
- Flooding destroyed the original landing. The current riverfront site is a viewing platform near the historic location.
- The Pony Express began its first official delivery from St. Joseph on April 3, 1860 and ended after the transcontinental telegraph reached the route in 1861.
- Jesse James was killed in St. Joseph on April 3, 1882 by Bob Ford. The preserved home has been moved from its original location.
- The Great Flood of 1993 reached St. Joseph and Elwood, Kansas, across the river. The U.S. Army Corps of Engineers reports that the Elwood-side levee unit overtopped and breached on July 26, 1993; its later study says the St. Joseph-side unit held but came close to overtopping. The St. Joseph Museum's Confluence exhibit describes the claim that Elwood's levee was deliberately destroyed to spare St. Joseph as an unsubstantiated local rumor. Preston personally remembers it as an intentional choice; preserve that as his firsthand recollection, separate from the available public record. A Corps report dated September 1994 may explain the remembered year, but that connection is only a possibility.

These facts suggest useful themes: the river as a connector and a threat, routes that change with technology, a legend that outlives the event, and the unequal costs of flood protection. Keep the fictional setting distinct. Do not turn psychiatric patients or treatments into monster concepts, or make Confederate leaders and violent outlaws aspirational creature partners. A historical figure may be discussed in context without becoming a collectible species. Before using specific Indigenous histories, names, symbols, or stories, research them with authoritative sources and seek appropriate community perspectives.

Sources:
- [St. Joseph Ferry Landing and Riverwalk, National Park Service](https://www.nps.gov/places/st-joseph-ferry-landing-and-riverwalk.htm)
- [The First Ride, Pony Express National Historic Trail](https://home.nps.gov/poex/learn/historyculture/the-first-ride.htm)
- [Gateway Park Historical Context, City of St. Joseph](https://www.stjosephmo.gov/357/Gateway-Park-Historical-Context)
- [Jesse James Home, City of St. Joseph](https://stjosephmo.gov/362/Jesse-James-Home)
- [Patee House Museum, National Park Service](https://www.nps.gov/places/patee-house-museum.htm)
- [St. Joseph Museum Confluence: Community in Action](https://stjosephmuseum.wixsite.com/confluence/community-in-action) (local exhibit with an account from 1993 emergency management director Ed Wildberger)
- [St. Joseph Museum Confluence: What Have You Heard About Flooding?](https://stjosephmuseum.wixsite.com/confluence/what-have-you-heard-about-flooding) (documents the deliberate-breach rumor and says evidence has not been found)
- [U.S. Army Corps of Engineers: St. Joseph Final Feasibility Report](https://usace.contentdm.oclc.org/digital/api/collection/p16021coll7/id/9413/download) (documents the July 26, 1993 overtopping failure and impacts in Elwood)
- [U.S. Army Corps of Engineers: Missouri River Levee System past performance assessment](https://www.nwk.usace.army.mil/Portals/29/Appendix%20A_1_%20LOMO%20FRM-Past%20Performance%20Assessment.pdf) (corroborates that the 1993 Elwood unit overtopped and breached)
- [Missouri Department of Conservation: Paddlefish](https://mdc.mo.gov/discover-nature/field-guide/paddlefish) (rostrum, filter feeding, and electro-sensory biology)
- [Missouri Department of Conservation: Bluffwoods Conservation Area](https://mdc.mo.gov/discover-nature/places/bluffwoods-conservation-area) (local loess hills, steep bluffs, woodland and prairie habitats)
- [Missouri Department of Conservation: Prairies](https://mdc.mo.gov/discover-nature/habitats/grasslands-prairies-savannas/prairies) (northwest Missouri loess hill prairie conditions and species)
- [National Park Service: Commemoration of the Pony Express](https://www.nps.gov/articles/000/commemoration-of-the-pony-express.htm) (mochila structure, relay operation, and 18-month duration)
- [City of St. Joseph historic-context report](https://www.stjosephmo.gov/DocumentCenter/View/16574/Polish-Trail-PDF) (stockyards scale, industry, labor, and local impacts)

### Grain, milling, and brewing (research anchors; not canon)

St. Joseph's industrial riverfront can give later routes a strong visual and gameplay identity. State history records a major grain exchange, Quaker Oats' 1928 mill and 1929 two-million-bushel elevator, and more than 13 million bushels ground locally in 1927. State and government records show how grain moved through cleaners, mills, conveyors, elevator bins, rail unloading, and packaging. Goetz Brewing's Country Club Special near beer offers a separate example of a company adapting its products during Prohibition. The Fuelling works add a smaller-scale bottling and food-production complex.

These are research anchors, not in-game canon. “Flour glut” as the cause of the pancake-mix invention remains unverified in the sources reviewed. The Fuelling works have conflicting early dates; the state survey places the works at 1001 Dewey and 115 West Franklin in buildings erected in 1871. A local observer's report of birds at spilled corn and a toasted-corn smell is useful sensory texture, not a general historical claim. See [docs/research/st-joseph-field-notes.md](research/st-joseph-field-notes.md) for source notes and corrections.

**Later-route proposals:** use the elevator skyline and material-handling flow for a distinct route or dungeon; explore a rail switching yard as a habitat only after more local wildlife accounts; or build a quest around a workshop adapting when supplies or routes change. These concepts are unapproved and should not displace the compact first route. Do not use racist branding as creature material, assume Goetz near beer was alcohol-free, turn workplace danger into a casual hazard, or treat historical pollution and broken glass as spectacle.

Sources: [Missouri historic-resources survey](https://mostateparks.com/sites/mostateparks/files/HistoricResources-StJoseph.pdf), [Missouri DNR Quaker Oats permit](https://dnr.mo.gov/sites/dnr/files/vfc/2023/02/main/quaker-oats-st-joseph-op2000-098.pdf), [Missouri Secretary of State archive on Pearl Milling](https://www.sos.mo.gov/CMSImages/Archives/newsletter/DecemberNewsletter.pdf), [St. Joseph CVB Goetz Brewery Museum](https://stjomo.com/goetz-brewery-museum-saint-josephs-rentable-historic-beer-museum/).
## 10. Grok field-research prompts

Treat Grok's findings as leads. Ask for public links, post dates, short supporting excerpts, and an explicit label for firsthand account, family story, secondhand rumor, or official record. Do not ask it to identify private individuals or search private groups. Verify historical claims against museums, archives, government sources, and local historians.

### Prompt A: How the place feels to residents

Find public firsthand accounts from people who live in or grew up in St. Joseph, Missouri, describing ordinary places and routines: walking from the bluffs toward the river, old neighborhoods, riverfront access, local weather, sounds, landmarks, and places they take visitors. Prioritize Reddit posts and public social posts where the writer is clearly describing their own experience. Give the exact link, date, a short excerpt, and why the detail might help a fictional game environment. Separate firsthand accounts from guesses and tourism copy. Do not include private personal information.

### Prompt B: River, floods, and the old landing

Search public firsthand posts and oral-history interviews by St. Joseph residents about the Missouri River, the riverfront, high water, flood preparations, levees, ferries, river trails, and how the river changes the way people travel or think about the city. For each result, include the source link, date, a short excerpt, and whether it is a firsthand memory, family account, or secondhand report. Look for small sensory details, not just flood statistics. Do not present another Missouri town's flood story as a St. Joseph account.

### Prompt C: Pony Express and Jesse James in local memory

Find public comments, Reddit discussions, interviews, museum guest reflections, and local-history discussions by St. Joseph residents about how the Pony Express and Jesse James are remembered today. What do people find fascinating, over-marketed, complicated, or missing from the familiar story? Include exact links, dates, short excerpts, and source type. Keep a separate section for claims that need historical verification. Do not turn an outlaw into a heroic role model by default.

### Prompt D: Local nature and creature behavior

Find firsthand public observations by people in the St. Joseph area about Missouri River wildlife and seasonal change: fish, mussels, amphibians, birds, insects, riverbank plants, mud, ice, high water, and sounds at dusk or dawn. Prefer local naturalists, anglers, conservation workers, and dated observations with photos or a named location. Link every account. Distinguish observation from species identification and verify species claims with a wildlife agency or museum.

### Prompt E: Cross-check and synthesis

Using the linked firsthand accounts above, identify five recurring details that are both specifically local and useful for a fictional monster-collector game. For each, quote no more than one short phrase, link the source, and explain how it could become a route detail, creature behavior, NPC voice, or quest. Keep real history and proposed fiction in separate columns. Flag contradictions instead of averaging them away.

## 11. Production plan

The [opening-chapter production path](opening-chapter-production-path.md) gives the current file-checked build order and cross-assistant handoffs. The phases below describe the wider game trajectory.

### Phase 0: Protect and understand the foundation - complete

Inspected the Godot project, its concept and art notes, creature resources, battle presentation, and current 2D overworld. Preserve existing assets and behavior unless a small prototype gives a clear reason to change them.

### Phase 1: Lock a world foundation - in progress

Create this living bible, record source facts separately from proposals, define the first route, and collect Grok firsthand research. Preston reviews names and any choices that would change the existing essence chart or creature roster.

### Phase 2: Make the project safe to change - ongoing

The project is a Git repository. Review the current branch and working tree before structural cleanup or commits; earlier branch and commit observations are stale. Keep generated assets and source references traceable. The CC0 river terrain has a source and license record, and original Forge images remain separate from converted game sprites.

### Phase 3: Prove one complete creature line - in progress

The evolution resource field, battle-win trigger, transformation animation, and three-stage line validator exist. Preston approved winning a battle as this prototype's evolution trigger and approved completing the Cinderhide starter line only. The current resources link Cinderhide → Clinkerhide → Ironvent; Clinkerhide's display name no longer carries a proposal suffix. These are playable resource links, while form names, balance, and finished art remain reviewable.

Each captured creature has its own run-local `PartyMember`; `PlayerParty` tracks the active slot, and a battle updates that same member on evolution. The first-route prototype has a P-key party panel. The current main scene has a separate bottom-left button that cycles the active creature for the next battle. Battle idle uses creature-specific code-driven breathing and size values; Preston also wants hand-drawn idle frames later. Switching within battle, individual HP and level progression, and saving remain open work. The encounter connection, idle in motion, party button, and full evolution line have not had a complete play review. Preston wants a distinct Hollowtide battle camera. The [battle camera brief](battle-camera-brief.md) tracks an implemented river-landing background study, short stage focus movements, and a moving creature stage under a fixed Main HUD. A captured battle showed name and HP overlap, so the HUD was revised to place those labels above the framed bars with a pixel font. The revised layout, camera timing, and full battle flow still need an in-game visual review. Coordinate work on `scripts/battle_screen.gd` with Claude and Summer Engine.

Preston also selected the River Listener as a nonstarter line prototype, but the earlier archived image conflicts with the current Cutbank Listener brief and the line is due for a redraw. Its art and resource links are pending review. Secondary essences are not represented by `CreatureData`. Do not restore the removed Cinderpelt link by inference.

### Phase 4: Build the first region slice - prototype in progress

`scenes/first_route_prototype.tscn` connects a dispatch point, a sand switchback, a crooked marker, a visible Cinderhide, an empty relay post, and a river landing. Its muted grass, shore, water, and shrub tiles come from the documented CC0 sheet. An original study pass adds a Wayline office, cottonwoods, a retaining wall, and a river-height marker; the landmark props remain placeholders. The height post can record visible, undated high-water cuts in Field Notes and, if inspected before filing, in the final route report. Its reach and panel layout still need play review.

The current main scene has a walking `EncounterTrigger` connected to battle alongside the visible Cinderhide interaction. Its saved scene-specific wild encounter pool contains Cinderhide only, avoiding evolved all-roster spawns. The revised behavior has not been played. The [asset location index](asset-location-index.md) identifies cutbank and courier prop studies that may add place-specific texture after slicing and scale review. The route is still a compact prototype rather than a finished town, road, and ward.

### Phase 5: Complete the first player journey - pending play review

The prototype script supplies one delivery, a restored marker, an optional river-call clue, and two report outcomes. The existing encounter supports a battle and capture. Play the outward-and-return loop, inspect both report branches and the battle, then refine pacing, navigation, and UI before making this the project's start scene. The player should finish with a question about the river's messages, not just more inventory.

### Phase 6: Expand from evidence

After the route loop has been played and refined: review the Wayline Compact, tune temperament and type teaching, review the linked Cinderhide line in play and art, add the next habitat, and grow the roster toward the 20-line target.

## 12. Decisions still open

- Keep six essences, or revisit the separate proposal for eight defensive essences and move-only attack types?
- Should the old Cinderpelt experiment remain retired, or be revisited as a separate concept after the current starter lines are reviewed? Do not restore the removed resource link by inference.
- Are Highbank, the Siltward Reach, Old Ferry Ward, and Wayline Compact the right names?
- Does the Wayline Compact register every creature formally, or is partnership personal and local?
- What visual shape should govern the game's UI: mineral facets, river-mark lines, or another motif?
- Should Hollowtide ultimately have a natural explanation, a creature-driven explanation, or remain partly ambiguous?
- What is the eventual truth of Hollowtide's fictional flood story? Keep it unresolved in early drafts; the real-world record and Preston's memory are documented separately above.
- Which original concepts should replace any retired Creaturedex pitches within the current 20-line roster? Keep Picarum, Tranquilith, Vulpfen, and Outlawg retired unless Preston explicitly revives them.

The grain/milling/brewing audit now has initial anchors in the state historic-resources survey, a Missouri DNR permit, the state archives, and local brewery sources. The 1888–89 Pearl Milling origin and regional grain scale are supported; the “flour glut” motive and Fuelling’s exact start date remain unsettled. Continue with worker and neighborhood perspectives before making an industrial site a major story location. Treat racialized commercial imagery as history to examine carefully, never as a creature-design shortcut.

Until decided, the six-essence chart, Cinderhide, current battle feel, and compact playable scope remain the working foundation.


