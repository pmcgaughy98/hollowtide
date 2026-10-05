from pathlib import Path
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an")
p=P/"scripts/world_journey.gd";t=p.read_text()
t=t.replace('@export_enum("Male", "Female") var courier_model := "Male"','@export_enum("Male", "Female") var courier_model := "Male"\n@export_enum("hometown", "route1", "riverfront") var initial_area := "hometown"')
old='_activate("hometown", Vector2(224, 280), Vector2.DOWN)'
new='''var arrival: Vector2 = {"hometown":Vector2(224,280),"route1":Vector2(-720,512),"riverfront":Vector2(320,512)}[initial_area]
    _activate(initial_area, arrival, Vector2.DOWN if initial_area == "hometown" else Vector2.RIGHT)'''
assert old in t;t=t.replace(old,new);p.write_text(t,encoding="utf-8")
p=P/"scripts/first_route_prototype.gd";t=p.read_text()
old='\t_build_hud()\n\t_refresh_objective()\n\n\nfunc _process'
new='''\t_build_hud()
\t_refresh_objective()
\t# F6 / a direct Route 1 launch also gets the same real area entrances.
\tif get_parent() is Window:
\t\tcall_deferred("_open_standalone_journey")


func _open_standalone_journey() -> void:
\tvar journey: Node2D = load("res://scenes/world_journey.tscn").instantiate()
\tjourney.set("initial_area", "route1")
\tjourney.call("set_courier_model", $Player.chibi_model)
\tvar error := get_tree().change_scene_to_node(journey)
\tif error != OK:
\t\tjourney.free()
\t\tpush_error("Could not open the connected Route 1 journey.")


func _process'''
assert old in t;t=t.replace(old,new);p.write_text(t,encoding="utf-8")
p=W/"archive_area_transitions.py";t=p.read_text()
old='assert hashlib.sha256((P/"project.godot").read_bytes()).hexdigest()==before["project.godot"]'
new='''previous=(D/"before/project.godot").read_text().splitlines()
current=(P/"project.godot").read_text().splitlines()
assert [x for x in previous if not x.startswith("run/main_scene=")]==[x for x in current if not x.startswith("run/main_scene=")]
(D/"concurrent-launch-setting.json").write_text(json.dumps({"changed_by_external_editor":True,"baseline":[x for x in previous if x.startswith("run/main_scene=")][0],"current":[x for x in current if x.startswith("run/main_scene=")][0],"agent_did_not_write_project_setting":True},indent=2))'''
assert old in t;t=t.replace(old,new)
t=t.replace("project.godot remains exact to the turn baseline, retaining the user's concurrent Oxbow Archon review launch setting.","The editor changed only project.godot's launch pointer during the turn, from the Oxbow Archon review back to Route 1. Codex preserved that external change and did not write the setting. Direct Route 1 launch now opens WorldJourney at the route entrance; New Game still begins at home.")
t=t.replace("The editor's default launch is left on its current review scene.","The editor's current Route 1 launch is preserved and now joins the same connected WorldJourney. New Game begins at home.")
t=t.replace("the concurrent Oxbow Archon launch setting are preserved.","the editor's concurrent launch setting are preserved. Direct Route 1 launch also opens the connected journey at the route entrance.")
p.write_text(t,encoding="utf-8")
print("Connected direct Route 1 launch without editing the project setting.")
