# Wayline Hall exterior proposal, October 9, 2026

The second Highbank art slice, following Claude's hub-layout handoff and Preston's “go.” A dedicated moss-roofed stone-and-root guild exterior replaces only the existing Hall block. Amber round windows and lanterns connect it to the approved creature-village menu. This is an implemented exterior proposal for Preston to review, not new canon or a completed guild service.

## Installed

- One native 240x144 transparent PNG, `assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png`.
- One small `scripts/town/wayline_hall_painter.gd` that restores the existing ground under alpha corners and blends only within the Hall's fixed footprint.
- A short hook in `scripts/town/highbank_ground_painter.gd`. No town controller, camera, layout, path, door, collision, service rule, creature, menu, prologue, save or dungeon edit.

The footprint is exactly (456,24), 240x144; the existing door remains tile (24,6), local (120,120), with its centre inside the dark entrance. The first generated entrance was too far right, so a second imagegen call corrected the front portal before native preparation. Source PNGs and both prompts are archived untouched. Nearly invisible outer padding was cropped using alpha > 1 bounds; all alpha inside the crop was retained; nearest-neighbour preparation provides the native canvas. No palette edit, creative Python image edit or old sprite replacement. Two built-in imagegen calls, zero Retro Diffusion calls; no dollar cost is inferred from unavailable receipts.

## Verification

13 native assertions pass: exact native dimensions; Hall rectangle visibly replaced; every pixel outside that rectangle byte-exact to installed ground; immutable collision/layout; entrance centre opaque and dark; repeatable rendering; real movement to approach and exact door; native E key through the current controller opens the existing guild panel; facade neighbours blocked; shared creature finish remains. With the optional Hall painter physically absent from the isolated review copy, the previous ground/blockout picture returns byte-for-byte.

The source, prepared PNG, full town picture, normal approach/service native captures and full-building native capture were inspected. `hall_overview.png` uses a review-only camera composition and hides labels/HUD to show the whole exterior. `hall_approach.png` and `hall_service.png` use the actual game camera. Normal camera scroll can crop the roof near the southern approach, as in the existing layout; the camera was not changed.

Final native logs contain no script/resource errors; the existing Windows root-certificate diagnostic remains. This slice does not certify a full dungeon clear. Prior town-loop testing is retained in the ground archive, and its controller/state/dungeon files were not edited here.

After installation, Godot imported the new PNG in the live project using an isolated user profile. A headless check then loaded the actual installed texture and town painter: native size and the complete rendered map match the reviewed map byte-for-byte. Imported cache metadata is maintained by Godot; no old source art was replaced.

Run F6 on `scenes/hub_town.tscn`, or New Game through the creature opening. Walk north from Market Street to the Hall's steps, face north, and press E. The current guild panel remains Claude's service description; jobs, roster rules and disk saves are later work. Other buildings remain blockout.

## Handoff

Authority: `docs/world/hub-layout-2026-10-09/README.md` and `scripts/town/town_layout.gd`. Visual references inspected: installed `creature_village_2026_10_09.png` and prior `dispatch_hall_complete.png`; no old artwork overwritten. No external game code, images, maps, text, music or numbers copied.

Next art slice: Home, exactly 120x120 at (72,72), door tile (5,7), then the shop/storage/scroll buildings one at a time. Keep the native 24px scale, creature-village architecture and dark material outlines. Preserve Claude's service/state ownership. No commit, revert, reset or stash.
