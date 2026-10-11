# Job Board finish and Home interior art

Preston requested sel-out on the enlarged Board, then the interior handoff; he clarified that the rooms need finished art matching the town and creatures, beyond block furniture. This slice finishes the Board and Home's art. Wayline Hall retains Claude's exact painting and is the next interior art task. No additional room or game systems are claimed built.

## Board

New transparent 96x48 native stand, four separate cream notices with line marks/seals, carved warm root timber, rope and brass joints, restrained moss. The full purposeful-building detail ink and selective outer rim are the installed shared town finish. Native 1x art gives the same pixel weight as the buildings. Canvas centre remains (648,168); original opaque contact row remains the original Board's measured foot y, using offset (-24, original_used.end.y - display_used.end.y). Original 48x24 PNG is untouched and falls back at its prior 2x scale if new art is absent/invalid. Source padding is measured rather than assuming the canvas bottom. Same z, contact shadow, logical layout, reading tile (26,8), Hall doorway/sign clearance, original ground and all three reading-feedback drawings. Job/request/payout systems unchanged.

## Home

336x240 native room at the original 14x10/24px grid. Original room layout reference and our approved Home exterior were the only generation references. Detailed rooted bed, moss cushion, embroidered folded cloth/pillow, limestone hearth/fire/kettle, rooted table, map/lantern, carved shelves with jars/scrolls, dense clover/fern, woven rug, timber/stone walls and warm quiet plank floor. Top-left daylight and warm fire light. The original south door drawing (165,216,30,24) is restored exactly in the image, retaining its real exit.

HomeRoomArt uses the existing shared masked terrain shader at its normal 0.75 detail ink on bounded furniture and walls. The finish does not modify walking floor/rug/exit. All room definitions, blocked tiles, interaction names/text, team/follower motion, camera, controls, return position and state methods are verbatim. A three-line Home-only art hook in room_painter and two-line map-finish hook in town_room; Hall unchanged. Missing Home art returns the exact original code painter. The room still has Claude's existing interaction behavior; no saving, healing/day cycle, dispatch, roster or persistence system has been added by this art task.

## Preparation and checks

Built-in imagegen two calls, zero Retro. Original generations and exact prompts saved. Godot nearest-neighbour normalization only: Home 1484x1060 ->336x240; Board ->96x48 preserving transparency. Shared finish is applied at runtime; no shared shader modified. Initial code-detail-only Home and Board prototypes were rejected as too block-like and are retained locally as development history, not installed.

Native Godot 4.7.2/NVIDIA Compatibility: 11 finish comparisons cover source/fallback preservation, Hall image exact, Home dimensions/door, actual GPU mask output (walking floor/rug/exit exact), Board centre/foot/native pixel weight, Hall clearance and real E/Escape reading feedback. All five Home and nine Hall interactions reached by real grid walking and E; both exits return to original building. Current Claude hub and full job rescue/recovery/return/payout checks pass. Missing-art check verifies exact original Home painting and original enlarged Board. Test profiles/output paths are isolated from player settings/saves. Review sandbox logs contain the Windows certificate-store warning. Early fixture/type/format diagnostics were corrected before installation; the legacy town_room_check assertions passed but its exit cleanup warning is retained. Final live verification is recorded below.

## Preservation and handoff

Only Board painter, two Home presentation hooks, one new Home art module, two sibling PNGs and collaboration note. Originals/candidates and active-file hashes archived. No source art replacement, creature palette/animation/body edit, shared shader change, layout/path/collision/rules change, title/menu/settings edit, commit/revert/stash. Concurrent edits are guarded and retained. Art is implemented for Preston's visual review; approval is not claimed.

Next: detailed Wayline Hall art at Claude's same 22x14 grid (dispatch counter, notice wall, roster, pillars, benches, charts/reports and parcels), with the existing job API when systems are expanded. Launch-frame handoff job8 and creature sel-out A/B choice remain open.

## Final live verification

All five installed native live runs pass with clean final logs: 11/11 finish checks, all 14 room interaction spots reached by walking and real E, both room exits, hub's 12 service interactions, full Board rescue/recovery/return/payout loop and installed native captures. No user profile/save changes. All seven installed paths match reviewed candidate hashes. 10261 protected active files and all 9715 original active asset files match the baseline. 5 concurrent changes retained and snapshotted; Claude added pilot-story job12 in the handoff while this task ran, left intact. Prior collaboration body remains verbatim.

Installed views: [Board](review/live/board.png), [Home at entry](review/live/home.png), [Home north](review/live/home-north.png), [unchanged Hall](review/live/hall.png). Original source and exact prompts are in original-generation/ and home_prompt.txt / board_prompt.txt. Whole Home and Board source assets are siblings, never replacements for old sources. Every published archive file is hashed in publication.json.

Next art slice: Wayline Hall. Late story job12 and launch pixel frames remain open; see the current Claude handoff before choosing subsequent work. Preston's visual approval is not claimed.
