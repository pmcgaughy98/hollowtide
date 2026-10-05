# Hometown tended garden, October 4, 2026

Installed and checked in the native engine: two timber planting beds, cultivated rows, continuous soil aisles, a distinct garden neighbor and an optional visible planting activity. Speak to the neighbor at the northwestern edge, then interact from the southern side of the right bed. Its three rows appear; the neighbor and notice acknowledge the work. Repeating interactions adds no duplicates. Rows remain in the cached hometown when returning from another area. The original notice interaction site (448,608) stays; its visible foot is moved to (472,594). Home text now correctly places the dispatcher inside the courier hall.

This is a bounded world improvement. Hometown, the full city and the Nexomon/Coromon-level world objective remain unfinished. Dialogue and shared-cuttings activity are prototype proposals. Activity state lasts in the live scene cache during the session; it does not add disk saves, inventory, rewards, healing or progression. Claude retains save/reward/state and battle ownership; Grok creature/move rules.

## Resident art, approval and cost

The first two text-only garden-neighbor candidates both clipped their hat crowns. Both originals remain under generation/. A top-only outpaint of the first candidate completed the crown. Automatic approval initially rejected uploading this non-public image; the user explicitly approved that exact upload and one $0.18 edit, and it then succeeded. No approval is pending.

Only 20 new crown pixels from the result are used, mapped to the original hat palette. The original body RGBA is restored exactly before native resizing. Generated false checker pixels in the new margin and 1465 changes to the existing image are excluded. The resulting resident is 17x30 visible pixels on a 21x34 canvas, matching courier height. The earlier workshop-keeper stand-in remains in prepared/garden_neighbor_standin.png. [Crown/body provenance](neighbor-completion.json), [independent audit](preservation-audit.json).

Four text-only RD Pro generations cost $0.72: bed, cuttings row and two neighbor candidates. The separately approved hat edit cost $0.18. Actual total $0.90; balance after completion $2.40, credits 50. Exact prompts, sanitized receipts and all candidates are retained. No reference images were uploaded for the four text-only requests.

## Exact game changes

Four existing files changed:

- scripts/world_area.gd: routes the new local garden interaction.
- scripts/area_landscape.gd: replaces tiny garden tufts, moves the existing notice and adds its small foot solid, relocates one shrub and the label.
- scripts/first_route_prototype.gd: exactly two home dialogue strings locating the dispatcher inside the hall.
- scenes/hometown.tscn: adds the garden component.

Ten new runtime files: scripts/hometown_garden.gd and its UID; four PNGs (timber_bed, cuttings_row, garden_lanes, garden_neighbor) under assets/sprites/world/hometown_garden_2026_10_04/, each with import metadata. [Fourteen exact paths and hashes](runtime-manifest.json). 2,191 of 2,195 baseline runtime files remain exact; four expected changes, none missing or unexpected. Current menu, creature art/resources, party, battle/move rules, original journey/entrances and launch/audio settings remain exact.

Beds preserve their 54x50 native silhouette with 2px transparent padding; cuttings preserve 38x18 pixels. The soil pass changes 384 interior furrow pixels using original palette colors, including 33 grain accents; timber, alpha and exterior pixels remain exact. Garden lanes reuse the existing 16px soil tile in phase with the original streets, including the final east join.

## Evidence and limits

Both male and female full ordinary-input journeys passed with the earlier keeper stand-in: completed_walk true, terminal exit 0, 12 actual walking-gate transitions, correct respective final flags, no test teleports or quest overrides, and zero runtime stderr bytes. Garden refusal before offering, three visible planted rows, repeat idempotence, resident acknowledgment, perimeter/central aisle, solid bed borders, original controller/flags/party/species/known-move/objective/board/notes state and cached return artwork were checked. Male completes all observations/report; female retains the simple report. [Full journey proof](proof/walk/retry1/), [fixture](proof/hometown_neighborhood_walk.gd).

Fresh final-asset checks then loaded the exact installed neighbor and final lane join for both couriers. Both pass 134 ordinary movement steps, 2 real hometown/hall gate crossings, foot collision on first and cached visits, complete garden interaction/perimeter/aisle/border checks, and unchanged original eleven flags, party, objective, board, notes, speed and scene/controller identities. Repeated planting and return retain exact row nodes/textures/positions. Both terminal exits are 0; final runtime stderr is empty. These final garden checks do not claim a second full twelve-gate journey. [Final exact-asset proof](proof/final-garden/), [fixture](proof/hometown_garden_final_walk.gd).

Initial evidence is invalid: a fixture assumed the auto-named collision shape's name, stopped early and recorded misleading pass fields. It is preserved under proof/initial-failure/. The corrected fixture finds shapes by type and requires full completion plus successful final capture. Historical importer UID/audio-bus and ObjectDB shutdown diagnostics remain in separate logs; final render and walk stderr are empty.

[Final native map](render/garden-final-hometown-native.png), [final detail](render/garden-final-detail.png), [actual planted garden](proof/final-garden/male-garden-planting.png). Independent visual review found the hat complete, resident texture/scale/contact plausible, plants rooted and east path join continuous. Repeated plant rows and a tiny grass notch below the sign, around x466–481,y602–608, remain minor visual limitations. These do not establish a finished hometown or final user aesthetic approval.

Originals, prior candidates, before/after runtime files and receipts are saved. The portable art builder is under rebuild/; its four-file byte comparison passed and is recorded in rebuild-check.json. Complete W evidence remains at C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-garden-2026-10-04/. No staging, commit, deletion or user-editor control.

## Continue the full objective

Honor new user sprite/menu feedback first. Continue hometown identity through varied house frontages and purposeful enterable spaces/services; the three houses still reuse one model. Broader fictional city sectors, richer Route 1 foliage/collision/water/ambience, exploration/encounters, cross-area readability and eventual save/reward integration remain. Current main menu and latest Coalcrest hidden-leg correction are preserved. User runs Gemini Deep Research; prepare prompts only when requested. No current blocker; do not mark the complete world goal achieved because these garden checks pass.
