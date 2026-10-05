class_name CreatureData
extends Resource

## One creature. Every creature in the game is one of these files sitting in
## data/creatures/. To add one, right click that folder in the FileSystem dock,
## choose New Resource, and pick CreatureData. No code needed.

## The essences. Electric and Ice were added by Preston on 2026-10-01; they go at
## the end so every existing creature and move keeps its saved value.
##
## This is a fixed list rather than free text on purpose. A text field would let
## a typo or an invented essence into the data. With a fixed list the Inspector
## gives you a dropdown and the bad value is simply not offerable.
##
## The essence cycle (Ember burns Bloom, Bloom breaks Stone, Stone dams Tide,
## Tide quenches Ember) is deliberately NOT encoded here. It is a combat rule,
## and it lives in EssenceChart, which BattleScreen uses for attack effectiveness.
enum Essence {
	EMBER,
	TIDE,
	STONE,
	GALE,
	BLOOM,
	HOLLOW,
	ELECTRIC,
	ICE,
}

## Dex number.
@export var id: int = 0

## The creature's name, as one field.
##
## This used to be split into gemstone and animal so an alliteration rule could
## be checked automatically. That rule is gone, because it is what made the old
## roster run dry and start repeating itself. Names are now free text and are
## yours to coin.
@export var creature_name: String = ""

@export var essence: Essence = Essence.EMBER

@export var sprite: Texture2D

## Optional rear view for the player side of battle.
@export var back_sprite: Texture2D

## Yours to write. Left blank deliberately rather than filled with invented lore.
@export_multiline var description: String = ""

## Legacy single move for older creature files. New creatures use moves below.
@export var move: MoveData

## Four selectable moves in battle, in display order.
@export var moves: Array[MoveData] = []

@export_group("Evolution")
## What this creature turns into. Leave empty for a creature that does not evolve.
##
## One link, not a list, and that is a design decision rather than a shortcut.
## A list would allow branching lines where one creature can become several
## things. A single link forward still allows the other bad shape, two creatures
## both pointing at the same destination, so CreatureRoster.validate_evolutions()
## rejects that across the whole roster.
##
## Both rules come from what you said you like about Digimon: the line should
## make sense, and nothing should share a destination.
@export var evolves_into: CreatureData
## Parts this body actually has. MoveGate reads this. Empty means the form
## has not been gated, and then only ultimates are refused.
@export var body_parts: PackedStringArray = []


@export_group("Base Stats")
## Placeholder values, all identical on purpose. Balance is a design decision
## and guessing at numbers here would quietly turn them into canon.
@export var base_hp: int = 60
@export var base_attack: int = 60
@export var base_defense: int = 60
@export var base_speed: int = 60


@export_group("Battle Idle")
## How deeply this creature breathes while it stands in battle, as a fraction of
## its own height. A light or restless creature wants this shallow and quick; a
## heavy, armoured or immovable one wants it deep and slow. Set it to 0 and the
## creature simply stands still.
##
## This is presentation, not balance, so it is safe to tune by eye. It lives on
## the creature rather than in the battle code so each form can be adjusted on
## its own in the Inspector, without touching a script.
@export var idle_breath: float = 0.02

## Seconds for one full breath, in and out.
@export var idle_period: float = 1.6

## A glow on the creature's fire-coloured parts (vents, seams, a furnace
## window) that brightens as it breathes in and dims as it breathes out.
## 0 is off; an attack's overheat peaks at 1, so keep this around 0.3 to 0.4
## (Preston, 2026-09-28: Ironvent's vents breathe, dimmer than Furnace Roar).
@export_range(0.0, 1.0, 0.05) var idle_vent_glow: float = 0.0
## Which colours glow when this creature heats up or idles with a glow:
## fire (furnace windows, molten seams) or jade (Oxbowarchon's green seams).
@export_enum("Fire", "Jade") var glow_kind: int = 0

## Where the breath stops, as a share of the body's height from the top of the
## art: everything above rises on the inhale, everything below (legs, feet)
## stays planted. Breathing moves whole art pixels, never a fractional stretch.
@export_range(0.0, 1.0, 0.01) var idle_breath_cut: float = 0.55
## How much narrower the body draws in on the inhale, as a share of its width
## (it grows taller and a little narrower, then settles), in whole art pixels.
## 0 keeps the width still.
@export_range(0.0, 0.1, 0.002) var idle_breath_widen: float = 0.0

## Optional hand-drawn loop. Every frame must share the same canvas and foot line.
## Battle uses these textures instead of procedural squash/stretch when present.
@export var idle_frames: Array[Texture2D] = []

@export_group("Idle Overlay")
## Optional moving part drawn over the front sprite while idle, such as
## Vitrecrag's mouth flame. When set, battle shows idle_overlay_body (the sprite
## without that part) and lays the part on top, running one loop: the frames
## play out (ending at full length), it holds and flickers between
## idle_overlay_flicker variants, then idle_overlay_fade_frames play it back in
## (a flame dissipating to an ember). Without fade frames it follows the breath
## instead, out on the exhale and in on the inhale. Attacks hide it.
@export var idle_overlay_body: Texture2D
@export var idle_overlay_frames: Array[Texture2D] = []
@export var idle_overlay_flicker: Array[Texture2D] = []
@export var idle_overlay_fade_frames: Array[Texture2D] = []
## Frames flickered between while resting at the end of the loop, such as small
## flames billowing out of a closed mouth. Empty rests on the last fade frame.
@export var idle_overlay_rest_frames: Array[Texture2D] = []
## Seconds for one full loop of the overlay. 0 follows the breath (idle_period).
@export var idle_overlay_period: float = 0.0
## Optional live idle effect riding on the front sprite, such as fire spilling
## from Vitrecrag's closed mouth (a scene with `facing`, `active`, `breathe()`).
## Works with idle_overlay_body alone, without any overlay frames.
@export var idle_smolder: PackedScene


@export_group("Aim Points")
## Where this creature's attacks come out of its body: a name ("mouth", "core",
## "vent", "horn") and a point in art pixels from the centre of the front sprite,
## with the art facing right as drawn. A shared move names the point it fires
## from (MoveData.aim), so the same move leaves Vitrecrag's mouth and another
## creature's vent without any new art (Preston, 2026-09-28).
@export var aim_points: Dictionary[String, Vector2] = {}


@export_group("Battle Size")
## How big this creature stands in battle, relative to every other creature.
## 1.0 is normal.
##
## Battle draws each creature at a fixed target height, so without this every
## creature ends up about the same size on screen no matter how large it is
## meant to be. A late evolution that should loom over its first stage needs a
## value above 1 here.
##
## The zoom is always a whole number, because a fractional one makes some
## pixels wider than others. That means only thresholds matter: for 100x100 art,
## 1.0 gives 3x and about 1.33 and up gives 4x. Nudging this to 1.1 will look
## like it did nothing, and that is the whole-number rule working as intended.
@export var battle_size: float = 1.0


## The Dex number padded for display, so 1 reads as "001".
var dex_number: String:
	get:
		return "%03d" % id


## Turns the stored essence into readable text, so HOLLOW reads as "Hollow".
func essence_name() -> String:
	return String(Essence.keys()[essence]).capitalize()
