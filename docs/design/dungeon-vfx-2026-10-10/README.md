# Dungeon VFX pass and the Growth Shrine (Claude, 2026-10-10)

Preston: "evolution scene then vfx pass", and evolving happens "outside dungeon at a specific location".

## Evolving at the Growth Shrine
- In the Hollow a teammate that has its level and conditions becomes ready ("Take it to the Growth Shrine in Highbank") and stays itself; nothing evolves mid-run.
- At the Shrine (`hub_town.gd` `_shrine_panel`, `evolve_at_shrine`) it asks; yes plays `scripts/ui/evolution_scene.gd` (structure from pokeemerald's evolution scene and Explorers of Sky's spring, nothing copied: the old form glows, turns to light, old and new silhouettes trade faster and faster, a flash, the new form in colour with the evolution jingle) using the big front idles, then `scripts/town/evolution.gd` applies Grok's move rules on the record. A move that did not fit waits in `pending_learn` and is offered at the start of the next run.
- Stills: `docs/ui/ui-tour-2026-10-10/13_evolution_trade.png`, `13_evolution_reveal.png`. Check: `tools/debug/evolution_check.gd`.

## VFX
- Every hit: sparks and a widening ring in the move's essence colour (all twelve essences, the new four included; their bursts borrow the nearest sheet until they get their own).
- A super-effective hit: more sparks, a white ring, a longer hit-stop (0.13 s; a pincer or ambush 0.09 s).
- Damage numbers the Mystery Dungeon DX way: they pop up, overshoot and settle, outlined in near-black; super effective is bigger, orange, with "!"; weak is grey; heals are teal.
- Seep ripples; healed creatures shed rising motes; a level up raises gold motes and a ring; ready-to-evolve raises purple motes; a faint leaves a puff of dust.
- Stills: this folder (`tools/debug/vfx_capture.gd`).
