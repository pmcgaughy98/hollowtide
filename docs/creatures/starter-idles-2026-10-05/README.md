# Starter-line idles and signature title cards (Claude, 2026-10-05)

## Idles
All nine starter-line forms have an 8-frame animated front idle from Retro Diffusion's `rd_advanced_animation__idle` ($0.14 each, $1.26 total), made from each creature's current front art (including Codex's newer material-detail versions). `tools/debug/rd_idle.py` makes a sheet; frames are in `assets/sprites/creatures/idle_2026_10_05/<file>/f0..f7.png`. Every sheet was checked: feet stay on one row (Rimefin and Rampartroot move by 1 to 2 px with their tail and breath), nothing touches the canvas edge. Stormwick's frames came back 216 px instead of its 219 px art and were padded back with the feet aligned.

`tools/debug/install_idles.gd` sets `idle_frames` and the per-form rhythm. The front loop plays on the opponent's side; your side keeps the back view's procedural breath, now tuned per form:

| Form | Period (s) | Breath | Widen | Idle glow |
|---|---|---|---|---|
| Kithflare / Sparkwick / Stormwick | 1.2 / 1.4 / 1.8 | 0.022 / 0.02 / 0.018 | 0 / 0 / 0.006 | lantern fire 0.2 / 0.25 / 0.35 |
| Tallowroot / Huskward / Rampartroot | 1.6 / 2.0 / 2.6 | 0.02 / 0.016 / 0.012 | 0 / 0.008 / 0.01 | Rampartroot shoot jade 0.12 |
| Rimefin / Riftfin / Scourmaw | 1.5 / 2.0 / 2.6 | 0.02 / 0.018 / 0.014 | 0 / 0.006 / 0.01 | none |

Preview: `starter_idles_preview.gif`. In battle: `idles_in_battle.png`. Not yet: animated back views (they would need their own sheets).

## Title cards
Stormlantern's and Root Rampart's portraits were cropped through the creature, and Undertow's touched every edge. `tools/debug/make_titlecard.py` now fits the whole creature into 140 x 118 with a margin, shrunk with RD's free k-centroid downscale, from each move's charged frame (Stormwick overloaded, Rampartroot with the club raised, Scourmaw jaws open). `docs/battle/signature_titlecards_2026-10-05.png`.
