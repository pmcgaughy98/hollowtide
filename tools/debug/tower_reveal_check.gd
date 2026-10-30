extends SceneTree
## The Wayline Tower scene (Claude, 2026-10-26, placeholder factory lane S; scripts/story/tower_reveal.gd). In Highbank:
## with the v2 switch off it never starts by itself. Run, it plays once: the two walk to the Tower's doors, the camera
## climbs the Tower and comes back down to them while every line is read, control comes back (no scene, no camera
## override, the sky behind the Tower gone, the town's camera on the leader) and tower_seen is set. With tower_seen
## set it does not play again. Under Reduce motion the camera cuts to the top and back instead.
## With HT_HIGHBANK_V2=1 and lane A's Tower Rise in, it also checks the scene is due there before the flag.
## 2026-10-27, the approved tower ("ride the climb", TOWER_DESIGN.md section 8), measured frame by frame from the
## world's offset at 30 fps: the camera settles on the doors in 0.7 s in the lean view (top 48 on Tower Rise), climbs
## four legs to the view tops TowerReveal.leg_tops() gives (-84, -226, -322, -513 on Tower Rise) in 1.9, 1.9, 1.4 and
## 2.4 s with pauses of 0.4, 0.4 and 0.5 s, holds at least 1.5 s with the vane's tip at least 8 px under the top edge
## and the Waiting Lamp on screen, and comes down in 4.5 s: about 15.6 s of camera. On the way the hoist basket rises
## from the yard to the hoist door with the first leg, a parcel slides down the chute on screen during the second, and
## on the third a cradle leaves the Reel Deck and slides out of the picture while the flood bell swings. The camera
## climbs a TowerParts tower, exactly one: the scene's own with the town's own hall hidden (v1's old Hall, or since
## 2026-10-29 the new Tower's foot on Tower Rise, RISE_CLIMB_SLICE.md slice 1, until slice 2 retimes the climb for the
## new Tower). On the new Rise the doors are on row 0, so the old tower's frame stands at (96, -696), the view tops are
## -78 at the doors and -276, -418, -514 and -705 up the legs. Everything the scene added is freed at its end, and
## freeing the town mid-climb ends the scene without an
## error. Under Reduce motion: a cut to the top, at least 2.5 s there, a cut back.
## Pass 9 (2026-10-27): the two stand a row back, one tile out past each door tile, and share no pixel (W1); no box
## comes up on the way down, the last lines wait for the camera to be back on the two (W2).
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/tower_reveal_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Reveal := preload("res://scripts/story/tower_reveal.gd")
const TP := preload("res://scripts/town/tower_parts.gd")
const HubTown := preload("res://scripts/town/hub_town.gd")
const STORY := {"met_crew": true, "parcel": "stolen", "guild_trial": true}   # past the board scene: no crew at the board
const FPS := 30.0
const LEFT_OVER := ["TowerCam", "TowerSky", "RevealTower", "RevealParcel", "RevealCradle"]
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _until(done: Callable, budget: int) -> bool:
	for k in budget:
		if done.call():
			return true
		await process_frame
	return done.call()


