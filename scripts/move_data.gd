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
@export_range(0.06, 0.8, 0.01) var contact_travel_seconds: float = 0.14

## Art pixels a contact attacker draws back during its brace frame before it
## charges: the wind-up, when no drawn anticipation pose exists. 0 for none.
@export_range(0.0, 12.0, 1.0) var contact_pullback_px: float = 0.0

## Art pixels past the usual stopping point, for strikes whose weapon sticks
## out beyond the body (a plate, a horn) and must actually reach the target.
@export_range(0.0, 60.0, 1.0) var contact_reach_px: float = 0.0

## Build-up chugs during the brace frame, like a locomotive getting up steam:
## the attacker rocks back and stomps forward this many times, each chug deeper
## and quicker than the last. 0 uses the plain tremble.
@export_range(0, 12) var contact_brace_chugs: int = 0

## Screen shake when a contact move lands, on the same 0-25 scale as a hit's
## damage shake, added on top of it. 0 for none.
@export_range(0, 25) var contact_impact_shake: int = 0

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

## Kickback when the emitter fires, in art pixels: on the first emit frame the
## body is thrown back this far, then settles back to its spot over the next
## frames (half as far each frame). For a cannon; 0 for none.
@export_range(0.0, 12.0, 1.0) var attack_recoil_px: float = 0.0

## Which drawn frame lands the hit, counting from 0. -1 keeps the usual rule:
## the second-to-last frame.
@export var attack_hit_frame: int = -1

## A frame where the creature plants itself and trembles before letting go,
## counting from 0. -1 for none.
@export var attack_brace_frame: int = -1

## "It's about to blow" (Preston, 2026-09-29): during this frame the body
## shakes harder and harder, the heat throbs faster and brighter with a growing
## rumble, then everything goes still for a held breath before the release.
## Give it a long hold (about a second). -1 for none.
@export var attack_strain_frame: int = -1

## Optional peak-overload pose for the strain (Vitrecrag's title-card look,
## Preston 2026-09-29): it flashes in on each throb, the flashes growing longer
## as the throbs speed up, and holds through the last stretch and the hush.
## Same canvas and registration as the attack frames.
@export var attack_strain_overload: Texture2D
## Frames to cycle through while the strain frame holds, so a long charge keeps
## moving instead of freezing on one drawing (Kingstone Rail's sphere turning
## between two drawings of its rings). Empty holds the strain frame still.
@export var attack_strain_loop: Array[Texture2D] = []
## Seconds each loop frame shows.
@export var attack_strain_loop_seconds: float = 0.12

@export_group("Back View")
## Frames for the same attack seen from behind, one per attack_frames entry, so
## the back view keeps the front's timing, hit frame, brace and emitter beats.
## When this is filled in, the player's side (or an ally beside it) plays the
## drawn timeline with its back sprite instead of the plain projectile.
@export var attack_back_frames: Array[Texture2D] = []

## Where the emitter sits on the back view, in frame pixels from its centre
## with the art facing right. From behind, a mouth is usually hidden on the far
## side of the body, so this is where the material first shows past the body.
@export var attack_back_emitter_offset: Vector2 = Vector2.ZERO

## Draw the emitter and volley behind the attacker on the back view, so they
## rise from behind the body instead of in front of it.
@export var attack_back_emitter_behind: bool = true

@export_group("Aim")
## Which of the attacker's aim points (CreatureData.aim_points) this move comes
## out of, such as "mouth". A plain projectile launches from there, and drawn
## frames without their own emitter offset use it too. Empty, or a name the
## creature does not have, keeps the old launch point.
@export var aim: String = ""


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

## Screen shake when the emitter bursts open, on the same scale as a hit's
## damage shake (25 is a heavy hit; signatures go higher). 0 for none.
@export_range(0, 60) var attack_emit_shake: int = 0

