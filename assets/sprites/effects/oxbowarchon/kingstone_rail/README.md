# Kingstone Rail projectile art

Cut on 2026-09-29 from Preston's `Kingstone rail projectile 1-4.jfif` (OneDrive `Documents/HollowTide Sprites/Effect Sheets/Oxbowarchon Effect/`), using `tools/cut_effect_sheet.py`. That tool splits sheets by their grid lines, or by the magenta gaps when a sheet has none. Every piece is on the 8-pixel drawn grid, the same density as the creature art. Crumbs (orb2_p08, orb2_p09, orb3_p06) were deleted, and pink bleed was cleaned with `tools/clean_spill.py`.

Preston's direction: the sphere gathered between the rails is the projectile, full of energy. It replaces the jade spike and slug.

**Used by** `scenes/effects/oxbowarchon_sky_rail.tscn` (script `scripts/effects/sky_rail_strike.gd`):

| Beat | Piece | What it is |
|---|---|---|
| Omen | drawn in code | a jade pixel ellipse spreading on the ground under the target as the ball comes down |
| Meteor | `orb4_p09` | ball with a flame trail above, falling straight down from the top of the screen over 0.5 s, 4x, with afterimages, burning brighter as it lands |
| Impact | drawn in code | full-screen white-green flash (3 steps), a column of light from the sky narrowing over 6 steps, stone and jade debris, an aftershock shake |
| Impact | `orb1_p07` starburst with cracking orb, then `orb2_p06` bloom swelling 3x to 4x | 3x |
| Shockwave | `orb1_p08` | two rings spreading 3x to 7x by whole sizes and fading |
| Core | `orb3_p10` | the burning core left where it hit, fading last |

Sizes changed 2026-09-30 (Preston: signatures are ultimate moves and the hit has to look it).

**The rest are a library** for other moves or variations:
- more charge-ups: `orb1_p00`, `orb3_p00`;
- orbs;
- rising and falling comets: `orb1_p05`, `orb1_p06` diagonal, `orb2_p03`, `orb2_p05`;
- rings.

**Changed the same day** (Preston): the separate launch orb (`orb1_p03`) and the re-gathering overhead (`orb2_p00`, `orb4_p00`, `orb4_p01`) were removed. The frames already show the sphere leaving, and the re-gather read as the orb teleporting there and vanishing. The ball now comes straight down onto the target. Those pieces stay in the library.