## Play the scene to its end, reading each line after a few frames as a player would, and record every frame: the
## view's top edge (world px), the stage, and on the tower being climbed the basket's row, the scene's parcel and
## cradle, and the bell's state (tower px).
func _play(town: Node) -> Dictionary:
	var out := {"frames": 0, "read": 0, "rec": [], "end": Vector2.ZERO}
	Reveal.run(town)
	out["started"] = town.cutscene and Reveal.seen(town) and Reveal.playing
	var tower: Variant = Reveal.town_tower(town)
	if tower == null:
		tower = town._world.get_node_or_null("RevealTower")
	out["tower"] = tower
	out["tower_found"] = tower != null   # read now: once the scene frees its own tower, it compares equal to null
	out["towers"] = _towers(town._world)
	if int(out["towers"]) != 1:
		print("  TowerParts towers in the world: %s" % str(_tower_paths(town._world, town._world)))
	var old: Variant = _old_hall(town)
	out["old_hidden"] = is_instance_valid(old) and not old.visible
	for k in 30 * 90:
		await process_frame
		out["frames"] = k + 1
		var row := {"top": -town._world.position.y, "stage": Reveal.stage, "talk": not town.talk.is_empty()}
		if not town.team.is_empty():
			var lead: Dictionary = town.team[0]
			row["feet"] = (lead["node"] as Node2D).position.y + town._extent_of(lead["still"][lead["facing"]]).end.y   # as hub_town's _lean_room
			if town.team.size() > 1:
				var mate: Dictionary = town.team[1]
				row["feet2"] = (mate["node"] as Node2D).position.y + town._extent_of(mate["still"][mate["facing"]]).end.y
				# Pass 9 W1: once, as the first line comes up, the opaque pixels the two sprites share in the world.
				if Reveal.stage == "start" and row["talk"] and not out.has("overlap"):
					out["overlap"] = _shared_px(town, lead, mate)
		if is_instance_valid(tower):
			row["basket"] = (tower.get_node("Basket") as Node2D).position.y
			var parcel: Variant = tower.get_node_or_null("RevealParcel")
			if parcel != null:
				row["parcel"] = parcel.position.y
			var cradle: Variant = tower.get_node_or_null("Waylines/RevealCradle")
			if cradle != null:
				row["cradle"] = cradle.position
			row["bell"] = String(tower.get_node("Bell").get_meta("state", ""))
		out["rec"].append(row)
		if not town.talk.is_empty() and k % 6 == 0:
			UI.finish_line()
			town.talk.pop_front()
			out["read"] = int(out["read"]) + 1
		if not Reveal.playing:
			break
	await _frames(2)
	out["end"] = Vector2(town.VIEW) * 0.5 - town._world.position
	return out


## Pass 9 W1 (H9-07): the opaque pixels two team members' sprites share in the town's world, as drawn this frame.
func _shared_px(town: Node, a: Dictionary, b: Dictionary) -> int:
	var ma := _opaque_px(town, a["sprite"])
	var n := 0
	for p in _opaque_px(town, b["sprite"]):
		if ma.has(p):
			n += 1
	return n


