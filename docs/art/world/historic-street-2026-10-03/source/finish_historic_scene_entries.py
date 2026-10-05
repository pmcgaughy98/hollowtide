from pathlib import Path
import json,hashlib,shutil
P=Path(r"C:/Users/pmcga/dev/hollowtide");W=Path(r"C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an");D=W/"historic-street-review";(D/"direct-entry").mkdir()
# Keep an editor-run of each map inside the same connected journey.
p=P/"scripts/world_area.gd"
assert hashlib.sha256(p.read_bytes()).hexdigest()==json.loads((D/"baseline.json").read_text())["scripts/world_area.gd"]
shutil.copy2(p,D/"world_area.gd.before");s=p.read_text()
s=s.replace("func _ready() -> void:\n","func _ready() -> void:\n    if get_parent() == get_tree().root:\n        call_deferred(\"_open_journey\")\n        return\n",1)
s+='''\nfunc _open_journey() -> void:
    var connected:Node2D=load("res://scenes/world_journey.tscn").instantiate()
    connected.initial_area=area_id
    get_tree().root.add_child(connected)
    get_tree().current_scene=connected
    queue_free()
'''
p.write_text(s,encoding="utf-8",newline="\n")
p=P/"scripts/historic_street.gd";s=p.read_text()
s=s.replace("func _ready() -> void:\n","func _ready() -> void:\n\tif get_parent() == get_tree().root:\n\t\tcall_deferred(\"_open_journey\")\n\t\treturn\n",1)
s+='''\nfunc _open_journey() -> void:
\tvar connected:Node2D=load("res://scenes/world_journey.tscn").instantiate()
\tconnected.initial_area="historic_street"
\tget_tree().root.add_child(connected)
\tget_tree().current_scene=connected
\tqueue_free()
'''
p.write_text(s,encoding="utf-8",newline="\n")
p=P/"scripts/first_route_prototype.gd";s=p.read_text()
assert s.count("var city_activity: Node2D")==1
s=s.replace("var city_activity: Node2D\n\n","")
s=s.replace("extends Node2D\n","extends Node2D\n\nvar city_activity: Node2D\n",1)
p.write_text(s,encoding="utf-8",newline="\n")
