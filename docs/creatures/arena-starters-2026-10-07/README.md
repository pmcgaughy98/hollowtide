# Arena starters (Claude, 2026-10-07)

Preston pivoted Hollowtide to a 2D top-down arena fighter (reference: the "Pokemon Arena" fan game video, `docs/research/arena-comparison-2026-10-07/`). First piece: arena sprites of the three current starters and a walkable test arena.

- **Sprites:** Retro Diffusion `rd_pro__default`, 96 px, two takes each from the current fronts ($1.08); Preston picked all three take 2s. Kithflare's take came with a blue square background, removed by flood fill. Each was turned into 8 directions with `rd_advanced_animation__rotate` ($0.30). RD balance after: $0.36.
- **Facings:** `tools/arena/slice_rotations.py` cuts each 3x3 sheet into `assets/sprites/arena/<name>/<s|se|e|ne|n|nw|w|sw>.png`. The sheets are not labelled, so the cell for each facing was read by eye; Kithflare and Rimefin share one layout, Tallowroot another. Kithflare and Rimefin had no clean east frame, so east is their west frame mirrored.
- **Arena prototype:** `scenes/arena_prototype.tscn` (`scripts/arena/arena_prototype.gd`). Arrows or WASD move the selected starter in 8 directions, keys 1/2/3 switch starter, and the other two turn to watch. No walk frames yet (a one-pixel bob), no attacks. Checked with `tools/debug/arena_capture.gd`: facings east, southeast, north and northwest all pick the right still (`arena_prototype_captures.png`).
- **Known:** Kithflare's take 2 holds a burning rock in its hand; its lantern tail tip is still lit. The rotation frames vary a little in detail between facings.



## Second pass, same day: closer to the reference (`arena_gameplay.mp4`)
- **Arenas:** two RD `rd_plus__topdown_map` backgrounds at 384 x 216 ($0.06 each, `tools/arena/rd_map.py`): a grass stadium pitch with a crowd, and a ruined stone arena. Shown at 3x. Copies the game loads: `assets/backgrounds/arena/`. Key M switches.
- **Scale:** the reference keeps creatures small and their pixels as chunky as the arena's. `tools/arena/downscale.py` shrinks every sprite to a third, keeping hard edges and colours (each 3x3 block becomes its most common colour), so creatures and map share one pixel grid at 3x.
- **Walking:** RD `rd_advanced_animation__walking`, 8 frames, five facings per starter ($0.14 each, 15 total, `tools/arena/rd_walk.py`); the other three facings are mirrors. `tools/arena/build_small.py` cuts, shrinks and mirrors them.
- **Attacks** (code only, Space): Kithflare a fireball with a spark trail that bursts and scorches the ground; Rimefin a short river-water pressure beam; Tallowroot a lobbed seed pod that bursts into earth and leaves. Hits flash the target and knock it back, with screen shake.
- **Checked:** `tools/debug/arena_movie.gd` (Godot `--fixed-fps 30`) records a scripted play-through frame by frame; walking in all directions, all three attacks, a fireball hit on Rimefin and the arena switch play with no script errors.
- **Spent this pass:** $2.22 (walks $2.10, maps $0.12). RD balance about $3.14.
- **Known:** walk frames came out slightly taller and thinner than the stills (most visible on Kithflare walking south). One RD sync call dropped and `rd_creature.py`'s recovery picked up the wrong job (nothing was charged); new jobs go through queued scripts instead.

