extends CanvasLayer

## The battle. Turns alternate, one move each, first creature to zero HP faints.
##
## Not built yet: experience, levels, status effects, a second move, items,
## and saving.
## Evolution below has only a win-trigger prototype; Preston has not approved this
## condition.

## The player's creature.
##
## This is the creature used by battle, assigned in the Inspector for this
## prototype. The player brings a
## single fixed creature to every battle. Putting it here
## rather than on the Player node avoids building an ownership chain for a
## active battle party that does not exist yet.
@export var player_creature: CreatureData

## The only move in the game.
##
## When there are real moves this becomes a MoveData resource, one file each,
## the same way creatures work. With exactly one move a pair of constants is
## the honest version and a resource would be scaffolding.
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
	if player_creature == null:
		push_warning("BattleScreen has no player_creature assigned, so it cannot start.")
		return

	_foe = wild
	_player_hp = player_creature.base_hp
	_foe_hp = _foe.base_hp

	# Faster creature acts first for the whole battle. Ties go to the player.
	_player_first = player_creature.base_speed >= _foe.base_speed

	_foe_sprite.texture = _foe.sprite
	_player_sprite.texture = player_creature.sprite
	# Reset anything a previous battle's animation might have left behind.
	for s in [_foe_sprite, _player_sprite]:
		s.scale = Vector2.ONE * _zoom(s)
		s.modulate = Color.WHITE
	offset = Vector2.ZERO
	_foe_name.text = _foe.creature_name + "   " + _foe.essence_name()
	_player_name.text = player_creature.creature_name + "   " + player_creature.essence_name()
	_refresh_bars()

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
	_set_buttons_enabled(true)
	_strike_button.grab_focus()


func _on_strike_pressed() -> void:
	if _phase != Phase.CHOOSING:
		return
	_phase = Phase.RESOLVING
	_set_buttons_enabled(false)

	# Both sides act in speed order within the same round, which is why the
	# player picks an action first and then the whole round resolves.
	if _player_first:
		await _attack(player_creature, true)
		if _phase == Phase.OVER:
			return
		await _attack(_foe, false)
	else:
		await _attack(_foe, false)
		if _phase == Phase.OVER:
			return
		await _attack(player_creature, true)

	if _phase != Phase.OVER:
		_begin_choice()


## One creature hits the other. `by_player` says which side is attacking.
func _attack(attacker: CreatureData, by_player: bool) -> void:
	var defender: CreatureData = _foe if by_player else player_creature
	var multiplier := EssenceChart.multiplier(attacker.essence, defender.essence)
	var dealt := _damage(attacker, defender, multiplier)

	var who := attacker.creature_name if by_player else "Wild " + attacker.creature_name
	_message.text = "%s used %s!" % [who, MOVE_NAME]

	# Damage is applied at the moment of contact inside the animation, not
	# before it, so the number and the picture agree.
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
func _damage(attacker: CreatureData, defender: CreatureData, multiplier: float) -> int:
	var raw := attacker.base_attack * MOVE_POWER / (defender.base_defense * 4.0)
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
	await _attack(_foe, false)
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
## Worth knowing: the party holds CreatureData references, so evolving is
## swapping one reference for another. That is why this did not force the rework
## player_party.gd warns about. The moment a creature needs to remember anything
## of its own, a nickname or current HP, that rework is still owed.
func _try_evolve() -> void:
	var next: CreatureData = player_creature.evolves_into
	if next == null:
		return

	var before: String = player_creature.creature_name
	_message.text = "%s is changing!" % before
	await get_tree().create_timer(BEAT).timeout

	await _evolution_animation(next)

	var slot: int = PlayerParty.caught.find(player_creature)
	if slot != -1:
		PlayerParty.caught[slot] = next
		PlayerParty.party_changed.emit()

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

	s.texture = next.sprite

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
	for child in _buttons.get_children():
		if child is Button:
			child.disabled = not on


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
	_message.size = Vector2(700, 40)
	add_child(_message)

	_buttons = VBoxContainer.new()
	_buttons.position = Vector2(860, 456)
	_buttons.add_theme_constant_override("separation", 8)
	add_child(_buttons)

	_strike_button = Button.new()
	_strike_button.text = MOVE_NAME
	_strike_button.custom_minimum_size = Vector2(200, 40)
	_strike_button.pressed.connect(_on_strike_pressed)
	_buttons.add_child(_strike_button)

	var catch := Button.new()
	catch.text = "Catch"
	catch.custom_minimum_size = Vector2(200, 40)
	catch.pressed.connect(_on_catch_pressed)
	_buttons.add_child(catch)

	var flee := Button.new()
	flee.text = "Flee"
	flee.custom_minimum_size = Vector2(200, 40)
	flee.pressed.connect(_on_flee_pressed)
	_buttons.add_child(flee)


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
