# Hollowtide opening chapter: production path

**Working plan, 26 September 2026.** This is a sequence for building the first playable journey, not a new canon decision. Preston's current directions, `THE_CONCEPT.md`, and the living [world bible](world-bible.md) govern design choices. The [AI handoff](AI_COLLABORATION.md) records shared ownership.

## Target

A player can take one Wayline assignment, travel the river route, observe the missing return mark and optional clues, battle or capture a creature, choose an owned partner, report what they actually found, and leave with a reason to visit the far bank. The existing battle impact feel and the six-essence, three-stage creature structure remain intact.

This opening is deliberately one finished local loop. The 20-line, 60-form roster is the wider game target, not a prerequisite for the first chapter.

## Current foundation, checked in project files

- `scenes/main.tscn` is still the project start scene. It contains the existing player, Dex overlay, field creature, encounter trigger, battle screen, and party switch.
- `scenes/first_route_prototype.tscn` is a separate courier route. Its script has dispatcher, marker, relay post, river and height-post interactions; Field Notes; party selection; and two report outcomes. A visible Cinderhide field encounter already lets the player battle or capture during this route. It is not yet the start scene.
- `scripts/battle_screen.gd` has attack motion, hit stop, effects, capture, battle-win evolution for the approved Cinderhide line, an original river-landing study, stage focus motion, and continuous HP bars under the Main HUD art. The latest name and HP header layout has not yet been viewed in a fresh battle.
- `scripts/player_party.gd` owns individual party slots, but `scripts/party_member.gd` currently stores species only. Individual HP, level, experience, and save data are still future systems.
- All nine Ember forms have linked fronts and backs. Eight backs are approved matching views; Ironvent uses Preston's existing side-facing back provisionally, pending an in-battle review. Vitrecrag's approved front and rear use 128×128 native grids. Rimefin's legacy sprite is due for a Forge redraw. The [production board](sprite-production-board.md) tracks one approved image at a time.

## Build order

### 1. Finish the current battle presentation

Use the next normal battle viewing session to judge the revised name headers, exact HP fill, creature ground contact, opponent distance, and camera focus timing. Keep the battle impact sequence Preston likes. Record any concrete visual fault, then adjust only the affected placement, scale, or timing. The HUD layout and newer font pass are ready for that review; neither has been reviewed in a played battle after installation.

### 2. Close the first route as a single journey

Walk the existing assignment from dispatcher to post and back, including both available report choices and the optional height marks. Review the Field Notes and party panel during that journey. Repair actual navigation, input, dialogue, or visibility problems in `first_route_prototype` before expanding its terrain. The placeholder landmarks may be replaced by approved original assets from Grok's asset lane; their current positions establish route meaning.

Once the loop is readable, make the reviewed route the normal start of the game. Preserve `main.tscn` as a recoverable prototype reference rather than discarding its battle, Dex, or party behavior.

### 3. Make one complete creature line feel owned

Keep the approved Cinderhide → Clinkerhide → Ironvent resource links and the existing four-move choices for each Ember form. The next systems design should specify when one owned creature retains HP and progression between encounters, when it evolves, and what a battle win changes. Claude leads the state model and scene relationships; Codex can implement the exact resource and UI edits after the rules are settled. Preston chose guards and interruptions for River Listener's eventual move kit; the [defensive move rules draft](defensive-move-rules-draft.md) records the combat extension that will be needed. Do not infer links for other draft lines from artwork alone.

Preston's Forge workflow supplies creature art. Review the linked provisional Ironvent back in battle, then review Rimefin's redraw and its next two stages one form at a time. For each Stage II and III prompt, attach the immediately previous approved sprite so anatomy and palette carry through. Keep original Forge output, converted game PNG, and approval status separate.

### 4. Build the next habitat only after the opening holds together

The [far-bank repair day](far-bank-slice-draft.md) is a proposed second loop: compare a raised track and lower cut, record two listening points, post a provisional route warning, and return. It should become a scene only after the first route has been played and refined and Preston approves its working place names and story direction. A Tide encounter can wait for approved creature art. Neither route should assert an unverified cause for a real flood.

### 5. Expand with repeatable rules

After two local loops work, establish reusable route interaction, field-note, encounter, battle-result, and save structures before copying them into a larger map. Add creature lines toward the 20-line target in habitat order, with one-to-one three-stage links and brief-led four-move identities. Extend the region only when a new place gives the player a distinct ecological, social, or traversal reason to visit.

## Decisions and handoffs

- **Preston:** approve or revise the names Highbank, Siltward Reach, Old Ferry Ward, and Wayline Compact; review the new HUD in play; approve each Forge image; decide how much uncertainty the flood story keeps.
- **Grok:** source or create non-creature assets and provide dimensions, rights, and integration notes; continue firsthand research with direct links and clear firsthand versus rumor labels.
- **Claude:** lead the party progression/save architecture and changes to serialized scene trees.
- **Codex:** make guarded local Godot edits, keep code and asset references consistent, and update this plan when the implemented state changes.

The first route and battle review are the immediate dependency. Draft names, real-world research leads, and unreviewed generated art do not become playable canon by appearing here.
