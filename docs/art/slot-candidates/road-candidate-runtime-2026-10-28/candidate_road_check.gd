extends "res://tools/debug/road_tower_view_check.gd"
## Candidate-only wrapper: unchanged production check, ephemeral ArtSlots cache substitution, never writes assets.
var candidate_config: Dictionary
var candidate_case := "revised"
var verify_pending := true
var expected_mid: Image

func _initialize() -> void:
 candidate_config = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/slot-candidates/road-candidate-runtime-2026-10-28/config.json"))
 candidate_case = OS.get_environment("HT_CANDIDATE_CASE")
 ArtSlots.clear_cache()
 for sid: String in candidate_config["candidate_paths"]:
  var path: String = candidate_config["candidate_paths"][sid]
  if sid == "road.backdrop.mid" and candidate_case == "old":
   path = candidate_config["old_mid"]
  var img := Image.load_from_file(ProjectSettings.globalize_path("res://" + path))
  assert(img != null and not img.is_empty(), "Missing candidate " + path)
  img.convert(Image.FORMAT_RGBA8)
  assert(img.get_size() == ArtSlots.spec(sid)["sheet_size"], "Candidate size differs " + sid)
  ArtSlots._img[sid] = img
  ArtSlots._tex[sid] = ImageTexture.create_from_image(img)
  ArtSlots._src[sid] = "candidate-in-memory"
  if sid == "road.backdrop.mid":
   expected_mid = img
  print("CANDIDATE_INPUT ", candidate_case, " ", sid, " ", FileAccess.get_sha256("res://" + path))
 print("CANDIDATE_ONLY: six road textures substituted in process cache; no installation")
 super._initialize()

func _far_seen() -> Dictionary:
 if verify_pending:
  for sid: String in candidate_config["candidate_paths"]:
   assert(ArtSlots.source(sid) == "candidate-in-memory", "Scene replaced candidate cache " + sid)
  assert(ArtSlots.image("road.backdrop.mid").get_data() == expected_mid.get_data(), "Scene uses different willow image")
  print("CANDIDATE_CACHE_VERIFIED ", candidate_case, ": actual road scene uses all six candidate textures")
  verify_pending = false
 return super._far_seen()
