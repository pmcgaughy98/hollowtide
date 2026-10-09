# Manual control, the movement model and the camera (Claude, 2026-10-08 night)

**Preston:** "How do we make the movement and combat more dynamic like the 2D arena video?" Then: "do 1 and 2" (the movement model and the camera), and in the same hour: "you control the creature you select before battle. So if it's more than 1v1 you choose one of the creatures to control before battle." That last line replaces the 2026-10-07 decision that the AI did all footwork; the player now steers.

## Controls (in the fight)
| Key | Does |
|---|---|
| WASD / arrows | steer your creature |
| J | basic attack, held to keep attacking the target in reach |
| Space | dash the way you steer (or face), with 0.2 s of safety; shares the dash cooldown |
| 1 2 3 | abilities |
| 4 (or K) | the signature, when the meter is full |
| Q / E | cycle your target among the enemies; Tab hands the choice back to the AI |
| F G T N B M V L R | the old test keys: stage, rival stage, rival, team size, rocks, arena, shake, AI log, rematch |

The matchup picker (`scenes/move_preview.tscn`) gained a **"WHO YOU CONTROL"** row for 3v3: your pick leads the team and the next two lines fill in, and any of the three can be the one you steer (`control_slot`). The other two, and the whole enemy team, run on Kit Sense. Your creature's own AI no longer moves it or swings for it; your target stands (Kit Sense's finish and peel retargeting is skipped for the steered creature). The checks and the simulator keep `auto_you`, where the AI drives it, and a `poll_input` switch lets a check inject steering and the attack key.

## The movement model
- **Momentum.** Every creature carries a velocity: full speed in about five frames, a short slide on release (1.7 px), a dust skid when it turns hard. Dashes, roots, holds and braces all go through the same velocity, so nothing teleports.
- **A dash every creature owns.** 260 px/s for 0.18 s (about 35 to 50 px), afterimages behind it, a 3 s cooldown. Yours is on Space. The AI dashes in when its target is far and dashes clear when it is a kiter with someone on it.
- **The dodge step.** When an enemy's telegraph aimed at a creature has 0.16 s left and is a melee, line or area (charges and rails cannot be stepped out of), it sidesteps about 34 px with 0.2 s of safety: tanks never, bruisers half the time, everyone else most of the time, a listener always. "Dodge" over its head and a line in the AI log.
- **Arcs, not standstills.** The default footwork strafes harder, and a presser circles once it is in your face.

## The camera
The fight renders into a 384 x 216 viewport shown at 3x; the world layer is now scaled about a focus point. A **drop-in** from 1.6x at the start of every match, easing out over about a second. An **action lean** to 1.12x on the fighters' centre when they are all within 150 px, back to full view when they spread. A **punch-in** to 1.35x on a signature's caster and 1.3x on a knockout, half a second each. **Shake** rides on top. The HUD layer is untouched by any of it.

## The crowd banner
A dark strip over the stands with a gold line, sliding in and out: **WHAT A HIT!** on any hit of 25 or more, **KNOCKOUT!** on a KO, with the crowd cheering under it. The reference video's cutaways, cut to the arena's size.

## Check (`tools/debug/arena_motion_check.gd`)
- Drop-in: zoom 1.60 at the start, 1.00 a second later; the picker's slot 1 put Rampartroot under your control.
- Momentum: speed over the first eight frames of steering 8, 17, 25, 34, 42, 42, 42, 42 (full 42); 1.7 px of slide after release.
- Dash: 35 px in 0.2 s with afterimages and 0.20 s of safety; cooldown 2.9 s.
- Attack on J: with J up the creature stood ready; with J held it swung at your target.
- AI dodge: over five telegraphed Cinder Claws Stormwick stepped out once (a 55% call each after the balance pass toned it down from 85%); the step is real, the rate is Grok's lever.
- Camera: with two fighters close the zoom settled at 1.12; the knockout punched toward 1.30 with the banner KNOCKOUT!, easing back after.
- Stills here: `entry.png`, `dash.png`, `dodge.png`, `knockout.png`.

## Known
- Non-integer zooms resample the pixel art a little (nearest filter); the lean is kept small and the punch-ins short for that reason.
- Aiming is target-based (Q/E), not mouse-based; a mouse aim can come with the Smite pass if Preston wants it.
- The old steering for recorded test movies (`debug_input`) still works for fighter 0.
- **Grok:** every number here is a draft.