## Third pass, same day: a real match, signatures, crowd, evolved forms (`arena_match.mp4`, `arena_stages_captures.png`)
- **Match:** you against a rival line (T switches it). The rival keeps its attack's range, circles, turns to face you and fires when lined up, with slower cooldowns than yours. HP and a signature meter per side in the HUD; landing hits fills your meter faster than taking them. At 0 HP the loser tips over and fades, with a win banner (R rematch).
- **Signatures** (`scripts/arena/arena_signature.gd`, K when the meter is full): the fight freezes and a giant close-up of the attacker's battle art slides across with the move's name, as in the reference, then the effect lands. Each line uses its existing signature and sounds: Stormlantern (three lightning strikes, then the lantern core falls in a fire blast), Root Rampart (roots tear across the ground, then a wall of roots erupts), Undertow (a whirlpool drags the target round, then a water spout bursts up).
- **Crowd and arena:** crowd pixels shift as people move and the stands bounce while the crowd cheers (hits, signatures, a win); dust puffs behind walking creatures; scorch marks fade after a few seconds. Hit, faint and attack sounds reuse the existing effects.
- **Evolved forms:** Sparkwick, Stormwick, Huskward, Rampartroot, Riftfin and Scourmaw as arena sprites (one RD take each from their fronts, $0.18; Scourmaw's first take came back blank from background removal and was redone with local removal), turned into 8 directions ($0.10 each). Stage 2 is generated larger than stage 1 and stage 3 larger again, so they grow in the arena. F and G switch your and the rival's stage. These have no walk cycles yet and bob a pixel while walking.
- **Provisional numbers for Grok** (top of `arena_prototype.gd`): 100 HP; fireball 10, beam 14, seed 12, signature 30 damage; each stage +25% HP and +20% damage; meter +18 per hit landed, +10 per hit taken.
- **Checked:** `tools/debug/arena_movie.gd` and `tools/debug/arena_stages.gd` (Godot `--fixed-fps 30`): three matches with all three signatures and a win, evolved-form matches, and a stage 3 Stormlantern dealing 42 to a 150-HP Scourmaw. No script errors.
- **Spent this pass:** $1.86 (six forms $1.26 including the blank Scourmaw, rotations $0.60).
- **To finish the evolved forms:** walk cycles, five facings each, 30 x $0.14 = $4.20.

## Evolved-form walks (after Codex's colour pass)
- 30 RD walk cycles, five facings for each of Sparkwick, Stormwick, Huskward, Rampartroot, Riftfin and Scourmaw, generated from Codex's colour-fixed facings at each form's own size ($4.20; `rd_walk.py` now uses the source size). The other three facings are mirrors.
- Locked to each form's approved palette with Codex's `tools/arena/normalize_arena_palette.py --forms <six forms>` (output to a scratch folder, then only the walk sheets copied in). Raw RD sheets kept in `walk_raw/`.
- Walk-frame brightness now sits inside each form's still range (e.g. Stormwick stills 81-87, walk frames 82-87). `arena_evolved_walks.mp4` (`tools/debug/arena_evolved_movie.gd`): three evolved matches, walking full circles so every facing plays; no script errors. RD balance after: $2.08.

## Visual upgrade from the reference (2026-10-07, `arena_vfx_v2.mp4`)
Studied the "Pokemon Arena" reference frames at full resolution (beam clash, flamethrower, smoke, impacts) and matched its look:
- **Pixel-true rendering:** the fight renders at the map's own 384 x 216 in a SubViewport and is shown at 3x with no smoothing, so every effect, line and puff lands on one chunky pixel grid (the reference's smoke and fire are low-resolution too). HUD, move names and close-up cards stay full resolution.
- **Effects restyled:** fire as chains of outlined blobs (dark red rim, orange body, yellow core); water beams as two twisting white-cored streams with foam and a shock ring at the tip; impacts with a white flash, a thin ground shock ring, speed lines and sparks; big hits crack the floor, leave a scorch with small flames, and throw up a rising, drifting plume of smoke.
- **Painted impacts:** four RD `rd_animation__vfx` sheets ($0.28: fire, water, earth, electric; `tools/arena/rd_vfx.py`), shrunk to half by `tools/arena/slice_vfx.py`, played once under the coded flash on fireball, jet, seed pod, club slam, root snare and Wick Bolt hits.
- **Checked:** `tools/debug/arena_vfx_check.gd` (staged effects) and the role matchups; no script errors. RD balance after: about $6.80.
