extends Node2D
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const CANOPY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
var _tree: Sprite2D
var _player: Node2D
var _old_tree_material: Material
var _canopy_material: ShaderMaterial
var _canopy_opacity := 1.0
var _landing_tree: Sprite2D
var _landing_material: ShaderMaterial
var _landing_opacity := 1.0
var _landing_old_material: Material

const FOOTPATH = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/landing_footpath.png")
func _enter_tree() -> void:
	# Cached route scenes re-enter without a second _ready call.
	if is_instance_valid(_tree) and _canopy_material:
		_tree.material = _canopy_material
	if is_instance_valid(_landing_tree) and _landing_material:
		_landing_tree.material = _landing_material

const SOUTH_LOOP = preload("res://assets/sprites/world/route1_spaced_landing_2026_10_03/landing_south_loop.png")

func _ready() -> void:
	var route: Node2D=get_parent().get_parent()
	_tree=route.get_node("RouteDecor/CottonwoodSouth")
	_player=route.get_node("Player")
	_old_tree_material=_tree.material
	_canopy_material=ShaderMaterial.new()
	_canopy_material.shader=CANOPY
	_tree.material=_canopy_material
	_canopy_material.set_shader_parameter("canopy_opacity", 1.0)
	_landing_tree=route.get_node("RouteDecor/CottonwoodMeadow07")
	_landing_old_material=_landing_tree.material
	_landing_material=ShaderMaterial.new()
	_landing_material.shader=CANOPY
	_landing_material.set_shader_parameter("canopy_opacity", 1.0)
	_landing_tree.material=_landing_material
	var surface:=Sprite2D.new()
	surface.name="LandingFootpath"
	surface.texture=FOOTPATH
	surface.centered=false
	surface.position=Vector2(292,258)
	surface.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	surface.material=route.get_node("Terrain").material
	add_child(surface)
	var south:=Sprite2D.new()
	south.name="SouthernLandingLoop"
	south.texture=SOUTH_LOOP
	south.centered=false
	south.position=Vector2(244,336)
	south.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	south.material=route.get_node("Terrain").material
	add_child(south)
	var notice:=Sprite2D.new()
	notice.name="OldLandingNotice"
	notice.texture=MARK
	notice.position=Vector2(320,442)
	notice.offset=Vector2(0,-15)
	notice.scale=Vector2.ONE*0.65
	notice.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	route.get_node("RouteDecor").add_child(notice)
	var body:=StaticBody2D.new()
	body.name="FootCollision";body.position=Vector2(0,-3)
	var shape:=CollisionShape2D.new()
	var rectangle:=RectangleShape2D.new()
	rectangle.size=Vector2(6,4);shape.shape=rectangle
	body.add_child(shape);notice.add_child(body)
	var label:=Label.new()
	label.name="LandingFootpathLabel"
	label.text="OLD LANDING"
	label.position=Vector2(280,480)
	label.add_theme_font_override("font",FONT)
	label.add_theme_font_size_override("font_size",8)
	label.add_theme_color_override("font_color",Color("#e5ddba"))
	label.add_theme_color_override("font_outline_color",Color("#293831"))
	label.add_theme_constant_override("outline_size",2)
	add_child(label)

func _process(delta: float) -> void:
	# Fade the crown while the courier passes behind it; the trunk stays grounded.
	var head:=_tree.to_local(_player.global_position+Vector2(0,-16))
	var behind:=_player.global_position.y<_tree.global_position.y-2 and _tree.get_rect().has_point(head)
	_canopy_opacity=move_toward(_canopy_opacity,0.35 if behind else 1.0,delta*3.0)
	_canopy_material.set_shader_parameter("canopy_opacity",_canopy_opacity)
	var landing_head:=_landing_tree.to_local(_player.global_position+Vector2(0,-16))
	var landing_behind:=_player.global_position.y<_landing_tree.global_position.y-2 and _landing_tree.get_rect().has_point(landing_head)
	_landing_opacity=move_toward(_landing_opacity,0.35 if landing_behind else 1.0,delta*3.0)
	_landing_material.set_shader_parameter("canopy_opacity",_landing_opacity)

func _exit_tree() -> void:
	if is_instance_valid(_tree):
		_tree.material=_old_tree_material

	if is_instance_valid(_landing_tree):
		_landing_tree.material=_landing_old_material
