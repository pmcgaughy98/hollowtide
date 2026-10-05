# First playable historic street, October 3, 2026

This world work was installed and verified before Preston's Coalcrest tail correction; it is preserved while his sprite feedback takes priority. The broad world objective remains to reach the quality of Nexomon/Coromon with Hollowtide's own St. Joseph inspired setting. This is a first playable historic block, not a complete downtown or finished game.

## Installed behavior

A separate cached 768x896 historic-street scene connects through a real north walking gate from the city riverfront. The return gate arrives on the riverfront's new grounded native-soil lane. The original hometown, courier hall, Route 1 and riverfront remain separately entered scenes. Actor scale and walking speed stay unchanged. Buildings use their existing original brick shop/ledger art; the camera frames their full roofs at the door. Fourteen varied existing cottonwoods fit completely inside the level, and their canopy fade works on repeat visits.

Native paving includes the street, front thresholds, central board plaza and a lower walking loop. Physical building/noticeboard footprints follow the artwork. The shop displays a clear current 18 and original lintel 6; the ledger plaque uses its own building surface. Fictional district names remain open.

The optional local activity compares the old lintel and current sign, checks the ledger, and returns to the existing riverfront clerk. Answer 6 receives a correction; 18 verifies the handoff and updates the cached board. Notes and contextual objectives reflect the activity. After verification, the original Route 1 objective returns so the hometown dispatcher report stays clear. The original assignment/report flags, controller, party and quest behavior remain; this adds scene-local state only, without a new disk-save or reward model.

Direct editor runs of the historic-street, riverfront and hometown scenes now enter the existing connected WorldJourney with the requested starting area. The editor's current run scene and original audio setting are preserved.

## Evidence

Both couriers completed ordinary-input full hall assignment / hometown / Route 1 / riverfront / historic-street / return / dispatcher / home journeys. Each had twelve actual gate crossings including repeat historic visits, zero test teleports, preserved cached areas/controller/party, appropriate full-vs-simple report flags, original notes/party panel behavior, front-facade collision and returning canopy fade. Both couriers passed the final plaque-layout city loop. The final objective and repeat-clerk reminder are checked in the male HUD loop. Three direct-scene entry checks pass with one active area and the original controller.

All final world logs are empty of stderr. The native 768x896 SubViewport overview and canopy-bound report are in review/final-render/. Earlier letterboxed/test frames remain historical evidence and are not used as the final art view. Scripts and full journey evidence are retained under source/ and review/.

The world patch changes four existing scripts. A later, separate Coalcrest correction changes its creature resource, explicitly recorded in the preservation audit; it is not part of city behavior. Every other file in the world baseline, including project launch/audio settings, remains exact.

## Exact runtime files

- scripts/world_journey.gd
- scripts/area_landscape.gd
- scripts/first_route_prototype.gd
- scripts/world_area.gd
- scripts/historic_street.gd
- scripts/historic_street.gd.uid
- scenes/historic_street.tscn
- assets/sprites/world/historic_street_2026_10_03/street_pavers.png
- assets/sprites/world/historic_street_2026_10_03/street_pavers.png.import
- assets/sprites/world/historic_street_2026_10_03/riverfront_north_lane.png
- assets/sprites/world/historic_street_2026_10_03/riverfront_north_lane.png.import

## Research, cost and remaining work

One actual Google Maps MCP query located the Missouri Theater public reference at 39.7659532, -94.8510362. It supports the historic venue/location context; Maps does not provide this fictional street geometry, building art or the renumbered-address activity. Public query/response evidence is preserved in review/.

[Google Maps attribution: Missouri Theater](https://www.google.com/maps/place//data=!4m2!3m1!1s0x87c01ba81644c9d7:0xff9946500be6e12a)

Prepared original assets and native materials were reused. No new artwork generation or Retro Diffusion charge: $0.00. No staging, commit, deletion or user-editor control. This street still needs believable frontage infill, residents, services/interiors and broader city identity. Other districts, complete hometown content, Route 1 final art/collision/ambience and save/reward integration also remain. Claude retains disk-save/state and battle architecture; Grok creature/move rules. Preston runs Gemini Deep Research; prepare prompts only when requested.
