# Fusern fixed upper-dome material comparison

This is the upper52% of the original painted bbox, excluding its silhouette edge. It is a comparable upper-dome diagnostic, **not semantic segmentation of the whole shell**. The mask remains fixed to the original, and alpha/canvas differences are reported. Bright warm orange uses L>=130; pale warm orange L>=165; dark joint-or-shadow uses L<=60. Warm RGB must satisfy R>1.3G, G>1.15B and HSV saturation>.35. Dark-pixel share and adjacent contrast do not prove that missing mortar geometry has been redrawn.

| Facing | Dome mean before→current | Bright orange% before→current | Pale orange% before→current | Dark joint/shadow% before→current |
| --- | --- | --- | --- | --- |
| base | 88.49 → 88.49 | 7.61 → 7.61 | 1.58 → 1.58 | 19.25 → 19.25 |
| s | 89.85 → 89.85 | 9.68 → 9.68 | 1.12 → 1.12 | 19.63 → 19.63 |
| se | 88.23 → 88.23 | 7.61 → 7.61 | 1.58 → 1.58 | 19.25 → 19.25 |
| e | 136.33 → 136.33 | 78.36 → 78.36 | 25.29 → 25.29 | 6.14 → 6.14 |
| ne | 120.35 → 120.35 | 51.66 → 51.66 | 22.82 → 22.82 | 8.40 → 8.40 |
| n | 130.47 → 130.47 | 61.97 → 61.97 | 26.33 → 26.33 | 2.05 → 2.05 |
| nw | 148.64 → 148.64 | 84.13 → 84.13 | 43.31 → 43.31 | 2.37 → 2.37 |
| w | 79.96 → 79.96 | 0.27 → 0.27 | 0.00 → 0.00 | 21.58 → 21.58 |
| sw | 84.46 → 84.46 | 2.26 → 2.26 | 0.00 → 0.00 | 20.84 → 20.84 |

Evaluated 121 frame/view records; original-source alpha exact: True; missing required sources: 0. All CSV/JSON data are calculated from the saved pixels under the declared current image root. This tool never edits source art, invokes generation, or calls the engine. Contacts expose dark original s/se/w/sw references and pale original e/ne/n/nw separately.
