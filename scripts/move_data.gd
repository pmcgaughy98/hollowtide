class_name MoveData
extends Resource

## One move. Every move is one of these files in data/moves/, the same way
## creatures live in data/creatures/. To add one, right click that folder in the
## FileSystem dock, choose New Resource, and pick MoveData.
##
## A creature with no move set uses Strike, which is still two constants in
## battle_screen.gd. Strike has no essence of its own and borrows its user's,
## which a file with a fixed essence field cannot say, so it stays as it is.

## How this action resolves. Old move files default to DAMAGE.
enum Kind { DAMAGE, GUARD, INTERRUPT }
enum Delivery { PROJECTILE, CONTACT }

@export var kind: Kind = Kind.DAMAGE

## A committed action can be canceled by a faster Interrupt hit. Quick moves
## and guards should leave this false.
@export var interruptible: bool = false

## Guard uses this fraction of the incoming hit's normal damage. 0.5 means
## half damage; a connecting hit still deals at least 1 HP.
@export_range(0.0, 1.0, 0.05) var guard_damage_fraction: float = 0.5

## Shown in battle as "Cinderhide used <this>!".
@export var move_name: String = ""

## The essence the move hits with. This, not the user's essence, is what the
## essence chart checks.
@export var essence: CreatureData.Essence = CreatureData.Essence.EMBER

## Placeholder until balance is decided. 40 matches Strike, so a move with the
## same essence as its user deals exactly what Strike would have.
@export var power: int = 40

## Uses available in one battle; zero means unlimited.
@export_range(0, 99) var max_uses: int = 0

## For projectile moves, the scene needs Trail and Burst CPUParticles2D;
## Ball (projectile) and Flash (contact burst) are optional Sprite2D children.
## When attack_frames are present, the scene plays at the target on the drawn
## hit frame: Burst, Flash, and an optional Impact sprite are used there.
@export var effect: PackedScene

@export_group("Battle Delivery")
## Contact moves carry the unchanged creature sprite toward the defender and
## play the effect at impact. Existing move files keep projectile delivery.
@export var delivery: Delivery = Delivery.PROJECTILE
@export_range(0.06, 0.30, 0.01) var contact_travel_seconds: float = 0.14

@export_group("Attack Frames")
## Optional same-form attack poses. Each frame keeps the creature on one fixed canvas.
## Battle plays these on the attacker instead of the usual lunge or projectile.
@export var attack_frames: Array[Texture2D] = []

## Seconds each drawn attack frame remains on screen.
@export_range(0.04, 0.3, 0.01) var attack_frame_seconds: float = 0.09

## Optional seconds for each drawn frame, in order. Frames past the end of this
## list use attack_frame_seconds. A pour needs a long wind-up and a held hit
## frame, which one shared speed cannot give.
@export var attack_frame_holds: Array[float] = []

## How far the drawn frames step toward the target, in pixels. 0 keeps the
## creature planted, for attacks that come out of its body instead of a lunge.
@export_range(0.0, 60.0, 1.0) var attack_lunge_px: float = 30.0

## Which drawn frame lands the hit, counting from 0. -1 keeps the usual rule:
## the second-to-last frame.
@export var attack_hit_frame: int = -1

## A frame where the creature plants itself and trembles before letting go,
## counting from 0. -1 for none.
@export var attack_brace_frame: int = -1

@export_group("Attack Emitter")
## Optional particle scene that pours out of the creature while the drawn frames
## play: glass from a mouth, sparks from a vent. Its particles should use local
## coordinates and be measured in the attack art's own pixels; battle scales
## and mirrors it to match the creature on screen.
@export var attack_emitter: PackedScene

## Where the emitter sits, in the attack frame's pixels from its centre, with
## the art facing right as drawn. Battle mirrors it for the foe.
@export var attack_emitter_offset: Vector2 = Vector2.ZERO

## First and last drawn frame (counting from 0) during which the emitter runs.
@export var attack_emit_frames: Vector2i = Vector2i(-1, -1)

## Screen shake when the emitter bursts open, on the same 0-25 scale as a hit's
## damage shake. 0 for none.
@export_range(0, 25) var attack_emit_shake: int = 0

## Optional scene lobbed from the emitter point onto the defender, over and over
## while the emitter runs, so the attack actually reaches its target. The first
## lob lands on the hit frame. Needs a Head sprite, a Trail and a one-shot Splash.
@export var attack_volley: PackedScene

## Seconds between lobs.
@export_range(0.05, 1.0, 0.01) var attack_volley_interval: float = 0.15
