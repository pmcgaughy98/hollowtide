extends Node

## Watches where the player is walking and decides when a wild creature turns up.
##
## This lives in the world rather than on the player because being wild ground is
## a property of the map, not of the person walking across it. Swap the map and
## the encounter rules come with it.

## Announced when an encounter should start. The encounter screen listens for
## this. Neither one has to know much about the other, which is why adding a
## second thing that reacts to encounters later will not mean editing this file.
signal encounter_started(creature: CreatureData)

## Name of the flag on the tileset that marks a tile as wild ground.
## Set per tile in the TileSet editor, so which ground is dangerous is data
## you can change without touching code.
const WILD_FLAG := "spawns_creatures"

## How far the player walks on wild ground between rolls, in pixels.
## A tile is 16, so this is one roll per tile stepped.
@export var pixels_between_rolls: float = 16.0

## Chance of an encounter on each roll.
@export_range(0.0, 1.0) var encounter_chance: float = 0.12

## Only these species can appear on this map. Set the list in the scene Inspector.
@export var encounter_pool: Array[CreatureData] = []

@export var player_path: NodePath
@export var ground_path: NodePath

var _player: Node2D
var _ground: TileMapLayer
var _available_creatures: Array[CreatureData] = []
var _last_position: Vector2
var _distance_on_wild_ground: float = 0.0


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_ground = get_node_or_null(ground_path)
	if _player == null or _ground == null:
		push_warning("EncounterTrigger has no player or ground assigned, so it is off.")
		set_physics_process(false)
		return
	for creature in encounter_pool:
		if creature != null:
			_available_creatures.append(creature)
	if _available_creatures.is_empty():
		push_warning("EncounterTrigger has no encounter pool, so wild encounters are off.")
		set_physics_process(false)
		return
	_last_position = _player.global_position


func _physics_process(_delta: float) -> void:
	var moved := _player.global_position.distance_to(_last_position)
	_last_position = _player.global_position

	if moved <= 0.0:
		return

	if not _standing_on_wild_ground():
		# The path is safe, so distance covered on it does not build up.
		_distance_on_wild_ground = 0.0
		return

	_distance_on_wild_ground += moved

	while _distance_on_wild_ground >= pixels_between_rolls:
		_distance_on_wild_ground -= pixels_between_rolls
		if randf() < encounter_chance:
			_start_encounter()
			return


func _standing_on_wild_ground() -> bool:
	var cell := _ground.local_to_map(_ground.to_local(_player.global_position))
	var tile := _ground.get_cell_tile_data(cell)
	if tile == null:
		return false
	return tile.get_custom_data(WILD_FLAG)


func _start_encounter() -> void:
	var creature: CreatureData = _available_creatures[randi() % _available_creatures.size()]
	encounter_started.emit(creature)
