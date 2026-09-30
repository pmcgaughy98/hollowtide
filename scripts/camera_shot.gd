class_name CameraShot
extends Resource

## One camera move inside a drawn attack (Preston, 2026-09-29: the sky view on
## Kingstone Rail is "like another signature of the signature move"). When the
## attack reaches `frame`, the scene's camera eases to this framing over
## `seconds` and holds it until the next shot or the end of the attack.
## The camera never shows past the edge of the scene: the backdrop is continued
## past its edges in battle_screen, and pans are clamped to stay inside that.

enum Look { STAGE, ATTACKER, TARGET }

## The attack frame this shot starts on.
@export var frame: int = 0
## What the camera leans toward: the scene's middle, the attacker or the target.
@export var look: Look = Look.STAGE
## How far to lean toward it: 0 stays put, 1 puts it in the middle of the screen.
@export_range(0.0, 1.0, 0.05) var lean: float = 0.0
## Zoom: 1 is the normal view, above 1 pushes in, below 1 pulls back. The
## backdrop is continued far enough past its edges for 0.7.
@export_range(0.7, 2.0, 0.01) var zoom: float = 1.0
## Screen pixels to tilt up (the scene moves down), to see art rising into the sky.
@export var lift: float = 0.0
## Seconds the camera takes to get there. Short (0.1) snaps; long (1.5+) creeps.
@export var seconds: float = 0.4
## Fade the HP cards out for this shot (for a cinematic view they would cover).
@export var hide_cards: bool = false
