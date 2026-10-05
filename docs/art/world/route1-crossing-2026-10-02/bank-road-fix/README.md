# Bridge approaches and grounded levee road

Preston reported that the bridge steps did not reach fully across the river and the new road looked detached from the ground. This correction is installed in `scripts/route1_crossing.gd`.

The bridge and foreground rail move 16 pixels east, centering the deck over the water. Both stone approaches now overlap dry bank by 16 pixels. The walking corridor, river collision and original artwork remain.

The road now joins the hometown lane at (184,200), curves through the levee entrance and ends at the western bridge approach. Its soil keeps the existing path colors. Narrow turf/earth edges and concentric, lightly shaded grass shoulders replace the broad displaced shadow. The rectangular western dirt patch was removed after it left a triangular fragment beside the curved road.

[Before](before.jpg), [corrected road](road.jpg), [corrected bridge](bridge.jpg), [wide inspection view](overview.jpg).

## Verification

The final deterministic game `bank-road-final` (seed 20261002, 60fps) walked from home (48,192), accepted the pouch/read the entrance, crossed to the city clerk, and returned along the bridge and road to (48,192). No player-position fixture was used for this final traversal.

- Home: physics frame 1237.
- Bridge center: frame 1812, (551.792,415.792).
- City clerk: frame 5017, arrival registered.
- West bank return: frame 5364, (431.792,415.792).
- Levee entrance return: frame 9954, (216,264).
- Hometown return: frame 10151, (48,192).

The overview temporarily used 2× camera zoom in the disposable instance. Normal 3× framing was restored for the return, and the saved camera settings were untouched. The before image uses an inspection position fixture. [Probes, inputs and diagnostics](verification.json) distinguish these checks.

The route runtime logged zero errors. Latest combined diagnostics: **0 errors, 10 existing battle warnings**. Two transient MoveGate errors in a concurrent open battle script buffer appeared during the test and cleared by the final read; no battle code was edited. All instances created for this fix were stopped.

## Exact files

Runtime: `scripts/route1_crossing.gd` only.

Records: `docs/AI_COLLABORATION.md`, `docs/team/ROUTE1_RD_AND_WALKS_HANDOFF_2026-10-01.md`, the parent `README.md`, `CHANGED_FILES.md`, `manifest.json`, `source_checks.json`, and this folder's `README.md`, `manifest.json`, `verification.json`, `capture_archive_receipt.json`, `initial_crossing_manifest.json`, `route1_crossing.before.gd.txt`, `route1_crossing.installed.gd.txt`, and four JPG captures.

Exact source hashes are in [manifest.json](manifest.json). The original scene and quest script hashes remain the same as the initial crossing. Previous captures, bridge source and generation records remain. **No paid generation**, staging, commit or deletion occurred.
