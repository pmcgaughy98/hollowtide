# Installed arena consistency report

Structural/palette checks passed.

| Check | Result |
| --- | --- |
| original_pngs | 369 |
| metric_records | 465 |
| protected_code_and_tools | 602 |
| existing_code_guard_pass | True |
| approved_bases_unchanged | True |
| full_and_walk_frame_geometry_exact | True |
| full_facing_and_whole_walk_sheet_alpha_exact | True |
| small_canvases_and_foot_rows_exact | True |
| exact_own_base_palette_pass | True |
| hard_alpha_pass | True |
| magenta_pixels_total | 0 |
| explicit_mirrors_exact | True |
| full_spreads_under8 | True |
| small_spreads_under8 | False |

The report reads the actual installed full/small PNGs, not candidate calculations. It does not run Godot; attach the separate native import/playback logs and captures. GIFs show the eight saved game frames at140ms per frame for inspection, and do not assert game playback timing. Small support/bbox changes caused by the corrected mirror/downscale pipeline are recorded individually in `consistency-check-summary.json`; they are not silently claimed to be exact original alpha. Existing tiny spikes, sparks and barbels are never deleted.

See `before-after-facings.md` and `.csv`, `before-after-spreads.md`/JSON/CSV, two walk-frame CSVs, all9 paired contact sheets,15 walk contact sheets/GIFs, the family contact and byte/hash proof.
