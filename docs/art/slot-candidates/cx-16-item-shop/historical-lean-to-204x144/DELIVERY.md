# cx-16-item-shop delivery, 2026-10-28

town.building.shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS

Swaphoard's lean-to, 204x144, 30 colours. Ragged reclaimed plank/tin roof, side heaps, trade hatch, brass balance, ladder and open dark doorway. This replaces the superseded 156x144 cx-01 shop candidate. Nothing installed; review answer pending Preston.

Verification:
- Standard prepare_slot.py and validate_slot.py unchanged, current registry 61d45c560e96. All 11 scripted checks PASS. Foot row 143; doorway x79,y94,22x48 clears Sparkjab 22x45. Orphan pixels 6 (0.03%).
- Untouched raw.png preserved; native-input.png is the exact-size registered/cleaned input. Reproduce with prepare_native.py, then the usual prepare and validate commands. Cleanup uses the existing NumPy-only clear_orphans helpers, keep=40; no shared tools changed.
- capture.png and capture-open.png are from the actual Highbank v2 scene at 1152x648, using this prepared.png only in ArtSlots' process cache. Sign, finish shader, foundation/step and door leaves come from production code. Runtime verified exactly one Exterior uses the candidate, and exited cleanly. These are visual previews, not a door interaction/playthrough test.
- All 18 tracked source/reference baseline hashes unchanged. Claude's and Grok's files preserved. Save writes explicitly isolated to preview-team.save inside this candidate slot. No registry, assets, shared scripts or team task file changed.

Source issues for Claude:
- Generator returned 1493x1054 despite the exact logical-size prompt. Raw retained; candidate registered to 204x144, alpha hardened, palette snapped, C9 cleanup applied, open doorway aligned to the contract. No remaining scripted art blocker.
- The task's Alt paragraph says 204x144 fits a 192x192 inpainting box. Width 204 exceeds that alternative's stated limit; correct that advice if it is reused. This delivery used built-in imagegen.
- Do not install the old cx-01 shop candidate. Current slot is the new lean_to contract, not the former box.

Review: review_sheet.png. Preston's answer belongs in review.json through Claude; no answer recorded on his behalf. No install_slot.py call.
