# cx-17 Home burrow delivery, 2026-10-29

## Installed and checked, 2026-10-29

Preston approved this visual review with "go". Recorded yes and installed ONLY cx-17's132x192 burrow with the prescribed install_slot.py, import/export enabled. assets/slots/town/building/home.png is byte-exact with the reviewed candidate (SHA-256 d02e2935540ffd2346f553b198254fedc75dd8fd8213ebcf2080b53f4d4f6ef4). Home status is installed; registry19fe5c2bff04. The old cx-01 cottage was not installed or changed. The previously installed trading post is unchanged.

Ran the required post-install command with HT_HIGHBANK_V2=0 and then=1, each at --jobs1 and --fixed-fps30:

    python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30

| Mode | art_slots | building_template | hub_town |
|---|---|---|---|
| v2 off | PASS | PASS | PASS |
| v2 on | PASS | PASS | PASS |

Both runners exited0. All11 slot checks also PASS against the installed registry. The regenerated review sheet shows yes. Full logs, tables and source-preservation evidence are in installation-2026-10-29/ (checks-v1.md,checks-v2.md,installation-result.json,install.log).

Preservation:318existing dirty tracked files protected. Only the intended Home status field changes inside town_buildings.gd; the entire file otherwise matches its pre-install bytes. Other installed.json entries, the old cottage files and installed shop match their pre-install state. No unexpected tracked changes. Installer outputs are Home's new asset/import metadata, own status and install metadata/slots.json; candidate receipts also updated. No creature sprite/data, Route1, forbidden Riftfin-redo or unrelated source edits, and no commit.

Highbank v2 uses the burrow; the default map remains unchanged. Unverified: no fresh manual room-entry/playthrough or exported-build QA; earlier window captures remain candidate previews, not a post-install manual walk. Installation and the required automated checks are complete. This status supersedes the pending/no-install statements in the historical generation delivery below.

PREPARED and CHECKED. Waiting for Preston's visual yes. NOT INSTALLED.

town.building.home: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C7 PASS, C8 PASS, C9 PASS, C10 PASS, C11 PASS, C12 PASS

One approved built-in imagegen call. New grass-bank Home matches the burrow layout: grass roof above the short stone face, stovepipe right of centre, round windows, ringed doorway, lantern and tied parcel. Native132x192;31colours;door[55,142,22,48];foot191;binaryalpha;clear forbidden edges. The old cx-01 cottage candidate was not installed or changed.

## Verified by running

- Current exported spec,target and registry agree on burrow132x192 and the exact doorway. Registry f8a00825c605.
- prepare_native.py reproduces the exact-size native-input.png from untouched raw.png. Uses the previously authorized Python cleanup: premultiplied BOX reduction, binary alpha, current palette, existing NumPy-only clear_orphans helpers, exact open door and foot registration. No shared tools changed.
- Unchanged tools/art/prepare_slot.py and tools/art/validate_slot.py PASS all11checks. C9 has5orphanpixels(0.03%);C8largestflatblock23%(under25%);door22x48clearsSparkjab22x45. Full details in prepared.png.check.json.
- Actual Highbank v2 capture at --fixed-fps30: exactly one live Home Exterior uses this candidate in ArtSlots' process cache; Sparkjab leader verified for scale. capture.png and capture-open.png show production finish, footing and door-frame assets, with an inspection camera/main HUD hidden. The door frame is changed manually for inspection, not through gameplay. Save isolated inside this slot folder; preferences are process-local ConfigFiles. Clean exit; runtime.log retained.
- All30 protected source/reference/historical cottage files unchanged. No registry, live asset, game script, creature data/sprite, Route1 or shared task-file change.

## Review

review_sheet.png is the standard batch sheet. preview-4x.png is an enlarged native preview; town.building.home/capture-open.png shows the open door in the town. review.json remains pending. Generation approval was not treated as visual approval.

## Source issues for Claude

- No current contract mismatch or scripted blocker.
- Imagegen returned1040x1512 rather than native132x192. Untouched raw preserved; exact native registration/cleanup, prompt and ledger are supplied. Only one image was generated.
- The required town_stone strip makes grass muted olive, with31colours used overall. This is visible in both native and runtime previews; no palette exception was introduced. Visual approval still decides the look.
- The thick arch remains around the exact rectangular dark doorway; the game supplies moving door leaves and footing. No separate door animation was painted.
- Old cx-01 cottage stays historical and superseded. Do not install it as Home.

## Unverified / next step

No install_slot.py call, no post-install checks, exported-build check or live door/room interaction. No additional generation approved or spent. After Preston's visual yes on THIS Home sheet, install this batch's active candidate through the normal tool, then run:

    python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30

No commit or cross-chat message. Stop here for visual review; batch lock released on delivery.
