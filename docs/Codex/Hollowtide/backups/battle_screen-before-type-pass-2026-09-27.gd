extends CanvasLayer

## The battle. Each side chooses one move per round; first creature to zero HP faints.
##
## Not built yet: experience, levels, status effects, items,
## and saving.
## Evolution below uses the battle-win prototype Preston approved for the
## Cinderhide line. Other lines are not linked by that decision.

## The Inspector creature starts a fresh game. After that, battle reads the
## active member from PlayerParty, so evolution remains owned across scenes.
@export var player_creature: CreatureData

## Strike, the move a creature uses when its `move` field is empty.
##
## Other moves are MoveData files in data/moves/. Strike stays as constants
## because it borrows its user's essence, which a MoveData file cannot express.
const MOVE_NAME := "Strike"
const MOVE_POWER := 40

## Capture chance. At the target's full HP it is CATCH_BASE. As its HP falls
## toward zero the chance climbs to CATCH_BASE plus CATCH_BONUS, which is why
## wearing something down before reaching for it is worth doing.
##
## No capture items. A ball with a catch rate is an item system, and items are
## their own step. Attempts are unlimited, and each one costs you the round.
const CATCH_BASE := 0.20
const CATCH_BONUS := 0.60

## How long each message sits on screen before the next one.
const BEAT := 0.75

## The freeze on contact. Working devs cite somewhere around 40 to 80
## milliseconds for this; 60 is a starting value to tune by feel, not a
## verified number. It is the cheapest single thing that makes a hit land.
const HIT_STOP := 0.06

const RIVER_LANDING = preload("res://assets/backgrounds/river_landing_battle.svg")
const CREATURE_NAME_FONT = preload("res://assets/fonts/Silkscreen-Bold.ttf")
const HP_NUMBER_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")

## The near-side scale target. Battle size still comes from each creature;
## the opponent also receives distance scaling so it reads farther away.
const CREATURE_HEIGHT := 264

## Adjustable in the BattleScreen Inspector until the dedicated battle camera
## and backgrounds are designed. Half-step zooms keep the distant 128px forms
## legible without making them the same size as the foreground partner.
@export_range(0.5, 1.0, 0.01) var foe_perspective_scale: float = 0.72

## Small focus shifts move the river and creatures together while the HUD stays still.
## These are Inspector controls for tuning the battle view after play review.
@export_range(0.0, 24.0, 1.0) var focus_shift_px: float = 16.0
@export_range(1.0, 1.08, 0.005) var focus_zoom: float = 1.04

## Battle idle. The creature breathes by squashing and stretching rather than
## sliding up and down, so its feet stay planted and the body compresses against
## the ground instead of lifting off it.
##
## How deep and how fast a creature breathes lives on the creature itself
## (CreatureData.idle_breath and idle_period), so a heavy, armoured form settles
## into slow deep breaths while a small runner stays quick and shallow, and no
## two creatures in a fight breathe alike.
##
## This is the fallback motion for every creature that has no hand-drawn idle
## frames; see docs/idle-animation-workflow.md for that pipeline.
##
## Real breathing is not symmetrical: drawing a breath in takes longer than
## letting it out. INHALE_SHARE is how much of the cycle the intake owns, and
## that imbalance is what stops the loop reading as a metronome.
const INHALE_SHARE := 0.55

enum Phase { CHOOSING, RESOLVING, OVER }

var _phase: Phase = Phase.OVER
var _foe: CreatureData
var _player_hp: int = 0
var _foe_hp: int = 0
var _player_first: bool = true
var _player_intent: MoveData
var _foe_intent: MoveData
var _player_action_pending: bool = false
var _foe_action_pending: bool = false
var _player_action_canceled: bool = false
var _foe_action_canceled: bool = false
var _player_guard_fraction: float = 1.0
var _foe_guard_fraction: float = 1.0
var _last_interrupt: String = ""

var _focus_stage: Node2D
var _focus_tween: Tween
var _battle_stage: Node2D
var _foe_sprite: Sprite2D
var _player_sprite: Sprite2D
var _foe_name: Label
var _player_name: Label
var _foe_bar: ProgressBar
var _player_bar: ProgressBar
var _foe_hp_text: Label
var _player_hp_text: Label
var _message: Label
var _buttons: VBoxContainer
var _strike_button: Button
var _move_grid: GridContainer
var _move_buttons: Array[Button] = []
var _catch_button: Button
var _flee_button: Button
var _player_uses: Dictionary = {}
var _foe_uses: Dictionary = {}

# Where each sprite rests. The idle bob and every hit shake measure from here.
var _foe_home: Vector2
var _player_home: Vector2

# Battle idle state. `_idle_time` advances only in _process, and
# `_idle_hold` pauses the breathing while an attack, a projectile or the
# evolution owns the sprites.
var _idle_time: float = 0.0
var _idle_on: bool = false
var _idle_hold: bool = false


func _ready() -> void:
	layer = 50
	visible = false
	# Keeps this screen running while the overworld is frozen.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_build_ui()


# ---------------------------------------------------------------- entry point

