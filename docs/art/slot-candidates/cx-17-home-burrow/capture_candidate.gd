extends SceneTree
## Actual Highbank, isolated preview save, process-only art override. No install.
const A := preload("res://scripts/art/art_slots.gd")
const L := preload("res://scripts/town/town_layout.gd")
const S := preload("res://scripts/town/team_state.gd")
const M := preload("res://scripts/audio/music.gd")
const U := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/art/slot-candidates/cx-17-home-burrow/town.building.home/"
const Arena := preload("res://scripts/arena/arena_prototype.gd")
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
 # Isolate both preference caches and save writes before creating the live town.
 U._prefs = ConfigFile.new()
 U._game_prefs = ConfigFile.new()
 S.save_path = ProjectSettings.globalize_path(OUT + "preview-team.save")
 assert(S.save_path != S.SAVE_PATH and S.save_path.contains("slot-candidates/cx-17-home-burrow/"))
 L.force_v2()
 A.clear_cache()
 var pic := Image.load_from_file(ProjectSettings.globalize_path(OUT + "prepared.png"))
 assert(pic.get_size() == Vector2i(132,192))
 candidate = ImageTexture.create_from_image(pic)
 A._img["town.building.home"] = pic
 A._tex["town.building.home"] = candidate
 A._src["town.building.home"] = "candidate-in-memory"
 var spark_line := -1
 for i in range(Arena.LINES.size()):
  if Arena.LINES[i]["forms"][1][0] == "sparkjab":
   spark_line = i
 assert(spark_line >= 0)
 S.start([[spark_line,1],[0,0]])
 S.data["story"] = {"parcel":"stolen","met_crew":true}
 S.data["beaten"] = ["mouth"]
 var town = load("res://scenes/hub_town.tscn").instantiate()
 town.poll_input = false
 S.give_to(town)
 root.add_child(town)
 for i in 8:
  await process_frame
 town.cam_focus = Vector2(192,128)
 town._hud.hide() # inspection view, to keep the whole roof unobscured
 town.panel.clear()
 for i in town.team.size():
  town.team[i]["pos"] = Vector2i(5+i,9)
  town._place(town.team[i])
 assert(town.team[0]["form"] == "sparkjab", "Scale preview must show Sparkjab")
 var users := _users(town)
 assert(users.size() == 1, "Exactly one live Exterior must use candidate")
 assert(users[0].name == "Exterior")
 assert(A.source("town.building.home") == "candidate-in-memory")
 print("CANDIDATE_VERIFIED: actual Highbank v2 Exterior uses prepared.png, 132x192; save isolated under cx-17")
 for i in 120:
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
 print("CAPTURE_PASS: production Highbank, Home finish, footing and door leaves; closed/open; inspection camera, HUD hidden, Sparkjab at scale")
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