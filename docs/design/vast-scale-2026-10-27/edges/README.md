# Town edge audit, 2026-10-29

Scope: resolved exterior building, prop, lamp, landmark and cliff slots through ArtSlots, including installed home/shop PNGs and legacy cliff strips. The room stair slots were also inspected for side walls. This is a visual audit, not a new automated art rule. The contact sheets show the current resolved images, not stale registry thumbnails.

Worst first, before this change:

1. `town.prop.hall.rise_stair`: no side walls; highlights behind the tread rather than on its front nosing. Fixed here.
2. `town.ground.cliff`: light bottom sediment ends abruptly without a dark continuous ground contact line. Runtime shadows are separate.
3. `town.ground.cliff_b`: same weak ground contact as cliff.
4. `town.building.lot_before_stall`: canopy ends in a thin outline without a lit turning edge and dark underside.
5. `town.building.lot_before_shop`: roof eave has an outline but no distinct lit cap over a dark undercut.
6. `town.building.storage`: roof eave has the same thin, flat cap treatment.
7. `town.building.scrolls`: roof eave has the same thin, flat cap treatment.
8. `town.prop.goods_table`: the apron overwrites the top's lower outline; legs end in their face color without dark ground contacts.
9. `town.prop.hall.wayline_post`: pale stone foot ends without a dark contact line in all three states.

The remaining exterior slots do not show a comparably clear violation in the isolated images. This is not approval of every surface in every assembled scene. Interior props are outside this town-exterior slice. The inspected hall_low stairs already have side walls.

Changed game file: `scripts/town/tower_parts.gd`, only `_stair`. Added front nosings, dark cap undersides, low stone cheeks with brighter west caps and darker east faces, and a dark toe row. No cast shadow is painted. Slot size 48x96, anchor (24,95), complete alpha mask and palette are unchanged; zero new RGBA colors. Of the dumped resolved slots, only `town.prop.hall.rise_stair` changed. Original source and focused diff are saved alongside the crops. No slot metadata, installed art, or protected Claude files were edited. No commit.

Evidence: `rise-stair-before-after.png`, the native `before_town.prop.hall.rise_stair.png` and `after_town.prop.hall.rise_stair.png`, `audit_contact.png`, and `audit_detail.png`. These are isolated slot crops, not gameplay captures.

Verification: ran `python tools/debug/run_checks.py art_slots building_template town_props --jobs 1 --fixed-fps 30` with HT_HIGHBANK_V2 absent and set to 1. Both runs returned runner FAIL 3, exit 1, despite all assertions reporting success: Python's private temporary directories prevented the sandboxed Godot child creating user data, and Godot could not read the root certificate store. Logs are in checks-v1 and checks-v2.

Retried the unchanged runner through `run_isolated_checks.py`, which only allocates private directories with inherited ACLs in this evidence folder. In both modes all three checks exited 0 and printed their successful RESULT lines. Their only engine error was `Failed to read the root certificate store`; the unmodified runner therefore still returned FAIL 3, exit 1. See checks-v1-acl and checks-v2-acl. No failure filtering or assertion changes were made.

Unverified: a clean engine/runner pass outside these sandbox environment errors, the stair in a real game window, movement clearance alongside the painted walls, and Preston's visual approval. Painted walls are inside the existing image; collision and placement did not change. Next safe step: Claude can run the same checks outside the sandbox and inspect Tower Rise in a window.

_Trimmed 2026-10-29 at Preston's request: the before shots, check logs and helper scripts were moved out of the repo. Only this README and rise-stair-before-after.png stay._
