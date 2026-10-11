extends SceneTree
func _initialize()->void:
	for m in ResourceUID.get_method_list():
		if "cache" in m.name or "id" in m.name or "path" in m.name:print(m.name)
	var resource:=load("res://default_bus_layout.tres")
	print("Audio layout path: ",resource.resource_path)
	print("Audio UID present: ",ResourceUID.has_id(ResourceUID.text_to_id("uid://blm6ps3r8bf7l")))
	quit()
