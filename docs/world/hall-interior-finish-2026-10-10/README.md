# Wayline Hall interior finish

Preston approved Home and the Job Board, then requested the same detailed finish for the other interiors. This slice finishes Wayline Hall, the other currently wired room. Shop, Storage, Scroll Keeper, Training Yard and Growth Shrine still use Claude's existing service panels; no new room systems are claimed built.

## Installed art

528x336 native pixels, original 22x14 room at 24px per tile. Detailed limestone wall and flagstone floor, warm carved dispatch counter, notice/roster panels, banners and wall lamps, quiet teal central runner, masonry pillars, full ferns, long carved benches, chart/compass table, report/scroll table, parcel stacks. Dark internal outlines and material detail match the approved Home and purposeful town buildings. Existing masked dungeon finish at 0.75 detail ink; no shared shader change. Furniture and walls are masked; walking floor, runner and exit remain exact relative to the raw composite.

The twelve freestanding props are alpha-composited at Claude's original pixel rectangles: four 22x46 pillars, two 24x32 ferns, two 20x70 benches, two 48x42 tables and two 44x26 parcel stacks. The background has clear floor underneath these, so there are no patches over generated furniture or moved blocked tiles. Original south exit drawing (261,312,30,24) is restored from the original painter exactly. Rooms, events, solid tiles, party/followers, camera, UI, text, controls and return behavior retain every original method byte-for-byte apart from two Hall-only presentation branches.

Seven new sibling PNGs and one Hall art module; two two-line branches in room_painter.gd and town_room.gd; collaboration note. Approved Home/Board modules and art are unchanged. Missing background or any prop restores the exact original Hall painter. No dispatch, roster, saving/resting/day system, rules, numbers, title/settings, commit/revert/stash or legacy human room changes.

## Sources and preparation

Built-in imagegen four calls, zero Retro. Our own Hall exterior, original Hall layout and approved Home art were the references. First whole-room and alignment generations did not reliably place furniture on the existing grid, and are retained as rejected source history. Installed art uses the selected floor-only generation plus the selected transparent six-prop atlas. Original sources are in original-generation/; the four exact prompts are hall_prompt.txt, hall_alignment_prompt.txt, hall_floor_prompt.txt and hall_props_prompt.txt. Original exterior/approved Home references and original layout snapshot are retained.

Godot native preparation only: floor 1573x1000 ->528x336 with nearest sampling; source atlas 2172x724 split into six bands using alpha gaps, cropped to visible alpha >0.5 to exclude nearly invisible padding, then fitted by nearest sampling to original prop rectangles. Transparency retained. Generated drawing was edited only through imagegen. Exact scripts/source paths and logs archived; no Python painting, source asset replacement or existing PNG edit.

## Checks and handoff

17 native finish checks: approved Home pixel-exact, Hall dimensions, original exit drawing exact, twelve prop sizes and actual GPU masked detail with unmasked floor/runner/exit exact. All five Home and nine Hall interactions reached through actual walking and E; both exits return correctly. Missing floor and missing chart tests each reproduce the original Hall painter byte-for-byte. Review sandbox logs contain a Windows certificate-store warning unrelated to the art. Final installed native proof and preservation audit follow below.

Before and after room views in review/before/ and review/after/. Full native finished room in review/hall-finished-native.png. Home and Board visual approval recorded from Preston; this new Hall art is ready for his review. Existing shared source/backups, seven-form refinements, Oxbowarchon jade, Sparkwick correction and Claude's concurrent code remain protected by active-file hashes and guarded writes. No worktree resets or commits.

Home and Hall now both have finished interior art. Future new interiors should use the same finish after their service/door/event layouts exist. Remaining launch pixel-frame job8, pilot waking job12 and guild system expansion stay in the current Claude handoff; do not infer them completed from this art slice.

## Final live verification

Installed native Godot runs pass with clean final logs: 17/17 finish checks including actual GPU output; all 14 Home/Hall interaction spots reached by walking and real E; both exits; five installed Hall captures. Profiles and outputs are isolated from the player's save/settings. All 11 installed files match reviewed hashes. 10270 protected active files and all 9717 original active asset files match the baseline. 2 concurrent active changes retained and snapshotted; prior collaboration body verbatim.

Installed views: [entry](review/live/entry.png), [middle aisle](review/live/middle.png), [counter](review/live/counter.png), [chart](review/live/chart.png), [roster](review/live/roster.png). [Full native finished room](review/hall-finished-native.png). Published source/candidate/original/proof files are verified in publication.json. Final checks did not edit player saves or source gameplay systems. Visual approval is pending.
