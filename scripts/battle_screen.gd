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
## Music for this battle; it loops, and ducks under attack sounds.
@export var battle_music: AudioStream = preload("res://assets/audio/music/battle_theme.mp3")
## The music's level under the sound effects, in decibels.
@export var music_db: float = -80.0
## Every signature move's music (Preston's "Signature Move", made in Suno). It
## starts from the top when the title card opens, builds for five seconds under
## the card, and keeps playing through the attack and on until the next turn
## begins (Preston, 2026-09-29: the move just changed the game, let it ring).
@export var signature_theme: AudioStream = preload("res://assets/audio/music/signature_move_full.mp3")
## Seconds into signature_theme of its big accent. The card's close-up picture
## slams in on this beat.
@export var signature_accent: float = 3.6

## The chiptune interface and feedback sounds (tools/build_ui_sounds.py). The
## world and the creatures are recorded sound; menus and game feedback are chip
## voices, tuned to the music's scale (Preston, 2026-09-30).
const UI_SOUNDS := {
	&"cursor": preload("res://assets/audio/sfx/ui/cursor.wav"),
	&"confirm": preload("res://assets/audio/sfx/ui/confirm.wav"),
	&"cancel": preload("res://assets/audio/sfx/ui/cancel.wav"),
	&"text": preload("res://assets/audio/sfx/ui/text.wav"),
	&"hit": preload("res://assets/audio/sfx/ui/hit.wav"),
	&"hit_strong": preload("res://assets/audio/sfx/ui/hit_strong.wav"),
	&"hit_weak": preload("res://assets/audio/sfx/ui/hit_weak.wav"),
	&"hp_drain": preload("res://assets/audio/sfx/ui/hp_drain.wav"),
	&"faint": preload("res://assets/audio/sfx/ui/faint.wav"),
	&"catch_reach": preload("res://assets/audio/sfx/ui/catch_reach.wav"),
	&"catch_success": preload("res://assets/audio/sfx/ui/catch_success.wav"),
	&"catch_fail": preload("res://assets/audio/sfx/ui/catch_fail.wav"),
	&"encounter": preload("res://assets/audio/sfx/ui/encounter.wav"),
}
## Loudness of all interface sounds together, in decibels.
@export var ui_sounds_db: float = -6.0

## Strike, the move a creature uses when its `move` field is empty.
##
## Other moves are MoveData files in data/moves/. Strike stays as constants
## because it borrows its user's essence, which a MoveData file cannot express.
const MOVE_NAME := BattleRules.STRIKE_NAME
const MOVE_POWER := BattleRules.STRIKE_POWER

## Capture chance. At the target's full HP it is CATCH_BASE. As its HP falls
## toward zero the chance climbs to CATCH_BASE plus CATCH_BONUS, which is why
## wearing something down before reaching for it is worth doing.
##
## No capture items. A ball with a catch rate is an item system, and items are
## their own step. Attempts are unlimited, and each one costs you the round.
const CATCH_BASE := BattleRules.CATCH_BASE  # the numbers live in battle_rules.gd
const CATCH_BONUS := BattleRules.CATCH_BONUS

## How long each message sits on screen before the next one.
const BEAT := 0.75
## The read-out before a move plays (Preston, 2026-09-29: like the old games,
## the attack is announced before it comes). Seconds per letter while the
## message types out, and the hold after it finishes.
const READ_OUT_LETTER := 0.022
const READ_OUT_HOLD := 0.4
## How long a signature's title card stays up before the animation starts
## (Preston, 2026-09-30: five seconds, so the signature music is heard).
const SIGNATURE_CARD_SECONDS := 5.0

## The freeze on contact. Working devs cite somewhere around 40 to 80
## milliseconds for this; 60 is a starting value to tune by feel, not a
## verified number. It is the cheapest single thing that makes a hit land.
const HIT_STOP := 0.06

## HUD layout on the 1152x648 screen. The foe's card sits top left, the
## player's card bottom right just above the commands, and the message and
## commands share the bottom band, so the top right, where the foe stands,
## stays clear of interface.
const CARD_SIZE := Vector2(476, 102)
const FOE_CARD_AT := Vector2(16, 16)
const PLAYER_CARD_AT := Vector2(660, 360)
const MESSAGE_AT := Vector2(16, 470)
const MESSAGE_SIZE := Vector2(652, 162)
const COMMANDS_AT := Vector2(688, 472)

## Every foe's lowest visible pixel rests on this line, just above the
## player's card; FOE_X is where it stands left to right.
const FOE_FOOT_Y := 350.0
const FOE_X := 820.0

const RIVER_LANDING = preload("res://assets/backgrounds/river_landing_battle.svg")
const CREATURE_NAME_FONT = preload("res://assets/fonts/Silkscreen-Bold.ttf")
const HP_NUMBER_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
## Whole-pixel breathing and the Overheat glow, worn by both creature sprites.
const CREATURE_SHADER = preload("res://scripts/effects/creature_sprite.gdshader")

## Whether the player's side shows each creature's back view (true) or its front
## art turned to face the foe (false). Preston switched back views off on
## 2026-09-28 (they were hard to generate and did not match) and back on on
## 2026-09-29. A creature without a back_sprite still shows its front art.
const USE_BACK_SPRITES := true

## The near-side scale target. Battle size still comes from each creature;
## the opponent also receives distance scaling so it reads farther away.
const CREATURE_HEIGHT := 264

## Where the player's creature stands (its feet), and the open stage it must fit.
const PLAYER_X := 300.0
## Your creature stands closer to the camera than the opponent, like the old
## handheld battles: bigger, and low enough that its legs go behind the message
## box, so you see its back and shoulders rather than the whole body (Preston,
## 2026-09-30: the full back view read as a bloated round shape). Effects still
## land above the box: _foot_point() keeps them there. The same share of
## every creature hides behind the box, so a small one is not cut off more.
const NEAR_HIDDEN := 0.27
const PLAYER_ROOM := Vector2(640, 440)  # includes the part hidden behind the message box

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
## frames; see docs/art/idle-animation-workflow.md for that pipeline.
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
## The two HP cards, faded out by camera shots that ask for a clear view.
var _cards: Array[CanvasItem] = []
var _throat_texture: ImageTexture
## Sprites in a hit squash: Vector2(widen, lift) in whole art pixels.
var _squash := {}
## Sounds an attack's cues started, so the strain's hush can silence them.
var _cue_players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _battle_stage: Node2D
var _foe_sprite: Sprite2D
var _player_sprite: Sprite2D
# Idle overlay layers (a mouth flame and the like), one per creature sprite.
var _foe_overlay: Sprite2D
## True during a reverse shot: the two sides are swapped on screen and in the
## battle's state, so the player's creature attacks from the far spot.
var _reversed := false
var _backdrop: Sprite2D
var _backdrop_edges: Array[Sprite2D] = []
var _player_overlay: Sprite2D
var _overlay_clock := 0.0
var _flick_left := 0.0
## Seconds each overlay frame holds; short enough to read as flickering.
const OVERLAY_STEP := 0.07
var _foe_name: Label
var _player_name: Label
var _foe_bar: ProgressBar
var _player_bar: ProgressBar
var _foe_hp_text: Label
var _player_hp_text: Label
var _message: Label
## True while the game places the menu focus itself, so that does not click.
var _quiet_focus := false
## The signature music after the release, which plays on until the next turn.
var _sig_theme: AudioStreamPlayer
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
	_start_music()

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
	_player_first = BattleRules.player_acts_first(player_creature, _foe)

	_foe_sprite.texture = _foe.idle_frames[0] if not _foe.idle_frames.is_empty() else _foe.sprite
	var player_back: Texture2D = _back_of(player_creature)
	_player_sprite.texture = player_back if player_back != null else (player_creature.idle_frames[0] if not player_creature.idle_frames.is_empty() else player_creature.sprite)
	_setup_overlay(_foe_sprite, _foe_overlay, _foe, true)
	_setup_overlay(_player_sprite, _player_overlay, player_creature, player_back == null)
	# Reset anything a previous battle's animation might have left behind.
	for s in [_foe_sprite, _player_sprite]:
		s.scale = Vector2.ONE * _zoom(s)
		s.modulate = Color.WHITE
		# A fresh material per battle, so no heat or breath carries over.
		var mat := ShaderMaterial.new()
		mat.shader = CREATURE_SHADER
		# Set every value up front: a Tween cannot animate a shader value that
		# has never been set, and in the editor that error pauses the game.
		mat.set_shader_parameter("heat", 0.0)
		mat.set_shader_parameter("breath_lift", 0.0)
		mat.set_shader_parameter("breath_cut", 0.5)
		mat.set_shader_parameter("idle_glow", 0.0)
		mat.set_shader_parameter("heat_sweep", 1.0)
		# Fire or jade: which of this creature's colours light up.
		mat.set_shader_parameter("glow_kind", (_foe if s == _foe_sprite else player_creature).glow_kind)
		s.material = mat
	_foe_home = _foot_home(_foe_sprite, Vector2(FOE_X, FOE_FOOT_Y))
	# The player's creature stands on its own floor line too, so a big body
	# keeps its feet above the message box instead of sinking behind it.
	_player_home = _foot_home(_player_sprite, Vector2(PLAYER_X, _near_foot_y()))
	_battle_stage.position = Vector2.ZERO
	if _focus_tween != null and _focus_tween.is_valid():
		_focus_tween.kill()
	_focus_stage.scale = Vector2.ONE * 1.035
	_focus_stage.position = _focus_target(Vector2.ZERO, 1.035)
	_focus_stage.modulate = Color.WHITE  # a signature's scene light never carries over
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
	_ui(&"encounter")

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
	_end_signature_theme(2.0)  # a new turn: the signature's moment is over
	if _foe_intent != null and _foe_intent.interruptible:
		_message.text = "Wild %s readies %s. Your move?" % [_foe.creature_name, _foe_intent.move_name]
	else:
		_message.text = "What will %s do?" % player_creature.creature_name
	_refresh_move_buttons()
	_set_buttons_enabled(true)
	_quiet_focus = true
	_move_buttons[0].grab_focus()
	_quiet_focus = false


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
		button.focus_entered.connect(_on_button_focus)
		_move_grid.add_child(button)
		_move_buttons.append(button)
	_strike_button = _move_buttons[0] # Compatibility for older scene callers.


func _on_move_pressed(index: int) -> void:
	if _phase != Phase.CHOOSING:
		return
	var chosen: MoveData = _selected_player_move(index)
	if _uses_left(chosen, true) == 0:
		return
	_ui(&"confirm")
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
	await _read_out()
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
	var raw_dealt := BattleRules.damage(attacker, defender, power, multiplier)
	var guard_fraction := _foe_guard_fraction if by_player else _player_guard_fraction
	var dealt := BattleRules.after_guard(raw_dealt, guard_fraction)
	var guarded := raw_dealt - dealt
	_last_interrupt = ""

	var who := attacker.creature_name if by_player else "Wild " + attacker.creature_name
	_message.text = "%s used %s!" % [who, move.move_name if move else MOVE_NAME]
	_tween_focus(Vector2(focus_shift_px if by_player else -focus_shift_px, 0), focus_zoom, 0.16)
	await _announce(attacker, by_player, move)

	# Damage is applied at the moment of contact inside the animation, not
	# before it, so the number and the picture agree.
	# Contact moves opt into drawn frames by naming their hit frame; Cinder
	# Claw's older six-frame sheet stays bypassed because it does not.
	# A player's signature is seen from the front: the camera cuts around so
	# the move plays exactly as it does for a wild creature (Preston,
	# 2026-09-30), and no back-view version of a signature is ever needed.
	if move and move.signature and by_player and not move.attack_frames.is_empty():
		await _reverse_shot(dealt, multiplier, move)
	elif move and move.delivery == MoveData.Delivery.CONTACT and not move.attack_frames.is_empty() and move.attack_hit_frame >= 0:
		await _contact_with_frames(by_player, dealt, multiplier, move)
	elif move and move.delivery == MoveData.Delivery.CONTACT:
		await _strike_animation(by_player, dealt, multiplier, move)
	elif move and not move.attack_frames.is_empty() and (not by_player or _back_of(attacker) == null):
		await _drawn_attack_animation(by_player, dealt, multiplier, move)
	elif move and not move.attack_back_frames.is_empty() and by_player:
		# Seen from behind: same timeline, back-view art.
		await _drawn_attack_animation(by_player, dealt, multiplier, move, true)
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
		_ui(&"faint")
		await get_tree().create_timer(BEAT).timeout
		# Leaves the message alone if nothing evolved, so _finish below just
		# holds whatever the last line said.
		await _try_evolve()
		await _finish(_message.text)
	elif _player_hp == 0:
		_ui(&"faint")
		await _finish("%s fainted." % player_creature.creature_name)


