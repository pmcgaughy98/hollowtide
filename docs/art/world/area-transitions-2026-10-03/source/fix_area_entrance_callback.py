from pathlib import Path
p=Path(r"C:/Users/pmcga/dev/hollowtide/scripts/world_journey.gd")
t=p.read_text()
old='''    active_area.get_node("Player").set_physics_process(false)
    active_area.process_mode = Node.PROCESS_MODE_DISABLED
    call_deferred("_perform_travel", destination, arrival, facing)

func _perform_travel(destination: String, arrival: Vector2, facing: Vector2) -> void:
    _fade.mouse_filter'''
new='''    active_area.get_node("Player").set_physics_process(false)
    call_deferred("_perform_travel", destination, arrival, facing)

func _perform_travel(destination: String, arrival: Vector2, facing: Vector2) -> void:
    # Entrance signals fire during physics. Disable collisions only after that callback.
    active_area.process_mode = Node.PROCESS_MODE_DISABLED
    _fade.mouse_filter'''
assert old in t
p.write_text(t.replace(old,new),encoding="utf-8")
print("Deferred source-area disabling until after the entrance physics callback.")
