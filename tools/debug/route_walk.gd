extends SceneTree
## Walks the courier along the refined meadow lane with ordinary movement input
## (the move_* actions, no teleporting) and reports any point it gets stuck.
## Usage: Godot.exe --path . --script res://tools/debug/route_walk.gd
## Saves user://route_captures/walk_end.png at the River Road.

# The lane's centre, the same curve as build_meadow.py, in world coordinates.
const P := [Vector2(-768, 512), Vector2(-518, 520), Vector2(-268, 190), Vector2(24, 192)]


func _initialize() -> void:
	_run()


func _point(t: float) -> Vector2:
	var u := 1.0 - t
	return u * u * u * P[0] + 3.0 * u * u * t * P[1] + 3.0 * u * t * t * P[2] + t * t * t * P[3]


func _steer(dir: Vector2) -> void:
	for a in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(a)
	if dir.x < -0.05: Input.action_press("move_left", -dir.x)
	if dir.x > 0.05: Input.action_press("move_right", dir.x)
	if dir.y < -0.05: Input.action_press("move_up", -dir.y)
	if dir.y > 0.05: Input.action_press("move_down", dir.y)


func _run() -> void:
	var route: Node = load("res://scenes/first_route_prototype.tscn").instantiate()
	root.add_child(route)
	await create_timer(4.0, true).timeout
	var courier: Node2D = route.get_node("Player")
	print("start ", courier.global_position)
	var stuck := 0
	for i in range(1, 41):
		var target := _point(i / 40.0)
		var t0 := Time.get_ticks_msec()
		var last := courier.global_position
		var last_move := t0
		while courier.global_position.distance_to(target) > 6.0:
			_steer((target - courier.global_position).normalized())
			await physics_frame
			if courier.global_position.distance_to(last) > 0.5:
				last = courier.global_position
				last_move = Time.get_ticks_msec()
			if Time.get_ticks_msec() - last_move > 1500:
				print("STUCK near ", courier.global_position.round(), " heading for ", target.round())
				stuck += 1
				break
	_steer(Vector2.ZERO)
	print("end ", courier.global_position.round(), " stuck points ", stuck)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("user://route_captures/walk_end.png"))
	quit()