## Called when the encounter trigger announces a wild creature.
func start(wild: CreatureData) -> void:
	if _phase != Phase.OVER:
		return
	PlayerParty.ensure_starter(player_creature)
	player_creature = PlayerParty.active_creature()
	if player_creature == null:
		push_warning("BattleScreen has no active creature, so it cannot start.")
		return

	_foe = wild
	_player_hp = player_creature.base_hp
	_foe_hp = _foe.base_hp
	_player_uses.clear()
	_foe_uses.clear()
	_player_intent = null
	_foe_intent = null
	_player_action_pending = false
	_foe_action_pending = false
	_player_action_canceled = false
	_foe_action_canceled = false
	_player_guard_fraction = 1.0
	_foe_guard_fraction = 1.0
	_last_interrupt = ""

	# Faster creature acts first for the whole battle. Ties go to the player.
	_player_first = player_creature.base_speed >= _foe.base_speed

	_foe_sprite.texture = _foe.idle_frames[0] if not _foe.idle_frames.is_empty() else _foe.sprite
	_player_sprite.texture = player_creature.back_sprite if player_creature.back_sprite != null else (player_creature.idle_frames[0] if not player_creature.idle_frames.is_empty() else player_creature.sprite)
	# Reset anything a previous battle's animation might have left behind.
	for s in [_foe_sprite, _player_sprite]:
		s.scale = Vector2.ONE * _zoom(s)
		s.modulate = Color.WHITE
	_battle_stage.position = Vector2.ZERO
	if _focus_tween != null and _focus_tween.is_valid():
		_focus_tween.kill()
	_focus_stage.scale = Vector2.ONE * 1.035
	_focus_stage.position = _focus_target(Vector2.ZERO, 1.035)
	_foe_sprite.position = _foe_home
	_player_sprite.position = _player_home
	# Restart the idle clock so every battle opens on the same frame.
	_idle_time = 0.0
	_idle_hold = false
	_idle_on = true
	_foe_name.text = _foe.creature_name + "   " + _foe.essence_name()
	_player_name.text = player_creature.creature_name + "   " + player_creature.essence_name()
	_refresh_bars()
	_refresh_move_buttons()

	visible = true
	get_tree().paused = true
	_tween_focus(Vector2.ZERO, 1.0, 0.35)
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)
	_message.text = "A wild %s appeared!" % _foe.creature_name

	await get_tree().create_timer(BEAT).timeout
	_begin_choice()


# ---------------------------------------------------------------- turn loop

func _begin_choice() -> void:
	_player_intent = null
	_foe_intent = _choose_foe_move()
	_player_action_pending = false
	_foe_action_pending = false
	_player_action_canceled = false
	_foe_action_canceled = false
	_player_guard_fraction = 1.0
	_foe_guard_fraction = 1.0
	_last_interrupt = ""
	_phase = Phase.CHOOSING
	if _foe_intent != null and _foe_intent.interruptible:
		_message.text = "Wild %s readies %s. Your move?" % [_foe.creature_name, _foe_intent.move_name]
	else:
		_message.text = "What will %s do?" % player_creature.creature_name
	_refresh_move_buttons()
	_set_buttons_enabled(true)
	_move_buttons[0].grab_focus()


func _battle_moves(creature: CreatureData) -> Array[MoveData]:
	if not creature.moves.is_empty():
		return creature.moves
	var result: Array[MoveData] = []
	if creature.move != null:
		result.append(creature.move)
	return result


## When all equipped limited moves are spent, the first button becomes Strike.
func _selected_player_move(index: int) -> MoveData:
	var known: Array[MoveData] = _battle_moves(player_creature)
	if known.is_empty():
		return null
	var all_spent := true
	for candidate in known:
		if _uses_left(candidate, true) != 0:
			all_spent = false
			break
	if all_spent and index == 0:
		return null
	return known[index] if index < known.size() else null


func _uses_left(move: MoveData, by_player: bool) -> int:
	if move == null or move.max_uses == 0:
		return -1
	var stock: Dictionary = _player_uses if by_player else _foe_uses
	return stock.get(move, move.max_uses)


func _consume_move(move: MoveData, by_player: bool) -> void:
	if move == null or move.max_uses == 0:
		return
	var stock: Dictionary = _player_uses if by_player else _foe_uses
	stock[move] = _uses_left(move, by_player) - 1


func _choose_foe_move() -> MoveData:
	var available: Array[MoveData] = []
	for candidate in _battle_moves(_foe):
		if _uses_left(candidate, false) != 0:
			available.append(candidate)
	if available.is_empty():
		return null # Strike if every limited move is spent.
	return available.pick_random()


func _refresh_move_buttons() -> void:
	for button in _move_buttons:
		button.queue_free()
	_move_buttons.clear()
	var known: Array[MoveData] = _battle_moves(player_creature)
	for i in range(maxi(1, known.size())):
		var chosen: MoveData = _selected_player_move(i)
		var button := Button.new()
		button.custom_minimum_size = Vector2(220, 48)
		button.add_theme_font_size_override("font_size", 18)
		_skin_command_button(button)
		button.text = chosen.move_name if chosen != null else MOVE_NAME
		if chosen != null and chosen.kind == MoveData.Kind.GUARD:
			button.tooltip_text = "Brace first and reduce one incoming hit this round."
		elif chosen != null and chosen.kind == MoveData.Kind.INTERRUPT:
			button.tooltip_text = "Damage a foe and break a slower committed action."
		if chosen != null and chosen.max_uses > 0:
			button.text += "  %d/%d" % [_uses_left(chosen, true), chosen.max_uses]
		button.pressed.connect(_on_move_pressed.bind(i))
		_move_grid.add_child(button)
		_move_buttons.append(button)
	_strike_button = _move_buttons[0] # Compatibility for older scene callers.


func _on_move_pressed(index: int) -> void:
	if _phase != Phase.CHOOSING:
		return
	var chosen: MoveData = _selected_player_move(index)
	if _uses_left(chosen, true) == 0:
		return
	_player_intent = chosen
	_player_action_pending = true
	_foe_action_pending = true
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)

	# Guards brace before ordinary speed order. They consume the action.
	if chosen != null and chosen.kind == MoveData.Kind.GUARD:
		await _perform_action(true, chosen)
	if _foe_intent != null and _foe_intent.kind == MoveData.Kind.GUARD:
		await _foe_attack()

	if _player_first:
		if _player_action_pending and not _player_action_canceled:
			await _perform_action(true, chosen)
		if _phase == Phase.OVER:
			return
		if _foe_action_pending and not _foe_action_canceled:
			await _foe_attack()
	else:
		if _foe_action_pending and not _foe_action_canceled:
			await _foe_attack()
		if _phase == Phase.OVER:
			return
		if _player_action_pending and not _player_action_canceled:
			await _perform_action(true, chosen)

	if _phase != Phase.OVER:
		_begin_choice()


