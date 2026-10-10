# Highbank finish: Home and Item Shop, October 10

Job 0, first pair in Claude's town finish brief. Preston's refinement: purposeful buildings need near-black internal outlines, including windows and architecture; background decoration should remain quieter.

## Installed

- Existing original PNGs as separate Sprite2Ds at the exact layout positions and sizes. Original silhouettes and palettes preserved.
- Building detail shader based on the unchanged creature house finish. Shared outline colour/weight plus internal dark-side contours; no blur or source-pixel replacement.
- Contact shadows falling bottom-right, broken foundation stones, ground-green grass overlaps, earthen approaches joining the existing street, threshold steps and an original shop bag sign.
- Procedural closed / ajar / open door textures, masked to each original opening. Opening/closing follows the existing service panel (E/J/Enter and Esc), without delaying or changing rules/sound. Frames are `buildings[id]["frames"][0..2]`; no hookup remains for this pair.
- Only the finished pair's old floating plaques removed. Existing service labels elsewhere stay.

Runtime files: `scripts/town/building_exteriors.gd`, `building_detail_finish.gdshader`, `home_painter.gd`, `item_shop_painter.gd`, and two small optional hooks / label skip in `hub_town.gd`. No act_use/state/layout/camera/UI/style/title/creature change.

## Verification

28 native assertions in finish_check.gd: rendered internal black-pixel increase, sprite placement/size, visible distinct door drawings, actual walking and key E from both approaches, same services/sound, intermediate/open/closed frames, and every ground pixel outside bounded Home/shop footprints plus shadows/aprons unchanged. Screenshots are 1152x648. Exterior captures manually frame the whole building in the fixture; service captures use the actual production camera.

Physically absent exterior module check restores the old entire map byte for byte, safely removes the optional view, and leaves Home usable. Existing hub_town_check: no overlaps, all reachable, all 12 ordinary services answer, walking/following and dungeon entrance remain. hall_door_check: both old Hall door tiles/steps remain usable.

Review editor import retained existing Windows certificate / stale review audio UID diagnostics; native final checks have no script/resource errors, only the pre-existing certificate warning. One intermediate run had a transient shutdown resource warning; final finish check was clean. These are presentation/route checks, not a natural dungeon-clear claim.

Installed live verification: all 28 checks, hub and Hall checks pass with clean final logs. Native previews in `review/` are from the installed live game. `layout_full.png` is now the ground layer from the old static painter check; the real building sprites are visible in the native exterior/service captures.

Preservation audit: 9,238 unowned pre-install files remain exact. Claude's concurrent dungeon helpers, essence/item icons, shared UI additions, new PartyScreen and pause-page integration/checks were retained. All pre-existing asset files match the task-start hashes. No prior backup archive was targeted.

No generated art, imagegen/Retro calls, borrowed game code/assets, settings edits or commit. Original PNGs, original scripts, palette locks and prior archives preserved. Five runtime files plus a collaboration-note prepend are installed with before-hash guards; all other protected files audited separately. Installation/audit JSON contains exact scope.

## Next

Wayline Hall, preserving its October 10 coherent art and two-tile doorway. Then remaining services, then decorative buildings. No new interiors, sleep, disk saves or economy in this slice; Claude owns those systems. This art treatment is implemented and native-reviewed, awaiting Preston's visual review.
