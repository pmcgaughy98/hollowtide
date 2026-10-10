# Wayline Hall finish, October 10

Second town-finish slice: Hall, following the completed Home / Item Shop. Purposeful buildings use near-black internal outlines at Preston's direction. The existing coherent October 10 PNG, side windows, silhouette and original backup art stay untouched.

## Installed

Hall is a separate Sprite2D using the installed building_detail_finish shader, with dark window/mullion, root/roof and stone contours. Ground-coloured bottom-right contact band, broken foundations and ground-green grass overlap anchor it to the terrain. An original three-route waymark plaque identifies the guild (visual proposal). The existing label hook removes Hall's floating plaque; other labels remain.

One animated paired-leaf door spans the existing two-tile entrance. `buildings["hall"]["frames"][0..2]` are closed / ajar / open. Either entrance or approach activates the same panel-driven animation; Esc closes it. Source arch mask preserves the coherent masonry and side windows. No hookup work remains for this door. Existing sound, guild response and controls are unchanged; no new interior/guild gameplay is claimed.

Runtime scope: building_exteriors.gd and wayline_hall_painter.gd, plus collaboration-note prepend. No asset/shader/controller/layout/path/camera/settings/title/creature/state/rule/UI edit. Exact world footprint (456,24), size240x144, door tiles(23,6)/(24,6), steps Rect2i(23,7,2,2). One-tile Home/shop rendering defaults retain identical output.

## Verification

26 native checks: actual shader output adds interior ink in both window regions and whole-building interior; correct sprite size/position and centered two-tile mask; three distinct nonempty drawings share the source shape; actual walking/native E from both entrance tiles and both steps, guild/sound, ajar/open/closed; Home/shop foundation/sign and six door drawings byte-exact; every ground pixel outside Hall and the two-pixel contact band exact, paved steps below that band exact.

Physically missing new Hall PNG / import metadata check in the isolated review checkout confirms exact historical fallback artwork, retained finished Home/shop and both usable Hall tiles. Original sources restored before installation. Final main native check has no script/resource errors (review checkout's existing certificate diagnostic remains); fallback fixture left a small shutdown resource warning, with no production cleanup change claimed.

`review/hall_exterior.png` is a native1152x648 capture with fixture camera framing for the complete Hall. `hall_service_23.png` / `hall_service_24.png` use the production camera. No production camera change, natural dungeon-clear or disk-save claim.

Guarded before-hash installation and originals snapshots preserve concurrent edits. No imagegen/Retro call, copied game assets/code or commit. All original assets and prior archives remain untouched. Reproduction scripts and exact install/preservation manifest accompany this file.

Installed live verification: all 26 checks plus hub_town_check and hall_door_check pass, with clean final live logs. Captures in review/ are from the installed live game. Claude's concurrent party-screen redesign and UI-tour additions were retained; no code from the isolated review checkout replaced those files.

## Next

Storage, then Scroll Keeper / remaining services, then decoration. Preserve near-black internal detail contours for purposeful buildings and quieter background treatment. Claude owns guild gameplay, interiors and state/rules.
