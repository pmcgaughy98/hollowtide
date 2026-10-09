# World map and the first morning — October 8, 2026

Implemented for Preston's world-refinement request and his correction that a starter must be obtained through a story in the world. Story wording and the courier-square label are playable proposals, not approved canon.

## Play it

Press F5, choose New Game and a courier. You enter the hometown without a partner. Follow the street signs east or open **M** for the regional map; the courier hall is pinned. Walk into its front door, speak to the dispatcher, collect straps at the right-hand sorting shelves, then meet Kithflare, Tallowroot and Rimefin around the room. After meeting all three, revisit the one you want and invite it. Escape/Keep looking leaves the choice open. Collect the existing sealed pouch from the dispatcher, leave the hall, and follow the east road onto the levee.

The three partners use the already-approved front idle animations. Portrait resources and source pixels remain unchanged. Ownership begins only on invitation; there is no hidden fallback starter in New Game. Direct world-scene previews retain their existing fallback behavior.

**M** opens/closes the seven-area route map. Escape also closes it. It shows current location, visited areas and nearby connections, allows a destination pin, and gives the next real exit to take. The physical square notice also opens the map. It does not fast-travel. Dialogue, party/notes, transitions, battles and relay practice block map opening; map input blocks underlying interactions and walking.

The hometown has a planted paved square, a map board, clearer lane signs and planting around the original homes and hall. Existing doors, the shared-garden planting activity, the levee and city connections remain in place. All world art is composed from existing textures.

## Verified

- Three complete native opening cases cover all starters and both courier appearances; 45 assertions each, including cancel without party loss, no premature starter, actual movement through the town and hall gates, every meeting, reversible invitation, actual party ownership, existing assignment and real levee departure.
- Nineteen navigation assertions cover the early departure gate, all seven scenes, discovery, distant destination routing and party identity.
- The extended existing relay check covers sorting, wrong/correct choices, actual entry/return, current arena practice, both Escape returns, cached state and map exclusion/restoration.
- Native screenshots and JSON results are in `native/`; final per-case counts and the exact tested combat hash are recorded in `installation.json`.
- Tests use a separate D:/dev project and user profile, Godot 4.7.2 Compatibility rendering, and actual input/movement. The active editor was not used as a test fixture.

The current project launch setting is preserved, including Claude's switch to `scenes/opening_flow.tscn`. Both that scene and the existing menu-art preview use the revised opening wrapper. The approved menu base scripts and artwork remain exact. The legacy opening check now delegates to the first-morning check; historical evidence for the earlier menu-based choice remains in its original archive.

## Boundaries

No save system or campaign/arena recruitment bridge is added. Party, first-morning progress, map discovery and pins are run-local. Existing Route 1 battle/controller code, party rules, creature data, arena code, builder/slicer tools and project settings are preserved. Native logs retain the Windows certificate-store diagnostic and world shutdown ObjectDB warnings; results are not represented as a clean engine-wide diagnostic run. Current concurrent VFX/chain/Listener/Canvaswing changes were inspected and refreshed into the final test snapshot; later changes remain outside its validation boundary.

The seven protected forms, dark-jade Oxbowarchon reference, originals and the existing front-idle assets were checked before installation. Galeshear's separately requested wing repair is archived independently.

[Firecrawl observations and implementation rationale](../../research/world-references-2026-10-08.md). Originals, research receipts, reproduction scripts and installation hashes are retained beside this file. No commit.
