# Storage art proposal: standalone Godot preview

Open `project.godot` in Godot 4.7.2 and press F5. The main scene is `preview.tscn`, at exact 3x native art scale. Space toggles the existing Hall material shader; M shows the material mask; Esc closes. This project has no game Storage data, keeper, collision, door or panel hook. Its copied finish support files are exact snapshots of the game's current shader/helper.

Room proposal: 17x13 tiles at 24px, 408x312 native. North wall is 72px tall; side walls 24px wide; south threshold is three tiles wide. `placements.json` is the geometry contract for review, including draw rectangles/depths, a three-tile clear aisle, entry (8,12), counter approach (8,7), and suggested footprints. **All layout/solids/depths and actual hook decisions remain Claude's.** The counter top overhangs its proposed five-tile body footprint; Claude should confirm the foot-based collision in the game.

For integration, use `art/shell.png` plus `art/props/*.png` with the supplied placements and `art/detail-mask.png`/the existing 0.75 masked finish, or use `art/storage-raw.png` as the flat background plus that same mask. Do not add the props twice. `review/finished-native.png` in the outer evidence folder is a baked reference; if using a baked finished image, do not apply the shader again. Separate props allow Claude to preserve foot sorting around the counter and cabinets. The lamp assets are back-wall mounts.

The room has reusable supplies: herb/oil jars, cloth, scroll canisters, rope and crates. It contains no courier parcel stock because the current Storage service refuses parcels. Decorative stock is not an inventory preset.

The current live Storage remains at its door with its existing unlock, panel and data. The existing panel rectangle is `Rect2(166,64,820,160+40*max(1,rows.size()))`; this package does not relocate or redraw it. No keeper creature is proposed. No live game art or scripts are overwritten by this package.

Original imagegen outputs, exact prompts, Hall sources, preparation recipe, CPU/native GPU proof and the full handoff are in the parent evidence folder.
