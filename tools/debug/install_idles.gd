extends SceneTree
## Installs the starter lines' animated idles and breathing (Claude, 2026-10-05).
## Run after slicing the RD sheets into assets/sprites/creatures/idle_2026_10_05/<file>/f0..f7.png
## and importing:  Godot --headless --path . --script res://tools/debug/install_idles.gd
## The front gets the 8-frame loop (shown on the opponent's side). Since 2026-10-06 the
## back view gets its own loop too (back_f0..back_f7.png, shown on the player's side);
## a form without back frames keeps the procedural breath, tuned per form. A front loop
## someone else installed from another folder (Codex's Kithflare tail-outline idle) is kept. idle_period is the loop length
## and the breath length. Glow: a faint idle glow on the lantern line (fire) and
## on Rampartroot's shoot (jade).

const DIR := "res://assets/sprites/creatures/idle_2026_10_05/"
# file: [idle_period, idle_breath, idle_breath_widen, idle_vent_glow, glow_kind]
const TUNING := {
	"103_kithflare": [1.2, 0.022, 0.0, 0.2, 0],
	"109_kithflare2": [1.4, 0.02, 0.0, 0.25, 0],
	"110_kithflare3": [1.8, 0.018, 0.006, 0.35, 0],
	"1701_tallowroot": [1.6, 0.02, 0.0, 0.0, 1],
	"1702_tallowroot2": [2.0, 0.016, 0.008, 0.0, 1],
	"1703_tallowroot3": [2.6, 0.012, 0.01, 0.12, 1],
	"001_rimefin": [1.5, 0.02, 0.0, 0.0, 0],
	"502_riftfin": [2.0, 0.018, 0.006, 0.0, 0],
	"503_scourmaw": [2.6, 0.014, 0.01, 0.0, 0],
}


func _initialize() -> void:
	for file in TUNING:
		var path: String = "res://data/creatures/%s.tres" % file
		var c: CreatureData = load(path)
		var frames: Array[Texture2D] = []
		for i in 8:
			var f: String = DIR + file + "/f%d.png" % i
			if ResourceLoader.exists(f):
				frames.append(load(f))
		var backs: Array[Texture2D] = []
		for i in 8:
			var f: String = DIR + file + "/back_f%d.png" % i
			if ResourceLoader.exists(f):
				backs.append(load(f))
		var t: Array = TUNING[file]
		var ours: bool = c.idle_frames.is_empty() or c.idle_frames[0].resource_path.begins_with(DIR)
		if frames.size() == 8 and ours:
			c.idle_frames = frames
		if backs.size() == 8:
			c.back_idle_frames = backs
		c.idle_period = t[0]
		c.idle_breath = t[1]
		c.idle_breath_widen = t[2]
		c.idle_vent_glow = t[3]
		c.glow_kind = t[4]
		ResourceSaver.save(c, path)
		print(c.creature_name, " front ", c.idle_frames[0].resource_path.get_base_dir().get_file() if not c.idle_frames.is_empty() else "none", " back frames ", c.back_idle_frames.size(), " period ", c.idle_period)
	quit()
