# cx-02-lots candidate delivery, 2026-10-27

town.building.lot_before_stall: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
town.building.lot_before_shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
town.landmark.lot_before_plot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS, C12 WARN

Source issues for Claude:
- town.building.lot_before_stall: image_gen returned [1190, 1322] raw; requested native [108, 120]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- town.building.lot_before_shop: image_gen returned [1305, 1205] raw; requested native [156, 144]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- town.landmark.lot_before_plot C12 WARN: upper-left edge 22, lower-right edge 73
- town.landmark.lot_before_plot: image_gen returned [1536, 1024] raw; requested native [144, 96]. Untouched raw preserved; provided prepare_slot produced exact-size candidate.
- In-game capture absent: no candidate installed or runtime wiring changed; R4 remains pending Preston/Claude review.

No install. Answers pending Preston. Old Tower candidate excluded. New Tower batches await Claude's exported contracts. cx-10-road-far remains held pending its revised brief / approved crown.

## Final contract recheck, 2026-10-27

Registry 235abb6156b1 via candidate-only official export. All checks current; answers unchanged.

town.building.lot_before_stall: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
town.building.lot_before_shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C12 PASS
town.landmark.lot_before_plot: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C9 PASS, C12 WARN
