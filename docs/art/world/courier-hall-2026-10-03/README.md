# Playable courier hall, October 3, 2026

Installed: walk up through the hometown hall doorway, speak to the dispatcher inside, read a single wide courier board or inspect sorting shelves, then walk out through the south doorway. The original assignment/report methods, live route controller, HUD, music and party remain in use. No new save, reward, inventory or quest model.

Preston asked for the three small upper-left posters to become one wide board. The final native room uses one wooden frame with cream route slips. Its generated white margin and extra wall posts were discarded during precise compositing; existing sage plaster was reused behind it. All pixels outside the board mask remain exact. The counter foreground is a native crop of the inspected original room, allowing the clerk to stand behind it while the courier stays in front. Solid shapes follow desk, racks, walls and the south doorway. The indoor camera frames the complete room at 2x; player/prop native sizes and walking speed remain unchanged.

## Exact game files

- scripts/world_journey.gd
- scripts/world_area.gd
- scripts/area_landscape.gd
- scripts/courier_hall.gd
- scripts/courier_hall.gd.uid
- scenes/courier_hall.tscn
- assets/sprites/world/courier_hall_2026_10_03/courier_hall_native.png
- assets/sprites/world/courier_hall_2026_10_03/courier_hall_native.png.import
- assets/sprites/world/courier_hall_2026_10_03/counter_foreground.png
- assets/sprites/world/courier_hall_2026_10_03/counter_foreground.png.import

## Verification

Both couriers completed ordinary-input assignment, delivery, city, return, marker repair, report and home trips. Eight real entrance transitions per full trip include two hall entries/exits and the four existing area gates. Male full report retains all eleven flags; female direct report retains seven required flags with four optional observation/report flags false. Same cached hall, home, route controller and active party member; one live area and one starter. Counter/house/sidewall collision, note/party freeze and release, board/sorting read-only behavior, and return canopies pass.

After the board finish, both couriers independently passed real doorstep entry, reading notices, assignment, counter collision, exit, cached hall re-entry and return home. Final board frames are in review/final-board-check; full-world trips are in review/final-trip. Final runtime stderr files are empty. Headless editor import shutdown warnings are retained separately. Initial 3x scrolling room frames and the first board delivery remain preserved.

Preservation audit: 2,120 of 2,123 recorded existing asset/data/script/scene files remain byte-identical. The other three are the targeted world scripts listed above. Coalcrest's separately authorized resource edit changes only its front texture path. Existing player, menu, quest controller, battle/rule/save scripts and original source art remain exact. No staging, commit, deletion or user-editor control.

## Google Maps MCP

One additional live official MCP search located the Pony Express Museum public place reference. Returned coordinates: 39.7561682, -94.8486314. This supports regional courier-heritage research only; Maps did not provide this fictional room's layout or artwork. Geometry and the hall design are original game work. Exact query and MCP response are in review/maps-query.json and review/maps-response.json.

[Google Maps attribution: Pony Express Museum](https://www.google.com/maps/place//data=!4m2!3m1!1s0x87c01a54e827d44f:0x9f792b3e117cc2b5)

## Art provenance and cost

Retro Diffusion RD Pro topdown room task 6a75a856-ed95-4a21-af4e-170ead62ae07: $0.18.
User-requested wide-board inpainting task 50d0db2c-dcbf-498d-af14-c267e631998e, inference inf_Oeo37pmvZnj04GERVeEq5PBxJXdRLYKV: $0.18.
Exact prompts, original outputs, input/mask PNGs, sanitized receipts, composite audits and installed hashes are retained. No private references were uploaded for the text-only room generation. The board edit uploaded only its prepared room-wall crop and mask. Maps billing total is not established here.

This completes a usable hometown interior slice, not the broader world. Route 1 foliage/collision/ambience and hometown/city identities, services and districts remain in development. Fictional names stay open. Claude retains disk-save and reward/state ownership. Preston runs Gemini Deep Research; prepare prompts only when requested.