## World px (town._world's) -> true for each opaque pixel of a sprite, one pixel of the rim the creature finish draws
## round it included.
func _opaque_px(town: Node, s: Sprite2D) -> Dictionary:
	var out := {}
	if s == null or s.texture == null:
		return out
	var img: Image = s.texture.get_image()
	if img == null:
		return out
	if img.is_compressed():
		img.decompress()
	var xf: Transform2D = (town._world as Node2D).global_transform.affine_inverse() * s.global_transform
	var off := s.offset - (Vector2(img.get_size()) * 0.5 if s.centered else Vector2.ZERO)
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a <= 0.0:
				continue
			var p: Vector2 = xf * (Vector2((img.get_width() - 1 - x) if s.flip_h else x, y) + off + Vector2(0.5, 0.5))
			for d in [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				out[Vector2i(floori(p.x), floori(p.y)) + d] = true
	return out


## Pass 9 W1: across every creature's town sprite (hub_town's set for it), the farthest its opaque pixels reach right
## of the sprite's middle facing `right_facing`, and left of it facing `left_facing`, plus the 1 px rim each way. Two
## creatures stood further apart than right + left never share a pixel. Returns [right, left, widest form right, left].
func _reach_out(right_facing: String, left_facing: String) -> Array:
	var best := [0.0, 0.0, "", ""]
	var dir := DirAccess.open("res://assets/sprites/arena")
	if dir == null:
		return best
	for form in dir.get_directories():
		var sets: String = HubTown._set_of(form)
		for k in 2:
			var path := "res://assets/sprites/arena/%s/%s/%s.png" % [form, sets, right_facing if k == 0 else left_facing]
			if not ResourceLoader.exists(path):
				continue
			var tex: Texture2D = load(path)
			var img := tex.get_image()
			if img.is_compressed():
				img.decompress()
			var used := img.get_used_rect()
			if used.size == Vector2i.ZERO:
				continue
			var mid := img.get_width() * 0.5
			var reach: float = (used.end.x - mid) + 1.0 if k == 0 else (mid - used.position.x) + 1.0
			if reach > float(best[k]):
				best[k] = reach
				best[k + 2] = form
	return best


## The towers standing in the world: nodes TowerParts placed (they carry the beacon).
func _towers(n: Node) -> int:
	var count := 1 if n.has_meta("beacon") and n.has_meta("apex") else 0
	for c in n.get_children():
		count += _towers(c)
	return count


## Where those towers are, for the report when there is not exactly one.
func _tower_paths(n: Node, base: Node) -> Array:
	var out: Array = []
	if n.has_meta("beacon") and n.has_meta("apex"):
		out.append("%s (visible %s)" % [base.get_path_to(n), n.is_visible_in_tree()])
	for c in n.get_children():
		out.append_array(_tower_paths(c, base))
	return out


## The old Hall picture of v1's map (building_exteriors.gd), or null.
func _old_hall(town: Node) -> Variant:
	var ext: Variant = town.get("_building_exteriors")
	if is_instance_valid(ext) and "buildings" in ext:
		var b: Variant = ext.buildings.get("hall", {})
		if b is Dictionary and is_instance_valid(b.get("base")) and not b["base"].has_meta("beacon"):
			return b["base"]
	return null


## Each run of 3 or more frames at one view top: [top, first frame, last frame].
func _rests(rec: Array) -> Array:
	var out: Array = []
	var start := 0
	for k in range(1, rec.size() + 1):
		if k == rec.size() or absf(float(rec[k]["top"]) - float(rec[start]["top"])) > 0.01:
			if k - start >= 3:
				out.append([float(rec[start]["top"]), start, k - 1])
			start = k
	return out


## The first rest at `top` (within 1 px) from frame `after` on, or [] for none.
func _rest_at(rests: Array, top: float, after: int) -> Array:
	for r: Array in rests:
		if int(r[1]) >= after and absf(float(r[0]) - top) <= 1.0:
			return r
	return []


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = STORY.duplicate()
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	town.force_scenes = true
	root.add_child(town)
	current_scene = town
	await _until(func() -> bool: return not town.team.is_empty(), 300)
	await _frames(4)
	# 1. Never by itself with the switch off; with it on, due on Tower Rise.
	var v2 := Layout.v2()
	if not v2:
		_ok("Highbank v2 off: the scene is never due (pending %s)" % Reveal.pending(town), not Reveal.pending(town))
	elif not Layout.area(Reveal.AREA).is_empty():
		town.enter_area(Reveal.AREA)
		await _frames(30)
		_ok("Highbank v2 on, on Tower Rise (%s): the scene is due before tower_seen" % Layout.area_id(), Reveal.pending(town))
	else:
		print("Highbank v2 is on but Tower Rise is not in yet; the scene is run directly")
	var rise := v2 and Layout.area_id() == Reveal.AREA
	# 2. Where the tower stands and the camera's plan.
	var geo := Reveal.geometry(town)
	var half := float(town.VIEW.y) * 0.5
	var door_top: float = geo["door_look"].y - half
	var tops: Array = []
	for leg: Dictionary in geo["legs"]:
		tops.append(float(leg["look"].y) - half)
	print("Tower origin %s, foot %s, beacon %s, apex %s; view tops: doors %.0f, legs %s" % [str(geo["origin"]), str(geo["foot"]), str(geo["beacon"]), str(geo["apex"]), door_top, str(tops)])
	_ok("The tower stands on the Hall's doors: its door axis %.0f over the doors' middle %.0f, the lamp over it (%.0f)" % [geo["origin"].x + TP.DOOR.get_center().x, geo["foot"].x, geo["beacon"].x],
		is_equal_approx(geo["origin"].x + TP.DOOR.get_center().x, geo["foot"].x) and is_equal_approx(geo["beacon"].x, geo["foot"].x))
	if rise:
		_ok("Tower Rise: the frame at (96, -696), the doors at (288, -42), the lamp 568 px over the door's middle; view tops %.0f (the lean's -144 plus TALK_ROOM), %s" % [door_top, str(tops)],
			geo["origin"] == Vector2(96, -696) and geo["origin"] + Vector2(TP.DOOR.position) == Vector2(288, -42)
			and is_equal_approx(geo["origin"].y + TP.DOOR.get_center().y - geo["beacon"].y, 568.0)
			and is_equal_approx(door_top, -144.0 + Reveal.TALK_ROOM) and tops == [-276.0, -418.0, -514.0, -705.0])
	# 3. Run it.
	Reveal.reduce_override = 0
	var got := await _play(town)
	var rec: Array = got["rec"]
	var rests := _rests(rec)
	var tower: Variant = got["tower"]
	_ok("It starts at once: a scene, tower_seen set (%s)" % got["started"], got["started"])
	if rise and Reveal.town_tower(town) != null:
		_ok("The camera climbs the town's own tower (towers in the world %d, the scene's own %s)" % [got["towers"], str(town._world.get_node_or_null("RevealTower"))],
			int(got["towers"]) == 1)
	else:   # v1's map, and Tower Rise's new foot (no beacon): the scene's own old tower, the town's hall hidden
		_ok("The camera climbs the scene's own tower, not the old Hall (towers in the world %d, the old Hall hidden %s)" % [got["towers"], got["old_hidden"]],
			int(got["towers"]) == 1 and got["tower_found"] and (got["old_hidden"] or _old_hall(town) == null))
	var at_doors := _rest_at(rests, door_top, 0)
	_ok("It settles on the doors in the lean view (top %.0f) in %.2f s (0.7)" % [door_top, (int(at_doors[1]) if not at_doors.is_empty() else -1) / FPS],
		not at_doors.is_empty() and int(at_doors[1]) <= int(Reveal.MOVE_IN * FPS) + 2)
	var legs: Array = []
	var after: int = int(at_doors[2]) if not at_doors.is_empty() else 0
	for k in tops.size():
		var r := _rest_at(rests, tops[k], after)
		legs.append(r)
		if not r.is_empty():
			after = int(r[2])
	_ok("Four legs, resting at view tops %s (found %s)" % [str(tops), str(legs.map(func(r: Array) -> String: return "-" if r.is_empty() else "%.0f@%d" % [r[0], r[1]]))],
		not legs.has([]))
	if not at_doors.is_empty() and not legs.has([]):
		# The camera leaves the doors from the last frame it is there before the first leg: a settle that lands early
		# (the town was already looking near the doors) can end in a 1 px wobble that splits the rest there in two.
		for k in range(int(at_doors[2]), int(legs[0][1])):
			if absf(float(rec[k]["top"]) - door_top) <= 1.0:
				at_doors[2] = k
		# From one start to the next is the leg plus its pause, to the frame (the eases' first and last half pixel
		# round alike at both ends); the last leg ends at its arrival.
		var spans: Array = []
		var good := true
		var leave := int(at_doors[2])
		for k in legs.size():
			var r: Array = legs[k]
			var want: float = (Reveal.LEG_SECS[k] + Reveal.LEG_PAUSE[k]) * FPS
			var got_f: int = int(r[2]) - leave if k < legs.size() - 1 else int(r[1]) - leave
			spans.append("%.2f" % (got_f / FPS))
			good = good and (absf(got_f - want) <= 2.0 if k < legs.size() - 1 else got_f >= want - 6.0 and got_f <= want + 1.0)
			leave = int(r[2])
		_ok("Leg and pause times %s s (1.9+0.4, 1.9+0.4, 1.4+0.5, 2.4)" % str(spans), good)
		var pauses: Array = []
		var paused := true
		for k in 3:
			var n: int = int(legs[k][2]) - int(legs[k][1]) + 1
			pauses.append("%.2f" % (n / FPS))
			paused = paused and n >= int(Reveal.LEG_PAUSE[k] * FPS) and n <= int(Reveal.LEG_PAUSE[k] * FPS) + 8
		_ok("The pauses between the legs %s s (0.4, 0.4, 0.5, each with the ease's last pixel)" % str(pauses), paused)
		var up: float = (int(legs[3][1]) - int(at_doors[2])) / FPS
		_ok("Up the tower in %.2f s (8.9)" % up, absf(up - 8.9) <= 0.2)
		var hold: Array = legs[3]
		var held: float = (int(hold[2]) - int(hold[1]) + 1) / FPS
		var apex_room: float = geo["apex"].y - float(hold[0])
		var lamp_down: float = geo["beacon"].y - float(hold[0])
		_ok("It holds %.2f s at the top (at least 1.5) with the vane's tip %.0f px under the top edge (at least 8) and the Waiting Lamp %.0f px down" % [held, apex_room, lamp_down],
			held >= Reveal.HOLD and apex_room >= 8.0 and lamp_down > 0.0 and lamp_down < half * 2.0 and (not rise or (apex_room == 10.0 and lamp_down == 127.0)))
		# The sky is painted for this hold (2026-10-28, vast scale): it fills the view, its beacon anchor is where the
		# Waiting Lamp's glass stands on screen, and the sky in a 17 px box round it is a calm cool blue (blue over red
		# on every pixel: no cloud, leaf or warm haze behind the lamp). Read from the sky as drawn: the placeholder, or
		# Codex's file once it is installed.
		var sky_img: Image = ArtSlots.texture(Reveal.SKY).get_image()
		sky_img.convert(Image.FORMAT_RGBA8)
		var lamp_at := Vector2i(roundi(geo["beacon"].x - geo["top_look"].x + town.VIEW.x * 0.5), roundi(lamp_down))
		var anchor: Vector2i = ArtSlots.spec(Reveal.SKY).get("anchors", {}).get("beacon", Vector2i(-1, -1))
		var warm := 0
		for y in range(anchor.y - 8, anchor.y + 9):
			for x in range(anchor.x - 8, anchor.x + 9):
				var c := sky_img.get_pixel(clampi(x, 0, sky_img.get_width() - 1), clampi(y, 0, sky_img.get_height() - 1))
				if c.b <= c.r:
					warm += 1
		_ok("The sky (%s) fills the view and its beacon anchor %s is the lamp at the hold %s, cool blue round it (%d warm px of 289)" % [str(sky_img.get_size()), str(anchor), str(lamp_at), warm],
			sky_img.get_size() == Vector2i(town.VIEW) and anchor == lamp_at and warm == 0)
		# The talk box (screen rows 452 to 568, view rows from 452 / 3) never covers what the scene is showing: the doors
		# and the two while the first line is up, and the crook and lamp for the hold before the partner's line on top.
		var box_top := 452.0 * float(town.VIEW.y) / 648.0
		var door_foot: float = (int(geo["door"].y) + 1) * float(Layout.T)
		var start_rows: Array = rec.filter(func(r: Dictionary) -> bool: return r["stage"] == "start" and r["talk"])
		var worst := -INF
		for r: Dictionary in start_rows:
			worst = maxf(worst, maxf(door_foot, maxf(float(r.get("feet", 0.0)), float(r.get("feet2", 0.0)))) - float(r["top"]))
		_ok("The first line's box sits under the doors and the two: the lowest of the doors' foot and the two's feet at view row %.1f, the box from %.1f (%d frames)" % [worst, box_top, start_rows.size()],
			not start_rows.is_empty() and worst <= box_top + 1.0)
		var hold_rows: Array = rec.filter(func(r: Dictionary) -> bool: return r["stage"] == "hold")
		var boxed: Array = hold_rows.filter(func(r: Dictionary) -> bool: return r["talk"])
		var top_line: Array = rec.filter(func(r: Dictionary) -> bool: return r["stage"] == "top" and r["talk"])
		_ok("The hold shows the crook clear: %d frames at the top with no box (%d with one), then the line about it (%d frames)" % [hold_rows.size(), boxed.size(), top_line.size()],
			hold_rows.size() >= int(Reveal.HOLD * FPS) - 2 and boxed.is_empty() and not top_line.is_empty())
		var home_top: float = float(got["end"].y) - half
		var down_at := -1
		for k in range(int(hold[2]) + 1, rec.size()):
			if absf(float(rec[k]["top"]) - home_top) <= 1.0:
				down_at = k
				break
		var down: float = (down_at - int(hold[2])) / FPS
		_ok("Down to the two in %.2f s (4.5)" % down, down_at > 0 and down >= Reveal.PAN_DOWN - 0.25 and down <= Reveal.PAN_DOWN + 0.05)
		# Pass 9 W2 (H9-03): no box on the way down (it sat over the galleries), the last lines once the camera is
		# with the two.
		var pan_boxed: int = rec.filter(func(r: Dictionary) -> bool: return r["stage"] == "down" and r["talk"]).size()
		var back_rows: Array = rec.filter(func(r: Dictionary) -> bool: return r["stage"] == "back" and r["talk"])
		var back_off := 0.0
		for r: Dictionary in back_rows:
			back_off = maxf(back_off, absf(float(r["top"]) - home_top))
		_ok("No box on the way down (%d frames with one); the last lines come with the camera back on the two (%d frames, at most %.1f px off its rest)" % [pan_boxed, back_rows.size(), back_off],
			pan_boxed == 0 and not back_rows.is_empty() and back_off <= 1.0)
		var camera: float = int(at_doors[1]) / FPS + up + held + down
		_ok("About 15.6 s of camera: %.2f s (settle %.2f, up %.2f, hold %.2f, down %.2f)" % [camera, int(at_doors[1]) / FPS, up, held, down], absf(camera - 15.6) <= 0.6)
		# The tower works beside the camera.
		var b0: Variant = rec[int(at_doors[2])].get("basket")
		var b1: Variant = rec[int(legs[0][2])].get("basket")
		_ok("The basket comes up with the first leg: from row %s as the camera leaves the doors to %s at the hoist door (%.0f) as it leaves again" % [str(b0), str(b1), TP.BASKET_HIGH],
			b0 != null and b1 != null and float(b0) >= TP.BASKET_LOW - 12.0 and absf(float(b1) - TP.BASKET_HIGH) <= 2.0)
		var seen_parcel := 0
		var parcel_down := true
		var last := -INF
		for k in range(int(legs[0][2]), int(legs[1][1]) + 1):
			var p: Variant = rec[k].get("parcel")
			if p == null:
				continue
			var world_y: float = geo["origin"].y + float(p)
			if world_y + 8.0 > float(rec[k]["top"]) and world_y < float(rec[k]["top"]) + half * 2.0:
				seen_parcel += 1
			parcel_down = parcel_down and float(p) >= last
			last = float(p)
		_ok("A parcel slides down the chute on screen while the camera climbs the second leg (%d frames in view)" % seen_parcel, seen_parcel >= 10 and parcel_down)
		var cradle_from: Variant = null
		var cradle_out := false
		var swung := false
		for k in range(int(legs[1][2]), rec.size()):
			var c: Variant = rec[k].get("cradle")
			swung = swung or String(rec[k].get("bell", "")) == "swing"
			if c == null:
				continue
			if cradle_from == null:
				cradle_from = c
			var w: Vector2 = geo["origin"] + Vector2(c)
			var view := Rect2(Vector2(geo["foot"].x - half * 16.0 / 9.0, float(rec[k]["top"])), Vector2(half * 32.0 / 9.0, half * 2.0))
			cradle_out = cradle_out or not view.intersects(Rect2(w, Vector2(12, 14)))
		_ok("On the third leg a cradle leaves the Reel Deck (from %s) and slides out of the picture (%s), and the bell swings (%s)" % [str(cradle_from), cradle_out, swung],
			cradle_from != null and cradle_out and swung)
	var home: Vector2 = Reveal.town_look(town)
	_ok("And back down to the two: the last look %s, the town's own %s" % [str(got["end"]), str(home)], got["end"].distance_to(home) <= 2.0)
	_ok("Every line read (%d) in %d frames" % [got["read"], got["frames"]], int(got["read"]) >= 11)
	var stand: Array = geo["stand"]
	_ok("The two stand at the Tower's doors (%s, %s), facing it (%s, %s)" % [str(town.team[0]["pos"]), str(town.team[1]["pos"]), town.team[0]["facing"], town.team[1]["facing"]],
		town.team[0]["pos"] == stand[0] and town.team[1]["pos"] == stand[1] and String(town.team[0]["facing"]) == "n" and String(town.team[1]["facing"]) == "n")
	# Pass 9 W1 (H9-07): the two never draw over each other: none of their pixels shared as the first line comes up, the
	# stand tiles open (not the door lamps'), and far enough apart that no two creatures' town sprites could meet.
	var apart: float = float((stand[1] as Vector2i).x - (stand[0] as Vector2i).x) * Layout.T
	var reach := _reach_out(String(town.team[0]["facing"]), String(town.team[1]["facing"]))
	_ok("The two do not overlap: %s px shared at the first line; stood %.0f px apart, more than any leader's right reach (%.0f, %s) and partner's left reach (%.0f, %s), rim included" % [str(got.get("overlap", "?")), apart, reach[0], reach[2], reach[1], reach[3]],
		int(got.get("overlap", -1)) == 0 and apart > float(reach[0]) + float(reach[1]) and town.open_at(stand[0]) and town.open_at(stand[1]))
	var leftover: Array = []
	for n in LEFT_OVER:
		if town.find_child(n, true, false) != null:
			leftover.append(n)
	var old: Variant = _old_hall(town)
	_ok("Control comes back: scene %s, playing %s, cam_focus %s, left over %s, the old Hall shown again %s" % [town.cutscene, Reveal.playing, str(town.cam_focus), str(leftover), str(old.visible) if is_instance_valid(old) else "(none)"],
		not town.cutscene and not Reveal.playing and town.cam_focus == null and leftover.is_empty() and (not is_instance_valid(old) or old.visible))
	if is_instance_valid(tower) and tower.get_node("Basket").get_meta("cycle", null) is Tween:
		var bell := String(tower.get_node("Bell").get_meta("state", ""))
		var loop: Tween = tower.get_node("Basket").get_meta("cycle")
		var t0 := loop.get_total_elapsed_time()
		await _frames(30)
		var pace := loop.get_total_elapsed_time() - t0
		_ok("The town's tower goes on as before: the bell at %s, the basket at its own pace (%.2f s a second)" % [bell, pace], bell == "rest" and absf(pace - 1.0) <= 0.05)
	# 4. Plays once.
	_ok("tower_seen is set and the scene is not due again (pending %s)" % Reveal.pending(town), Reveal.seen(town) and not Reveal.pending(town))
	var look_before: Vector2 = town._world.position
	Reveal.run(town)
	await _frames(20)
	_ok("Run again with tower_seen set: nothing plays (scene %s, camera moved %s)" % [town.cutscene, look_before != town._world.position],
		not town.cutscene and not Reveal.playing and town.find_child("TowerCam", true, false) == null)
	# 5. Reduce motion: a cut to the top, held at least 2.5 s, a cut back; no frame between.
	TeamState.data["story"].erase(Reveal.FLAG)
	Reveal.reduce_override = 1
	var cut := await _play(town)
	var top_y: float = tops[tops.size() - 1]
	var between := 0
	var at_top := 0
	# The cut back lands on the town's own look, which is above the doors' (TALK_ROOM), so "between" is above both.
	var low := minf(door_top, float(cut["end"].y) - half)
	for row: Dictionary in cut["rec"]:
		var y := float(row["top"])
		if absf(y - top_y) <= 1.0:
			at_top += 1
		elif y < low - 8.0 and y > top_y + 8.0:
			between += 1
	_ok("Reduce motion cuts to the top and back: %.2f s at the top (at least 2.5), %d frames between" % [at_top / FPS, between],
		at_top >= int(Reveal.REDUCED_HOLD * FPS) and between == 0 and not town.cutscene and not Reveal.playing)
	var cut_home: float = float(cut["end"].y) - half
	var cut_back: Array = (cut["rec"] as Array).filter(func(r: Dictionary) -> bool: return r["stage"] == "back" and r["talk"])
	var cut_off := 0.0
	for r: Dictionary in cut_back:
		cut_off = maxf(cut_off, absf(float(r["top"]) - cut_home))
	_ok("Reduce motion: the last lines after the cut back, on the two (%d frames, at most %.1f px off)" % [cut_back.size(), cut_off],
		not cut_back.is_empty() and cut_off <= 1.0)
	Reveal.reduce_override = -1
	# 6. The town freed mid-climb: the scene ends quietly (no error, nothing playing) and leaves nothing behind.
	TeamState.data["story"].erase(Reveal.FLAG)
	Reveal.reduce_override = 0
	var orphans := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	Reveal.run(town)
	await _until(func() -> bool:
		if not town.talk.is_empty():
			UI.finish_line()
			town.talk.pop_front()
		return Reveal.stage == "climb", 30 * 20)
	await _frames(40)
	var mid := Reveal.stage
	town.queue_free()
	current_scene = null
	await _frames(60)
	var orphans_after := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	_ok("The town freed mid-climb (stage %s): the scene ends without an error (playing %s, stage %s), orphan nodes %d -> %d" % [mid, Reveal.playing, Reveal.stage, int(orphans), int(orphans_after)],
		mid == "climb" and not Reveal.playing and Reveal.stage == "done" and orphans_after <= orphans)
	Reveal.reduce_override = -1
	print("TOWER REVEAL: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
