# Title cleanup, Item Shop and Hall approach, October 9, 2026

Preston requested removal of title creatures, continuation from Home, and a wider Hall approach. The title now shows the village and lettering without the foreground Punchybun/Cinderhide sprites or their shadows. Original animation PNGs, lighting actor script and backups are retained. The inherited ambient/launch loop continues; New Game still opens the creature prologue.

Claude concurrently added the title theme. Creature removal was rebased onto his current file, retaining the exact music hookup and Options volume behavior. Both initial menu and current-with-theme originals are retained. The rebased native title smoke also checks the theme resource.

## Shop exterior proposal

One new transparent native 144x120 sprite: `assets/sprites/world/item_shop_2026_10_09/item_shop_native.png`. Moss/root roof and sandstone match Home and Hall; a muted red canopy shelters berries, lamp oil and stones. `scripts/town/item_shop_painter.gd` blends only within world (744,72), size 144x120. Door remains tile (33,7), native centre (60,108), opaque and dark. The existing shop service remains a description; purchases/economy are not built here.

One built-in imagegen call, generate mode, transparent background; zero Retro calls. Prompt is `generation-prompts.txt`, untouched generated source is `sources/shop_generated_original.png`. Technical alpha > 1 padding crop and nearest resize to the fixed footprint; alpha inside retained. No palette edit or creative Python edits. No existing asset replaced. Cost is not inferred without receipts. Installed Home/Hall inspected before generation; no external game assets/code copied.

## Hall approach correction

Preston: “the door for wayline hall isn't lined up with the path could just used widened.” The visible paving is now three tiles wide, x23..25 at y7..8, world (552,168), size 72x48. Its centre x588 matches the unchanged door tile (24,6). Tile x25 was already walkable grass. No layout/collision/door change, no Hall sprite edit. Joined paving can also change the two-pixel seam with Market Street at y216..217. Every pixel outside Shop and the bounded Hall apron/seam rectangle (552,168), 72x50, remains byte-exact. This cosmetic paving extension is recorded for Claude here; his canonical `PATHS` and controller are untouched.

## Verification

13 Shop native assertions pass: correct dimensions, replacement, bounded pixel preservation, immutable layout, doorway, determinism, real walking/E, facade and shared Finish. Six Hall assertions pass: exterior byte-exact, visible extension, already-walkable strip, real movement from it to approach, native E guild service and exact doorway. Title smoke confirms zero foreground actors/shadows, visible menu/title and New Game button opening the prologue. Removing Shop painter physically returns the exact wider-apron ground/Home/Hall baseline; the requested apron is independently retained.

Native captures reviewed: title, Shop service/overview, Hall wider approach. Overview captures use review-only camera and hidden HUD/labels; actual service captures use the game camera. Southern normal views can crop roofs as before. No runtime camera edit. Logs contain no script/resource errors; the pre-existing Windows certificate diagnostic remains. Live import/render verification and preservation hashes are recorded in final logs and `installation.json`. No full dungeon-clear claim.

F5 shows the title. F6 on `scenes/hub_town.tscn` shows the town. Face north from (33,8) and press E for Shop; (24,7) for Hall. Services/disk saves remain Claude's later work. Next exterior: Storage, then Scroll Keeper, one at a time.

Runtime scope: menu script removal, new Shop PNG/painter, small capture/hook and visual apron mask in the ground painter. Creature art, title art, Home/Hall, original backups, Claude dungeon/state and project settings are preserved. No commit, reset, revert or stash. Source-of-truth remains the hub-layout handoff and `town_layout.gd`.
