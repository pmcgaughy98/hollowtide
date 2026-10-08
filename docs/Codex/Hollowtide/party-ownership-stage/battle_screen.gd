extends CanvasLayer

## The battle. Each side chooses one move per round; first creature to zero HP faints.
##
## Not built yet: experience, levels, status effects, items,
## and saving.
## Evolution below has only a win-trigger prototype; Preston has not approved this
## condition.

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

## How far past the viewport the backdrop is grown. Screen shake moves the
## whole layer, so a backdrop sized exactly to the screen slides off it and
## exposes the void behind. Bigger than the strongest shake and it never shows.
const SHAKE_MARGIN := 48

## How tall a creature stands on screen, in screen pixels. Each sprite gets the
## whole-number zoom that lands closest to this, so old 96x88 art draws at 3x
## and new 64x64 art at 4x, and both end up about the same size. Whole numbers
## only, because a zoom like 3.4 makes some pixels wider than others.
const CREATURE_HEIGHT := 264

enum Phase { CHOOSING, RESOLVING, OVER }

var _phase: Phase = Phase.OVER
var _foe: CreatureData
var _player_hp: int = 0
var _foe_hp: int = 0
var _player_first: bool = true

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

	# Faster creature acts first for the whole battle. Ties go to the player.
	_player_first = player_creature.base_speed >= _foe.base_speed

	_foe_sprite.texture = _foe.sprite
	_player_sprite.texture = player_creature.back_sprite if player_creature.back_sprite != null else player_creature.sprite
	# Reset anything a previous battle's animation might have left behind.
	for s in [_foe_sprite, _player_sprite]:
		s.scale = Vector2.ONE * _zoom(s)
		s.modulate = Color.WHITE
	offset = Vector2.ZERO
	_foe_name.text = _foe.creature_name + "   " + _foe.essence_name()
	_player_name.text = player_creature.creature_name + "   " + player_creature.essence_name()
	_refresh_bars()
	_refresh_move_buttons()

	visible = true
	get_tree().paused = true
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)
	_message.text = "A wild %s appeared!" % _foe.creature_name

	await get_tree().create_timer(BEAT).timeout
	_begin_choice()


# ---------------------------------------------------------------- turn loop

func _begin_choice() -> void:
	_phase = Phase.CHOOSING
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
		var chosen: MoveData = known[i] if i < known.size() else null
		var button := Button.new()
		button.custom_minimum_size = Vector2(204, 40)
		button.text = chosen.move_name if chosen != null else MOVE_NAME
		if chosen != null and chosen.max_uses > 0:
			button.text += "  %d/%d" % [_uses_left(chosen, true), chosen.max_uses]
		button.pressed.connect(_on_move_pressed.bind(i))
		_move_grid.add_child(button)
		_move_buttons.append(button)
	_strike_button = _move_buttons[0] # Compatibility for older scene callers.


func _on_move_pressed(index: int) -> void:
	if _phase != Phase.CHOOSING:
		return
	var known: Array[MoveData] = _battle_moves(player_creature)
	var chosen: MoveData = known[index] if index < known.size() else null
	if _uses_left(chosen, true) == 0:
		return
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)
	_consume_move(chosen, true)

	# The selected action resolves in speed order, preserving the existing hit timing.
	if _player_first:
		await _attack(player_creature, true, chosen)
		if _phase == Phase.OVER:
			return
		await _foe_attack()
	else:
		await _foe_attack()
		if _phase == Phase.OVER:
			return
		await _attack(player_creature, true, chosen)

	if _phase != Phase.OVER:
		_begin_choice()


func _foe_attack() -> void:
	var chosen: MoveData = _choose_foe_move()
	_consume_move(chosen, false)
	await _attack(_foe, false, chosen)


