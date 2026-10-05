func historic_loop() -> bool:
    var unchanged:=flags()
    if not await path([Vector2(880,512),Vector2(880,64),Vector2(880,24)]):return false
    if not await exit_area("move_up","historic_street"):return false
    var area:Node2D=journey.active_area
    var area_id:=area.get_instance_id()
    if not await panel_check(KEY_P,"_party_panel"):return false
    if not await interaction(Vector2(384,664),"CITY ADDRESS CHECK"):return false
    if not await path([Vector2(416,664),Vector2(416,480),Vector2(224,480)]):return false
    if not await interaction(Vector2(224,428),"PUBLIC STREET LEDGER"):return false
    await capture("historic-ledger")
    # The visible facade blocks northward walking.
    Input.action_press("move_up");await frames(45);release()
    var facade:bool=player().position.y>=407.9 and player().position.y<429
    steps.append({"historic_ledger_facade_collision":facade})
    if not facade:failed=true;return false
    if not await path([Vector2(224,480),Vector2(544,480)]):return false
    if not await interaction(Vector2(544,428),"REPAIRED SHOP"):return false
    await capture("historic-shop")
    if not await panel_check(KEY_J,"_notes_panel"):return false
    await key(KEY_J)
    var findings:bool=route.get("_notes_body").text.contains("Shop lintel: old 6") and route.get("_notes_body").text.contains("Ledger: old 6")
    await key(KEY_E)
    steps.append({"historic_findings_in_shared_notes":findings})
    if not findings:failed=true;return false
    if not await path([Vector2(544,480),Vector2(416,480),Vector2(416,704),Vector2(384,784),Vector2(384,866)]):return false
    if not await exit_area("move_down","riverfront"):return false
    if not await path([Vector2(880,512),Vector2(640,512),Vector2(512,456),Vector2(512,400)]):return false
    await key(KEY_E)
    if not route.get("_choices").visible or route.get("_choices").get_child_count()!=2:
        failed=true;return false
    # Choose the incorrect retained lintel first through the ordinary UI.
    await key(KEY_ENTER)
    var wrong:bool=not area.handoff_verified and area.last_submitted_number==6 and route.get("_body").text.contains("handoff is still open")
    steps.append({"wrong_old_number_keeps_activity_open":wrong})
    await capture("historic-wrong-number")
    if not wrong:failed=true;return false
    await key(KEY_E);await key(KEY_E);await key(KEY_DOWN);await key(KEY_ENTER)
    var correct:bool=area.handoff_verified and area.last_submitted_number==18 and flags()==unchanged
    steps.append({"current_number_verifies_handoff":correct,"original_route_flags_exact":flags()==unchanged})
    await capture("historic-handoff")
    if not correct:failed=true;return false
    await key(KEY_E)
    if not await path([Vector2(512,456),Vector2(640,512),Vector2(880,512),Vector2(880,24)]):return false
    if not await exit_area("move_up","historic_street"):return false
    var same:bool=journey.active_area.get_instance_id()==area_id and area.handoff_verified and area.get("_status").text=="18 / VERIFIED"
    steps.append({"cached_historic_area_and_verified_board":same})
    if not same:failed=true;return false
    if not await path([Vector2(416,848),Vector2(416,664),Vector2(416,480),Vector2(112,480),Vector2(112,240),Vector2(104,144),Vector2(72,144)]):return false
    await frames(24)
    var tree:Sprite2D=area.get("_trees")[0]
    var opacity:float=tree.material.get_shader_parameter("canopy_opacity")
    var faded:bool=opacity<=0.351
    steps.append({"historic_canopy_after_return":faded,"opacity":opacity})
    await capture("historic-canopy-after-return")
    if not faded:failed=true;return false
    if not await path([Vector2(104,144),Vector2(104,224)]):return false
    await frames(24)
    var restored:bool=tree.material.get_shader_parameter("canopy_opacity")>=0.999
    steps.append({"historic_canopy_restored":restored})
    if not restored:failed=true;return false
    if not await path([Vector2(112,480),Vector2(168,568),Vector2(184,664),Vector2(304,728),Vector2(384,784),Vector2(384,866)]):return false
    if not await exit_area("move_down","riverfront"):return false
    if not await path([Vector2(880,512),Vector2(816,512)]):return false
    var preserved:bool=flags()==unchanged and root.get_node("PlayerParty").active_member().get_instance_id()==party_id
    steps.append({"historic_complete_loop_preserves_primary_route_and_party":preserved})
    if not preserved:failed=true;return false
    return true
