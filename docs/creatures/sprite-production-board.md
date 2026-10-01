# Hollowtide sprite production board

**File-checked 2026-09-27.** This records what Godot currently links, what exists only as a candidate, and the next art jobs. Draft roster names remain proposals. Use it beside the [60-form briefs](creature-roster-draft.md), [Ember prompt pack](../forges/ember-forge-prompt-pack.md), and [asset index](../team/asset-location-index.md). The [main Sprite Forge](https://opal.google/edit/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY) handles Stage I fronts and same-form redraws; the [Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV) handles later fronts and true backs. Generation availability changes by quota. Do not substitute an unapproved candidate just to fill a slot.

## Current game art

- **Ember:** all nine fronts are in the game. Seven back PNGs are present. Clinkerhide and Fusern currently have no back PNG; their resources use the existing front-sprite fallback until matching backs are reviewed. Ironvent uses a **provisional** side-facing battle back.
- **Cinderhide → Clinkerhide → Ironvent:** the approved starter evolution path is linked. Ironvent's front, six-frame claw attack, and provisional converted back are in game. The new Gemini attack-animation research is reviewed in [this adoption note](../research/gemini-combat-animation-research-adoption.md); it does not yet replace Ironvent's current attack.
- **Kithflare → Wayburn → Coalcrest:** Kithflare's approved front and back remain linked. Preston approved a distinct Wayburn Stage II front and a revised rear that keeps its matching pose with the left hind foot tucked inward; `104_wayburn.tres` links the new 100×100 pair. Preston approved Coalcrest's revised rear with front claws pointing away; `105_coalcrest.tres` links that 100×100 rear with its already approved front. These resources load in Godot. The line's evolution links remain a separate design decision.
- **Fusern → Slagglass → Vitrecrag:** Fusern's missing back reference was removed pending new art. Slagglass keeps its pair. Preston approved Vitrecrag's new true rear; its exact previously imported 128×128 front and rear were restored to the paths linked by `108_vitrecrag.tres`, with `battle_size = 1.75`. Their source hashes match Godot's prior imports. The line's evolution links remain a separate design decision.
- **Rimefin:** the exact legacy front was restored from the project archive to keep the current resource loadable. It is temporary art; its Forge redraw and back have not been approved or imported.
- **Other essences:** Stone, Gale, Bloom, Hollow, and the other Tide forms currently have roster briefs rather than production sprites or live creature resources. The archived River Listener image does not match the current split-brow amphibian brief.
- **Stone starter:** Preston selected his personal jade titan (an invented creature, not an Earth animal) [Preostmar → Oathfen → Oxbowarchon](personal-stone-line-proposal.md) for Line 17. Its prompts exist, but no sprite or live resource exists yet.

A front is not a complete battle form. Any partner needs a matching approved rear, a transparent native-grid import, and an in-game scale/pose review. Art alone does not approve evolution links or balance values. Preserve original source images, old versions, and rejected candidates for comparison; do not silently replace approved fronts.

**Source-path note:** `docs/HollowTide Sprites/` is absent in the current checkout. The nine raw Ember fronts are in `docs/creatures/source-art/`, while matching raw backs were not found there. Older path references later in this file are historical; check files before following them.

## Next art sessions when generation is available

1. **Missing Ember backs:** make or locate matching Clinkerhide and Fusern backs, review them at battle size, then wire them. Do not promote Clinkerhide's unapproved rig pilot candidate as final art.
2. **Ironvent back review:** view the linked provisional `ironvent_back_2026_09_27.png` in battle. Preston supplied the source and chose to use it for now; make a truer rear only if that view still feels wrong.
3. **Battle view review:** inspect the approved Wayburn, Coalcrest and Vitrecrag front/rear pairs at real battle size, including the large Vitrecrag's silhouette and stance. Their resource links are saved; the on-screen scale still needs an eye check.
4. **Ironvent Cinder Claw:** follow [the reviewed Gemini combat motion note](../research/gemini-combat-animation-research-adoption.md). Approve the anticipation and contact poses before replacing the current action frames.
5. **Evolution lines:** keep the Kithflare and Fusern line links unassigned until their game progression rules are deliberately set. Art approval alone is not evolution approval.
6. **Rimefin:** redraw Stage I from its current wedge head, dorsal notch and river palette; approve its front, then back, before growing Riftfin and Scourmaw one stage at a time.
7. **Preostmar:** make the personal Stone starter from its approved concept and prepared brief. Approve Stage I before using it as Oathfen's ancestry, then Oxbowarchon's. Each rear uses the exact same form's approved front.
8. **River Listener and habitat lines:** follow the table below as those places become playable. Keep the River Listener line's guards and interruptions in its move direction, while its names and Hollow secondary remain proposals.

If the generator stops for the day, stop at the last approved form and save its original output and brief. Never feed a rejected image into the next evolution.

## Line queue

| Line | Essence and role | Current production state | Next front action |
|---|---|---|---|
| Cinderhide → Clinkerhide → Ironvent | Ember starter | Three fronts; Clinkerhide back missing and using front fallback; Ironvent back provisional; linked evolution | Make and review Clinkerhide back |
| Kithflare → Wayburn → Coalcrest | Ember relay runner | All three approved front/back pairs linked; evolution path still unassigned | Battle size and pose review |
| Fusern → Slagglass → Vitrecrag | Ember kiln arthropod | Fusern back missing and using front fallback; Slagglass pair linked; Vitrecrag official pair restored at 128×128 | Make Fusern back; battle size review |
| Rimefin → Riftfin → Scourmaw | Tide starter | Legacy Rimefin front only | Redraw Rimefin |
| Cutbank Listener → Bend Caller → Quietwater Warden | Tide river listener | Archived rejected candidate only | Cutbank Listener |
| Siltcrank → Millcurrent → Braidwake | Tide channel swimmer | No production art | Siltcrank |
| Marlward → Terraceward → Bluffmantle | Retired (replaced by Preston's line, 2026-09-29) | No production art | none |
| Flintram → Mortarback → Cutbank Bastion | Stone bank guardian | No production art | Flintram |
| Ballastak → Switchhold → Deepcut | Stone rail-bed burrower | No production art | Ballastak |
| Troughspine → Archroot → Springvault | Stone spring crawler | No production art | Troughspine |
| Skirr → Scudder → Stormveer | Gale starter | No production art | Skirr |
| Dustkite → Waywhistle → Highsignal | Gale signal glider | No production art | Dustkite |
| Canvaswing → Windcut → Galeshear | Gale floodplain glider | No production art | Canvaswing |
| Preostmar → Oathfen → Oxbowarchon | Stone starter (Preston's, v2 prompts) | Concept and prompts; no art | Preostmar |
| Tallowroot → (Stage II unnamed) → (Stage III unnamed) | Bloom starter (restored 2026-09-29) | No production art; Stages II-III need names | Tallowroot |
| Cotterseed → Canopyvein → Floodcrown | Bloom floodplain shade | No production art | Cotterseed |
| Milletusk → Threshback → Gleanhorn | Bloom grainfield grazer | No production art | Milletusk |
| Masonsward → Thimblecomb → Combwright | Bloom pollinator-builder | No production art | Masonsward |
| Hushmire → Lullfen → Tarnreach | Hollow starter | No production art | Hushmire |
| Echolarva → Stillshade → Nullchorus | Hollow silence line | No production art | Echolarva |
| Mutecho → Unanswered → Unspoken | Hollow message mimic | No production art | Mutecho |

## Handoff for each approved image

Save the original output with creature name and view in `docs/HollowTide Sprites`. Compare the form and view with its roster brief: silhouette, head and identity anchors, stage growth, palette, right-facing front or true rear, one creature, and no toy-like treatment. Convert the approved source with `tools/convert_forge_sprite.py`, review its comparison, and import the transparent PNG at its *actual* logical grid. The official Vitrecrag uses 128×128; many other forms use 100×100. Keep original and game PNG separately, and record approval and battle-view status. Update this board after each import.