func _foe_attack() -> void:
	if not _foe_action_pending or _foe_action_canceled:
		return
	await _perform_action(false, _foe_intent)


func _perform_action(by_player: bool, move: MoveData) -> void:
	if by_player:
		_player_action_pending = false
	else:
		_foe_action_pending = false
	_consume_move(move, by_player)
	if move != null and move.kind == MoveData.Kind.GUARD:
		await _brace(by_player, move)
	else:
		await _attack(player_creature if by_player else _foe, by_player, move)


func _brace(by_player: bool, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var who := player_creature.creature_name if by_player else "Wild " + _foe.creature_name
	var fraction := clampf(move.guard_damage_fraction, 0.0, 1.0)
	if by_player:
		_player_guard_fraction = fraction
	else:
		_foe_guard_fraction = fraction
	_message.text = "%s used %s and braced!" % [who, move.move_name]
	_idle_hold = true
	var base_scale := Vector2.ONE * _zoom(sprite)
	var t := create_tween()
	t.tween_property(sprite, "scale", Vector2(base_scale.x * 1.05, base_scale.y * 0.92), 0.12)
	t.tween_property(sprite, "scale", base_scale, 0.18).set_trans(Tween.TRANS_SINE)
	await t.finished
	_idle_hold = false
	await get_tree().create_timer(BEAT * 0.5).timeout


## One creature hits the other. `by_player` says which side is attacking.
func _attack(attacker: CreatureData, by_player: bool, move: MoveData) -> void:
	var defender: CreatureData = _foe if by_player else player_creature
	# A move hits with its own essence. Strike hits with its user's.
	var essence: CreatureData.Essence = move.essence if move else attacker.essence
	var power: int = move.power if move else MOVE_POWER
	var multiplier := EssenceChart.multiplier(essence, defender.essence)
	var raw_dealt := _damage(attacker, defender, power, multiplier)
	var guard_fraction := _foe_guard_fraction if by_player else _player_guard_fraction
	var dealt := maxi(1, int(ceil(float(raw_dealt) * guard_fraction)))
	var guarded := raw_dealt - dealt
	_last_interrupt = ""

	var who := attacker.creature_name if by_player else "Wild " + attacker.creature_name
	_message.text = "%s used %s!" % [who, move.move_name if move else MOVE_NAME]
	_tween_focus(Vector2(focus_shift_px if by_player else -focus_shift_px, 0), focus_zoom, 0.16)

	# Damage is applied at the moment of contact inside the animation, not
	# before it, so the number and the picture agree.
	if move and not move.attack_frames.is_empty() and (not by_player or attacker.back_sprite == null):
		await _drawn_attack_animation(by_player, dealt, multiplier, move)
	elif move and move.effect:
		await _projectile_animation(by_player, dealt, multiplier, move.effect, move)
	else:
		await _strike_animation(by_player, dealt, multiplier, move)
	_tween_focus(Vector2.ZERO, 1.0, 0.24)

	var note := EssenceChart.effectiveness_text(multiplier)
	if note.is_empty():
		_message.text = "It dealt %d damage." % dealt
	else:
		_message.text = "%s  %d damage." % [note, dealt]
	if guarded > 0:
		_message.text += " Guarded %d." % guarded
	if not _last_interrupt.is_empty():
		_message.text += " " + _last_interrupt
	await get_tree().create_timer(BEAT).timeout

	if _foe_hp == 0:
		_message.text = "The wild %s fainted." % _foe.creature_name
		await get_tree().create_timer(BEAT).timeout
		# Leaves the message alone if nothing evolved, so _finish below just
		# holds whatever the last line said.
		await _try_evolve()
		await _finish(_message.text)
	elif _player_hp == 0:
		await _finish("%s fainted." % player_creature.creature_name)


## Damage is attack times move power, divided by defence times four, then
## scaled by the essence matchup, never below 1.
##
## With every stat at 60 and a power of 40 the base is 10 a hit. A strong
## matchup doubles that to 20, a weak one halves it to 5, so a 60 HP creature
## falls in three hits or twelve depending on what is hitting it.
##
## No random variance on purpose. It keeps the number predictable while you are
## learning what the formula does, and it makes the battle testable. Variance is
## one multiplication when you want it.
func _damage(attacker: CreatureData, defender: CreatureData, power: int, multiplier: float) -> int:
	var raw := attacker.base_attack * power / (defender.base_defense * 4.0)
	return maxi(1, int(raw * multiplier))


## The chance the next capture attempt succeeds, 0 to 1. Split out from the
## attempt itself so the number can be checked without rolling a dice.
func catch_chance() -> float:
	var ratio := float(_foe_hp) / _foe.base_hp
	return CATCH_BASE + (1.0 - ratio) * CATCH_BONUS


func _on_catch_pressed() -> void:
	if _phase != Phase.CHOOSING:
		return
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)

	if PlayerParty.is_full():
		_message.text = "Your party is full."
		await get_tree().create_timer(BEAT).timeout
		_begin_choice()
		return

	_message.text = "You reach for the wild %s!" % _foe.creature_name
	await get_tree().create_timer(BEAT).timeout

	if randf() < catch_chance():
		PlayerParty.add(_foe)
		await _finish("Caught %s!" % _foe.creature_name)
		return

	_message.text = "It broke free!"
	await get_tree().create_timer(BEAT).timeout

	# A failed attempt costs the round; use the foe's declared action.
	_player_intent = null
	_player_action_pending = false
	_foe_action_pending = true
	await _foe_attack()
	if _phase != Phase.OVER:
		_begin_choice()


# ---------------------------------------------------------------- impact
#
# Everything below exists to make a hit read as a hit instead of as a number
# changing. None of it touches the rules: the damage is identical either way.

