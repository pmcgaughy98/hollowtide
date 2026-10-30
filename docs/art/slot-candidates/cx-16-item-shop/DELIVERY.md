# cx-16 revised trading-post delivery, 2026-10-28

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

PREPARED and CHECKED; visual approval pending. NOT INSTALLED.

town.building.shop: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS

Active candidate: town.building.shop/prepared.png, 204x192, trading_post contract. 26 colours, binary alpha, clear edges, foot191, door [79,142,22,48]. C9: 2 orphan pixels (0.01%). One built-in imagegen job; no failed validation attempts, no paid alternative. Exact prompt and untouched raw retained. This latest delivery supersedes the old root delivery; all 24 previous files were copied byte-for-byte to historical-lean-to-204x144/ before work began. Never install either older box or lean-to.

Verified by running:
- prepare_native.py creates an exact-size native-input.png from the untouched 1293x1217 generation using the pixel cleanup Preston previously approved. No shared tool edits.
- Unchanged tools/art/prepare_slot.py and validate_slot.py: all 11 checks PASS at current registry 2d9b461262c9, both the versioned staging file and promoted active file.
- capture_candidate.gd at --fixed-fps30: actual Highbank v2 Exterior uses this prepared texture in process memory. Sparkjab is asserted as the leader. Production finish, sign, footings, moving-door frame assets and dooryard props show in capture.png / capture-open.png. Inspection camera; main HUD hidden for roof inspection. Save path isolated inside trading-post-2026-10-28/. The preview manually changes the shown door frame; this is not a door-interaction test. Clean exit.
- tools/art/review_sheet.py cx-16-item-shop regenerated review_sheet.png from the current target, active candidate, runtime capture and current check report. The answer remains pending.
- All 19 protected source/registry/reference hashes unchanged.

Source issues for Claude:
- Re-export is now consistent: spec JSON, target PNG, slots.json and live registry agree on trading_post 204x192, door [79,142,22,48]. Earlier blocker is resolved.
- Imagegen returned a larger raster despite the native-size prompt. Untouched raw preserved; native registration, current-palette snap, orphan cleanup and exact dark door are recorded in pixel-cleanup.json. No scripted blocker remains.
- Brief says 1px dark outline while the structured field remains runtime_rim. Candidate avoids a heavy painted outer contour, and production finish was viewed. No shared rule changed.

Unverified / awaiting Preston:
- No visual yes recorded, no installation, and no post-install suite. Generation approval is not a visual approval.
- No live shop interaction, v1/v2 regression suite, exports or dooryard-prop approval claimed. Existing code props remain placeholders.
- After Preston says yes to this revised sheet, install the active 204x192 candidate only, then run: python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30.

No commit, creature sprite/data/Route1 edit, registry edit, forbidden Riftfin-redo access or cross-chat message. Batch lock released on delivery. Required team handoff: docs/team/CODEX_HANDOFF_2026-10-28_cx-16-trading-post.md.
