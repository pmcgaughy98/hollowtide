# Tile structure reference ledger

Used Firecrawl skill search and scrape to inspect primary SkyTemple dungeon-tileset documentation. Structure only: no borrowed game assets, code, room layouts, numeric tuning or palettes.

- [SkyTemple Dungeon Tileset documentation](https://wiki.skytemple.org/index.php?title=Dungeon_Tileset): describes native24px terrain tiles and adjacency rules for ground, walls and special terrain. Used to confirm that walls should choose a consistent cap/face shape from neighbours.
- [SkyTemple DTEF specification project](https://github.com/SkyTemple/skytemple-dtef): describes rule-based import/export and256 adjacency combinations. Hollowtide independently implements eight-neighbour selection and collapses irrelevant grass diagonals into47 shapes. Source art and rendering code are original to this project.

Palette reference: installed Hollow entrance painting `assets/sprites/world/waking_bank_2026_10_10/entrance_native.png`. Desk reference: approved `assets/sprites/world/hall_interior_2026_10_10/hall_native.png`; design target: Claude's original `assets/sprites/world/guild_desk/desk.png`.
