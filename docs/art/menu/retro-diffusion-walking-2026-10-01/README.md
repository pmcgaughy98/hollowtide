# Courier Lookout walking arrival | October 1, 2026

Preston requested legitimate walking motion using Retro Diffusion. The courier and Cinderhide now take a short walk along the bluff into their existing lookout positions, then settle into the previously saved idle animations. Both retain the rear-right direction and current scale. Menu controls remain usable during arrival.

[Actual menu animation](menu_walk_in_runtime_smooth.gif) | [Walking capture](menu_walk_runtime_capture.jpg) | [Settled capture](menu_settled_runtime_capture.jpg)
[Courier frame review](menu_courier_walk_frames_review.png) | [Cinderhide frame review](menu_cinderhide_walk_frames_review.png)

RD Advanced Walking used frame 0 of the courier contrast atlas and Cinderhide dusk-lit atlas as exact 80x80 inputs. Eight generated frames each, originally 150ms. Native extraction into 640x80 horizontal atlases; no frame resizing, resampling or fixed foot band. Three isolated courier white pixels and two Cinderhide white pixels use existing neighboring colors; every alpha remains unchanged. Original GIFs and exact requests are preserved.

Installed:
- assets/sprites/menu/retro_diffusion_idle_2026_10_01/menu_courier_walk_atlas.png
- assets/sprites/menu/retro_diffusion_idle_2026_10_01/menu_cinderhide_walk_atlas.png
- scripts/main_menu_art_preview.gd updated with the one-time walking arrival.

Courier starts at feet (174,466), waits 0.3s, then travels (126,-42) over three 0.8s cycles, ending at feet (300,424) at menu time 2.7. Cinderhide starts at feet (296,498), waits 0.5s, then travels (136,-50) over three 0.96s cycles, ending at feet (432,448) at time 3.38. Its existing layered contact shadow follows the foot anchor. Positions are pixel-rounded; no extra deformation shader. Idles begin from their standing first frame after arrival, with the existing 2.4s/3.2s cycles. Their previous clock phase is superseded by this arrival timing.

Fresh deterministic menu-walk-review in Summer 0.5.68 observed all eight walking frames for both actors. At menu time 4.417 both are back at the original idle positions (180,211) and (353,304), with Cinderhide shadow (432,448). Reduce Motion callback frozen at time 2.417: all actor frames, positions, shadow and menu time stayed identical through 120 further process ticks; disabling it resumed motion. New Game invoked during arrival at time 0.6 loaded FirstRoutePrototype; route opened solely to verify menu transition. Actual 37-frame capture at seven process ticks per sample shows arrival and settling.

Post-play diagnostics: zero runtime, open-script and total errors; 11 warnings from the shared project, none from the changed preview script. All copy helpers completed with no script/boot errors. Own disposable instance stopped; no unrelated main process was stopped by this task. Keyboard/controller and audible-quality checks were not repeated.

Generation cost: $0.28, two successful jobs, no paid retry. The landscape, previous idle/lighting atlases, battle art, launch setting and main_menu.gd remain intact. No Git staging, commit or discard. No blocker.

The subsequent eight-direction male/female walking package is documented in [the chibi record](../../characters/retro-diffusion-chibi-walking-2026-10-01/README.md).
[Preparation and exact pixel repairs](menu_walk_preparation.json) | [Runtime receipt](runtime_check.json)