## Optional scene lobbed from the emitter point onto the defender, over and over
## while the emitter runs, so the attack actually reaches its target. The first
## lob lands on the hit frame. Needs a Head sprite, a Trail and a one-shot Splash.
@export var attack_volley: PackedScene

## Seconds between lobs.
@export_range(0.05, 1.0, 0.01) var attack_volley_interval: float = 0.15

## Optional ground flow (a scene with flow(start, end, px, advance, sustain),
## such as the lava river) that runs from the attacker to the defender's feet:
## it arrives on the hit frame and keeps flowing while the emitter runs.
@export var attack_river: PackedScene

## Where the river starts, in attack-frame pixels from centre, art facing right
## (usually the pool under a pour). The back view has its own point.
@export var attack_river_offset: Vector2 = Vector2.ZERO
@export var attack_back_river_offset: Vector2 = Vector2.ZERO


@export_group("Vents")
## A creature that vents heat from its body (Ironvent's Furnace Roar blowdown,
## Preston 2026-09-29). Points are art pixels from the frame's centre, art
## facing right; mirrored for the foe.
## Where the vents are on the wind-up and settle poses: each hisses a charge
## puff as the heat sweep reaches it, and smokes during the aftermath.
@export var vent_rest_points: PackedVector2Array = PackedVector2Array()
## Where the vents are on the release pose: each erupts a column there.
@export var vent_points: PackedVector2Array = PackedVector2Array()
## Which way each release vent blasts, one per vent_points entry: (0, -1) up,
## (-1, 0) back toward the tail. A missing entry means up.
@export var vent_directions: PackedVector2Array = PackedVector2Array()
## The blast art per vent, one per vent_points entry; a missing entry uses
## vent_column. Art for an up blast has its source at the bottom edge; art for
## a back blast has its source at the right (head-side) edge.
@export var vent_jets: Array[Texture2D] = []
## Optional animated rearward fan shared by horizontal spine vents. Each frame
## has the same transparent canvas and a fixed root near its right edge.
@export var vent_fan_frames: Array[Texture2D] = []
## Per vent: true draws the blast behind the body, so it rises out from behind
## the ridge (for a vent on the top edge); false draws it in front.
@export var vent_behind: Array[bool] = []
@export var vent_charge: Texture2D
@export var vent_column: Texture2D
@export var vent_smoke: Texture2D


@export_group("Impact")
## A white-hot flash of the whole scene on the hit frame (the HUD is never
## tinted), for a detonation such as Furnace Roar's trick shot.
@export var impact_flash: bool = false
## Screen shake on the hit frame of drawn-frame moves, on the damage-shake
## scale; 0 leaves only the usual hit shake.
@export_range(0, 60) var impact_shake: int = 0
## Hit-stop: seconds everything holds at the moment of impact, the target
## frozen white-hot in its hit pose while the flash and shake play on (Gemini
## VFX research, 2026-09-29: 40 to 80 ms, longer for heavy hits). -1 picks it
## automatically: 0.12 for a signature, 0.06 otherwise.
@export var impact_freeze: float = -1.0


@export_group("Cut-In")
## A big close-up of the attacker that sweeps across the screen for a moment,
## on a dark band, the way big moves flash a close-up (Ironvent's Furnace Roar,
## Preston 2026-09-28). Drawn at 3x on the stage, under the HUD, sliding in from
## the attacker's side. Art faces right as drawn; it is mirrored for the foe.
@export var attack_cut_in: Texture2D
## The drawn frame where it appears (counting from 0); -1 for none.
@export var attack_cut_in_frame: int = -1
## Seconds it holds in the middle before sliding out.
@export var attack_cut_in_seconds: float = 0.5


@export_group("Signature")
## A signature move takes over the whole scene (Preston, 2026-09-28: signatures
## are rare and must feel impactful in their own way). While the attacker winds
## up to the first emit frame, the scene dims; at the emit frame it flashes and
## is lit by signature_light until the effect cools. Drawn-frame moves only.
@export var signature: bool = false
## The light the scene takes while the signature erupts (a multiplier, so
## values above 1 brighten; the HUD is never tinted).
@export var signature_light: Color = Color(1.3, 0.95, 0.75)
## Optional scene-wide effect started at the emit frame, such as Vitrecrag's
## glass meltdown flood. Its script needs erupt(start, end, px, arrive, sustain),
## the same call as attack_river.
@export var signature_effect: PackedScene

