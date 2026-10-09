extends Node
## The first fight (Claude, 2026-10-09). Preston: refine the launch flow through the first story.
## Every reference puts a fight right after the partner choice (Coromon's lab battle, Nexomon's
## woods); Hollowtide's first morning ended on the levee with the old turn-based screen behind
## the Cinderhide. Now that Cinderhide is fought in the arena, 1v1, with the partner you chose
## and you at the controls. Win and the road is open; lose and it is still there to try again.
## Prose here is a proposal, not canon. Run-local, like the rest of the first morning.

const ARENA_SCENE := preload("res://scenes/arena_prototype.tscn")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const ENCOUNTER := "CinderhideEncounter"

var journey: Node2D
var won := false
var fights := 0
var _layer: CanvasLayer
var _arena: Node2D
var _encounter: Node


func _ready() -> void:
	name = "FirstFight"
	journey = get_parent()


## On the levee, the field creature's old battle screen is replaced by this bridge.
func enter_area(id: String, area: Node2D) -> void:
	if id != "route1" or won:
		return
	_encounter = area.get_node_or_null(ENCOUNTER)
	if _encounter != null:
		_encounter.set("_battle_screen", self)


## The field creature calls this the way it called the battle screen.
func start(wild: CreatureData) -> void:
	if _layer != null:
		return
	var mine: CreatureData = PlayerParty.active_creature()
	if mine == null:
		journey.route._show_message("THE LEVEE\nYou have no partner beside you. The dispatcher at the courier hall is waiting.")
		return
	var you := _form_of(mine)
	var foe := _form_of(wild)
	if you.is_empty() or foe.is_empty():
		journey.route._show_message("THE LEVEE\n%s squares up, but this fight is not ready yet." % wild.creature_name)
		return
	fights += 1
	_layer = CanvasLayer.new()
	_layer.name = "FirstFightArena"
	_layer.layer = 0
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_arena = ARENA_SCENE.instantiate()
	_arena.teams_override = [[you], [foe]]
	_arena._you = you[0]
	_arena._you_stage = you[1]
	_arena._rival = foe[0]
	_arena._rival_stage = foe[1]
	_arena.team_size = 1
	_arena.control_slot = 0
	_arena.charm_pick = ""
	_arena.rocks_on = true
	_arena.start_arena = 0
	_arena.story_mode = true
	journey.get_node("RouteHUD").hide()
	journey.get_node("RouteMusic").stream_paused = true
	if journey.atlas != null:
		journey.atlas.visible = false   # the map button stays out of the arena
	journey.process_mode = Node.PROCESS_MODE_DISABLED
	journey.add_child(_layer)
	_layer.add_child(_arena)
	_arena.match_over.connect(_on_over)


func _on_over(winner: int) -> void:
	_layer.queue_free()
	_layer = null
	_arena = null
	journey.process_mode = Node.PROCESS_MODE_INHERIT
	journey.get_node("RouteHUD").show()
	journey.get_node("RouteMusic").stream_paused = false
	if journey.atlas != null:
		journey.atlas.visible = true
	journey.active_area.get_node("Player/Camera2D").make_current()
	var partner: String = PlayerParty.active_creature().creature_name
	if winner == 0:
		won = true
		if is_instance_valid(_encounter):
			# Hidden and switched off, not freed: the route's map polish still looks the node up.
			_encounter.visible = false
			_encounter.set("_player_nearby", false)
			_encounter.set_deferred("monitoring", false)
			_encounter.process_mode = Node.PROCESS_MODE_DISABLED
			_encounter = null
		journey.route._show_message("THE LEVEE\nThe Cinderhide backs off the road and drops into the reeds. %s shakes itself out and looks to you for the next mark.\nThe old landing is east along the levee." % partner)
	else:
		journey.route._show_message("THE LEVEE\n%s is spent. The Cinderhide settles back onto the road, still watching.\nCatch your breath and try again when you are ready. Sidestep its claw, and press when it is recovering." % partner)


## The arena line and stage for a creature, by its name against the arena's form keys.
func _form_of(data: CreatureData) -> Array:
	var key: String = String(data.creature_name).to_lower()
	for line in Arena.LINES.size():
		for stage in 3:
			if Arena.LINES[line]["forms"][stage][0] == key:
				return [line, stage]
	return []
