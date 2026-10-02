extends Area2D

## A visible creature the player can approach and meet deliberately.
## Its battle still uses the existing BattleScreen and battle presentation.

@export var creature: CreatureData
@export var player_path: NodePath
@export var battle_screen_path: NodePath
## Optional overworld-only idle art; battle continues to use CreatureData.
@export var field_idle_texture: Texture2D
@export var field_idle_fps: float = 4.0
var _field_idle_phase := 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _prompt: Label = $Prompt

var _battle_screen: Node
var _player: Node
var _player_nearby: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_battle_screen = get_node_or_null(battle_screen_path)
	if creature == null:
		push_warning("Field creature has no creature resource assigned.")
	else:
		_sprite.texture = field_idle_texture if field_idle_texture != null else creature.sprite
		if field_idle_texture != null:
			_sprite.region_enabled = true
			_sprite.region_rect = Rect2(0, 0, 80, 80)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby or not event.is_action_pressed("interact"):
		return
	if creature == null:
		return
	if _battle_screen == null or not _battle_screen.has_method("start"):
		push_warning("Field creature has no battle screen assigned.")
		return

	_battle_screen.call("start", creature)
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if body != _player:
		return
	_player_nearby = true
	_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_player_nearby = false
	_prompt.visible = false


func _process(delta: float) -> void:
	if field_idle_texture == null:
		return
	_field_idle_phase = fmod(_field_idle_phase + delta * field_idle_fps, 8.0)
	_sprite.region_rect = Rect2(int(_field_idle_phase) * 80, 0, 80, 80)