## The chance the next capture attempt succeeds, 0 to 1. Split out from the
## attempt itself so the number can be checked without rolling a dice.
func catch_chance() -> float:
	return BattleRules.catch_chance(_foe_hp, _foe.base_hp)


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
	_ui(&"catch_reach")
	await get_tree().create_timer(BEAT).timeout

	if randf() < catch_chance():
		PlayerParty.add(_foe)
		_ui(&"catch_success")
		await _finish("Caught %s!" % _foe.creature_name)
		return

	_message.text = "It broke free!"
	_ui(&"catch_fail")
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

## Carry the unchanged sprite to the opponent's visible edge, strike there,
## then return to the exact idle home. The alpha bounds account for species
## size, battle zoom, and perspective instead of using a fixed lunge distance.
func _strike_animation(by_player: bool, dealt: int, multiplier: float, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	_idle_hold = true
	var home: Vector2 = _player_home if by_player else _foe_home
	sprite.position = home
	sprite.scale = Vector2.ONE * _zoom(sprite)
	var direction: Vector2 = (target.position - home).normalized()
	var contact: Vector2 = home + direction * _contact_travel(sprite, target, direction)
	var travel_seconds: float = move.contact_travel_seconds if move else 0.14

	var t := create_tween()
	t.tween_property(sprite, "position", home - direction * 18.0, 0.10).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position", contact, travel_seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(_drawn_impact_effect.bind(by_player, move))
	t.tween_callback(_on_impact.bind(by_player, dealt, multiplier, move))
	t.tween_interval(HIT_STOP)
	t.tween_property(sprite, "position", home, 0.22).set_trans(Tween.TRANS_SINE)
	await t.finished
	_idle_hold = false


## A contact move with drawn frames: the intact creature winds up, charges the
## target as a game piece while its frames play, hits on the hit frame, and
## returns home while the rest play out.
##
## Frame roles come from the move: frames before attack_hit_frame are the
## wind-up; the brace frame draws back contact_pullback_px and trembles; the
## frame just before the hit is shown for the whole charge; the hit frame lands
## the damage; frames after it play on the way home. The foe sees the drawn
## frames; from behind (no back frames) the plain sprite does the same moves.
func _contact_with_frames(by_player: bool, dealt: int, multiplier: float, move: MoveData) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var home: Vector2 = _player_home if by_player else _foe_home
	var original_texture: Texture2D = sprite.texture
	var back: bool = by_player and _attacker_uses_back(by_player)
	var frames: Array[Texture2D] = move.attack_back_frames if back else move.attack_frames
	var hit: int = move.attack_hit_frame
	if hit < 0 or hit >= move.attack_frames.size():
		hit = maxi(0, move.attack_frames.size() - 2)
	_idle_hold = true
	sprite.position = home
	sprite.scale = Vector2.ONE * _zoom(sprite)
	var direction: Vector2 = (target.position - home).normalized()
	# Reach carries a protruding weapon onto the target, never past 80% of the
	# way, so the attacker does not pass through it.
	var travel: float = _contact_travel(sprite, target, direction) + move.contact_reach_px * _zoom(sprite)
	travel = minf(travel, home.distance_to(target.position) * 0.8)
	var contact: Vector2 = home + direction * travel
	var pullback: Vector2 = -direction * move.contact_pullback_px * _zoom(sprite)
	# Overheat: a glow on the creature's fire-coloured core that the chugs stoke.
	var heat: ShaderMaterial = null
	var peak: float = move.attack_overheat
	if peak > 0.0 and sprite.material is ShaderMaterial:
		heat = sprite.material
		_heat_to(heat, 0.15 * peak, 0.2)

	for i in range(move.attack_frames.size()):
		if i < frames.size():
			sprite.texture = frames[i]
		var hold: float = move.attack_frame_seconds
		if i < move.attack_frame_holds.size():
			hold = move.attack_frame_holds[i]
		if i < hit - 1:
			if i == move.attack_brace_frame:
				var draw_back := create_tween()
				draw_back.tween_property(sprite, "position", home + pullback, hold * 0.4).set_trans(Tween.TRANS_SINE)
				await draw_back.finished
				if move.contact_brace_chugs > 0:
					await _brace_chug(sprite, home + pullback, direction, maxf(0.04, hold * 0.6), move.contact_brace_chugs,
						heat, peak)
				else:
					await _brace_tremble(sprite, home + pullback, maxf(0.04, hold * 0.6))
			else:
				await get_tree().create_timer(maxf(0.04, hold)).timeout
		elif i == hit - 1:
			# The charge: this frame rides the whole way in. A heavy charger starts
			# slow and builds speed (cubic ease-in); a light one darts (quad).
			if heat != null:
				_heat_to(heat, peak, move.contact_travel_seconds)
			var charge := create_tween()
			var curve: int = Tween.TRANS_CUBIC if move.contact_brace_chugs > 0 else Tween.TRANS_QUAD
			charge.tween_property(sprite, "position", contact, move.contact_travel_seconds) \
				.set_trans(curve).set_ease(Tween.EASE_IN)
			await charge.finished
		elif i == hit:
			sprite.position = contact
			_drawn_impact_effect(by_player, move)
			_on_impact(by_player, dealt, multiplier, move)
			if move.contact_impact_shake > 0:
				_shake(move.contact_impact_shake)
			if heat != null:
				# The hit flares the core, then the long cool-off starts.
				heat.set_shader_parameter("heat", 1.4 * peak)
				var recovery_seconds: float = 0.0
				for k in range(hit + 1, move.attack_frames.size()):
					recovery_seconds += move.attack_frame_holds[k] if k < move.attack_frame_holds.size() \
						else move.attack_frame_seconds
				_heat_to(heat, 0.7 * peak, maxf(HIT_STOP, hold))
				_heat_to(heat, 0.0, recovery_seconds + 0.8, maxf(HIT_STOP, hold))
			await get_tree().create_timer(maxf(HIT_STOP, hold)).timeout
		else:
			# Recovery frames share the trip home.
			var steps: int = move.attack_frames.size() - hit - 1
			var leg := create_tween()
			var t: float = float(i - hit) / float(steps)
			leg.tween_property(sprite, "position", contact.lerp(home, t), maxf(0.04, hold)).set_trans(Tween.TRANS_SINE)
			await leg.finished
	sprite.texture = original_texture
	sprite.position = home
	_idle_hold = false


## True when the attacker on this side is showing its back sprite.
func _attacker_uses_back(by_player: bool) -> bool:
	return by_player and _back_of(player_creature) != null


## The rear view the player's side should show, or null to show the front art
## facing the foe (always null while USE_BACK_SPRITES is off).
func _back_of(creature: CreatureData) -> Texture2D:
	if not USE_BACK_SPRITES or creature == null:
		return null
	return creature.back_sprite


## Project each sprite's visible alpha bounds onto the line of travel. A small
## minimum keeps a lunge readable when silhouettes already overlap in this
## three-quarter battle view; the maximum keeps the attacker beside its target.
func _contact_travel(attacker: Sprite2D, target: Sprite2D, direction: Vector2) -> float:
	var distance: float = attacker.position.distance_to(target.position)
	if distance <= 0.0:
		return 0.0
	var attack_bounds: Vector2 = _visible_projection(attacker, direction)
	var target_bounds: Vector2 = _visible_projection(target, direction)
	var gap: float = distance + target_bounds.x - target_bounds.y - attack_bounds.x - attack_bounds.y
	return clampf(gap - 2.0, 44.0, maxf(44.0, distance * 0.80))


## Returns the visible center offset and half-extent along a direction.
func _visible_projection(sprite: Sprite2D, direction: Vector2) -> Vector2:
	if sprite.texture == null:
		return Vector2.ZERO
	var used: Rect2i = sprite.texture.get_image().get_used_rect()
	var size: Vector2 = Vector2(used.size)
	var center: Vector2 = Vector2(used.position) + size * 0.5
	if sprite.centered:
		center -= sprite.texture.get_size() * 0.5
	if sprite.flip_h:
		center.x = -center.x
	if sprite.flip_v:
		center.y = -center.y
	center += sprite.offset
	var scaled_size: Vector2 = size * sprite.scale.abs()
	var half_extent: float = (absf(direction.x) * scaled_size.x + absf(direction.y) * scaled_size.y) * 0.5
	return Vector2((center * sprite.scale).dot(direction), half_extent)


## Hand-drawn same-form attack poses. The source sheets share one canvas and baseline,
## so only a small lunge is added; the hit lands on the penultimate action pose.
##
## back: play the move's back-view frames instead, on the same timeline. The
## emitter and volley then start from the back-view offset, and can be drawn
## behind the attacker so they rise from behind its body.
func _drawn_attack_animation(by_player: bool, dealt: int, multiplier: float, move: MoveData, back: bool = false) -> void:
	var sprite: Sprite2D = _player_sprite if by_player else _foe_sprite
	var home: Vector2 = sprite.position
	var original_texture: Texture2D = sprite.texture
	var frames: Array[Texture2D] = move.attack_back_frames if back else move.attack_frames
	var offset: Vector2 = move.attack_back_emitter_offset if back else move.attack_emitter_offset
	# Frames without their own emitter point fire from the creature's aim point.
	var attacker: CreatureData = player_creature if by_player else _foe
	if not back and offset == Vector2.ZERO and _has_aim(attacker, move):
		offset = attacker.aim_points[move.aim]
	# Behind the attacker means earlier in BattleStage's draw order, not a lower
	# z_index: a negative z would drop it behind the river backdrop too.
	var behind: Sprite2D = sprite if back and move.attack_back_emitter_behind else null
	var dir: float = 1.0 if by_player else -1.0
	var impact_index: int = move.attack_hit_frame
	if impact_index < 0 or impact_index >= move.attack_frames.size():
		impact_index = maxi(0, move.attack_frames.size() - 2)
	# The default 30 px gives the original -8 / +12 / +30 steps; 0 stays planted.
	var lunge: float = move.attack_lunge_px
	var emitter: Node2D = null
	# Mouth Heat: the fire held in the mouth reacts to the jaws opening (front only).
	var smolder: Node2D = null
	if not back and move.smolder_gasp_frame >= 0 and sprite.has_meta("smolder") \
			and is_instance_valid(sprite.get_meta("smolder")):
		smolder = sprite.get_meta("smolder")
		smolder.attack_owned = true
		smolder.visible = true
		smolder.facing = -1.0 if sprite.flip_h else 1.0
	# Overheat on drawn frames: the core climbs to near peak through the wind-up.
	var heat: ShaderMaterial = sprite.material if move.attack_overheat > 0.0 and sprite.material is ShaderMaterial else null
	var windup: float = _frames_seconds(move, 0, maxi(0, move.attack_emit_frames.x))
	# The heat builds until the seal frame when there is one, otherwise until release.
	var build_end: int = maxi(0, move.attack_emit_frames.x)
	if move.overheat_seal_frame >= 0:
		build_end = move.overheat_seal_frame
	elif move.attack_strain_frame >= 0:
		build_end = move.attack_strain_frame  # the strain throbs the heat itself
	var build: float = _frames_seconds(move, 0, build_end)
	if heat != null:
		_heat_to(heat, 0.9 * move.attack_overheat, build)
		if move.overheat_sweep:
			# Pressure climbing vent by vent, tail end to head.
			heat.set_shader_parameter("heat_sweep", 0.0)
			create_tween().tween_property(heat, "shader_parameter/heat_sweep", 1.0, maxf(0.05, build))
			# Each vent hisses as the sweep's front reaches it (the shader's front
			# sits at heat_sweep * 1.1 across the art, tail end first).
			if move.vent_charge != null:
				var w: float = float(sprite.texture.get_width())
				var vent_number := 0
				for p in move.vent_rest_points:
					var reach: float = clampf((p.x + w * 0.5) / w / 1.1, 0.0, 1.0) * build
					get_tree().create_timer(reach).timeout.connect(
						_vent_sprite.bind(sprite, p, move.vent_charge, 0.35, 0.0))
					# Its hiss, the same moment, a step higher for each vent toward the head.
					if move.vent_charge_sound != null:
						get_tree().create_timer(reach).timeout.connect(
							_play_sound.bind(move.vent_charge_sound, move.vent_sound_db, 0.0, 1.0 + 0.12 * vent_number))
					vent_number += 1
	# Signature music: the build is started partway in so its climax lands on
	# the release frame, whatever this move's wind-up length; the battle music
	# steps aside until the attack is over.
	# (The music is started by _announce, under the title card.)
	# Signature: the whole scene (not the HUD) dims while it winds up.
	if move.signature:
		var dim_to := Color(0.5, 0.46, 0.58)
		var dim := create_tween().set_parallel()
		dim.tween_property(_focus_stage, "modulate", dim_to, windup).set_trans(Tween.TRANS_SINE)
		# Spotlight: the attacker cancels the dim (a touch brighter still), so its
		# overload burns against a darkening world, like the title card.
		var lit := Color(1.08 / dim_to.r, 1.08 / dim_to.g, 1.08 / dim_to.b)
		dim.tween_property(sprite, "modulate", lit, windup).set_trans(Tween.TRANS_SINE)
	_idle_hold = true
	for frame_index in range(move.attack_frames.size()):
		if frame_index < frames.size():
			sprite.texture = frames[frame_index]
			# A frame taller than the idle (Kingstone Rail's raised rails) is drawn
			# with the idle at its bottom; the sprite is centred, so without this
			# the feet would drop by half the extra height.
			sprite.offset.y = (original_texture.get_height() - frames[frame_index].get_height()) * 0.5
		# A signature's close-up is shown on its title card before the attack.
		if frame_index == move.attack_cut_in_frame and move.attack_cut_in != null and not move.signature:
			_show_cut_in(by_player, move)
		for shot in move.camera_shots:
			if shot != null and shot.frame == frame_index:
				_camera_shot(shot, sprite, _foe_sprite if by_player else _player_sprite)
		for i in mini(move.sound_cues.size(), move.sound_cue_frames.size()):
			if move.sound_cue_frames[i] == frame_index:
				_play_sound(move.sound_cues[i], move.sound_cue_db[i] if i < move.sound_cue_db.size() else 0.0)
		if heat != null and frame_index == move.overheat_seal_frame:
			# The seal: the glow pulls inward for a beat, the quiet before it blows.
			_heat_to(heat, 0.35 * move.attack_overheat, 0.15)
		if frame_index == move.attack_emit_frames.x:
			if heat != null:
				heat.set_shader_parameter("heat", 1.4 * move.attack_overheat)
				_heat_to(heat, 0.8 * move.attack_overheat, 0.3)
			if move.vent_column != null:
				# A beat apart, tail end first, so each vent reads as its own blast.
				for i in move.vent_points.size():
					var jet: Texture2D = move.vent_jets[i] if i < move.vent_jets.size() and move.vent_jets[i] != null else move.vent_column
					var way: Vector2 = move.vent_directions[i] if i < move.vent_directions.size() else Vector2.UP
					var under: bool = i < move.vent_behind.size() and move.vent_behind[i]
					var fan_frames: Array[Texture2D] = []
					if absf(way.x) > absf(way.y):
						fan_frames = move.vent_fan_frames
					get_tree().create_timer(0.08 * i + 0.001).timeout.connect(
						_vent_jet.bind(sprite, move.vent_points[i], jet, way, under, 0.55, fan_frames))
					# Its blast, in step with the jet; a little different in pitch each, so
					# four vents read as four blasts and not one sound repeated.
					if move.vent_jet_sound != null:
						get_tree().create_timer(0.08 * i + 0.001).timeout.connect(
							_play_sound.bind(move.vent_jet_sound, move.vent_sound_db, 0.0, [0.94, 1.06, 0.88, 1.0][i % 4]))
			if move.signature:
				# The rupture: a white-hot flash, then the scene lit by the glass.
				sprite.modulate = Color.WHITE  # the spotlight ends with the flash
				_focus_stage.modulate = Color(1.9, 1.6, 1.3)
				var light := create_tween()
				light.tween_property(_focus_stage, "modulate", move.signature_light, 0.35)
		if smolder != null:
			var surge: bool = frame_index >= move.smolder_surge_frames.x and frame_index <= move.smolder_surge_frames.y
			if frame_index == move.smolder_gasp_frame:
				smolder.gasp(offset)
			elif frame_index > move.smolder_gasp_frame:
				smolder.set_aura(offset, 1.0 if surge else 0.5, move.smolder_aura_column if surge else 0.0)
		if frame_index < 2:
			sprite.position = home - Vector2(dir * lunge * 8.0 / 30.0, 0.0)
		elif frame_index < impact_index:
			sprite.position = home + Vector2(dir * lunge * 12.0 / 30.0, 0.0)
		else:
			sprite.position = home + Vector2(dir * lunge, 0.0)
		# Cannon kickback: thrown back on the firing frame, settling after, in
		# whole art pixels so the sprite stays on its grid.
		var fired_for: int = frame_index - move.attack_emit_frames.x
		if move.attack_recoil_px > 0.0 and move.attack_emit_frames.x >= 0 and fired_for >= 0:
			var kick: float = roundf(move.attack_recoil_px * pow(0.5, fired_for)) * _zoom(sprite)
			sprite.position -= Vector2(dir * kick, 0.0)
		if frame_index == move.attack_emit_frames.x:
			emitter = _start_emitter(sprite, move, offset)
			# An emitter that can aim (Furnace Roar's pressure wave) points at the target.
			if emitter != null and emitter.has_method("aim_at"):
				var aim_target: Sprite2D = _foe_sprite if by_player else _player_sprite
				emitter.aim_at(aim_target.global_position)
			if emitter != null and behind != null:
				_battle_stage.move_child(emitter, behind.get_index())
			if move.attack_volley != null:
				_start_volley(sprite, by_player, move, _frames_seconds(move, frame_index, impact_index),
					_frames_seconds(move, frame_index, move.attack_emit_frames.y + 1), offset, behind)
			if move.attack_river != null:
				_start_river(sprite, by_player, move, _frames_seconds(move, frame_index, impact_index),
					_frames_seconds(move, frame_index, move.attack_emit_frames.y + 1),
					move.attack_back_river_offset if back else move.attack_river_offset)
			if move.signature_effect != null:
				_start_signature_effect(sprite, by_player, move, frame_index, impact_index,
					move.attack_back_river_offset if back else move.attack_river_offset)
		var froze := false
		if frame_index == impact_index:
			_drawn_impact_effect(by_player, move)
			_on_impact(by_player, dealt, multiplier, move)
			froze = true
			if move.impact_shake > 0:
				_shake(move.impact_shake)
			if move.impact_flash:
				# The detonation: the scene flashes white-hot, then returns to its light.
				var back_to: Color = _focus_stage.modulate
				_focus_stage.modulate = Color(2.0, 1.7, 1.4)
				create_tween().tween_property(_focus_stage, "modulate", back_to, 0.3)
		var hold: float = move.attack_frame_seconds
		if frame_index < move.attack_frame_holds.size():
			hold = move.attack_frame_holds[frame_index]
		if froze:
			# Hit-stop: the hit frame holds a beat longer while the target
			# freezes white-hot (see _flash) and the shake plays out.
			hold += _freeze_for(move)
		if frame_index == move.attack_brace_frame:
			await _brace_tremble(sprite, sprite.position, maxf(0.04, hold))
		elif frame_index == move.attack_strain_frame:
			# The overload pose is front art; from behind, the back frames carry on.
			var strain_loop: Array[Texture2D] = []
			if not back:
				strain_loop = move.attack_strain_loop
			await _strain(sprite, sprite.position, maxf(0.3, hold), heat, move.attack_overheat,
				null if back else move.attack_strain_overload,
				strain_loop, move.attack_strain_loop_seconds)
		else:
			await get_tree().create_timer(maxf(0.04, hold)).timeout
		if emitter != null and frame_index == move.attack_emit_frames.y:
			_stop_emitter(emitter)
			emitter = null
	if emitter != null:
		_stop_emitter(emitter)
	if smolder != null:
		smolder.resume_flames()
		smolder.attack_owned = false
	if heat != null:
		_heat_to(heat, 0.0, 1.5)
		heat.set_shader_parameter("heat_sweep", 1.0)
	if move.vent_smoke != null:
		for p in move.vent_rest_points:
			_vent_sprite(sprite, p, move.vent_smoke, 1.2, 10.0)
	if move.signature:
		# The light fades with the cooling glass, after the frames are done.
		var settle := create_tween()
		settle.tween_property(_focus_stage, "modulate", Color.WHITE, move.signature_linger) \
			.set_trans(Tween.TRANS_SINE)
	sprite.texture = original_texture
	sprite.offset.y = 0.0
	sprite.position = home
	_idle_hold = false
	if not move.camera_shots.is_empty() and not _reversed:
		_fade_cards(1.0, 0.3)  # in a reverse shot the cards return after the cut back
	# The battle music stays down while the signature music plays on.
	if move.signature and not is_instance_valid(_sig_theme):
		_duck_music(false)


## The reverse shot (Preston, 2026-09-30). The camera cuts around to the
## other side of the field: the player's creature now stands in the far spot,
## seen from the front, and the opponent stands in the near spot, seen from
## behind (or as a dark foreground silhouette when it has no back view), with
## the backdrop mirrored. The signature then plays exactly as it does when a
## wild creature uses it, so every signature is built once, from the front.
## Then the camera cuts back and the HP bar slides down.
##
## Under the hood the two sides are swapped, creatures, HP and turn state
## alike, so the attack code runs unchanged as "the far side attacks the near
## side"; the damage still lands on the real opponent. Swapping again undoes it.
func _reverse_shot(dealt: int, multiplier: float, move: MoveData) -> void:
	# The title card already swapped the sides as it covered the screen; this
	# covers the case where it did not (a move with no card), so the shot works anyway.
	if not _reversed:
		await _camera_cut(func() -> void: _swap_sides())
	await _drawn_attack_animation(false, dealt, multiplier, move)
	await _band_sweep(func() -> void:
		_clear_stage_effects()  # the move's leftovers belong to the other angle
		_swap_sides())
	_fade_cards(1.0, 0.25)
	_animate_bars()


## Remove whatever an attack left on the stage (floods, embers, rings), keeping
## the two creatures. Used when the camera cuts, so nothing lingers in a spot
## that no longer makes sense from the new angle.
func _clear_stage_effects() -> void:
	for child in _battle_stage.get_children():
		if child != _foe_sprite and child != _player_sprite:
			child.queue_free()


## The way back from the reverse shot: a dark band in the card's style sweeps
## across the screen from right to left, the sides swap while it covers
## everything, and the battle is back to its normal angle behind it.
func _band_sweep(swap: Callable) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var band := ColorRect.new()
	band.color = Color(0.06, 0.04, 0.05, 0.96)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.size = Vector2(view.x + 240.0, view.y)
	band.position = Vector2(view.x, 0)
	add_child(band)
	move_child(band, _focus_stage.get_index() + 1)
	# A leading edge of light, so it reads as a sweep and not a blackout.
	var edge := ColorRect.new()
	edge.color = Color(1.0, 0.85, 0.7, 0.9)
	edge.size = Vector2(8, view.y)
	band.add_child(edge)
	var cover := create_tween()
	cover.tween_property(band, "position:x", -120.0, 0.18).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await cover.finished
	swap.call()
	var off := create_tween()
	off.tween_property(band, "position:x", -band.size.x - 20.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	off.tween_callback(band.queue_free)
	await off.finished


## A hard cut: the screen flashes white, `swap` runs under the flash, and the
## new angle fades in.
func _camera_cut(swap: Callable) -> void:
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.size = get_viewport().get_visible_rect().size
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	var t := create_tween()
	t.tween_property(flash, "color:a", 1.0, 0.07)
	await t.finished
	swap.call()
	var out := create_tween()
	out.tween_property(flash, "color:a", 0.0, 0.22)
	out.tween_callback(flash.queue_free)
	await get_tree().create_timer(0.12).timeout


func _swap_sides() -> void:
	var c: CreatureData = _foe
	_foe = player_creature
	player_creature = c
	var hp: int = _foe_hp
	_foe_hp = _player_hp
	_player_hp = hp
	var g: float = _foe_guard_fraction
	_foe_guard_fraction = _player_guard_fraction
	_player_guard_fraction = g
	var intent: MoveData = _foe_intent
	_foe_intent = _player_intent
	_player_intent = intent
	var pending: bool = _foe_action_pending
	_foe_action_pending = _player_action_pending
	_player_action_pending = pending
	var canceled: bool = _foe_action_canceled
	_foe_action_canceled = _player_action_canceled
	_player_action_canceled = canceled
	_reversed = not _reversed
	_dress_sides()


## Put each side's creature in its spot: the far one from the front, the near
## one from behind, sized and stood on its floor line, each glowing its own
## way, and the backdrop facing the right way for the camera.
func _dress_sides() -> void:
	_foe_sprite.texture = _foe.idle_frames[0] if not _foe.idle_frames.is_empty() else _foe.sprite
	var near_back: Texture2D = _back_of(player_creature)
	_player_sprite.texture = near_back if near_back != null else (player_creature.idle_frames[0] if not player_creature.idle_frames.is_empty() else player_creature.sprite)
	# No back view: in the reverse shot the opponent is a dark shape in the
	# foreground, which reads as "seen from behind" without showing a face.
	_player_sprite.self_modulate = Color(0.12, 0.1, 0.15) if _reversed and near_back == null else Color.WHITE
	_setup_overlay(_foe_sprite, _foe_overlay, _foe, true)
	_setup_overlay(_player_sprite, _player_overlay, player_creature, near_back == null)
	for pair in [[_foe_sprite, _foe], [_player_sprite, player_creature]]:
		var sp: Sprite2D = pair[0]
		sp.scale = Vector2.ONE * _zoom(sp)
		if sp.material is ShaderMaterial:
			(sp.material as ShaderMaterial).set_shader_parameter("glow_kind", (pair[1] as CreatureData).glow_kind)
	_foe_home = _foot_home(_foe_sprite, Vector2(FOE_X, FOE_FOOT_Y))
	_player_home = _foot_home(_player_sprite, Vector2(PLAYER_X, _near_foot_y()))
	_foe_sprite.position = _foe_home
	_player_sprite.position = _player_home
	# The camera is on the other side of the field, so the scene is mirrored.
	if _backdrop != null:
		_backdrop.flip_h = _reversed
	for strip in _backdrop_edges:
		var r: Rect2 = strip.region_rect
		if r.size.x == 1.0:  # the side strips: each shows the backdrop's outermost column
			var w: float = float(_backdrop.texture.get_width())
			r.position.x = (w - 1.0) - r.position.x
			strip.region_rect = r


## Before a move plays, the message reads it out: the letters type in, then it
## holds a moment. A signature also gets its title card, and its music starts
## here so it has room to build before the animation begins.
func _announce(attacker: CreatureData, by_player: bool, move: MoveData) -> void:
	if move == null or not move.signature:
		await _read_out()
		return
	_start_signature_music(move)
	_read_out()  # types under the card; the card sets the pace
	# A player's signature is played from the front (the reverse shot): the
	# card itself is the camera cut, swapping the sides while it covers the screen.
	var cover := Callable()
	if by_player and not move.attack_frames.is_empty():
		cover = _swap_sides
	await _signature_card(attacker, by_player, move, cover)


## Type the current message out letter by letter, then hold it.
func _read_out() -> void:
	var letters: int = _message.text.length()
	_message.visible_ratio = 0.0
	var t := create_tween()
	t.tween_property(_message, "visible_ratio", 1.0, clampf(letters * READ_OUT_LETTER, 0.2, 0.7))
	# A tick every other letter or so while it types.
	var ticks := create_tween().set_loops()
	ticks.tween_callback(_ui.bind(&"text")).set_delay(0.05)
	await t.finished
	ticks.kill()
	await get_tree().create_timer(READ_OUT_HOLD).timeout


## The signature music starts from the top as the title card opens; the battle
## music steps aside for it.
func _start_signature_music(_move: MoveData) -> void:
	_duck_music(true)
	_end_signature_theme(0.3)  # a second signature in the same turn takes over
	_start_signature_theme()


## The colour a signature's title card is trimmed in: the attacker's own glow
## (jade) when it has one, otherwise the move's essence.
func _card_accent(attacker: CreatureData, move: MoveData) -> Color:
	if attacker.glow_kind == 1:
		return Color("#84f49c")  # Oxbowarchon's brightest jade
	match move.essence:
		CreatureData.Essence.EMBER:
			return Color("#fc9c4c")
		CreatureData.Essence.TIDE:
			return Color("#6cc4f4")
		CreatureData.Essence.STONE:
			return Color("#d4b47c")
		CreatureData.Essence.GALE:
			return Color("#c4ecf4")
		CreatureData.Essence.BLOOM:
			return Color("#9cdc6c")
	return Color("#b49cdc")


## A signature's title card (Preston, 2026-09-30: keep it, always). Five
## seconds, in two beats timed to the signature music:
##   1. The announcement. A dark band snaps open with a flash in the attacker's
##      colour; the move's name slams in from the attacker's side under its
##      owner's name and a SIGNATURE MOVE tag. Slanted stripes race behind it,
##      faster and faster, and a charge line under the name fills up.
##   2. The close-up, on the music's big accent. The band flashes and opens
##      taller, the name steps aside, and the move's close-up picture (the
##      title card art, `attack_cut_in`) slams in from the attacker's side and
##      drifts while it holds. A move with no close-up yet shows its owner's
##      battle sprite enlarged instead.
## Then it closes and the attack begins.
func _signature_card(attacker: CreatureData, by_player: bool, move: MoveData, cover: Callable = Callable()) -> void:
	var accent: Color = _card_accent(attacker, move)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var band_h := 124.0
	var mid_y: float = roundf(view.y * 0.36)
	var side: float = 1.0 if by_player else -1.0
	var reveal_at: float = clampf(signature_accent, 1.0, SIGNATURE_CARD_SECONDS - 1.0)
	# The close-up: the move's own picture, or its owner's sprite until one exists.
	var art_tex: Texture2D = move.attack_cut_in if move.attack_cut_in != null else attacker.sprite
	var art_zoom: float = 3.0 if art_tex.get_height() * 3.0 <= 390.0 else 2.0
	var tall_h: float = maxf(band_h, art_tex.get_height() * art_zoom + 24.0)

	var band := ColorRect.new()
	band.color = Color(0.06, 0.04, 0.05, 0.9)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.clip_contents = true
	band.position = Vector2(0, mid_y)
	band.size = Vector2(view.x, 0)
	add_child(band)
	move_child(band, _focus_stage.get_index() + 1)
	# Slanted stripes that race across behind the name, like speed lines. Tall
	# enough for the band's second, taller beat.
	var stripes := Node2D.new()
	band.add_child(stripes)
	var slant: float = 40.0 * tall_h / band_h
	for i in int(view.x / 150.0) + 3:
		var stripe := Polygon2D.new()
		var w: float = 24.0 + 12.0 * (i % 2)
		stripe.polygon = PackedVector2Array([Vector2(slant, 0), Vector2(slant + w, 0), Vector2(w, tall_h), Vector2(0, tall_h)])
		stripe.color = Color(accent, 0.22 if i % 2 == 0 else 0.12)
		stripe.position = Vector2(i * 150.0 - 150.0, 0)
		stripes.add_child(stripe)
	# Two thin trim lines in the accent colour, top and bottom of the band.
	var trims: Array[ColorRect] = []
	for y in [6.0, band_h - 10.0]:
		var line := ColorRect.new()
		line.color = accent
		line.position = Vector2(0, y)
		line.size = Vector2(view.x, 4)
		band.add_child(line)
		trims.append(line)
	var tag := Label.new()
	tag.text = "%s   SIGNATURE MOVE" % attacker.creature_name.to_upper()
	tag.add_theme_font_override("font", HP_NUMBER_FONT)
	tag.add_theme_font_size_override("font_size", 18)
	tag.add_theme_color_override("font_color", accent)
	band.add_child(tag)
	var title := Label.new()
	title.text = move.move_name.to_upper()
	title.add_theme_font_override("font", CREATURE_NAME_FONT)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#F0F4F8"))
	title.add_theme_color_override("font_shadow_color", Color(accent, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	band.add_child(title)
	var title_w: float = maxf(title.get_minimum_size().x, tag.get_minimum_size().x)
	var rest_x: float = roundf((view.x - title_w) * 0.5)
	title.position = Vector2(rest_x - side * view.x, 38)
	tag.position = Vector2(rest_x, 14)
	tag.modulate.a = 0.0
	# The charge line under the name: a dim track that fills in the accent
	# colour until the close-up lands.
	var track := ColorRect.new()
	track.color = Color(accent, 0.25)
	track.position = Vector2(rest_x, 98)
	track.size = Vector2(title_w, 4)
	band.add_child(track)
	var charge := ColorRect.new()
	charge.color = accent
	charge.position = track.position
	charge.size = Vector2(0, 4)
	band.add_child(charge)

	# The HP cards step out of the way for the whole card.
	_fade_cards(0.0, 0.12)
	# Beat 1. Open: the band snaps open bright in the accent colour, then settles dark.
	var dark: Color = band.color
	var open := create_tween().set_parallel()
	open.tween_property(band, "size:y", band_h, 0.08)
	open.tween_property(band, "position:y", mid_y - band_h * 0.5, 0.08)
	await open.finished
	band.color = Color(accent.lightened(0.5), 0.95)
	create_tween().tween_property(band, "color", dark, 0.2)
	_shake(12)
	# The name slams in from the attacker's side and overshoots a touch.
	var slam := create_tween()
	slam.tween_property(title, "position:x", rest_x + side * 10.0, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	slam.tween_property(title, "position:x", rest_x, 0.06)
	create_tween().tween_property(tag, "modulate:a", 1.0, 0.15).set_delay(0.12)
	# The stripes race and the charge line fills, stepped 12 times a second like
	# drawn frames. Both speed up toward the close-up.
	var started: int = Time.get_ticks_msec()
	var run := create_tween().set_loops()
	run.tween_interval(1.0 / 12.0)
	run.tween_callback(func() -> void:
		var k: float = clampf((Time.get_ticks_msec() - started) / 1000.0 / reveal_at, 0.0, 1.0)
		stripes.position.x = fposmod(stripes.position.x + side * roundf(lerpf(12.0, 54.0, k * k)), 150.0)
		charge.size.x = roundf(title_w * k / 4.0) * 4.0)
	await get_tree().create_timer(maxf(0.1, reveal_at - 0.08)).timeout

	# Beat 2. The close-up, on the music's accent: flash, the band opens taller,
	# the name steps to the far side and the picture slams in.
	band.color = Color(accent.lightened(0.6), 0.95)
	create_tween().tween_property(band, "color", dark, 0.22)
	_shake(18)
	_play_sound(move.card_sound, move.card_sound_db)  # the creature's cry, with its picture
	var grow := create_tween().set_parallel()
	grow.tween_property(band, "size:y", tall_h, 0.08)
	grow.tween_property(band, "position:y", mid_y - tall_h * 0.5, 0.08)
	trims[1].position.y = tall_h - 10.0
	var text_x: float = clampf(roundf(view.x * 0.5 + side * view.x * 0.25 - title_w * 0.5), 16.0, view.x - title_w - 16.0)
	var text_y: float = roundf(tall_h * 0.5 - 30.0)
	title.position = Vector2(text_x, text_y)
	tag.position = Vector2(text_x, text_y - 24.0)
	track.position = Vector2(text_x, text_y + 60.0)
	charge.position = track.position
	title.modulate = Color(1.6, 1.6, 1.6)
	create_tween().tween_property(title, "modulate", Color.WHITE, 0.25)
	var art := Sprite2D.new()
	art.texture = art_tex
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.scale = Vector2.ONE * art_zoom
	art.flip_h = not by_player  # drawn facing right; the foe faces left
	band.add_child(art)
	var art_w: float = art_tex.get_width() * art_zoom
	var from_x: float = view.x * 0.5 - side * (view.x * 0.5 + art_w * 0.5)
	var art_x: float = view.x * 0.5 - side * view.x * 0.24
	var place := func(x: float) -> void:
		art.position = Vector2(roundf(x / art_zoom) * art_zoom, roundf(tall_h * 0.5))
	place.call(from_x)
	art.modulate = Color(2.2, 2.0, 1.7)
	create_tween().tween_property(art, "modulate", Color.WHITE, 0.25)
	var hold: float = maxf(0.2, SIGNATURE_CARD_SECONDS - reveal_at - 0.12 - 0.08)
	var slide := create_tween()
	slide.tween_method(place, from_x, art_x, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	slide.tween_method(place, art_x, art_x + side * 18.0, hold)  # a slow drift while it holds
	await slide.finished
	run.kill()
	if cover.is_valid():
		# The card is the camera cut (Preston, 2026-09-30): the band grows to
		# cover the whole screen as the picture and name fade, the sides swap
		# behind it, then it opens from the middle onto the other side of the field.
		var to_full := create_tween().set_parallel()
		to_full.tween_property(band, "size:y", view.y, 0.16).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		to_full.tween_property(band, "position:y", 0.0, 0.16).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		for child in band.get_children():
			if child != stripes:
				to_full.tween_property(child, "modulate:a", 0.0, 0.12)
		await to_full.finished
		cover.call()
		await get_tree().create_timer(0.08).timeout
		var reveal := create_tween().set_parallel()
		reveal.tween_property(band, "size:y", 0.0, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		reveal.tween_property(band, "position:y", roundf(view.y * 0.5), 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await reveal.finished
		band.queue_free()
		return
	var close := create_tween().set_parallel()
	close.tween_property(band, "size:y", 0.0, 0.08)
	close.tween_property(band, "position:y", mid_y, 0.08)
	await close.finished
	band.queue_free()
	# A move with camera shots brings the cards back itself when it ends.
	if move.camera_shots.is_empty():
		_fade_cards(1.0, 0.2)


## A move's close-up cut-in: a dark band opens across the screen, the close-up
## slides in from the attacker's side, holds, and slides out the other way,
## then the band closes. It sits above the stage and under the HUD, and moves in
## whole screen pixels at 3x so the art stays crisp. Not awaited by the caller.
func _show_cut_in(by_player: bool, move: MoveData) -> void:
	const ZOOM := 3.0
	var tex: Texture2D = move.attack_cut_in
	var art_size: Vector2 = tex.get_size() * ZOOM
	var view: Vector2 = get_viewport().get_visible_rect().size
	var band_h: float = art_size.y + 24.0
	var mid_y: float = roundf(view.y * 0.36)
	var band := ColorRect.new()
	band.color = Color(0.06, 0.04, 0.05, 0.85)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.clip_contents = true
	band.position = Vector2(0, mid_y)
	band.size = Vector2(view.x, 0)
	add_child(band)
	move_child(band, _focus_stage.get_index() + 1)
	var art := Sprite2D.new()
	art.texture = tex
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.scale = Vector2.ONE * ZOOM
	art.flip_h = not by_player  # the foe faces left
	band.add_child(art)
	var side: float = 1.0 if by_player else -1.0
	var from_x: float = view.x * 0.5 - side * (view.x * 0.5 + art_size.x * 0.5)
	var rest_x: float = view.x * 0.5 - side * 40.0
	var out_x: float = view.x * 0.5 + side * (view.x * 0.5 + art_size.x * 0.5)
	var place := func(x: float) -> void:
		art.position = Vector2(roundf(x / ZOOM) * ZOOM, roundf(band_h * 0.5))
	place.call(from_x)
	var open := create_tween().set_parallel()
	open.tween_property(band, "size:y", band_h, 0.08)
	open.tween_property(band, "position:y", mid_y - band_h * 0.5, 0.08)
	await open.finished
	# The flash: the band opens white-hot and the close-up burns bright, then
	# both settle, so the moment lands like a special move's title card.
	var dark: Color = band.color
	band.color = Color(1.0, 0.9, 0.72, 0.95)
	art.modulate = Color(2.2, 2.0, 1.7)
	var flash := create_tween().set_parallel()
	flash.tween_property(band, "color", dark, 0.18)
	flash.tween_property(art, "modulate", Color.WHITE, 0.22)
	var slide := create_tween()
	slide.tween_method(place, from_x, rest_x, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	slide.tween_method(place, rest_x, rest_x - side * 18.0, move.attack_cut_in_seconds)  # a slow drift while it holds
	slide.tween_method(place, rest_x - side * 18.0, out_x, 0.12).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await slide.finished
	var close := create_tween().set_parallel()
	close.tween_property(band, "size:y", 0.0, 0.08)
	close.tween_property(band, "position:y", mid_y, 0.08)
	await close.finished
	band.queue_free()


## Start a signature's scene-wide effect (the meltdown flood) under the river,
## timed so it bursts out as the river reaches the target.
func _start_signature_effect(sprite: Sprite2D, by_player: bool, move: MoveData, frame_index: int,
		impact_index: int, offset: Vector2) -> void:
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var effect: Node2D = move.signature_effect.instantiate()
	_battle_stage.add_child(effect)
	_battle_stage.move_child(effect, 0)  # under the river and the creatures
	var start: Vector2 = _emitter_point(sprite, offset)
	var arrive: float = _frames_seconds(move, frame_index, impact_index)
	var run: float = _frames_seconds(move, frame_index, move.attack_emit_frames.y + 1)
	# Effects that stage the whole field (Furnace Roar) also get the opponent's
	# sprite to shake, where the attacker stands, and the screen shake.
	if "target" in effect:
		effect.target = target
	if "source_feet" in effect:
		effect.source_feet = _foot_point(sprite, target.position)
	if "shake" in effect:
		effect.shake = _shake
	effect.erupt(start, _foot_point(target, start), _zoom(sprite), arrive, maxf(0.0, run - arrive))


## Plant and strain before letting go: the body sinks one art pixel and shakes
## side to side by one art pixel, so it reads as bracing without leaving its spot.
func _brace_tremble(sprite: Sprite2D, base: Vector2, seconds: float) -> void:
	var px: float = _zoom(sprite)
	var elapsed := 0.0
	var side := 1.0
	while elapsed < seconds:
		sprite.position = base + Vector2(px * side, px)
		side = -side
		await get_tree().create_timer(0.04).timeout
		elapsed += 0.04
	sprite.position = base


## One vent effect standing on a point of the attacker's body (a charge puff, a
## column, a curl of smoke): its bottom edge on the vent, the creature's zoom so
## its pixels match, mirrored with a foe. It flickers out at the end, or with
## rise, drifts up that many art pixels while it fades. Not awaited.
## One vent blowing out on release (Preston, 2026-09-29: the blasts must read
## as coming out of the vents). The vent slit flashes white-hot, then the blast
## grows out of it in whole-pixel steps, its source edge on the slit, holds,
## flickers and is gone. `way` is up (source at the art's bottom edge) or back
## toward the tail (source at its right edge); `under` draws it behind the body
## so it rises out from behind the ridge.
func _vent_jet(sprite: Sprite2D, point: Vector2, tex: Texture2D, way: Vector2, under: bool, seconds: float, fan_frames: Array[Texture2D]) -> void:
	if not is_instance_valid(sprite) or tex == null:
		return
	var zoom: float = _zoom(sprite)
	var facing: float = -1.0 if sprite.flip_h else 1.0
	var vent: Vector2 = _emitter_point(sprite, point)
	_vent_throat(vent, zoom)
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * zoom
	s.flip_h = sprite.flip_h
	_battle_stage.add_child(s)
	if under:
		_battle_stage.move_child(s, sprite.get_index())
	if not fan_frames.is_empty():
		# The cut frames share a 56x48 canvas. Their fixed vent root is two
		# pixels in from the right edge and two-thirds down the canvas.
		for frame_index in fan_frames.size():
			if not is_instance_valid(s):
				return
			var frame: Texture2D = fan_frames[frame_index]
			if frame != null:
				s.texture = frame
				var size := Vector2(frame.get_width(), frame.get_height())
				var origin := Vector2(size.x - 2.0, size.y * 2.0 / 3.0)
				s.position = vent + Vector2((size.x * 0.5 - origin.x) * zoom * facing,
					(size.y * 0.5 - origin.y) * zoom)
			await get_tree().create_timer(seconds / fan_frames.size()).timeout
		if is_instance_valid(s):
			s.queue_free()
		return
	s.region_enabled = true
	var w: int = tex.get_width()
	var h: int = tex.get_height()
	var up: bool = absf(way.y) >= absf(way.x)
	for share in [0.35, 0.7, 1.0]:
		if not is_instance_valid(s):
			return
		if up:
			var rh: int = maxi(1, int(round(h * share)))
			s.region_rect = Rect2(0, h - rh, w, rh)
			s.position = vent + Vector2(0, -rh * 0.5 * zoom)
		else:
			var rw: int = maxi(1, int(round(w * share)))
			s.region_rect = Rect2(w - rw, 0, rw, h)
			# The source edge sits on the vent; the blast spreads toward the tail.
			s.position = vent + Vector2(-rw * 0.5 * zoom * facing, 0)
		await get_tree().create_timer(0.03).timeout
	var t := create_tween()
	t.tween_interval(seconds * 0.7)
	for i in 3:
		t.tween_property(s, "visible", false, 0.0)
		t.tween_interval(seconds * 0.05)
		t.tween_property(s, "visible", true, 0.0)
		t.tween_interval(seconds * 0.05)
	t.finished.connect(s.queue_free)


## The vent slit blowing white-hot as it fires: a small pale star in whole art
## pixels on the slit, gone in a few frames.
func _vent_throat(at: Vector2, zoom: float) -> void:
	if _throat_texture == null:
		var img := Image.create(5, 5, false, Image.FORMAT_RGBA8)
		var pale := Color("fcdca4")
		var hot := Color("fc9c4c")
		for q in [Vector2i(2, 0), Vector2i(0, 2), Vector2i(4, 2), Vector2i(2, 4)]:
			img.set_pixelv(q, hot)
		for q in [Vector2i(2, 1), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3)]:
			img.set_pixelv(q, pale)
		_throat_texture = ImageTexture.create_from_image(img)
	var f := Sprite2D.new()
	f.texture = _throat_texture
	f.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	f.scale = Vector2.ONE * zoom
	f.position = (at / zoom).round() * zoom
	_battle_stage.add_child(f)
	get_tree().create_timer(0.12).timeout.connect(f.queue_free)


func _vent_sprite(sprite: Sprite2D, offset: Vector2, tex: Texture2D, seconds: float, rise: float) -> void:
	if not is_instance_valid(sprite):
		return
	var zoom: float = _zoom(sprite)
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * zoom
	s.flip_h = sprite.flip_h
	s.offset = Vector2(0, -tex.get_height() * 0.5)  # stand on the vent
	s.position = _emitter_point(sprite, offset)
	_battle_stage.add_child(s)
	var t := create_tween()
	if rise > 0.0:
		t.set_parallel()
		t.tween_property(s, "position:y", s.position.y - rise * zoom, seconds)
		t.tween_property(s, "modulate:a", 0.0, seconds).set_ease(Tween.EASE_IN)
	else:
		t.tween_interval(seconds * 0.7)
		for i in 3:
			t.tween_property(s, "visible", false, 0.0)
			t.tween_interval(seconds * 0.05)
			t.tween_property(s, "visible", true, 0.0)
			t.tween_interval(seconds * 0.05)
	t.finished.connect(s.queue_free)


## "It's about to blow": the body shakes harder and harder (one to three art
## pixels), the heat throbs brighter and faster with a rumble that grows each
## throb, then everything goes still for a held breath right before release.
func _strain(sprite: Sprite2D, base: Vector2, seconds: float, heat: ShaderMaterial, peak: float,
		overload: Texture2D = null, loop: Array[Texture2D] = [], loop_seconds: float = 0.12) -> void:
	var px: float = _zoom(sprite)
	var hush: float = minf(0.22, seconds * 0.25)
	var build: float = seconds - hush
	var elapsed := 0.0
	var side := 1.0
	var next_throb := 0.0
	var calm: Texture2D = sprite.texture
	var surge_until := -1.0  # while elapsed is below this, the overload pose shows
	# Elapsed is read off the clock: each 0.04 s wait really lasts until the next
	# frame, so adding 0.04 per step ran the strain about a third long and the
	# signature music ended before the release (found 2026-09-29).
	var started: int = Time.get_ticks_msec()
	while elapsed < build:
		var k: float = elapsed / build
		var amp: float = roundf(lerpf(1.0, 3.0, k))
		sprite.position = base + Vector2(px * amp * side, px if side > 0.0 else 0.0)
		side = -side
		if elapsed >= next_throb:
			if heat != null:
				heat.set_shader_parameter("heat", lerpf(0.95, 1.35, k) * peak)
				_heat_to(heat, 0.8 * peak, 0.07)
			_shake(int(lerpf(6.0, 18.0, k)))
			var interval: float = lerpf(0.28, 0.08, k)
			next_throb = elapsed + interval
			# The core surges past its limit: the overload pose flashes in, for
			# longer each throb, and from about 70% of the way it stays.
			surge_until = elapsed + (build if k > 0.7 else interval * lerpf(0.25, 0.8, k))
		if overload != null:
			sprite.texture = overload if elapsed < surge_until else calm
		elif not loop.is_empty():
			# Keep a long charge alive: step through the loop drawings.
			sprite.texture = loop[int(elapsed / maxf(0.04, loop_seconds)) % loop.size()]
		await get_tree().create_timer(0.04).timeout
		elapsed = (Time.get_ticks_msec() - started) / 1000.0
	# The held breath, at peak meltdown. Sound goes silent with it, so the
	# release lands out of silence (Gemini audio research, 2026-09-29: the
	# vacuum before a hit is what makes it read as huge). Timed off the hush
	# itself, so it holds however the frame timing drifts.
	_hush_cues()
	if overload != null:
		sprite.texture = overload
	sprite.position = base
	if heat != null:
		_heat_to(heat, 0.55 * peak, 0.08)
	await get_tree().create_timer(hush).timeout


## Getting up steam: the attacker rocks back and stomps forward `count` times,
## each chug deeper and quicker than the last, with a small ground shake on
## every stomp. Moves are whole art pixels so the sprite stays on its grid.
##
## heat: an Overheat glow to stoke. Each stomp flares it and it settles back a
## little higher than before, climbing toward 0.8 of peak, like a firebox.
func _brace_chug(sprite: Sprite2D, base: Vector2, direction: Vector2, seconds: float, count: int,
		heat: ShaderMaterial = null, peak: float = 0.0) -> void:
	var px: float = _zoom(sprite)
	# Intervals shrink from long to short and add up to `seconds`.
	var weights: Array[float] = []
	var total := 0.0
	for k in count:
		var w: float = lerpf(1.6, 0.6, float(k) / maxf(1.0, count - 1))
		weights.append(w)
		total += w
	for k in count:
		var beat: float = seconds * weights[k] / total
		var depth: float = roundf(lerpf(1.0, 3.0, float(k) / maxf(1.0, count - 1))) * px
		var chug := create_tween()
		chug.tween_property(sprite, "position", base - direction * depth + Vector2(0, px), beat * 0.55) \
			.set_trans(Tween.TRANS_SINE)
		chug.tween_property(sprite, "position", base, beat * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await chug.finished
		_shake(8 + k * 2)
		if heat != null:
			var level: float = lerpf(0.35, 0.9, float(k) / maxf(1.0, count - 1)) * peak
			heat.set_shader_parameter("heat", level + 0.5 * peak)
			_heat_to(heat, level, beat * 0.5)
	sprite.position = base


## Ease an Overheat glow to `to` over `seconds`, after `delay`.
func _heat_to(heat: ShaderMaterial, to: float, seconds: float, delay: float = 0.0) -> void:
	if heat.get_shader_parameter("heat") == null:
		heat.set_shader_parameter("heat", 0.0)
	var t := create_tween()
	t.tween_property(heat, "shader_parameter/heat", to, maxf(0.01, seconds)).set_delay(delay) \
		.set_trans(Tween.TRANS_SINE)


## Attach a move's particle scene to the attacker, measured in the attack art's
## own pixels, so the glass or fire leaves the anatomy the frames show. Scaling
## by the sprite's zoom keeps one particle pixel the same size as one art pixel;
## the negative x scale mirrors it for a foe, whose sprite is flipped.
func _start_emitter(sprite: Sprite2D, move: MoveData, offset: Vector2) -> Node2D:
	if move.attack_emitter == null:
		return null
	var mirror: float = -1.0 if sprite.flip_h else 1.0
	var zoom: float = _zoom(sprite)
	var emitter: Node2D = move.attack_emitter.instantiate()
	emitter.scale = Vector2(mirror * zoom, zoom)
	emitter.position = _emitter_point(sprite, offset)
	_battle_stage.add_child(emitter)
	for child in emitter.get_children():
		if child is CPUParticles2D:
			child.emitting = true
	if move.attack_emit_shake > 0:
		_shake(move.attack_emit_shake)
	# An optional drawn Burst pops out as the emitter opens, then flickers away.
	var burst: Sprite2D = emitter.get_node_or_null("Burst")
	if burst:
		burst.visible = true
		var flicker := create_tween()
		flicker.tween_interval(0.16)
		for i in 2:
			flicker.tween_property(burst, "visible", false, 0.0)
			flicker.tween_interval(0.04)
			flicker.tween_property(burst, "visible", true, 0.0)
			flicker.tween_interval(0.04)
		flicker.tween_property(burst, "visible", false, 0.0)
	# An optional Throw: drawn frames shown one after another from the emitter
	# point (a rope of glass stretching out), each for its "hold" seconds.
	var throw: Node2D = emitter.get_node_or_null("Throw")
	if throw:
		var steps := create_tween()
		for step in throw.get_children():
			if step is CanvasItem:
				steps.tween_property(step, "visible", true, 0.0)
				steps.tween_interval(float(step.get_meta("hold", 0.08)))
				steps.tween_property(step, "visible", false, 0.0)
	return emitter


## Where an offset measured in the attack art's pixels (art facing right) lands
## on screen for this sprite: scaled by its zoom and mirrored if it is flipped.
## Works for any sprite in any spot, which is what a 2v2 layout will need.
## True when the move names an aim point this creature has.
func _has_aim(creature: CreatureData, move: MoveData) -> bool:
	return creature != null and move != null and move.aim != "" and creature.aim_points.has(move.aim)


func _emitter_point(sprite: Sprite2D, offset: Vector2) -> Vector2:
	var mirror: float = -1.0 if sprite.flip_h else 1.0
	return sprite.position + Vector2(offset.x * mirror, offset.y) * _zoom(sprite)


## Seconds the drawn frames from first up to (not including) last stay on screen.
func _frames_seconds(move: MoveData, first: int, last: int) -> float:
	var total := 0.0
	for i in range(first, mini(last, move.attack_frames.size())):
		var hold: float = move.attack_frame_seconds
		if i < move.attack_frame_holds.size():
			hold = move.attack_frame_holds[i]
		total += maxf(0.04, hold)
	return total


## Lob the move's volley scene from the emitter point onto the defender on a
## steady beat while the emitter runs. Every lob flies for the same time as the
## first, which is timed to land on the hit frame, so glass and damage arrive
## together and the rest keep raining on the target. Not awaited by the caller.
func _start_volley(sprite: Sprite2D, by_player: bool, move: MoveData, flight: float, run_seconds: float, offset: Vector2, behind: Sprite2D = null) -> void:
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var mouth: Vector2 = _emitter_point(sprite, offset)
	flight = maxf(0.15, flight)
	var elapsed := 0.0
	var first := true
	while elapsed < run_seconds - flight * 0.5:
		# The first lob lands dead centre on the hit; the rest scatter a little
		# so their splashes do not pile onto one spot.
		var landing: Vector2 = target.position
		if not first:
			landing += Vector2(randf_range(-28.0, 28.0), randf_range(-18.0, 18.0))
		elapsed += move.attack_volley_interval
		var last: bool = elapsed >= run_seconds - flight * 0.5
		# The first lob's landing is the hit itself; later ones make the target flinch.
		_lob(move.attack_volley, mouth, landing, flight, last, null if first else target, behind)
		first = false
		await get_tree().create_timer(move.attack_volley_interval).timeout


## A ground flow from the attacker's pool to the defender's feet. It is laid
## on the ground under both creatures, reaches the target on the hit frame, and
## while it keeps coming the target flinches. Not awaited by the caller.
func _start_river(sprite: Sprite2D, by_player: bool, move: MoveData, arrive: float, run_seconds: float, offset: Vector2) -> void:
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var river: Node2D = move.attack_river.instantiate()
	_battle_stage.add_child(river)
	_battle_stage.move_child(river, 0)
	var start: Vector2 = _emitter_point(sprite, offset)
	var sustain: float = maxf(0.2, run_seconds - arrive)
	river.flow(start, _foot_point(target, start), _zoom(sprite), maxf(0.15, arrive), sustain)
	await get_tree().create_timer(maxf(0.15, arrive) + 0.35).timeout
	var elapsed := 0.35
	while elapsed < sustain:
		_flinch(target)
		await get_tree().create_timer(0.35).timeout
		elapsed += 0.35


## Where a flow should end at a creature: the bottom of its visible art, a
## little in from the side facing the attacker, kept above the message box.
func _foot_point(target: Sprite2D, from: Vector2) -> Vector2:
	var point: Vector2 = target.position
	if target.texture != null:
		var used: Rect2i = target.texture.get_image().get_used_rect()
		point.y += (used.position.y + used.size.y - target.texture.get_height() * 0.5) * target.scale.y - 4.0 * _zoom(target)
		var half_width: float = used.size.x * target.scale.x * 0.5
		point.x += signf(from.x - point.x) * half_width * 0.35
	point.y = minf(point.y, MESSAGE_AT.y - 8.0)
	return point


## One lob: an arc from one point to another, dripping its Trail on the way,
## then its Splash bursts on landing. Optional pieces in the scene: a Head with
## a "variants" list of textures (one is picked each throw, mirrored to face
## the way it flies), an Impact sprite shown briefly on landing, and a Crust
## sprite the final lob leaves behind to fade.
func _lob(scene: PackedScene, from: Vector2, to: Vector2, seconds: float, last: bool = false, flinch: Sprite2D = null, behind: Sprite2D = null) -> void:
	var lob: Node2D = scene.instantiate()
	lob.position = from
	_battle_stage.add_child(lob)
	if behind != null:
		_battle_stage.move_child(lob, behind.get_index())
	var trail: CPUParticles2D = lob.get_node_or_null("Trail")
	if trail:
		trail.emitting = true
	var head: Sprite2D = lob.get_node_or_null("Head")
	if head:
		if head.has_meta("variants"):
			var variants: Array = head.get_meta("variants")
			if not variants.is_empty():
				head.texture = variants.pick_random()
		# The drawn globs fly to the right with their tail behind; mirror, never
		# rotate, so the pixels stay on the grid.
		head.flip_h = to.x < from.x
	var height: float = maxf(60.0, from.distance_to(to) * 0.3)
	var fly := create_tween()
	fly.tween_method(func(k: float) -> void:
		lob.position = from.lerp(to, k) + Vector2(0.0, -height * 4.0 * k * (1.0 - k)),
		0.0, 1.0, seconds)
	await fly.finished
	if head:
		head.visible = false
	if trail:
		trail.emitting = false
	var splash: CPUParticles2D = lob.get_node_or_null("Splash")
	if splash:
		splash.restart()
	if flinch:
		_flinch(flinch)
	var impact: Sprite2D = lob.get_node_or_null("Impact")
	if impact:
		impact.flip_h = to.x < from.x
		impact.visible = true
		get_tree().create_timer(0.18).timeout.connect(impact.hide)
	var crust: Sprite2D = lob.get_node_or_null("Crust")
	var linger := 0.9
	if crust and last:
		crust.visible = true
		var cool := create_tween()
		cool.tween_interval(0.5)
		cool.tween_property(crust, "modulate:a", 0.0, 0.7)
		linger = 1.3
	get_tree().create_timer(linger).timeout.connect(lob.queue_free)


## A lighter version of the hit flash for follow-up blows that deal no extra
## damage: the target brightens and settles, so every landing still registers.
func _flinch(sprite: Sprite2D) -> void:
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1.45, 1.3, 1.2), 0.02)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.14)


## Stop pouring but let the particles already in the air finish falling.
func _stop_emitter(emitter: Node2D) -> void:
	var longest := 0.0
	for child in emitter.get_children():
		if child is CPUParticles2D:
			child.emitting = false
			longest = maxf(longest, child.lifetime)
	get_tree().create_timer(longest + 0.1).timeout.connect(emitter.queue_free)


## Show the claw art on the target at the exact hit frame. The creature
## animation stays on Ironvent; the slash and molten debris belong to the hit.
func _drawn_impact_effect(by_player: bool, move: MoveData) -> void:
	if move == null or move.effect == null:
		return
	var target: Sprite2D = _foe_sprite if by_player else _player_sprite
	var effect: Node2D = move.effect.instantiate()
	effect.position = target.position
	_battle_stage.add_child(effect)
	var ball: Sprite2D = effect.get_node_or_null("Ball")
	if ball:
		ball.visible = false
	var trail: CPUParticles2D = effect.get_node_or_null("Trail")
	if trail:
		trail.emitting = false
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
	# An optional drawn Sequence (AnimatedSprite2D) plays through once on the
	# target, such as Furnace Roar's slam, ring and fading heat. Its art travels
	# right as drawn; it is mirrored, offset included, when the foe attacks.
	var linger := 0.65
	var seq: AnimatedSprite2D = effect.get_node_or_null("Sequence")
	if seq:
		if not by_player:
			seq.flip_h = true
			seq.position.x = -seq.position.x
		seq.play()
		var frames: SpriteFrames = seq.sprite_frames
		var total := 0.0
		for i in frames.get_frame_count(seq.animation):
			total += frames.get_frame_duration(seq.animation, i) / frames.get_animation_speed(seq.animation)
		linger = maxf(linger, total + 0.05)
	get_tree().create_timer(linger).timeout.connect(effect.queue_free)


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

	# Added last so it draws over both creatures. Launched from the move's aim
	# point on the attacker (its mouth, vent...) when it has one; otherwise from
	# the front edge rather than the centre, so it leaves the mouth, not the belly.
	var attacker: CreatureData = player_creature if by_player else _foe
	if _has_aim(attacker, move):
		effect.position = _emitter_point(sprite, attacker.aim_points[move.aim])
	else:
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
	_flash(target, _freeze_for(move))
	_shake(dealt)
	_pop_damage(target, dealt, multiplier)
	if not _reversed:
		_animate_bars()  # in a reverse shot the bars slide once the camera cuts back
	# The chip tick over the recorded impact says how well it landed, and the HP
	# run follows it down.
	_ui(&"hit_strong" if multiplier > 1.0 else (&"hit_weak" if multiplier < 1.0 else &"hit"))
	get_tree().create_timer(0.12).timeout.connect(_ui.bind(&"hp_drain"))


## Seconds of hit-stop for a move: its own impact_freeze, or 0.12 for a
## signature and the usual HIT_STOP otherwise.
func _freeze_for(move: MoveData) -> float:
	if move == null:
		return HIT_STOP
	if move.impact_freeze >= 0.0:
		return move.impact_freeze
	return 0.12 if move.signature else HIT_STOP


## The struck creature blows out bright and squashes, holds there for the
## hit-stop, then springs back.
func _flash(sprite: Sprite2D, freeze: float = 0.0) -> void:
	var bright := create_tween()
	bright.tween_property(sprite, "modulate", Color(6, 6, 6), 0.03)
	bright.tween_interval(freeze)
	bright.tween_property(sprite, "modulate", Color.WHITE, 0.18)

	_squash_hit(sprite, freeze)


## The hit squash in whole art pixels (Preston, 2026-09-29): the body drops
## shorter and wider through the hit-stop, rebounds a little taller and
## narrower, then settles. Scaling by 1.15 x 0.88 broke the pixel grid.
func _squash_hit(sprite: Sprite2D, freeze: float) -> void:
	if sprite.texture == null:
		return
	var used: Rect2i = _used_rect(sprite.texture)
	var room: int = mini(used.position.x, sprite.texture.get_width() - used.end.x)
	var down: float = maxf(1.0, roundf(used.size.y * 0.1))
	var out: float = clampf(roundf(used.size.x * 0.07), 1.0, maxf(1.0, float(room)))
	_squash[sprite] = Vector2(out, -down)
	_set_breath(sprite, 0.0, 0.5)
	await get_tree().create_timer(0.05 + freeze).timeout
	_squash[sprite] = Vector2(-roundf(out * 0.5), roundf(down * 0.5))
	_set_breath(sprite, 0.0, 0.5)
	await get_tree().create_timer(0.08).timeout
	_squash.erase(sprite)
	_set_breath(sprite, 0.0, 0.5)


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
	# Jumps rather than slides, in whole backdrop pixels (4 screen px), dying
	# down over six kicks: sliding between offsets drew the scene between
	# pixels (Gemini VFX research, 2026-09-29: snap shake to the pixel grid).
	var t := create_tween()
	for i in 6:
		var k: float = 1.0 - i / 6.0
		var kick := Vector2(randf_range(-power, power), randf_range(-power, power)) * k
		kick = (kick / 4.0).round() * 4.0
		t.tween_callback(func() -> void: _battle_stage.position = kick)
		t.tween_interval(0.035)
	t.tween_callback(func() -> void: _battle_stage.position = Vector2.ZERO)


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
	_ui(&"cancel")
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
	_stop_music(BEAT * 1.5)
	_end_signature_theme(BEAT * 1.5)
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

	s.texture = _back_of(next) if _back_of(next) != null else next.sprite

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
## The height of a creature's own sprite, not of whatever frame it is showing.
## Attack frames can be taller (Kingstone Rail's raised rails: 216 against 128),
## and measuring the current frame made the creature's pixel size come out
## halved mid-attack, which shrank every effect sized from it.
func _base_height(s: Sprite2D) -> float:
	if s == _foe_sprite and _foe != null and _foe.sprite != null:
		return float(_foe.sprite.get_height())
	if s == _player_sprite and player_creature != null and player_creature.sprite != null:
		return float(player_creature.sprite.get_height())
	return float(s.texture.get_height())


func _zoom(s: Sprite2D) -> float:
	if s.texture == null:
		return 3.0
	var target: float = CREATURE_HEIGHT * _battle_size_of(s)
	var near_zoom: float = maxf(1.0, roundf(target / _base_height(s)))
	if s == _foe_sprite:
		return maxf(1.0, roundf(near_zoom * foe_perspective_scale * 2.0) / 2.0)
	# The player's side has PLAYER_ROOM of stage, counting the lower part that
	# sits behind the message box. A big form is capped to fit it. Measured on the creature's front art, not the current frame, so
	# the size never jumps between attack frames.
	if player_creature != null and player_creature.sprite != null:
		var used: Rect2i = _used_rect(player_creature.sprite)
		if used.size.x > 0 and used.size.y > 0:
			var fit: float = floorf(minf(PLAYER_ROOM.x / used.size.x, PLAYER_ROOM.y / used.size.y))
			return maxf(1.0, minf(near_zoom, fit))
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
	if not _idle_on:
		return
	if _idle_hold:
		# Attacks swap in their own frames; the idle overlay waits until they finish.
		_foe_overlay.visible = false
		_player_overlay.visible = false
		for s in [_foe_sprite, _player_sprite]:
			_set_breath(s, 0.0, 0.5)  # attack frames are drawn as they are
			if s.material is ShaderMaterial:
				s.material.set_shader_parameter("idle_glow", 0.0)  # the attack's own heat takes over
			# An attack with Mouth Heat steers its own smolder (the heat aura).
			if s.has_meta("smolder") and is_instance_valid(s.get_meta("smolder")) \
					and not s.get_meta("smolder").attack_owned:
				s.get_meta("smolder").active = false
				s.get_meta("smolder").visible = false
		return
	_idle_time += delta
	_overlay_clock += delta
	if _overlay_clock >= OVERLAY_STEP:
		_overlay_clock = 0.0
		_tick_overlay(_foe_sprite, _foe_overlay, _foe, true, 0.35)
		_tick_overlay(_player_sprite, _player_overlay, player_creature, _back_of(player_creature) == null, 0.0)
	# Read from the creature every frame rather than caching, so evolving mid-line
	# picks up the new form's breathing the moment the sprite swaps.
	_apply_idle(_player_sprite, _player_home, player_creature, 0.0)
	# The foe breathes a little behind the player so they never lock in step, and
	# its own period keeps the two from drifting back into time with each other.
	_apply_idle(_foe_sprite, _foe_home, _foe, 0.35)


## Show a creature's body without its moving part and lay the part on top, when
## it has one and is seen from the front. Otherwise the layer stays hidden.
func _setup_overlay(s: Sprite2D, overlay: Sprite2D, creature: CreatureData, front: bool) -> void:
	var has_body: bool = creature != null and front and creature.idle_overlay_body != null
	var has_overlay: bool = has_body and not creature.idle_overlay_frames.is_empty()
	overlay.visible = has_overlay
	if has_body:
		s.texture = creature.idle_overlay_body
	if has_overlay:
		overlay.texture = creature.idle_overlay_frames[-1]
		overlay.flip_h = s.flip_h
	# A live idle effect (fire spilling from a closed mouth) rides on the sprite.
	if s.has_meta("smolder"):
		var old: Node = s.get_meta("smolder")
		if is_instance_valid(old):
			old.queue_free()
		s.remove_meta("smolder")
	if creature != null and front and creature.idle_smolder != null:
		var smolder: Node2D = creature.idle_smolder.instantiate()
		s.add_child(smolder)
		s.set_meta("smolder", smolder)


## Pick this step's overlay frame from the breath: the part slides out as the
## creature breathes out and back in as it breathes in, flickers at full length,
## and now and then gives a quick extra flick so it never looks mechanical.
func _tick_overlay(s: Sprite2D, overlay: Sprite2D, creature: CreatureData, front: bool, phase: float) -> void:
	if creature == null or not front:
		overlay.visible = false
		return
	if creature.idle_overlay_body != null and s.texture != creature.idle_overlay_body:
		s.texture = creature.idle_overlay_body  # an attack just handed the sprite back
	if s.has_meta("smolder"):
		var smolder: Node2D = s.get_meta("smolder")
		if is_instance_valid(smolder):
			smolder.visible = true
			smolder.active = true
			smolder.facing = -1.0 if s.flip_h else 1.0
			smolder.breathe(_breath_wave(_idle_time / maxf(0.2, creature.idle_period) + phase))
	if creature.idle_overlay_frames.is_empty():
		overlay.visible = false
		return
	overlay.visible = true
	overlay.flip_h = s.flip_h
	var period: float = creature.idle_overlay_period if creature.idle_overlay_period > 0.0 else creature.idle_period
	if not creature.idle_overlay_fade_frames.is_empty():
		_loop_overlay(overlay, creature, fposmod(_idle_time / maxf(0.2, period) + phase, 1.0))
		return
	var breathe: float = _breath_wave(_idle_time / maxf(0.2, period) + phase)
	var out: float = 0.5 - 0.5 * breathe  # 1 when fully breathed out
	if _flick_left > 0.0:
		_flick_left -= OVERLAY_STEP
		out = 1.0
	elif randf() < 0.02:
		_flick_left = 0.28
	var frames: Array[Texture2D] = creature.idle_overlay_frames
	# Smallest frame when breathed in, longest when breathed out; it never vanishes.
	var index: int = clampi(int(round(out * (frames.size() - 1))), 0, frames.size() - 1)
	if index >= frames.size() - 1 and not creature.idle_overlay_flicker.is_empty() and randf() < 0.6:
		overlay.texture = creature.idle_overlay_flicker.pick_random()
	else:
		overlay.texture = frames[mini(index, frames.size() - 1)]


## One pass of an out-and-back overlay loop, t running 0 to 1: reform out
## (first 20%), hold at full length and flicker (to 48%), fade back in (to 72%),
## then rest: flickering between the rest frames (small flames billowing from
## the closed mouth) or, without any, holding the last fade frame.
func _loop_overlay(overlay: Sprite2D, creature: CreatureData, t: float) -> void:
	var grow: Array[Texture2D] = creature.idle_overlay_frames
	var fade: Array[Texture2D] = creature.idle_overlay_fade_frames
	if t < 0.2:
		overlay.texture = grow[mini(grow.size() - 1, int(t / 0.2 * grow.size()))]
	elif t < 0.48:
		if not creature.idle_overlay_flicker.is_empty() and randf() < 0.5:
			overlay.texture = creature.idle_overlay_flicker.pick_random()
		else:
			overlay.texture = grow[-1]
	elif t < 0.72:
		overlay.texture = fade[mini(fade.size() - 1, int((t - 0.48) / 0.24 * fade.size()))]
	elif not creature.idle_overlay_rest_frames.is_empty():
		overlay.texture = creature.idle_overlay_rest_frames.pick_random()
	else:
		overlay.texture = fade[-1]


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
	# Breathing vents: brightest when the breath is fully drawn in.
	if s.material is ShaderMaterial:
		var inhale: float = 0.5 + 0.5 * _breath_wave(_idle_time / maxf(0.2, creature.idle_period) + phase)
		s.material.set_shader_parameter("idle_glow", creature.idle_vent_glow * inhale)
	# A hand-drawn front loop takes precedence over procedural breathing. A real
	# back sprite keeps the old motion until its own sheet has been drawn.
	if not creature.idle_frames.is_empty() and (s == _foe_sprite or _back_of(creature) == null):
		var duration: float = maxf(0.2, creature.idle_period)
		var frame_count: int = creature.idle_frames.size()
		var frame_index: int = mini(frame_count - 1, int(floor(fposmod(_idle_time, duration) / duration * frame_count)))
		s.texture = creature.idle_frames[frame_index]
		s.scale = Vector2.ONE * _zoom(s)
		s.position = home
		_set_breath(s, 0.0, 0.5)
		return
	# Always whole-number zoom: a fractional stretch makes some art pixels wider
	# than others, which showed as a moving grid across the body.
	s.scale = Vector2.ONE * _zoom(s)
	s.position = home
	var depth: float = maxf(0.0, creature.idle_breath)
	if is_zero_approx(depth):
		# A creature set to breathe 0 stands completely still.
		_set_breath(s, 0.0, 0.5)
		return
	var period: float = maxf(0.2, creature.idle_period)
	var breathe: float = _breath_wave(_idle_time / period + phase)
	# The upper body rises whole art pixels drawing breath in and settles letting
	# it out, while the legs stay planted. depth is a share of the body's height,
	# so a deep breather on tall art lifts more pixels than a shallow one.
	var used: Rect2i = _used_rect(s.texture)
	var most: float = maxf(1.0, roundf(depth * used.size.y))
	var lift: float = roundf((breathe + 1.0) * 0.5 * most)
	# Taller and a little narrower on the inhale, like a chest filling.
	var widen: float = -roundf((breathe + 1.0) * 0.5 * roundf(creature.idle_breath_widen * used.size.x))
	var cut_row: float = used.position.y + roundf(used.size.y * clampf(creature.idle_breath_cut, 0.0, 1.0))
	_set_breath(s, lift, cut_row / s.texture.get_height(), widen)


## Sets a sprite's whole-pixel stretch (see creature_sprite.gdshader). A hit
## squash in progress (_squash) takes over from breathing until it ends.
func _set_breath(s: Sprite2D, lift: float, cut: float, widen: float = 0.0) -> void:
	if not (s.material is ShaderMaterial) or s.texture == null:
		return
	var used: Rect2i = _used_rect(s.texture)
	var th: float = float(s.texture.get_height())
	var tw: float = float(s.texture.get_width())
	if _squash.has(s):
		var q: Vector2 = _squash[s]
		widen = q.x
		lift = q.y
		cut = float(used.position.y + used.size.y) / th  # the whole body, feet planted
	var m: ShaderMaterial = s.material
	m.set_shader_parameter("breath_lift", lift)
	m.set_shader_parameter("breath_widen", widen)
	m.set_shader_parameter("breath_cut", cut)
	m.set_shader_parameter("breath_top", float(used.position.y) / th)
	m.set_shader_parameter("breath_mid", (used.position.x + used.size.x * 0.5) / tw)
	m.set_shader_parameter("breath_half", used.size.x * 0.5 / tw)


## The visible part of a texture, cached because breathing asks every frame.
var _used_rects: Dictionary = {}
func _used_rect(texture: Texture2D) -> Rect2i:
	if not _used_rects.has(texture):
		_used_rects[texture] = texture.get_image().get_used_rect()
	return _used_rects[texture]


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


## Screen pixels of sky painted above the backdrop, so a camera that tilts up
## (CameraShot.lift) sees more sky instead of the black behind the scene.
const SKY_ABOVE := 480.0
## Screen pixels of scene continued past the backdrop's sides and bottom, so a
## shot can pull back (zoom below 1) without showing black edges.
const SCENE_BEYOND := 320.0


## Plays a one-off sound and frees its player when it ends. Sounds started by
## an attack's cues are remembered so the strain's hush can silence them.
## `from` starts it partway in (seconds).
## The signature music. It is not a cue, so an attack's hush does not cut it
## (it only dips); it plays until the next turn or the battle's end.
const SIGNATURE_THEME_DB := -5.0
func _start_signature_theme() -> void:
	if signature_theme == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = signature_theme
	p.volume_db = SIGNATURE_THEME_DB
	p.bus = &"SFX"  # its accents land with the hits, not ducked under them
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
	_sig_theme = p


## Slide the signature music to a level: down for the held breath before the
## release, back up on the release.
func _signature_theme_level(db: float, seconds: float) -> void:
	if is_instance_valid(_sig_theme):
		create_tween().tween_property(_sig_theme, "volume_db", db, seconds)


## Fade the signature music out and bring the battle music back.
func _end_signature_theme(seconds: float) -> void:
	if not is_instance_valid(_sig_theme):
		return
	var p: AudioStreamPlayer = _sig_theme
	_sig_theme = null
	var t := create_tween()
	t.tween_property(p, "volume_db", -60.0, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(p.queue_free)
	if _phase != Phase.OVER:
		_duck_music(false)


## An interface or feedback sound by name. These are not attack cues: they are
## not hushed before a release, and they play straight to the Master bus so a
## line of text ticks does not make the music duck.
func _ui(sound: StringName, db: float = 0.0) -> void:
	var stream: AudioStream = UI_SOUNDS.get(sound)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = ui_sounds_db + db
	if sound == &"text":
		p.pitch_scale = randf_range(0.94, 1.06)  # a little different each letter, like a voice
	p.bus = &"Master"
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


## Moving onto a command with the keyboard or pad. Silent when the game itself
## places the focus at the start of a turn.
func _on_button_focus() -> void:
	if _phase == Phase.CHOOSING and not _quiet_focus:
		_ui(&"cursor")


func _play_sound(stream: AudioStream, db: float = 0.0, from: float = 0.0, pitch: float = 1.0) -> AudioStreamPlayer:
	if stream == null:
		return null
	var p := AudioStreamPlayer.new()
	_cue_players.append(p)
	p.tree_exiting.connect(func() -> void: _cue_players.erase(p))
	p.stream = stream
	p.volume_db = db
	p.pitch_scale = pitch
	# The SFX bus: music (when there is some) ducks under it, and the Master
	# limiter keeps stacked hits from clipping (default_bus_layout.tres).
	p.bus = &"SFX"
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play(from)
	return p


## The battle theme (Preston's "Galloping Triplet Pulse", made in Suno,
## 2026-09-29), looping on the Music bus, which ducks under attack sounds.
func _start_music() -> void:
	if battle_music == null:
		return
	if _music == null:
		_music = AudioStreamPlayer.new()
		_music.bus = &"Music"
		add_child(_music)
	if "loop" in battle_music:
		battle_music.loop = true
	_music.stream = battle_music
	_music.volume_db = -40.0
	_music.play()
	get_tree().call_group(&"area_music", &"battle_began")  # the route's music steps aside
	create_tween().tween_property(_music, "volume_db", music_db, 0.6)


## During a signature the battle music fades right out, and comes back after.
func _duck_music(down: bool) -> void:
	if _music == null or not _music.playing:
		return
	create_tween().tween_property(_music, "volume_db", -40.0 if down else music_db, 0.4 if down else 1.2)


func _stop_music(seconds: float) -> void:
	if _music == null or not _music.playing:
		return
	var t := create_tween()
	t.tween_property(_music, "volume_db", -40.0, seconds)
	t.tween_callback(_music.stop)
	get_tree().call_group(&"area_music", &"battle_ended")  # and comes back


func _hush_cues() -> void:
	# The signature music holds its breath too, then comes back on the release.
	_signature_theme_level(-18.0, 0.05)
	get_tree().create_timer(0.22).timeout.connect(_signature_theme_level.bind(SIGNATURE_THEME_DB, 0.05))
	for p in _cue_players.duplicate():
		if is_instance_valid(p) and p.playing:
			var t := create_tween()
			t.tween_property(p, "volume_db", -60.0, 0.03)
			t.tween_callback(p.queue_free)


## A move's camera shot: lean toward the attacker or target, push in, tilt up.
## The pan is clamped so the view never runs past the backdrop's sides or
## bottom, and past its top only into the painted sky.
func _camera_shot(shot: CameraShot, attacker: Sprite2D, target: Sprite2D) -> void:
	var center := Vector2(576, 324)
	var z: float = shot.zoom
	var pan := Vector2(0, shot.lift)
	if shot.look != CameraShot.Look.STAGE:
		var p: Vector2 = (attacker if shot.look == CameraShot.Look.ATTACKER else target).position
		pan += -shot.lean * z * (p - center)
	# How far the view can slide before a scene edge comes into view.
	var spare: Vector2 = center * (z - 1.0)
	pan.x = clampf(pan.x, -spare.x - SCENE_BEYOND * z, spare.x + SCENE_BEYOND * z)
	pan.y = clampf(pan.y, -spare.y - SCENE_BEYOND * z, spare.y + SKY_ABOVE * z)
	_tween_focus(pan, z, maxf(0.05, shot.seconds))
	_fade_cards(0.0 if shot.hide_cards else 1.0, 0.3)


func _fade_cards(alpha: float, seconds: float) -> void:
	for card in _cards:
		if is_instance_valid(card) and not is_equal_approx(card.modulate.a, alpha):
			create_tween().tween_property(card, "modulate:a", alpha, seconds)


## The HUD panel a card's label sits in (the direct child of this CanvasLayer).
func _hud_root(node: Node) -> CanvasItem:
	while node != null and node.get_parent() != self:
		node = node.get_parent()
	return node as CanvasItem


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
	_backdrop = river_landing
	# The painting continued past its edges for camera shots that pull back or
	# tilt up: its outermost row or column of pixels stretched outward. The
	# scene is horizontal bands (sky, banks, river), so a stretched edge column
	# reads as the same bands carrying on. The sky above is its flat top band.
	var sky := ColorRect.new()
	sky.name = "SkyAbove"
	sky.color = Color("1d333b")
	sky.position = Vector2(-SCENE_BEYOND, -SKY_ABOVE)
	sky.size = Vector2(1152 + 2 * SCENE_BEYOND, SKY_ABOVE)
	_focus_stage.add_child(sky)
	var w: int = RIVER_LANDING.get_width()
	var h: int = RIVER_LANDING.get_height()
	for edge in [
			[Rect2(0, 0, 1, h), Vector2(-SCENE_BEYOND * 0.5, 324), Vector2(SCENE_BEYOND, 4)],
			[Rect2(w - 1, 0, 1, h), Vector2(1152 + SCENE_BEYOND * 0.5, 324), Vector2(SCENE_BEYOND, 4)],
			[Rect2(0, h - 1, w, 1), Vector2(576, 648 + SCENE_BEYOND * 0.5), Vector2(4, SCENE_BEYOND)]]:
		var strip := Sprite2D.new()
		strip.texture = RIVER_LANDING
		strip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		strip.region_enabled = true
		strip.region_rect = edge[0]
		strip.position = edge[1]
		strip.scale = edge[2]
		_focus_stage.add_child(strip)
		_backdrop_edges.append(strip)

	# Creatures, projectiles, and damage numbers move together on this stage.
	# HUD controls stay on the CanvasLayer so impacts do not shake the interface.
	_battle_stage = Node2D.new()
	_battle_stage.name = "BattleStage"
	_focus_stage.add_child(_battle_stage)

	# Foe sits top right, player bottom left, so they face each other. The
	# sprite art faces right, so the foe is flipped.
	_foe_sprite = Sprite2D.new()
	# Replaced in start() once the foe's art is known: see _foot_home().
	_foe_home = Vector2(FOE_X, 190)
	_foe_sprite.position = _foe_home
	_foe_sprite.scale = Vector2.ONE * _zoom(_foe_sprite)
	_foe_sprite.flip_h = true
	_battle_stage.add_child(_foe_sprite)

	_player_sprite = Sprite2D.new()
	_player_home = Vector2(300, 335)
	_player_sprite.position = _player_home
	_player_sprite.scale = Vector2.ONE * _zoom(_player_sprite)
	_battle_stage.add_child(_player_sprite)

	# Idle overlay layers ride on each creature sprite, so they share its
	# position, breathing scale and hit flash.
	_foe_overlay = Sprite2D.new()
	_foe_overlay.visible = false
	_foe_sprite.add_child(_foe_overlay)
	_player_overlay = Sprite2D.new()
	_player_overlay.visible = false
	_player_sprite.add_child(_player_overlay)

	# One card per creature: name and HP number on top, the framed bar below.
	# The foe's card sits top left, the player's bottom right above the
	# commands, so the top right where the foe stands stays clear.
	var foe_card := _make_hp_card(FOE_CARD_AT)
	_foe_name = foe_card[0]
	_foe_hp_text = foe_card[1]
	_foe_bar = foe_card[2]

	var player_card := _make_hp_card(PLAYER_CARD_AT)
	_cards = [_hud_root(foe_card[0]), _hud_root(player_card[0])]
	_player_name = player_card[0]
	_player_hp_text = player_card[1]
	_player_bar = player_card[2]

	_add_hud_panel(MESSAGE_AT, MESSAGE_SIZE)
	_message = _make_label("", 22)
	_message.position = MESSAGE_AT + Vector2(45, 40)
	_message.size = Vector2(MESSAGE_SIZE.x - 90, 44)
	add_child(_message)

	_buttons = VBoxContainer.new()
	_buttons.position = COMMANDS_AT
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
	_catch_button.focus_entered.connect(_on_button_focus)
	utility.add_child(_catch_button)

	_flee_button = Button.new()
	_flee_button.text = "Flee"
	_flee_button.custom_minimum_size = Vector2(220, 48)
	_flee_button.add_theme_font_size_override("font_size", 18)
	_skin_command_button(_flee_button)
	_flee_button.pressed.connect(_on_flee_pressed)
	_flee_button.focus_entered.connect(_on_button_focus)
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


func _add_hud_panel(at: Vector2, dimensions: Vector2) -> Panel:
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
	return outer


## One health card in the usual slate-and-silt panel. Returns the name label,
## the HP number label and the bar, in that order.
func _make_hp_card(at: Vector2) -> Array:
	var card := _add_hud_panel(at, CARD_SIZE)
	var row := HBoxContainer.new()
	row.position = Vector2(22, 14)
	row.size = Vector2(CARD_SIZE.x - 44, 32)
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)
	var name_label := _make_creature_name()
	name_label.custom_minimum_size = Vector2(CARD_SIZE.x - 44 - 94, 32)
	row.add_child(name_label)
	var hp_label := _make_hp_number()
	row.add_child(hp_label)
	var holder := _make_bar_holder()
	holder.position = Vector2((CARD_SIZE.x - holder.size.x) * 0.5, 48)
	card.add_child(holder)
	return [name_label, hp_label, holder.get_node("Fill") as ProgressBar]


## The resting centre that puts a sprite's lowest visible pixel on a foot
## line, so creatures of any size stand on the same ground and a giant grows
## upward instead of down behind the HUD. Uses the sprite's current scale.
## Where your creature's feet go: below the top of the message box by a fixed
## share of its drawn height, so about three quarters of it shows above the box.
func _near_foot_y() -> float:
	if _player_sprite.texture == null:
		return MESSAGE_AT.y + 80.0
	var used: Rect2i = _player_sprite.texture.get_image().get_used_rect()
	return roundf(MESSAGE_AT.y + NEAR_HIDDEN * used.size.y * _player_sprite.scale.y)


func _foot_home(sprite: Sprite2D, foot: Vector2) -> Vector2:
	if sprite.texture == null:
		return foot
	var used: Rect2i = sprite.texture.get_image().get_used_rect()
	var bottom: float = used.position.y + used.size.y - sprite.texture.get_height() * 0.5
	return Vector2(foot.x, foot.y - bottom * sprite.scale.y)


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
