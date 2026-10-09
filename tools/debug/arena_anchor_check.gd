extends SceneTree
## The floating pass (Claude, 2026-10-09: "Warden looks like it's floating"): every form's feet
## sit on its body origin in every facing, and every walk cycle stands on one planted row so a
## lifted foot lifts without the body dropping (the second pass, same day: "still floating
## when it walks"); the shadow fits the body, under the body for long low forms.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_anchor_check.gd
## Stills to docs/creatures/arena-anchor-2026-10-09/.

const OUT := "res://docs/creatures/arena-anchor-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 1
	var worst := 0.0
	var worst_name := ""
	var checked := 0
	var bob := 0.0
	var bob_name := ""
	var wrong := 0
	var sunk := 0
	var deepest := 0.0
	var deepest_name := ""
	for line in arena.LINES.size():
		for stage in 3:
			arena._you = line; arena._you_stage = stage
			arena._rival = (line + 1) % arena.LINES.size()
			arena._new_match()
			await process_frame
			var f: Dictionary = arena._fighters[0]
			var art: Dictionary = f["art"]
			var sprite: Sprite2D = f["sprite"]
			for facing in arena.FACINGS:
				var texs: Array = [art["still"][facing]] + Array(art["walk"][facing])
				for tex in texs:
					arena._set_texture(f, tex)
					var bottom: float = sprite.position.y + sprite.offset.y - tex.get_height() * 0.5 + art["foot"][tex]   # where the anchored feet row lands, relative to the origin (a centred sprite draws its top at -h/2)
					var off: float = absf(bottom - 0.0)
					checked += 1
					if off > worst:
						worst = off
						worst_name = "%s %s" % [f["name"], facing]
				# The walk cycle stands on one planted row: a frame's own lowest pixel may sit above it (a lifted foot) or, for a wing tip dipping far below the stance, under it; a foot under it by more than the wing allowance is wrong.
				for tex in art["walk"][facing]:
					var own: float = arena._foot_row(tex)
					if own > art["foot"][tex] + 0.5:
						sunk += 1
						if own - art["foot"][tex] > deepest:
							deepest = own - art["foot"][tex]
							deepest_name = "%s %s" % [f["name"], facing]
						if own - art["foot"][tex] <= 4.0:
							wrong += 1
							print("WRONG: %s %s walk frame stands %.0f px below its cycle's planted row" % [f["name"], facing, own - art["foot"][tex]])
					if art["foot"][tex] - own > bob:
						bob = art["foot"][tex] - own
						bob_name = "%s %s" % [f["name"], facing]
	print("Anchors: %d textures across every form, facing and walk frame; the anchored feet row sits on the origin within %.1f px at worst (%s); every walk cycle stands on its planted stance: a lifted foot up to %.0f px above it (%s), %d frames with a wing or tail tip dipping under it (the deepest %.0f px, %s), %d frames wrong" % [checked, worst, worst_name, bob, bob_name, sunk, deepest, deepest_name, wrong])
	# The Warden walking south-east beside Windcut, and the Warden's walk cycle frame by frame, for the eye.
	arena.team_size = 1
	arena._you = 7; arena._you_stage = 2
	arena._rival = 8; arena._rival_stage = 1
	arena._new_match()
	await process_frame
	for f in arena._fighters:
		f["stun"] = 60.0
	var centre: Vector2 = arena.ARENAS[arena._arena]["floor"].get_center()
	arena._fighters[0]["body"].position = centre + Vector2(-50, 0)
	arena._fighters[1]["body"].position = centre + Vector2(50, 0)
	arena._fighters[0]["facing"] = "se"
	arena._fighters[1]["facing"] = "w"
	arena._fighters[0]["walk"] = 0.3
	arena._fighters[1]["walk"] = 0.3
	await process_frame
	root.get_texture().get_image().save_png(OUT + "warden_windcut.png")
	var me: Dictionary = arena._fighters[0]
	var strip := Image.create(8 * 70, 80, false, Image.FORMAT_RGBA8)
	strip.fill(Color(0.35, 0.35, 0.35, 1))
	var frames: Array = me["art"]["walk"]["se"]
	for k in frames.size():
		var tex: Texture2D = frames[k]
		var img: Image = tex.get_image()
		var foot: float = me["art"]["foot"][tex]
		# Draw each frame with its anchored feet row on one baseline (y = 64), and the baseline itself.
		strip.blit_rect_mask(img, img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(k * 70 + 4, int(64 - foot)))
	for x in strip.get_width():
		strip.set_pixel(x, 64, Color(1, 0.9, 0.4, 1))
	strip.save_png(OUT + "warden_walk_se_baseline.png")
	quit()
