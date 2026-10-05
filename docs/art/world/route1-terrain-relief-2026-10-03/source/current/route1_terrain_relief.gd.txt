extends Node2D
## Raised grassy levee slopes and softened route paths, baked from native materials.
## Exact build inputs and the offline builder are preserved in the art record.
const SLOPES = preload("res://assets/sprites/world/route1_terrain_relief_2026_10_03/levee_grass_slopes.png")
const LANES = preload("res://assets/sprites/world/route1_terrain_relief_2026_10_03/rounded_dispatch_landing_paths.png")
var surface_build_ms := 0

func _ready() -> void:
	var started := Time.get_ticks_msec()
	var terrain: TileMapLayer = get_parent().get_parent().get_node("Terrain")
	_surface("GrassyLeveeShoulders", SLOPES, Vector2(136, 216), terrain.material)
	_surface("RoundedDispatchAndLandingLanes", LANES, Vector2(0, 80), terrain.material)
	surface_build_ms = Time.get_ticks_msec() - started

func _surface(label: String, texture: Texture2D, at: Vector2, finish: Material) -> void:
	var surface := Sprite2D.new()
	surface.name = label
	surface.texture = texture
	surface.centered = false
	surface.position = at
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	surface.material = finish
	add_child(surface)
