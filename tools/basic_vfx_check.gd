extends SceneTree
## Confirms ordinary-move scenes carry the basic sheets, and the ultimates do not.


func _init() -> void:
	var ember: Node = load("res://scenes/effects/cinderhide_ember_flick.tscn").instantiate()
	var coal: Node = load("res://scenes/effects/cinderhide_coal_spit.tscn").instantiate()
	var slash: Node = load("res://scenes/effects/cinderhide_vent_rake.tscn").instantiate()
	var shaped: Node = load("res://scenes/effects/cinderhide_spineflare.tscn").instantiate()
	var strike: Node = load("res://scenes/effects/basic_hit_pop.tscn").instantiate()
	var roar: Node = load("res://scenes/effects/ironvent_furnace_roar.tscn").instantiate()
	var lunge: Node = load("res://scenes/effects/vitrecrag_plate_lunge.tscn").instantiate()
	var claw: Node = load("res://scenes/effects/ironvent_cinder_claw.tscn").instantiate()
	var glass: Node = load("res://scenes/effects/vitrecrag_molten_glass.tscn").instantiate()
	var nodes: Array[Node] = [ember, coal, slash, shaped, strike, roar, lunge, claw, glass]

	var ember_shot: Texture2D = _need_sheet(ember, "Shot")
	var ember_pop: Texture2D = _need_sheet(ember, "Pop")
	var coal_shot: Texture2D = _need_sheet(coal, "Shot")
	var coal_pop: Texture2D = _need_sheet(coal, "Pop")
	if ember_shot == null or ember_pop == null or coal_shot == null or coal_pop == null:
		_free_all(nodes)
		return
	if ember_shot.resource_path == coal_shot.resource_path:
		_free_all(nodes)
		push_error("ember and coal shots are the same sheet")
		quit(1)
		return
	if ember_pop.resource_path != coal_pop.resource_path:
		_free_all(nodes)
		push_error("hit pop is not shared")
		quit(1)
		return
	if not ember.get_node("Shot").get("loop"):
		_free_all(nodes)
		push_error("shot should loop")
		quit(1)
		return
	if ember.get_node("Pop").get("loop"):
		_free_all(nodes)
		push_error("pop should play once")
		quit(1)
		return
	if ember.get_node("Pop").visible or not ember.get_node("Shot").visible:
		_free_all(nodes)
		push_error("shot or pop visibility is wrong")
		quit(1)
		return
	if slash.get_node_or_null("Shot") != null:
		_free_all(nodes)
		push_error("slash scene should keep its still, no shot")
		quit(1)
		return
	var slash_pop: Texture2D = _need_sheet(slash, "Pop")
	if slash_pop == null:
		_free_all(nodes)
		return
	if slash_pop.resource_path == ember_pop.resource_path:
		_free_all(nodes)
		push_error("slash used the hit pop")
		quit(1)
		return
	if shaped.get_node_or_null("Shot") != null:
		_free_all(nodes)
		push_error("shaped scene should keep its still")
		quit(1)
		return
	var shaped_pop: Texture2D = _need_sheet(shaped, "Pop")
	if shaped_pop == null or shaped_pop.resource_path != ember_pop.resource_path:
		_free_all(nodes)
		if shaped_pop != null:
			push_error("shaped scene missed the hit pop")
			quit(1)
		return
	if _need_sheet(strike, "Pop") == null or not strike.get_node("Pop").visible:
		_free_all(nodes)
		if strike.get_node_or_null("Pop") != null:
			push_error("strike pop should start visible")
			quit(1)
		return
	for untouched in [roar, lunge, claw, glass]:
		if untouched.get_node_or_null("Pop") != null or untouched.get_node_or_null("Shot") != null:
			_free_all(nodes)
			push_error("%s was given a basic sheet" % untouched.name)
			quit(1)
			return
	_free_all(nodes)
	print("BASIC_VFX_OK")
	quit(0)


func _need_sheet(node: Node, child_name: String) -> Texture2D:
	var sprite: Node = node.get_node_or_null(child_name)
	if sprite == null:
		push_error("%s missing %s" % [node.name, child_name])
		quit(1)
		return null
	var texture: Texture2D = sprite.get("texture")
	if texture == null or texture.get_width() != 192 or texture.get_height() != 192:
		push_error("%s %s sheet is wrong" % [node.name, child_name])
		quit(1)
		return null
	return texture


func _free_all(nodes: Array[Node]) -> void:
	for node in nodes:
		if is_instance_valid(node):
			node.free()
