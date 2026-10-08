# Original arena sprite audit (October 7, 2026)

Read-only project audit. All original project files were preserved byte-for-byte in `originals/` using their project-relative paths. No project asset, code, paid generation, or engine process was changed/launched by this audit.

## Scope and definitions

- 369 original PNG snapshots: nine approved bases, nine rotation sheets, 72 full-size facings, 15 walk sheets (120 distinct source frames), and 264 game PNGs (72 stills + 192 walk frames, including mirrors).
- `before-manifest.json` holds SHA-256 and byte lengths for those PNGs and 602 protected `.gd`, `.tscn`, and existing Python tool files.
- `before-metrics.json`/CSV has 465 image/frame records. Mean brightness is .299R + .587G + .114B over painted pixels. Saturation is the mean HSV saturation expressed as 0–100%. Palette counts use exact painted RGB colours. Transparent RGB is excluded.
- Connected-component flags use 8-neighbour connectivity; dark outline coverage is the percentage of 4-neighbour silhouette edge pixels below luminance40. These are diagnostics, not deletion masks.
- All sources, facings, walk frames, and current small game PNGs have hard alpha: zero half-transparent pixels.

## Brightness spread before repair

| Form | Approved-base mean | Full 8-facing spread | Small 8-facing spread | All source-walk spread | All small-walk spread |
| --- | ---: | ---: | ---: | ---: | ---: |
| Kithflare | 120.55 | 5.72 | 12.74 | 9.67 | 15.65 |
| Sparkwick | 124.73 | 26.88 | 20.26 | — | — |
| Stormwick | 90.73 | 15.17 | 17.12 | — | — |
| Tallowroot | 97.10 | 6.07 | 4.71 | 11.57 | 16.21 |
| Huskward | 93.26 | 5.98 | 7.29 | — | — |
| Rampartroot | 74.91 | 10.04 | 14.60 | — | — |
| Rimefin | 97.09 | 11.01 | 13.27 | 14.64 | 21.39 |
| Riftfin | 84.96 | 8.99 | 11.02 | — | — |
| Scourmaw | 65.09 | 9.51 | 11.40 | — | — |

The existing majority downscaler changes painted-colour proportions, so the good full-size Kithflare spread5.72 is already12.74 at game size. Report both rather than treating a full-size<8 result as proof of the runtime sprite.

## Visible defects and colour drift

1. Sparkwick NE/N are flat dark brown compared with the source and other golden facings. This is the clearest texture/brightness discontinuity; source124.73 versus NE98.75 and N102.06. Rear-facing absence of the cream chest is legitimate, but the copper material itself should retain the source colour family and contrast.
2. Even visually good Kithflare facings have67–85% of painted pixels outside the approved base's exact palette. Sparkwick89–96%, Stormwick75–82%, Tallowroot18–26%, Huskward35–41%, Rampartroot47–61%. `palette-drift-and-magenta.json` enumerates every frame. Exact base-palette mapping is justified independently of brightness spread.
3. Catfish facings already use nearly the same colours: Riftfin0% outside base palette, Scourmaw0–1%, Rimefin2–5%. These need restrained per-view brightness/material balancing, not an invented new colour system.
4. Definite erroneous magenta colour in Tallowroot NE walk: f0 has17 magenta pixels on the crown/spike (bbox x47–50,y32–40); f1 has6 pixels (three on spike x58–59,y39–40 and three on shoulder x85–86,y78–79). Game NE/NW f0 each retains3 magenta pixels, visible on contacts. Recolour these locally into the surrounding approved material; no alpha or shape change is necessary.
5. Kithflare source's detached2-pixel component at x17,y38–39 and north facing x92,y52–53 are near the flame; preserve them as existing sparks. Small Stormwick antenna and Rimefin/Riftfin barbel islands arise when thin source features pass through majority downscale. Do not indiscriminately remove these as background noise. All full-size facings have no canvas-edge clipping and no widespread stray-background components.
6. Walk silhouettes/details do change between frames (Tallowroot's spike angle/crown and Rimefin barbels, Kithflare body proportions). The user prohibits shape/pose changes; colour correction cannot claim to have repaired anatomy drift. Preserve original frame timing, alpha, foot rows, and positions.

## Safe interpretation of the target

Under-about8 full-size brightness spread is a useful per-form objective and can be approached by correcting colour and saturation against the approved take, then searching bounded palette-preserving gains. Mean luminance alone does not prove material/texture consistency. The approved bases deliberately become darker in later evolutions; forcing every form to Kithflare's mean would contradict those bases. Use Kithflare's clean outlines, limited coherent palette, and local highlight/shadow separation as a clarity bar while keeping each form's own material colours.

Exact base RGB palette, original alpha/geometry, faithful source outline colours, mirror equality, visual contact review, and actual game-size metrics must all be reported. The `finish_back.py` adaptation must omit its canvas/foot repositioning and must select an actual source palette colour if a median outline RGB is not literally in the palette. Turning every luminous silhouette pixel black would destroy the lantern/fin glow rather than improve consistency; preserve intentional bright rim details.

The existing pipeline's majority-colour operation can produce unequal runtime means even when full means match; any small-size<8 claim needs a direct separate check. If palette/pose constraints prevent a strict target, retain the approved appearance and report the remaining measured spread instead of silently changing shapes or redistributing whole materials.

## Artifacts

- `contacts/<form>-facings-before-game3x.png`: nine requested 8-facing before rows at actual small sprites enlarged3x by nearest neighbour.
- `contacts/<form>-source-and-facings-original1x.png`: nine approved-source/rotation comparisons.
- `contacts/{kithflare,tallowroot,rimefin}-walks-before-game3x.png`: all8 facings ×8 game walk frames.
- `mirror-checks-original.json`: all5 explicit full-size mirror assignments pass exact RGBA equality.
- `before-metrics.json`, `before-metrics.csv`, `before-summary.json`: complete numerical records.
- `palette-drift-and-magenta.json`: exact palette drift and defect coordinates.

