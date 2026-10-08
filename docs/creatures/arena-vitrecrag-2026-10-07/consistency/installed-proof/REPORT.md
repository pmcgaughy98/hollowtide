# Installed arena consistency report

One or more structural/palette checks failed; inspect the JSON proof before accepting this output.

| Check | Result |
| --- | --- |
| original_pngs | 264 |
| metric_records | 363 |
| protected_code_and_tools | 628 |
| existing_code_guard_pass | False |
| approved_bases_unchanged | True |
| full_and_walk_frame_geometry_exact | False |
| full_facing_and_whole_walk_sheet_alpha_exact | False |
| small_canvases_and_foot_rows_exact | True |
| exact_own_base_palette_pass | True |
| hard_alpha_pass | True |
| magenta_pixels_total | 0 |
| explicit_mirrors_exact | True |
| full_spreads_under8 | False |
| small_spreads_under8 | False |

Any explicitly audited artifact removals are validated pixel by pixel in the geometry-valid fields; exact-alpha fields still report false for those frames. The report reads the actual installed full/small PNGs, not candidate calculations. It does not run Godot; attach the separate native import/playback logs and captures. GIFs show the eight saved game frames at140ms per frame for inspection, and do not assert game playback timing. Small support/bbox changes caused by the corrected mirror/downscale pipeline are recorded individually in `consistency-check-summary.json`; they are not silently claimed to be exact original alpha. Intended spikes, sparks and barbels are preserved; only separately audited generated curl pixels are removed.

See `before-after-facings.md` and `.csv`, `before-after-spreads.md`/JSON/CSV, two walk-frame CSVs, selected facing contact sheets, source walk contact sheets/GIFs, the family contact and byte/hash proof.
