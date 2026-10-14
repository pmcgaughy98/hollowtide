extends Node2D
## Standalone art review only. No Storage logic, room collision or game scene hook.
## Space: toggle shared finish. M: inspect material mask. Escape: close.
const FINISH := preload("res://scripts/dungeon/dungeon_finish.gdshader")
var sprite: Sprite2D
var finish_material: ShaderMaterial
var finish_on := true
var mask_on := false
func _ready() -> void:
	sprite=Sprite2D.new();sprite.centered=false;sprite.scale=Vector2(3,3)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture=load("res://art/storage-raw.png");add_child(sprite)
	finish_material=ShaderMaterial.new();finish_material.shader=FINISH
	finish_material.set_shader_parameter("detail_mask",load("res://art/detail-mask.png"))
	finish_material.set_shader_parameter("detail_ink",0.75)
	update_view()
func update_view() -> void:
	sprite.texture=load("res://art/detail-mask.png" if mask_on else "res://art/storage-raw.png")
	sprite.material=finish_material if finish_on and not mask_on else null
func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	match event.keycode:
		KEY_SPACE:finish_on=not finish_on;update_view()
		KEY_M:mask_on=not mask_on;update_view()
		KEY_ESCAPE:get_tree().quit()
