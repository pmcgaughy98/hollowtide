# UI pass: one look from title to town to dungeon (Claude, 2026-10-10)

Preston: "Do U.I upgrades and visuals... including from main menu to town to battle everything", then "make small square portraits for the creatures next to their name" and "we want headshots like mystery dungeon, facing us but pointing to their right".

## What the tour found (`tools/debug/ui_tour_capture.gd`, windowed; stills here)
Two UI languages: Codex's title and pause menu (moss panel, brass edge, Alegreya Sans SC, readable) beside the dungeon and town HUDs (bare boxes, Silkscreen at 8 to 11 px, unreadable at 1152x648), a control line printed over the top wall, a near-empty log box.

## What changed
- **`scripts/ui/ui_style.gd`**: the shared look, taken from Codex's pause menu: panel, gauge, text, coloured-name lines (Explorers of Sky colours names in its log).
- **Dungeon HUD** (`_draw_hud` in `dungeon.gd`), laid out like Explorers of Sky: floor and lantern top left; the team beneath with a headshot, name, level, IQ, health and the evolve sliver; the bag and orders inside that panel; the moves two by two at the bottom left; a bordered message box with your creatures' names in blue and wild ones in coral; a short key list at the bottom right (the full list stays under Menu, Controls); the boss bar, the banner, scene dialogue, the join question, the bag and the learn/teach panel all on the shared look at 14 to 22 px.
- **Town HUD** (`hub_town.gd`): a Highbank panel with the place you stand at, signboard plaques behind the place names, the place panel without the "BLOCKOUT" note.
- **Headshots** (`tools/arena/build_portraits.py`): a 48 px square for every form, cut from its own three-quarter sprite turned to its right (sw) round the head; heavy-shelled and dark forms (the Ironvent, Vitrecrag and jade lines, Tallowroot) use the front. Crops were placed by eye and checked on `portraits_sheet.png`. Shown in the team panel and on the pause menu's TEAM page.

## Not changed
Codex's title, opening and pause menu look (already the source of the style), the town's ground and buildings (Codex's art job), the arena's own fight HUD. Drawn Mystery Dungeon portraits with expressions are still Codex's portrait job; these crops stand in until then.
