from pathlib import Path
W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"route1-spaced-landing-review";P=Path(r"C:/Users/pmcga/dev/hollowtide")
for file in D.glob("after-*.png"):(D/(file.stem+".initial.png")).write_bytes(file.read_bytes())
p=P/"scripts/route1_landing_loop.gd";t=p.read_text();assert t.count("label.position=Vector2(280,480)")==1
(D/"candidate/route1_landing_loop.initial.gd").write_text(t)
p.write_text(t.replace("label.position=Vector2(280,480)","label.position=Vector2(248,486)"))
t=(W/"area_transition_walkthrough.gd").read_text()
t=t.replace("area-transition-review","route1-spaced-landing-review")
t=t.replace("var approach_frames := 0","var approach_frames := 0\nvar relay_walk_frames := 0\nvar relay_start_frames := 0")
insert="""func canopy_check(which: String, expected_faded: bool, label: String) -> bool:
	await frames(22)
	var loop: Node=route.get_node("RiverCrossing/LandingLoop")
	var tree: Sprite2D=loop.get("_landing_tree" if which=="landing" else "_tree")
	var material: ShaderMaterial=loop.get("_landing_material" if which=="landing" else "_canopy_material")
	var opacity: float=material.get_shader_parameter("canopy_opacity")
	var okay: bool=tree.material==material and (opacity<=0.351 if expected_faded else opacity>=0.999)
	steps.append({"canopy":which,"check":label,"opacity":opacity,"material_bound":tree.material==material,"passed":okay})
	if not okay:failed=true
	await capture(label)
	return okay
"""
t=t.replace("func _run() -> void:",insert+"func _run() -> void:")
start=t.index('\tif not await path([Vector2(-640,512)')
end=t.index('\tif not await path([Vector2(432,416)',start)
new="""	if not await path([Vector2(-640,512),Vector2(-640,336),Vector2(-432,336),Vector2(-432,192),Vector2(48,192)]):finish();return
	approach_frames=total_walk_frames-approach_start
	if not await interaction(Vector2(64,200),"ROUTE 1","levee_entrance_read"):finish();return
	relay_start_frames=total_walk_frames
	if model=="Male":
		if not await path([Vector2(184,192),Vector2(272,192),Vector2(320,192),Vector2(360,220),Vector2(392,260),Vector2(414,245)]):finish();return
		if not await interaction(Vector2(423,215),"Several old","water_mark_observed"):finish();return
		if not await path([Vector2(410,240),Vector2(402,296),Vector2(430,318),Vector2(430,341),Vector2(427,366),Vector2(414,383),Vector2(395,393),Vector2(344,352)]):finish();return
	else:
		if not await path([Vector2(184,192),Vector2(272,192),Vector2(306,272),Vector2(344,352)]):finish();return
	if not await path([Vector2(318,388),Vector2(320,456)]):finish();return
	var notice_flags:=flags()
	if not await interaction(Vector2(320,456),"OLD LANDING FOOTPATH"):finish();return
	var notice_safe: bool=notice_flags==flags()
	steps.append({"notice_preserves_flags":notice_safe})
	if not notice_safe:failed=true;finish();return
	if not await path([Vector2(354,496),Vector2(378,540)]):finish();return
	if not await interaction(Vector2(398,550),"You slide","delivered"):finish();return
	relay_walk_frames=total_walk_frames-relay_start_frames
	if not await path([Vector2(414,574),Vector2(416,592)]):finish();return
	if model=="Male":
		if not await interaction(Vector2(416,592),"A two-note","heard_calls"):finish();return
	if not await canopy_check("landing",true,"landing-canopy-first"):finish();return
	if not await path([Vector2(420,510)]):finish();return
	if not await canopy_check("landing",false,"landing-canopy-restored"):finish();return
	if not await path([Vector2(424,464),Vector2(424,416)]):finish();return
"""
t=t[:start]+new+t[end:]
start=t.index('\tif not await path([Vector2(395,393),Vector2(328,334)')
end=t.index('\tif not await interaction(Vector2(272,112)',start)
new="""	var loop: Node=route.get_node("RiverCrossing/LandingLoop")
	var bound: bool=loop.get("_tree").material==loop.get("_canopy_material") and loop.get("_landing_tree").material==loop.get("_landing_material")
	steps.append({"both_canopies_bound_after_route_return":bound})
	if not bound:failed=true;finish();return
	if not await path([Vector2(424,464),Vector2(420,510),Vector2(416,592)]):finish();return
	if not await canopy_check("landing",true,"landing-canopy-after-return"):finish();return
	if not await path([Vector2(420,510),Vector2(424,464),Vector2(424,416),Vector2(395,393),Vector2(414,383),Vector2(427,366),Vector2(430,341)]):finish();return
	if not await canopy_check("bank",true,"bank-canopy-after-return"):finish();return
	if not await path([Vector2(368,280),Vector2(368,112)]):finish();return
"""
t=t[:start]+new+t[end:]
t=t.replace('"route_approach_walk_frames":approach_frames,','"route_approach_walk_frames":approach_frames,"levee_sign_to_relay_walk_frames":relay_walk_frames,')
(W/"route1_spacing_walkthrough.gd").write_text(t)
# Use the same physical-input movement helper to enter the relocated encounter.
e=t[:t.index("func _run() -> void:")]
e+="""func _run() -> void:
	journey=load("res://scenes/world_journey.tscn").instantiate()
	journey.initial_area="route1";journey.set_courier_model(model)
	root.add_child(journey);current_scene=journey;route=journey.route
	await frames(45)
	if not await path([Vector2(-640,512),Vector2(-640,336),Vector2(-432,336),Vector2(-432,192),Vector2(48,192),Vector2(184,192),Vector2(272,192),Vector2(306,272),Vector2(344,352),Vector2(304,392),Vector2(276,368),Vector2(240,344)]):
		await finish_encounter(false);return
	var creature: Area2D=route.get_node("CinderhideEncounter")
	var before:=flags()
	var near: bool=creature.get("_player_nearby") and creature.get_node("Prompt").visible
	await capture("hollow-encounter-before")
	await key(KEY_E);await frames(35)
	var battle: CanvasLayer=route.get_node("BattleScreen")
	var okay: bool=near and battle.visible and battle.get("_foe")==creature.get("creature") and player().chibi_model==model and before==flags()
	steps.append({"ordinary_encounter_started":okay,"nearby_prompt":near,"creature_resource_matches":battle.get("_foe")==creature.get("creature"),"quest_flags_preserved":before==flags()})
	await capture("hollow-battle-start")
	await finish_encounter(okay)
func finish_encounter(okay: bool) -> void:
	release()
	var file:=FileAccess.open(BASE+model.to_lower()+"-encounter.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":okay and not failed,"model":model,"ordinary_input_only":true,"test_teleports":0,"quest_overrides":0,"steps":steps},"\\t"));file.close();file=null
	print("SPACED_HOLLOW_ENCOUNTER ",model," ",okay and not failed)
	# Unpause only to clean up this isolated review after its final assertion.
	paused=false
	journey.queue_free();current_scene=null;journey=null;route=null
	await frames(12);quit(0 if okay and not failed else 1)
"""
(W/"route1_spacing_encounter.gd").write_text(e)
print("Prepared ordinary-input full/simple route and encounter checks; moved the label clear of tall grass.")
