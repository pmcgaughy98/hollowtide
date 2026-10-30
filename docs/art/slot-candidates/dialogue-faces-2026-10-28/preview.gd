extends SceneTree
const UI := preload("res://docs/art/slot-candidates/dialogue-faces-2026-10-28/ui_style_candidate.gd")
const B := "res://docs/art/slot-candidates/dialogue-faces-2026-10-28/"
func _initialize() -> void:
 _run.call_deferred()
func _run() -> void:
 for form in ["punchybun","sparkjab"]:
  var pic := Image.load_from_file(ProjectSettings.globalize_path(B+form+"/prepared.png"))
  UI._icons["dialogue/"+form] = ImageTexture.create_from_image(pic)
 var canvas: Node2D = load(B+"preview_canvas.gd").new()
 root.add_child(canvas)
 for i in 5:
  await process_frame
 await RenderingServer.frame_post_draw
 var err := root.get_texture().get_image().save_png(ProjectSettings.globalize_path(B+"runtime-preview.png"))
 assert(err == OK)
 print("PREVIEW_PASS: production dialogue and headshot methods, candidate faces and proposed FACE_AT rows only")
 canvas.queue_free()
 await process_frame
 quit(0)