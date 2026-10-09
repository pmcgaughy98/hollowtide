# Riverfront quay district, October 8, 2026

Preston asked to continue upgrading the **playable world** using Firecrawl. This expands the existing city riverfront rather than the regional-map interface. New local names and dialogue are playable proposals, not approved canon.

## Play

Follow the existing levee bridge into the city. The quay board is just north of the bridge road, beside the keeper. Press **E** to read it. Open `scenes/city_riverfront.tscn` in Godot and use **F6** to preview the connected riverfront directly. Claude's latest project setting starts the arena/picker on F5; that concurrent setting is preserved. The existing story opening is available through `scenes/opening_flow.tscn` with F6.

Explore the promenade and timber landing, the courier branch court, the repair frontage, the dry-goods shop approach and the sheltered cuttings garden. The garden's west and east side openings are always walkable. A resident walks the branch lane, pausing near you and during menus; reduced motion keeps the resident still.

The optional quay walk asks for three observations, in any order:

1. Read the landing gauge at the end of the new timber deck.
2. Check the dry-goods shop's raised approach.
3. Speak to the cuttings keeper in the southern garden.

Return to the board. The keeper opens the garden's north gate, giving a short route back to the branch court. Repeat interactions do not duplicate progress. The existing north street, east relay road and west bridge remain available throughout; this side round is not required for the main delivery.

## Implementation

- `scripts/riverfront_quay.gd`: new local scenery, side-round state, physical gate and ambient walker. The current world scene cache retains observations and the open gate when leaving and returning.
- `scripts/area_landscape.gd`: attaches the district, adjusts planting and opens only the exact landing rectangle in the river collision.
- `scripts/world_area.gd`: includes the new sites in existing proximity hints and interaction dispatch.
- Ground surfaces use a shared texture grid across overlapping paths, avoiding rectangular seams. All textures are existing project art; no source pixel files were edited or generated. The bridge, ground, planted beds, wall, reeds, keeper and walking sheets retain their current source files.

No new quest manager, player/party rule, reward economy, save format or arena integration is introduced. Progress remains **run-local**. The new repair frontage is an exterior landmark; this slice does not add shop interiors or commerce.

## Verification and evidence

`native/check/` has the native end-to-end quay test, screenshots and its JSON results. Forty-four assertions cover real keyboard movement, all three observations (out of order and repeated), dialogue/map exclusion, each landing edge and solid water, closed/open gate collision, both garden side paths, cache persistence, every real city exit and return, unchanged party/delivery flags, ambient movement and reduced motion. The existing first-morning test also passes 45 assertions with female courier/Tallowroot, checking shared hometown behavior and story-based partner selection. The isolated test project explicitly starts the opening scene; this does not claim the current live F5 setting starts the menu. Exact result counts and hashes are recorded in `installation.json`.

`native/before/` and `native/after/` contain engine-rendered overviews and normal 3x views of the arrival, landing, branch, garden and shop. The overview zooms out for layout review; it is not the normal play camera. `originals/` preserves both changed live scripts, and `logs/` retains final runs and earlier errors caught during the review. The final quay and overview runs retain the Windows certificate-store diagnostic but have no script errors; opening diagnostics are reported in the installation record rather than suppressed.

`tools/debug/riverfront_quay_check.gd` is repeatable with the existing `first_morning_check.gd` input helpers. Default output goes to this archive's `rerun/`; a path after `--` overrides it. Testing used a separate D:/dev project and isolated profile. No active editor session or live save data was used.

## Sources and preservation

[Firecrawl source ledger and implementation rationale](../../research/riverfront-world-references-2026-10-08.md). The archive retains successful scrape/search receipts, including the Nexomon page's limited coverage. These are product-structure references, not a claim to have examined complete games.

The seven-form refinements, dark-jade Oxbowarchon, original/palette backups, Galeshear wing repair and Listener palette pass are hash-checked. Creature pixels, front idles, menu art, current launch setting, Route 1 controller, arena, party and save code are unchanged by this installation. Claude's concurrent combat/anchoring changes are preserved; world checks do not certify that separate combat work. No commit.
