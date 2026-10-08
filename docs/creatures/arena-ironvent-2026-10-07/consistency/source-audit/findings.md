# Ironvent-line arena original audit (October 7, 2026)

Read-only project audit; no live assets, scripts, scenes, rules, or paid services were changed. Evidence and preserved originals are staged only in this task folder.

## Saved evidence

- `before-manifest.json`: 265 new-line PNG originals, with SHA-256/size and the previous arena-report schema (`files`, `protected_code_and_tools`).
- `originals/`: 24 full facings, 216 current game PNGs (24 stills +192 walks),15 source walk sheets,3 approved bases,3 rotation sheets,3 padded inputs, and Clinkerhide's raw take. Project-relative paths are retained.
- Fresh `protected_assets`: 765 current files belonging to the old nine forms (72 full facings +648 small still/walk PNGs +45 active walk sheets). These hashes capture the current completed evolved walks and do not use outdated proof.
- Fresh `protected_code_and_tools`: 615 current `.gd`, `.tscn`, and Python-tool hashes. Existing `build_small.py`, `slice_rotations.py`, `downscale.py`, and `finish_back.py` are guarded. Only the reporting tool extension is explicitly recorded as an authorized intended exception.
- `capture_originals`:11 current native-capture PNGs preserved separately; these are not immutable art sources. Root's native checks may refresh them.
- `before-metrics.json` / CSV:363 records (3 bases,24 full facings,24 game stills,120 source walk frames,192 game walk frames).
- `contacts/<form>-base-and-facings-before-game3x.png`: all8 directions with approved source reference, at game size3x. The base reference passes through the existing shrink purely for display; the original is preserved.
- Additional contacts show the8-direction row alone, the approved full source beside8 original facings, and all8×8 walk frames at game size3x.
- `palette-drift-and-magenta.json`, `canvas-and-source-outline-summary.json`, and `before-summary.json` retain the extra diagnostics.

## Before values

Mean brightness uses .299R+.587G+.114B; saturation is mean HSV percent; transparent pixels are excluded.

| Form | Base brightness | Base saturation% | Full brightness spread | Game brightness spread | Source walks brightness spread | Game walks brightness spread |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Cinderhide |37.82|26.86|5.80|6.95|7.22|8.45|
| Clinkerhide |44.84|22.36|4.26|6.51|8.48|12.17|
| Ironvent |45.34|35.12|8.15|6.70|8.76|10.49|

The still-brightness numbers are mostly already controlled; texture problems cannot be judged solely by a<8 spread. Saturation loss and exact colour drift are more evident:

- Cinderhide full saturation15.01–21.43% versus26.86% source. North/northwest are duller and more gray. Its facings have0–6.94% painted RGB pixels outside the source palette.
- Clinkerhide full saturation19.84–22.76% versus22.36% source. Its facings have5.37–10.48% outside-source colours. Walk brightness drops on frames/facings and the generated texture changes while moving.
- Ironvent full saturation27.37–30.97% versus35.12% source; source walks14.77–21.20%, and small walks10.57–19.28%. This is the strongest fade/washout. Its facings have19.47–27.50% outside-source colours. North-facing brightness36.94 versus45.34 source is also lower.

## Geometry and visible limits

All3 approved sources and all facings/walk frames already have binary alpha: no half-transparent pixels. No full-size facing or walk-frame painted pixels touch any canvas edge. There is no demonstrated source clipping to repair by enlarging/repositioning canvases.

Full/source-walk canvases are128×128 Cinderhide,144×144 Clinkerhide,160×160 Ironvent; game canvases are42×42,48×48,53×53. Their approved sources are96,112,128 pixels respectively. Rebuild through the existing named pipeline; never run the rotation slicer or builder without names, because bare calls overwrite the old nine forms.

The approved line is intentionally dark graphite armor with warm vents. Existing dark-edge coverage is97.31%,93.26%,95.70% for the three bases. Source outline medians are almost black ([1,1,2], [4,4,3], [5,1,1]); use an actual source palette colour rather than creating a new median tuple if it is absent from the palette. Do not raise this line to Kithflare's light-gold mean merely to make scalar metrics equal. Preserve local graphite highlight/shadow separation and warm vent colours.

No magenta case or widespread disconnected stray-background component was found. Clinkerhide's known south-walk thin curl over its head is generated anatomy. A single isolated game pixel occurs in south f2 atx28,y7 after shrinking; its full source remains connected. Removing it alone would not repair the underlying curl and would change the fixed support. Treat that separately from palette/texture normalization and do not describe a colour pass as an anatomy fix.

Review contacts after correction, especially Ironvent's walk vents/gray armor and Clinkerhide's south loop. Geometry drift between AI walk frames remains an honest limitation unless Preston authorizes a redraw; palette locking cannot restore model features that are physically absent from a frame.