## The signature's own stage (Preston, 2026-10-01): a full scene painted for
## this move, shown in place of the river while it plays. 448x256, drawn at 3x,
## so it covers the screen with room for camera shots that pull back.
@export var signature_stage: Texture2D

## The row of the stage painting (in its own pixels) where the far creature
## stands. The painting is shifted so this row meets that creature's feet.
@export var signature_stage_floor_y: int = 128
## Seconds the scene stays lit after the frames end, while the effect cools.
@export var signature_linger: float = 2.4


@export_group("Sound")
## Sounds played on chosen frames of a drawn attack: sound_cues[i] starts when
## the attack reaches frame sound_cue_frames[i] (Vitrecrag's meltdown buildup on
## the brace frame, the rupture on the release). Files live in assets/audio/sfx/.
@export var sound_cues: Array[AudioStream] = []
@export var sound_cue_frames: Array[int] = []
## Loudness per cue in decibels (0 is as recorded); missing entries are 0.
@export var sound_cue_db: Array[float] = []
## The creature's cry, played on a signature's title card the moment the
## close-up picture lands (Ironvent's roar, Vitrecrag's brass bellow).
@export var card_sound: AudioStream
@export var card_sound_db: float = 0.0
## One short sound per vent as it pressurizes during an overheat sweep, played
## the moment that vent lights. Each vent from tail to head is pitched a step
## higher, so the pressure is heard climbing (Ironvent, Preston 2026-09-30:
## the sound should follow the vents).
@export var vent_charge_sound: AudioStream
## One sound per vent as it blows on the release, in step with the jets.
@export var vent_jet_sound: AudioStream
## Loudness of the vent sounds in decibels. Several play at once, so keep it below 0.
@export var vent_sound_db: float = -6.0


@export_group("Camera")
## Camera moves during a drawn attack, each starting on its own frame: a tilt
## up to the sky (Kingstone Rail), a creeping push-in, a crash zoom on the hit.
## Empty keeps the usual attack framing. See scripts/camera_shot.gd.
@export var camera_shots: Array[CameraShot] = []


@export_group("Overheat")
## For a contact charge by a fire-cored creature: peak strength of a glow on its
## fire-coloured core pixels (0 is off, 1 is overheating). Each brace chug stokes
## it higher like a locomotive's firebox, the charge runs at full heat, the hit
## flares it, and it cools off through the recovery.
@export_range(0.0, 1.5, 0.05) var attack_overheat: float = 0.0

## Drawn-frame moves: fill the heat from the tail end to the head during the
## wind-up instead of all at once, its leading edge flaring vent by vent
## (Ironvent's Furnace Roar).
@export var overheat_sweep: bool = false

## Drawn-frame moves: the frame where the heat seals in, pulling its glow
## inward for a beat before the release on the first emit frame. -1 for none.
@export var overheat_seal_frame: int = -1


@export_group("Mouth Heat")
## For a creature with an idle_smolder (fire held in its mouth), what that heat
## does during this attack, front view only. At this frame the mouth opens and
## the trapped fire escapes in one gasp; from then on the flames become a dim
## heat aura around the emitter point, and when the frames end the mouth closes
## with a puff of smoke and the flames ease back. -1 leaves the smolder hidden
## during the attack, as before.
@export var smolder_gasp_frame: int = -1
## Frames (first, last) where the aura burns at full strength, such as the pour.
@export var smolder_surge_frames: Vector2i = Vector2i(-1, -1)
## Art pixels of the stream below the emitter that also give off heat wisps
## during the surge.
@export var smolder_aura_column: float = 0.0
