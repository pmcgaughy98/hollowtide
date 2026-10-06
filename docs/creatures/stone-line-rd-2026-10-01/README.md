# Preostmar and Oathfen redo (2026-10-01, candidates, not in the game)

Preston: Oxbowarchon is perfect, but Preostmar and Oathfen did not look like they evolve into him (old Preostmar: light brown slab with mint crystals; old Oathfen: bright teal dome, nearly upright). Redone backwards from Oxbowarchon with Retro Diffusion: Oathfen used Oxbowarchon as its reference, Preostmar used both.

- **Preostmar:** compact young stone creature; dark cracked hide with emerald light, small jade-and-emerald cluster on the shoulders, one gold gem, wedge-tipped tail. No rails.
- **Oathfen:** Oxbowarchon's build, smaller: craggy jade armour mountain with gold gems and the emerald; the rails lie folded flat along its back as a green band.
- Back views (back three-quarter facing up-right): Preostmar rotation cell 6, Oathfen cell 3. No clipped edges on any front or cell.
- Neither creature has game data yet (no `.tres`): stats, moves and dex numbers are Preston's to set. The old art is untouched.

## In the game, provisionally (2026-10-05)

Preston asked to add the line "for now". `data/creatures/901_preostmar.tres` and `902_oathfen.tres` use `preostmar_front_pad_192.png`/`preostmar_back_192.png` and `oathfen_front_pad_192.png`/`oathfen_back_192.png` (copied to `assets/sprites/creatures/stone_line_2026_10_05/`; the pad fronts share the backs' pixel scale). Preostmar evolves into Oathfen, Oathfen into Oxbowarchon; `CreatureRoster.validate_evolutions` passes. Default 60 stats, no moves (Strike), no body parts, `battle_size` 1.8 (2.5x zoom: about 215 px and 330 px tall against Oxbowarchon's 385). Job, numbers and kit are Grok's to set.
