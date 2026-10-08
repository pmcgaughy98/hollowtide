# The Vitrecrag line in the arena (Claude, 2026-10-07, late)

Fusern, Slagglass, Vitrecrag: the Ember kiln line ("Ember kiln, then armour, then the cannon"; six legs and a shell; no claw moves; Molten Glass is the ultimate, per `docs/creatures/DESIGN_RULES.md`).

## Art
- **Takes:** `tools/arena/rd_arena_sprite.py` from the fronts in `assets/sprites/creatures/rd_material_match_2026_10_01/`, at 96, 112 and 128 px ($0.54). All three came out faithful at the first take: Fusern's cracked lava shell and single eye, Slagglass's ridged plates and six long legs, Vitrecrag's crater dome.
- **Eight directions:** `rd_creature.py rotate` ($0.30); all three sheets in Tallowroot's layout, read cell by cell (`slice_rotations.py`).
- **Walks:** `rd_walk.py`, five facings each, the other three mirrored ($2.10). All fifteen succeeded first time.
- **Spent:** $2.94. Retro Diffusion balance after: $10.92 (Preston topped up on 2026-10-07; it would have been about $0.92). **Codex:** these three need your palette lock, as the Ironvent line did; `normalize_arena_palette.py` still lists only the first nine.
- Raw takes, rotation sheets and receipts: `docs/creatures/arena-starters-2026-10-07/forms/` and `walk/`.

## In the arena
Key **5** picks the line (F for its stage); the picker has a fifth column. Kits are drafted from the line's own turn-based moves, nothing invented (**Grok:** every number is a draft):
- **Fusern:** Ember Pellet (10, range 90).
- **Slagglass** (1.1x HP, 0.9x speed): Glass Spur (13, close), Furnace Shard (12, range 100).
- **Vitrecrag, ARTILLERY** (1.25x HP, 0.7x speed; holds about 100 px, backs off from anything close, otherwise stands still): **Plate Lunge** (14, close, a shove that carries the target), **Molten Cannon** (16, range 150, a lob of molten glass that carries whoever it lands on; 0.5 s area telegraph), **Molten Beam** (12, range 120, a short bright pour). Passive **Kiln Heat**: the crater heats while it stands (full in about 2.2 s), cools at half that while it walks; a hot shot does x1.4 and spends the heat. The HUD shows heat under its meter like Ironvent's Stoke.
- **Signature, Molten Glass** (from the turn-based ultimate's buildup and rupture, and its sounds): the arena dims to kiln light, the crater brightens from orange to white, steam jets from the seams of the shell, then the shell ruptures: a column of molten glass bursts up and arcs onto the target, shards scatter wide, and glass rains down round it. The target takes the signature damage; everyone else inside the rain takes a third and is slowed a moment ("Glassed").

## Check (`tools/debug/arena_vitrecrag_check.gd`)
- Kiln Heat reached 41 after 2.5 s in a live match (the artillery walked to range first); cold Molten Beam 17, hot 24.
- Molten Glass in a 3v3: the rival Stormwick took 49 and the rival Scourmaw in the rain took 32.
- AI 1v1 against Rampartroot: lost in 18 s, 160 dealt to 188. A first draft; the balance pass is Grok's.
- Stills here: `line_stage1..3.png`, `glass_*.png`, `match.png`. No script errors.

## Known
- Molten Beam first drew in the water beam's blue (and splashed blue on hit) and the cannon lob flew as a seed pod; all three recoloured to molten orange the same evening. Checked: `match.png`.
