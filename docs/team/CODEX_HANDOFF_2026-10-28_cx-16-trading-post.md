# Codex handoff: revised cx-16 trading post, 2026-10-28

## Installed and checked, 2026-10-29

Preston gave the revised trading post a visual yes. Recorded it with review_sheet.py, then ran the prescribed install_slot.py with import/export enabled. Installed assets/slots/town/building/shop.png matches the approved 204x192 candidate byte for byte (SHA-256 b229d8f8024d7ba6535bd970347ca153212c0b9e04fa30bfc258dff9bbca6beb). Slot status is installed; registry now e4505c70e661. Old lean-to remains historical and was not installed.

Ran the required command with Highbank v2 off, then on, each with --jobs1 and --fixed-fps30:

    python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30

| Mode | art_slots | building_template | hub_town |
|---|---|---|---|
| v2 off | PASS | PASS | PASS |
| v2 on | PASS | PASS | PASS |

Both runners exited0. Slot validation remains11/11PASS against the post-install registry, and review_sheet.png now shows yes. Logs and the preservation receipt are in docs/art/slot-candidates/cx-16-item-shop/installation-2026-10-29/ (checks-v1.md,checks-v2.md,installation-result.json).

Preserved the existing298 dirty tracked files: the only intentional source edit is this slot's status. Reversing that one status field reproduces the entire pre-install town_buildings.gd hash, so Claude's other edits remain exact. Other existing dirty files have no changes from this run. Installer outputs are the new shop asset/import metadata, installed.json,slots.json and that status field. Candidate records and this handoff also updated. No commit, creature data/sprite or Route1 edit, forbidden Riftfin-redo access or real-save change.

The building is used by Highbank v2; the default map remains unchanged. Unverified: no fresh manual playthrough or exported-build QA. Earlier in-memory window captures remain preview evidence, not a post-install manual walk. Installation and the required automated checks are complete. This status supersedes the pending/no-install statements in the historical generation delivery below.

## Done

Explicitly reopened cx-16-item-shop for town.building.shop after the latest generation authorization. Re-exported refs verified against registry 2d9b461262c9: trading_post, 204x192, door [79,142,22,48], foot row191. Generated one roof-first trading-post candidate with built-in imagegen; no retry needed. The clay hip roof dominates the picture, with dormer/hoist/crate, ridge sack, chimney, shuttered window and striped counter awning. Ground stock remains separate dooryard props.

Old 204x144 lean-to files and DELIVERY.md preserved under docs/art/slot-candidates/cx-16-item-shop/historical-lean-to-204x144/. The active candidate and root DELIVERY.md now describe the revised 204x192 trading post. Generation approval was not recorded as visual approval; review.json still says pending.

## Verified by running

- Existing prepare_slot.py and validate_slot.py passed all 11 scripted checks against the current registry. Check line: town.building.shop PASS C1,C2,C3,C4,C5,C7,C8,C9,C10,C11,C12. Native204x192,26colours,binaryalpha,door22x48 clearsSparkjab22x45,foot191,C9 orphan2/0.01%.
- Exact-size native-input.png was registered from the untouched1293x1217 generator output with the Python pixel cleanup Preston previously authorized. Existing cleanup helpers used; no shared tools changed. Raw,prompt,ledger and cleanup measurements retained. One image job, zero failed validation attempts; no external paid generator called. Built-in tool did not report monetary/credit cost.
- Actual Highbank v2 preview at --fixed-fps30 verified the active candidate texture in ArtSlots' in-memory cache. Sparkjab leader asserted for scale. Closed/open door captures include the production finish, sign, footing and placeholder dooryard props; an inspection camera and hidden main HUD show the whole roof. Save explicitly isolated inside the candidate revision folder. Clean process exit. The preview changed door frames manually, so no interaction or progression test is claimed.
- review_sheet.py cx-16-item-shop generated the current sheet from target,candidate,runtimecapture andcheckreport. Visually inspected by Codex. All19 protected source/registry/reference hashes unchanged.

## Review and paths

- Review: docs/art/slot-candidates/cx-16-item-shop/review_sheet.png
- Active candidate: docs/art/slot-candidates/cx-16-item-shop/town.building.shop/prepared.png
- Large preview: docs/art/slot-candidates/cx-16-item-shop/preview-4x.png
- Open-door view: docs/art/slot-candidates/cx-16-item-shop/town.building.shop/capture-open.png
- Full receipt: docs/art/slot-candidates/cx-16-item-shop/DELIVERY.md
- Versioned inputs and preview fixture: docs/art/slot-candidates/cx-16-item-shop/trading-post-2026-10-28/

## Unverified / next action

Await Preston's visual yes on THIS revised sheet. No install_slot.py call and no post-install run_checks.py suite. No live door interaction,v1/v2 regression or exported build result claimed. Dooryard prop approval is a separate batch. Historical PASS lines for the old lean-to are not this contract's evidence.

After his visual yes, install only the active204x192 candidate, then run:

    python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30

Source issues for Claude: refs now match the registry; no scripted blocker remains. Generator output was larger than the asked logical canvas, so raw and reproducible native cleanup are retained. Brief says1pxdarkoutline while structuredoutline remainsruntime_rim; candidate avoids a heavy outer contour and was viewed with the runtime finish.

No commit, production script/registry/asset change, creature sprite/data or Route1 edit, forbidden Riftfin-redo access, real save or cross-chat message. Writes limited to the reopened candidate batch and this expressly requested team handoff. Batch lock released at delivery.
