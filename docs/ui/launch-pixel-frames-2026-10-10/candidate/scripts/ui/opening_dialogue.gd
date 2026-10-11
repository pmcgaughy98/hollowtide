extends Node2D
## Presentation for the existing opening text model; choices and story state stay in the prologue.
const UI := preload("res://scripts/ui/ui_style.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
var source: Node2D
var clock := 0.0
var portrait: Sprite2D
var well: ImageTexture
func _ready() -> void:
	var clear := Image.create(1,1,false,Image.FORMAT_RGBA8)
	clear.fill(Color.TRANSPARENT)
	well=ImageTexture.create_from_image(clear)
	portrait=Sprite2D.new()
	portrait.centered=false
	portrait.position=Vector2(120,174)
	portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	Finish.apply(portrait)
	add_child(portrait)
func _process(delta: float) -> void:
	if not source.reduce_motion: clock += delta
	var index: int=source.hero if source.phase==0 else source.partner
	portrait.texture=UI.dialogue_portrait(source.FORMS[index])
	portrait.visible=portrait.texture!=null
	if portrait.visible: portrait.scale=Vector2(120,120)/portrait.texture.get_size()
	queue_redraw()
func _wrapped(line: String, width: float) -> String:
	var lines: Array[String] = []
	for paragraph in line.split("\n"):
		var current := ""
		for word in paragraph.split(" "):
			var next := word if current.is_empty() else current+" "+word
			if UI.width_of(next,22)>width and not current.is_empty():
				lines.append(current)
				current=word
			else: current=next
		lines.append(current)
	return "\n".join(lines)
func _draw() -> void:
	if source == null or source.prose == null: return
	var index: int=source.hero if source.phase==0 else source.partner
	var speaker: String=source.NAMES[index]
	# A transparent well reserves the shared portrait/name-tab layout. The creature itself
	# draws on its own finished sprite layer, as required on every creature screen.
	UI.dialogue(self,Rect2(102,324,948,128),speaker,_wrapped(source.prose.text,878),well if UI.dialogue_portrait(source.FORMS[index])!=null else null,clock,22)
