# Kithflare line review and Coalcrest hidden far leg, October 4, 2026

Coalcrest rear now follows Preston's latest pose correction: the back and foreground tail conceal the far hind leg. Only the original authored foot peeks beneath the shifted-right tail. The earlier exposed-leg/shin repair is superseded. The tail exit is narrower and bends right before sweeping into the curl; the rump join is rounded, the old dark stump/nib is removed, and the tail uses original authored scale material. Original head, sail, upper body, near hind leg, native canvas and hanging light-organ identity remain.

This is an installed, engine-reviewed refinement for Preston to judge. It is not a claim that every sprite or the game world is finished. The diagnostic view and eighteen current rear attack phase frames show no major stump, disconnected foot or canvas cutoff. Some regular angular lower-tail clusters remain; further user feedback takes precedence.

## Current six-view selection

Kithflare front/back are retained byte-exact from the prior polish. Coalcrest front is retained byte-exact from the prior rechecked version; the rear correction does not claim new front foot/lantern work. Wayburn front curl is more gradually tapered and three stark toe highlights are warmed to its native ivory palette; rear tail material has softer cluster transitions. Those Wayburn edits were installed earlier in this full-line continuation.

Coalcrest rear is now assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_occluded_leg_v3.png, SHA256 e2cde80eb484a38d0322c225a83d8584a37fb96c1ebfc6c1db83d373966020a1.

## Exact game files

Two preexisting resources changed:
- data/creatures/104_wayburn.tres: front/back texture paths only.
- data/creatures/105_coalcrest.tres: rear texture path only.

Six active new files:
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/wayburn_front.png
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/wayburn_front.png.import
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/wayburn_back.png
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/wayburn_back.png.import
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_occluded_leg_v3.png
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_occluded_leg_v3.png.import

Four preserved, unreferenced candidate files:
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back.png
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back.png.import
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_anatomy_v2.png
- assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_anatomy_v2.png.import

[Machine-readable twelve-file list and hashes](game-files.json). 2,183 of 2,185 baseline existing runtime files remain exact, two changed, none missing. Every resource property outside the texture lines matches its saved source. All prior art, moves/rules, battle/world/player/state code, scenes and project launch/audio settings remain. No staging, commit, deletion or user-editor control.

## Visual and native evidence

[Previous installed rear versus latest pose](review/coalcrest-rear-installed-comparison.png), [six-view native sheet](review/final-six-view-line.png), and [latest actual battle view](runtime-installed-hidden-leg/coalcrest-back-full-sprite-diagnostic.png).

The original all-six battle run contains twenty-two legal view/attack combinations. Its old Coalcrest rear has been superseded. Current proof combines nineteen unchanged combinations from runtime with three installed-rear combinations from runtime-installed-hidden-leg. All twenty-two timelines were visually reviewed; the eighteen latest rear phase frames are saved separately. Fixture HUD controls are hidden only for full-body diagnostics and restored in normal-HUD captures. Production HUD placement was not modified.

The latest installed-resource run confirms the actual selected texture, unchanged zoom 2.5, restored texture/position and released reverse state through Crest Signal, Furnace Bolt and Longfire Burst. Plate Rake remains excluded by the existing body gate. Final installed game-runtime stderr is empty and owned probes exited. Importer shutdown RID/ObjectDB warnings are retained in separate import logs.

Native audits cover original foot position/colors, hidden-leg negative space, foreground tail/foot overlap, four-connected tail corridor, no new islands/matte/clipping, native palette, near leg and fin/head/upper-body preservation. They do not establish aesthetic completion by themselves. [Current native audit](native-checks.json), [installed runtime audit](runtime-installed-hidden-leg/runtime-checks.json), [manual review and limitations](manual-review.json).

[Self-contained rebuild](portable-rebuild-v2/) reconstructs all six PNGs byte-exact using Pillow/numpy and archived sources; [rebuild verification](portable-rebuild-v2-check.json). Run rebuild_wayburn.py, rebuild_coalcrest_hidden.py, then audit_native.py there. Earlier candidates and old installed version are retained in sources/draft/review.

## Retro Diffusion result and cost

One separately approved rear sprite/mask edit earlier in this continuation cost $0.18. It changed the whole pose/facing and removed the sail, so it was rejected; no generated pixels were installed. Input, mask, prompt, result, sanitized receipt and decision are preserved under rd-rear-material. The subsequent native repairs and this hidden-leg correction made no further paid request/upload/charge.

## Goal and next work

The complete Nexomon/Coromon-level Hollowtide world objective remains active and unachieved. Recent sprite feedback has priority; current repair is a concrete progress step, not completion of that objective. Coalcrest front foot/lantern concerns from the visual critique were not silently marked resolved by this rear patch. Honor Preston's next sprite feedback, then resume meaningful hometown/city spaces and regional map quality from the world checkpoint. Claude owns save/reward/state and battle architecture; Grok creature/move rules. Preston runs Gemini Deep Research; prompts only when requested.
