extends SceneTree
## Walks the new Tower Rise climb in a window and saves three stills for Preston (Claude, 2026-10-29;
## docs/design/vast-scale-2026-10-27/RISE_CLIMB_SLICE.md slice 1, step 6): the stair's foot looking up, the terrace,
## the doors. The walk starts on the Street, goes up the steps onto the Rise, up both flights to the doors, through them
## into the hall's room, back out onto the landing, and down again to the Street. Not a check: it prints every step it
## could not take and where each part ended, and the stills are for looking at.
##   HT_HIGHBANK_V2=1 Godot --path . --fixed-fps 30 --script res://tools/debug/rise_climb_capture.gd
## (with APPDATA pointed at a scratch folder, so the walk's autosaves leave the real save alone)

const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const OUT := "res://docs/design/vast-scale-2026-10-27/rise-climb/"
const N := Vector2i(0, -1)
const S := Vector2i(0, 1)

var town: Node
var problems: Array = []


func _initialize() -> void:
	if not Layout.v2():
		print("rise_climb_capture needs Highbank v2 (HT_HIGHBANK_V2=1)")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	# The crew met and the Tower seen, so no scene takes the walk over on the way up.
	TeamState.data["story"] = {"met_crew": true, "tower_seen": true}
	town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	current_scene = town
	await _frames(10)
	# The town opens on the Street, away from the steps: onto the Rise, then down its steps to the Street's top.
	await town.enter_area("hall_rise", "rise_steps")
	await _frames(10)
	await _walk(S, 1)
	await _frames(20)
	_say("down the steps to the Street")
	await _settle()
	await _snap("00_street_top", true)
	# A still by the Street's first building, for its new ground shadow; then back to the steps.
	var at: Vector2i = town.team[0]["pos"]
	for p in Layout.PLACES:
		if String(p.get("kind", "")) == "building":
			town.team[0]["pos"] = Vector2i(p["door"]) + Vector2i(2, 2)
			town._place(town.team[0])
			await _settle()
			await _snap("00b_street_%s" % String(p["id"]), true)
			break
	town.team[0]["pos"] = at
	town._place(town.team[0])
	await _settle()
	if Layout.area_id() != "street":
		problems.append("the steps down from the Rise ended in %s, not the street" % Layout.area_id())
	# Up the Street's steps onto the Rise.
	for k in 4:
		if Layout.area_id() == "hall_rise":
			break
		await _step(N)
	await _frames(20)
	_say("onto the Rise")
	await _walk(N, 2)                      # to the stair's foot, (12,27)
	await _settle()
	await _snap("01_stair_foot")
	await _walk(N, 12)                     # up step 1's flight to the middle of the terrace, (12,15)
	await _settle()
	await _snap("02_terrace")
	await _walk(N, 13)                     # up step 2's flight onto the landing under the doors, (12,2)
	await _settle()
	await _snap("03_doors")
	await _walk(N, 2)                      # onto the door tile, (12,0)
	_say("at the doors")
	town.act_use()
	var room := await _next_scene()
	_say("inside: %s, room %s" % [room.name if room != null else "none", str(room.get("room_id")) if room != null else "-"])
	await _frames(30)
	await _snap("04_hall_room", true)
	if room != null and room.has_method("leave"):
		room.leave()
		town = await _next_scene()
		await _frames(40)
		_say("back out")
		await _snap("05_back_out", true)
		if Layout.area_id() != "hall_rise" or town.team[0]["pos"] != Vector2i(12, 1):
			problems.append("out of the hall at %s %s, not hall_rise (12,1)" % [Layout.area_id(), str(town.team[0]["pos"])])
		town.poll_input = false
		await _walk(S, 29)                 # all the way down and over the south edge
		await _frames(20)
		_say("down again")
		if Layout.area_id() != "street":
			problems.append("the walk down ended in %s, not the street" % Layout.area_id())
	else:
		problems.append("the doors did not open into the hall's room")
	print("RESULT: %s" % ("walked up, in, out and down" if problems.is_empty() else "; ".join(problems)))
	quit(1 if not problems.is_empty() else 0)


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## One step `d`; logs it when the leader did not move (a wall) and the area has not changed (an exit).
func _step(d: Vector2i) -> void:
	var was: Vector2i = town.team[0]["pos"]
	var area := Layout.area_id()
	await town.act_move(d)
	await _frames(2)
	if Layout.area_id() != area:   # no fade with poll_input off: the step's tween can land after the arrival, so re-place
		for e in town.team:
			town._place(e)
	if Layout.area_id() == area and town.team[0]["pos"] == was:
		problems.append("%s blocked at %s going %s" % [area, str(was), str(d)])


func _walk(d: Vector2i, n: int) -> void:
	for k in n:
		await _step(d)


## Lets the camera and the look-up lean finish easing (0.4 s) and the walk cycle stop.
func _settle() -> void:
	await _frames(24)


func _say(what: String) -> void:
	var lead: Dictionary = town.team[0] if is_instance_valid(town) and town.get("team") != null and not town.team.is_empty() else {}
	print("%s: %s %s, view top %.0f" % [what, Layout.area_id(), str(lead.get("pos", "-")),
		-town._world.position.y if is_instance_valid(town) and town.get("_world") != null else 0.0])


## Waits for the scene change a door or leave() starts (a fade, then the new scene builds), then its fade back in.
func _next_scene() -> Node:
	var was := current_scene
	for k in 240:
		await process_frame
		if current_scene != was and current_scene != null and current_scene.is_node_ready():
			await _frames(30)
			return current_scene
	return null


## Saves the window as it was drawn. `scratch`: proof for the report, kept out of the design folder.
func _snap(name: String, scratch := false) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var dir := OS.get_environment("RISE_SCRATCH") if scratch else ProjectSettings.globalize_path(OUT)
	if dir == "":
		return
	img.save_png(dir.path_join(name + ".png"))
	print("saved %s %s" % [name, str(img.get_size())])
