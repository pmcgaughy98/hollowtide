class_name MoveData
extends Resource

## One move. Every move is one of these files in data/moves/, the same way
## creatures live in data/creatures/. To add one, right click that folder in the
## FileSystem dock, choose New Resource, and pick MoveData.
##
## A creature with no move set uses Strike, which is still two constants in
## battle_screen.gd. Strike has no essence of its own and borrows its user's,
## which a file with a fixed essence field cannot say, so it stays as it is.

## Shown in battle as "Cinderhide used <this>!".
@export var move_name: String = ""

## The essence the move hits with. This, not the user's essence, is what the
## essence chart checks.
@export var essence: CreatureData.Essence = CreatureData.Essence.EMBER

## Placeholder until balance is decided. 40 matches Strike, so a move with the
## same essence as its user deals exactly what Strike would have.
@export var power: int = 40

## The animation, as a scene. It needs a CPUParticles2D child named Trail,
## which runs while the effect flies at the target, and one named Burst, which
## fires once on contact. It may also have a Sprite2D named Ball, the drawn
## projectile, and one named Flash, the drawn burst. Open the scene and tune it
## in the Inspector; no code.
@export var effect: PackedScene
