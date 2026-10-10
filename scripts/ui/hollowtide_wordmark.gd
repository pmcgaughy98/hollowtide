extends Node2D
## Original native-pixel lettering and root ornament for the creature village.
const SIZE:=Vector2i(384,84)
const INK:=Color("#15221e")
const WOOD:=Color("#51402e")
const MOSS:=Color("#71915d")
const LEAF:=Color("#b4bc74")
const FACE_CODE="""
shader_type canvas_item;
uniform float cap_top = 10.0;
uniform float cap_bottom = 40.0;
void fragment() {
    vec4 glyph = texture(TEXTURE, UV);
    float k = (floor(VERTEX.y) - cap_top) / max(1.0, cap_bottom-cap_top);
    vec3 bone = vec3(1.0,0.94,0.76);
    vec3 gold = vec3(0.91,0.77,0.49);
    vec3 clay = vec3(0.70,0.52,0.30);
    vec3 face = k<0.22 ? bone : (k<0.70 ? gold : clay);
    COLOR = vec4(face, glyph.a * COLOR.a);
}
"""
var font:FontVariation
var left:=0.0
var right:=0.0

func _ready() -> void:
	var base:FontFile=preload("res://assets/fonts/Vollkorn-Variable.ttf").duplicate()
	base.antialiasing=TextServer.FONT_ANTIALIASING_NONE
	base.hinting=TextServer.HINTING_NONE
	base.subpixel_positioning=TextServer.SUBPIXEL_POSITIONING_DISABLED
	font=FontVariation.new()
	font.base_font=base
	font.variation_opentype={"wght":900.0}
	var letters:="HOLLOWTIDE"
	var width:=0.0
	for i in letters.length():width+=font.get_string_size(letters[i],HORIZONTAL_ALIGNMENT_LEFT,-1,48 if i in [0,6] else 42).x+1
	left=floorf((SIZE.x-width)*0.5)
	var x:=left
	for i in letters.length():
		var size:int=48 if i in [0,6] else 42
		var y:float=2 if i in [0,6] else 7+roundf(sin(float(i)/8.0*PI)*2)
		var at:=Vector2(x,y)
		letter(letters[i],size,at+Vector2(0,4),WOOD,4)
		letter(letters[i],size,at,INK,3)
		var face:=letter(letters[i],size,at,Color.WHITE,0)
		var mat:=ShaderMaterial.new()
		mat.shader=Shader.new()
		mat.shader.code=FACE_CODE
		mat.set_shader_parameter("cap_top",floorf(font.get_ascent(size)-size*0.70))
		mat.set_shader_parameter("cap_bottom",font.get_ascent(size))
		face.material=mat
		x+=font.get_string_size(letters[i],HORIZONTAL_ALIGNMENT_LEFT,-1,size).x+1
	right=x-1
	queue_redraw()

func letter(text:String,size:int,at:Vector2,colour:Color,outline:int) -> Label:
	var label:=Label.new()
	label.text=text
	label.position=at.round()
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",colour)
	if outline>0:
		label.add_theme_color_override("font_outline_color",INK)
		label.add_theme_constant_override("outline_size",outline)
	add_child(label)
	return label

func pixels(a:Vector2i,b:Vector2i,colour:Color,thickness:int=1) -> void:
	var p:=a
	var dx:=absi(b.x-a.x)
	var dy:=-absi(b.y-a.y)
	var sx:=1 if a.x<b.x else -1
	var sy:=1 if a.y<b.y else -1
	var error:=dx+dy
	while true:
		draw_rect(Rect2(Vector2(p),Vector2.ONE*thickness),colour)
		if p==b:break
		var twice:=2*error
		if twice>=dy:error+=dy;p.x+=sx
		if twice<=dx:error+=dx;p.y+=sy

func root_branch(points:Array[Vector2i]) -> void:
	for i in range(1,points.size()):
		pixels(points[i-1]+Vector2i(0,1),points[i]+Vector2i(0,1),INK,3)
		pixels(points[i-1],points[i],WOOD,2)
		pixels(points[i-1],points[i],Color("#a48450"))

func _draw() -> void:
	if font==null:return
	# Split roots frame a small dark Hollow arch beneath the exact lettering.
	root_branch([Vector2i(80,59),Vector2i(111,63),Vector2i(155,61),Vector2i(179,67)])
	root_branch([Vector2i(304,59),Vector2i(273,63),Vector2i(229,61),Vector2i(205,67)])
	root_branch([Vector2i(113,63),Vector2i(101,70),Vector2i(87,69)])
	root_branch([Vector2i(271,63),Vector2i(283,70),Vector2i(297,69)])
	root_branch([Vector2i(153,61),Vector2i(139,71),Vector2i(126,75)])
	root_branch([Vector2i(231,61),Vector2i(245,71),Vector2i(258,75)])
	# An original burrow motif: stepped stone arch, amber doorway, silt threshold.
	draw_rect(Rect2(182,61,20,15),INK)
	draw_rect(Rect2(185,59,14,3),INK)
	draw_rect(Rect2(184,63,3,12),Color("#b9a675"))
	draw_rect(Rect2(197,63,3,12),Color("#b9a675"))
	draw_rect(Rect2(187,61,10,3),Color("#dac996"))
	draw_rect(Rect2(190,66,4,8),Color("#d5a75e"))
	draw_rect(Rect2(180,76,24,2),Color("#bfa56e"))
	# Leaves touch the outside capitals and branch ends, never the letter counters.
	for pos in [Vector2(int(left)-4,19),Vector2(int(right)+1,20),Vector2(88,66),Vector2(295,66)]:
		draw_rect(Rect2(pos+Vector2(-1,1),Vector2(7,3)),INK)
		draw_rect(Rect2(pos,Vector2(5,2)),MOSS)
		draw_rect(Rect2(pos+Vector2(2,-1),Vector2(2,2)),LEAF)