## One creature hits the other. `by_player` says which side is attacking.
func _attack(attacker: CreatureData, by_player: bool, move: MoveData) -> void:
	var defender: CreatureData = _foe if by_player else player_creature
	# A move hits with its own essence. Strike hits with its user's.
	var essence: CreatureData.Essence = move.essence if move else attacker.essence
	var power: int = move.power if move else MOVE_POWER
	var multiplier := EssenceChart.multiplier(essence, defender.essence)
	var dealt := _damage(attacker, defender, power, multiplier)

	var who := attacker.creature_name if by_player else "Wild " + attacker.creature_name
	_message.text = "%s used %s!" % [who, move.move_name if move else MOVE_NAME]

	# Damage is applied at the moment of contact inside the animation, not
	# before it, so the number and the picture agree.
	if move and move.effect:
		await _projectile_animation(by_player, dealt, multiplier, move.effect)
	else:
		await _strike_animation(by_player, dealt, multiplier)

	var note := EssenceChart.effectiveness_text(multiplier)
	if note.is_empty():
		_message.text = "It dealt %d damage." % dealt
	else:
		_message.text = "%s  %d damage." % [note, dealt]
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

	# A failed attempt costs the round, so the wild creature still gets its hit.
	await _foe_attack()
	if _phase != Phase.OVER:
		_begin_choice()


# ---------------------------------------------------------------- impact
#
# Everything below exists to make a hit read as a hit instead of as a number
# changing. None of it touches the rules: the damage is identical either way.

## The whole strike as one tween: wind up, lunge, freeze on contact, recover.
## Anticipation then follow through, which is the oldest trick in animation.
func _strike_animation(by_player: bool, dealt: int, multiplier: float) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var dir := 1.0 if by_player else -1.0
	var home: Vector2 = sprite.position

	var t := create_tween()
	t.tween_property(sprite, "position", home - Vector2(dir * 18, 0), 0.10).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position", home + Vector2(dir * 62, 0), 0.07).set_ease(Tween.EASE_OUT)
	t.tween_callback(_on_impact.bind(by_player, dealt, multiplier))
	t.tween_interval(HIT_STOP)
	t.tween_property(sprite, "position", home, 0.22).set_trans(Tween.TRANS_SINE)
	await t.finished


## A move thrown across the screen instead of carried in a lunge: the user
## rears back and flicks forward, the effect flies to the target leaving its
## Trail, and the Burst goes off on contact. The contact frame is the same
## _on_impact Strike uses, so flash, shake and damage numbers still apply.
func _projectile_animation(by_player: bool, dealt: int, multiplier: float, effect_scene: PackedScene) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var dir := 1.0 if by_player else -1.0
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
	add_child(effect)
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
	_on_impact(by_player, dealt, multiplier)
	await get_tree().create_timer(HIT_STOP + 0.22).timeout

	# Let the last embers finish their lives before removing the effect.
	get_tree().create_timer(burst.lifetime + 0.1).timeout.connect(effect.queue_free)


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
func _on_impact(by_player: bool, dealt: int, multiplier: float) -> void:
	if by_player:
		_foe_hp = maxi(0, _foe_hp - dealt)
	else:
		_player_hp = maxi(0, _player_hp - dealt)

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


## Screen shake, scaled by how hard the hit was.
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
		t.tween_property(self, "offset",
			Vector2(randf_range(-power, power), randf_range(-power, power)), 0.035)
	t.tween_property(self, "offset", Vector2.ZERO, 0.09)


## The damage number lifts off the target and fades out.
func _pop_damage(at: Sprite2D, dealt: int, multiplier: float) -> void:
	var label := Label.new()
	label.text = str(dealt)
	label.add_theme_font_size_override("font_size", 34 if multiplier > 1.0 else 24)
	label.add_theme_color_override("font_color",
		Color(1, 0.82, 0.28) if multiplier > 1.0 else Color(0.95, 0.95, 1.0))
	label.position = at.position + Vector2(-12, -70)
	add_child(label)

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
	_tint_bar(_player_bar, float(_player_hp) / player_creature.base_hp)
	_tint_bar(_foe_bar, float(_foe_hp) / _foe.base_hp)

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
	_set_buttons_enabled(false)
	_message.text = final_message
	await get_tree().create_timer(BEAT * 1.5).timeout
	visible = false
	get_tree().paused = false


# ---------------------------------------------------------------- evolution

