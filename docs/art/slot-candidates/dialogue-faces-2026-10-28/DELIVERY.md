# Punchybun and Sparkjab dialogue-face candidates, 2026-10-28

H9-44 / LF7-17 face gap: prepared, checked, NOT INSTALLED; Preston approval pending.

- punchybun: PASS 6/6 local crop checks; 40x40, 15 source colours, binary alpha; proposed FACE_AT Vector2i(14,22); 24px headshot 95.8% opaque.
- sparkjab: PASS 6/6 local crop checks; 40x40, 15 source colours, binary alpha; proposed FACE_AT Vector2i(21,21); 24px headshot 99.3% opaque.
- Candidate fixture of the existing Godot face_crop_check: all 5 verdicts PASS for 51 faces, zero failures, all 39 roster forms have a face in the fixture. face_crop_check.log and all-faces-check.png preserve evidence. The production UI source is copied only under this folder, with just the two proposed FACE_AT rows added; new images enter only its process-local icon cache. Production scripts and assets stay unchanged.
- Runtime window preview PASS, clean exit. runtime-preview.png uses the production dialogue/headshot draw methods from that isolated UI copy. It is a fixture preview, not a live story interaction.

Art source and method:
Both candidates are crops of their current assets/sprites/arena/<form>/sw.png, using the existing HEAD entry, build_dialogue_portraits.auto_cut and downscale.resample. No new art, repaint, palette change, generator, spending or creature-rule change. Current source copies, source crops, 40px prepared files and 48px headshots are retained per form. build_candidates.py recreates/checks outputs from the repository root. Ledgers contain source and candidate hashes. All protected source/creature/dialogue files remain byte-exact (see source-preservation.json).

Review: review_sheet.png (full face, outlined small cut and small headshot); runtime-preview.png (actual dialogue framing); answer pending in review.json. Do not infer yes from go.

Source issues / integration for Claude, after Preston approves:
1. Proposed destinations are assets/sprites/ui/dialogue/punchybun.png and sparkjab.png. They do not exist today. This session writes candidates only.
2. Both forms remain in tools/ui/build_dialogue_portraits.py NOT_MET, so the current builder intentionally skips them. To make the result reproducible in production, remove these two forms from that exclusion (keep starward's existing hand-placed source). The existing HEAD entries already recreate these cuts.
3. Add FACE_AT rows punchybun=(14,22), sparkjab=(21,21) to ui_style.gd with the two faces, then rerun the unchanged face_crop check. The candidate fixture verifies those exact rows, not the production default centre.
4. These are creature dialogue faces, not ArtSlots registry entries. prepare_slot.py/validate_slot.py cannot validate them; no fake registry or shared palette was introduced. Local crop checks plus the existing face check are the applicable verification.

No production integration, registry edit, install_slot.py, real save, team-doc edit, commit or cross-chat message. The title's exported-palette hold remains unchanged. Next independent queue item: audit the Riftfin growth still against current runtime art before deciding a crop/repaint.