## The whole strike as one tween: wind up, lunge, freeze on contact, recover.
## Anticipation then follow through, which is the oldest trick in animation.
func _strike_animation(by_player: bool, dealt: int, multiplier: float, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var dir := 1.0 if by_player else -1.0
	_idle_hold = true
	var home: Vector2 = sprite.position

	var t := create_tween()
	t.tween_property(sprite, "position", home - Vector2(dir * 18, 0), 0.10).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position", home + Vector2(dir * 62, 0), 0.07).set_ease(Tween.EASE_OUT)
	t.tween_callback(_on_impact.bind(by_player, dealt, multiplier, move))
	t.tween_interval(HIT_STOP)
	t.tween_property(sprite, "position", home, 0.22).set_trans(Tween.TRANS_SINE)
	await t.finished
	_idle_hold = false


## Hand-drawn same-form attack poses. The source sheets share one canvas and baseline,
## so only a small lunge is added; the hit lands on the penultimate action pose.
func _drawn_attack_animation(by_player: bool, dealt: int, multiplier: float, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var home: Vector2 = sprite.position
	var original_texture: Texture2D = sprite.texture
	var dir: float = 1.0 if by_player else -1.0
	var impact_index: int = maxi(0, move.attack_frames.size() - 2)
	_idle_hold = true
	for frame_index in range(move.attack_frames.size()):
		sprite.texture = move.attack_frames[frame_index]
		if frame_index < 2:
			sprite.position = home - Vector2(dir * 8.0, 0.0)
		elif frame_index < impact_index:
			sprite.position = home + Vector2(dir * 12.0, 0.0)
		else:
			sprite.position = home + Vector2(dir * 30.0, 0.0)
		if frame_index == impact_index:
			_drawn_impact_effect(by_player, move)
			_on_impact(by_player, dealt, multiplier, move)
		await get_tree().create_timer(maxf(0.04, move.attack_frame_seconds)).timeout
	sprite.texture = original_texture
	sprite.position = home
	_idle_hold = false


## Show the claw art on the target at the exact hit frame. The creature
## animation stays on Ironvent; the slash and molten debris belong to the hit.
func _drawn_impact_effect(by_player: bool, move: MoveData) -> void:
	if move.effect == null:
		return
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var effect: Node2D = move.effect.instantiate()
	effect.position = target.position
	_battle_stage.add_child(effect)
	var burst: CPUParticles2D = effect.get_node_or_null("Burst")
	if burst:
		burst.restart()
	var flash: Sprite2D = effect.get_node_or_null("Flash")
	if flash:
		_burst_flash(flash)
	var impact: Sprite2D = effect.get_node_or_null("Impact")
	if impact:
		impact.visible = true
		var fade := create_tween()
		fade.tween_interval(0.12)
		fade.tween_property(impact, "visible", false, 0.0)
	get_tree().create_timer(0.65).timeout.connect(effect.queue_free)


## A move thrown across the screen instead of carried in a lunge: the user
## rears back and flicks forward, the effect flies to the target leaving its
## Trail, and the Burst goes off on contact. The contact frame is the same
## _on_impact Strike uses, so flash, shake and damage numbers still apply.
func _projectile_animation(by_player: bool, dealt: int, multiplier: float, effect_scene: PackedScene, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var dir := 1.0 if by_player else -1.0
	_idle_hold = true
	var home: Vector2 = sprite.position

	var effect: Node2D = effect_scene.instantiate()
	var trail: CPUParticles2D = effect.get_node("Trail")
	var burst: CPUParticles2D = effect.get_node("Burst")
	# Optional drawn pieces. An effect made only of particles still works.
	var ball: Sprite2D = effect.get_node_or_null("Ball")
	var flash: Sprite2D = effect.get_node_or_null("Flash")

	# The ball art flies down and to the right. Mirroring, never rotating,
	# because rotated pixel art stops lining up with the pixel grid. Your side
	# throws up and right (flip top to bottom); the foe throws down and left
	# (flip left to right).
	if ball:
		ball.flip_v = by_player
		ball.flip_h = not by_player

	var t := create_tween()
	t.tween_property(sprite, "position", home - Vector2(dir * 14, 6), 0.14).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position", home + Vector2(dir * 16, 0), 0.06).set_ease(Tween.EASE_OUT)
	await t.finished

	# Added last so it draws over both creatures. Launched from the user's
	# front edge rather than its centre, so it leaves the mouth, not the belly.
	effect.position = home + Vector2(dir * 40, 0)
	_battle_stage.add_child(effect)
	trail.emitting = true

	var fly := create_tween()
	fly.set_parallel()
	fly.tween_property(effect, "position", target.position, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(sprite, "position", home, 0.22).set_trans(Tween.TRANS_SINE)
	await fly.finished

	trail.emitting = false
	if ball:
		ball.visible = false
	burst.restart()
	if flash:
		_burst_flash(flash)
	_on_impact(by_player, dealt, multiplier, move)
	await get_tree().create_timer(HIT_STOP + 0.22).timeout

	# Let the last embers finish their lives before removing the effect.
	get_tree().create_timer(burst.lifetime + 0.1).timeout.connect(effect.queue_free)
	_idle_hold = false


## The drawn burst on contact. It pops from 2x to 3x rather than growing
## smoothly, because an in-between size like 2.4x smears the pixels. Then it
## flickers out instead of fading, which reads as fire rather than as a dissolve.
func _burst_flash(flash: Sprite2D) -> void:
	flash.visible = true
	flash.scale = Vector2(2, 2)
	var t := create_tween()
	t.tween_interval(0.05)
	t.tween_property(flash, "scale", Vector2(3, 3), 0.0)
	t.tween_interval(0.12)
	for i in 3:
		t.tween_property(flash, "visible", false, 0.0)
		t.tween_interval(0.04)
		t.tween_property(flash, "visible", true, 0.0)
		t.tween_interval(0.04)
	t.tween_property(flash, "visible", false, 0.0)


## The single frame where the hit lands.
func _on_impact(by_player: bool, dealt: int, multiplier: float, move: MoveData) -> void:
	if by_player:
		_foe_hp = maxi(0, _foe_hp - dealt)
		_foe_guard_fraction = 1.0
	else:
		_player_hp = maxi(0, _player_hp - dealt)
		_player_guard_fraction = 1.0

	if move != null and move.kind == MoveData.Kind.INTERRUPT:
		if by_player and _foe_action_pending and _foe_intent != null and _foe_intent.interruptible:
			_foe_action_canceled = true
			_last_interrupt = "Wild %s's %s was interrupted." % [_foe.creature_name, _foe_intent.move_name]
		elif not by_player and _player_action_pending and _player_intent != null and _player_intent.interruptible:
			_player_action_canceled = true
			_last_interrupt = "%s's %s was interrupted." % [player_creature.creature_name, _player_intent.move_name]

	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	_flash(target)
	_shake(dealt)
	_pop_damage(target, dealt, multiplier)
	_animate_bars()


## The struck creature blows out bright and squashes, then springs back.
func _flash(sprite: Sprite2D) -> void:
	var bright := create_tween()
	bright.tween_property(sprite, "modulate", Color(6, 6, 6), 0.03)
	bright.tween_property(sprite, "modulate", Color.WHITE, 0.18)

	var squash := create_tween()
	squash.tween_property(sprite, "scale", Vector2(_zoom(sprite) * 1.15, _zoom(sprite) * 0.88), 0.05)
	squash.tween_property(sprite, "scale", Vector2.ONE * _zoom(sprite), 0.22) 		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Battle-stage shake, scaled by how hard the hit was.
##
## Trauma is squared, so a strong hit feels explosive while a weak one barely
## registers. Shaking every hit the same amount is what turns shake into noise
## instead of weight, and it is the usual reason shake feels cheap.
func _shake(dealt: int) -> void:
	var trauma: float = clampf(float(dealt) / 25.0, 0.0, 1.0)
	var power: float = 16.0 * trauma * trauma
	if power < 0.5:
		return
	var t := create_tween()
	for i in 6:
		t.tween_property(_battle_stage, "position",
			Vector2(randf_range(-power, power), randf_range(-power, power)), 0.035)
	t.tween_property(_battle_stage, "position", Vector2.ZERO, 0.09)


## The damage number lifts off the target and fades out.
func _pop_damage(at: Sprite2D, dealt: int, multiplier: float) -> void:
	var label := Label.new()
	label.text = str(dealt)
	label.add_theme_font_size_override("font_size", 34 if multiplier > 1.0 else 24)
	label.add_theme_color_override("font_color",
		Color(1, 0.82, 0.28) if multiplier > 1.0 else Color(0.95, 0.95, 1.0))
	label.position = at.position + Vector2(-12, -70)
	_battle_stage.add_child(label)

	var move := create_tween()
	move.tween_property(label, "position", label.position + Vector2(0, -55), 0.75) 		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	move.tween_callback(label.queue_free)

	var fade := create_tween()
	fade.tween_interval(0.3)
	fade.tween_property(label, "modulate:a", 0.0, 0.45)


## HP slides down instead of snapping. A bar that jumps between values is the
## clearest single tell that nothing in the scene is animated.
func _animate_bars() -> void:
	_player_hp_text.text = "%d / %d" % [_player_hp, player_creature.base_hp]
	_foe_hp_text.text = "%d / %d" % [_foe_hp, _foe.base_hp]
	# The value_changed signal keeps the fill colour aligned with the visible
	# half-second HP slide instead of jumping to the final colour at hit start.
	var p := create_tween()
	p.tween_property(_player_bar, "value", _player_hp, 0.5) 		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var f := create_tween()
	f.tween_property(_foe_bar, "value", _foe_hp, 0.5) 		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_flee_pressed() -> void:
	if _phase != Phase.CHOOSING:
		return
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)
	# Fleeing always works. A flee that can fail is a mechanic, and mechanics
	# come after the loop works.
	await _finish("Got away safely.")


func _finish(final_message: String) -> void:
	_phase = Phase.OVER
	_player_action_pending = false
	_foe_action_pending = false
	_player_guard_fraction = 1.0
	_foe_guard_fraction = 1.0
	_idle_on = false
	_set_buttons_enabled(false)
	_message.text = final_message
	await get_tree().create_timer(BEAT * 1.5).timeout
	visible = false
	if _focus_tween != null and _focus_tween.is_valid():
		_focus_tween.kill()
	_focus_stage.position = Vector2.ZERO
	_focus_stage.scale = Vector2.ONE
	get_tree().paused = false


# ---------------------------------------------------------------- evolution

## Evolves the player's creature if it has somewhere to go. Does nothing, and
## leaves the message untouched, if it does not.
##
## The current prototype trigger is the battle win Preston approved for the
## Cinderhide line. Final evolution conditions remain open; do not add levels
## to justify an unapproved trigger.
##
## The active party member keeps its identity while its species changes.
## This is still a run-local prototype; evolution conditions remain provisional.
func _try_evolve() -> void:
	var next: CreatureData = player_creature.evolves_into
	if next == null or PlayerParty.active_creature() != player_creature:
		return

	var before: String = player_creature.creature_name
	_message.text = "%s is changing!" % before
	await get_tree().create_timer(BEAT).timeout

	await _evolution_animation(next)

	if not PlayerParty.evolve_active(player_creature, next):
		push_error("Active creature changed during evolution.")
		return

	player_creature = next
	# The new form's HP pool is usually larger. Carrying the old current HP over
	# rather than refilling keeps the win from doubling as a free heal, and the
	# clamp covers the case where the evolved form is somehow frailer.
	_player_hp = mini(_player_hp, next.base_hp)
	_player_name.text = next.creature_name
	_refresh_bars()

	_message.text = "%s evolved into %s!" % [before, next.creature_name]
	await get_tree().create_timer(BEAT * 1.5).timeout


## White out, swell, swap the texture at the peak, settle back.
##
## The swap happens while the sprite is pure white, so you never actually watch
## one creature turn into the other. That single trick is the whole reason the
## genre's evolution reads as a transformation instead of a texture change, and
## it is why the timing below matters more than the numbers do.
func _evolution_animation(next: CreatureData) -> void:
	var s: Sprite2D = _player_sprite
	_idle_hold = true
	_tween_focus(Vector2(focus_shift_px, 0), focus_zoom, 0.30)

	var glow := create_tween()
	glow.tween_property(s, "modulate", Color(8, 8, 8), 0.5)

	var swell := create_tween()
	swell.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	swell.tween_property(s, "scale", Vector2.ONE * _zoom(s) * 1.3, 0.5)

	await glow.finished

	s.texture = next.back_sprite if next.back_sprite != null else next.sprite

	# Reuses the hit shake with a high value, because the argument is damage and
	# there is no damage here. It is the landing thump, not a hit.
	_shake(22)

	var settle := create_tween()
	settle.tween_property(s, "modulate", Color.WHITE, 0.4)

	var shrink := create_tween()
	shrink.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	shrink.tween_property(s, "scale", Vector2.ONE * _zoom(s), 0.45)

	await settle.finished

	# Hand the sprite back to the idle loop, which counts its bob from home.
	s.position = _player_home
	_tween_focus(Vector2.ZERO, 1.0, 0.30)
	_idle_hold = false


## Keep each creature's own battle size, then place the opponent at the
## smaller, distant scale. Most sprites retain whole-number zoom. A 128px foe
## can land on a half step rather than jumping from 2x all the way to 1x.
## The battle's nearest texture filter keeps the source pixels sharp.
func _zoom(s: Sprite2D) -> float:
	if s.texture == null:
		return 3.0
	var target: float = CREATURE_HEIGHT * _battle_size_of(s)
	var near_zoom: float = maxf(1.0, roundf(target / s.texture.get_height()))
	if s == _foe_sprite:
		return maxf(1.0, roundf(near_zoom * foe_perspective_scale * 2.0) / 2.0)
	return near_zoom


## The size multiplier of the creature a battle sprite is currently showing.
##
## There are only ever two battle sprites, so telling them apart is a straight
## comparison against the foe. Anything that is not the foe is the player's,
## and that stays correct through the evolution swap because the player's
## creature reference changes and this reads it fresh instead of caching it.
func _battle_size_of(s: Sprite2D) -> float:
	var creature: CreatureData = player_creature
	if s == _foe_sprite:
		creature = _foe
	if creature == null:
		return 1.0
	return maxf(0.1, creature.battle_size)


# ---------------------------------------------------------------- idle motion
#
# The breathing loop. It runs every frame a battle is on screen and writes the
# creatures' squash and stretch. Both get it, out of phase with each other,
# because two sprites breathing in perfect time reads as a machine rather than
# as two animals standing there.

func _process(delta: float) -> void:
	if not _idle_on or _idle_hold:
		return
	_idle_time += delta
	# Read from the creature every frame rather than caching, so evolving mid-line
	# picks up the new form's breathing the moment the sprite swaps.
	_apply_idle(_player_sprite, _player_home, player_creature, 0.0)
	# The foe breathes a little behind the player so they never lock in step, and
	# its own period keeps the two from drifting back into time with each other.
	_apply_idle(_foe_sprite, _foe_home, _foe, 0.35)


## One breath, as a wave running from -1 fully let out to +1 fully drawn in.
##
## The intake is stretched over INHALE_SHARE of the cycle and the release takes
## the rest, so the creature fills its chest slowly and settles back a little
## quicker. A plain sine would tick like a clock; this does not.
func _breath_wave(cycle: float) -> float:
	var t: float = fposmod(cycle, 1.0)
	var half: float
	if t < INHALE_SHARE:
		half = 0.5 * t / INHALE_SHARE
	else:
		half = 0.5 + 0.5 * (t - INHALE_SHARE) / (1.0 - INHALE_SHARE)
	return -cos(TAU * half)


## One creature's breath. `phase` is a fraction of a full cycle that offsets it
## from the other creature, and `creature` supplies this form's own depth and
## speed.
func _apply_idle(s: Sprite2D, home: Vector2, creature: CreatureData, phase: float) -> void:
	if s == null or s.texture == null or creature == null:
		return
	# A hand-drawn front loop takes precedence over procedural breathing. A real
	# back sprite keeps the old motion until its own sheet has been drawn.
	if not creature.idle_frames.is_empty() and (s == _foe_sprite or creature.back_sprite == null):
		var duration: float = maxf(0.2, creature.idle_period)
		var frame_count: int = creature.idle_frames.size()
		var frame_index: int = mini(frame_count - 1, int(floor(fposmod(_idle_time, duration) / duration * frame_count)))
		s.texture = creature.idle_frames[frame_index]
		s.scale = Vector2.ONE * _zoom(s)
		s.position = home
		return
	var zoom: float = _zoom(s)
	var depth: float = maxf(0.0, creature.idle_breath)
	if is_zero_approx(depth):
		# A creature set to breathe 0 stands completely still.
		s.scale = Vector2.ONE * zoom
		s.position = home
		return
	var period: float = maxf(0.2, creature.idle_period)
	var breathe: float = _breath_wave(_idle_time / period + phase)
	# The body stretches taller drawing breath in and squashes shorter letting it
	# out. The sideways crush is half the vertical stretch, which is what keeps
	# the volume reading as the same creature rather than as a growing one.
	var tall: float = zoom * (1.0 + breathe * depth)
	s.scale = Vector2(zoom * (1.0 - breathe * depth * 0.5), tall)
	# Sprite2D scales about its centre, so stretching would drive the feet
	# through the floor. Lifting by half of the height change pins them where
	# they stand, and that is what makes this read as breathing instead of as
	# the whole creature drifting up and down.
	s.position = home + Vector2(0.0, roundf(-s.texture.get_height() * (tall - zoom) * 0.5))


# ---------------------------------------------------------------- display

func _refresh_bars() -> void:
	_player_bar.max_value = player_creature.base_hp
	_player_bar.value = _player_hp
	_foe_bar.max_value = _foe.base_hp
	_foe_bar.value = _foe_hp
	_player_hp_text.text = "%d / %d" % [_player_hp, player_creature.base_hp]
	_foe_hp_text.text = "%d / %d" % [_foe_hp, _foe.base_hp]
	_tint_bar(_player_bar, float(_player_hp) / player_creature.base_hp)
	_tint_bar(_foe_bar, float(_foe_hp) / _foe.base_hp)


## Turbo Green viridian at full health flows through yellow and orange in
## the middle range, then red at low HP. The fill length remains exact HP / max HP.
func _health_colour(ratio: float) -> Color:
	var hp := clampf(ratio, 0.0, 1.0)
	var critical := Color("#922B35")
	var low := Color("#C24841")
	var orange := Color("#D47B37")
	var yellow := Color("#DDB651")
	var full := Color("#1B8E78")
	if hp <= 0.15:
		return critical
	if hp <= 0.35:
		return critical.lerp(low, (hp - 0.15) / 0.20)
	if hp <= 0.50:
		return low.lerp(orange, (hp - 0.35) / 0.15)
	if hp <= 0.70:
		return orange.lerp(yellow, (hp - 0.50) / 0.20)
	if hp <= 0.80:
		return yellow.lerp(full, (hp - 0.70) / 0.10)
	return full


func _tint_bar(bar: ProgressBar, ratio: float) -> void:
	var fill := bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = _health_colour(ratio)


func _on_bar_value_changed(value: float, bar: ProgressBar) -> void:
	_tint_bar(bar, value / maxf(bar.max_value, 1.0))


func _set_buttons_enabled(on: bool) -> void:
	_buttons.visible = on
	for i in range(_move_buttons.size()):
		var selected: MoveData = _selected_player_move(i)
		_move_buttons[i].disabled = not on or _uses_left(selected, true) == 0
	_catch_button.disabled = not on
	_flee_button.disabled = not on


func _focus_target(pan_offset: Vector2, zoom: float) -> Vector2:
	var center := Vector2(576, 324)
	return center - center * zoom + pan_offset


func _tween_focus(pan_offset: Vector2, zoom: float, duration: float) -> void:
	if _focus_tween != null and _focus_tween.is_valid():
		_focus_tween.kill()
	_focus_tween = create_tween()
	_focus_tween.set_parallel()
	_focus_tween.tween_property(_focus_stage, "position", _focus_target(pan_offset, zoom), duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_focus_tween.tween_property(_focus_stage, "scale", Vector2.ONE * zoom, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.06, 0.07, 0.12, 1.0)
	add_child(backdrop)

	# The focus rig moves the river and creatures together. Impacts still shake
	# only BattleStage, and all HUD controls remain on the fixed CanvasLayer.
	_focus_stage = Node2D.new()
	_focus_stage.name = "FocusStage"
	add_child(_focus_stage)

	# A 288x162 original cutbank study shown at an exact fourfold resting scale.
	var river_landing := Sprite2D.new()
	river_landing.name = "RiverLanding"
	river_landing.texture = RIVER_LANDING
	river_landing.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	river_landing.position = Vector2(576, 324)
	river_landing.scale = Vector2(4, 4)
	_focus_stage.add_child(river_landing)

	# Creatures, projectiles, and damage numbers move together on this stage.
	# HUD controls stay on the CanvasLayer so impacts do not shake the interface.
	_battle_stage = Node2D.new()
	_battle_stage.name = "BattleStage"
	_focus_stage.add_child(_battle_stage)

	# Foe sits top right, player bottom left, so they face each other. The
	# sprite art faces right, so the foe is flipped.
	_foe_sprite = Sprite2D.new()
	_foe_home = Vector2(820, 190)
	_foe_sprite.position = _foe_home
	_foe_sprite.scale = Vector2.ONE * _zoom(_foe_sprite)
	_foe_sprite.flip_h = true
	_battle_stage.add_child(_foe_sprite)

	_player_sprite = Sprite2D.new()
	_player_home = Vector2(300, 350)
	_player_sprite.position = _player_home
	_player_sprite.scale = Vector2.ONE * _zoom(_player_sprite)
	_battle_stage.add_child(_player_sprite)

	# Names and HP numbers sit on separate headers above the framed bars.
	# This keeps the HUD sheet's top border clear and makes both lines readable.
	var foe_header := _make_health_header(Vector2(70, 42))
	_foe_name = _make_creature_name()
	_foe_hp_text = _make_hp_number()
	foe_header.add_child(_foe_name)
	foe_header.add_child(_foe_hp_text)
	_add_hud_panel(Vector2(52, 85), Vector2(500, 112))
	var foe_bar_holder := _make_bar_holder()
	foe_bar_holder.position = Vector2(90, 117)
	_foe_bar = foe_bar_holder.get_node("Fill") as ProgressBar
	add_child(foe_bar_holder)

	# The player panel ends above the move controls.
	var player_header := _make_health_header(Vector2(660, 270))
	_player_name = _make_creature_name()
	_player_hp_text = _make_hp_number()
	player_header.add_child(_player_name)
	player_header.add_child(_player_hp_text)
	_add_hud_panel(Vector2(642, 313), Vector2(500, 112))
	var player_bar_holder := _make_bar_holder()
	player_bar_holder.position = Vector2(680, 345)
	_player_bar = player_bar_holder.get_node("Fill") as ProgressBar
	add_child(player_bar_holder)

	_add_hud_panel(Vector2(55, 510), Vector2(570, 130))
	_message = _make_label("", 22)
	_message.position = Vector2(100, 550)
	_message.size = Vector2(490, 44)
	add_child(_message)

	_buttons = VBoxContainer.new()
	_buttons.position = Vector2(650, 430)
	_buttons.add_theme_constant_override("separation", 8)
	add_child(_buttons)

	_move_grid = GridContainer.new()
	_move_grid.columns = 2
	_move_grid.add_theme_constant_override("h_separation", 8)
	_move_grid.add_theme_constant_override("v_separation", 8)
	_buttons.add_child(_move_grid)

	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 8)
	_buttons.add_child(utility)

	_catch_button = Button.new()
	_catch_button.text = "Catch"
	_catch_button.custom_minimum_size = Vector2(220, 48)
	_catch_button.add_theme_font_size_override("font_size", 18)
	_skin_command_button(_catch_button, true)
	_catch_button.pressed.connect(_on_catch_pressed)
	utility.add_child(_catch_button)

	_flee_button = Button.new()
	_flee_button.text = "Flee"
	_flee_button.custom_minimum_size = Vector2(220, 48)
	_flee_button.add_theme_font_size_override("font_size", 18)
	_skin_command_button(_flee_button)
	_flee_button.pressed.connect(_on_flee_pressed)
	utility.add_child(_flee_button)


## Hollowtide field instruments: slate, river metal, and warm silt edges.
## The health signal alone carries Turbo Green; controls and text stay neutral.
func _field_box(face: Color, edge: Color, border: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = face
	box.border_color = edge
	box.set_border_width_all(border)
	box.set_corner_radius_all(2)
	return box


func _add_hud_panel(at: Vector2, dimensions: Vector2) -> void:
	var outer := Panel.new()
	outer.position = at
	outer.size = dimensions
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_theme_stylebox_override("panel", _field_box(Color("#171C21"), Color("#75604D"), 3))
	add_child(outer)
	var inset := Panel.new()
	inset.position = Vector2(6, 6)
	inset.size = dimensions - Vector2(12, 12)
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.add_theme_stylebox_override("panel", _field_box(Color("#242E32"), Color("#3E5A58"), 1))
	outer.add_child(inset)
	var route_mark := ColorRect.new()
	route_mark.position = Vector2(17, 12)
	route_mark.size = Vector2(64, 3)
	route_mark.color = Color("#A38C74")
	route_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(route_mark)


func _make_bar_holder() -> Control:
	var holder := Panel.new()
	holder.custom_minimum_size = Vector2(420, 46)
	holder.size = Vector2(420, 46)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_theme_stylebox_override("panel", _field_box(Color("#10191B"), Color("#8F756D"), 3))
	var bar := _make_bar()
	bar.name = "Fill"
	bar.position = Vector2(9, 10)
	bar.custom_minimum_size = Vector2(402, 26)
	bar.size = Vector2(402, 26)
	holder.add_child(bar)
	return holder


func _command_background(face: Color, edge: Color, border: int = 2) -> StyleBoxFlat:
	var box := _field_box(face, edge, border)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 5
	box.content_margin_bottom = 5
	return box


func _skin_command_button(button: Button, teal: bool = false) -> void:
	var face := Color("#2C4743") if teal else Color("#29343A")
	var rim := Color("#547D70") if teal else Color("#75604D")
	button.add_theme_stylebox_override("normal", _command_background(face, rim))
	button.add_theme_stylebox_override("hover", _command_background(Color("#36524B"), Color("#1B8E78"), 3))
	button.add_theme_stylebox_override("pressed", _command_background(Color("#1B302D"), Color("#1B8E78"), 3))
	button.add_theme_stylebox_override("disabled", _command_background(Color("#20272B"), Color("#494B48")))
	button.add_theme_stylebox_override("focus", _command_background(Color.TRANSPARENT, Color("#1B8E78"), 2))
	button.add_theme_font_override("font", HP_NUMBER_FONT)
	button.add_theme_color_override("font_color", Color("#F0F4F8"))
	button.add_theme_color_override("font_hover_color", Color("#FFFFFF"))
	button.add_theme_color_override("font_pressed_color", Color("#F0F4F8"))
	button.add_theme_color_override("font_disabled_color", Color("#87928D"))


func _make_health_header(at: Vector2) -> HBoxContainer:
	var plate := Panel.new()
	plate.position = at
	plate.size = Vector2(466, 38)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override("panel", _field_box(Color("#1A2429"), Color("#75604D"), 2))
	add_child(plate)
	var row := HBoxContainer.new()
	row.position = Vector2(16, 3)
	row.size = Vector2(434, 32)
	row.add_theme_constant_override("separation", 0)
	plate.add_child(row)
	return row


func _make_creature_name() -> Label:
	var label := _make_label("", 24)
	label.custom_minimum_size = Vector2(340, 32)
	label.add_theme_font_override("font", CREATURE_NAME_FONT)
	label.add_theme_color_override("font_color", Color("#F0F4F8"))
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label


func _make_hp_number() -> Label:
	var label := _make_label("", 17)
	label.custom_minimum_size = Vector2(94, 32)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_override("font", HP_NUMBER_FONT)
	label.add_theme_color_override("font_color", Color("#DCE7E3"))
	return label


func _make_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", HP_NUMBER_FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("#F0F4F8"))
	return label


func _make_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(402, 26)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("#12302B")
	track.border_color = Color("#0B1518")
	track.set_border_width_all(2)
	bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#1B8E78")
	bar.add_theme_stylebox_override("fill", fill)
	bar.value_changed.connect(_on_bar_value_changed.bind(bar))
	return bar