## Evolves the player's creature if it has somewhere to go. Does nothing, and
## leaves the message untouched, if it does not.
##
## The current test trigger is a battle win; Preston has not approved it as the
## final evolution condition.
## This prototype is isolated from levels. Any final trigger conditions need
## Preston's approval; do not add levels to justify an unapproved trigger.
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


## The whole-number zoom that makes this sprite stand about CREATURE_HEIGHT tall.
## Read from the texture each time, so evolution picks up the new form's size.
func _zoom(s: Sprite2D) -> float:
	if s.texture == null:
		return 3.0
	return maxf(1.0, roundf(float(CREATURE_HEIGHT) / s.texture.get_height()))


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


## Green above half, amber above a quarter, red below. The default progress bar
## fill is grey on grey, which is unreadable at a glance in a fight.
func _tint_bar(bar: ProgressBar, ratio: float) -> void:
	var colour := Color(0.31, 0.78, 0.37)
	if ratio <= 0.25:
		colour = Color(0.85, 0.28, 0.28)
	elif ratio <= 0.5:
		colour = Color(0.92, 0.70, 0.25)
	var fill := StyleBoxFlat.new()
	fill.bg_color = colour
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)


func _set_buttons_enabled(on: bool) -> void:
	_buttons.visible = on
	for i in range(_move_buttons.size()):
		var known: Array[MoveData] = _battle_moves(player_creature)
		var selected: MoveData = known[i] if i < known.size() else null
		_move_buttons[i].disabled = not on or _uses_left(selected, true) == 0
	_catch_button.disabled = not on
	_flee_button.disabled = not on


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.offset_left = -SHAKE_MARGIN
	backdrop.offset_top = -SHAKE_MARGIN
	backdrop.offset_right = SHAKE_MARGIN
	backdrop.offset_bottom = SHAKE_MARGIN
	backdrop.color = Color(0.06, 0.07, 0.12, 1.0)
	add_child(backdrop)

	# Foe sits top right, player bottom left, so they face each other. The
	# sprite art faces right, so the foe is flipped.
	_foe_sprite = Sprite2D.new()
	_foe_sprite.position = Vector2(820, 190)
	_foe_sprite.scale = Vector2.ONE * _zoom(_foe_sprite)
	_foe_sprite.flip_h = true
	add_child(_foe_sprite)

	_player_sprite = Sprite2D.new()
	_player_sprite.position = Vector2(300, 420)
	_player_sprite.scale = Vector2.ONE * _zoom(_player_sprite)
	add_child(_player_sprite)

	var foe_panel := _make_panel(Vector2(70, 90))
	_foe_name = _make_label("", 20)
	_foe_bar = _make_bar()
	_foe_hp_text = _make_label("", 14)
	foe_panel.add_child(_foe_name)
	foe_panel.add_child(_foe_bar)
	foe_panel.add_child(_foe_hp_text)
	add_child(foe_panel)

	# Sits well above the action buttons, which grew from two to three.
	var player_panel := _make_panel(Vector2(660, 320))
	_player_name = _make_label("", 20)
	_player_bar = _make_bar()
	_player_hp_text = _make_label("", 14)
	player_panel.add_child(_player_name)
	player_panel.add_child(_player_bar)
	player_panel.add_child(_player_hp_text)
	add_child(player_panel)

	_message = _make_label("", 22)
	_message.position = Vector2(70, 552)
	_message.size = Vector2(550, 40)
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
	_catch_button.custom_minimum_size = Vector2(204, 40)
	_catch_button.pressed.connect(_on_catch_pressed)
	utility.add_child(_catch_button)

	_flee_button = Button.new()
	_flee_button.text = "Flee"
	_flee_button.custom_minimum_size = Vector2(204, 40)
	_flee_button.pressed.connect(_on_flee_pressed)
	utility.add_child(_flee_button)


func _make_panel(at: Vector2) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.position = at
	box.custom_minimum_size = Vector2(420, 0)
	box.add_theme_constant_override("separation", 6)
	return box


func _make_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	return label


func _make_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(420, 22)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.13, 0.15, 0.21)
	track.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", track)
	return bar
