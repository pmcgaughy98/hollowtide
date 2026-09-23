extends CharacterBody2D

## Walking speed in pixels per second.
## One tile is 16 pixels wide, so 80 works out to five tiles per second.
## This is exported, which means you can change it in the Inspector without
## touching this file.
@export var speed: float = 80.0


func _physics_process(_delta: float) -> void:
	# Reads the four movement actions and turns them into a direction.
	# The result is already normalized, so holding two keys to move diagonally
	# is not faster than moving straight. That is a real bug in a lot of
	# beginner movement code and this one line avoids it.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * speed

	# move_and_slide reads velocity, moves the body, and stops it against
	# anything solid. The tilemap collision is what it is stopping against.
	move_and_slide()
