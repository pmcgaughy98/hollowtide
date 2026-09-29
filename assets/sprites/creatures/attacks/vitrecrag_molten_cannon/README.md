# Vitrecrag Molten Cannon (attack-sheet protocol, 2026-09-28)

Ember (fire) essence. Built by `docs/attack-sheet-protocol.md` from Preston's Opal sheets in
`OneDrive/Documents/HollowTide Sprites/Effect Sheets/Vitecrag Effect/` (originals untouched):

- `Molten Cannon Animation/` sheets 1 to 4 (cannon1 to cannon4)
- `Molten Beam Attack Animation/` sheets 1 to 4 (beam1 to beam4). Preston dropped Molten Beam and said to reuse
  what fits the cannon.
- `Vitrecrag Project Effects/Molten cannon Projectile(Optional).jfif` and `Vitrecrag effect Sticky Bomb.jfif`
  (projectile, explosion, particles), cut to `assets/sprites/effects/vitrecrag/molten_cannon/`

Research read for this build: `Pixel Art Combat Animation Pipeline Research` and the monster-taming animation
research (earlier the same session), plus `RPG Move Animation Scaling` (shared body poses plus effects). Summer
MCP was connected (editor debugger used the same session).

## Cutting

`tools/cut_vitrecrag_cannon_sheets.py` cuts every cell on each sheet's own layout (sheet 1 has black cell
borders and uneven cells; sheets 2 and 4 use only the top two-thirds). Each cell converts at its own block so
the body matches the approved front's measured body height (89 rows by the same measure). 48 frames in
`frames/`. `tools/build_vitrecrag_molten_cannon.py` snaps, clears crumbs and registers the chosen frames on a
148x128 canvas (in-game sprite at x+10, same centre) into `built/`.

## Every frame

Facing right in all frames. "Scale" compares with the in-game front (122x93).

| Frame | What it shows | Beat | Decision |
|---|---|---|---|
| cannon1_f00 | Idle, mouth flame | rest | reference (sheet 1 drawn smaller than sheet 3) |
| cannon1_f01 | Head in, collar ring opening | anticipation | reference |
| cannon1_f02 | Core bright, head in | charge | reference |
| cannon1_f03 | Core bright, head in | charge | reference (near duplicate of f02) |
| cannon1_f04 | Glowing orb in collar, rear exhaust flame | release | reference; rear exhaust is a good idea for later |
| cannon1_f05 | Core bright, mouth flame out | recovery | reference |
| cannon1_f06 | Core dimmer, mouth flame | recovery | reference |
| cannon2_f00 | Idle, mouth flame | rest | reference |
| cannon2_f01 | Head in, core bright | charge | reference |
| cannon2_f02 | Big orb in collar | charge peak | reference |
| cannon2_f03 | Bigger orb, faint magenta edge on it | charge peak | reference |
| cannon2_f04 | Head in, core dim, no flame | spent | reference |
| cannon2_f05 | Core dim, smoke curl at collar | follow-through | reference |
| cannon3_f00 | Idle, mouth flame | rest | **keep: rest** |
| cannon3_f01 | Head in, legs spread wide, flame still out | brace | **keep: brace** |
| cannon3_f02 | Head in, legs wide, core brightening | charge | **keep: charge** |
| cannon3_f03 | Fire swirling in the core window | charge | **keep: swirl** |
| cannon3_f04 | Core blazing | charge peak | **keep: blaze** |
| cannon3_f05 | Core dark, smoke curling from collar | spent | **keep: spent** |
| cannon4_f00 | Idle, mouth flame | rest | reference |
| cannon4_f01 | Head in, core medium | charge | reference |
| cannon4_f02 | Core swirl | charge | reference |
| cannon4_f03 | Smoke venting from the shell top, core dim | follow-through | reference; strong idea, other scale |
| cannon4_f04 | Fireball bursting from the collar | release | reference; came out undersized (fireball skews the height measure) |
| cannon4_f05 | Smoke wisp at mouth | recovery | reference |
| beam1_f00 to f04 | Idle to charging core, mouth flame | rest, charge | reference |
| beam1_f05, f06 | Core flaring white | charge | reference |
| beam1_f07 | Core flare with glow, white-hot mouth wisp | charge peak | reference; good overheat read |
| beam1_f08 | Idle | rest | reference |
| beam2_f00 to f02 | Beam sheet 2: idle and beam jets | release | reject: beam jets |
| beam3_f00 | Idle, mouth flame | rest | reference |
| beam3_f01 | Legs wide, core bright | brace | reference |
| beam3_f02 | Fire kindling in the open collar | charge | **keep: kindle** |
| beam3_f03 | Fireball formed in the muzzle | loaded | **keep: loaded** |
| beam3_f04 | Beam jet | release | reject: beam |
| beam3_f05 | Core relit, last smoke at collar | recovery | **keep: vent** |
| beam4_f00 to f03 | Idle and spent, tiny ember at mouth | rest, spent | reference |
| beam4_f04 | Thin beam | release | reject: beam |

## Final timeline

Only cannon sheet 3 and beam sheet 3 are used: they are drawn at the same scale, so there is no size jump
between poses, and after the height fix they match the in-game sprite (123 to 130 wide, 91 to 95 tall; brace
is 135 wide because the legs really spread).

| # | Frame | Source | Hold | Code |
|---|---|---|---|---|
| 0 | rest | cannon3_f00 | 0.08 | |
| 1 | brace | cannon3_f01 | 0.35 | brace tremble; mouth fire gasps into a heat aura |
| 2 | charge | cannon3_f02 | 0.14 | overheat climbs toward 0.72 |
| 3 | swirl | cannon3_f03 | 0.20 | |
| 4 | blaze | cannon3_f04 | 0.20 | |
| 5 | kindle | beam3_f02 | 0.14 | |
| 6 | loaded | beam3_f03 | 0.30 | held anticipation |
| 7 | spent | cannon3_f05 | 0.14 | FIRE: muzzle blast at (48, 14), shell launched, 4 px recoil, shake 30, heat flare |
| 8 | spent | cannon3_f05 | 0.26 | shell in flight |
| 9 | vent | beam3_f05 | 0.30 | HIT: explosion on the target |
| 10 | vent | beam3_f05 | 0.20 | back to idle |

Effects: `vitrecrag_cannon_muzzle.tscn` (explosion bomb_f01 at the muzzle, flame spray, smoke), 
`vitrecrag_cannon_shell.tscn` (segmented fireball proj_f00, flame trail), `vitrecrag_cannon_blast.tscn`
(explosion bomb_f01, flame burst). The yellow starburst (proj_f01) is not used: it is the cartoony style
Preston flagged. All particles draw at 3 screen px per art pixel.

## Open

- Finish: frames keep the known slight darkening and faint magenta edge; Codex's style-match pass
  (`tools/retouch_vitrecrag_attack_finish_2026_09_28.gd`) has not been run on them yet.
- Awaiting Preston's review in play.
