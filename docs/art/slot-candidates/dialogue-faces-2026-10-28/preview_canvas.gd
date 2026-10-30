extends Node2D
const UI := preload("res://docs/art/slot-candidates/dialogue-faces-2026-10-28/ui_style_candidate.gd")
func _draw() -> void:
 draw_rect(Rect2(0,0,1152,648),Color("#1d2420"))
 var f := UI.font("label")
 draw_string(f,Vector2(30,34),"CANDIDATE FACE PREVIEW - NO ASSETS INSTALLED",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
 for i in 2:
  var form: String = ["punchybun","sparkjab"][i]
  var top := 160+i*282
  var tex := UI.dialogue_portrait(form)
  UI.dialogue(self,Rect2(48,top,1056,144),form.capitalize(),"",tex,0.0)
  draw_string(f,Vector2(232,top+62),"40 x 40 dialogue face from existing art",HORIZONTAL_ALIGNMENT_LEFT,-1,16,UI.TEXT)
  draw_string(f,Vector2(232,top+90),"Candidate only; awaiting Preston's review",HORIZONTAL_ALIGNMENT_LEFT,-1,16,UI.TEXT)
  var r := Rect2(966,top-64,48,48)
  UI.headshot_well(self,r)
  draw_texture(UI.portrait_3x(form),r.position)
  UI.headshot_rim(self,r,true)
  draw_string(f,Vector2(862,top-76),"24px cut at 2x",HORIZONTAL_ALIGNMENT_LEFT,-1,16,UI.TEXT)