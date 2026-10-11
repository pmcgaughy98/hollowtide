# Dungeon tile and Guildmaster desk finish — October10,2026

Implements Preston's seven terrain requirements in Rootbank Warren and the Hollow, including Claude's concurrent boss-free Hollow Mouth.

1. Quiet native24px floors; four very close material shades, two tiny broad wear shapes, no even speckle, diagonal streaks or scattered room pebbles. Root/stone clusters stay within outer tile margins beside walls.
2. Connected moss tiles with edge, convex corner and concave corner silhouettes. Eight neighbours select256 cases, reducing to47 meaningful grass shapes. No dithered dotted edges.
3. Neighbour-selected wall cap, bevelled lip and face. South face16px, side faces4px; inside diagonal corners expose stone/root height. Rootbank has clay strata and roots; Hollow valley has natural slate blocks; ruin has coursed masonry.
4. Upper-left light, shared material sel-out rim and0.55 bounded internal ink. No creature source, palette, portrait, fringe or shader changes.
5. Rootbank clay/root/moss; all Hollow looks share one slate/teal palette drawn from the installed entrance. Terrain atlases contain only24 named palette swatches. The shared rim derives darker hues from the selected material.
6. Unseen tiles are opaque `#080b0e` in a final world layer above effects, below HUD. Lantern reach, reveal, explored tiles and enemy visibility rules remain exact.
7. A restrained1px grid on24px floor boundaries, with low contrast and close floor variants.

Twelve PNG atlases and `scripts/dungeon/dungeon_tile_art.gd` are the actual authored runtime tile source. The three existing painters retain all original helpers and non24px fallbacks, including helpers used by Highbank. No generator, room topology, walkable cells, stairs footprint, encounter, movement, collision, story, save, settings or rule changes. The shared dungeon script changes only `_ready` and `_draw_fx`; the Hall changes only `_guild_desk` and the desk asset constant. Latest Claude Hollow Mouth definition and no-boss last-stair clear are retained.

Guildmaster desk: versioned192x52 transparent detailed furniture matched to the Hall. Original `desk.png`, preview and editable Claude renderer remain installed unchanged. Position168,70; depth116; row2 passage; solid rows3/4; dispatch spot remain exact. Native nearest crop preparation is in `prepare_desk.gd`. Built-in imagegen, one call; unmodified2172x724 output and [exact prompt](generated/PROMPT.md) archived. The interim flat code-rendered desk was reviewed and superseded by the detailed version; it is not installed.

Validation:26/26 native terrain checks, including palette/opacity, grass seams/corners, margins, wall height, unchanged data, deterministic seed and opaque unseen pixels over a high-z magenta effect. Actual Hall desk finish, size, depth and obstacle grid pass. Current native two-dungeon fixture passes rival crew, Blight/Drain Bite, Hollow valley/ruin, Warden pond scene and town routing. Final live verification and scoped hashes are recorded alongside this document. Headless trials produced renderer-only shader warnings and were superseded by native GPU checks.

Review images: [Rootbank](review/after/rootbank.png), [Hollow ruin](review/after/hollow-ruin.png), [Hollow valley](review/after/hollow-valley.png), [Guildmaster desk](review/after/guild-desk.png). Full native maps and pre-change captures are under review. Originals and the concurrent-source preinstall snapshot are archived separately. `visual-hooks.diff` and `manifest.json` document exact scope. [Primary reference ledger](research.md).

Keep installed seven-form refinements, darker jade Oxbowarchon, original backups, Starward portraits/fringe and Claude's concurrent work. Visual proposal is ready for Preston's review; no new lore or mechanics are approved by this art pass.

Final live GPU verification: terrain26/26; Guildmaster desk placement/depth/obstacle exact; three starter action/hurt/sleep animations pass; current rival crew, Warden pond and town routes pass without errors. Live Hollow Mouth is included in review/after/hollow-mouth.png. Scoped audit:21 installed files exact;3,198 protected source/art files exact;30,443 preinstall sprite hashes archived. No commits, resets, source PNG overwrites or gameplay changes.
