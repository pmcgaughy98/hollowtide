extends SceneTree
const State := preload("res://scripts/town/team_state.gd")
var bad := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func key(pressed: bool) -> void:
	var e := InputEventKey.new()
	e.keycode=KEY_E
	e.pressed=pressed
	Input.parse_input_event(e)
func walk(room: Node, to: Vector2i) -> bool:
	var start: Vector2i=room.team[0].pos
	var came := {start:start}
	var q: Array=[start]
	while not q.is_empty():
		var c: Vector2i=q.pop_front()
		if c==to: break
		for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var n: Vector2i = c+d
			if not came.has(n) and room._open(n): came[n]=c; q.append(n)
	if not came.has(to): return false
	var path: Array=[]
	var p := to
	while p!=start: path.push_front(p); p=came[p]
	for step in path:
		await room.act_move(step-room.team[0].pos)
		await frames(2)
	return true
func _run() -> void:
	State.start([[0,0],[1,0]])
	for id in ["home","hall"]:
		var room: Node2D=load("res://scenes/town_room.tscn").instantiate()
		room.room_id=id
		room.poll_input=false
		root.add_child(room)
		await frames(8)
		for spot in room.room().spots:
			var done := false
			var r: Rect2i=spot.rect
			for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				for y in range(r.position.y,r.end.y):
					for x in range(r.position.x,r.end.x):
						var at: Vector2i = Vector2i(x,y)+d
						if done or r.has_point(at) or not room._open(at): continue
						if not await walk(room,at): continue
						room.team[0].facing=room._facing_of(-d)
						room._place(room.team[0])
						room.poll_input=true
						key(true)
						await frames(3)
						key(false)
						await frames(3)
						var ok: bool=room.panel.get("id","")==spot.id
						print("PASS " if ok else "FAIL ",id," walk and real E: ",spot.id)
						if not ok: bad+=1
						room.poll_input=false
						room.panel={}
						done=true
			if not done: bad+=1; print("FAIL unreachable ",id," ",spot.id)
		await walk(room,room.room().door)
		var left: bool=room.get_meta("left",false) and State.data.arrive_at==id
		print("PASS " if left else "FAIL ",id," walks back through original exit")
		if not left: bad+=1
		room.queue_free()
		await frames(12)
	print("SPOTS all ok" if bad==0 else "SPOTS failed")
	quit(0 if bad==0 else 1)
