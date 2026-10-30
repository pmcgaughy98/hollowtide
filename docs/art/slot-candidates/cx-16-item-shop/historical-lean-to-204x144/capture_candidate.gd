extends SceneTree
## Actual Highbank, isolated preview save, process-only art override. No install.
const A := preload("res://scripts/art/art_slots.gd")
const L := preload("res://scripts/town/town_layout.gd")
const S := preload("res://scripts/town/team_state.gd")
const M := preload("res://scripts/audio/music.gd")
const OUT := "res://docs/art/slot-candidates/cx-16-item-shop/town.building.shop/"
var candidate: Texture2D
func _initialize() -> void:
 _run.call_deferred()
func _users(n: Node) -> Array[Node]:
 var result: Array[Node] = []
 if n is Sprite2D and n.name == "Exterior" and n.texture == candidate:
  result.append(n)
 for ch in n.get_children():
  result.append_array(_users(ch))
 return result
func _run() -> void:
 # Isolate all possible autosave writes BEFORE creating the live town.
 S.save_path = ProjectSettings.globalize_path(OUT + "preview-team.save")
 assert(S.save_path != S.SAVE_PATH and S.save_path.contains("slot-candidates/cx-16-item-shop/"))
 L.force_v2()
 A.clear_cache()
 var pic := Image.load_from_file(ProjectSettings.globalize_path(OUT + "prepared.png"))
 assert(pic.get_size() == Vector2i(204,144))
 candidate = ImageTexture.create_from_image(pic)
 A._img["town.building.shop"] = pic
 A._tex["town.building.shop"] = candidate
 A._src["town.building.shop"] = "candidate-in-memory"
 S.start([[0,0],[1,0]])
 S.data["story"] = {"parcel":"stolen","met_crew":true}
 S.data["beaten"] = ["mouth"]
 var town = load("res://scenes/hub_town.tscn").instantiate()
 town.poll_input = false
 root.add_child(town)
 for i in 8:
  await process_frame
 town.cam_focus = Vector2(360,108)
 town.panel.clear()
 for i in town.team.size():
  town.team[i]["pos"] = Vector2i(14+i*2,7)
  town._place(town.team[i])
 var users := _users(town)
 assert(users.size() == 1, "Exactly one live Exterior must use candidate")
 assert(users[0].name == "Exterior")
 assert(A.source("town.building.shop") == "candidate-in-memory")
 print("CANDIDATE_VERIFIED: actual Highbank v2 Exterior uses prepared.png, 204x144; save isolated under cx-16")
 for i in 8:
  await process_frame
 await RenderingServer.frame_post_draw
 var err := root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "capture.png"))
 assert(err == OK)
 var building := users[0].get_parent()
 var door := building.get_node("Door") as Sprite2D
 var frames: Array = building.get_meta("frames")
 door.texture = frames[2]
 for i in 3:
  await process_frame
 await RenderingServer.frame_post_draw
 err = root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "capture-open.png"))
 assert(err == OK)
 print("CAPTURE_PASS: production scene, finish shader, sign, footing, door leaves; closed and open")
 M.release(self)
 var stop := Time.get_ticks_msec()+5000
 var minimum := Time.get_ticks_msec()+120
 while Time.get_ticks_msec()<minimum or (M.working() and Time.get_ticks_msec()<stop):
  await process_frame
 M.finish_work()
 town.queue_free()
 for i in 3:
  await process_frame
 quit(0)