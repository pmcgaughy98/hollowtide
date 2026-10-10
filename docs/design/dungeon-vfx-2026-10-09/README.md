# Move effects in the dungeon (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Upgrade skill animations and VFX with the synthesis."

## Structure (nothing copied)
- **Explorers of Sky:** each move has the user's animation, an optional projectile, an effect on the target, and a screen effect.
- **Rescue Team DX:** a shake on strong hits, a short freeze on a heavy hit, a flash on a super-effective one, and the move's name over the user (built earlier as `_callout`).
- **Into the Breach:** the one acting is made visible, so a creature winding up glows.

## What is built (`scripts/dungeon/dungeon.gd`)
- **The art:** the arena's own 35 painted Retro Diffusion effect sheets (`assets/sprites/arena/vfx/`, 16 frames each). No new art was paid for.
- **`MOVE_FX`:** each dungeon move's projectile (`proj`, flies down the line), hit effect (`hit`, on each target) and area effect (`area`, where a burst lands), chosen by what the body does.
  - Examples: Ember Shot flies as a lantern ball and bursts as fire; Seed Pod lobs a pod and erupts roots; Rake and Pounce slash; Needle Bite splashes; Shear cuts with a sail slash.
  - A move not listed uses its essence's burst (`ESSENCE_FX`). A shot without a painted projectile flies as a dot in its essence colour.
- **On a strong hit** (super effective, ambush or pincer): screen shake, a short freeze (0.08 s) and, if super effective, a white flash. An ordinary hit gets a small shake.
- **A slam:** slam shock and rock dust at the wall, and a bigger shake.
- **A dash** leaves three fading afterimages.
- **A wind-up:** besides the red tiles, the creature gathering glows in its move's essence colour.

## Check (`tools/debug/dungeon_vfx_check.gd`)
| Move | Result |
|---|---|
| Ember Shot | the lantern-ball projectile, then fire on the Tallowroot, shake 2.5 |
| Rake | the light slash, shake 2.5 |
| Ember Feint (a one-tile dash) | 3 afterimages into open floor; fire when it hits a creature beside it |
| Seed Pod | the pod projectile and the root burst |
| A wind-up | the glow under the creature gathering |

Stills are in this folder. The partner's Seed Pod and the wind-up glow fell outside the crop; the check's printout confirms them. Every other dungeon check still passes.

## Open
- **New painted effects** (Preston topped up Retro Diffusion) are only worth it where the library lacks a fitting sheet; none is missing today.
- **The next visual step** could be per-creature attack animations for more lines, as done for the starters.
