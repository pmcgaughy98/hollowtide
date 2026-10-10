# Highbank Home exterior proposal, October 9, 2026

The third hub art slice follows Preston's “go”: a cozy moss-roofed root-and-stone home for the creature team. One round amber window and a doorway lantern carry the installed Wayline Hall and village menu materials into a smaller building. This is an implemented visual proposal, not new lore or a completed sleep/save service.

## Installed and runnable

- `assets/sprites/world/home_2026_10_09/home_native.png`, native 120x120, transparent corners.
- `scripts/town/home_painter.gd`, restores native ground and blends only inside Home.
- Small Home ground capture and optional painter hook in `scripts/town/highbank_ground_painter.gd`. Existing Hall composition is retained.

Claude's footprint is unchanged: world (72,72), size 120x120. Door remains tile (5,7), local (48,96), centre (60,108), inside the dark entrance. No door, collision, layout, path, town controller, camera, menu, creature, dungeon, state or project-settings edit.

F6 on `scenes/hub_town.tscn`, or New Game through the creature opening. Home is the initial spawn landmark. Face north from tile (5,8) and press E to open Claude's existing Home description. The description mentions sleep/save; those systems remain unimplemented here.

## Generation and preparation

One built-in imagegen generation call, transparent background, zero Retro Diffusion calls. Final prompt is in `generation-prompts.txt`. The untouched source is in `sources/home_generated_original.png`. No previous sprite was replaced. Technical alpha > 1 padding crop and nearest-neighbour resize to the exact footprint; all alpha inside the crop retained, original source untouched. No creative Python image edits or palette changes. Dollar cost is not inferred without receipts.

Inspected installed Hall, menu village and old human Garden Home before generation; the new asset follows the current creature village architecture. No external game assets or code were copied.

## Verification and review

13 native assertions pass: art/map dimensions, visible replacement, every pixel outside Home byte-exact to installed ground (including Hall), immutable layout/collision, opaque dark doorway centre, repeatable rendering, actual movement to approach/door, native E input opening the Home service, solid adjacent facade, shared creature finish retained. With Home painter physically absent from the isolated copy, the previous ground/Hall picture returns byte-exact. Final logs have no script/resource errors; the existing Windows certificate diagnostic remains.

`review/home_approach.png` and `review/home_service.png` show the actual game camera. `review/home_overview.png` is a native engine capture using review-only camera (0,-24) and hidden labels/HUD to display the whole building. The normal southern approach crops the roof as the existing camera scrolls; no runtime camera changes. `town_before.png`, `town_after.png` and the native surroundings crop are retained.

Live import and map comparison are recorded in `installation.json` and final logs after installation. This slice does not certify a full dungeon clear. Existing town loop and service ownership remain with Claude. Source backups and checks are retained here; no commit, reset, revert or stash.

Next: Item Shop at its existing 144x120 footprint, then Storage and Scroll Keeper, one at a time. Authority remains the hub-layout handoff and `scripts/town/town_layout.gd`.
