# Independent Vitrecrag-line material review — 2026-10-07

Root approved the final W-only Fusern NW texture option and the complete Vitrecrag seam/core/enclosed-void proposal. This review agent has not edited the live project, run Godot, called an art API or spent credit. Parent owns native validation and project installation.

Fusern S/SE/W/SW show the intended dark rust masonry. E/NE/N/NW originally have pale fill and bright mortar. Bright RGB252/161/82 mixes narrow mortar with broad central faces; whole-class dark recoloring would create a black slab. The reviewed 8-connected warm-roof classifier plus conservative 3×3 opening protects eye/rim/legs and retains broad fills. NW genuinely lacked central courses. Root selected the existing good W course/transition/fill tones copied at identical coordinates into the 548-pixel central interior mask: 349 RGB changes, outside and alpha literal. The first dotted mortar extraction and 16-join flat option were rejected. This is finite interior texture restoration, not merely palette lock.

Slagglass's dark maroon ridges and orange heat remain coherent at game size. Its south walk has a few pale shapes above the crest, including a ring. Some attach to the crest, so no safe stray-background deletion was inferred. These ambiguous source animation particles retain their geometry.

Vitrecrag's original NE/NW walks flash white radial grids and N crater changes gold→copper/brown. Reviewed color stages map existing shell spokes to restrained approved copper and transfer approved base crater luminance shade ranks inside finite pit envelopes. They preserve all alpha. The approved base's measured warm pit is L153.63. Original crater shape/area/seam layout differences remain; no motion or anatomy is redrawn.

The remaining apparent E/SE cold center was actually RGBA255/255/255/0, not gray paint. Eleven original holes are fully enclosed 8-connected transparent components, surrounded by painted crater pixels. Root approved their restoration using four exact approved-base colors, orange edge→gold center, with inward-distance shading. Exactly 2886 alpha pixels are added: S 558, SE 1298, E 1030; NE/N 0. Exterior-connected background, every original painted rim/outline pixel, canvas, bounding box and feet remain literal. Exact-alpha is honestly false for the 11 affected frames. Small-size additions project through the unchanged shrink to 62/146/115 direct S/SE/E pixels before mirrored directions; named builder must produce final game sprites.

Selected candidate records:
- `candidate/vitrecrag-material-audits/selected-integration.json` — source hashes and selected layered audit links.
- `candidate/vitrecrag-seam-audit.json`, `candidate/vitrecrag-core-audit.json`, `candidate/vitrecrag-enclosed-core-report.json` — exact selected audit copies.
- `candidate/vitrecrag-crater-repairs.json` — report schema `operation: fill_enclosed_crater`, exact sheet coordinates for 0→255 additions.
- `candidate/vitrecrag-material-audits/{seams,core,fill}/` — selected per-frame/source-sheet masks and original/baseline/proposal full/game contacts.
- `candidate/vitrecrag-material-audits/palette-baseline/` — five preserved palette-only source sheets, before material repair.
- Final five source walk sheets in `candidate/docs/creatures/arena-starters-2026-10-07/walk/vitrecrag_{s,se,e,ne,n}_sheet.png` match the root-reviewed enclosed-core proposal.

The earlier unnumbered seam/core options and first dotted NW donor are intermediate, not selected final art. `vitrecrag-seam-proposal-v2`, `vitrecrag-core-proposal-v2` and `vitrecrag-enclosed-core-proposal` are the selected three material stages.

## Exact repeat from preserved inputs

Install all three sibling Python files together; the core script imports seam helpers, and the enclosed-void script imports both. They write separate project-relative review trees only; they refuse the exact live-project root or an input root as the output root. Use the preserved palette baseline, not repaired candidate sheets, for the first stage. The source root supplies the approved base and raw originals. No `.gd`/`.tscn` edits or generation calls occur.

```powershell
$arenaProject = 'C:\Users\pmcga\dev\hollowtide'
$arenaReview = 'C:\Users\pmcga\Documents\Codex\2026-10-01\referenced-chatgpt-conversation-this-is-an\arena-vitrecrag-consistency-2026-10-07'
$arenaPython = 'C:\Users\pmcga\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$arenaToolDir = Join-Path $arenaReview 'candidate-tools'
$arenaOriginal = Join-Path $arenaReview 'source-audit\originals'
$arenaPalette = Join-Path $arenaReview 'candidate\vitrecrag-material-audits\palette-baseline'
$arenaSeams = Join-Path $arenaReview 'reproduce\vitrecrag-seams'
$arenaCore = Join-Path $arenaReview 'reproduce\vitrecrag-core'
$arenaFinal = Join-Path $arenaReview 'reproduce\vitrecrag-final'

& $arenaPython -X utf8 (Join-Path $arenaToolDir 'repair_vitrecrag_seams.py') --source $arenaOriginal --baseline $arenaPalette --output $arenaSeams --project $arenaProject
& $arenaPython -X utf8 (Join-Path $arenaToolDir 'repair_vitrecrag_core.py') --source $arenaOriginal --baseline $arenaPalette --seams $arenaSeams --output $arenaCore --project $arenaProject
& $arenaPython -X utf8 (Join-Path $arenaToolDir 'fill_vitrecrag_core_voids.py') --source $arenaOriginal --baseline $arenaPalette --input $arenaCore --output $arenaFinal --project $arenaProject
```

Final integration rebuild is the existing named `build_small.py fusern slagglass vitrecrag`, after source selection. All facings/cell sizes remain unchanged; missing walk directions mirror only after the existing shrink. Final source-cycle game brightness spreads are S 5.47, SE 7.80, E 5.43, NE 5.82, N 3.85. Across-direction pooled brightness can differ because intact/fixed hot-pit area changes and original material proportions differ. Do not claim every pooled walk brightness is <8 or all source topology is uniform.

## Final visual review

Reviewed all 24 frozen selected stills and all 192 actual rebuilt game walk PNGs, at 3×, directly from the final named pipeline outputs. Fusern retains dark warm brick material, Slagglass retains separated maroon ridges and heat, and Vitrecrag retains orange/gold hot pits with copper spokes. All repaired internal crater holes are filled; no new exterior cutoffs were observed. Six 32-frame review contacts and their exact 192 source PNG SHA-256 hashes are saved in `independent-review/final-game-walks/`. Source animation poses, seam layout/width, hot-feature areas and the ambiguous Slagglass crest particles still vary; no anatomy or animation-topology redraw is claimed.
